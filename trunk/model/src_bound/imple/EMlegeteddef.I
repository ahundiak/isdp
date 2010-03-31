/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns linear edge definition.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSlinedge;

#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 *EMmsg = EMS_S_Success;
 EMPutGenEdInfo(edinfo);
 edinfo->edgetype = EMSlinear;
 edinfo->specinfo.linedge.num_points = ME.EMSlinedge->num_points;


wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSlinedge;
