/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This is the overridden implementation for the method declared at
  EMSedge. The method acts as a pass on like all other methods for
  EMSpartedge, sending down the proper boundary.
	If a NULL pointer is passed for the EMSpartedinfo, this object sends
  down its structure. Otherwise it simply passes on the structure it 
  received from the sender.

Assumption
	Every EMSpartedge object has a 'to_edge' connection. Going down
  this channel, one will ultimately hit the full edge where the action is.

History
        PP    12/02/87   Made changes for edge type
	SM    02/26/87   Creation date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMpt_location(IGRlong *EMmsg; IGRdouble *point;
		     struct EMSptloc_info *location;
		     struct EMSpartedinfo *part;
		     struct EMSpartolbasis *partolbasis)
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
	
	if(part)
	sts = om$send(msg=message EMSedge.EMpt_location
			(EMmsg,point,location,part,partolbasis),
			p_chanselect = &to_edge);
	else
	 {
	   struct EMSpartedinfo my_info;
           EMput_partinfo (my_info);
	   sts = om$send(msg=message EMSedge.EMpt_location
			(EMmsg,point,location,&my_info,partolbasis),
			p_chanselect = &to_edge);
	 }
wrapup:
	EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMpt_location")
	return(sts);
}

end implementation EMSpartedge;
