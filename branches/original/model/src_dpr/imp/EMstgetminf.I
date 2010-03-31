/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  modobjinfo->num_sfsmod = 0;
  modobjinfo->num_sfsdel = 0;

  modobjinfo->num_lpsmod = 0;
  modobjinfo->num_lpsdel = 0;

  modobjinfo->num_edsmod = 0;
  modobjinfo->num_edsdel = 0;

  modobjinfo->num_ptrs_malloced = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSsfstitch;

