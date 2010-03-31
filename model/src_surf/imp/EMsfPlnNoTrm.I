/* ###################   APOGEE COMPILED   ################## */
/*
   This methos intersects a plane with a surface and returns the untrimmed
   model space curves.
   
   SM           05/21/87  Creation Date.
   SM		09-Jan-91 See EMsfintpln.I
*/

class implementation EMSsurface;

#include "EMS.h"
# include <stdio.h>
#include "EMSbnddef.h"
#include "EMSbnd.h"
# include "emssfintdef.h"
# include "emssfint.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsolid_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

method EMintplane_notrim(struct GRvg_construct *construct_list;
                   struct IGRplane *plane;
                   struct GRlc_info *located_object;
                   int *numinters;
                   struct GRid **inters;
                   int *msg)
{
 struct GRmdenv_info        *env;
 IGRushort          outworld_opt, trim_opt, outparam_opt, inters_opt;
 struct EMSdataselect       other_data;
 IGRlong                    sts;
 extern IGRlong		    EMintersect_surfaces();
 struct GRid		    my_GRid;
 OMuword		    myclass;
 IGRboolean save_pathway_trim, save_pathway_orient;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 *numinters = 0;
 (*inters) = (struct GRid *) om$malloc(size = sizeof(struct GRid));
 EMerr_hndlr(!(*inters), *msg, EMS_E_NoDynamicMemory, wrapup);
 (*inters)->osnum = construct_list->env_info->md_id.osnum;
 (*inters)->objid = NULL_OBJID;

 env = &located_object->module_info.md_env;
 other_data.datatype = EMSdata_plane;
 other_data.data.plane = plane;

 outparam_opt = NULL;
 outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_OBJECT;
 trim_opt = NULL;
 inters_opt = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_NOREFINE;
 sts = om$get_classid(objid = my_id, p_classid = &myclass);
 if( (sts = om$is_ancestry_valid(subclassid = myclass, 
				 superclassid = OPP_EMSsolid_class_id))
    == OM_S_SUCCESS)
  inters_opt |= EMS_SFINT_MUSTCLOSE | EMS_SFINT_AUTODOUBLECHECK;
 else sts = OM_S_SUCCESS;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 _pathway_trim = 0;
 _pathway_orient = 0;

 sts = EMintersect_surfaces(msg, &my_GRid, env, 1, &other_data, env, 
			    inters_opt, outworld_opt, outparam_opt, trim_opt, 
			    construct_list, numinters, NULL, NULL, NULL, NULL,
			    &(*inters)->objid, NULL, NULL);
 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 if(!*numinters || (*msg == EMS_I_NotFound))
  {
   *numinters = 0;
   *msg = EMS_I_NoIntersection;
   sts = OM_S_SUCCESS;	/* 09-Jan-91 -- SM */
   goto wrapup;
  }
 else if(inters && !IF_NULL_OBJID((*inters)->objid)) *numinters = 1;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
wrapup:
 EMWRAPUP(*msg,sts,"In EMSsurface.EMintplane_notrim");
 return(sts);

}

end implementation EMSsurface;
