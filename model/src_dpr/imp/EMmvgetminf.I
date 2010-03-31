/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSboundary import EMgetsurface_info;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  IGRint i, num_sfsmod;
  IGRlong msg_loc, stat_OM;
  GRobjid *sfobjs, **memptrs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  sfobjs = NULL;
  memptrs = NULL;

  num_sfsmod = om$dimension_of (varray = ME.EMSdpr->ids);
  sfobjs = (GRobjid *) om$malloc (size = num_sfsmod * sizeof (GRobjid));
  EMerr_hndlr (!sfobjs, *msg, EMS_E_NoDynamicMemory, ret_end);
  for (i=0; i<num_sfsmod; i++)
   {
   stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
              &sfobjs[i], NULL), targetid = ME.EMSdpr->ids[i]);
   EMomerr_exit (stat_OM, ret_end);
   EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
   }
  modobjinfo->num_sfsmod = num_sfsmod;
  modobjinfo->sfsmod = sfobjs;
  modobjinfo->num_sfsdel = 0;

  /*
   * These loops are not actually deleted but are modified in
   * model-space. It's edges are also considered modified in
   * model-space. Instead of taking the trouble to malloc and format, just
   * treat these loops as deleted.
   */

  modobjinfo->num_lpsdel = num_sfsmod;
  modobjinfo->lpsdel = ME.EMSdpr->ids;
  modobjinfo->num_lpsmod = 0;

  modobjinfo->num_edsmod = 0;
  modobjinfo->num_edsdel = 0;

  memptrs = (GRobjid **) om$malloc (size = sizeof (GRobjid));
  EMerr_hndlr (!memptrs, *msg, EMS_E_NoDynamicMemory, ret_end);
  memptrs[0] = sfobjs;
  modobjinfo->ptrs_malloced = (IGRchar **) memptrs;
  modobjinfo->num_ptrs_malloced = 1;

ret_end:
  if (EMSerror (*msg & stat_OM))
    {
    if (sfobjs)
      om$dealloc (ptr = sfobjs);
    if (memptrs)
      om$dealloc (ptr = memptrs);
    }
  return (stat_OM);
}

end implementation EMSsfmove;

