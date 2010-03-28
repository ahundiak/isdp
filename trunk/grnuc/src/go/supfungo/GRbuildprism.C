/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRbuild_prism_in_wnd

Description
   This function returns a prism.  This function works on the assuption
   that the points of the polygon or curve or being viewed from a specific
   window.  

   *msg              IGRlong              completion code
   *window_id        stuct GRid           object id of the window.
   *curve            struct IGRbsp_curve  original bspline
   *prism            IGRchar              pointer to prism

Notes
   If the curve is order two and is not rational than a right prism
   is fromed.  Otherwise a curve prism is formed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/07/88    Creation date.
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"

extern IGRboolean    MAtypemx();
extern IGRboolean    MAoptsxform();
extern IGRboolean    MArptsxform();

IGRint GRbuild_prism_in_wnd (msg, window_id, curve, prism)
IGRlong              *msg;
struct GRid          *window_id;
struct IGRbsp_curve  *curve;
IGRchar              *prism;
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRboolean           status;
IGRint               i;
IGRint               prism_type;
IGRshort             matrix_type;
IGRdouble            wld_to_local_matrix[16];
struct IGRrt_prism   *rt_prism;
struct IGRcv_prism   *cv_prism;


   *msg = MSSUCC;
   cv_prism = (struct IGRcv_prism *)prism;
   rt_prism = (struct IGRrt_prism *)prism;
   prism_type = ((curve->order == 2) && (!curve->rational)) ? 
                GR_RIGHT_PRISM : GR_CURVE_PRISM;

   if (prism_type == GR_RIGHT_PRISM)
   {
      om_msg = GRbuild_prism_helper (&ret_msg, window_id, NULL,
               NULL, NULL, NULL, NULL, rt_prism->matrix, 
               wld_to_local_matrix, &rt_prism->height);
   }else
   {
      om_msg = GRbuild_prism_helper (&ret_msg, window_id, NULL,
               NULL, NULL, NULL, NULL, cv_prism->matrix, 
               wld_to_local_matrix, &cv_prism->height);
   }

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Transform the points from the world coordinate system to the 
       *  local coordinate system of the right prism.
       */
       
       if (prism_type == GR_RIGHT_PRISM)
       { 
           status = MAtypemx (&ret_msg, wld_to_local_matrix, &matrix_type);
           status = MAoptsxform (&ret_msg, &curve->num_poles, &matrix_type,
                    wld_to_local_matrix, curve->poles,
                    rt_prism->polygon.points);

         /*
          *  Project each of these points onto the matrix
          *  defining the back.  This project can be done by 
          *  zeroing out the z coordinate of each point.  
          */

         for (i = 2; i < curve->num_poles * 3; i += 3)
         {
            rt_prism->polygon.points[i] = 0;
         }

         rt_prism->polygon.num_points = curve->num_poles;
      }else
      {
         status = MArptsxform (&ret_msg, &curve->num_poles, 
                  &curve->rational, curve->weights, wld_to_local_matrix,
                  curve->poles, cv_prism->curve.poles);

         /*
          *  Project each of these points onto the matrix
          *  defining the back.  This project can be done by 
          *  zeroing out the z coordinate of each point.  
          */

         for (i = 2; i < curve->num_poles * 3; i += 3)
         {
            cv_prism->curve.poles[i] = 0;
         }

         if (curve->rational)
         {
            for (i=0; i < curve->num_poles; ++i)
            {
               cv_prism->curve.weights[i] = curve->weights[i];
            }
         }

         if (curve->num_knots)
         {
            for (i=0; i < curve->num_knots; ++i)
            {
               cv_prism->curve.knots[i] = curve->knots[i];
            }
         }

         if (curve->num_boundaries)
         {
            for (i=0; i < curve->num_boundaries * 2; ++i)
            {
               cv_prism->curve.bdrys[i] = curve->bdrys[i];
            }
         }

         cv_prism->curve.order = curve->order;
         cv_prism->curve.periodic = curve->periodic;
         cv_prism->curve.non_uniform = curve->non_uniform;
         cv_prism->curve.num_poles = curve->num_poles;
         cv_prism->curve.num_knots = curve->num_knots;
         cv_prism->curve.rational = curve->rational;
         cv_prism->curve.planar = curve->planar;
         cv_prism->curve.phy_closed = curve->phy_closed;
         cv_prism->curve.num_boundaries = curve->num_boundaries;
      }
   }
   return(OM_S_SUCCESS);
}
