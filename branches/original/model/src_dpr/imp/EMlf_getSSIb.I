/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "EMSmsgdef.h"

/*
Histroy
            RC        11/01/87       Creation Date
            RC        03/14/88       Rewrote for 1.2.0
            RC        05/24/88       Added code for single sf lift.
*/


method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
{
  IGRlong                   OM_stat;
  IGRint                    num_bytes = 0;
  struct EMSlftssi_size  *my_size;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->lft_info;
  *ssi = NULL;

  /*
   * Calculate the size of the buffer
   */

  num_bytes = sizeof(union EMSssi_table);
 
  num_bytes += ( my_size->num_composites +
                 my_size->num_surfaces_out +
                 (my_size->num_sf_affected) * 2 + 
                 my_size->num_eds_rplcd ) 
                 * sizeof(IGRint);

  num_bytes += ( my_size->num_composites +
                 my_size->num_surfaces_out +
                 my_size->num_sf_lifted +
                 my_size->num_sf_affected +
                 my_size->num_regions_in +
                 my_size->num_regions_out +
                 my_size->num_eds_rplcd +
                 my_size->num_eds_in +
                 (my_size->num_eds_wcm_md) * 4 +
                 (my_size->num_ed_wmv_cm)  * 2  +
                 (my_size->num_eds_wcm_eds) * 2 )
                 * sizeof(GRobjid);

  /*
   * Allocate the buffer
   */

  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  EMerr_hndlr(!(*ssi), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  /*
   * Partition the buffer
   */

  {
    IGRint                       *int_ptr;
    GRobjid                      *objid_ptr;
    struct EMSlftssi_table    *my_info;
    union EMSssi_table           *ssi_ptr;

    /*
     * Set int_ptr just below the header.
     */

    ssi_ptr = *ssi;
    my_info = &ssi_ptr->lft_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /*
     * Assign the integer pointers.
     */

    my_info->num_surfaces_out = int_ptr;
    int_ptr += my_size->num_composites;

    my_info->composite_indices = int_ptr;
    int_ptr += my_size->num_surfaces_out;

    my_info->num_regions_in = int_ptr;
    int_ptr += my_size->num_sf_affected;

    my_info->num_regions_out = int_ptr;
    int_ptr += my_size->num_sf_affected;

    my_info->num_eds_in = int_ptr;
    int_ptr += my_size->num_eds_rplcd;

    /*
     * Assign the objid pointers.
     */

    objid_ptr = (GRobjid *) int_ptr;

    my_info->composite_ids = objid_ptr;
    objid_ptr += my_size->num_composites;

    my_info->surface_out_ids = objid_ptr;
    objid_ptr += my_size->num_surfaces_out;

    my_info->sf_lifted_ids = objid_ptr;
    objid_ptr += my_size->num_sf_lifted;

    my_info->sf_affctd_ids = objid_ptr;
    objid_ptr += my_size->num_sf_affected;

    my_info->region_in_ids = objid_ptr;
    objid_ptr += my_size->num_regions_in;

    my_info->region_out_ids = objid_ptr;
    objid_ptr += my_size->num_regions_out;

    my_info->ed_rplcd_ids = objid_ptr;
    objid_ptr += my_size->num_eds_rplcd;

    my_info->ed_in_ids = objid_ptr;
    objid_ptr += my_size->num_eds_in;

    my_info->ed_mcm_ed_ids = objid_ptr;
    objid_ptr += (my_size->num_eds_wcm_md) * 4;

    my_info->ed_ced_ids = objid_ptr;
    objid_ptr += (my_size->num_ed_wmv_cm) * 2;

    my_info->ed_cm_ed_ids = objid_ptr;

  }

wrapup:
EMWRAPUP(*EMmsg,OM_stat, "In EMSlift.EMgetSSIbuffer");
  return(OM_stat);
}

end implementation EMSlift;
