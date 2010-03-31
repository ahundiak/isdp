/* ###################   APOGEE COMPILED   ################## */
class implementation SKconstraint;

method SKconnect_to_skmgr(IGRlong *EMmsg;
                        OM_S_OBJID mgr_id;
                        IGRushort options;
                        IGRint mgr_index, constraint_index)
{
 IGRlong status;
 OM_S_CHANSELECT to_mgr, to_constraints;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$make_chanselect(channame = "SKconstraint.to_mgr",
                             p_chanselect = &to_mgr);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "SKmgr.to_constrs",
                             p_chanselect = &to_constraints);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message Root.connect(to_mgr,mgr_index,
                         mgr_id,OM_Gw_current_OS, to_constraints,
                         constraint_index),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "In SKconstraint:SKconnect_to_skmgr error");
 return (status);
}
end implementation SKconstraint;

