/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"

method EMconstruct_seg(IGRlong *EMmsg; struct EMSpartedinfo *partinfo;
                       struct EMSpartolbasis *partolbasis;  
                       GRobjid *new_objid)
/*
Description
Notes
History
    DLB 5/17/87 creation.
*/

{
 IGRlong OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_edge;
 
 
 *EMmsg = EMS_S_Success;

 to_edge.type = OM_e_addr;
 to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

 /*Pass on!!!*/
 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_edge);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "In EMSpartedge.EMconstruct_seg")
   return (OM_stat);
}
end implementation EMSpartedge;
