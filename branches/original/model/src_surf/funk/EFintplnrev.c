/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function intersects a surface of revolution with an infinite plane
 and returns the resulting intersection curves, if any.  Note that only
 iso_edge_cuts are supported.

 Arguments

 surface		Surface to be intersected
 is_revolved_format	Is the surface stored as a revolution as opposed to
                        a projection, i.e. v=0 describes the curve which
                        was revolved.
 plane			The infinite plane cutting the surface
 base_curve_type	The type of the section which was revolved, can be
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

 11/10/88 : rlw : Creation date
 02/14/89 : rlw : Fixed a problem in which some line intersections were
                  incorrectly being tossed.
 07/06/93 : Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"		/* Shared libraries */
#include <math.h>		/* fabs() */
#include "bs.h"			/* Type definitions */
#include "bsmemory.h"		/* BSMEMCPY() macro */
#include "bsparameters.h"	/* Tolerances */
#include "bsconic.h"		/* Conic type defines */
#include "bsvalues.h"		/* M_PI */
#include "EMSmsgdef.h"		/* Error return codes */
#include "emsedgedef.h"		/* Edge type definitions */
#include "msdef.h"		/* MSSUCC */
#include "madef.h"		/* MAmaximum() macro */
#include "bsunwght_p.h"
#include "bsptlnplan.h"
#include "bspl_cv_int.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpl.h"
#include "bsconstprcv.h"
#include "bsblkmv.h"
#include "bsalloccv.h"

IGRlong EFintersect_sf_of_rev_with_plane(
 surface,
 is_revolved_format,
 plane,
 base_curve_type,
 is_iso_edge,
 curve_type,
 number_of_curves,
 curves,
 msg)

struct		IGRbsp_surface *surface;
IGRboolean	is_revolved_format;
struct		IGRplane *plane;
IGRlong		base_curve_type;
IGRboolean	*is_iso_edge;
IGRlong		*curve_type;
IGRlong		*number_of_curves;
struct		IGRbsp_curve ***curves;
IGRlong		*msg;

{
 IGRboolean	parallel_cut;
 IGRpoint	axis[3], *points;
 struct		IGRbsp_curve *base_curve, *arc_curve;
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 *number_of_curves = 0;
 *curves = NULL;
 base_curve = NULL;
 arc_curve = NULL;
 points = NULL;
/*
 * Extract the axis of the surface of revolution
 */
 {
  void		EMextract_axis();
  IGRlong	loc_msg;

  EMextract_axis(
    &loc_msg,
    NULL,	/* Not by object */
    surface,
    axis);
   if (loc_msg != MSSUCC)
    {
     *msg = EMS_I_NoSolution;
     goto wrapup;
    }
 }
/*
 * Extract the curve which was revolved to produce the surface
 * and a, hopefully, non-degenerate arc in the revolution.
 */
 {
  IGRboolean	status, test_planarity;
  IGRshort	order, extract_option;
  IGRlong	number_of_poles, loc_msg, i;
  IGRdouble	parameter;
  struct	IGRbsp_curve *curve;

  order = MAmaximum(surface->u_order, surface->v_order);
  number_of_poles = MAmaximum(surface->u_num_poles, surface->v_num_poles) + 3;
  for (i = 0; i < 2; i++)
   {
    BSalloccv(
      order,
      number_of_poles,
      surface->rational,		/* Better be TRUE */
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
     arc_curve = curve;
   } /* for (i = 0; i < 3; i++) */
/*
 * Extract the constant parameter curves
 */
  if (is_revolved_format)
   {
    extract_option = 2;
    parameter = surface->v_knots[surface->v_order - 1];
   }
  else
   {
    extract_option = 1;
    parameter = surface->u_knots[surface->u_order - 1];
   }
  test_planarity = TRUE;
  status = BSconstprcv(
    &loc_msg,
    surface,
    &extract_option,
    &parameter,
    &test_planarity,
    base_curve);
   if (loc_msg != BSSUCC)
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  if (is_revolved_format)
   {
    extract_option = 1;
    parameter = (surface->u_knots[surface->u_order - 1] + 
     surface->u_knots[surface->u_num_poles]) / M_PI;	/* Random number */
   }
  else
   {
    extract_option = 2;
    parameter = (surface->v_knots[surface->v_order - 1] +
     surface->v_knots[surface->v_num_poles]) / M_PI;	/* Random number */
   }
  status = BSconstprcv(
    &loc_msg,
    surface,
    &extract_option,
    &parameter,
    &test_planarity,
    arc_curve);
   if (loc_msg != BSSUCC)
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
   else if (! arc_curve->planar)
    {
     *msg = EMS_I_NoSolution;
     goto wrapup;
    }
/*
 * Determine if the base curve is planar and lies
 * in the same plane as the axis.  If not then
 * give it up.
 */
  {
   IGRlong	loc_msg;
   IGRint	planar_code;
   IGRvector	normal_vector;

   BSMEMCPY(
    3 * sizeof(IGRpoint),
    (char *) axis,
    (char *) &base_curve->poles[3 * base_curve->num_poles]);
   if (base_curve->rational)				/* Should be */
    {
     IGRdouble	*wt_ptr;

     wt_ptr = &base_curve->weights[base_curve->num_poles];
     wt_ptr[0] = 1.0;
     wt_ptr[1] = 1.0;
     wt_ptr[2] = 1.0;
    }
   BSptlnplan(
     base_curve->num_poles + 3,
     base_curve->rational,
     (IGRpoint *)base_curve->poles,
     base_curve->weights,
     &planar_code,
     normal_vector,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = EMS_E_BSerror;
      goto wrapup;
     }
   if (planar_code != 3)	/* Not a unique plane? */
    {
     *msg = EMS_I_NoSolution;
     goto wrapup;
    }
  }
 }
/*
 * Determine the relationship between the cutting plane
 * and the axis.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;
  IGRdouble	dot_product, dot_tolerance;
  IGRvector	axis_vector;

  axis_vector[0] = (axis[0][0] - axis[2][0]);
  axis_vector[1] = (axis[0][1] - axis[2][1]);
  axis_vector[2] = (axis[0][2] - axis[2][2]);
  status = BSnorvec(
    &loc_msg,
    axis_vector);
   if (loc_msg != BSSUCC)		/* Degenerate vector */
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  BSEXTRACTPAR(
   &loc_msg,
   BSTOLORTHOVEC,
   dot_tolerance);
  dot_product = BSdotp(
   &loc_msg,
   axis_vector,
   plane->normal);
  dot_product = fabs(dot_product);
  if (dot_product < dot_tolerance)			/* 0 degrees */
   {
    IGRdouble	distance, dist_tol;

    BSEXTRACTPAR(
     &loc_msg,
     BSTOLLENVEC,
     dist_tol);
    status = BSdistptpl(	/* Can't fail */
     &loc_msg,
     axis[0],
     plane->point,
     plane->normal,
     &distance);
    if (distance > dist_tol)	/* Axis does not lie in cutting plane? */
     {
      *msg = EMS_I_NoSolution;
      goto wrapup;
     }
    parallel_cut = TRUE;
    *is_iso_edge = TRUE;
   }
  else
   {
    parallel_cut = FALSE;
    if (fabs(1.0 - dot_product) < dot_tolerance)	/* 90 degrees */
     *is_iso_edge = TRUE;
    else						/* Arbitrary angle */
     {
      *msg = EMS_I_NoSolution;
      goto wrapup;
     }
   }
 }
/*
 * Intersect the appropriate curve with the plane
 */
 {
  IGRboolean	status;
  IGRlong	number_of_doubles, loc_msg;
  IGRint	number_of_intersections, number_of_overlaps;
  IGRdouble	*double_pointer, *parameters, *starting_u, *ending_u;
  struct	IGRbsp_curve *curve;

  curve = (parallel_cut ? arc_curve : base_curve);
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
   else if (number_of_overlaps)			/* No overlaps possible */
    {
     *msg = EMS_E_Fail;
     goto wrapup;
    }
  if (number_of_intersections == 0)
   {
    *msg = EMS_I_NoIntersection;
    goto wrapup;
   }
/*
 * If the cut is parallel, i.e. the axis lies in the cutting plane,
 * then we have sectioned a non-degenerate sweep arc.  This should
 * have generated either 1 or 2 points.  The parameters of these
 * points will give us the v parameters of the iso edge.  In this
 * case the u parameter will run from 0 to 1.
 *
 * If the cut was perpendicular to the axis then we have sectioned
 * the curve which was revolved.  In this case we can have any number
 * of intersection points.  The parameters will give up a set of
 * u parameters of the iso edges.  In this case the v parameter will
 * run from 0 to 1.
 *
 * If the resulting intersection curve is not planar then toss it.
 * The only way this can happen is if that curve degenerates to a point
 * and such intersections are tossed by EFfixtheint().
 */
  {
   IGRboolean	status, test_planarity;
   IGRshort	order, extract_option;
   IGRlong	i, number_of_poles;
   struct	IGRbsp_curve *tmp_curve;

   if (is_revolved_format)
    extract_option = (parallel_cut ? 2 : 1);
   else
    extract_option = (parallel_cut ? 1 : 2);
   test_planarity = TRUE;
   order = MAmaximum(surface->u_order, surface->v_order);
   number_of_poles = MAmaximum(surface->u_num_poles, surface->v_num_poles);
   *curves = (struct IGRbsp_curve **) malloc(number_of_intersections *
     sizeof(struct IGRbsp_curve *));
    if (! *curves)
     {
      *msg = EMS_E_NoDynamicMemory;
      goto wrapup;
     }
   for (i = 0; i < number_of_intersections; i++) 
    (*curves)[i] = NULL;
   for (i = 0; i < number_of_intersections; i++)
    {
     BSalloccv(
       order,
       number_of_poles,
       surface->rational,		/* Better be TRUE */
       0,				/* No boundaries */
       &tmp_curve,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = EMS_E_NoDynamicMemory;
        goto wrapup;
       }
     (*curves)[*number_of_curves] = tmp_curve;
     *number_of_curves = *number_of_curves + 1;
     status = BSconstprcv(
       &loc_msg,
       surface,
       &extract_option,
       &parameters[i],
       &test_planarity,
       tmp_curve);
      if (loc_msg != BSSUCC)
       {
        *msg = EMS_E_BSerror;
        goto wrapup;
       }
     if (! tmp_curve->planar)
      {
       IGRint		planar_code;
       IGRvector	normal_vector;

       BSptlnplan(
         tmp_curve->num_poles,
         tmp_curve->rational,
         (IGRpoint *)tmp_curve->poles,
         tmp_curve->weights,
         &planar_code,
         normal_vector,
         &loc_msg);
        if (loc_msg != BSSUCC)
         {
          *msg = EMS_E_BSerror;
          goto wrapup;
         }
       if (planar_code == 1) 		/* Point curve */
        {

         *number_of_curves = *number_of_curves - 1;
         status = BSfreecv(
          &loc_msg,
          tmp_curve);
        }
       else if  (planar_code == 4)         /* Non-planar - Impossible */
        {
         *msg = EMS_E_Fail;
         goto wrapup;
        }
       else
        tmp_curve->planar = TRUE;
      }
    } /* for (i = 0; i < number_of_intersections; i++) */
   if (*number_of_curves == 0)
    {
     free(*curves);
     *curves = NULL;
     *msg = EMS_I_NoIntersection;
     goto wrapup;
    }
  }
 }
/*
 * Set the edge types.  If the curves are linear then toss
 * the weights as they are not needed and may confuse the caller
 * since the post methods for linear elements don't properly
 * handle weights.
 */
 if (parallel_cut)
  {
   switch (base_curve_type)
    {
     case BSCCIRCLE:
      *curve_type = (base_curve->phy_closed ? EMcircle : EMcircular_arc);
      break;
     case BSCELLIPSE:
      *curve_type = (base_curve->phy_closed ? EMellipse : EMelliptical_arc);
      break;
     default:
      if (base_curve->order == 2)
       {
        IGRboolean	status;
        IGRlong		i, loc_msg;
        struct		IGRbsp_curve *curve;

        if (base_curve->num_poles == 2)
         *curve_type = EMlinesegment;
        else
         *curve_type = EMplanar_linestring;
        for (i = 0; i < *number_of_curves; i++)
         {
          curve = (*curves)[i];
          if (curve->rational)          
           {
            status = BSunwght_p(
              &loc_msg,
              curve->poles,
              curve->weights,
              &curve->num_poles,
              curve->poles);
            free(curve->weights);
            curve->rational = FALSE;
            curve->weights = NULL;
           }
         } /* for (i = 0; i < *number_of_curves; i++) */
       }
      else
       *curve_type = EMfreeform_curve;
      break;
    } /* switch (base_curve_type) */
  }
 else
  {
   *curve_type = (arc_curve->phy_closed ? EMcircle : EMcircular_arc);
  }
/*
 * Free up memory
 */
wrapup:
 if (points) free(points);
 {
  IGRboolean	status;
  IGRlong	loc_msg;

  if (base_curve)
   {
    status = BSfreecv(
     &loc_msg,
     base_curve);
   }
  if (arc_curve)
   {
    status = BSfreecv(
     &loc_msg,
     arc_curve);
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
