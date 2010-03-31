/* ###################   APOGEE COMPILED   ################## */
class implementation ECstitch;

/*
HISTORY

07/21/92    NP	Updated for message subsystem compliance.
06/04/91    DLB Support current_creator.
22 May 1989 jBk Replaced GRm_STRING masks with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

15 May 1989 jBk Removed init, wakeup and sleep implementations.

                Replaced usages of redundant instance variable,
                struct GRmd_env mod_info, with usages of
                me^^ECelement.md_env.
*/

#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

# include "griomacros.h" /* co$getevent */

#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "EMSmsgdef.h"
#include "exmacros.h"
#include "msmacros.h" /* for ex$message */
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"

#define MYTYPE_STITCH   0
#define MYTYPE_MATCH    1
#define MYTYPE_IGNOREGAP 2

#define STITCH          4
#define ASK_INVESTIGATE 5
#define SAMPLE_SIZE     6
#define TOLERANCE       7
#define FILENAME        8
#define MATCH           9

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsfstitch_class_id;

from GRgraphics import GRdisplay;
from EMSsubbs import EMgetedges, EMmk_nat_bdry;
from GRvg import GRchgprops;
from EMSsurface import EMdisplay_edges;
from EMSedge import EMstitch;
from EMSsfstitch import EMmake_comp;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func, hili;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint event_size, display_flag;
  IGRlong stat_OM, msg_loc, qsize;
  IGRlong event_mask1, event_mask2;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT       to_loopset;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  struct GRid           *edges = NULL, activeid;
  OMuint                count;
  IGRint                num_edges = 0, buf_size = 0;

  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECstitch.execute"); /* no message key needed here */
  

  if (ME.super_cmd->mytype == MYTYPE_STITCH)
  {
      ex$message(msgnumb = EM_M_StitchTwoEdges);
  }
  else if (ME.super_cmd->mytype == MYTYPE_MATCH)
  {
      ex$message(msgnumb = EM_M_InvestigateEdgeMatch);
  }
  else if (ME.super_cmd->mytype == MYTYPE_IGNOREGAP)
  {
    ex$message(msgnumb = EMS_I_TwilightZone);
    ex$message(msgnumb = EM_M_StitchTwoEdgesIgnoreGap);
  }
    

  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

  do 
    {
    switch (ME.super_cmd->state)
      {
      case 0:
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
        ex$message(msgnumb = EMS_P_IdentifySurface1,
                   buff    = loc_prompt);
    display_flag = 6;
    ex$message(msgnumb = EMS_P_AccWithEdgeReject,
               buff    = acc_prompt);
    ex$message(msgnumb = EMS_I_00011,
               buff    = reloc_prompt);
    lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY |
                         IGN_MOD_BIT;
    lc_attr.owner_action = LC_RIGID_COMP | LC_LOCALMOD |
                           LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER;

    strcpy(lc_attr.classes, "EMSsubbs");

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsubbs_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelement->locev, 
              event2 = &accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &lc_attr, 
              stack = &ME.ECelement->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

        ex$message(msgnumb = EM_M_ClearMessageField);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
          {
            ME.super_cmd->state = 0;
            break;
          }
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:
            me->surf[0].objid = accev.located_object[0].located_obj.objid;
            me->surf[0].osnum = accev.located_object[0].located_obj.osnum;

            stat_OM = om$get_channel_count(objid = me->surf[0].objid,
                                 osnum = me->surf[0].osnum,
                                 p_chanselect=&to_loopset,
                                 count=&count);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

            if(!count)
            {
               stat_OM = om$send(msg=message EMSsubbs.EMmk_nat_bdry (&msg_loc, 
                          &me^^ECelement.md_env.md_env, NULL), 
                      targetos = me->surf[0].osnum,
                      targetid = me->surf[0].objid);
               EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
               EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
                        ret_end);
            }
            (ME.super_cmd->state) ++;
            qsize = sizeof(accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = &qsize,
                          buffer = (char *)&accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
            break;
          default:
            goto ret_end;
          }
        break;


      case 1:

        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me^^ECelement.md_env.md_env.matrix_type,
                         me^^ECelement.md_env.md_env.matrix,
                           &dpmode, &me^^ECelement.md_env.md_id),
                          senderid = my_id,
                       targetid = me->surf[0].objid,
                       targetos = me->surf[0].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            msgnum = EMS_P_IdentifyEdge,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;             
        switch (event.response)
          {
          case EX_DATA:
            me->button = event.event.button;
            num_edges = 0;
            stat_OM = om$send(msg = message EMSsubbs.EMgetedges(&msg_loc,
                                        EMS_OPT_CONNECTABLE,
                                        &edges, &buf_size, &num_edges,
                                        NULL, NULL, NULL, NULL),
                        targetid = me->surf[0].objid,
                        targetos = me->surf[0].osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        
            if (! num_edges)
            {
                ex$message(msgnumb = EMS_I_SurfNoStitchEdges);
                ME.super_cmd->state = 0;
                break;
            }
            stat_OM = dp$erase_hilite(msg = &msg_loc);

            ex$message(msgnumb = EMS_P_AccWithSurf2RejectEdge,
                       buff    = acc_prompt);
            stat_OM = EMtpselect(&msg_loc, edges, me->surf[0], num_edges,
                                 EMS_GET_MOD_EDGE, NULL, event,
                                 &me^^ECelement.md_env,
                                 acc_prompt, &event_mask1,
                                 &event_size, response, response_data,
                                 &accev, &hili);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (accev.response == EX_BACK_UP ||
                accev.response == GR_UNKNOWN_TYPE)  break;

            me->pair.edge0 = accev.located_object[0].located_obj.objid;
            qsize = sizeof(accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = &qsize,
                          buffer = (char *)&accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

            ME.super_cmd->state = 2;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 0;
            break;
          default:
            goto ret_end;
          }
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        break;


      case 2:
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
      ex$message(msgnumb = EMS_P_IdentifySurface2,
                 buff    = loc_prompt);
    display_flag = 6;
    ex$message(msgnumb = EMS_P_AccWithEdgeReject,
               buff    = acc_prompt);
    ex$message(msgnumb = EMS_I_00011,
               buff    = reloc_prompt);
    lc_attr.properties = 0x11 | LC_RW;
    lc_attr.owner_action = LC_RIGID_COMP | LC_LOCALMOD | 
                           LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER;
    strcpy(lc_attr.classes, "EMSsubbs");

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsubbs_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelement->locev, 
              event2 = &accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &lc_attr, 
              stack = &ME.ECelement->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

        ex$message(msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
          {
            ME.super_cmd->state = 1;
            break;
          }
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:
            me->surf[1].objid = accev.located_object[0].located_obj.objid;
            me->surf[1].osnum = accev.located_object[0].located_obj.osnum;

            stat_OM = om$get_channel_count(objid = me->surf[1].objid,
                                 osnum = me->surf[1].osnum,
                                 p_chanselect=&to_loopset,
                                 count=&count);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

            if(!count)
            {
               stat_OM = om$send(msg=message EMSsubbs.EMmk_nat_bdry (&msg_loc, 
                          &me^^ECelement.md_env.md_env, NULL), 
                      targetos = me->surf[1].osnum,
                      targetid = me->surf[1].objid);
               EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
               EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
                        ret_end);
            }
            (ME.super_cmd->state) ++;
            qsize = sizeof(accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = &qsize,
                          buffer = (char *)&accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
            break;
          default:
            goto ret_end;
          }
        break;


      case 3:

        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me^^ECelement.md_env.md_env.matrix_type,
                         me^^ECelement.md_env.md_env.matrix,
                           &dpmode, &me^^ECelement.md_env.md_id),
                          senderid = my_id,
                       targetid = me->surf[1].objid,
                       targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            msgnum = EMS_P_IdentifyEdge,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;             
        switch (event.response)
          {
          case EX_DATA:
            num_edges = 0;
            stat_OM = om$send(msg = message EMSsubbs.EMgetedges(&msg_loc,
                                        EMS_OPT_CONNECTABLE,
                                        &edges, &buf_size, &num_edges,
                                        NULL, NULL, NULL, NULL),
                        targetid = me->surf[1].objid,
                        targetos = me->surf[1].osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        
            if (! num_edges)
            {
                ex$message(msgnumb = EMS_I_SurfNoStitchEdges);
                ME.super_cmd->state = 2;
                break;
            }
            stat_OM = dp$erase_hilite(msg = &msg_loc);
            ex$message(msgnumb = EMS_P_AccRejEdge,
                       buff    = acc_prompt);
            stat_OM = EMtpselect(&msg_loc, edges, me->surf[1], num_edges,
                                 EMS_GET_MOD_EDGE, NULL, event,
                                 &me^^ECelement.md_env, acc_prompt, &event_mask1,
                                 &event_size, response, response_data,
                                 &accev, &hili);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (accev.response == EX_BACK_UP ||
                accev.response == GR_UNKNOWN_TYPE)  break;

            me->pair.edge1 = accev.located_object[0].located_obj.objid;
            if (me->pair.edge1 == me->pair.edge0)
            {
                ex$message(msgnumb = EMS_I_CantStitchToSelf);
                ME.super_cmd->state = 0;
                break;
            }
            ME.super_cmd->state = 
                (ME.super_cmd->mytype == MYTYPE_STITCH) ||
                (ME.super_cmd->mytype == MYTYPE_IGNOREGAP)
		? STITCH : SAMPLE_SIZE; 
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 2;
            break;
          default:
            goto ret_end;
          }
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        break;


      case STITCH:

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_Processing);

        activeid.osnum = me->surf[0].osnum;
        stat_OM = om$construct(classid = OPP_EMSsfstitch_class_id,
                       p_objid = &activeid.objid,
                       osnum = me->surf[0].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

        me->pair.surf0 =  me->surf[0].objid;
        me->pair.surf1 =  me->surf[1].objid;
        me->pair.edge_geom0 = me->pair.edge_geom1 = NULL;
        me->pair.surf_geom0 = me->pair.surf_geom1 = NULL;
        me->pair.option = NULL;

        if(ME.super_cmd->mytype == MYTYPE_IGNOREGAP)
          me->pair.option |= EMSstitch_IgnoreGap;
         
        {
          extern OM_S_OBJID current_creator;
          current_creator = activeid.objid;
          stat_OM = om$send(msg = message EMSsfstitch.EMmake_comp(&msg_loc, 
                                0, NULL, &me^^ECelement.md_env, NULL, 
                                &me->pair, 
                                1, NULL, /*EMSmakecs_FineToCoarseTol*/ NULL), 
                          targetid = activeid.objid, 
                          targetos = activeid.osnum);
          current_creator = NULL_OBJID;
        }
                              
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        if (msg_loc == EMS_I_Fail)
        {
         OM_S_CHANSELECT       to_comps;  /*DECL*/
         OMuint                 count;
        
         ex$message(msgnumb = EMS_I_CantStitchEdges);
         ems_sleep(2);

         stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

         EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
         stat_OM = om$get_channel_count(objid = activeid.objid,
                                   osnum = activeid.osnum,
                                   p_chanselect = &to_comps,
                                   count = &count);
  
         EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
         if (!count)
          {
           stat_OM = om$send(msg = message Root.delete(0),
                        targetos = activeid.osnum,
                        targetid = activeid.objid);
          }
         ME.super_cmd->state = ASK_INVESTIGATE;
         break;
        }
        else
        {
           ex$message(msgnumb = EMS_I_StitchSuccessful);
        }
        ME.super_cmd->state = 0;
        break;


      case ASK_INVESTIGATE:
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            msgnum = EMS_P_InvestigateEdgeMatch,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
          ME.super_cmd->state = SAMPLE_SIZE;
          break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;             
        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'N')
                    ME.super_cmd->state = 0;
            else ME.super_cmd->state = SAMPLE_SIZE;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 3;
            break;
          case EX_RJT_MOVEON:
            ME.super_cmd->state = SAMPLE_SIZE;
            break;
          default:
            goto ret_end;
          }
        break;

      case SAMPLE_SIZE:
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_SCALAR,
            msgnum = EMS_P_EntNumSampPtsEdgeMoveOnQuit,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
          me->sample_size = 4;
          ME.super_cmd->state = TOLERANCE;
          break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_VALUE:
            if (event.event.value < 2)
              {             
              ex$message(msgnumb = EMS_I_SampleSizeAtLeast2);
              break;
              }
            me->sample_size = event.event.value;
            ME.super_cmd->state = TOLERANCE;
            break;
          case EX_RJT_MOVEON:
            ME.super_cmd->state = 0;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = ASK_INVESTIGATE;
            break;
          default:
            goto ret_end;
          }
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        break;


      case TOLERANCE:
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_SCALAR,
            msgnum = EMS_P_EntEdgeMatchTol,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
          me->use_sti_tol = TRUE;
          ME.super_cmd->state = FILENAME;
          break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
              ex$message(msgnumb = EMS_I_EdgeMatchTolPositive);
              break;
              }
            me->use_sti_tol = FALSE;
            me->match_tol = event.event.value;
            ME.super_cmd->state = FILENAME;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = SAMPLE_SIZE;
            break;
          case EX_RJT_MOVEON:
            me->use_sti_tol = TRUE;
            ME.super_cmd->state = FILENAME;
            break;
          default:
            goto ret_end;
          }
        break;


      case FILENAME:
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            msgnum = EMS_P_EnterFileNameStderr,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC) goto ret_end;             
        switch (event.response)
          {
          case STRING:
            if (event.event.keyin[0] == NULL)
                me->is_fileptr = FALSE;
            else
            {
                me->fileptr = fopen(event.event.keyin, "a");
                if (! me->fileptr)
                  {  ex$message(msgnumb = EMS_S_FilCantOpen);
                     break;
                  }
                me->is_fileptr = TRUE;
            }
            ME.super_cmd->state = MATCH;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = TOLERANCE;
            break;
          case EX_RJT_MOVEON:
            me->is_fileptr = FALSE;
            ME.super_cmd->state = MATCH;
            break;
          default:
            goto ret_end;
          }
        break;


      case MATCH:

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_Processing);

        stat_OM = dp$erase_hilite(msg = &msg_loc);

        me->pair.surf0 =  me->surf[0].objid;
        me->pair.surf1 =  me->surf[1].objid;
        me->pair.edge_geom0 = me->pair.edge_geom1 = NULL;
        me->pair.surf_geom0 = me->pair.surf_geom1 = NULL;
        me->pair.option = EMSstitch_TopEdge | EMSstitch_InternalValidation;
        if (! me->use_sti_tol) me->pair.option |= EMSstitch_MatchTolerance;

        stat_OM = om$send(msg = message EMSedge.EMstitch(&msg_loc,
                                &me->pair,
                                &me^^ECelement.md_env,
                                NULL, me->sample_size, me->match_tol,
                                &me->button,                            
                                me->is_fileptr ? me->fileptr : NULL),
                        targetos = me->surf[0].osnum,           
                        targetid = me->pair.edge0);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        if (msg_loc == EMS_I_Fail)
                ex$message(msgnumb = EMS_I_GapPtsDisplayed);
        if (me->is_fileptr) fclose(me->fileptr);
        ME.super_cmd->state = SAMPLE_SIZE;
        break;


      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:

  if (edges) om$dealloc(ptr = edges);

  /*
    Sleep message implementation always performed the
    dp$erase_hilite.  To obviate need for override, I do it here.
    -- jBk 15 May 1989
  */
  {
    IGRlong dpehrc;

    dp$erase_hilite (msg = &dpehrc);
  }

  return (stat_OM);
}

end implementation ECstitch;
