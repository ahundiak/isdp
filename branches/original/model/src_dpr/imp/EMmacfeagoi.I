/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmacfea;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "EMSasfeatdef.h"

/*
Uses class name and appends operation type to it. Uses the resulting string
as the message name to search the message file.
*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar myclassname[OM_K_MAXCLASS_LEN];
 IGRlong sts = OM_S_SUCCESS;
 *msg = MSSUCC;

 if(ME.EMSassoc->type == EMS_I_AM_A_MACFEA_POCKET)
   ex$message(msgname = "EMSsfmacfea2", buff = info->type)
 else if(ME.EMSassoc->type == EMS_I_AM_A_MACFEA_BOSS)
   ex$message(msgname = "EMSsfmacfea1", buff = info->type)
 else 
   {
   sts = om$send(mode = OM_e_wrt_message,
                 msg = message EMSsurface.GRgetobjinfo(msg,info),
                 targetid= my_id);
   }

ret_end:
 return(sts);
}
end implementation EMSsfmacfea;
