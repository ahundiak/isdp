/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshovflow;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMovfinit (IGRlong *msg; GRobjid shobj; IGRboolean (*vfunc)())
{
  IGRint vfunc_identifier;
  IGRlong stat_OM, msg_loc;
  OM_S_CHANSELECT chan_to_shobjmgr, chan_to_overflow;
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  ME.EMSshobjmgr->watermark = MAXINT;
  ME.EMSshobjmgr->numclasses = 0;
  ME.EMSshobjmgr->numobjects = 0;

  (*vfunc) (&msg_loc, NULL, NULL, NULL, &vfunc_identifier);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  ME.EMSshovflow->vfunc_identifier = vfunc_identifier;

  stat_OM = EMmake_chanselect (EMSshovflow_to_shobjmgr, &chan_to_shobjmgr);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMSshobjmgr_to_overflow, &chan_to_overflow);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message Root.connect (chan_to_shobjmgr, NULL,
             shobj, OM_Gw_current_OS, chan_to_overflow, MAXINT),
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  return (stat_OM);
}

end implementation EMSshovflow;
