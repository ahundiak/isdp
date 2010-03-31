/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMScpmgr_class_id;

method EMwakeup (IGRboolean temp_wakeup)
{
  IGRlong stat_OM, msg_loc;
  extern void EMputmgr();

  stat_OM = OM_S_SUCCESS;

  /*
   * If this is when the file is first being opened, put this manager's
   * id in the local table stored as static-global in the object-manager-
   * manipulation file. All this, for easy access during the design
   * session.
   */

  if (!temp_wakeup)
    {
    EMputmgr (&msg_loc, OM_Gw_current_OS, OPP_EMScpmgr_class_id,
     ME.EMSobjmgr->label, my_id);
    if (EMSerror (msg_loc))
      stat_OM = OM_E_ABORT;
    }

ret_end:
  return (stat_OM);
}


method EMsleep (IGRboolean temp_sleep; IGRboolean file_write)
{
  IGRlong stat_OM, msg_loc;
  extern void EMremmgr();

  stat_OM = OM_S_SUCCESS;

  /*
   * If this is a permanent sleep, that is a file is being closed, then
   * remove this object's id form the table in the object-manager manipulation
   * file.
   */

  if (! temp_sleep)
    {
    EMremmgr (&msg_loc, OM_Gw_current_OS, OPP_EMScpmgr_class_id,
     ME.EMSobjmgr->label);
    if (EMSerror (msg_loc))
      stat_OM = OM_E_ABORT;
    }

ret_end:
  return (stat_OM);
}

end implementation EMScpmgr;
