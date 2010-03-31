class implementation EMSsfaddraft;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)

/*

DESCRIPTION

    This method gets the stave state info structure from the instance
    data of this object and orders it logically. 

Return values 
    EMmsg - EMS_S_Success if all goes well.

HISTORY

   02/27/92  :  Nirmal  :  Creation

*/

{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSaddraftssi_table     *my_info;
  union EMSssiSizeData      size_data;

  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  sts = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  sts = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data,
                      ssi), 
                targetid = my_id); 
  if (!(1 & sts & *EMmsg)) goto wrapup;

  my_info = &((*ssi)->addrft_info);

  my_info->num_composites = ME.EMSsfaddraft->num_composites;

  /* Move num surfs out per composite to ssi struct */

  total_surfs_out = 0;
  for (i = 0; i < my_info->num_composites; i ++)
  {
   my_info->num_surfaces_out[i] = ME.EMSsfregmod->in_out[i];

   /* Compute total num surfs out in order to get comp indices */

   total_surfs_out += ME.EMSsfregmod->in_out[i];
  }

  /* Move composite to surface channel indices to ssi struct */

  for (j = 0; j < total_surfs_out; j ++, i ++)
    my_info->composite_indices[j] = ME.EMSsfregmod->in_out[i];

  /* Get the composite ids */

  for(i = 0; i < my_info->num_composites; i ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->composite_ids[i] = ME.EMSdpr->ids[i];
      else
      {
        my_info->composite_ids[i] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }


  l = 0;
  for(j = 0; j < my_info->num_composites; j ++)
  {
   for(k = 0; k < my_info->num_surfaces_out[j]; k ++, i ++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->surface_out_ids[l] = ME.EMSdpr->ids[i];
      else
      {
        my_info->surface_out_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  my_info->num_old_commedge_pairs = ME.EMSsfaddraft->num_old_commedge_pairs;
  for(j = 0; j < my_info->num_old_commedge_pairs; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->old_commedge_pairs1[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->old_commedge_pairs1[j] =  NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

  my_info->num_old_commedge_pairs = ME.EMSsfaddraft->num_old_commedge_pairs;
  for(j = 0; j < my_info->num_old_commedge_pairs; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->old_commedge_pairs2[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->old_commedge_pairs2[j] =  NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

  my_info->num_new_commedge_pairs = ME.EMSsfaddraft->num_new_commedge_pairs;
  for(j = 0; j < my_info->num_new_commedge_pairs; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->new_commedge_pairs1[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->new_commedge_pairs1[j] =  NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

  my_info->num_new_commedge_pairs = ME.EMSsfaddraft->num_new_commedge_pairs;
  for(j = 0; j < my_info->num_new_commedge_pairs; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->new_commedge_pairs2[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->new_commedge_pairs2[j] =  NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }


 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfaddraft.EMgetSSI")
  return(sts);
}
end implementation EMSsfaddraft;
