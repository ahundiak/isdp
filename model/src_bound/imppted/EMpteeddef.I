/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns point edge definition.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSptedge;

#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 *EMmsg = EMS_S_Success;
 EMPutGenEdInfo(edinfo);
 edinfo->edgetype = EMSpt;

wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSptedge;
