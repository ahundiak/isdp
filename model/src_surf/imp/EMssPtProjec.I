/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
  
 This method returns the closest point on a surface to the input point.
 The parameters of the point on the surface are also returned.
  
 RETURN VALUES
 
 proj_pt                The closest point on the surface to the input point
  
 proj_parms             The surface parameters corresponding to the proj_pt.
  
 msg                    MSSUCC if success
                        MANOMEMORY if no memory
                        MSFAIL if problems 
  
 NOTES
  
 This routine gets the abstract geometry for the surface and finds
 the minimum distance point using the bs math.  If the surface has
 no boundaries then the point is merely returned.  If the surface
 has boundaries then a message is sent to the loopset to perform
 a point location.  This method will return the closest point, in
 (u,v) space, which is in an area region or on an edge.
  
 BUGS

 If the surface has boundaries then it is certainly possible that
 the true minimum distance point will not be returned.  In order to
 solve this problem one would have to find all points on the surface
 who's normals pass pass through the input point and would also have
 to consider cusp and edge curves.  This would require extensive
 math support and computation time would be expensive.

 In additon the loopset point location method will "snap" the point
 to the edge of the most nested loop it is contained in, not to the
 nearest edge.

 HISTORY
  
 06/27/86 : rlw : The beginning
 09/21/86 : rlw : OM 4.0 conversion
 01/26/87 : rlw : Rewritten as per nucleus changes to return GRparms
 05/25/87 : rlw : Basically rewritten to use loopsets.
 01/13/93 : WBC : Replaced the call to BSmdistptsf with a call to BSprptarrsf.
 07/07/93 : Sudha Modified for BSprototypes ansification

 */

class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0

#if DEBUG
#include <stdio.h>
#endif

# include "EMSprop.h"
# include "EMSopt.h"
#include "OMminimum.h"          /* for gocmacros.h  */
#include "igrtypedef.h"         /* for gocmacros.h  */
#include "gocmacros.h"          /* GRgetabsg macro  */
#include "msdef.h"              /* MS message codes */
#include "madef.h"              /* MA message codes */
#include "bserr.h"              /* BS message codes */
#include "EMSbnddef.h"          /* EMS loopset properties keywords */
#include "EMSbnd.h"             /* EMS information structures */
#include "EMSmsgdef.h"          /* EMS error return codes */
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bsprptarrsf.h"
#include "bsfreecv.h"
#include "bsdistptpts.h"

#define WBC_USE_NEW_MATH 1

from EMSloopset import EMget_props, EMpt_location;

method GRptproject(
  IGRlong       *msg;                   /* Error return code */
  IGRshort      *matrix_type;           /* My matrix type */
  IGRmatrix     matrix;                 /* My module matrix */
  IGRpoint      point;                  /* The input point */
  IGRpoint      proj_pt;                /* The projected point */
  struct        GRparms *proj_parms)    /* The projected parms */

{
 IGRchar                *generic_pointer;
extern void EFinit_geom_surface() ;
#if !WBC_USE_NEW_MATH
 IGRboolean             status;
#endif
 IGRboolean             all_on_surf;
 IGRlong                sts, loc_msg;
 IGRint                 num_pts;
#if !WBC_USE_NEW_MATH
 IGRdouble              distance;
#endif
 IGRdouble              dist_tol;
 BSpair                 uv_point;
 IGRpoint               xyz_point;
 struct                 IGRbsp_surface *surface;
 struct BSgeom_bsp_surf geom_surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 geom_surface.sfgen_cv = NULL;
/*
 * Initialize the projection parameters
 */
 proj_parms->u = 0.0;
 proj_parms->v = 0.0;
 proj_parms->polygon_inx = 0;
 proj_parms->leaf_id.objid = my_id;
 proj_parms->leaf_id.osnum = OM_Gw_current_OS;
/*
 * Generate my abstract data
 */
 GRgetabsg(msg, matrix_type, matrix, &generic_pointer, i);
  if (! (1 & *msg)) goto wrapup;
 surface = (struct IGRbsp_surface *) generic_pointer;
/*
 * Project this point onto the surface
 */

#if WBC_USE_NEW_MATH
 EFinit_geom_surface(&loc_msg, surface, my_id, OM_Gw_current_OS,
                     &geom_surface);
 if (! (1 & loc_msg)) goto wrapup;

 BSEXTRACTPAR (&loc_msg, BSTOLLENVEC, dist_tol);
 num_pts = 1;

 BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, point, uv_point,
             xyz_point, &all_on_surf, NULL, &loc_msg);
 if (loc_msg != BSSUCC)
 {
  *msg = MSFAIL;
  goto wrapup;
 }
#else
 status = BSmdistptsf(
   &loc_msg, 
   surface, 
   point, 
   &uv_point[0],
   &uv_point[1],
   xyz_point,
   &distance);
 if (!status)
  {
   *msg = MSFAIL;
   goto wrapup;
  }
#endif
/*
 * Adjust the point such that it lies in area
 */
 {
  IGRboolean            was_in_area;
  IGRlong               best_solution, EFclassify_points_wrt_loopset();
  BSpair                uv_solution;
  IGRpoint              xyz_solution;
  OM_S_CHANSELECT       to_my_loopset;

  to_my_loopset.type = OM_e_addr;
  to_my_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset; 
  sts = EFclassify_points_wrt_loopset(
    &to_my_loopset,
    my_id,
    matrix_type,
    matrix,
    surface,
    1,                          /* Only one point to classify */
    uv_point,
    xyz_point,
    &best_solution,
    &was_in_area,
    uv_solution,
    xyz_solution,
    msg);
   if (! (1 & sts)) goto wrapup;
  proj_parms->u = uv_solution[0];
  proj_parms->v = uv_solution[1];
  proj_pt[0] = xyz_solution[0];
  proj_pt[1] = xyz_solution[1];
  proj_pt[2] = xyz_solution[2];
 }
/*
 * Eof
 */
wrapup:

 if (geom_surface.sfgen_cv)
    BSfreecv(&loc_msg, geom_surface.sfgen_cv);

 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

/*
 * This function accepts a list of points, lying on a particular surface,
 * and returns an index to which point was found to be the closest to
 * it's corresponding input point.
 *
 * Error return codes:
 *
 * sts          OM_S_SUCCESS or OM_E_ABORT
 *
 * msg          MSINARG - no input points
 *              MSFAIL  - it just didn't work
 *              MSSUCC  - it worked
 *
 * rlw : 05/24/87 : Creation date
 * SM  : 04-Feb-87: Modified status check after EMpt_location message
		    to (!(1&sts&EMmsg)) instead of explicit check of return
		    code.
   SM  : 08-Jun-92: Use EMS_PTLOC_CLOSEST_EDGE in point location.
 */

IGRlong EFclassify_points_wrt_loopset(
 to_my_loopset,         /* Channel selector to the surfaces loopset */
 my_stupid_id,          /* The surface's object id */
 matrix_type,           /* The surface's matrix type */
 matrix,                /* The surface's matrix */
 surface,               /* The surface */
 number_of_points,      /* Number of points that you are giving me */
 uv_points,             /* Your points in the surfaces parametric space */
 xyz_points,            /* Your points in the surfaces model space */
 best_solution,         /* Index to the best solution I could find */
 was_in_area,           /* Notification if the best solution came from */
                        /* an input point that  was in area */
 uv_solution,           /* The uv of the best solution */
 xyz_solution,          /* The xyz of the best solution */
 msg)                   /* The error return code */

OM_S_CHANSELECT         *to_my_loopset;
OM_S_OBJID              my_stupid_id;
IGRshort                *matrix_type;
IGRmatrix               matrix;
struct                  IGRbsp_surface *surface;
IGRlong                 number_of_points;
BSpair                  uv_points[];
IGRpoint                xyz_points[];
IGRlong                 *best_solution;
IGRboolean              *was_in_area;
BSpair                  uv_solution;
IGRpoint                xyz_solution;
IGRlong                 *msg;

{
 IGRushort      loopset_properties;
 IGRlong                sts, i, EMmsg, loc_msg;
 IGRdouble              min_dist_sq;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Any data passed in?
 */
 if (number_of_points < 1)
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Check if the loopset is natural.  I initialize it to natural so that
 * if no loopset is present I will think that the loopset answered
 * that is was, in fact, natural.
 */
 loopset_properties = EMLS_NATURAL;
 sts = om$send(msg = message EMSloopset.EMget_props(
                &EMmsg,
                &loopset_properties),
               p_chanselect = to_my_loopset,
               senderid = my_stupid_id);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * If the loopset was natural then any of the solutions will do
 */
 if (loopset_properties & EMLS_NATURAL)
  {
   *best_solution = 0;
   *was_in_area =  TRUE;
   uv_solution[0] = uv_points[0][0];
   uv_solution[1] = uv_points[0][1];
   xyz_solution[0] = xyz_points[0][0];
   xyz_solution[1] = xyz_points[0][1];
   xyz_solution[2] = xyz_points[0][2];
#if DEBUG
fprintf(stderr, "\nLoopset is natural");
#endif
  }
/*
 * Unfortunately the loopset was not natural.  Setup all the stuff and
 * then loop around all the input points until we find a point in area
 * or all the input points have been exhausted.  If no point was found
 * in area then return the best point that we found.
 */
 else
 {
  struct EMSptloc_info location_information;
  struct EMSpartolbasis partolbasis;

/*
 * Initialze the parameter basis tolerance
 */
  {

   BSsfkttol2(surface->u_order,
              surface->v_order,
              surface->u_knots,
              surface->v_knots,
              surface->u_num_poles,
              surface->v_num_poles,
              surface->poles,
              surface->weights,
              &partolbasis.tol,
              &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   partolbasis.is_valid = TRUE;
   partolbasis.in_world = TRUE;
   partolbasis.mattyp = matrix_type;
   partolbasis.mat = (IGRdouble *) &matrix[0];
  }
#if DEBUG
 fprintf(stderr, "\nLoopset is not natural");
#endif
/*
 * Setup the point location option mask
 */
  location_information.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_CLOSEST_EDGE;
/*
 * Send a message to my loopset to perform a point location
 * with the appropriate options
 */
  for (i = 0, *was_in_area = FALSE;
       (i < number_of_points) && (! (*was_in_area));
       i++)
   {
#if DEBUG
fprintf(stderr, "\nCalling point location with u %lf v %lf",
        uv_points[i][0], uv_points[i][1]);
#endif
    sts = om$send(msg = message EMSloopset.EMpt_location(
                   &EMmsg,
                   uv_points[i],
                   &location_information,
                   &partolbasis),
                  p_chanselect = to_my_loopset,
                  senderid = my_stupid_id);
     if (!(1 & sts & EMmsg))
      {
#if DEBUG
fprintf(stderr, "\nEMSloopset.EMpt_location error %x\n", EMmsg);
om$report_error(sts = sts);
#endif
       *msg = MSFAIL;
       goto wrapup;
      }
/*
 * Interpret the results
 */
    switch (location_information.location)
     {
      case EMS_L_INAREA:
      case EMS_L_ONEDGE:
      case EMS_L_ONVRTX:
       *best_solution = i;
       *was_in_area =  TRUE;
       uv_solution[0] = uv_points[i][0];
       uv_solution[1] = uv_points[i][1];
       xyz_solution[0] = xyz_points[i][0];
       xyz_solution[1] = xyz_points[i][1];
       xyz_solution[2] = xyz_points[i][2];
       break;
      case EMS_L_INHOLE:
      case EMS_L_UNKNWN:      /* two edges implies closest thing was vertex */
       if (location_information.num_located_edges)
        {
         BSpair         guess_uv;
         IGRdouble      distance_sq;
         IGRpoint       guess_xyz;

         guess_uv[0] = location_information.edge[0].nst_pt.proj_pt[0];
         guess_uv[1] = location_information.edge[0].nst_pt.proj_pt[1];
#if DEBUG
fprintf(stderr, "\nGuess u %lf v %lf", guess_uv[0], guess_uv[1]);
#endif
         BSsfeval(
           surface, 
           guess_uv[0],
           guess_uv[1],
           0, 
           (IGRpoint *)guess_xyz,
           &loc_msg);
          if (loc_msg != BSSUCC)
           {
            *msg = MSFAIL;
            goto wrapup;
           }
         distance_sq = BSdistptpts(
           &loc_msg,
           xyz_points[i],
           guess_xyz);
         if (i)                         /* Not first pass? */
          {
           if (distance_sq < min_dist_sq)
            {
             *best_solution = i;
             uv_solution[0] = guess_uv[0];
             uv_solution[1] = guess_uv[1];
             xyz_solution[0] = guess_xyz[0];
             xyz_solution[1] = guess_xyz[1];
             xyz_solution[2] = guess_xyz[2];
            } /* if (distance_sq < min_dist_sq) */
          } /* if (i) */
         else
          {
           min_dist_sq = distance_sq;
           *best_solution = 0;
           uv_solution[0] = guess_uv[0];
           uv_solution[1] = guess_uv[1];
           xyz_solution[0] = guess_xyz[0];
           xyz_solution[1] = guess_xyz[1];
           xyz_solution[2] = guess_xyz[2];
          } /* ELSE FOR if (i) */
        }
       else                             /* Should never happen */
        {
#if DEBUG
fprintf(stderr, "\nLocated edge cout is %d",
        location_information.num_located_edges);
#endif
         *msg = MSFAIL;
         goto wrapup;
        } /* ELSE FOR if (location_information.num_located_edges) */
       break;
      default:                          /* Should never happen */
#if DEBUG
fprintf(stderr, "\nDefault case, location is %x", 
        location_information.location);
#endif
       *msg = MSFAIL;
       goto wrapup;
       break;
     }   
   } /* for (i = 0, *was_in_area = FALSE; (i < number_of_points ...)) */
 } /* ELSE FOR if (loopset_properties & EMLS_NATURAL) */
/*
 * Eof
 */
wrapup:
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation EMSsubbs;
