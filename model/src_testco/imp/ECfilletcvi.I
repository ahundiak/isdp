/* 
DESCRIPTION
    This command object auto fillets a composite curve or a linestring or
    some other linear object.  A GRcurve or a GRcompcurve class
    object is identified.  If the curve isn't a composite curve, then it is
    checked to see if the order is 2.  If it is not, then an error message
    is displayed and the user is asked to identify another linear curve.
    If all goes well, the curve is broken up into segments.  A radius
    value for the fillet is requested for each consecutive pair of
    segments.  Each pair of segments is filleted and a composite curve is
    returned.

OPERATION SEQUENCE
    1) "Identify linestring or composite curve"
        The curve is highlighted.

    2) "Accept / reject"
        Input a data button to accept or a reject-moveon to reject.

    3) "Enter fillet radius / (a)ll / (l)ast / [no radius]"
        The first two segments are highlighted.  Keyin a radius value for
        the two segments highlighted.  Keyin an "a" if you want all the 
        segments to have the last radius value entered.  Keyin a "l" if you
        want the highlighted segments to have the last radius value 
        entered.  Give a moveon or hit carriage return to take the default
        of no radius.

        The command stays here until all the segments' radius values have
        been entered.

    4) "Processing"
        The located curve is erased and the curve is now being filleted.

    5) "Enter a new radius [no radius]"
        Control comes here if an error occurred in the fillet processing.
        The segments are highlighted where the error occurred.
        The 3 error message that appear are:
        1) "Error in placing fillet: Enter new radius"
            Something went wrong in the placement of the fillet.

        2) "Fillet radius is too big: Enter new radius"
            The radius value given was too large.

        3) "Fillet curves overlap: Enter new radius"
            The radius value given caused the constructed fillet to overlap
            with the previous fillet.

    6) "Accept / reject"
        The new composite curve is highlighted and waiting to be accepted.
        If a data button is given, the old curve is deleted and the new
        composite curve is dehighlighted.  If a reject-moveon is given,
        the new composite curve is deleted and the old curve is
        redisplayed.

HISTORY

    dhm    03/23/88    creation date.  This command was taken in part from
                       a COB command written by sundar.
    dhm    03/30/88    added code to delete fil_crv_info[].subcrv_id and
                       fil_id on an error.
    dhm    09/07/88    added clear_vsd to the delete method.
    jBk    05/22/89    Changed from use of GRgetevent to co$getevent,
                       including modification to use value_type argument.
                       Changed from GRm_STRING mask to GRm_TEXT_VALUE.
    rlw    06/09/89    Modified such that lines in composites are just copied.
    dhm    10/28/91    Changed the locatable and displayable props on the 
                       subcrv's when command is suspended.
    hgb	   12/19/91    Display the linestring/composite curve when the user
                       exits the ACCEPT/REJECT fillet(s) with something other
                       than data point or reset point. 
    dhm    01/20/92    Erase original curve upon re-entering the ACCEPT/REJECT
                       state. Set the new composite curve display properties to
                       non-locatable and non-displayable whenever the command
                       is suspended.
    Sudha  07/05/93    Modified for BSprototypes ansification
    scw    08/14/94    clarified sleep method

*/

class implementation ECfilletcv;

#include "EMS.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "godef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"  /* for clear_vsd */
#include "OMminimum.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* gr$get_active_display */
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "emserr.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EC_M.h"
#include "EC_P.h"
#include "bsdistptpts.h"

from GRgraphics import GRdisplay, GRdelete, GRcopy;
from GRvg       import GRchgprops;
from GRcurve    import GRendpts, GRrevparm;
from GRbspline  import EMbctobz;
from GRowner    import GRget_number_components, GRget_components;

extern OMuword  OPP_GRcurve_class_id, OPP_GRcompcurve_class_id,
                OPP_GRlinestr_class_id, OPP_GRplanar_class_id;

/*
 * method  init
 */

method init(int type; char *str_ptr)
{
  IGRlong   status = OM_S_SUCCESS;

  me->state = 1;
  me->mytype = 0;
  me->hilite_subcrv = FALSE;
  me->num_subcrvs = 0;
  me->compcv_id = NULL_OBJID;

  status = om$vla_set_dimension(varray = me->fil_crv_info,
                                size = 20);
  EMomerr_hndlr(status, wrapup, "om$vla_set_dimension error");

wrapup:
  return (status);
}

/*
 * method wakeup
 */

method wakeup(int pos)
{
  enum GRdpmode     DisplayMode = GRhd;
  IGRint            j, inx;
  IGRlong           msg, status;
  IGRshort          action, props;

  status = OM_S_SUCCESS;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  action = 1;

  /*
   * Set the new composite curve's properties back to locatable and 
   * displayable.  dhm  1/20/92
   */

  if (me->compcv_id != NULL_OBJID)
  {
    status = om$send(msg = message GRvg.GRchgprops(&msg, &action, &props),
                     senderid = my_id,
                     targetid = me->compcv_id,
                     targetos = me->lc_obj.located_obj.osnum);
    EMomerr_hndlr(status, wrapup, "ECfilletcv: GRchgprops");
    EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
  }

  /*
   * Set the properties back to locatable and displayable on the subcrv's.
   *   dhm   10/28/91
   */

  for (j = 0; j < me->num_subcrvs; j++)
  {
    status = om$send(msg = message GRvg.GRchgprops(&msg, &action, &props),
                     senderid = my_id,
                     targetid = me->fil_crv_info[j].subcrv_id,
                     targetos = me->lc_obj.located_obj.osnum);
    EMomerr_hndlr(status, wrapup, "ECfilletcv: GRchgprops");
    EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
  }

  if (me->hilite_subcrv)
  {
    for (j = me->subcrv_inx; j < (me->subcrv_inx + 2); j++)
    {
       if (j == me->num_subcrvs)
         inx = 0;  /* can only occur if curve is closed */
       else
         inx = j;

       status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->lc_obj.module_info.md_env.matrix_type,
                           me->lc_obj.module_info.md_env.matrix,
                           &DisplayMode, &me->lc_obj.module_info.md_id),
                        targetid = me->fil_crv_info[inx].subcrv_id,
                        targetos = me->lc_obj.located_obj.osnum);
       EMomerr_hndlr(status, wrapup, "ECfilletcv: GRdisplay");
       EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
    }
  }

wrapup:
  return(status);
}

/*
 * method sleep
 */

method super_cmd.sleep (int pos)
{
   IGRlong    msg, status;
   IGRint     i;
   IGRshort   action, props;

    ex$message(msgnumb = EMS_P_ClearPromptField);
    ex$message(msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EM_M_ClearMessageField);

   status = OM_S_SUCCESS;
   props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   action = 0;

   status = dp$erase_hilite(msg = &msg);

  /*
   * Set the new composite curve's properties to non-locatable and
   * non-displayable.  dhm  1/20/92
   */

  if (me->compcv_id != NULL_OBJID)
  {
    status = om$send(msg = message GRvg.GRchgprops(&msg, &action, &props),
                     senderid = my_id,
                     targetid = me->compcv_id,
                     targetos = me->lc_obj.located_obj.osnum);
    EMomerr_hndlr(status, wrapup, "ECfilletcv: GRchgprops");
    EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
  }

   /*
    * Make the subcrv's non-locatable and non-displayable.  dhm  10/28/91
    */

   for (i = 0; i < me->num_subcrvs; i++)
   {
     status = om$send(msg = message GRvg.GRchgprops(&msg, &action, &props),
                      senderid = my_id,
                      targetid = me->fil_crv_info[i].subcrv_id,
                      targetos = me->lc_obj.located_obj.osnum);
     EMomerr_hndlr(status, wrapup, "ECfilletcv: GRchgprops");
     EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
   }

wrapup:
   return (status);
}

/*
 * method delete
 */

method delete (int  f_defer_flag)
{
   IGRlong    msg, status = OM_S_SUCCESS;
   IGRint     i;

   clear_vsd;   /* macro to clear out strings from the queue */

   for (i = 0; i < me->num_subcrvs; i++)
   {
     status = om$send(msg = message GRgraphics.GRdelete(&msg,
                            &me->lc_obj.module_info),
                      targetid = me->fil_crv_info[i].subcrv_id,
                      targetos = me->lc_obj.located_obj.osnum);
     EMomerr_hndlr(status, wrapup, "ECfilletcv: delete method\n");
     EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
   }

  status = om$send(mode = OM_e_wrt_message,
                   msg = OPPmargs,
                   targetid = my_id);
  EMomerr_hndlr(status, wrapup, "send to ECfilletcv's parent delete\n");

wrapup:
   return (status);
}

/*
 * method execute
 */

method execute ( int *response; char *response_data; int pos )
{
  IGRchar     errmsg[EMMAXERRMSG_LEN];
  IGRboolean  sts;
  IGRshort    level;
  IGRint      vla_size, i;
  IGRlong     status = OM_S_SUCCESS, msg, NumberOfBytes, BytesReceived;
  IGRlong     locate_mask, accept_mask, size, qsize, display_flag;
  enum GRdpmode       DisplayMode;
  struct GRlc_locate  attributes;
  struct GRevent      event, locate_event;
  struct IGRdisplay   display_attr;
  OM_S_CLASSLIST      rtree_classes, elig_classes;
  OMuword             rclass, eliclass;
/*  extern   IGRlong             GRgetevent(); */
  GRobjid             *subcrvs;
  struct GRid         *objects;
  struct GRvg_construct   const_list;
  struct IGRbsp_curve     *curve;

  #define ID_CURVE            1
  #define CHECK_CLOSED        3
  #define PREPROCESS_CURVES   4
  #define ENTER_RADIUS        5
  #define PROCESS             6
  #define FILLET_ERR_CONTINUE 7
  #define ACCEPT_REJECT       8
  #define DELETE              9

  ex$message(msgnumb = EM_M_AutoFilt);
  strcpy (errmsg, "ECfilletcv.execute");
  size = sizeof(struct GRevent);
  qsize = sizeof(event.event);
  objects = NULL;
  subcrvs = NULL;
  curve = NULL;

  NumberOfBytes = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg,
                         sizbuf = &NumberOfBytes,
                         buffer = &display_attr,
                         nret = &BytesReceived );
  EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);
 
  NumberOfBytes = sizeof(IGRshort);
  gr$get_active_level(msg = &msg,
                       sizbuf = &NumberOfBytes,
                       buffer = &level,
                       nret = &BytesReceived );
  EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

  const_list.msg        = &msg;
  const_list.class_attr = NULL;       /* use defaults */
  const_list.level      = level;
  const_list.display    = &display_attr;
  const_list.env_info   = &me->lc_obj.module_info;
  const_list.newflag    = FALSE;
  const_list.name       = NULL;
  const_list.geometry   = NULL;
  const_list.properties = GRIS_NEW | GRIS_LOCATABLE 
                                   | GRIS_DISPLAYABLE;

  do
  {
    switch(me->state)
    {
      case ID_CURVE:
      {
        locate_mask = GRm_DATA | GRm_BACK_UP;
        accept_mask = GRm_DATA;

        attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
        attributes.owner_action = LC_FLEX_COMP | LC_RIGID_OWNER;
        display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;

        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

        rclass = OPP_GRcurve_class_id;
        eliclass = OPP_GRcurve_class_id;

        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;

        lc$locate(rc = &msg,
              event1 = &locate_event,
              event2 = &event,
              mask1 = locate_mask,
              mask2 = accept_mask,
              eventsize= &size,
              display_flag = display_flag,
              unhilight_mode = GRhe,
              response = response,
              response_data = response_data,
              locate_key = EMS_P_IdLsOrCmpCrv,
              acc_key    = EMS_P_00038,
              relocate_key = EMS_I_CvNotLocated,
              attributes = &attributes,
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes,
              eligible_classes = &elig_classes);

        ex$message(msgnumb = EMS_S_ClearStatusField);

        if (!msg )
        {
          if ( (locate_event.response == EX_BACK_UP ) ||
               (locate_event.response == EX_RJT_MOVEON) )
             break;
          else
             return ( OM_S_SUCCESS );
        }

        me->lc_obj = event.located_object[0];

        me->state = CHECK_CLOSED;
        break;

      }  /* end case ID_CURVE */


      case CHECK_CLOSED:
      {
        IGRpoint    cv_spnt, cv_epnt;
        IGRdouble   dist_sqtol;

        status = BSEXTRACTPAR(&msg, BSTOLSQLENVEC, dist_sqtol);

        /*
         * Get the curve's endpoints to check for closed.
         */

        status = om$send(msg = message GRcurve.GRendpts(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             cv_spnt, cv_epnt),
                         targetid = me->lc_obj.located_obj.objid,
                         targetos = me->lc_obj.located_obj.osnum);
        EMomerr_hndlr(status, wrapup, "ECfilletcv: GRendpts");
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

        me->is_closed =(BSdistptpts(&msg, cv_spnt, cv_epnt) <= dist_sqtol);
        me->state = PREPROCESS_CURVES;
        break;

      }  /* end case CHECK_CLOSED */


      case PREPROCESS_CURVES:
      {
        IGRboolean  is_compcv = FALSE, is_segmented;
        IGRint      j, count, ret_ct, subcrv_count;
        OMuword     class_id; 

        me->num_subcrvs = 0;

        status = om$get_classid(objid = me->lc_obj.located_obj.objid,
                                osnum = me->lc_obj.located_obj.osnum,
                                p_classid = &class_id);
        EMomerr_hndlr(status, wrapup, errmsg);

        is_compcv = (class_id == OPP_GRcompcurve_class_id);

        if (is_compcv)
        {
          struct GRlc_info   lc_info;
          lc_info.module_info = me->lc_obj.module_info;

          status = om$send(msg = message GRowner.GRget_number_components(
                                 &msg, &count),
                           targetid = me->lc_obj.located_obj.objid,
                           targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, wrapup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

          objects = (struct GRid *) om$malloc(size = count *
                                          sizeof(struct GRid));
          EMerr_hndlr(!objects, *response, TERMINATE, wrapup);

          status = om$send(msg = message GRowner.GRget_components(&msg,
                                 &me->lc_obj.module_info, objects,
                                 count, &ret_ct, 0, (count-1)),
                           targetid = me->lc_obj.located_obj.objid,
                           targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, wrapup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

          for (i = 0; i < count; i++)
          {
            lc_info.located_obj = objects[i];
            status = EMget_the_geometry(&lc_info, TRUE, FALSE, FALSE,
                                        my_id, &curve, &msg);
            EMomerr_hndlr(status, wrapup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

            is_segmented = ((curve->order == 2) && (curve->num_poles > 2));

            if (curve)  free(curve);
            curve = NULL;

            if (is_segmented)
            {
              status = om$send(msg = message GRbspline.EMbctobz(
                                     &const_list, &subcrvs,
                                     &subcrv_count, &msg),
                               targetid = objects[i].objid,
                               targetos = objects[i].osnum);
              EMomerr_hndlr(status, cleanup, errmsg);
              EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

              vla_size = om$dimension_of(varray = me->fil_crv_info);
              if ( (me->num_subcrvs + subcrv_count) >= vla_size)
              {
                status = om$vla_set_dimension(varray = me->fil_crv_info,
                                       size = (vla_size + subcrv_count));
                EMomerr_hndlr(status, cleanup, errmsg);
              }

              for (j = 0; j < subcrv_count; j++, me->num_subcrvs++)
              {
                me->fil_crv_info[me->num_subcrvs].is_segment = TRUE;
                me->fil_crv_info[me->num_subcrvs].subcrv_id = subcrvs[j];
                me->fil_crv_info[me->num_subcrvs].fil_id = NULL;
              }

              if (subcrvs) free(subcrvs);
              subcrvs = NULL;

            }  /* end if segmented */
            else
            {
              vla_size = om$dimension_of(varray = me->fil_crv_info);
              if (me->num_subcrvs >= vla_size)
              {
                status = om$vla_set_dimension(varray = me->fil_crv_info,
                                              size = (vla_size + 5));
                EMomerr_hndlr(status, cleanup, errmsg);
              }

              status = om$send(msg = message GRgraphics.GRcopy(&msg,
                             &me->lc_obj.module_info,
                             &me->lc_obj.module_info,
                             &me->fil_crv_info[me->num_subcrvs].subcrv_id),
                            targetid = objects[i].objid,
                            targetos = objects[i].osnum);
              EMomerr_hndlr(status, cleanup, errmsg);
              EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

              me->fil_crv_info[me->num_subcrvs].is_segment = FALSE;
              me->fil_crv_info[me->num_subcrvs].fil_id = NULL;
              me->num_subcrvs++;
            }

          }  /* end for i loop */

          if (objects)  om$dealloc(ptr = objects);
          objects = NULL;

        }  /* end if is_compcv */

        else  /* not a composite curve */
        {
          status = EMget_the_geometry(&me->lc_obj, TRUE, FALSE, FALSE,
                                      my_id, &curve, &msg);
          EMomerr_hndlr(status, wrapup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

          is_segmented = ((curve->order == 2) && (curve->num_poles > 2));

          if (curve)  free(curve);
          curve = NULL;

          if (is_segmented)
          {
            status = om$send(msg = message GRbspline.EMbctobz(
                                   &const_list, &subcrvs, &subcrv_count,
                                   &msg),
                             targetid = me->lc_obj.located_obj.objid,
                             targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, wrapup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);

            vla_size = om$dimension_of(varray = me->fil_crv_info);
            if ( (me->num_subcrvs + subcrv_count) >= vla_size)
            {
              status = om$vla_set_dimension(varray = me->fil_crv_info,
                                     size = (vla_size + subcrv_count));
              EMomerr_hndlr(status, wrapup, errmsg);
            }

            for (i = 0; i < subcrv_count; i++, me->num_subcrvs++)
            {
              me->fil_crv_info[me->num_subcrvs].is_segment = TRUE;
              me->fil_crv_info[me->num_subcrvs].subcrv_id = subcrvs[i];
              me->fil_crv_info[me->num_subcrvs].fil_id = NULL;
            }

            if (subcrvs) free(subcrvs);
            subcrvs = NULL;

          }  /* end if is_segmented */
          else
          {
            ex$message(msgnumb = EMS_S_InsuffInp);
            me->state = ID_CURVE;
            break;
          }
        }  /* end if not composite curve */

        /*
         * Only one segment, ask for another curve.
         */

        if (me->num_subcrvs == 1)
        {
          ex$message(msgnumb = EMS_S_InsuffInp);
          me->state = ID_CURVE;
          break;
        }

        /*
         * Hilite the first two sub-curves in preparation for ENTER_RADIUS.
         */

        DisplayMode = GRhd;
        for (i = 0; i < 2; i++)
        {
          status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                         targetid = me->fil_crv_info[i].subcrv_id,
                         targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, cleanup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
        }

        me->hilite_subcrv = TRUE;
        me->subcrv_inx = 0;
        me->state = ENTER_RADIUS;
        break;

      }  /* end case PREPROCESS_CURVES */


      case ENTER_RADIUS:
      {
        IGRint       disp_crv;
/*
        ex$message(msgnumb = EMS_P_EntFillRd);
        accept_mask = GRm_DIST | GRm_TEXT_VALUE |
            GRm_BACK_UP | GRm_RJT_MOVEON;
        sts = GRgetevent(&msg, &accept_mask, &size, &event, response,
                         response_data);
*/
        sts = co$getevent (
            msg = &msg,
            event_mask = GRm_VALUE | GRm_TEXT_VALUE |
                GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_DISTANCE,
            msgnum = EMS_P_EntFillRd,
            response = response,
            response_data = response_data,
            event = &event
        );

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_S_ClearStatusField);

        if (!sts)
        {
          *response = TERMINATE;
          goto cleanup;
        }

        if (msg == GRw_no_value)
           event.response = EX_RJT_MOVEON;
        else if (msg != MSSUCC) goto cleanup;

        DisplayMode = GRhe;
        status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->lc_obj.module_info.md_env.matrix_type,
                           me->lc_obj.module_info.md_env.matrix,
                           &DisplayMode, &me->lc_obj.module_info.md_id),
                    targetid = me->fil_crv_info[me->subcrv_inx].subcrv_id,
                    targetos = me->lc_obj.located_obj.osnum);
        EMomerr_hndlr(status, cleanup, errmsg);
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

        switch (event.response)
        {
          case EX_VALUE:
          {
            me->last_radius = event.event.value;
            me->fil_crv_info[me->subcrv_inx].radius = me->last_radius;
            break;
          }

          case EX_RJT_MOVEON:
          {
            me->fil_crv_info[me->subcrv_inx].radius = 0;
            break;
          }  /* end case EX_RJT_MOVEON */

          case EX_STRING:
          {
            switch (toupper (event.event.keyin[0]))
            {
              case 'A':
              {
                disp_crv = me->subcrv_inx + 1;
                for (; me->subcrv_inx < me->num_subcrvs; me->subcrv_inx++)
                 me->fil_crv_info[me->subcrv_inx].radius = me->last_radius;

                if (!me->is_closed)
                  me->fil_crv_info[(me->subcrv_inx - 1)].radius = 0;

                if (me->is_closed && (disp_crv == me->num_subcrvs))
                  disp_crv = 0;

                me->hilite_subcrv = FALSE;
                me->state = PROCESS;
                goto display_curve;
              }  /* end case A */

              case 'L':
              {
                me->fil_crv_info[me->subcrv_inx].radius = me->last_radius;
                break;
              } /* end case L */

              default:
                goto wrapup;  /* don't want to delete subcrvs */

            }  /* end switch event.event.keyin[0] */

            break;
          }  /* end case EX_STRING */


          case EX_BACK_UP:
          {
            if (me->subcrv_inx == 0)
            {
              disp_crv = me->subcrv_inx + 1;
              me->hilite_subcrv = FALSE;
              me->state = DELETE;
              goto display_curve;
            }
            else
            {
              if ( me->subcrv_inx == (me->num_subcrvs - 1) )
                 disp_crv = 0;  /* can only occur if curve is closed */
              else
                 disp_crv = me->subcrv_inx + 1;

              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->lc_obj.module_info.md_env.matrix_type,
                           me->lc_obj.module_info.md_env.matrix,
                           &DisplayMode, &me->lc_obj.module_info.md_id),
                    targetid = me->fil_crv_info[disp_crv].subcrv_id,
                    targetos = me->lc_obj.located_obj.osnum);
              EMomerr_hndlr(status, cleanup, errmsg);
              EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

              DisplayMode = GRhd;
              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->lc_obj.module_info.md_env.matrix_type,
                           me->lc_obj.module_info.md_env.matrix,
                           &DisplayMode, &me->lc_obj.module_info.md_id),
                    targetid = me->fil_crv_info[me->subcrv_inx].subcrv_id,
                    targetos = me->lc_obj.located_obj.osnum);
              EMomerr_hndlr(status, cleanup, errmsg);
              EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

              me->subcrv_inx--;
              disp_crv = me->subcrv_inx;
              goto display_curve;
            }
          }  /* end case EX_BACK_UP */


          default:
            goto wrapup;  /* don't want to delete subcrvs */

        }  /* end switch event.response */

        me->subcrv_inx++;

        if ( me->subcrv_inx == (me->num_subcrvs - 1) )
        {
          if (me->is_closed)
          {
            disp_crv = 0;
            DisplayMode = GRhd;
          }
          else
          {
            disp_crv = me->subcrv_inx;
            me->fil_crv_info[me->subcrv_inx].radius = 0;
            me->hilite_subcrv = FALSE;
            me->state = PROCESS;
          }
        }
        else if (me->subcrv_inx == me->num_subcrvs)
        {
          disp_crv = 0;
          me->hilite_subcrv = FALSE;
          me->state = PROCESS;
        }
        else
        {
          disp_crv = me->subcrv_inx + 1;
          DisplayMode = GRhd;
        }

      display_curve:
        status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->lc_obj.module_info.md_env.matrix_type,
                           me->lc_obj.module_info.md_env.matrix,
                           &DisplayMode, &me->lc_obj.module_info.md_id),
                    targetid = me->fil_crv_info[disp_crv].subcrv_id,
                    targetos = me->lc_obj.located_obj.osnum);
        EMomerr_hndlr(status, cleanup, errmsg);
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

        break;

      }  /* end case ENTER_RADIUS */


      case PROCESS:
      {
        IGRlong    EMfilletcv();
        IGRint     bad_index;

        ex$message(msgnumb = EMS_I_00003);

        status = EMfilletcv(&msg, &const_list, me->is_closed,
                            me->num_subcrvs, me->fil_crv_info,
                            &me->compcv_id, &bad_index);
        EMomerr_hndlr(status, cleanup, "ECfilletcv.process : EMfilletcv");
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

        /*
         * Check for error in fillet processing
         */

        if (msg == EMS_ErrorFillet)
        {
          ex$message(msgnumb = EMS_S_ErrorFltPl);
          me->subcrv_inx = bad_index;
          me->state = FILLET_ERR_CONTINUE;
        }
        else if (msg == EMS_RadiusTooBig)
        {
          ex$message(msgnumb = EMS_S_FiltTooBig );
          me->subcrv_inx = bad_index;
          me->state = FILLET_ERR_CONTINUE;
        }
        else if (msg == EMS_OverlapCurves)
        {
          ex$message(msgnumb = EMS_S_FiltOvlap);
          me->subcrv_inx = bad_index;
          me->state = FILLET_ERR_CONTINUE;
        }
        else
          me->state = ACCEPT_REJECT;

        break;
      }  /* end case PROCESS */


      case FILLET_ERR_CONTINUE:
      {
        IGRint    inx;

        DisplayMode = GRhd;
        for (i = me->subcrv_inx; i < (me->subcrv_inx + 2); i++)
        {
          if (i == me->num_subcrvs)
            inx = 0;  /* can only occur if curve is closed */
          else
            inx = i;

          status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->lc_obj.module_info.md_env.matrix_type,
                                me->lc_obj.module_info.md_env.matrix,
                                &DisplayMode, 
                                &me->lc_obj.module_info.md_id),
                           targetid = me->fil_crv_info[inx].subcrv_id,
                           targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, cleanup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
        }
        me->hilite_subcrv = TRUE;
/*
        ex$message(msgnumb = EMS_P_EntFiltRad);
        accept_mask = GRm_DIST | GRm_BACK_UP | GRm_RJT_MOVEON;
        sts = GRgetevent(&msg, &accept_mask, &size, &event, response,
                         response_data);
*/
        sts = co$getevent (
            msg = &msg,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_DISTANCE,
            msgnum = EMS_P_EntFiltRad,
            response = response,
            response_data = response_data,
            event = &event
        );

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_S_ClearStatusField);

        if (!sts)
        {
          *response = TERMINATE;
          goto cleanup;
        }

        if ( (msg == GRw_no_value) || (event.response == EX_RJT_MOVEON) )
        {
          me->fil_crv_info[me->subcrv_inx].radius = 0;
          me->state = PROCESS;
        }
        else if (msg != MSSUCC) goto cleanup;

        if (event.response == EX_VALUE)
        {
          me->fil_crv_info[me->subcrv_inx].radius = event.event.value;
          me->state = PROCESS;
        }
        else if (event.response == EX_BACK_UP)
        {
          if (me->subcrv_inx == 0)
          {
            me->state = DELETE;
          }
          else
          {
            if ( me->subcrv_inx == (me->num_subcrvs - 1) )
               i = 0;  /* can only occur if curve is closed */
            else
               i = me->subcrv_inx + 1;

            DisplayMode = GRhe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->lc_obj.module_info.md_env.matrix_type,
                                me->lc_obj.module_info.md_env.matrix,
                                &DisplayMode, 
                                &me->lc_obj.module_info.md_id),
                             targetid = me->fil_crv_info[i].subcrv_id,
                             targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            me->subcrv_inx--;
            DisplayMode = GRhd;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->lc_obj.module_info.md_env.matrix_type,
                                me->lc_obj.module_info.md_env.matrix,
                                &DisplayMode, 
                                &me->lc_obj.module_info.md_id),
                             targetid = me->fil_crv_info
                                        [me->subcrv_inx].subcrv_id,
                             targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            me->state = ENTER_RADIUS;
            break;
          }
        }  /* end event.response == EX_BACK_UP */

        /*
         * Dehilite the two subcrvs.
         */

        DisplayMode = GRhe;
        for (i = me->subcrv_inx; i < (me->subcrv_inx + 2); i++)
        {
          if (i == me->num_subcrvs)
            inx = 0;  /* can only occur if curve is closed */
          else
            inx = i;

          status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->lc_obj.module_info.md_env.matrix_type,
                                me->lc_obj.module_info.md_env.matrix,
                                &DisplayMode, 
                                &me->lc_obj.module_info.md_id),
                           targetid = me->fil_crv_info[inx].subcrv_id,
                           targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, cleanup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
        }
        me->hilite_subcrv = FALSE;

        /*
         * If the event wasn't value or backup, then return to the
         * command server.
         */

        if (event.response == GR_UNKNOWN_TYPE)
           goto wrapup;

        break;
      }  /* end FILLET_ERR_CONTINUE */


      case ACCEPT_REJECT:
      {
        /*
         * Erase the original curve.
         */

        DisplayMode = GRbe;
        status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                        targetid = me->lc_obj.located_obj.objid,
                        targetos = me->lc_obj.located_obj.osnum);
        EMomerr_hndlr(status, cleanup, errmsg);
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

        /*
         * Display the new composite curve in hilite.
         */

        DisplayMode = GRbdhd;
        status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                       targetid = me->compcv_id,
                       targetos = me->lc_obj.located_obj.osnum);
        EMomerr_hndlr(status, cleanup, errmsg);
        EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

        ex$message(msgnumb = EMS_S_ClearStatusField);
/*
        ex$message(msgnumb = EMS_P_00038);
        accept_mask = GRm_DATA | GRm_RJT_MOVEON;
        sts = GRgetevent(&msg, &accept_mask, &size, &event, response,
                         response_data);
*/
        sts = co$getevent (
            msg = &msg,
            event_mask = GRm_DATA | GRm_RJT_MOVEON,
            msgnum = EMS_P_00038,
            response = response,
            response_data = response_data,
            event = &event
        );

        ex$message(msgnumb = EMS_P_ClearPromptField);

        if (!sts)
        {
          *response = TERMINATE;
          goto wrapup;
        }
        if (msg != MSSUCC) goto cleanup;

        switch (event.response)
        {
          case EX_DATA:
          {
            status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                   &me->lc_obj.module_info),
                            targetid = me->lc_obj.located_obj.objid,
                            targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
      
            DisplayMode = GRhe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                       targetid = me->compcv_id,
                       targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            break;
          }  /* end case EX_DATA */

          case EX_RJT_MOVEON:
          {
            DisplayMode = GRbehe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                       targetid = me->compcv_id,
                       targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                   &me->lc_obj.module_info),
                             targetid = me->compcv_id,
                             targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
            me->compcv_id = NULL;

            DisplayMode = GRbd;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id),
                       targetid = me->lc_obj.located_obj.objid,
                       targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            break;
          }  /* end case EX_RJT_MOVEON */

          default:

            /*
             * Erase the new composite curve.  dhm  1/20/92
             */

            DisplayMode = GRbehe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                   &me->lc_obj.module_info.md_env.matrix_type,
                                   me->lc_obj.module_info.md_env.matrix,
                                   &DisplayMode, 
                                   &me->lc_obj.module_info.md_id),
                             targetid = me->compcv_id,
                             targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            /* make sure the linestring/composite curve is displayed */
            DisplayMode = GRbd;
            status = om$send(msg = message GRgraphics.GRdisplay ( &msg,
                             &me->lc_obj.module_info.md_env.matrix_type,
                             me->lc_obj.module_info.md_env.matrix,
                             &DisplayMode, 
                             &me->lc_obj.module_info.md_id ),
                        targetid = me->lc_obj.located_obj.objid,
                        targetos = me->lc_obj.located_obj.osnum);
            EMomerr_hndlr(status, cleanup, errmsg);
            EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);

            goto wrapup;  /* don't want to delete compcv or subcrvs */

        }  /* end switch event.response */

        me->state = DELETE;
        break;

      }  /* end case ACCEPT_REJECT */


      case DELETE:
      {
        for (i = 0; i < me->num_subcrvs; i++)
        {
          status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                 &me->lc_obj.module_info),
                           targetid = me->fil_crv_info[i].subcrv_id,
                           targetos = me->lc_obj.located_obj.osnum);
          EMomerr_hndlr(status, cleanup, errmsg);
          EMerr_hndlr(EMis_error(msg), *response, TERMINATE, cleanup);
          me->fil_crv_info[i].subcrv_id = NULL;
        }

        me->compcv_id = NULL_OBJID;
        me->num_subcrvs = 0;
        me->state = ID_CURVE;
        break;
      }


      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto cleanup;

    }  /* end switch */

  }  while (TRUE);


cleanup:
   for (i = 0; i < me->num_subcrvs; i++)
   {
     if (me->fil_crv_info[i].subcrv_id)
     {
       status = om$send(msg = message GRgraphics.GRdelete(&msg,
                              &me->lc_obj.module_info),
                        targetid = me->fil_crv_info[i].subcrv_id,
                        targetos = me->lc_obj.located_obj.osnum);
       EMomerr_hndlr(status, wrapup, errmsg);
       EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);
       me->fil_crv_info[i].subcrv_id = NULL;
     }

     if (me->fil_crv_info[i].fil_id)
     {
       status = om$send(msg = message GRgraphics.GRdelete(&msg,
                              &me->lc_obj.module_info),
                        targetid = me->fil_crv_info[i].fil_id,
                        targetos = me->lc_obj.located_obj.osnum);
       EMomerr_hndlr(status, wrapup, errmsg);
       EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);
       me->fil_crv_info[i].fil_id = NULL;
     }

   }

   if (me->compcv_id != NULL_OBJID)
   {
     status = om$send(msg = message GRgraphics.GRdelete(&msg,
                            &me->lc_obj.module_info),
                      targetid = me->compcv_id,
                      targetos = me->lc_obj.located_obj.osnum);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(msg), *response, TERMINATE, wrapup);
   }

   me->compcv_id = NULL_OBJID;
   me->num_subcrvs = 0;
   status = OM_E_ABORT;
   me->state = ID_CURVE;

wrapup:
   if (objects)  om$dealloc(ptr = objects);
   objects = NULL;
   if (subcrvs) free(subcrvs);
   subcrvs = NULL;
   if (curve)  free(curve);
   curve = NULL;
   return(status);
}

end implementation ECfilletcv;
