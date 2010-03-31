/* ###################   APOGEE COMPILED   ################## */

class implementation EMSpcone;

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
# include "EMSsfparms.h"


method EMget_params(
 IGRlong *EMmsg;
 struct IGRbsp_surface *geom;
 struct GRmd_env *env; /* module environment of the surface */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets ONLY the range of the partial cone when 
             specified the module environment.  

             Input
              env   Module environment
		
	      geom  Surface geometry.
          
             Output
              EMmsg : Completion status
              type : geometric type of the surface. May be set to NULL if
                     not interested in the same.
              params : structure containing the type of the surface, which
                       in this case is EMpcone and parameters to go with
                       the same. 
                       May be set to NULL if not interested in the same


Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

             This method  could be optimised to take into account the
             storage mechanism.
             
Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 06/01/88	Added geom argument to message and
					 call to EFsam_partial_quadric_
					 range_box().
             PP       : 01/11/88        Modified the argumemt list to
                                        return type and parameters
                                        seperately
             PP       : 12/03/87        Conversion to 1.1, and changed the
                                        organisation of the method
             PP       : 06/06/87        Modification to accomadate the
                                        new class structure and include files
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

 struct IGRbsp_surface  *surf;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct EMpartial_cone_params   *ptr;   /* pointer to struct containing
    					 partial cone parameters */

 void                   BSpconprop ();
 
 IGRboolean				EFsam_partial_quadric_range_box();
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
  *type = EMpcone;
 }

 if (params)
 {
  ptr = &params->params.pcone;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   surf = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   surf = geom;
  
  EMerr_hndlr(!EFsam_partial_quadric_range_box(surf, EMpcone, params),
			   *EMmsg, EMS_E_BSerror, wrapup);
 } /* If (params) */
 
 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
#if DEBUG
  EMWRAPUP(*EMmsg, status, "In EMSpcone:  EMget_cone_props error");
#endif
  return (status);

}

end implementation EMSpcone;      
