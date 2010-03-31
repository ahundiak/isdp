/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function intersects a surface of projection with an infinite plane
 and returns the resulting intersection curves, if any.  Note that surface
 of projection with scaling are not supported, e.g. cone, partial cone,
 elliptical cone, partial elliptical cone, etc..

 Arguments

 surface		Surface to be intersected
 projected_along_v	Is the surface linear in v?
 plane			The infinite plane cutting the surface
 base_curve_type	The type of the section which was swept, can be
                        BSCCIRCLE - circle or circular arc,
                        BSCELLIPSE - ellipse or elliptical arc,
                        BSCUNKNOWNTYPE - general curve
 is_iso_edge		Tells if the resulting intersection curves can
                        be represented by constant parameter curves on the
                        surface.
 curve_type		The element type of the intersection curves.  One of
                        EMcircle, EMcircular_arc, EMellipse, EMelliptical_arc,
                        EMfreeform_curve, EMplanar_linestring, EMlinesegment.
 number_of_curves	Number of intersection curves
 curves			Intersection curves
 msg			EMS_S_Success - No problem
			EMS_I_NoSolution - I cannot solve this problem, i.e.
                         better use the regular intersection routine
                        EMS_I_NoIntersection - No intersection found
			EMS_E_Fail - Something went wrong
			EMS_E_BSerror - Something went wrong
			EMS_E_NoDynamicMemory - No memory
                        EMS_E_InvalidArg - Base curve type was not valid

 History

 11/03/88 : rlw : Creation date
 08/27/92 : NP  : Modified for ANSI compliance.
 07/06/93 : Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"		/* Shared libraries */
#include <math.h>		/* fabs() */
#include "bs.h"			/* Type definitions */
#include "bsparameters.h"	/* Tolerances */
#include "bsconic.h"		/* Conic type defines */
#include "EMSmsgdef.h"		/* Error return codes */
#include "emsedgedef.h"		/* Edge type definitions */
#include "bstst_plan.h"
#include "bsptlngen.h"
#include "bsprj_cv_pl.h"
#include "bspl_cv_int.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

static void EFintersect_sf_of_proj_with_plane_helper();

IGRlong EFintersect_sf_of_proj_with_plane(
 surface,
 projected_along_v,
 plane,
 base_curve_type,
 is_iso_edge,
 curve_type,
 number_of_curves,
 curves,
 msg)

struct		IGRbsp_surface *surface;
IGRboolean	projected_along_v;
struct		IGRplane *plane;
IGRlong		base_curve_type;
IGRboolean	*is_iso_edge;
IGRlong		*curve_type;
IGRlong		*number_of_curves;
struct		IGRbsp_curve ***curves;
IGRlong		*msg;

{
 IGRboolean	parallel_cut;
 IGRvector	projection_vector, sweep_vector;
 IGRpoint	base_point, top_point;
 struct		IGRbsp_curve *base_curve, *top_curve, *projected_curve;
 struct	IGRplane base_plane, top_plane;
 IGRboolean	is_planar;
 IGRvector	normal_vector;

/*
 * Initialize
 */
 *msg = EMS_S_Success;
 *number_of_curves = 0;
 *curves = NULL;
 base_curve = NULL;
 top_curve = NULL;
 projected_curve = NULL;
/*
 * Extract the two constant parameter curves which defines the
 * open ends of the surface of projection.
 */
 {
  IGRboolean	status, test_planarity;
  IGRshort	order, extract_option;
  IGRlong	number_of_poles, loc_msg, i;
  IGRdouble	low, high;
  struct	IGRbsp_curve *curve;

  if (projected_along_v)
   {
    order = surface->u_order;
    number_of_poles = surface->u_num_poles;
    extract_option = 2;
    low  = surface->u_knots[order - 1];
    high = surface->u_knots[number_of_poles];
   }
  else
   {
    order = surface->v_order;
    number_of_poles = surface->v_num_poles;
    extract_option = 1;
    low  = surface->v_knots[order - 1];
    high = surface->v_knots[number_of_poles];
   }
  for (i = 0; i < 3; i++)
   {
    BSalloccv(
      order,
      number_of_poles,
      surface->rational,
      0,				/* No boundaries */
      &curve,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = EMS_E_NoDynamicMemory;
       goto wrapup;
      }
    if (i == 0)
     base_curve = curve;
    else if (i == 1)
     top_curve = curve;
    else
     projected_curve = curve;
   } /* for (i = 0; i < 3; i++) */
/*
 * Extract the constant parameter curves
 */
  test_planarity = TRUE;
  BSconstprcv(
    &loc_msg,
    surface,
    &extract_option,
    &low,
    &test_planarity,
    base_curve);
   if (loc_msg != BSSUCC)
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  BSconstprcv(
    &loc_msg,
    surface,
    &extract_option,
    &high,
    &test_planarity,
    top_curve);
   if (loc_msg != BSSUCC)
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
/*
 * Determine if a non-planar curve was swept
 */
  if ( ! (base_curve->planar && top_curve->planar))
   {
    *msg = EMS_I_NoSolution;
    goto wrapup;
   }
 }

/*
 * Determine the projection vector and the equations of the planes defining
 * the end caps.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;
  IGRdouble	weight;

  weight = (surface->rational ? base_curve->weights[0] : 1.0);
  base_point[0] = base_curve->poles[0] / weight;
  base_point[1] = base_curve->poles[1] / weight;
  base_point[2] = base_curve->poles[2] / weight;
  top_point[0]  = top_curve->poles[0]  / weight;
  top_point[1]  = top_curve->poles[1]  / weight;
  top_point[2]  = top_curve->poles[2]  / weight;
  sweep_vector[0] = (top_point[0] - base_point[0]);
  sweep_vector[1] = (top_point[1] - base_point[1]);
  sweep_vector[2] = (top_point[2] - base_point[2]);
  projection_vector[0] = sweep_vector[0];
  projection_vector[1] = sweep_vector[1];
  projection_vector[2] = sweep_vector[2];
  status = BSnorvec(
    &loc_msg,
    projection_vector);
   if (loc_msg != BSSUCC)		/* Degenerate vector */
    {
     *msg = EMS_E_Fail;
     goto wrapup;
    }

  /*
   * Determine the equations of the planes defining the end caps.
   */

   BStst_plan(
     base_curve->num_poles,
     base_curve->poles,
     base_curve->weights,
     &is_planar,
     normal_vector,
     &loc_msg);
    if ((loc_msg != BSSUCC) ||
        (! is_planar))		/* It said it was earlier */
     {
      *msg = EMS_E_BSerror;
      goto wrapup;
     }
   base_plane.point = base_point;
   base_plane.normal = normal_vector;
   top_plane.point = top_point;
   top_plane.normal = normal_vector;
 }

/*
 * Determine the relationship between the cutting plane
 * and the projection vector and the cutting plane and the end cap (to see
 * if the intersection is iso). -- SM 05-Sep-89.
 */
 {
  IGRlong	loc_msg;
  IGRdouble	dot_product, dot_tolerance;

  BSEXTRACTPAR(
   &loc_msg,
   BSTOLORTHOVEC,
   dot_tolerance);
  dot_product = BSdotp(
   &loc_msg,
   projection_vector,
   plane->normal);
  dot_product = fabs(dot_product);
  if (dot_product < dot_tolerance)	/* Plane is parallel to projection */
   {
    parallel_cut = TRUE;
    /* *is_iso_edge = TRUE; */
   }
  else
   {
    parallel_cut = FALSE;
/**************************************
    if (fabs(1.0 - dot_product) < dot_tolerance)
     *is_iso_edge = TRUE;
    else
     *is_iso_edge = FALSE;
**************************************/
   }

  /* Following iso check added, and the above iso check commented out by 
     SM 05-Sep-89.
  */
  dot_product = BSdotp(
   &loc_msg,
   normal_vector,
   plane->normal);
  dot_product = fabs(dot_product);
  if (dot_product < dot_tolerance) *is_iso_edge = TRUE;
  else if (fabs(1.0 - dot_product) < dot_tolerance) *is_iso_edge = TRUE;
  else *is_iso_edge = FALSE;
 }

/*
 * Process parallel cuts
 */
 if (parallel_cut)
  {

   EFintersect_sf_of_proj_with_plane_helper(
     base_curve,
     plane,
     sweep_vector,
     number_of_curves,
     curves,
     msg);
    if ((! (1 & *msg)) ||
        (*msg == EMS_I_NoIntersection))
     goto wrapup;
   *curve_type = EMlinesegment;
  } /* if (parallel_cut) */
/*
 * Process non-parallel cuts
 */
 else
  {
   extern	IGRlong EFclip_curve_to_planes();
   IGRboolean	status, was_curve_clipped;
   IGRlong	loc_msg, sts;

/*
 * Project the base curve onto the cutting plane
 * using the projection vector.
 */
   status = BSprj_cv_pl(
     &loc_msg,
     base_curve,
     plane->point,
     plane->normal,
     projection_vector,
     projected_curve);
    if (loc_msg != BSSUCC)
     {
      *msg = EMS_E_BSerror;
      goto wrapup;
     }
/*
 * Clip the intersection curve to the planes defining the end caps.
 */
   sts = EFclip_curve_to_planes(
     projected_curve,
     &top_plane,
     &base_plane,
     TRUE,		/* Save the overlaps */
     &was_curve_clipped,
     number_of_curves,
     curves,
     &loc_msg);
    if (! sts)
     {
      *msg = EMS_E_Fail;
      goto wrapup;
     }
   if (*number_of_curves == 0)
    {
     *msg = EMS_I_NoIntersection;
     goto wrapup;
    }
/*
 * Set up the proper curve type
 */
   if (! projected_curve->phy_closed)
    was_curve_clipped = TRUE;
   switch (base_curve_type)
    {
     case BSCCIRCLE:
      if (*is_iso_edge)
       {
        if (was_curve_clipped)
         *curve_type = EMcircular_arc;
        else
         *curve_type = EMcircle;
       }
      else
       {
        if (was_curve_clipped)
         *curve_type = EMelliptical_arc;
        else
         *curve_type = EMellipse;
       }
      break;
     case BSCELLIPSE:
      if (was_curve_clipped)
       *curve_type = EMelliptical_arc;
      else
       *curve_type = EMellipse;
      break;
     case BSCUNKNOWNTYPE:
      if ((surface->u_order == 2) &&
          (surface->v_order == 2))
       *curve_type = EMplanar_linestring;
      else
       *curve_type = EMfreeform_curve;
      break;
     default:
      *msg = EMS_E_InvalidArg;
      goto wrapup;
    } /* switch (base_curve_type) */
  } /* ELSE FOR if (parallel_cut) */
/*
 * Free up memory
 */
wrapup:
 {
  IGRboolean	status;
  IGRlong	loc_msg, i;

  if (base_curve)
   {
    status = BSfreecv(
     &loc_msg,
     base_curve);
   }
  if (top_curve)
   {
    status = BSfreecv(
     &loc_msg,
     top_curve);
   }
  if (projected_curve)
   {
    status = BSfreecv(
     &loc_msg,
     projected_curve);
   }
 }
/*
 * eof
 */
 if (! (1 & *msg))
  {
   if (*curves)
    {
     IGRboolean	status;
     IGRlong	i, loc_msg;
     struct	IGRbsp_curve *curve;

     for (i = 0; i < *number_of_curves; i++)
      {
       curve = (*curves)[i];
       if (curve)
        {
         status = BSfreecv(
          &loc_msg,
          curve);
        }
      } /* for (i = 0; i < *number_of_curves; i++) */
     free(*curves);
     *curves = NULL;
    } /* if (*curves) */
   *number_of_curves = 0;
   return(FALSE);
  }
 else
  return(TRUE);
}
/*
 Description

 This static function is provided to handle the cases when the
 cutting plane is parallel to the projection vector.  The intersections
 are found by cutting the base curve with plane.  This will produce a
 series of points which are swept by the projection vector to produce
 a series of curves which are lines.

 History

 11/08/88 : rlw : Creation date
 08/27/92 : NP  : Modified for ANSI compliance.
 */

static void EFintersect_sf_of_proj_with_plane_helper(
 curve,
 plane,
 projection_vector,
 number_of_curves,
 curves,
 msg)

struct		IGRbsp_curve *curve;
struct		IGRplane *plane;
IGRvector	projection_vector;		/* Not normalized! */
IGRlong		*number_of_curves;
struct		IGRbsp_curve ***curves;
IGRlong		*msg;

{
 IGRint		number_of_intersections;
 IGRpoint	*points;
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 *number_of_curves = 0;
 *curves = NULL;
 points = NULL;
/*
 * Intersect the base curve with the infinite plane
 */
 {
  IGRboolean	status;
  IGRint	number_of_overlaps;
  IGRlong	number_of_doubles, loc_msg;
  IGRdouble	*double_pointer, *parameters, *starting_u, *ending_u;

  number_of_doubles = curve->num_poles * 6;	 /* 3 + 1 + 1 + 1 */
  double_pointer = (IGRdouble *) malloc(number_of_doubles * sizeof(IGRdouble));
   if (! double_pointer)
    {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  points = (IGRpoint *) double_pointer;
  double_pointer += curve->num_poles * 3;
  parameters = double_pointer;
  double_pointer += curve->num_poles;
  starting_u = double_pointer;
  double_pointer += curve->num_poles;
  ending_u = double_pointer;
/*
 * Perform the intersection
 */
  status = BSpl_cv_int(
    &loc_msg,
    curve,
    plane->point,
    plane->normal,
    &number_of_intersections,
    (IGRdouble *)points,
    parameters,
    &number_of_overlaps,
    starting_u,
    ending_u);
   if ((! status) || 
       (loc_msg != BSSUCC))
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
 }
/*
 * If any intersections were found, then build up
 * a line curve for each of the points.
 */
 if (number_of_intersections)
  {
   IGRboolean	status;
   IGRlong	i, loc_msg;
   IGRint	type;
   IGRpoint	other_point;
   struct	IGRbsp_curve *curve;

   *curves = (struct IGRbsp_curve **) malloc(
     number_of_intersections * sizeof(struct IGRbsp_curve *));
    if (! *curves)
     {
      *msg = EMS_E_NoDynamicMemory;
      goto wrapup;
     }
   for (i = 0; i < number_of_intersections; i++)
    {
     BSalloccv(
       2,		/* order */
       2,		/* num_poles */
       FALSE,		/* rational */
       0,		/* num_boundaries */
       &curve,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = EMS_E_NoDynamicMemory;
        goto wrapup;
       }
     other_point[0] = points[i][0] + projection_vector[0];
     other_point[1] = points[i][1] + projection_vector[1];
     other_point[2] = points[i][2] + projection_vector[2];
     status = BSptlngen(
       &loc_msg,
       points[i],
       other_point,
       curve,
       &type);
      if (loc_msg != BSSUCC)
       {
        *msg = EMS_E_BSerror;
        goto wrapup;
       }
     (*curves)[i] = curve;
     *number_of_curves = *number_of_curves + 1;
    } /* for (i = 0; i < number_of_intersections; i++) */
  } /* if (number_of_intersections) */
 else
  *msg = EMS_I_NoIntersection;
/*
 * Eof
 */
wrapup:
 if (points) free(points);
 return;
}
