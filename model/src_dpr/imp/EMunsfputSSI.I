class implementation EMSsfunitesf;

#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;

method EMputSSI( IGRlong *EMmsg; 
                 union EMSssi_table *ssi)

/*

DESCRIPTION

This method stores the save state info in its packed form in the
instance data of this object.

RETURN VALUES
 
EMmsg - EMSS_S_Success if all is well.

HISTORY

  07/10/92  :  AMD  :  Creation

*/

{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSunssi_table     *my_info;
  IGRushort                 props = EMLP_SPLIT;
  IGRshort                  option = EMS_O_OFF;
  void                      EFcvrt_to_from_tag();


  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (NOT ssi) return EMS_S_Success;

  my_info = &ssi->un_info;

  /* Compute the size needed for SSI */
 
  /* All composite ids will be on vla */
 
  i = my_info->num_composites;
  
  /* Compute total number of surfaces removed */

  total_surfs_out = 0;
  for(j = 0; j < my_info->num_composites; j ++)
    total_surfs_out += my_info->num_surfaces_out[j];

  /* Add total surfs out to existing vla size count */
  i += total_surfs_out;
  
  /* Add all edges : disconnected, added, removed */
  i += 3*my_info->num_edges;

  /* Expand the vla for SSI */
 
 sts = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                             size = i);
  if (!(1 & sts)) goto wrapup;   
 
  /* Put the composites to the vla */

  if (my_info->num_composites)
  {
    OM_BLOCK_MOVE(my_info->composite_ids,
                  ME.EMSdpr->ids,
                  my_info->num_composites * sizeof(GRobjid));
  }

  /* Add the surfaces removed ids */

  i = my_info->num_composites;
  l = 0;
  for(j = 0; j < my_info->num_composites; j ++)
  {
    for(k = 0; k < my_info->num_surfaces_out[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->surface_out_ids[l];
    }
  }

  /* Add the edges disconnected */

  if (my_info->num_edges)
  {
    OM_BLOCK_MOVE(my_info->edges_disconnected,
                  &ME.EMSdpr->ids[i],
                  my_info->num_edges* sizeof(GRobjid));
    i += my_info->num_edges;
  }

  /* Add the edges removed */

  if (my_info->num_edges)
  {
    OM_BLOCK_MOVE(my_info->edges_removed,
                  &ME.EMSdpr->ids[i],
                  my_info->num_edges * sizeof(GRobjid));
    i += my_info->num_edges;
  }

  /* Add the edges added */

  if (my_info->num_edges)
  {
    OM_BLOCK_MOVE(my_info->edges_added,
                  &ME.EMSdpr->ids[i],
                  my_info->num_edges * sizeof(GRobjid));
    i += my_info->num_edges;
  }
       
  /* Post the new info in the instance data */

  ME.EMSsfunitesf->num_composites = my_info->num_composites;
  ME.EMSsfunitesf->num_edges = my_info->num_edges;
  
  /* Dimension the in_out vla */

  sts = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                             size = my_info->num_composites + 
                                    total_surfs_out);

  /* Put num surfs out per composite in vla */   

  for(i = 0; i < my_info->num_composites; i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_surfaces_out[i];

  /* Put composite to surface indices in vla */

  for (j = 0; j < total_surfs_out; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->composite_indices[j];        

wrapup:

  EMWRAPUP(*EMmsg, sts, "EMSsfunitesf.EMputSSI")
  return(sts);
}
end implementation EMSsfunitesf;
