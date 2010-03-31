class implementation NMfeaturelp;

#include "OMmacros.h"

method EMintcopy(IGRlong *EMmsg; struct GRmd_env *mdenv; 
		 GRspacenum obj_osnum, new_osnum; 
  		 IGRushort options; GRobjid *newobjid;
		 struct EMcp_info *copy_info)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		copy_exists = FALSE;
 GRobjid		my_nesting_parent = NULL_OBJID, 
			copy_nesting_parent = NULL_OBJID;
			
 /* Do the work as a EMSgraloop.
 */
 sts = om$send(mode = OM_e_wrt_message, msg = message EMSgraloop.EMintcopy
       (EMmsg, mdenv, obj_osnum, new_osnum, options, newobjid, copy_info), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Set up the nesting parent of the copy.
 */
 sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
       &my_nesting_parent, TRUE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!IF_NULL_OBJID(my_nesting_parent))
  {
   EMcpsearch (EMmsg, my_nesting_parent, &copy_nesting_parent, copy_info, 0, 
   &copy_exists);
   if(!(1&*EMmsg)) goto wrapup;
   if(!copy_exists) copy_nesting_parent = NULL_OBJID;
  }

 sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
       &copy_nesting_parent, FALSE), targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMfeaturelp.EMintcopy");
return(sts);
}
end implementation NMfeaturelp;
