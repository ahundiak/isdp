/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MSsftosf(area_only, origin, scaling_factor, x_axis, y_axis,
	      sf_int, glo_prop);

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
	
Arguments

IGRdouble	trans_vect[3];	The origin with respect to which
				the integrals are computed

IGRdouble	scaling_factor;	scaling if any

IGRvector	x_axis, y_axis;

IGRdouble	sf_int[NUMB_PROPS];	surface integrals

IGRdouble	glo_prop[NUMB_PROPS];	surface properties

History:
	gk	3/9/88	for non planar surfaces, centroids are also computed
*/

#include <stdio.h>
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmass.h"
#include "bsvalues.h" /* added for M_PI */

void MSsftosf(area_only, origin, scaling_factor, x_axis, y_axis,
	      sf_int, glo_prop)

IGRboolean	area_only;
IGRvector	origin;
IGRdouble	scaling_factor;
IGRvector	x_axis;
IGRvector	y_axis;
IGRdouble	sf_int[];
IGRdouble	glo_prop[];

{
 extern  IGRdouble  fabs();
   IGRdouble		scaling_2, scaling_3, scaling_4;
   IGRdouble		x, y, x_sq, y_sq;	/* all deltas */
   IGRlong		i, rc;
   IGRdouble		zero_tol;

   BSEXTRACTPAR(&rc, BSTOLCLOSETOZERO, zero_tol);   

    scaling_2 = scaling_factor * scaling_factor;
    scaling_3 = scaling_2 * scaling_factor;
    scaling_4 = scaling_3 * scaling_factor;

/* If only area was computed, then return the centroid as well */

  if(area_only)
   {
/*
     Factor 3.0 is used to divide because centroid of a triangle is
     (x1 + x2 + x3)/3.0 and in integrator division is not carried out
*/
     glo_prop[2]  = scaling_factor * sf_int[12] / (3.0 * sf_int[11]);
     glo_prop[3]  = scaling_factor * sf_int[13] / (3.0 * sf_int[11]);
     glo_prop[4]  = scaling_factor * sf_int[14] / (3.0 * sf_int[11]);
     glo_prop[11] = scaling_2 * sf_int[11] * 0.5;
     return;
   }

/* Divide all the integrals by 9.0 - 2d Simpson divisor
			       4.0 - 2d Gaussian scheme
*/

  for(i = 11; i < 18; i++)sf_int[i] /= INTEGRATION_FACTOR;

/*
Compute centroid and translate sf_int to the centroid
 */
    x = scaling_factor * sf_int[12]/sf_int[11];
    y = scaling_factor * sf_int[13]/sf_int[11];

    glo_prop[2] = origin[0] + x * x_axis[0] + y * y_axis[0];	/* Xc */
    glo_prop[3] = origin[1] + x * x_axis[1] + y * y_axis[1];	/* Yc */
    glo_prop[4] = origin[2] + x * x_axis[2] + y * y_axis[2];	/* Zc */

    glo_prop[5] = x_axis[0];
    glo_prop[6] = x_axis[1];
    glo_prop[7] = x_axis[2];

    glo_prop[8] = y_axis[0];
    glo_prop[9] = y_axis[1];
    glo_prop[10] = y_axis[2];

    x_sq = x * x;
    y_sq = y * y;

    glo_prop[11] = sf_int[11] * scaling_2;	/* Surface area */

    glo_prop[14] = sf_int[16] * scaling_4 - glo_prop[11] * y * y;
    glo_prop[15] = sf_int[15] * scaling_4 - glo_prop[11] * x * x;
    glo_prop[16] = sf_int[17] * scaling_4 - glo_prop[11] * x * y;


/* Enhancement: Return the properties along principal axes */

  /* 
   * corrected the equations, fixed a bug in outputting the new axes
   * and added code to handle special cases where angle_2 is +/- PI/2.
   *    07/28/88   RV.
   */

  if (fabs(glo_prop[16]) > zero_tol)
  {
 extern  IGRdouble  cos();
 extern  IGRdouble  atan2();
 extern  IGRdouble  sin();
    IGRdouble	IXX, IYY, IXY, P, Q, angle, angle_2,
    		loc_tran[3][3], glo_loc[3][3], final[3][3];
    void	MSmat_mult();

    IXX = glo_prop[14];
    IYY = glo_prop[15];
    IXY = glo_prop[16];

    /*
     * Corrected the equations and fixed a bug in outputting the 
     * principal axes.  RV  07/22/88.
     */

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

    glo_loc[0][0] = x_axis[0];
    glo_loc[0][1] = x_axis[1];
    glo_loc[0][2] = x_axis[2];
    glo_loc[1][0] = y_axis[0];
    glo_loc[1][1] = y_axis[1];
    glo_loc[1][2] = y_axis[2];
    glo_loc[2][0] = 0.0;
    glo_loc[2][1] = 0.0;
    glo_loc[2][2] = 0.0;

    MSmat_mult(loc_tran, glo_loc, final);

    glo_prop[5] = final[0][0];
    glo_prop[6] = final[0][1];
    glo_prop[7] = final[0][2];

    glo_prop[8] = final[1][0];
    glo_prop[9] = final[1][1];
    glo_prop[10] = final[1][2];
  }
  else glo_prop[16] = 0.0;
  return;
}
