/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;

method EMputSSI(IGRlong *EMmsg; 
                union EMSssi_table *ssi)
/*
DESCRIPTION

This method stores the save state info in its packed form in the
instance data of this object.

RETURN VALUES
 
EMmsg - EMSS_S_Success if all is well.

HISTORY

 August, 1991  :  AMD  :  Creation

*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSdbssi_table   *my_info;
  IGRushort         props = EMLP_SPLIT;
  IGRshort                  option = EMS_O_OFF;
  void                      EFcvrt_to_from_tag();


  /*Initialize.*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (NOT ssi) return EMS_S_Success;

  my_info = &ssi->db_info;

  /*Compute the size needed for SSI.*/
 
  /*All composite ids will be on vla.*/
  i = my_info->num_composites;
  
  /*Compute total number of surfaces removed.*/
  total_surfs_out = 0;
  for(j = 0; j < my_info->num_composites; j ++)
    total_surfs_out += my_info->num_surfaces_out[j];

  /*Add total surfs out to existing vla size count.*/
  i += total_surfs_out;
  
  /*Add all modified surfaces ids.*/
  i += my_info->num_surfaces;

  /*Add all loop ids removed per surface.*/
  for(j = 0; j < my_info->num_surfaces; j ++)
    i += my_info->num_regions_out[j];

  /* Add all edges disconnected */
   i += my_info->num_edges_disconnected;

  /*Expand the vla for SSI.*/
  sts = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                             size = i);
  if (!(1 & sts)) goto wrapup;   
 
  /*Put the composites to the vla.*/
  if (my_info->num_composites)
  {
    OM_BLOCK_MOVE(my_info->composite_ids,
                  ME.EMSdpr->ids,
                  my_info->num_composites * sizeof(GRobjid));
  }

  /*Add the surfaces removed ids.*/
  i = my_info->num_composites;
  l = 0;
  for(j = 0; j < my_info->num_composites; j ++)
  {
    for(k = 0; k < my_info->num_surfaces_out[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->surface_out_ids[l];
    }
  }

  /*Add the surfaces modified*/
  if (my_info->num_surfaces)
  {
    OM_BLOCK_MOVE(my_info->surface_ids,
                  &ME.EMSdpr->ids[i],
                  my_info->num_surfaces * sizeof(GRobjid));
    i += my_info->num_surfaces;
  }

  /*Add the loops out per surface.*/
  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_out[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->region_out_ids[l];

      /*Turn off split bit of each loop.*/
      sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                          option),
                    targetid = my_info->region_out_ids[l]);
      if (! (1 & sts & *EMmsg)) goto wrapup;
    }
  }

  /* Add the edges disconnected */
  if (my_info->num_edges_disconnected)
  {
    OM_BLOCK_MOVE(my_info->edges_disconnected,
                  &ME.EMSdpr->ids[i],
                  my_info->num_edges_disconnected * sizeof(GRobjid));
    i += my_info->num_edges_disconnected;
  }
       
  /*Post the new info in the instance data.*/
  ME.EMSsfrembnd->num_composites = my_info->num_composites;
  ME.EMSsfrembnd->num_edges = my_info->num_edges_disconnected;
  ME.EMSsfregmod->num_surfaces = my_info->num_surfaces;
  
  /*Dimension the in_out vla.*/
  sts = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                             size = my_info->num_composites + 
                                    my_info->num_surfaces * 2 +
                                    total_surfs_out);

  /*Put num surfs out per composite in vla.*/   
  for(i = 0; i < my_info->num_composites; i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_surfaces_out[i];

  /*Put num loops removed per surface in vla.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_regions_out[j];    

  /*Put composite to surface indices in vla.*/
  for (j = 0; j < total_surfs_out; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->composite_indices[j];        

wrapup:
  EMWRAPUP(*EMmsg, sts, "sfb.putSSI")
  return(sts);
}
end implementation EMSsfrembnd;
