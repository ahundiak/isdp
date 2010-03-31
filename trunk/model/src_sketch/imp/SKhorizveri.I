class implementation SKhorizvert;
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = EMS_S_Success;

 if (ME.SKconstraint->props & SK_HORIZONTAL)
 {
   ex$message ( buff = info->type, msgnumb = EMS_S_Horizontal );
 }
 else
 {
   ex$message ( buff = info->type, msgnumb = EMS_S_Vertical );
 }

 return OM_S_SUCCESS;
}

end implementation SKhorizvert;

