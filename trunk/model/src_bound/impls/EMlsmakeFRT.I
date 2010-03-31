/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
from EMSloop import EMmakeFRT;

/*
   History
            ??    ??/??/??  Creation date
            RC    06/03/88  If the loopset is natural, return with
                            success as natural sf does not need a
                            FRT.
*/

method EMmakeFRT(IGRlong *EMmsg; GRobjid surf_id)
{
  IGRlong           sts;
  OM_S_CHANSELECT   to_loops;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  if (ME.EMSloopset->ls_props & EMLS_NATURAL) goto wrapup;
  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  /*
   * Send the message on to the loops
   */
  sts = om$send(msg = message EMSloop.EMmakeFRT(EMmsg, surf_id),
                p_chanselect = &to_loops);

wrapup:
  EMSmsgReport(sts, "EMSloopset.EMmakeFRT", FALSE);
  if EMSmsgReport(*EMmsg, "EMSloopset.EMmakeFRT", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSloopset;
