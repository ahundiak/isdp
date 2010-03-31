/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include 	<stdio.h>
#include 	<math.h>
#include	"igrtypedef.h"
#include	"igr.h"
#include	"bsparameters.h"
#include	"bserr.h"
#include	"emsmass.h"


/*
	Given 4 points this function returns the integrals
	
	Note: Remember to divide by 4 at the end of numerical computations.
*/

void	MSquadint(option, A, B, C, D, quad_int)
IGRlong		option;		/* 0 or 1 */
IGRdouble	*A, *B, *C, *D, *quad_int;
{
/*
 		       C	       D
			 -------------
			| 	      |
			|  7   8   9  |
			|	      |
			|  4   5   6  |
			|	      |
			|  1   2   3  |
			|	      |
		    v	 -------------
		    |  A	       B
	    	    |
		     ---- u
   Let:
   P = B-A
   Q = C-A
   R = A + D - B - C

   Then:
   P(u,v) = A + Pu + Qv + Ruv
   dpdu   = P + Rv
   dpdv   = Q + Ru

   cross = dpdu x dpdv

         = (P x Q) + (P x R)u + (R x Q)v

   cross  =   | i    j    k  |  + u | i   j   k  |  + v | i   j   k  |
	      | Px   Py   Pz |	    | Px  Py  Pz |	| Rx  Ry  Rz |
	      | Qx   Qy   Qz |	    | Rx  Ry  Rz |	| Qx  Qy  Qz |
	
History:
	gk	3/9/88	Non planar surfaces areas are computed 
			differently. Centroids are also computed
*/

#define IS	==

#define MASS_PROPS 0
#define SURF_PROPS 1
#define AREA_ONLY  2

#define X	0
#define Y	1
#define Z	2

#define VOL	0
#define MAS	1
#define MDX	2
#define MDY	3
#define MDZ	4
#define MX2	5
#define MY2	6
#define MZ2	7
#define MXY	8
#define MYZ	9
#define MZX	10

#define SUR	11

#define SRX	12
#define SRY	13
#define SRZ	14
#define SX2	15
#define SY2	16
#define SXY	17

#define CROSS_PR(A, B, C)	 \
{				 \
   C[X] = A[Y]*B[Z] - B[Y]*A[Z]; \
   C[Y] = A[Z]*B[X] - B[Z]*A[X]; \
   C[Z] = A[X]*B[Y] - B[X]*A[Y]; \
}

  IGRdouble	P[3], Q[3], R[3], constant[3], pntc[3], crossc[3],
		pnt[3], cross[3], cross_norm, delta_area,
		u_vector[3], v_vector[3], h_func,
		loc_quad_int[NUMB_PROPS];

  static IGRdouble
  u[3]  = { 0.1127016653792585, 0.5000000000000000, 0.8872983346207415},

  wt[9] = { 0.3086419753086424, 0.4938271604938275, 0.3086419753086424,
	    0.4938271604938275, 0.7901234567901235, 0.4938271604938275,
	    0.3086419753086424, 0.4938271604938275, 0.3086419753086424};


  IGRlong	i, j, wt_cnt;
/*
  u[0] = (1.0 - 0.774596669241483) * 0.5;
  u[1] = 0.5;
  u[2] = (1.0 + 0.774596669241483) * 0.5;

  wt[0] = first * first;
  wt[1] = first * second;
  wt[2] = wt[0];
  wt[3] = wt[1];
  wt[4] = second * second;
  wt[5] = wt[1];
  wt[6] = wt[0];
  wt[7] = wt[1];
  wt[8] = wt[0];
*/

  for(i = 0; i < NUMB_PROPS; i ++) loc_quad_int[i] = 0.0;

/*
   If only AREA_ONLY option is specified, then need to compute only
   surface area and the centroid

   No need to go Gaussian here.	3/9/88
*/

  if(option IS AREA_ONLY)
   {
     for(i = 0; i < 3; i ++)     
      {
	P[i] = B[i] - A[i];
	Q[i] = D[i] - A[i];
	R[i] = C[i] - A[i];
	pnt[i]  = A[i] + B[i] + D[i];
	pntc[i] = A[i] + C[i] + D[i];
      }

     CROSS_PR(P, Q, constant);
     cross_norm = constant[0]*constant[0] + constant[1]*constant[1]
		+ constant[2]*constant[2];
     delta_area = sqrt(cross_norm);

     loc_quad_int[SUR] += delta_area;
     loc_quad_int[SRX] += delta_area * pnt[X];
     loc_quad_int[SRY] += delta_area * pnt[Y];
     loc_quad_int[SRZ] += delta_area * pnt[Z];

     CROSS_PR(Q, R, constant);
     cross_norm = constant[0]*constant[0] + constant[1]*constant[1]
		+ constant[2]*constant[2];
     delta_area = sqrt(cross_norm);

     loc_quad_int[SUR] += delta_area;
     loc_quad_int[SRX] += delta_area * pntc[X];
     loc_quad_int[SRY] += delta_area * pntc[Y];
     loc_quad_int[SRZ] += delta_area * pntc[Z];

     /* 
      * if the reference vector was such that the area is negative, then
      * negate all the props.  jul-20-88   RV.
      */

     if (loc_quad_int[SUR] < 0)
     {
	loc_quad_int[SUR] = -loc_quad_int[SUR];
	loc_quad_int[SRX] = -loc_quad_int[SRX];
	loc_quad_int[SRY] = -loc_quad_int[SRY];
	loc_quad_int[SRZ] = -loc_quad_int[SRZ];
     }

     quad_int[SUR] += loc_quad_int[SUR];
     quad_int[SRX] += loc_quad_int[SRX];
     quad_int[SRY] += loc_quad_int[SRY];
     quad_int[SRZ] += loc_quad_int[SRZ];

     return;
   }


  for( i = 0; i < 3; i ++)
   {
     P[i] = B[i] - A[i];
     Q[i] = C[i] - A[i];
     R[i] = A[i] + D[i] - B[i] - C[i];
   }

  CROSS_PR(P, Q, constant);
  CROSS_PR(P, R, u_vector);
  CROSS_PR(R, Q, v_vector);

  wt_cnt = 0;
  for(i = 0; i < 3; i++)	/* v varies */
   {
     pntc[X] = A[X] + Q[X]*u[i];
     pntc[Y] = A[Y] + Q[Y]*u[i];
     pntc[Z] = A[Z] + Q[Z]*u[i];

     crossc[X] = constant[X] + u[i]*v_vector[X];
     crossc[Y] = constant[Y] + u[i]*v_vector[Y];
     crossc[Z] = constant[Z] + u[i]*v_vector[Z];

     for(j = 0; j < 3; j++)	/* u varies */
      {
	pnt[X] = pntc[X] + P[X]*u[j] + R[X]*u[j]*u[i];
	pnt[Y] = pntc[Y] + P[Y]*u[j] + R[Y]*u[j]*u[i];
	pnt[Z] = pntc[Z] + P[Z]*u[j] + R[Z]*u[j]*u[i];

	cross[X] = crossc[X] + u[j]*u_vector[X];
	cross[Y] = crossc[Y] + u[j]*u_vector[Y];
	cross[Z] = crossc[Z] + u[j]*u_vector[Z];

/* 	No matter what the option, we need norm of cross product */

        cross_norm = cross[X]*cross[X] + cross[Y]*cross[Y] + cross[Z]*cross[Z];
        cross_norm = sqrt(cross_norm);

        loc_quad_int[SUR] += cross_norm * wt[wt_cnt];

	if(option IS MASS_PROPS)
	 {
/*	   Compute mass prop contribution at this point */
/* 	   Volume  p . (dp/du x dp/dv )*/
/*	   mass too */

           h_func = pnt[X]*cross[X] + pnt[Y]*cross[Y] + pnt[Z]*cross[Z];

           loc_quad_int[VOL] += h_func * wt[wt_cnt];

/*   	   dm x  (x_comp of p)**2 . (dp/du x dp/dv) */
/*	   dm x2 (x_comp of p)**3 . (dp/du x dp/dv) */

           h_func = pnt[X] * pnt[X] * cross[X] * wt[wt_cnt];
           loc_quad_int[MDX] += h_func;
           loc_quad_int[MX2] += h_func * pnt[X];

/*	   dm y  (y_comp of p)**2 . (dp/du x dp/dv) */
/*	   dm y2 (y_comp of p)**3 . (dp/du x dp/dv) */

           h_func = pnt[Y] * pnt[Y] * cross[Y] * wt[wt_cnt];
           loc_quad_int[MDY] += h_func;
           loc_quad_int[MY2] += h_func * pnt[Y];

/*	   dm z  (z_comp of p)**2 . (dp/du x dp/dv) */
/*	   dm z2 (z_comp of p)**3 . (dp/du x dp/dv) */

           h_func = pnt[Z] * pnt[Z] * cross[Z] * wt[wt_cnt];
           loc_quad_int[MDZ] += h_func;
           loc_quad_int[MZ2] += h_func * pnt[Z];

/*	   dm xy  kth component of xyz . (dp/du x dp/dv) */

           h_func = pnt[X] * pnt[Y] * pnt[Z];

           loc_quad_int[MXY] += h_func * cross[Z] * wt[wt_cnt];

/* 	   dm yz  ith component of xyz . (dp/du x dp/dv) */

           loc_quad_int[MYZ] += h_func * cross[X] * wt[wt_cnt];

/*	   dm zx  jth component of xyz . (dp/du x dp/dv) */

           loc_quad_int[MZX] += h_func * cross[Y] * wt[wt_cnt];
         }
        else if(option IS SURF_PROPS)
         {
/*         da X px | (dp/du x dp/dv) | */
/*         da X2 px.px. | (dp/du x dp/dv) | */
	
	   loc_quad_int[SRX] += cross_norm * pnt[X] * wt[wt_cnt];
	   loc_quad_int[SX2] += cross_norm * pnt[X] * pnt[X] * wt[wt_cnt];

/*         da Y py | (dp/du x dp/dv) | */
/*         da Y2 py.py. | (dp/du x dp/dv) | */
	
	   loc_quad_int[SRY] += cross_norm * pnt[Y] * wt[wt_cnt];
	   loc_quad_int[SY2] += cross_norm * pnt[Y] * pnt[Y] * wt[wt_cnt];
	
/*         da XY px.py. | (dp/du x dp/dv) | */
	
	   loc_quad_int[SXY] += cross_norm * pnt[X] * pnt[Y] * wt[wt_cnt];
         }

	wt_cnt ++;

      }		/* j loop */

   }		/* i loop */

   /* 
    * if the reference vector was such that the area is negative, then
    * negate all the props.  jul-20-88   RV.
    */

  if (loc_quad_int[SUR] < 0.0)
  {
     for(i = 0; i < NUMB_PROPS; i ++) loc_quad_int[i] = -loc_quad_int[i];
  }
  for(i = 0; i < NUMB_PROPS; i ++) quad_int[i] += loc_quad_int[i];
  quad_int[MAS] = quad_int[VOL];

  return;
}		/* end of function */

