/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This is the overridden implementation for the method declared at
  EMSedge. The method acts as a pass on like all other methods for
  EMSpartedge, sending down the proper boundary.
	If a NULL pointer is passed for the boundary, this object sends
  down its boundary. Otherwise it simply passes on the boundary it 
  received from the sender.

Assumption
	Every EMSpartedge object has a 'to_edge' connection. Going down
  this channel, one will ultimately hit the full edge where the beef is.

History
        PP    12/03/87   Made changes for edge type
	SM    02/26/87   Creation date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMgetrange(IGRlong *EMmsg; IGRdouble *range;
		  struct EMSpartedinfo *bnd)
{

	IGRlong			sts;
	OM_S_CHANSELECT		to_edge;

	*EMmsg=EMS_S_Success;
	sts = OM_S_SUCCESS;

/* If a NULL pointer was passed for bnd, it means I have to send down my
   geometry. If the pointer is non NULL then it means that somebody up
   there is trying hard to reach its geometry and I need to help by acting
   as a passon.
*/


	sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
	if(!(1&sts)) goto wrapup;
	
	if(bnd)
	  sts = om$send(msg=message EMSedge.EMgetrange
			(EMmsg,range,bnd),
			p_chanselect = &to_edge);
	else	
	 {
	   struct EMSpartedinfo my_info;

           EMput_partinfo (my_info);

	  sts = om$send(msg=message EMSedge.EMgetrange
			(EMmsg,range,&my_info),
			p_chanselect = &to_edge);
	 }
	
wrapup:
	EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMgetrange")
	return(sts);
}

end implementation EMSpartedge;
