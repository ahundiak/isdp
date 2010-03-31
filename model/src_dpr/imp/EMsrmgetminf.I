/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRushort *numarray;
  IGRint i, inx;
  IGRint num_sfsmod, num_lpsdel, num_lpsadd;
  IGRint num_edsdel, num_edsadd, dum_num_regions;
  IGRlong stat_OM;
  GRobjid *ids;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numarray = ME.EMSsfregmod->in_out;
  ids = ME.EMSdpr->ids;
  inx = 0;

  num_sfsmod = ME.EMSsfregmod->num_surfaces;

  num_lpsadd = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsadd += numarray[inx++];
  num_lpsdel = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsdel += numarray[inx++];

  dum_num_regions = numarray[inx++];

  num_edsdel = numarray[inx++];
  num_edsadd = 0;
  for (i=0; i<num_edsdel; i++)
    num_edsadd += numarray[inx++];

  modobjinfo->num_sfsmod = num_sfsmod;
  inx = 0;
  modobjinfo->sfsmod = &ids[inx];
  modobjinfo->num_sfsdel = 0;

  modobjinfo->num_lpsdel = num_lpsdel;
  inx += (num_sfsmod + num_lpsadd);
  modobjinfo->lpsdel = &ids[inx];
  modobjinfo->num_lpsmod = 0;

  modobjinfo->num_edsdel = num_edsdel;
  inx += (dum_num_regions + num_edsadd);
  modobjinfo->edsdel = &ids[inx];
  modobjinfo->num_edsmod = 0;

  modobjinfo->num_ptrs_malloced = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSsfregmod;

