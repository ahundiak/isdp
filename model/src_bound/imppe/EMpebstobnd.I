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

method EMbstobnd(IGRlong *EMmsg;IGRint num_param;
		IGRdouble  *bs_param;
		struct EMSedgebound *bnd_param)
{

	IGRlong			sts;
	OM_S_CHANSELECT		to_edge;

	*EMmsg=EMS_S_Success;
	sts = OM_S_SUCCESS;


	sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
	if(!(1&sts)) goto wrapup;
	
	  sts = om$send(msg=message EMSedge.EMbstobnd
			(EMmsg,num_param,bs_param,bnd_param),
			p_chanselect = &to_edge);
	
wrapup:
	EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMbstobnd")
	return(sts);
}

end implementation EMSpartedge;
