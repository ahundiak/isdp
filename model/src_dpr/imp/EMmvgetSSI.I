/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"

method EMgetSSI (IGRlong *EMmsg;
                 union EMSssi_table **ssi)
/*
History

    gupta    10/29/87    Creation Date
*/
{
  struct EMSmvssi_table     *my_info;
  union EMSssiSizeData      size_data;
  IGRlong                   stat_OM, msg;
  IGRint                    i;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *ssi = NULL;

  stat_OM = om$send(msg = message EMSdpr.EMgetSSIsize
                          (&msg, &size_data),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMmvgetSSI.EMgetSSIsize");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  stat_OM = om$send(msg = message EMSdpr.EMgetSSIbuffer
                          (&msg, &size_data, ssi),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMmvgetSSI.EMgetSSIbuffer");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  my_info = &((*ssi)->mv_info);

  my_info->num_loops = OM_DIMENSION_OF(ME.EMSdpr->ids);

  for (i = 0; i < my_info->num_loops; i++)
   {
    my_info->loop_ids[i] = ME.EMSdpr->ids[i];
   }

wrapup:

  return(stat_OM);
}
end implementation EMSsfmove;
