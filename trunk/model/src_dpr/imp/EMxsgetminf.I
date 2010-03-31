/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRushort *numarray;
  IGRint i, inx;
  IGRint num_compsf, num_sfsdel, num_sfsmod;
  IGRint num_lpsdel, num_lpsadd;
  GRobjid *ids;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numarray = ME.EMSsfregmod->in_out;
  ids = ME.EMSdpr->ids;
  inx = 0;

  num_compsf = numarray[inx++];
  num_sfsdel = 0;
  for (i=0; i<num_compsf; i++)
    num_sfsdel += numarray[inx++];
  inx += num_sfsdel;
  num_sfsmod = numarray[inx++];
  
  num_lpsadd = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsadd += numarray[inx++];
  num_lpsdel = 0;
  for (i=0; i<num_sfsmod; i++)
    num_lpsdel += numarray[inx++];
  
  modobjinfo->num_sfsdel = num_sfsdel;
  inx = num_compsf;
  modobjinfo->sfsdel = &ids[inx];
  modobjinfo->num_sfsmod = num_sfsmod;
  inx += num_sfsdel;
  modobjinfo->sfsmod = &ids[inx];

  modobjinfo->num_lpsdel = num_lpsdel;
  inx += num_lpsadd;
  modobjinfo->lpsdel = &ids[num_lpsadd];
  modobjinfo->num_lpsmod = 0;

  modobjinfo->num_edsmod = 0;
  modobjinfo->num_edsdel = 0;

  modobjinfo->num_ptrs_malloced = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSxsec_st;

