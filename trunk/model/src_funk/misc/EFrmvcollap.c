/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/* 
   DESCRIPTION
  
   This routine moves data which is very near natural edges to the
   natural edge.  It also either:
  
   a) Removes segments which lie along natural edges
   b) If the surface is physically closed then it will move seam segments
      to the lower edge, i.e. u = 1 goes to u = 0 and v = 1 goes to v = 0.
  
   RETURN VALUES
  
   status               TRUE if success, FALSE if failure
   number_of_groups     resulting number of groups
   points_per_group     resulting number of points per group
   xyz_group            resulting model space points
   uv1_group            resulting uv points in parametric space of surface 1
   uv2_group		resulting uv points in parametric space of surface 2
                        or NULL
   msg                  MSSUCC - success
                        MANOMEMORY - no dynamic memory available
                        MSFAIL - implies that EFsegment_breaker() has failed
  
   NOTES
  
   This routine may create groups that have single points.  These points
   should be ignored.  If two uv groups are input then only collapsed
   edges in uv1_group are removed.  If a collapsed edge in uv1_group is found
   then it is removed and the corresponding edge in uv2_group (if present)
   is also removed.
  
   HISTORY
  
   01/23/87 : rlw : creation date
   04/21/87 : rlw : Modified calling argument list in order to accept two
                    groups.  The collapsed ege is removed from all the
                    groups.
   10/07/87 : rlw : Added option to move seams edges to a side as opposed
                    to removing them.
 */

#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "maerr.h"
#include "bstypes.h"
#include "emsbreak.h"

#define INVALID -1
#define NONE 0
#define U_LOW 1
#define U_HIG 2
#define V_LOW 3
#define V_HIG 4

struct RLW
 {
  IGRlong	begin_index;
  IGRlong	end_index;
  IGRlong	side;
  IGRlong	group_index;
 };

IGRboolean EFremove_collapsed_edges(
 remove_the_edges,           /* Are collapsed edges to be removed? */
 surface,                    /* The surface data, srf 1 */
 par_tol,                    /* Parametric tolerance for surf 1 */
 number_of_groups,           /* Number of sets of data */
 points_per_group,           /* Number of points in each set */
 xyz_group,                  /* Sets for model space */
 uv1_group,                  /* Sets for parametric space, srf 1 */
 uv2_group,                  /* Sets for parametric space, srf 2 */
 msg)                        /* Error return code */

IGRboolean	remove_the_edges;
struct          IGRbsp_surface *surface;
IGRdouble       par_tol;
IGRlong         *number_of_groups;
IGRlong         **points_per_group;
IGRpoint        ***xyz_group;
BSpair          ***uv1_group;
BSpair          ***uv2_group;
IGRlong         *msg;

{
 IGRboolean     status, EFsegment_breaker();
 IGRlong        i, j, on_side, previous_on_side, side_count;
 IGRlong        u_side, v_side, previous_u_side, previous_v_side;
 IGRdouble      u_low, u_hig, v_low, v_hig, *u, *v;
 struct		RLW *sections;
/*
 * Initialize
 */
 *msg = MSSUCC;
 sections = NULL;
/*
 * Determine the parametric values of the edges of the surface
 */
 u_low = surface->u_knots[surface->u_order - 1];
 u_hig = surface->u_knots[surface->u_num_poles];
 v_low = surface->v_knots[surface->v_order - 1];
 v_hig = surface->v_knots[surface->v_num_poles];
/*
 * Process every group
 */
 for (i = 0; i < *number_of_groups; i++)
  {
/*
 * For all points in this group
 */
   side_count = 0;
   previous_on_side = NONE;
   previous_u_side = NONE;
   previous_v_side = NONE;
   for (j = 0; j < (*points_per_group)[i]; j++)
    {
     u = &(*uv1_group)[i][j][0];
     v = &(*uv1_group)[i][j][1];
/*
 * Determine which side, if any, the u coordinate is on
 */
     if ((*u - u_low) < par_tol)
      {
       *u = u_low;
       u_side = U_LOW;
      }
     else if ((u_hig - *u) < par_tol)
      {
       *u = u_hig;
       u_side = U_HIG;
      }
     else
      u_side = NONE;
/*
 * Determine which side, if any, the v coordinate is on
 */
     if ((*v - v_low) < par_tol)
      {
       *v = v_low;
       v_side = V_LOW;
      }
     else if ((v_hig - *v) < par_tol)
      {
       *v = v_hig;
       v_side = V_HIG;
      }
     else
      v_side = NONE;
/*
 * Determine if this point in conjunction with the last point
 * puts us on a side.  I am trying to stay on the same side, if possible,
 * as corners can throw one off.
 *
 * If we have duplicate corner points (lower right or upper left) which
 * extends down the U/V_HIG seam then this will not work so efficently,
 * i.e. I will not detect that we have remained on the U/V_HIG side.
 * But the routine should still work, even in this crazy case.
 */
     if (previous_u_side && (previous_u_side == u_side))
      on_side = u_side;
     else if (previous_v_side && (previous_v_side == v_side))
      on_side = v_side;
     else
      on_side = NONE;
/*
 * Decision time
 */
     if (on_side)
      {
/*
 * Remove the edge, if desired
 */
       if (remove_the_edges)
        {
         struct	EMsegment_breaker breaks;

         breaks.group_number = i;
         breaks.segment_number = j - 1;
         breaks.uv1_coordinate[0] = 9999;
         breaks.uv1_coordinate[1] = 9999;
         breaks.line_parameter = 9999;
         breaks.times_to_insert = 0;
         breaks.break_it = EMforward_break;
         status = EFsegment_breaker(
                   1,
                   &breaks,
                   number_of_groups,
                   points_per_group,
                   xyz_group,
                   uv1_group,
                   uv2_group,
                   msg);
          if (!status)
           {
            if (*msg == MSINARG) *msg = MSFAIL;
            goto wrapup;
           }
        } /* if (remove_the_edges) */
/*
 * If we are on the high side and the surface is physically
 * closed in this direction then mark this edge as one which
 * must be moved.
 */
       else if (((on_side == V_HIG) && surface->v_phy_closed) ||
                ((on_side == U_HIG) && surface->u_phy_closed))
        {
         if (previous_on_side == on_side)
          sections[side_count - 1].end_index++;
         else
          {
           if (side_count)
            sections = (struct RLW *) realloc(sections,
                       sizeof(struct RLW) * (side_count + 1));
           else
            sections = (struct RLW *) malloc(sizeof(struct RLW));
           if (! sections)
            {
             *msg = MANOMEMORY;
             goto wrapup;
            }
           sections[side_count].begin_index = j - 1;
           sections[side_count].end_index = j;
           sections[side_count].side = on_side;
           side_count++;
          }
        }
      } /* if (on_side) */
/*
 * Save this point's information
 */
     previous_on_side = on_side;
     previous_u_side = u_side;
     previous_v_side = v_side;
    } /* for (j = 0; j < (*points_per_group)[i]; j++) */
/*
 * If we have some sides to shift then shift them
 */
   if (side_count)
    {
     IGRlong	k, m, num_brk, begin, end, index, group_counter;
     struct	EMsegment_breaker *breaks;

     num_brk = 0;
     breaks = (struct EMsegment_breaker *) malloc(2 * side_count *
               sizeof(struct  EMsegment_breaker));
      if (!breaks)
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     group_counter = *number_of_groups;
     for (k = 0; k < side_count; k++)
      {
       begin = (sections[k].begin_index == 0);
       end = (sections[k].end_index == ((*points_per_group)[i] - 1));
       if (begin && end)
        sections[k].group_index = i;
       else
        {
         if (!begin)
          {
           sections[k].group_index = group_counter;
           group_counter++;
           index = sections[k].begin_index;
           breaks[num_brk].group_number = i;
           breaks[num_brk].segment_number = index - 1;
           breaks[num_brk].uv1_coordinate[0] = (*uv1_group)[i][index][0];
           breaks[num_brk].uv1_coordinate[1] = (*uv1_group)[i][index][1];
           breaks[num_brk].line_parameter = 1.0;
           breaks[num_brk].times_to_insert = 1;
           breaks[num_brk].break_it = EMforward_break;
           num_brk++;
          }
         if (!end)
          {
           sections[k].group_index = begin ? i : INVALID;
           group_counter++;
           index = sections[k].end_index;
           breaks[num_brk].group_number = i;
           breaks[num_brk].segment_number = index - 1;
           breaks[num_brk].uv1_coordinate[0] = (*uv1_group)[i][index][0];
           breaks[num_brk].uv1_coordinate[1] = (*uv1_group)[i][index][1];
           breaks[num_brk].line_parameter = 1.0;
           breaks[num_brk].times_to_insert = 1;
           breaks[num_brk].break_it = EMforward_break;
           num_brk++;
          }
        } /* ELSE FOR if (begin && end) */
      } /* for (k = 0; k < side_count; k++) */
/*
 * Break 'er up
 */
     status = EFsegment_breaker(
               num_brk,
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
        free(breaks);
        goto wrapup;
       }
/*
 * Move the data to the approriate side
 */
     for (k = 0; k < side_count; k++)
      {
       IGRlong	group_to_move, points_to_move;

       group_to_move = sections[k].group_index;
       points_to_move = (group_to_move == INVALID) ? 0 :
                        (*points_per_group)[group_to_move];
       for (m = 0; m < points_to_move; m++)
        {
         if (sections[k].side == U_HIG)
          (*uv1_group)[group_to_move][m][0] = u_low;
         else if (sections[k].side == V_HIG)
          (*uv1_group)[group_to_move][m][1] = v_low;
         else		/* Not possible */
          {
           *msg = MSFAIL;
           goto wrapup;
          }
        } /* for (m = 0; m < (*points_per_group)[group_to_move]; m++) */
      } /* for (k = 0; k < side_count; k++) */
    } /* if (side_count) */
  } /* for (i = 0; i < *number_of_groups; i++) */
/*
 * End of routine
 */
wrapup:
 if (sections) free(sections);
 if (! (1 & *msg))
  return(FALSE);
 else
 return(TRUE);
} /* EOF */
