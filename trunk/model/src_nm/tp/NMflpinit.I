class implementation NMfeaturelp;

#include "EMSfrtdef.h"
#include "OMmacros.h"

from EMSsurface import EMputLsIfNotThere;
from EMSloopset import EMnesting;

method NMflpinit(IGRlong *EMmsg; struct EMSpartolbasis *partol;
		 struct GRmd_env *env;
		 IGRushort lp_props; unsigned char helper_props; 
		 GRobjid surf_id, nesting_parent; IGRushort options;
		 struct NMgmSSI *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSnest_info    nesting;
 GRobjid		lsid;
 extern OM_S_OBJID      current_creator;
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

 if((IF_NULL_OBJID(nesting_parent)) && (!IF_NULL_OBJID(surf_id)))
  {
   sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, 
         &env->md_env, NULL, &lsid, NULL, NULL), targetid = surf_id);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg, &nesting),
         targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_NestError, wrapup);

   /* Turn off the EMLP_OPEN and EMLP_NOAREA_NOHOLE properties in the
      nesting structure, otherwise the nesting is forced to be under
      the loopset.
   */
   nesting.lp_props &= ~(EMLP_OPEN | EMLP_NOAREA_NOHOLE);
   sts = om$send(msg=message EMSloopset.EMnesting
         (EMmsg, &nesting, partol), targetid = lsid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_NestError, wrapup);
   nesting_parent = nesting.parent;
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
EMWRAPUP(*EMmsg, sts, "NMfeaturelp.NMflpinit");
return(sts);
}
end implementation NMfeaturelp;
