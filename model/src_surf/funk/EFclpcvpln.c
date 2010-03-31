/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 Given a curve and two parallel planes this function will clip the curve
 such that only the portion lying between the planes exists.

 History

 10/26/88 : rlw : Creation date
 08/27/92 : NP  : Modified for ANSI compliance. Moved static function declaration
		  to global scope.  Changed incorrect typecasts.
 07/06/93 : Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"		/* Shared libraries */
#include <math.h>		/* fabs() */
#include "bs.h"			/* Type definitions */
#include "bsparameters.h"	/* Tolerances */
#include "msdef.h"		/* Error return codes */
#include "maerr.h"		/* Error return codes */
#include "bsquicksort.h"
#include "bspl_cv_int.h"
#include "bspartofcv.h"
#include "bsfreecv.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bscv_copy.h"
#include "bsalloccv.h"

static IGRlong	EFintersect_plane_save_side_for_curves();

IGRlong EFclip_curve_to_planes(
 curve,				/* Curve to intersect with plane */
 top_plane,			/* The plane, the plane */
 bottom_plane,			/* The plane, the plane */
 save_overlaps,			/* Do you want sections on the plane? */
 curve_was_clipped,		/* Is the original being returned in tact? */
 number_of_clipped_curves,	/* Number of resulting curves (possibly 0) */
 clipped_curves,		/* Resulting curves (possibly none) */
 msg)				/* Error return code */

struct		IGRbsp_curve *curve;
struct		IGRplane *top_plane;
struct		IGRplane *bottom_plane;
IGRboolean	save_overlaps;
IGRboolean	*curve_was_clipped;
IGRlong		*number_of_clipped_curves;
struct		IGRbsp_curve ***clipped_curves;
IGRlong		*msg;

{
 IGRboolean	top_clipping, bottom_clipping;
 IGRlong	sts, top_count;
 struct		IGRbsp_curve **top_curves;
 IGRpoint	save_side;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *curve_was_clipped = TRUE;
 *number_of_clipped_curves = 0;
 *clipped_curves = NULL;
 top_count = 0;
 top_curves = NULL;
/*
 * Generate a point on the save side
 */
 save_side[0] = (top_plane->point[0] + bottom_plane->point[0]) / 2.0;
 save_side[1] = (top_plane->point[1] + bottom_plane->point[1]) / 2.0;
 save_side[2] = (top_plane->point[2] + bottom_plane->point[2]) / 2.0;
/*
 * Clip to the first plane
 */
 sts = EFintersect_plane_save_side_for_curves(
   curve,
   top_plane,
   save_side,
   save_overlaps,
   &top_clipping,
   &top_count,
   &top_curves,
   msg);
  if (! sts) goto wrapup;
/*
 * Clip to the second plane
 */
 if (top_count)
  {
   IGRboolean	status;
   IGRlong	loc_msg, i, bottom_count;
   struct	IGRbsp_curve **bottom_curves;

   for (i = 0; i < top_count; i++)
    {
     sts = EFintersect_plane_save_side_for_curves(
       top_curves[i],
       bottom_plane,
       save_side,
       save_overlaps,
       &bottom_clipping,
       &bottom_count,
       &bottom_curves,
       msg);
      if (! sts) goto wrapup;
     if (bottom_count)
      {
       IGRlong	total_curves, j, k;

       total_curves = *number_of_clipped_curves + bottom_count;
       if (*clipped_curves)
        {
         *clipped_curves = (struct IGRbsp_curve **) realloc(
           (IGRchar *)*clipped_curves,
           total_curves * sizeof(struct IGRbsp_curve *));
        } /* if (*clipped_curves) */
       else
        {
         *clipped_curves = (struct IGRbsp_curve **) malloc(
           total_curves * sizeof(struct IGRbsp_curve *));
        } /* ELSE FOR if (*clipped_curves) */
       if (! *clipped_curves)
        {
         *msg = MANOMEMORY;
         goto wrapup;
        }
       for (j = 0; j < bottom_count; j++)
        {
         k = j + *number_of_clipped_curves;
         (*clipped_curves)[k] = bottom_curves[j];
        } /* for (j = 0; j < bottom_count; j++) */
       *number_of_clipped_curves = total_curves;
       free(bottom_curves);
       if (! (bottom_clipping || top_clipping)) *curve_was_clipped = FALSE;
      } /* if (bottom_count) */
    } /* for (i = 0; i < top_count; i++) */
  } /* if (top_count) */
/*
 * Eof
 */
wrapup:
 {
  IGRboolean	status;
  IGRlong	i, loc_msg;
  struct	IGRbsp_curve *curve;

  for (i = 0; i < top_count; i++)
   {
    curve = top_curves[i];
    if (curve)
     {
      status = BSfreecv(
       &loc_msg,
       curve);
     }
   } /* for (i = 0; i < top_count; i++) */
  if (top_curves) free(top_curves);
  if (! (1 & *msg))
   {
    for (i = 0; i < *number_of_clipped_curves; i++)
     {
      curve = (*clipped_curves)[i];
      if (curve)
       {
        status = BSfreecv(
         &loc_msg,
         curve);
       }
     } /* for (i = 0; i < *number_of_clipped_curves; i++) */
    if (*clipped_curves) free(*clipped_curves);
    *clipped_curves = NULL;
    *number_of_clipped_curves = 0;
    return(FALSE);
   }
  else
   return(TRUE);
  }
}

/*
 Description

 Given a curve and a plane this routine clips the curve such
 that only that portion lying on one side of the plane remains.
 The resulting curves, if any, are returned to the caller.

 History

 10/24/88 : rlw : Creation date

 */

static IGRlong EFintersect_plane_save_side_for_curves(
 curve,				/* Curve to intersect with plane */
 plane,				/* The plane, the plane */
 point_on_side_to_save,		/* Point on side of plane to remain */
 save_overlaps,			/* Do you want sections on the plane? */
 curve_was_clipped,		/* Is the original being returned in tact? */
 number_of_clipped_curves,	/* Number of resulting curves (possibly 0) */
 clipped_curves,		/* Resulting curves (possibly none) */
 msg)				/* Error return code */

struct		IGRbsp_curve *curve;
struct		IGRplane *plane;
IGRpoint	point_on_side_to_save;
IGRboolean	save_overlaps;
IGRboolean	*curve_was_clipped;
IGRlong		*number_of_clipped_curves;
struct		IGRbsp_curve ***clipped_curves;
IGRlong		*msg;

{
 IGRboolean	pos_orient, status;
 IGRlong	loc_msg;
 IGRint		number_of_parameters;
 IGRdouble	*u_parm, *parameters, *starting_u, *ending_u, dist_tol;
 IGRpoint	*points;
/*
 * Initialize
 */
 *msg = MSSUCC;
 u_parm = NULL;
 points = NULL;
 *curve_was_clipped = TRUE;
 *number_of_clipped_curves = 0;
 *clipped_curves = NULL;
/*
 * Determine which side of the plane is to be saved
 */
 {
  IGRdouble	dot_product;
  IGRvector	vector;

  vector[0] = point_on_side_to_save[0] - plane->point[0];
  vector[1] = point_on_side_to_save[1] - plane->point[1];
  vector[2] = point_on_side_to_save[2] - plane->point[2];
  dot_product  = vector[0] * plane->normal[0];
  dot_product += vector[1] * plane->normal[1];
  dot_product += vector[2] * plane->normal[2];
  status = BSEXTRACTPAR(
    &loc_msg,
    BSTOLLENVEC,
    dist_tol);
  if (fabs(dot_product) < dist_tol)
   {
    *msg = MSINARG;
    goto wrapup;
   }
  else if (dot_product < 0.0)
   pos_orient = FALSE;
  else
   pos_orient = TRUE;
 }
/*
 * Get the memory required to store the intersections
 */
 {
  IGRlong	number_of_doubles;
  IGRint	number_of_intersections, number_of_overlaps;
  IGRdouble	*double_pointer;

  number_of_doubles = curve->num_poles * 6;	 /* 3 + 1 + 1 + 1 */
  double_pointer = (IGRdouble *) malloc(number_of_doubles * sizeof(IGRdouble));
   if (! double_pointer)
    {
     *msg = MANOMEMORY;
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
     *msg = MSFAIL;
     goto wrapup;
    }
/*
 * Get the memory required to hold the sorted
 * intersections and overlaps.
 */
  {
   IGRint	start, end;
   IGRlong	size_required, i, j;
   IGRdouble	knot_tolerance, u_low, u_high, parm;
   
   size_required = number_of_intersections + 2;	/* Want 0 and 1 */
   if (save_overlaps)
    size_required += 2 * number_of_overlaps;
   u_parm = (IGRdouble *) malloc(size_required * sizeof(IGRdouble));
    if (! u_parm)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
/*
 * Get the knot tolerance
 */
   BScvkttol2(
     curve->order,
     curve->knots,
     curve->num_poles,
     curve->poles,
     curve->weights,
     &knot_tolerance,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
/*
 * Build the array
 */
   u_low = curve->knots[curve->order - 1];
   u_high = curve->knots[curve->num_poles];
   u_parm[0] = u_low;
   u_parm[1] = u_high;
   j = 2;
   for (i = 0; i < number_of_intersections; i++)
    {
     parm = parameters[i];
     if (((parm - u_low) > knot_tolerance) &&
        ((u_high - parm) > knot_tolerance))
      u_parm[j++] = parm;
    }
   for (i = 0; i < number_of_overlaps; i++)
    {
     parm = starting_u[i];
     if (((parm - u_low) > knot_tolerance) &&
         ((u_high - parm) > knot_tolerance))
      u_parm[j++] = parm;
     parm = ending_u[i];
     if (((parm - u_low) > knot_tolerance) &&
         ((u_high - parm) > knot_tolerance))
      u_parm[j++] = parm;
    }
/*
 * Sort the suckers
 */
   number_of_parameters = j;
   start = 0;
   end = number_of_parameters - 1;
   status = BSquicksort(
     &loc_msg,
     &start,
     &end,
     &number_of_parameters,
     u_parm);
    if ((! status) ||
        (loc_msg != BSSUCC))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  }
/*
 * We now have an array of intersection parameters.
 * We need to classify the curves defined by each
 * pair of these parameters.  If that curve lies on
 * the proper side of the plane then we will add
 * it to the accepted list.
 */
  {
   IGRboolean	extract_curve;
   IGRlong	number_of_curves_to_extract, i;
   IGRdouble	dot_product, parameter;
   IGRvector	vector;
   IGRpoint	point_on_curve;

   number_of_curves_to_extract = number_of_parameters - 1;
   *clipped_curves = (struct IGRbsp_curve **) malloc(
     number_of_curves_to_extract * sizeof(struct IGRbsp_curve *));
    if (! *clipped_curves)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   for (i = 0; i < number_of_curves_to_extract; i++)
    {
     parameter = (u_parm[i] + u_parm[i + 1]) / 2.0;
     BScveval(
       curve,
       parameter,
       0,		/* No derivatives */
       (IGRpoint *)point_on_curve,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     vector[0] = point_on_curve[0] - plane->point[0];
     vector[1] = point_on_curve[1] - plane->point[1];
     vector[2] = point_on_curve[2] - plane->point[2];
     dot_product  = vector[0] * plane->normal[0];
     dot_product += vector[1] * plane->normal[1];
     dot_product += vector[2] * plane->normal[2];
     if (fabs(dot_product) < dist_tol)
      {
       if (save_overlaps)
        extract_curve = TRUE;
       else
        extract_curve = FALSE;
      }
     else if ((dot_product < 0.0) && (! pos_orient))
      extract_curve = TRUE;
     else if ((dot_product > 0.0) && pos_orient)
      extract_curve = TRUE;
     else
      extract_curve = FALSE;
     if (extract_curve)
      {
       struct	IGRbsp_curve *partial_curve, tmp_curve;

       BSalloccv(
         curve->order,
         curve->num_poles,
         curve->rational,
         0,
         &partial_curve,
         &loc_msg);
        if (loc_msg != BSSUCC)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
       tmp_curve = *curve;
       if (number_of_curves_to_extract != 1)	/* Not the whole curve */
        {
         tmp_curve.phy_closed = FALSE;
         status = BSpartofcv(
           &loc_msg,
           &tmp_curve,
           u_parm[i],
           parameter,
           u_parm[i + 1],
           partial_curve);
        }
       else
        {

         *curve_was_clipped = FALSE;
         status = BScv_copy(
          &loc_msg,
          curve,
          partial_curve);
        }
       (*clipped_curves)[*number_of_clipped_curves] = partial_curve;
       *number_of_clipped_curves = *number_of_clipped_curves + 1;
       if (loc_msg != BSSUCC)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
      } /* if (extract_curve) */
    } /* for (i = 0; i < number_of_parameters - 1; i++) */
/*
 * Free the control structure, if
 * none of the curves was acceptable
 */
   if (*number_of_clipped_curves == 0)
    {
     free(*clipped_curves);
     *clipped_curves = NULL;
    } /* if (*number_of_clipped_curves == 0) */
  }
 }
/*
 * Eof
 */
wrapup:
 if (u_parm) free(u_parm);
 if (points) free(points);
 if (! (1 & *msg))
  {
   if (*clipped_curves)
    {
     IGRlong	i;
     struct	IGRbsp_curve *curve;

     for (i = 0; i < *number_of_clipped_curves; i++)
      {
       curve = (*clipped_curves)[i];
       if (curve)
        {
         status = BSfreecv(
          &loc_msg,
          curve);
        }
      } /* for (i = 0; i < *number_of_clipped_curves; i++) */
     free(*clipped_curves);
     *clipped_curves = NULL;
    } /* if (*clipped_curves) */
   *number_of_clipped_curves = 0;
   return(FALSE);
  }
 else
  return(TRUE);
}
