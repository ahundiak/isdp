/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns bs edge definition.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSbsedge;

#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 struct EMSbsedgedef	*info;

 *EMmsg = EMS_S_Success;
 EMPutGenEdInfo(edinfo);
 edinfo->edgetype = EMSbs;
 info = (struct EMSbsedgedef *) &edinfo->specinfo.bsedge;
 info->order = ME.EMSbsedge->order;
 info->num_poles = ME.EMSbsedge->num_poles;
 info->bs_props = ME.EMSbsedge->bs_props;

wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSbsedge;
