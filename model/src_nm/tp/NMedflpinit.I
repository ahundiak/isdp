class implementation NMedflp;

#include "EMSfrtdef.h"
#include "OMmacros.h"

from NMpartedge import NMget_region_edge;

method NMflpinit(IGRlong *EMmsg; struct EMSpartolbasis *partol;
		 struct GRmd_env *env;
		 IGRushort lp_props; unsigned char helper_props; 
		 GRobjid surf_id, nesting_parent; IGRushort options;
		 struct NMgmSSI *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 extern OM_S_OBJID      current_creator;
 OM_S_CHANSELECT	to_comps;
 struct GRid		sfGRid;
 struct NMentities	*this_nm = NULL;

 *EMmsg = EMS_S_Success;
 ME.EMSboundary->creator_id = current_creator;

 sts = om$send(msg = message EMSgraloop.EMglpinit(EMmsg, lp_props, partol, 
       surf_id), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message EMShelper.EMset_props(EMmsg, 
       helper_props, EMS_O_SET), targetid = my_id); 
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(IF_NULL_OBJID(nesting_parent))
  {
   GRobjid		reg_edge = NULL_OBJID;
   
   EMmake_chanselect(EMSbd_owner_to_comps, &to_comps);

   sts = om$send(msg = message NMpartedge.NMget_region_edge
	 (EMmsg, &reg_edge, &nesting_parent), p_chanselect = &to_comps, 
	 from = 0, to = 0);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 ME.NMfeaturelp->nesting_parent = nesting_parent;

 if( !(options & NMinit_AddToSSI) || !ssi || (IF_NULL_OBJID(surf_id)))
  goto wrapup;

 sfGRid.objid = surf_id;
 sfGRid.osnum = OM_Gw_current_OS;

 sts = NMsetUpSSI(EMmsg, &sfGRid, ssi, &this_nm);
 if(!(1&*EMmsg&sts)) goto wrapup;

 EMerr_hndlr(!this_nm, *EMmsg, EMS_E_Fail, wrapup);

 this_nm->flps[this_nm->num_flps++] = my_id;
 this_nm->flpsbufsize--;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMedflp.NMflpinit");
return(sts);
}
end implementation NMedflp;
