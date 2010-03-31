/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSIsize (IGRlong *EMmsg;
                     union EMSssiSizeData *size)
/* History
 *
 *    gupta : 10/29/87  Creation date;
 */

{
  IGRint                vla_count;
  struct EMSspssi_size  *my_size;

  *EMmsg = EMS_S_Success;

  my_size = &size->spl_info;
  my_size->num_srf_owner = 1;
  my_size->num_srf = 1;

  vla_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

  my_size->num_edges = (vla_count - 2);

  return(OM_S_SUCCESS);
}

end implementation EMSsfsplit;
