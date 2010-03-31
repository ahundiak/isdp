/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include <stdio.h>
# include "EMSmsgdef.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSbnddef.h"
# include "emsmacros.h"
# include "DPdlist.h"

/* New prototype */
PROTO_DPdlist_surface_drop_notify

from EMSloopset import EMdrop;
from EMSassoc import EMdrop_associativity;

method EMdrop(IGRlong *EMmsg; struct GRmd_env *env)
/*
Description

Return Values
     EMS_S_Success if all is well.

Notes 

History
  DLB 12/12/91 Issue EMdrop_assoc; add env parameter.
  DLB 06/01/91 Change the creator id to this surface in remaining topology.
  DLB 04/19/87 creation
*/
{
 IGRlong           OM_stat;
 OM_S_CHANSELECT   to_loopset;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 /*Send to my topology.  The loopset will determine if it should remain 
  * (its non-natural) or should be deleted.  If the loopset decides to
  * remain then it will pass this message on to its loops and loops to
  * edges.  The edges will delete the common edge connection BETWEEN
  * SURFACES ONLY.  
  */
 
 OM_stat = om$send(msg = message EMSloopset.EMdrop(EMmsg),
                   p_chanselect = &to_loopset);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, NULL,
                         my_id, NULL),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
 { /*INTENTIONAL*/
   GRobjid newobj;   

   OM_stat = om$send(msg = message EMSassoc.EMdrop_associativity(EMmsg, NULL,
                           env, &newobj),
                     targetid = my_id);
   if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
   else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 /* When you drop a surface, notify the display list */
 DPdlist_surface_drop_notify( my_id, OM_Gw_current_OS );

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsubbs.EMdrop")
  return (OM_stat);
}

end  implementation EMSsubbs;
