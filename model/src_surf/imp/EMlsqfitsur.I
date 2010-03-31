/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs a least squares data fit on a set of input
 linestrings producing a surface.

 Notes

 Read the specification file for documentation.

 History

 06/18/86 : gk  : design date.
 12/16/87 : rlw : Total rewrite to kill digital data
 02/17/88 : rlw : Modified EFget_matrix_of_linestrings() to
                  compress the linear data (I was leaving gaps).
                  Also modified logic to clear surface pointer on
                  math error.
 09/27/88 : rlw : Modified to support fitting using data reduction
                  techniques.
 08/19/92 :  NP : SUN ANSI compile errors fixed. "curve" was typecast to
		  "IGRchar **" instead of "IGRchar *" in GRgenabsg. 
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "OMmacros.h"			/* OM_BLOCK_MOVE  stuff */
#include "bsunwght_p.h"
#include "bssdta_rdls.h"
#include "bsrev_cv.h"
#include "bslsqfitsf.h"
#include "bsfreesf.h"

method EMleast_squares_fit_surface(
 IGRlong	u_order;
 IGRlong	v_order;
 IGRboolean	u_periodic;
 IGRboolean	v_periodic;
 IGRlong	number_of_linestrings;
 struct		GRlc_info linestrings[];
 IGRlong	number_of_u_spans;
 IGRlong	number_of_v_spans;
 IGRdouble	*average_error;
 IGRdouble	*maximum_error;
 IGRlong	maximum_indicator[2];
 IGRpoint	maximum_segment[2];
 struct		GRvg_construct *construct_list)

{
 IGRboolean	use_data_reduction;
 IGRlong	sts, *msg, i, num_v_points, maximum_points;
 IGRlong	*points_per_linestring;
 IGRpoint	*fit_points;
 struct		IGRbsp_surface *surface;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 surface = NULL;
 fit_points = NULL;
 points_per_linestring = NULL;
/*
 * Set up data reduction
 */
 use_data_reduction = ((number_of_u_spans == 0) || (number_of_v_spans == 0));
 if (use_data_reduction)
  {
   u_periodic = FALSE;
   v_periodic = FALSE;
  } /* if (use_data_reduction) */
/*
 * Get the linestrings
 */
 {
    IGRlong EFget_matrix_of_linestrings();
 sts = EFget_matrix_of_linestrings(
   my_id,
   u_periodic, 
   v_periodic,
   number_of_linestrings, 
   linestrings,
   &num_v_points,
   &maximum_points,
   &points_per_linestring,
   &fit_points,
   msg);
  if (! (1 & sts)) goto wrapup;
  }
/*
 * Call the math
 */
 if (use_data_reduction)
  {
   IGRint	tangent_left, tangent_right;
   IGRlong	interior_knot_multiplicity, loc_msg;
   IGRdouble	u, v;

   tangent_left = 0;		/* No constraint */
   tangent_right = 0;		/* No constraint */
   maximum_indicator[1] = -1;
   interior_knot_multiplicity = 1;
   BSsdta_rdls(
     num_v_points,
     (IGRint *)points_per_linestring,
     fit_points,
     u_order,
     v_order,
     interior_knot_multiplicity,
     TRUE,		/* All tangent conditions are the same on each side */
     &tangent_left,	/* Options for tangents along left side */
     &tangent_right,	/* Options for tangents along right side */
     NULL,		/* No tangents constrained on the left */
     NULL,		/* No tangents constrained on the right */
     TRUE,		/* Output error information */
     maximum_error,
     average_error,
     (IGRint *)maximum_indicator,         /* Math only sets the row */
     &maximum_segment[1][0],	/* Point on original data (max error) */
     &u, &v,
     &maximum_segment[0][0],	/* Point on fitted surface (max error) */
     &surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      surface = NULL;		/* Just in case math returns garbage */
      *msg = MSFAIL;
      goto wrapup;
     }
   if (*maximum_error == 0.0) maximum_indicator[0] = -1;
  } /* if (use_data_reduction) */
 else
  {
   IGRlong	count, loc_msg;

   BSlsqfitsf(
     num_v_points,
     points_per_linestring,
     fit_points,
     u_order,
     v_order,
     number_of_u_spans,
     number_of_v_spans,
     u_periodic, 
     v_periodic, 
     &surface,
     average_error,
     maximum_error,
     (IGRint *)maximum_indicator,
     (IGRdouble *)maximum_segment,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      surface = NULL;		/* Math returns garbage */
      *msg = MSFAIL;
      goto wrapup;
     }
    else if (maximum_indicator[0] != -1)
     {
      IGRpoint	*pointer;
 
      pointer = fit_points + maximum_indicator[1];
      for (i = 0; i < maximum_indicator[0]; i++)
       pointer += points_per_linestring[i];
      maximum_segment[1][0] = pointer[0][0];
      maximum_segment[1][1] = pointer[0][1];
      maximum_segment[1][2] = pointer[0][2];
     }
  } /* if (use_data_reduction) */
/*
 * Load my instance data
 */
 construct_list->geometry = (IGRchar *) surface;
 sts = om$send(
   msg = message GRvg.GRconstruct(construct_list),
   targetid = my_id);
  if (! (1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (fit_points) free(fit_points);
 if (points_per_linestring) free(points_per_linestring);
 if (surface)
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(&loc_msg, surface);
  }
 if (! (1 & *msg))
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

/*
 Description

 This function gets a matrix of points from a set of linestrings.
 It was written because this same functionality is shared between
 surface by poles, direct fit, and least squares fit.

 History

 12/16/87 : rlw : The beginning
 02/17/88 : rlw : Compress the data.
 */

IGRlong EFget_matrix_of_linestrings(
 my_stupid_id,
 u_periodic, v_periodic,
 number_of_linestrings, linestrings,
 num_v_pts, max_pts,
 number_of_points_per_linestring, linestring_points,
 msg)

 OMuword	my_stupid_id;
 IGRboolean	u_periodic;
 IGRboolean	v_periodic;
 IGRlong	number_of_linestrings;
 struct		GRlc_info linestrings[];
 IGRlong	*num_v_pts;
 IGRlong	*max_pts;
 IGRlong	**number_of_points_per_linestring;
 IGRpoint	**linestring_points;
 IGRlong	*msg;

{
 IGRlong	i, *points_per_linestring;
 IGRlong	sts, num_points, maximum_points, num_v_points;
 IGRpoint	*points, *fit_points, *fit_points_pointer;
 struct		GRid *id;
 struct		GRlc_info *linestring;
 struct		GRmdenv_info *mdenv_info;
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 fit_points = NULL;
 points_per_linestring = NULL;
 *max_pts = 0;
 *num_v_pts = 0;
 *number_of_points_per_linestring = NULL;
 *linestring_points = NULL;
/*
 * Find out the maximum number of points required
 */
 maximum_points = 0;
 for (i = 0; i < number_of_linestrings; i++)
  {
   linestring = &linestrings[i];
   id = &linestring->located_obj;
   mdenv_info = &linestring->module_info.md_env;
   sts = om$send(
     msg = message GRvg.GRgenabsg(
      msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      (IGRchar **) &curve),
     senderid = my_stupid_id,
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   num_points = curve->num_poles;
   if (num_points > maximum_points)
    maximum_points = num_points;
  } /* for (i = 0; i < number_of_linestrings; i++) */
/*
 * Get the required memory
 */
 if (v_periodic) 
  num_v_points = number_of_linestrings + 1;
 else
  num_v_points = number_of_linestrings;
 fit_points = (IGRpoint *) malloc(num_v_points *
   maximum_points * sizeof(IGRpoint));
  if (!fit_points)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 fit_points_pointer = fit_points;
 points_per_linestring = (IGRlong *) malloc(
   num_v_points * sizeof(IGRlong));
  if (!points_per_linestring)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
/*
 * Get the point data
 */
 for (i = 0; i < number_of_linestrings; i++)
  {
   linestring = &linestrings[i];
   id = &linestring->located_obj;
   mdenv_info = &linestring->module_info.md_env;
   sts = om$send(
     msg = message GRvg.GRgenabsg(
      msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      (IGRchar **) &curve),
     senderid = my_stupid_id,
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   num_points = curve->num_poles;
   points = (IGRpoint *) curve->poles;
/*
 * Reverse the linestring, if required
 */
   if (linestring->geom_parms.polygon_inx)
    {
     IGRboolean	status;
     IGRlong	loc_msg;

     status = BSrev_cv(
       &loc_msg,
       curve);
      if (!status)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
    }
/*
 * Unweight the curve, if necessary
 */
   if (curve->rational)
    {
     IGRboolean	status;
     IGRlong	loc_msg;

     status = BSunwght_p(
      &loc_msg,
      curve->poles,
      curve->weights,
      &curve->num_poles,
      curve->poles);
    } /* if (curve->rational) */
/*
 * Close the curve, if it is periodic
 */
   if (u_periodic)
    {
     IGRint	i;

     i = num_points - 1;
     points[i][0] = points[0][0];
     points[i][1] = points[0][1];
     points[i][2] = points[0][2];
    }
/*
 * Arrange the data, as per math requires
 */
   points_per_linestring[i] = num_points;
   OM_BLOCK_MOVE(
    points,
    fit_points_pointer,
    num_points * sizeof(IGRpoint));
   fit_points_pointer += num_points;
  } /* for (i = 0; i < number_of_linestrings; i++) */
/*
 * Close the data in v, if periodic
 */
 if (v_periodic)
  {
   OM_BLOCK_MOVE(
    fit_points,
    fit_points_pointer,
    points_per_linestring[0] * sizeof(IGRpoint));
  }
/*
 * Shift the results
 */
 *number_of_points_per_linestring = points_per_linestring;
 points_per_linestring = NULL;
 *linestring_points = fit_points;
 fit_points = NULL;
 *num_v_pts = num_v_points;
 *max_pts = maximum_points;
/*
 * End of routine
 */
wrapup:
 if (fit_points) free(fit_points);
 if (points_per_linestring) free(points_per_linestring);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSgenbs;
