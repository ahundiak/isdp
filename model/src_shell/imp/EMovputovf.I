/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshovflow;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMputovflow (IGRlong *msg; GRobjid shobj; IGRboolean (*vfunc)())
{
  IGRint vfunc_ident;
  IGRlong stat_OM;
  extern IGRboolean EMvfunc_by_identifier();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  (*vfunc) (msg, NULL, NULL, NULL, &vfunc_ident);
  EMerr_hndlr (EMSerror (*msg), stat_OM, OM_E_ABORT, ret_end);

  if (vfunc_ident == ME.EMSshovflow->vfunc_identifier)
    {
    stat_OM = om$send (msg = message EMSshobjmgr.EMputshobj (msg,
               shobj, vfunc), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    stat_OM = OM_I_STOP_SENDING;
    }
  else
    *msg = EMS_I_NotFound;

ret_end:
  return (stat_OM);
}

end implementation EMSshovflow;
