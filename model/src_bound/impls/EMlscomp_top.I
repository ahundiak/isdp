/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emsdef.h"

extern OMuword OPP_EMSloop_class_id;

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
 OM_S_CHANSELECT to_loops;

 /*If this loopset is not natural then continue*/ 
 if (! (ME.EMSloopset->ls_props & EMLS_NATURAL))
 {
   to_loops.type = OM_e_addr;
   to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

   OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(EMmsg, 
                           message EMSboundary.EMcompress_top(EMmsg,
                           partolbasis, newobjid), MAXINT, 1, 
                           &OPP_EMSloop_class_id, TRUE, NULL, NULL, NULL),
                     p_chanselect = &to_loops);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloopset.EMcompress_top")
  return (OM_stat);
}

end implementation EMSloopset;
