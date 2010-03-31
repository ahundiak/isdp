/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

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
 OM_S_CHANSELECT to_owner, to_edge;


 *EMmsg = EMS_S_Success; 


 to_owner.type = OM_e_addr;
 to_owner.u_sel.addr = &ME.EMSedge->to_owner;

 OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
 if (! (1 & OM_stat)) goto wrapup;

 /*Connect me (at the end) to the input partedge*/
 OM_stat = om$send(msg = message Root.connect(to_edge, OM_K_MAXINT, 
                         my_id, OM_Gw_current_OS, to_owner, 0),
                   targetid = *connect_id);
 if (! (1 & OM_stat)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSnatedge.EMconnect_to_ne")
  return (OM_stat);
}

end implementation EMSnatedge;
