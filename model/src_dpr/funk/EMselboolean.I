/*
 * This file contains all the functions related to sort point generation.
 *
 * HISTORY:
 *
 * Rustagi  ????     Creation.
 *
 * NP       9/8/93   Do not do point location to generate the UV values
 *                   corresponding to XYZ points on the surface. The values
 *                   already returned by GRptproject is what we need. See
 *                   comments inside function.
 * NP       9/9/93   Changed argument "sortpt_info" from EMSsortpt_info to
 *                   EMparms. Associated changes made in function.
 * NP      9/21/93   Do not allow zero intersections of ray with surface, if
 *                   option is
 * Rustagi 9/24/93   Fix for the crash problems in placing radial pattern
 *                   for holes. Also fix for TR#119307657. There are some 
 *                   other changes which are made in support for reference
 *                   planes associated with from_to options originally designed
 *                   for Add/Remove material features. Also moved the history
 *                   at the top of this file.
 */


class implementation Root;


#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "EMSdef.h"

/* externs */
extern IGRint GRcreate_curve_by_option();
extern void EMsort_by_parameter();
extern IGRboolean BSnorvec(), BSmvecsclr(), BSfreecv(), BSpl_cv_int();
extern void BSalloccv(), BSpolyxt2sd();
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_GR3dlineseg_class_id;

/* imports */
from GRgraphics import GRcopy, GRxform, GRptproject;
from GRvg import GRgetsize, GRgetgeom, EMptatpr;
from EMSsurface import EMcrvsrfint;  
from EMSsolid import EMpoint_locate;
from GRcurve import EMcrvcrvint, EMpartofcv, GRendpts;
from GRowner import GRget_components, GRget_number_components;
from EMSloopset import EMpt_location;
from GRlinear import GRputpolyline;
from EMSdatpln import EMget_pln_info;


/* Function to cast ray from a given point on the curve. Incase vector
   is the input, the range is determined by the input argument. 

  Input :
    Curve : id of the curve/geometry.
    point : the xyz point on the curve as the origin of constructing ray.
    vector: The direction to construct ray segment. Can be NULL if does not
            make sense like in the case of trace curve is provided.
    range : length of the ray incase vector is the input.
    trace : id of the curve/geometry. (Vector input is NULL). 
   
  Output  : A curve which passes through the given point in the direction
            of vector or trace. 
*/

IGRlong EMget_the_ray(msg,
                     startpt, 
                     vector,
                     range,
                     tracecv,
                     startpt_trace_vec,
                     modenv,
                     const_args,
                     outcrv)
IGRlong *msg;
IGRpoint startpt;
IGRdouble *vector;
IGRdouble  range;
struct GRid *tracecv;
IGRpoint startpt_trace_vec;
struct GRmd_env *modenv;
struct GRvg_construct *const_args;
struct GRid *outcrv;
{
IGRlong msg_loc, sts;
IGRpoint endpt;
IGRint i;
IGRboolean success;
IGRvector xforms_vec;
IGRdouble polpts[6];
struct IGRpolyline polyline;
struct GRpost_info postinfo;
IGRmatrix xform_mat;
IGRshort xform_mattyp;
struct GRid curve_copy, loccrv;
BSrc rc;
OM_S_OBJID save_md_id;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 postinfo.construct_flag = TRUE;

 if(vector && range)
  {
  /* get the unit vector */
  BSnorvec(&rc, vector);
  sts = BSmvecsclr(&rc, &range, vector);
  EMerr_hndlr(EMSerror(sts), *msg, EMS_E_BSerror, ret_end);
  endpt[0] = startpt_trace_vec[0] + vector[0];
  endpt[1] = startpt_trace_vec[1] + vector[1];
  endpt[2] = startpt_trace_vec[2] + vector[2];
  OM_BLOCK_MOVE(startpt_trace_vec, polpts, 3 * sizeof(IGRdouble));
  OM_BLOCK_MOVE(endpt, polpts+3, 3 * sizeof(IGRdouble));

  polyline.num_points = 2;
  polyline.points = polpts;
  loccrv.osnum = modenv->md_id.osnum;

  sts = om$construct(classid = OPP_GR3dlineseg_class_id,
                     p_objid = &(loccrv.objid),
                     osnum = loccrv.osnum);
  save_md_id = modenv->md_id.objid;
  modenv->md_id.objid = NULL_OBJID;
  sts = om$send(msg = message GRlinear.GRputpolyline(&msg_loc, modenv,
                          &postinfo, &polyline, &loccrv.objid),
                        senderid = NULL_OBJID,
                        targetid = loccrv.objid,
                        targetos = loccrv.osnum);
  modenv->md_id.objid = save_md_id;
  EMerr_hndlr(EMSerror(sts), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
  loccrv.objid = tracecv->objid;
  loccrv.osnum = tracecv->osnum;
  }

  /* It means the trace curve is being provided and we have to transform
   * the given trace curve upto the startpt. If we make the assumption that
   * the trace information passed in is originating from the profile, then
   * we have to find which end point of the trace is lying on the profile
   * to find the linear transformation matrix. 
   */
  for(i=0; i< 3; i++)
  xforms_vec[i] = startpt[i] - startpt_trace_vec[i];
  success = MAtrlmx(&msg_loc, xforms_vec, (IGRdouble *)xform_mat);
  EMerr_hndlr (!success || !(1&msg_loc), *msg, EMS_E_BSerror, ret_end);
  /* find out the type of the matrix */
  success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattyp);
  EMerr_hndlr (!success || !(1&msg_loc), *msg, EMS_E_BSerror, ret_end);
 /*
  * Copying and transforming the object.
  */
  curve_copy.osnum = loccrv.osnum;
  save_md_id = const_args->env_info->md_id.objid;
  const_args->env_info->md_id.objid = NULL_OBJID;
  
  sts = om$send (msg= message GRgraphics.GRcopy(&msg_loc,
                                                modenv,
                                                const_args->env_info,
                                                &(curve_copy.objid)),
                                  senderid=NULL_OBJID,
                                  targetid=loccrv.objid,
                                  targetos=loccrv.osnum);
  const_args->env_info->md_id.objid = save_md_id;
  EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

  /* xform the copy of the the curve by the given matrix, ONLY if both the
   * matrix and its type are not NULL
   */
   if ((xform_mattyp != NULL)  && (xform_mat != NULL))
   {
    save_md_id = modenv->md_id.objid;
    modenv->md_id.objid = NULL_OBJID;
   sts = om$send (msg = message GRgraphics.GRxform(&msg_loc,
                                    modenv, &xform_mattyp, xform_mat,
                                    &outcrv->objid),
                  senderid = NULL_OBJID,
                  targetid = curve_copy.objid,
                  targetos = curve_copy.osnum);
    modenv->md_id.objid = save_md_id;
    modenv->md_id.objid = NULL_OBJID;
   EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
   }
  outcrv->osnum = curve_copy.osnum;
  sts = om$send (msg = message Root.delete(1),
                     targetid = loccrv.objid,
                     targetos = loccrv.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);

ret_end:

 return(sts);
}

/*
 * This function selects the right point for the proper transformation
 * of the given trace curve. This function is basically mean to counter
 * those situations in which the trace end point is lying on the profile
 * rather than the start point. The proper selection of the point is
 * very crucial factor in the transformation of the curve. Incase the
 * trace curve is close then any point on the trace will serve our purpose.
 */

IGRlong EMget_the_right_point(msg,
                              profile,
                              trace,
                              modenv,
                              the_point)
IGRlong *msg;
struct GRid *profile, *trace;
struct GRmd_env *modenv;
IGRpoint the_point;
{
 IGRlong msg_loc, sts, pnt_slots, grand_num_pt;
 IGRdouble *inter_pnts_xyz;
 IGRlong EMget_component_info();
 
 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
/*
 * Get the nature of the trace curve i.e. simple or composite. Incase of
 * composite, intersect the first and last segment of the trace with the
 * profile else the sole segment. This function is ofcourse based on the
 * assumption that the trace is passing through a point on the profile which
 * is not a severe assumption considering the fact that incase the surfces
 * are produced through skinning, better it pass through the end of the
 * profile otherwise ...it may not produce nice surfaces.
 */
 pnt_slots = 0;
 grand_num_pt = 0;
 inter_pnts_xyz = NULL;
 sts = om$send(msg = message GRcurve.EMcrvcrvint(&msg_loc,
                                      NULL,
                                      &modenv->md_env, 
                                      NULL,
                                      profile,
                                      &modenv->md_env,
                                      FALSE,
                                      &pnt_slots,
                                      &grand_num_pt,
                                      NULL,
                                      NULL, 
  				      NULL,
                                      &inter_pnts_xyz,
                                      NULL, NULL, NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = trace->objid,
                        targetos = trace->osnum);
 EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
 if(grand_num_pt IS 0)
  {
  *msg = EMS_E_InvalidCase; /* The trace does not pass through a point
                               on the profile. || weired combination of
                               the trace and profile */
  sts = EMS_S_Fail;
  goto ret_end;
  }
 else
  OM_BLOCK_MOVE(&inter_pnts_xyz[0], the_point, 3 * sizeof(IGRdouble));

ret_end:
 if(inter_pnts_xyz) om$dealloc(ptr = inter_pnts_xyz);
 return(sts);
}

/*
 * This function takes in a set of points and generate the sort points
 * based on the options like add material/remove material.
 */

IGRlong EMgnsortpts(msg,
                    cvgeom,
                    modenvcv,
                    solid_GRid,
                    feasfid,
                    modenvsf,
                    feaopts,
                    num_sort,
                    sortpt_info)
IGRlong *msg;
struct IGRbsp_curve *cvgeom;
struct GRmd_env *modenvcv;
struct GRid *solid_GRid, *feasfid;
struct GRmd_env *modenvsf;
IGRlong feaopts;
IGRuint *num_sort;
struct EMparms **sortpt_info;
{
 IGRlong msg_loc, sts;
 struct EMparms *loc_sortinfo;
 IGRpoint start_pnt, stop_pnt, junkpt, proj_pt;
 IGRdouble **pts, **locpts;
 IGRint loc_numint, i, num_sortpts, j, k;
 struct GRparms *parminfocv=NULL, *parminfosf=NULL;
 IGRdouble *xyz_pts=NULL;
 IGRulong *intprops=NULL;
 IGRlong pnt_slots, numint;
 struct GRparms proj_parms;
 OM_S_CHANSELECT to_loopset;
 OMuint  N;
 IGRint temp_var;
 GRspacenum startpt_match, stoppt_match;
 IGRboolean world, no_intersection;
 IGRulong loc_junkpt;

 *msg = EMS_S_Success;
 sts =  OM_S_SUCCESS;
 loc_sortinfo = NULL;
 world = TRUE;
 startpt_match = FALSE;
 stoppt_match = FALSE;

 sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);
 /*
  * Get the intersection between the curve and the base solid.
  */
  pnt_slots = 0;
  numint = 0;
  sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg_loc,
                              NULL, &modenvsf->md_env, cvgeom, NULL,
                              &modenvcv->md_env, FALSE,
                              &pnt_slots, &numint, NULL,
                              &parminfosf, &parminfocv, &xyz_pts, &intprops),
                         senderid = NULL_OBJID,
                         targetid = solid_GRid->objid,
                         targetos = solid_GRid->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
  if(numint IS 0)
   no_intersection = TRUE;
  else
   no_intersection = FALSE;    
  if(numint > 1)
  EMsort_by_parameter(parminfosf, parminfocv, xyz_pts, intprops, numint);
  if(parminfocv[0].u IS 0.0)
   startpt_match = TRUE;
  if(parminfocv[numint - 1].u IS 1.0)
   stoppt_match = TRUE;
 /*
  * Finding the start and stop point for the curve.
  */
 N = cvgeom->num_poles;
 OM_BLOCK_MOVE(&cvgeom->poles[0], start_pnt, sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3 * (N - 1)], stop_pnt, sizeof(IGRpoint));

 if(startpt_match && stoppt_match)
  loc_numint = numint;
 else
 if((startpt_match && !stoppt_match) || (!startpt_match && stoppt_match)) 
  loc_numint = numint + 1;
 else
  loc_numint = numint + 2;

 pts = NULL;
 pts = (IGRdouble **) om$malloc(size = loc_numint * sizeof(IGRdouble *));
 EMerr_hndlr (!pts, *msg, EMS_E_NoDynamicMemory, ret_end);
 for(i=0 ;i< loc_numint; i++)
 {
 pts[i] = NULL;
 pts[i] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
 EMerr_hndlr (!pts[i], *msg, EMS_E_NoDynamicMemory, ret_end);
 }

 if(startpt_match && !stoppt_match)
  { 
  for(i=0; i<loc_numint; i++)
   {
   if(i IS (loc_numint-1))
    OM_BLOCK_MOVE(stop_pnt, pts[i], 3 * sizeof(IGRdouble));
   else
    {
    if(i IS 0)
     OM_BLOCK_MOVE(start_pnt, pts[i], 3 * sizeof(IGRdouble));
    else
     OM_BLOCK_MOVE(&xyz_pts[3*(i-1)], pts[i], 3 * sizeof(IGRdouble));
    }
   }
  }
 else
 if(!startpt_match && stoppt_match)
  {
   for(i=0; i<loc_numint; i++)
   {
   if(i IS 0)
    OM_BLOCK_MOVE(start_pnt, pts[i], 3 * sizeof(IGRdouble));
   else
    {
    if(i IS (loc_numint - 1))
     OM_BLOCK_MOVE(stop_pnt,  pts[i], 3 * sizeof(IGRdouble));
    else
     OM_BLOCK_MOVE(&xyz_pts[3*(i-1)], pts[i], 3 * sizeof(IGRdouble));
    }
   }
  }
 else
 if(startpt_match && stoppt_match)
  {
  for(i=0; i<loc_numint; i++)
   OM_BLOCK_MOVE(&xyz_pts[3*i], pts[i], 3 * sizeof(IGRdouble));
  }
 else
  {
  for(i=0; i<loc_numint; i++)
   {
   if(i IS 0)
    OM_BLOCK_MOVE(start_pnt, pts[i], 3 * sizeof(IGRdouble));
   else
   if(i IS (loc_numint -1))
    OM_BLOCK_MOVE(stop_pnt, pts[i], 3 * sizeof(IGRdouble));
   else
    OM_BLOCK_MOVE(&xyz_pts[3*(i-1)], pts[i], 3 * sizeof(IGRdouble));
   }
  }
 for(i=0; i<3; i++)
 junkpt[i] = (pts[0][i] + pts[1][i])/2.0;

 sts = om$send(msg = message EMSsolid.EMpoint_locate(&msg_loc,
                            modenvsf, NULL, junkpt, NULL, &loc_junkpt),
                      senderid = NULL_OBJID,
                      targetid = solid_GRid->objid,
                      targetos = solid_GRid->osnum);
 EMSmsgReport(msg_loc, "EMgnsortpts:EMSsolid.EMpoint_locate", FALSE);

 if(loc_numint % 2 IS 0)
  num_sortpts = loc_numint/2;
 else
  num_sortpts = (loc_numint + 1)/2;

 locpts = NULL;
 locpts = (IGRdouble **) om$malloc(size = num_sortpts * sizeof(IGRdouble *));
 EMerr_hndlr (!locpts, *msg, EMS_E_NoDynamicMemory, ret_end);
   
 if(no_intersection)
  {
  locpts[0] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
  EMerr_hndlr (!locpts[0], *msg, EMS_E_NoDynamicMemory, ret_end);
  locpts[0][0] = (pts[0][0] + pts[0][0])/2.0;
  locpts[0][1] = (pts[0][1] + pts[0][1])/2.0;
  locpts[0][2] = (pts[0][2] + pts[0][2])/2.0;
  goto LOC_SORT_INFO;
  }

 temp_var = 0;
 if(feaopts & EMSadd_material) 
 {
  if(loc_junkpt IS EMS_S_INSOLID)
  {
   for(i=1, k=0; (i<loc_numint && k<num_sortpts); i=i+2, k++)
    {
    j= i+1;
    if(j<loc_numint)
     {
     temp_var ++;
     locpts[k] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
     EMerr_hndlr (!locpts[k], *msg, EMS_E_NoDynamicMemory, ret_end);
     locpts[k][0] = (pts[i][0] + pts[j][0])/2.0;
     locpts[k][1] = (pts[i][1] + pts[j][1])/2.0;
     locpts[k][2] = (pts[i][2] + pts[j][2])/2.0;
     }
    }
  }
 else
  if(loc_junkpt IS EMS_S_OUTSOLID)
   {
   for(i=0, k=0; (i<loc_numint && k<num_sortpts); i=i+2, k++)
    {
    j= i+1;
    if(j<loc_numint)
     {
     temp_var ++;
     locpts[k] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
     EMerr_hndlr (!locpts[k], *msg, EMS_E_NoDynamicMemory, ret_end);
     locpts[k][0] = (pts[i][0] + pts[j][0])/2.0;
     locpts[k][1] = (pts[i][1] + pts[j][1])/2.0;
     locpts[k][2] = (pts[i][2] + pts[j][2])/2.0;
     }
    }
   }
  else
   {
    *msg = EMS_E_Fail;
    goto ret_end;
   }
 }
 if(feaopts & EMSremove_material) 
 {
  if(loc_junkpt IS EMS_S_INSOLID)
  {
   for(i=0, k=0; (i<loc_numint && k<num_sortpts); i=i+2, k++)
    {
    j= i+1;
    if(j<loc_numint)
     {
     temp_var ++;
     locpts[k] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
     EMerr_hndlr (!locpts[k], *msg, EMS_E_NoDynamicMemory, ret_end);
     locpts[k][0] = (pts[i][0] + pts[j][0])/2.0;
     locpts[k][1] = (pts[i][1] + pts[j][1])/2.0;
     locpts[k][2] = (pts[i][2] + pts[j][2])/2.0;
     }
    }
  }
 else
  if(loc_junkpt IS EMS_S_OUTSOLID)
   {
   for(i=1, k=0; (i<loc_numint && k<num_sortpts); i=i+2, k++)
    {
    j= i+1;
    if(j<loc_numint)
     {
     temp_var ++;
     locpts[k] = (IGRdouble *)om$malloc(size = 3 * sizeof(IGRdouble));
     EMerr_hndlr (!locpts[k], *msg, EMS_E_NoDynamicMemory, ret_end);
     locpts[k][0] = (pts[i][0] + pts[j][0])/2.0;
     locpts[k][1] = (pts[i][1] + pts[j][1])/2.0;
     locpts[k][2] = (pts[i][2] + pts[j][2])/2.0;
     }
    }
   }
  else
   {
    *msg = EMS_E_Fail;
    goto ret_end;
   }
 }

 /*
  * Allocating the memory for the sort points.
  */
 LOC_SORT_INFO:
 loc_sortinfo = (struct EMparms *)om$malloc(size = temp_var *
                                           sizeof(struct EMparms ));
 EMerr_hndlr (!loc_sortinfo, *msg, EMS_E_NoDynamicMemory, ret_end);
 for(i=0; i<temp_var; i++)
  {
  sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                              &modenvsf->md_env.matrix_type,
                              modenvsf->md_env.matrix,
                              locpts[i],
                              proj_pt,
                              &proj_parms),
                       senderid = NULL_OBJID,
                       targetid = feasfid->objid,
                       targetos = feasfid->osnum);
  EMSmsgReport(msg_loc, "EMgnsortpts:GRowner.GRptproject", FALSE);
  loc_sortinfo[i].leaf_id = proj_parms.leaf_id;
  loc_sortinfo[i].u = proj_parms.u;
  loc_sortinfo[i].v = proj_parms.v;
  }
 *num_sort = temp_var;
 *sortpt_info = loc_sortinfo;
ret_end:
 if(parminfosf) om$dealloc (ptr = parminfosf);
 if(parminfocv) om$dealloc (ptr = parminfocv);
 if(xyz_pts) om$dealloc (ptr = xyz_pts);
 if(intprops) om$dealloc (ptr = intprops);
 for(i=0; i<temp_var; i++)
  if(locpts[i])om$dealloc(ptr = locpts[i]);
  if(locpts) om$dealloc(ptr = locpts);
 for(i=0; i<loc_numint; i++)
  if(pts[i])om$dealloc(ptr = pts[i]);
  if(pts) om$dealloc(ptr = pts);

 return(sts);
}

/*
 * This function take in ray, base solid, feature type, id's of
 * the surfaces OR ref. planes and then based on the feature type
 * extract a portion of the original ray. It then call the intersection
 * of this ray with the base solid to create the input for the sort point
 * generation.
 */

IGRlong EMprocess_ray(msg,
                      ray,
                      modenvcv,
                      feat_type,
                      solid_GRid,
                      surfid,
                      modenvsf,
                      newgeom)
IGRlong *msg;
struct GRid *ray;
struct GRmd_env *modenvcv;
IGRlong feat_type;
struct GRid *solid_GRid;
struct GRmd_env *modenvsf;
struct GRid *surfid;
struct IGRbsp_curve **newgeom; 
{
 IGRlong sts, msg_loc, num_bytes, pnt_slots, num_of_int;
 IGRboolean stat_func;
 struct IGRbsp_curve *geom, *loc_geom;
 struct GRparms startparm, stopparm, midparm;
 struct GRparms *cv_pnt_start=NULL, *cv_pnt_stop=NULL;
 struct GRparms *parminfocv=NULL, *parminfosf=NULL;
 IGRdouble *xyz_pts=NULL, *int_points_fr=NULL, *a_fr=NULL, *b_fr=NULL;
 IGRdouble *u_fr=NULL, *int_points_to=NULL, *a_to=NULL, *b_to=NULL, *u_to=NULL;
 IGRpoint base_from, base_to;
 BSrc rc;
 IGRint n_int, n_seg;
 IGRdouble tmp_start_u, tmp_stop_u;
 IGRvector from_normal, to_normal;
 OMuword classid;
 IGRulong *intprops=NULL;
 IGRlong locpnt_slots, locnum_of_int;

 sts = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;
 *newgeom = NULL;
 startparm.u=-1.0;
 stopparm.u=-1.0;
 midparm.u=-1.0;
 loc_geom = NULL;
 geom = NULL;
 /*
  * Get the size and geometry of the curve/ray passed in.
  */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                              &modenvcv->md_env.matrix_type,
                              modenvcv->md_env.matrix, &num_bytes),
                      senderid = NULL_OBJID,
                      targetid = ray->objid,
                      targetos = ray->osnum);
 EMSmsgReport(msg_loc, "EMgetsort_points:GRvg.GRgetsize", FALSE);
 geom = (struct IGRbsp_curve *)om$malloc(size = num_bytes);
 EMerr_hndlr(!geom, *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                              &modenvcv->md_env.matrix_type,
                              modenvcv->md_env.matrix,
                              (IGRchar *)geom),
                       senderid = NULL_OBJID,
                       targetid = ray->objid,
                       targetos = ray->osnum);
 EMSmsgReport(msg_loc, "EMgetsort_points :GRvg.GRgetgeom", FALSE);
 if(feat_type & EMSfeature_from_to || feat_type & EMSfeature_thru_until)
  {
  if(surfid[0].objid != NULL_OBJID)
   {
   sts = om$get_classid(objid = surfid[0].objid,
                        osnum = surfid[0].osnum,
                        p_classid = &classid);
   if(!(1&sts)) goto ret_end;
   if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS)
    {
    sts = om$send(msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                                  NULL,
                                  modenvsf,
                                  NULL,
                                  NULL,
                                  from_normal,
                                  base_from,
                                  NULL),
                       senderid = NULL_OBJID,
                       targetid = surfid[0].objid,
                       targetos = surfid[0].osnum);
    if(!(1&sts)) goto ret_end; 
    /*
     * allocating the memory for the math routine
     */
    int_points_fr=(IGRdouble *)alloca(3 * geom->num_poles * sizeof(IGRdouble));
    u_fr = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
    a_fr = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
    b_fr = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
    sts = BSpl_cv_int(&rc, geom, base_from, from_normal, &n_int, int_points_fr,
                      u_fr, &n_seg, a_fr, b_fr);
    if(n_int)
     tmp_start_u = u_fr[0];
    else
     tmp_start_u = -1.0;
    }
   else
   {
   pnt_slots=0;
   num_of_int=0;
   sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg_loc,
                              NULL, &modenvsf->md_env, geom, NULL,
                              &modenvcv->md_env, FALSE,
                              &pnt_slots, &num_of_int, NULL,
                              NULL, &cv_pnt_start, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = surfid[0].objid,
                         targetos = surfid[0].osnum);
   EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
   if(num_of_int)
   tmp_start_u = cv_pnt_start->u;
   else
   tmp_start_u = -1.0;
   }
  }
  if(feat_type & EMSfeature_from_to)
   {
   if(surfid[1].objid != NULL_OBJID)
    {
    sts = om$get_classid(objid = surfid[1].objid,
                        osnum = surfid[1].osnum,
                        p_classid = &classid);
    if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS)
     {
     sts = om$send(msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                                  NULL,
                                  modenvsf,
                                  NULL,
                                  NULL,
                                  to_normal,
                                  base_to,
                                  NULL),
                       senderid = NULL_OBJID,
                       targetid = surfid[1].objid,
                       targetos = surfid[1].osnum);
     if(!(1&sts)) goto ret_end; 
     /*
      * allocating the memory for the math routine
      */
     int_points_to=(IGRdouble *)alloca(3 * geom->num_poles * sizeof(IGRdouble));
     u_to = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
     a_to = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
     b_to = (IGRdouble *)alloca(geom->num_poles * sizeof(IGRdouble));
     sts = BSpl_cv_int(&rc, geom, base_to, to_normal, &n_int, int_points_to,
                      u_to, &n_seg, a_to, b_to);
     if(n_int)
     tmp_stop_u = u_to[0];
     else
     tmp_stop_u = -1.0;
     }
    else
     {
     pnt_slots=0;
     num_of_int=0;
     sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg_loc,
                              NULL, &modenvsf->md_env, geom, NULL,
                              &modenvcv->md_env, FALSE,
                              &pnt_slots, &num_of_int, NULL,
                              NULL, &cv_pnt_stop, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = surfid[1].objid,
                         targetos = surfid[1].osnum);
     EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
     if(num_of_int)
      tmp_stop_u = cv_pnt_stop->u;
     else
      tmp_stop_u = -1.0;
     }
    }
   }
    startparm.u = tmp_start_u;
    stopparm.u = tmp_stop_u;
    midparm.u = (startparm.u + stopparm.u)/2.0;
  }
  else
  if(feat_type & EMSfeature_thru_until)
   {
   startparm.u = 0.0;
   stopparm.u = tmp_start_u;
   midparm.u = (startparm.u + stopparm.u)/2.0;
   }
  else
  if(feat_type & EMSfeature_thru_next || feat_type & EMSfeature_thru_all ||
     feat_type & EMSfeature_to_next)
  {
  /* Get the intersection between the base solid and the ray and extract
   * only that part of the ray i.e. from the start to next intersection.
   */
  locpnt_slots = 0;
  locnum_of_int = 0;
  sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg_loc,
                              NULL, &modenvsf->md_env, geom, NULL,
                              &modenvcv->md_env, FALSE,
                              &locpnt_slots, &locnum_of_int, NULL,
                              &parminfosf, &parminfocv, &xyz_pts, &intprops),
                         senderid = NULL_OBJID,
                         targetid = solid_GRid->objid,
                         targetos = solid_GRid->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
  if(locnum_of_int)
  {
   if(locnum_of_int > 1)
   EMsort_by_parameter(parminfosf, parminfocv, xyz_pts, intprops,locnum_of_int);

   if(feat_type & EMSfeature_thru_next)
   {
   startparm.u = 0.0;
   stopparm.u = parminfocv[1].u;
   midparm.u = (startparm.u + stopparm.u)/2.0;
   }
   else
   if(feat_type & EMSfeature_thru_all)
   {
   startparm.u = 0.0;
   stopparm.u = parminfocv[locnum_of_int - 1].u;
   midparm.u = (startparm.u + stopparm.u)/2.0;
   }
   else
   if(feat_type & EMSfeature_to_next)
   {
   startparm.u = 0.0;
   stopparm.u = parminfocv[0].u;
   midparm.u = (startparm.u + stopparm.u)/2.0;
   }
  }
 }
  /*
   * Extracting the part of the curve using math.
   */
   if(!(startparm.u < 0.0 || stopparm.u < 0.0 || midparm.u < 0.0))
   {
   BSalloccv(
     geom->order,
     geom->num_poles + 2 * geom->order - 1,
     geom->rational,
     0,                        /* No boundaries */
     &loc_geom,
     &msg_loc);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

    stat_func = BSpartofcv(
      &msg_loc,
      geom,
      startparm.u,
      midparm.u,
      stopparm.u,
      loc_geom);
    EMerr_hndlr(! stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  if(newgeom)
  *newgeom = loc_geom;
  }
ret_end:
  if(geom) om$dealloc (ptr = geom);
  if(cv_pnt_start) om$dealloc (ptr = cv_pnt_start);
  if(cv_pnt_stop) om$dealloc (ptr = cv_pnt_stop);
  if(parminfocv) om$dealloc (ptr = parminfocv);
  if(parminfosf) om$dealloc (ptr= parminfosf);
  if(xyz_pts) om$dealloc (ptr = xyz_pts);
  if(intprops) om$dealloc (ptr = intprops);

  return(sts);
}

/*
 * This function takes in the object id, its module environment and the
 * type of the object. It returns the number of components and the related
 * id's and a flag indicating the nature of the object i.e. composite
 * or non composite.
 */

IGRlong EMget_component_info(msg,
                             objectid,
                             modenv,
                             num_comps,
                             compids,
                             flag)

IGRlong *msg;
struct GRid *objectid;
struct GRmd_env *modenv;
IGRint *num_comps;
struct GRid **compids;
IGRboolean *flag;

/*
 msg         : code returned.
 objectid    : GRid of the object passed in.
 modenv      : Module environment of the object.
 num_comp    : OUTPUT : Number of the components objects.
 compids     : OUTPUT : The ids of the component objects.
 flag        : OUTPUT : Indicating if it a composite or non composite.
*/

{
 IGRlong sts, msg_loc;
 IGRint count, junk;
 OMuword classid;
 struct GRid *comps;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 /*
  * Get the classid of the object passed in.
  */
 sts = om$get_classid(objid = objectid->objid,
                         osnum = objectid->osnum, p_classid = &classid);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);
 if( om$is_ancestry_valid(subclassid = classid,
      superclassid = OPP_EMScomposite_class_id) IS OM_S_SUCCESS)
   *flag =TRUE;
  else
   *flag = FALSE;
 if(*flag)
 {
 sts = om$send(msg = message GRowner.GRget_number_components(&msg_loc, &count),
                              senderid = NULL_OBJID,
                              targetid = objectid->objid,
                              targetos = objectid->osnum);
 EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
 comps = (struct GRid *)om$malloc(size = count * sizeof(struct GRid ));
 EMerr_hndlr(!comps, *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRowner.GRget_components(&msg_loc,
                             modenv, comps, count, &junk, 0, MAXINT),
                     senderid = NULL_OBJID,
                     targetid = objectid->objid,
                     targetos = objectid->osnum);
 EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
 }
 else
 {
 comps = (struct GRid *)om$malloc(size = sizeof(struct GRid));
 comps[0].objid = objectid->objid;
 comps[0].osnum = objectid->osnum;
 count = 1;
 }
 *compids = comps;
 *num_comps = count;
ret_end:

return(sts);
}

/* This function takes in a curve, base solid, and the feature surfaecs and
 * options associated with i.e. from/to, until etc, and whether it is
 * add material/remove material. It outputs the the sort point information.
 */

IGRlong EMgen_rightsortpts(msg,
                           profid,
                           modenvcv,
                           startpt_vec,
                           vector,
                           range,
                           trace,
                           solid_GRid,
                           feasfs,
                           surfid,
                           modenvsf,
                           array_size,
                           array,
                           feaopts,
                           matopts,
                           const_args,
                           numofsort,
                           sortpt)
IGRlong *msg;
struct GRid *solid_GRid, *profid, *surfid, *trace, *feasfs;
IGRdouble *startpt_vec, *vector, range;
struct GRmd_env *modenvcv, *modenvsf;
IGRint array_size;
IGRdouble *array;
IGRlong feaopts, matopts;
struct GRvg_construct *const_args;
IGRint *numofsort;
struct EMparms **sortpt;
{
 IGRlong msg_loc, sts;
 struct EMparms *loc_sortpt=NULL, *sortpoints=NULL;
 struct IGRbsp_curve *newgeom=NULL;
 IGRboolean flag;
 IGRpoint the_point, point;
 IGRint i, numcomp, **numsort=NULL, temp_var, j, newsize;
 struct GRid *compids=NULL, outid;
 BSrc rc;
 IGRlong EMget_the_right_point();
 IGRlong EMget_component_info();
 IGRlong EMget_the_ray(), EMprocess_ray();
 IGRlong EMgnsortpts();

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 temp_var = 0;
 *sortpt = NULL;
 newsize = 0;


 sts = EMget_component_info(&msg_loc, profid, modenvcv, &numcomp, &compids,
                            &flag);
 EMSmsgReport(msg_loc, "EMgen_rightsortpts:EMget_component_info", FALSE);
 if(trace)
 {
 sts = EMget_the_right_point(&msg_loc, profid, trace, modenvcv, the_point); 
 EMSmsgReport(msg_loc, "EMgen_rightsortpts:EMget_the_right_point", FALSE); 
 }
 else
 OM_BLOCK_MOVE(startpt_vec, the_point, sizeof(IGRpoint));
 numsort = (IGRint **) om$malloc (size = numcomp * sizeof(IGRint *));
 for(i=0; i<numcomp; i++)
  numsort[i] = (IGRint *)om$malloc(size = array_size * sizeof(IGRint));

 for(i=0; i<numcomp; i++)
 {
 for(j=0; j<array_size; j++)
  {
  numsort[i][j] = 0;
  sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                                    &modenvcv->md_env.matrix_type,
                                    modenvcv->md_env.matrix,
                                    &array[j], 1, point),
                       senderid = NULL_OBJID,
                       targetid = compids[i].objid,
                       targetos = compids[i].osnum);
  EMSmsgReport(msg_loc, "EMgen_rightsortpts:GRvg.EMptatpr", FALSE);
  sts = EMget_the_ray(&msg_loc, point, vector, range, trace, the_point,
             modenvcv, const_args, &outid);
  EMSmsgReport(msg_loc, "EMgen_rightsortpts:EMget_the_ray", FALSE);
  sts = EMprocess_ray(&msg_loc, &outid, modenvcv, feaopts, solid_GRid,
             surfid, modenvsf, &newgeom);
  EMSmsgReport(msg_loc, "EMgen_rightsortpts:EMprocess_ray", FALSE);
  if(newgeom != NULL)
  {
  sts = EMgnsortpts(&msg_loc, newgeom, modenvcv, solid_GRid, feasfs,
      modenvsf, matopts, &numsort[i][j], &loc_sortpt);
  EMSmsgReport(msg_loc, "EMgen_rightsortpts:EMgnsortpts", FALSE);
  }
  if(numsort[i][j]) 
  {
  temp_var ++;
  newsize = newsize + numsort[i][j];
  if(temp_var IS 1)
   {
   sortpoints = (struct EMparms *)om$malloc(size = newsize *
                            sizeof(struct EMparms));
   EMerr_hndlr (!sortpoints, *msg, EMS_E_NoDynamicMemory, ret_end);
   OM_BLOCK_MOVE(loc_sortpt, &sortpoints[0],
                             newsize * sizeof(struct EMparms));
   }
  else
   {
   sortpoints = (struct EMparms *)om$realloc(ptr = (IGRchar *)sortpoints,
                          size = newsize * sizeof(struct EMparms));
   EMerr_hndlr (!sortpoints, *msg, EMS_E_NoDynamicMemory, ret_end);
   OM_BLOCK_MOVE(loc_sortpt, &sortpoints[(newsize - numsort[i][j])] ,
                            numsort[i][j] * sizeof(struct EMparms));
   }
  }
  if(loc_sortpt) om$dealloc (ptr = loc_sortpt); loc_sortpt = NULL;
  if(newgeom) BSfreecv(&rc, newgeom); newgeom = NULL;
  sts = om$send (msg = message Root.delete(1),
                       targetid = outid.objid,
                       targetos = outid.osnum,
                       senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);

  } 
 } 
 *sortpt = sortpoints;
 *numofsort = newsize;

ret_end:
 if(compids) om$dealloc (ptr = compids);
 for(i=0; i<numcomp; i++)
  if(numsort[i]) om$dealloc (ptr = numsort[i]); 
  if(numsort) om$dealloc (ptr = numsort);
 return(sts);
}
end implementation Root;
     
