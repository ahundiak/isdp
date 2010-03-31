/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

#include <math.h>

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
#include "msdef.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"

void EMuvresolve (msg, uvinx, uvval, min, max, tol, poly, bdry, corresp_bdry)
IGRlong *msg;
IGRint uvinx;
IGRdouble uvval[2], min, max, tol;
struct IGRpolyline *poly;
struct EMSpypoint *bdry, *corresp_bdry;
{
  IGRlong msg_loc;
  IGRboolean further_check;
  IGRdouble uvval_alt[2], mindist;
  struct EMSpypoint temp_bdry, *temp_bdry_ptr;
  void EMcnvtpypts();

  *msg = MSSUCC;
  temp_bdry_ptr = &temp_bdry;

  further_check = FALSE;
  if (fabs (uvval[uvinx] - min) <= tol)
    {
    uvval_alt[uvinx] = max;
    uvval_alt[!uvinx] = uvval[!uvinx];
    further_check = TRUE;
    }
  else if (fabs (uvval[uvinx] - max) <= tol)
    {
    uvval_alt[uvinx] = min;
    uvval_alt[!uvinx] = uvval[!uvinx];
    further_check = TRUE;
    }

  /*
   * There seems to exist a possibility of not having
   * to do this conversion to "temp_bdry" based on a
   * criterion that seeks to determine if the point represented
   * by "bdry" is indeed the corresponding point on
   * "corresp_bdry". Some thought needs to go into that 
   * one. For now this mandatory check (if further_check)
   * will suffice.
   */

  if (further_check)
    {
    EMcnvtpypts (&msg_loc, poly, 2, 1, uvval_alt, &temp_bdry_ptr, &mindist);
    EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);

    if (fabs ((temp_bdry.span_inx + temp_bdry.param) -
              (corresp_bdry->span_inx + corresp_bdry->param)) <
        fabs ((temp_bdry.span_inx + temp_bdry.param) -
              (bdry->span_inx + bdry->param)))
      {
      *bdry = temp_bdry;
      bdry->next = NULL;
      }
    }

ret_end:;
}
