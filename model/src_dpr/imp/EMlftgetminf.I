/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRushort *numarray;
  IGRint i, inx;
  IGRint num_compsfs, num_sfsdel, num_sfsadd, num_sfsmod;
  IGRint num_lpsdel, num_lpsadd, num_edsdel, num_edsadd;
  IGRlong stat_OM;
  GRobjid *ids;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ids = ME.EMSdpr->ids;
  numarray = ME.EMSsfregmod->in_out;
  inx = 0;

  num_compsfs = numarray[inx++];
  num_sfsdel = 0;
  for (i=0; i<num_compsfs; i++)
    num_sfsdel += numarray[inx++];
  inx += num_sfsdel;
  num_sfsadd = numarray[inx++];
  num_sfsmod = numarray[inx++];

  num_lpsadd = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsadd += numarray[inx++];
  num_lpsdel = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsdel += numarray[inx++];

  num_edsdel = numarray[inx++];
  num_edsadd = 0;
  for (i=0; i<num_edsdel; i++)
    num_edsadd += numarray[inx++];

  modobjinfo->num_sfsdel = num_sfsdel;
  inx = num_compsfs;
  modobjinfo->sfsdel = &ids[inx];
  modobjinfo->num_sfsmod = num_sfsmod;
  inx += (num_sfsdel + num_sfsadd);
  modobjinfo->sfsmod = &ids[inx];

  modobjinfo->num_lpsdel = num_lpsdel;
  inx += (num_sfsmod + num_lpsadd);
  modobjinfo->lpsdel = &ids[inx];
  modobjinfo->num_lpsmod = 0;

  modobjinfo->num_edsdel = num_edsdel;
  inx += num_lpsdel;
  modobjinfo->edsdel = &ids[inx];
  modobjinfo->num_edsmod = 0;

  modobjinfo->num_ptrs_malloced = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSlift;

