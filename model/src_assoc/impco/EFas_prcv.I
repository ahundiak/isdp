class implementation EMSassoc;
/*
History

   recompute function for associative curve projection onto surface

3  Nov 1993 creation,  dfloegel , HDC 
   June 1995 - fixes,  dfloegel , HDC

*/


#include "ems_m_inc.h"
#include "bsicmpcvoff.h"
#include "EMSopt.h"
#include "EMSasmacros.h"
#include "grwireframe.h"
#include "ECmsg.h"



%safe
#include "math.h"
%endsafe


#define dflT1 0
#define dflT2 0

/* command options */
#define NORMAL_TO_SURFACE       0
#define ALONG_VECTOR            1
#define OFFSET                  1
#define NO_OFFSET               0


from GRcurve import  GRendpts; 
from EMSsubbs import EMsfcvoffset, EMproject_curve_onto_surface,
                                   EMproject_curve_along_surface_normals;

extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_GR3dpoint_class_id;

extern IGRboolean BSnorvec();
extern OMuword			OPP_GRbcsubbc_class_id;


IGRint EFas_prcv(EMmsg,
                   options,
                   old_objid,
                   new_objid,
                   num_parents,
                   parent_info,
                   recomp_info,
                   const_list,
                   mod_new_id)

 	IGRlong 		*EMmsg;
 	IGRuint 		options;
	GRobjid			old_objid;
	GRobjid			new_objid;
	IGRint			num_parents;
	IGRchar			*parent_info;
	IGRchar			*recomp_info;
	struct GRvg_construct	*const_list;
	GRobjid			*mod_new_id;


/*
    comment


**************************************************************************/
{
 int				XXXXX; 
 BSrc                           rc;
 IGRboolean                     is_point;
 IGRuint			root_type[4];
 IGRuint			root_count;
 IGRint                         inx; /* PACOS */
 IGRlong			sts;
 IGRlong			stat_OM;
 IGRlong			msg_loc;
 IGRlong			size;
 IGRlong			ln;
 IGRint                         in;
 IGRlong			mem_size;
 IGRlong                        number_of_objects;
 IGRdouble                      dist_at_stpt; /* PACOS */
 IGRdouble                      dist_at_ept; /* PACOS */
 IGRdouble                      dist;
 IGRdouble                      u, v, *up=NULL, *vp=NULL;
 IGRvector			plane_normal;
 IGRvector                      tvector;
 IGRpoint			plane_point;
 IGRpoint                       vector; /* PACOS */
 IGRpoint                       vector_first_point; /* PACOS */
 IGRpoint                       vector_second_point; /* PACOS */
 IGRpoint                       npoint;
 IGRdouble                      nnormal[3];
 IGRpoint                       *vpoint = NULL;
 OM_S_OBJID                     *objects; /* PACOS */
 struct GRid                    temp_id;
 struct GRid			pro_curve_id;
 struct IGRplane		plane;
 struct IGResbc                 esbc;
 struct IGRbsp_curve		*bsp_curve = NULL;
 struct IGRbsp_curve		*proj_bsp_curve = NULL;
 struct IGRbsp_curve            *law_cv = NULL; /* PACOS */
 struct IGRbsp_surface          *bsp_surface = NULL;
 union EMSparent_info		*roots = NULL;
 OMuword 		        class_id;
 struct GRprops                 obj_properties;
 struct 			as_project_ctrl {
         IGRint        projection_type;
         IGRint        offset;
         IGRint        right_side;
         IGRint        project_onto_refplane;
         IGRchar       lawcurve_name[MAX_CHAR + 1];    
    };


 struct as_project_ctrl 	*projectptr = NULL;

 *EMmsg = OM_S_SUCCESS;
 sts = OM_S_SUCCESS;
 XXXXX = 1;
 /* get recompute control information */
 projectptr = (struct as_project_ctrl  *) recomp_info;


#if dflT1
 /* test what came in */
 printf("projection type = %d\n", projectptr->projection_type);
 printf("offset = %d\n", projectptr->offset);
 printf("project onto refplane = %d\n", projectptr->project_onto_refplane);
 printf("lawcurve name = %s\n", projectptr->lawcurve_name);


#endif

 /* extract the parent_info */
 root_type[0] = EMSlcinfo;
 root_type[1] = EMSlcinfo;
 
 root_count = num_parents;

 if (projectptr->projection_type == NORMAL_TO_SURFACE && 
     projectptr->offset == OFFSET) {
   /* offset distances exist as objects */
   root_type[2] = EMSdistance;
   root_type[3] = EMSdistance;
 }

 if (projectptr->projection_type == ALONG_VECTOR) {
   root_type[2] = EMSlcinfo;
 }

 roots = (union EMSparent_info *) stackalloc(root_count * sizeof
                                      (union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);


 stat_OM = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                                                        NULL,
                                                        root_count,
                                                        parent_info,
                                                        root_type,
                                                        roots),
               senderid = new_objid,
               targetid = new_objid);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);


 /* get the offset distances */
 if (projectptr->projection_type == NORMAL_TO_SURFACE){
     if (projectptr->offset == OFFSET) {
       dist_at_stpt = (roots + 2)->value;
       dist_at_ept  = (roots + 3)->value;
     } else {
       dist_at_stpt = 0.0;
       dist_at_ept = 0.0;
       law_cv = NULL;
     }
   }


 /* get vector first and last point if ALONG_VECTOR */
 if (projectptr->projection_type == ALONG_VECTOR) {

    stat_OM = om$send(msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &roots->lc_info.module_info.md_env.matrix_type,
                             roots->lc_info.module_info.md_env.matrix,
                             vector_first_point,
                             vector_second_point),
                      senderid = new_objid,
                      targetos = (roots + 2)->lc_info.located_obj.osnum,
                      targetid = (roots + 2)->lc_info.located_obj.objid );
    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    vector[0] = vector_second_point[0] - vector_first_point[0];
    vector[1] = vector_second_point[1] - vector_first_point[1];
    vector[2] = vector_second_point[2] - vector_first_point[2];
    BSnorvec(&msg_loc, vector);
 }
  
 const_list->class_attr = NULL;


 /* get geometry of the  curve  */
 stat_OM = om$send( msg = message GRvg.GRgetsize(
                          EMmsg,
                          &roots->lc_info.module_info.md_env.matrix_type,
                          roots->lc_info.module_info.md_env.matrix,
                          &size ),
                    senderid = new_objid,
                    targetos = roots->lc_info.located_obj.osnum,
                    targetid = roots->lc_info.located_obj.objid );
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);


 bsp_curve = (struct IGRbsp_curve *) stackalloc( size );
 EMerr_hndlr(!bsp_curve, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
 stat_OM = om$send( msg = message GRvg.GRgetgeom(
                          EMmsg,
                          &roots->lc_info.module_info.md_env.matrix_type,
                          roots->lc_info.module_info.md_env.matrix,
                          (IGRchar *)bsp_curve ),
                    senderid = new_objid,
                    targetos = roots->lc_info.located_obj.osnum,
                    targetid = roots->lc_info.located_obj.objid );
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
         
 BSalloccv( bsp_curve->order,
               bsp_curve->num_poles,
               bsp_curve->rational,
               bsp_curve->num_boundaries,
               &proj_bsp_curve,
               &msg_loc );

 /* get surface properties */
 stat_OM = om$send(msg = message GRvg.GRgeomprops(
                         &msg_loc,
                         &(roots+1)->lc_info.module_info.md_env.matrix_type,
                         (roots +1)->lc_info.module_info.md_env.matrix,
                         &obj_properties),
                   senderid = new_objid,
                   targetos = (roots+1)->lc_info.located_obj.osnum,
                   targetid = (roots+1)->lc_info.located_obj.objid );
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
 
  /* test, if curve is a point */
  is_point = FALSE;
  stat_OM = om$get_classid(
            objid = roots->lc_info.located_obj.objid,
            osnum = roots->lc_info.located_obj.osnum,
            p_classid = &class_id);
  EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
  stat_OM = om$is_ancestry_valid(subclassid = class_id, 
            superclassid = OPP_GR3dpoint_class_id);
  EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
  if (stat_OM == OM_S_SUCCESS) 
     is_point = TRUE;

  /* get geometry of the surface if curve is point  */
  /* will be needed for the BS functions */
  if(is_point && !projectptr->project_onto_refplane) {
      stat_OM = om$send( msg = message GRvg.GRgetsize(
                 &msg_loc,
                 &(roots+1)->lc_info.module_info.md_env.matrix_type,
                 (roots +1)->lc_info.module_info.md_env.matrix,
                 &mem_size ),
              senderid = new_objid,
              targetos = (roots+1)->lc_info.located_obj.osnum,
              targetid = (roots+1)->lc_info.located_obj.objid );
      EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);


      bsp_surface = (struct IGRbsp_surface *) om$malloc( size = mem_size);
      EMerr_hndlr(!bsp_surface, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
  
 
      stat_OM = om$send( msg = message GRvg.GRgetgeom(
               &msg_loc,
               &(roots+1)->lc_info.module_info.md_env.matrix_type,
               (roots +1)->lc_info.module_info.md_env.matrix,
               (IGRchar *) bsp_surface),
            senderid = new_objid,
            targetos = (roots+1)->lc_info.located_obj.osnum,
            targetid = (roots+1)->lc_info.located_obj.objid );
      EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);
 }

 /* determine plane point and normal if surface is plane or reference plane */
 if(obj_properties.planar || projectptr->project_onto_refplane) {
    plane.point = (IGRdouble *) &plane_point[0];
    plane.normal = (IGRdouble *) &plane_normal[0];
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRdetplane(
                            &msg_loc,
                            &(roots + 1)->lc_info.module_info.md_env.matrix_type,
                            (roots + 1)->lc_info.module_info.md_env.matrix,
                            &plane),
                      senderid = new_objid,
                      targetid = (roots + 1)->lc_info.located_obj.objid,
                      targetos = (roots + 1)->lc_info.located_obj.osnum);


    if (projectptr->projection_type == NORMAL_TO_SURFACE) {
      vector[0] = plane.normal[0];
      vector[1] = plane.normal[1];
      vector[2] = plane.normal[2];
    }
  }

 /* compute new curve */
 if(is_point && !projectptr->project_onto_refplane) {
   if (projectptr->projection_type == NORMAL_TO_SURFACE) {
       /* compute projection point normal to surface */
       BSptnorsf(bsp_surface, 
              bsp_curve->poles, 
              &in,
              &u, 
              &v,
              npoint,
              &dist,
              &rc);
       if (rc == EMS_I_BSerror || in == 0) {
         ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
         *EMmsg = msg_loc;
         goto wrapup;
       }
       /* compute normal in projection point */
       BSsfarrevn(&rc,
                  bsp_surface,
                  1,
                  &u,
                  1,
                  &v,
                  npoint,
                  nnormal);
       if (rc == EMS_I_BSerror) {
         ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
         *EMmsg = msg_loc;
         goto wrapup;
       }
       /* determine direction of offset */
        npoint[X] += (nnormal[X] * (dist_at_stpt * 
                     (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1)));
        npoint[Y] += (nnormal[Y] * (dist_at_stpt * 
                     (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1)));
        npoint[Z] += (nnormal[Z] * (dist_at_stpt * 
                     (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1)));

       /* place projection-point as object */
       /* because the curve is a point we compute the new curve in that we
          take the old curve structure and assign the projected point as 
          the new poles */
       bsp_curve->poles[0] = npoint[X];
       bsp_curve->poles[1] = npoint[Y];
       bsp_curve->poles[2] = npoint[Z];
       bsp_curve->poles[3] = npoint[X];
       bsp_curve->poles[4] = npoint[Y];
       bsp_curve->poles[5] = npoint[Z];
       const_list->newflag = FALSE;
    
       /* construct a new curve object of class point */
       pro_curve_id.osnum = const_list->env_info->md_id.osnum;
       const_list->geometry = (IGRchar *) bsp_curve;

       stat_OM = om$construct (classid = OPP_GR3dpoint_class_id,
                               msg = message GRvg.GRconstruct(const_list),
                               p_objid = &pro_curve_id.objid,
                               osnum = pro_curve_id.osnum);
       EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);
   } else {
   /* here we project along vector and still a point */
       tvector[0] = vector[0];
       tvector[1] = vector[1];
       tvector[2] = vector[2];
       BSpj_pt_sf(bsp_surface,
                  bsp_curve->poles,
                  tvector, 
                  &ln, 
                  &vpoint, 
                  &up, 
                  &vp, 
                  &rc);
       if (rc == EMS_I_BSerror || ln == 0) {
         ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
         *EMmsg = msg_loc;
         goto wrapup;
       }
       /* place projection-point as object */
       bsp_curve->poles[0] = vpoint[0][X];
       bsp_curve->poles[1] = vpoint[0][Y];
       bsp_curve->poles[2] = vpoint[0][Z];
       bsp_curve->poles[3] = vpoint[0][X];
       bsp_curve->poles[4] = vpoint[0][Y];
       bsp_curve->poles[5] = vpoint[0][Z];

       const_list->newflag = FALSE;
       pro_curve_id.osnum = const_list->env_info->md_id.osnum;
       const_list->geometry = (IGRchar *) bsp_curve;

       stat_OM = om$construct (classid = OPP_GR3dpoint_class_id,
                               msg = message GRvg.GRconstruct(const_list),
                               p_objid = &pro_curve_id.objid,
                               osnum = pro_curve_id.osnum);
       EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);

     }
  } else if (projectptr->project_onto_refplane) {
       /* projecting onto reference plane is special */

       if(projectptr->offset == OFFSET) { 
         plane.point[X] +=  (vector[X] * dist_at_stpt * 
                      (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1));
         plane.point[Y] +=  (vector[Y] * dist_at_stpt * 
                      (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1));
         plane.point[Z] +=  (vector[Z] * dist_at_stpt * 
                      (IGRdouble) ((projectptr->right_side == TRUE) ? 1 : -1));
       }
       stat_OM = BSprj_cv_pl(&msg_loc,
                             bsp_curve,
                             plane.point,
                             plane.normal,
                             vector,
                             proj_bsp_curve );

       if ((msg_loc == EMS_I_BSerror) || (!(1&stat_OM))) {
          ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
          *EMmsg = msg_loc;
          goto wrapup;
       }

       /* we distinguish between point and curve construction */
       const_list->newflag = FALSE;
       pro_curve_id.osnum = const_list->env_info->md_id.osnum;
       const_list->geometry = (IGRchar *) proj_bsp_curve;
       if(is_point) {
         stat_OM = om$construct (classid = OPP_GR3dpoint_class_id,
                                 msg = message GRvg.GRconstruct(const_list),
                                 p_objid = &pro_curve_id.objid,
                                 osnum = pro_curve_id.osnum);
         EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);
       } else {
         stat_OM = om$construct (classid = OPP_GRbcsubbc_class_id,
                                 msg = message GRvg.GRconstruct(const_list),
                                 p_objid = &pro_curve_id.objid,
                                 osnum = pro_curve_id.osnum);
         EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);
       }
 
  } else {
   if (projectptr->projection_type == NORMAL_TO_SURFACE) {
       /* is along normal and is no point and not onto reference plane */

       if (strcmp(projectptr->lawcurve_name, "\0 ")) {
          inx = -1;
          EMget_lawcurve(&msg_loc,
                         projectptr->lawcurve_name,
                         &inx,
                         &law_cv);
          EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
       }
       const_list->geometry = NULL;
       const_list->class_attr = NULL;
       objects = NULL;
       number_of_objects = 0;

       stat_OM = om$send (msg = message EMSsubbs.EMproject_curve_along_surface_normals(
                                 &( roots)->lc_info,
                                 &(roots + 1)->lc_info,
                                 const_list,
                                 TRUE, /*want status message */
                                 TRUE, /*trimming required */
                                 &number_of_objects,
                                 &objects,
                                 &msg_loc),
                          targetid = (roots + 1)->lc_info.located_obj.objid,
                          targetos = (roots + 1)->lc_info.located_obj.osnum,
                          senderid = new_objid);
       if(msg_loc == EMS_I_InvalidArg) {
          ex$message(msgnumb=EMS_S_InvalidOfstCode);
         *EMmsg = msg_loc;
         goto wrapup;
       } else if ((msg_loc == EMS_I_BSerror) || 
                 (! (1&msg_loc)) || 
                 (number_of_objects == 0) ||
                 (!(1&stat_OM))) {
            ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
            *EMmsg = msg_loc;
            goto wrapup;
         }
       if(dist_at_stpt != 0.0 || dist_at_ept != 0.0) {
         stat_OM = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetattr(&msg_loc, (char *)&esbc),
                           senderid = new_objid,
                           targetos = roots->lc_info.located_obj.osnum,
                           targetid = roots->lc_info.located_obj.objid);

         if (! (1&msg_loc&stat_OM)) {
            ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
            *EMmsg = msg_loc;
            goto wrapup;
         }

         const_list->class_attr = NULL;
         const_list->geometry = NULL;
         const_list->msg = &msg_loc;
         const_list->newflag = FALSE;
         const_list->properties = GRIS_DISPLAYABLE | 
                                  GRIS_NEW | 
                                  GRIS_LOCATABLE;
         const_list->name = NULL;


         temp_id.osnum = const_list->env_info->md_id.osnum;
         temp_id.objid = objects[0];
         stat_OM = om$send(msg = message EMSsubbs.EMsfcvoffset (
                                 &msg_loc,
                                 &const_list->env_info->md_env.matrix_type,
                                 const_list->env_info->md_env.matrix,
                                 const_list,
                                 &temp_id,
                                 projectptr->right_side,
                                 dist_at_stpt,
                                 dist_at_ept,
                                 (dist_at_ept == 0.0) ? FALSE : TRUE,
                                 (dist_at_ept == 0.0) ? FALSE : TRUE,
                                 law_cv,
                                 &pro_curve_id),
                           senderid = new_objid,
                           targetid = (roots + 1)->lc_info.located_obj.objid,
                           targetos = (roots + 1)->lc_info.located_obj.osnum);
         if(msg_loc == EMS_I_InvalidArg) {
            ex$message(msgnumb=EMS_S_InvalidOfstCode);
            *EMmsg = msg_loc;
            goto wrapup;
         } else if ((msg_loc == EMS_I_BSerror) || 
                    (! (1&msg_loc)) || 
                    (!(1&stat_OM))) {
               ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
               *EMmsg = msg_loc;
               stat_OM = om$send (msg = message GRgraphics.GRdelete(
                                        EMmsg,
                                        const_list->env_info),
                                  senderid = new_objid,
                                  targetid = temp_id.objid,
                                  targetos = temp_id.osnum);
                EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
                goto wrapup;
         }
         /* delete the temporary object */
         stat_OM = om$send (msg = message GRgraphics.GRdelete(
                                  EMmsg,
                                  const_list->env_info),
                            senderid = new_objid,
                            targetid = temp_id.objid,
                            targetos = temp_id.osnum);
         EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
     } else {
       if(number_of_objects) {
          pro_curve_id.objid = objects[0];
          pro_curve_id.osnum = const_list->env_info->md_id.osnum;
       } else {
          ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
          *EMmsg = msg_loc;
          goto wrapup;
       }
     }
      
 } else {
      /* is along vector and no point and not onto reference plane*/

      objects = NULL;
      number_of_objects = 0;

      stat_OM = om$send (msg = message EMSsubbs.EMproject_curve_onto_surface(
                               &( roots)->lc_info,
                               &(roots + 1)->lc_info,
                               const_list,
                               vector,
                               TRUE, /*want status message */
                               TRUE, /*trimming required */
                               &number_of_objects,
                               &objects,
                               &msg_loc),
                         targetid = (roots + 1)->lc_info.located_obj.objid,
                         targetos = (roots + 1)->lc_info.located_obj.osnum,
                         senderid = new_objid);
      if(msg_loc == EMS_I_InvalidArg) {
         ex$message(msgnumb=EMS_S_InvalidOfstCode);
      } else if ((msg_loc == EMS_I_BSerror) || 
                 (! (1&msg_loc)) || 
                 (!(1&stat_OM))) {
         ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
         *EMmsg = msg_loc;
         goto wrapup;
      }

      pro_curve_id.objid = objects[0];
      pro_curve_id.osnum = const_list->env_info->md_id.osnum;

    }
 }

 *mod_new_id = pro_curve_id.objid;


 wrapup:
  if (!(1&stat_OM&*EMmsg)) *mod_new_id = NULL_OBJID;
  return (stat_OM);
}

end implementation EMSassoc;
