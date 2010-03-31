/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSIsize (IGRlong *EMmsg;
                     union EMSssiSizeData *size)
/* History
 *
 *    gupta : 10/29/87  Creation date;
 */

{
  struct EMSmvssi_size  *my_size;

  *EMmsg = EMS_S_Success;

  my_size = &size->mv_info;
  my_size->num_loops = OM_DIMENSION_OF(ME.EMSdpr->ids);

  return(OM_S_SUCCESS);
}

end implementation EMSsfmove;
