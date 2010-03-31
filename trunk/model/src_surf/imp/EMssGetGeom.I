/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: EMSsubbs
     METHOD NAME: GRgetgeom

     Abstract: This routine gets the internal B-spline geometry of
               an object and places it into the provided storage.

-----
%SC%    
 
     GRgetgeom(msg,mat_type,matrix,geometry)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type    IGRshort       matrix type
     matrix       IGRmatrix      environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        return code:
                                        MSSUCC - successful
                                        MSFAIL - failed due to 
                                                 storage allocation problems.

     *geometry     IGRchar       geometry pointer (preallocated space)

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
              GRgenabsg

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
            The input geometry pointer must point to memory which
           has already been allocated.

            The pointer for the poles, weights, etc. will be assigned
           by this routine. Hence, the size of the memory allocated
           to hold the geometry should be the size of an IGRbsp_surface
           structure  plus  the size of the poles, weights, etc. in bytes.
           See method GRgetsize of class EMSsubbs for size computation.
-----
%CH%

     CHANGE HISTORY:
        
        RLW     07/10/86 : The beginning
        RLW     09/21/86 : OM 4.0 modifications
        AIC     05/04/87 : Return only surface3 geometry.
                           Boundaries can be obtained through the
                           EMget_boundaries method.
        NP      08/25/92 : Changed all char/int/double to IGRchar/IGRint/IGRdouble
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine sends a message to GRgenabsg to get the abstract 
geometry and then copies the geometry into the storage indicated by 
the input pointer.

----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
/*#include "grdef.h"*/
#include "madef.h"
#include "OMmacros.h"

method GRgetgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
                 IGRchar *geometry)
{
 IGRchar           *generic_pointer;
 IGRint            total_poles, num_pnts, num_bytes, i;
 IGRdouble         *double_ptr;
 struct         IGRbsp_bdry_ptrs *bnd_struct_ptr;
 struct         IGRbsp_surface *surface, *abstract, *surf_ptr;
/*
 * Initialize
 */
 *msg = MSSUCC;
 surface = (struct IGRbsp_surface *) geometry;
/*
 * Generate my abstract data
 */
 GRgetabsg(msg, mat_type, matrix, &generic_pointer, i);
  if (! (1 & *msg)) return(OM_E_ABORT);
 abstract = (struct IGRbsp_surface *) generic_pointer;
/*
 * Fill the the surface data
 */
 surface->u_order = abstract->u_order;
 surface->v_order = abstract->v_order;
 surface->u_periodic = abstract->u_periodic;
 surface->v_periodic = abstract->v_periodic;
 surface->u_non_uniform = abstract->u_non_uniform;
 surface->v_non_uniform = abstract->v_non_uniform;
 surface->u_num_poles = abstract->u_num_poles;
 surface->v_num_poles = abstract->v_num_poles;
 surface->u_num_knots = abstract->u_num_knots;
 surface->v_num_knots = abstract->v_num_knots;
 surface->rational = abstract->rational;
 surface->planar = abstract->planar;
 surface->u_phy_closed = abstract->u_phy_closed;
 surface->v_phy_closed = abstract->v_phy_closed;
 surface->pos_orient = abstract->pos_orient;
 surface->on_off = abstract->on_off;
 surface->num_boundaries = abstract->num_boundaries;
 surface->bdrys = NULL;
/*
 * Move the poles
 */
 surf_ptr = surface + 1;
 double_ptr = (IGRdouble *) GRalign_double(surf_ptr);
 surface->poles = double_ptr;
 total_poles = surface->u_num_poles * surface->v_num_poles;
 num_bytes = total_poles * 3 * sizeof(IGRdouble);
 OM_BLOCK_MOVE(abstract->poles, surface->poles, num_bytes);
 double_ptr += total_poles * 3;
/*
 * Move the weights
 */
 if (abstract->rational)
  {
   surface->weights = double_ptr;
   num_bytes = sizeof(IGRdouble) * total_poles;
   OM_BLOCK_MOVE(abstract->weights, surface->weights, num_bytes);
   double_ptr += total_poles;
  }
 else
  surface->weights = NULL;
/*
 * Move the knots
 */
 surface->u_knots = double_ptr;
 num_bytes = sizeof(IGRdouble) * abstract->u_num_knots;
 OM_BLOCK_MOVE(abstract->u_knots, surface->u_knots, num_bytes);
 double_ptr += abstract->u_num_knots;
 surface->v_knots = double_ptr;
 num_bytes = sizeof(IGRdouble) * abstract->v_num_knots;
 OM_BLOCK_MOVE(abstract->v_knots, surface->v_knots, num_bytes);
 double_ptr += abstract->v_num_knots;

 return(OM_S_SUCCESS);
}
end implementation EMSsubbs;
