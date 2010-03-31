/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Put natural loopset if no loopset exists.
	
History
	SM	06-Jun-89	Creation.
        NP      26-Aug-92	Modified for ANSI compliance.
*/

class implementation EMSsubbs;

#include "EMS.h"

method EMputLsIfNotThere(IGRlong *EMmsg;
			  struct GRmdenv_info *env;
			  GRobjid *edge_ids, *lsid;
			  IGRushort options;
			  IGRboolean *ls_created)

{
 IGRlong			sts;
 OM_S_CHANSELECT		to_loopset;
 IGRuint			count = 0;
 OM_S_OBJECT_LINKAGE		junk;
 extern IGRlong			EMmake_chanselect();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
 if(!(1&sts)) goto wrapup;

 sts = om$get_channel_count(object = me, p_chanselect = &to_loopset,
				count = &count);
 EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);


/* If the surface has no loopset, create a natural loopset on it.
*/
 if(!count)
  {
   sts = om$send (msg = message EMSsubbs.EMmk_nat_bdry (EMmsg, env, edge_ids),
                       targetid = my_id);
   EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);
   if(ls_created) *ls_created = TRUE;
  }    
 else if(ls_created) *ls_created = FALSE;
		
 if(lsid)
  {
   count = 0;
   sts = om$get_channel_objects(object = me, p_chanselect = &to_loopset, 
			list = &junk, size = 1, count = &count);
   EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);
   if(count) *lsid = junk.S_objid;
   else *lsid = NULL_OBJID;
  }

wrapup:
 EMWRAPUP(*EMmsg,sts,"In EMSsubbs.EMputLsIfNotThere");
 return(sts);
}

end implementation EMSsubbs;
