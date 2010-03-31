/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "emsmacros.h"

method EMgetSSIbuffer(IGRlong *EMmsg;
                      union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
/* History
 *
 *    gupta : 10/29/87  Creation date;
 */

{
  IGRlong               stat_OM;
  IGRint                num_bytes;
  struct EMSspssi_size  *my_size;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->spl_info;
  *ssi = NULL;

  /* Calculate the size of the buffer */

  num_bytes = sizeof(union EMSssi_table);
  num_bytes += (my_size->num_srf_owner + 
                my_size->num_srf +
                my_size->num_edges) * 
                sizeof(GRobjid) +
               (my_size->num_srf_owner *       /*********DLB ADDITION******/
                sizeof(IGRint));
                                               /***************************/
  /* Allocate the buffer */

  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);

  EMerr_hndlr (! (*ssi) , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  /* Partition the buffer */

  {
    IGRint                      *int_ptr;
    GRobjid                     *objid_ptr;
    struct EMSsspssi_table      *my_info;
    union EMSssi_table          *ssi_ptr;

    /*
     * Set int_ptr just below the header.
     */
    ssi_ptr = *ssi;
    my_info = &ssi_ptr->spl_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /*****************DLB ADDITION***********/
    /*
     * Assign the integer pointer.
     */

    my_info->owner_indices = int_ptr;
    int_ptr += my_size->num_srf_owner;
    /***************************************/

    /*
     * Assign the objid pointers.
     */

    objid_ptr = (GRobjid *) int_ptr;
    my_info->srf_owner_ids = objid_ptr;
    objid_ptr += my_size->num_srf_owner;
    my_info->srf_ids = objid_ptr;
    objid_ptr += my_size->num_srf;
    my_info->edge_ids = objid_ptr;
  }

wrapup:

  return(stat_OM);
}
end implementation EMSsfsplit;
