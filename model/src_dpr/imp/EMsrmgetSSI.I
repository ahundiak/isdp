/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
/*
Description
    This method gets the stave state info structure from the instance
    data of this object and orders it in a logically. 

Return values 
    EMmsg - EMS_S_Success if all goes well.

History
    SM	   11-Feb-88   Modified to take care of edges modified.
    DLB    11/02/87    Changed name of structure to ssi for vers. 1.1.0
    AIC    03/31/87    Creation Date
*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l, vla_size;
  struct EMSsfssi_table     *my_info;
  union EMSssiSizeData      size_data;
  IGRboolean		    edges_modified;

  /* Initialize*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  sts = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  sts = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data, ssi),
                targetid = my_id); 
  if (!(1 & sts & *EMmsg)) goto wrapup;

  /* Set the counters*/
  my_info = &((*ssi)->sf_info);
  my_info->num_surfaces = ME.EMSsfregmod->num_surfaces;

  for (i = 0; i < my_info->num_surfaces; i ++)
    my_info->num_regions_in[i] = ME.EMSsfregmod->in_out[i];

  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    my_info->num_regions_out[j] = ME.EMSsfregmod->in_out[i];

  if( (vla_size = om$dimension_of(varray = ME.EMSsfregmod->in_out))
      > i)
   {
       my_info->num_regions = (IGRint) ME.EMSsfregmod->in_out[i++];
       my_info->cum_num_edges_out = (IGRint) ME.EMSsfregmod->in_out[i++];
   }
  else
   {
       my_info->num_regions = 0;
       my_info->cum_num_edges_out = 0;
   }

  for(j=0; j<my_info->cum_num_edges_out; j++, i++)
   my_info->num_edges_in[j] = (IGRint) ME.EMSsfregmod->in_out[i];

  for(j = 0; j < my_info->num_regions; j ++, i ++)
    my_info->num_edges_out[j] = (IGRint) ME.EMSsfregmod->in_out[i];

  /* Are num_edges_copied stored?
  */
  if( (vla_size = om$dimension_of(varray = ME.EMSsfregmod->in_out))
      > i)
      my_info->num_edges_copied = ME.EMSsfregmod->in_out[i++];
  else my_info->num_edges_copied = 0;


  /* Get the object ids*/
  for(i = 0; i < my_info->num_surfaces; i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->surface_ids[i] = ME.EMSdpr->ids[i];
    else
    {
      my_info->surface_ids[i] = NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_in[j]; k ++, i++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->region_in_ids[l] = ME.EMSdpr->ids[i];          
      else
      {
        my_info->region_in_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;         
      }
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
  EMWRAPUP(*EMmsg, sts, "EMSsfregmod.EMgetSSI");
  return(sts);
}

end implementation EMSsfregmod;
