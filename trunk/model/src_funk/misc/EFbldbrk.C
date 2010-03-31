/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to make up a set of insert/break
 * instructions in order to break up surface/surface intersection data
 * such that intersections do not occur between the data.  The input
 * basically consists of the output of EF2dpyint().  The output is that
 * needed by EFsegment_breaker().
 *
 * RETURN VALUES
 *
 * number_of_breaks     Number of breaks required to remove this
 *                      intersection.
 * breaks               Break information required by EFsegment_breaker()
 *                      to remove this intersection.
 * msg                  MSSUCC if sucess
 *                      MSFAIL if severe problems (best to abort), note
 *                      that this most likely implies coding or
 *                      algorithm problems.
 *
 * NOTES
 *
 * It is assumed that if the type is endpoint intersection then the
 * parameters will EXACTLY correspond to one of the endpoints, i.e.
 * 0.0 or 1.0.  Note that EF2dpyint() assures this is true.
 *
 * HISTORY
 *
 * 01/05/87 : rlw : creation date
 * 02/04/87 : rlw : Added logic to take care of collapsed intersections.
 *                  If a collapsed intersection occurrs then I just break
 *                  the data up at the collapse.
 * 04/28/87 : rlw : Changed overlap logic such that one piece is
 *                  removed and the other piece is split out. 
 *                  Previously both pieces were removed.
 * 05/12/87 : rlw : Change enum EMpyint_type to EMScvinttype and adjusted
 *                  the code
 */

# include "EMS.h"

#define THIS_DOES_NOT_WORK 0
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif

# include "OMminimum.h"
# include "msdef.h" /* MS message codes */
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "bs.h"				/* Added */
# include "bsparameters.h"
# include "ma.h"				/* Added */
# include "msmacros.h"				/* Added */
# include "emsdattyp.h"
# include "emsinter.h"
# include "emsbreak.h"			/* Changed from "ems.h" */
# include "emsdef.h"

IGRboolean EFbuild_breaks(
        points_per_group,               /* Number of points in each group */
        group1_index,                   /* Which group for 1st intersection */
        group1_segment,                 /* Which segment number in linestrng */
        pars_1,                         /* Params for 1st intersection */
        type_1,                         /* Type of 1st intersection */
        group2_index,                   /* Which group for 2nd intersection */
        group2_segment,                 /* Which segment number in linestrng */
        pars_2,                         /* Params for 2nd intersection */
        type_2,                         /* Type of 2nd intersection */
        points,                         /* Intersection point(s) */
        number_of_breaks,               /* Number of breaks required */
        breaks,                         /* Break information */
        msg)                            /* Error return code */

 IGRlong        *points_per_group;
 IGRlong        group1_index;
 IGRlong        group1_segment;
 IGRdouble      pars_1[2];
 enum           EMScvinttype type_1;
 IGRlong        group2_index;
 IGRlong        group2_segment;
 IGRdouble      pars_2[2];
 enum           EMScvinttype type_2;
 BSpair         points[2];
 IGRlong        *number_of_breaks;
 struct         EMsegment_breaker breaks[MAXIMUM_BREAKS];
 IGRlong        *msg;
{
 IGRlong        num_brk;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *number_of_breaks = 0;
 num_brk = 0;
/*
 * Middle - Middle 
 *
 * Algorithm - We must insert two points on either side of the intersection
 * into both lines.  We then break up this piece into 3 pieces.  We essentially
 * cut out the loop.
 */
 if ((type_1 == EMScvint_middle) &&
     (type_2 == EMScvint_middle))
  {
   num_brk = 2;
   breaks[0].group_number = group1_index;
   breaks[0].segment_number = group1_segment;
   breaks[0].uv1_coordinate[0] = points[0][0]; 
   breaks[0].uv1_coordinate[1] = points[0][1];
   breaks[0].line_parameter = pars_1[0];
   breaks[0].times_to_insert = 2;
   breaks[0].break_it = EMforward_break;
   breaks[1].group_number = group2_index;
   breaks[1].segment_number = group2_segment;
   breaks[1].uv1_coordinate[0] = points[0][0];
   breaks[1].uv1_coordinate[1] = points[0][1];
   breaks[1].line_parameter = pars_2[0];
   breaks[1].times_to_insert = 2;
   breaks[1].break_it = EMforward_break;
#if DEBUG
fprintf(stderr, "\nmiddle - middle");
#endif
  } /* if ((type_1 == EMScvint_middle) && (type_2 == EMScvint_middle)) */
/*
 * Middle - End
 *
 * Algorithm - We must insert two points on either side of the intersections
 * into the first line.  If we are not at the end of the linestring then
 * we must also insert a point in the other line also.  We then break up this
 * piece into 2 pieces (if at end of linestring) or 3 pieces (if not at end 
 * of linestring).
 */
 else if (type_1 == EMScvint_middle)
  {
   IGRboolean           beg_frst_piece, end_last_piece;

   beg_frst_piece = ((pars_2[0] == 0.0) && (group2_segment == 0));
   end_last_piece = ((pars_2[0] == 1.0) &&
     (group2_segment == (points_per_group[group2_index] - 2)));
   num_brk = 1;
   breaks[0].group_number = group1_index;
   breaks[0].segment_number = group1_segment;
   breaks[0].uv1_coordinate[0] = points[0][0]; 
   breaks[0].uv1_coordinate[1] = points[0][1];
   breaks[0].line_parameter = pars_1[0];
   breaks[0].times_to_insert = 2;
   breaks[0].break_it = EMforward_break;
   if (!(beg_frst_piece || end_last_piece))
    {
     num_brk = 2;
     breaks[1].group_number = group2_index;
     breaks[1].segment_number = group2_segment;
     breaks[1].uv1_coordinate[0] = points[0][0]; 
     breaks[1].uv1_coordinate[1] = points[0][1];
     breaks[1].line_parameter = pars_2[0];
     breaks[1].times_to_insert = (type_2 == EMScvint_collapsed ? 0 : 1);
     breaks[1].break_it = EMforward_break;
    }
#if DEBUG
fprintf(stderr, "\nmiddle - end");
#endif
  } /* else if (type_1 == EMScvint_middle) */
/*
 * End - Middle
 *
 * Algorithm - If the end is at the beginning of the 1st line then do nothing
 * to the first piece else insert one point at the intersection into the first
 * line.  We then insert two points into the other line.  We then break
 * up the piece into 2 (1st line do nothing) or 3 pieces (lst line insert).
 */
 else if (type_2 == EMScvint_middle)
  {
   IGRboolean           beg_frst_piece, end_last_piece;

   beg_frst_piece = ((pars_1[0] == 0.0) && (group1_segment == 0));
   end_last_piece = ((pars_1[0] == 1.0) &&
     (group1_segment == (points_per_group[group1_index] - 2)));
   if (!(beg_frst_piece || end_last_piece))
    {
     num_brk = 1;
     breaks[0].group_number = group1_index;
     breaks[0].segment_number = group1_segment;
     breaks[0].uv1_coordinate[0] = points[0][0]; 
     breaks[0].uv1_coordinate[1] = points[0][1];
     breaks[0].line_parameter = pars_1[0];
     breaks[0].times_to_insert = (type_1 == EMScvint_collapsed ? 0 : 1);
     breaks[0].break_it = EMforward_break;
    }
   breaks[num_brk].group_number = group2_index;
   breaks[num_brk].segment_number = group2_segment;
   breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
   breaks[num_brk].uv1_coordinate[1] = points[0][1];
   breaks[num_brk].line_parameter = pars_2[0];
   breaks[num_brk].times_to_insert = 2;
   breaks[num_brk].break_it = EMforward_break;
   num_brk++;
#if DEBUG
fprintf(stderr, "\nend - middle");
#endif
  } /* else if (type_2 == EMScvint_middle) */
/*
 * End - End
 *
 * Algorithm - If the beginning of the first segment intersects the end of
 * the last segment then do nothing.  If two consequtive segments intersect
 * at the ending and beginning points respectively, then do nothing. Else
 * we must insert a point into the first line.  If we are not at the end of 
 * the linestring then we must also insert a point in the other line also.  
 * We then break up this piece into 2 pieces (if at end of linestring) or 
 * 3 pieces (if not at end of linestring).
 *
 * Modified such that even if it is a special case, checks are still performed
 * to determine if the intersections are degenerate.  If they are then
 * just break them up at the duplicate point. (rlw 02/04/87)
 */
 else if (type_1 != EMScvint_overlap)
  {
   IGRboolean           special_case;
   IGRboolean           beg_frst_piece, end_frst_piece;
   IGRboolean           beg_last_piece, end_last_piece;

   special_case = ((group1_index == group2_index) &&
                   (group2_segment == (group1_segment + 1)));
   if (!special_case ||
       (type_1 == EMScvint_collapsed) ||
       (type_2 == EMScvint_collapsed))
    {
     beg_frst_piece = ((pars_1[0] == 0.0) && (group1_segment == 0));
     end_frst_piece = (!beg_frst_piece && (pars_1[0] == 1.0) &&
       (group1_segment == (points_per_group[group1_index] - 2)));
     if (!(beg_frst_piece || end_frst_piece))
      {
       if (!special_case || (type_1 == EMScvint_collapsed))
        {
         num_brk = 1;
         breaks[0].group_number = group1_index;
         breaks[0].segment_number = group1_segment;
         breaks[0].uv1_coordinate[0] = points[0][0]; 
         breaks[0].uv1_coordinate[1] = points[0][1];
         breaks[0].line_parameter = pars_1[0];
         breaks[0].break_it = EMforward_break;
         breaks[0].times_to_insert = (type_1 == EMScvint_collapsed ? 0 : 1);
        }
      }
     beg_last_piece = ((pars_2[0] == 0.0) && (group2_segment == 0));
     end_last_piece = (!beg_last_piece && (pars_2[0] == 1.0) &&
       (group2_segment == (points_per_group[group2_index] - 2)));
     if (!(beg_last_piece || end_last_piece))
      {
       if (!special_case || (type_2 == EMScvint_collapsed))
        {
         breaks[num_brk].group_number = group2_index;
         breaks[num_brk].segment_number = group2_segment;
         breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
         breaks[num_brk].uv1_coordinate[1] = points[0][1];
         breaks[num_brk].line_parameter = pars_2[0];
         breaks[num_brk].times_to_insert = (type_2 == EMScvint_collapsed ? 0 : 1);
         breaks[num_brk].break_it = EMforward_break;
         num_brk++;
        }
      }
    }
#if DEBUG
fprintf(stderr, "\nend - end");
#endif
  } /* else if (type_1 != EMScvint_overlap) */
/*
 * Overlap
 *
 * Algorithm - Try an cut out the overlap in both sections.  This is
 * accomplished by inserting points (if necessary) into both lines
 * such that we have two identical lines (with possibly different directions).
 * Then the resulting totally overlapping lines can be removed.
 */
 else
  {
   IGRboolean           total_over_1;
   IGRboolean           is_reversed_2;
/*
 * Branch based on whether the first intersection is partial on left,
 * partial on right, partial in middle, or total
 */
   total_over_1 = ((pars_1[0] == 0.0) && (pars_1[1] == 1.0));
   if (!total_over_1)
    {
     if (pars_1[0] == 0.0)
      {
       num_brk = 1;
       breaks[0].group_number = group1_index;
       breaks[0].segment_number = group1_segment;
       breaks[0].uv1_coordinate[0] = points[1][0]; 
       breaks[0].uv1_coordinate[1] = points[1][1];
       breaks[0].line_parameter = pars_1[1];
       breaks[0].times_to_insert = 1;
       breaks[0].break_it = EMbackwards_break;
      }
     else if (pars_1[1] == 1.0)
      {
       num_brk = 1;
       breaks[0].group_number = group1_index;
       breaks[0].segment_number = group1_segment;
       breaks[0].uv1_coordinate[0] = points[0][0]; 
       breaks[0].uv1_coordinate[1] = points[0][1];
       breaks[0].line_parameter = pars_1[0];
       breaks[0].times_to_insert = 1;
       breaks[0].break_it = EMforward_break;
      }
     else
      {
       num_brk = 2;
       breaks[0].group_number = group1_index;
       breaks[0].segment_number = group1_segment;
       breaks[0].uv1_coordinate[0] = points[0][0]; 
       breaks[0].uv1_coordinate[1] = points[0][1];
       breaks[0].line_parameter = pars_1[0];
       breaks[0].times_to_insert = 1;
       breaks[0].break_it = EMno_break;
       breaks[1].group_number = group1_index;
       breaks[1].segment_number = group1_segment;
       breaks[1].uv1_coordinate[0] = points[1][0]; 
       breaks[1].uv1_coordinate[1] = points[1][1];
       breaks[1].line_parameter = pars_1[1];
       breaks[1].times_to_insert = 1;
       breaks[1].break_it = EMbackwards_break;
      }
    }
   else
    {
     num_brk = 1;
     breaks[0].group_number = group1_index;
     breaks[0].segment_number = group1_segment;
     breaks[0].uv1_coordinate[0] = 9999; 
     breaks[0].uv1_coordinate[1] = 9999;
     breaks[0].line_parameter = 9999;
     breaks[0].times_to_insert = 0;
     breaks[0].break_it = EMforward_break;
    }
/*
 * Since the parameterization of the second line may not be in increasing
 * order we may have to reverse the data
 */
   is_reversed_2 = (pars_2[0] > pars_2[1]);
   if (is_reversed_2)
    {
     IGRdouble  temp;

     temp = pars_2[0];
     pars_2[0] = pars_2[1];
     pars_2[1] = temp;
     temp = points[0][0];
     points[0][0] = points[1][0];
     points[1][0] = temp;
     temp = points[0][1];
     points[0][1] = points[1][1];
     points[1][1] = temp;
    }
/*
 * Branch based on whether the second intersection is partial on left,
 * partial on right, partial in middle, or total
 *
 * Modified to only break out the overlap in the portion of the 
 * curve 04/28/87 (rlw).
 */
   if (pars_2[0] == 0.0)
    {
     if ((group2_segment == 0) ||		     /* First segment? */
         ((group2_index == group1_index) &&	     /* Same group? */
          (group1_segment == (group2_segment - 1)))) /* Conseq. seg.? */
      {
/*     noop;     */
      }
     else
      {
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment - 1;
       breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[0][1];
       breaks[num_brk].line_parameter = 1.0;
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMforward_break;
       num_brk++;
      }
    }
   else
    {
     breaks[num_brk].group_number = group2_index;
     breaks[num_brk].segment_number = group2_segment;
     breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
     breaks[num_brk].uv1_coordinate[1] = points[0][1];
     breaks[num_brk].line_parameter = pars_2[0];
     breaks[num_brk].times_to_insert = 2;
     breaks[num_brk].break_it = EMforward_break;
     num_brk++;
    }
   if (pars_2[1] == 1.0)
    {
     if (group2_segment != (points_per_group[group2_index] - 2))
      {
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment;
       breaks[num_brk].uv1_coordinate[0] = points[1][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[1][1];
       breaks[num_brk].line_parameter = 1.0;
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMforward_break;
       num_brk++;
      }
    }
   else
    {
     breaks[num_brk].group_number = group2_index;
     breaks[num_brk].segment_number = group2_segment;
     breaks[num_brk].uv1_coordinate[0] = points[1][0]; 
     breaks[num_brk].uv1_coordinate[1] = points[1][1];
     breaks[num_brk].line_parameter = pars_2[1];
     breaks[num_brk].times_to_insert = 2;
     breaks[num_brk].break_it = EMforward_break;
     num_brk++;
    }
#if DEBUG
fprintf(stderr, "\noverlap - overlap");
#endif
  } /* else => overlap */
/*
 * Debug code
 */
#if DEBUG
{
 void RLW_print_the_breaks();

 RLW_print_the_breaks(num_brk, breaks);
}
#endif
/*
 * End of routine
 */
 *number_of_breaks = num_brk;
 return(TRUE);
}

#if DEBUG
static void RLW_print_the_breaks(number_of_breaks, breaks)

IGRlong        number_of_breaks;
struct         EMsegment_breaker breaks[MAXIMUM_BREAKS];

{
 IGRlong	i;

 fprintf(stderr, "\nThere are %d breaks", number_of_breaks);
 for (i = 0; i < number_of_breaks; i++)
  {
   fprintf(stderr, "\nProcessing break %d", i);
   fprintf(stderr, "\ngroup number is %d", breaks[i].group_number);
   fprintf(stderr, "\nsegment number is %d", breaks[i].segment_number);
   fprintf(stderr, "\nu %lf v %lf", breaks[i].uv1_coordinate[0], 
           breaks[i].uv1_coordinate[1]);
   fprintf(stderr, "\nline parameter %lf", breaks[i].line_parameter);
   fprintf(stderr, "\ntimes to insert %d", breaks[i].times_to_insert);
   fprintf(stderr, "\nbreak type %d\n\n", breaks[i].break_it);
  }
}
#endif

#if THIS_DOES_NOT_WORK
/*
 * Removed overlap code - saved just in case
 */
   total_over_2 = ((pars_2[0] == 0.0) && (pars_2[1] == 1.0));
   if (!total_over_2)
    {
     if (pars_2[0] == 0.0)
      {
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment;
       breaks[num_brk].uv1_coordinate[0] = points[1][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[1][1];
       breaks[num_brk].line_parameter = pars_2[1];
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMbackwards_break;
       num_brk++;
      }
     else if (pars_2[1] == 1.0)
      {
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment;
       breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[0][1];
       breaks[num_brk].line_parameter = pars_2[0];
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMforward_break;
       num_brk++;
      }
     else
      {
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment;
       breaks[num_brk].uv1_coordinate[0] = points[0][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[0][1];
       breaks[num_brk].line_parameter = pars_2[0];
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMno_break;
       num_brk++;
       breaks[num_brk].group_number = group2_index;
       breaks[num_brk].segment_number = group2_segment;
       breaks[num_brk].uv1_coordinate[0] = points[1][0]; 
       breaks[num_brk].uv1_coordinate[1] = points[1][1];
       breaks[num_brk].line_parameter = pars_2[1];
       breaks[num_brk].times_to_insert = 1;
       breaks[num_brk].break_it = EMbackwards_break;
       num_brk++;
      }
    }
   else
    {
     breaks[num_brk].group_number = group2_index;
     breaks[num_brk].segment_number = group2_segment;
     breaks[num_brk].uv1_coordinate[0] = 9999; 
     breaks[num_brk].uv1_coordinate[1] = 9999;
     breaks[num_brk].line_parameter = 9999;
     breaks[num_brk].times_to_insert = 0;
     breaks[num_brk].break_it = EMforward_break;
     num_brk++;
    }
#endif
