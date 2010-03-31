/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;
/*
Description

This override is done such that coincident cones can be flagged as
non-intersecting.  If the method does not detect this condition then
it merely asks an ancestor to compute this intersection.

History

01/11/89 : rlw : Creation date
*/

#include "EMS.h"		/* Shared libraries */
%safe
#include <math.h>		/* fabs() */
%endsafe
#include "bs.h"			/* It has it all */
#include "bserr.h"		/* BS error return codes */
#include "bsparameters.h"	/* BSEXTRACTPAR macro */
#include "EMSmsgdef.h"		/* EMS message codes */

extern OMuword OPP_EMScone_class_id;
extern IGRboolean _new_sfsfint_math;

method EMget_int_data (
 IGRlong                       *EMmsg;
 IGRushort             options;
 struct EMSdataselect          *other_data;
 struct IGRbsp_surface         *my_geom;
 struct IGRbsp_surface         *other_geom;
 IGRdouble		       *my_uvrange;
 IGRdouble		       *other_uvrange;
 struct EMSpartolbasis         *my_partol;
 struct EMSpartolbasis         *other_partol;
 IGRint                        *num_out_cvs;
 struct EMSdataselect          **my_xyz_data;
 struct EMSdataselect          **other_xyz_data;
 struct EMSdataselect          **my_uv_data;
 struct EMSdataselect          **other_uv_data;
 IGRdouble		       ***correl_params;
 IGRchar                       *curve_type;
 IGRushort             *intinfo)
{
 IGRlong	sts;
/*
 * Initialize
 */
 *EMmsg = EMS_I_NoSolution;
 *num_out_cvs = 0;
 *my_xyz_data = NULL;
 *other_xyz_data = NULL;
 *my_uv_data = NULL;
 *other_uv_data = NULL;
 *correl_params = NULL;
 *intinfo = 0;			/* See emssfintdef.h */

 if (_new_sfsfint_math)
   return (om$send(
    mode = OM_e_wrt_message,
    msg = message EMSsubbs.EMget_int_data(
     EMmsg,
     options,
     other_data,
     my_geom,
     other_geom,
     my_uvrange,
     other_uvrange,
     my_partol,
     other_partol,
     num_out_cvs,
     my_xyz_data,
     other_xyz_data,
     my_uv_data,
     other_uv_data,
     correl_params,
     curve_type,
     intinfo),
    targetid = my_id));

/*
 * Determine if the other object is a cone
 */
 if (other_data->datatype == EMSdata_object)
  {
   OMuword	other_classid;
   struct	GRid *id;

   id = other_data->data.object;
   sts = om$get_classid(
     objid = id->objid,
     osnum = id->osnum,
     p_classid = &other_classid);
    if (! (1 & sts))
     {
      *EMmsg = EMS_E_OMerror;
      goto wrapup;
     }
   sts = om$is_ancestry_valid(
     subclassid = other_classid,
     superclassid = OPP_EMScone_class_id);
/*
 * At this point we have 2 cones.
 * Now we wish to know if they are coincident.
 */
   if (sts == OM_S_SUCCESS)
    {
     void	EFcheck_cones_for_coincidence();
     IGRboolean	call_sfsf_int;

     EFcheck_cones_for_coincidence(
      my_geom,
      other_geom,
      &call_sfsf_int);
     if (! call_sfsf_int)
      *EMmsg = EMS_I_NoIntersection;
    }
  } /* if (other_data->datatype == EMSdata_object) */
/*
 * Free up memory
 */
wrapup:
/*
 * If we have failed because we were unable
 * to properly support the operation then
 * let someone else take a shot at the problem.
 */
 if (*EMmsg == EMS_I_NoSolution)
  {
   sts = om$send(
    mode = OM_e_wrt_message,
    msg = message EMSproject.EMget_int_data(
     EMmsg,
     options,
     other_data,
     my_geom,
     other_geom,
     my_uvrange,
     other_uvrange,
     my_partol,
     other_partol,
     num_out_cvs,
     my_xyz_data,
     other_xyz_data,
     my_uv_data,
     other_uv_data,
     correl_params,
     curve_type,
     intinfo),
    targetid = my_id);
   return(sts);
  } /* if (*EMmsg == EMS_I_NoSolution) */
/*
 * The end
 */
 if (! (1 & *EMmsg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}

/*
 Description

 Given 2 elements (cone, cylinder, partial cylinder, partial cone) this
 function trys to determine if there is some coincidence between the
 cones.  If coincidence is detected or the routine determines that no
 intersection is possible it will indicate that surface/surface intersection
 need not be called.

 Notes

 If call_sfsf_int is TRUE then this does not imply that a intersection
 exists between the two cones.

 History

 01/11/89 : rlw : Creation date
 08/18/92 : NP  : Added missing typecasts for ANSI compliance.

 */

void EFcheck_cones_for_coincidence(
 cone_1,
 cone_2,
 call_sfsf_int)

struct		IGRbsp_surface *cone_1;
struct		IGRbsp_surface *cone_2;
IGRboolean	*call_sfsf_int;
{
 IGRlong	msg, i;
 IGRdouble	t[2], radii_1[2], radii_2[2];
 IGRpoint	axis_1[2], axis_2[2];
/*
 * Initialize
 */
 *call_sfsf_int = TRUE;
/*
 * Extract the axis and radius information from
 * the input surfaces
 */
 {
  extern	void BSconprop();
  IGRdouble	knots[4], height, area, volume, slant_height;
  struct	IGRbsp_curve axis_as_a_curve;

  axis_as_a_curve.knots = knots;
  axis_as_a_curve.poles = (IGRdouble *)axis_1; /*typecast ofr ANSI */
  BSconprop(
    cone_1,
    &axis_as_a_curve,
    &height,
    &radii_1[1],	/* Radius at axis_1[1] */
    &radii_1[0],	/* Radius at axis_1[0] */
    &area,
    &volume,
    &slant_height,
    &msg);
   if (msg != BSSUCC) return;
  axis_as_a_curve.poles = (IGRdouble *)axis_2; /*typecast for ANSI */
  BSconprop(
    cone_2,
    &axis_as_a_curve,
    &height,
    &radii_2[1],	/* Radius at axis_2[1] */
    &radii_2[0],	/* Radius at axis_2[0] */
    &area,
    &volume,
    &slant_height,
    &msg);
   if (msg != BSSUCC) return;
 }
/*
 * We must first determine whether or not the axes are
 * colinear.  If they are not then no coincidence is possible
 * between the cones.
 */
 {
  extern	IGRboolean MAptlnproj(), BSdistnct2();
  IGRboolean	status;
  IGRpoint	projected_point;
  struct	IGRline line;

  line.point1 = axis_1[0]; 
  line.point2 = axis_1[1]; 
  for (i = 0; i < 2; i++)
   {
    status = MAptlnproj(	/* Project the second axis on the first axis */
      &msg,
      axis_2[i],
      &line,
      projected_point,
      &t[i]);
     if (! status) return;
    status = BSdistnct2(
      &msg,
      projected_point,
      axis_2[i]);
     if (status) return;
   } /* for (i = 0; i < 2; i++) */
 }
/*
 * Compute the portion of axis_1 which is also on axis_2.
 */
 {
  extern	IGRboolean MAptlnproj();
  extern	IGRdouble BSdistptpts();
  IGRboolean	status;
  IGRdouble	length, dist_tol, par_tol, parameter;
  IGRdouble	overlap_rad_1[2], overlap_rad_2[2];
  IGRpoint	point, projected_point;
  struct	IGRline line;

  length = BSdistptpts(
   &msg,
   axis_1[0],
   axis_1[1]);
  status = BSEXTRACTPAR(
   &msg,
   BSTOLLENVEC,
   dist_tol);
  if (length < dist_tol) return;	/* Should be impossible */
  par_tol = dist_tol / length;
  for (i = 0; i < 2; i++)
   {
    if (t[i] < par_tol)
     t[i] = 0.0;
    else if (t[i] > (1 - par_tol))
     t[i] = 1.0;
   } /* for (i = 0; i < 2; i++) */
  if (fabs(t[0] - t[1]) < par_tol)
   {
    *call_sfsf_int = FALSE;
    return;
   }
/*
 * Non-degenerate overlap of axis was detected.  We must now
 * determine, based on the radii, if the overlap implies true
 * coincidence.
 *
 * Compute the radius of the cone at the specified parameters
 */
  overlap_rad_1[0] = radii_1[0] + (radii_1[1] - radii_1[0]) * t[0];
  overlap_rad_1[1] = radii_1[0] + (radii_1[1] - radii_1[0]) * t[1];
/*
 * Compute the radius of the other cone at the same points
 */
  line.point1 = axis_2[0]; 
  line.point2 = axis_2[1]; 
  for (i = 0; i < 2; i++)
   {
    point[0] = axis_1[0][0] + (axis_1[1][0] - axis_1[0][0]) * t[i];
    point[1] = axis_1[0][1] + (axis_1[1][1] - axis_1[0][1]) * t[i];
    point[2] = axis_1[0][2] + (axis_1[1][2] - axis_1[0][2]) * t[i];
    status = MAptlnproj(	/* Project the second axis on the first axis */
      &msg,
      point,
      &line,
      projected_point,
      &parameter);
     if (! status) return;
    overlap_rad_2[i] = radii_2[0] + (radii_2[1] - radii_2[0]) * parameter;
   } /* for (i = 0; i < 2; i++) */
/*
 * Compare the computed radii.  If they are the same then we have
 * coincidence.
 */
  if ((fabs(overlap_rad_1[0] - overlap_rad_2[0]) < dist_tol) &&
      (fabs(overlap_rad_1[1] - overlap_rad_2[1]) < dist_tol))
   {
    *call_sfsf_int = FALSE;
    return;
   }
 }
/*
 * eof
 */
 return;
}

end implementation EMScone;
