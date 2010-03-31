/*
  DESCRIPTION

    A linked list of two EMpypoints is input and these represent the 
    boundary on the input geometry which may be a polyline or a B-spline
    curve. This function then extracts the geometry lying in between these
    two boundaries and returns it.
 
    This function always assumes the output "carrier" structure pointing
    to a valid IGRpolyline in the case of polylines or an IGRbsp_curve in the
    case of B-spline curves. The 'points' pointer inside the IGRpolyline
    or the 'poles', 'weights' and 'knots' inside the IGRbsp_curve  may be
    passed in as NULL. In this case this function will malloc the memory
    as individually freeable chunks. If any of these pointers is non-NULL,
    this function assumes sufficient space for output is available.
    The input boundaries need not be in increasing order.

  RETURN VALUE

    EMS_S_Success -
      If all went well and the output was not really clipped
    EMS_I_Clipped - 
      If all went well and the output was really clipped
    EMS_I_Degenerate -
      If all went well and the output was degenerate

    On error an EMS_E_InvalidArg or EMS_E_NoDynamicMemory is returned

  HISTORY

    SS  :  Long time :  Creation
    SS  :  02/16/89  :  Added the return code EMS_I_Clipped
   Sudha   07/08/93  :  Modified for BSprototypes ansification

*/

#include "EMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "bspartofcv.h"

void EMgetactgm (msg, ingeom, pybdry, outgeom)
IGRlong *msg;
struct EMSdataselect *ingeom;
struct EMSpypoint *pybdry;
struct EMSdataselect *outgeom;
{
  IGRshort dim;
  IGRint np;
  IGRlong msg_loc, stat_func;
  IGRdouble startpar, midpar, stoppar, tmppar;
  struct IGRbsp_curve *incrv, *outcrv;
  union EMSdata data;
  enum EMSdatatype datatype;

  *msg = EMS_S_Success;

  datatype = ingeom->datatype;
  data = ingeom->data;
  if (datatype == EMSdata_poly2d || 
      datatype == EMSdata_poly3d)
    {
    dim = datatype == EMSdata_poly2d ? 2 : 3;
    EMgetactpy (&msg_loc, data.poly, dim, pybdry, outgeom->data.poly);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (msg_loc == EMS_I_Clipped)
      *msg = EMS_I_Clipped;
    else if (msg_loc == EMS_I_Degenerate)
      *msg = EMS_I_Degenerate;
    outgeom->datatype = datatype;
    }
  else if (datatype == EMSdata_curve3d)
    {
    incrv = data.curve;
    outcrv = outgeom->data.curve;
    if (!outcrv->poles)
      outcrv->poles = (IGRdouble *) om$malloc (size = 
       (np = incrv->num_poles + 2 * incrv->order - 1) *
       3 * sizeof (IGRdouble));
    if (!outcrv->knots)
      outcrv->knots = (IGRdouble *) om$malloc (size = 
       (np + incrv->order) * sizeof (IGRdouble));
    if (incrv->rational && !outcrv->weights)
      outcrv->weights = (IGRdouble *) om$malloc (size = 
       np * sizeof (IGRdouble));
    EMerr_hndlr (!outcrv->poles || !outcrv->knots ||
     (incrv->rational && !outcrv->weights), *msg, EMS_E_NoDynamicMemory,
     ret_end);

    startpar = pybdry->param;
    stoppar = pybdry->next->param;
    if (startpar > stoppar)
      {
      tmppar = startpar;
      startpar = stoppar;
      stoppar = tmppar;
      }
    midpar = startpar + (stoppar - startpar) / 2.0;
    stat_func = BSpartofcv (&msg_loc, data.curve, startpar, midpar, stoppar,
                 outgeom->data.curve);
    EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror, 
         ret_end);
    if (startpar != 0.0 || stoppar != 1.0)
      *msg = EMS_I_Clipped;
    else if (startpar == stoppar)
      *msg = EMS_I_Degenerate;
    outgeom->datatype = datatype;
    }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMgetactgm");
}
