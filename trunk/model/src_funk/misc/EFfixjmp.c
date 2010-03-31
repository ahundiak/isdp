/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

#include "EMS.h"

/* 
DESCRIPTION
  
   This routine removes any jumps across parametric space  which do not
   have corresponding jumps in model space from the parametric data of
   surface 1, i.e. uv1_group.
  
ASSUMPTIONS
  
   It is assumed that all the uv points are valid, i.e. are within the
   parametric range of the surface.
  
RETURN VALUES
  
   status		TRUE if success, FALSE if failure
   number_of_groups	resulting number of groups
   points_per_group	resulting number of points per group
   xyz_group		resulting model space points
   uv1_group		resulting uv points in parametric space 1
   uv2_group		resulting uv points in parametric space 2
   msg			MSSUCC - success
  			MANOMEMORY - no dynamic memory available
   			MSFAIL - implies that BSsfeval() has failed or
  			that EFsegment_breaker() has failed
  
NOTES
  
   This routine may create groups that have single points.  These points
   should be ignored.

   This routine assumes that all the parametric points are within the
   ranges dictated by the knot vectors.  It also assumes that the surface
   has reasonable parameterization, i.e. stepping equally in parametric
   space roughly corresponds to stepping equally in model space.
  
HISTORY
  
   01/05/87 : rlw : creation date
   01/13/87 : rlw : changed the algorithm to work with surf/surf int. output
   01/14/87 : rlw : redid break logic
   02/04/87 : rlw : modify argument list to pass in dist_sqtol
   02/06/87 : rlw : modified to check all segments as opposed to just
                    interior ones
   02/21/87 : rlw : modified to check for backward jumps as well as forward
                    jumps.  (It only checked forward jumps before).
   04/12/87 : rlw : Added additional jump checks to catch jumps not
                    originating within tolerance of a natural edge.
   04/22/87 : rlw : Fixed two bugs which caused breaks to occur where there
                    were no jumps.
   04/24/87 : rlw : Modified such that the point in the second parametric 
                    space (uv2) is also adjusted when a jump occurs.  This
                    was causing Siki problems since it did not correspond
                    to the model space point.  This change required an
                    additional argument in the calling sequence.  I also
                    changed the way the tolerances are input as they are
                    now all passed in as arguments, and fixed a bug in the
                    jump to an edge logic.
   04/27/87 : rlw : Modified the code to be a little bit smarter about
                    finding jumps.  It had problems when a point was closer
                    to a side other than the jump side.  I hope this finally
                    fixes this routine.
   06/19/87 : rlw : Fixed bug Siki found where the matching parameters
                    produced were out of the range of the knot vector
   10/03/89 : rlw : Modified, per Sunit's request, to trust the physically
                    closed bits in the surface structure, i.e. don't check
                    model space points if the surface says it is closed.
   02/07/90 : sm  : Fixed a bug in the above modification which caused 
		    'point' and 'matching_point' to remain unevaluated but
		    used later to change the data.
   07/09/93 : Sudha Modified for BSprototypes anisfication

ALGORITHM
  
   Jumps generally occur when intersecting two closed surfaces.  The first
   surfaces intersection generally begins and ends on a natural edge.  The
   second surfaces intersection will usually cross the seam.  The parametric
   data in this case looks like:

   a) Forward jump, i.e. jump from a natural edge
        ...
      .98, .46
      1.0, .5		!Natural  edge
      .01, .52		!Jumped to other side
      .03, .55
        ...
      Fixed data should be:
        ...
      .98, .46
      1.0, .5		!Natural edge
      Break the data here
      0.0, .5		!Natural edge
      .01, .52
      .03, .55
        ...
   b) Backwards jump, i.e. jump to a natural edge
        ...
      .03, .55
      .01, .52		!Not a natural edge
      1.0, .5		!Natural edge and jump occured
      .98, .46
        ...
      Fixed data should be:
        ...
      .03, .55
      .01, .52
      1.0, .5		!Natural edge
      Break the data here
      0.0, .5		!Natural edge
      .98, .46
        ...
   A third kind of jump occurs when imposing boundaries.  What happens
   is that a jump occurs but neither point is on a natural edge.  For 
   example:

      ...
   .960, .670
   .970, .680		!Not a natural edge
   .006, .670		!Not a natural edge and jump occured
   .010, .672
      ...
   Fixed data should be:
      ...
   .960, .670
   .970, .680
   1.00, .675		!Natural edge (Note that v coord. was averaged)
   Break the data here
   0.00, .675		!Natural edge
   .006, .670
   .010, .672
      ...
 */

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#ifndef DEBUG
#define DEBUG 0
#endif

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

#include "bs.h"
#include "emsbreak.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"

enum EMjump_type
 {
  EMjump_none,
  EMjump_from_an_edge,
  EMjump_to_an_edge,
  EMjump_no_edges
 };

static void		EFfind_jump_side_if_any();

IGRboolean EFfix_jumps(
            surface_1,			/* Surface data - primary */
            surface_2,			/* Surface data - secondary */
            par_tol_1,			/* Parameteric tolerance - srf 1 */
            par_tol_2,			/* Parameteric tolerance - srf 2 */
            dist_sqtol,			/* Model space tolerance squared */
            number_of_groups,		/* Number of sets of data */
            points_per_group,		/* Number of points in each set */
            xyz_group,			/* Sets for model space */
            uv1_group,			/* Sets for parametric space srf 1 */
            uv2_group,			/* Sets for parametric space srf 2 */
            msg)			/* Error return code */

struct		IGRbsp_surface *surface_1;
struct		IGRbsp_surface *surface_2;
IGRdouble	par_tol_1;
IGRdouble	par_tol_2;
IGRdouble	dist_sqtol;
IGRlong		*number_of_groups;
IGRlong		**points_per_group;
IGRpoint	***xyz_group;
BSpair		***uv1_group;
BSpair		***uv2_group;
IGRlong		*msg;

{
 IGRboolean	status, EFsegment_breaker();
 IGRlong	i, j, k, msg_loc;
 IGRdouble	u_low, u_hig, v_low, v_hig;
 IGRdouble	u, v, next_u, next_v, matching_u, matching_v;
 IGRdouble	u_new, v_new, u_middle, v_middle;
 IGRdouble	delta_x, delta_y, delta_z, distance_squared;
 IGRpoint	point, matching_point;
 struct		EMsegment_breaker breaks[2];
 enum		EMjump_type jump_type;
/*
 * Initialize
 */
 *msg = MSSUCC;
#if DEBUG
fprintf(stderr, "\nInside fix the jumps");
fprintf(stderr, "\nModel space tolerance squared is %lf", dist_sqtol);
fprintf(stderr, "\nParametric space tolerance is %lf", par_tol_1);
#endif
/*
 * Determine the parametric values of the edges of the surface
 */
 u_low = surface_1->u_knots[surface_1->u_order - 1];
 u_hig = surface_1->u_knots[surface_1->u_num_poles];
 v_low = surface_1->v_knots[surface_1->v_order - 1];
 v_hig = surface_1->v_knots[surface_1->v_num_poles];
/*
 * Determine the middle of parametric space
 */
 u_middle = (u_hig - u_low) / 2.0;
 v_middle = (v_hig - v_low) / 2.0;
/*
 * Enter a loop to process all pairs of points
 */
 for (i = 0; i < *number_of_groups; i++)
  {
/*
 * Skip this loop if there are less than three points
 */
#if DEBUG
fprintf(stderr, "\nProcessing group %d", i);
#endif
   if ((*points_per_group)[i] < 3) continue;
/*
 * Initialize
 */
   u = 0.0;				/* Random junk */
   v = 0.0;				/* Random junk */
   next_u = (*uv1_group)[i][0][0];
   next_v = (*uv1_group)[i][0][1];
/*
 * Check all line segments
 */
   for (j = 0; j < ((*points_per_group)[i] - 1); j++)
    {
/*
 * Get the current point and the next point
 */
     u = next_u;
     v = next_v;
     k = j + 1;
     next_u = (*uv1_group)[i][k][0];
     next_v = (*uv1_group)[i][k][1];
/*
 * Determine if this point is on an edge and if the next point is
 * closer to this edge or the opposite edge.  The midknot stuff is
 * an effort to work around bad surface parameterization.
 */
     EFfind_jump_side_if_any(
      par_tol_1,
      u, v,
      next_u, next_v,
      u_low, u_hig, v_low, v_hig,
      u_middle, v_middle,
      &jump_type,
      &u_new, &v_new,
      &matching_u, &matching_v);
/*
 * If a jump not envolving an edge came up then investigate further.
 * We want to know if it is closer to close across parametric space
 * or around parametric space.  (Confusing a'int it)
 */
     if (jump_type == EMjump_no_edges) /* Only forward jumps are checked */
      {
       extern		IGRdouble sqrt();
       IGRdouble	outside_dist, inside_dist;

       outside_dist = sqrt((u - u_new) * (u - u_new) +
                           (v - v_new) * (v - v_new)) +
                      sqrt((next_u - matching_u) * (next_u - matching_u) +
                           (next_v - matching_v) * (next_v - matching_v));
       inside_dist = sqrt((u - next_u) * (u - next_u) +
                          (v - next_v) * (v - next_v));
#if DEBUG
fprintf(stderr, "\nInside distance %lf, Outside distance %lf",
        inside_dist, outside_dist);
#endif
       if ((2.0 * outside_dist) > inside_dist)
        jump_type = EMjump_none;
      } /* if (jump_type == EMjump_no_edges) */
/*
 * Finally, let's check to see if the parametric space jump has a
 * corresponding model space jump.
 */
     if (jump_type != EMjump_none)
      {
#if DEBUG
fprintf(stderr, "\nChecking model space jump at point %d", j);
#endif
       BSsfeval(surface_1, 
                matching_u,
                matching_v,
                0, 
                (IGRpoint *)matching_point, 
                &msg_loc);
       if (msg_loc != BSSUCC)
        {
         *msg = MSFAIL;
         return(FALSE);
        }
       BSsfeval(surface_1, 
                u_new,
                v_new,
                0, 
                (IGRpoint *)point, 
                &msg_loc);
       if (msg_loc != BSSUCC)
        {
         *msg = MSFAIL;
         return(FALSE);
        }

       if (surface_1->u_phy_closed &&
           (v_new == matching_v))
        {}
       else if (surface_1->v_phy_closed &&
           (u_new == matching_u))
        {}
       else
        {
         delta_x = matching_point[0] - point[0];
         delta_x *= delta_x;
         delta_y = matching_point[1] - point[1];
         delta_y *= delta_y;
         delta_z = matching_point[2] - point[2];
         delta_z *= delta_z;
         distance_squared = delta_x + delta_y + delta_z;
         jump_type = (distance_squared > dist_sqtol) ? EMjump_none : jump_type;
#if DEBUG
fprintf(stderr, "\nModel space check distance squared is %lf",
        distance_squared);
fprintf(stderr, "\nPoint is %lf %lf %lf", point[0], point[1], point[2]);
fprintf(stderr, "\nParameter is %lf %lf", u_new, v_new);
fprintf(stderr, "\nMatching %lf %lf %lf", matching_point[0], matching_point[1],
        matching_point[2]);
fprintf(stderr, "\nParameter is %lf %lf", matching_u, matching_v);
#endif
        }
      } /* if (jump_type != EMjump_none) */
/*
 * Get rid of this jump by first inserting the first point of the jump
 * line into the uv data.  This will create a mutiple point at which
 * we can break.  Then break the data at this point.  Now everything is
 * correct except that we still must move the uv coordinate to the other
 * side of the surface
 */
     if (jump_type != EMjump_none)
      {
       IGRlong	number_of_breaks, last_point, last_group;
#if DEBUG
fprintf(stderr, "\nJump found at point %d", j);
#endif
       number_of_breaks = 0;
       if ((jump_type == EMjump_to_an_edge) ||
           (jump_type == EMjump_no_edges))
        {
#if DEBUG
fprintf(stderr, "\nRequest insertion at segment %d", j - 1);
#endif
         breaks[0].group_number = i;
         breaks[0].segment_number = (j ? (j - 1) : j);
         breaks[0].uv1_coordinate[0] = u;
         breaks[0].uv1_coordinate[1] = v;
         breaks[0].line_parameter = 1.0;
         breaks[0].times_to_insert = 1;
         breaks[0].break_it = EMno_break;
         number_of_breaks = 1;
        }
       if ((jump_type == EMjump_from_an_edge) ||
           (jump_type == EMjump_no_edges))
        {
#if DEBUG
fprintf(stderr, "\nRequest insertion at segment %d", j);
#endif
         if (number_of_breaks &&
             (breaks[0].segment_number == j))
          breaks[0].times_to_insert = 2;
         else
          {
           breaks[number_of_breaks].group_number = i;
           breaks[number_of_breaks].segment_number = j;
           breaks[number_of_breaks].uv1_coordinate[0] = u;
           breaks[number_of_breaks].uv1_coordinate[1] = v;
           breaks[number_of_breaks].line_parameter = 1.0;
           breaks[number_of_breaks].times_to_insert = 1;
           breaks[number_of_breaks].break_it = EMno_break;
           number_of_breaks++;
          }
        }
       status = EFsegment_breaker(
                 number_of_breaks,
                 breaks,
                 number_of_groups,
                 points_per_group,
                 xyz_group,
                 uv1_group,
                 uv2_group,
                 msg);
        if (!status)
         {
          if (*msg == MSINARG) *msg = MSFAIL;
          return(FALSE);
         }
       number_of_breaks = 1;
       breaks[0].times_to_insert = 0;
       breaks[0].break_it = EMforward_break;
       if (jump_type == EMjump_from_an_edge)
        breaks[0].segment_number = j;
       else
        breaks[0].segment_number = j + 1;
#if DEBUG
fprintf(stderr, "\nRequest break at segment %d", breaks[0].segment_number);
#endif
       status = EFsegment_breaker(
                 number_of_breaks,
                 breaks,
                 number_of_groups,
                 points_per_group,
                 xyz_group,
                 uv1_group,
                 uv2_group,
                 msg);
        if (!status)
         {
          if (*msg == MSINARG) *msg = MSFAIL;
          return(FALSE);
         }
/*
 * Adjust the points to be exact
 */
#if DEBUG
fprintf(stderr, "\nAdjusting data");
#endif
       last_point = (*points_per_group)[i] - 1;
       (*uv1_group)[i][last_point][0] = u_new;
       (*uv1_group)[i][last_point][1] = v_new;
       (*xyz_group)[i][last_point][0] = point[0];
       (*xyz_group)[i][last_point][1] = point[1];
       (*xyz_group)[i][last_point][2] = point[2];
       last_group = *number_of_groups - 1;
       (*uv1_group)[last_group][0][0] = matching_u;
       (*uv1_group)[last_group][0][1] = matching_v;
       (*xyz_group)[last_group][0][0] = matching_point[0];
       (*xyz_group)[last_group][0][1] = matching_point[1];
       (*xyz_group)[last_group][0][2] = matching_point[2];
/*
 * Adjust the points in the parametric space of the second surface, if any.
 */
       if (uv2_group && surface_2)
        {
         switch (jump_type)
          {
/*
 * Change the first point of the new group to correspond to the last point
 * of the current group.
 */
           case EMjump_from_an_edge:
            (*uv2_group)[last_group][0][0] = (*uv2_group)[i][last_point][0];
            (*uv2_group)[last_group][0][1] = (*uv2_group)[i][last_point][1];
            break;
/*
 * Change the last point of the current group to corresponds to the first
 * point of the new group.
 */
           case EMjump_to_an_edge:
            (*uv2_group)[i][last_point][0] = (*uv2_group)[last_group][0][0];
            (*uv2_group)[i][last_point][1] = (*uv2_group)[last_group][0][1];
            break;
/*
 * This case is a little tricky since we don't know the new point in the second
 * parametric space.  The only way I know how to get this point is to
 * map from model space to the second parametric space.  
 */
           case EMjump_no_edges:
            {
             IGRboolean	on_side, EFfind_closest_uv_side();
             IGRlong	loc_msg, side;
             IGRdouble	u, v, distance_1, distance_2;
             IGRdouble	u_low, u_hig, v_low, v_hig;
             IGRdouble	u_new, v_new, matching_u, matching_v;
             IGRpoint	point_on_the_surface;

             u_low = surface_2->u_knots[surface_2->u_order - 1];
             u_hig = surface_2->u_knots[surface_2->u_num_poles];
             v_low = surface_2->v_knots[surface_2->v_order - 1];
             v_hig = surface_2->v_knots[surface_2->v_num_poles];
             status = BSmdistptsf(
               &loc_msg,
               surface_2,
               point,
               &u,
               &v,
               point_on_the_surface,
               &distance_1);
              if (!status || (loc_msg != BSSUCC))
               {
                *msg = MSFAIL;
                return(FALSE);
               }
/*
 * If this parametric point is on a side then we may have two possible
 * solutions.  Pick the solution which is nearest the data where the
 * break occurred.
 */
             on_side = EFfind_closest_uv_side(
                         u_low, u_hig, v_low, v_hig,
                         u, v, par_tol_2, &side,
                         &u_new, &v_new, &matching_u, &matching_v);
             if (on_side)
              {
               u = (*uv2_group)[last_group][0][0];
               v = (*uv2_group)[last_group][0][1];
               distance_1 = (u - u_new) * (u - u_new) +
                            (v - v_new) * (v - v_new);
               distance_2 = (u - matching_u) * (u - matching_u) +
                            (v - matching_v) * (v - matching_v);
               if (distance_1 < distance_2)
                {
                 u = u_new;
                 v = v_new;
                }
               else
                {
                 u = matching_u;
                 v = matching_v;
                }
              }
             (*uv2_group)[last_group][0][0] = u;
             (*uv2_group)[last_group][0][1] = v;
             (*uv2_group)[i][last_point][0] = u;
             (*uv2_group)[i][last_point][1] = v;
            } /* case EMjump_no_edges: */
            break;
           default:				/* Impossible */
            *msg = MSFAIL;
            return(FALSE);
          } /* switch (jump_type) */
        } /* if (uv2_group && surface_2) */
      } /* if (jump_type != EMjump_none) */
    } /* for (j = 1; j < (*points_per_group)[i] - 3; j++) */
  } /* for (i = 0; i < *number_of_groups; i++) */
/*
 * End of routine
 */
 return(TRUE);
}

/*
 * This is a helper function.  It trys to weed out cases which are not
 * jumps.  If it thinks a jump is possible then it will return what
 * kind of jump could occur as well as the parameter values of where
 * the jump might occur.
 *
 * 04/27/87 : rlw : creation date
 * 04/28/87 : rlw : Once again I have gotten my ? and : backwords
 */

static void EFfind_jump_side_if_any(
 par_tol,
 u, v,
 u_next, v_next,
 u_low, u_hig,
 v_low, v_hig,
 u_mid_value, v_mid_value,
 jump_type,
 u_new, v_new,
 u_matching, v_matching)

IGRdouble	par_tol;
IGRdouble	u, v;
IGRdouble	u_next, v_next;
IGRdouble	u_low, u_hig;
IGRdouble	v_low, v_hig;
IGRdouble	u_mid_value, v_mid_value;
enum		EMjump_type *jump_type;
IGRdouble	*u_new, *v_new;
IGRdouble	*u_matching, *v_matching;

{
 IGRlong	side, next_side, on_side[2];
 extern		IGRdouble fabs();
 IGRdouble	delta_u, delta_v;
 IGRdouble	distance_to_side[5];
/*
 * Initialize
 */
 *jump_type = EMjump_none;
/*
 * Compute distances (sort of)
 */
 delta_u = fabs(u_next - u);
 delta_v = fabs(v_next - v);
/*
 * Trivial rejection time.  If this test fails then we have probably 
 * crossed vast expanses in model space.  Next we will determine whether 
 * to look for a jump from side 1 to side 2 or from side 3 to side 4.
 */
 if ((delta_u < u_mid_value) &&
     (delta_v < v_mid_value)) return;
/*
 * Looking for a jump in v.  Find out which side (3 or 4) each of the input
 * points is closest to.  If they are on the same side, very unlikely,
 * then just return.
 */
 if (delta_u < delta_v)
  {
#if DEBUG
fprintf(stderr, "\nLooking for a jump in v");
#endif
   distance_to_side[3] = v - v_low;
   distance_to_side[4] = v_hig - v;
   side = ((distance_to_side[3] < distance_to_side[4]) ? 3 : 4);
   on_side[0] = (distance_to_side[side] < par_tol);
   distance_to_side[3] = v_next - v_low;
   distance_to_side[4] = v_hig - v_next;
   next_side = ((distance_to_side[3] < distance_to_side[4]) ? 3 : 4);
   on_side[1] = (distance_to_side[next_side] < par_tol);
   if (next_side == side) return;
#if DEBUG
fprintf(stderr, "\non_side[0] %d, on_side[1] %d", on_side[0], on_side[1]);
fprintf(stderr, "\nside %d, next_side %d", side, next_side);
#endif
/*
 * Setup (u_new, v_new) to correspond to (u, v) moved to the edge and
 * (u_matching, v_matching) to correspond to (u_next, v_next) moved to the
 * edge.
 */
   if (side == 3)
    {
     *v_new = v_low;
     *v_matching = v_hig;
    }
   else
    {
     *v_new = v_hig;
     *v_matching = v_low;
    }
/*
 * If the first point was on a side then we are potentially jumping 
 * from an edge.
 */
   if (on_side[0])
    {
     *jump_type = EMjump_from_an_edge;
     *u_new = u;
     *u_matching = u;
    }
/*
 * If the second point was on a side then we are potentially jumping 
 * to an edge.
 */
   else if (on_side[1])
    {
     *jump_type = EMjump_to_an_edge;
     *u_new = u_next;
     *u_matching = u_next;
    }
/*
 * Neither point was on an edge.  Therefore we are potentially jumping
 * with no edges.
 */
   else
    {
     *jump_type = EMjump_no_edges;
     *u_new = (u + u_next) / 2.0;			/* Average */
     *u_matching = *u_new;
    } /* ELSE FOR else if (on_side[1]) */
  } /* if (delta_u < delta_v) */
/*
 * Looking for a jump in u.  Find out which side (1 or 2) each of the input
 * points is closest to.  If they are on the same side, very unlikely,
 * then just return.
 */
 else
  {
#if DEBUG
fprintf(stderr, "\nLooking for a jump in u");
#endif
   distance_to_side[1] = u - u_low;
   distance_to_side[2] = u_hig - u;
   side = ((distance_to_side[1] < distance_to_side[2]) ? 1 : 2);
   on_side[0] = (distance_to_side[side] < par_tol);
   distance_to_side[1] = u_next - u_low;
   distance_to_side[2] = u_hig - u_next;
   next_side = ((distance_to_side[1] < distance_to_side[2]) ? 1 : 2);
   on_side[1] = (distance_to_side[next_side] < par_tol);
   if (next_side == side) return;
#if DEBUG
fprintf(stderr, "\non_side[0] %d, on_side[1] %d", on_side[0], on_side[1]);
fprintf(stderr, "\nside %d, next_side %d", side, next_side);
#endif
/*
 * Setup (u_new, v_new) to correspond to (u, v) moved to the edge and
 * (u_matching, v_matching) to correspond to (u_next, v_next) moved to the
 * edge.
 */
   if (side == 1)
    {
     *u_new = u_low;
     *u_matching = u_hig;
    }
   else
    {
     *u_new = u_hig;
     *u_matching = u_low;
    }
/*
 * If the first point was on a side then we are potentially jumping 
 * from an edge.
 */
   if (on_side[0])
    {
     *jump_type = EMjump_from_an_edge;
     *v_new = v;
     *v_matching = v;
    }
/*
 * If the second point was on a side then we are potentially jumping 
 * to an edge.
 */
   else if (on_side[1])
    {
     *jump_type = EMjump_to_an_edge;
     *v_new = v_next;
     *v_matching = v_next;
    }
/*
 * Neither point was on an edge.  Therefore we are potentially jumping
 * with no edges.
 */
   else
    {
     *jump_type = EMjump_no_edges;
     *v_new = (v + v_next) / 2.0;			/* Average */
     *v_matching = *v_new;
    } /* ELSE FOR else if (on_side[1]) */
  } /* ELSE FOR if (delta_u < delta_v) */
/*
 * eof
 */
 return;
}
