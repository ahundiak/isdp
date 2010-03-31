/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emserr.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSmsgdef.h"
#include "bstrplprod.h"
#include "bsmdistptcv.h"
#include "bscvarrevt.h"
#include "bsbx2.h"

EFcwccw(EMmsg, curve, cwccw)

 IGRlong             *EMmsg;
 struct IGRbsp_curve *curve;
 IGRint              *cwccw;


/*

	This method finds the clockwise / counterclockwise orientation of
    a curve.

*cwccw = 1  -----------    clockwise
*cwccw = -1 -----------    counter-clockwise
else        -----------    unknown

Notes
    The curve should be planar

History
	gupta	01/12/88	creation date
        Sudha   07/09/93        Modified for BSprototypes anisfication
        SCW     02/13/97        Changed emsmacros inclusion to emsmacros_c


*/

{
  IGRlong             msg;
  IGRshort            k, n;
  IGRint              i,
                      numpar;
  IGRvector           tangent,
                      normal,
                      ref_vector;
  IGRdouble           *pars = NULL, 
                      *intpars = NULL,
                      dist,
                      knot_tol,
                      product;
  IGRpoint            tan_xyz[1][2],
                      ext_pt;
  IGRpoint            min, max;
  IGRboolean          stat;

/*-----------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;

  if (! curve->planar)
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }

  BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

  stat = BSbx2 (&msg, &curve->num_poles, (IGRpoint *)curve->poles, curve->weights,
                min, max);
  EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, msg, wrapup);

  /* get a point in the ratio 9:1 external to line min - max */

  for (i=0; i<3; i++)
   ext_pt[i] = (min[i] * 10 - max[i]) / 9;

  BSmdistptcv(curve, ext_pt, &k, &n, &pars, &dist, &intpars, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, msg, wrapup);

  pars[0] -= 100 * knot_tol; /* to avoid inflexion points */

  if (pars[0] < 0.0) pars[0] = 0.0;

  numpar = 1;
  BScvarrevt(curve, pars, numpar, dist, tan_xyz, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, msg, wrapup);

  for (i=0; i<2; i++)
   {
    tangent[i] = tan_xyz[0][1][i] - tan_xyz[0][0][i];
    normal[i] =  ext_pt[i] - tan_xyz[0][0][i];
   }
  tangent[2] = normal[2] = 0.0; /* transform the vectors on  */
                                /* to x-y plane              */

  ref_vector[0] = ref_vector[1] = 0.0;
  ref_vector[2] = dist;

  stat = BStrplprod(&msg, tangent, normal, ref_vector, &product);
  EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, msg, wrapup);

  if (product > 0)
      *cwccw = 1;
  else
  if (product < 0)
      *cwccw = -1;
  else
      *cwccw = 0;

wrapup:
  return; 
}
