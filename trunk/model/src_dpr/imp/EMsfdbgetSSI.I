class implementation EMSsfrembnd;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
/*
Description
    This method gets the stave state info structure from the instance
    data of this object and orders it logically. 

Return values 
    EMmsg - EMS_S_Success if all goes well.

History

 August, 1991  :  AMD  :  Creation

*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSdbssi_table     *my_info;
  union EMSssiSizeData      size_data;

  /*Initialize.*/
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

  my_info = &((*ssi)->db_info);

  my_info->num_composites = ME.EMSsfrembnd->num_composites;

  /*Move num surfs out per composite to ssi struct.*/

    total_surfs_out = 0;
    for (i = 0; i < my_info->num_composites; i ++)
    {
       my_info->num_surfaces_out[i] = ME.EMSsfregmod->in_out[i];
       /*Compute total num surfs out in order to get comp indices*/
       total_surfs_out += ME.EMSsfregmod->in_out[i];
    }

  my_info->num_surfaces = ME.EMSsfregmod->num_surfaces;

  /*Move num loops out per surf to ssi struct.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    my_info->num_regions_out[j] = ME.EMSsfregmod->in_out[i];

    /*Move composite to surface channel indices to ssi struct.*/
    for (j = 0; j < total_surfs_out; j ++, i ++)
      my_info->composite_indices[j] = ME.EMSsfregmod->in_out[i];

    /*Get the composite ids.*/
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

  for(j = 0; j < my_info->num_surfaces; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->surface_ids[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->surface_ids[j] = NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }


  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_out[j]; k ++, i++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->region_out_ids[l] = ME.EMSdpr->ids[i];
      else
      {
        my_info->region_out_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  my_info->num_edges_disconnected = ME.EMSsfrembnd->num_edges;

  for(j = 0; j < my_info->num_edges_disconnected; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->edges_disconnected[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->edges_disconnected[j] = NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfrembnd.EMgetSSI")
  return(sts);
}
end implementation EMSsfrembnd;
