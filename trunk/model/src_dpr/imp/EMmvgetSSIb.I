/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

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
  struct EMSmvssi_size  *my_size;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->mv_info;
  *ssi = NULL;

  /* Calculate the size of the buffer */

  num_bytes = sizeof(union EMSssi_table);
  num_bytes += my_size->num_loops * sizeof(GRobjid);

  /* Allocate the buffer */

  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);

  EMerr_hndlr (! (*ssi) , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  /* Partition the buffer */

  {
    GRobjid                     *objid_ptr;
    struct EMSmvssi_table       *my_info;
    union EMSssi_table          *ssi_ptr;

    /*
     * Set int_ptr just below the header.
     */
    ssi_ptr = *ssi;
    my_info = &ssi_ptr->mv_info;
    objid_ptr = (GRobjid *) (ssi_ptr + 1);

    /* Assign the objid pointers */

    my_info->loop_ids = objid_ptr;
  }

wrapup:

  return(stat_OM);
}
end implementation EMSsfmove;
