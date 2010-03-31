/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns part edge definition.
History
	23-Mar-89	SM	Creation.
        09-Feb-95       Sanjay  bottomed was not posted with the correct 
                                value.
*/
class implementation EMSpartedge;

#include "OMmacros.h"
#include "emsmacros.h"

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 struct EMSpartedgedef	*info;
 IGRlong		sts;
 GRobjid		bottomed = NULL_OBJID;
 struct EMSedgeinfo	locinfo;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 EMPutGenEdInfo(edinfo);
 edinfo->edgetype = EMSpart;
 info = (struct EMSpartedgedef *) &edinfo->specinfo.partedge;
 OM_BLOCK_MOVE(ME.EMSpartedge->boundary, info->edbdry, 
		2 * sizeof(struct EMSedgebound));
 if(options & EMGetDef_OnlyPartInfo) goto wrapup;


 info->fulled_id.objid = NULL_OBJID;
 info->fulled_id.osnum = OM_Gw_current_OS;
 info->fulled_type = EMSunknown;

 /* Do I have a bottom edge ?
 */
 sts = om$send(msg = message EMSedge.EMget_bottom_edge
			(EMmsg, &info->fulled_id.objid), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(IF_NULL_OBJID(info->fulled_id.objid)) goto wrapup;

 bottomed = info->fulled_id.objid;

 /* Get the info from the bottom edge.
 */
 sts = om$send(msg = message EMSedge.EMgetedgedef(EMmsg, options, &locinfo), 
			targetid = bottomed);
 if(!(1&*EMmsg&sts)) goto wrapup;

 info->fulled_type = locinfo.edgetype;
 info->fulled_props = locinfo.edprops;
 info->fulled_curve_type = locinfo.curve_type;
 switch(info->fulled_type)
  {
   case EMSlinear:
    OM_BLOCK_MOVE(&locinfo.specinfo.linedge, &info->fulled.linedge, 
			sizeof(struct EMSlinedgedef));
   break;

   case EMSnatural:
    OM_BLOCK_MOVE(&locinfo.specinfo.natedge, &info->fulled.natedge, 
			sizeof(struct EMSnatedgedef));
   break;

   case EMSbs:
    OM_BLOCK_MOVE(&locinfo.specinfo.bsedge, &info->fulled.bsedge, 
			sizeof(struct EMSbsedgedef));
   break;

   default:
    *EMmsg = EMS_E_Fail;
   break;
  }


wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSpartedge;
