/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"


method EMsend_dummy_edge(IGRlong *EMmsg;
			 GRobjid sender_obj;
			 OM_p_MESSAGE messg;
			 IGRboolean *dummy_edge_found)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_comps;


  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;


  /* Send the message down to the edge I own. This is the route to the
     dummy edge if there is one.
  */
    sts = om$send(msg = message EMSedge.EMsend_dummy_edge
			(EMmsg, sender_obj, messg, dummy_edge_found), 
				p_chanselect = &to_comps);
				
wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMSpartedge.EMsend_dummy_edge");
	return(sts);
}

end implementation EMSpartedge;
