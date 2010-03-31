class implementation NMtrim;

#include "OMmacros.h"
#include "nddef.h"

from NMinters import NMintcopy;

method EMintcopy(IGRlong *EMmsg; struct GRmd_env *obj_mdenv;
        	 struct GRmd_env *new_mdenv; GRobjid *newobjid;
        	 struct EMcp_info *copy_info;
 		 IGRushort bdry_options,  sf_options)

{
 IGRlong		sts = OM_S_SUCCESS;
 union EMSparent_info  	roots[2];
 unsigned int	root_type[2];
 struct GRid		parents[2];
 struct EMSobject_info	copy_parents[2];
 IGRint			count, i;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 struct GRvg_construct  construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;
 IGRboolean		copy_exists = FALSE;


 *EMmsg = EMS_S_Success;

 /* If Already copied, exit.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 0, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;
 if(copy_exists) goto wrapup;

 /* Do the work as EMSsfboolean.
 */
 sts = om$send(mode = OM_e_wrt_message, msg = message EMSsfboolean.EMintcopy
       (EMmsg, obj_mdenv, new_mdenv, newobjid, copy_info, bdry_options, 
        sf_options), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Copy my parents if necessary and make my copy dependent on them.
 */
 sts = om$send(msg = message NDnode.NDget_objects(ND_ROOT, parents, 2, NULL, 0,
       MAXINT, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 root_type[0] = root_type[1] = EMSgrid;
 sts = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, count, 
       (IGRchar *) parents, root_type, roots), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<2; i++)
  {
   copy_parents[i].env = *new_mdenv;
   copy_parents[i].grid.osnum = new_mdenv->md_id.osnum;
   
   if(i == SrcIdx)
    sts = om$send(msg = message NMinters.NMintcopy(EMmsg, obj_mdenv, 
          new_mdenv, &copy_parents[i].grid.objid, copy_info, NULL, 
          bdry_options, sf_options), targetid = roots[i].grobj.grid.objid);
   else
    sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, obj_mdenv, 
          new_mdenv, &copy_parents[i].grid.objid, copy_info,
	  bdry_options, sf_options), targetid = roots[i].grobj.grid.objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = EMmsg;
 construct.env_info = &env;
 env = *new_mdenv;

 sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;
 sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, initas_opt, 
       2, copy_parents, NULL, NULL, NULL, &construct), targetid = *newobjid);

wrapup:
EMWRAPUP(*EMmsg, sts, "NMtrim.EMintcopy");
return(sts);
}

end implementation NMtrim;
