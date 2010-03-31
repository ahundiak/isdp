class implementation EMSsfround;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;
from EMSloop import EMactivate_loop;

method EMputSSI(IGRlong *EMmsg; 
                union EMSssi_table *ssi)

{
  IGRlong                    stat_OM, msg;
  IGRint                     i, j, k, l;
  IGRuint            vla_size, ids_vla_size;
  struct EMSrndssi_table     *my_info;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_info = &ssi->rnd_info;

  /* Post the new info in the instance data */

   i = 0;
   
   vla_size = 2 * my_info->num_surfaces + 1 + my_info->num_edges_out + 2;

   stat_OM = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                                  size = vla_size);
   EMerr_hndlr (! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   ids_vla_size = my_info->num_surfaces;

   ME.EMSsfregmod->in_out[i++] = my_info->num_surfaces;

   for (j=0; j<my_info->num_surfaces; j++, i++)   
    {
     ME.EMSsfregmod->in_out[i] = my_info->num_regions_in[j];
     ids_vla_size += my_info->num_regions_in[j];
    }

   for (j = 0; j < my_info->num_surfaces; j++, i++)   
    {
     ME.EMSsfregmod->in_out[i] = my_info->num_regions_out[j];     
     ids_vla_size += my_info->num_regions_out[j];
    }

   ME.EMSsfregmod->in_out[i++] = my_info->num_edges_out;
   ids_vla_size += my_info->num_edges_out;

   for (j = 0; j < my_info->num_edges_out; j++, i++)   
    {
     ME.EMSsfregmod->in_out[i] = my_info->num_edges_in[j];     
     ids_vla_size += my_info->num_edges_in[j];
    }

   ME.EMSsfregmod->in_out[i++] = my_info->num_edges_rounded;
   ids_vla_size += my_info->num_edges_rounded;

  /* Set the EMSdpr.ids[] vla */

  stat_OM = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                                 size = ids_vla_size);
  EMerr_hndlr (!(1&stat_OM),*EMmsg,EMS_E_OMerror, wrapup);

  /* Save the surfaces */

  for(i=0; i<my_info->num_surfaces; i++)
    ME.EMSdpr->ids[i] = my_info->surface_ids[i];

  /* Save the region_in objects */

  l = 0;
  for(j=0; j<my_info->num_surfaces; j++)
   {
    for(k=0; k<my_info->num_regions_in[j]; k++, i++, l++)
     {
      ME.EMSdpr->ids[i] = my_info->region_in_ids[l];
 
      stat_OM = om$send (msg = message EMSloop.EMactivate_loop (&msg),
                         targetid = my_info->region_in_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
     }
   }

  /* Save the region_out objects */

  l = 0;
  for(j=0; j<my_info->num_surfaces; j++)
   {
    for(k=0; k<my_info->num_regions_out[j]; k++, i++, l++)
     {
      ME.EMSdpr->ids[i] = my_info->region_out_ids[l];

      stat_OM = om$send (msg = message EMSloop.EMset_props(&msg,
                               EMLP_ACTIVE, EMS_O_OFF),
                         targetid = my_info->region_out_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
     }
   }

  for(j=0; j<my_info->num_edges_out; j++, i++)
    ME.EMSdpr->ids[i] = my_info->edge_out_ids[j];

  l = 0;
  for(j=0; j<my_info->num_edges_out; j++)
   {
    for(k=0; k<my_info->num_edges_in[j]; k++, i++, l++)
     {
      ME.EMSdpr->ids[i] = my_info->edge_in_ids[l];
     }
   }

  for(j=0; j<my_info->num_edges_rounded; j++, i++)
    ME.EMSdpr->ids[i] = my_info->rounded_edge_ids[j];

wrapup:

  EMWRAPUP(*EMmsg, stat_OM, "EMSsfround.EMputSSI")
  return(stat_OM);
}

end implementation EMSsfround;
