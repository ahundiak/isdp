/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"

method EMgetprimsfromtree(IGRlong *EMmsg; IGRint *count; GRobjid **prims)
/*
Description
    See description header in EMsfgetprims.I

History
   DLB 09/16/88 Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_comps;

  
  *EMmsg = EMS_S_Success;                

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_comps);
   
  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "In EMSsfdpr.EMgetprimsfromtree")
    return(OM_stat);
}
end implementation EMSsfdpr;
