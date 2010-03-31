class implementation EMSsfboolfea;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
#include "emserr.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslboolfea");
  return(OM_S_SUCCESS);
}

end implementation EMSsfboolfea;


