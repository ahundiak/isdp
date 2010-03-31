/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSopt.h" 
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "emserr.h"

from EMSloop import EMset_props;

extern OMuword OPP_EMSloop_class_id;

method EMtoglpactive(IGRlong *EMmsg)
/*
Description

Return Values
     EMS_S_Success if all is well.

Notes 

History
  DLB 5/19/87 creation.
*/
{
 IGRlong           OM_stat;
 OM_S_CHANSELECT   to_loops;
 IGRushort props = EMLP_ACTIVE;
 IGRshort option = EMS_O_TOGGLE;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_loops.type = OM_e_addr;
 to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

 /*Send to all my loops to toggle their active bits.*/

 OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(EMmsg, 
                         message EMSloop.EMset_props(EMmsg, props, 
                         option), MAXINT, 1, &OPP_EMSloop_class_id, TRUE,
                         NULL, NULL, NULL),
                   p_chanselect = &to_loops);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloopset.EMtoglpactive")
  return (OM_stat);
}

end  implementation EMSloopset;
