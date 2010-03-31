class implementation Root;


/* algorithm for the surfaces of rib is similar to web, except that we create
 * side planes instead of surfaces of projection.

 ASSUMPTIONS:

 The "cv_plane_normal" is always referred to the "right side" normal to the 
 plane of the curve. Therefore, if a one-sided rib thickness is desired, no 
 matter which side of the rib-profile is chosen as the thickness direction for 
 the rib, the incoming dirction is always referred to the "right side" by 
 convention.

 NOTES:
 1. The following functions ALWAYS return success, and thus error check need not
    be done after them.
    BScrossp, BSdotp

 HISTORY

   NP  07/02/93   Creation.
   NP  10/06/93   Changed "EFget_projection_distance" to "EFget_dist_to_bounds"
                  and made it a global function so that "EFmodify_profile"
                  function can call it.
   NP  10/17/93   Changed arguments to "EFget_dist_to_bounds" and renamed 
                  function to "EFextend_to_bounds".
   NP  12/14/93   In case of a type 2 rib (web) that is placed as a no-extend 
                  the top surface of the rib (and bottom surface, if finite rib)
                  is/are always stitched to the composite side surface, so that
                  we return only ONE composite surface from the function that
                  generates a type 2 rib.  For reasons why, see notes in fn.
Aditya 03/30/95   Fix for TR#119525131. Modified error message checks in 
                  "EFcreate_type1_rib_surface" and "EFcreate_type2_rib_surface"
                  to clean up surfaces in 'wrapup' before erroring out.
                  Check for offset profile degeneracy included in function
                  "EFxform_and_project_curve". 
 */

#define LEFT  0
#define RIGHT 1

#define CURVE_EVAL_PARAMETER 0.5
#define PT_IN_VOLUME_FACTOR  3.0
#define NUM_INTERNAL_SAMPLES 3
 
/* The top surface for rib/web is created such that it extends 
 * "EXTRA_OFFSET_FACTOR * cht_tol" beyond the side surfaces, so as to get clean
 * (==> interior and not boundary) intersections between side and top surfaces.
 */
#define EXTRA_OFFSET_FACTOR 50.0

#define MAX_SURFACES 6    /* max surfaces possibly returned from this file*/


#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "ma.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h" /* for BSCONSTOFF*/
#include "EMSmsgdef.h" /* error codes */
#include "EMSconstruct.h" /* surface construction properties */
#include "emserr.h" /*error handler macro*/
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsmapdef.h"
#include "emsfeaopts.h"
#include "EMSprop.h"
#include "EMSopt.h"

/* math prototypes */

#include "maptsxfor.h"
#include "matrlmx.h"
#include "matypemx.h"
#include "maunitvc.h"

#include "bsptsoldtnw.h"
#include "bssfntoo.h"
#include "bssfoton.h"
#include "bsmergarrcv.h"
#include "bsptonnsdsf.h"
#include "bscveval.h"
#include "bscvarrevt.h"
#include "bssfarrevn.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bspl_of_cv.h"
#include "bslngen.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsrevsf_u.h"
#include "bsproj1.h"
#include "bstrans1.h"
#include "bststcvfln.h"
#include "bststcvdegn.h"

from GRvg         import GRrigidconn, GRgeomprops, GRgetrang, GRgetsize; 
from GRvg         import GRchgprops, GRgetgeom;
from GRgraphics   import GRxform, GRcopy, GRconstruct, GRdelete;
from GRcurve      import EMcvoffset, GRendpts;
from EMSgenbs     import EMruled_surface;
from EMSproject   import EMplace_surface_of_projection;
from EMSsurface   import EMmk_nat_bdry, EMgetedges;
from GRcurve      import GRrevparm;
from GRcompcurve  import EMmakecomp;
from EMSedge      import EMset_props, EMget_bcxyz_geom;
from EMSloop      import EMget_props, EMset_props, EMreverse;
from EMSloopset   import EMset_props;
from EMSboundary  import EMget_edges;


extern OMuword  OPP_EMScomposite_class_id, OPP_EMSprjcompsf_class_id;
extern OMuword  OPP_EMSplane_class_id, OPP_EMSloopset_class_id;

extern IGRboolean rlw_get_better_line();
extern void EFget_components();
extern IGRlong EMmake_chanselect(), EMgetvggeom(), EFsspbtol_by_geom();
extern void EFclassify_degenerate_edges();

/* function defined in this file itself */
IGRlong 	  EFextend_to_bounds();


%safe
static IGRlong 	  EFxform_and_project_curve();
static void       EFcreate_planar_surface();
static void       EFcap_surface_with_plane();
%endsafe

/* CREATE TYPE 1 RIB SURFACES (Thickness perependicular to profile plane)*/

#argsused
IGRlong EFcreate_type1_rib_surfaces(
     EFmsg,
     options,
     construct_list,
     cv, /* id of comp.cv.(extended profile) of web/rib */
     cv_env, /* mod env of cv.(extended profile) of web/rib */
     cv_plane_normal, /* normal to plane of curve */
     symmetric, /*whether the rib is symmetric */
     extend_profile, /*whether the rib is no-extend/extend type */
     flip_thickness_side, /* whether "cv_plane_normal" needs to be flipped to
                           * get the thickness side (default dir for thk. is 
                           * "cv_plane_normal").
                           */
     flip_proj_side,/* default projection side/dir is "TxN", where T is curve 
                     * tangent and N is the "cv_plane_normal". If true, then
                     * sign of TxN is reversed, so that material side is now
                     * reversed.
                     */
     thickness, /* i.e. thickness of rib */
     rib_proj_distance, /* if non-NULL, finite rib is assumed */
     solid_id, /* id of parent solid */
     num_feasfs, 
     feasfs) /* "feasfs" array has to be freed by CALLER */ 
IGRlong		*EFmsg, options;
struct GRid	*cv;
IGRboolean      extend_profile, symmetric, flip_thickness_side, flip_proj_side;
IGRdouble	thickness, *rib_proj_distance;
IGRvector	cv_plane_normal;
struct GRvg_construct  *construct_list;
struct GRmd_env *cv_env;
struct GRid 	*solid_id, **feasfs;
IGRint          *num_feasfs;
{

BSrc		rc;
IGRlong		sts, msg_loc, cv_size;
IGRboolean	success;
IGRboolean	finite_rib, reverse_parametrization, rational;
IGRmatrix	xform_mat;
IGRshort	mat_type, xform_mattype;
struct GRid	loc_cv_rev, offset_cv, loc_cv, *curr_sf;
struct GRid     feasfs_loc[MAX_SURFACES];
struct GRmd_env *md_env;
IGRvector	unit_thk_vector, cv_plane_unit_normal, xform_vec;
IGRvector	left_unit_vector,right_unit_vector,proj_vector;
IGRvector	nat_normal;
IGRvector       profile_curve_tangent;
IGRint		i,j,k,num_feasfs_loc, num_parameters;
IGRpoint	pt_in_volume;
IGRpoint	tangent_pts[1][2];
IGRdouble       *mat, *unit_vector, cht_tol, dist, basis_tol;
IGRdouble       parameter;
IGRdouble       left_offset, extra_offset=0, top_sf_proj_dist;
IGRdouble       tempx, tempy, tempz, weight;
IGRdouble       unit_rot_mat[3][3];
struct IGRbsp_curve *curve_geom, **xform_cv_geom;
struct IGRbsp_curve *left_curve, *right_curve;
GRspacenum      construct_os;
OMuword		curve_class_id;
OM_S_CHANSELECT to_components;
IGRint		num_curves=0, *off_code;

sts    = OM_S_SUCCESS;
*EFmsg = EMS_S_Success;

finite_rib     = rib_proj_distance? TRUE : FALSE;

md_env   = construct_list->env_info;
mat      = md_env->md_env.matrix;
mat_type = md_env->md_env.matrix_type;
construct_os = md_env->md_id.osnum;

/*get the current chord height and basis tol*/
BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
BSEXTRACTPAR(&rc, BSTOLBASIS, basis_tol);



/*INITIALIZE. IMPORTANT. CHECKED BEFORE DELETING */

num_feasfs_loc     = 0; /* at start */
*num_feasfs        = 0; /* at start */
*feasfs            = NULL; /* not alloced yet*/

offset_cv.objid    = NULL_OBJID;
offset_cv.osnum    = construct_os;
loc_cv_rev.objid   = NULL_OBJID;
loc_cv_rev.osnum   = construct_os;
loc_cv.objid       = NULL_OBJID;
loc_cv.osnum       = construct_os;

for (i=0; i<MAX_SURFACES; i++)
{
  feasfs_loc[i].objid = NULL_OBJID;
  feasfs_loc[i].osnum = construct_os;
}
 
/* make sure array pointer has been input */
EMerr_hndlr (!feasfs, *EFmsg, EMS_E_InvalidArg, wrapup);

/* normalize the plane normal */
success = MAunitvc( &msg_loc, cv_plane_normal, cv_plane_unit_normal);
EMerr_hndlr ((msg_loc!= MSSUCC) || !success, *EFmsg, EMS_E_Fail, wrapup);

/* make a copy of the incoming profile/composite curve, in the module 
 * environment defined by the construct list.
 */
sts = om$send (msg= message GRgraphics.GRcopy(
                                         &msg_loc,
                                         cv_env,
                                         (struct GRmd_env *)md_env,
                                         &(loc_cv.objid)),
                      senderid=NULL_OBJID,
                      targetid=cv->objid,
                      targetos=cv->osnum);
EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);


/* If this is a finite rib, we need some information about the number of 
 * components in the composite curve so tht we can create an array of offset 
 * codes. This will be used later, while offsetting the curve.
 */
if (finite_rib)
{
   /* get classid of input curve (or its copy)*/
   sts = om$get_classid (osnum     = loc_cv.osnum,
                         objid     = loc_cv.objid,
                         p_classid = &curve_class_id);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);
   
   /* find out if it is a composite curve */
   sts = om$is_ancestry_valid (subclassid   = curve_class_id,
                               superclassid = OPP_EMScomposite_class_id);
   EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);
   
   /* if comp. cv, find number of component curves */
   if (sts == OM_S_SUCCESS)
   { /* Set up the channel select */
      sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
      EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);
   
      /* Get number of components */
      num_curves=0;
      sts = om$get_channel_count(p_chanselect = &to_components,
                                 objid        = loc_cv.objid,
                                 osnum        = loc_cv.osnum,
                                 count        = (OMuint *) (&num_curves));
   }
   else /* ==> single curve */
     num_curves = 1;
   
   /* declare an array of "off_codes" for the offset. Each curve will have the
    * same value (BSCONSTOFF) of offset_type.
    */
   off_code = (IGRint *) alloca (sizeof (IGRint) * num_curves);
   for (i=0; i<num_curves; i++)
     off_code[i] = BSCONSTOFF;
   
}



/*get the size of the curve */
sts = om$send (msg = message GRvg.GRgetsize(&msg_loc,
                        &mat_type,
                        mat,&cv_size),
                senderid = NULL_OBJID,
                targetid = loc_cv.objid,
                targetos = loc_cv.osnum);
EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EFmsg, EMS_E_Fail, wrapup);

curve_geom  = (struct IGRbsp_curve *) alloca (cv_size);



/*Get the geometry of the curve*/
sts = om$send (msg = message GRvg.GRgetgeom( &msg_loc,
                          &mat_type, 
                          mat,
                          (IGRchar *)(curve_geom)),
                senderid = NULL_OBJID,
                targetid = loc_cv.objid,
                targetos = loc_cv.osnum);
EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EFmsg, EMS_E_Fail, wrapup);

  /* evaluate the thickness vector and the projection vector. Calculate the
   * "tangent" vector and the "right-side normal" vector of the profile at its
   * mid-pt (for want of a better point). Also calculate the "plane-normal" of
   * the profile plane by crossing "tangent" with "right-side normal".
   *
   * Profile plane normal = "plane-normal"
   * Tangent to profile   = "prof_tangent"
   * Normal to profile    = "prof_normal"
   *
   * STEPS: 1. Get the normal of the ref. plane attached to the profile.
   *           If not profile,  we might have a FLIPPING PROBLEM!!!!!!!!
   *        2. Apply flip factor ("flip_thk" for rib, "flip_proj_side" for web)
   *           to get the final "plane-normal".
   *        3. Get the tangent to the profile at any point (say start pt).
   *        4. Cross the tangent with the ref. plane normal to create the
   *           "right_side normal".
   *        5. Apply flip factor ("flip_proj_side" for rib, "flip_thk" for web)
   *           to the the final "right_side normal".
   *        6. For "web_type" -> "right-side normal" is the "thk_vector"
   *                             "plane-normal" is the "proj_vector"
   *           For "rib_type" -> "right-side normal" is the "proj_vector"
   *                             "plane-normal" is the "thk_vector"
   */
/* evaluate a tangent to the curve at its mid-pt (other pts also will do). It
 * is important that the next set of tangents, normals, thk vectors all be
 * evaluated at the SAME point.
 */

parameter = CURVE_EVAL_PARAMETER;
num_parameters = 1;

BScvarrevt(curve_geom,&parameter,num_parameters,1.0,tangent_pts,&rc);
EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

for (i=0; i<3; i++)
    profile_curve_tangent[i] = tangent_pts[0][1][i] - tangent_pts[0][0][i];

/*normalize the curve tangent*/
success = BSnorvec(&rc,(IGRdouble *)profile_curve_tangent);
EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

for (i=0; i<3; i++)
    unit_thk_vector[i]=(flip_thickness_side? -1.0:1.0)*cv_plane_unit_normal[i];

 
/* ----------------------------------------------------------------*/
/* ----------------------------------------------------------------*/
/* calc. the cross product of curve tangent and curve plane normal. This
 * is the "right_side" normal of the profile curve, which is the default
 * projection-side.
 */
success =  BScrossp(&rc,profile_curve_tangent, cv_plane_unit_normal,
                   proj_vector);

if (flip_proj_side)
{
    for (i=0; i<3; i++)
       proj_vector[i] = -proj_vector[i];
}

success = BSnorvec(&rc,(IGRdouble *)proj_vector);
EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

/* find a POINT IN VOLUME used to orient the surfaces later. We evalualte the
 * curve at a point. We then offset that point a small amount 
 * along the unit "proj_vector" and a similar amount in the direction
 * of the thickness vector, to get the point in volume.
 */
BScveval(curve_geom,CURVE_EVAL_PARAMETER,0,&pt_in_volume,&rc);
EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

for (i=0; i<3; i++)
  pt_in_volume[i] += PT_IN_VOLUME_FACTOR * cht_tol * 
                            (proj_vector[i]+unit_thk_vector[i]);

/* While creating the top surface, we translate the curve in the opposite dir of
 * the thk vector and then project the curve by distance equal to thickness,
 * along the thickness vector. The cross product of the curve tangent and the 
 * thickness vector and will be the NATURAL normal to the resultant surface.
 * We want this natural normal to point into VOLUME.
 * We already have a "proj_vector" which denotes volume direction. Therefore
 * if the cross product above is in the direction of the "proj_vector", we are 
 * fine, else we need to reverse the normal of the surface, which is equivalent
 * to reversing the parametrization of the curve, before we project it.
 */

success =  BScrossp(&rc,profile_curve_tangent, unit_thk_vector, nat_normal);

reverse_parametrization = (BSdotp(&rc,nat_normal,proj_vector) < 0.0)?TRUE:FALSE;

/* we will need the reversed curve for creating the bottom surface */
if (reverse_parametrization || finite_rib)
{
   /* make a copy of the current curve and reverse its parametrization */
   loc_cv_rev.osnum = loc_cv.osnum;
   sts = om$send (msg      = message GRgraphics.GRcopy(
                               &msg_loc, md_env, md_env, &(loc_cv_rev.objid)),
                  senderid = NULL_OBJID,
                  targetid = loc_cv.objid,
                  targetos = loc_cv.osnum);
   EMerr_hndlr (!(1&sts) || (msg_loc!=MSSUCC), *EFmsg, EMS_E_Fail, wrapup);


   sts = om$send (msg      = message GRcurve.GRrevparm(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = loc_cv_rev.objid,
                  targetos = loc_cv_rev.osnum);
   EMerr_hndlr (!(1&sts) || (msg_loc!=MSSUCC), *EFmsg, EMS_E_Fail, wrapup);

}

/* ----------------------------------------------------------------*/
/* ----------------------------------------------------------------*/


/* Now we create the right and left unit vectors. The "left_unit_vector" is 
 * anti-parallel to the thickness vector and the "right_unit_vector" is the 
 * same as the thickness vector.
 */

for (i=0; i<3; i++)
  right_unit_vector[i] = unit_thk_vector[i];

for (i=0; i<3; i++)
  left_unit_vector[i] = -1.0 * unit_thk_vector[i];

/* create a unit rotation matrix */
for (i=0; i<3; i++)
{ for (j=0; j<3; j++)
  {  if (i==j)
      unit_rot_mat[i][j] = 1.0;
     else 
       unit_rot_mat[i][j]=0.0;
  }
}


/* CREATE LEFT AND RIGHT SIDE SURFACES */
for (i=0; i<2; i++)
{
  /* i==0 is LEFT and i==1 is RIGHT*/

  curr_sf      = &(feasfs_loc[num_feasfs_loc++]);
  xform_cv_geom = (i==0) ? &left_curve : &right_curve;

  /* calc. distance to translate range of curve to the left/right */
  dist = (symmetric? thickness/2.0 : (i==LEFT? 0:thickness));
  
  /* set the unit vector to the correct side */
  unit_vector = (IGRdouble *)(i==LEFT? left_unit_vector : right_unit_vector);

  for (j=0; j<3; j++)
    xform_vec[j]   = dist * unit_vector[j];
  
  
  /* allocate memory for copied and transformed curve*/
  *xform_cv_geom = (struct IGRbsp_curve *) alloca (sizeof(struct IGRbsp_curve));
  (*xform_cv_geom)->poles   = (IGRdouble *) alloca (sizeof(IGRpoint) * 
                                             curve_geom->num_poles);
  (*xform_cv_geom)->knots   = (IGRdouble *) alloca (sizeof(IGRdouble) * 
                                             curve_geom->num_knots);
  (*xform_cv_geom)->weights = (curve_geom->weights? 
                                (IGRdouble *) alloca (sizeof(IGRdouble) * 
                                          curve_geom->num_poles) : NULL);
     
  success =  BScv_copy(&rc,curve_geom,*xform_cv_geom);
  EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

  /* TRANSLATE THE CURVE USING XFORM_VEC */
  
  rational = (*xform_cv_geom)->weights ? TRUE : FALSE;
  for(j=0,k=0; j< curve_geom->num_poles; j++, k+=3)
  {
     weight= rational ? (*xform_cv_geom)->weights[j] : 1.0;

     tempx = (*xform_cv_geom)->poles[k]   / weight;
     tempy = (*xform_cv_geom)->poles[k+1] / weight;
     tempz = (*xform_cv_geom)->poles[k+2] / weight;

     (*xform_cv_geom)->poles[k]   = (tempx + xform_vec[0]) * weight;
     (*xform_cv_geom)->poles[k+1] = (tempy + xform_vec[1]) * weight;
     (*xform_cv_geom)->poles[k+2] = (tempz + xform_vec[2]) * weight;
  }

  (void) EFcreate_planar_surface (&msg_loc, construct_list, *xform_cv_geom, 
                                 proj_vector, solid_id, pt_in_volume, curr_sf);
  EMerr_hndlr (!(1&msg_loc) || (curr_sf->objid == NULL_OBJID), 
                  *EFmsg, EMS_E_Fail, wrapup);

 /* make natural boundaries for the planes */
  sts = om$send (msg = message EMSsurface.EMmk_nat_bdry (
                             &msg_loc, &(md_env->md_env), NULL),
                senderid = NULL_OBJID,
                targetid = curr_sf->objid,
                targetos = curr_sf->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);

}/*for*/

/* CREATE TOP AND BOTTOM SURFACES */
  
/* The surfaces are created such that they extend a little beyond the left and
 * the right surfaces, so as to create clean intersections (intersections in
 * the interior of the surface and not at the edges). Translate the 
 * curve(s) in the -ve dir of thk vector and project it by the
 * specified distance to create the surface of projection on top.
 */

left_offset  = symmetric? thickness/2.0 : 0 ;
BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);
extra_offset     = EXTRA_OFFSET_FACTOR * cht_tol;
left_offset     += extra_offset;
top_sf_proj_dist = thickness + 2 * extra_offset;

/* create a transformation matrix to translate to the "left" by the amount 
 * specified by "left_offset" in the NEGATIVE direction of the 
 * "thickness vector". Then the curve is projected by the distance 
 * specified by "top_sf_proj_dist" in the direction specified by 
 * "thickness vector" 
 */

for (j=0; j<3; j++)
   xform_vec[j] =  -1.0 * unit_thk_vector[j] * left_offset;

success = MAtrlmx(&msg_loc, xform_vec,(IGRdouble *)xform_mat);
EMerr_hndlr (!success || (msg_loc!=MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

/* find out the type of the matrix */
success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattype);
EMerr_hndlr (!success || (msg_loc!=MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

/* CREATE TOP SURFACE */

/* create the top surface by translating and projecting the curve */
sts = EFxform_and_project_curve (&msg_loc, NULL, construct_list, xform_mat,
                                 &xform_mattype, 
                                 reverse_parametrization?&loc_cv_rev:&loc_cv, 
                                 md_env, &top_sf_proj_dist, 
                                 unit_thk_vector, 
                                 &(feasfs_loc[num_feasfs_loc++]));
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);


/* CREATE BOTTOM SURFACE */
/* use same transform matrices as above. */
if (finite_rib)
{
   /* Offset the curve in the direction of VOLUME (dir of proj. vector). This
    * curve, when transformed and projected like above, will create the bottom
    * surface. Also, since the cross product of the "curve tangent" and the 
    * "thk vector" is the "proj vector", the curve is "offset-right" with 
    * respect to those two vectors.  But now the offset cv has to be reversed.
    * The parametrization of the curve for the bottom surface has to be 
    * OPPOSITE of that for the top surface, since the natural normals (which is
    * the volume side normals here) of the two should point in opposite 
    * directions. Therefore, instead of offsetting an then reversing the curve,
    * we offset the reversed curve (however, it should now be "offset left").
    * The curve that we choose for offsetting is the REVERSE of the one used in
    * the projection of top surface.
    */
    sts = om$send (msg= message GRcurve.EMcvoffset(&msg_loc,
                            &mat_type, mat, construct_list,
                            rib_proj_distance,
                            unit_thk_vector,
                            FALSE,
                            TRUE, off_code,
                            FALSE, TRUE,
                            &offset_cv,
                            NULL,NULL,NULL),
           senderid = NULL_OBJID,
           targetid = reverse_parametrization? loc_cv.objid : loc_cv_rev.objid,
           targetos = reverse_parametrization? loc_cv.osnum : loc_cv_rev.osnum);
    EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

   /* create the bottom surface by translating and projecting the offset curve 
    * using the same matrices and dist as the top surface.
    */
   sts = EFxform_and_project_curve (&msg_loc, NULL, construct_list, xform_mat,
                                 &xform_mattype, 
                                 &offset_cv, 
                                 md_env, &top_sf_proj_dist, 
                                 unit_thk_vector, 
                                 &(feasfs_loc[num_feasfs_loc++])/*bottom_sf*/);
   EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
    
   /* this surface will already HAVE natural boundaries (DOUBLE CHECK THIS)*/
}


/* send the surface info back*/
if (feasfs)
{
  *num_feasfs = num_feasfs_loc;
  *feasfs = (struct GRid *) om$malloc (size = sizeof(struct GRid) * 
                                          num_feasfs_loc);
  for (i=0; i< num_feasfs_loc; i++)
  {
     (*feasfs)[i] = feasfs_loc[i];
  }
}

wrapup:


/* DO NOT ADD CODE BETWEEN THIS LINE AND WRAPUP ABOVE. THIS IS SO THAT "msg_loc"
 * CAN CONTINUE TO REPRESENT AN ERROR FROM THE CODE, AND NOT FROM ANYTHING DONE
 * IN WRAPUP.
 *
 * On error, delete ANY surface objects created
 */

if (!(1&msg_loc&sts))
{
   for (i=0; i<num_feasfs_loc; i++)
   {
     /* check if it is NULL_OBJID. Counter "num_feasfs_loc" gets incremented
      * before surface creation.
      */
     if (feasfs_loc[i].objid != NULL_OBJID)
     {
       sts = om$send (msg  = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = feasfs_loc[i].objid,
                  targetos = feasfs_loc[i].osnum);
     }

   }

}/*if*/
  /* delete the copy of the profile composite curve */
  if (loc_cv.objid != NULL_OBJID)
  {  sts = om$send (msg      = message GRgraphics.GRdelete (&msg_loc, md_env),
                    senderid = NULL_OBJID,
                    targetid = loc_cv.objid,
                    targetos = loc_cv.osnum);
  }
  
  /* delete the reversed copy of the copy of the profile composite curve */
  if (loc_cv_rev.objid != NULL_OBJID)
  {  sts = om$send (msg      = message GRgraphics.GRdelete (&msg_loc, md_env),
                    senderid = NULL_OBJID,
                    targetid = loc_cv_rev.objid,
                    targetos = loc_cv_rev.osnum);
  }
  
  /* delete the offset curve craeted for bottom surface generation */
  if (offset_cv.objid != NULL_OBJID)
  {  sts = om$send (msg      = message GRgraphics.GRdelete (&msg_loc, md_env),
                    senderid = NULL_OBJID,
                    targetid = offset_cv.objid,
                    targetos = offset_cv.osnum);
  }
  EMWRAPUP (*EFmsg, sts, "In EFcreate_type1_rib_surfaces");
  return (sts);


}/* end of "EFcreate_type1_rib_surfaces"*/


/*----------------------------------------------------------------------------*/

/* CREATE TYPE 2 RIB SURFACES (Thickness in profile plane) */

#argsused
IGRlong EFcreate_type2_rib_surfaces(
     EFmsg,
     options,
     construct_list,
     cv, /* id of comp.cv.(extended profile) of web/rib */
     cv_env, /* mod env of comp.cv.(extended profile) of web/rib */
     cv_plane_normal, /* normal to plane of curve */
     symmetric, /* whether the rib is symmetric */
     extend_profile, /* whether user expects rib profile to be extended */
     closed_profile, /* whether profile is closed */
     flip_thickness_side,/* default thickness side/dir is "TxN", where T is 
                          * curve tangent and N is the "cv_plane_normal". If 
                          * true, then sign of TxN is reversed, so that material
                          * side is now reversed.
                          */
     flip_proj_side,  /* whether "cv_plane_normal" needs to be flipped to
                       * get the projection side (default dir for proj. is
                       * "cv_plane_normal").
                       */
     thickness, /* i.e. thickness of web */
     rib_proj_distance, /* if non-NULL, finite rib is assumed*/
     solid_id, /* id of parent solid */
     num_feasfs,
     feasfs, /* "feasfs" array has to be freed by CALLER */ 
     num_caps)
IGRlong		*EFmsg, options;
struct GRid	*cv, **feasfs;
IGRdouble	thickness, *rib_proj_distance;
IGRvector	cv_plane_normal;
struct GRvg_construct  *construct_list;
struct GRid 	*solid_id;
struct GRmd_env *cv_env;
IGRboolean      symmetric, extend_profile, flip_thickness_side, flip_proj_side;
IGRboolean      closed_profile;
IGRint          *num_caps, *num_feasfs;
{

BSrc		rc;
IGRint          seg_type, num_feasfs_loc;
IGRlong         num_pts, rotten_one;
IGRlong		sts, msg_loc, msg_del;
IGRboolean	found_sf, nat_side, success, offset_left, offset_right;
IGRmatrix	xform_mat;
IGRshort	mat_type, xform_mattype;
struct GRid	loc_cv, left_offset_cv, right_offset_cv; 
struct GRid     *offset_cv, *curr_sf, top_left_cv, top_right_cv;
struct GRid     top_sf, bottom_sf, feasfs_loc[MAX_SURFACES];
struct GRid     new_cv, start_seg_cv, end_seg_cv, single_side_sf;
struct GRid     new_compsf;
GRobjid         objid;
struct GRmd_env *md_env;
struct GRprops  props; 
struct GRlc_info comp_ids[4];
IGRvector	cv_plane_unit_normal, proj_vector, xform_vec;
IGRvector	unit_thk_vector, profile_curve_tangent;
IGRint		i, num_curves=0, *off_code, num_parameters;
IGRpoint	start_pt, ext_pt, junkpt;
IGRpoint	lf_cv_pts[2], rt_cv_pts[2];
IGRpoint	pt_in_volume, tangent_pts[1][2];
IGRdouble       *mat, cht_tol, offset_dist;
IGRdouble       parameter,proj_dist,poles1[6],poles2[6],knots1[4],knots2[4];
IGRdouble       proj_dist_single_side_sf;
IGRdouble       sf_poles0[12], u_knots0[4], v_knots0[4];
IGRdouble       sf_poles1[12], u_knots1[4], v_knots1[4];
IGRdouble       start_seg[6], end_seg[6];

OMuword		curve_class_id;
OM_S_CHANSELECT to_components;
struct IGRbsp_curve *curve_geom;
struct IGRbsp_curve seg1, seg2, *cvs[4], *merged_cv;
struct IGRbsp_curve *left_curve_geom, *right_curve_geom;
struct IGRbsp_surface top_pln_sf, bottom_pln_sf;
IGRboolean      reverse_curve, finite_rib;
IGRboolean      closed_curve, single_closed_side_surface;
GRspacenum      construct_os;
IGRlong		cv_size;

sts    = OM_S_SUCCESS;
*EFmsg = EMS_S_Success;

BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);

finite_rib    = rib_proj_distance ? TRUE : FALSE;

md_env       = construct_list->env_info;
mat          = md_env->md_env.matrix;
mat_type     = md_env->md_env.matrix_type;
construct_os = md_env->md_id.osnum;

/* IMPORTANT INITIALIZATIONS, CHECKED AT WRAPUP */

num_feasfs_loc     = 0; /* at start */
*num_feasfs        = 0; /* at start */
*feasfs            = NULL; /* not alloced yet*/
*num_caps          = 0; /* assume */

loc_cv.objid          = NULL_OBJID;
loc_cv.osnum          = construct_os;
top_left_cv.objid     = NULL_OBJID;
top_left_cv.osnum     = construct_os;
top_right_cv.objid    = NULL_OBJID;
top_right_cv.osnum    = construct_os;
left_offset_cv.objid  = NULL_OBJID;
left_offset_cv.osnum  = construct_os;
right_offset_cv.objid = NULL_OBJID;
right_offset_cv.osnum = construct_os;
new_cv.objid          = NULL_OBJID;
new_cv.osnum          = construct_os;
single_side_sf.objid  = NULL_OBJID;
single_side_sf.osnum  = construct_os;
single_closed_side_surface = FALSE;

for (i=0; i<MAX_SURFACES; i++)
{
  feasfs_loc[i].objid = NULL_OBJID;
  feasfs_loc[i].osnum = construct_os;
}

/* If this is a "no-extend-profile" type of rib, then two side surfaces, a top
 * surface (& possibly bottom surface)  will NOT be enough to create a solid, 
 * since there will be gaps at the ends of the profile, for which we have
 * NOT created surfaces. In case of extended profiles, this is not a problem, 
 * because they are extended to the bounding box of the solid, and the ends 
 * will be closed by surfaces of the solid. In the no-extend case too, it would
 * be allright if the profile were closed. It is the open-profile, no-extend
 * case that is the killer!!!!!! Therefore, what we do in here for such cases 
 * is to offset the open profile on both sides as necessary, create a CLOSED
 * curve by joining their end points with line segments, and then project this
 * closed curve to create only ONE side surface, which is now closed in one
 * direction.
 * 12/10/93: Further to above, in case of a open-profile, no-extend case, we 
 * --------  need to stitch the top (and bottom surface, if finite rib) to the
 * single closed side surface, to handle boolean intersection algorithm 
 * robustly. Here is why: if the profile lies on an edge of the solid, then, 
 * there is a possibility of 2 surface from the base solid and two surfaces from
 * the rib meeting along an edge. In a regular boolean, the two rib surfaces can
 * be imagined to be part of a solid (or at least part of a composite surface).
 * Since ONE intersection is retained along every edge of either operand of a 
 * boolean, the result will be that only ONE of the rib surfaces should have an
 * intersection. Even if the intersection is retained on the WRONG surface (due
 * to the arbitrary nature of deletion of duplicate intersections across 
 * surfaces), we still have post-processing (fixing) code in the intersection 
 * algorithm that detects this and pushes the intersection to the corrrect 
 * surface across the common-edge. Now THIS is the key. Since we are creating 
 * rib surfaces independently of each other (i.e. side surface and top are 
 * separate surfaces) there is no common edge to push across. The common edges
 * are generated at the very end of the rib algorithm. Therefore, at the 
 * intersection stage we are faced with the possibility of an intersection on 
 * the wrong surface (or worse, missing intersection on the correct surface, 
 * which is more dangerous, since we will not be able to close groups and will
 * have to fail). Since the duplicate intersection deletion is arbitrary, we MAY
 * or MAY NOT succeed. To avoid this proble, we STITCH the top plane (and bottom
 * plane if necessary) to the single closed side surface. This way, we are 
 * guaranteed to generate the intersection on the correct rib surface. 
 *
 *    The story does not unfortunately end here. Another important part of the
 * rib algorithm is in the "marking" of intobjs on the rib surfaces. These 
 * intobjs are the ones that we know MUST be kept to close the correct groups.
 * These are found by offsetting of the input profile by the thickness
 * (if one-sided rib) or by half the thickness (symmetric rib) so that they are
 * coincident with intobjs that will eventually be the common edge between the 
 * top surface and the side surfaces of the rib. herein lies the problem !!!!!!!
 * Since we have already MADE the common edge connections already, there are 
 * no intobjs that are coincident with the offsets of the profiles (if the top
 * surface were separate, we would have intersected the top and side surfaces to
 * generate these intobs). Not having the "marked" intobjs, it becomes an 
 * impossible task to figure out which of the possibly many closed intersection
 * groups (on the rib surfaces) need to be kept and which ones deleted. 
 * THEREFORE, we resort to an undoing of what we did above. i.e. once we are 
 * past the stage where we generate intersections with the base solid, we 
 * simply disconnect the common edges between the top and side surfaces and 
 * pretend as if they had never been connected. The subsequent intersections 
 * between the top and side surfaces will generate the intobjs that will later
 * get "marked".
 *
 * Note that this is only if the profile is open and it is a no-extend case. In
 * all other cases, we will generate huge surfaces upto and a little beyond the
 * bounding box and the 4-surfaces-meeting-at-edge problem will NEVER come up.
 *
 * In case this is a finite rib, then by capping the side surface we are really 
 * getting a solid, but we simply consider it as a composite surface, which
 * works fine for us.
 */ 
 
 /* send GRgeomprops message to the curve to find out if it is CLOSED or OPEN.*/

sts = om$send (msg = message GRvg.GRgeomprops(&msg_loc,
                               &(cv_env->md_env.matrix_type), 
                               cv_env->md_env.matrix, &props),
                senderid = NULL_OBJID,
                targetid = cv->objid,
                targetos = cv->osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

closed_curve = props.phy_closed; 

if (!extend_profile &&  !closed_curve)
   single_closed_side_surface=TRUE;
else
   single_closed_side_surface=FALSE;





/* normalize the plane normal */
success = MAunitvc( &msg_loc, cv_plane_normal, cv_plane_unit_normal);
EMerr_hndlr ((msg_loc!= MSSUCC) || !success, *EFmsg, EMS_E_Fail, wrapup);


/* make a copy of the incoming profile/composite curve, in the module
 * environment defined by the construct list.
 */
loc_cv.osnum   = construct_os;
loc_cv.objid   = NULL_OBJID;
sts = om$send (msg= message GRgraphics.GRcopy(
                                         &msg_loc,
                                         cv_env,
                                         (struct GRmd_env *)md_env,
                                         &(loc_cv.objid)),
                      senderid=NULL_OBJID,
                      targetid=cv->objid,
                      targetos=cv->osnum);
EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);

/*get the size of the copied curve */
sts = om$send (msg = message GRvg.GRgetsize(&msg_loc,
                        &mat_type,
                        mat,&cv_size),
                senderid = NULL_OBJID,
                targetid = loc_cv.objid,
                targetos = loc_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

curve_geom  = (struct IGRbsp_curve *) alloca (cv_size);

/*Get the geometry of the copied curve*/
sts = om$send (msg = message GRvg.GRgetgeom( &msg_loc,
                          &cv_env->md_env.matrix_type,
                          cv_env->md_env.matrix,
                          (IGRchar *)(curve_geom)),
                senderid = NULL_OBJID,
                targetid = loc_cv.objid,
                targetos = loc_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

/* evaluate a tangent to the curve at its mid-pt (other pts also will do). It
 * is important that the next set of tangents, normals, thk vectors all be
 * evaluated at the SAME point.
 */

parameter = CURVE_EVAL_PARAMETER;
num_parameters = 1;

BScvarrevt(curve_geom,&parameter,num_parameters,1.0,tangent_pts,&rc);
EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

for (i=0; i<3; i++)
    profile_curve_tangent[i] = tangent_pts[0][1][i] - tangent_pts[0][0][i];

/*normalize the curve tangent*/
success = BSnorvec(&rc,(IGRdouble *)profile_curve_tangent);
EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

/* calc. the projection vector */
for (i=0; i<3; i++)
    proj_vector[i]=(flip_proj_side? -1.0:1.0)*cv_plane_unit_normal[i];

/* ----------------------------------------------------------------*/
/* ----------------------------------------------------------------*/
/* calc. the cross product of curve tangent and curve plane normal. This
 * is the "right_side" normal of the profile curve, which is the default
 * thickness direction.
 */
success =  BScrossp(&rc,profile_curve_tangent, cv_plane_unit_normal,
                   unit_thk_vector);

if (flip_thickness_side)
{
    for (i=0; i<3; i++)
       unit_thk_vector[i] = -unit_thk_vector[i];
}

success = BSnorvec(&rc,(IGRdouble *)unit_thk_vector); /* NEEDED?*/
EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

/* find a POINT IN VOLUME used to orient the surfaces later. We evalualte the
 * curve at a point. We then offset that point a small amount 
 * along the unit "proj_vector" and a similar amount along the thickness vector
 * to get the point in volume.
 */
BScveval(curve_geom,CURVE_EVAL_PARAMETER,0,&pt_in_volume,&rc);
EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

for (i=0; i<3; i++)
  pt_in_volume[i] += PT_IN_VOLUME_FACTOR * cht_tol * 
                             (proj_vector[i]+unit_thk_vector[i]);


/* Create a matrix to translate the offset curves (left & right curves) by
 * a certain amount (default to 10*cht_tol here) in the -ve direction of the 
 * projection vector. This will be used down below. This is so that when we 
 * intersect the top and side surfaces, we find clean interior intersections, 
 * instead of intersections along the boundaries. 
 *
 *   BUT, if we need a single closed side surface (which needs to be capped by
 * the top plane), we better create it such that the end of the surface lies 
 * on the plane of the profile. Therefore, NO extention above the plane.
 */

if (single_closed_side_surface)
{
    MAidmx(&msg_loc,(IGRdouble *)xform_mat); /* always returns success*/
    xform_mattype = MAIDMX;
}
else
{
  /* create a vector opposite to the projection vector */
  for (i=0; i<3; i++)
    xform_vec[i] = -proj_vector[i];
  
  /* normalize it */
  success = BSnorvec(&rc,xform_vec);
  EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
  
  for (i=0; i<3; i++)
     xform_vec[i] *=  EXTRA_OFFSET_FACTOR * cht_tol;
  
  success = MAtrlmx(&msg_loc, xform_vec,(IGRdouble *)xform_mat);
  EMerr_hndlr (!success || (msg_loc!=MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
  
  /* find out the type of the matrix to pass into GRxform */
  success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattype);
  EMerr_hndlr (!success || (msg_loc!=MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
}


/* Create an array of offset codes needed by the method that offsets the 
 * composite curve.
 */

/* get classid of input curve (or its copy)*/
sts = om$get_classid (osnum     = loc_cv.osnum,
                      objid     = loc_cv.objid,
                      p_classid = &curve_class_id);
EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

/* find out if it is a composite curve */
sts = om$is_ancestry_valid (subclassid   = curve_class_id, 
                            superclassid = OPP_EMScomposite_class_id);
EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);

/* if comp. cv, find number of component curves */
if (sts == OM_S_SUCCESS)
{ /* Set up the channel select */
   sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
   EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);

   /* Get number of components */
   sts = om$get_channel_count(p_chanselect = &to_components,
                              objid        = loc_cv.objid, 
                              osnum        = loc_cv.osnum,
                              count        = (OMuint *) (&num_curves));
}
else /* ==> single curve */
  num_curves = 1;

/* declare an array of "off_codes" for the offset. Each curve will have the
 * same value (BSCONSTOFF) of offset_type.
 */
off_code = (IGRint *) alloca (sizeof (IGRint) * num_curves);
for (i=0; i<num_curves; i++)
  off_code[i] = BSCONSTOFF; 

/* CREATE LEFT AND RIGHT SIDE SURFACES */

/* T   = tangent of curve
 * N   = plane normal
 * TxN = "RIGHT" side normal in plane of curve. Offset along this vector is 
 *       offset RIGHT (this is the default).
 *
 * ONE_SIDED_RIB:
 *
 * If "flip_thickness_side" is TRUE, then the curve has to be offset LEFT,(with 
 * respect to TxN), which is the dir of thickness. If FALSE, curve is offset 
 * RIGHT (default).
 *
 * SYMMETRIC_RIB:
 *
 * Curve has to be offset RIGHT and LEFT both, by half the thickness.
 */

offset_left  = symmetric? TRUE : (flip_thickness_side? TRUE  : FALSE);
offset_right = symmetric? TRUE : (flip_thickness_side? FALSE : TRUE);
offset_dist  = symmetric? thickness/2.0 : thickness;

if (single_closed_side_surface)
   proj_dist_single_side_sf = MINDOUBLE; /* set at start */

for (i=0; i<2; i++)
{
  /* i==0 is for LEFT offset and i==1 is for RIGHT */

  /* if we need a "single_closed_side_surface", then we use this for loop
   * to only generate the offset curves from the original curve.
   */

  if (!single_closed_side_surface)
     curr_sf = &(feasfs_loc[num_feasfs_loc++]);


  offset_cv = (i==0? &left_offset_cv : &right_offset_cv);

  if (i==0?offset_left:offset_right)
  {
     sts = om$send (msg= message GRcurve.EMcvoffset(&msg_loc,
                            &mat_type, mat, construct_list, 
                            &offset_dist,
                            cv_plane_unit_normal,
                            (i==0? FALSE: TRUE), 
                            TRUE, off_code,
                            FALSE, TRUE, 
                            offset_cv, 
                            NULL,NULL,NULL),
                 senderid = NULL_OBJID,
                 targetid = loc_cv.objid,
                 targetos = loc_cv.osnum);
     EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
  }
  else /* ==> NO offset required.*/
  { 
    /* the offset (zero offset) is nothing but a copy of the original curve */
     
    offset_cv->osnum = loc_cv.osnum;
    sts = om$send (msg= message GRgraphics.GRcopy(
                   &msg_loc,
                   (struct GRmd_env *)md_env,
                   (struct GRmd_env *)md_env,
                   &(offset_cv->objid)),
               senderid=NULL_OBJID,
               targetid=loc_cv.objid,
               targetos=loc_cv.osnum);
    EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);


  }

  /* get the start point of the offset curve */
  sts = om$send (msg=message GRcurve.GRendpts (&msg_loc, &mat_type, mat,
                      start_pt, junkpt),
               senderid = NULL_OBJID,
               targetid = offset_cv->objid,
               targetos = offset_cv->osnum);
  EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  /* find the extent of projection necessary thro the solid (upto range box) */
  sts = EFextend_to_bounds (&msg_loc, md_env, start_pt, NULL, solid_id,
                             proj_vector, ext_pt);
  EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  /* find proj. dist*/
  proj_dist = BSdistptpt( &rc, start_pt, ext_pt);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_Fail, wrapup);

  /* store this for later, in case we need a single-side-surface*/
  if (proj_dist > proj_dist_single_side_sf)
    proj_dist_single_side_sf = proj_dist ;

  /* add the extra proj. dist needed due to translation done before projecting*/
  proj_dist += EXTRA_OFFSET_FACTOR * cht_tol;
 
  /* check if the curve needs to be reversed in parametrization, so that the
   * natural normal of the surface may point into the volume of the rib.
   * EXPLANATION:
   * The left and right offsets are with respect to TxN, T=curve tangent and
   * N=curve plane normal. Obviuosly, the offsets will be parametrized in the 
   * same dir as the orig. curve. Since the projection directions for both
   * offsets are the same, the natural normals will point in the same direction
   * too. We dont want that, because it means one of them will point OUTSIDE
   * the volume. Therefore, we need to reverse ONE of the offset curves. Which
   * one? To answer that question, we look at whether the proj direction is
   * in the same dir as curve plane normal. If they are same, then we need only
   * a RIGHT offset, the orig curve will generate the LEFT surface. This also
   * means  UxV for left surface will point INTO volume and for right surface
   * will point OUT of volume ==> REVERSE right offset curve, before projection,
   * which will reverse natural normal. If however, the proj dir is OPPOSITE to
   * the curve plane normal, the logic is reversed. This whole logic is very 
   * succintly captured in the line of code below.
   */
  reverse_curve = (i==0? flip_proj_side : !flip_proj_side);

  if (reverse_curve)
  {
     sts = om$send (msg    = message GRcurve.GRrevparm(&msg_loc, md_env),
               senderid = NULL_OBJID,
               targetid = offset_cv->objid,
               targetos = offset_cv->osnum);
     EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  } 
  if (!single_closed_side_surface)
  { 
      /* create the projected surface on the left (i==0) or right (i==1) side*/
     sts = EFxform_and_project_curve (&msg_loc, NULL, construct_list, xform_mat,
                &xform_mattype,offset_cv,md_env,&proj_dist,proj_vector,curr_sf);
     EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

     /* This surfaces of projection already has natural boundaries on it. 
      * (DOUBLE CHECK this. Otherwise we have to make natural boundaries on it).
      */
  }

} /*  CREATE LEFT AND RIGHT SIDE SURFACES */

/* CREATE TOP SURFACE */

/* The top surface will be created by joining the two offset curves above with
 * end segments and making it a single b-spline curve, and then finding a plane
 * that just encloses this curve. If we need a "single_closed_side_surface",
 * then we make use of these end components in creating the closed curve.
 */

/*get the size of the LEFT offset curve */
sts = om$send (msg = message GRvg.GRgetsize(&msg_loc,
                        &mat_type,
                        mat,&cv_size),
                senderid = NULL_OBJID,
                targetid = left_offset_cv.objid,
                targetos = left_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

left_curve_geom  = (struct IGRbsp_curve *) alloca (cv_size);

/*Get the geometry of the curve*/
sts = om$send (msg = message GRvg.GRgetgeom( &msg_loc,
                          &mat_type,
                          mat,
                          (IGRchar *)(left_curve_geom)),
                senderid = NULL_OBJID,
                targetid = left_offset_cv.objid,
                targetos = left_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

/*get the size of the RIGHT offset curve */
sts = om$send (msg = message GRvg.GRgetsize(&msg_loc,
                        &mat_type,
                        mat,&cv_size),
                senderid = NULL_OBJID,
                targetid = right_offset_cv.objid,
                targetos = right_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

right_curve_geom  = (struct IGRbsp_curve *) alloca (cv_size);

/*Get the geometry of the curve*/
sts = om$send (msg = message GRvg.GRgetgeom( &msg_loc,
                          &mat_type,
                          mat,
                          (IGRchar *)(right_curve_geom)),
                senderid = NULL_OBJID,
                targetid = right_offset_cv.objid,
                targetos = right_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

/* Here is the logic for creating the correctly oriented plane (i.e. with normal
 * pointing IN the direction of projection, i.e. INTO volume).
 *
 * 1. Create two linear segments that join the two offset curves at the ends.
 * 2. Merge the curves to make a single closed curve.
 * 3. Call BSplan_of_cv to create the plane.
 * 4. Check if the plane normal is same or opposite to proj. dir.
 * 5. If opposite, reverse "u" or "v" direction of plane to have normal point
 *    in dir of projection.
 */

  /* get the endpts of the left offset curve */
  sts = om$send (msg=message GRcurve.GRendpts (&msg_loc, &mat_type, mat, 
                      lf_cv_pts[0], lf_cv_pts[1]),
               senderid = NULL_OBJID,
               targetid = left_offset_cv.objid,
               targetos = left_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  /* get the endpts of the right offset curve */
  sts = om$send (msg=message GRcurve.GRendpts (&msg_loc, &mat_type, mat, 
                      rt_cv_pts[0], rt_cv_pts[1]),
               senderid = NULL_OBJID,
               targetid = right_offset_cv.objid,
               targetos = right_offset_cv.osnum);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  if (single_closed_side_surface)
  {
    /* 1. Create two "GRbcsubbc" object using the endpts.(GR3dlineseg object
     *    apparently has problems, if we use it to create a composite from the
     *    existing offset curves). These should be created in the SAME direction
     *    of parametrization as the offset curevs. Reason is, offset curves have
     *    been correctly created to have surface normal point into volume.
     * 2. Use these segments in closing the existing offset curves.
     * 3. Project this curve to form the only side surface created in this 
     *    function.
     * 4. Continue creating the top plane.
     */

     /* seg 1 */
     OM_BLOCK_MOVE (lf_cv_pts[1], &start_seg[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE (rt_cv_pts[0], &start_seg[3], sizeof (IGRpoint));

     /* CHECK THE PARAMETERS*/
     GRcreate_curve_by_option(&msg_loc, md_env, 0, NULL, 2,
          start_seg, NULL, NULL, 2, FALSE, NULL, NULL, &start_seg_cv, NULL, 0);

     /* seg 2 */
     OM_BLOCK_MOVE (rt_cv_pts[1], &end_seg[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE (lf_cv_pts[0], &end_seg[3], sizeof (IGRpoint));

     /* CHECK THE PARAMETERS*/
     GRcreate_curve_by_option(&msg_loc, md_env, 0, NULL, 2,
          end_seg, NULL, NULL, 2, FALSE, NULL, NULL, &end_seg_cv, NULL, 0);

     /* construct a new composite curve out of these curves */

     new_cv.osnum = construct_os;
     sts = om$construct(classid= OPP_GRcompcurve_class_id,
                        osnum  = construct_os,
                        msg    = message GRgraphics.GRconstruct(construct_list),
                        p_objid= &new_cv.objid);
    EMerr_hndlr (!(1&sts) || ((*construct_list->msg) != MSSUCC), *EFmsg, 
                                      EMS_E_Fail, wrapup);
   
    for (i=0; i<4; i++)
    {
      OM_BLOCK_MOVE (md_env,&(comp_ids[i].module_info),sizeof(struct GRmd_env));
      comp_ids[i].located_obj.objid = (i==0?left_offset_cv.objid:
                                      (i==1?start_seg_cv.objid : 
                                      (i==2?right_offset_cv.objid:
                                            end_seg_cv.objid)));
      comp_ids[i].located_obj.osnum = construct_os;
    }

    sts = om$send( msg = message GRcompcurve.EMmakecomp(&msg_loc,
                               md_env, 4, comp_ids, &rotten_one),
                          senderid = NULL_OBJID,
                          targetid = new_cv.objid,
                          targetos = new_cv.osnum);
    EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

    /* get its properties to make sure that it is closed, just in case */
    sts = om$send (msg = message GRvg.GRgeomprops(&msg_loc,
                               &mat_type, mat, &props),
                senderid = NULL_OBJID,
                targetid = new_cv.objid,
                targetos = new_cv.osnum);
    EMerr_hndlr (!(1&sts&msg_loc) || !(props.phy_closed), 
                                                 *EFmsg, EMS_E_Fail, wrapup);

    /* now project this to create the single, closed, side surface. Note that
     * just as we neeed to have an end-cap on the top of this surface, we may
     * need one on the bottom too. This means, for a finite rib, we better 
     * project by EXACTLY the input "*rib_proj_distance". The translation matrix
     * has already been set to identity.
     */

    if (finite_rib)
       proj_dist_single_side_sf = *rib_proj_distance;

    sts = EFxform_and_project_curve (&msg_loc, NULL, construct_list, xform_mat,
               &xform_mattype,&new_cv,md_env,
               &proj_dist_single_side_sf,proj_vector,
               &single_side_sf);
    EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

    feasfs_loc[num_feasfs_loc++] = single_side_sf;

    /* This surface of projection already has natural boundaries on it. 
     * (DOUBLE CHECK this. Otherwise we have to make natural boundaries on it).
     */

    /* continue with top plane code below */

  }/*single_closed_side_surface*/

  /* make two line segments joining the corresponding start and end pts. No
   * need to check seg_type, which should always be BSCLINE, since function
   * will return error otherwise. 
   */

  seg1.poles = poles1; /*assign stack memory */
  seg1.knots = knots1; /*assign stack memory */
  success = BSlngen( &rc, rt_cv_pts[0], lf_cv_pts[0], &seg1, &seg_type);
  EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

  seg2.poles = poles2; /*assign stack memory */
  seg2.knots = knots2; /*assign stack memory */
  success = BSlngen( &rc, rt_cv_pts[1], lf_cv_pts[1], &seg2, &seg_type);
  EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

  /* create an array of curve pointers */
  cvs[0] = flip_proj_side ? left_curve_geom  : right_curve_geom;
  cvs[1] = &seg1;
  cvs[2] = flip_proj_side ? right_curve_geom : left_curve_geom;
  cvs[3] = &seg2;
 
  BSmergarrcv(4,cvs,&merged_cv,&rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);


  /* allocate local stack memory for the geometry of the plane*/
  top_pln_sf.poles    = (IGRdouble *) sf_poles0;
  top_pln_sf.weights = NULL;
  top_pln_sf.u_knots = (IGRdouble *) u_knots0;
  top_pln_sf.v_knots = (IGRdouble *) v_knots0;

  success = BSpl_of_cv(&rc, merged_cv, &top_pln_sf);
  EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

  (void) BSptonnsdsf(&top_pln_sf, pt_in_volume, &nat_side, &rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  /* If natural normal of plane does NOT point into volume, reverse the 
   * U-parametrization of the planar surface, so that the nat-normal may point
   * into volume.
   * 
   * If surface is to be reversed to have the natural normal point into volume,
   * do so.  It is better to have the natural normals point into the volume
   * rather than setting the pos-orient bit. This is because, in the latter
   * case, if the natural normals as returned by math flip during recompute,
   * the edges on the secondary surfaces might be created in a different order,
   * which screws up the associate keys on the edges.
   */
  if (!nat_side)
  {  success =  BSrevsf_u(&rc,&top_pln_sf);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
  }

  /* construct an EMSplane object */
  top_sf.objid =  NULL_OBJID;
  top_sf.osnum = construct_os;

  sts = om$construct (
              classid = OPP_EMSplane_class_id,
              p_objid = &(top_sf.objid),
              osnum   = top_sf.osnum);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  /* fill up the geometry in the construct list*/
  construct_list->geometry = (IGRchar *)(&top_pln_sf);

  /* send the plane object the GRconstruct message */
  sts = om$send (msg = message GRgraphics.GRconstruct (construct_list),
                 senderid = NULL_OBJID,
                 targetid = top_sf.objid,
                 targetos = top_sf.osnum);

  /* on error, delete the plane object */
  if (!(1&sts&(*construct_list->msg)))
  {
     sts = om$send (msg    = message GRgraphics.GRdelete (&msg_del, md_env),
                  senderid = NULL_OBJID,
                  targetid = top_sf.objid,
                  targetos = top_sf.osnum);

    msg_loc = EMS_E_Fail;
    top_sf.objid = NULL_OBJID;
    EMerr_hndlr (TRUE,  *EFmsg, EMS_E_Fail, wrapup);
  }



  /* Now, if the side surface was a single composite, we need to cap its ends.
   * This can be done in two steps. One, map the "new_cv", which represents the
   * top boundary of the side surface onto the plane. Two, stitch the two 
   * together.
   * If the top plane is NOT to be connected to the side surface, simply make a
   * natural boundary on it and keep going.
   */

  if (single_closed_side_surface)
  {

     new_compsf.objid = NULL_OBJID;
     (void) EFcap_surface_with_plane (&msg_loc, &top_sf, &single_side_sf, 
                                  &new_compsf, &new_cv, md_env, construct_list);
     EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

     (*num_caps)++;  /* increment the number of caps */

     if (new_compsf.objid != NULL_OBJID)
     {
        /* we need to replace the surface "single_side_sf" in the "loc_feasfs"
         * array with the new composite surface. The top_sf is now part of this
         * composite and will not go in separately into the array.
         */
        found_sf = FALSE;
        for (i=0; i<num_feasfs_loc; i++)
        { if (feasfs_loc[i].objid == single_side_sf.objid)
           { feasfs_loc[i] = new_compsf;
             found_sf = TRUE;
             break;
           }
        }
        EMerr_hndlr (!found_sf, *EFmsg, EMS_E_Fail, wrapup);

        single_side_sf = new_compsf; /* since one replaces the other */
     }
  }
  else
  {
    /* make natural boundaries on the top plane */
    sts = om$send (msg = message EMSsurface.EMmk_nat_bdry (
                                 &msg_loc, &(md_env->md_env), NULL),
                    senderid = NULL_OBJID,
                    targetid = top_sf.objid,
                    targetos = top_sf.osnum);
    EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);

    feasfs_loc[num_feasfs_loc++] = top_sf;
  }


  if (finite_rib)
  { /* we also need to create the bottom surface. The algorithm here is:
     * 
     * 1. Copy and translate the top plane geometry along the proj. dir by the 
     *    "rib_proj_distance".
     * 2. Reverse its normal so that it points INTO volume.
     * 3. Construct the object.
     * 4. Connect it to the side surface if necessary.
     */
    
     /* make a translation matrix in the direction of projection, for 
      * translation by a distance "rib_proj_distance".
      */
     for (i=0; i<3; i++)
         xform_vec[i] = proj_vector[i];

     success = BSnorvec(&rc,xform_vec);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

     for (i=0; i<3; i++)
        xform_vec[i] *=  (*rib_proj_distance);

     success = MAtrlmx(&rc, xform_vec,(IGRdouble *)xform_mat);
     EMerr_hndlr (!success || (rc != MSSUCC),*EFmsg,EMS_E_BSerror,wrapup);


     /* allocate local stack memory for the geometry of the plane*/
     bottom_pln_sf.poles    = (IGRdouble *) sf_poles1;
     bottom_pln_sf.weights = NULL;
     bottom_pln_sf.u_knots = (IGRdouble *) u_knots1;
     bottom_pln_sf.v_knots = (IGRdouble *) v_knots1;
 
     /*make a copy of the top plane geometry*/
     success =  BSsf_copy(&rc,&top_pln_sf,&bottom_pln_sf);
     EMerr_hndlr (!success || (rc!=BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

     num_pts = bottom_pln_sf.u_num_poles * bottom_pln_sf.v_num_poles;
     
     /* transform bottom plane to its correct position. MAptsxform operates
      * on non-rational poles only. If poles were rational, they would have to
      * be unweighted first. Input and output can be same, here.
      */
     success = MAptsxform (&rc,&num_pts,(IGRdouble *)xform_mat,
                           bottom_pln_sf.poles, bottom_pln_sf.poles);
     EMerr_hndlr (!success || (rc!=MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

     success =  BSrevsf_u(&rc,&bottom_pln_sf);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

     /* construct an EMSplane object */

     bottom_sf.objid = NULL_OBJID;
     bottom_sf.osnum = construct_os;
     sts = om$construct (
                 classid = OPP_EMSplane_class_id,
                 p_objid = &(bottom_sf.objid),
                 osnum   = bottom_sf.osnum);
     EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);
   
     /* fill up the geometry in the construct list*/
     construct_list->geometry = (IGRchar *)(&bottom_pln_sf);
   
     /* send the plane object the GRconstruct message */
     sts = om$send (msg = message GRgraphics.GRconstruct (construct_list),
                    senderid = NULL_OBJID,
                    targetid = bottom_sf.objid,
                    targetos = bottom_sf.osnum);
     /* on error, delete the plane object */
     if (!(1&sts) || ((*construct_list->msg) != MSSUCC))
     {
        sts = om$send (msg    = message GRgraphics.GRdelete (&msg_del, md_env),
                     senderid = NULL_OBJID,
                     targetid = bottom_sf.objid,
                     targetos = bottom_sf.osnum);
   
       bottom_sf.objid = NULL_OBJID;
       msg_loc = EMS_E_Fail;
       *EFmsg       = EMS_E_Fail;
       goto wrapup;
      }

     /* For the same reasons as the top plane, make this bottom surface an end-
      * cap, if the side surface is a single (possibly) composite surface of
      * projection, else return it as a separate surface.
      */

     if (single_closed_side_surface)
     {

        /* the boundary curve we had used for mapping onto the top plane will
         * now need to be translated to the bottom plane. However, the impt.
         * thing to note will be that the correspondence with the surface will
         * still be maintained. i.e. the "i"th component of the curve will have
         * generated the "i"th component of the "single_side_sf". Even if we
         * added a top end cap to this composite surface above, it was added at
         * the END, and hence the above holds.
         */

        /* translate the boundary curve to the bottom. It uses the SAME 
         * matrix that is used to generate the bottom plane from the top plane.
         */

         success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattype);
         EMerr_hndlr (!success||!(1&msg_loc),*EFmsg, EMS_E_BSerror, wrapup);
 
        sts = om$send (msg = message GRgraphics.GRxform(
               &msg_loc, md_env, &xform_mattype, xform_mat, &objid),
                      senderid = NULL_OBJID,
                      targetid = new_cv.objid,
                      targetos = new_cv.osnum);
        EMerr_hndlr (!(1&sts&msg_loc) || (objid != new_cv.objid),
                     *EFmsg, EMS_E_Fail, wrapup);
 
        new_compsf.objid = NULL_OBJID;
        (void) EFcap_surface_with_plane (&msg_loc, &bottom_sf, &single_side_sf,
                                 &new_compsf, &new_cv, md_env, construct_list);
        EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
   
        (*num_caps)++;  /* increment the number of caps */

        if (new_compsf.objid != NULL_OBJID)
        {
           /* we need to replace the surface "single_side_sf" in the 
            * "feasfs_loc" array with the new composite surface. The bottom
            * surface is now part of this composite.
            */
           found_sf = FALSE;
           for (i=0; i<num_feasfs_loc; i++)
           { if (feasfs_loc[i].objid == single_side_sf.objid)
              { feasfs_loc[i] = new_compsf;
                found_sf = TRUE;
                break;
              }
           }
           EMerr_hndlr (!found_sf, *EFmsg, EMS_E_Fail, wrapup);
        }
     }
     else
     {
         /* make natural boundaries on the bottom surface */
         sts = om$send (msg = message EMSsurface.EMmk_nat_bdry (
                                &msg_loc, &(md_env->md_env), NULL),
                   senderid = NULL_OBJID,
                   targetid = bottom_sf.objid,
                   targetos = bottom_sf.osnum);
         EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
   
         feasfs_loc[num_feasfs_loc++] = bottom_sf;
     }
   
   }/*if finite_rib */
   

/* send the surface info back*/
if (feasfs)
{
  *num_feasfs = num_feasfs_loc;
  *feasfs = (struct GRid *) om$malloc (size = sizeof(struct GRid) *
                                          num_feasfs_loc);
  for (i=0; i< num_feasfs_loc; i++)
  {
     (*feasfs)[i] = feasfs_loc[i];
  }
 
}


wrapup:

/* DO NOT ADD CODE BETWEEN THIS LINE AND WRAPUP ABOVE. THIS IS SO THAT "msg_loc"
 * CAN CONTINUE TO REPRESENT AN ERROR FROM THE CODE, AND NOT FROM ANYTHING DONE
 * IN WRAPUP.
 *
 * On error, delete ANY surface objects created 
 */

if (!(1&sts&*EFmsg))
{
   for (i=0; i<num_feasfs_loc; i++)
   {
     /* check if it is NULL_OBJID. Counter "num_feasfs_loc" gets incremented
      * before surface creation.
      */
     if (feasfs_loc[i].objid != NULL_OBJID)
     {
       sts = om$send (msg  = message GRgraphics.GRdelete(&msg_del, md_env),
                  senderid = NULL_OBJID,
                  targetid = feasfs_loc[i].objid,
                  targetos = feasfs_loc[i].osnum);
     }

   }

}/*if*/

/* delete the copy of the profile composite curve */
if (loc_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = loc_cv.objid,
                  targetos = loc_cv.osnum);
}

/* delete the left offset curve */
if (left_offset_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = left_offset_cv.objid,
                  targetos = left_offset_cv.osnum);
}

/* delete the right offset curve */
if (right_offset_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = right_offset_cv.objid,
                  targetos = right_offset_cv.osnum);
}
/* delete the top left and right offset curves */
if (top_left_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = top_left_cv.objid,
                  targetos = top_left_cv.osnum);
}
if (top_right_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = top_right_cv.objid,
                  targetos = top_right_cv.osnum);
}

/* delete "new_cv" if not done so already */

if (new_cv.objid != NULL_OBJID)
{  sts = om$send (msg      = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = new_cv.objid,
                  targetos = new_cv.osnum);
}

  EMWRAPUP (*EFmsg, sts, "In EFcreate_type2_rib_surfaces");
  return (sts);

}/* EFcreate_type2_rib__surfaces() */

/*----------------------------------------------------------------------------*/



/* This function takes in a startpt, id of base solid (or a given range), a 
 * projection vector as input. It then extends the vector till the bounding
 * box of the solid (or the given range). The two points are returned in the 
 * direction of the vector (i.e. vector is point2-point1).
 */

IGRlong EFextend_to_bounds(
               EFmsg,
               md_env,     /* NULL if bounding box is input. Used to get
                            * range of input surface/solid.
                            */
               startpt,
               bounding_box,
               base_sf_sl_id, /*  NULL if bounding box is input */
               proj_vector,
               endpt)
IGRlong		*EFmsg;
struct GRmd_env *md_env;
GRrange         bounding_box;
struct GRid	*base_sf_sl_id;
IGRvector	proj_vector;
IGRpoint	startpt, endpt;
{
IGRint		i;
IGRlong		sts, msg_loc;
IGRpoint	better_line[2];
IGRboolean	world, success;
GRrange		range;
struct IGRline  ray, line;
IGRdouble	t, tmin, tmax;
IGRdouble	junk_pt[3];


sts      = OM_S_SUCCESS;
*EFmsg   = EMS_S_Success;


if (bounding_box)
{
  OM_BLOCK_MOVE (bounding_box, range, sizeof (GRrange) ); 
}
else if (base_sf_sl_id)
{
  /*  get the range of the input surface or solid */
  world=TRUE; /* get range in world coordinates */
  sts = om$send (msg = message GRvg.GRgetrang (&msg_loc,
                        &(md_env->md_env.matrix_type), 
                        md_env->md_env.matrix, &world, range),
                        senderid = NULL_OBJID,
                        targetid = base_sf_sl_id->objid,
                        targetos = base_sf_sl_id->osnum);
  EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
}
else
{
  EMerr_hndlr (TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);

}


/* allocate space for the line's points */

ray.point1 = (IGRdouble *) alloca (sizeof(IGRpoint));
ray.point2 = (IGRdouble *) alloca (sizeof(IGRpoint));

/* create a "ray" from start pt of curve in dir. of given vector */

OM_BLOCK_MOVE (startpt, ray.point1, sizeof (IGRpoint));

for (i=0; i<3; i++)
  ray.point2[i] = ray.point1[i] + proj_vector[i];

/* extend the ray so that it extends across the range box of the solid. The 
 * function "rlw_get_better_line" projects the range box onto the ray and 
 * returns the line joining the projected points with the highest and least 
 * value of parameter "t". It returns the two points such that
 * "better_line[1] - better_line[0]" is in same dir. as 
 * "ray.point2 - ray.point1"
 */

success = rlw_get_better_line( (IGRpoint *)range, &ray, better_line, &msg_loc);
EMerr_hndlr (!(1&sts&msg_loc) || !success, *EFmsg, EMS_E_Fail, wrapup);

/* put the coordinates of the "better_line" into IGRline form */
line.point1 = (IGRdouble *) alloca (sizeof (IGRpoint));
line.point2 = (IGRdouble *) alloca (sizeof (IGRpoint));
OM_BLOCK_MOVE (better_line[0], line.point1, sizeof (IGRpoint));
OM_BLOCK_MOVE (better_line[1], line.point2, sizeof (IGRpoint));

/* project start pt of original ray onto the better line */
success = MAptlnproj (&msg_loc, ray.point1, &line, junk_pt, &t);
EMerr_hndlr ((msg_loc != MSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);

/* project start pt of better line onto the better line (tmin should be "0")*/
success = MAptlnproj (&msg_loc, better_line[0], &line, junk_pt, &tmin);
EMerr_hndlr ((msg_loc != MSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);

/* project end pt of better line onto the better line (tmax should be "1")*/
success = MAptlnproj (&msg_loc, better_line[1], &line, junk_pt, &tmax);
EMerr_hndlr ((msg_loc != MSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);

/* Five scenarios are possible:
 *
 * 1. The start point of the ray (i.e. line.point1) is INSIDE the range box.
 * 2. The start point of the ray (i.e. line.point1) is ON the range box and the
 *    ray travels AWAY from the range box.
 * 3. The start point of the ray (i.e. line.point1) is ON the range box and the
 *    ray travels INTO the range box.
 * 4. The start point of the ray (i.e. line.point1) is OUTSIDE the range box and
 *    there are NO intersections with the range box in the direction of the ray.
 *    (i.e. range box is "behind" the ray).
 * 5. The start point of the ray (i.e. line.point1) is OUTSIDE the range box and
 *    there are TWO intersections with the range box in the direction of the 
 *    ray. (i.e. range box is "ahead of" the ray).
 *
 */

 /* Now the logic for the above 5 cases becomes:
  * t <= tmin ==> return t, tmax
  * t >= tmax ==> return NULL (no intersection)
  * tmin < t < tmax ==> return t, tmax
  */

  if ( (t <= tmin) || ( (t>tmin) && (t<tmax) ) )
  { 
    OM_BLOCK_MOVE (better_line[1], endpt,  sizeof(IGRpoint) );
  }
  else 
  {
    /* The bounding box is "behind" the ray. */
    EMerr_hndlr (TRUE, *EFmsg, EMS_I_NoSolution, wrapup); 
  }  


wrapup:

EMWRAPUP (*EFmsg, sts, "EFextend_to_bounds");
return (sts);

}
/*----------------------------------------------------------------------------*/

/**
 NOTES:
 1. "options" currently unused.

**/

#ifdef __STDC__
#argsused
#else
/*ARGSUSED*/
#endif

static IGRlong EFxform_and_project_curve(
          EFmsg,
          options,
          construct_list,
          xform_mat, /* can be NULL */
          xform_mattype, /* can be NULL */
          curve,
          curve_md_env,
          proj_dist,
          proj_vector,
          proj_surface)
IGRlong		*EFmsg;
IGRshort	options, *xform_mattype;
struct GRvg_construct *construct_list;
struct GRid	*curve, *proj_surface;
struct GRmd_env *curve_md_env;
IGRdouble	*proj_dist;
IGRvector	proj_vector;
IGRmatrix	xform_mat;
{
  IGRint	  i;
  IGRlong	  sts, msg_loc;
  GRobjid	  surf, objid;
  IGRpoint	  proj_extents[2], startpt, endpt;
  struct GRmd_env *md_env;
  struct GRid     curve_copy;
  GRspacenum      construct_os;
  IGRvector	  unit_proj_vector;
  IGRdouble	  *mat;
  IGRshort	  mat_type;
  IGRboolean      success, degen;
  struct IGRbsp_curve *cv_geom = NULL;
  IGRlong cv_size;
  BSrc rc;

  

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  md_env = construct_list->env_info;
  mat    = md_env->md_env.matrix;
  mat_type=md_env->md_env.matrix_type;

  construct_os = md_env->md_id.osnum;

  /*initialize */

  curve_copy.objid = NULL_OBJID;
  curve_copy.osnum = construct_os;

  /* NORMALIZE the input vector. Important */
  success = MAunitvc( &msg_loc, proj_vector, unit_proj_vector);
  EMerr_hndlr ((msg_loc!= MSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);

  /* make a copy of the curve in the module environment defined by the 
   * construct list.
   */
   curve_copy.osnum = construct_os;
   sts = om$send (msg= message GRgraphics.GRcopy(
                                         &msg_loc,
                                         curve_md_env,
                                         md_env,
                                         &(curve_copy.objid)),
                      senderid=NULL_OBJID,
                      targetid=curve->objid,
                      targetos=curve->osnum);
   EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);


  /* xform the copy of the the curve by the given matrix, ONLY if both the 
   * matrix and its type are not NULL
   */
  if (xform_mattype && xform_mat)
  {  sts = om$send (msg = message GRgraphics.GRxform(
                        &msg_loc, md_env, xform_mattype, xform_mat, &objid),
                  senderid = NULL_OBJID,
                  targetid = curve_copy.objid,
                  targetos = curve_copy.osnum);
     EMerr_hndlr (!(1&sts&msg_loc) || (objid != curve_copy.objid), *EFmsg, 
                                EMS_E_Fail, wrapup);
  }

	/* Check for degeneracy of the transformed curve.
	 * Fix for TR#119525131
	 */
	/*Get the size of the curve */
	sts = om$send (msg = message GRvg.GRgetsize(&msg_loc,
							                    &mat_type,
											    mat,&cv_size),
                  senderid = NULL_OBJID,
				targetid = curve_copy.objid,
				targetos = curve_copy.osnum);
	EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

	cv_geom  = (struct IGRbsp_curve *) om$malloc (size = cv_size);
	EMerr_hndlr (!(cv_geom), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

	/*Get the geometry of the curve*/
	sts = om$send (msg = message GRvg.GRgetgeom( &msg_loc,
												&mat_type,
												mat,
												(IGRchar *)(cv_geom)),
					senderid = NULL_OBJID,
					targetid = curve_copy.objid,
					targetos = curve_copy.osnum);
	EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

	BStstcvdegn( cv_geom, &degen, &rc);
	EMerr_hndlr ((rc != BSSUCC) || degen, *EFmsg, EMS_E_Fail, wrapup);
 


  if (proj_dist)
  { /* get endpts of the curve */
    sts = om$send (msg=message GRcurve.GRendpts(&msg_loc, &mat_type, mat,
                startpt, endpt),
            senderid = NULL_OBJID,
            targetid = curve_copy.objid,
            targetos = curve_copy.osnum);
    EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
 
    OM_BLOCK_MOVE (startpt, proj_extents[0], sizeof (IGRpoint));

    for (i=0; i<3; i++)
      proj_extents[1][i] = proj_extents[0][i]+(*proj_dist)*unit_proj_vector[i];
  }
  else
  {  EMerr_hndlr (TRUE, *EFmsg, EMS_E_Fail, wrapup); /* macro. Needs braces */
  }

 /* create a EMSproject class object and send it the following message:
  * "EMplace_surface_of_projection". (If the curve is a composite, then a 
  * composite surface is returned and the EMSproject object becomes its
  * first component. However, if a special surface is created instead of the
  * EMSproject surface, then the "EMSproject" surface is deleted internally). 
  * Note that the proj sf is  not necessarily a composite surface, but could 
  * also be a single surface, if the input curve is not a composite.
  * If simple curve,
  *     proj_surface->objid == surf
  * else if composite
  *     proj_surface->objid != surf ("surf" is now FIRST component of 
  *                                  "proj_surface->objid")
  */

  sts = om$construct (classname = "EMSproject", p_objid = &surf, 
                                                  osnum = construct_os);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  /* The pos-orient flag is always expected to be true, since we take some
   * pains to parametrize the curve correctly before projection so that the
   * natural normal (in the direction of the cross product of the curve
   * parametrization and the projection normal) points INTO volume of rib.
   */

  construct_list->geometry = NULL; /* generated inside the method */
  sts = om$send (msg = message EMSproject.EMplace_surface_of_projection (
                                  construct_list, &curve_copy, md_env, NULL, 
                                  (IGRuchar)NULL,
                                  proj_extents[0], proj_extents[1], 
                                  TRUE , &(proj_surface->objid)),
                          senderid = NULL_OBJID,
                          targetid = surf,
                          targetos = construct_os);

  if (!(1&sts&(*(construct_list->msg))))
  {
    
    /* delete the surface of projection on error*/
    om$send (msg    = message GRgraphics.GRdelete (&msg_loc, md_env),
           senderid = NULL_OBJID,
           targetid = surf,
           targetos = construct_os);
    *EFmsg =  EMS_E_Fail; 
    goto wrapup;
  }
  proj_surface->osnum = construct_os;

  

wrapup:

  
  /* delete the copy of the input (possibly composite) curve */
  sts=om$is_objid_valid(objid=curve_copy.objid,osnum=curve_copy.osnum);
  if (sts == OM_S_SUCCESS)
  {  sts = om$send (msg    = message GRgraphics.GRdelete (&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = curve_copy.objid,
                  targetos = curve_copy.osnum);
  }

  EMWRAPUP (*EFmsg, sts, "In EFxform_and_project_curve");
  return (sts);
}

/****************************************************************************/
 
  /* ALGORITHM:
   *
   * NOTE: The proj_vector is used ONLY when the curve is linear, to define 
   *       a unique plane. If the caller is sure the curve is NOT linear, this
   *       can be NULL.
   *
   * 1.  Create a planar surface from the curve.
   * 2.  Find the bounding box of the solid.
   * 3.  Project bounding box points onto the curve plane.
   * 4.  Transform the plane and the projected points to the XY plane, using
   *     math fn. "BSptsoldtnw" such that the parametric origin of the plane 
   *     is the global origin, and the natural normal is aligned with the 
   *     Z-axis.
   * 5.  Extend the plane to include ALL the transformed projected points.
   * 6.  Transform enlarged plane back to original position (BSptsnwtold) with
   *     a suitable scale factor, so that it is expanded by a small amount.
   * 8.  Construct an EMSplane object out of it.
   * 9.  On error, delete plane object and return NULL_OBJID in "newsf".
   */            

static void EFcreate_planar_surface(EFmsg, construct_list, cv_geom, 
                                    proj_vector, solid_id, orient_pt, newsf)
IGRlong *EFmsg;
struct GRvg_construct *construct_list;
struct IGRbsp_curve *cv_geom;
struct GRid *solid_id, *newsf;
IGRpoint orient_pt;
IGRvector proj_vector;
{
   IGRlong sts, msg_loc;
   BSrc rc;
   IGRint  i, j;
   IGRshort is_line;
   IGRboolean nat_side, success, world;
   struct IGRbsp_surface planar_surf, XY_plane; 
   IGRdouble  scale, upars, vpars, *mat, poles0[12], u_knots0[4], v_knots0[4];
   IGRdouble  poles1[12], u_knots1[4], v_knots1[4];
   IGRdouble  transvec[3], rot_mat[3][3], xmin, ymin, xmax, ymax;
   IGRshort mat_type;
   IGRpoint startpt, endpt, another_pt, point, global_origin;
   IGRvector normal, global_z_axis;
   struct GRmd_env *md_env;
   GRrange range, pj_range;
   GRspacenum construct_os;


   sts = OM_S_SUCCESS;
   *EFmsg = EMS_S_Success;

   md_env       = construct_list->env_info;
   mat          = md_env->md_env.matrix;
   mat_type     = md_env->md_env.matrix_type;
   construct_os = md_env->md_id.osnum;

   /* INITIALIZE */
   newsf->objid = NULL_OBJID;
   newsf->osnum = construct_os;


  /* allocate stack memory for the geometry of the plane(poles and knots only)*/
  planar_surf.poles   = (IGRdouble *) poles0;
  planar_surf.weights = NULL;
  planar_surf.u_knots = (IGRdouble *) u_knots0;
  planar_surf.v_knots = (IGRdouble *) v_knots0;

  /* first of all, check to see if the curve is a LINE */

  (void) BStstcvfln(cv_geom,&is_line,startpt,endpt,&rc);
  EMerr_hndlr ((is_line == 2 /*POINT*/ ) || (rc != BSSUCC), *EFmsg, 
                EMS_E_BSerror, wrapup);

  if (is_line == 1) /** ==> curve is a LINE */
  {
     /* make sure projection vector is input */
     EMerr_hndlr (!proj_vector, *EFmsg, EMS_E_InvalidArg, wrapup);

     for (i=0; i<3; i++)
       another_pt[i] = startpt[i]+ proj_vector[i];

     success =  BSplane3pt(&rc, startpt, endpt, another_pt, &planar_surf);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

  }
  else
  {
     success = BSpl_of_cv(&rc, cv_geom, &planar_surf);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
  }
 
  /* get bounding box of solid */
  world=TRUE; /* get range in world coordinates */
  sts = om$send (msg = message GRvg.GRgetrang (&msg_loc,
                        &mat_type, mat, &world, range),
                        senderid = NULL_OBJID,
                        targetid = solid_id->objid,
                        targetos = solid_id->osnum);
  EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  /* get the normal of the plane */
  upars = 0.5;
  vpars = 0.5;
  (void) BSsfarrevn(&rc, &planar_surf, 1, &upars, 1, &vpars, (IGRdouble *)point,
                     (IGRdouble *)normal);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);


  /* project range box min-max points onto the plane */
   success = BSproj1(&rc,range, normal, point, pj_range);
   EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

   success = BSproj1(&rc,&range[3], normal, point, &pj_range[3]);
   EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

   /* create the rot. matrix to take the plane to global XY plane, with
    * its natural normal aligned with the Z-axis.
    */

   global_origin[0] = 0.0; global_origin[1] = 0.0; global_origin[2] = 0.0;
   global_z_axis[0] = 0.0; global_z_axis[1] = 0.0; global_z_axis[2] = 1.0; 
   scale = 1.0;

   /*first pole of plane is at uv=0,0 and denotes the displacement of the 
    * parametric origin from the global origin (translation vector).
    */
   OM_BLOCK_MOVE (planar_surf.poles, transvec, sizeof(IGRvector));

   success = BStrans1(&rc, (IGRdouble *)point,normal,(IGRdouble *)global_origin,
                      (IGRdouble *)global_z_axis,transvec,rot_mat,&scale);
   EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

   /*allocate stack memory for the geometry of the plane(poles and knots only)*/
   XY_plane.poles   = (IGRdouble *) poles1;
   XY_plane.weights = NULL;
   XY_plane.u_knots = (IGRdouble *) u_knots1;
   XY_plane.v_knots = (IGRdouble *) v_knots1;

   /* transform the plane to the XY plane */
   (void) BSsfoton(transvec, rot_mat, &scale,  &planar_surf, &XY_plane, &rc);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   /* transform the projected points min-max to the XY plane also. In this fn.
    * input and output can be the same array.
    */
   (void) BSptsoldtnw(transvec, rot_mat, scale, 2, FALSE, 
                      (IGRpoint *)pj_range, NULL, (IGRpoint *)pj_range, &rc);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   /* now find the new range box for the plane using the non-rational poles and
    * the transformed projected points range.
    */

   /* zmin and zmax are both zero, for XY plane */
   xmin = pj_range[0]; ymin = pj_range[1];
   xmax = pj_range[3]; ymax = pj_range[4];

   for (i=0, j=0; i<4; i++, j+=3)
   {  
      if (XY_plane.poles[j] < xmin)
         xmin = XY_plane.poles[j];

      if (XY_plane.poles[j] > xmax)
         xmax = XY_plane.poles[j];

      if (XY_plane.poles[j+1] < ymin)
         ymin = XY_plane.poles[j+1];

      if (XY_plane.poles[j+1] > ymax)
         ymax = XY_plane.poles[j+1];
   }

   /* Now update the poles of the plane using the new min-max range */
   XY_plane.poles[0] =xmin; XY_plane.poles[1] =ymin; XY_plane.poles[2] =0.0;
   XY_plane.poles[3] =xmax; XY_plane.poles[4] =ymin; XY_plane.poles[5] =0.0;
   XY_plane.poles[6] =xmin; XY_plane.poles[7] =ymax; XY_plane.poles[8] =0.0;
   XY_plane.poles[9] =xmax; XY_plane.poles[10]=ymax; XY_plane.poles[11]=0.0;

   /* transform the plane back to its original location. The same translation
    * vector and matrix used above are used here. Internally, the function
    * reverses the vector and inverts the matrix. A scale factor of less than 
    * 1 means that the surface is a little BIGGER after transformation.
    */
   scale = 0.95;
   (void) BSsfntoo(transvec, rot_mat, &scale, &XY_plane, &planar_surf, &rc);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);


   
  (void) BSptonnsdsf(&planar_surf, orient_pt, &nat_side, &rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  /* If surface is to be reversed to have the natural normal point into volume,
   * do so.  It is better to have the natural normals point into the volume
   * rather than setting the pos-orient bit. This is because, in the latter
   * case, if the natural normals as returned by math flip during recompute,
   * the edges on the secondary surfaces might be created in a different order,
   * which screws up the associate keys on the edges.
   */
  if (!nat_side)
  {  success =  BSrevsf_u(&rc,&planar_surf);
     EMerr_hndlr (!success || (rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
  }

  /* construct an EMSplane object */
  newsf->osnum = construct_os;
  sts = om$construct (
              classid = OPP_EMSplane_class_id,
              p_objid = &(newsf->objid),
              osnum   = newsf->osnum);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  /* fill up the geometry in the construct list*/
  construct_list->geometry = (IGRchar *)(&planar_surf);

  /* send the plane object the GRconstruct message */
  sts = om$send (msg = message GRgraphics.GRconstruct (construct_list),
                 senderid = NULL_OBJID,
                 targetid = newsf->objid,
                 targetos = newsf->osnum);

  /* on error, delete the plane object */
  if (!(1&sts) || ((*construct_list->msg) != MSSUCC))
  {
     sts = om$send (msg    = message GRgraphics.GRdelete (&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = newsf->objid,
                  targetos = newsf->osnum);

    newsf->objid = NULL_OBJID;
    *EFmsg       = EMS_E_Fail;
    goto wrapup;
  }


  wrapup:

 
  EMWRAPUP (*EFmsg, sts, "In EFcreate_planar_surface");

}

/* DESCRIPTION:
 *
 * This function takes the "bnd_cv" curve that represents an open boundary of
 * the input surface "surf" and maps in onto the input plane "plane". After 
 * doing so, it stitches the boundaries of the surface and the plane together.
 * It then connects the plane to the composite surface "surf". In case "surf" is
 * not a composite, it creates a new composite surface node and connects BOTH
 * the incoming "surf" and "plane" to it. This new surface is now returned as
 * "surf" back to the caller.
 *
 * ASSUMTPTIONS:
 *
 * 1. "bnd_cv" has been used to create "surf" by projection. Therefore the
 *    boundary edge corresponding to the first component of "bnd_cv" is on the
 *    first component of the (possibly composite) surface etc. etc.
 * 2. The input plane is correctly oriented so that its natural normal points
 *    into volume (of course, by volume, I mean the volume AFTER the rib is 
 *    finally created). In any case, what this means is that the edges are 
 *    reverse-connected after mapping.
 * 3. The input plane has NO natural boundary.
 * 4. The construct list env is the SAME as the env for the surface and plane.
 * 5. The input surface "surf" is a (composite) surface of projection. This
 *    info is assumed in case we need to create a composite surface inside this
 *    function, which is always created as "EMSprjcompsf".
 */

static void EFcap_surface_with_plane (EFmsg, plane, surf, new_compsf, bnd_cv, 
                                       md_env, const_list)
IGRlong *EFmsg;
struct GRid *plane, *surf, *bnd_cv, *new_compsf;
struct GRvg_construct *const_list;
struct GRmd_env *md_env;
{
   IGRlong sts, msg_loc;
   IGRint i, j, num_sfs=0, num_cvs=0, num_edges=0, array_size=0;
   IGRboolean match, found, is_comp_sf=FALSE, is_comp_cv=FALSE;
   GRobjid *sfs=NULL, *cvs=NULL;
   struct GRlc_info *cv_obj=NULL;
   GRspacenum const_os, sfos;
   IGRdouble *mat;
   IGRshort mat_type;
   struct IGRbsp_surface *plane_geom=NULL;
   struct IGRbsp_curve ed_xyz_geom;
   struct GRid loopset_id, clip_ls, *edges=NULL, *sfedges=NULL;
   struct EMSgetlp_output loops, out_cvs;
   IGRint buf_size=0, num_sfedges=0;
   OM_S_CHANSELECT chan_to_common_edge, to_loopset, to_surface;
   OM_S_CHANSELECT to_outter, to_loops, to_components;
   IGRushort lsprops, lpprops, edprops1, edprops2;
   IGRshort  csmask, csaction;
   struct EMSdataselect data1, data2;
   IGRdouble partolbasis;


   *EFmsg = EMS_S_Success;
   sts    = OM_S_SUCCESS;

   EMerr_hndlr(!new_compsf, *EFmsg, EMS_E_InvalidArg, wrapup);

   /* INITIALIZATIONS */

   sfs = NULL;
   cvs = NULL;
   cv_obj=NULL;
   plane_geom=NULL;
   ed_xyz_geom.poles = NULL;
   ed_xyz_geom.knots = NULL;
   ed_xyz_geom.weights = NULL;
   edges = NULL;
   loopset_id.objid = NULL_OBJID;
   loops.objs = NULL;
   out_cvs.objs = NULL;

 
   mat      = md_env->md_env.matrix;
   mat_type = md_env->md_env.matrix_type;
   sfos     = md_env->md_id.osnum;
   const_os = const_list->env_info->md_id.osnum;
    
   new_compsf->objid = NULL_OBJID;
   new_compsf->osnum = const_os;
   clip_ls.objid = NULL_OBJID;
   clip_ls.osnum = const_os;


   sts = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   sts = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);
 
   sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   EMmake_chanselect (GRcmpowner_to_components, &to_components);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   sfs = NULL;
   EFget_components(&msg_loc, surf, &num_sfs, &sfs, &is_comp_sf);
   EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

   cvs = NULL;
   EFget_components(&msg_loc, bnd_cv, &num_cvs, &cvs, &is_comp_cv);
   EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
 
   
   /* create GRlc_info structure for the curves as input for mapping*/
   cv_obj = (struct GRlc_info *) alloca ((sizeof (struct GRlc_info)) * num_cvs);
 
   for (i=0; i<num_cvs; i++)
   { /*only these inputs are needed in the struct */
     cv_obj[i].located_obj.objid  = cvs[i];
     cv_obj[i].located_obj.osnum  = const_os;
     OM_BLOCK_MOVE (md_env, &(cv_obj[i].module_info), sizeof(struct GRmd_env));
   }
 
   /* get the geometry of the plane */
   sts = EMgetvggeom(&msg_loc,&mat_type,mat,plane,(IGRchar **)&plane_geom,NULL);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);

   sts = EFsspbtol_by_geom (&msg_loc, plane_geom, &partolbasis);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);

 
   /* create edges by mapping the curves onto the surface. The option
    * "EMMapBnd_WantBadCurves" is needed because during mapping to special 
    * planes a scaling is done for the poles and this allows the poles to fall 
    * outside the surface bounds (however the curve MUST lie on the surface).
    * Outputting the XYZ curves after mapping would be an easy way to get the 
    * XYZ geometry of the edges, since we need to match that with connectable 
    * edges on "surf". HOWEVER, the corresponsence bwteen the edges and the
    * XYZ curves is lost, if we have to do a loop reversal below. So we choose
    * to generate the XYZ geometry of the edges at the time we need to do the 
    * matching.
    */
   loops.objs = NULL; /* IMPT */
   loops.num_objs = 0; /* IMPT */
   out_cvs.objs = NULL; /* IMPT */
   out_cvs.num_objs = 0; /* IMPT */

   sts = EMget_mapped_data(
       num_cvs,    /* no. of curves to be mapped */
       NULL,
       cv_obj,     /* input curves */
       const_list, /* not needed if XYZ mapped curves not needed */
       plane_geom,
       &partolbasis, /* plane partolbasis */
       md_env,
       NULL,       /* not intersted in outputting bad curves */
       NULL,       /* not interested in dangling data (should never happen) */
       &loops, /* output: loops on surface (kinda like subgroups) */
       NULL,  /* DO NOT output XYZ mapped curves */
       clip_ls,    /* NULL_OBJID, function will clip against nat. loopset*/
       EMMapBnd_ClipBdryArea | EMMapBnd_SurfIsPlane  | EMMapBnd_WantBadCurves,
       NULL,       /* planar info needed ????????*/
       &msg_loc
       );
   EMerr_hndlr(!(msg_loc&sts&1), *EFmsg, msg_loc, wrapup);
   EMerr_hndlr(loops.num_objs != 1,*EFmsg,EMS_E_Fail,wrapup);/*ONLY one loop*/
   EMerr_hndlr(msg_loc == EMS_I_NoMoreLoops, *EFmsg,EMS_E_Fail,wrapup);

   /* Make sure we have a p-loop on the cap plane */
   lpprops = NULL;
   sts = om$send(msg = message EMSloop.EMget_props(
                        &msg_loc, &lpprops),
                      senderid = NULL_OBJID,
                      targetos = const_os,
                      targetid = loops.objs[0]);
   EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_LoopError,wrapup);

   if (!(lpprops & EMLP_PLOOP))
   {
     /* since we have already oriented the surfaces consistently, i.e. BOTH the
      * surfaces' natural normals point INTO the volume of the rib, the mapped 
      * loop HAS to be a p-loop. Therefore, we reverse it, if it is not so.
      */
     sts = om$send(msg = message EMSloop.EMreverse(&msg_loc),
                   senderid = NULL_OBJID,
                   targetos = const_os,
                   targetid = loops.objs[0]);
     EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_LoopError,wrapup);
   } 

   if ( !(lpprops & EMLP_EXTERNAL) || !(lpprops & EMLP_ACTIVE))
   {
      lpprops = EMLP_EXTERNAL | EMLP_ACTIVE;
      sts = om$send(msg = message EMSloop.EMset_props(
                        &msg_loc, lpprops, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetos = const_os,
                      targetid = loops.objs[0]);
      EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_LoopError,wrapup);
   }
 
   /* create a loopset for the cap plane and connect the above loop to it */

   loopset_id.osnum = const_os;
   sts = om$construct (classid = OPP_EMSloopset_class_id,
                       p_objid = &(loopset_id.objid));
   EMerr_hndlr(!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

   /* connect the loopset and the plane */
   sts = om$send (msg = message Root.connect (to_surface, 0,
                            plane->objid, const_os, to_loopset, 0),
                       senderid = plane->objid,
                       targetos = loopset_id.osnum,
                       targetid = loopset_id.objid);
   EMerr_hndlr(!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

   /* connect the loop and the loopset */
   sts = om$send(msg = message Root.connect(
                to_outter, 0, loopset_id.objid,
                const_os, to_loops, 0),
                senderid = loopset_id.objid,
                targetos = const_os,
                targetid = loops.objs[0]);

   lsprops = EMLS_NONMODIFIABLE;
   sts = om$send(msg = message EMSloopset.EMset_props(
                        &msg_loc, lsprops, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetos = loopset_id.osnum,
                      targetid = loopset_id.objid);
   EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_LoopsetError,wrapup);

   /* The mapping is done such that the first edge in the loop corresponds to 
    * the first curve in "cv_obj"  etc. etc. Therefore, we simply get a list of
    * the edges from the loop. Since we know that each edge corresponds to a 
    * different surface (again, correspondence is maintained), we simply get the
    * id of the edge on the surface and common edge connect the two.
    */
 
   num_edges=0;
   array_size=0;

   sts = om$send (msg = message EMSboundary.EMget_edges(&msg_loc, MAXINT, 
                            EMS_OPT_ALL, &edges, &array_size, &num_edges),
                   senderid = NULL_OBJID,
                   targetid = loops.objs[0],
                   targetos = const_os);
   EMerr_hndlr(!(msg_loc&sts&1), *EFmsg, msg_loc, wrapup);
   EMerr_hndlr(num_edges != num_cvs, *EFmsg, EMS_E_Fail, wrapup);

   /* get ALL the connectable edges of the input surface. These are 
    * the likely common edges for the edges in the mapped loop.
    */
   buf_size=0;
   num_sfedges=0;
   sfedges=NULL;
   sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                           EMS_OPT_CONNECTABLE, &sfedges, &buf_size, 
                           &num_sfedges, NULL, NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = surf->objid,
                        targetos = surf->osnum);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);


   /* Match the XYZ geometry of the edges with connectable edges on the
    * input surface "surf" to find matching edges. Connect them as common edges.
    */

   for (i=0; i<num_edges; i++)
   {
      /* get the XYZ geometry of this edge */
      ed_xyz_geom.poles = NULL;
      ed_xyz_geom.knots = NULL;
      ed_xyz_geom.weights = NULL;
      sts = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                           &(md_env->md_env), NULL, NULL, 0, MAXINT,
                           FALSE, NULL, &ed_xyz_geom),
                     senderid = NULL_OBJID,
                     targetid = edges[i].objid,
                     targetos = edges[i].osnum);
      EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

      found = FALSE;
      for (j=0; j<num_sfedges && !found; j++)
      {
         data1.datatype = EMSdata_curve3d;
         data1.data.curve = &ed_xyz_geom;

         data2.datatype = EMSdata_object;
         data2.data.object = &(sfedges[j]);

         match = FALSE;
         match = EFis_xyz_overlap (&msg_loc, &data1, &data2, 
                                      NULL, NULL, NULL, md_env);
         EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

         if (match)
         {
           /* Found common edge. Connect them. */

          sts = om$send (msg = message Root.connect (chan_to_common_edge,
                       0, edges[i].objid, const_os, chan_to_common_edge, 0),
                       targetid = sfedges[j].objid, targetos = const_os,
                       senderid = NULL_OBJID);
          EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

          /* set appropriate properties relating to having a common edge */ 
          edprops1=EMED_REVERSE_CONNECT; /* since natural normals pt INTO vol*/
          edprops2=EMED_REVERSE_CONNECT | EMED_SUBORDINATE;
    
          sts = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                                             edprops1, EMS_O_ON), 
                         targetid = edges[i].objid,
                         targetos = const_os, 
                         senderid = NULL_OBJID);
          EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);

          sts = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                                             edprops2, EMS_O_ON), 
                         targetid = sfedges[j].objid,
                         targetos = const_os, 
                         senderid = NULL_OBJID);
          EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);

          found = TRUE;
         }

      }/* for, num_sfedges */

      if (!found)
        {EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);}
      if (ed_xyz_geom.poles)
        {om$dealloc(ptr=ed_xyz_geom.poles); ed_xyz_geom.poles=NULL;}
      if (ed_xyz_geom.knots)
        {om$dealloc(ptr=ed_xyz_geom.knots); ed_xyz_geom.knots=NULL;}
      if (ed_xyz_geom.weights)
        {om$dealloc(ptr=ed_xyz_geom.weights); ed_xyz_geom.weights=NULL;}
 
   }/*for, num_edges */
    

   /* finally, we need to connect the planar surface to the incoming composite
    * surface. If the surface is NOT composite, then we create a composite and
    * connect BOTH the incoming surfaces to it. In this case the newly created 
    * composite surface of projection is also returned.
    */

   /* QUESTION: DO WE HAVE TO SEND A GRCONSTRUCT TO THE COMPOSITE SURFACE? */
   if (!is_comp_sf)
   {
     /* create a new composite surface object */
     new_compsf->osnum = const_os;
     sts = om$construct (classid = OPP_EMSprjcompsf_class_id,
                         p_objid = &(new_compsf->objid));
     EMerr_hndlr(!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

     /* connect the input sufaces to it, such that the plnar cap is the SECOND 
      * (or last) surface on its channel. 
      */ 
     for (i=0; i<2; i++)
     {
        sts = om$send( msg = message GRvg.GRrigidconn
                                    (&msg_loc, new_compsf,
                                      (IGRlong *)&i ),
                       targetid = (i==0?surf->objid : plane->objid),
                       targetos = const_os,
                       senderid = NULL_OBJID);
        EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_Fail,wrapup);
     }

     /* set necessary propertiees for the composite surface */
     csmask   = GRIS_LOCATABLE | GRIS_DISPLAYABLE,
     csaction = TRUE;
     sts = om$send(msg = message GRvg.GRchgprops(&msg_loc, &csaction, &csmask),
                    targetid = new_compsf->objid,
                    targetos = new_compsf->osnum,
                    senderid = NULL_OBJID);
     EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_Fail,wrapup);

   }
   else
   {
       /* add the planar end cap surface as the last element on the composite
        * surface's channel. We know that there are "num_sfs" surfaces in this
        * composite. Therefore the first avl. index is "num_sfs".
        */

       sts = om$send( msg = message GRvg.GRrigidconn
                                    (&msg_loc, surf, (IGRlong *)&num_sfs),
                       targetid = plane->objid,
                       targetos = const_os,
                       senderid = NULL_OBJID);
       EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_Fail,wrapup);
   }


   wrapup:

   /* on error, delete any objects created inside here */
   if (!(1&sts&msg_loc&*EFmsg))
   {
      if (loopset_id.objid != NULL_OBJID)
      {  sts = om$send (msg  = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = loopset_id.objid,
                  targetos = loopset_id.osnum);
      }
      /* if the loop was already connected to the loopset, it might have ALREADY
       * gotten deleted above, but if not connected, it needs to be deleted.
       */
      if (loops.objs && (loops.objs[0] != NULL_OBJID))
      {  sts = om$send (msg  = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = loops.objs[0],
                  targetos = const_os);
      }

      if (new_compsf->objid != NULL_OBJID)
      {
         /* Note that if this composite surface had already been connected to 
          * the input surfaces, then those are deleted too. Ideally, we should
          * not mess with the inputs, but in this case, since there is an error,
          * the input surfaces will get deleted anyway, outside this function.
          * Therefore we allow them to get deleted in here.
          */
         sts = om$send (msg  = message GRgraphics.GRdelete(&msg_loc, md_env),
                  senderid = NULL_OBJID,
                  targetid = new_compsf->objid,
                  targetos = new_compsf->osnum);
      }

   }/*if (error) */

   if (cv_obj)
    stackfree(cv_obj);
   if (cvs)
    {om$dealloc(ptr=cvs);}
   if (sfs)
    {om$dealloc(ptr=sfs);}
   if (ed_xyz_geom.poles)
     {om$dealloc(ptr=ed_xyz_geom.poles);}
   if (ed_xyz_geom.knots)
     {om$dealloc(ptr=ed_xyz_geom.knots);}
   if (ed_xyz_geom.weights)
     {om$dealloc(ptr=ed_xyz_geom.weights);}
   if (plane_geom)
    {om$dealloc(ptr=plane_geom);}
   if (out_cvs.objs)
     {om$dealloc (ptr=out_cvs.objs);} 
   if (loops.objs)
     {om$dealloc (ptr=loops.objs);} 
   if (sfedges)
     {om$dealloc (ptr=sfedges);}

   EMWRAPUP (*EFmsg, sts, "In EFcap_surface_with_plane");
}

end implementation Root;
