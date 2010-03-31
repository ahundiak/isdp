/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSdpr.h"

method EMgetModRange(IGRlong *EMmsg; struct EMSinlist *inlist;
                     GRobjid nodes_side_id; struct GRmd_env *env)
/*
Description
    Simply return success.

History
    DLB    11/28/89   Creation
*/
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}
end implementation EMSdpr;
