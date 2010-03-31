/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmacro;

#include "EMS.h"

#include "EMSmsgdef.h"
#include "emsdef.h"


method EMundo(IGRlong           *EMmsg;
              IGRushort *option;
              struct GRmd_env   *my_env;
              struct GRid       **active_state; 
              IGRint            *num, 
                                *buff_size;
              GRobjid           **display_ids;
              IGRint            *display_count,
                                *involk_count)
/*********************************************************************
Description
  This method contains the override to undo the surface/solid based on
  the number of states being controlled by the macro object and who
  sends the message. 

Arguments
 See DPR message definition at EMSdpr.S

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail: Otherwise

History
 Creation : PP : 05/25/90

 ******************************************************************** */

{
 IGRlong             status;
 IGRint tree_depth;
 OM_S_CHANSELECT to_comps;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 status = om$is_objid_on_channel(objid_c = my_id,
                                 p_chanselect = &to_comps,
                                 objid = sender_id);

 if (status == OM_S_SUCCESS)
 {
  status = om$send (msg = message EMSdpr.EMundo(EMmsg,option,my_env,
                          active_state,num,buff_size,display_ids,
                          display_count,involk_count),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
  tree_depth = ME.EMSsfmacro->num_states - 1;

  status = om$send (msg = message EMSdpr.EMpass(EMmsg, NULL, OPPmargs, 
                          &tree_depth),
                    p_chanselect = &to_comps);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
wrapup:
  EMWRAPUP(*EMmsg, status, "In EMSsfmacro.EMundo")
  return(status);
}

end implementation EMSsfmacro;
