/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This is the overridden implementation for the method declared at
  EMSedge. The method acts as a pass on like all other methods for
  EMSpartedge.

Assumption
	Every EMSpartedge object has a 'to_edge' connection. Going down
  this channel, one will ultimately hit the full edge where the beef is.

History
	SM    02/26/87   Creation date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"

method EMptatpr(IGRlong *EMmsg; IGRint num_param;
		struct EMSedgebound *param;
		IGRdouble *bs_param;IGRdouble *point)
{

	IGRlong			sts;
	OM_S_CHANSELECT		to_edge;

	*EMmsg=EMS_S_Success;
	sts = OM_S_SUCCESS;


	sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
	if(!(1&sts)) goto wrapup;
	
	  sts = om$send(msg=message EMSedge.EMptatpr
			(EMmsg,num_param,param,bs_param,point),
			p_chanselect = &to_edge);
	
wrapup:
	EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMptatpr")
	return(sts);
}

end implementation EMSpartedge;
