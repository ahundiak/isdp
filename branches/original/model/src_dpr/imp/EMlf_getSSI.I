class implementation EMSlift;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)

/*
History

        RC        11/1/87       Creation Date
        RC        03/14/88      Rewrote for 1.2.0
        RC        05/24/88      Added code for single sf lift.
*/

{
  IGRlong                       OM_stat;
IGRlong   mthd_stat;
  IGRint                        i, j, k, in_out_idx, ids_idx, dim = 0;
  struct EMSlftssi_table     *my_info;
  union EMSssiSizeData          size_data;
  struct EMSlftssi_size      *my_size;

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
   * fill the buffer
   */

  my_info = &((*ssi)->lft_info);
  my_size = &size_data.lft_info;

  in_out_idx = ids_idx = 0;

  /*
   * Get The numbers
   */
  dim = om$dimension_of(varray = me->in_out);
  my_info->num_composites = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  for ( i = 0; i < my_info->num_composites; i++, in_out_idx++)
    my_info->num_surfaces_out[i] = me->in_out[in_out_idx];

  for (i = 0; i < my_size->num_surfaces_out; i++, in_out_idx++)
    my_info->composite_indices[i] = me->in_out[in_out_idx];

  my_info->num_sf_lifted = dim ? (IGRint) me->in_out[in_out_idx++] : 0;
  my_info->num_sf_affected = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  for (i = 0; i < my_info->num_sf_affected; i++, in_out_idx++)
    my_info->num_regions_in[i] = (IGRint) me->in_out[in_out_idx];

  for (i = 0; i < my_info->num_sf_affected; i++, in_out_idx++)
    my_info->num_regions_out[i] = (IGRint) me->in_out[in_out_idx];

  my_info->num_eds_rplcd = dim ? (IGRint) me->in_out[in_out_idx++] : 0;
  
  for (i = 0; i < my_info->num_eds_rplcd; i++, in_out_idx++)
    my_info->num_eds_in[i] = (IGRint) me->in_out[in_out_idx];

  my_info->num_eds_wcm_md = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  my_info->num_ed_wmv_cm = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  my_info->num_eds_wcm_eds = dim ? (IGRint) me->in_out[in_out_idx] : 0;
  
  /*
   * Get the objids
   */

  for (i = 0; i < my_info->num_composites; i++, ids_idx++)
   my_info->composite_ids[i] = me->ids[ids_idx];

  for (i = 0; i < my_size->num_surfaces_out; i++, ids_idx++)
   my_info->surface_out_ids[i] = me->ids[ids_idx];

  for (i = 0; i < my_info->num_sf_lifted; i++, ids_idx++)
   my_info->sf_lifted_ids[i] = me->ids[ids_idx];

  for (i = 0; i < my_info->num_sf_affected; i++, ids_idx++)
    my_info->sf_affctd_ids[i] = me->ids[ids_idx];

  k = 0;
  for (i = 0; i < my_info->num_sf_affected; i++)
   for (j = 0; j < my_info->num_regions_in[i]; j++, k++, ids_idx++)
     my_info->region_in_ids[k] = me->ids[ids_idx];

  k = 0;
  for (i = 0; i < my_info->num_sf_affected; i++)
   for (j = 0; j < my_info->num_regions_out[i]; j++, k++, ids_idx++)
     my_info->region_out_ids[k] = me->ids[ids_idx];

  for (i = 0; i < my_info->num_eds_rplcd; i++, ids_idx++)
    my_info->ed_rplcd_ids[i] = me->ids[ids_idx];

  k = 0;
  for (i = 0; i < my_info->num_eds_rplcd; i++)
   for (j = 0; j < my_info->num_eds_in[i]; j++, k++, ids_idx++)
     my_info->ed_in_ids[k] = me->ids[ids_idx];

  for (i = 0; i < (my_info->num_eds_wcm_md * 4); i++, ids_idx++)
    my_info->ed_mcm_ed_ids[i] = me->ids[ids_idx];

  for (i = 0; i < (my_info->num_ed_wmv_cm * 2); i++, ids_idx++)
    my_info->ed_ced_ids[i] = me->ids[ids_idx];

  for (i = 0; i < (my_info->num_eds_wcm_eds * 2); i++, ids_idx++)
    my_info->ed_cm_ed_ids[i] = me->ids[ids_idx];

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSlift.EMgetSSI");
  return(OM_stat);
}

end implementation EMSlift;
