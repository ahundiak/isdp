/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfeditmgr;

#include "EMS.h"

method EMinit(IGRlong *EMmsg; GRobjid uneval_id;
              IGRushort options)
/*
Description
    This message initializes the unevaluation manager and adds the
    unevaluated id to its to_comps channel.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      uneval_id - the id of the node that has been unevaluated
      options - currently unused.

History
    DLB 12/19/88 Creation.
*/
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRlong     index=0;
  struct GRid my_GRid;

  *EMmsg = EMS_S_Success;

  ME.EMSsfeditmgr->first_freed = uneval_id;

  /*I am the active state now.*/
  ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);
  
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                          &my_GRid, &index),
                    targetid = uneval_id);
                      
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfeditmgr.EMinit")
  return(OM_stat);
}
end implementation EMSsfeditmgr;
