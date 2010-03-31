/* ###################   APOGEE COMPILED   ################## */
class implementation EMSboundary;

#include "EMS.h"

method EMget_objid(IGRlong *EMmsg; GRobjid *my_objid)
{
  *EMmsg = EMS_S_Success;
  *my_objid = my_id;
  return(OM_S_SUCCESS);
}

end implementation EMSboundary;
