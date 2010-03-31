/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This funtion will display the natural normal of a curve or
 the a directional indicator (tangent) at the beginning or end
 of the curve.

 Arguments

 loc_info		Curve locate information

 event			This event is used to determine the view normal
			vector.  It is used iff displaying normals and
			the curve is not planar.

 display_normal		If TRUE  then display the normal vector of the
                        curve near the middle of the curve.  If the curve
			is planar then the vector draw is the cross product
			of the tangent vector and the plane normal.  If the
			curve is nonplanar then the vector draw is the
			cross product of the tangent vector and the view
			normal.  If FALSE then the vector drawn is the
			tangent vector at the beginning of the curve.

 reverse_vector		If TRUE and displaying the normal then the vector
			is drawn in the opposite direction.  If TRUE
			and displaying the tangent then the vector is
			drawn at the end of the curve.

 my_stupid_id		Callers object id.

 draw_mode		Inputs the display mode:
                        (eg: GRbe, GRbd, GRhe, GRhd, GRhhd);

 display_env		Display enviroment.  Should be obtained by calling
			gr$get_display_env().

 display		Active color, weight, etc.  Should be obtained by
			calling gr$get_active_display().

 msg			MSSUCC or MSFAIL

 History

 11/12/87 : rlw : Creation date
 01/05/89 : ss  : Changed the Boolean flag - "draw_background" to
                  "draw_mode"
 10/26/89 : rlw : Modified such that the routine will not error out if
                  a point curve is input.  In such cases it merely returns
                  without drawing an arrow.
 Sudha   06/02/93        modified to include for BSprototype headers

 */

class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "bserr.h"		/* Math error return codes */
#include "bsnorvec.h"
#include "bscvnormal.h"
#include "bscveval_b.h"
#include "bscrossp.h"
#include "bsbx2.h"

from GRvg import GRgenabsg;

IGRlong EFdisplay_curve_normal_or_tangent(
 loc_info,		/* Which curve? */
 event,			/* Used to get boreline for normal vectors */
 display_normal,	/* Display normal vector or tangent vector? */
 reverse_vector,	/* Reverse the vector or not */
 my_stupid_id,		/* Your id */
 draw_mode,		/* Drawing mode */
 display_env,		/* Display enviroment */
 display,		/* Color, weight, etc. */
 msg)			/* Error return code */

struct		GRlc_info *loc_info;
struct		GRevent *event;
IGRboolean	display_normal;
IGRboolean	reverse_vector;
OM_S_OBJID	my_stupid_id;
enum GRdpmode	draw_mode;
struct		GRmd_env *display_env;
struct		IGRdisplay *display;
IGRlong		*msg;

{
 IGRlong	sts;
 IGRpoint	point_on_curve;
 IGRvector	tangent_vector, normal_vector, curve_normal;
 GRrange	range;
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Get the curve geometry
 */
 {
  IGRchar	*generic_pointer;
  struct	GRid *id;
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &loc_info->module_info.md_env;
  id = &loc_info->located_obj;
  sts = om$send(
    msg = message GRvg.GRgenabsg(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     &generic_pointer),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts)) goto wrapup;
  curve = (struct IGRbsp_curve *) generic_pointer;
 }
/*
 * Compute the tangent vector of the curve at
 * a predefined parameter value
 */
 {
  IGRboolean	status;
  IGRboolean	evaluate_boundaries, was_discontinuous;
  IGRlong	loc_msg;
  IGRint        number_of_derivatives;
  IGRdouble	u_value, u_low, u_hig;
  IGRpoint	left_derv[2], right_derv[2];

  u_low = curve->knots[curve->order - 1];
  u_hig = curve->knots[curve->num_poles];
  if (display_normal)
   u_value = (u_hig - u_low) / 2.0;
  else if (reverse_vector)
   u_value = u_hig;
  else
   u_value = u_low;
  evaluate_boundaries = TRUE;
  number_of_derivatives = 1;
  status = BScveval_b(
    &loc_msg,
    curve,
    &u_value,
    &number_of_derivatives,
    &evaluate_boundaries,
    &was_discontinuous,
    left_derv,
    right_derv);
   if (! status)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
/*
 * If the tangent was not continuous at the chosen
 * parameter then average the left and right tangents
 */
  if (was_discontinuous)
   {
    left_derv[1][0] += right_derv[1][0];
    left_derv[1][0] /= 2.0;
    left_derv[1][1] += right_derv[1][1];
    left_derv[1][1] /= 2.0;
    left_derv[1][2] += right_derv[1][2];
    left_derv[1][2] /= 2.0;
   }
/*
 * Normalize the tangent vector
 */
  status = BSnorvec(
    &loc_msg,
    left_derv[1]);
   if (!status)
    {
     if (loc_msg != BSDGENRAT)
      *msg = MSFAIL;
     goto wrapup;
    }
  point_on_curve[0] = left_derv[0][0];
  point_on_curve[1] = left_derv[0][1];
  point_on_curve[2] = left_derv[0][2];
  tangent_vector[0] = left_derv[1][0];
  tangent_vector[1] = left_derv[1][1];
  tangent_vector[2] = left_derv[1][2];
 }
/*
 * Get the curve normal if the curve is planar other wise
 * use the view z vector as the desired normal
 */
 if (display_normal)
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BScvnormal2(
     &loc_msg,
     curve,
     normal_vector);
    if (!status)
     {
      if (loc_msg == BSNONPLANAR)
       {
        IGRboolean	EFboreline();
        IGRpoint	points[2];
        struct		IGRline bore_line;
 
        bore_line.point1 = &points[0][0];
        bore_line.point2 = &points[1][0];
        status = EFboreline(
          msg,
          my_stupid_id,
          event,
          &bore_line);
         if (!status) goto wrapup;
        normal_vector[0] = points[0][0] - points[1][0];
        normal_vector[1] = points[0][1] - points[1][1];
        normal_vector[2] = points[0][2] - points[1][2];
        status = BSnorvec(
          &loc_msg,
          normal_vector);
         if (!status)
          {
           *msg = MSFAIL;
           goto wrapup;
          }
       } /* if (loc_msg == BSNONPLANAR) */
      else
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     } /* if (!status) */
/*
 * Cross the plane normal with the curve tangent to yield
 * the curve normal.
 */
   status = BScrossp(
    &loc_msg,
    normal_vector,
    tangent_vector,
    curve_normal);
   status = BSnorvec(
     &loc_msg,
     curve_normal);
    if (!status)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* if (display_normal) */
/*
 * Get the range of the curve.  This is used to
 * determine the length of the vector drawn on
 * the screen.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;

  status = BSbx2(
    &loc_msg,
    &curve->num_poles,
    (IGRpoint *)curve->poles,
    (curve->rational ? curve->weights : NULL),
    &range[0],
    &range[3]);
   if (! status)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Finally, let's draw the vector
 */
 {
  void		EFdraw_vector_on_screen();
  IGRlong	loc_msg;

  EFdraw_vector_on_screen(
   my_stupid_id,
   display,
   display_env,
   draw_mode,
   reverse_vector,
   point_on_curve,
   (display_normal ? curve_normal : tangent_vector),
   range,
   &loc_msg);
 }
/*
 * eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
