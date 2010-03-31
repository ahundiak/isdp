class implementation EMSsfaddraft;

#include "EMS.h"
/*
Description
    This method returns its corresponding solid class.

History 
    Nirmal 02/14/93 Creation.
*/

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSsladdraft");
  return(OM_S_SUCCESS);
}
end implementation EMSsfaddraft;
