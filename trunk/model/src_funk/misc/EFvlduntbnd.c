/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

/*
  DESCRIPTION
  
   This routine validates an untrimmed group given it's beginning
   and ending points.  It determine if the group closes either
   on itself or wrt the unit square.  If the checks fail in parameteric
   space then they are carryed out in model space in order to ensure
   that no valid data is disregarded.
  
   If it is decided that the group is valid then it is "snapped" 
   to exactly close either on the unit square or on itself.  This
   implies that the input data, i.e. the data pointed at by first_point_uv, 
   last_point_uv, first_point_xyz, and last_point_xyz will be changed.
  
   If it is decided that the group does not close then is_valid is
   returned as FALSE and one or both of the xyz end points are returned
   depending upon which are not on edge, i.e. the offending xyz data is
   returned.
  
  RETURN VALUES
  
   EMmsg		EMS_S_success
  			EMS_E_DynamicMemoryAllocated
  			EMS_E_BSerror
  
   is_valid		TRUE if the input data closes
  
   number_of_points	if the group is valid then zero
                        else it will contain the number of points found
                        [1,2] at the ends of the open loop
  
   points		model space points corresponding to the endpoint(s)
                        of an open loop
                        
  NOTES
   
   number_of_points and points should be initialized before calling this
   routine
   
  HISTORY
  
   02/09/87 : rlw : creation date
   04/13/87 : rlw : Removed this functionality from EFget_loops and
                    modified the checks to also occur in model space
                    to ensure that no valid data is disregarded.
   04/24/87 : rlw : Modified due to changes in EFfind_closest_uv_side()
   05/26/87 : rlw : Removed this code from EFvlduntbnd.c so that
                    it could be also used by Sunit's routine EMvalidate_points
   07/09/93 :Sudha: Modified for BSprototypes anisfication
 */

#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif

#include "bs.h"
#include "bsparameters.h"
#include "maerr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "bssfeval.h"
#include "bsdistptpts.h"

IGRboolean EFvalidate_an_untrimmed_loop(
 surface,			/* The surface */
 u_low, u_hig,			/* Limits on the surfaces u knots */
 v_low, v_hig,			/* Limits on the surfaces v knots */
 first_point_uv,		/* First uv endpoint of loop */
 last_point_uv,			/* Last uv endpoint of loop */
 xyz_data_valid,		/* Is the input xyz data valid? */
 first_point_xyz,		/* First xyz endpoint of loop */
 last_point_xyz,		/* Last xyz endpoint of loop */
 par_tol,			/* Parameteric tolerance */
 par_sqtol,			/* Parameteric tolerance squared */
 dist_sqtol,			/* Model space tolerance squared */
 is_valid,			/* Was the loop valid? */
 number_of_points,		/* Number of bad points found [0,1,2] */
 points, 			/* Bad points found */
 EMmsg)				/* EMS error return code */

struct		IGRbsp_surface *surface;
IGRdouble	u_low, u_hig, v_low, v_hig;
IGRdouble	*first_point_uv, *last_point_uv;
IGRboolean	xyz_data_valid;
IGRdouble	*first_point_xyz, *last_point_xyz;
IGRdouble	par_tol, par_sqtol, dist_sqtol;
IGRboolean	*is_valid;
IGRlong		*number_of_points;
IGRpoint	**points;
IGRlong		*EMmsg;

{
 IGRboolean	closed, on_edge[2], EFfind_closest_uv_side();
 IGRlong	side[2], loc_msg, j;
 IGRdouble	distance_squared;
 IGRdouble	delta_u, delta_v, u_new, v_new;
 BSpair		*uv[2];
 IGRpoint	*xyz[2], point, xyz_points[2];
/*
 * Initialize
 */
 *EMmsg = EMS_S_Success;
 on_edge[0] = FALSE;
 on_edge[1] = FALSE;
 *is_valid = TRUE;
 delta_u = first_point_uv[0] - last_point_uv[0];
 delta_v = first_point_uv[1] - last_point_uv[1];
 distance_squared = delta_u * delta_u + delta_v * delta_v;
 closed = (distance_squared < par_sqtol);
/*
 * If there is no model space data then make some up
 */
 if (!xyz_data_valid)
  {
   first_point_xyz = (IGRdouble *) &xyz_points[0][0];
   last_point_xyz  = (IGRdouble *) &xyz_points[1][0];
   BSsfeval(surface, 
            first_point_uv[0],
            first_point_uv[1],
            0, 
            (IGRpoint *)first_point_xyz, 
            &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *EMmsg = EMS_E_BSerror;
      goto wrapup;
     }
   BSsfeval(surface, 
            last_point_uv[0],
            last_point_uv[1],
            0, 
            (IGRpoint *)last_point_xyz, 
            &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *EMmsg = EMS_E_BSerror;
      goto wrapup;
     }
  } /* if (!xyz_data_valid) */
/*
 * Are the endpoints on natural edges?
 */
 if (!closed)
  {
   uv[0] = (BSpair *) first_point_uv;
   uv[1] = (BSpair *) last_point_uv;
   xyz[0] = (IGRpoint *) first_point_xyz;
   xyz[1] = (IGRpoint *) last_point_xyz;
   for (j = 0; j < 2; j++)
    {
     on_edge[j] = EFfind_closest_uv_side(u_low, u_hig, v_low, v_hig,
                     (*uv[j])[0], (*uv[j])[1], par_tol, &side[j],
                     &u_new, &v_new, NULL, NULL);
     BSsfeval(surface, 
              u_new,
              v_new,
              0, 
              (IGRpoint *)point, 
              &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *EMmsg = EMS_E_BSerror;
        goto wrapup;
       }
     if (!on_edge[j])
      {
       distance_squared = BSdistptpts(
         &loc_msg, 
         (*xyz[j]),
         point);
       on_edge[j] = (distance_squared < dist_sqtol);
      }
     if (on_edge[j])
      {
       (*uv[j])[0]  = u_new;
       (*uv[j])[1]  = v_new;
       (*xyz[j])[0] = point[0];
       (*xyz[j])[1] = point[1];
       (*xyz[j])[2] = point[2];
      }
    } /* for (j = 0; j < 2; j++) */
  } /* if (!closed) */
/*
 * Does the loop close on itself?
 */
 if (! (closed || (on_edge[0] && on_edge[1])))
  {
   distance_squared = BSdistptpts(
     &loc_msg, 
     first_point_xyz,
     last_point_xyz);
   closed = (distance_squared < dist_sqtol);
  }
/*
 * Adjust, if closed
 */
 if (closed)
  {
   last_point_uv[0] = first_point_uv[0];
   last_point_uv[1] = first_point_uv[1];
   last_point_xyz[0] = first_point_xyz[0];
   last_point_xyz[1] = first_point_xyz[1];
   last_point_xyz[2] = first_point_xyz[2];
  }
/*
 * Take care of bad data
 */
 else if (! (on_edge[0] && on_edge[1]))
  {
   *is_valid = FALSE;
   for (j = 0; j < 2; j++)
    {
     if (!on_edge[j])
      {
       if (*points)
        *points = (IGRpoint *) realloc(*points, sizeof(IGRpoint) * 
          (1 + *number_of_points));
       else
        *points = (IGRpoint *) malloc(sizeof(IGRpoint));
       if (! *points)
        {
         *EMmsg = EMS_E_DynamicMemoryAllocated;
         goto wrapup;
        }
       (*points)[*number_of_points][0] = (*xyz[j])[0];
       (*points)[*number_of_points][1] = (*xyz[j])[1];
       (*points)[*number_of_points][2] = (*xyz[j])[2];
       *number_of_points = *number_of_points + 1;
      } /* if (!on_edge[j]) */
    } /* for (j = 0; j < 2; j++) */
  } /* else if (! (on_edge[0] && on_edge[1])) */
/*
 * Eof
 */
wrapup:
 if (1 & *EMmsg)
  return(TRUE);
 else
  return(FALSE);
}

#define THIS_CODE_IS_USED 0
#if THIS_CODE_IS_USED
/*
DESCRIPTION

   This function ascertains the validity of untrimmed boundaries.
   It checks to ensure that the boundaries closed either on themselves
   or with respect to the unit square.  If an invalid open loop is
   encountered then this function will return the endpoint(s) at which 
   the opening occur.  The parametric endpoints of the loops are "snapped" 
   to close either wrt the loop itself or wrt the unit square it they are 
   within tolerance of doing so.
  
RETURN VALUES

   status		TRUE if success, FALSE if failure
   number_of_points	Number of points being returned at the ends of
			open loops
   points		Points at the ends of bad open loops
   msg			MSSUCC - success
  			MANOMEMORY - no dynamic memory available
   			MSFAIL - implies that BSsfeval() has failed

NOTES

   If an invalid loop is found then it is free'ed by this routine
   and the count and pointers are set to NULL for the offending group.

HISTORY
  
   02/09/87 : rlw : creation date
   04/13/87 : rlw : Removed this functionality from EFget_loops and
                    modified the checks to also occur in model space
                    to ensure that no valid data is disregarded.
   04/24/87 : rlw : Modified due to changes in EFfind_closest_uv_side()
   05/26/87 : rlw : Removed most of the logic and placed it in a function,
                    contained in this file, such that Sunit could use
                    it for the loopset code.
 */

IGRboolean EFvalidate_untrimmed_boundaries(
  surface,                      /* Surface data */
  number_of_groups,             /* Number of loops to try and form */
  points_per_group,             /* Number of points in each group */
  uv_group,                     /* Parametric data */
  xyz_group,                    /* Model space data */
  par_tol,                      /* Parametric tolerance */
  number_of_points,             /* Number of points at end of bad open loops */
  points,                       /* Points at the end of bad open loops */
  msg)                          /* Error return code */

struct          IGRbsp_surface *surface;
IGRlong         number_of_groups;
IGRlong         points_per_group[];
BSpair          **uv_group;
IGRpoint        **xyz_group;
IGRdouble       par_tol;
IGRlong         *number_of_points;
IGRpoint        **points;
IGRlong         *msg;

{
 IGRboolean	valid_group, status, EFvalidate_an_untrimmed_loop();
 IGRlong        i, last_point, EMmsg, loc_msg;
 IGRdouble	u_low, u_hig, v_low, v_hig;
 IGRdouble      dist_tol, dist_sqtol, par_sqtol, cht;
 BSpair		*first_point_uv, *last_point_uv;
 IGRpoint	*first_point_xyz, *last_point_xyz;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *number_of_points = 0;
 *points = NULL;
 par_sqtol = par_tol * par_tol;
 status = BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, cht);
 dist_tol = 2.0 * cht;
 dist_sqtol = dist_tol * dist_tol;
/*
 * Determine the parametric values of the edges of the surface
 */
 u_low = surface->u_knots[surface->u_order - 1];
 u_hig = surface->u_knots[surface->u_num_poles];
 v_low = surface->v_knots[surface->v_order - 1];
 v_hig = surface->v_knots[surface->v_num_poles];
/*
 * Loop around all the input data
 */
 for (i = 0; i < number_of_groups; i++)
  {
/*
 * Initialize
 */
   last_point = points_per_group[i] - 1;
   first_point_uv = &uv_group[i][0][0];
   last_point_uv = &uv_group[i][last_point][0];
   first_point_xyz = &xyz_group[i][0][0];
   last_point_xyz = &xyz_group[i][last_point][0];
   status = EFvalidate_an_untrimmed_loop(
     surface,
     u_low, u_hig,
     v_low, v_hig,
     first_point_uv,
     last_point_uv,
     TRUE,
     first_point_xyz,
     last_point_xyz,
     par_tol,
     par_sqtol,
     dist_sqtol,
     &valid_group,
     number_of_points,
     points,
     &EMmsg);
   if (!status)
    {
     if (EMmsg == EMS_E_DynamicMemoryAllocated)
      *msg = MANOMEMORY;
     else
      *msg = MSFAIL;
     return(FALSE);
    }
/*
 * Free this group as it represents invalid data
 */
   if (!valid_group)
    {
     free(uv_group[i]);
     uv_group[i] = NULL;
     free(xyz_group[i]);
     xyz_group[i] = NULL;
     points_per_group[i] = 0;
    } /* if (!valid_group) */
  } /* for (i = 0; i < number_of_groups; i++) */
/*
 * End of routine
 */
 return(TRUE);
} /* eof */
#endif

