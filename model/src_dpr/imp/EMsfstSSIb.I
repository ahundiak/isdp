/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"

method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
{
 IGRlong			sts;
 struct EMSstchssi_size		*my_size;
 IGRint				num_bytes;
 IGRint      			*int_ptr;
 GRobjid                	*objid_ptr;
 struct EMSstchssi_table	*my_info;
 union EMSssi_table     	*ssi_ptr;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_size = &size->stch_info;
 *ssi = NULL;
 num_bytes = sizeof(union EMSssi_table);   /*Space for pointers etc.*/

 /* Space for num_edges_in per edge out.
  */
 num_bytes += my_size->num_edges_out * sizeof(IGRint);

 /* space for edges out.
 */
 num_bytes += my_size->num_edges_out * sizeof(GRobjid);

 /* Space for edges in.
 */
 num_bytes += my_size->total_num_edges_in * sizeof(GRobjid);

 /* Space for edges connected.
 */
 num_bytes += my_size->num_edges_connected * sizeof(GRobjid);

 /* Allocate the buffer*/

 *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
 if(! (*ssi)){*EMmsg = EMS_E_NoDynamicMemory;  goto wrapup;}

	
 /* Partition the buffer -
 */
 ssi_ptr = *ssi;

 my_info = &ssi_ptr->stch_info;
 objid_ptr = (GRobjid *) (ssi_ptr + 1);

 /* Assign the GRobjid pointers */

 if(my_size->num_edges_out)
  {
   my_info->edges_out = (GRobjid *) objid_ptr;
   objid_ptr += my_size->num_edges_out;
  }
 else my_info->edges_out = NULL;

 if(my_size->total_num_edges_in)
  {
   my_info->edges_in = (GRobjid *) objid_ptr;
   objid_ptr += my_size->total_num_edges_in;
  }
 else my_info->edges_in = NULL;

 if(my_size->num_edges_connected)
  {
   my_info->edges_connected = (GRobjid *) objid_ptr;
   objid_ptr += my_size->num_edges_connected;
  }
 else my_info->edges_connected = NULL;
 
 /* Assign the int pointer
 */
 int_ptr = (IGRint *) objid_ptr;
 if(my_size->num_edges_out)
  {
   my_info->num_edges_in = (IGRint *) int_ptr;
   int_ptr += my_size->num_edges_out;
  }
 else my_info->num_edges_in = NULL;

 my_info->num_edges_out = 0;
 my_info->num_edges_connected = 0;

wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMgetSSIbuffer")
return(sts);

}
end implementation EMSsfstitch;
