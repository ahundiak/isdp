class implementation EMSsfmkface;

#include "EMS.h"
#include <stdio.h>
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSopt.h"

from EMSloop	import EMset_props;
from EMSloop    import EMactivate_loop;

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
/*
History

    AIC    03/31/87    Creation Date
    RC     06/11/87    Modified due to changes in EMSsfmkface instance
			data and in EMSmfssi_table
    RC     11/02/87    Modified for version 1.1.0
*/

{
  IGRlong                   OM_stat;
  IGRlong   		    mthd_stat;
  IGRint                    i, j, k, l;
  IGRuint           	    vla_size, ids_vla_size;
  struct EMSmfssi_table     *my_info;
  OM_S_CHANSELECT	    to_edges;
  OM_S_OBJECT_LINKAGE	    *actlps = NULL;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_info = &ssi->mf_info;

  /*
   * Post the new info in the instance data.
   */

   ME.EMSsfregmod->num_surfaces = my_info->num_surfaces;
   
   vla_size = 2 * my_info->num_surfaces +  my_info->num_regions +
		my_info->cum_num_edges_out;

   OM_stat = om$vla_set_dimension(varray = ME.EMSsfregmod->in_out,
                                size = vla_size);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   ids_vla_size = my_info->num_surfaces;

   for (i = 0; i < my_info->num_surfaces; i++)   
   {
     ME.EMSsfregmod->in_out[i] = my_info->num_regions_in[i];
     ids_vla_size += my_info->num_regions_in[i];
   }

   for (j = 0; j < my_info->num_surfaces; j++, i++)   
   {
     ME.EMSsfregmod->in_out[i] = my_info->num_regions_out[j];     
     ids_vla_size += my_info->num_regions_out[j];
   }

   ME.EMSsfmkface->num_regions = my_info->num_regions;
   ids_vla_size += my_info->num_regions;
   ME.EMSsfmkface->num_edges_out = my_info->cum_num_edges_out;
   ids_vla_size += my_info->cum_num_edges_out;
   
   for (j = 0; j < my_info->cum_num_edges_out; i++, j++)   
   {
     ME.EMSsfregmod->in_out[i] = my_info->num_edges_in[j];     
     ids_vla_size += my_info->num_edges_in[j];
   }

   for (j = 0; j < my_info->num_regions; j++, i++)   
     ME.EMSsfregmod->in_out[i] = my_info->num_edges_out[j];     

   ME.EMSsfmkface->num_edges_copied = my_info->num_edges_copied;
   ids_vla_size += my_info->num_edges_copied * 2;
  
  /*
   * Set the EMSdpr.ids[] vla
   */

  OM_stat = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                                 size = ids_vla_size);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

  /*
   * Save the surfaces
   */

  for(i = 0; i < my_info->num_surfaces; i ++)
    ME.EMSdpr->ids[i] = my_info->surface_ids[i];

  /*
   * Save the region_in objects
   */
  /* The activate loop message was being sent indiscriminately to all loops
     added by this node. If one of these loops is later taken out by some
     other operation, activating it here is incorrect. Added a check to
     activate a loop only if none of its edges are currently owned by some
     other active loop. This possibility exists only if there is a owner.
     SM 4/27/93
  */
  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_in[j]; k ++, i ++, l ++)
    {
      IGRboolean activate = TRUE;

      ME.EMSdpr->ids[i] = my_info->region_in_ids[l];
       {
	GRobjid thislp, thised;
	GRspacenum thisedos;
        OMuint num_edges = 0;
        IGRint idx, num_actlps = 0, inx;

	thislp = my_info->region_in_ids[l];
	
        OM_stat = om$get_channel_count(objid = thislp, 
                  p_chanselect = &to_edges, count = &num_edges);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        for(idx = 0; idx<num_edges; idx++)
         {
	  OM_stat = om$get_objid_at_index(objid = thislp, 
	            p_chanselect = &to_edges, index = idx, objidaddr = &thised,
	            osnumaddr = &thisedos);
          EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

          /* How many active loops own this edge?
          */
          if(actlps) om$dealloc(ptr = actlps);
          actlps = NULL;
          num_actlps = 0;

          OM_stat = EMcount_loops(&mthd_stat, thised, &num_actlps, &actlps, 
                    EMLP_ACTIVE, NULL, NULL);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

          for(inx = 0; inx<num_actlps; inx++)
           if(!IF_EQ_OBJID(thislp, actlps[inx].S_objid))
            {
	     activate = FALSE;
	     break;
            }
          if(!activate) break;

         } /* for(idx = 0; idx<num_edges; idx++) */

       } 

      if(activate)
       {
        OM_stat = om$send (msg = message EMSloop.EMactivate_loop( 
                          &mthd_stat),
                         targetid = my_info->region_in_ids[l]);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
       }
    }
  }

  /*
   * Save the region_out objects
   */

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_out[j]; k ++, i ++, l ++)
    {
      ME.EMSdpr->ids[i] = my_info->region_out_ids[l];

      {
	IGRshort option = EMS_O_OFF;
	IGRushort props = EMLP_ACTIVE;
	OM_stat = om$send (msg = message EMSloop.EMset_props(
				&mthd_stat, props, option),
			targetid = my_info->region_out_ids[l]);
	EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
      }

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
   
  /*
   * Save edges copied
   */

  for (j = 0; j < 2 * my_info->num_edges_copied; j++, i++)
    ME.EMSdpr->ids[i] = my_info->ed_cp_ed_ids[j];


wrapup:
  if(actlps) om$dealloc(ptr = actlps);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfmakeface.EMputSSI")
  return(OM_stat);

}

end implementation EMSsfmkface;
