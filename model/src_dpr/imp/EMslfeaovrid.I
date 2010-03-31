/*
 * History
 *     ???????    ?????   Creation
 *     Rustagi    2/1/94  Fix for TR 119416302
 */
class implementation EMSslfeature;

#include "msdef.h"
#include "msmacros.h"
#include "EMSasfeatdef.h"

/******************************************************************************/

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslfeature");
  return(OM_S_SUCCESS);
}

/******************************************************************************/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  IGRlong sts;

  sts  = OM_S_SUCCESS;
  *msg = EMS_S_Success;

   if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_RIB)
   {
     ex$message(msgname = "EMSslfeature1", buff = info->type);
   }
   else if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_ADD_MATERIAL)
   {
     ex$message(msgname = "EMSslfeature2", buff = info->type);
   }
   else if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
   {
     ex$message(msgname = "EMSslfeature3", buff = info->type);
   }
   else
   {
   /*** fix for TR # 119603402 - Sp.Balamurugan 12/12/96 **/
   ex$message(msgname = "EMSslfeature", buff = info->type);
   }
   return(OM_S_SUCCESS);
}

/******************************************************************************/

end implementation EMSslfeature;

