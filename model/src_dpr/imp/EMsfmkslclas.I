/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
/*
Description
    This method returns its corresponding solid class.

History 
    DLB 06/14/88 Creation.
*/

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslmkface");
  return(OM_S_SUCCESS);
}
end implementation EMSsfmkface;
