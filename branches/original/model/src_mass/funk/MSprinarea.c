/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MSprincipal_area (sf_int, glo_prop);

Description
	Given a point (on the surface) and the properties about that point
	this function derives surface properties at the centroid
	
Notes
	All the transformations occur in the plane of the surface.
	glo_prop[2-4] contain the centroid of the surface
	glo_prop[5-10] contain the x axis and y axis respectively
	glo_prop[11]  contains the surface area
	glo_prop[14]  contains moment about the x axis at centroid
	glo_prop[15]  contains moment about the y axis at centroid
	glo_prop[16]  contains product moment about the centroid
	

History:
    gupta   12/11/89 Creation
*/

#include <stdio.h>
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmass.h"
#include "bsvalues.h" /* added for M_PI */

void MSprincipal_area (sf_int, glo_prop)

IGRdouble	sf_int[];
IGRdouble	glo_prop[];

{
 extern  IGRdouble  fabs();
 IGRlong            i, rc;
 IGRdouble          zero_tol;

 BSEXTRACTPAR(&rc, BSTOLCLOSETOZERO, zero_tol);   

 glo_prop[0] = glo_prop[1] = 0.0;
 for (i=2; i<5; i++) glo_prop[i] = sf_int[i];
 for (i=5; i<11; i++) glo_prop[i] = 0.0;
 glo_prop[5] = 1.0;
 glo_prop[9] = 1.0;
 glo_prop[11] = sf_int[11];
 glo_prop[12] = glo_prop[13] = 0.0;
 glo_prop[14] = sf_int[5];
 glo_prop[15] = sf_int[6];
 glo_prop[16] = sf_int[8];
 
 if (fabs(glo_prop[16]) > zero_tol)
  {
   extern  IGRdouble  cos();
   extern  IGRdouble  atan2();
   extern  IGRdouble  sin();
   IGRdouble          IXX, IYY, IXY, P, Q, angle, angle_2,
                      loc_tran[3][3], glo_loc[3][3], final[3][3];
   void               MSmat_mult();

   IXX = glo_prop[14];
   IYY = glo_prop[15];
   IXY = glo_prop[16];

   P = (IYY + IXX) * 0.5;
   Q = (IYY - IXX) * 0.5;

   if (fabs(Q) < zero_tol)
    {
     angle_2 = IXY < 0.0 ? -M_PI/2 : M_PI/2;
     glo_prop[14] = IYY + (IXY < 0.0 ? IXY : -IXY);
     glo_prop[15] = IXX + (IXY < 0.0 ? -IXY : IXY);
     glo_prop[16] = 0.0;
    }
   else
    {
     angle_2 = atan2( IXY, Q);	/* 2.theta */
     glo_prop[14] = P - Q / cos(angle_2);
     glo_prop[15] = P + Q / cos(angle_2);
     glo_prop[16] = 0.0;
    }
     
   angle = 0.5 * angle_2;

   loc_tran[0][0] = cos(angle);
   loc_tran[0][1] = sin(angle);
   loc_tran[0][2] = 0.0;
   loc_tran[1][0] = - loc_tran[0][1];
   loc_tran[1][1] = loc_tran[0][0];
   loc_tran[1][2] = 0.0;
   loc_tran[2][0] = 0.0;
   loc_tran[2][1] = 0.0;
   loc_tran[2][2] = 1.0;

   glo_loc[0][0] = glo_prop[5];
   glo_loc[0][1] = glo_prop[6];
   glo_loc[0][2] = glo_prop[7];
   glo_loc[1][0] = glo_prop[8];
   glo_loc[1][1] = glo_prop[9];
   glo_loc[1][2] = glo_prop[10];
   glo_loc[2][0] = 0.0;
   glo_loc[2][1] = 0.0;
   glo_loc[2][2] = 0.0;

   MSmat_mult(loc_tran, glo_loc, final);

   glo_prop[5] =  final[0][0];
   glo_prop[6] =  final[0][1];
   glo_prop[7] =  final[0][2];

   glo_prop[8] =  final[1][0];
   glo_prop[9] =  final[1][1];
   glo_prop[10] = final[1][2];
  }
 else
   glo_prop[16] = 0.0;
 return;
}
