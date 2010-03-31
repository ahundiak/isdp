/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSssi.h"
#include "OMprimitives.h"
#include "OMmacros.h"

/*

Description

    This file contains all of the implementations needed
    for cross section save state manipulation.

History
        RC        09/01/88       Creation Date
*/


method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
{
  union   EMSssiSizeData  size_data;
  struct  EMSxsssi_table  *my_info;
  struct  EMSxsssi_size   *my_size;

  IGRlong                 OM_stat, mthd_stat;
  IGRint                  i, j, k, in_out_idx, ids_idx;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  OM_stat = om$send (msg = message EMSdpr.EMgetSSIsize (&mthd_stat,
                      &size_data), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  OM_stat = om$send (msg = message EMSdpr.EMgetSSIbuffer (&mthd_stat,
                      &size_data, ssi), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  my_info = &((*ssi)->xs_info);
  my_size = &size_data.xs_info;
  in_out_idx = ids_idx = 0;

  /*
   * Load the numbers.
   */

  my_info->num_composites = (IGRint) me->in_out[in_out_idx++];

  for (i = 0; i < my_info->num_composites; i++, in_out_idx++)
   my_info->num_surfaces_out[i] = me->in_out[in_out_idx];

  for (i = 0; i < my_size->num_surfaces_out; i++, in_out_idx++)
   my_info->composite_indices[i] = me->in_out[in_out_idx];

  my_info->num_surfaces = (IGRint) me->in_out[in_out_idx++];

  for (i = 0; i < my_info->num_surfaces; i++, in_out_idx++)
   my_info->num_regions_in[i] = me->in_out[in_out_idx];

  for (i = 0; i < my_info->num_surfaces; i++, in_out_idx++)
   my_info->num_regions_out[i] = me->in_out[in_out_idx];

  /*
   * Load objectids
   */

  for (i = 0; i < my_info->num_composites; i++, ids_idx++)
   my_info->composite_ids[i] = me->ids[ids_idx];

  for (i = 0; i < my_size->num_surfaces_out; i++, ids_idx++)
   my_info->surface_out_ids[i] = me->ids[ids_idx];

  for (i = 0; i < my_info->num_surfaces; i++, ids_idx++)
   my_info->surface_ids[i] = me->ids[ids_idx];

  for (i = 0, k = 0; i < my_info->num_surfaces; i++)
   for (j = 0; j < my_info->num_regions_in[i]; j++, ids_idx++, k++)
     my_info->region_in_ids[k] = me->ids[ids_idx];

  for (i = 0, k = 0; i < my_info->num_surfaces; i++)
   for (j = 0; j < my_info->num_regions_out[i]; j++, ids_idx++, k++)
     my_info->region_out_ids[k] = me->ids[ids_idx];

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMgetSSI");
   return (OM_stat);
}

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
{
  struct EMSxsssi_table   *my_info;

  IGRlong                 OM_stat;
  IGRint                  i, j, k, in_out_idx, ids_idx, cum_num_sfs_out;
  OMuint                  in_out_vla_size, ids_vla_size;
  

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_info = &ssi->xs_info;

  cum_num_sfs_out = 0;
  for (i = 0; i < my_info->num_composites; i++)
    cum_num_sfs_out += my_info->num_surfaces_out[i];

  in_out_vla_size = 2 + my_info->num_composites +
                    cum_num_sfs_out + my_info->num_surfaces * 2;

  OM_stat = om$vla_set_dimension (varray = me->in_out,
                                  size = in_out_vla_size);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * Load in_out[] vla
   */

  in_out_idx = 0;
  ids_vla_size = 0;

  me->in_out[in_out_idx++] = my_info->num_composites;
  ids_vla_size += my_info->num_composites;

  for (i = 0; i < my_info->num_composites; i++, in_out_idx++)
   me->in_out[in_out_idx] = my_info->num_surfaces_out[i];

  ids_vla_size += cum_num_sfs_out;

  for (i = 0; i < cum_num_sfs_out; i++, in_out_idx++)
   me->in_out[in_out_idx] = my_info->composite_indices[i];

  me->in_out[in_out_idx++] = my_info->num_surfaces;
  ids_vla_size += my_info->num_surfaces;

  for (i = 0; i < my_info->num_surfaces; i++, in_out_idx++)
  {
    me->in_out[in_out_idx] = my_info->num_regions_in[i];
    ids_vla_size += my_info->num_regions_in[i];
  }

  for (i = 0; i < my_info->num_surfaces; i++, in_out_idx++)
  {
    me->in_out[in_out_idx] = my_info->num_regions_out[i];
    ids_vla_size += my_info->num_regions_out[i];
  }

  /*
   * Load ids[] vla
   */

  OM_stat = om$vla_set_dimension (varray = me->ids,
                                  size = ids_vla_size);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  ids_idx = 0;

  for (i = 0; i < my_info->num_composites; i++, ids_idx++)
   me->ids[ids_idx] = my_info->composite_ids[i];

  for (i = 0; i < cum_num_sfs_out; i++, ids_idx++)
   me->ids[ids_idx] = my_info->surface_out_ids[i];

  for (i = 0; i < my_info->num_surfaces; i++, ids_idx++)
   me->ids[ids_idx] = my_info->surface_ids[i];

  for (i = 0, k = 0; i < my_info->num_surfaces; i++)
   for (j = 0; j < my_info->num_regions_in[i]; j++, k++, ids_idx++)
    me->ids[ids_idx] = my_info->region_in_ids[k];

  for (i = 0, k = 0; i < my_info->num_surfaces; i++)
   for (j = 0; j < my_info->num_regions_out[i]; j++, k++, ids_idx++)
     me->ids[ids_idx] = my_info->region_out_ids[k];

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "IN EMSxsec_st.EMputSSI");
  return (OM_stat);
}

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
{
  struct  EMSxsssi_size   *my_size;
  IGRint                  i, in_out_idx;

  *EMmsg = EMS_S_Success;
  
  my_size = &size->xs_info;

  in_out_idx = 0;

  my_size->num_composites = (IGRint) me->in_out[in_out_idx++];

  my_size->num_surfaces_out = 0;
  for (i = 0; i < my_size->num_composites; i++, in_out_idx++)
   my_size->num_surfaces_out += (IGRint) me->in_out[in_out_idx];

  in_out_idx += my_size->num_surfaces_out;

  my_size->num_surfaces = me->in_out[in_out_idx++];

  my_size->num_regions_in = 0;
  for (i = 0; i < my_size->num_surfaces; i++, in_out_idx++)
    my_size->num_regions_in += me->in_out[in_out_idx];

  my_size->num_regions_out = 0;
  for (i = 0; i < my_size->num_surfaces; i++, in_out_idx++)
    my_size->num_regions_out += me->in_out[in_out_idx];

  return (OM_S_SUCCESS);
}

method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
{
  struct EMSxsssi_size  *my_size;
  IGRlong               OM_stat;
  IGRint                num_bytes;
 
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->xs_info;
  *ssi = NULL;

  /*
   * Calculate the buffer size
   */

  num_bytes = sizeof(union EMSssi_table);

  num_bytes += (my_size->num_composites +
                my_size->num_surfaces_out +
                my_size->num_surfaces * 2 )  * sizeof(IGRint);

  num_bytes += (my_size->num_composites +
                my_size->num_surfaces_out +
                my_size->num_surfaces +
                my_size->num_regions_in +
                my_size->num_regions_out) * sizeof(GRobjid);

  /*
   * Allocate buffer
   */

  *ssi = (union EMSssi_table *) om$malloc (size = num_bytes);
  EMerr_hndlr (!(*ssi), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  /*
   * Partition the buffer
   */

  {
    IGRint                     *int_ptr;
    GRobjid                    *objid_ptr;
    struct   EMSxsssi_table    *my_info;
    union    EMSssi_table      *ssi_ptr;

    /*
     * Set int_ptr just below the header
     */

    ssi_ptr = *ssi;
    my_info = &ssi_ptr->xs_info;
    int_ptr = (IGRint *) (ssi_ptr +1);

    my_info->num_surfaces_out = int_ptr;
    int_ptr += my_size->num_composites;

    my_info->composite_indices = int_ptr;
    int_ptr += my_size->num_surfaces_out;

    my_info->num_regions_in = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_regions_out = int_ptr;
    int_ptr += my_size->num_surfaces;

    objid_ptr = (GRobjid *) int_ptr;

    my_info->composite_ids = objid_ptr;
    objid_ptr += my_size->num_composites;

    my_info->surface_out_ids = objid_ptr;
    objid_ptr += my_size->num_surfaces_out;

    my_info->surface_ids = objid_ptr;
    objid_ptr += my_size->num_surfaces;

    my_info->region_in_ids = objid_ptr;
    objid_ptr += my_size->num_regions_in;

    my_info->region_out_ids = objid_ptr;

   }
   
  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMgetSSIbuffer");
   return (OM_stat);
}

end implementation EMSxsec_st;
