/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
method EMcompress_top(IGRlong *EMmsg;
                      struct EMSpartolbasis *partolbasis;
                      GRobjid *newobjid)
/*
Description

Return values
    
History
  DLB 4/22/87
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_edges;


 *EMmsg = EMS_S_Success;

 /*If this loop is not natural then compress the edges*/
 if (! (ME.EMSloop->lp_props & EMLP_NATURAL))
 {
   to_edges.type = OM_e_addr;
   to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

   OM_stat = om$send(msg = OPPmargs,
                     p_chanselect = &to_edges);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloop.EMcompress_top")
  return (OM_stat);
}

end implementation EMSloop;
