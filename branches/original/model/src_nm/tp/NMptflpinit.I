class implementation NMptflp;

#include "EMSfrtdef.h"
#include "OMmacros.h"

from EMSsurface import EMputLsIfNotThere;
from EMSloopset import EMpt_location;

/****************************************************************************

      History :  Created to fix the TR#169314013.

      Creation : 28/01/94
                 Vadi.
*****************************************************************************/

method NMflpinit(IGRlong *EMmsg; struct EMSpartolbasis *partol;
                 struct GRmd_env *env;
                 IGRushort lp_props; unsigned char helper_props;
                 GRobjid surf_id, nesting_parent; IGRushort options;
                 struct NMgmSSI *ssi)
{
 IGRlong                sts = OM_S_SUCCESS;
 IGRdouble              uv[2][2];
 GRobjid                lsid;
 extern OM_S_OBJID      current_creator;
 struct GRid            sfGRid;
 struct EMSptloc_info   location;
 struct NMentities      *this_nm = NULL;

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

   sts = om$send(msg = message EMSloop.EMendpts(EMmsg, uv[0],
                                                NULL,NULL,NULL),
                                        targetid = my_id);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

   location.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP;
   sts = om$send(msg = message EMSloopset.EMpt_location
                                (EMmsg,uv[0],&location,partol),
                                 targetid = lsid);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

   if(location.location == EMS_L_INAREA)  
      nesting_parent = location.loop_id;
   else
      nesting_parent = lsid;
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

EMWRAPUP(*EMmsg, sts, "NMptflp.NMflpinit");
return(sts);
}
end implementation NMptflp;
