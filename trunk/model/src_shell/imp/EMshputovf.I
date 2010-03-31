/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshobjmgr;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSshovflow_class_id;

from EMSshovflow import EMovfinit;

method EMputovflow (IGRlong *msg; GRobjid shobj; IGRboolean (*vfunc)())
{
  IGRlong stat_OM, msg_loc;
  GRobjid ovfobj;
  OM_S_CHANSELECT chan_to_ovflow;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_ovflow);
  EMomerr_exit (stat_OM, ret_end);

  *msg = EMS_I_NotFound;
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_ovflow);
  if (*msg == EMS_I_NotFound)
    {
    stat_OM = om$construct (classid = OPP_EMSshovflow_class_id,
               p_objid = &ovfobj, msg = message EMSshovflow.EMovfinit
               (&msg_loc, my_id, vfunc));
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = OPPmargs, targetid = ovfobj);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshobjmgr.EMputovflow");
  return (stat_OM);
}

end implementation EMSshobjmgr;
