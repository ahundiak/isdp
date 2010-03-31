/* ###################   APOGEE COMPILED   ################## */
class implementation SKmgr;

#include "EMSmsgdef.h"


method SKconnect_to_ptvar(IGRlong *EMmsg;
                          OM_S_OBJID ptvar_id;
                          IGRushort options;
                          IGRint pt_index, mgr_index)

{
 IGRlong status;
 OM_S_CHANSELECT to_mgr, to_vars;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$make_chanselect(channame = "SKvariable.to_mgr",
                             p_chanselect = &to_mgr);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "SKmgr.to_vars",
                             p_chanselect = &to_vars);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message Root.connect(to_vars,pt_index,
                         ptvar_id,OM_Gw_current_OS, to_mgr,mgr_index),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "In SKmgr:SKconnect_to_ptvar error");
 return (status);
}

end implementation SKmgr;
