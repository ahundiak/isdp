/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMgetSSIbuffer(IGRlong              *EMmsg;
                      union EMSssiSizeData *size;
                      union EMSssi_table   **ssi)
{
  IGRlong               stat_OM;
  IGRint                num_bytes = 0;
  struct EMSrndssi_size *my_size;

/*---------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

my_size = &size->rnd_info;
*ssi = NULL;

num_bytes = sizeof(union EMSssi_table);

num_bytes += (my_size->num_surfaces * 2 + my_size->num_edges_out)
                                                * sizeof(IGRint);

num_bytes += (my_size->num_surfaces +
              my_size->num_regions_in +
              my_size->num_regions_out +
              my_size->num_edges_out +
              my_size->num_edges_in +
              my_size->num_edges_rounded) * sizeof(GRobjid);

/* Allocate the buffer */

*ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
EMerr_hndlr(!(*ssi), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

/* Partition the buffer */
{
 IGRint                    *int_ptr;
 GRobjid                   *objid_ptr;
 struct EMSrndssi_table    *my_info;
 union EMSssi_table        *ssi_ptr;

 /* Set int_ptr just below the header */

 ssi_ptr = *ssi;
 my_info = &ssi_ptr->rnd_info;
 int_ptr = (IGRint *) (ssi_ptr + 1);

 /* Assign the integer pointers */

 my_info->num_regions_in = int_ptr;
 int_ptr += my_size->num_surfaces;

 my_info->num_regions_out = int_ptr;
 int_ptr += my_size->num_surfaces;

 my_info->num_edges_in = int_ptr;
 int_ptr += my_size->num_edges_out;

 /* Assign the objid pointers */

 objid_ptr = (GRobjid *) int_ptr;

 my_info->surface_ids = objid_ptr;
 objid_ptr += my_size->num_surfaces;

 my_info->region_in_ids = objid_ptr;
 objid_ptr += my_size->num_regions_in;

 my_info->region_out_ids = objid_ptr;
 objid_ptr += my_size->num_regions_out;

 my_info->edge_out_ids = objid_ptr;
 objid_ptr += my_size->num_edges_out;

 my_info->edge_in_ids = objid_ptr;
 objid_ptr += my_size->num_edges_in;

 my_info->rounded_edge_ids = objid_ptr;
 objid_ptr += my_size->num_edges_rounded;
}

wrapup:

EMWRAPUP(*EMmsg,stat_OM,"In EMSsfround.EMgetSSIbuffer");
  return(stat_OM);
}

end implementation EMSsfround;
