class implementation SKground;

#include "SKinc.h"
#include "SKdef.h"
#include "msdef.h"
#include "ECmsg.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = MSSUCC;
 ex$message ( buff = info->type, msgnumb = EMS_S_GroundConstraint );
 return OM_S_SUCCESS;
}

end implementation SKground;

