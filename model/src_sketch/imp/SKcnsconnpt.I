/* ###################   APOGEE COMPILED   ################## */
class implementation SKconstraint;

extern OMuword OPP_SKvariable_class_id;

method SKconnect_to_pt(IGRlong *EMmsg;
                        OM_S_OBJID pt_id;
                        IGRushort options;
                        IGRint pt_index, constraint_index)
{
 IGRlong status;
 OM_S_CHANSELECT to_variables, to_constraints,to_super_constrs;
 OMuword pt_classid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 status = om$get_classid (objid = pt_id,
                          p_classid = &pt_classid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "SKconstraint.to_variables",
                             p_chanselect = &to_variables);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$is_ancestry_valid(subclassid = pt_classid,
                               superclassid = OPP_SKvariable_class_id);
 if (status == OM_S_SUCCESS)
 {
  status = om$make_chanselect(channame = "SKvariable.to_constraints",
                             p_chanselect = &to_constraints);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$send (msg = message Root.connect(to_variables,pt_index,
                          pt_id,OM_Gw_current_OS, to_constraints,
                          constraint_index),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }
 else if (status == OM_I_INVANCESTRY)
 {
  status = OM_S_SUCCESS;

  status = om$make_chanselect(channame = "SKconstraint.to_super_constrs",
                              p_chanselect = &to_super_constrs);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$send (msg = message Root.connect(to_variables,pt_index,
                          pt_id,OM_Gw_current_OS, to_super_constrs,
                          constraint_index),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_OMerror;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In SKconstraint:SKconnect_to_pt error");
 return (status);
}
end implementation SKconstraint;

