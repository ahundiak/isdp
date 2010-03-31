/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "emserr.h"

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
 OM_S_CHANSELECT   to_edge;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /*Involk the parents (edge) method to disconnect me*/
 OM_stat = om$send(mode = OM_e_wrt_message,
                   msg = message EMSedge.EMdrop(EMmsg),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 to_edge.type = OM_e_addr;
 to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

 /*Send to my edge*/
 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_edge);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSpartedge.EMdrop")
  return (OM_stat);
}

end  implementation EMSpartedge;
