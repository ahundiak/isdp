/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "OMmacros.h"


method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
{
 IGRlong			sts;
 struct EMSstchssi_table	*my_info;
 IGRint				i, total_objids = 0, total_edges_in = 0;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 my_info = &ssi->stch_info;

 ME.EMSsfstitch->num_edges_out = my_info->num_edges_out;
 if(my_info->num_edges_out)
  {
   sts = om$vla_set_dimension(varray = ME.EMSsfstitch->num_edges_in, 
			size = my_info->num_edges_out);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }

 for(i=0; i<my_info->num_edges_out; i++)
  ME.EMSsfstitch->num_edges_in[i] = my_info->num_edges_in[i];

		
 /* Store the ids */

 total_edges_in = 0;
 for(i=0; i<my_info->num_edges_out; i++)
  total_edges_in += my_info->num_edges_in[i];

 total_objids = my_info->num_edges_out + total_edges_in + 
		my_info->num_edges_connected;

 sts = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                             size = total_objids);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 if(my_info->num_edges_out) 
  OM_BLOCK_MOVE(my_info->edges_out, ME.EMSdpr->ids, 
	       my_info->num_edges_out * sizeof(GRobjid));
 if(total_edges_in)
  OM_BLOCK_MOVE(my_info->edges_in, &ME.EMSdpr->ids[my_info->num_edges_out], 
	       total_edges_in * sizeof(GRobjid));
 if(my_info->num_edges_connected)
  OM_BLOCK_MOVE(my_info->edges_connected, 
	       &ME.EMSdpr->ids[my_info->num_edges_out + total_edges_in], 
	       my_info->num_edges_connected * sizeof(GRobjid));
	
wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMputSSI");
return(sts);
}
end implementation EMSsfstitch;
