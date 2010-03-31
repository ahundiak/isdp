/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "emserr.h"

from EMSedge import EMdrop;

method EMdrop(IGRlong *EMmsg)
/*
Description

Return Values
     EMS_S_Success if all is well.

Notes 

History
  DLB 4/19/87 creation
*/
{
 IGRlong           OM_stat;
 OM_S_CHANSELECT   to_edges;
 OM_S_CHANSELECT   to_inner;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_edges.type = OM_e_addr;
 to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

 to_inner.type = OM_e_addr;
 to_inner.u_sel.addr = &ME.EMSloop->to_inner;

 /*Send to all my edges*/
 OM_stat = om$send(msg = message EMSedge.EMdrop(EMmsg),
                   p_chanselect = &to_edges);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Send to my inner loops*/
 OM_stat = om$send(msg = message EMSloop.EMdrop(EMmsg),
                   p_chanselect = &to_inner);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloop.EMdrop")
  return (OM_stat);
}

end  implementation EMSloop;
