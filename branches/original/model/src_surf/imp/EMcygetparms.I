/* ###################   APOGEE COMPILED   ################## */

class implementation EMScylindr;

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

#include "EMSerrordef.h"
# include "bserr.h"
#include "EMSsfparms.h"


#define AXIS_POLES 2
#define AXIS_KNOTS 4

method EMget_params(
 IGRlong *EMmsg; /* Completion message */
 struct IGRbsp_surface *geom; /* Surface geometry */
 struct GRmd_env *env; /* module environment */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)  /* structure containing parameters of
									   the cylinder */
                            

/* *********************************************************************

Description
             This method gets the parameters of the cylinder and the
             surface type.

             Input
              env 
		
	      geom	Geometry of the surface.          

             Output
              EMmsg : completion status
              type : type of the surface. May be set to NULL
                     if not interested in the same.
              params : structure containing parameters of the cylinder
                       May be set to null if not interested in the same

Notes
             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_Fail : if failure

Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
	     SAM      : 15/05/88 	Added geom argument to the call
					 and call to EFsam_full_quadric_
					 range_box.
             PP       : 01/11/87        Modified the argument list  to
                                        return type and the parameters
                                        seperately
             PP       : 12/03/87        Conversion to 1.1, and changed the
                                        organisation of the method
             PP       : 06/06/87        Conversion to the new class structure
                                        data structure and include files
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

 IGRdouble              knots[AXIS_KNOTS]; 
                                /* for storing the knots */
 IGRdouble              cyl_height; 
                                /* height of the cylinder */
 IGRpoint               poles[AXIS_POLES];
                                /* for storing the poles */
 struct IGRbsp_surface  *surf;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct EMcylinder_params *ptr; /* pointer to a structure containing 
                                   cylinder parameters */
 struct IGRbsp_curve    axis;
                                /* axis of the cylinder */
 extern  IGRboolean             BScylprop (),
                                EFsam_full_quadric_range_box();
                                /* Function declaration */


/* ***************************

   Initialisation

   *************************** */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 surf = NULL;

 axis.poles = (IGRdouble *) poles;
 axis.knots = (IGRdouble *) knots;
 axis.weights = NULL;
 axis.bdrys = NULL;

 if (type)
 {
  *type = EMcylinder;
 }

 if (params)
 {
  ptr = &params->params.cyl;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   surf = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   surf = geom;
 
  bssts = BScylprop (&rc, surf, &axis, &cyl_height, &ptr->radius,
                     &ptr->area, &ptr->volume);

  if (!bssts)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

  for (i=0; i < 3; i++)
    ptr->height[i] = axis.poles[3 + i] - axis.poles[0 + i];

  for (i=0 ; i<3; i++)
    ptr->base_center[i] = axis.poles[0+i];

  EMerr_hndlr(!EFsam_full_quadric_range_box(ptr->radius,
               ptr->radius, &axis.poles[0], &params->range[0]), 
              *EMmsg, EMS_E_BSerror, wrapup);
 } /* if (params) */

 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
  return (status);

}

end implementation EMScylindr;
