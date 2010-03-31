/*
If no direct path upto the surface, try through my nesting_parent.
*/
class implementation NMfeaturelp;

#include "OMmacros.h"

method EMgetsurface_info(IGRlong *EMmsg;GRobjid *srfid;
			 struct EMSpartolbasis *partolbasis)
{
 IGRlong 		sts = OM_S_SUCCESS;
 GRobjid		nestingp = NULL_OBJID;

 if(srfid) *srfid = NULL_OBJID;
 if(partolbasis) partolbasis->is_valid = FALSE;

 sts = om$send(mode = OM_e_wrt_message, 
       msg = message EMSgraloop.EMgetsurface_info(EMmsg, srfid, partolbasis), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(srfid && (!IF_NULL_OBJID(*srfid))) goto wrapup; /* bingo */
 if(partolbasis && partolbasis->is_valid) goto wrapup;    /* bingo */

 sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent
       (EMmsg, &nestingp, TRUE),
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(IF_NULL_OBJID(nestingp)) goto wrapup;

 sts = om$send(msg = message EMSboundary.EMgetsurface_info
       (EMmsg, srfid, partolbasis), targetid = nestingp);

wrapup:
if(!(1&*EMmsg&sts))
 {
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_I_NotFound;
 }
EMWRAPUP(*EMmsg, sts, "NMfeaturelp.EMgetsurface_info");
return(sts);
}

end implementation NMfeaturelp;
