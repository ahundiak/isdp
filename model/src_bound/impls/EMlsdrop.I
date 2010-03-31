/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "emserr.h"

from EMSloop import EMdrop;

method EMdrop(IGRlong *EMmsg)
/*
Description

Return Values
     EMS_S_Success if all is well.

Notes 

History
  DLB 4/19/87   creation
  SM  06-Jan-89 Changed the criterion for deleting the loopset to
                natural loopset AND num loops = 1. This is because a natural
                loopset with feature loops is still considered natural. But
                we do not want to delete it.
  DLB 4/14/89   Removed code to delete loopset if natural and count == 1.  
                It is best just to leave it since FEM may be listening etc.   
*/
{
 IGRlong           OM_stat;
 OM_S_CHANSELECT   to_loops;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_loops.type = OM_e_addr;
 to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

 /*Send to all my loops to drop the common edges between surfs*/
 OM_stat = om$send(msg = message EMSloop.EMdrop(EMmsg),
                   p_chanselect = &to_loops);

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloopset.EMdrop")
  return (OM_stat);
}
end  implementation EMSloopset;
