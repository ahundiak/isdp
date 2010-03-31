/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to break up the results of the
 * surface/surface instersection data such that no linestring in the parametric
 * space of the first surface intersects no other linestring in the parametric
 * space of the first surface.
 *
 * It maintains compatibility between the lists, i.e. you can still find the 
 * corresponding uv parameters given an xyz index.
 *
 * RETURN VALUES
 *
 * status               if TRUE then no problems else failure
 * number_of_groups     resulting number of groups
 * points_per_group     resulting number of points per group
 * xyz_group            resulting model space points
 * uv1_group            resulting uv points in parametric space 1
 * uv2_group            resulting uv points in parametric space 2
 * msg                  MSSUCC if sucess
 *                      MANOMEMORY if no memory
 *                      MSFAIL if severe problems (best to abort), note that
 *                      this most likely implies coding or algorithm problems
 *
 * NOTES
 *
 * This routine will remove overlaps created by two overlapping segments.  If 
 * the overlap occurs between three segments overlapping segments then it will 
 * probably not be totally removed.
 *
 * This routine may create groups that have single points.  These points
 * should be ignored.
 *
 * When inserting points not at an endpoint this routine uses linear
 * interpolation to determine the corresponding points in xyz and uv2 space.
 *
 * The following tolerances are used:
 *
 * BSTOLCOLLINVEC       tolerance to check cross product for colinear vectors
 * BSTOLSQLENVEC        small distance squared (zero distance squared)
 * BSTOLLENVEC          small distance (zero distance)
 *
 * They should be adjusted by the caller to be meaningful in the parametric
 * space of the first surface.
 *
 * HISTORY
 *
 * 01/05/87 : rlw : creation date
 * 03/17/87 : rlw : modified due to argument list change in EF2dpyint()
 * 06/18/87 : sm  : corrected enum definition EMScvint_type to
 *                  EMScvinttype.
 * 02/13/97 : SCW : included emsmacros_c.h rather than emsmacros.h
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

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */
#include "msmacros.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "emsbreak.h"
#include <math.h>
#include "emsmacros_c.h"
#include "emsdattyp.h"
#include "emsinter.h"

IGRboolean EFgroup_intersect(
            number_of_groups,           /* Number of sets of data */
            points_per_group,           /* Number of points per set */
            xyz_group,                  /* Sets of model space data */
            uv1_group,                  /* Sets of parametric data srf 1 */
            uv2_group,                  /* Sets of parametric data srf 2 */
            msg)                        /* Error return code */

IGRlong         *number_of_groups;
IGRlong         **points_per_group;
IGRpoint        ***xyz_group;
BSpair          ***uv1_group;
BSpair          ***uv2_group;
IGRlong         *msg;

{
 void           EM2dbx();
 IGRboolean     EM2dsegbxint(), EF2dpyint(), EFbuild_breaks();
 IGRboolean     EFsegment_breaker();
 IGRboolean     status, line_box_test, box_box_test, intersection_found;
 IGRlong        i, j, k, cur_grp, tst_grp, msg_loc, old_num_groups;
 IGRlong        num_groups_formed, num_brk;
 IGRdouble      dist_tol, box[4];
 IGRdouble      pars_1[2], pars_2[2];
 BSpair         points[2];
 enum           EMScvinttype type_1, type_2;
 struct         EMsegment_breaker breaks[MAXIMUM_BREAKS];

 typedef        IGRdouble uv_range[4];
 uv_range       *range_boxes;
/*
 * Initialize
 */
 *msg = MSSUCC;
 if (*number_of_groups < 2) return(TRUE);
 range_boxes = NULL;
 status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
/*
 * Compute the ranges of all the groups
 */
 range_boxes = (uv_range *) malloc(*number_of_groups * sizeof(uv_range));
  if (!range_boxes)
   {
    *msg = MANOMEMORY;
    return(FALSE);
   }
 for (i = 0; i < *number_of_groups; i++)
  {
   EM2dbx((*points_per_group)[i], (*uv1_group)[i], range_boxes[i]);
   EM2dbxinc(range_boxes[i], dist_tol)
  }
/*
 * Process all the groups
 */
 cur_grp = 0;
 while (cur_grp < (*number_of_groups - 1))    /* While there is a next group */
  {
   for (tst_grp = cur_grp + 1; 
        (tst_grp < *number_of_groups) &&
        ((*points_per_group)[cur_grp] > 1);
        tst_grp++)                      /* For all remaining groups */
    {
/*
 * Compare the range of the control group (cur_grp) with the test group
 * (tst_grp). If the box test fails then do nothing the loop will 
 * automatically increment the test group.  If the box test passes 
 * then we must look into the test group.
 */
     if ((*points_per_group)[tst_grp] < 2)
      box_box_test = FALSE;
     else
      box_box_test = EM2dbxbxint(range_boxes[cur_grp], range_boxes[tst_grp]);
     if (box_box_test)
      {
/* 
 * We know that the boxes intersect.  Loop through and intersect all the
 * segments of the controlling group with the test group.  This process
 * terminates when one of the following conditions becomes true:
 *
 * 1) All segments have been exhausted.
 * 2) The controlling group has vanished to a point
 * 3) The test group has vanished to a point
 */
       for (i = 0; 
            (i < ((*points_per_group)[cur_grp] - 1)) &&
            ((*points_per_group)[tst_grp] > 1);
            i++)
        {
/*
 * Compare the range of the control group line segment to the test group.
 * If this test passes then enter a loop to check all the line segments
 * in the test group for intersections with the control group line segment.
 */
         line_box_test = EM2dsegbxint((*uv1_group)[cur_grp][i],
                           range_boxes[tst_grp]);
         if (line_box_test)
          {
           EM2dbx(2, (*uv1_group)[cur_grp][i], box);
           EM2dbxinc(box, dist_tol)
           for (j = 0;
                (j < ((*points_per_group)[tst_grp] - 1)) &&
                (i < ((*points_per_group)[cur_grp] - 1));
                j++)
            {
/*
 * Check to see if the line segment in the test group intersects the range
 * box of the line segment in the control group
 */
             line_box_test = EM2dsegbxint((*uv1_group)[tst_grp][j], box);
             if (line_box_test)
              {
               intersection_found = EF2dpyint(NULL,
                 (*uv1_group)[cur_grp][i],
                 (*uv1_group)[cur_grp][i + 1],
                 (*uv1_group)[tst_grp][j],
                 (*uv1_group)[tst_grp][j + 1],
                 &type_2, pars_2,
                 &type_1, pars_1,
                 points, msg);
                 if (*msg != MSSUCC)
                  {
                   if (range_boxes) free(range_boxes);
                   return(FALSE);
                  }
                if (intersection_found)
                 {
/*
 * Unfortunately, we have found an intersection.  Build a break instruction
 * list based on the type of intersection found.
 */
                  status = EFbuild_breaks(
                            *points_per_group,
                            cur_grp,
                            i,
                            pars_1,
                            type_1,
                            tst_grp,
                            j,
                            pars_2,
                            type_2,
                            points,
                            &num_brk,
                            breaks,
                            msg);
                   if (!status) return(FALSE);  /* Should never happen */
/*
 * Break 'er up
 */
                  old_num_groups = *number_of_groups;
                  if (num_brk)
                   {
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
                       if (*msg == MSINARG) *msg = MSFAIL; /* Internal error */
                       if (range_boxes) free(range_boxes);
                       return(FALSE);
                      }
/*
 * We must recompute the ranges of the cur_grp, tst_grp, and of the new
 * groups formed by this break.
 */
                    EM2dbx((*points_per_group)[cur_grp], (*uv1_group)[cur_grp],
                           range_boxes[cur_grp]);
                    EM2dbxinc(range_boxes[cur_grp], dist_tol)
                    EM2dbx((*points_per_group)[tst_grp], (*uv1_group)[tst_grp],
                           range_boxes[tst_grp]);
                    EM2dbxinc(range_boxes[tst_grp], dist_tol)
                    num_groups_formed = *number_of_groups - old_num_groups;
                    if (num_groups_formed)
                     {
                      range_boxes = (uv_range *) realloc(range_boxes,
                       *number_of_groups * sizeof(uv_range));
                       if (!range_boxes)
                        {
                         *msg = MANOMEMORY;
                         return(FALSE);
                        }
                      for (k = old_num_groups; k < *number_of_groups; k++)
                       {
                        EM2dbx((*points_per_group)[k], (*uv1_group)[k],
                               range_boxes[k]);
                        EM2dbxinc(range_boxes[k], dist_tol)
                       } /* for (k = old_num_groups; k < *number_of_groups */
                     } /* if (num_groups_formed) */
                   } /* if (num_brk) */
                 } /* if (intersection_found) */
              } /* if (line_box_test) */
            } /* for (j = 0; (j < ((*points_per_group)[tst_grp] - 1)) &&
                (i < ((*points_per_group)[cur_grp] - 1)); j++) */
          } /* if (line_box_test) */
        } /* for (i = 0; i < ((*points_per_group)[cur_grp] - 1); i++) */
      } /* if (box_box_test) */
    } /* for (tst_grp = cur_grp + 1; tst_grp < *number_of_groups; tst_grp++) */
/*
 * Increment the current group
 */
   cur_grp++;
  } /* while (cur_grp < (*number_of_groups - 1)) */
/*
 * End of routine
 */
 if (range_boxes) free(range_boxes);
 return(TRUE);
}
