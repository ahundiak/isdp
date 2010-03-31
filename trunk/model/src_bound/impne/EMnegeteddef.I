/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns natural edge definition.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSnatedge;

#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 *EMmsg = EMS_S_Success;

 EMPutGenEdInfo(edinfo);
 edinfo->edgetype = EMSnatural;
 edinfo->specinfo.natedge.location = (ME.EMSnatedge->location & 0x3);

wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSnatedge;
