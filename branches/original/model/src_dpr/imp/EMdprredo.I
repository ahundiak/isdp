/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSmsgdef.h"
#include "EMSopt.h"

method EMredo(IGRlong *EMmsg;
              IGRushort *option;
              struct GRmd_env *my_env;
              GRobjid **display_ids;
              IGRint *display_count, *involk_count)
/*
Description
    This method will redo one or more states depending on where the
    message is sent in the tree.  

    The message must be sent to a state in the tree that is NOT part of the
    active path.  If the message is sent to any state above the active 
    state(s) then an redo will occur from the active state up to AND
    INCLUDING the state the message was originally sent to.  After redo is
    done the state the redo was originally sent to will be active.
     
    The options for redo are:  

      EMS_DO_DISPLAY - This is an optimization feature to speed up the
                       display of complex solids and surfaces. 

Return Values
    EMmsg - EMS_S_Success if all is well
            EMS_E_ChanCountWrong if discrepencies in the tree are found

Notes
    if 'option' != EMS_DO_DISPLAY then display_ids, display_count, and 
    involk_count parameters may be passed as NULL.


History
   DLB   04/30/91 EMreex param change (type; recomp_info).
   DLB   03/29/91 EMreex param change (construct_list).
   DLB   03/13/91 EMreex param change.
   DLB   07/27/89 Added check for UNEVAL_STATE bit.
   SM    23-May-89 If EMreexecute returns EMS_I_ChangeClass then send the
                  message EMSdpr.EMchangeClass just before exiting.
   DLB   03/14/88 Added selective display code
   DLB   11/02/87 Modified for version 1.1.0
   DLB    4/16/87 creation
*/
{
 IGRlong             OM_stat;
 OM_S_CHANSELECT     to_comps;
 IGRboolean          action, chgclass = FALSE;
 IGRushort   mask;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 if (*option & EMS_DO_DISPLAY) (*involk_count)++;

 /*If I am active then all is well.*/
 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) goto wrapup;

 /*Send on down the tree*/
 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 /*Check the return code since the msg could have been sent to a primitive
  * which would not have understood the msg.
  */
 OM_stat = om$send(msg = OPPmargs,
                   p_chanselect = &to_comps);
 if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

 if (*EMmsg == EMS_I_BoolFail) 
 {
   OM_stat = OM_S_SUCCESS;
   goto wrapup;
 }

 OM_stat = OM_S_SUCCESS; /*Fix the return code*/
   
 if (ME.EMSdpr->dpr_props & EMS_PERFORM_REEX)
 {
   /*Recompute this state.*/
   OM_stat = om$send(msg = message EMSdpr.EMreexecute(EMmsg, option,
                           my_env, NULL, NULL, NULL, NULL, NULL), 
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
   if (*EMmsg == EMS_I_BoolFail) 
   {
      OM_stat = OM_S_SUCCESS;
      goto wrapup;
   }
   else if(*EMmsg == EMS_I_ChangeClass) chgclass = TRUE;
 }
 else
 {
   if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
   {
     OM_stat = om$send(msg = message EMSdpr.EMactivate(EMmsg, 
                             (IGRshort *) option, my_env,
                             display_ids, display_count),
                       targetid = my_id);
     if (! (1 & OM_stat & *EMmsg)) goto wrapup;
   }
   ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);
 }

 /*Turn off last states active state bit*/
 action = FALSE;
 mask = EMSIS_ACTIVE_STATE;

 /*NOTE- My last state may not be of class EMSdpr in which case it won't
  *      understand this message.  So I just check the return 
  *      om message and ignore an unknown msg warning.
  */
 OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, &mask),
                   p_chanselect = &to_comps);
 if(!(1 & *EMmsg & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG))goto wrapup;
   
 OM_stat = OM_S_SUCCESS;  /*Fix the return status*/

 wrapup:
  if (*option & EMS_DO_DISPLAY)
  {
    if (*involk_count == 1)
    {
      /*This is the first invocation of this method so redisplay.*/
      IGRlong tmp_stat, i, tmp_msg;
      enum GRdpmode display_mode=GRbd;  /*DECL*/

      for (i=0; i<*display_count; i++)
      {
        tmp_stat = om$send(msg = message GRgraphics.GRdisplay(&tmp_msg, 
                                 &my_env->md_env.matrix_type,
                                 my_env->md_env.matrix, &display_mode,
                                 &my_env->md_id),
                           targetid = (*display_ids)[i]);
        if (!(1 & tmp_stat & tmp_msg)) break;
      }
    }

    (*involk_count)--;
    if ( !(*involk_count) && *display_ids ) om$dealloc(ptr = *display_ids);
  }

  if( (1&*EMmsg&OM_stat) && chgclass)
   OM_stat = om$send(msg = message EMSdpr.EMchangeClass(EMmsg, NULL, NULL), 
                     targetid = my_id);

  EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMredo")
  return(OM_stat);
}
end implementation EMSdpr;
