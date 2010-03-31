/* ###################   APOGEE COMPILED   ################## */
class implementation ECtestpt;
/*
   HISTORY:
 Vadiraj 20/05/92   Modified for message subsystem compliance.
 scw     08/14/94   clarified sleep method
*/

#include "EMS.h"
#include <stdio.h>
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "lcmacros.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EC_I.h"
#include "EC_S.h"
#include "EC_M.h"

extern OMuword OPP_EMSsubbs_class_id, OPP_EMScomposite_class_id,
               OPP_EMScompsurf_class_id;

from GRgraphics import GRdisplay;
from EMSsolid import EMpoint_locate;

method super_cmd.sleep(int pos)
{
ex$message(msgnumb=EM_M_ClearMessageField);
ex$message(msgnumb=EMS_S_ClearStatusField);
ex$message(msgnumb=EMS_P_ClearPromptField);
 return (OM_S_SUCCESS);
}


method execute(int *response; char *response_data; int pos)
{
 IGRlong               msg;
 IGRint                sts=OM_S_SUCCESS, size=sizeof(struct GRevent),display_flag;
 IGRint                locate_mask, accept_mask, token = 0;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass;
 IGRchar               loc_prompt[40], acc_prompt[40], reloc_prompt[40];

 
/* TABLE STUFF */

#   define NUM_TOKENS 3
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, initialize, store_sol, drop
    };

#   define NUM_STATES 2
    enum states
    {
        start, got_sol
    };

    /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    EX_BACK_UP     DATA      UNK
    old state: */                                   
    /* start    */ {start,    got_sol,  start   },
    /* got_sol  */ {got_sol,  start,    got_sol }
    };

    /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    EX_BACK_UP  DATA        UNK
    old state: */                                     
    /* start    */ {NIL,   store_sol,  NIL }, 
    /* got_sol  */ {NIL,   drop,       NIL }
    };

    ex$message(msgnumb=EM_M_TstPtLocnOnSolid);

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


   case drop:
   {
    ex$message(msgname=ECsS_Processing);
    ex$message(msgname=ECsP_NULL);   
    Display_Mode = GRbdhe;
    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                        &me->solid_info.module_info.md_env.matrix_type,
                        me->solid_info.module_info.md_env.matrix,
                        &Display_Mode, 
                        &me->solid_info.module_info.md_id),
                  targetid = me->solid_info.located_obj.objid,
                  targetos = me->solid_info.located_obj.osnum);
    ERROR(sts, msg, "test point locate", wrapup)

    {
       struct GRid surf_id;         /*DECL*/
       IGRulong location;
       IGRushort options = 0;
       IGRpoint inpoint;
   
       surf_id.objid = me->solid_info.located_obj.objid;
       surf_id.osnum = me->solid_info.located_obj.osnum; 

       fflush(stdin);
       printf ("\nEnter the xyz coordinates of the point \n");
       scanf ("%lf %lf %lf", &inpoint[0], &inpoint[1], &inpoint[2]);

       fflush(stdin);
       printf ("\n The coordinates are %lf %lf %lf \n",inpoint[0], inpoint[1],
                   inpoint[2]); 

       sts = om$send(msg = message EMSsolid.EMpoint_locate(&msg,
                          &me->solid_info.module_info, options,
                           inpoint, NULL,&location),
                    targetid = surf_id.objid,
                    targetos = surf_id.osnum);
       if (COERROR(sts) || COERROR(msg))
            ex$message(msgnumb=EMS_I_CantDetLocn)
       else       
        {
         if (location == EMS_S_ONSOLID)
            ex$message(msgnumb=EMS_S_PtOnSolid)
         else if (location == EMS_S_OUTSOLID)
            ex$message(msgnumb=EMS_S_PtOutSolid)
         else if (location == EMS_S_INSOLID)
            ex$message(msgnumb=EMS_S_PtInSolid)  
         else
            ex$message(msgnumb=EMS_I_CantDetLocn);
        }
    }
    break;
   }


   default:
   {
     ERROR(sts, msg, "test point locate  action garbage", wrapup)
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {

   case start:
   {

    display_flag = 6;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   
    /*strcpy(loc_prompt, ECsP_Identify_solid);*/
      ex$message(buff = loc_prompt, msgnumb = EMS_P_00032);
    /*strcpy(acc_prompt, ECsP_Accept_reject_sol);*/
      ex$message(buff = acc_prompt, msgnumb = EMS_P_Accept_reject_sol); 
    /*strcpy(reloc_prompt, ECsP_Solid_not_found);*/
      ex$message(buff = reloc_prompt, msgnumb = EMS_I_00012);
    strcpy(attr.classes, "EMSsurface");
    attr.properties = 0x11 | LC_RW;
    attr.owner_action = 0x2;

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMScomposite_class_id;

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
     ERROR(sts, msg, "testpoint locate state garbage", wrapup)
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return (sts);

 wrapup:
   *response = TERMINATE;
   return(OM_E_ABORT);
}
end implementation ECtestpt;
