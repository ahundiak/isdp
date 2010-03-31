/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "OMmacros.h"


method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
{
 IGRlong			sts;
 struct EMSstchssi_table	*my_info;
 IGRint				i, total_edges_in, vla_size;
 union EMSssiSizeData		size_data;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 *ssi = NULL;

  sts = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  sts = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data, ssi),
                targetid = my_id); 
  if (!(1 & sts & *EMmsg)) goto wrapup;

 my_info = &( (*ssi)->stch_info);

 my_info->num_edges_out = ME.EMSsfstitch->num_edges_out;

 for(i=0; i<my_info->num_edges_out; i++)
  my_info->num_edges_in[i] = ME.EMSsfstitch->num_edges_in[i];

 total_edges_in = 0;
 for(i=0; i<my_info->num_edges_out; i++)
  total_edges_in += my_info->num_edges_in[i];

 vla_size = om$dimension_of (varray = ME.EMSdpr->ids);
 my_info->num_edges_connected = vla_size - my_info->num_edges_out -
				total_edges_in;
 
 /* put the ids */

 if(my_info->num_edges_out)
  OM_BLOCK_MOVE(ME.EMSdpr->ids, my_info->edges_out, 
	       my_info->num_edges_out * sizeof(GRobjid));
 if(total_edges_in)
  OM_BLOCK_MOVE(&ME.EMSdpr->ids[my_info->num_edges_out], my_info->edges_in,
	       total_edges_in * sizeof(GRobjid));
 if(my_info->num_edges_connected)
  OM_BLOCK_MOVE(&ME.EMSdpr->ids[my_info->num_edges_out + total_edges_in], 
	       my_info->edges_connected,
	       my_info->num_edges_connected * sizeof(GRobjid));
	
 
wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMgetSSI");
return(sts);
}
end implementation EMSsfstitch;
