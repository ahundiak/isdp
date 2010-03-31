/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to break up the results of the
 * surface/surface instersection data such that no linestring in the parametric
 * space of the first surface intersects itself.
 *
 * It maintains compatibility between the lists, i.e. you can still find the 
 * corresponding uv parameters given an xyz index.
 *
 * RETURN VALUES
 *
 * status		if TRUE then no problems else failure
 * number_of_groups	resulting number of groups
 * points_per_group	resulting number of points per group
 * xyz_group		resulting model space points
 * uv1_group		resulting uv points in parametric space 1
 * uv2_group		resulting uv points in parametric space 2
 * msg			MSSUCC if sucess
 *			MANOMEMORY if no memory
 *			MSFAIL if severe problems (best to abort), note that
 *			this most likely implies coding or algorithm problems
 *
 * NOTES
 *
 * This routine may create linestrings which intersect other linestrings.
 *
 * This routine may create groups that have single points.  These points
 * should be ignored.
 *
 * When inserting points not at an endpoint this routine uses linear
 * interpolation to determine the corresponding points in xyz and uv2 space.
 *
 * The following tolerances are used:
 *
 * BSTOLCOLLINVEC	tolerance to check cross product for colinear vectors
 * BSTOLSQLENVEC	small distance squared (zero distance squared)
 * BSTOLLENVEC		small distance (zero distance)
 *
 * They should be adjusted by the caller to be meaningful in the parametric
 * space of the first surface.
 *
 * HISTORY
 *
 * 01/05/87 : rlw : creation date
 * 03/17/87 : rlw : modified due to argument list change in EF2dpyint()
 * 06/17/87 : sm  : corrected enum definition EMScvint_type to
 *                  EMScvinttype.
 * 04/07/88 : rlw : Modified such that degenerate 2 point groups are
 *                  broken up as per Siki's request.
 * 02/13/97 : scw : included emsmacros_c.h rather than emsmacros.h
 */

#include "OMminimum.h"			/* Required by ems include files */
#include "igetypedef.h"			/* Required by ems include files */
#include "bs.h"
#include "bsparameters.h"		/* BSEXTRACTPAR() macro */
#include "msdef.h"			/* MS error return codes */
#include "maerr.h"			/* MA error return codes */
#include "gr.h"				/* Required by ems include files */
#include <math.h>
#include "emsmacros_c.h"
#include "emsbreak.h"
#include "emsdattyp.h"
#include "emsinter.h"

IGRboolean EFself_intersect(
            number_of_groups,		/* Number of sets of data */
            points_per_group,		/* Number of points in each set */
            xyz_group,			/* Sets for model space */
            uv1_group,			/* Sets for parametric space srf 1 */
            uv2_group,			/* Sets for parametric space srf 2 */
            msg)			/* Error return code */

IGRlong		*number_of_groups;
IGRlong		**points_per_group;
IGRpoint	***xyz_group;
BSpair		***uv1_group;
BSpair		***uv2_group;
IGRlong		*msg;

{
 IGRboolean	EM2dsegbxint(), EF2dpyint(), EFsegment_breaker();
 IGRboolean	EFbuild_breaks();
 IGRboolean	status, intersection_found, intersection_possible;
 IGRlong	i, j, cur_grp, msg_loc, number_of_segments, num_brk;
 IGRdouble	dist_tol, box[4];
 IGRdouble	pars_1[2], pars_2[2];
 BSpair		points[2];
 enum		EMScvinttype type_1, type_2;
 struct		EMsegment_breaker breaks[MAXIMUM_BREAKS];
/*
 * Initialize
 */
 *msg = MSSUCC;
 cur_grp = 0;
 status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
/*
 * Process all the groups
 */
 while (cur_grp < *number_of_groups)
  {
   intersection_found = FALSE;
   number_of_segments = (*points_per_group)[cur_grp] - 1;
   if (number_of_segments == 1)
    {
     IGRdouble		tolerance_squared, distance_squared;

     status = BSEXTRACTPAR(&msg_loc, BSTOLSQLENVEC, tolerance_squared);
     distance_squared = EM2ddistptpts(		/* A macro */
       (*uv1_group)[cur_grp][0],
       (*uv1_group)[cur_grp][1]);
     if (distance_squared < tolerance_squared)
      {
       num_brk = 1;
       breaks[0].group_number = cur_grp;
       breaks[0].segment_number = 0;
       breaks[0].times_to_insert = 0;
       breaks[0].break_it = EMforward_break;
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
          if (*msg == MSINARG) *msg = MSFAIL;	/* Internal error */
          return(FALSE);
         } 
      } /* if (distance_squared < tolerance_squared) */
    } /* if (number_of_segments == 1) */
   else
    {
     for (i = 0; (i < (number_of_segments - 1)) && !intersection_found; i++)
      {
       EM2dbx(2, (*uv1_group)[cur_grp][i], box);
       EM2dbxinc(box, dist_tol)
       for (j = i + 1; (j < number_of_segments) && !intersection_found; j++)
        {
         intersection_possible = EM2dsegbxint((*uv1_group)[cur_grp][j], box);
         if (intersection_possible)
          {
           intersection_found = EF2dpyint(NULL,
                     (*uv1_group)[cur_grp][i],
                     (*uv1_group)[cur_grp][i + 1],
                     (*uv1_group)[cur_grp][j],
                     (*uv1_group)[cur_grp][j + 1],
                     &type_2, pars_2,
                     &type_1, pars_1,
                     points,
                     msg);
            if (*msg != MSSUCC) return(FALSE);	/* Should never happen */
           if (intersection_found)
            {
             status = EFbuild_breaks(
                       *points_per_group,
                       cur_grp,
                       i,
                       pars_1,
                       type_1,
                       cur_grp,
                       j,
                       pars_2,
                       type_2,
                       points,
                       &num_brk,
                       breaks,
                       msg);
             if (!status) return(FALSE);	/* Should never happen */
/*
 * If after all that we still have an intersection then call the insert/break
 * routine to rid ourselves of this vicious tumor
 */
             intersection_found = (num_brk != 0);
             if (intersection_found)
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
                  if (*msg == MSINARG) *msg = MSFAIL;	/* Internal error */
                  return(FALSE);
                 } 
              } /* if (intersection_found) */
            } /* if (intersection_found) */
          } /* (intersection_possible) */
        } /* for (j = i + 1; j < number_of_segments; j++) */
      } /* for (i = 0; i < number_of_segments - 1; i++) */
    } /* ELSE FOR if (number_of_segments == 1) */
/*
 * Go to the next intersection whether we found an intersection or not
 */
   cur_grp++;
  } /* while (cur_grp < *number_of_groups) */
/*
 * End of routine
 */
 return(TRUE);
}
