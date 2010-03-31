/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

#include "OMerrordef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "EMSbstrim.h"
#include "OMprimitives.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsspn_t_bz.h"
#include "bsbx2.h"

EMgetspan (EMmsg, mygeom, mspn, mbz)

/*
 * This function allocates memory for the poles weights and knots if the
 * appropriate pointers in the curve structure are set to null
 * Otherwise it assumes that sufficient memory is coming in and will not
 * allocate memory.
 */

/*
History
	DLB	9/21/91		BSbx2 was passed *short instead of *int
				SUN issue.
        Sudha   07/08/93        Modified for BSprototypes ansification
        SCW     13-Feb-1997     included emsmacros_c.h rather than emsmacros.h

*/

IGRlong *EMmsg;
struct IGRbsp_curve *mygeom;
IGRint *mspn;
struct EMplanar_bezier_curve *mbz;

{
 
     IGRlong num_bytes;
      BSrc rc;

     *EMmsg = EMS_S_Success;

     if (!mbz->curve.poles)
     {
     num_bytes = sizeof (IGRpoint) * mygeom->order;
     mbz->curve.poles = (IGRdouble *) om$malloc (size = num_bytes);
     EMerr_hndlr (!mbz->curve.poles, *EMmsg, EMS_E_DynamicMemoryAllocated,
                  wrapup);
     }


     if (!mbz->curve.knots)
     {
     num_bytes = sizeof (IGRdouble) * (mygeom->order + mygeom->order);
     mbz->curve.knots = (IGRdouble *) om$malloc (size = num_bytes);
     EMerr_hndlr (!mbz->curve.knots, *EMmsg, EMS_E_DynamicMemoryAllocated,
                  wrapup);
     }

     if (mygeom->rational)
     {
      if (!mbz->curve.weights)
      {
      num_bytes = sizeof (IGRdouble) * mygeom->order;
      mbz->curve.weights = (IGRdouble *) om$malloc (size = num_bytes);
      EMerr_hndlr (!mbz->curve.weights, *EMmsg,
                    EMS_E_DynamicMemoryAllocated, wrapup);
      }
     }
      
     (void) BSspn_t_bz ( &rc, *mspn, mygeom, &mbz->curve, FALSE,
                         FALSE);
     EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

     if (mbz->curve.rational)
     {
	IGRlong num_pts;
	num_pts = mbz->curve.order; 	/*pass *int - DLB */
     (void) BSbx2 ( &rc, &num_pts,
                     (IGRpoint *)mbz->curve.poles, mbz->curve.weights,
                     mbz->minmax.min,
                     mbz->minmax.max);
     EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);
     }
     else
     {
	IGRlong num_pts;
	num_pts = mbz->curve.order; 	/*pass *int - DLB */
     (void) BSbx2 ( &rc, &num_pts,
                     (IGRpoint *)mbz->curve.poles, NULL,
                     mbz->minmax.min,
                     mbz->minmax.max);
     EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);
     }

     mbz->minmax.valid = TRUE;

wrapup:

 return;

}

