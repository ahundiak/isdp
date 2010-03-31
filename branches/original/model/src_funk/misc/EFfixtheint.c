/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/* 
DESCRIPTION
  
   The purpose of this routine is to try and break up the output of the
   surface/surface intersection routine such that:
  
   1) Data which is near the natural edges is moved to the natural edges.

   2) Removes edges which lie along natural edges (makes sense only if
      one surface is input) OR make sure that seam intersections do
      not occur in the parameteric data twice.

   3) No jump occurs in parametric space when there is not a corresponding
      jump in model space.
  
   4) The parametric linestrings do not intersect themselves.
  
   5) The parametric linestrings do not intersect with any other parametric
      linestrings in the same space.
  
   It maintains compatibility between the lists, i.e. you can still find the 
   corresponding uv parameters given an xyz index.
  
UPDATE (2/9/92)

   This function was originally called "EFfix_the_intesection". I had to add an
   argument to this function and therefore I changed the name to "EFfix_the_int"
   so that upstream users of this function may know that it has been modified.
   The reason for the update is as follows:
 	Originally, for EMS 1.4, we were using only poly intersection data. With
   the new math for 2.0, we are able to use intersection Bspline curves too. 
   In the boolean code, we may decide to use Bspline curves for either/both XYZ
   and/or UV data for the intersection surfaces. This function is called to
   check for jumps in UV space of parametric data and other such checks. We pass
   only the xyz and uv POLY data to this function and NOT the "Bspline curve" 
   data. During the various function calls in this function, it is possible that
   we may insert points and break up the the input data such that the number of
   intersection groups is increased. However we  have NOT split the 
   corresponding "Bspline curve" data for these intersection curves. Therefore,
   if we decide to use, in the calling function,  the "Bspline curve" data for
   one surface and the POLY data for the other, then there is the possibility of
   a mismatch between the surfaces, if the intersections were broken up in 
   this function. 
    	In the special case that necessitated the change of this 
   function's name, the intersections were split but the degenerate intersectio-
   ns were deleted resulting in the SAME number of intersections output
   as were input. HOWEVER, due to the peculiar nature of some of the functions,
   the intersection data was now REVERSED. By that I mean, the first group or
   intersection was last and the last was first. Obviously, this was creating 
   a mismatch between the Bspline curve data and the poly data. Therefore, I 
   have added a new parameter to this function called "groups_modified", that 
   would flag any modification made to the input intersection data. 
   Since the number of groups could be increased and then decreased to its
   original input value, (WITHIN this function as stated above), it was not 
   sufficient to make a check only at the very end and therefore, is made after
   ALL functions that could potentially change the number of intersections.
   If the user does not care if the intersections were modified or not, a NULL
   can be passed in for "groups_modified".
									Navin.
UPDATE (06/17/93)

   Parameter "groups_modified"  (IGRboolean) is now changed to "groups_fixed",
   (IGRushort). Will now return bits indicating type of fixing done.


RETURN VALUES
  
   status               if TRUE then no problems else failure
   groups_fixed         Will contain bits indicating how the input data was
                        modified/fixed.
                        (If caller does not wish to know if input groups were
                         modified or not, this can be passed as NULL into this
                         function)
   number_of_groups     resulting number of groups
   points_per_group     resulting number of points per group
   xyz_group            resulting model space points
   uv1_group            resulting uv points in parametric space 1
   uv2_group            resulting uv points in parametric space 2
   msg                  MSSUCC if sucess
                        MANOMEMORY if no memory
                        MSFAIL if severe problems (best to abort), note that
                        this most likely implies coding, algorithm, or
                        math problems
  
NOTES
  
   All resulting linestrings will consist of two or more points.
  
   Linear interpolation is used to compute coordinates in the other two
   spaces.
  
   If an error occurs then the results (xyz, uv1, uv2, points_per_group)
   are not freed.
  
HISTORY
  
   01/06/87 : rlw : creation date
   02/04/87 : rlw : Changed to also adjust the cross product tolerance in
                    parametric space.  Also changed due to change in argument
                    list in fix jump.
   04/24/87 : rlw : Modified due to changes in argument list of EFfix_jumps()
   06/03/87 : rlw : Added code to skip fix jumps if neither of the input
                    surfaces is physically closed
   10/07/87 : rlw : Added option to remove collapsed edges
   01/20/92 : np  : There was an error in check to calculate "number_of_loops".
                    ("uv_group_2" had been mistakenly written as "uv2_group").
                    As a result sometimes a surface with parametric jumps was
                    not sent thro the loop.
   02/09/92 : np  : Added an argument "modified_groups" and hence changed the 
                    name of this function  from "EFfix_the_intersections" to 
                    "EFfix_the_int". For reasons why see the "UPDATE" column 
                    above.
   06/17/93 : np  : Argument "groups_modified" is now changed to the argument
                    "groups_fixed", an option type of argument, which will
                    return bits indicating exactly how the groups were fixed or
                    modified.
   07/09/93 :Sudha: Modified for BSprototypes anisfication

 */

#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif

#include "EMS.h"
#include "emssfintdef.h" /* fixing options */
#include "bs.h"
#include "bsparameters.h"
#include "msdef.h"
#include "bssfkttol2.h"
#include "bschangepar.h"


IGRboolean EFfix_the_int(
            groups_fixed,       /* Tells how input data was fixed/modified */
            remove_the_edges,	/* Should collapsed edges be chunked */
            surface_1,          /* First surface data */
            surface_2,          /* Second surface data */
            number_of_groups,   /* Number of sets of data */
            points_per_group,   /* Number of points in each set */
            xyz_group,          /* Sets for model space */
            uv_group_1,         /* Sets for parametric space srf 1 */
            uv_group_2,         /* Sets for parametric space srf 2 */
            msg)                /* Error return code */

IGRushort       *groups_fixed;
IGRboolean      remove_the_edges;
struct          IGRbsp_surface *surface_1;
struct          IGRbsp_surface *surface_2;
IGRlong         *number_of_groups;
IGRlong         **points_per_group;
IGRpoint        ***xyz_group;
BSpair          ***uv_group_1;
BSpair          ***uv_group_2;
IGRlong         *msg;

{
 IGRboolean     status, EFfix_jumps(), EFself_intersect();
 IGRboolean     EFgroup_intersect(), EFcompress_groups();
 IGRboolean	EFremove_collapsed_edges();
IGRboolean   need_to_fix_jumps;
 IGRlong        i, msg_loc, number_of_loops;
 IGRdouble      par_tol[2], dist_tol, dist_sqtol, cross_tol;
 BSpair         ***uv1_group, ***uv2_group;
 IGRint         current_number_of_groups;
 IGRushort      groups_fixed_loc;
/*
 * Initialize
 */
#if DEBUG
fprintf(stderr, "\nEnter EFfixtheint.c");
#endif
 *msg = MSSUCC;

 groups_fixed_loc = NULL;
 current_number_of_groups = *number_of_groups;

 status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
 status = BSEXTRACTPAR(&msg_loc, BSTOLSQLENVEC, dist_sqtol);
 status = BSEXTRACTPAR(&msg_loc, BSTOLCOLLINVEC, cross_tol);

 BSsfkttol2(surface_1->u_order,
            surface_1->v_order,
            surface_1->u_knots,
            surface_1->v_knots,
            surface_1->u_num_poles,
            surface_1->v_num_poles,
            surface_1->poles,
            surface_1->weights,
            &par_tol[0],
            &msg_loc);
  if (msg_loc != BSSUCC)
   {
#if DEBUG
fprintf(stderr, "\nBSsfkttol2 error %d",  msg_loc);
#endif
    *msg = MSFAIL;
    goto wrapup;
   }

if (surface_2  && uv_group_2)
 {
   BSsfkttol2(surface_2->u_order,
              surface_2->v_order,
              surface_2->u_knots,
              surface_2->v_knots,
              surface_2->u_num_poles,
              surface_2->v_num_poles,
              surface_2->poles,
              surface_2->weights,
              &par_tol[1],
              &msg_loc);
    if (msg_loc != BSSUCC)
     {
#if DEBUG
fprintf(stderr, "\nBSsfkttol2 error %d",  msg_loc);
#endif
      *msg = MSFAIL;
      goto wrapup;
     }
 }



 need_to_fix_jumps = (surface_1->u_phy_closed ||
                      surface_1->v_phy_closed ||
                      (surface_2 &&
                       (surface_2->u_phy_closed ||
                        surface_2->v_phy_closed)));
/*
 * Determine how many times to loop
 */
 if ((surface_2 == NULL) || (uv_group_2 == NULL))
  number_of_loops = 1;
 else
   number_of_loops = 2;


/*
 * Enter a loop to process wrt both parametric spaces
 */
 for (i = 0; i < number_of_loops; i++)
  {
/*
 * Pick the appropriate parametric space
 */
   if (i)
    {
     uv1_group = uv_group_2;
     uv2_group = uv_group_1;
    }
   else
    {
     uv1_group = uv_group_1;
     uv2_group = uv_group_2;
    }
/*
 * Insure that no illegal jumps across parametric space occur
 */
   if (need_to_fix_jumps)
    {
     status =  EFfix_jumps(
                (i ? surface_2 : surface_1),
                (i ? surface_1 : surface_2),
                (i ? par_tol[1] : par_tol[0]),
                (i ? par_tol[0] : par_tol[1]),
                dist_sqtol,
                number_of_groups,
                points_per_group,
                xyz_group,
                uv1_group,
                uv2_group,
                msg);
     /* Check to see if above call has changed the number of intersections
      * that originally came into this function.
      */
      if (*number_of_groups  != current_number_of_groups)
      { current_number_of_groups = *number_of_groups;
        groups_fixed_loc |= EMSdebug_intdata_fixed_jumps; 
      }

      if (!status) 
       {
#if DEBUG
fprintf(stderr, "\nEFfix_jumps error %x", *msg);
#endif
        goto wrapup;
       }
    } /* if (need_to_fix_jumps) */
/*
 * Remove or shift edges lying on seam edges
 * Also moves data near edges to the edges
 */
   status =  EFremove_collapsed_edges(
              remove_the_edges,
              (i ? surface_2 : surface_1),
              par_tol[i],
              number_of_groups,
              points_per_group,
              xyz_group,
              uv1_group,
              uv2_group,
              msg);
     /* Check to see if above call has changed the number of intersections
      * that originally came into this function.
      */
      if (*number_of_groups  != current_number_of_groups)
      { current_number_of_groups = *number_of_groups;
        groups_fixed_loc |= EMSdebug_intdata_fixed_edge_ints; 
      }

    if (!status) 
     {
#if DEBUG
fprintf(stderr, "\nEFremove_collapsed_edges error %x", *msg);
#endif
      goto wrapup;
     }
/*
 * Adjust tolerances
 */
   status = BSchangepar(&msg_loc, BSTOLLENVEC, par_tol[i]);
   status = BSchangepar(&msg_loc, BSTOLSQLENVEC, par_tol[i] * par_tol[i]);
   status = BSchangepar(&msg_loc, BSTOLCOLLINVEC, 0.5 * par_tol[i]);
/*
 * Insure that none of the intersections intersect themselves
 */
   status =  EFself_intersect(
              number_of_groups,
              points_per_group,
              xyz_group,
              uv1_group,
              uv2_group,
              msg);
    /* Check to see if above call has changed the number of intersections
      * that originally came into this function.
      */
      if (*number_of_groups  != current_number_of_groups)
      { current_number_of_groups = *number_of_groups;
        groups_fixed_loc  |= EMSdebug_intdata_fixed_self_intr;
      }

    if (!status) 
     {
#if DEBUG
fprintf(stderr, "\nEFself_intersect error %x", *msg);
#endif
      goto wrapup;
     }
/*
 * Insure that none of the intersections intersect any of the other
 * intersections
 */
   status =  EFgroup_intersect(
              number_of_groups,
              points_per_group,
              xyz_group,
              uv1_group,
              uv2_group,
              msg);
    /* Check to see if above call has changed the number of intersections
      * that originally came into this function.
      */
      if (*number_of_groups  != current_number_of_groups)
      { current_number_of_groups = *number_of_groups;
        groups_fixed_loc |= EMSdebug_intdata_fixed_grp_intr;
      }

    if (!status) 
     {
#if DEBUG
fprintf(stderr, "\nEFgroup_intersect error %x", *msg);
#endif
      goto wrapup;
     }
/*
 * Get rid of all groups with just one member
 */
   status =  EFcompress_groups(
              number_of_groups,
              points_per_group,
              xyz_group,
              uv1_group,
              uv2_group,
              msg);
    /* Check to see if above call has changed the number of intersections
      * that originally came into this function.
      */
      if (*number_of_groups  != current_number_of_groups)
      { current_number_of_groups = *number_of_groups;
        groups_fixed_loc |= EMSdebug_intdata_fixed_degen_intr;
      }

    if (!status) 
     {
#if DEBUG
fprintf(stderr, "\nEFcompress_groups error %x", *msg);
#endif
      goto wrapup;
     }
/*
 * Restore the tolerances
 */
   status = BSchangepar(&msg_loc, BSTOLLENVEC, dist_tol);
   status = BSchangepar(&msg_loc, BSTOLSQLENVEC, dist_sqtol);
   status = BSchangepar(&msg_loc, BSTOLCOLLINVEC, cross_tol);
  } /* for (i = 0; i < 2; i++) */
/*
 * End of routine
 */
wrapup:
#if DEBUG
fprintf(stderr, "\nLeaving EFfixtheint.c");
#endif
 status = BSchangepar(&msg_loc, BSTOLLENVEC, dist_tol);
 status = BSchangepar(&msg_loc, BSTOLSQLENVEC, dist_sqtol);
 status = BSchangepar(&msg_loc, BSTOLCOLLINVEC, cross_tol);

 /* pass back the info as to whether the input intersections were modified in
  * any manner at all.
  */
 if (groups_fixed)
   *groups_fixed = groups_fixed_loc;

 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}
