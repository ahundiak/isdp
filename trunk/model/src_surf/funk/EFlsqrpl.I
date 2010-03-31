/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "emsdattyp.h"
#include "bserr.h" /* FOR BSSUCC.. */
#include "bsparameters.h" /* For BSTOLCLOSETOZERO */
#include "bslsqrpl2.h"

IGRint EFgenerate_least_squares_plane (EMmsg, curve_GRid, curve_env, pln)
IGRlong *EMmsg;
struct GRid *curve_GRid;
struct GRmd_env *curve_env;
struct IGRplane *pln;

/************************************************************************

Description

  This function determines a least square infinite plane passing through
  a given curve which can either be a composite curve or a regular curve.
  
Arguments
 Input
 curve_GRid : Grid of the input curve about which a least squares plane
              needs to be determined
 curve_env  : curve environment

 Output
 EMmsg : completion status
 pln : Plane structure


Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If everything goes OK
 EMS_E_Fail: Error in getting geometry
 EMS_E_BSerror: If error in math routine to determine the least squares
                plane
 EMS_E_InvalidArg: Probably because the determined plane was degenerate or
                   if a valid curve is not passed

History
   Creation : PP : 08/08/89
   dhm    10/22/92    initialize coeffs.
   Sudha  07/06/93    Modified for BSprototypes ansification

************************************************************************ */

{
 IGRlong rc,sts;
 IGRint n,indx;
 IGRdouble coeffs[4], save_coeff;
 IGRint code;
 IGRchar *geom = NULL;
 IGRdouble zero_tol;
 struct IGRbsp_curve *curve = NULL;
 IGRvector normal;
 enum EMSdatatype type;
 extern IGRdouble fabs();

 *EMmsg = EMS_S_Success;
 sts = 1;

 /* Initialize coeffs */

 for (n = 0; n < 4; n++)
    coeffs[n] = 0.0;

 pln->point[0] = 0.0;
 pln->point[1] = 0.0;
 pln->point[2] = 0.0;

 sts = BSEXTRACTPAR (&rc, BSTOLCLOSETOZERO, zero_tol);

 EMgetvggeom(EMmsg, &curve_env->md_env.matrix_type, curve_env->md_env.matrix,
            curve_GRid, &geom, &type);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 EMerr_hndlr((type != EMSdata_curve3d), *EMmsg, EMS_E_InvalidArg, wrapup);

 curve = (struct IGRbsp_curve *)geom;

 BSlsqrpl2 (curve->num_poles,curve->poles,curve->weights,&code,coeffs,
            normal,&rc);
 EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

 for (n=0;n<3;n++)
   pln->normal[n] = normal[n];

 save_coeff = 0.0;
 indx  = 0;

 for(n=0;n < 3;n++ )
 {
  if (save_coeff < fabs(coeffs[n]))
  {
   save_coeff = fabs(coeffs[n]);
   indx = n;
  }
 }
/*
 * If the maximum of the coefficients of the plane is less than zero tol
 * then we cannot handle this case.
 */
 if( save_coeff < zero_tol)
 {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup; 
 }
 pln->point[indx] = - coeffs[3] / coeffs[indx];

wrapup:
 if (geom) om$dealloc(ptr = geom);
 if (!(1&*EMmsg)) return (0);
 else return (1);

}
end implementation EMSsubbs;

