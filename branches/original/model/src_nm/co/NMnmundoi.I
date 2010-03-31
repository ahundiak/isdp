class implementation NMnmundo;

#include <stdio.h>
#include "ECdlb.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "EMSprop.h"
#include "msmacros.h"   /* ex$message */

#include "ECcmd.h"
#include "ECmsg.h"
#include "NMcmd.h"
#include "NMmsg.h"

from GRgraphics import GRdisplay;
from GRowner import GRdrop;

extern OMuword OPP_NMnonmani_class_id,
               OPP_EMSsubbs_class_id;

void localMsg();

method wakeup(int pos)
{
 return OM_S_SUCCESS;
}

method sleep(int pos)
{
 localMsg (EM_M_ClearMessageField);
 localMsg (EMS_P_ClearPromptField);
 localMsg (NM_I_ClearStatusField);
 return OM_S_SUCCESS;
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS, size=sizeof(struct GRevent),display_flag;
 IGRint                locate_mask, accept_mask, token;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass;
 IGRlong	       msg;

#define NUM_TOKENS 3
#define NUM_STATES 1
 
    static int Tokens[NUM_TOKENS] =
    {
     EX_BACK_UP, DATA, GR_UNKNOWN_TYPE
    };

    enum actions
    {
     NIL, ERR, initialize, undo
    };

    enum states
    {
     start
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP     DATA      UNK
    old state: */                                   
    /* start    */ {start,         start,    start   }
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP  DATA        UNK
    old state: */                                     
    /* start    */ { NIL,       undo,       NIL }
    };

 localMsg(NMC_M_UndoNmState);

 do
 {
  switch (ME.COconst->action)
  {
   case NIL:
    break;

   case ERR:
    break;

   case initialize:
    break;

   case undo:
   {
    localMsg (EMS_I_Processing);
    localMsg (EMS_P_ClearPromptField);

    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "NMnmundo_exec erase hi", wrapup);
  
    sts = om$send(msg = message GRowner.GRdrop(&msg,
                        &me->nm_info.module_info), 
                     targetid = me->nm_info.located_obj.objid,
                     targetos = me->nm_info.located_obj.osnum);
 
    localMsg (NM_I_ClearStatusField);

    if (COERROR(sts) || COERROR(msg))
     localMsg(EMS_E_OperationFailed);
    break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "NMnmundo action table garbage", wrapup);
   }

  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case start:
   {
     display_flag = NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT;
     locate_mask = GRm_DATA | GRm_BACK_UP;
     accept_mask = GRm_DATA;   

     strcpy(attr.classes, "NMnonmani");

     attr.properties = 0x11 | LC_RW;

     attr.owner_action = LC_FLEX_OWNER | 
                         (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

     rtree_classes.w_count = 1;
     elig_classes.w_count = 1;
     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

     rclass = OPP_EMSsubbs_class_id;
     eliclass = OPP_NMnonmani_class_id;

     rtree_classes.p_classes = &rclass;
     elig_classes.p_classes = &eliclass;

     lc$locate(rc = &msg, 
               event1 = &me->locate_event, 
               event2 = &me->locate_event,
               mask1 = locate_mask, 
               mask2 = accept_mask, 
               eventsize= &size, 
               display_flag = display_flag,
               response = response, 
               response_data = response_data, 
	       locate_key = NM_P_IdNmState, 
	       acc_key = EMS_P_00038,  /* Accept/Reject */
	       relocate_key = NM_I_NmStateNotFound, 	
               attributes = &attr, 
               stack = &me->locate_stack, 
               rtree_classes = &rtree_classes, 
               eligible_classes = &elig_classes);

     token = GRloc_token(&msg, Tokens, &me->locate_event);
     if(token == 1)
       OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->nm_info, sizeof(struct GRlc_info));
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


static void localMsg (msgnumb)
IGRlong msgnumb;
{
    ex$message (msgnumb = msgnumb);

    return;
}

end implementation NMnmundo;
