class implementation EMSsfaddraft;

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

  02/10/92  :  Nirmal  :  Creation

  10/xx/95  :  Hari    :  Fix for an internal error. Fix for
                          TR#119527618, TR#119527596, TR#119527808.

*/

{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSaddraftssi_table     *my_info;
  IGRushort                 props = EMLP_SPLIT;
  IGRshort                  option = EMS_O_OFF;
  void                      EFcvrt_to_from_tag();


  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (NOT ssi) return EMS_S_Success;

  my_info = &ssi->addrft_info;

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
  i += 2*my_info->num_old_commedge_pairs;
  i += 2*my_info->num_new_commedge_pairs;

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
  for(j=0; j< my_info->num_composites; j++)
    for(k = 0; k < my_info->num_surfaces_out[j]; k ++, i ++, l++)
      ME.EMSdpr->ids[i] = my_info->surface_out_ids[l];

  /* Add the edges disconnected */

  if (my_info->num_old_commedge_pairs)
  {
    OM_BLOCK_MOVE(my_info->old_commedge_pairs1,
                  &ME.EMSdpr->ids[i],
                  my_info->num_old_commedge_pairs* sizeof(GRobjid));
    i += my_info->num_old_commedge_pairs;
  }

  if (my_info->num_old_commedge_pairs)
  {
    OM_BLOCK_MOVE(my_info->old_commedge_pairs2,
                  &ME.EMSdpr->ids[i],
                  my_info->num_old_commedge_pairs* sizeof(GRobjid));
    i += my_info->num_old_commedge_pairs;
  }

  /*
   * Note : num_old_commedge_pairs need not be same as 
   *        num_new_commedge_pairs. Hari
   */
  if (my_info->num_new_commedge_pairs)
  {
    OM_BLOCK_MOVE(my_info->new_commedge_pairs1,
                  &ME.EMSdpr->ids[i],
                  my_info->num_new_commedge_pairs* sizeof(GRobjid));
    i += my_info->num_new_commedge_pairs;
  }
  if (my_info->num_new_commedge_pairs)
  {
    OM_BLOCK_MOVE(my_info->new_commedge_pairs2,
                  &ME.EMSdpr->ids[i],
                  my_info->num_new_commedge_pairs* sizeof(GRobjid));
    i += my_info->num_new_commedge_pairs;
  }

  /* Post the new info in the instance data */

  ME.EMSsfaddraft->num_composites = my_info->num_composites;
  ME.EMSsfaddraft->num_new_commedge_pairs = my_info->num_new_commedge_pairs;
  ME.EMSsfaddraft->num_old_commedge_pairs = my_info->num_old_commedge_pairs;
  
  /* Dimension the in_out vla */
  sts = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                             size = my_info->num_composites +
                                    total_surfs_out);

  /* Put num surfs out per composite in vla */   

  ME.EMSsfaddraft->num_composites = my_info->num_composites;
  for(i = 0; i < my_info->num_composites; i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_surfaces_out[i];

  /* Put composite to surface indices in vla */

  for (j = 0; j < total_surfs_out; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->composite_indices[j];        

wrapup:

  EMWRAPUP(*EMmsg, sts, "EMSsfaddraft.EMputSSI")
  return(sts);
}
end implementation EMSsfaddraft;
