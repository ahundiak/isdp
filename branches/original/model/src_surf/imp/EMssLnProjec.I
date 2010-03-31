/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
  
 This method returns the closest point on a surface to the input boreline.
 The parameters of the point on the surface are also returned.
  
 RETURN VALUES
 
 line_pt                The closet point on the line to the surface.

 surf_pt                The closest point on the surface to the line.

 t                      The parameter on the line corresponding to the
                        closest point on the line to the surface.

 proj_parms             The surface parameters corresponding to the surf_pt.
  
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
 who's normals pass pass through the input line and would also have
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

 08 Dec 87  AIC   KLUGED to perform wireframe check if locating.

 12/14/87 : pp :  made rlw_get_better_line nonstatic because I
                  felt I could use it too.

 29 Jun 88  AIC   Removed locate KLUGE.
 09/07/88 : DLB:  Added code to sort surface intersection points wrt.
                  incoming boreline point[0] (by distance).  The idea is
                  to choose the best point when there are 2 or more
                  intersections on the surface.  Note that I use a brute
                  force sort since there will almost always be 2 or less
                  points to sort.  
08/25/92  : NP    Modified for ANSI compliance. Variable "distance_sq" had been
		  typecast on allocation to "struct IGRdouble *". The things you see
		  in these files.....!!!!! 
*/

class implementation EMSsubbs;


# define LOCATE_KLUGE 0
# define DEBUG 0

# if DEBUG
# include <stdio.h>
# include "grdpbmacros.h"
# endif

# include "EMS.h"
# include "gocmacros.h"          /* GRgetabsg macro  */
# include "msdef.h"              /* MS message codes */
# include "madef.h"              /* MA message codes */
# include "bs.h"                 /* BS stuff         */
# include "OMmacros.h"           /* OM_BLOCK_MOVE    */

# define TRUE 1
# define FALSE 0

method GRlnproject(
  IGRlong       *msg;                   /* Error return code */
  IGRshort      *matrix_type;           /* My matrix type */
  IGRmatrix     matrix;                 /* My module matrix */
  struct        IGRline *line;          /* The boreline */
  IGRpoint      line_pt;                /* Point on the line */
  IGRpoint      surf_pt;                /* Point on the surface */
  IGRdouble     *t;                     /* Line parameter */
  struct        GRparms *proj_parms)    /* The projected parms */

{
  IGRlong       sts = OM_S_SUCCESS;

# if LOCATE_KLUGE
  IGRboolean    EMSsubbs_am_I_locating();

  if(EMSsubbs_am_I_locating())
  {
    sts = om$send(msg = message EMSsubbs.EMborelineProject(msg,
                  matrix_type, matrix, line, line_pt, surf_pt, t,
                  proj_parms), targetid = my_id);
  }
  else

# endif

  {
  extern     void                   BSmdistcvsf();
    IGRchar                *generic_pointer;
 extern  IGRboolean  BSptlngen();
    IGRboolean             status, was_in_area;
    IGRlong                EFclassify_points_wrt_loopset();
    IGRlong                i, loc_msg, number_of_points;
    IGRlong                type_of_line, best_solution;
    IGRdouble              *line_parameters, knot_vector[4], distance;
    BSpair                 *surface_parameters, uv_solution;
    IGRpoint               *line_points, *surface_points, poles[2];
    IGRpoint               xyz_solution, better_line[2];
    struct                 IGRbsp_curve the_line;
    struct                 IGRbsp_surface *surface;
    OM_S_CHANSELECT        to_my_loopset;

    /*
     * Initialize
     */
    *msg = MSSUCC;
    number_of_points = 0;
    line_parameters = NULL;
    surface_parameters = NULL;
    line_points = NULL;
    surface_points = NULL;

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
     * Since the input line will be intersected with the surface, let's
     * generate a better/smaller line.  All this nonsense would not be
     * necessary if the math worked.  It seems to have problems generating
     * accurate results if the line is extremly long.
     */
    {
      extern IGRboolean  BSbx2();
      IGRboolean    status, rlw_get_better_line();
      IGRlong       total_poles;
      IGRdouble     range[6];

      total_poles = surface->u_num_poles * surface->v_num_poles;
      status = BSbx2(&loc_msg, &total_poles, surface->poles,
                     (surface->rational ? surface->weights : NULL),
                     &range[0], &range[3]);
      if (!status) { *msg = MSFAIL; goto wrapup; }
      status = rlw_get_better_line(range, line, better_line, msg);
      if (!status) goto wrapup;
    }

    /*
     * Generate the boreline as a curve
     */
    the_line.knots = &knot_vector[0];
    the_line.poles = (IGRdouble *) &poles[0][0];
    status = BSptlngen(&loc_msg, &better_line[0][0], &better_line[1][0],
                       &the_line, &type_of_line);
    if (!status) { *msg = MSFAIL; goto wrapup; }

    /*
     * If the input boreline is degenerated to a point, then
     * send a point project message to myself
     */
    if (type_of_line == BSCPOINT)
    {
      sts = om$send(msg = message EMSsubbs.GRptproject(msg, matrix_type,
                    matrix, &better_line[0][0], surf_pt, proj_parms),
                    targetid = my_id);
      goto wrapup;
    }

    /*
     * Project this point onto the surface
     */
    BSmdistcvsf(&the_line, surface, &number_of_points, &line_parameters,
                &surface_parameters, &line_points, &surface_points,
                &distance, &loc_msg);
    if (loc_msg != BSSUCC) { *msg = MSFAIL; goto wrapup; }

    /*Brute force sort the intersection points wrt. the first point of the
     * boreline.
     *
     * IMPORTANT NOTE: The line_parameters and line_points are NOT sorted.
     *                 They are not currently being used so they are
     *                 ignored. -DLB
     */

    if (number_of_points > 1)
    {
      IGRdouble        dist_temp;    /*DECL*/
      BSpair           parm_temp;
      IGRpoint         point_temp;
      extern IGRdouble BSdistptpts();   
      IGRdouble        *distance_sq=NULL;
      IGRint           ii, jj;

      distance_sq = (IGRdouble *) om$malloc(
                     size = number_of_points * sizeof(IGRdouble));
      if (!distance_sq) {*msg = MSFAIL; goto wrapup;}

      for (ii = 0; ii < number_of_points; ii++) /*Compute the distances*/
      {
        distance_sq[ii] = BSdistptpts(&loc_msg, &surface_points[ii][0],
                                      &line->point1[0]);
      }

      for (ii = number_of_points - 1; ii > 0; ii--)
      {
        for (jj = 0; jj < ii; jj ++)
        {
          if (distance_sq[ii] < distance_sq[jj])
          {
            /*Swap em baby!!*/
            dist_temp = distance_sq[ii];
            distance_sq[ii] = distance_sq[jj];
            distance_sq[jj] = dist_temp;
            OM_BLOCK_MOVE(&surface_parameters[ii][0],
                          &parm_temp[0],
                          sizeof(BSpair));
            OM_BLOCK_MOVE(&surface_parameters[jj][0],
                          &surface_parameters[ii][0],
                          sizeof(BSpair));
            OM_BLOCK_MOVE(&parm_temp[0],
                          &surface_parameters[jj][0], 
                          sizeof(BSpair));
            OM_BLOCK_MOVE(&surface_points[ii][0],
                          &point_temp[0],
                          sizeof(IGRpoint));
            OM_BLOCK_MOVE(&surface_points[jj][0],
                          &surface_points[ii][0],
                          sizeof(IGRpoint));
            OM_BLOCK_MOVE(&point_temp[0],
                          &surface_points[jj][0], 
                          sizeof(IGRpoint));
          }
        }
      }
      om$dealloc(ptr = distance_sq);
    }

    /*
     * Find a solution which lies in area or if none do then find
     * the best of the lot.  Note that the function called here can
     * be found in the same file as the point project method.
     */
    to_my_loopset.type = OM_e_addr;
    to_my_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset; 
    sts = EFclassify_points_wrt_loopset(&to_my_loopset, my_id,matrix_type,
                                        matrix, surface, number_of_points,
                                        surface_parameters,surface_points,
                                        &best_solution, &was_in_area,
                                        uv_solution, xyz_solution, msg);
    if (! (1 & sts)) goto wrapup;

    /*
     * Load the solution found
     */
    proj_parms->u = uv_solution[0];
    proj_parms->v = uv_solution[1];
    surf_pt[0] = xyz_solution[0];
    surf_pt[1] = xyz_solution[1];
    surf_pt[2] = xyz_solution[2];

    /*
     * Eof
     */
wrapup:
    if (number_of_points)
    {
      if (line_parameters) free(line_parameters);
      if (surface_parameters) free(surface_parameters);
      if (line_points) free(line_points);
      if (surface_points) free(surface_points);
    }
    /*
     * Display the better line for debug purposes
     */

    /*
     * Compute the line information
     */
    if (1 & *msg)
    {
  extern       IGRboolean   MAptlnproj();
   
      status = MAptlnproj(msg, surf_pt, line, line_pt, t);
      if (!status) { *msg = MSFAIL; return(OM_E_ABORT); }
    }
    else *msg = MSFAIL;

  } /* if (EMSsubbs_am_I_locating()) */

  EMWRAPUP(*msg, sts, "EMSsubbs.GRlnproject")
  return(sts);
}


end implementation EMSsubbs;
