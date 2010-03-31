/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRushort *numarray;
  IGRint i, inx;
  IGRint num_compsf, num_sfsdel, num_sfsmod;
  IGRint num_lpsdel, num_lpsadd;
  IGRlong stat_OM;
  GRobjid *ids;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numarray = ME.EMSsfregmod->in_out;
  ids = ME.EMSdpr->ids;
  inx = 0;

  num_compsf = ME.EMSsfboolean->num_composites;
  num_sfsdel = 0;
  for (i=0; i<num_compsf; i++)
    num_sfsdel += numarray[inx++];
  num_sfsmod = ME.EMSsfregmod->num_surfaces;

  num_lpsadd = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsadd += numarray[inx++];
  num_lpsdel = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsdel += numarray[inx++];

  modobjinfo->num_sfsdel = num_sfsdel;
  modobjinfo->sfsdel = &ids[num_compsf];
  modobjinfo->num_sfsmod = num_sfsmod;
  modobjinfo->sfsmod = &ids[num_compsf + num_sfsdel];

  modobjinfo->num_lpsdel = num_lpsdel;
  modobjinfo->lpsdel = &ids[num_compsf + num_sfsdel + num_sfsmod + num_lpsadd];
  modobjinfo->num_lpsmod = 0;

  modobjinfo->num_edsmod = 0;
  modobjinfo->num_edsdel = 0;

  modobjinfo->num_ptrs_malloced = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSsfboolean;

