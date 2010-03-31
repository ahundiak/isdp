/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/* 
DESCRIPTION

   This routine returns the index of the side closest to the input
   parametric point.  It also returns the (u,v) if the input point
   were moved to this side and the (u,v) point if the input point were
   moved to the opposite side. Sides are numbered as follows:

   1) u = u_low
   2) u = u_high
   3) v = v_low
   4) v = v_high

RETURN VALUES

   status		TRUE if the point is within par_tol of closes_side,
			else FALSE
   closest_side         The closest side [1,4]
   side_u, side_v	The (u,v) coordinate of the input point if it were
			moved to the closest side.
   matching_side_u, 	The (u,v) coordinate of the input point if it were
   matching_side_v	moved to the side opposite the closest side.

NOTES

   The input point must be within the limits, i.e. u_low, u_high,
   v_low, and v_high.

HISTORY

   04/12/87 : rlw : creation date
   04/24/87 : rlw : Modified calling sequence such that additional information
                    is returned, i.e. (side_u, side_v, matching_side_u,
                    matching_side_v)
*/

#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
/* include "igr.h"*/

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

IGRboolean EFfind_closest_uv_side(
  u_low,
  u_high,
  v_low,
  v_high,
  u, 
  v,
  par_tol,
  closest_side,
  side_u,
  side_v,
  matching_side_u, 
  matching_side_v)

IGRdouble	u_low;		/* u_knots[u_order - 1] */
IGRdouble	u_high;		/* u_knots[u_num_poles] */
IGRdouble	v_low;		/* v_knots[v_order - 1] */
IGRdouble	v_high;		/* v_knots[v_num_poles] */
IGRdouble	u;		/* u coordinate */
IGRdouble	v;		/* v coordinate */
IGRdouble	par_tol;	/* Parametric tolerance */
IGRlong		*closest_side;	/* The closest side */
IGRdouble	*side_u;	/* u coordinate if on the closest side */
IGRdouble	*side_v;	/* v coordinate if on the closest side */
IGRdouble	*matching_side_u;/* u coordinate if on opposite side */
IGRdouble	*matching_side_v;/* v coordinate if on opposite side */

{
 IGRlong	i;
 IGRdouble	distance, distance_to_side[4];
/*
 * Compute distances
 */
 distance_to_side[0] = u - u_low;
 distance_to_side[1] = u_high - u;
 distance_to_side[2] = v - v_low;
 distance_to_side[3] = v_high - v;
#if DEBUG
fprintf(stderr, "\nInside find closest side");
fprintf(stderr, "\nu is %lf, v is %lf", u, v);
fprintf(stderr, "\nDistance to side 1 is %lf", distance_to_side[0]);
fprintf(stderr, "\nDistance to side 2 is %lf", distance_to_side[1]);
fprintf(stderr, "\nDistance to side 3 is %lf", distance_to_side[2]);
fprintf(stderr, "\nDistance to side 4 is %lf", distance_to_side[3]);
#endif
/*
 * Find the closest side
 */
 *closest_side = 0;
 distance = distance_to_side[0];
 for (i = 1; i < 4; i++)
  {
   if (distance_to_side[i] < distance)
    {
     *closest_side = i;
     distance = distance_to_side[i];
    }
  } /* for (i = 1; i < 4; i++) */
 (*closest_side)++;
#if DEBUG
fprintf(stderr, "\nClosest side found was %d", *closest_side);
fprintf(stderr, "\nside u pointer %x side v pointer %x", side_u, side_v);
fprintf(stderr, "\nmatch side u pointer %x match side v pointer %x", 
        matching_side_u, matching_side_v);
#endif
/*
 * Find the parameter value of the point if it were on a side
 * and the matching parameter value if on the opposite side
 */
 switch (*closest_side)
  {
   case 1:
    if (side_u) *side_u = u_low;
    if (side_v) *side_v = v;
    if (matching_side_u) *matching_side_u = u_high;
    if (matching_side_v) *matching_side_v = v;
    break;
   case 2:
    if (side_u) *side_u = u_high;
    if (side_v) *side_v = v;
    if (matching_side_u) *matching_side_u = u_low;
    if (matching_side_v) *matching_side_v = v;
    break;
   case 3:
    if (side_u) *side_u = u;
    if (side_v) *side_v = v_low;
    if (matching_side_u) *matching_side_u = u;
    if (matching_side_v) *matching_side_v = v_high;
    break;
   case 4:
    if (side_u) *side_u = u;
    if (side_v) *side_v = v_high;
    if (matching_side_u) *matching_side_u = u;
    if (matching_side_v) *matching_side_v = v_low;
    break;
   default:
    break;
  } /* switch (*closest_side) */
#if DEBUG
if (side_u && side_v)
 fprintf(stderr, "\nside_u %lf, side_v %lf", *side_u, *side_v);
if (matching_side_u && matching_side_v)
 fprintf(stderr, "\nmatch_u %lf, match_v %lf", 
  *matching_side_u, *matching_side_v);
fprintf(stderr, "\nExit closest side\n\n");
#endif
/*
 * Eof
 */
 if (distance < par_tol)
  return(TRUE);
 else
  return(FALSE);
}
