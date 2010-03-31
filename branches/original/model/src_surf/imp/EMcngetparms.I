/* ###################   APOGEE COMPILED   ################## */

class implementation EMScone;

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
# include "EMSsfparms.h"
#include "emsmacros.h"


#  define DEBUG 0

#define AXIS_POLES 2
#define AXIS_KNOTS 4

method EMget_params(
 IGRlong *EMmsg; /* Completion message */
 struct IGRbsp_surface *geom; /* Surface geometry */
 struct GRmd_env *env; /* module environment of the  surface */
 IGRushort *type; /* surface type */
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets the parameters of the cone when 
             specified the module environment.  

             Input
              env   Module environment
		
	      geom  Surface geometry
          
             Output
              EMmsg : Completion status
              type : geometric type of the surface. May be set to NULL if
                     not interested in the same.
              params : structure containing the type of the surface, which
                       in this case is EMcone and parameters to go with
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
    23 Sep 1988 AIC Modified type of BSconprop from boolean to
                    void.
	     SAM      : 10/05/88	Added geom argument and call to
					 EFsam_full_quadric_range_box to
					 return the range of the cone.
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


 IGRdouble              knots[AXIS_KNOTS]; 
                                /* for storing the knots */
 IGRdouble              cone_height; 
                                /* height of the cone */
 IGRpoint               poles[AXIS_POLES];
                                /* for storing the poles */
 struct IGRbsp_surface  *surf;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct IGRbsp_curve    axis;
                                /* axis of the cylinder */
 struct EMcone_params   *ptr;   /* pointer to structure containing cone
                                   parameters */
 extern void            BSconprop ();
 IGRboolean             EFsam_full_quadric_range_box();
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
  *type = EMcone;
 }

 if (params)
 {
  ptr = &params->params.cone;
  if(!geom)
  {
   GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
             &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   surf = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   surf = geom;

  BSconprop(surf, &axis, &cone_height, &ptr->top_radius,
            &ptr->base_radius, &ptr->area, &ptr->volume,
            &ptr->slant_height, &rc);

  /*
    BSconprop is a void function, but the return status was being
    checked here. I changed it to check the return code argument.
    AIC 23 Sept 1988
  */
  if (rc)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

  for (i=0; i < 3; i++)
    ptr->height[i] = axis.poles[3 + i] - axis.poles[0 + i];

  for (i=0 ; i<3; i++)
    ptr->base_center[i] = axis.poles[0+i];

  EMerr_hndlr(!EFsam_full_quadric_range_box(ptr->base_radius,
               ptr->top_radius, &axis.poles[0], &params->range[0]), 
              *EMmsg, EMS_E_BSerror, wrapup);

 } /* if (params) */
 
 wrapup:
  if (surf_ptr) GRabsg_del (surf_ptr);
#if DEBUG
  EMWRAPUP(*EMmsg, status, "In EMScone:  EMget_cone_props error");
#endif
  return (status);

}

end implementation EMScone;      
