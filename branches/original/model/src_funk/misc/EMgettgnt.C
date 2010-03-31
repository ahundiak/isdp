/* ###################   APOGEE COMPILED   ################## */

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

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

#include "emserr.h"
#include "OMmacros.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscveval.h"

EMget_tangent(msg_loc,geom,par,reverse,vector)

IGRlong *msg_loc;
struct IGRbsp_curve *geom;
IGRdouble *par;
IGRboolean reverse;
IGRvector vector;
{
 BSrc rc;
 IGRpoint deriv[2];
 IGRboolean bssts;
 IGRint num_deriv;

 num_deriv = 1;
 BScveval (geom, *par, num_deriv, deriv, &rc);
 EMerr_hndlr (BSERROR(rc), *msg_loc, EMS_E_Fail, wrapup);

 OM_BLOCK_MOVE (deriv[1], vector, sizeof (IGRpoint));
 bssts = BSnorvec (&rc, vector);
 EMerr_hndlr (!bssts, *msg_loc, EMS_E_Fail, wrapup);

 if (reverse)
 {
   vector[X] = 0.0 - vector[X];
   vector[Y] = 0.0 - vector [Y];
 }

 wrapup:

 return;
}
 

 

