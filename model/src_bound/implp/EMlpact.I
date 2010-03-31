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
class implementation EMSloop;

#include "EMS.h"
from EMSedge import EMactivate_loop;

method EMactivate_loop(IGRlong *EMmsg)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_edges;
  IGRint		i;
  OMuint                count;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  ME.EMSloop->lp_props |= EMLP_ACTIVE;

  sts = om$get_channel_count(object = me, p_chanselect = &to_edges, 
			     count = &count);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

/* Send the message down to all the edges. The edge index is sent down
   because from the loop side the edge indices should not change to ensure
   that all edges get this message. If the edge index is sent down, the
   edge does not have to determine the index again, and thus saves some
   processing.
*/
  for(i=0;i<count;i++)
   {
      sts = om$send(msg = message EMSedge.EMactivate_loop(EMmsg, i), 
			p_chanselect=&to_edges, from=i, to=i);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
   }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMactivate_loop");
  return(sts);
}
end implementation EMSloop;
