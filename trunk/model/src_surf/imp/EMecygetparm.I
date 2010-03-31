/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpcyl;

#include "EMS.h"
# include <stdio.h>

# include "msdef.h"

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
# include "EMSsfparms.h"  /* struct EMsurface_params */

#include "madef.h"


method EMget_params(
 IGRlong *EMmsg;
 struct IGRbsp_surface *geom; /* Surface geometry */
 struct GRmd_env *env;
 IGRushort *type;
 struct EMsurface_params *params; )

/* *********************************************************************

Description
             This method gets the parameters of an elliptical cylinder when
             specified the module environment.

             Input
              env 
  	      
	      geom : Surface geometry.        
             Output
              type
              params
              EMmsg
   
Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 06/08/88	Added geom argument to the message
					 and call to EFsam_elliptical_
					 full_quadric_range_box.
             PP       : 01/11/88        Modified the argumemt list to
                                        return type and parameters
                                        seperately
             PP       : 12/03/87        Conversion to 1.1, and changed the
                                        organisation of the method
             PP       : 06/06/87        Changes for the new class structure,
                                        and include files
             PP       : 03/03/87        Design date

********************************************************************** */

{

 IGRlong                status; /* OM return status */
 IGRlong                i, j;      /* used for getting the abstract geometry */

 
 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
									surface */
 struct EMelliptical_cylinder_params *ptr;
								/* pointer to a structure containing 
								   elliptical cone parameters */
 struct IGRbsp_surface  *elliptical_cylinder;
                                /* pointer to the abstract geometry of the
                                   surface */
void                     BSecylprp();
IGRint sizept = sizeof(IGRpoint);
  extern IGRboolean MAaddvc();
IGRboolean   EFsam_elliptical_full_quadric_range_box();
IGRpoint center[2];

/* ***************************
   Initialisation
   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 elliptical_cylinder = NULL;


 if (type)
 {
  *type = EMelliptical_cylinder;
 }

 if (params)
 {
  ptr = &params->params.elpcyl;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;
   elliptical_cylinder = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   elliptical_cylinder = geom;

 (void) BSellcylprp (elliptical_cylinder, ptr->height, ptr->base_center,
                     ptr->semi_major_axis, ptr->semi_minor_axis, 
                     &ptr->area, &ptr->volume, &rc);
 if (rc != BSSUCC)
 {
  *EMmsg = EMS_E_Fail;
  goto wrapup;
 }

 OM_BLOCK_MOVE(ptr->base_center, &center[0][0], sizept);

 bssts = MAaddvc(EMmsg, &center[0][0], ptr->height, &center[1][0]);
 EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

 EMerr_hndlr(!EFsam_elliptical_full_quadric_range_box(
                ptr->semi_major_axis, ptr->semi_minor_axis,
			    1.0, center, &params->range[0]),
               *EMmsg, EMS_E_BSerror, wrapup);
} /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);

}

end implementation EMSelpcyl;
