/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"

from EMSdpr import EMundo, EMredo;
extern OMuword OPP_EMSdpr_class_id;

method EMmake_active_state(IGRlong *EMmsg; IGRushort *option;
                           struct GRmd_env *my_env; 
                           struct GRid **active_state; 
                           IGRint *num, *buff_size;
                           GRobjid **display_ids;
                           IGRint *display_count, *involk_count)
/*
Description
    This method will cause this tree node to become active by performing
    an undo or redo on the proper states.

Return Values
    EMmsg - EMS_S_Success if all is well

History
   DLB    07/07/92  Exit with success only if owner is not a DPR type when
                    sending EMundo or if I'm not a DPR type when sending
                    EMredo.    
   SM     06/05/92  Exit if not a DPR type.
   DLB    04/29/88  Modified to perform redo if not in the active path.
   DLB    10/31/87  Modified for version 1.1.0
   DLB    04/9/87   Creation.
*/
{
 IGRlong    OM_stat;
 IGRboolean unused_info=FALSE, active_path=FALSE;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 OM_stat = om$send(msg = message EMSsurface.EMisactive(EMmsg, &unused_info,
                         &active_path),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        

 if (active_path)
 {
   OM_S_CHANSELECT     to_owners;

   to_owners.type = OM_e_addr;
   to_owners.u_sel.addr = &ME.GRconnector->to_owners;
    
   OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg, option, my_env, 
                           active_state, num, buff_size, display_ids, 
                           display_count, involk_count),
                     p_chanselect = &to_owners,
                     from = 0, to = 0);
   if (OM_stat == OM_W_UNKNOWN_MSG) 
   {OM_stat = OM_S_SUCCESS; goto wrapup;}
   else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else
 {
   OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, option, my_env, 
                           display_ids, display_count, involk_count),
                     targetid = my_id);
   if (OM_stat == OM_W_UNKNOWN_MSG) 
   {OM_stat = OM_S_SUCCESS; goto wrapup;}
   if (!(1  & OM_stat & *EMmsg)) goto wrapup;
 } 
 
 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "surf.EMmkactst")
  return(OM_stat);
}
end implementation EMSsurface;
