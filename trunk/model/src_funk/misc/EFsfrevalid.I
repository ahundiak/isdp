/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/* 
DESCRIPTION
		
This function is a simple validator for surface of revolution.
Given a curve (simple or composite) locate information and 2 points 
defining the axis line it will check for "overlaps" and illegal 
"intersections" between the curve and the axis line, if any. The
argument "EMmsg" holds this information. EMmsg contains the 
following values under different conditions:

EMS_S_Success
 If curve is OK for revolution about the axis.

EMS_I_Intersect
 If curve and the axis line have illegal intersections between them:
  a) If curve is closed, all intersections are illegal.
  b) If curve is not cosed, all intersections beside end point 
     intersections are illegal.

EMS_I_Coincident
 If parts of curve overlaps with the axis line.

EMS_I_Useless
 Implies (EMS_I_Intersect && EMS_I_Concident.)
     
NOTES

If the "display" information is sent then the function will dipslay
the overlaps and illegal intersections, if any.

Boolean argument "is_solid" is used to tell this routine if the resulting
entity is to be solid.  If this is the case and the curve is not closed, then
additional checks are performed to ensure that closing the curve off with
respect to the axis will form a valid solid.

HISTORY
	
02/22/88 : SAM : Creation date
03/21/88 : rlw : Modified return code as per documentation.
01/16/89 : rlw : Reworked in order to properly support solid placements
07/08/93 :Sudha  Modified for BSprototypes ansification

*/
class implementation Root;

#include "EMS.h"		/* Big daddy */

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"		/* The works */
#include "bserr.h"		/* Return codes */
#include "emsmacros.h"		/* EM3dbxinc macro */
#include "emserr.h"		/* Return codes */
#include "EMSmsgdef.h"		/* Return codes */
#include "maptlnpro.h"
#include "bsparameters.h"
#include "bscvkttol2.h"
#include "bscvcvint.h"
#include "bsbx2.h"

IGRlong EFvalidate_surface_of_revolution(
 is_solid,
 curve_info,
 axis,
 my_id,
 display,
 display_env,
 EMmsg)

IGRboolean	is_solid;
struct		GRlc_info *curve_info;
IGRpoint	axis[2];
OM_S_OBJID	my_id;
struct		IGRdisplay *display;
struct		GRmd_env *display_env;
IGRlong		*EMmsg;
{
 IGRlong	sts, number_of_lines;
 IGRpoint	line[3][2];
 struct		IGRbsp_curve *curve;
 struct		IGRdisplay local_display;
/*
 * Initialize
 */
 *EMmsg = EMS_S_Success;
/*
 * Increase the display weight such that overlaps
 * can be seen.
 */
 if (display)
  {
   local_display = *display;
   local_display.weight += 3;
  }
/*
 * Get the geometry of the input curve
 */
 {
  extern	IGRlong EFgetabstract();
  struct	GRevent event;

  event.located_object[0] = *curve_info;
  sts = EFgetabstract(
    &event,
    my_id,
    &curve,
    EMmsg);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * Get the range of the input curve
 */
 {
extern IGRboolean rlw_get_better_line() ;
  IGRboolean	status;
  IGRlong	loc_msg;
  IGRdouble	dist_tol, range[6];
  struct	IGRline input_line;

  status = BSbx2(
   &loc_msg,
   &curve->num_poles,
   (IGRpoint *)curve->poles,
   curve->weights,
   &range[0],
   &range[3]);
/*
 * Increase the range box by an acceptable tolerance
 */
  status = BSEXTRACTPAR(
   &loc_msg,
   BSTOLLENVEC,
   dist_tol);
  dist_tol *= 2.0;
  EM3dbxinc(		/* This is a macro */
   range,
   dist_tol);
/*
 * Use this range to construct an axis line which totally extends 
 * through the range box of the curve.
 */
  input_line.point1 = axis[0];
  input_line.point2 = axis[1];
  status = rlw_get_better_line(
    range,
    &input_line,
    line,
    EMmsg);
   if (! status) goto wrapup;
 }
/*
 * If we are validating a solid of revolution then we also need
 * to perform additional checks if the input curve is open.  In such
 * cases we close off the solid by caps and at times these caps can
 * intersect the solid.  We need to intersect the input curve with 
 * lines which extend from the curve endpoints to the axis.  If these
 * lines cut the curve then we know that an invalid solid will be formed.
 */
 if (is_solid &&
     (! curve->phy_closed))
  {
   IGRboolean	status;
   IGRlong	index;
   IGRdouble	t;
   struct	IGRline better_line;

   line[1][0][0] = curve->poles[0];
   line[1][0][1] = curve->poles[1];
   line[1][0][2] = curve->poles[2];
   index = (curve->num_poles - 1) * 3;
   line[2][0][0] = curve->poles[index++];
   line[2][0][1] = curve->poles[index++];
   line[2][0][2] = curve->poles[index];
   if (curve->rational)
    {
     line[1][0][0] /= curve->weights[0];
     line[1][0][1] /= curve->weights[0];
     line[1][0][2] /= curve->weights[0];
     index = (curve->num_poles - 1);
     line[2][0][0] /= curve->weights[index];
     line[2][0][1] /= curve->weights[index];
     line[2][0][2] /= curve->weights[index];
    }
   better_line.point1 = line[0][0];
   better_line.point2 = line[0][1];
   status = MAptlnproj(
     EMmsg,
     line[1][0],
     &better_line,
     line[1][1],
     &t);
    if (! status) goto wrapup;
   status = MAptlnproj(
     EMmsg,
     line[2][0],
     &better_line,
     line[2][1],
     &t);
    if (! status) goto wrapup;
   number_of_lines = 3;
  } /* if (is_solid && (! curve->phy_closed)) */
 else
  number_of_lines = 1;
/*
 * Preperation work for intersection computation
 * and display.
 */
 {
  IGRlong	i, loc_msg;
  IGRdouble	par_tol, knots[4];
  struct	IGRbsp_curve axis_curve;

  BScvkttol2(
    curve->order,
    curve->knots,
    curve->num_poles,
    curve->poles,
    curve->weights,
    &par_tol,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *EMmsg = MSFAIL;
     goto wrapup;
    }
  knots[0] = knots[1] = 0.0;
  knots[2] = knots[3] = 1.0;
  axis_curve.order = 2;
  axis_curve.periodic = FALSE;
  axis_curve.non_uniform = FALSE;
  axis_curve.num_poles = 2;
  axis_curve.num_knots = 4;
  axis_curve.knots = knots;
  axis_curve.rational = FALSE;
  axis_curve.weights = NULL;
  axis_curve.planar = TRUE;
  axis_curve.phy_closed = FALSE;;
  axis_curve.num_boundaries = 0;
  axis_curve.bdrys = NULL;
  *EMmsg = EMS_S_Success;
/*
 * Intersect each of the lines with the curve
 */
  for (i = 0; i < number_of_lines; i++)
   {
    IGRboolean	out_pt_alloc, out_over_alloc;
    IGRlong	loc_msg;
    IGRdouble	par0[3], par1[3];
    BSpair	over0[2], over1[2];
    IGRpoint	int_pts[3], end_pts[2][2];
    BSpair	*xover0, *xover1;
    IGRdouble	*xpar0, *xpar1;
    IGRpoint	*xint_pts, *xend_pts;
    IGRint	nint, nover;
/*
 * Initialize
 */
    axis_curve.poles = (IGRdouble *)line[i];
    xover0 = xover1 = NULL;
    xpar0 = xpar1 = NULL;
    xint_pts = xend_pts = NULL;
    nint = 0;
    nover = 0;
/*
 * Intersect the curve with the axis line
 */
    BScvcvint(
     curve,
     &axis_curve,
     TRUE,		/* Remove duplicate intersect points */
     3,			/* 3 points preallocated */
     2,			/* 2 overlaps preallocated */
     int_pts,		/* Preallocated intersection points */
     par0,		/* Preallocated intersection parameters on cv 0 */
     par1,		/* Preallocated intersection parameters on cv 1 */
     end_pts[0],	/* Preallocated overlap points */
     (IGRdouble *)over0,/* Preallocated overlap parameters on cv 0 */
     (IGRdouble *)over1,/* Preallocated overlap parameters on cv 1 */
     &nint,		/* Number of intersection points found */
     &nover,		/* Number of overlaps found */
     &out_pt_alloc,	/* Are int points in xint_pts (TRUE) or int_pts */
     &out_over_alloc,	/* Are overlaps in x stuff (TRUE) or regular stuff */
     &xint_pts,		/* Intersection points allocated by the math */
     &xpar0,		/* Intersection parameters allocated by the math */
     &xpar1,		/* Intersection parameters allocated by the math */
     &xend_pts,		/* Overlap points allocated by the math */
     (IGRdouble **)&xover0,/* Overlap parameters allocated by the math */
     (IGRdouble **)&xover1,/* Overlap parameters allocated by the math */
     &loc_msg);		/* Error return code */
    if (loc_msg != BSSUCC)
     {
      *EMmsg = MSFAIL;
      goto wrapup;
     }
/*
 * At this point we have the intersections between the axis
 * line and the curve.  Any overlaps or non-endpoint intersections
 * between the two is sufficent to disqualify this curve.
 */
    if (nover)
     {
      if (*EMmsg == EMS_S_Success)
       *EMmsg = EMS_I_Coincident;
      else if (*EMmsg == EMS_I_Intersect)
       *EMmsg = EMS_I_Useless;
      if (display)
       {
        extern		IGRlong ECdisplayPointSetByBuffer();
        IGRlong		j;
        IGRpoint	*over_pts;

        if (out_over_alloc)
         over_pts = xend_pts;
        else
         over_pts = (IGRpoint *)end_pts;
        for (j = 0; j < nover; j++)
         {
          sts = ECdisplayPointSetByBuffer(
            &loc_msg,
            local_display,
            *display_env,
            my_id,
            2,			/* number_of_points */
            over_pts[2 * j],	/* points */
            TRUE);		/* draw background */
         } /* for (j = 0; j < nover; j++) */
       } /* if (display) */
      if (out_over_alloc)
       {
        free(xend_pts);
        free(xover0);
        free(xover1);
       } /* if (out_over_alloc) */
     } /* if (nover) */
    if (nint)
     {
      extern		IGRlong ECdisplayPointSetByBuffer();
      IGRlong		j, good_intersection_count = 0;
      IGRdouble		*pars, u_low, u_hig;
      IGRpoint		*inter_pts;

      if (out_pt_alloc)
       {
        pars = xpar0;
        inter_pts = xint_pts;
       }
      else
       {
        pars = par0;
        inter_pts = int_pts;
       }
      u_low = curve->knots[curve->order - 1];
      u_hig = curve->knots[curve->num_poles];
      for (j = 0; j < nint; j++)
       {
        if (curve->phy_closed ||
            ((fabs(pars[j] - u_low) > par_tol) &&
            (fabs(pars[j] - u_hig) > par_tol)))
         {
          good_intersection_count++;
          if (display)
           {
            sts = ECdisplayPointSetByBuffer(
              &loc_msg,
              local_display,
              *display_env,
              my_id,
              1,		/* number_of_points */
              inter_pts[j],	/* points */
              TRUE);		/* draw background */
           } /* if (display) */
         } /* if the intersect counts as good */
       } /* for (j = 0; j < nint; j++) */
      if (good_intersection_count)
       {
        if (*EMmsg == EMS_S_Success)
         *EMmsg = EMS_I_Intersect;
        else if (*EMmsg == EMS_I_Coincident)
         *EMmsg = EMS_I_Useless;
       } /* if (good_intersection_count) */
      if (out_pt_alloc)
       {
        free(xint_pts);
        free(xpar0);
        free(xpar1);
       } /* if (out_pt_alloc) */
     } /* if (nint) */
   } /* for (i = 0; i < number_of_lines; i++) */
 }
/*
 * eof
 */
wrapup:
 if (1 & *EMmsg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
