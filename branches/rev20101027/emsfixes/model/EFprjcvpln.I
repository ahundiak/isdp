/* ###################   APOGEE COMPILED   ################## */
/*
Abstract

 This function projects a curve on to an infinite plane along a
 specified vector.  The resulting curve and it's type are returned.

Input arguments

 located_curve		Located information for the curve to be projected.
 input_curve_geometry	Geometry of the curve to be projected, used if and
			only if located_curve not specified.
 input_curve_class	Class id of the curve to be projected, used if and
			only if located_curve not specified.
 plane			The plane on to which the curve is to be projected.
 projection_vector	Vector along which the curve is to be projected.
 my_stupid_id		Caller's object id

Output arguments

 output_curve		Geometry of output curve.  Note that memory should
			already be allocated by the caller as it is the
			same as the input curve.
 output_curve_class	Class id of projected curve.
 msg			Error return code
			MSSUCC - No problem
			MSFAIL - It didn't work
			MANOSOLUTION - No intersection possible

History

 07/21/88 : dhm : creation date.
 10/04/88 : rlw : Reworked such that this function could easily be used
                  by EFmapthecrv.I and to correct logic problems.
 10/21/89 : pp  : Fixed a problem wherein BStstcvfln was not returning end
                  points when the output curve was degenerate.
 07/08/93   Sudha Modified for BSprototypes ansification


 04/03/98   HF	  TR 179800504 I/LOFT: Create Balanced Plates

*/

class implementation Root;

#include <stdio.h>
#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"		/* Includes everything */
#include "bststcvfln.h"
#include "bsptlnplan.h"
#include "bsptlngen.h"
#include "bsprj_cv_pl.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsaxeslen.h"
#include "bsprtbspcv.h"

#define POINT_CONDITION    0
#define COLLAPSE_CONDITION 1
#define AT_ANGLE_CONDITION 2
#define GENERAL_CONDITION  3
#define PRESERVE_CONDITION 4

extern OMuword OPP_GR3dellarc_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dpllnstr_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GRbcsubbc_class_id;

// #define VD_DEBUG
// #include  "VDdebug.h"

IGRlong EFproject_curve_onto_plane(
 located_curve,
 input_curve_geometry,
 input_curve_class,
 plane,
 projection_vector,
 my_stupid_id,
 output_curve,
 output_curve_class,
 msg) 
 
struct		GRlc_info *located_curve;
struct		IGRbsp_curve *input_curve_geometry;
OMuword		input_curve_class;
struct		IGRplane *plane;
IGRvector	projection_vector;
OMuword		my_stupid_id;
struct		IGRbsp_curve *output_curve;
OMuword		*output_curve_class;
IGRlong		*msg;

{
 OMuword	curve_class_id;
 IGRboolean	not_classified;
 IGRlong	sts, condition;
 IGRint		planar_code;
 IGRpoint	point_on_curve;
 IGRvector	normal_vector_to_curve;
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve = NULL;
 not_classified = FALSE;

// __enterFunction ( name = "EFproject_curve_onto_plane", argfmt = "projection_vector = %lg %lg %lg",
//		   args = `projection_vector[0], projection_vector[1], projection_vector[2]` );
/*
 * Get the geometry and class information of
 * the input curve
 */
 if (located_curve)
  {
   extern	IGRlong EMget_the_geometry();
   struct	GRid *id;

   sts = EMget_the_geometry(
     located_curve,
     TRUE,		/* This is a curve */
     FALSE,		/* Use existing flow direction */
     FALSE,		/* Separate mallocs not necessary */
     my_stupid_id,
     &curve,
     msg);
    if (! (1 & sts)) goto wrapup;
   id = &located_curve->located_obj;
   sts = om$get_classid(
     objid = id->objid,
     osnum = id->osnum,
     p_classid = &curve_class_id);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* if (located_curve) */
 else
  {
   curve = input_curve_geometry;
   curve_class_id = input_curve_class;
  } /* ELSE FOR if (located_curve) */
/*
 * Project the curve on to the plane.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;

  status = BSprj_cv_pl(
    &loc_msg,
    curve,
    plane->point,
    plane->normal,
    projection_vector,
    output_curve);
   if (loc_msg != BSSUCC)
    {
     if (loc_msg == BSINVDIR)
      *msg = MANOSOLUTION;
     else
      *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Determine the plane of the input curve, if any
 */
 {
  IGRlong	loc_msg;

  BSptlnplan(
    curve->num_poles,
    curve->rational,
    (IGRpoint *)curve->poles,
    curve->weights,
    &planar_code,		/* 1 point, 2 line, 3 plane, 4 non-planar */
    normal_vector_to_curve,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  point_on_curve[0] = curve->poles[0];
  point_on_curve[1] = curve->poles[1];
  point_on_curve[2] = curve->poles[2];
  if (curve->rational)
   {
    IGRdouble	weight;

    weight = curve->weights[0];
    point_on_curve[0] /= weight;
    point_on_curve[1] /= weight;
    point_on_curve[2] /= weight;
   } /* if (curve->rational) */
 }
/*
 * Ascertain the nature of the projection
 */
 switch (planar_code)
  {
   case 1:			/* Curve is a point */
    condition = POINT_CONDITION;
    break;
   case 2:			/* Curve does not lie in a unique plane */
    condition = COLLAPSE_CONDITION;
    break;
   case 3:			/* Curve is planar */
    {
     IGRboolean	status;
     IGRlong	loc_msg;
     IGRdouble	dot_product, dot_tol;
     IGRvector	normalized_projection_vector;

     normalized_projection_vector[0] = projection_vector[0];
     normalized_projection_vector[1] = projection_vector[1];
     normalized_projection_vector[2] = projection_vector[2];
     status = BSnorvec(
       &loc_msg,
       normalized_projection_vector);
      if (! status)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     dot_product = BSdotp(
      &loc_msg,
      normal_vector_to_curve,
      normalized_projection_vector);
     dot_product = fabs(dot_product);
     status = BSEXTRACTPAR(
      &loc_msg, 
      BSTOLORTHOVEC, 
      dot_tol);
     if (dot_product < dot_tol)
      condition = COLLAPSE_CONDITION;
     else if ((dot_product > (1.0 - dot_tol)) &&
              (dot_product < (1.0 + dot_tol)))
      {
       dot_product = BSdotp(
        &loc_msg,
        normal_vector_to_curve,
        plane->normal);
       dot_product = fabs(dot_product);
       if (dot_product < dot_tol)
        {
         *msg = MANOSOLUTION;		/* Should have be caught by math */
         goto wrapup;
        }
       else if ((dot_product > (1.0 - dot_tol)) &&
                (dot_product < (1.0 + dot_tol)))
        condition = PRESERVE_CONDITION;
       else
        condition = AT_ANGLE_CONDITION;
      }
     else
      condition = AT_ANGLE_CONDITION;
    }
    break;
   case 4:			/* Curve is not planar */
   default:			/* Not possible */
    condition = GENERAL_CONDITION;
    break;
  } /* switch (planar_code) */
/*
 * Ascertain the nature of the projection
 */
 switch (condition)
  {
   case AT_ANGLE_CONDITION:
    if (curve_class_id == OPP_GR3dcircle_class_id)
     *output_curve_class = OPP_GR3dellipse_class_id;
    else if (curve_class_id == OPP_GR3dcirarc_class_id)
     *output_curve_class = OPP_GR3dellarc_class_id;
    else if ((curve_class_id == OPP_GR3dellipse_class_id) ||
             (curve_class_id == OPP_GR3dellarc_class_id))
     {
      IGRboolean	status;
      IGRlong		loc_msg;
      IGRint		type;
      IGRdouble		basis_tol, major_axis_length, minor_axis_length;
      IGRpoint		major_1, major_2, minor_1, minor_2;

      status = BSEXTRACTPAR(
       &loc_msg, 
       BSTOLLENVEC, 
       basis_tol);
      if (curve_class_id == OPP_GR3dellipse_class_id)
       type = BSCELLIPSE;
      else
       type = BSCARCELLIPTIC;
      status = BSaxeslen(
        &loc_msg,
        &type,
        output_curve,
        plane->normal,
        major_1,
        major_2,
        minor_1,
        minor_2,
        &major_axis_length,
        &minor_axis_length);
       if (! status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
      if (fabs(major_axis_length - minor_axis_length) < basis_tol)
       {
        if (type == BSCELLIPSE)
         *output_curve_class = OPP_GR3dcircle_class_id;
        else
         *output_curve_class = OPP_GR3dcirarc_class_id;
       }
      else
       *output_curve_class = curve_class_id;
     }
    else
     not_classified = TRUE;
    break;
   case PRESERVE_CONDITION:
    *output_curve_class = curve_class_id;
    break;
   case POINT_CONDITION:
   case COLLAPSE_CONDITION:
    {
     IGRboolean	status;
     IGRlong	loc_msg;
     IGRint	type;
     IGRpoint	start_point, end_point;
     IGRboolean degenerate;
     IGRboolean	is_line;

     degenerate = FALSE;
     if (condition == POINT_CONDITION)
       degenerate = TRUE;
     else
      {

       BStstcvfln(
         output_curve,
         &is_line,
         start_point,
         end_point,
         &loc_msg);
        if (loc_msg != BSSUCC)
         {
          *msg = MSFAIL;
          goto wrapup;
         }
/*
 * If it is a degenerate line then math does not return end points.
 * pp (10/21/89)
 */
        if (is_line == 2)
         degenerate = TRUE;
/* end pp */

      } /* ELSE FOR if (condition == POINT_CONDITION) */


/* begin pp */
     if (degenerate)
     {
      start_point[0] = output_curve->poles[0];
      start_point[1] = output_curve->poles[1];
      start_point[2] = output_curve->poles[2];
      if (output_curve->rational)
      {
        IGRdouble	weight;

        weight = output_curve->weights[0];
        start_point[0] /= weight;
        start_point[1] /= weight;
        start_point[2] /= weight;
      }
       end_point[0] = start_point[0];
       end_point[1] = start_point[1];
       end_point[2] = start_point[2];
     }
/* end pp */


/* HF: 04/03/98 begin TR 179800504 I/LOFT: Create Balanced Plates  */

     if (is_line == FALSE)
     {
       int k, i0 = output_curve->num_poles - 1;

       for (k=0; k < 3; k++)
       {
	 start_point[k] = output_curve->poles[k];
	 end_point  [k] = output_curve->poles[i0 * 3 + k];
       }
       
       if (output_curve->rational)
       {
	 IGRdouble	weight_0, weight_1;
	 weight_0 = output_curve->weights[0];
	 weight_1 = output_curve->weights[i0];

	 for (k=0; k < 3; k++ )
	 {
	   start_point[k] /= weight_0;
	   end_point  [k] /= weight_1;
	 }
       }
     }
//     __printf("start_point = %lg %lg %lg, end_point = %lg %lg %lg",
//	      `start_point[0],start_point[1],start_point[2],  end_point[0],end_point[1],end_point[2]` );
     
/* end HF: */

     status = BSptlngen(
       &loc_msg,
       start_point,
       end_point,
       output_curve,
       &type);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     if (type == BSCPOINT)
      *output_curve_class = OPP_GR3dpoint_class_id;
     else
      *output_curve_class = OPP_GR3dlineseg_class_id;
    }
    break;
   case GENERAL_CONDITION:
    not_classified = TRUE;
    break;
  } /* switch (planar_code) */
/*
 * If the curve type is still not classified then
 * mark as linear or freeform.
 */
 if (not_classified)
  {
   if (output_curve->order == 2)
    {
     if (output_curve->num_poles == 2)
      *output_curve_class = OPP_GR3dlineseg_class_id;
     else
      *output_curve_class = OPP_GR3dpllnstr_class_id;
    }
   else
    *output_curve_class = OPP_GRbcsubbc_class_id;
  } /* if (not_classified) */
/*
 * eof
 */
wrapup:

 //BSprtbspcv(output_curve);
 //BSprtbspcv(curve );

 if (curve && (curve != input_curve_geometry))
   free(curve);

 if (1 & *msg)
   sts = (TRUE);
 else
   sts = (FALSE);
 
// __exitFunction ( name = "EFproject_curve_onto_plane", argfmt = "sts = %d, *msg = %d",
//		  args = `sts, *msg` );
 
 return(sts);
}

end implementation Root;
