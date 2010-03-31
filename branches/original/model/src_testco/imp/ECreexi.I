/* ###################   APOGEE COMPILED   ################## */
class implementation ECreex;

/*
 History
 
 Rustagi 05/26/92  Modefied for Message sub-system Compliance
 scw     08/14/94  clarified sleep method

*/

#define DEBUG 0  /*SET TO '1' WHEN WANTING ERROR STRINGS PRINTED FOR DEBUG*/


#include "EMS.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "EMSerrordef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "emsdef.h"
#include "EMSdpb.h"
#include "EMSmsgdef.h"
#include "EC_I.h"
#include "EC_M.h"
# include "griomacros.h" /* co$getevent */
#include "emsdef.h"

from GRgraphics import GRlnproject, GRdisplay, GRdelete;
from EMSsurface import EMgetactiveid;
from EMSdpr 	import EMprep_reex, EMredo;

extern OMuword  OPP_EMSsubbs_class_id;

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhd;
 IGRint        OM_stat = OM_S_SUCCESS;
 IGRlong       EMmsg = EMS_S_Success;
 IGRint        EMdpb_getinfo();
 struct GRid   top_id, active_id, *active_state;
 
 if (me->top_lm_active)
 {
   /*Get the active solid id from the state tree*/
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid (
                            &EMmsg, &active_id, &top_id),
                     targetid = me->surf_info.located_obj.objid,
                     targetos = me->surf_info.located_obj.osnum);
   ERROR(OM_stat, EMmsg, "wake, getactiveid error", wrapup);

   if ((me->top_lm_GRid.objid != top_id.objid) ||
       (me->active_state_GRid.objid != active_id.objid))
   {
     ex$message(msgnumb = EMS_S_ModInfCrpt);  
     return(OM_E_ABORT);
   }

   me->num_states = 0;
   active_state = NULL;
   OM_stat = EFundo_to_lm(&EMmsg, &me->surf_info.located_obj, 
                          &me->top_lm_GRid, &me->active_state_GRid, 
                          &me->surf_info.module_info, &me->num_states,
                          &active_state);
   ERROR(OM_stat, EMmsg, "wake, EFundo_to_lm error", wrapup);
     
   if (active_state) om$dealloc(ptr = active_state);
   ex$message(msgnumb = EMS_S_ClearStatusField);

 } /*End if active and top lm different*/

 if (me->srf_hi)
 { 
   Display_Mode = GRhd;
   OM_stat = om$send(msg = message GRgraphics.GRdisplay(&EMmsg, 
                           &me->surf_info.module_info.md_env.matrix_type, 
                           me->surf_info.module_info.md_env.matrix, 
                           &Display_Mode, 
                           &me->surf_info.module_info.md_id),
                    targetid = me->surf_info.located_obj.objid,
                    targetos = me->surf_info.located_obj.osnum);
   ERROR(OM_stat, EMmsg, "wake, GRdisplay", wrapup);
 }

 /*
  * Get current dpb 
  */

 OM_stat = EMdpb_getinfo (&EMmsg, &me->dpb_info);
 ERROR (OM_stat, EMmsg, "wake, EMdpb_getinfo", wrapup);

 wrapup:
   return(OM_stat);
}

method super_cmd.sleep(int pos)
{
 IGRint  OM_stat = OM_S_SUCCESS;
 IGRlong EMmsg = EMS_S_Success;
 
 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);

 if ((me->srf_hi && !me->top_lm_active))
 { 
   OM_stat = dp$erase_hilite(msg = &EMmsg);
 }

 if (me->top_lm_active)
 {
   OM_stat = EFredo_to_top(&EMmsg, &me->active_state_GRid,
                           &me->surf_info.module_info, &me->num_states,
                           me->state_list);
   ERROR(OM_stat, EMmsg, "sleep, EFredo_to_top", wrapup);
 }
 
 wrapup:
  return (OM_stat);
}

 
method execute(int *response; char *response_data; int pos)
{
  IGRlong  		mthd_stat = EMS_S_Success;
  IGRint  		OM_stat = OM_S_SUCCESS,
          		size=sizeof(struct GRevent), display_flag, locate_mask,
          		accept_mask, mask; 
  struct GRlc_locate    attr;
  OM_S_CLASSLIST  	rtree_classes, elig_classes;
  OMuword    		rclass, eliclass;
  IGRushort   		redo_option;
  IGRchar    		loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint		display_count = 0,  involk_count = 0;
  GRobjid		*display_ids = NULL;

 ex$message(msgnumb = EM_M_ReexTree);
 do
 {
  switch (ME.super_cmd->state)
   {
    case 0:

    case 1:
    me->srf_hi = FALSE;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   
    display_flag = 7; /**don't project accept point on surface**/
    ex$message(msgnumb = EMS_P_00031, buff = loc_prompt);
    ex$message(msgnumb = EMS_P_AccRjectSf, buff = acc_prompt);
    ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);
    strcpy(attr.classes, "EMSsurface");
    attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
    attr.owner_action = LC_RIGID_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS;

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsubbs_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    lc$locate(rc = &mthd_stat, 
                       event1 = &me->locate_event, 
                       event2 = &me->locate_event,
                       mask1 = locate_mask, mask2 = accept_mask, 
                       eventsize= &size, display_flag = display_flag,
                       response = response, response_data = response_data, 
                       locate_prompt = loc_prompt, 
                       acc_prompt = acc_prompt,
                       relocate_prompt = reloc_prompt, 
                       attributes = &attr, 
                       stack = &me->locate_stack, 
                       rtree_classes = &rtree_classes, 
                       eligible_classes = &elig_classes);
    if (!mthd_stat)
    {
     if (me->locate_event.response == EX_BACK_UP)
      ME.super_cmd->state = 0;
     else
      return(OM_S_SUCCESS);
    }
   else
    {
     me->srf_hi = TRUE;
 
     OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->surf_info, sizeof(struct GRlc_info));
   
     OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                    &me->local_info, sizeof(struct GRlc_info));

    /*Get the active solid id from the state tree.*/
    OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(&mthd_stat,
                            &me->active_state_GRid, &me->top_lm_GRid),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, mthd_stat, "exec, getacid", wrapup);

    OM_stat = om$send(msg = message ECreex.ECvalidate(&mthd_stat),
                      targetid = my_id);
    ERROR(OM_stat, mthd_stat, "EClmod, send ECvalidate", wrapup);
    if( (1&mthd_stat) && (mthd_stat != EMS_I_Stop))
     ME.super_cmd->state = 2;
   }
   break;
   
   case 2:
     {
      OM_S_OBJECT_LINKAGE	junk;
      OMuint			count;
      OM_S_CHANSELECT	        to_own;

       OM_stat = OM_S_SUCCESS;
       mask = GRm_DATA | GRm_BACK_UP;
       co$getevent (
        msg = &mthd_stat,
        event_mask = mask,
        prompt = "Data to reexecute/ Backup to cancel",
        response = response,
        response_data = response_data,
        event = &me->locate_event);
      printf("\nResponse = %d\n", me->locate_event.response);
      ERROR(OM_stat, mthd_stat, "exec, getevent", wrapup);

      if(me->locate_event.response == EX_DATA)
       {
	EMmake_chanselect(GRconnector_to_owners, &to_own);
	OM_stat = om$get_channel_objects(objid = me->top_lm_GRid.objid, 
			osnum = me->top_lm_GRid.osnum, p_chanselect = &to_own, 
			list = &junk,  size = 1, count = &count);
        ERROR(OM_stat, mthd_stat, "exec, getevent", wrapup);

         OM_stat = om$send(msg = message EMSdpr.EMprep_reex
		(&mthd_stat, &me->surf_info.module_info),
              targetid=junk.S_objid, targetos=me->top_lm_GRid.osnum);
         ERROR(OM_stat, mthd_stat, "exec, EMprep_reex", wrapup);
         display_ids = NULL;
         display_count = 0;
         involk_count = 0;
	 redo_option = EMS_DO_DISPLAY;
         OM_stat = om$send(msg = message EMSdpr.EMredo(&mthd_stat, 
		&redo_option, &me->surf_info.module_info, &display_ids, 
		&display_count, &involk_count),
                      targetid = me->active_state_GRid.objid, 
                      targetos = me->active_state_GRid.osnum);
         ERROR(OM_stat, mthd_stat, "exec, EMredo", wrapup);
       }  
      else
       {
         OM_stat = EFredo_to_top(&mthd_stat, &me->active_state_GRid,
                              &me->surf_info.module_info, &me->num_states,
                              me->state_list);
         ERROR(OM_stat, mthd_stat, "exec, EFredo_to_top", wrapup);
       }
      me->top_lm_active = FALSE;
      ME.super_cmd->state = 0;
     }
   break;

  }

 } while(TRUE);

 wrapup:
   *response = TERMINATE;
   return OM_E_ABORT;

}  /*method execute*/


method ECvalidate(IGRlong *EMmsg)
{
  IGRlong     OM_stat;
  struct GRid *active_state;


  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (me->active_state_GRid.objid == me->top_lm_GRid.objid)
  {
    ex$message(msgnumb = EMS_S_CantRexute);
    OM_stat = dp$erase_hilite(msg = EMmsg);
    me->state = 0;     /*HARD CODE start */
    *EMmsg = EMS_I_Stop;
    goto wrapup;  /*Not modif and no tree so cant even undo.*/
  }

  me->num_states = 0;
  active_state = NULL;
  OM_stat = EFundo_to_lm(EMmsg, &me->surf_info.located_obj,
                         &me->top_lm_GRid, &me->active_state_GRid,
                         &me->surf_info.module_info, &me->num_states,
                         &active_state);
  ERROR(OM_stat, *EMmsg, "ECval, EFundo_to_lm", wrapup);

  me->top_lm_active = TRUE;
  
  if (me->num_states > om$dimension_of(varray =me->state_list)) 
  {
    OM_stat = om$vla_set_dimension(varray = me->state_list,
                                   size = me->num_states);
    ERROR(OM_stat, *EMmsg, "ECval, set vla", wrapup);
  }

  OM_BLOCK_MOVE(active_state, me->state_list,
                me->num_states * sizeof(struct GRid));

  if (active_state) om$dealloc(ptr = active_state);

  {
    enum GRdpmode Display_Mode = GRhd;
    OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->surf_info.module_info.md_id),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, *EMmsg, "ECval, GRdisplay", wrapup);
  }

  ex$message(msgnumb = EMS_S_ClearStatusField);
  wrapup:
    return (OM_stat);
}

end implementation ECreex;
