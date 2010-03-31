/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
/*
Description
    This method stores the save state info in its packed form in
    the instance data of this object.

Return values 
    EMmsg - EMS_S_Success if all is well.

History
    SM	   11-Feb-88   modified to take care of edges modified.
    DLB    11/02/87    Changed struct name to EMSssi_table for vers. 1.1.0
    AIC    03/31/87    Creation Date
*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l;
  struct EMSsfssi_table     *my_info;
  IGRushort         props = EMLP_SPLIT;    
  IGRshort                  option = EMS_O_OFF;


  /*Initialize.*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_info = &ssi->sf_info;

  /*Compute the size needed for the vla and apply it.*/

  /*All modified surface ids will be on vla.*/
  i = my_info->num_surfaces;

  /*Add loop ids added per surface.*/
  for(j = 0; j < my_info->num_surfaces; j ++)
    i += my_info->num_regions_in[j];

  /*Add loop ids removed per surface.*/
  for(j = 0; j < my_info->num_surfaces; j ++)
    i += my_info->num_regions_out[j];

  /* Add total number of regions and the number of edges out */
  i+= my_info->num_regions;
  i+= my_info->cum_num_edges_out;

  /* Add num_edges in for each edge out */
  for(j=0; j<my_info->cum_num_edges_out; j++)
   i+= my_info->num_edges_in[j];

  i+= my_info->num_edges_copied * 2;

  /*Expand the vla for SSI.*/
  sts = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                             size = i);
  if (!(1 & sts)) goto wrapup;
  
  /*Put surfaces modified on vla.*/
  if (my_info->num_surfaces)
  {
    OM_BLOCK_MOVE(my_info->surface_ids,
                  ME.EMSdpr->ids,
                  my_info->num_surfaces * sizeof(GRobjid));
  }

  /*Add the region_in ids.*/
  i = my_info->num_surfaces;
  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_in[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->region_in_ids[l];
    }
  }

  /*Add the region_out objects.*/
  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_out[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->region_out_ids[l];

      /*Turn off split bit for each loop*/
      sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                          option),
                    targetid = my_info->region_out_ids[l]);
      if (! (1 & sts & *EMmsg)) goto wrapup;
    }
  }


  /*
   * Save the regions
   */

  for(j = 0; j < my_info->num_regions; j++, i++)
    ME.EMSdpr->ids[i] = my_info->region_ids[j];

  /*
   * Save the edge_in objects
   */

  l = 0;
  for(j = 0; j < my_info->cum_num_edges_out; j ++)
    for(k = 0; k < my_info->num_edges_in[j]; k ++, i ++, l ++)
      ME.EMSdpr->ids[i] = my_info->edge_in_ids[l];

  /*
   * Save the edge_out objects
   */
  
  l = 0;
  for(j = 0; j < my_info->num_regions; j ++)
    for(k = 0; k < my_info->num_edges_out[j]; k ++, i ++, l ++)
      ME.EMSdpr->ids[i] = my_info->edge_out_ids[l];
   

  /* Save the ed_cp_ids.
  */
  for (j = 0; j < 2 * my_info->num_edges_copied; j++, i++)
    ME.EMSdpr->ids[i] = my_info->ed_cp_ed_ids[j];

  /*Post the total num surfaces mod in the instance data.*/
  ME.EMSsfregmod->num_surfaces = my_info->num_surfaces;
   
  /*In_out vla is list of number of loops in and out per surface.*/
  sts = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                             size = 2 * my_info->num_surfaces +
				    2 +
				    my_info->num_regions +
				    my_info->cum_num_edges_out +
				    1);

  /*Fill the vla.*/
  /*Put number of loops in on vla first.*/
  for (i = 0; i < my_info->num_surfaces; i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_regions_in[i];

  /*Add number of loops removed to vla.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    ME.EMSsfregmod->in_out[i] = my_info->num_regions_out[j];

  ME.EMSsfregmod->in_out[i++] = my_info->num_regions;
  ME.EMSsfregmod->in_out[i++] = my_info->cum_num_edges_out;

  for (j = 0; j < my_info->cum_num_edges_out; i++, j++)   
     ME.EMSsfregmod->in_out[i] = my_info->num_edges_in[j];     

  for (j = 0; j < my_info->num_regions; j++, i++)   
     ME.EMSsfregmod->in_out[i] = my_info->num_edges_out[j];     

  ME.EMSsfregmod->in_out[i] = my_info->num_edges_copied;

 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfregmod.EMputSSI")
  return(sts);
}
end implementation EMSsfregmod;
