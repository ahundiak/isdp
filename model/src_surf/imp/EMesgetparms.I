/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpsoid;

# include "EMS.h"
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
# include "EMSsfparms.h"

#include "madef.h"


method EMget_params(
 IGRlong *EMmsg; /* completion message */
 struct IGRbsp_surface *geom; /* Surface geometry */
 struct GRmd_env *env;   /* module environment of the surface */
 IGRushort *type;
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets the parameters of an ellipsoid when
             specified with the module environment

             Input
              env 
          
	      geom : Geometry of the surface.

             Output
              EMmsg 
              type : geometric type of the surface. May be set to NULL if
                     not interested in the same.
              param : parameters of the surface. 
                      May be set to NULL if not interested in the same


Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History	
	     SAM      : 06/01/88	Added geom argument to the message
					 and call to EFsam_full_quadric_
					 range_box.
             PP       : 01/11/88        Modified the argumemt list to
                                        return type and parameters
                                        seperately
             PP       : 12/03/87         Method reorg
             PP       : 06/06/87         Converted to new class structure
             PP       : 03/03/87         Design date

********************************************************************** */

{

 IGRlong                status; /* OM return status */
 IGRlong                i;      /* used for getting the abstract geometry */

 IGRboolean             bssts;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */

 struct EMellipsoid_params *ptr;
 struct IGRbsp_surface  *ellipsoid;
                                /* pointer to the abstract geometry of the
                                   surface */
  extern  void                    BSellpsdprp ();
                                /* Function declaration */
  extern IGRboolean MAaddvc();
  extern IGRboolean   MAsubvc();
IGRboolean   EFsam_full_quadric_range_box();
IGRvector center[2], origin;
 

/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 ellipsoid = NULL;

 if (type)
 {
  *type = EMellipsoid;
 }

 if (params)
 {
  ptr = &params->params.elpsd;
  if(!geom)
  {
   GRgetabsg (EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
              &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   ellipsoid = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   ellipsoid = geom;

  (void) BSellpsdprp (ellipsoid, ptr->focus0, ptr->focus1, ptr->center,
                      &ptr->radius, &ptr->major_axis_length, 
                      ptr->semi_major_axis, &ptr->area,&ptr->volume, &rc);

  if (rc != BSSUCC)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

  origin[0] = origin[1] = origin[2] = 0.0;
  bssts = MAsubvc(EMmsg, origin, ptr->semi_major_axis, &center[1][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  bssts = MAaddvc(EMmsg,ptr->semi_major_axis, ptr->center, &center[0][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  bssts = MAaddvc(EMmsg, &center[1][0], ptr->center, &center[1][0]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  EMerr_hndlr(!EFsam_full_quadric_range_box(ptr->radius, ptr->radius,
                center,&params->range[0]), *EMmsg, EMS_E_BSerror, wrapup);
 } /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);
}

end implementation EMSelpsoid;
