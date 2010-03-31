/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
# include <stdio.h>

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* needed for gocmacros.h */
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"    /* needed for gocmacros.h */
# endif
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRalign_* */
# endif

# include "EMSerrordef.h"
# include "bserr.h"
# include "OMmacros.h"
#include "EMSsfparms.h"

/*
DESCRIPTION:

 This method just returns the range of the surface by doing a BSbx2() on
  the surface poles.

HISTORY:

SAM	06/20/88 	Creation.
*/

method EMget_params(IGRlong *EMmsg; 
struct IGRbsp_surface *geom;
 struct GRmd_env *env;
 IGRushort *type;
 struct EMsurface_params *params)
{

 IGRlong                status; /* OM return status */
 IGRlong                i,j; /* used for getting the abstract geometry */

 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct IGRbsp_surface  *gen_surface;
                                /* pointer to the abstract geometry of the
                                   surface */
IGRint num_pts;
  extern IGRboolean BSbx2();

/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 gen_surface = NULL;
 
 if (type)
   *type = EMfreeform_surface;

 if(params)
 {
  if(!geom)
  {
   GRgetabsg (EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
              &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   gen_surface = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   gen_surface = geom;

  num_pts = gen_surface->u_num_poles * gen_surface->v_num_poles;
  bssts = BSbx2(&rc, &num_pts, gen_surface->poles, gen_surface->weights,
				&params->range[0], &params->range[3]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);
 } /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);

}
end implementation EMSsubbs;
