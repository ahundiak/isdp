/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRget_prism_size

Description
   This method returns the size of the buffer needed to contain the
   prism geometry.

   *msg              IGRlong        completion code
   *mod_env          GRmd_env       The module environment. 
   *prism_type       IGRint         The type of the prism
                                       -  GR_RIGHT_PRISM
                                       -  GR_CURVE_PRISM
   *size             IGRint         Total size of the prism geometry.
   *num_poles        IGRint         The number of poles or points;
   *num_weights      IGRint         The number of weights
   *num_knots        IGRint         The number of knots
   *num_boundaries   IGRint         The nubmer of boundaries;
 
Return Values
   MSSUCC  -- successful completion

History
   Gray Winn    11/10/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
   mrm          02/20/89    send GRvg.GRgetsize out channel rather than to self
   msm          07/09/92    ANSI-C conversion.
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"
#include "gocmacros.h"

from GRvg   import   GRgenabsg, GRgetsize;

method GRget_prism_size (IGRlong *msg; struct GRmd_env *mod_env;
                         IGRint *prism_type; IGRint *size;
                         IGRint *num_poles; IGRint *num_weights;
                         IGRint *num_knots; IGRint *num_boundaries)
{
IGRint               tsize;
OM_S_CHANSELECT      chansel;
struct IGRbsp_curve  *absgptr;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om$send(msg  = message GRvg.GRgenabsg (msg, 
      &mod_env->md_env.matrix_type, mod_env->md_env.matrix, (IGRchar **)&absgptr),
      p_chanselect = &chansel);

   if ((absgptr->order == 2) && (!absgptr->rational))
   {
      /*
       *  Generate a right prism.
       */

      *prism_type = GR_RIGHT_PRISM;
      if (size)
      {
         *size = sizeof (struct IGRrt_prism) + 
                 sizeof (IGRdouble) * 3 * absgptr->num_poles;
      }

      if (num_poles) 
      {
         *num_poles = absgptr->num_poles;
      }

      if (num_weights)
      {
         *num_weights = 0;
      }

      if (num_knots)
      {
         *num_knots = 0;
      }

      if (num_boundaries)
      {
         *num_boundaries = 0;
      }
   }else
   {
      /*
       *  Generate a curve prism.
       */

      *prism_type = GR_CURVE_PRISM;
      if (size)
      {
         om$send (msg = message GRvg.GRgetsize
                       (msg, &mod_env->md_env.matrix_type,
                        mod_env->md_env.matrix, (IGRlong *)&tsize),
                  p_chanselect = &chansel);

         *size = tsize + sizeof (struct IGRcv_prism) - 
                 sizeof (struct IGRbsp_curve);
      }
         
      if (num_poles)
      {
         *num_poles = absgptr->num_poles;
      }

      if (num_weights)
      {
         *num_weights = absgptr->num_poles;
      }

      if (num_knots)
      {
         *num_knots = absgptr->num_knots;
      }

      if (num_boundaries)
      {
         *num_boundaries = absgptr->num_boundaries;
      }
   }
   return(OM_S_SUCCESS);
}
end implementation GRgsmgr;
