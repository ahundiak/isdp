class implementation ECfixsup;

/*
History
    DLB 06/31/91    Creation date.
    Vadiraj 25/05/92 Modified for message subsystem compliance.    
    scw 08/14/94    clarified sleep method
*/

#define FIXSUP 0

#include <stdio.h>
#include "msmacros.h"
#include "ECdlb.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "griomacros.h"
#include "emsdef.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"


from GRgraphics  import GRdisplay;
from EMSdpr      import EMget_suppress_ids;
from EMSsurface  import EMgetstatedesc;


extern OMuword OPP_EMSsubbs_class_id,
               OPP_EMSdpr_class_id;

method wakeup(int pos)
{
  return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRlong EMmsg;

  ex$message(msgnumb=EM_M_ClearMessageField);
  ex$message(msgnumb=EMS_S_ClearStatusField);
  ex$message(msgnumb=EMS_P_ClearPromptField);
  dp$erase_hilite(msg = &EMmsg);
  return(OM_S_SUCCESS);
}

#define GET_MODEL       0
#define SHOW_SUPS       1
#define DELETE_SUP      2
#define REDEFINE_SUP    3

method execute(int *response; char *response_data; int pos)
{
 IGRlong               EMmsg=EMS_S_Success;
 IGRint                OM_stat=OM_S_SUCCESS,
                       size=sizeof(struct GRevent), display_flag, num_sids;
 enum     GRdpmode     display_mode;
 OM_S_CHANSELECT       to_father;
 IGRchar               loc[60], acc[60], reloc[60];

 ex$message(msgnumb=EM_M_FixupSuppNodes);

 num_sids = om$dimension_of(varray = me->sids);
 EMmake_chanselect(NDfather_father, &to_father);

 do
 {
   switch(me->state)
   {
     case GET_MODEL:
     {
       struct GRlc_locate attr;
       OM_S_CLASSLIST     rtree_classes, elig_classes;
       OMuword            rclass, eliclass;

  
       display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
       strcpy(attr.classes, "EMSsurface");
       attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
       attr.owner_action = LC_RIGID_OWNER |
                           LC_FLEX_COMP | 
                           LC_ASSOCIATIVE |
                           LC_EXTERN_CONSTRAINED;
  
       rtree_classes.w_count = elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
  
       rclass = OPP_EMSsubbs_class_id;
       eliclass = OPP_EMSdpr_class_id;
  
       /*loc = "Identify model";*/
       ex$message(msgnumb = EMS_P_IdModel, buff = loc);
       /*acc = "Accept model / reject";*/
       ex$message(msgnumb = EMS_P_AcptModRej, buff = acc);
       /*reloc = "Model not found";*/
       ex$message(msgnumb = EMS_S_ModNtFnd, buff = reloc);
  
       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;
  
       lc$locate(rc = &EMmsg, 
                 event1 = &me->event, 
                 event2 = &me->event,
                 mask1 = GRm_DATA | GRm_BACK_UP, 
                 mask2 = GRm_DATA,
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc, 
                 acc_prompt = acc,
                 relocate_prompt = reloc, 
                 attributes = &attr, 
                 stack = &me->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
  
       switch(me->event.response)
       {
         case EX_DATA:
         {
           GRobjid *sids=NULL;

           OM_BLOCK_MOVE(&me->event.located_object[0].module_info,
                         &me->ModuleInfo,
                         sizeof(struct GRmd_env));

           me->model_GRid = me->event.located_object[0].located_obj;

           num_sids = 0;
           OM_stat = om$send(msg = message EMSdpr.EMget_suppress_ids(&EMmsg, 
                                   &num_sids, &sids, NULL),
                             targetid = me->model_GRid.objid,
                             targetos = me->model_GRid.osnum);
           if (!(1 & OM_stat & EMmsg)) goto wrapup;

           if (num_sids)
           {
             OM_stat = om$vla_set_dimension(varray = me->sids,
                                            size = num_sids);
             if (!(1 & OM_stat)) goto wrapup;

             OM_BLOCK_MOVE(sids,
                           me->sids,
                           num_sids * sizeof(GRobjid));

             om$dealloc(ptr = sids);

             me->state = SHOW_SUPS;
           }                                       
           else
           {
             ex$message(msgnumb=EMS_S_LocatedModelContnsNoSupresdNodes) 
             me->state = GET_MODEL;
           }        
           break;
         }

         case EX_BACK_UP:
         {
           me->state = GET_MODEL;
           break;
         }

         default:
         {
           goto wrapup;
         }
       }
       dp$erase_hilite(msg = &EMmsg);
       break;
     }

     case SHOW_SUPS:
     {
       IGRchar         desc[54];


       if (me->sids[me->current_sid] == NULL_OBJID)
       {
         me->current_sid++;
         break;
       }

       if (me->current_sid >= num_sids)
       {
         me->current_sid = 0;
         me->state = GET_MODEL;
         break;
       }
       else if (num_sids == 1)
      ex$message(msgnumb=EMS_S_ThisIsTheOnlySuppressedNod, field=KEYIN_FIELD) 
       else if (me->current_sid == (num_sids-1))
    ex$message(msgnumb=EMS_S_ThisIsTheLastSuppressedNode, field=KEYIN_FIELD)

       (void) EFsetsfstate(&EMmsg, me->sids[me->current_sid],
                           me->model_GRid.osnum, EMS_O_ON);

       display_mode = GRhd;
       OM_stat = om$send(msg = message GRgraphics.GRdisplay(&EMmsg,
                               &me->ModuleInfo.md_env.matrix_type,
                               me->ModuleInfo.md_env.matrix,
                               &display_mode, 
                               &me->ModuleInfo.md_id),
                         targetid = me->sids[me->current_sid],
                         targetos = me->model_GRid.osnum);
       if (!(1 & OM_stat & EMmsg)) goto wrapup;
                 
       (void) EFsetsfstate(&EMmsg, me->sids[me->current_sid],
                           me->model_GRid.osnum, EMS_O_OFF);

       OM_stat = om$send(msg = message EMSsurface.EMgetstatedesc(&EMmsg, 
                               desc),
                         senderid = me->sids[me->current_sid],
                         targetos = me->model_GRid.osnum,
                         p_chanselect = &to_father);
       if (!(1 & OM_stat & EMmsg)) goto wrapup;

       ex$message(field = ERROR_FIELD, in_buff = desc);

       /*loc = "D)elete, R)edefine, K)eep suppressed (move on to keep)";*/
       ex$message(msgnumb = EMS_P_DltRedefKpSup, buff = loc);

       OM_stat = co$getevent(msg = &EMmsg,
                             event_mask = GRm_STRING | 
                                          GRm_BACK_UP | 
                                          GRm_RJT_MOVEON,
                             prompt = loc,
                             response = response,
                             response_data = response_data,
                             event = &me->event);

       ex$message(msgnumb=EMS_S_ClearStatusField, field=KEYIN_FIELD);

       switch(me->event.response)
       {
         case EX_STRING:
         {
           if (toupper(me->event.event.keyin[0]) == 'D')
           {
             me->state = DELETE_SUP;
           }
           else if (toupper(me->event.event.keyin[0]) == 'K')
           {
             me->current_sid++;
           }
           else if (toupper(me->event.event.keyin[0]) == 'R')
           {
             me->state = REDEFINE_SUP;
           }
           else goto wrapup;

           break;
         }

         case EX_RJT_MOVEON:
         {
           me->current_sid++;
           break;
         }

         case EX_BACK_UP:
         {
           do
           {
             if (me->current_sid == 0)
             {
               me->state = GET_MODEL;
               break;
             }
             else
             {
               me->current_sid--;
             }
           }
           while (me->sids[me->current_sid] == NULL_OBJID);

           break;
         }

         default:
         {
           goto wrapup;
         }
       }

       dp$erase_hilite(msg = &EMmsg);
       break;
     }

     case DELETE_SUP:
     {
/**********
       OM_stat = om$send(msg = message EMSsuppress.EMdelete_suppressed(&EMmsg, 
                               &me->ModuleInfo, NULL),
                         targetid = me->sids[me->current_sid],
                         targetos = me->model_GRid.osnum);
       if (!(1 & OM_stat & EMmsg)) goto wrapup;
**************/

       me->sids[me->current_sid] = NULL_OBJID;                         
       me->state = SHOW_SUPS;
       break;
     }

     case REDEFINE_SUP:
     {
       ex$message(msgnumb=EMS_F_0001);
       me->state = SHOW_SUPS;
       break;
     }

     default:
     {
       EMmsg = EMS_E_InvalidCase;
       goto wrapup;
     }
   } /*end state switch*/
 } while(TRUE);

wrapup:
  if (!(1 & OM_stat & EMmsg)) *response = TERMINATE;
  dp$erase_hilite(msg = &EMmsg);
  return(OM_stat);
}
end implementation ECfixsup;
