/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
method EMgetownerinfo(IGRlong *EMmsg; struct GRid *ownerid;
                      IGRint *ownerindex)
/*
Description
    This method get info from the split local mod for use by the add
    method.  The info extracted is the owner and index of the active state
    object that was removed by the split object.  This is a special case
    that the EMadd method must handle.
   
Return Values
    EMmsg - EMS_S_Success if all is well

History
   DLB   12/09/87 Creation
*/

{
 IGRlong                OM_stat;
 union EMSssi_table     *ssi;
 struct EMSsspssi_table *my_info;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 ssi = NULL;
 my_info = NULL;
    
 OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 my_info = &ssi->spl_info;
 
 ownerid->osnum = OM_Gw_current_OS;
 ownerid->objid = my_info->srf_owner_ids[0];

 *ownerindex = my_info->owner_indices[0];
   
 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfsplit.EMgetownerinfo")
  return(OM_stat);
}
end implementation EMSsfsplit;
