/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
#include "EMSmsgdef.h"

/*
 History
           AIC   ???      Creation Code
           RC    05/10/87  Added missing code and
                           fixed the bugs.
           RC    06/11/87  Made changes needed due to
                           change in EMSmfssi_table struct.
           RC    11/02/87  Modified for version 1.1.0
*/


method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
{
  IGRlong               OM_stat;
  IGRint                num_bytes = 0;
  struct EMSmfssi_size  *my_size;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->mf_info;
  *ssi = NULL;

  /*
   * Calculate the size of the buffer
   */

  num_bytes = sizeof(union EMSssi_table);

  num_bytes += (my_size->num_surfaces * 2 +
		my_size->num_regions + my_size->num_edges_out) 
		  * sizeof(IGRint);

  num_bytes += ( my_size->num_surfaces +
		 my_size->num_regions_in +
		 my_size->num_regions_out +
		 my_size->num_regions +
		 my_size->num_edges_in +
		 my_size->num_edges_out +
                 my_size->num_edges_copied * 2) * sizeof(GRobjid);

  /*
   * Allocate the buffer
   */
  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  EMerr_hndlr(!(*ssi), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  /*
   * Partition the buffer
   */
  {
    IGRint                   *int_ptr;
    GRobjid                  *objid_ptr;
    struct EMSmfssi_table    *my_info;
    union EMSssi_table       *ssi_ptr;

    /*
     * Set int_ptr just below the header.
     */
    ssi_ptr = *ssi;
    my_info = &ssi_ptr->mf_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /*
     * Assign the integer pointers.
     */
    my_info->num_regions_in = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_regions_out = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_edges_in = int_ptr;
    int_ptr += my_size->num_edges_out;

    my_info->num_edges_out = int_ptr;
    int_ptr += my_size->num_regions;

    /*
     * Assign the objid pointers.
     */

    objid_ptr = (GRobjid *) int_ptr;

    my_info->surface_ids = objid_ptr;
    objid_ptr += my_size->num_surfaces;

    my_info->region_in_ids = objid_ptr;
    objid_ptr += my_size->num_regions_in;

    my_info->region_out_ids = objid_ptr;
    objid_ptr += my_size->num_regions_out;

    my_info->region_ids = objid_ptr;
    objid_ptr += my_size->num_regions;

    my_info->edge_in_ids = objid_ptr;
    objid_ptr += my_size->num_edges_in;

    my_info->edge_out_ids = objid_ptr;
    objid_ptr += my_size->num_edges_out;

    my_info->ed_cp_ed_ids = objid_ptr;
  }

wrapup:
EMWRAPUP(*EMmsg,OM_stat,"In EMSsfmkface.EMgetSSIbuffer");
  return(OM_stat);
}

end implementation EMSsfmkface;
