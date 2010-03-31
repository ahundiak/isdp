class implementation SKnormal;

#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = EMS_S_Success;
 ex$message ( buff = info->type, msgnumb = EMS_S_Perpendicular );
 return OM_S_SUCCESS;
}

end implementation SKnormal;

