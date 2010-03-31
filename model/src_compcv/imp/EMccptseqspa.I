class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsprptoncv.h"

extern OMuword OPP_GRbcsubbc_class_id;

method GRptseqspace(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  IGRpoint pnt1, pnt2, pnt3; struct GRparms *parm1, *parm2, *parm3;
		  IGRlong *num; IGRdouble *out_points)
/*
Abstract
	This method produces a point on a composite curve at a given distance
	from the input point in the direction of the second point.

Arguments

Notes

Files
	EMccptalong.I

History
	dhm		10/26/87		Creation date.
	dhm		12/21/87		converted to 1.1
        Sudha   06/21/93        modified for BSprototype ansification
*/

{
  IGRlong	msg_loc, status;
  IGRdouble par1, par2, par3;
  IGRboolean	on_curve, sts;
  IGRchar	errmsg[EMMAXERRMSG_LEN];
  struct IGRbsp_curve	*comp_cv;
  struct IGRpolyline	pnt_set;
  extern  IGRboolean  GRpybcueqspace();

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "GRcompcurve.GRptalong\n");
  comp_cv = NULL;

  /*
   * Get the abstract geometry
   * of myself (composite curve)
   */

  GRgetabsg (&msg_loc, matrix_type, matrix, (char **) &comp_cv, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the parameter value of pnt1, pnt2, pnt3 on the
   * composite curve.
   */

  sts = BSprptoncv(&msg_loc, comp_cv, pnt1, &par1, &on_curve);
  EMerr_hndlr((!sts || msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  sts = BSprptoncv(&msg_loc, comp_cv, pnt2, &par2, &on_curve);
  EMerr_hndlr((!sts || msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  sts = BSprptoncv(&msg_loc, comp_cv, pnt3, &par3, &on_curve);
  EMerr_hndlr((!sts || msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  /*
   * Call the routine which computes the
   * points between pnt1 and pnt3.
   */

  pnt_set.points = out_points;

  sts = GRpybcueqspace(&msg_loc, comp_cv, num, pnt1, pnt2, pnt3, &par1,
                       &par2, &par3, &pnt_set);
  EMerr_hndlr((!sts || msg_loc != MSSUCC), *msg, MSFAIL, ret_end);

ret_end:
	return(status);

}

end implementation GRcompcurve;
