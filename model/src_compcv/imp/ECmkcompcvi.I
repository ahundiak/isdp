class implementation ECmkcompcv;

#include "EMScc.h"
#include "ECcmd.h"
#include "ECmsg.h"

/*
DESCRIPTION:
  This command object is to build the composite curve from
  simple curves. Also it adds the simple curves to already 
  existing composite curve and make new composite curve.

HISTORY:

  scw   08/14/94        Clarified sleep method
  Sudha 06/21/93        Modified to handle BSprototype ansification
  jsd   12/09/92        UMS compliance
  ra    07/02/92	Message system compliance.
  pp    01/25/90        Fixed an infinite loop problem occuring whenever
                        an object was tentatively located.
  pp    09/29/89        Changed arguments to EFshort_cvtn to prevent
                        potential memory problems.
12 Jun 1989 jBk Changed wakeup and init to send to self wrt
                parent.

                Removed active layer and display initialization
                from init.

22 May 1989 jBk Replaced occurrences of GRm_STRING with
                GRm_TEXT_VALUE.

                Replaced invocations of GRgetevent with uses of
                co$getevent.

  pp    11/11/88        Modified code to not locate associative wireframe 
                        elements while making the composite curve.
  dhm   07/21/88        Changed to call the functions EMclosecomp and
                        EMmaintfirst.
  dhm   01/15/88        Modified to extend to intersection and
                        changed the flow of the construct logic.
  gk    11/13/87        Request direction of flow data point
  DLB   01/12/88        Modified for EMS 1.1.x release.
  rlw   09/24/87        The code which bumped up the VLA dimension was
                        wrong and causing memory faults.  I fixed it.
  rlw   07/16/87        added move-on to prompt
  rlw   05/14/87        changed prompts to output counts
  rlw   05/08/87        modifed due to renaming EMinitcc to GRconstruct
  gk    03-02-87        modified to reduce number of variables
  Kirit Patel(KRP)  Nov-20-1986 Genesis Date.
*/

/* include files here */

#include <stdio.h>       /* Needed for print statements   */
#include "griodef.h"
#include "emserr.h"      /* Has EMomerr_hndlr defined     */
#include "OMmacros.h"    /* Has SET_DIMENSION             */
#include "exmacros.h"    /* Has ex$putque                 */
#include "lcmacros.h"
#include "dpmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "EMSaction.h" /* Structure definition for action handler */
#include "EMSasdef.h" /* For ASSOC */
#include "emsdef.h"
#include "bsdistptpt.h"
# include "griomacros.h" /* co$getevent */

/* define here */

#define TRUE 1
#define FALSE 0
#define IS ==
#define IS_NOT !=
#define AND &&
#define OR  ||
#define DIMEN_INC 5

/* import here */

from GRgraphics  import GRdisplay, GRconstruct;
from GRcompcurve import EMmakecomp, EMaddtocomp;
from GRcurve     import GRrevparm;
from GRconnector import GRdisconn, GRrigidconn;
from GRowner     import GRdrop, GRget_components;
from GRvg        import GRgeomprops, GRpostabsg;

extern OMuword OPP_GRcurve_class_id, OPP_GRcompcurve_class_id;

#if ASSOC
 extern OMuword OPP_ASnode_class_id;
#endif

method init(int type; char *str_ptr)
{
  ME.super_cmd->state = 0;
  OM_SET_DIMENSION(me->locobj, DIMEN_INC);

  return om$send (
    mode = OM_e_wrt_parent,
    msg = message ECmkcompcv.init (type, str_ptr),
    targetid = my_id
  );
}

method super_cmd.sleep ( int pos )
{
  IGRlong     i, msg=1, sts=OM_S_SUCCESS;

  UI_prompt(" ");
  UI_status(" ");
  UI_message(" ");
    
  /* Dehilight curves */
  sts = dp$erase_hilite(msg = &msg);
  EMomerr_hndlr(sts, wrapup, "ECmkcompcv: sleep dehilite");

wrapup:
  return ( sts );
}


method wakeup ( int pos )
{
  IGRlong       i, msg=1, sts=OM_S_SUCCESS;
  enum GRdpmode DisplayMode=GRhhd;

  sts = om$send (
    mode = OM_e_wrt_parent,
    msg = message ECmkcompcv.wakeup (pos),
    targetid = my_id
  );

  UI_status(" ");
  UI_prompt(" ");

  for ( i = 0; i <me->num_crv AND EMSokay (sts); i++)
  {
    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                        &me->locobj[i].module_info.md_env.matrix_type,
                        me->locobj[i].module_info.md_env.matrix,
                        &DisplayMode, &me->locobj[i].module_info.md_id),
                  targetid = me->locobj[i].located_obj.objid,
                  targetos = me->locobj[i].located_obj.osnum);
    EMomerr_hndlr(sts, wrapup, "ECmkcompcv: wakeup display");
  }     

wrapup:
  return ( sts );
}



method execute(int *response; char *response_data; int pos)
{
  extern IGRlong        EFshort_cvtn();
  IGRint                size, display_flag, mask, i, locate_mask,
                        accept_mask, j;
  IGRlong               sts, msg, return_num, rotten_one /*, eventmask */;
  enum GRdpmode         DisplayMode;
  struct GRevent        event, accept_event;
  struct GRlc_locate    attributes;
  IGRboolean            sts_okay = TRUE;
  IGRboolean            log_sts;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  IGRchar               prompt[80], header[80],
                        locate_prompt[40];
  IGRdouble             dist;
  IGRpoint              start_pnt, stop_pnt;
  IGRint                end_of_interest;
  struct GRprops        props;
  OM_S_CHANSELECT       to_components;
  IGRint                inx;
  OMuword               loc_obj_class_id;
  struct GRid           compcv_id, first_obj;
  extern   void                  EMgetendpnt();
  extern IGRlong   EMclose_composite();
  extern IGRlong   EMmaintain_first_component();


#define INIT     0
#define MODE     10
#define ID_FIRST 1
#define GET_REST 2
#define PROCESS  3

  sts = OM_S_SUCCESS;

  ex$message (msgnumb = EM_M_MakeCompositeCurve);

  do
  {
    switch(ME.super_cmd->state)
    {
    case INIT:
      log_sts = BSEXTRACTPAR(&msg, BSTOLLENVEC, me->connect_tol);
      log_sts = BSEXTRACTPAR(&msg, BSTOLCHRDHT, me->search_tol);

      ex$message (msgnumb = EMS_P_ConnectTol, buff = header);
      sts = EFshort_cvtn( header, me->connect_tol, 1,80);
      ex$message (msgnumb = EMS_P_SearchTol, buff = header);
      sts = EFshort_cvtn( header, me->search_tol, 2,80); 
      strncpy(prompt, header, 80);

      UI_status(prompt);
      ME.super_cmd->state = MODE;

    case MODE:
      ex$message (buff = prompt, msgnumb = EMS_P_ModeExtendtoIntersecty);  
      sts = co$getevent (
            msg = &msg,
            event_mask = GRm_BACK_UP | GRm_TEXT_VALUE | GRm_RJT_MOVEON,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
            );

      if (!sts)
           goto wrapup;
      else if (event.response IS GR_UNKNOWN_TYPE)
           return(OM_S_SUCCESS);
      else if (event.response IS EX_BACK_UP)
      {
           ME.super_cmd->state = MODE;
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

      ME.super_cmd->state = ID_FIRST;
      break;


    case ID_FIRST:
    {

#if ASSOC

/*
 * Do not locate associative wireframe elements.
 * pp - 11/10/88 
 */

       extern   IGRlong EFlocate_action_handler();
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

      compcv_id.objid = NULL;
      compcv_id.osnum = NULL;
      me->num_crv = 0;

      display_flag = 6;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;

      attributes.properties = 0x11 | LC_RW;
      attributes.owner_action = 0x6;

      size = sizeof(struct GRevent);

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

      rclass = OPP_GRcurve_class_id;
      eliclass = OPP_GRcurve_class_id;

      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

#if ASSOC
      sts = lc$locate(rc = &msg,
              event1 = &me->locate_event,
              event2 = &accept_event,
              mask1 = locate_mask, 
              mask2 = accept_mask,
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_key = EMS_P_IdentifyCurve1,
              acc_key = EMS_P_AccDatatoIndDirReject,
              relocate_key = EMS_I_CvNotLocated,
              act_handler = EFlocate_action_handler,
              act_args = &dont_locate,
              attributes = &attributes, 
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
#else
      sts = lc$locate(rc = &msg,
              event1 = &me->locate_event,
              event2 = &accept_event,
              mask1 = locate_mask, 
              mask2 = accept_mask,
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_key = EMS_P_IdentifyCurve1,
              acc_key = EMS_P_AccDatatoIndDirReject,
              relocate_key = EMS_I_CvNotLocated,
              attributes = &attributes, 
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
#endif

      UI_echo(" ");

      if ( ! sts )
      {
        fprintf(stderr, "ECmkcompcv execute, Error at case 1 for locate");
        goto wrapup;
      }
      else if (me->locate_event.response IS EX_BACK_UP )
      {
        ME.super_cmd->state = MODE;
        break;
      }

      else if((me->locate_event.response IS GR_UNKNOWN_TYPE) OR
              (accept_event.response IS GR_UNKNOWN_TYPE) )
         return(OM_S_SUCCESS);
      else
      {
        me->locobj[0] = accept_event.located_object[0]; 
        me->ModuleInfo = accept_event.located_object[0].module_info;
        ME.super_cmd->state = GET_REST;
        me->num_crv = 1;

        /*
         * process accept_event.event to determine
         * if the curve identified needs to be reversed or not.
         * Thus the stop point of the curve is always the
         * flow direction as far as the methods are concerned.
         */

         EMgetendpnt(&msg, &accept_event, &accept_event, &me->ModuleInfo,
                     me->connect_tol, my_id, start_pnt, stop_pnt,
                     &end_of_interest);

         if (msg != MSSUCC)
         {
            goto wrapup;
         }
         else if (end_of_interest < 0)
         {
            /* unhilite curve */

            DisplayMode = GRbdhe;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                   &me->ModuleInfo.md_env.matrix_type,
                                   me->ModuleInfo.md_env.matrix,
                                   &DisplayMode, &me->ModuleInfo.md_id),
                             targetid = me->locobj[0].located_obj.objid,
                             targetos = me->locobj[0].located_obj.osnum);
            EMomerr_hndlr(sts, wrapup, "phy closed display");
            EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

            ex$message (msgnumb = EMS_S_CurvePhysicallyClosed);

            ME.super_cmd->state = ID_FIRST;
            me->num_crv--;
            break;
         }
         else if (end_of_interest == 0)
         {
            me->flow_pnt[0] = start_pnt[0];
            me->flow_pnt[1] = start_pnt[1];
            me->flow_pnt[2] = start_pnt[2];

            sts = om$send(msg = message GRcurve.GRrevparm(&msg,
                                   &me->ModuleInfo),
                             targetid = me->locobj[0].located_obj.objid,
                             targetos = me->locobj[0].located_obj.osnum);
            EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRrevparm");
            EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);
         }
         else if (end_of_interest == 1)
         {
            me->flow_pnt[0] = stop_pnt[0];
            me->flow_pnt[1] = stop_pnt[1];
            me->flow_pnt[2] = stop_pnt[2];
         }

      } /* end else DATA */
     }

      break;


    case GET_REST:
    {
       struct GRevent event3;


#if ASSOC 

       extern   IGRlong EFlocate_action_handler();
       struct   EMSaction_handler dont_locate;
       OMuword reject_classid;
/*
 * Do not locate associative wireframe elements.
 * pp - 11/10/88 
 */

       reject_classid = OPP_ASnode_class_id;
       dont_locate.next = NULL;
       dont_locate.option = 2;
       dont_locate.type = 3;
       dont_locate.num_objects = 1;
       dont_locate.objects.classids = &reject_classid;

/* end pp change - 11/10/88 */

#endif

      size = sizeof(struct GRevent);

      display_flag = 70;
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA;

      attributes.properties = 0x11 | LC_RW;
      attributes.owner_action = 0x6;

      if (me->num_crv > 1)
      {
        ex$message (buff = locate_prompt, msgnumb = EMS_P_00037, 
                    type = "%d", var = me->num_crv + 1);
      }
/*        sprintf(locate_prompt, "Identify curve %d/move on",
                me->num_crv + 1);
*/
      else
      {
        ex$message (buff = locate_prompt, msgnumb = EMS_P_00035, 
                    type = "%d", var = me->num_crv + 1);
      }
/*        sprintf(locate_prompt, "Identify curve %d",
                me->num_crv + 1);
*/
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_GRcurve_class_id;
       eliclass = OPP_GRcurve_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

#if ASSOC
       sts = lc$locate(rc = &msg,
              event1 = &me->locate_event,
              event2 = &me->accept_event,
              event3 = &event3,
              mask1 = locate_mask, 
              mask2 = accept_mask,
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_prompt = locate_prompt,
              acc_key = EMS_P_AccwCv,
              relocate_key = EMS_I_CvNotLocated,
              act_handler = EFlocate_action_handler,
              act_args = &dont_locate,
              attributes = &attributes, 
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
#else
       sts = lc$locate(rc = &msg,
              event1 = &me->locate_event,
              event2 = &me->accept_event,
              event3 = &event3,
              mask1 = locate_mask, 
              mask2 = accept_mask,
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_prompt = locate_prompt,
              acc_key = EMS_P_AccwCv,
              relocate_key = EMS_I_CvNotLocated,
              attributes = &attributes, 
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
#endif

      UI_echo(" ");

      if ( ! sts )
      {
        fprintf(stderr, "ECmkcompcv execute, Error at case 2 for locate");
        goto wrapup;
      }

#if DEBUG
    fprintf(stderr,"\nloc_event.response = %d", me->locate_event.response);
    fprintf(stderr,"\nacc_event.response = %d", me->accept_event.response);
    fprintf(stderr,"\nloc_obj_event.response = %d", event3.response);
    fprintf(stderr,"\nloc_stk.#entries = %d", me->locate_stack.num_entries);
    fprintf(stderr,"\nloc_stk.#loc = %d", me->locate_stack.number_located);
#endif

    if (msg == LC_OBJ_LOCATED) /*Something was located.*/
    {
      me->locate_event.num_id = event3.num_id;
      me->locate_event.located_object[0] = event3.located_object[0];
      me->locate_event.response = me->accept_event.response; /*correct it*/
    }
    else if (me->locate_stack.num_entries)
      /*Exited locate during acc/rjt, reflect response in locate_event.*/
      me->locate_event.response = me->accept_event.response; 
    else if (me->locate_event.response == EX_DATA)    
      me->locate_event.response = EX_BACK_UP; /*Backed out of acc/rjt*/

      if (me->locate_event.response IS EX_BACK_UP )
      {
         DisplayMode = GRhe;
         i = me->num_crv - 1;        /* index of last curve */

         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->locobj[i].module_info.md_env.matrix_type,
                             me->locobj[i].module_info.md_env.matrix,
                             &DisplayMode,
                             &me->locobj[i].module_info.md_id),
                       targetid = me->locobj[i].located_obj.objid,
                       targetos = me->locobj[i].located_obj.osnum);
         EMomerr_hndlr(sts, wrapup, "ECmkcompcv: reset display");
         EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

         me->num_crv--;
         if(me->num_crv IS 0)ME.super_cmd->state = ID_FIRST;
       }

       else if((me->locate_event.response IS GR_UNKNOWN_TYPE) OR
               (me->accept_event.response IS GR_UNKNOWN_TYPE) ||
               (event3.response == GR_UNKNOWN_TYPE))
          return ( OM_S_SUCCESS );

       else if (me->locate_event.response IS EX_RJT_MOVEON )
          ME.super_cmd->state = PROCESS;

       else      /* Continue adding located objects to the list */
       {
         /*
          * Get the endpoints of the
          * located obj and check for
          * any gaps
          */

         event = me->accept_event;
         event.located_object[0] = event3.located_object[0];
         event.event.button.x = me->flow_pnt[0];
         event.event.button.y = me->flow_pnt[1];
         event.event.button.z = me->flow_pnt[2];

         EMgetendpnt(&msg, &event, &event, &me->ModuleInfo,
                     me->connect_tol, my_id, start_pnt, stop_pnt,
                     &end_of_interest);

         if (end_of_interest == 0)
         {
            dist = BSdistptpt(&msg, me->flow_pnt, start_pnt);
            EMerr_hndlr(msg != BSSUCC, sts, OM_E_ABORT, wrapup);

            me->flow_pnt[0] = stop_pnt[0];
            me->flow_pnt[1] = stop_pnt[1];
            me->flow_pnt[2] = stop_pnt[2];
         }
         else if (end_of_interest == 1)
         {
            dist = BSdistptpt(&msg, me->flow_pnt, stop_pnt);
            EMerr_hndlr(msg != BSSUCC, sts, OM_E_ABORT, wrapup);

            me->flow_pnt[0] = start_pnt[0];
            me->flow_pnt[1] = start_pnt[1];
            me->flow_pnt[2] = start_pnt[2];
         }
         else  /* the add curve is closed */
         {
            DisplayMode = GRbdhe;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                   &me->ModuleInfo.md_env.matrix_type,
                                   me->ModuleInfo.md_env.matrix,
                                   &DisplayMode, &me->ModuleInfo.md_id),
                             targetid = event3.located_object[0].
                                        located_obj.objid,
                             targetos = event3.located_object[0].
                                        located_obj.osnum);
            EMomerr_hndlr(sts, wrapup, "EClink: phy closed display");
            EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

            /*
             * 12/09/92 - JSD - changing call to make ums compliant
             */
            ex$message (msgnumb = EMS_S_CurvePhysicallyClosed);

            break;
         }

         /*
          * Check for a gap between the curves
          */

         if (dist > me->connect_tol)  /* there's a gap */
         {
            ex$message (msgnumb = EMS_S_GapDist);
            sts = EFshort_cvtn(prompt, dist, 0, 80); 
            UI_echo(prompt);

            if (!me->ext_to_int)
            {
               DisplayMode = GRbdhe;
               sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                      &me->ModuleInfo.md_env.matrix_type,
                                      me->ModuleInfo.md_env.matrix,
                                      &DisplayMode, &me->ModuleInfo.md_id),
                                targetid = event3.located_object[0].
                                           located_obj.objid,
                                targetos = event3.located_object[0].
                                           located_obj.osnum);
               EMomerr_hndlr(sts, wrapup, "EClink: display");
               EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

               break;
            }
         }  /* ends if dist > connect_tol */

         i = OM_DIMENSION_OF(me->locobj);

         if (i <= me->num_crv )
         {
           i += DIMEN_INC;
/* rlw bug fix 09/24/87 */
/*         OM_SET_DIMENSION(me->locobj, DIMEN_INC); */
           OM_SET_DIMENSION(me->locobj, i); 
         }               

        me->locobj[me->num_crv] = event3.located_object[0];
        me->num_crv++;

/*
 * If the located object is the same as the accepted object do not put
 * on queue to prevent relocation of the same object.
 */

       if ( (me->locate_event.subtype != GRst_REGULAR) && 
            me->locate_event.num_id && 
            (me->locate_event.located_object[0].located_obj.objid ==
             me->accept_event.located_object[0].located_obj.objid) ) break;

        size = sizeof(struct GRevent);
        log_sts = ex$putque(msg = &msg,
                            response = response,
                            byte = (long *) &size,
                            buffer = (char *) &me->accept_event.event);

       }  /* end else continue to add obj */

     }
      break;


    case PROCESS:
      return_num = 0;

      ex$message (msgnumb = EMS_I_Processing);
      UI_prompt(" ");

      /*
       * Make the chanselect to use in the processing.
       */

      sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
      EMomerr_hndlr(sts, wrapup, "EMmake_chanselect\n");

      /*
       * A composite of only one curve
       * is not valid.
       */

      if (me->num_crv == 1)
      {
         ex$message (msgnumb = EMS_S_CannotMakeCompOutofOneCv);

         DisplayMode = GRbdhe;
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->ModuleInfo.md_env.matrix_type,
                             me->ModuleInfo.md_env.matrix,
                             &DisplayMode, &me->ModuleInfo.md_id),
                       targetid = me->locobj[0].located_obj.objid,
                       targetos = me->locobj[0].located_obj.osnum);
         EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");
         EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

         ME.super_cmd->state = ID_FIRST;
         break;
      }

      /*
       * Dehilite the curves and erase them if the mode is extend to int.
       */

      dp$erase_hilite(msg = &msg);
      EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

      if (me->ext_to_int)
      {
        DisplayMode = GRbe;
        for (i = 0; i < me->num_crv; i++)
        {
           sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                               &me->ModuleInfo.md_env.matrix_type,
                               me->ModuleInfo.md_env.matrix,
                               &DisplayMode, &me->ModuleInfo.md_id),
                         targetid = me->locobj[i].located_obj.objid,
                         targetos = me->locobj[i].located_obj.osnum);
            EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");
            EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);
        }
      }  /* end if ext_to_int */

      /*
       * Get the classid and test to see
       * if first object is a composite.
       */
  
      sts = om$get_classid(osnum = me->locobj[0].located_obj.osnum,
                           objid = me->locobj[0].located_obj.objid,
                           p_classid = &loc_obj_class_id);
      EMomerr_hndlr(sts, wrapup, "ECcompcv: get classid");

      if ( loc_obj_class_id IS_NOT OPP_GRcompcurve_class_id )
      {
         struct GRvg_construct  construct_list;

         first_obj.objid = me->locobj[0].located_obj.objid;
         first_obj.osnum = me->locobj[0].located_obj.osnum;

         construct_list.msg        = (IGRlong *)&msg;
         construct_list.class_attr = NULL;
         construct_list.level      = me->ActiveLevel;
         construct_list.display    = &me->ActiveDisplay;
         construct_list.env_info   = &me->ModuleInfo;
         construct_list.newflag    = FALSE;
         construct_list.name       = NULL;
         construct_list.properties = GRIS_NEW | GRIS_LOCATABLE
                                              | GRIS_DISPLAYABLE;

         sts = om$construct(classid = OPP_GRcompcurve_class_id,
                            p_objid = &compcv_id.objid,
                            osnum = me->locobj[0].located_obj.osnum,
                            msg = message GRgraphics.GRconstruct(
                                          &construct_list) );
         EMomerr_hndlr(sts, wrapup, "ECmkcompcv: construct error");
         compcv_id.osnum = me->locobj[0].located_obj.osnum;

         sts = om$send(msg = message GRcompcurve.EMmakecomp(&msg,
                             &me->ModuleInfo, 1, &me->locobj[0],
                             &rotten_one),
                       targetid = compcv_id.objid,
                       targetos = compcv_id.osnum);
         EMomerr_hndlr(sts, wrapup, "ECmkcompcv: makecomp error1");
         EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);
      }
      else       /* this composite has a valid tail */
      {
         compcv_id.objid = me->locobj[0].located_obj.objid;
         compcv_id.osnum = me->locobj[0].located_obj.osnum;

         sts = om$get_objid_at_index(objid = compcv_id.objid,
                                     osnum = compcv_id.osnum,
                                     p_chanselect = &to_components,
                                     index = 0,
                                     objidaddr = &first_obj.objid,
                                     osnumaddr = &first_obj.osnum);
         EMomerr_hndlr(sts, wrapup, "om$get_objid_at_index");
      }

      for (i = 1; i < me->num_crv; i++)
      {
          sts = om$send(msg = message GRcompcurve.EMaddtocomp(&msg,
                              me->locobj[i].located_obj,
                              &me->locobj[i].module_info,
                              &me->ModuleInfo, me->ext_to_int,
                              me->search_tol,
                              me->connect_tol, FALSE,
                              start_pnt, stop_pnt,
                              &return_num),
                        targetid = compcv_id.objid,
                        targetos = compcv_id.osnum);
          EMomerr_hndlr_action(sts, msg = MSFAIL, "EMaddtocomp\n");

          if ( (msg == EMS_E_NoIntersection) ||
               (msg == EMS_E_Modified) )
          {
            sts_okay = FALSE;
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
            sts_okay = FALSE;
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
            sts_okay = FALSE;
            if (i == 1)
            {
              ex$message (msgnumb = EMS_S_InvalidCvCCvNotDefined);
            }
            else
            {
              ex$message (msgnumb = EMS_S_InvalidCvCCvDefined);
            }
          }

          if (!sts_okay)
          {
            /*
             * If it failed at the first add
             * attempted and the located_object's
             * class id wasn't originally a 
             * composite curve, then drop (delete) the
             * constructed composite curve and redisplay
             * the first curve.
             */

            if ( (i == 1) &&
                 (loc_obj_class_id != OPP_GRcompcurve_class_id) )
            {
               sts = om$send(msg = message GRowner.GRdrop(&msg,
                                   &me->ModuleInfo),
                             targetid = compcv_id.objid,
                             targetos = compcv_id.osnum);
               EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");

               DisplayMode = GRbd;
               sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                   &me->ModuleInfo.md_env.matrix_type,
                                   me->ModuleInfo.md_env.matrix,
                                   &DisplayMode, &me->ModuleInfo.md_id),
                             targetid = me->locobj[0].located_obj.objid,
                             targetos = me->locobj[0].located_obj.osnum);
               EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");
               EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

               compcv_id.objid = NULL;
               compcv_id.osnum = NULL;
            }

            /* 
             * On error, redisplay the
             * remaining curves and display
             * the bad curve in highlight.
             */

            DisplayMode = GRbd;
            for (j = i; j < me->num_crv; j++)
            {
                sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                    &me->ModuleInfo.md_env.matrix_type,
                                    me->ModuleInfo.md_env.matrix,
                                    &DisplayMode, &me->ModuleInfo.md_id),
                             targetid = me->locobj[j].located_obj.objid,
                             targetos = me->locobj[j].located_obj.osnum);
                EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");
                EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);
            }

            DisplayMode = GRhd;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->ModuleInfo.md_env.matrix_type,
                                me->ModuleInfo.md_env.matrix,
                                &DisplayMode, &me->ModuleInfo.md_id),
                          targetid = me->locobj[i].located_obj.objid,
                          targetos = me->locobj[i].located_obj.osnum);
            EMomerr_hndlr(sts, wrapup, "ECmkcompcv: GRdisplay");
            EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

            break;

          } /* if (!sts_okay) */

      }  /* for  addtocomp */


      if (sts_okay)
      {
        /*
         * If mode is extend to intersection, call EMclose_composite
         * to test to see if there is a gap at the endpoints of the
         * composite.  If there is a gap, it will close it off.
         */

        if (me->ext_to_int)
        {
          sts = EMclose_composite(&msg, &me->ModuleInfo, compcv_id,
                                  me->search_tol, me->connect_tol);
          EMomerr_hndlr(sts, wrapup, "EClink:EMclose_composite\n");
          EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

        }  /* end endpoints gap check */

        /*
         * Call EMmaintain_first_component to check for composite closed.
         * If it is closed, then check to see if the first located
         * object is the first object in the composite.
         * If not, cyclic shift.
         */

        sts = EMmaintain_first_component(&msg, &me->ModuleInfo,
                                         compcv_id, first_obj);
        EMomerr_hndlr(sts, wrapup, "EClink:EMmaintain_first_comp\n");
        EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);

        if (msg != EMS_I_Open)
        {
          ex$message (msgnumb = EMS_I_CompCurveIsClosed);
        }
        
        ex$message (msgnumb = EMS_S_CompCurveIsDefined);

      }  /* end if sts_okay */

      /*
       * If I have a composite, then display it.
       */

      if (compcv_id.objid)
      {
         DisplayMode = GRbd;
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->ModuleInfo.md_env.matrix_type,
                             me->ModuleInfo.md_env.matrix,
                             &DisplayMode, &me->ModuleInfo.md_id),
                       targetid = compcv_id.objid,
                       targetos = compcv_id.osnum);
         EMomerr_hndlr(sts, wrapup, "ECmkcompcv: final display\n");
         EMerr_hndlr(EMis_error(msg), sts, OM_E_ABORT, wrapup);
      }

      ME.super_cmd->state = ID_FIRST;
      break;


    default:
      fprintf(stderr, "Error reached at default state ");
      goto wrapup;

    } /* end of switch */

  } /* end of do loop */
 while ( TRUE );

wrapup:
 *response = TERMINATE;
 return(sts);

} /* execute method */

end implementation ECmkcompcv;
