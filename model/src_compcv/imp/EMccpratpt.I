class implementation GRcompcurve;

/*
  HISTORY

        Sudha   06/21/93        modified for BSprototype ansification
*/

#include "EMScc.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsprptoncv.h"

method EMpratpt (IGRlong *msg; IGRshort *mat_type; IGRmatrix
    matrix; IGRpoint wpoint_xyz; IGRdouble point_parametric[]; IGRint
    *num_parameters)
{
  IGRlong	msg_loc, status;
  IGRchar	errmsg[EMMAXERRMSG_LEN];
  IGRboolean	sts, on_curve;
  struct IGRbsp_curve	*comp_cv;                   

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "GRcompcurve.EMpratpt\n");

  /*
   * Get the abstract geometry
   * of myself (composite curve)
   */

  GRgetabsg (&msg_loc, mat_type, matrix, (char **) &comp_cv, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the parameter value of pnt1 on the
   * composite curve.
   */

  sts = BSprptoncv(&msg_loc, comp_cv, wpoint_xyz, point_parametric,
                   &on_curve);
  EMerr_hndlr((!sts || msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  if (on_curve) *num_parameters = 1;
  else *num_parameters = 0;

  ret_end:
	return(status);
}

end implementation GRcompcurve;
