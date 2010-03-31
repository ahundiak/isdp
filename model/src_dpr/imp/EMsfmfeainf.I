class implementation EMSsfmacfea;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
#include "msmacros.h"

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslmacfea");
  return(OM_S_SUCCESS);
}

end implementation EMSsfmacfea;

