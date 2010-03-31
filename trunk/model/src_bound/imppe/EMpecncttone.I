/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"

method EMconnect_to_ne(IGRlong *EMmsg; GRobjid *connect_id)
/*
Description

Return values
    
History
   DLB 4/23/87
*/
{
 IGRlong         OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_edge;


 *EMmsg = EMS_S_Success; 

 to_edge.type = OM_e_addr;
 to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_edge);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup; 

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSpartedge.EMconnect_to_ne")
  return (OM_stat);
}

end implementation EMSpartedge;
