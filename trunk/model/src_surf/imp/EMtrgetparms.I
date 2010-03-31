/* ###################   APOGEE COMPILED   ################## */

class implementation EMStorus;

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

#include "madef.h"

method EMget_params(
 IGRlong *EMmsg; /* Completion message */
 struct IGRbsp_surface *geom;   /* Surface geometry */
 struct GRmd_env *env; /* module environment of the surface */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets the parameters of the torus when 
             specified with the module environment. 

             Input
              env 
	      geom : Geometry of the surface.

             Output
               EMmsg, type, params

Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 04/28/88	Added geom argument to the message
					 and call to EFsam_full_quadric_
					 range_box().
             PP       : 01/11/88        Modified the argumemt list to
                                        return type and parameters
                                        seperately
             PP       : 12/03/87         Method reorg
             PP       : 06/06/87         Changes for the new class structure
                                         and include files.
             PP       : 03/03/87         Design date

********************************************************************** */

{

 IGRlong                status; /* OM return status */
 IGRlong                i,j; /* used for getting the abstract geometry */

 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct EMtorus_params  *ptr;
 struct IGRbsp_surface  *torus;
                                /* pointer to the abstract geometry of the
                                   surface */
  extern  void                    BStorusprop ();
                                /* Function declaration */
IGRdouble total_radius, magnitude;
  extern IGRboolean MAaddvc();
  extern IGRboolean   MAscalvc();
IGRboolean   EFsam_full_quadric_range_box();
IGRvector center[2];

/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 torus = NULL;
 
 if (type)
 {
   *type = EMtorus;
 }

 if (params)
 {
  ptr = &params->params.torus;
  if(!geom)
  {
   GRgetabsg (EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
              &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   torus = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   torus = geom;

  (void) BStorusprop(torus, ptr->center, ptr->normal, &ptr->major_radius, 
                     &ptr->minor_radius, &ptr->area, &ptr->volume, &rc);
  if (rc != BSSUCC)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

  magnitude = ptr->minor_radius;
  bssts = MAscalvc(EMmsg, &magnitude, ptr->normal, &center[0][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  magnitude = -magnitude;
  bssts = MAscalvc(EMmsg, &magnitude, ptr->normal, &center[1][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup); 

  bssts = MAaddvc(EMmsg, ptr->center, &center[0][0], &center[0][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  bssts = MAaddvc(EMmsg, ptr->center, &center[1][0], &center[1][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  total_radius = ptr->major_radius + ptr->minor_radius;

  EMerr_hndlr(!EFsam_full_quadric_range_box(total_radius, total_radius,
                center,&params->range[0]), *EMmsg, EMS_E_BSerror, wrapup);
 } /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);

}
end implementation EMStorus;
