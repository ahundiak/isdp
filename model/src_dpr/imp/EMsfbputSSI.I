class implementation EMSsfboolean;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
/*
DESCRIPTION

This method stores the save state info in its packed form in the
instance data of this object.

RETURN VALUES
 
EMmsg - EMS_S_Success if all is well.

HISTORY

08-Dec-1987 jBk Put back Dave's fixes for OM_BLOCK_MOVE blocks of
                zero bytes.
04-Dec-1987 jBk If input ssi is NULL, return success immediately.
03-Nov-1987 DLB Changed struct name to EMSssi_table for version 1.1.0
31-Mar-1987 AIC Creation Date
*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSboolssi_table   *my_info;
  IGRushort         props = EMLP_SPLIT;
  IGRshort                  option = EMS_O_OFF;


  /*Initialize.*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

    if (NOT ssi)
    {
        return EMS_S_Success;
    }

  my_info = &ssi->bool_info;

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

  /*Add all loop ids added per surface.*/
  for(j = 0; j < my_info->num_surfaces; j ++)
    i += my_info->num_regions_in[j];

  /*Add all loop ids removed per surface.*/
  for(j = 0; j < my_info->num_surfaces; j ++)
    i += my_info->num_regions_out[j];

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
  }

  /*Add the loops in per surface.*/
  i += my_info->num_surfaces;
  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_in[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->region_in_ids[l];
    }
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

  /*Post the new info in the instance data.*/
  ME.EMSsfboolean->num_composites = my_info->num_composites;
  ME.EMSsfregmod->num_surfaces = my_info->num_surfaces;
   
  /*Dimension the in_out vla.*/
  sts = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                             size = my_info->num_composites + 
                                    my_info->num_surfaces * 2 +
                                    total_surfs_out);

  /*Put num surfs out per composite in vla.*/   
  for(i = 0; i < my_info->num_composites; i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_surfaces_out[i];

  /*Put num loops added per surface in vla.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_regions_in[j];    

  /*Put num loops removed per surface in vla.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_regions_out[j];    

  /*Put composite to surface indices in vla.*/
  for (j = 0; j < total_surfs_out; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->composite_indices[j];        

 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfboolean.EMputSSI")
  return(sts);
}
end implementation EMSsfboolean;
