/*
Abstract
  This command object scans the r-tree for curves that are within the
  tolerances from the previous curve until no more are found.  It then
  links the accepted group of curves together to form a composite curve.
  It first displays the connect and search tolerances in the status field
  and prompts the user for whether or not they want to extend to an 
  intersect point if there is a gap between some of the curves.  The 
  connect tolerance can be changed by changing the base tol and the search
  tolerance can be changed by changing the chord height tol.  Next, it
  prompts the user for the beginning curve and the end point to start
  the search from.  It then scans for the curves.  If it finds a place 
  where more than one path can be taken, it prompts the user to accept the 
  curve along the path desired.  Finally, all the curves within tolerance
  are highlighted and the user can then backup to reject one on the end,
  give a moveon to accept all curves, or a data point to continue scanning.
  When all curves are accepted, they are linked together to form a 
  composite curve.

Notes

Return Codes

History

12 Jun 1989 jBk Changed wakeup to send to self wrt parent.

22 May 1989 jBk Replaced occurrences of GRm_STRING with
                GRm_TEXT_VALUE.

                Replaced invocations of GRgetevent with uses of
                co$getevent.

  rlw   05/08/87    modified due to renaming EMinitcc to GRconstruct
  rlw   05/13/87    Removed inclusion of EMlc.h
  gk    05/14/87    Changed the locate prompt
  dhm   11/18/87    Changed to extend to intersection for gaps.  Rewrote
                    most of the command object.
  dhm   07/21/88    Changed to call the functions EMclosecomp and
                    EMmaintfirst.
  pp    11/11/88    Modified code to not locate associative wireframe elements
                    while making the composite curve.
  pp    09/29/89    Changed arguments to EFshort_cvt to prevent potential
                    memory problems.
  jsd   12/09/92    UMS compliance
  Sudha 06/21/93    modified for BSprototype ansification
  Carlos M. Diaz 07/29/93 added conversion to profile.  
  Carlos M. Diaz 12/21/93 removed GRrevparam, it is unnecessary and messes
  		    up profiles.
  Carlos M. Diaz 01/11/94 added support for SKbsplines.
  Carlos M. Diaz 01/31/94 added a locate handler to solve problem of locating
  		    profiles but not components of composite curves nor edges
  		    or boundaries of solids.
  scw   08/14/94    Clarified sleep method
*/

class implementation EClink;

#include "EMScc.h"
#include <stdio.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "grdpbmacros.h" /* gr$get_associative_flag */
#include "griodef.h"
#include "grio.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grerr.h"     /* GRILLDEFINITION */
#include "msdef.h"     /* MS message codes */
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "codef.h"
#include "griomacros.h" /* co$getevent */
#include "emserr.h"
#include "emsdig.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "EMSaction.h" /* Structure definition for action handler */
#include "EMSasdef.h" /* For ASSOC */
#include "emsdef.h"
#include "msmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "bsdistptpt.h"
#include "EMdtmacros.h"
#include "comisc.h"
#include "SKdef.h"
#include "SKmacros.h"


from GRgraphics  import GRgetprops, GRdisplay, GRconstruct, GRcopy, GRdelete;
from GRvg        import GRgeomprops, GRpostabsg;
from GRcurve     import EMbuild_stack, GRrevparm, GRendpts;
from GRcompcurve import EMaddtocomp, EMmakecomp;
from GRowner     import GRdrop, GRget_components;
from GRconnector import GRdisconn, GRrigidconn;
from SKgeometry import SKgetmgr;
from SKmgr import GRremove_components;
from EMSdatpln import EMget_pln_info;

%safe
short _SM_KLUDGE_TO_PREVENT_MERGE_MANIA = 0;
%endsafe

extern OMuword      OPP_GRcompcurve_class_id, OPP_GRcurve_class_id,
			OPP_SKline_class_id, OPP_SKarc_class_id, 
			OPP_SKcompcurve_class_id,OPP_SKbspline_class_id;

#if ASSOC
extern OMuword      OPP_ASnode_class_id;
#endif

/*------------------------------------------------------ */

method init(int type; char *str_ptr)
{

  IGRlong   status;

  status = om$vla_set_dimension(varray = ME.EClink->located_obj,
      size = 20);
  EMomerr_hndlr(status, wrapup, "om$vla_set_dimension error");

  status = om$send(mode = OM_e_wrt_parent,
      msg = message EClink.init(type, str_ptr),
      targetid = my_id);
  EMomerr_hndlr(status, wrapup, "parent EClink.init error");
wrapup:
  return (status);
}


method wakeup(int pos)
{
  enum GRdpmode     DisplayMode = GRhd;
  IGRint            j;
  IGRlong           msg, status;

  gr$get_associative_flag( buffer = &me->associative );
  GRdisplay_associative_button(me->associative);

  status = om$send (
      mode = OM_e_wrt_parent,
      msg = message EClink.wakeup (pos),
      targetid = my_id
      );

  if (EMSokay (status) AND me->num_comp > 0)
  {
    for (j = 0; j < me->num_comp; j++)
    {
      status = om$send(msg = message GRgraphics.GRdisplay(&msg,
          &me->ModuleInfo.md_env.matrix_type,
          me->ModuleInfo.md_env.matrix,
          &DisplayMode, &me->ModuleInfo.md_id),
          targetid = me->located_obj[j].located_obj.objid,
          targetos = me->located_obj[j].located_obj.osnum);
      EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
      EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
    }
  }

wrapup:
  return(status);

}


method super_cmd.sleep(int pos)
{
  IGRlong           msg, status;

  status = OM_S_SUCCESS;

  /*
   * Toggle the associative flag color off.  Doree  12/7/93
   */

  if (me->associative)
      GRdisplay_associative_button(FALSE);

  status = dp$erase_hilite(msg = &msg);
  EMomerr_hndlr(status, wrapup, "EClink: dp$erase_hilite");
  EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

wrapup:
  return(status);

}


method execute ( int *response; char *response_data; int pos )
{
  IGRchar             prompt[MAX_PROMPT_SIZE];
  IGRlong             status, msg, eventmask, eventmask1, j, i, error,
      num_elements, size, display_flag, bytes_ret;
  enum GRdpmode       DisplayMode;
  struct GRlc_locate  attributes;
  struct GRevent      event;
  IGRboolean          logstat, no_last_prompt = FALSE;
  IGRpoint            search_pnt;
  IGRdouble           dist, uor;
  OMuword             loc_obj_class_id, rclass[5], eliclass;
  OM_S_CLASSLIST      rtree_classes, elig_classes;
  OM_S_MESSAGE        post_scan_msg;
  struct GRid         comp_curve;
  struct var_list     list[2];
  IGRchar             header[80];
  struct GRcurve_EMbuild_stack_Msg    post_scan_arglist;
  extern  IGRlong     EFshort_cvtn();
  extern  void         EMgetendpnt();
  IGRboolean	do_profiles = NULL;
  GRobjid profile_grid;

#define DEBUG     0

#define INIT         0
#define SELECT_MODE  10
#define ID_OBJ       1
#define PRE_PROCESS  2
#define MAKE_MSG     21
#define PROCESS      3
#define BACKUP_MAYBE 4

  ex$message (msgnumb = EM_M_AutoLinkCurves);

  do
  {
    switch (ME.super_cmd->state)
    {
    case INIT:
      {
        logstat = BSEXTRACTPAR(&msg, BSTOLLENVEC, me->connect_tol);
        logstat = BSEXTRACTPAR(&msg, BSTOLCHRDHT, me->search_tol);

        ex$message (msgnumb = EMS_P_ConnectTol, buff = header);
        status = EFshort_cvtn( header, me->connect_tol,1,80);
        ex$message (msgnumb = EMS_P_SearchTol, buff = header);
        status = EFshort_cvtn( header, me->search_tol,2,80);
        strncpy(prompt, header, MAX_PROMPT_SIZE);

        UI_status(prompt);
        ME.super_cmd->state = SELECT_MODE;
      }


    case SELECT_MODE:
      { /* REMOVED THIS STATE FOR 2.4, ALWAYS EXTEND TO INTERSECT
        ex$message (msgnumb = EMS_P_ModeExtendtoIntersecty, buff = prompt);
        status = co$getevent (
            msg = &msg,
            event_mask = GRm_BACK_UP | GRm_TEXT_VALUE | GRm_RJT_MOVEON,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
            );

        if (!status)
          goto wrapup;
        else if (event.response IS GR_UNKNOWN_TYPE)
          return(OM_S_SUCCESS);
        else if (event.response IS EX_BACK_UP)
        {
          ME.super_cmd->state = SELECT_MODE;
          break;
        }
        else if (event.response IS EX_RJT_MOVEON)
          me->ext_to_int = TRUE;
        else if ((event.event.keyin[0] == NULL) ||
            (toupper(event.event.keyin[0]) == 'Y') )
          me->ext_to_int = TRUE;
        else if (toupper(event.event.keyin[0]) == 'N')
          me->ext_to_int = FALSE;
        else
          return (OM_S_SUCCESS);

        ME.super_cmd->state = ID_OBJ;
        break;
        */
        me->ext_to_int = TRUE;
     }


    case ID_OBJ:
      {

#if ASSOC

        /*
 * Do not locate associative wireframe elements. Also to support the same
 * EMbuild_stack method at the curve level is being modified to not locate
 * associative wireframe elements as it bypasses the action handler during the
 * process of scanning the rtree for other curve elements for auto linking.
 * pp - 11/10/88 
 */

        extern   IGRlong EFlocate_action_handler();
        extern   IGRlong EClink_action_handler();
        struct   EMSaction_handler dont_locate;
        OMuword reject_classid;

        reject_classid = OPP_ASnode_class_id;
        dont_locate.next = NULL;
        dont_locate.option = 2;
        dont_locate.type = 3;
        dont_locate.num_objects = 1;
        dont_locate.objects.classids = &reject_classid;

        /* end pp change - 11/10/88 */

#endif

        comp_curve.objid = NULL;
        comp_curve.osnum = NULL;
        me->num_comp = 0;

        eventmask = GRm_DATA | GRm_BACK_UP;
        eventmask1 = GRm_DATA;

        size = sizeof(struct GRevent);
        attributes.properties   = 0x11 | LC_RW;
        attributes.owner_action = 0x7;
        display_flag = 3;

        rtree_classes.w_count = 4;
        elig_classes.w_count = 4;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

        rclass[0] = OPP_GRcurve_class_id;
        rclass[1] = OPP_SKcompcurve_class_id;
        rclass[2] = OPP_SKline_class_id;
        rclass[3] = OPP_SKarc_class_id;
        rclass[4] = OPP_SKbspline_class_id;

        /* eliclass = OPP_GRcurve_class_id; */

        rtree_classes.p_classes = &rclass[0];
        elig_classes.p_classes = &rclass[0];  /*&eliclass*/

#if ASSOC
        lc$locate(rc = &msg, 
            event1 = &me->event_1, 
            event2 = &me->event_1,
            mask1 = eventmask, 
            mask2 = eventmask1, 
            eventsize= &size, 
            display_flag = display_flag,
            response = response, 
            response_data = response_data, 
            locate_key = EMS_P_IdCv,
            acc_key = EMS_P_AcceptNearEndReject,
            relocate_key = EMS_I_CvNotLocated,
            act_handler = EClink_action_handler,
            act_args = &dont_locate,
            attributes = &attributes,
            stack = &me->lc_stack, 
            rtree_classes = &rtree_classes, 
            eligible_classes = &elig_classes);
#else
        lc$locate(rc = &msg, 
            event1 = &me->event_1, 
            event2 = &me->event_1,
            mask1 = eventmask, 
            mask2 = eventmask1, 
            eventsize= &size, 
            display_flag = display_flag,
            response = response, 
            response_data = response_data, 
            act_handler = EClink_action_handler,
            locate_key = EMS_P_IdCv, 
            acc_key = EMS_P_AcceptNearEndReject,
            relocate_key = EMS_I_CvNotLocated,
            attributes = &attributes,
            stack = &me->lc_stack, 
            rtree_classes = &rtree_classes, 
            eligible_classes = &elig_classes);
#endif

        UI_echo(" ");

        if ( (! msg) )
        {
          if (me->event_1.response IS EX_BACK_UP)
            ME.super_cmd->state = INIT;
          else if (me->event_1.response IS EX_RJT_MOVEON)
            break;
          else
            return(OM_S_SUCCESS);
        }

        else if (me->event_1.response IS DATA)
          ME.super_cmd->state = PRE_PROCESS;

        break;
      }


    case PRE_PROCESS:
      {
        IGRlong retb1, which_error;

        ex$message (msgnumb = EMS_S_Processing);
        UI_prompt(" ");

        /* set the module environment to be the locate environment */

        me->ModuleInfo = me->event_1.located_object[0].module_info;

        /* get active levels */

        list[0].var = LEVELS;
        list[0].var_ptr = (IGRchar *) me->levels;
        list[0].num_bytes = sizeof(IGRint) * 32;
        list[0].bytes_returned = &retb1;

        list[1].var = END_PARAM;
        list[1].var_ptr = NULL;
        list[1].num_bytes = 0;
        list[1].bytes_returned = NULL;

        status = dp$inq_set_gragad(msg = &msg,
            osnum = me->lc_stack.window.osnum,
            gragad_objid = me->lc_stack.window.objid,
            which_error = &which_error,
            var_list = list);

        if (NOT status OR NOT(1 & msg))
        {
          fprintf(stderr, "EClink: inq_set_gragad\n");
          EFprintcode(0, msg);
          EFprintcode(0, status);
          status = OM_E_ABORT;
          goto wrapup;
        }

        /* Now validate the end points */

        EMgetendpnt(&msg, &me->event_1, &me->event_1, &me->ModuleInfo,
            me->connect_tol, my_id, me->start_pnt, me->stop_pnt,
            &me->end_of_interest);

        if (msg IS_NOT MSSUCC)
        {
          goto wrapup;
        }
        else if (me->end_of_interest < 0)
        {
          /* unhilite curve */

          DisplayMode = GRbdhe;
          status = om$send(msg = message GRgraphics.GRdisplay(&msg,
              &me->ModuleInfo.md_env.matrix_type,
              me->ModuleInfo.md_env.matrix,
              &DisplayMode, &me->ModuleInfo.md_id),
              targetid = me->event_1.located_object[0].
              located_obj.objid,
              targetos = me->event_1.located_object[0].
              located_obj.osnum);
          EMomerr_hndlr(status, wrapup, "EClink: phy closed display");
          EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

          ex$message (msgnumb = EMS_S_CurvePhysicallyClosed);

          ME.super_cmd->state = ID_OBJ;
          break;
        }
        else if (me->end_of_interest == 0)
        {
          /* Carlos M. Diaz. Removed this call since it is unnecessary: 
          status = om$send(msg = message GRcurve.GRrevparm(&msg,
              &me->event_1.located_object[0].module_info),
              targetid = me->event_1.located_object[0].
              located_obj.objid,
              targetos = me->event_1.located_object[0].
              located_obj.osnum);
          EMomerr_hndlr(status, wrapup, "EClink: GRrevparm");
          EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
	  */
	  /* Carlos M. Diaz. Swapping me->stop_pnt by me->start_pnt
	     instead of calling GRrevparam....*/
          status = om$send(msg = message GRcurve.GRendpts(&msg,
              &me->event_1.located_object[0].module_info.
              md_env.matrix_type,
              me->event_1.located_object[0].module_info.
              md_env.matrix, me->stop_pnt,
              me->start_pnt),
              targetid = me->event_1.located_object[0].
              located_obj.objid,
              targetos = me->event_1.located_object[0].
              located_obj.osnum);
          EMomerr_hndlr(status, wrapup, "EClink: GRendpnt");
          EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

          me->end_of_interest = 1;  /* stop point */
        }

        me->located_obj[me->num_comp] = me->event_1.located_object[0];
        me->num_comp++;
        ME.super_cmd->state = MAKE_MSG;
        break;

      }


    case MAKE_MSG:
      {
        post_scan_arglist.msg           = &msg;
        post_scan_arglist.search_pt     = &search_pnt[0];
        post_scan_arglist.original_cc   = me->located_obj[me->num_comp-1].
            located_obj;
        post_scan_arglist.generic_tol   = me->search_tol;
        post_scan_arglist.closed_tol    = me->connect_tol;
        post_scan_arglist.active_levels = me->levels;
        post_scan_arglist.module_info   = &me->ModuleInfo;
        post_scan_arglist.stack         = &me->lc_stack;

        status = om$make_message(classname = "GRcurve",
            methodname = "EMbuild_stack",
            size = sizeof(post_scan_arglist),
            p_arglist = &post_scan_arglist,
            p_msg = &post_scan_msg);
        EMomerr_hndlr(status, wrapup, "EClink: make message");
      }


    case PROCESS:
      {
        struct GRlc_info      add_obj;
        IGRboolean            is_already_located, save_obj = TRUE;
        IGRlong               scan_msg, cur_entry;
	IGRchar		      object_hilited;

        if (me->end_of_interest == 0)
        {
          search_pnt[0] = me->start_pnt[0];
          search_pnt[1] = me->start_pnt[1];
          search_pnt[2] = me->start_pnt[2];
        }
        else
        {
          search_pnt[0] = me->stop_pnt[0];
          search_pnt[1] = me->stop_pnt[1];
          search_pnt[2] = me->stop_pnt[2];
        }

        me->lc_stack.num_entries = 0;
        EMscan(&scan_msg, search_pnt, me->search_tol, &me->ModuleInfo,
            &post_scan_msg);

        if (scan_msg IS_NOT MSSUCC)
        {
          status = OM_E_ABORT;
          goto wrapup;
        }

        if (me->lc_stack.num_entries IS 0)
        {
          ME.super_cmd->state = BACKUP_MAYBE;
          break;
        }
        else /* (me->lc_stack.num_entries != 0 */
        {

          /*
          * If the object found is equal to any of
          * the objects already located, then it's 
          * invalid and thus should be filtered out
          */

          i = 0;
          do
          {
            is_already_located = FALSE;
            cur_entry = 0;
            do
            {
              if (me->lc_stack.entry[i].located_obj.objid ==
                  me->located_obj[cur_entry].located_obj.objid)
                is_already_located = TRUE;
              else cur_entry++;
            } while (!is_already_located && cur_entry < me->num_comp);

            if (is_already_located)
            {
              for (j = i; j < me->lc_stack.num_entries - 1; j++)
                me->lc_stack.entry[j] = me->lc_stack.entry[j+1];
              me->lc_stack.num_entries--;

            } /* if (is_already_located) */
            else i++;

          } while (i <  me->lc_stack.num_entries);


          /*
          * Process stack returned from the scan.
          */

          if (me->lc_stack.num_entries IS 0)
          {
            ME.super_cmd->state = BACKUP_MAYBE;
            add_obj = me->located_obj[cur_entry];
            save_obj = FALSE;
          }
          else
          {
            /* found another curve or more after resuming, so
              prompt user to accept again */

            if (no_last_prompt) no_last_prompt = FALSE;

            if (me->lc_stack.num_entries IS 1)
            {
              add_obj = me->lc_stack.entry[0];

              DisplayMode = GRhd;
              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                  &add_obj.module_info.md_env.matrix_type,
                  add_obj.module_info.md_env.matrix,
                  &DisplayMode, &me->ModuleInfo.md_id),
                  targetid = add_obj.located_obj.objid,
                  targetos = add_obj.located_obj.osnum);
              EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
              EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            } /* if (me->lc_stack.num_entries IS 1) */
            else
            {
              size = sizeof(struct GRevent);
              eventmask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

              /*
              * 12/09/92 - JSD - changing call to make UMS compliant
              */
              ex$message (msgnumb = EMS_P_00038, buff = prompt);

              EMselect(&msg, &eventmask, &size, response, response_data,
                  &event, &object_hilited, &me->lc_stack,
                  prompt);

              if (event.response IS GR_UNKNOWN_TYPE)
                return(OM_S_SUCCESS);

              else if ((event.response IS EX_BACK_UP) ||
                  (!object_hilited))
              {
                me->lc_stack.num_entries = 0;
                ME.super_cmd->state = BACKUP_MAYBE;
                break;
              }
              else if (!msg)
                goto wrapup;

              add_obj = event.located_object[0];

            } /* else (me->lc_stack.num_entries > 1) */

          }  /* else (me->lc_stack.num_entries != 0) after compare  */

        }  /* else (me->lc_stack.num_entries != 0)  */

        /*
        * Get the endpoints of the
        * located obj and check for
        * any gaps
        */

        event = me->event_1;
        event.event.button.x = search_pnt[0];
        event.event.button.y = search_pnt[1];
        event.event.button.z = search_pnt[2];
        event.located_object[0] = add_obj;

        EMgetendpnt(&msg, &event, &event, &me->ModuleInfo,
            me->connect_tol, my_id, me->start_pnt, me->stop_pnt,
            &me->end_of_interest);

        if (me->end_of_interest == 0)
        {
          dist = BSdistptpt(&msg, search_pnt, me->start_pnt);
          EMerr_hndlr(msg != BSSUCC, status, OM_E_ABORT, wrapup);

          me->end_of_interest = 1;
        }
        else if (me->end_of_interest == 1)
        {
          dist = BSdistptpt(&msg, search_pnt, me->stop_pnt);
          EMerr_hndlr(msg != BSSUCC, status, OM_E_ABORT, wrapup);

          me->end_of_interest = 0;
        }
        else /* the add curve is closed */
        {
          DisplayMode = GRbdhe;
          status = om$send(msg = message GRgraphics.GRdisplay(&msg,
              &me->ModuleInfo.md_env.matrix_type,
              me->ModuleInfo.md_env.matrix,
              &DisplayMode, &me->ModuleInfo.md_id),
              targetid = event.located_object[0].
              located_obj.objid,
              targetos = event.located_object[0].
              located_obj.osnum);
          EMomerr_hndlr(status, wrapup, "EClink: phy closed display");
          EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

          ex$message (msgnumb = EMS_S_CurvePhysicallyClosed);

          ME.super_cmd->state = BACKUP_MAYBE;
          break;
        }

        /*
        * Check for a gap between the curves
        */

        if ( (dist <= me->connect_tol) && (save_obj) )
        {
          num_elements = om$dimension_of(varray = me->located_obj);
          if (me->num_comp >= num_elements)
          {
            status = om$vla_set_dimension(varray = me->located_obj,
                size = num_elements + 1);
            EMomerr_hndlr(status, wrapup, "set_dimension  error");
          }

          me->located_obj[me->num_comp] = add_obj;
          me->num_comp++;
        }
        else if (dist > me->connect_tol)  /* there's a gap */
        {
          ex$message (msgnumb = EMS_S_GapDist, buff = prompt);
          status = EFshort_cvtn(prompt, dist, 0,MAX_PROMPT_SIZE);

          if (me->start_pnt[1] == me->stop_pnt[1])
          {
            list[0].var = UOR_PER_REF_Y;
            list[0].var_ptr = (IGRchar *) &uor;
            list[0].num_bytes = sizeof(IGRdouble);
            list[0].bytes_returned = &bytes_ret;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = 0;
            list[1].bytes_returned = NULL;

            dp$inq_set_gragad(msg = &msg,
                osnum = event.event.button.osnum,
                gragad_objid = event.event.button.objid,
                which_error = &error, var_list = list);
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            event.event.button.y = search_pnt[1] + uor;
          }

          status = EMrastext(&msg, prompt, &event.event.button);
          EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

          if ( (me->ext_to_int) && (save_obj) )
          {
            num_elements = om$dimension_of(varray = me->located_obj);
            if (me->num_comp >= num_elements)
            {
              status = om$vla_set_dimension(varray = me->located_obj,
                  size = num_elements + 1);
              EMomerr_hndlr(status, wrapup, "set_dimension  error");
            }

            me->located_obj[me->num_comp] = add_obj;
            me->num_comp++;
          }
          else if (!me->ext_to_int)
          {
            DisplayMode = GRbdhe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->ModuleInfo.md_env.matrix_type,
                me->ModuleInfo.md_env.matrix,
                &DisplayMode, &me->ModuleInfo.md_id),
                targetid = event.located_object[0].
                located_obj.objid,
                targetos = event.located_object[0].
                located_obj.osnum);
            EMomerr_hndlr(status, wrapup, "EClink: display");
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
            me->lc_stack.num_entries = 0;
            ME.super_cmd->state = BACKUP_MAYBE;
          }
        }  /* end if dist > connect_tol */

        break;

      }


    case BACKUP_MAYBE:
      {
        IGRboolean      stay_in_loop, everything_okay;
        IGRlong         comp_so_far = 0;
        struct GRid     first_obj;
        OM_S_CHANSELECT to_components;

        UI_status(" ");
        stay_in_loop = TRUE;
        everything_okay = TRUE;

        while(stay_in_loop)
        {
          if (me->num_comp == 1)
          {
            ex$message (msgnumb = EMS_S_NoMoreCvsNoCCvCreated);

            DisplayMode = GRbdhe;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->ModuleInfo.md_env.matrix_type,
                me->ModuleInfo.md_env.matrix,
                &DisplayMode, &me->ModuleInfo.md_id),
                targetid = me->located_obj[0].
                located_obj.objid,
                targetos = me->located_obj[0].
                located_obj.osnum);
            EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            ME.super_cmd->state = ID_OBJ;
            break;
          }

          /* if they gave a data pnt to resume and there was no
            more curves to get, then go ahead and make the composite
            and don't prompt them again. */

          if (no_last_prompt)
          {
            no_last_prompt = FALSE;
            event.response = EX_RJT_MOVEON;
          }
          else
          {
            ex$message (msgnumb = EMS_P_MvOntoAccBackupDPtoResume, buff = prompt);
            status = co$getevent (
                msg = &msg,
                event_mask = GRm_BACK_UP | GRm_DATA | GRm_RJT_MOVEON,
                prompt = prompt,
                response = response,
                response_data = response_data,
                event = &event
                );

            if (!status)  /* error from the getevent */
              goto wrapup;
          }


          if (event.response IS EX_RJT_MOVEON)   /* new curve */
          {
            /*
            * Make the chanselect to use in the processing.
            */

            status = EMmake_chanselect(GRcmpowner_to_components,
                &to_components);
            EMomerr_hndlr(status, wrapup, "EMmake_chanselect\n");

            /*
            * Erase highlight plane of window
            * where raster text is displayed and
            * also erase the curves if ext_to_int is TRUE.
            */

            dp$erase_hilite(msg = &msg);
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            if (me->ext_to_int)
            {
              DisplayMode = GRbe;
              for (i = 0; i < me->num_comp; i++)
              {
                status = om$send(msg = message GRgraphics.GRdisplay(
                    &msg,
                    &me->ModuleInfo.md_env.matrix_type,
                    me->ModuleInfo.md_env.matrix,
                    &DisplayMode,
                    &me->ModuleInfo.md_id),
                    targetid = me->located_obj[i].
                    located_obj.objid,
                    targetos = me->located_obj[i].
                    located_obj.osnum);
                EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
                EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
              }
            }  /* end if me->ext_to_int */

	    /*
	     * check for the existence of profiles
	     */
            for (i = 0; i < me->num_comp; i++)
              {
                status = om$get_classid(
	                osnum = me->located_obj[i].located_obj.osnum,
        	        objid = me->located_obj[i].located_obj.objid,
                    	p_classid = &loc_obj_class_id);
                EMomerr_hndlr(status, wrapup, "EClink: om$get_classid");
		if (
			(loc_obj_class_id IS OPP_SKcompcurve_class_id) ||
			(loc_obj_class_id IS OPP_SKarc_class_id) ||
			(loc_obj_class_id IS OPP_SKline_class_id)||
			(loc_obj_class_id IS OPP_SKbspline_class_id)
		    )
		    {
		     do_profiles = TRUE;    
		     break;
                    }
              }           
	    if (do_profiles) 
	    {
            for (i = 0; i < me->num_comp; i++)
              {
                status = om$get_classid(
	                osnum = me->located_obj[i].located_obj.osnum,
        	        objid = me->located_obj[i].located_obj.objid,
                    	p_classid = &loc_obj_class_id);
                EMomerr_hndlr(status, wrapup, "EClink: om$get_classid");
		if (
			(loc_obj_class_id IS OPP_SKcompcurve_class_id) ||
			(loc_obj_class_id IS OPP_SKarc_class_id) ||
			(loc_obj_class_id IS OPP_SKline_class_id)||
			(loc_obj_class_id IS OPP_SKbspline_class_id)

		   )
		{
		 IGRlong msg_loc;
		 struct GRid new_grid;
		 GRobjid mgr_id;
		 
		 new_grid.osnum = me->located_obj[i].located_obj.osnum; 
		 status = om$send (msg = message GRgraphics.GRcopy (&msg_loc,
		 				&me->ModuleInfo,
		 				&me->ModuleInfo,
		 				&new_grid.objid),
		 		  targetid = me->located_obj[i].located_obj.objid,
		 		  targetos = me->located_obj[i].located_obj.osnum,
		 		  senderid = my_id);
		 EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, wrapup);
		 EMomerr_hndlr(status, wrapup, "in EClink:GRcopy\n");

		 status = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc,
		 				&mgr_id),
		 		  targetid = me->located_obj[i].located_obj.objid,
		 		  targetos = me->located_obj[i].located_obj.osnum,
		 		  senderid = my_id);
		 EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, wrapup);
		 EMomerr_hndlr(status, wrapup, "in EClink:SKgetmgr\n");

		 {
		 struct GRobj_env obj_env[1];
		 int num_objects = 1;
		 
		 obj_env[0].obj_id.objid = me->located_obj[i].located_obj.objid;
		 obj_env[0].obj_id.osnum = me->located_obj[i].located_obj.osnum;
		 obj_env[0].mod_env = me->ModuleInfo;		
		 status = om$send (msg = message SKmgr.GRremove_components (
		 				&msg_loc,
		 				&me->ModuleInfo,
		 				&num_objects,
		 				obj_env),
		 		  targetid = mgr_id,
		 		  targetos = me->located_obj[i].located_obj.osnum,
		 		  senderid = my_id);
		 EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, wrapup);
		 EMomerr_hndlr(status, wrapup, "in EClink:GRremove_components\n");
		 }
		 me->located_obj[i].located_obj.objid = new_grid.objid;
		}/* end if class check */
	      }/* end of for loop */
            }/* endif do_profiles */

            status = om$get_classid(
                osnum = me->located_obj[0].located_obj.osnum,
                objid = me->located_obj[0].located_obj.objid,
                p_classid = &loc_obj_class_id  );
            EMomerr_hndlr(status, wrapup, "EClink: get classid");

            if (loc_obj_class_id IS_NOT OPP_GRcompcurve_class_id)
            {
              struct GRvg_construct      constr;
              IGRlong               rotten_one;

              first_obj.objid = me->located_obj[0].located_obj.objid;
              first_obj.osnum = me->located_obj[0].located_obj.osnum;

              constr.msg        =  &msg;
              constr.class_attr =  NULL;       /* use defaults */
              constr.level      =  ME.CObuild->ActiveLevel;
              constr.display    = &ME.CObuild->ActiveDisplay;
              constr.env_info   = &me->ModuleInfo;
              constr.newflag    = FALSE;
              constr.name       = NULL;
              constr.properties = GRIS_NEW | GRIS_LOCATABLE 
                  | GRIS_DISPLAYABLE;

              status = om$construct(classid = OPP_GRcompcurve_class_id,
                  osnum = me->located_obj[0].
                  located_obj.osnum,
                  p_objid = &comp_curve.objid,
                  msg = message
                  GRgraphics.GRconstruct(&constr));
              EMomerr_hndlr(status, wrapup, "EClink: construct");
              comp_curve.osnum = me->located_obj[0].located_obj.osnum;

              status = om$send(msg = message GRcompcurve.EMmakecomp(
                  &msg, &me->ModuleInfo, 1,
                  &me->located_obj[0], &rotten_one),
                  targetid = comp_curve.objid,
                  targetos = comp_curve.osnum);
              EMomerr_hndlr(status, wrapup, "EClink: EMmakecomp\n");
              EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            }
            else
            {
              comp_curve.objid = me->located_obj[0].located_obj.objid;
              comp_curve.osnum = me->located_obj[0].located_obj.osnum;

              status = om$get_objid_at_index(objid = comp_curve.objid,
                  osnum = comp_curve.osnum,
                  p_chanselect = &to_components,
                  index = 0,
                  objidaddr = &first_obj.objid,
                  osnumaddr = &first_obj.osnum);
              EMomerr_hndlr(status, wrapup, "om$get_objid_at_index");
            }



            for (i = 1; i < me->num_comp; i++)
            {
              if(i == (me->num_comp - 1))
                _SM_KLUDGE_TO_PREVENT_MERGE_MANIA = 0;
              else
                _SM_KLUDGE_TO_PREVENT_MERGE_MANIA = 1;

              status = om$send(msg = message GRcompcurve.EMaddtocomp(&msg,
                  me->located_obj[i].located_obj,
                  &me->located_obj[i].module_info,
                  &me->ModuleInfo, me->ext_to_int,
                  me->search_tol, me->connect_tol, FALSE,
                  me->start_pnt, me->stop_pnt, 
                  &comp_so_far),
                  targetid = comp_curve.objid,
                  targetos = comp_curve.osnum);

              _SM_KLUDGE_TO_PREVENT_MERGE_MANIA = 0;

              EMomerr_hndlr_action(status, msg = MSFAIL,
                  "Failure in EMaddtocomp\n");

              if ( (msg == EMS_E_NoIntersection) ||
                  (msg == EMS_E_Modified) )
              {
                everything_okay = FALSE;
                if (i == 1)
                {
  		 ex$message (msgnumb = EMS_S_CouldntExtendCurveNotDef);
                }
                else
                {
  		 ex$message (msgnumb = EMS_S_CouldntExtendCurveDef);
                }
              }
              else if (msg == EMS_I_OutOfBounds)
              {
                everything_okay = FALSE;
                if (i == 1)
                {
  		ex$message (msgnumb = EMS_S_ExtptOutSearchTolNotDef);
                }
                else
                {
  		ex$message (msgnumb = EMS_S_ExtptOutSearchTolDef);
                }
              }
              else if (!(1&msg))
              {
                everything_okay = FALSE;
                if (i == 1)
                {
  		ex$message (msgnumb = EMS_S_InvalidCvCCvNotDefined);
                }
                else
                {
  		ex$message (msgnumb = EMS_S_InvalidCvCCvDefined);
                }
              }

              if (!everything_okay)
              {
                /*
                * If it failed at the first add
                * attempted and the located_objects's
                * class id wasn't originally a 
                * composite curve, then drop (delete) the
                * constructed composite curve and redisplay
                * the first curve.
                */

                if ( (i == 1) 
                	&& 
                     (loc_obj_class_id != OPP_GRcompcurve_class_id) 
                   )
		{
		 status = om$send(msg = message GRowner.GRdrop(&msg,
		 		&me->ModuleInfo),
      		 	targetid = comp_curve.objid,
      		 	targetos = comp_curve.osnum);
  		 EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");

		 DisplayMode = GRbd;
		 status = om$send(msg = message GRgraphics.GRdisplay(
				&msg,
				&me->ModuleInfo.md_env.matrix_type,
				me->ModuleInfo.md_env.matrix,
				&DisplayMode,
				&me->ModuleInfo.md_id),
			targetid = me->located_obj[0].located_obj.objid,
      			targetos = me->located_obj[0].located_obj.osnum);
  		 EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
  		 EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

  		 comp_curve.objid = NULL;
  		 comp_curve.osnum = NULL;
		}
                
                /* 
                * On error, redisplay the
                * remaining curves and display
                * the bad curve in highlight.
                */

                DisplayMode = GRbd;
                for (j = i; j < me->num_comp; j++)
                {
  		 status = om$send(msg = message GRgraphics.GRdisplay(&
				msg,
				&me->ModuleInfo.md_env.matrix_type,
				me->ModuleInfo.md_env.matrix,
				&DisplayMode,
				&me->ModuleInfo.md_id),
	    	 	targetid = me->located_obj[j].
	         	located_obj.objid,
	         	targetos = me->located_obj[j].
	         	located_obj.osnum);
		 EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
  		 EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);
                }

                DisplayMode = GRhd;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                    		&me->ModuleInfo.md_env.matrix_type,
                    		me->ModuleInfo.md_env.matrix,
                    		&DisplayMode, 
                    		&me->ModuleInfo.md_id),
                    	targetid = me->located_obj[i].
                    	located_obj.objid,
                    	targetos = me->located_obj[i].
                    	located_obj.osnum);
                EMomerr_hndlr(status, wrapup, "EClink: GRdisplay");
                EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

                break;
              }  /* end if !everything_okay */

            }  /* for  addtocomp */


            /*
            * If everything is okay, then call EMclose_composite to
            * test to see if there is a gap at the endpoints of the
            * composite.  If there is a gap, then it closes it off.
            * Also display status that composite was defined.
            */

            if (everything_okay)
            {
              if (me->ext_to_int)
              {
                extern IGRlong  EMclose_composite();

                status = EMclose_composite(&msg, &me->ModuleInfo,
                    comp_curve, me->search_tol, me->connect_tol);
                EMomerr_hndlr(status, wrapup, "EClink:EMclose_composite\n");
                EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

              }
              if (me->associative)
              {
 		sk$convert_to_profile (msg      = &msg,
				       options  = SK_CONVERT_VERBOSE,
				       geometry = comp_curve,
				       module   = &me->ModuleInfo,
				       profile  = &profile_grid,
				       automask = SK_AUTO_GEOMETRIC);
		EMomerr_hndlr(status, wrapup, "EClink:EFconvert_to_profile\n");
              }
            } /* end if everything okay */

            stay_in_loop = FALSE;
            ME.super_cmd->state = ID_OBJ;

          }  /* ends MOVEON */

          else if(event.response IS DATA)      /* continue processing */
          {
            no_last_prompt = TRUE;
            UI_prompt(" ");
            ME.super_cmd->state = MAKE_MSG;
            stay_in_loop = FALSE;
          }

          else if (event.response IS EX_BACK_UP)     /* drop component */
          {
            if (me->num_comp != 0)
              me->num_comp--;
            else
              stay_in_loop = FALSE;

            /* unhilite the object */

            if (stay_in_loop)
            {
              DisplayMode = GRbdhe;
              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                  &me->ModuleInfo.md_env.matrix_type,
                  me->ModuleInfo.md_env.matrix,
                  &DisplayMode, &me->ModuleInfo.md_id),
                  targetid = me->located_obj[me->num_comp].
                  located_obj.objid,
                  targetos = me->located_obj[me->num_comp].
                  located_obj.osnum);
              EMomerr_hndlr(status, wrapup, "EClink: drop: GRdisplay");
              EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

              me->located_obj[me->num_comp].located_obj.objid = NULL;
              me->located_obj[me->num_comp].located_obj.osnum = NULL;
            }
            else
            {
              ME.super_cmd->state = ID_OBJ;
              comp_curve.objid = NULL;
              comp_curve.osnum = NULL;
            }

          }  /* ends back_up */

          else if (event.response IS GR_UNKNOWN_TYPE)
          {
            /* erase highlight plane of window where raster text and
              curves are displayed */

            dp$erase_hilite(msg = &msg);
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            return(OM_S_SUCCESS);
          }


          /*
          * If I'm through and I have a composite curve, then call
          * EMmaintain_fist_component to see if it is closed.  If closed, 
          * it will make the start curve the same as the first one
          * the user identified.  Display the current composite curve.
          */

          if ((ME.super_cmd->state IS ID_OBJ)  AND
              (comp_curve.objid IS_NOT NULL))
          {
            extern            IGRlong    EMmaintain_first_component();

            status = EMmaintain_first_component(&msg, &me->ModuleInfo,
                comp_curve, first_obj);
            EMomerr_hndlr(status, wrapup, "EClink:EMmaintain_first_comp\n");
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

            if (msg != EMS_I_Open)
            {
              ex$message (msgnumb = EMS_I_CompCurveIsClosed);
            }

            DisplayMode = GRbd;
            status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->ModuleInfo.md_env.matrix_type,
                me->ModuleInfo.md_env.matrix,
                &DisplayMode, &me->ModuleInfo.md_id),
                targetid = comp_curve.objid,
                targetos = comp_curve.osnum);
            EMomerr_hndlr(status, wrapup, "EClink: final display");
            EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, wrapup);

          }  /* if ((ME.super_cmd->state IS ID_OBJ)  AND
                                   (comp_curve.objid IS_NOT NULL))    */


        }  /* end while stay_in_loop */

        break;

      }  /* end case BACKUP_MAYBE */


    default:
      /* 
        * In an invalid state, severe error.
        */

      *response = TERMINATE;
      return (OM_S_SUCCESS);


    } /* end switch */

  } /* end do */

  while(TRUE);

wrapup:
  *response = TERMINATE;
  return(status);
}


IGRlong EClink_action_handler(
 not_used,
 new_entry,
 locate_args,
 action)

IGRchar *not_used;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;

{
 IGRboolean     call_action_handler;
 IGRlong msg_loc;
 IGRlong        sts;
 extern OMuword OPP_GAcurve_class_id,
                OPP_SKgeometry_class_id,
                OPP_GAcompcurve_class_id;
/*
 * Initialize
 */
 call_action_handler = TRUE;

 switch (*action)
 {
   case add_all:
   case add_inside:
   case add_outside:
   case add_overlap:
   case add_nopost:
   {
     IGRlong    i;
     IGRshort graphics_props;
     struct     GRid check_id, *search_id, temp_GRid;
     OM_S_CHANSELECT to_owners;

     search_id = &new_entry->located_obj;
/*
 * See if the guy that was identified has a rigid owner.
 */
     graphics_props = 0;
     sts = om$send (msg = message GRgraphics.GRgetprops(&msg_loc,
                          &graphics_props),
                    senderid = NULL_OBJID,
                    targetid = search_id->objid,
                    targetos = search_id->osnum);
      if (!(1&sts&msg_loc)) return (OM_S_SUCCESS);

      if (graphics_props & GR_RIGID_RELATIONSHIP)
      {
       EMmake_chanselect(GRconnector_to_owners, &to_owners);

       if (EFisAncestryValid(&msg_loc, search_id->objid,
                             search_id->osnum, OPP_SKgeometry_class_id)
          )
        check_id = *search_id;
       else
        call_action_handler = FALSE;
      }
      else
       check_id = *search_id;

       if (call_action_handler)
       {
        if (EFisAncestryValid(&msg_loc, search_id->objid,
                              search_id->osnum, OPP_GAcurve_class_id) ||
            (search_id->osnum == OM_Gw_TransOSnum_0)
           )
         call_action_handler = FALSE;
       }
    }
   
    break;
/*
 * If the action is not to add then let the
 * regular action handler take care of the 
 * situation.
 */
   case start_transition:
   case end_transition:
   case post_object:
   case check_object:
    break;
  } /* switch (*action) */
/*
 * Call the action handler
 */
 if (call_action_handler)
  {
   extern IGRlong LCptlocact();

   sts = LCptlocact(NULL, new_entry, locate_args, action);
  }
 else
  sts = OM_S_SUCCESS;
/*
 * Eof
 */
 return(sts);
}
end implementation EClink;
