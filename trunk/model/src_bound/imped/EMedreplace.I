/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method replaces my_id by new edge in all references
	to me as far as channels are concerned.
	The new edge should NOT have ANY channel connections before
	sending this message.
	
History
	SM	21-Jan-89	Added to replace a function with same
				name. A message makes sense rather than
				function because each kind of edge knows
				exactly what kinds of channels it
				inherits. 
*/

class implementation EMSedge;

#include "EMS.h"

method	EMreplace_edge(IGRlong *EMmsg;
		       GRobjid new_edge;
		       IGRboolean delete_old_edge)
{
	IGRlong		sts;
	OM_S_CHANSELECT	to_owner, to_assoc, to_common_edge;

	sts = OM_S_SUCCESS;
	*EMmsg = EMS_S_Success;
	
/* Move owners to the new  edge
*/

	  sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
 
     	  sts = om$send(msg = message Root.move_chan(to_owner, my_id,
                           OM_Gw_current_OS, to_owner),
                     targetid = new_edge, senderid = new_edge);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Move common edge to the new edge
*/

     	  sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

     	  sts = om$send(msg = message Root.move_chan(to_common_edge, 
			   my_id, OM_Gw_current_OS, to_common_edge),
                     targetid = new_edge, senderid = my_id);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Move associations to the new edge
*/

	  sts = EMmake_chanselect (GRnotify_notification, &to_assoc);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

     	  sts = om$send(msg = message Root.move_chan(to_assoc, my_id,
                           OM_Gw_current_OS, to_assoc),
                     targetid = new_edge, senderid = my_id);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

	  if(delete_old_edge)
	   {
	     sts = om$send(msg = message Root.delete(NULL), 
			targetid = my_id, senderid = my_id);
	     EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	   }

wrapup:
	return(sts);
}

end implementation EMSedge;
