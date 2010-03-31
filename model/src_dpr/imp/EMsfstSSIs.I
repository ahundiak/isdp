/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
{
 IGRlong		sts;
 struct EMSstchssi_size *my_size;
 IGRint			i, vla_size = 0;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 my_size = (struct EMSstchssi_size *) &size->stch_info;

 my_size->num_edges_out = ME.EMSsfstitch->num_edges_out;
 my_size->total_num_edges_in = 0;

 for(i=0; i<my_size->num_edges_out; i++)
  my_size->total_num_edges_in += ME.EMSsfstitch->num_edges_in[i];

 vla_size = om$dimension_of (varray = ME.EMSdpr->ids);
 my_size->num_edges_connected = vla_size - my_size->num_edges_out -
				my_size->total_num_edges_in;
				
 return(OM_S_SUCCESS);

}
end implementation EMSsfstitch;
