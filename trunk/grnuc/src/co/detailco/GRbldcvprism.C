/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRbuild_prism_in_design_cube

Description
   This function is used to build a curve prism given a bspline curve,
   and a rotation matrix defining how the bspline curve is being view.
   The curve prism will span the design cube.

   *msg                 IGRlong              Completion code
   *curve               struct IGRbsp_curve  Curve to build prism from
   *cv_prism            struct IGRcv_prism   The curve prism
   *ortho_view          IGRint               True if view is ortho
   wld_to_vw_matrix[]   IGRdouble            World to view rotation matrix

Notes
   The curve prism should contain a pointer to the poles (the poles are
   transformed).  The other parts of the curve prism (knots, weights, 
   and boundaries) will not be modified from the curve definition.
   There pointers are copied from the curve to the prism.  

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    06/19/87    Creation date.
   SCW          07/08/92    ANSI conversion
\*/

#include "coimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "OMerrordef.h"

IGRint GRbuild_prism_in_design_cube (msg, curve, cv_prism, ortho_view,
                     wld_to_vw_matrix)
IGRlong              *msg;
struct IGRbsp_curve  *curve;
struct IGRcv_prism   *cv_prism;
IGRint               ortho_view;
IGRdouble            wld_to_vw_matrix[];
{
IGRint               i;
IGRboolean           status;
IGRshort             matrix_type;
IGRlong              ret_msg;
IGRlong              one;
IGRdouble            distance;
IGRdouble            *temp_pointer;
IGRdouble            local_matrix[16];
IGRpoint             diag_pt1;
IGRpoint             diag_pt2;
IGRpoint             avg_point;
IGRpoint             point2;
IGRpoint             low_point;
IGRpoint             high_point;
IGRvector            vector;
IGRvector            unit_vector;
IGRvector            scale_vector;
IGRpoint             beg_point;
IGRpoint             end_point;
IGRpoint             local_beg_point;
IGRpoint             local_end_point;
struct IGRline       line;
struct IGRline_seg   line_seg;

   *msg = MSSUCC;
   one = 1;

   /*
    *  Calulate the average of the points in the curve.
    */

   if (curve->rational)
   {
      BSavgpts(&ret_msg, curve->num_poles, curve->poles, curve->weights,
               avg_point);
   }else
   {
      BSavgpts(&ret_msg, curve->num_poles, curve->poles, NULL, avg_point);
   }

   /*
    *  Build a unit view vector.
    */

   vector[0] = wld_to_vw_matrix[8];
   vector[1] = wld_to_vw_matrix[9];
   vector[2] = wld_to_vw_matrix[10];
   MAunitvc (&ret_msg, vector, unit_vector);

   /*
    *  Add the unit view vector onto the avgerage point to define a
    *  line.
    */
   
   point2[0] = unit_vector[0] + avg_point[0];
   point2[1] = unit_vector[1] + avg_point[1];
   point2[2] = unit_vector[2] + avg_point[2];

   line_seg.beg_point = beg_point;
   line_seg.end_point = end_point;
   line.point1 = avg_point;
   line.point2 = point2;

   /*
    *  Define the cube to be the design cube.
    */

   diag_pt1[0] = diag_pt1[1] = diag_pt1[2] = GRDGNLIMITS_MIN_D;
   diag_pt2[0] = diag_pt2[1] = diag_pt2[2] = GRDGNLIMITS_MAX_D;

   /*
    *  Clip the infinite line to a line segment on the design cube.
    */

   status = MAlncbclip(&ret_msg, &line, diag_pt1, diag_pt2, &line_seg);

   /*
    *  Is the view aligned with the design cube?  If not then
    *  it is necessary to adjust the height of the line segment 
    *  so that it will not extend pass the design cube.
    */

   if (!ortho_view)
   {
      /*
       *  Find the range of the curve.
       */

      status = MAcubepy (&ret_msg, curve, low_point, high_point);

      /*
       *  Find the distance between the two points.
       */

      status = MA2ptdis (&ret_msg, low_point, high_point, &distance);

      /*
       *  Scale the unit view vector by this distance to ensure that the
       *  line segment is inside the design cube.
       */

      status = MAscalvc(&ret_msg, &distance, unit_vector, scale_vector);

      /*
       *  The distance added should make point the point fall inside
       *  the design cube.
       */

      if ((beg_point[0] + scale_vector[0] <=  GRDGNLIMITS_MIN_D) ||
          (beg_point[1] + scale_vector[1] <=  GRDGNLIMITS_MIN_D) ||
          (beg_point[2] + scale_vector[2] <=  GRDGNLIMITS_MIN_D))
      {
         beg_point[0] -= scale_vector[0];
         beg_point[1] -= scale_vector[1];
         beg_point[2] -= scale_vector[2];
      
         end_point[0] += scale_vector[0];
         end_point[1] += scale_vector[1];
         end_point[2] += scale_vector[2];
      }else
      {
         beg_point[0] += scale_vector[0];
         beg_point[1] += scale_vector[1];
         beg_point[2] += scale_vector[2];

         end_point[0] -= scale_vector[0];
         end_point[1] -= scale_vector[1];
         end_point[2] -= scale_vector[2];
      }
   }

   /*
    *  Copy the curve to the curve prism.  Note that the poles pointer
    *  should be saved and restored.
    */

   temp_pointer = cv_prism->curve.poles;
   cv_prism->curve = *curve;
   cv_prism->curve.poles = temp_pointer;

   /*
    *  Transform the points of the line segment from the world cordinates
    *  to the view system.
    */

   MAtypemx(&ret_msg, wld_to_vw_matrix, &matrix_type);
   MAoptsxform (&ret_msg, &one, &matrix_type, wld_to_vw_matrix,
                beg_point, local_beg_point);
   MAoptsxform (&ret_msg, &one, &matrix_type, wld_to_vw_matrix,
                end_point, local_end_point);

   /*
    *  Build a matrix to take elements from world coordinates to
    *  local coordinates. This local coordinate system will be 
    *  aligned with the view and translated about the begin point
    *  of the line segment.
    */

   for (i = 0; i < 16; ++i)
   {
      local_matrix[i] = wld_to_vw_matrix[i];
   }

   local_matrix[3]  -= local_beg_point[0];
   local_matrix[7]  -= local_beg_point[1];
   local_matrix[11] -= local_beg_point[2];

   /*
    *  Transform the points from the world coordinate system to the 
    *  local coordinate system of the prism.
    */
    
   if (!curve->rational)
   {
      status = MAtypemx (&ret_msg, local_matrix, &matrix_type);
      status = MAoptsxform (&ret_msg, &curve->num_poles, &matrix_type, 
               local_matrix, curve->poles, cv_prism->curve.poles);
   }else
   {
      status = MArptsxform (&ret_msg, &curve->num_poles, &curve->rational,
               curve->weights, local_matrix, curve->poles, 
               cv_prism->curve.poles);
   }

   /*
    *  Project each of these points onto the matrix
    *  defining the back.  This project can be done by 
    *  zeroing out the z coordinate of each point.  
    */

   for (i = 2; i < cv_prism->curve.num_poles * 3; i += 3)
   {
      cv_prism->curve.poles[i] = 0;
   }

   /*
    *  The prism matrix transform from local coordinates
    *  to world coordinates.  
    *  local_to_world_matrix * (pt - 0) + origin in world.
    */

   cv_prism->matrix[0]  =  wld_to_vw_matrix[0];
   cv_prism->matrix[1]  =  wld_to_vw_matrix[4];
   cv_prism->matrix[2]  =  wld_to_vw_matrix[8];
   cv_prism->matrix[3]  =  beg_point[0];
   cv_prism->matrix[4]  =  wld_to_vw_matrix[1];
   cv_prism->matrix[5]  =  wld_to_vw_matrix[5];
   cv_prism->matrix[6]  =  wld_to_vw_matrix[9];
   cv_prism->matrix[7]  =  beg_point[1];
   cv_prism->matrix[8]  =  wld_to_vw_matrix[2];
   cv_prism->matrix[9]  =  wld_to_vw_matrix[6];
   cv_prism->matrix[10] =  wld_to_vw_matrix[10];
   cv_prism->matrix[11] =  beg_point[2];
   cv_prism->matrix[12] =  wld_to_vw_matrix[12];
   cv_prism->matrix[13] =  wld_to_vw_matrix[13];
   cv_prism->matrix[14] =  wld_to_vw_matrix[14];
   cv_prism->matrix[15] =  wld_to_vw_matrix[15];

   /*
    *  The height of the prism is equal to the distance between the
    *  two points of the line segment.
    */
   
   cv_prism->height = local_end_point[2] - local_beg_point[2];

   return(OM_S_SUCCESS);
}
