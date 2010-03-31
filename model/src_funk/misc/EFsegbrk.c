/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to support breaking up of surface/surface
 * intersection data at particular points.  These points are usually determined
 * by jumps across parametric space, self intersections within the
 * intersections, and intersections within the intersections.
 * This routine inserts points into the lists and breaks up the lists at
 * the instructed places.  It maintains compatibility between the lists, i.e.
 * you can still find the corresponding uv parameters given an xyz index.
 *
 * RETURN VALUES
 *
 * status		if TRUE then no problems else failure
 * breaks		the break segments may be modified by this routine
 * number_of_groups	resulting number of groups
 * points_per_group	resulting number of points per group
 * xyz_group		resulting model space points
 * uv1_group		resulting uv points in parametric space 1
 * uv2_group		resulting uv points in parametric space 2
 * msg			MSSUCC if sucess
 *			MANOMEMORY if no memory
 *			MSINARG if breaks not in increasing order (see notes)
 *                              or factor is not in [0,1,2]
 *			MSFAIL if severe problems (best to abort)
 *
 * NOTES
 *
 * Breaks for a particular group must be in increasing order wrt the
 * strings of data, i.e. if break[4] inserts a point in segment 4 then 
 * break[5,6,7,...] cannot insert any points in segments [0,1,2,3] of 
 * the same group.  Futhermore, if another insertion is required in segment 4
 * then it must be inserted to the right of the the last insertion.
 *
 * When inserting a point at an existing endpoint you must insert at
 * parameter 1.0.  This implies that you must use the endpoint of the previous
 * segment as opposed to the beginning point of the next segment.
 *
 * Note that after breaking a group may contain only one point.  It is
 * the callers responsibility to throw this point away, if necessary.
 *
 * When inserting points not at an endpoint this routine uses linear
 * interpolation to determine the corresponding points in xyz and uv2 space.
 *
 * HISTORY
 *
 * 12/31/86 : rlw : creation date
 *
 */


/* igr.h replacement */


# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

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
#include "maerr.h"
#include "bs.h"
#include "emsbreak.h"

IGRboolean EFsegment_breaker(
            number_of_breaks,		/* Number of breaks requested */
            breaks,			/* Break information */
            number_of_groups,		/* Number of sets of data */
            points_per_group,		/* Number of points per set */
            xyz_group,			/* Sets of model space data */
            uv1_group,			/* Sets of parametric data srf 1 */
            uv2_group,			/* Sets of parametric data srf 2 */
            msg)			/* Error return code */

IGRlong		number_of_breaks;
struct		EMsegment_breaker *breaks;
IGRlong		*number_of_groups;
IGRlong		**points_per_group;
IGRpoint	***xyz_group;
BSpair		***uv1_group;
BSpair		***uv2_group;
IGRlong		*msg;

{
 IGRlong	i, j;
 IGRlong	cur_grp, factor, cur_seg, start_index, end_index;
 IGRlong	num_points_to_move, future_size, new_num_points;
 IGRlong	old_num_points, new_num_groups;
 IGRlong	num_seg_removed, num_seg_added;
 BSpair		uv;
 IGRpoint	point;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Loop over all the insert/break combinations
 */
 for (i = 0; i < number_of_breaks; i++)
  {
/*
 * Initialize
 */
   cur_grp = breaks[i].group_number;
   cur_seg = breaks[i].segment_number;
   factor = breaks[i].times_to_insert;
   start_index = cur_seg + 1;
   num_seg_removed = 0;
   num_seg_added = 0;
/*
 * If insertion is desired then do so now
 */
   if (factor)
    {
     if ((factor < 0) || (factor > 2))
      {
       *msg = MSINARG;
       return(FALSE);
      }
/*
 * Reallocate such that we have enough memory
 */
     future_size = factor + (*points_per_group)[cur_grp];
     (*xyz_group)[cur_grp] = (IGRpoint *) realloc(
      (*xyz_group)[cur_grp], future_size * sizeof(IGRpoint));
      if (!(*xyz_group)[cur_grp])
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     (*uv1_group)[cur_grp] = (BSpair *) realloc(
      (*uv1_group)[cur_grp], future_size * sizeof(BSpair));
      if (!(*uv1_group)[cur_grp])
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     if (uv2_group)
      {
       (*uv2_group)[cur_grp] = (BSpair *) realloc(
        (*uv2_group)[cur_grp], future_size * sizeof(BSpair));
        if (!(*uv2_group)[cur_grp])
         {
          *msg = MANOMEMORY;
          return(FALSE);
         }
      }
/*
 * Shift the data so that the place to insert is clear
 */
     end_index = start_index + factor;
     num_points_to_move = (*points_per_group)[cur_grp] - start_index;
     EM_BLOCK_MOVE(
      (*xyz_group)[cur_grp][start_index],
      (*xyz_group)[cur_grp][end_index],
      num_points_to_move * sizeof(IGRpoint));
     EM_BLOCK_MOVE(
      (*uv1_group)[cur_grp][start_index],
      (*uv1_group)[cur_grp][end_index],
      num_points_to_move * sizeof(BSpair));
     if (uv2_group)
      EM_BLOCK_MOVE(
       (*uv2_group)[cur_grp][start_index],
       (*uv2_group)[cur_grp][end_index],
       num_points_to_move * sizeof(BSpair));
/*
 * Compute the points to insert by linear interpolation
 */
     point[0] = (*xyz_group)[cur_grp][cur_seg][0] + breaks[i].line_parameter *
               ((*xyz_group)[cur_grp][end_index][0] -
                (*xyz_group)[cur_grp][cur_seg][0]);
     point[1] = (*xyz_group)[cur_grp][cur_seg][1] + breaks[i].line_parameter *
               ((*xyz_group)[cur_grp][end_index][1] -
                (*xyz_group)[cur_grp][cur_seg][1]);
     point[2] = (*xyz_group)[cur_grp][cur_seg][2] + breaks[i].line_parameter *
               ((*xyz_group)[cur_grp][end_index][2] -
                (*xyz_group)[cur_grp][cur_seg][2]);
     if (uv2_group)
      {
       uv[0] = (*uv2_group)[cur_grp][cur_seg][0] + breaks[i].line_parameter *
               ((*uv2_group)[cur_grp][end_index][0] -
                (*uv2_group)[cur_grp][cur_seg][0]);
       uv[1] = (*uv2_group)[cur_grp][cur_seg][1] + breaks[i].line_parameter *
               ((*uv2_group)[cur_grp][end_index][1] -
                (*uv2_group)[cur_grp][cur_seg][1]);
      }
/*
 * Insert the data
 */
     for (j = start_index; j < end_index; j++)
      {
       EM_BLOCK_MOVE(
        breaks[i].uv1_coordinate,
        (*uv1_group)[cur_grp][j],
        sizeof(BSpair));
       if (uv2_group)
        EM_BLOCK_MOVE(
         uv,
         (*uv2_group)[cur_grp][j],
         sizeof(BSpair));
       EM_BLOCK_MOVE(
        point,
        (*xyz_group)[cur_grp][j],
        sizeof(IGRpoint));
      }
     (*points_per_group)[cur_grp] += factor;
/*
 * Adjust the segment counters for the new piece
 */
     num_seg_added = factor;
    }
/*
 * Break, if required
 */
   if (breaks[i].break_it != EMno_break)
    {
/*
 * Adjust the current segment such that the breaks will work.
 * Assumption is that if only one point is being inserted then it is
 * inserted on an vertex and the segment number is (vertex - 1), i.e.
 * inserted at the end.
 */
     if (factor &&
         (breaks[i].break_it == EMforward_break))
      {
       cur_seg++;
       start_index++;
      }
     num_seg_removed = cur_seg + 1;
/*
 * Compute the number of points that will remain in the old group
 * and the number of points that will be assigned to the new group.
 * Since the number of points remaining may be 1 we really should
 * not have to go through this allocation exercise if this is true.
 */
     old_num_points = cur_seg + 1;
     new_num_points = (*points_per_group)[cur_grp] - old_num_points;
/*
 * Increase the size of the control information arrays by one since we
 * are adding a new string of data
 */
     new_num_groups = *number_of_groups + 1;
     *xyz_group = (IGRpoint **) realloc(*xyz_group,
      new_num_groups * sizeof(IGRpoint *));
      if (!*xyz_group)
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     *uv1_group = (BSpair **) realloc(*uv1_group,
      new_num_groups * sizeof(BSpair *));
      if (!*uv1_group)
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     if (uv2_group)
      {
       *uv2_group = (BSpair **) realloc(*uv2_group,
        new_num_groups * sizeof(BSpair *));
        if (!*uv2_group)
         {
          *msg = MANOMEMORY;
          return(FALSE);
         }
      }
     *points_per_group = (IGRlong *) realloc(*points_per_group,
      new_num_groups * sizeof(IGRlong));
      if (!*points_per_group)
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
/*
 * Allocate space to store the new data in
 */
     (*xyz_group)[*number_of_groups] = (IGRpoint *) malloc(
      new_num_points * sizeof(IGRpoint));
      if (!(*xyz_group)[*number_of_groups])
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     (*uv1_group)[*number_of_groups] = (BSpair *) malloc(
      new_num_points * sizeof(BSpair));
      if (!(*uv1_group)[*number_of_groups])
       {
        *msg = MANOMEMORY;
        return(FALSE);
       }
     if (uv2_group)
      {
       (*uv2_group)[*number_of_groups] = (BSpair *) malloc(
        new_num_points * sizeof(BSpair));
        if (!(*uv2_group)[*number_of_groups])
         {
          *msg = MANOMEMORY;
          return(FALSE);
         }
      }
/*
 * Move the data to it's new home
 */
     (*points_per_group)[cur_grp] = old_num_points;
     (*points_per_group)[*number_of_groups] = new_num_points;
     EM_BLOCK_MOVE(
      (*xyz_group)[cur_grp][start_index],
      (*xyz_group)[*number_of_groups],
      new_num_points * sizeof(IGRpoint));
     EM_BLOCK_MOVE(
      (*uv1_group)[cur_grp][start_index],
      (*uv1_group)[*number_of_groups],
      new_num_points * sizeof(BSpair));
     if (uv2_group)
      EM_BLOCK_MOVE(
       (*uv2_group)[cur_grp][start_index],
       (*uv2_group)[*number_of_groups],
       new_num_points * sizeof(BSpair));
     *number_of_groups = new_num_groups;
    }
/*
 * If a break or insertion occurred then adjust the remaining break indices
 */
   if (factor ||
       (breaks[i].break_it != EMno_break))
    {
     IGRlong	segments_added, new_loc;
 extern  IGRdouble  fabs();
     IGRdouble	delta_u, delta_v;

     segments_added = num_seg_added - num_seg_removed;
     for (j = i + 1; j < number_of_breaks; j++)
      {
/*
 * Adjust the segment numbers for other insertions/breaks in the group
 * we just modified
 */
       if (breaks[j].group_number == cur_grp)
        {
         new_loc = breaks[j].segment_number + segments_added;
          if (new_loc < 0)
           {
            *msg = MSINARG; 
            return(FALSE);
           }
/*
 * If we have another insertion on the same segment then we must
 * recompute it's line parameter since the old one will be invalid
 */
         if (factor &&
             breaks[j].times_to_insert &&
             (breaks[j].segment_number == breaks[i].segment_number))
          {
           if (breaks[i].line_parameter > breaks[j].line_parameter)
            {
             *msg = MSINARG; 
             return(FALSE);
            }
           delta_u = (*uv1_group)[cur_grp][new_loc + 1][0] - 
                     breaks[i].uv1_coordinate[0];
           delta_v = (*uv1_group)[cur_grp][new_loc + 1][1] - 
                     breaks[i].uv1_coordinate[1];
           if (fabs(delta_u) > fabs(delta_v))
            {
             if (delta_u == 0.0)
              breaks[i].line_parameter = 1.0;
             else
              breaks[j].line_parameter = (breaks[j].uv1_coordinate[0] - 
               breaks[i].uv1_coordinate[0]) / delta_u;
            }
           else
            {
             if (delta_v == 0.0)
              breaks[i].line_parameter = 1.0;
             else
              breaks[j].line_parameter = (breaks[j].uv1_coordinate[1] - 
               breaks[i].uv1_coordinate[1]) / delta_v;
            }
          }
         breaks[j].segment_number = new_loc;
         if (breaks[i].break_it != EMno_break) 
          breaks[j].group_number = *number_of_groups - 1;
        }
      }
    }
  }
 return(TRUE);
}

