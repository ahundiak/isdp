/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	Long Ago	Creation.
	SM	12-Sep-88	Removed the assumption that all model space
				intersection data is polyline form. It can
				now also be data type EMSdata_curve3d.
				Also construct parametric edges to retain
				the curve_type info to e used in outputting 
				proper class of model space curves.
	SM	09-Jan-91	I don't remember why MUST_INTERSECT option 
				is specified (may be because of the way
				intersection worked at the time). But becuase
				of this option, the method errors out if
				there is no intersection since sts was
				not cleared. Fixed to also clear the
				sts.
	SM      08-Jun-93       Create natural LS on the constructed plane.
*/

class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
extern OMuword OPP_EMSsolid_class_id, OPP_EMSplane_class_id;
extern OM_S_OBJID current_creator;

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

method EMintplane(struct GRvg_construct *construct_list;
                   struct IGRplane *plane;
                   struct GRlc_info *located_object;
                   int *numinters;
                   struct GRid **inters;
                   int *EMmsg)
{
 IGRlong                 sts, rc;
 GRrange                 my_range;
 IGRboolean              world;
 struct IGRbsp_surface   plane_to_intersect;
 struct GRid             plane_GRid;
 struct GRid             save_mdid;
 IGRboolean              inrange;
 extern  void 		 BSplptnorrg();
 IGRpoint                plane_poles[4];
 IGRdouble               u_knots[4],v_knots[4];
 struct GRmd_env	 *my_env;
 IGRshort               outworld_opt, trim_opt, outparam_opt, inters_opt;
 struct EMSdataselect   other_data;
 extern IGRlong		 EMintersect_surfaces();
 struct GRid		    my_GRid;
 OMuword		    myclass;
 IGRchar		*save_geom = NULL;
 OM_S_OBJID		save_creator;
 IGRboolean save_pathway_trim, save_pathway_orient;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 plane_GRid.objid = NULL_OBJID;
 save_creator = current_creator;
 current_creator = NULL_OBJID;

 *numinters = 0;
 (*inters) = (struct GRid *) om$malloc(size = sizeof(struct GRid));
 EMerr_hndlr(!(*inters), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 (*inters)->osnum = construct_list->env_info->md_id.osnum;
 (*inters)->objid = NULL_OBJID;

 world = TRUE;
 my_env = &located_object->module_info;


/* Get my range
*/
 sts = om$send(msg=message EMSsurface.GRgetrang
         ((IGRlong *)EMmsg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
 	  &world,my_range), targetid = my_id);
 if(!(1&*EMmsg&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;

/* Get the plane definition which encompases the surface range.
*/
 plane_to_intersect.poles = (IGRdouble *) plane_poles;
 plane_to_intersect.u_knots = u_knots;
 plane_to_intersect.v_knots = v_knots;

 BSplptnorrg(my_range,&my_range[3],plane->point,plane->normal,1.1,
                &inrange,&plane_to_intersect,&rc);
 if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;


 /* Following temporary construction of the plane is a major kludge. I was
    setting the other datatype to be EMSdata_surface. But this does not
    capture the fact that it was a plane. Hence special math routines for
    analytical surfaces do not get invoked from EMget_int_data. Constructing
    a plane object seems to be the cleanest way at this time for communicating
    the information. Since the temporary plane isn't getting into the Rtree, 
    the expense is not much.
    SM Oct 20, 1992.
 */
  save_mdid = construct_list->env_info->md_id;
  /* Set mdid to NULL_OBJID to prevent Rtree processing.
  */
  construct_list->env_info->md_id.objid = NULL_OBJID;
  save_geom = construct_list->geometry;
  construct_list->geometry = (IGRchar *) &plane_to_intersect;
  plane_GRid.osnum = construct_list->env_info->md_id.osnum;
  sts = om$construct(osnum = plane_GRid.osnum, 
        p_objid = &plane_GRid.objid, classid = OPP_EMSplane_class_id, 
        msg = message GRgraphics.GRconstruct(construct_list));
  construct_list->env_info->md_id = save_mdid;
  construct_list->geometry = save_geom;
  if(!(1&*EMmsg&sts)) goto wrapup;

  sts = om$send(msg = message EMSsurface.EMmk_nat_bdry((IGRlong *)EMmsg, 
        &construct_list->env_info->md_env, NULL), 
        targetid = plane_GRid.objid, targetos = plane_GRid.osnum);
  if(!(1&*EMmsg&sts)) goto wrapup;

/*  Intersect the plane with the surface.
*/
 other_data.datatype = EMSdata_object;
 other_data.data.object = &plane_GRid;

 outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
 outworld_opt = EMSINT_OUTPUT_WORLD;                        
 trim_opt = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_COPLANAR
	    | EMSINT_TRIM_PROCOVERLAP;
	
 inters_opt = EMS_SFINT_MUSTINTERSECT;

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

 sts = EMintersect_surfaces(EMmsg, &my_GRid, &my_env->md_env, 1, &other_data,
       &construct_list->env_info->md_env, inters_opt, outworld_opt, 
       outparam_opt, trim_opt, construct_list,
       numinters, NULL, NULL, NULL, NULL, &(*inters)->objid, NULL, NULL);

 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 if(!*numinters || (*EMmsg == EMS_I_NotFound))
  {
   *numinters = 0;
   *EMmsg = EMS_I_NoIntersection;
   sts = OM_S_SUCCESS;	/* 09-Jan-91 -- SM */
   goto wrapup;
  }
 else if(inters && !IF_NULL_OBJID((*inters)->objid)) *numinters = 1;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

wrapup:
 if(!IF_NULL_OBJID(plane_GRid.objid))
  {
   save_mdid = construct_list->env_info->md_id;
   /* Set mdid to NULL_OBJID to prevent Rtree processing.
   */
   construct_list->env_info->md_id.objid = NULL_OBJID;
   sts = om$send(msg = message GRgraphics.GRdelete((IGRlong *)EMmsg, 
         construct_list->env_info), targetid = plane_GRid.objid, 
         targetos = plane_GRid.osnum);
   construct_list->env_info->md_id = save_mdid;
  }

 current_creator = save_creator;
 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EMintplane");
 return(sts);
}

end implementation EMSsurface;
