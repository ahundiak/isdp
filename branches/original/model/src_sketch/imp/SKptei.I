class implementation SKptonelmt;

#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
  *msg = MSSUCC;
  ex$message ( buff = info->type, msgnumb = EMS_S_PointOn );
  return OM_S_SUCCESS;
}

end implementation SKptonelmt;
