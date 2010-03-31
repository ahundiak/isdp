/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

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
  struct EMSmvssi_table     *my_info;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_info = &ssi->mv_info;

  stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, my_info->num_loops);
  if (! (1 & stat_OM)) goto wrapup;

  for (i=0; i<my_info->num_loops; i++)
   {
    ME.EMSdpr->ids[i] = my_info->loop_ids[i];
   }

wrapup:

  return(stat_OM);
}
end implementation EMSsfmove;
