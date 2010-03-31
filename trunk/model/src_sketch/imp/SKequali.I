class implementation SKequal;

#include "msdef.h"
#include "ECmsg.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = MSSUCC;
 ex$message ( buff = info->type, msgnumb = EMS_S_EqualDistance );
 return(OM_S_SUCCESS);
}

end implementation SKequal;

