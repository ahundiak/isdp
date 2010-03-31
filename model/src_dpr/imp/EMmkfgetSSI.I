class implementation EMSsfmkface;

#include "EMS.h"
#include <stdio.h>
#include "EMSerrordef.h"
#include "emserr.h"

from EMSboundary import EMget_objid;

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
/*
History

    AIC    03/31/87    Creation Date
    RC     06/10/87    Modified due to changes in EMSsfmkface
		       instance data and EMSmfssi_table struct.
    RC     11/05/87    Modified for version 1.1.0 and change in
                       EMSmfssi_table struct.
*/
{
  IGRlong                OM_stat;
IGRlong   mthd_stat;
  IGRint                 i, j, k, l;
  struct EMSmfssi_table  *my_info;
  union EMSssiSizeData   size_data;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSIsize(&mthd_stat, 
                 &size_data), targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  OM_stat = om$send(msg = message EMSdpr.EMgetSSIbuffer
                (&mthd_stat, &size_data, ssi), targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  /*
   * Set the counters
   */

  my_info = &((*ssi)->mf_info);

  my_info->num_surfaces = (IGRint) ME.EMSsfregmod->num_surfaces;

  for(i = 0; i < my_info->num_surfaces; i ++)
    my_info->num_regions_in[i] = (IGRint) ME.EMSsfregmod->in_out[i];

  for(j = 0; j < my_info->num_surfaces; j ++, i ++)
    my_info->num_regions_out[j] = (IGRint) ME.EMSsfregmod->in_out[i];

  my_info->num_regions = (IGRint) ME.EMSsfmkface->num_regions;
  my_info->cum_num_edges_out = (IGRint) ME.EMSsfmkface->num_edges_out;
  my_info->num_edges_copied = (IGRint) ME.EMSsfmkface->num_edges_copied;

  for(j = 0; j < my_info->cum_num_edges_out; j ++, i ++)
    my_info->num_edges_in[j] = (IGRint) ME.EMSsfregmod->in_out[i];

  for(j = 0; j < my_info->num_regions; j ++, i ++)
    my_info->num_edges_out[j] = (IGRint) ME.EMSsfregmod->in_out[i];

  /*
   * Get the object ids
   */

  for(i = 0; i < my_info->num_surfaces; i++)
      my_info->surface_ids[i] = ME.EMSdpr->ids[i];

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
      for(k = 0; k < my_info->num_regions_in[j]; k ++, i++, l ++)
        my_info->region_in_ids[l] = ME.EMSdpr->ids[i];
  }

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
      for(k = 0; k < my_info->num_regions_out[j]; k ++, i++, l ++)
        my_info->region_out_ids[l] = ME.EMSdpr->ids[i];
  }

  for(j = 0; j < my_info->num_regions; j ++, i++)
      my_info->region_ids[j] = ME.EMSdpr->ids[i];

  l = 0;
  for(j = 0; j < my_info->cum_num_edges_out; j ++)
  {
      for(k = 0; k < my_info->num_edges_in[j]; k ++, i++, l ++)
        my_info->edge_in_ids[l] = ME.EMSdpr->ids[i];
  }

  l = 0;
  for(j = 0; j < my_info->num_regions; j ++)
  {
      for(k = 0; k < my_info->num_edges_out[j]; k ++, i++, l ++)
        my_info->edge_out_ids[l] = ME.EMSdpr->ids[i];
   }

   l = 0; 
   for (j = 0; j < 2 * my_info->num_edges_copied; j++, l++, i++ )
     my_info->ed_cp_ed_ids[l] = ME.EMSdpr->ids[i];

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSmfregmod.EMgetSSI");
  return(OM_stat);
}

end implementation EMSsfmkface;
