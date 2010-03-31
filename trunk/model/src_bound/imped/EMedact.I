/* ###################   APOGEE COMPILED   ################## */
/*
Abstract
	This message is for the use of the DPR node,  when it is made 
  active. The DPR state sends this message to each loop that it needs to
  activate. The loop makes itself active and passes the message to all its
  edges. The edge simply moves the loop to its last channel index.
	The need to do this channel manipulation from the edge side arises
  because during closing a loop, there is a point when an edge is owned by
  2 active loops. So a convention needs to be followed that the 'old'
  active loop will always be at the last index before the closing process
  is initiated.

History
	SM	05/21/87	Creation date.
	
*/
class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"

method EMactivate_loop(IGRlong *EMmsg; IGRint edge_index)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_edges, to_owner;


  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_owner.type = OM_e_addr;
  to_owner.u_sel.addr = &ME.EMSedge->to_owner;

  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

/* Move the sender id to my last index. My index from the sender's side
   remains the same (which is passed as input).
*/

  sts = om$send(msg = message Root.disconnect(to_edges, my_id, 
			OM_Gw_current_OS, to_owner), 
			targetid = sender_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$send(msg = message Root.connect(to_edges, MAXINT, my_id, 
			OM_Gw_current_OS, to_owner, edge_index), 
			targetid = sender_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMactivate_loop");
  return(sts);
}
end implementation EMSedge;
