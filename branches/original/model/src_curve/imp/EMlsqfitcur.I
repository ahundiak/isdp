/*
  Least squares fit for curves

  History

  02/11/88 : rlw : Modified such that if the desired order is 2 then
                   I just output the input curve stroked.  I also
                   had forgotten to free the resulting curve.
  09/02/88 : rlw : Modified such that if the number of spans desired
                   is zero then the fit is performed using data reduction
  03/09/89 : rlw : Added conditional compilation statements for I/DRAW
  09/26/89 : rlw : Added support of a reference curve as input for least
                   squares instead of number of spans.  In such cases the
                   knots of the resulting curve are taken from the reference
                   curve.  This will be done when similar parameterization is
                   required by the user.  Also renamed method due to argument
                   changes.
  Sudha  06/16/93     Modified for BSprototype ansification

 */

class implementation GRsubbc;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "OMmacros.h"
#include "bsupthe_deg.h"
#include "bslsqfitcv.h"
#include "bsfreecv.h"
#include "bsfitratcv.h"
#include "bsdtardupts.h"
#include "bschtptstcv.h"

method EMleast_squares_fit_curvee(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 IGRvector	*beg_tangent;
 IGRvector	*end_tangent;
 IGRlong	number_of_spans;
 struct		GRlc_info *reference_curve;
 IGRdouble	*average_error;
 IGRdouble	*maximum_error;
 IGRlong	*maximum_indicator;	/* Index of point w/ max error */
 IGRpoint	maximum_segment[2];	/* From fitted curve to point  */
 struct		GRvg_construct *construct_list)

{
 IGRboolean	least_squares_fit;
 IGRboolean	delete_on_failure;
 IGRlong	sts, *msg, num_points;
 IGRpoint	*points;
 struct		IGRbsp_curve curve, *ref_cv_geom;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 delete_on_failure = TRUE;
 curve.poles = NULL;
 curve.weights = NULL;
 curve.knots = NULL;
 points = NULL;
 ref_cv_geom = NULL;
 least_squares_fit = ((number_of_spans != 0) || reference_curve);
/*
 * Get the points
 */
 if (input_points)
  {
   num_points = number_of_points;
   points = input_points;
  }
 else
  {
   IGRlong	loc_msg;
   struct	GRid *id;
   struct	GRmdenv_info *mdenv_info;
   struct	IGRbsp_curve *point_curve;

   id = &linestring->located_obj;
   mdenv_info = &linestring->module_info.md_env;
   sts = om$send(
     msg = message GRvg.GRgenabsg(
      msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      (IGRchar **) &point_curve),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   if ((point_curve->order != 2) ||
       point_curve->rational)
    {
     IGRdouble	*params;

     params = NULL;
     BSchtptstcv(
       point_curve,
       (IGRint *)&num_points,
       &points,
       &params,    
       &loc_msg);
      if (params) free(params);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
    }
   else
    {
     num_points = point_curve->num_poles;
     points = (IGRpoint *) malloc(num_points * sizeof(IGRpoint));
      if (! points)
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     OM_BLOCK_MOVE(
      point_curve->poles,
      points,
      num_points * sizeof(IGRpoint));
    }
  }
/*
 * If the desired order is 2 then let's cheat and just
 * output the stroked curve
 */
#ifndef IDRAW
 if ((order == 2) &&
     least_squares_fit)
  {
   delete_on_failure = FALSE;
   sts = om$send(
     msg = message GRsubbc.EMcurve_by_poles(
      order,
      periodic,
      num_points,
      points,
      NULL,
      construct_list),
     targetid = my_id);
   *average_error = 0.0;
   *maximum_error = 0.0;
   *maximum_indicator = -1;
  } /* if ((order == 2) && least_squares_fit) */
 else
#endif
  {
   IGRlong	loc_msg;
/*
 * Process least squares fit
 */
#ifndef IDRAW
   if (least_squares_fit)
    {
/*
 * Close the curve, if it is periodic
 */
     if (periodic)
      {
       IGRlong	i;

       i = num_points - 1;
       points[i][0] = points[0][0];
       points[i][1] = points[0][1];
       points[i][2] = points[0][2];
      } /* if (periodic) */
/*
 * Get the reference curve if there is one
 */
     if (reference_curve)
      {
       extern	IGRlong EMget_the_geometry();
       struct	IGRbsp_curve *tmp_curve = NULL;

       sts = EMget_the_geometry(
         reference_curve,
         TRUE,                /* is_a_curve */
         TRUE,                /* is_directed */
         TRUE,                /* separate_mallocs */
         my_id,
         &ref_cv_geom,
         msg);
        if (! (1 & sts)) goto wrapup;
/*
 * Determine the number of spans required
 */
       if (ref_cv_geom->order < order)
        {
         IGRboolean	status;
         IGRshort	degree;

         degree = order - 1;
         status = BSupthe_deg(
           &loc_msg,
           ref_cv_geom,
           &degree);
          if (! status)
           {
            *msg = MSFAIL;
            goto wrapup;
           }
        }
       else if (ref_cv_geom->order > order)
        {
         *msg = MSINARG;
         goto wrapup;
        }
       if (periodic &&
           (! ref_cv_geom->periodic))
        {
         IGRlong	i, order, num_poles;
         IGRdouble	*knots, u_min, u_max;

         order = ref_cv_geom->order;
         num_poles = ref_cv_geom->num_poles;
         knots = ref_cv_geom->knots;
         u_min = knots[order - 1];
         u_max = knots[num_poles];
         for (i = 0; i < order - 1; i++)
          {
           knots[order - 2 - i] = knots[num_poles - i - 1] + u_min - u_max;
           knots[num_poles + i + 1] = knots[order + i] + u_max - u_min;
          } /* for (i = 0; i < order - 1; i++) */
        } /* if (periodic && ...) */
       BSfitratcv(
        num_points,
        points, 
        NULL,                     /* weights */
        NULL,                     /* parameters */
        NULL,                     /* span indices */
        order, 
        ref_cv_geom->num_knots,
        ref_cv_geom->knots,
        periodic,
        2,                        /* code as per Dieter Breden */
        (beg_tangent ? 1 : 0),    /* endl */
        (end_tangent ? 1 : 0),    /* endr */
        (IGRdouble *)beg_tangent,              /* tanpoll */
        (IGRdouble *)end_tangent,              /* tanpolr */
        NULL,                     /* crvpoll */
        NULL,                     /* crvpolr */
        0.0,                      /* ewtl */
        0.0,                      /* ewtr */
        0.0,                      /* newtl */
        0.0,                      /* newtr */
        0,                        /* dirfit */
        0.0,                      /* tolerance */
        &tmp_curve,
        average_error,
        maximum_error,
        (IGRint *)maximum_indicator,
        (IGRdouble *)maximum_segment,
        &loc_msg);
       if (tmp_curve)
        {
         curve = *tmp_curve;
         free(tmp_curve);
        }
      } /* if (reference_curve) */
     else
      {
       IGRlong	count;
/*
 * Allocate the required memory
 */
       count = number_of_spans + order;
       curve.poles = (IGRdouble *) malloc(count * sizeof(IGRpoint));
        if (!curve.poles)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
       count += order;
       curve.knots = (IGRdouble *) malloc(count * sizeof(IGRdouble));
        if (!curve.knots)
         {
          *msg = MANOMEMORY;
          goto wrapup;
         }
/*
 * Call the math
 */
       BSlsqfitcv(
        num_points,
        points, 
        order, 
        beg_tangent ? 1 : 0,
        end_tangent ? 1 : 0,
        periodic, 
        (IGRdouble *)beg_tangent,
        (IGRdouble *)end_tangent,
        number_of_spans,
        &curve,
        average_error,
        maximum_error,
        (IGRint *)maximum_indicator,
        (IGRdouble *)maximum_segment,
        &loc_msg);
      } /* ELSE FOR if (reference_curve) */
    } /* if (least_squares_fit) */
/*
 * Perform fit via data reduction
 */
   else
#endif
    {
     IGRlong	interior_knot_multiplicity;
     struct	IGRbsp_curve *tmp_curve = NULL;

     interior_knot_multiplicity = 1;
     BSdtardupts(
      num_points,
      (IGRdouble *)points, 
      order, 
      interior_knot_multiplicity,
      beg_tangent ? 2 : 0,
      end_tangent ? 2 : 0,
      (IGRdouble *)beg_tangent,
      (IGRdouble *)end_tangent,
      TRUE,                 /* Want error information */
      maximum_error,
      average_error,
      (IGRint *)maximum_indicator,
      (IGRdouble *)maximum_segment,
      &tmp_curve,
      &loc_msg);
     if (tmp_curve)
      {
       curve = *tmp_curve;
       free(tmp_curve);
      }
     if (*maximum_error == 0.0) *maximum_indicator = -1;
    } /* ELSE FOR if (least_squares_fit) */
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
   else if(*maximum_indicator != -1)
    {
     maximum_segment[1][0] = points[*maximum_indicator][0];
     maximum_segment[1][1] = points[*maximum_indicator][1];
     maximum_segment[1][2] = points[*maximum_indicator][2];
    }
/*
 * Load my instance data
 */
   construct_list->geometry = (IGRchar *) &curve;
   sts = om$send(
     msg = message GRvg.GRconstruct(construct_list),
     targetid = my_id);
    if (! (1 & sts)) goto wrapup;
  } /* ELSE FOR if ((order == 2) && least_squares_fit) */
/*
 * End of routine
 */
wrapup:
 if (points && (points != input_points)) free(points);
 if (curve.poles) free(curve.poles);
 if (curve.weights) free(curve.weights);
 if (curve.knots) free(curve.knots);
 if (ref_cv_geom)
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreecv(
    &loc_msg, 
    ref_cv_geom);
  }
 if ((! (1 & *msg)) && 
     delete_on_failure)
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation GRsubbc;
