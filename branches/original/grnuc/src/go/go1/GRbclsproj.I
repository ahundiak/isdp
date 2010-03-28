/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
  
 This method returns the point on a bspline curve that is both closest to the
 input line segment and has a line projection point that lies on the line
 segment.  If there is more than one point at the closest distance, the
 point that is the closest to the first point of the line segment is returned.
 The parameters of the point on the curve are also returned. This routine was
 written because the existing GRlnproject method will arbitrarily return a
 locate point if there are more than one.  This was written primarily for
 placing symbology overrides.
  
 RETURN VALUES
 
 line_pt                The closet point on the line to the curve.

 curve_pt               The closest point on the curve to the line.

 t                      The parameter on the line corresponding to the
                        closest point on the line to the curve.

 proj_parms             The curve parameters corresponding to the curve_pt.
  
 msg                    MSSUCC if success
                        MANOMEMORY if no memory
                        MSFAIL if problems 
  
 NOTES
  
 This routine gets the abstract geometry for the curve and finds
 the minimum distance point(s) using the bs math.  If only one point is
 returned from the bs routine, a boreline that passes through this
 point and is same direction and magnitude as the specified boreline is
 constructed.  This new boreline is then used in the call to the bs routine
 again.  It is necessary to do this since the math routine will only return
 multiple minimum distance points if elements intersect.

 HISTORY
  
 01/31/92 : Jack : Created from EMssLnProjec.I.
 02/08/92 : WBC  : Modified to project onto a line segment instead of a line.
                   Also now calls calls BSmdistcvcv twice (if necessary) to
                   check for multiple minimum distance points.
*/

class implementation GRbspline;


# define DEBUG 0

# if DEBUG
# include <stdio.h>
# include "grdpbmacros.h"
# endif

# include "gocmacros.h"          /* GRgetabsg macro  */
# include "msdef.h"              /* MS message codes */
# include "madef.h"              /* MA message codes */
# include "bs.h"                 /* BS stuff         */
# include "OMmacros.h"           /* OM_BLOCK_MOVE    */

# define TRUE 1
# define FALSE 0

method GRlinesegproj(IGRlong   *msg;                  /* Error return code */
                     IGRshort  *matrix_type;          /* My matrix type */
                     IGRmatrix  matrix;               /* My module matrix */
                     struct IGRline_seg *line_seg;    /* The line segment */
                     IGRpoint   lineseg_pt;           /* Point on line seg */
                     IGRpoint   curve_pt;             /* Point on the curve */
                     IGRdouble *t;                    /* Line seg parameter */
                     struct     GRparms *proj_parms)  /* The projected parms */

{
    extern  IGRdouble      BSdistptpts();
    extern  IGRboolean     BSptlngen();
    extern     void        BSmdistcvcv();

    IGRlong                loc_msg, number_of_points,
                           type_of_line,
                           sts = OM_S_SUCCESS;
    IGRint                 index,
                           closest_index;
    IGRdouble              knot_vector[4], distance,
                           *line_parameters,
                           *curve_parameters,
                           closest_distance;
    IGRpoint               better_line[2],
                           *line_points, *curve_points, poles[2];
    struct                 IGRbsp_curve the_line;
    struct                 IGRbsp_curve *curve;
    IGRchar                *generic_pointer;
    IGRboolean             status;

    /*
     * Initialize
     */
    *msg = MSSUCC;
    number_of_points = 0;
    line_parameters = NULL;
    curve_parameters = NULL;
    line_points = NULL;
    curve_points = NULL;

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
    curve = (struct IGRbsp_curve *) generic_pointer;

    /*
     * Since the input line will be intersected with the curve, let's
     * generate a better/smaller line.  The math seems to have problems 
     * generating accurate results if the line is extremly long.
     */
    {
      extern IGRboolean  BSbx2();
      int           status, jjc_get_better_line();
      IGRdouble     range[6];

      status = BSbx2(&loc_msg, &curve->num_poles, curve->poles,
                     (curve->rational ? curve->weights : NULL),
                     &range[0], &range[3]);
      if (!status) { *msg = MSFAIL; goto wrapup; }
      status = jjc_get_better_lineseg(range, line_seg, better_line, msg);
      if (!status) goto wrapup;
    }

    /*
     * Generate the boreline as a curve
     */
    the_line.knots = &knot_vector[0];
    the_line.poles = (IGRdouble *) &poles[0][0];

    status = BSptlngen(&loc_msg, &better_line[0][0], &better_line[1][0],
                       &the_line, &type_of_line);
/*
    status = BSptlngen(&loc_msg, line_seg->beg_point, line_seg->end_point,
                       &the_line, &type_of_line);
*/
    if (!status) { *msg = MSFAIL; goto wrapup; }

    /*
     * If the input boreline is degenerated to a point, then
     * send a point project message to myself
     */
    if (type_of_line == BSCPOINT)
    {
      sts = om$send(msg = message GRbspline.GRptproject(msg, matrix_type,
                    matrix, &better_line[0][0], curve_pt, proj_parms),
                    targetid = my_id);
/*
      sts = om$send(msg = message GRbspline.GRptproject(msg, matrix_type,
                    matrix, line_seg->beg_point, curve_pt, proj_parms),
                    targetid = my_id);
*/
      goto wrapup;
    }

    /*
     * Project this point onto the curve
     */
    BSmdistcvcv(&the_line, curve, &number_of_points, &line_parameters,
                &curve_parameters, &line_points, &curve_points,
                &distance, &loc_msg);
    if (loc_msg != BSSUCC) { *msg = MSFAIL; goto wrapup; }

    if (number_of_points == 1)
    {
      IGRdouble  trans_vector[3];

      /* alter the line by finding the vector that goes from the line point
       * to the curve point, and adding this vector to the two line points;
       * this needs to be done because the math routine will only return
       * multiple points if the two elements actually intersect
       */

      for (index = 0; index < 3; index++)
      {
        trans_vector[index] = curve_points[0][index] - line_points[0][index];
        better_line[0][index] += trans_vector[index];
        better_line[1][index] += trans_vector[index];
      }

      status = BSptlngen(&loc_msg, &better_line[0][0], &better_line[1][0],
                         &the_line, &type_of_line);

      if (!status) { *msg = MSFAIL; goto wrapup; }

      if (line_parameters)
      {
        free(line_parameters);
        line_parameters = NULL;
      }

      if (curve_parameters)
      {
        free(curve_parameters);
        curve_parameters = NULL;
      }

      if (line_points)
      {
        free(line_points);
        line_points = NULL;
      }

      if (curve_points)
      {
        free(curve_points);
        curve_points = NULL;
      }

      BSmdistcvcv(&the_line, curve, &number_of_points, &line_parameters,
                  &curve_parameters, &line_points, &curve_points,
                  &distance, &loc_msg);
      if (loc_msg != BSSUCC) { *msg = MSFAIL; goto wrapup; }
    }

    /* find which point on the curve is both closest to the line whose
     * corresponding line point is on the line segment
     */

    closest_index = -1;

    for (index = 0; index < number_of_points; index++)
    {
        if ((line_parameters[index] >= 0.0) &&
            (line_parameters[index] <= 1.0))
        {
            if ((closest_index == -1) ||
                 (BSdistptpts(&loc_msg, curve_points[index],
                              better_line[0]) < closest_distance))
            {
                closest_distance = distance;
                closest_index = index;
            }
        }
    }

    if (closest_index != -1)
    {
        /* Load the solution found */

        proj_parms->u = curve_parameters[closest_index];
        curve_pt[0] = curve_points[closest_index][0];
        curve_pt[1] = curve_points[closest_index][1];
        curve_pt[2] = curve_points[closest_index][2];
        *t = line_parameters[closest_index];
        lineseg_pt[0] = line_points[closest_index][0];
        lineseg_pt[1] = line_points[closest_index][1];
        lineseg_pt[2] = line_points[closest_index][2];
    }
    else
        *msg = MSINARG;

wrapup:
    if (number_of_points)
    {
      if (line_parameters)  free(line_parameters);
      if (curve_parameters) free(curve_parameters);
      if (line_points)      free(line_points);
      if (curve_points)     free(curve_points);
    }

  return(sts);
}


/*
 * This static function returns a bounded line which 
 * is based on the input range box.  This is a copy
 * of the equivalent function in Model called 
 * rlw_get_better_line that has been changed so that the line will not
 * grow any longer, even if the line does not extend all the way through
 * the range box
 */

int jjc_get_better_lineseg(
  range,
  line_seg,
  better_line,
  msg)

 IGRpoint       range[2];
 struct         IGRline_seg *line_seg;
 IGRpoint       better_line[2];
 IGRlong        *msg;
{
 extern  IGRboolean  MAptlnproj();
 struct IGRline line;
 IGRboolean     status;
 IGRlong        i;
 IGRdouble      t, min_t, max_t;
 IGRpoint       corners[8], line_pt;
/*
 * Build an array which consists of the eight corner points of
 * the input range box
 */
 corners[0][0] = range[0][0];
 corners[0][1] = range[0][1];
 corners[0][2] = range[0][2];
 corners[1][0] = range[1][0];
 corners[1][1] = range[0][1];
 corners[1][2] = range[0][2];
 corners[2][0] = range[1][0];
 corners[2][1] = range[1][1];
 corners[2][2] = range[0][2];
 corners[3][0] = range[0][0];
 corners[3][1] = range[1][1];
 corners[3][2] = range[0][2];
 corners[4][0] = range[0][0];
 corners[4][1] = range[0][1];
 corners[4][2] = range[1][2];
 corners[5][0] = range[1][0];
 corners[5][1] = range[0][1];
 corners[5][2] = range[1][2];
 corners[6][0] = range[1][0];
 corners[6][1] = range[1][1];
 corners[6][2] = range[1][2];
 corners[7][0] = range[0][0];
 corners[7][1] = range[1][1];
 corners[7][2] = range[1][2];

 line.point1 = line_seg->beg_point;
 line.point2 = line_seg->end_point;

 for (i = 0; i < 8; i++)
  {
   status = MAptlnproj(msg, corners[i], &line, line_pt, &t);
   if (!status) return(FALSE);

   if (i)
   {
     if (t < min_t)
     {
        min_t = t;
        better_line[0][0] = line_pt[0];
        better_line[0][1] = line_pt[1];
        better_line[0][2] = line_pt[2];
     }

     if (t > max_t)
     {
        max_t = t;
        better_line[1][0] = line_pt[0];
        better_line[1][1] = line_pt[1];
        better_line[1][2] = line_pt[2];
     }
  }
  else
  {
     min_t = t;
     max_t = t;
     better_line[0][0] = line_pt[0];
     better_line[0][1] = line_pt[1];
     better_line[0][2] = line_pt[2];
     better_line[1][0] = line_pt[0];
     better_line[1][1] = line_pt[1];
     better_line[1][2] = line_pt[2];
  }
 }

 if (min_t < 0.0)
 {
   better_line[0][0] = line_seg->beg_point[0];
   better_line[0][1] = line_seg->beg_point[1];
   better_line[0][2] = line_seg->beg_point[2];
 }

 if (max_t > 1.0)
 {
   better_line[1][0] = line_seg->end_point[0];
   better_line[1][1] = line_seg->end_point[1];
   better_line[1][2] = line_seg->end_point[2];
 }

 return(TRUE);
}

end implementation GRbspline;
