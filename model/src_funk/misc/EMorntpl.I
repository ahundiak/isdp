/*

 This function inputs plane geometry and an axis defined by 2 points 
 (refpts[6]).

 It will rearrange the poles of the planes such that the closest of the plane
 axes to the input axis becomes u=0.

History

      PP        21-Jan-94       Fix for TR 119415885
      PP        02-Aug-93       Fixed a bug in setting of pos-orient.
      Sudha     09-jul-93       Modified for BSprototypes anisfication
      DLB       26-Jun-92       Added closed_cv param.  If passed in use
                                BSortcvnorm to get a consistent normal to the
                                curve plane instead of using the
                                less-than-perfect curve vector/dot product
                                stuff. 
      SM        28-May-92       Created this function from DLB's code which
                                existed in EMedcappl.I.
*/
class implementation EMSedge;

#include "EMS.h"

#ifndef SUNOS5
%safe
#include <math.h>
%endsafe
#endif

#include "emsmacros.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "EMScap.h"
#include "bs.h"
#include "bsparameters.h"
#include "msdef.h"
#include "maerr.h"
#include "emsmapdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "emsplndef.h"
#include "bserr.h"
#include "bsortcvnorm.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bscrossp.h"
#include <stdio.h>


IGRlong EMorient_plane(EMmsg, refpts, plane, closed_cv)
IGRlong *EMmsg;
IGRdouble *refpts;
struct IGRbsp_surface *plane;
struct IGRbsp_curve *closed_cv;
{

 IGRdouble              mnd=MAXDOUBLE, dists, dotp0, dotp1;
 IGRpoint               pl_poles[4], cv_poles[2];
 IGRvector              cv_vec, pl_vec0, pl_vec1, cv_nor_vec, pl_nor_vec;
 BSrc                   rc;
 IGRint                 jj, uv0, index[4];
 IGRint                 ccode;
 IGRvector              bef_vec, aft_vec;
 IGRdouble              zerotol;
 extern IGRboolean      WANT_POST220_BEHAVIOR;

 BSEXTRACTPAR (&rc, BSTOLSQLENVEC, zerotol);

 OM_BLOCK_MOVE(plane->poles, pl_poles, 4*sizeof(IGRpoint));
 BSptlnplan((plane->u_num_poles + plane->v_num_poles), 
            plane->rational, (IGRpoint *)plane->poles, 
            plane->weights, &ccode, bef_vec, &rc);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
 BSnorvec(&rc, bef_vec);

 if (closed_cv)
 {
   OM_BLOCK_MOVE(closed_cv->poles, &cv_poles[0][0], sizeof(IGRpoint));
   OM_BLOCK_MOVE(&closed_cv->poles[3], &cv_poles[1][0], sizeof(IGRpoint));
 }
 else if (refpts)
 {
   OM_BLOCK_MOVE(refpts, &cv_poles[0][0], sizeof(IGRpoint));
   OM_BLOCK_MOVE(&refpts[3], &cv_poles[1][0], sizeof(IGRpoint));
 }
 else
 {
   *EMmsg = EMS_E_InvalidCase; goto wrapup;
 }

 for(jj=0; jj<4; jj++)
 {
   dists = BSdistptpts(&rc, &cv_poles[0][0], &pl_poles[jj][0]);

/*
 * The following fix is being made for TR 119415885. In this the plane
 * that was replacing the disk created in revolution was changing 
 * parametrization whenever the profile driving the solid of revolution
 * was being changed. This caused the reference plane in the TR to
 * flip. 
 * This was happening because noise governed which pole of the plane got
 * picked as the origin. In the above TR case there were two poles which
 * were equidistant from the circle.
 * The fix is being activated for post 220 files only because of flipping
 * problems that it may cause with pre 2.2 files.
 * end pp 
 * 01/22/94
 */


   if (WANT_POST220_BEHAVIOR)
   {
    if ((dists < mnd) && (fabs (dists - mnd) > zerotol))
    {
     uv0 = jj;
     mnd = dists;
    }
   }
   else
   {
    if (dists < mnd)
    {
     uv0 = jj;
     mnd = dists;
    }
   }
 }

 /*Now find which direction to use*/

 if (closed_cv)
 {
   (void) BSortcvnorm(closed_cv, cv_nor_vec, &rc);
   if (BSERROR(rc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 }
 else
 {
   BSmkvec(&rc, cv_vec, &cv_poles[0][0], &cv_poles[1][0]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   BSnorvec(&rc, cv_vec);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);  
 }

 if (uv0 == 0)
 {
   BSmkvec(&rc, pl_vec0, pl_poles[0], pl_poles[1]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   BSmkvec(&rc, pl_vec1, pl_poles[0], pl_poles[2]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (uv0 == 1)
 {
   BSmkvec(&rc, pl_vec0, pl_poles[1], pl_poles[0]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   BSmkvec(&rc, pl_vec1, pl_poles[1], pl_poles[3]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (uv0 == 2)
 {
   BSmkvec(&rc, pl_vec0, pl_poles[2], pl_poles[3]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   BSmkvec(&rc, pl_vec1, pl_poles[2], pl_poles[0]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
 }
 else 
 {
   BSmkvec(&rc, pl_vec0, pl_poles[3], pl_poles[2]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   BSmkvec(&rc, pl_vec1, pl_poles[3], pl_poles[1]);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
 }
  
 BSnorvec(&rc, pl_vec0);
 EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

 BSnorvec(&rc, pl_vec1);
 EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);      

 index[0] = uv0;

 if (closed_cv)
 {
   BScrossp(&rc, pl_vec0, pl_vec1, pl_nor_vec);
   if (BSERROR(rc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   dotp0 = BSdotp(&rc, pl_nor_vec, cv_nor_vec);

   if (dotp0 > 0.0)
   {
     /*Plane and curve normal same direction so force into the if case below*/
     dotp0 = 1.0;
     dotp1 = 0.0;
   }
   else
   {
     /*Plane and curve normal opposite direction so force into else below*/
     dotp0 = 0.0;
     dotp1 = 1.0;
   }
 }  
 else
 {
   dotp0 = fabs(BSdotp(&rc, pl_vec0, cv_vec));
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

   dotp1 = fabs(BSdotp(&rc, pl_vec1, cv_vec));  
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
 }

 if (dotp0 > dotp1)
 {
   if (uv0 == 0)
   {
     index[1] = 1; index[2] = 2; index[3] = 3;
   }
   else if (uv0 == 1)
   {
     index[1] = 0; index[2] = 3; index[3] = 2;
   }
   else if (uv0 == 2)
   {
     index[1] = 3; index[2] = 0; index[3] = 1;
   }
   else if (uv0 == 3)
   {
     index[1] = 2; index[2] = 1; index[3] = 0;
   }
 }
 else
 {
   if (uv0 == 0)
   {
     index[1] = 2; index[2] = 1; index[3] = 3;
   }
   else if (uv0 == 1)
   {
     index[1] = 3; index[2] = 0; index[3] = 2;
   }
   else if (uv0 == 2)
   {
     index[1] = 0; index[2] = 3; index[3] = 1;
   }
   else if (uv0 == 3)
   {
     index[1] = 1; index[2] = 2; index[3] = 0;
   }
 }
 
 for(jj=0; jj<4; jj++)
 {
   OM_BLOCK_MOVE(pl_poles[index[jj]], 
                 &plane->poles[3*jj], sizeof(IGRpoint));
 }
 BSptlnplan((plane->u_num_poles + plane->v_num_poles), 
            plane->rational, (IGRpoint *)plane->poles, 
            plane->weights, &ccode, aft_vec, &rc);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
 BSnorvec(&rc, aft_vec);
 dotp0 = BSdotp(&rc, bef_vec, aft_vec);

 if (dotp0 < 0.0)
  plane->pos_orient = !plane->pos_orient;

wrapup:
return(OM_S_SUCCESS);
}

end implementation EMSedge;
