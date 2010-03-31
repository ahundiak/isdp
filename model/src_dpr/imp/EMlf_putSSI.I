class implementation EMSlift;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "EMSopt.h"

from EMSloop	import EMset_props;

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
/*
History

       RC        11/01/87       Creation Date
       RC        03/14/88       Rewrote for 1.2.0
       RC        05/24/88       Added code for single sf lift.
*/

{
  IGRlong                      OM_stat;
  IGRlong                      mthd_stat;
  IGRint                       i, j, k, in_out_idx, ids_idx, 
                               cum_num_sfs_out;
  IGRuint                      in_out_vla_size, ids_vla_size;
  IGRshort                     option = EMS_O_OFF;
  IGRushort                    props = EMLP_ACTIVE;
  struct EMSlftssi_table    *my_info;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_info = &ssi->lft_info;

  cum_num_sfs_out = 0;
  for (i = 0; i < my_info->num_composites; i++)
    cum_num_sfs_out += my_info->num_surfaces_out[i];

  in_out_vla_size = 7 +                      /* for int variables */
                    my_info->num_composites +
                    cum_num_sfs_out +
                    (my_info->num_sf_affected) * 2  +  
                    my_info->num_eds_rplcd;

  OM_stat = om$vla_set_dimension (varray = me->in_out, 
                                  size = in_out_vla_size);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

  /*
   * fill in_out[] array
   */

  in_out_idx = 0;
  ids_vla_size = 0;

  me->in_out[in_out_idx++] = my_info->num_composites;
  ids_vla_size += my_info->num_composites;

  for ( i = 0; i < my_info->num_composites; i++, in_out_idx++)
    me->in_out[in_out_idx] = my_info->num_surfaces_out[i];

  ids_vla_size += cum_num_sfs_out;

  for ( i = 0; i < cum_num_sfs_out; i++, in_out_idx++)
   me->in_out[in_out_idx] = my_info->composite_indices[i];

  me->in_out[in_out_idx++] = my_info->num_sf_lifted;
  ids_vla_size += my_info->num_sf_lifted;

  me->in_out[in_out_idx++] = my_info->num_sf_affected;
  ids_vla_size += my_info->num_sf_affected;

  for (i = 0; i < my_info->num_sf_affected; i++, in_out_idx++)
  {
     me->in_out[in_out_idx] = my_info->num_regions_in[i];
     ids_vla_size += my_info->num_regions_in[i];
  }

  for (i = 0; i < my_info->num_sf_affected; i++, in_out_idx++)
  {
    me->in_out[in_out_idx] = my_info->num_regions_out[i];
    ids_vla_size += my_info->num_regions_out[i];
  }

  me->in_out[in_out_idx++] = my_info->num_eds_rplcd;
  ids_vla_size += my_info->num_eds_rplcd;

  for (i = 0; i < my_info->num_eds_rplcd; i++, in_out_idx++)
  {
     me->in_out[in_out_idx] = my_info->num_eds_in[i];
     ids_vla_size += my_info->num_eds_in[i];
  }

  me->in_out[in_out_idx++] = my_info->num_eds_wcm_md;
  ids_vla_size += (my_info->num_eds_wcm_md) * 4;

  me->in_out[in_out_idx++] = my_info->num_ed_wmv_cm;
  ids_vla_size += (my_info->num_ed_wmv_cm) * 2;

  me->in_out[in_out_idx] = my_info->num_eds_wcm_eds;
  ids_vla_size += (my_info->num_eds_wcm_eds) * 2;
  
  /*
   * fill ids[] array
   */

  OM_stat = om$vla_set_dimension (varray = me->ids, 
                                  size = ids_vla_size);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

  ids_idx = 0;

  for ( i = 0; i < my_info->num_composites; i++, ids_idx++)
    me->ids[ids_idx] = my_info->composite_ids[i];

  for ( i = 0; i < cum_num_sfs_out; i++, ids_idx++)
    me->ids[ids_idx] = my_info->surface_out_ids[i];

  for (i = 0; i < my_info->num_sf_lifted; i++, ids_idx++)
    me->ids[ids_idx] = my_info->sf_lifted_ids[i];

  for (i = 0; i < my_info->num_sf_affected; i++, ids_idx++)
    me->ids[ids_idx] = my_info->sf_affctd_ids[i];

  k = 0;
  for (i = 0; i < my_info->num_sf_affected; i++)
    for (j = 0; j< my_info->num_regions_in[i]; j++, k++, ids_idx++)
       me->ids[ids_idx] = my_info->region_in_ids[k];

  k = 0;
  for (i = 0; i < my_info->num_sf_affected; i++)
  {
   for (j = 0; j < my_info->num_regions_out[i]; j++, k++, ids_idx++)
   {
      me->ids[ids_idx] = my_info->region_out_ids[k];
      OM_stat = om$send (msg = message EMSloop.EMset_props(
                          &mthd_stat, props, option),
                         targetid = my_info->region_out_ids[k]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

   } /* for (j = 0; j < my_info->num_regions_out[i]; j++, k++, 
             ids_idx++)*/

  } /* for (i = 0; i < my_info->num_sf_affected; i++) */

  for (i = 0; i < my_info->num_eds_rplcd; i++, ids_idx++)
   me->ids[ids_idx] = my_info->ed_rplcd_ids[i];

  k = 0;
  for (i = 0; i < my_info->num_eds_rplcd; i++)
   for (j = 0; j < my_info->num_eds_in[i]; j++, k++, ids_idx++)
     me->ids[ids_idx] = my_info->ed_in_ids[k];

  for (i = 0; i < (my_info->num_eds_wcm_md * 4); i++, ids_idx++)
    me->ids[ids_idx] = my_info->ed_mcm_ed_ids[i];

  for (i = 0; i < (my_info->num_ed_wmv_cm * 2); i++, ids_idx++)
    me->ids[ids_idx] = my_info->ed_ced_ids[i];

  for (i = 0; i < (my_info->num_eds_wcm_eds * 2); i++, ids_idx++)
   me->ids[ids_idx] = my_info->ed_cm_ed_ids[i];

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSlift.EMputSSI")
  return(OM_stat);
}

end implementation EMSlift;
