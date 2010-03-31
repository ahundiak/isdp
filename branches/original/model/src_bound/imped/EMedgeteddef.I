/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns edge definition common to all edges.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSedge;

#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 *EMmsg = EMS_S_Success;
 EMPutGenEdInfo(edinfo);
 return(OM_S_SUCCESS);
}

end implementation EMSedge;
