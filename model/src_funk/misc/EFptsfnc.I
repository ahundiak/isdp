/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "igr.h" /* For IGRrt_prism */
#include "EMSerrordef.h" /* For EMS_S_Success */
#include "bspolincfnc.h"
#include "bspol_infnc.h"

EFptsinfnc(EMmsg,ptset,prism_type,prism,ind)
IGRlong *EMmsg;
struct IGRpointset *ptset;
IGRshort prism_type;
IGRchar *prism;
IGRint *ind;
{
 IGRlong sts;
 IGRlong rc;
 struct IGRbsp_curve curve;

 sts = 1;
 *EMmsg = EMS_S_Success;

/*
 * Currently fool the math function; Change the same when math get their
 * act together and provide a function which only takes in points
 * and not a curve geometry.
 */

 curve.num_knots = 0;
 curve.knots = NULL;
 curve.weights = NULL;
 curve.order = 0;
 curve.bdrys = NULL;
 curve.rational = FALSE;

 curve.num_poles = ptset->num_points;
 curve.poles = ptset->points;
 
 
 if (prism_type == GRCURVE_PRISM)
  BSpolincfnc(&curve,(struct IGRcv_prism *)prism,ind,&rc);
 else
  BSpol_infnc(&curve,(struct IGRrt_prism *)prism,ind,&rc);

 EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

wrapup:
 return (sts);
}
end implementation EMSsubbs;

