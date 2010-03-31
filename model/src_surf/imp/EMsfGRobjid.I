/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
# include "EMSerrordef.h"

method EMgetGRobjid(IGRlong *EMmsg; GRobjid *objid)
{
  *objid = my_id;
  *EMmsg = EMS_S_Success;

  return(OM_S_SUCCESS);
}

end implementation EMSsurface;
