/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  DESCRIPTION

    Given some curve data and the zero-length tolerance, this function
    returns a reasonable approximation of the curves-parametric
    tolerance. If the input is a B-spline the curve is assumed parameterized
    from 0.0 to 1.0. If it is a polyline, then each span is assumed 
    parameterized from 0.0 to 1.0. In the latter case, a specific span
    on which to compute is also input. If the span is degenerate, a 
    parametric tolerance of 1.0 is the result.

  BUGS

    Currently, only 2D polylines are supported.

  HISTORY

    SS  :  02/01/88  :  Creation
    RV  :  05/05/88  :  Added support for 3d curves.
    Sudha  07/09/93  :  Modified for BSprototypes anisfication

*/

#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "OMmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bscumdist.h"

#define X 0
#define Y 1

void EMwpartol (msg, cvdata, span, lentol, partol)
IGRlong *msg;
struct EMSdataselect *cvdata;
IGRint span;
IGRdouble lentol, *partol;
{
  IGRlong msg_loc, tmp_msg;
  IGRdouble *pts, seglen, dx, dy;
  struct IGRpolyline *py;
  enum EMSdatatype datatype;


  *msg = EMS_S_Success;
  tmp_msg = EMS_S_Success;
  datatype = cvdata->datatype;
  switch (datatype)
    {
    case EMSdata_poly2d:
      py = cvdata->data.poly;
      EMerr_hndlr (py->num_points < 2, *msg, EMS_E_InvalidArg, ret_end);
      pts = &py->points[span * 2];
      dx = pts[X+2] - pts[X];
      dy = pts[Y+2] - pts[Y];
      seglen = sqrt (dx*dx + dy*dy);
      if (seglen < MINDOUBLE)
        *partol = 1.0;
      else
        *partol = 1.0 / (seglen / lentol);
      break;
    case EMSdata_curve3d:
      BScumdist(&msg_loc, &(cvdata->data.curve->num_poles),
       cvdata->data.curve->poles,
       cvdata->data.curve->rational ? cvdata->data.curve->weights : NULL,
       &seglen);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      if (seglen < MINDOUBLE) *partol = 1.0;
      else *partol = 1.0 / (seglen / lentol);
      break;
    default:
      *msg = EMS_E_InvalidArg;
    }

ret_end:
  EMWRAPUP (*msg, tmp_msg, "EMwpartol");
}


