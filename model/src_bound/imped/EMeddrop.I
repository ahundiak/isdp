/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "DPdlist.h"

/* New Prototypes */
PROTO_DPdlist_get_partial_drop_mode
PROTO_DPdlist_surface_drop_notify

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
 OM_S_CHANSELECT   to_common_edge;
 GRobjid           surf_id;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_common_edge.type = OM_e_addr;
 to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;


 /*If not a seam edge then disconnect the common edge*/
 if (! (ME.EMSedge->ed_props & EMED_SEAM))
 {
   IGRushort props;

   /*Turn off my bits related to common edge.*/
   ME.EMSedge->ed_props &= ~(EMED_SUBORDINATE | EMED_REVERSE_CONNECT);

   /*Turn off my common edges bits.*/
   props = EMED_SUBORDINATE | EMED_REVERSE_CONNECT;
   OM_stat = om$send(msg = message EMSedge.EMset_props(EMmsg, props,
                           EMS_O_OFF), 
                     p_chanselect = &to_common_edge);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &surf_id,
                           NULL ),
                     p_chanselect = &to_common_edge);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   if ( DPdlist_get_partial_drop_mode() )
   {
      DPdlist_surface_drop_notify( surf_id, OM_Gw_current_OS );
   }

   OM_stat = om$send(msg = message Root.wild_disconnect(to_common_edge),
                     targetid = my_id);
   if (! (1 & OM_stat)) goto wrapup;
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSedge.EMdrop")
  return (OM_stat);
}

end  implementation EMSedge;
