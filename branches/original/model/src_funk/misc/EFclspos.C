/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h" 
#include "bserr.h"
#include "bsparameters.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "emsdattyp.h" /* For EMSdataselect */
#include "bsdistptpts.h"
#include "bscveval.h"

#define NUM_DERIV 0

IGRboolean EFclassify_position(EMmsg, indata, inpar, atstart, atend)
IGRlong *EMmsg;
struct EMSdataselect *indata;
IGRdouble *inpar;
IGRboolean *atstart;
IGRboolean *atend;
/* **********************************************************************

Description
  This function classifies the postion of the inparameter as to whether
  it is at the start or at the end. 

Arguments
 Input
   indata : It is meant to handle either object id or a curve buffer.
            Currently it only handles a curve buffer.
   inpar  : The parameter on the curve which needs to be classified.
   
 Output
   atstart : is TRUE if the point corresponding to inpar is at the start
             of the bspline curve.
   atend : is TRUE if the point corresponding to inpar is at the end of the
           bspline curve.
   EMmsg : completion code

Notes
 Upon exit the completion code will be one of the following:
 EMS_E_InvalidArg: If one is passing in anything except a curve 3d buffer
                   for the incoming geometry.
 EMS_E_BSerror : If there was a math error in either evaluating a parameter
                 or in getting the tolerance.
 
History
 Creation : PP : 08/23/88
 
	Sudha	07/08/93	Modified for BSprototypes ansification
        SCW     13-Feb01997     included emsmacros_c.h rather than emsmacros.h

 ************************************************************************* */

{
 IGRpoint startpt, endpt;
 IGRpoint inpt;
 IGRdouble dist;
 IGRdouble distsqtol;
 IGRlong rc;
 IGRboolean bssts;
 struct IGRbsp_curve *ingeom;

 *EMmsg = EMS_S_Success;

 if (indata->datatype != EMSdata_curve3d)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 
 ingeom = indata->data.curve;

 BScveval (ingeom, ingeom->knots[ingeom->order - 1], NUM_DERIV, (IGRpoint *)startpt, &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 BScveval (ingeom, ingeom->knots[ingeom->num_poles], NUM_DERIV, (IGRpoint *)endpt, &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 BScveval (ingeom, *inpar, NUM_DERIV, (IGRpoint *)inpt, &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 bssts = BSEXTRACTPAR(&rc, BSTOLSQLENVEC, distsqtol);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

 dist = BSdistptpts (&rc, startpt, inpt);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

 
 if (dist < distsqtol)
 {
   *atstart = TRUE;
   *atend = FALSE;
 }
 else
 {
   dist = BSdistptpts (&rc, endpt, inpt);
   EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

   if (dist < distsqtol)
   {
    *atstart = FALSE;
    *atend = TRUE;
   }
   else
   {
    *atstart = FALSE;
    *atend = FALSE;
   }
 }

wrapup:
 if (!(1&*EMmsg)) return (FALSE);
 else
  return (TRUE);
}
