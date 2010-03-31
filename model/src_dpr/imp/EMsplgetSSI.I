/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

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
  struct EMSsspssi_table    *my_info;
  union EMSssiSizeData      size_data;
  IGRlong                   stat_OM, msg;
  IGRint                    i, vla_count;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *ssi = NULL;

  stat_OM = om$send(msg = message EMSdpr.EMgetSSIsize
                          (&msg, &size_data),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMsplgetSSI.EMgetSSIsize");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  stat_OM = om$send(msg = message EMSdpr.EMgetSSIbuffer
                          (&msg, &size_data, ssi),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMsplgetSSI.EMgetSSIbuffer");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  my_info = &((*ssi)->spl_info);

  my_info->num_srf_owner = 1;
  for (i=0; i<my_info->num_srf_owner; i++)
   {  
    my_info->srf_owner_ids[i] = ME.EMSdpr->ids[0];
    /******************DLB ADDITION***********************/
    my_info->owner_indices[i] = ME.EMSsfsplit->owner_index;
    /*****************************************************/
   }

  my_info->num_srf = 1;
  for (i=0; i<my_info->num_srf; i++)
   {
    my_info->srf_ids[i] = ME.EMSdpr->ids[1];
   }

  vla_count = OM_DIMENSION_OF(ME.EMSdpr->ids);
  my_info->num_edges = (vla_count - 2);

  for (i = 0; i < my_info->num_edges; i++)
   {
    my_info->edge_ids[i] = ME.EMSdpr->ids[i+2];
   }

wrapup:

  return(stat_OM);
}

end implementation EMSsfsplit;
