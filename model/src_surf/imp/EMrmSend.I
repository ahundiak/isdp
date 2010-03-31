/* ###################   APOGEE COMPILED   ################## */
class implementation Rootmsg;

/*
HISTORY:

Long Ago:  ??   Creation.
08/28/92:  NP   The "p_chanselect" parameter was mistakenly declared as a 
		"OM_S_CHANSELECT" instead of "OM_p_CHANSELECT".
09/13/96:  SCW  Removed references to OMprimindex.h


*/


#include "EMS.h"

method send_obj( int			type;
		  OM_E_WRT_FLAG		mode;
		  OM_p_MESSAGE		msg;
		  OM_S_OBJID		senderid;
		  OM_S_OBJID		targetid;
		  OMuword		targetos;
		  OM_p_CHANSELECT	p_chanselect;
		  int			from_ndx;
		  int			to_ndx;
	)

{
	switch(type) {
	case 1:
 		return( som_send_foreign
			((mode), (msg), (senderid),
			 (targetid), (targetos),(NULL_CHANNUM))
			);
		break;
	case 2:
        	return( som_send_object
			((mode), (msg), (senderid), 
			(targetid), (NULL_CHANNUM))
			);
		break;
	case 3:
		return( som_send_channel
			((mode), (msg), (targetos),
			(senderid), (p_chanselect),(from_ndx), (to_ndx))
			);
	break;
	}
}

end implementation Rootmsg;
