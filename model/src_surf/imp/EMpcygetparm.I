/* ###################   APOGEE COMPILED   ################## */

class implementation EMSpcylindr;

# include "EMS.h"
# include "msdef.h"
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

#include "EMSerrordef.h"
# include "bserr.h"
#include "EMSsfparms.h"

method EMget_params(
 IGRlong *EMmsg;
 struct IGRbsp_surface *geom;
 struct GRmd_env *env; /* module environment */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)  /* structure containing
                                                      parameters of the
                                                      partial cylinder */
/* *********************************************************************

Description
             This method gets ONLY the range of the partial cylinder and 
	      the surface type.

             Input
              env 
              geom : Geometry of the surface.

             Output
              EMmsg : completion status
              type : type of the surface. May be set to NULL
                     if not interested in the same.
              params : structure containing parameters of the partial 
			cylinder.
                       May be set to null if not interested in the same

Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 06/05/88	Creation.

********************************************************************** */

{

 IGRlong                status; /* OM return status */
 IGRlong                i;      /* used for getting the abstract geometry */

 
 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */

 struct IGRbsp_surface  *surf;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct EMpartial_cylinder_params *ptr; /* pointer to a structure 
										containing  cylinder parameters */

 IGRboolean       EFsam_partial_quadric_range_box();


/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 surf = NULL;

 if (type)
 {
  *type = EMpcylinder;
 }

 if (params)
 {
  ptr = &params->params.pcyl;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   surf = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   surf = geom;
  
  EMerr_hndlr(!EFsam_partial_quadric_range_box(surf, EMpcylinder, params),
			   *EMmsg, EMS_E_BSerror, wrapup);

 } /* IF params */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  EMWRAPUP(*EMmsg, status, "In EMSpcylindr.EMget_params");
  return (status);

}

end implementation EMSpcylindr;
