/*
  DESCRIPTION

    This method treats the composite as a merged curve and returns
    the poles requested based on this geometry.

  HISTORY

    SS  :  01/06/89  :  Creation
*/

class implementation GRcompcurve;

#include "EMS.h"
#include "gocmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "msdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetpoles (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   IGRlong *start; IGRlong *needed; IGRdouble *points;
                   IGRlong bufsize; IGRlong *sent; IGRboolean *is_reg)
{
  IGRint dumint, i, frominx, toinx, inx;
  IGRlong stat_OM, msg_loc;
  struct IGRbsp_curve *cv;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *is_reg = TRUE;

  GRgetabsg (&msg_loc, mattyp, mat, (char **) &cv, dumint);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
  if (cv->num_poles < *start)
    {
    *sent = 0;
    goto ret_end;
    }
  else if (cv->num_poles - *start < *needed)
    *sent = cv->num_poles - *start;
  else
    *sent = *needed;

  frominx = *start;
  toinx = *start + *sent;
  inx = 0;
  for (i=3*frominx; i<3*toinx; i++)
    points[inx++] = cv->poles[i];
  if (cv->rational)
    {
    inx = 0;
    for (i=frominx; i<toinx; i++)
      {
      points[inx++] /= cv->weights[i];
      points[inx++] /= cv->weights[i];
      points[inx++] /= cv->weights[i];
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "GRcompcurve.EMgetpoles");
  return (stat_OM);
}

end implementation GRcompcurve;

