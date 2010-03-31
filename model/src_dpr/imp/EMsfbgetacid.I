/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSerrordef.h"

method EMgetactiveid(IGRlong *EMmsg; 
                     struct GRid *active_id, *top_lm_id)
/*
Description
   This method determine if this state is active and if so will put its id 
   in the list otherwise it will send on up.

Return Values
   EMSS_S_Success if all is well

History
   DLB 11/27/90 If im not in the active path return NULL_OBJIDS.
   DLB 10/31/87 Creation.
*/

{
  IGRlong OM_stat = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;                  /* initialize messages      */


  if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE)
  {
   /*I am the active state*/
   active_id->objid = my_id;
   active_id->osnum = OM_Gw_current_OS;
  }  
  else if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
  {
    /*Send on up to whoever.  There may not be any objects subclassed from
     * EMScomposite in which case an unknown msg warning will be returned.
     */
    OM_S_CHANSELECT to_owners;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,active_id,
                            top_lm_id ), 
                      p_chanselect = &to_owners);
    if(!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    OM_stat = OM_S_SUCCESS;
  }                    
  else
  {
    /*NOT IN ACTIVE PATH!!*/
    active_id->objid = NULL_OBJID;
    active_id->osnum = OM_Gw_current_OS;
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sfb.getacid")
  return(OM_stat);
}
end implementation EMSsfboolean;

