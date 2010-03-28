/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSput_prism 

Description
   This method stores the prism.

Arguments
   *msg                 IGRlong              return code 
   *prism_type          IGRint               Prism type
                                                -  GR_RIGHT_PRISM
                                                -  GR_CURVE_PRISM
   *prism               IGRchar              The prism

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   Gray Winn   07/11/87    Creation Date
   Gray Winn   10/07/88    Changes for 1.2
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "grgsdef.h"

method GSput_prism (IGRlong *msg; IGRint *prism_type; IGRchar *prism)
{
IGRlong              om_msg;
IGRint               i;
struct IGRrt_prism   *right_prism;
struct IGRcv_prism   *curve_prism;

   *msg = MSSUCC;
   me->prism_type = *prism_type;

   /*
    *  Store the right prism in instance data.
    */

   if (*prism_type == GR_RIGHT_PRISM)
   {
      right_prism = (struct IGRrt_prism *)prism;
      me->prism_height = right_prism->height; 
      me->prism_num_poles = right_prism->polygon.num_points;

      for (i=0; i < 16; ++i) 
      {
         me->prism_matrix[i] = right_prism->matrix[i];
      } 

      om_msg = om$vla_set_dimension(varray = me->prism_poles,
               size = me->prism_num_poles * 3);

      for (i=0; i < me->prism_num_poles * 3; ++i)
      {
         me->prism_poles[i] = right_prism->polygon.points[i];
      }
   }else
   {
      curve_prism = (struct IGRcv_prism *)prism;
      me->prism_height = curve_prism->height;
      me->prism_num_poles = curve_prism->curve.num_poles;
      for (i=0; i<16; ++i) 
      {
         me->prism_matrix[i] = curve_prism->matrix[i];
      } 

      om_msg = om$vla_set_dimension(varray = me->prism_poles,
               size = curve_prism->curve.num_poles * 3);

      for (i=0; i < me->prism_num_poles * 3; ++i)
      {
         me->prism_poles[i] = curve_prism->curve.poles[i];
      }

      if (curve_prism->curve.rational)
      {
         om_msg = om$vla_set_dimension(varray = me->prism_curve_weights,
                  size = curve_prism->curve.num_poles);

         for (i=0; i < curve_prism->curve.num_poles; ++i)
         {
            me->prism_curve_weights[i] = curve_prism->curve.weights[i];
         }
      }

      if (curve_prism->curve.num_knots)
      {
         om_msg = om$vla_set_dimension(varray = me->prism_curve_knots,
                  size = curve_prism->curve.num_knots);

         for (i=0; i < curve_prism->curve.num_knots; ++i)
         {
            me->prism_curve_knots[i] = curve_prism->curve.knots[i];
         }
      }

      if (curve_prism->curve.num_boundaries)
      {
         om_msg = om$vla_set_dimension(varray = me->prism_curve_bdrys,
                  size = curve_prism->curve.num_boundaries * 2);

         for (i=0; i < curve_prism->curve.num_boundaries * 2; ++i)
         {
            me->prism_curve_bdrys[i] = curve_prism->curve.bdrys[i];
         }
      }

      me->prism_curve_order = curve_prism->curve.order;
      me->prism_curve_periodic = curve_prism->curve.periodic;
      me->prism_curve_non_uniform = curve_prism->curve.non_uniform;
      me->prism_curve_num_knots = curve_prism->curve.num_knots;
      me->prism_curve_rational = curve_prism->curve.rational;
      me->prism_curve_planar = curve_prism->curve.planar;
      me->prism_curve_phy_closed = curve_prism->curve.phy_closed;
      me->prism_curve_num_boundaries = curve_prism->curve.num_boundaries;
   }
   return ( OM_S_SUCCESS );
}
end implementation GRfcset;
