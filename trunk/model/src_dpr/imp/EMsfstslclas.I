/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslstitch");
  return(OM_S_SUCCESS);
}
end implementation EMSsfstitch;
