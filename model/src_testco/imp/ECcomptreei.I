/* ###################   APOGEE COMPILED   ################## */
class implementation ECcomptree;

#include "EMS.h"
/*
Description
        This command will locate a solid on the state tree and 
        remove the previous states on the tree making the solid a
        primitive. After this is done an undo is not possible.
        All of the tree down to the surfaces is deleted.
        When done the solid looks just like a primitive solid
        except that the class remains the same.
            
Return values
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

Bugs
        Note the comments in the code where external routines
        do not behave as is expected.

History
        scw     08/14/94    Clarified sleep method
        Jack    9-Mar-93    Added ClearStatusField call since Processing...
                            message was remaining after the command returned.
        Rustagi 05/21/92    Modified for message sub-system compliance.
        DLB     10/23/88    Added EMreduce_range send.  Note that this
                            code was removed from EMSdpr.EMmake_primitive1.
        DLB     01/06/87    Creation date.
*/


#include "stdio.h"
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSerrordef.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "emsdef.h"
#include "EC_I.h"
#include "EC_M.h"

#define DEBUG 0 /*Set this to 1 if want error messages printed.*/

from GRgraphics import GRdisplay;
from EMSdpr     import EMmake_primitive1;
from EMSsubbs   import EMreduce_range;


method wakeup(int pos)
{
#if DEBUG
 fprintf(stderr,"Command in DEBUG");   
#endif 
 return OM_S_SUCCESS;
}


method super_cmd.sleep(int pos)
{
 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);
 return OM_S_SUCCESS;
}

extern OMuword OPP_EMSsubbs_class_id, OPP_EMSdpr_class_id;

method execute(int *response; char *response_data; int pos)
{
 IGRint              sts=OM_S_SUCCESS, size=sizeof(struct GRevent),display_flag;
 IGRlong             msg;
 IGRint              locate_mask, accept_mask, token;
 enum   GRdpmode     Display_Mode;
 struct GRid         new_id;
 struct GRlc_locate  attr;
 OM_S_CLASSLIST      rtree_classes, elig_classes;
 OMuword             rclass, eliclass;
 IGRchar             loc_prompt[40], acc_prompt[40], reloc_prompt[40];
 

#   define NUM_TOKENS 3
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, initialize, store_sol, mkprim
    };

#   define NUM_STATES 2
    enum states
    {
        start, got_sol
    };

    /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP     DATA      UNK
    old state: */                                   
    /* start    */ {start,         got_sol,  start   },
    /* got_sol  */ {got_sol,       start,    got_sol }
    };

    /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      EX_BACK_UP  DATA        UNK
    old state: */                                     
    /* start    */ {NIL,        store_sol,  NIL }, 
    /* got_sol  */ {NIL,        mkprim,     NIL }
    };

 ex$message(msgnumb = EM_M_CompTree);

 do
 {
  switch (ME.COconst->action)
  {
   
   case NIL:
   case ERR:
   case initialize: break;

   case store_sol:
   {
    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->solid_info, sizeof(struct GRlc_info));
    break;
   }   

   case mkprim:
   {
     ex$message(msgnumb = EMS_I_00003);
     ex$message(msgnumb = EMS_P_ClearPromptField);

     Display_Mode = GRbehe;
     sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                         &me->solid_info.module_info.md_env.matrix_type,
                         me->solid_info.module_info.md_env.matrix,
                         &Display_Mode, &me->solid_info.module_info.md_id),
                   targetid = me->solid_info.located_obj.objid,
                   targetos = me->solid_info.located_obj.osnum);
     ERROR(sts, msg, "ECcomptree erase display", wrapup);

     sts = om$send(msg = message EMSdpr.EMmake_primitive1(&msg,
                         &me->solid_info.module_info,
                         &new_id),
                   targetid = me->solid_info.located_obj.objid,
                   targetos = me->solid_info.located_obj.osnum);
     
     ex$message(msgnumb = EMS_P_ClearPromptField);

     if (COERROR(sts) || COERROR(msg))
     {
       new_id = me->solid_info.located_obj;

       ex$message(msgnumb = EMS_S_IntErrOcc);
     }     
     else
     {
       /*Reduce the range of the surfaces of the compressed tree.*/
       if (EFisAncestryValid(&msg, new_id.objid, new_id.osnum,
                             OPP_EMSsubbs_class_id, FALSE))
       {
         /*The remains of compressed tree is a single surface.*/
         sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
                             &me->solid_info.module_info, &new_id.objid, 0),
                       targetid = new_id.objid,
                       targetos = new_id.osnum);
         ERROR(sts, msg, "ECcomptree red range", wrapup);
       }
       else
       {
         /*The remains of compressed tree is a composite surface or solid.*/
         OM_S_CHANSELECT to_comps;
         GRobjid return_id;

         sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
    
         sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
                             &me->solid_info.module_info, &return_id, 0),
                       senderid = new_id.objid,
                       targetos = new_id.osnum,  /*Im sending across OS.*/
                       p_chanselect = &to_comps);
         ERROR(sts, msg, "ECcomptree red range", wrapup);
       }
     }

     Display_Mode = GRbd;
     sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                         &me->solid_info.module_info.md_env.matrix_type,
                         me->solid_info.module_info.md_env.matrix,
                         &Display_Mode, &me->solid_info.module_info.md_id),
                   targetid = new_id.objid,
                   targetos = new_id.osnum);
     ERROR(sts, msg, "ECcomptree display new", wrapup);

     ex$message(msgnumb = EMS_S_ClearStatusField);

     break;
   }

   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECcomptree exec action garb", wrapup);
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case start:
   {
    display_flag = 6;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   
    ex$message(msgnumb = EMS_P_IdStTreeElm , buff = loc_prompt);
    ex$message(msgnumb = EMS_P_AccStRej, buff = acc_prompt);
    ex$message(msgnumb = EMS_S_TreElmNtFnd, buff = reloc_prompt);
    strcpy(attr.classes, "EMSsurface");
    attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
    attr.owner_action = LC_RIGID_OWNER | 
                        (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSdpr_class_id;

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
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &attr, 
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }

   case got_sol:
   {
    /**DUMMY STATE**/
    token = 1; /**DATA INPUT**/
    break;
   }

   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECcomptree exec state garb", wrapup);
   }
  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return (sts);

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);
}  /*method execute*/

end implementation ECcomptree;
