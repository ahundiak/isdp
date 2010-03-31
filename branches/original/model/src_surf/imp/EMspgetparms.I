/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsphere;

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

# include "EMSerrordef.h"
# include "bserr.h"
# include "EMSsfparms.h" /* For EMsurface_params */


method EMget_params(
 IGRlong *EMmsg; /* Completion message */
 struct IGRbsp_surface *geom;
 struct GRmd_env *env; /* module environment */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets the parameters of a sphere when
             specified with the module environment

             Input
              env 
	      geom : Geometry of the surface.
          
             Output
               EMmsg,
               type : geometric type of the surface. May be set to NULL if
                     not interested in the same.
               params: Parameters of the surface.
                       May be set to NULL if not interested in the same


Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 05/20/88	Added geom argument to the message
					 and code to calculate the sphere
					 range.
             PP       : 01/11/88        Modified the argumemt list to
                                        return type and parameters
                                        seperately
             PP       : 12/03/87        Changed the method org.
             PP       : 06/06/87        Changes due to the new class 
                                        structure and include files
             PP       : 02/10/87        Design date

********************************************************************** */

{

 IGRlong                status; /* OM return status */
 IGRlong                i;      /* used for getting the abstract geometry */

 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */

 struct EMsphere_params *ptr;
 struct IGRbsp_surface  *surf;
                                /* pointer to the abstract geometry of the
                                   surface */
  extern  IGRboolean             BSsphrprop (); 
                                /* Function declaration */

/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 surf = NULL;

 if (type)
 {
  *type = EMsphere;
 }

 if (params)
 {
  ptr = &params->params.sphere;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   surf = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   surf = geom;

 bssts = BSsphrprop (&rc, surf, ptr->center, &ptr->radius, 
                     &ptr->volume, &ptr->area);
 if (!bssts)
 {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }
 
 params->range[0] = ptr->center[0] - ptr->radius;
 params->range[1] = ptr->center[1] - ptr->radius;
 params->range[2] = ptr->center[2] - ptr->radius; 

 params->range[3] = ptr->center[0] + ptr->radius;
 params->range[4] = ptr->center[1] + ptr->radius;
 params->range[5] = ptr->center[2] + ptr->radius;
} /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);

}

end implementation EMSsphere;
