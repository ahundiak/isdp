/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This routine maps a series of points to a surface generating the
 required uv data.  The points are determined by stroking the input
 curve by the active chord height tolerance.  If it is known that the
 curve is a iso-parametric curve of the surface then special processing
 takes place.

 Arguments

 curve		This curve is stroked by the active chord height tolerance
                and the corresponding xyz and uv data are returned.  It
                is assumed that this curve lies on the surface within the
                basis tolerance.
 surface	Surface on which the uv data is desired.
 par_tol	Parametric basis tolerance for the surface.
 type		This variable defines the element type of base of the
                surface.  It can be:
                BSCCIRCLE implying cylinder, partial cylinder, cone, or
                 partial cone.
                BSCELLIPSE implying elliptical cylinderr, partial elliptical
                 cylinder, elliptical cone, partial elliptical cone.
                BSCUNKNOWNTYPE implying nothing is known.
                This type is used to provide for fast mapping when possible.
 is_iso_data	Used iff the input is given by a curve.
                Flag indicating whether or not the xyz data is known to
                lie along a constant parametric curve.  If this is true
                then special processing takes place.
 num_points	This data is returned such that is corresponds with the uv
                data.
 points		This data is returned such that is corresponds
                with the uv data.
 uv_data	The resulting parametric space data.
 correlation    An array of double of size num_points.  For each point
                returned the corresponding parameter on the input curve
                is also returned.
 msg		Error return code.
                MSSUCC  - All is fine.
                MSINARG - This routine could not solve your problem.
		EMS_E_InvalidArg - incorrect iso property sent in.
                M*      - Something went wrong
		
 Notes

 This routine will return parametric data without any jumps in parametric
 space so long as the input curve does not cross the seam, i.e. it is
 split at the seam.  It will also fix jumps if all the data lies along
 a seam edge.  Note that a minimum of 4 points is required to be mapped.
 This is need to ensure that the above jumps do not occur.

 The knot vector of the input curve is assumed to be normalized!

 History

 11/10/88 : rlw : Creation date
 11/17/88 : rlw : Modified due to changed in the functions which fix
                  parametric data on degenerate edges.
 01/23/89 : rlw : Modified not to call the special mapping routine for 
                  arcs.  Because Dieter has changed the way these are defined
                  in the I/EMS 1.2.0 release, the MAangtou() function no
                  longer works properly and cannot be repaired such that
                  both old and new design files work properly.
 01/25/89 : rlw : I screwed up the above fix.
 02/02/89 : rlw : Modified to also stroke iso edges by cht and to
                  return information which correlates the points to the
                  input curve.  Also give up if the math says the data
                  is not on the surface.
 09/05/89 : SM  : Call EFis_iso_edge if the input data is iso, to check if
		  it is really so. If conflicting, return EMS_E_InvalidArg.
		  This is a safety check to counter tolerance problems
		  when using dot tolerance for determining the relationship
		  between two vectors or simply to counter some other problem.
		  An error message is printed to track such a case.
 10/30/89 : SM  : Print error message for the above case only if DEBUG.
 02/11/90 : SS  : Added angle-tolerancing in map_xyz_uv_cyl function, when
                  obtaining the 'u' parameter.
 07/06/93 : Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"		/* Shared libraries */
#include <stdio.h>
#include <math.h>		/* Define fab(), etc. */
#include "bs.h"			/* Type definitions */
#include "bsconic.h"		/* Defines conic types */
#include "bsparameters.h"	/* Tolerances */
#include "bsmemory.h"		/* BSMEMCPY() macro */
#include "bsvalues.h"		/* M_PI */
#include "msdef.h"		/* Error return codes */
#include "maerr.h"		/* Error return codes */
#include "EMSmsgdef.h"		/* EMS_E_InvalidArg */
#include "emsdef.h"		/* MINDOUBLE */
#include "maptwcang.h"
#include "maptlspro.h"
#include "maidmx.h"
#include "bsunwght_p.h"
#include "bsptsoldtnw.h"
#include "bsptlnplan.h"
#include "bsprptsonsf.h"
#include "bsnorvec.h"
#include "bslocalcord.h"
#include "bsfreesf.h"
#include "bsexch_u_v.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bscncprop.h"
#include "bschtptstcv.h"
#include "bsblkmv.h"
#include "bsangarctou.h"
#include "bsallocsf.h"

static IGRlong EFget_uv_from_xyz_for_cylinders();
static IGRlong EMmap_xyz_to_uv_for_cylinder();
static IGRboolean EFbspcurve_to_igrarc();

IGRlong EFspecial_map_xyz_to_uv(
 curve,
 surface,
 par_tol,
 type,
 is_iso_data,
 num_points,
 points,
 uv_data,
 correlation,
 msg)

struct		IGRbsp_curve *curve;
struct		IGRbsp_surface *surface;
IGRdouble	par_tol;
IGRlong		type;
IGRboolean	is_iso_data;
IGRlong		*num_points;
IGRpoint	**points;
BSpair		**uv_data;
IGRdouble	**correlation;
IGRlong		*msg;

{
/*
 * Initialize
 */
 *msg = MSSUCC;
 *num_points = 0;
 *points = NULL;
 *uv_data = NULL;
 *correlation = NULL;
/*
 * Process linear curves
 */
 if (curve->order == 2)
  {
   *num_points = curve->num_poles;
   *points = (IGRpoint *) malloc(*num_points * sizeof(IGRpoint));
    if (! *points)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   if (curve->rational)
    {
     IGRboolean	status;
     IGRlong	loc_msg;

     status = BSunwght_p(
      &loc_msg,
      curve->poles,
      curve->weights,
      &curve->num_poles,
      (IGRdouble *)*points);
    }
   else
    {
     BSMEMCPY(
      *num_points * sizeof(IGRpoint),
      (char *) curve->poles,
      (char *) *points);
    }
   *correlation = (IGRdouble *) malloc(*num_points * sizeof(IGRdouble));
    if (! *correlation)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   BSMEMCPY(
    *num_points * sizeof(IGRdouble),
    (char *) &curve->knots[1],
    (char *) *correlation);
  }
/*
 * Stroke the input curve
 */
 else
  {
   IGRlong	i, loc_msg;
   IGRdouble	u_low, u_hig, delta_u, u;

   if (is_iso_data)
    {
     *num_points = 4;     /* Minimum number needed */
     *points = (IGRpoint *) malloc(*num_points * sizeof(IGRpoint));
      if (! *points)
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     u_low = curve->knots[curve->order - 1];
     u_hig = curve->knots[curve->num_poles];
     delta_u = (u_hig - u_low) / (*num_points - 1);
     u = u_low;
     for (i = 0; i < *num_points; i++)
      {
       BScveval(
         curve,
         u,
         0,		/* No derivatives */
         (IGRpoint *) (*points)[i],
         &loc_msg);
        if (loc_msg != BSSUCC)
         {
          *msg = MSFAIL;
          goto wrapup;
         }
       u += delta_u;
      } /* for (i = 0; i < *num_points; i++) */
     } /* if (is_iso_data) */
   else
    {
     IGRlong	loc_msg;

     BSchtptstcv(
       curve,
       (IGRint *)num_points,
       points,
       correlation,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
/*
 * If the surface is closed and we have less than
 * 4 stroked points then give it up because we
 * cannot ensure that the output will not have
 * jumps in it.
 */
     if ((surface->u_phy_closed ||
          surface->v_phy_closed) &&
         (*num_points < 4))
      {
       *msg = MSINARG;
       goto wrapup;
      }
    } /* ELSE FOR if (is_iso_data) */
  } /* ELSE FOR if (curve->order == 2) */
/*
 * Now we have the required model space data to be mapped
 * to the surface.  The mapping is done based on the type
 * of surface involved.
 */
 *uv_data = (BSpair *) malloc(*num_points * sizeof(BSpair));
  if (! (*uv_data))
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 if ((type == BSCCIRCLE) || 
     (type == BSCELLIPSE))
  {
   IGRboolean	is_circular;
   IGRlong	sts, EFget_uv_from_xyz_for_cylinders();

   if (surface->u_phy_closed || surface->v_phy_closed)    /* Patch - rlw */
    {
     is_circular = (type == BSCCIRCLE);
     sts = EFget_uv_from_xyz_for_cylinders(
       surface,
       is_circular,
       *num_points,
       *points,
       *uv_data,
       msg);
      if (! (1 & *msg)) goto wrapup;
    } /* if (surface->u_phy_closed || surface->v_phy_closed) */
   else
    type = BSCUNKNOWNTYPE;
  }
 if (type == BSCUNKNOWNTYPE)
  {
   IGRboolean	all_data_on_surface;
   IGRlong	loc_msg;

   BSprptsonsf(
     *num_points,
     *points,
     surface,
     *uv_data,
     &all_data_on_surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
/*
 * If the data is not on the surface then the caller
 * has given me bad data or the math is returning
 * garbage parameters.  In either case I cannot correct
 * the situation.
 */
   if (! all_data_on_surface)
    {
     *msg = MSINARG;
     goto wrapup;
    }
  }
 else if ((type != BSCCIRCLE) &&
          (type != BSCELLIPSE))
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Fix any data which is associated with
 * degenerate edges
 */
 {
  extern	void EFclassify_degenerate_edges();
  extern	void EFfix_uv_on_degenerate_edges();
  IGRboolean	is_degenerate[2][2];

  EFclassify_degenerate_edges(
    surface,
    is_degenerate,
    msg);
   if (! (1 & *msg)) goto wrapup;
  EFfix_uv_on_degenerate_edges(
    surface,
    par_tol,
    is_degenerate,
    num_points,
    uv_data,
    NULL,		/* Don't insert any points */
    msg);
   if (! (1 & *msg)) goto wrapup;
 }
/*
 * Snap the points to the natural boundaries.  Also fix
 * any jumps in the parametric space data.  Note that
 * only jumps at the starting and ending point are fixed.
 * This will remove all jumps so long as the input curve
 * does not cross a seam edge of the surface.
 */
 {
  IGRdouble	u_low, u_hig, v_low, v_hig;
  IGRshort	check_u, check_v;
  IGRlong	last_point, i, u_seam_count, v_seam_count;
  IGRdouble	dist_1, dist_2, *uv, *next;

  u_low = surface->u_knots[surface->u_order - 1];
  u_hig = surface->u_knots[surface->u_num_poles];
  v_low = surface->v_knots[surface->v_order - 1];
  v_hig = surface->v_knots[surface->v_num_poles];
  last_point = *num_points - 1;
  u_seam_count = 0;
  v_seam_count = 0;
  for (i = 0; i <= last_point; i++)
   {
    uv = &(*uv_data)[i][0];
    if ((uv[0] - u_low) < par_tol)
     {
      uv[0] = u_low;
      check_u = 1;
     }
    else if ((u_hig - uv[0]) < par_tol)
     {
      uv[0] = u_hig;
      check_u = 2;
     }
    else
     check_u = 0;
    if ((uv[1] - v_low) < par_tol)
     {
      uv[1] = v_low;
      check_v = 1;
     }
    else if ((v_hig - uv[1]) < par_tol)
     {
      uv[1] = v_hig;
      check_v = 2;
     }
    else
     check_v = 0;
   if (check_u &&
       surface->u_phy_closed)
    {
     u_seam_count++;
     if (i == 0)
      next = &(*uv_data)[1][0];
     else if (i == last_point)
      next = &(*uv_data)[last_point - 1][0];
     else
      next = NULL;
     if (next)
      {
       dist_1 = next[0] - u_low;
       dist_2 = u_hig - next[0];
       if (dist_1 > dist_2)
        {
         if (check_u == 1)
          uv[0] = u_hig;
        }
       else if (check_u == 2)
        uv[0] = u_low;
      } /* if (next) */
    } /* if (check_u && surface->u_phy_closed) */
   if (check_v &&
       surface->v_phy_closed)
    {
     v_seam_count++;
     if (i == 0)
      next = &(*uv_data)[1][0];
     else if (i == last_point)
      next = &(*uv_data)[last_point - 1][0];
     else
      next = NULL;
     if (next)
      {
       dist_1 = next[1] - v_low;
       dist_2 = v_hig - next[1];
       if (dist_1 > dist_2)
        {
         if (check_v == 1)
          uv[1] = v_hig;
        }
       else if (check_v == 2)
        uv[1] = v_low;
      } /* if (next) */
    } /* if (check_v && surface->v_phy_closed) */
   } /* for (i = 0; i <= last_point; i++) */
  if (u_seam_count == *num_points)
   {
    for (i = 0; i <= last_point; i++)
     {
      (*uv_data)[i][0] = u_low;
     } /* for (i = 0; i <= last_point; i++) */
   } /* if (u_seam_count == *num_points) */
  else if (v_seam_count == *num_points)
   {
    for (i = 0; i <= last_point; i++)
     {
      (*uv_data)[i][1] = v_low;
     } /* for (i = 0; i <= last_point; i++) */
   } /* else if (v_seam_count == *num_points) */
 }
/*
 * If the curve is iso check if the uv data is really iso.
 * -- SM 05-Sep-89.
 *
 * If the curve is an iso edge then ensure that the
 * parameters are exactly equal.
 */
 if (is_iso_data)
  {
   IGRboolean	u_iso_curve;
   IGRlong	last_point, i;
   IGRdouble	u, v, delta_u, delta_v, junk[4];
   extern IGRboolean EMis_iso_edge();

   if(!EMis_iso_edge(*num_points, *uv_data, par_tol, junk))
    {
#if DEBUG
     fprintf(stderr, "\nIncorrect isoness detected in EFspecmap\n");
     fprintf(stderr, "\ntolerance is %lg\n", par_tol);
     for (i = 0; i < *num_points; i++)
      {
       fprintf(stderr, "\nPoint[%d] = %lf %lf",
        i, (*uv_data)[i][0], (*uv_data)[i][1]);
      }
     fprintf(stderr, "\n\n");
#endif
     *msg = EMS_E_InvalidArg;
     goto wrapup;
    }

   last_point = *num_points - 1;
   delta_u = fabs((*uv_data)[0][0] - (*uv_data)[last_point][0]);
   delta_v = fabs((*uv_data)[0][1] - (*uv_data)[last_point][1]);
   if (delta_u < delta_v)
    {
     u = (*uv_data)[0][0];
     u_iso_curve = TRUE;
    }
   else
    {
     v = (*uv_data)[0][1];
     u_iso_curve = FALSE;
    }
   for (i = 0; i < *num_points; i++)
    {
     if (u_iso_curve)
      (*uv_data)[i][0] = u;
     else
      (*uv_data)[i][1] = v;
    } /* for (i = 0; i < *num_points; i++) */
/*
 * If we have no correlation data then generate it
 */
   if (! *correlation)
    {
     IGRlong	loc_msg, i;
     IGRdouble	x0, y0, x1, y1, t;

     x0 = (*uv_data)[0][0];
     y0 = (*uv_data)[0][1];
     x1 = (*uv_data)[last_point][0];
     y1 = (*uv_data)[last_point][1];
     free(*uv_data); *uv_data = NULL;
     free(*points);  *points = NULL;
     BSchtptstcv(
       curve,
       (IGRint *)num_points,
       points,
       correlation,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     *uv_data = (BSpair *) malloc(*num_points * sizeof(BSpair));
      if (! (*uv_data))
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     for (i = 0; i < *num_points; i++)
      {
       t = (*correlation)[i];
       (*uv_data)[i][0] = x0 + (x1 - x0) * t;
       (*uv_data)[i][1] = y0 + (y1 - y0) * t;
#if DEBUG
       {
        IGRboolean	distinct;
        IGRlong		loc_msg;
        IGRpoint	point;

        BSsfeval(
          surface,
          (*uv_data)[i][0],
          (*uv_data)[i][1],
          0,
          point,
          &loc_msg);
         if (loc_msg != BSSUCC)
          {
           fprintf(stderr, "\nBSsfeval error %d in CORRELATION", loc_msg);
           *msg = MSFAIL;
           goto wrapup;
          }
        distinct = BSdistnct2(
         &loc_msg,
         point,
         (*points)[i]);
        if (distinct)
         {
          IGRdouble	x, y, z;

          fprintf(stderr, "\nCORRELATION mapping is INVALID on pnt %d", i);
          x = point[0] - (*points)[i][0];
          y = point[1] - (*points)[i][1];
          z = point[2] - (*points)[i][2];
          fprintf(stderr, "\nDistance is %.15f",
           sqrt(x * x + y * y + z * z));
         }
       }
#endif
      } /* for (i = 0; i < *num_points; i++) */
    } /* if (! *correlation) */
  } /* if (is_iso_data) */
/*
 * eof
 */
wrapup:

 if (! (1 & *msg))
  {
   *num_points = 0;
   if (*points) free(*points);
   if (*uv_data) free(*uv_data);
   if (*correlation) free(*correlation);
   *points = NULL;
   *uv_data = NULL;
   *correlation = NULL;
   return(FALSE);
  }
 else
  return(TRUE);
}
/*
 Description

 This routine generates uv data from xyz data for surfaces of projection
 when the swept element is a circle, circular arc, ellipse or elliptical
 arc.  The surface may be swept with uniform scaling, i.e. cones are
 supported.

 Arguments

 input_surface		The surface on which the uv data is to be found.
 is_circular		Is the basic section circular?
 number_of_points	Number of points to be mapped.
 points			Points to be mapped.
 uv_points		Resulting parametric data.
 msg			Error return code.

 History

 11/03/88 : rlw : Creation date
 01/23/89 : rlw : v coordinates were computed wrong when circles were
                  flipped to get larger circle
 */

static IGRlong EFget_uv_from_xyz_for_cylinders(
 input_surface,
 is_circular,
 number_of_points,
 points,
 uv_points,
 msg)

struct		IGRbsp_surface *input_surface;
IGRboolean	is_circular;
IGRlong		number_of_points;
IGRpoint	points[];
BSpair		uv_points[];
IGRlong		*msg;
{
 IGRboolean	flip_surface;
 IGRpoint	axis[2];
 struct		IGRarc igr_arc;
 struct		IGRbsp_surface *surface;
/*
 * Initialize
 */
 *msg = MSSUCC;;
 surface = NULL;
/*
 * Determine if the surface needs to be flipped
 */
 if (input_surface->u_order == 2)
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   BSallocsf(			/* Note that u and v must be swapped */
     input_surface->v_order,
     input_surface->u_order,
     input_surface->v_num_poles,
     input_surface->u_num_poles,
     input_surface->rational,
     0,				/* No boundaries */
     &surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   flip_surface = TRUE;
   status = BSexch_u_v(
     &loc_msg,
     input_surface,
     surface);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* if (surface->u_order == 2) */
 else
  {
   flip_surface = FALSE;
   surface = input_surface;
  }
/*
 * Convert away to parametric space
 */
 {
  IGRboolean	status, EFbspcurve_to_igrarc();
  IGRdouble	size_1, size_2;
  struct	IGRbsp_curve arc;
  struct	IGRarc temp_igr_arc;

  arc.order = surface->u_order;
  arc.periodic = surface->u_periodic;
  arc.non_uniform = surface->u_non_uniform;
  arc.num_poles = surface->u_num_poles;
  arc.poles = surface->poles;
  arc.num_knots = surface->u_num_knots;
  arc.knots = surface->u_knots;
  arc.rational = surface->rational;
  arc.weights = surface->weights;
  arc.planar = 1;
  arc.phy_closed = surface->u_phy_closed;
  arc.num_boundaries = 0;
  arc.bdrys = NULL;
  status = EFbspcurve_to_igrarc(
    &arc, 
    &igr_arc, 
    msg);
   if (! (1 & *msg)) goto wrapup;
  arc.poles = &surface->poles[surface->u_num_poles * 3];
  arc.weights = &surface->weights[surface->u_num_poles];
  status = EFbspcurve_to_igrarc(
    &arc, 
    &temp_igr_arc, 
    msg);
   if (! (1 & *msg)) goto wrapup;
/*
 * Save the axis to pass to the mapper
 */
  axis[0][0] = igr_arc.origin[0];
  axis[0][1] = igr_arc.origin[1];
  axis[0][2] = igr_arc.origin[2];
  axis[1][0] = temp_igr_arc.origin[0];
  axis[1][1] = temp_igr_arc.origin[1];
  axis[1][2] = temp_igr_arc.origin[2];
/*
 * Try and use the largest arc
 */
  if (igr_arc.prim_axis > igr_arc.sec_axis)
   size_1 = igr_arc.prim_axis;
  else
   size_1 = igr_arc.sec_axis;
  if (temp_igr_arc.prim_axis > temp_igr_arc.sec_axis)
   size_2 = temp_igr_arc.prim_axis;
  else
   size_2 = temp_igr_arc.sec_axis;
  if (size_2 > size_1)
   igr_arc = temp_igr_arc;
/*
 * If it is supposed to be a circle then
 * force the issue
 */
  if (is_circular)
   {
    igr_arc.prim_axis += igr_arc.sec_axis;
    igr_arc.prim_axis /= 2.0;
    igr_arc.sec_axis = igr_arc.prim_axis;
   } /* if (is_circular) */
 }
/*
 * Convert to parametric space
 */
 {
  IGRlong	sts, EMmap_xyz_to_uv_for_cylinder();

  sts = EMmap_xyz_to_uv_for_cylinder(
    &igr_arc,
    axis,
    number_of_points,
    points,
    uv_points,
    msg);
   if (!sts) goto wrapup;
  if (flip_surface)		/* Flip u and v parameters */
   {
    IGRlong	i;
    IGRdouble	temp;

    for (i = 0; i < number_of_points; i++)
     {
      temp = uv_points[i][0];
      uv_points[i][0] = uv_points[i][1];
      uv_points[i][1] = temp;
     } /* for (i = 0; i < number_of_points; i++) */
   } /* if (flip_surface) */
 }
/*
 * eof
 */
wrapup:
 if (flip_surface)
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(
    &loc_msg,
    surface);
  } /* if (flipped_surface) */
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}
/* 
 Description

 This routine generates the uv data for a surface which is
 produced by sweeping a conic along a line.

 Arguments

 arc			The conic which was swept
 axis			Axis used in the sweep
 number_of_points	Number of points to be mapped.
 xyz_points		Points to be mapped.
 uv_points		Resulting parametric space data.
 msg			Error return code.

 History

 11/03/88 : rlw : Creation date
 01/23/89 : rlw : Modified to pass axis in
 11/16/89 : rlw : Modified to call BSangarctou() instead of MAangarctou()
                  as per Dieter Breden.
 02/11/90 : SS  : Added angle-tolerancing in map_xyz_uv_cyl function, when
                  obtaining the 'u' parameter.
 02/20/90 : SS  : If any of the math calls fail, return MSINARG which
                  would should kick off the general B-spline algorithm in 
                  the calling routine.
 */

static IGRlong EMmap_xyz_to_uv_for_cylinder(
 arc,
 axis,
 number_of_points,
 xyz_points,
 uv_points,
 msg)

struct		IGRarc *arc;		/* The base circle or ellipse */
IGRpoint	axis[2];		/* Axis of projection */
IGRlong		number_of_points;	/* Number of points to be mapped */
IGRpoint	xyz_points[];		/* Model space data */
BSpair		uv_points[];		/* Preallocated parametric data */ 
IGRlong		*msg;			/* Error return code */

{
 IGRboolean	status;
 IGRlong	rc, i;
 IGRdouble	theta, u, len_tol, theta_tol, divisor, quotient;
 IGRpoint	projected_point;
 struct		IGRline_seg line_segment;

/*
 * Obtain the angle-tolerance based on a circle with radius equal to the
 * average of the primary and secondary axis:
 *
 *   theta_tol = 2*PI (len_tol / avgcirlen);
 * where, 
 *   avgcirlen = 2*PI*avgrad;
 * where
 *   avgrad = (prim_axis + sec_axis) / 2;
 *
 * Therefore,
 *   theta_tol = 2 * (len_tol / (prim_axis + sec_axis));
 */
 divisor = arc->prim_axis + arc->sec_axis;
 if (divisor > MINDOUBLE)
   {
   BSEXTRACTPAR (&rc, BSTOLLENVEC, len_tol);
   quotient = len_tol / divisor;
   theta_tol = quotient + quotient;
   }
 else
   theta_tol = 0.0;

/*
 * Get the u value for each xyz point
 */
 for (i = 0; i < number_of_points; i++)
  {
   status = MAptwcangel(
     msg,
     xyz_points[i],
     (struct IGRellipse *)arc,
     &theta);
    if (! (status && (1 & *msg))) 
     {
      *msg = MSINARG;
      return(FALSE);
     }

   theta -= arc->start_angle;
   if (fabs (theta) < theta_tol)
     theta = 0.0;
   else if (fabs (theta - arc->sweep_angle) < theta_tol)
     theta = arc->sweep_angle;

   BSangarctou(
     arc->sweep_angle,
     theta,
     &u,
     &rc);
    if (rc != BSSUCC)
     {
      *msg = MSINARG;
      return(FALSE);
     }
   if (u < 0.0)
    u = 0.0;
   else if (u > 1.0)
    u = 1.0;
   uv_points[i][0] = u;
  } /* for (i = 0; i < number_of_points; i++) */
/*
 * Generate a linesegment representing one of the v iso curves
 */
 line_segment.beg_point = (IGRdouble *) &axis[0][0];
 line_segment.end_point = (IGRdouble *) &axis[1][0];
/*
 * Get the v value for each xyz point
 */
 for (i = 0; i < number_of_points; i++)
  {
   status = MAptlsproj(
     msg,
     xyz_points[i],
     &line_segment,
     projected_point,
     &uv_points[i][1]);
    if (! (status && (1 & *msg)))
     {
      *msg = MSINARG;
      return(FALSE);
     }
  } /* for (i = 0; i < number_of_points; i++) */
/*
 * End of routine
 */
wrapup:
 return(TRUE);
}
/*
 Description

 Given a bspline curve which represents a circle, ellipse, circular arc,
 or elliptical arc, this function returns the IGRarc definition of this
 element.

 Arguments

 curve		A bspline curve which is known to be a circle, ellipse,
                elliptical arc, or circular arc.
 arc		The resulting arc.
 msg		Error return code.  Note that if the code is MAIDGENRAT
                then the circle/ellipse is degenerate (a point).
 Notes

 This functionality is already present in the MAbctoel() function.  I
 have written this routine because the MA functions sometimes shift
 the results by 90 degrees because they always define the major axis
 as the largest axis.  Much of this logic was gleaned from MA routines
 and some from BS routines.

 History

 11/03/88 : rlw : Creation date
 */

static IGRboolean EFbspcurve_to_igrarc(
 curve,
 arc,
 msg)

struct	IGRbsp_curve *curve;
struct	IGRarc *arc;
IGRlong	*msg;

{
 IGRpoint	unweighted_poles[BSCIRCLE_NUM_POLES_MAX];
 IGRpoint	prim_point;
 IGRvector	z_vector;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Reasonable input?
 */
 if ((curve->num_poles < 3) ||
     (curve->num_poles > BSCIRCLE_NUM_POLES_MAX) ||
     (! curve->rational))
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Get the conic properties
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg; 
  IGRint	conic_type, planar_code;
  IGRpoint	f1, f2, v[4];

  arc->start_angle = 0.0;
  arc->sweep_angle = M_PI * 2;
  status = MAidmx(
   msg,
   arc->rot_matrix);
  status = BSunwght_p(
    &loc_msg,
    curve->poles,
    curve->weights,
    &curve->num_poles,
    (IGRdouble *)unweighted_poles);
   if (loc_msg != BSSUCC) goto bs_fail;
  BSptlnplan(
    curve->num_poles,
    FALSE,			/* Not rational */
    unweighted_poles,
    NULL,			/* No weights */
    &planar_code,		/* 1 point, 2 line, 3 plane, 4 non-planar */
    z_vector,
    &loc_msg);
   if (loc_msg != BSSUCC) goto bs_fail;
  if ((planar_code == 4) ||
      (planar_code == 2))
   {
    *msg = MSINARG;
    goto wrapup;
   }
  else if (planar_code == 1)
   {
    arc->origin[0] = unweighted_poles[0][0];
    arc->origin[1] = unweighted_poles[0][1];
    arc->origin[2] = unweighted_poles[0][2];
    arc->prim_axis = 0.0;
    arc->sec_axis  = 0.0;
    *msg = MAIDGENRAT;
    goto wrapup;
   }
  status = BScncprop(
    &loc_msg,
    z_vector,
    unweighted_poles[0],
    unweighted_poles[1],
    unweighted_poles[2],
    &curve->weights[0],
    &curve->weights[1],
    &curve->weights[2],
    &conic_type,
    arc->origin,
    &arc->prim_axis, &arc->sec_axis, /* major axis length, minor axis length */
    f1, f2,                          /* focii */
    v[0], v[1],                      /* Vertex on major axis, other vertex */
    v[2], v[3]);                     /* Vertex on minor axis, other vertex */
   if (loc_msg != BSSUCC) goto bs_fail;
  if (conic_type == BSCCIRCLE)
   {
    arc->sec_axis = arc->prim_axis;
    prim_point[0] = unweighted_poles[0][0];
    prim_point[1] = unweighted_poles[0][1];
    prim_point[2] = unweighted_poles[0][2];
   }
  else if (conic_type == BSCELLIPSE)
   {
    IGRlong	loc_msg, indx, i, j;
    IGRdouble	distance, tmp, minimum_distance;
    IGRpoint	*point;

    minimum_distance = MAXFLOAT;
    for (j = 0; j < 2; j++)
     {
      if (j == 0)
       point = (IGRpoint *)(unweighted_poles[0]);
      else
       point = (IGRpoint *)(unweighted_poles[curve->num_poles - 1]);
      for (i = 0; i < 4; i++)
       {
        distance = BSdistptpts(
         &loc_msg,
         point[0],
         v[i]);
        if (distance < minimum_distance)
         {
          indx = i;
          minimum_distance = distance;
         }
       } /* for (i = 0; i < 4; i++) */
     } /* for (j = 0; j < 2; j++) */
    prim_point[0] = v[indx][0];
    prim_point[1] = v[indx][1];
    prim_point[2] = v[indx][2];
    if (indx > 1)
     {
      tmp = arc->prim_axis;
      arc->prim_axis = arc->sec_axis;
      arc->sec_axis = tmp;
     }
   }
  else
   {
    *msg = MSINARG;
    goto wrapup;
   }
 }
/*
 * At this point we know the following:
 *
 * 1) The element is an circle, ellipse, elliptical arc, circular arc
 * 2) The length of the major and minor axis
 * 3) The origin
 * 4) A point on the element which will define the local x axis (prim_point)
 * 5) The normal vector to the plane
 */
/*
 * Cross the x axis vector with the normal to the plane to produce a
 * local y axis.  Using these 3 points form a matrix which will convert
 * the curve such that it is 2 dimensional.  After this conversion determine
 * whether the curve flows cw or ccw.  If the curve flows cw then choose
 * the other y axis as we want a positive sweep angle.
 */
 {
  IGRboolean	status, right_hand_system;
  IGRlong	loc_msg, i, iterate;
  IGRdouble	bs_matrix[3][3], x1, x2, y1, y2, area;
  IGRpoint	y_point, flat_poles[BSCIRCLE_NUM_POLES_MAX + 1];
  IGRvector	x_vector, y_vector;

  right_hand_system = TRUE;
  x_vector[0] = prim_point[0] - arc->origin[0];
  x_vector[1] = prim_point[1] - arc->origin[1];
  x_vector[2] = prim_point[2] - arc->origin[2];
  status = BScrossp(		/* Z cross X */
   &loc_msg,
   z_vector,
   x_vector,
   y_vector);
  status = BSnorvec(
    &loc_msg,
    y_vector);
   if (loc_msg != BSSUCC) goto bs_fail;
  y_point[0] = arc->origin[0] + y_vector[0];   
  y_point[1] = arc->origin[1] + y_vector[1];   
  y_point[2] = arc->origin[2] + y_vector[2];   
  status = BSlocalcord(
    &loc_msg,
    arc->origin,
    prim_point,
    y_point,
    &right_hand_system,
    bs_matrix);
   if (loc_msg != BSSUCC) goto bs_fail;
  BSptsoldtnw(
    arc->origin,
    bs_matrix,
    1.0,		/* Unity scaling */
    curve->num_poles,
    FALSE,		/* Not rational */
    unweighted_poles,
    NULL,		/* No weights */
    flat_poles,
    &loc_msg);
   if (loc_msg != BSSUCC) goto bs_fail;
  if (curve->phy_closed)
   iterate = curve->num_poles - 1;
  else
   {
    iterate = curve->num_poles;
    flat_poles[iterate][0] = flat_poles[0][0];
    flat_poles[iterate][1] = flat_poles[0][1];
    flat_poles[iterate][2] = flat_poles[0][2];
   }
  area = 0;
  for (i = 0; i < iterate; i++)
   {
    x1 = flat_poles[i][0];
    x2 = flat_poles[i + 1][0];
    y1 = flat_poles[i][1];
    y2 = flat_poles[i + 1][1];
    area += (y2 - y1) * (x1 + x2);	/* Actually area = .5 * area */
   } /* for (i = 0; i < iterate; i++) */
  if (area < 0.0)  /* Clock wise */
   {
    y_point[0] = arc->origin[0] - y_vector[0];
    y_point[1] = arc->origin[1] - y_vector[1];
    y_point[2] = arc->origin[2] - y_vector[2];
    status = BSlocalcord(
      &loc_msg,
      arc->origin,
      prim_point,
      y_point,
      &right_hand_system,
      bs_matrix);
     if (loc_msg != BSSUCC) goto bs_fail;
   } /* if (area < 0.0) */
  arc->rot_matrix[0]  = bs_matrix[0][0]; /* Arc matrix is global to local */
  arc->rot_matrix[1]  = bs_matrix[1][0];
  arc->rot_matrix[2]  = bs_matrix[2][0];
  arc->rot_matrix[4]  = bs_matrix[0][1];
  arc->rot_matrix[5]  = bs_matrix[1][1];
  arc->rot_matrix[6]  = bs_matrix[2][1];
  arc->rot_matrix[8]  = bs_matrix[0][2];
  arc->rot_matrix[9]  = bs_matrix[1][2];
  arc->rot_matrix[10] = bs_matrix[2][2];
 }
/*
 * Compute the proper start and sweep angles
 */
 if (! curve->phy_closed)
  {
   IGRboolean	status;

   status = MAptwcangel(
     msg,
     unweighted_poles[0],
     (struct IGRellipse *)arc,
     &arc->start_angle);
    if (! (1 & *msg)) goto wrapup;
   status = MAptwcangel(
     msg,
     unweighted_poles[curve->num_poles - 1],
     (struct IGRellipse *)arc,
     &arc->sweep_angle);
    if (! (1 & *msg)) goto wrapup;
   if (arc->sweep_angle < arc->start_angle)
    arc->sweep_angle += 2 * M_PI - arc->start_angle;
   else if (arc->sweep_angle != 0.0)
    arc->sweep_angle -= arc->start_angle;
  } /* if (! curve->phy_closed) */
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
bs_fail:
 *msg = MSFAIL;
 return(FALSE);
}
