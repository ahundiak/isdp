/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "emserr.h"

method EMputSSI (IGRlong *EMmsg;
                 union EMSssi_table *ssi)
/*
History

    gupta    10/30/87    Creation Date
*/
{
  IGRlong                   stat_OM;
  IGRint                    i;
  struct EMSsspssi_table    *my_info;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_info = &ssi->spl_info;

  stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, my_info->num_srf_owner +
                                             my_info->num_srf +
                                             my_info->num_edges);
  if (! (1 & stat_OM)) goto wrapup;

  /**********************DLB ADDITION*******************/
  ME.EMSsfsplit->owner_index = my_info->owner_indices[0];
  /*****************************************************/

  ME.EMSdpr->ids[0] = my_info->srf_owner_ids[0];
  ME.EMSdpr->ids[1] = my_info->srf_ids[0];
  
  for (i=0; i<my_info->num_edges; i++)
   {
    ME.EMSdpr->ids[i+2] = my_info->edge_ids[i];
   }

wrapup:

  return(stat_OM);
}
end implementation EMSsfsplit;
