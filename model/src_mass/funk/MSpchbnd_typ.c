/* ###################   APOGEE COMPILED   ################## */
/*
	This function determines the boundary condition of a patch when it
    shares a natural boundary of the surface

    gupta   : 12/27/88   creation
 
*/

#include    "EMS.h"
#include	"igrtypedef.h"
#include 	"emsmass.h"
#include    "wanginc.h"

MSpatch_boundary_type (patch_data, knot_tol, boundary_type)

struct BNpatch        *patch_data;
IGRdouble             knot_tol;
IGRlong               *boundary_type;

{
 
 if ((patch_data->us <= knot_tol) && (patch_data->vs <= knot_tol) &&
     (patch_data->ud >= 1-knot_tol))
      *boundary_type = BND_V_ZERO_ONLY;
 else
 if ((patch_data->us <= knot_tol) && (patch_data->vs <= knot_tol) &&
     (patch_data->vd >= 1-knot_tol))
      *boundary_type = BND_U_ZERO_ONLY;
 else
 if ((patch_data->ud >= 1-knot_tol) && (patch_data->vd >= 1-knot_tol) &&
     (patch_data->us <= knot_tol))
      *boundary_type = BND_V_ONE_ONLY;
 else
 if ((patch_data->ud >= 1-knot_tol) && (patch_data->vd >= 1-knot_tol) &&
     (patch_data->vs <= knot_tol))
      *boundary_type = BND_U_ONE_ONLY;
 else
 if ((patch_data->us <= knot_tol) && (patch_data->ud >= 1-knot_tol))
      *boundary_type = BND_U_ZERO_U_ONE;
 else
 if ((patch_data->vs <= knot_tol) && (patch_data->vd >= 1-knot_tol))
      *boundary_type = BND_V_ZERO_V_ONE;
 else
 if ((patch_data->us <= knot_tol) && (patch_data->vs <= knot_tol))
      *boundary_type = BND_ZERO_ZERO;
 else
 if ((patch_data->us <= knot_tol) && (patch_data->vd >= 1-knot_tol))
      *boundary_type = BND_ZERO_ONE;
 else
 if ((patch_data->ud >= 1-knot_tol) && (patch_data->vd >= 1-knot_tol))
      *boundary_type = BND_ONE_ONE;
 else
 if ((patch_data->vs <= knot_tol) && (patch_data->ud >= 1-knot_tol))
      *boundary_type = BND_ONE_ZERO;
 else
 if (patch_data->us <= knot_tol)
      *boundary_type = BND_U_ZERO;
 else
 if (patch_data->ud >= 1-knot_tol)
      *boundary_type = BND_U_ONE;
 else
 if (patch_data->vs <= knot_tol)
      *boundary_type = BND_V_ZERO;
 else
 if (patch_data->vd >= 1-knot_tol)
      *boundary_type = BND_V_ONE;
 else
      *boundary_type = NOT_ON_PATCH_BND;
 
 return;

}
