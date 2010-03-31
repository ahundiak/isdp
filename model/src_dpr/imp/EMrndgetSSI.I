class implementation EMSsfround;

/*
History
    DLB 08/06/91    Dont get SSI if NULL state.
*/    

#include "EMS.h"
method EMgetSSI(IGRlong *EMmsg;
                union EMSssi_table **ssi)

{
 IGRlong                   stat_OM, msg;
 IGRint                    i, j, k, l;
 struct EMSrndssi_table    *my_info;
 union EMSssiSizeData      size_data;

/*--------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 *ssi = NULL;

 if (ME.EMSdpr->dpr_props & EMS_NULL_STATE) goto wrapup;

 stat_OM = om$send(msg = message EMSdpr.EMgetSSIsize(&msg, &size_data),
                   targetid = my_id);
 if (! (1 & stat_OM & msg)) goto wrapup;

 stat_OM = om$send(msg = message EMSdpr.EMgetSSIbuffer(&msg, &size_data,
                         ssi),
                   targetid = my_id); 
 if (! (1 & stat_OM & msg)) goto wrapup;

  /* Set the counters */

  my_info = &((*ssi)->rnd_info);

  i = 0;
  my_info->num_surfaces = ME.EMSsfregmod->in_out[i++];

  for (j=0; j<my_info->num_surfaces; j++, i++)
   {
    my_info->num_regions_in[j] = ME.EMSsfregmod->in_out[i];
   }

  for (j=0; j<my_info->num_surfaces; j++, i++)
   {
    my_info->num_regions_out[j] = ME.EMSsfregmod->in_out[i];
   }

  my_info->num_edges_out = ME.EMSsfregmod->in_out[i++];

  for (j=0; j<my_info->num_edges_out; j++, i++)
   {
    my_info->num_edges_in[j] = ME.EMSsfregmod->in_out[i];
   }

  my_info->num_edges_rounded = ME.EMSsfregmod->in_out[i++];

  /* Get the object ids */

  for(i=0; i<my_info->num_surfaces; i++)
   {
    my_info->surface_ids[i] = ME.EMSdpr->ids[i];
   }

  l = 0;
  for(j=0; j<my_info->num_surfaces; j++)
   {
    for(k=0; k<my_info->num_regions_in[j]; k++, i++, l++)
     {
      my_info->region_in_ids[l] = ME.EMSdpr->ids[i];          
     }
   }

  l = 0;
  for(j=0; j<my_info->num_surfaces; j++)
   {
    for(k=0; k<my_info->num_regions_out[j]; k++, i++, l++)
     {
      my_info->region_out_ids[l] = ME.EMSdpr->ids[i];
     }
   }

  for(j=0; j<my_info->num_edges_out; j++, i++)
   {
    my_info->edge_out_ids[j] = ME.EMSdpr->ids[i];
   }

  l = 0;
  for(j=0; j<my_info->num_edges_out; j++)
   {
    for(k=0; k<my_info->num_edges_in[j]; k++, i++, l++)
     {
      my_info->edge_in_ids[l] = ME.EMSdpr->ids[i];          
     }
   }

  for(j=0; j<my_info->num_edges_rounded; j++, i++)
   {
    my_info->rounded_edge_ids[j] = ME.EMSdpr->ids[i];
   }

wrapup:

  EMWRAPUP(*EMmsg, stat_OM, "EMSsfround.EMgetSSI");
  return(stat_OM);
}

end implementation EMSsfround;
