/* ###################   APOGEE COMPILED   ################## */
class implementation ECdprundo;

#include "EMS.h"
/*
DESCRIPTION
        This command will undo to a last state in the state tree if
        one exists. The command will locate a solid and if the solid
        is on the tree (has a last state), then it is undone. The
        last state of the solid is displayed. If the current state is
        only a local mod then the same object is redisplayed with the
        modification undone. If the current state is a global mod
        then the last two objects that formed this object will be 
        displayed.
NOTES
        None.

ASSUMPTIONS
        None.

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

SEE ALSO

BUGS
        Note the comments in the code where external routines
        do not behave as is expected.

HISTORY
        scw     08/14/94    Clarified Sleep method
	Tapadia  5/26/92    Modified for message sub system compliance
        DLB     07/08/91    Add flex_owner to locate_owner actions.
        AMD     04/05/90    Added code to handle multiple undo for
                            multiple booleans.
        AIC     07 Apr 88   Include EMSlcdef.h.
        DLB     01/06/87    Creation date.
*/

#define UNDO 0

#include <stdio.h>
#include "msmacros.h"
#include "ECdlb.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "EMSprop.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"

from GRgraphics import GRdisplay;
from EMSsurface import EMgetactiveid, EMisClassInTree;
from EMSdpr     import EMundo;
from EMSdpr     import EMmult_undo;
from EMSdpr     import EMget_dpr_props;

extern OMuword OPP_EMSsfhist_class_id,
               OPP_EMSsubbs_class_id,
               OPP_EMSdpr_class_id;

static IGRboolean aflag;

method wakeup(int pos)
{
 return OM_S_SUCCESS;
}


method super_cmd.sleep(int pos)
{
 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EM_M_ClearMessageField);
 return OM_S_SUCCESS;
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS, size=sizeof(struct GRevent),display_flag;
 IGRlong               msg;
 IGRint                locate_mask, accept_mask, token, count, dummy;
 IGRint                i;
 enum     GRdpmode     display_mode;
 struct GRid           *old_solid;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 IGRushort     	       option;
 OMuword               rclass, eliclass;
 IGRchar               loc_prompt[54], acc_prompt[54], reloc_prompt[54];

 IGRlong RFlocate_element_for_undo_handler();
 
/* TABLE STUFF */

#define NUM_TOKENS 3
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, initialize, store_sol, undo
    };

#define NUM_STATES 2
    enum states
    {
        start, got_sol
    };

    /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP     DATA      UNK
    old state: */                                   
    /* start    */ {start,    got_sol,  start   },
    /* got_sol  */ {got_sol,  start,    got_sol }
    };

    /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP  DATA        UNK
    old state: */                                     
    /* start    */ {NIL,   store_sol,  NIL }, 
    /* got_sol  */ {NIL,   undo,       NIL }
    };

 ex$message(msgnumb = EM_M_UndoState);

 do
 {
  switch (ME.COconst->action)
  {
   case NIL:
   {
    break;
   }


   case ERR:
   {
    break;
   }
 

   case initialize:
   {
    break;
   }


   case store_sol:
   {
    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->solid_info, sizeof(struct GRlc_info));
    break;
   }   


   case undo:
   {
    GRobjid *display_ids=NULL;           /*DECLARATION*/
    IGRint display_count=0, involk_count=0;
    struct GRid active_id;
    IGRboolean gothist = FALSE;

    ex$message(msgnumb = EMS_I_00003);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    sts = om$send(msg = message EMSsurface.EMisClassInTree(&msg,
                        &OPP_EMSsfhist_class_id, 1, &gothist, TRUE),
                  targetid = me->solid_info.located_obj.objid,
                  targetos = me->solid_info.located_obj.osnum);
    ERROR(sts, EMS_S_Success, "ECbool_exec get classid", wrapup);   
                         
    if (gothist)
    {
       active_id.objid = NULL_OBJID;
       active_id.osnum = OM_Gw_current_OS;

       sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                           &active_id, NULL),
                     targetid = me->solid_info.located_obj.objid,
                     targetos = me->solid_info.located_obj.osnum);
       ERROR(sts, EMS_S_Success, "ECbool_exec get classid", wrapup);   

       display_mode = GRbehe;
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->solid_info.module_info.md_env.matrix_type,
                           me->solid_info.module_info.md_env.matrix,
                           &display_mode, 
                           &me->solid_info.module_info.md_id),
                     targetid = active_id.objid,
                     targetos = active_id.osnum);
      ERROR(sts, msg, "ECundo erase ", wrapup);
    }
    else
    {
      sts = dp$erase_hilite(msg = &msg);
      ERROR(sts, msg, "ECbool_exec erase hi", wrapup);
    }

    count = 0;
    old_solid = NULL;
  
    {
      IGRushort mult_union;
      IGRlong  rc;

      option = EMS_UNDO_DELETE; 

      option |= gothist ? EMS_GET_ACTIVE_STATES : EMS_DO_DISPLAY;

      /*Do it*/

     /* AMD -- Added code here to handle multiple undo */

       sts = om$send(msg = message EMSdpr.EMget_dpr_props(
                           &rc, &mult_union ),
                     targetid = me->solid_info.located_obj.objid,
                     targetos = me->solid_info.located_obj.osnum);

       if( mult_union & EMS_MULT_BOOL )
       {
       sts = om$send(msg = message EMSdpr.EMmult_undo(&msg,
                           &option, 
                           &me->solid_info.module_info,
                           &old_solid, &count, &dummy, &display_ids,
                           &display_count, &involk_count),
                     targetid = me->solid_info.located_obj.objid,
                     targetos = me->solid_info.located_obj.osnum);

       }
       else
       {
       sts = om$send(msg = message EMSdpr.EMundo(&msg,
                           &option, 
                           &me->solid_info.module_info,
                           &old_solid, &count, &dummy, &display_ids,
                           &display_count, &involk_count),
                     targetid = me->solid_info.located_obj.objid,
                     targetos = me->solid_info.located_obj.osnum);
       }
    }

    ex$message(msgnumb = EMS_S_ClearStatusField);
    if (COERROR(sts) || COERROR(msg))
    {
      ex$message(msgnumb = EMS_S_IntErrOcc);

      if (gothist)
      {
        /*Redraw the active solid*/  

        display_mode = GRbd;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->solid_info.module_info.md_env.matrix_type,
                            me->solid_info.module_info.md_env.matrix,
                            &display_mode, 
                            &me->solid_info.module_info.md_id),
                      targetid = active_id.objid,
                      targetos = active_id.osnum);
        ERROR(sts, msg, "ECundo redraw sol", wrapup);
      }

      if (gothist && old_solid) om$dealloc(ptr = old_solid);
      break;
    }
 
    if (gothist)
    {
      /*Draw the now active solid(s)*/
      display_mode = GRbd;
      for (i = 0; i < count; i++)
      {
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                            &me->solid_info.module_info.md_env.matrix_type, 
                            me->solid_info.module_info.md_env.matrix, 
                            &display_mode, 
                            &me->solid_info.module_info.md_id),
                      targetid = old_solid[i].objid,
                      targetos = old_solid[i].osnum);
        ERROR(sts, msg, "ECundo draw new sols", wrapup);
      }
    }

    if (gothist && old_solid) om$dealloc(ptr = old_solid);
    break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECundo action table garbage", wrapup);
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case start:
   {
     display_flag = 6;
     locate_mask = GRm_DATA | GRm_BACK_UP;
     accept_mask = GRm_DATA;   
     attr.properties = 0x11 | LC_RW; 

     strcpy(attr.classes, "EMSsurface");

     aflag = pwIsActivationOn();
     if (aflag)
     {
     attr.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP | LC_REF_OBJECTS |
                         (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);
     }
     else
     {
     attr.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP | LC_NO_REF_OBJECTS |
                         (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);
     }


     rtree_classes.w_count = 1;
     elig_classes.w_count = 1;
     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

     rclass = OPP_EMSsubbs_class_id;
     eliclass = OPP_EMSdpr_class_id;

     ex$message(msgnumb = EMS_P_IdeStaTreeNode, buff = loc_prompt,
                buffer_size = 54); 
     ex$message(msgnumb = EMS_P_AccNodeRej, buff = acc_prompt,
                buffer_size = 54); 
     ex$message(msgnumb = EMS_P_NodeNotFound, buff = reloc_prompt,
                buffer_size = 54); 

     rtree_classes.p_classes = &rclass;
     elig_classes.p_classes = &eliclass;

     aflag = pwIsActivationOn();
     if(aflag)
     {
       GRspacenum osn;
       osn = pwGetActiveOs();
       lc$locate(rc = &msg, 
                 event1 = &me->locate_event, 
                 event2 = &me->locate_event,
                 mask1 = locate_mask, 
                 mask2 = accept_mask, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_prompt = acc_prompt,
                 relocate_prompt = reloc_prompt, 
                 attributes = &attr, 
                 stack = &me->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes,
                 act_handler = RFlocate_element_for_undo_handler,
                 act_args = &osn);
     }
     else
     {
       lc$locate(rc = &msg, 
                 event1 = &me->locate_event, 
                 event2 = &me->locate_event,
                 mask1 = locate_mask, 
                 mask2 = accept_mask, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_prompt = acc_prompt,
                 relocate_prompt = reloc_prompt, 
                 attributes = &attr, 
                 stack = &me->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
     }
     token = GRloc_token(&msg, Tokens, &me->locate_event);

     break;
   }


   case got_sol:
   {
    token = 1; /**DATA INPUT**/
    break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECundo state table bad", wrapup);
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return sts;

 wrapup:
  *response = TERMINATE;
  return (OM_E_ABORT);

}
IGRlong RFlocate_element_for_undo_handler(osn, new_entry, locate_args, action)
GRspacenum *osn;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;
{
  IGRboolean  call_action_handler = FALSE;
  IGRlong sts = OM_S_SUCCESS;

  switch(*action)
  {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         if (new_entry->located_obj.osnum != *osn)
         {
          call_action_handler = FALSE;
         }
         else
         {
            call_action_handler = TRUE;
         }
      }
      break;

      default:

      break;
  }

  /* Call the default action handler */

  if(call_action_handler)
      sts = LCptlocact(NULL, new_entry, locate_args, action);
  else
      sts = OM_S_SUCCESS;

  return(sts);
}
end implementation ECdprundo;
