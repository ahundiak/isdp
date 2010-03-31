/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsdef.h"

method EMcorrectOrient(IGRlong *EMmsg)
/*
Description
    This message will traverse up the tree correctly setting the orientation
    that was reset during a random access operation.

Return Values
    EMS_S_Success if all is well.

Notes
    This message comes into play during a random access tree operation (namely
    unevaluate and evaluate).

History
    DLB 02/04/90 Changed EMtoggleOrient sends to reflect the movement of this
                 msg up to EMSdpr.  Prior to this move, the send by this method
                 to anything other than a boolean class resulted in an unknown
                 msg and the invocation of the GRowner unknown msg handler.
    DLB 07/11/89 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_owners;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMtoggleOrient(EMmsg, NULL), 
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  OM_stat = om$send(msg = message EMSdpr.EMcorrectOrient(EMmsg),
                    p_chanselect = &to_owners);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMcorrectOrient")
    return(OM_stat);
}
end implementation EMSdpr;
