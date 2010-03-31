class implementation EMSsfcapsf;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)

/*

DESCRIPTION

    This method gets the stave state info structure from the instance
    data of this object and orders it logically. 

Return values 
    EMmsg - EMS_S_Success if all goes well.

HISTORY

   11/10/92  :  AMD  :  Creation

*/

{
  IGRlong                   sts;
  IGRint                    j;
  struct EMScapssi_table    *my_info;
  union EMSssiSizeData      size_data;

  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  sts = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  sts = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data,
                      ssi), 
                targetid = my_id); 
  if (!(1 & sts & *EMmsg)) goto wrapup;

  my_info = &((*ssi)->cap_info);

  my_info->num_edges = ME.EMSsfcapsf->num_edges;

  for(j = 0; j < my_info->num_edges; j ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[j]);
    if (sts == OM_S_SUCCESS)
      my_info->edges_connected[j] = ME.EMSdpr->ids[j];
    else
    {
      my_info->edges_connected[j] = NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfcapsf.EMgetSSI")
  return(sts);
}
end implementation EMSsfcapsf;
