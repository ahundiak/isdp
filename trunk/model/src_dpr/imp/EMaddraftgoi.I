class implementation EMSsfaddraft;

#include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "EMSasfeatdef.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grmacros.h"
#include "exmacros.h"
#include <alloca.h>

extern unsigned char EMS_locate_features;

/*
Uses class name and appends operation type to it. Uses the resulting string
as the message name to search the message file.
*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRlong stat_OM = OM_S_SUCCESS;
 *msg = MSSUCC;

    if (ME.EMSassoc->type >= REPLACE_SURFACE)
     {
       ex$message(msgname = "EMSsfaddraft1", buff = info->type) 
     }
     else       
     {
       ex$message(msgname = "EMSsfaddraft", buff = info->type) 
     }

wrapup:
  EMWRAPUP(*msg, stat_OM, "EMSaddraft GRgetobjinfo")
  return(stat_OM);
}
end implementation EMSsfaddraft;
