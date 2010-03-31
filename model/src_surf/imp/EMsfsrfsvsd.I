/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method intersects a surface with the host surface and saves
a particular side of the host. The side to be saved is designated by a
3D point or by a flag indicating that the side to save is on the natural
normal side of the slicing object.  If no save side point is provided,
or the natural normal option is not set, it performs a split operation
(saving both sides).

	The surface becomes a part of the solid after saving the side.
Thus the resulting solid remains valid (closed). In case of a surface or
a composite surface the surface does not become a part of the result.
The object, however is retained (but made non locatable, non
displayable) for reexecute purposes.

The input surface can be - 

	EMSdata_plane
	EMSdata_surface
	EMSdata_object.
	
History
        mrm     07/30/91        Added natural normal option for save side.
        mrm     04/10/91        Added parent arg, send to EMinit_assoc.
	SM	09-Jan-89	Modified EMintplane_saveside to be
				EMintsurf_saveside with additional code
				to support what is suggested by the new
				name. Also if no save side point is provided
				a 'split' operation is done on the host 
				surface.
	SM	29-Nov-88	Pass option EMSbool_opt_display to the
				boolean method for selective display of the
				surfaces modified.
	SM	04/29/87	Creation Date.
*/
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "emssfintdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emserr.h"
#include "bserr.h"
#include "emsbool.h"
#include "OMmacros.h"
#include "EMSasdef.h"
#include "EMSasopts.h"
#include "EMSasnucdef.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "REsfboolean.h"
#include "godef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define StaticBuf 10

extern OMuword OPP_EMSplane_class_id,OPP_EMSslboolean_class_id, 
	       OPP_EMSsfboolean_class_id, OPP_EMSsolid_class_id, 
	       OPP_EMSloopset_class_id, OPP_EMSsfspltwsf_class_id, 
	       OPP_EMSslspltwsf_class_id, OPP_EMSgenbs_class_id;

from EMSassoc import EMinit_associative;
from EMSsfboolean import EMboolean;
from EMSsfspltwsf import EMsplit_with_surface;
from GRowner import GRget_number_components, GRget_components;

method EMintsurf_saveside(
	 IGRlong *EMmsg;
         struct GRvg_construct *construct_list;
	 struct EMSdataselect *surf;
	 struct GRmd_env *my_env;
         IGRdouble *saveside_point;
         IGRint natural_normal;
	 IGRushort options;
	 GRobjid *intobj, *auxobj;
	 IGRboolean want_status_messages;
         struct EMSobject_info *parent)
{
 	IGRlong			sts,rc;
	GRrange			my_range;
	IGRboolean		world,natside,inrange, issolid = FALSE, 
				surf_constructed_here = TRUE;
	struct IGRbsp_surface 	plane_to_intersect, *sfgm = NULL;
	GRobjid			surf_id = NULL_OBJID,gmid = NULL_OBJID;
  	extern void  		BSplptnorrg();
	IGRpoint		plane_poles[4];
	IGRdouble		u_knots[4],v_knots[4];
	IGRshort		*mat_type;
	IGRdouble		*matrix;
	enum EMSbooltype	bool_type;
	OMuword			myclassid;
       	struct IGRplane		*plane;
        struct GRid             *comps = NULL, compsbuf[StaticBuf];
        IGRint                  num_comps = 0;
        IGRboolean              surf_reversed = FALSE;
 IGRdouble norm1[3], srfpt[3], u_par, v_par, dotp;
 extern void BSsfarrevn();
     
      struct IGRbsp_surface *surf_geom;
      IGRint                 buff_size;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 world = TRUE;
 mat_type = &my_env->md_env.matrix_type;
 matrix = my_env->md_env.matrix;

 EMerr_hndlr(!surf, *EMmsg, EMS_E_InvalidArg, wrapup);

 /* All the players involved (including the ones forthcoming) need to exist
    in the same object space.
 */
 EMerr_hndlr(construct_list->env_info->md_id.osnum != my_env->md_id.osnum, 
		*EMmsg, EMS_E_InvalidArg, wrapup);
 EMerr_hndlr(construct_list->env_info->md_id.osnum != OM_Gw_current_OS, 
		*EMmsg, EMS_E_InvalidArg, wrapup);
		
 /* Determine the save side surface based on the type of input.
 */
 if(surf->datatype == EMSdata_plane)
  {
   if(want_status_messages) ex$message(msgnumb = EMS_I_GeneratingPlane)
   plane = (struct IGRplane *) surf->data.plane;

   /* Get my range
   */
   sts = om$send(msg=message EMSsurface.GRgetrang
			(EMmsg,mat_type,matrix,&world,my_range),
			targetid = my_id);
   if(!(1&*EMmsg&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;

   /* Get the plane definition which encompasses the surface range.
   */
   plane_to_intersect.poles = (IGRdouble *)plane_poles;
   plane_to_intersect.u_knots = u_knots;
   plane_to_intersect.v_knots = v_knots;

   BSplptnorrg(my_range, &my_range[3], plane->point, plane->normal, 1.1,
		&inrange, &plane_to_intersect, &rc);
    if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
    else *EMmsg = EMS_S_Success;

   /* Set the pos_orient bit such that the save_side point is outside the
      solid of which the plane is a part. If save side point is not supplied
      then perform split operation (intersect surface & save both sides).
   */
/*
   if (natural_normal == FALSE)
   {
     plane_to_intersect.pos_orient = TRUE;
   }
   else if (natural_normal == TRUE)
   {
     plane_to_intersect.pos_orient = FALSE;
   }
   else
*/
   if (saveside_point)
   {
     (void) BSptonnsdsf(&plane_to_intersect,saveside_point,&natside,&rc);
     if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
     else *EMmsg = EMS_S_Success;

     /* If the point is away from the natural normal of the surface then the
        pos_orient flag should be set to TRUE, which will mean that the natural
        normal of the surface points into the solid, or in other words, the
        point lies outside the solid.
     */
     if(!natside)
      plane_to_intersect.pos_orient = TRUE;
     else
      plane_to_intersect.pos_orient = FALSE;
   }
   else
   {
     if(natural_normal == FALSE)
      plane_to_intersect.pos_orient = TRUE;
     else if(natural_normal == TRUE)
      plane_to_intersect.pos_orient = FALSE;

   u_par = v_par = 0.0;
   BSsfarrevn(EMmsg, &plane_to_intersect, 1, &u_par, 1 , &v_par,  srfpt, norm1);
   dotp = norm1[0] * surf->data.plane->normal[0] +
          norm1[1] * surf->data.plane->normal[1] +
          norm1[2] * surf->data.plane->normal[2] ;
   if(dotp < 0.)
      plane_to_intersect.pos_orient = !plane_to_intersect.pos_orient;
   }

   sts = om$construct(classid = OPP_EMSplane_class_id,
			p_objid = &surf_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   construct_list->geometry = (IGRchar *) &plane_to_intersect;

   sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
			targetid = surf_id);
   if(!(1&sts))
    {
      *EMmsg = EMS_E_Fail;
      goto wrapup;
    }
   else *EMmsg = EMS_S_Success;
   construct_list->geometry = NULL;

  } /* if(surf->datatype == EMSdata_plane) */

 else if(surf->datatype == EMSdata_surface)
  {
   if (saveside_point)
   {
     (void) BSptonnsdsf(surf->data.surface, saveside_point, &natside, &rc);
     if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
     else *EMmsg = EMS_S_Success;

     /* If the point is away from the natural normal of the surface then the
        pos_orient flag should be set to TRUE, which will mean that the natural
        normal of the surface points into the solid, or in other words, the
        point lies outside the solid.
     */
     if(!natside)
      surf->data.surface->pos_orient = TRUE;
     else
      surf->data.surface->pos_orient = FALSE;
    }
   else
   {
     if(natural_normal == FALSE)
      surf->data.surface->pos_orient = TRUE;
     else if(natural_normal == TRUE)
      surf->data.surface->pos_orient = FALSE;
   }


   sts = om$construct(classid = OPP_EMSgenbs_class_id, p_objid = &surf_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   construct_list->geometry = (IGRchar *) surf->data.surface;
   sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
			targetid = surf_id);
   if(!(1&sts))
    {
      *EMmsg = EMS_E_Fail;
      goto wrapup;
    }
   else *EMmsg = EMS_S_Success;
   construct_list->geometry = NULL;

  } /* if(surf->datatype == EMSdata_surface) */
 
 else if(surf->datatype == EMSdata_object)  /* could be a composite */
  {
   IGRint junk;

   if(surf->data.object->osnum != OM_Gw_current_OS)
    {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
   surf_id = surf->data.object->objid;
   surf_constructed_here = FALSE;

   /* If composite, use the first component to do point on side testing.
   */
   num_comps = 0;
   sts = om$send(msg = message GRowner.GRget_number_components
           (EMmsg, &num_comps), targetid = surf_id);
   if(sts == OM_W_UNKNOWN_MSG) /* must be a single surface */
    {
     comps = compsbuf;
     comps[0].objid = surf_id;
     comps[0].osnum = OM_Gw_current_OS;
     junk = 1;
     sts = OM_S_SUCCESS;
    }
   else
    {
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     if(num_comps > StaticBuf)
      comps = (struct GRid *) om$malloc(size = num_comps *
              sizeof(struct GRid));
     else comps = compsbuf;
     EMerr_hndlr(!comps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     sts = om$send(msg = message GRowner.GRget_components(EMmsg, my_env, 
           comps, num_comps, &junk, 0, MAXINT), targetid = surf_id);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    }
   EMerr_hndlr(!junk, *EMmsg, EMS_E_Fail, wrapup);

   sts = EMgetvggeom(EMmsg, mat_type, matrix, comps, &sfgm, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(saveside_point)
    {
     (void) BSptonnsdsf(sfgm, saveside_point, &natside, &rc);
     if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
     else *EMmsg = EMS_S_Success;

     /* If the point is away from the natural normal of the surface then the
        pos_orient flag should be set to TRUE, which will mean that the natural
        normal of the surface points into the solid, or in other words, the
        point lies outside the solid.
     */
    if( (!natside && (sfgm->pos_orient != TRUE)) ||
        (natside && (sfgm->pos_orient != FALSE)))
     {
      sts = om$send (msg = message EMSsurface.EMrevorient(EMmsg), 
                   targetid = surf->data.object->objid,
                   targetos = OM_Gw_current_OS);
      EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);
     }
   }
  else
   {
    if( ((natural_normal == FALSE) && (sfgm->pos_orient == FALSE)) ||
          ((natural_normal == TRUE) && (sfgm->pos_orient == TRUE)))
     {
      surf_reversed = TRUE;
      sts = om$send (msg = message EMSsurface.EMrevorient(EMmsg), 
                   targetid = surf->data.object->objid,
                   targetos = OM_Gw_current_OS);
      EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);
     }
   }

  }
 else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

 sts = om$send(msg = message EMSsurface.EMputLsIfNotThere
			(EMmsg, &my_env->md_env, NULL, NULL, NULL, NULL), 
			targetid = my_id);
 EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
 sts = om$send(msg = message EMSsurface.EMputLsIfNotThere
			(EMmsg, &my_env->md_env, NULL, NULL, NULL, NULL), 
			targetid = surf_id);
 EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
 
 sts = om$get_classid(objid = my_id, p_classid = &myclassid);
 if (myclassid == OPP_EMSsolid_class_id || 
     om$is_ancestry_valid (subclassid = myclassid,
           superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS)
    issolid = TRUE;
 else issolid = FALSE;

 if(want_status_messages) ex$message(msgnumb = EMS_I_IntersTrimSurfaces)

 if(saveside_point || (natural_normal == FALSE) || (natural_normal == TRUE))
  {
   /* Create a Globalmod object of right kind and perform the boolean.
   */
   sts = om$construct(classid = issolid ? OPP_EMSslboolean_class_id
					: OPP_EMSsfboolean_class_id, 
                      p_objid = &gmid);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   if (parent)
   {
     /* set up an associative relationship with the boolean as a child of
        the object defining the plane and the object being sliced - mrm */

     IGRboolean pos_orient,i;
     IGRushort pos_option;
     IGRlong rc, owner_index = OM_K_MAXINT;
     IGRpoint plane_point,elem_pln_pt;
     IGRvector elem_pln_nrml;
     IGRdouble dotp;
     struct GRid bool;
     struct IGRplane element_pln;
     struct EMSobject_info *parents;
     struct EMparms parms;

     parents = (struct EMSobject_info *)
               alloca(sizeof(struct EMSobject_info) * 2);
     parents[0].grid.objid = my_id;
     parents[0].grid.osnum = OM_Gw_current_OS;
     parents[0].env = *my_env;
     parents[1] = *parent;
     element_pln.point = elem_pln_pt;
     element_pln.normal = elem_pln_nrml;
/*
 * Get the natural normal of the plane and the pos orient bit.
 * and see if it is opposite to the side being save as indicated
 * by the normal of the planar element (considering the natural
 * normal bit). The natural_normal property is a misnomer. This
 * indicates the normal direction as obtained by GRdetplane.
 */
       sts = om$send(msg = message EMSsurface.EMget_point_on_surface(EMmsg,
                          construct_list->env_info,0,1, plane_point, &parms),
                   targetid = surf_id,
                   targetos = OM_Gw_current_OS);
       EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);

       pos_option = EMS_GET_POS_ORIENT;
       sts = om$send (msg = message EMSsurface.EMalgnnrml(
                           EMmsg,
                           pos_option,
                           &pos_orient,
                           NULL,
                           NULL),
                   targetid = surf_id,
                   targetos = OM_Gw_current_OS);
       EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);

       if (!pos_orient)
       {
        for (i=0;i<3;i++)
          parms.normal[i] *= -1.0;
       }

       sts = om$send (msg = message GRvg.GRdetplane(EMmsg,
                            &parent->env.md_env.matrix_type,
                             parent->env.md_env.matrix,
                            &element_pln),
                      targetid = parent->grid.objid,
                      targetos = parent->grid.osnum);
       EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);

       BSnorvec(&rc, elem_pln_nrml);

       if (!natural_normal)
       {
        for (i=0;i<3;i++)
          elem_pln_nrml[i] *= -1.0;
       }

       dotp = elem_pln_nrml[0]*parms.normal[0] + 
              elem_pln_nrml[1]*parms.normal[1] +
              elem_pln_nrml[2]*parms.normal[2];

       if (dotp > 0)
       {
        sts = om$send (msg = message EMSsurface.EMrevorient(
                           EMmsg),
                   targetid = surf_id,
                   targetos = OM_Gw_current_OS);
        EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);
       }
     

     /* Hook up the sliced object (me) and the generated plane to the
        boolean object before calling init_assoc.  This will prevent the
        sliced object from being hooked up to the boolean on the
        father-child channel in init_assoc. */

     bool.objid = gmid;
     bool.osnum = OM_Gw_current_OS;

     if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
       ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;

     sts = om$send(msg = message GRconnector.GRrigidconn
                        (EMmsg, &bool, &owner_index),
                   targetid = my_id,
                   targetos = OM_Gw_current_OS);
     EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);

/*
 * Commented this out. pp 12/24/91
   The rigid connection of the surface to the owner is done by the boolean
   code. Doing this connection here causes problems while doing the save
   side operation on surfaces/composite surfaces.
     if (issolid)
     {
      sts = om$send(msg = message GRconnector.GRrigidconn
                        (EMmsg, &bool, &owner_index),
                   targetid = surf_id,
                   targetos = OM_Gw_current_OS);
      EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);
     }
*/

     sts = om$send(msg = message EMSassoc.EMinit_associative
                        (EMmsg,             /* return code */
                         EMS_no_const_assoc,/* options */
                         2,                 /* number of parents */
                         parents,           /* parent information */
                         EMS_ASbool_saveside,/* type of operation */
                         sizeof(IGRint),    /* size of info to store */
                         (IGRchar *)&natural_normal, 
                         construct_list),   /* construction parameters */
                   targetid = gmid);
     EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_Fail,wrapup);
   }

   bool_type = EMSbool_saveside;
   if(!issolid) options |= EMSsfbool_opt_OpenIntPossible |
			       EMSsfbool_opt_SingleTopology;
   sts = om$send(mode = OM_e_wrt_message, 
                 msg = message EMSsfboolean.EMboolean(EMmsg, mat_type, matrix,
			my_id, 1, &surf_id, construct_list, bool_type,
			options, NULL, intobj, auxobj, NULL, NULL),
                 targetid = gmid);
  }
 else
  {
   sts = om$construct(classid = issolid ? OPP_EMSslspltwsf_class_id
					: OPP_EMSsfspltwsf_class_id, 
			p_objid = &gmid);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   sts = om$send(msg = message EMSsfspltwsf.EMsplit_with_surface
			(EMmsg, construct_list, my_id, surf_id, 
			 options, NULL, my_env, NULL, intobj, auxobj, NULL, 
			 NULL), targetid = gmid);
  }

wrapup:

 if(sfgm) om$dealloc(ptr = sfgm);
 if(comps && (comps != compsbuf)) om$dealloc(ptr = comps);

 if( (!(1&*EMmsg&sts)) || (*EMmsg == EMS_I_NoIntersection))
  {
/*
 * If my rigid relationship bit is set then unset the same.
 * This is necessary from a cleanup viewpoint. Otherwise the
 * model is hosed. 
 * pp 01/24/92
 */
    if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
       ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;

/* end change */

    if(!IF_NULL_OBJID(surf_id) && surf_constructed_here)
     sts = om$send(msg = message GRgraphics.GRdelete
			(&rc,construct_list->env_info), 
			targetid = surf_id);
    if(!IF_NULL_OBJID(gmid))
     sts = om$send(msg = message Root.delete(TRUE),targetid = gmid);
  }
 else if(want_status_messages) ex$message(msgnumb = EMS_S_Done)

 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EMintplane_saveside");
 return(sts);
}

end implementation EMSsurface;
