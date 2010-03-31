/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include 	<stdio.h>
#include 	<math.h>
#include	"igrtypedef.h"
#include	"igr.h"
#include	"bsparameters.h"
#include	"bserr.h"
#include	"emsmass.h"
#include "bsnorvec.h"

void	MSloopint(option, numb_pnts, pnts, loop_int)
IGRlong 	option, numb_pnts;
IGRdouble	*pnts, *loop_int;
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
   P = B-A					= V12
   Q = C-A		= 0 if C=A
   R = A + D - B - C    = D - B if C = A	= V23

   Then:
   P(u,v) = A + Pu + Qv + Ruv	= A + Pu + Ruv
   dpdu   = P + Rv		= P + Rv
   dpdv   = Q + Ru		= Ru

   cross = dpdu x dpdv

         = (P x Q) + (P x R)u + (R x Q)v

	 = (P x R)u

   cross  =   | i    j    k  |  + u | i   j   k  |  + v | i   j   k  |
	      | Px   Py   Pz |	    | Px  Py  Pz |	| Rx  Ry  Rz |
	      | Qx   Qy   Qz |	    | Rx  Ry  Rz |	| Qx  Qy  Qz |
	
	  = V12 x V23 u
History:
	gk	3/9/88	Non planar surfaces areas are computed 
			differently. Centroids are also computed

	Sudha	3/28/93	Modified for BSprototype ansification

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

 extern  IGRdouble  sqrt(), fabs();
  IGRdouble	pnt[3], cross[3], u_vector[3], value, h_func,
		V12[3], V13[3], V23[3], *first_pnt, *second_pnt, *third_pnt,
		temp, *temp_p, *ptr, ref_vect[3], dirn_vect[3], dotpr,
		quad_int[NUMB_PROPS], loc_loop_int[NUMB_PROPS],
		cross_norm, delta_area;

  static IGRdouble
  u[3]  = { 0.1127016653792585, 0.5000000000000000, 0.8872983346207415},

  wt[9] = { 0.3086419753086424, 0.4938271604938275, 0.3086419753086424,
	    0.4938271604938275, 0.7901234567901235, 0.4938271604938275,
	    0.3086419753086424, 0.4938271604938275, 0.3086419753086424};


  IGRlong	rc, i, j, k, wt_cnt;
  IGRdouble     temp_magsq, ref_magsq, temp_first[3], temp_second[3],
		temp_third[3], temp_V12[3], temp_V13[3], temp_ref_vect[3],
		*temp_ptr, dottol;

  for(i = 0; i < NUMB_PROPS; i ++) loc_loop_int[i] = 0.0;
  ptr = (IGRdouble *)pnts;

  first_pnt = (IGRdouble *)ptr;
  ptr += 3;

  second_pnt = (IGRdouble *)ptr;
  ptr += 3;

  for( i = 0; i < 3; i ++)
   {
     V12[i] = second_pnt[i] - first_pnt[i];
     V13[i] = second_pnt[i+3] - first_pnt[i];
   }

   /* 
    * compute the best reference vector i.e., the largest in magnitude
    * so that it represents the average plane of the facet, as closely
    * as possible --- fixed on jul-20-88 by RV. The last cross product
    * is not considered for simplicity of code.
    */

  ref_magsq = 0;
  for( i = 0; i < numb_pnts -2; i ++)
  {
    temp_ptr = (IGRdouble *) &pnts[3*i];
    temp_first[0] = temp_ptr[0];
    temp_first[1] = temp_ptr[1];
    temp_first[2] = temp_ptr[2];

    temp_ptr += 3;
    temp_second[0] = temp_ptr[0];
    temp_second[1] = temp_ptr[1];
    temp_second[2] = temp_ptr[2];

    temp_ptr += 3;
    temp_third[0] = temp_ptr[0];
    temp_third[1] = temp_ptr[1];
    temp_third[2] = temp_ptr[2];

    for(k = 0; k < 3; k ++)
    {
	temp_V12[k] = temp_second[k] - temp_first[k];
	temp_V13[k] = temp_third[k] - temp_first[k];
    }
    CROSS_PR(temp_V12, temp_V13, temp_ref_vect);    
    temp_magsq = temp_ref_vect[0]*temp_ref_vect[0] +
       	         temp_ref_vect[1]*temp_ref_vect[1] +
    	       	 temp_ref_vect[2]*temp_ref_vect[2];
    if (temp_magsq > ref_magsq)
    {
      ref_vect[0] = temp_ref_vect[0];
      ref_vect[1] = temp_ref_vect[1];
      ref_vect[2] = temp_ref_vect[2];
      ref_magsq = temp_magsq;
    }
  }

  BSnorvec(&rc, ref_vect);

  BSEXTRACTPAR(&rc, BSTOLCOLLINVEC, dottol);
  
/* If option is AREA_ONLY then no need to go through the mess */

  if(option IS AREA_ONLY)
   {
     for(k = 2; k < numb_pnts - 1; k ++)
      {
        third_pnt = (IGRdouble *)ptr;
        ptr += 3;

	for(i = 0; i < 3; i ++)
	 {
	   V13[i] = third_pnt[i] - first_pnt[i];
	   pnt[i] = first_pnt[i] + second_pnt[i] + third_pnt[i];
	 }
 
        CROSS_PR(V12, V13, dirn_vect);

        cross_norm = dirn_vect[0]*dirn_vect[0] + dirn_vect[1]*dirn_vect[1]
		   + dirn_vect[2]*dirn_vect[2];

	value = sqrt(cross_norm);

        dotpr = ref_vect[0] * dirn_vect[0] +
	        ref_vect[1] * dirn_vect[1] +
 	        ref_vect[2] * dirn_vect[2];

	/*
	 * ignore contribution if dotpr is almost zero , i.e., the three
	 * points define a plane perpendicular to the refernce vector
	 * OR are collinear : RV jul-20-88
	 */

	if (fabs(dotpr) < dottol) delta_area = 0.0;
	else delta_area = (dotpr >= 0.0) ? (value) : ( - value);

	loc_loop_int[SUR] += delta_area;
	loc_loop_int[SRX] += (delta_area * pnt[X]);
	loc_loop_int[SRY] += (delta_area * pnt[Y]);
	loc_loop_int[SRZ] += (delta_area * pnt[Z]);

	second_pnt = (IGRdouble *)third_pnt;
	V12[0] = V13[0];
	V12[1] = V13[1];
	V12[2] = V13[2];
      }

      /* 
       * if the reference vector was such that the area is negative, then
       * negate all the props.  jul-20-88   RV.
       */

      if (loc_loop_int[SUR] < 0.0)
      {
         for(i = 0; i < NUMB_PROPS; i ++) loc_loop_int[i] = -loc_loop_int[i];
      }
      for(i = 0; i < NUMB_PROPS; i ++) loop_int[i] += loc_loop_int[i];
     return;
   }	/* AREA_ONLY */

  for(k = 2; k < numb_pnts - 1; k ++)
   {
     third_pnt = (IGRdouble *)ptr;
     ptr += 3;

     V13[0] = third_pnt[0] - first_pnt[0];
     V13[1] = third_pnt[1] - first_pnt[1];
     V13[2] = third_pnt[2] - first_pnt[2];

     CROSS_PR(V12, V13, dirn_vect);

     dotpr = ref_vect[0] * dirn_vect[0] +
	     ref_vect[1] * dirn_vect[1] +
	     ref_vect[2] * dirn_vect[2];

     /*
      * ignore contribution if dotpr is almost zero , i.e., the three
      * points define a plane perpendicular to the refernce vector
      * OR are collinear : RV jul-20-88
      */

     if (fabs(dotpr) < dottol)
     {
	second_pnt = (IGRdouble *)third_pnt;
	V12[0] = V13[0];
	V12[1] = V13[1];
	V12[2] = V13[2];
	continue;
     }

     /*
      * If dot product is less than 0, then only thing it affects is
      * the computation of area. The points do not have to be swapped,
      * and at the end if the dot product is negative, add to the total 
      * negative of the surface area. Hence I chose to comment the below
      * swapping code.
      * pp (11/22/88)
      */

/*

     if(dotpr < 0.0)	
      {
	for(i = 0; i < 3; i ++)
	 {
	   temp = V12[i];
	   V12[i] = V13[i];
	   V13[i] = temp;

	   temp_p = (IGRdouble *)second_pnt;
	   second_pnt = (IGRdouble *)third_pnt;
	   third_pnt  = (IGRdouble *)temp_p;
	 }
      }
*/

     V23[0] = third_pnt[0] - second_pnt[0];
     V23[1] = third_pnt[1] - second_pnt[1];
     V23[2] = third_pnt[2] - second_pnt[2];

     CROSS_PR(V12, V23, u_vector);

     for(i = 0; i < NUMB_PROPS; i ++)quad_int[i] = 0.0;

     wt_cnt = 0;
     for(i = 0; i < 3; i++)	/* v varies */
      {
        for(j = 0; j < 3; j++)	/* u varies */
         {
   	   pnt[X] = first_pnt[X] + V12[X]*u[j] + V23[X]*u[j]*u[i];
	   pnt[Y] = first_pnt[Y] + V12[Y]*u[j] + V23[Y]*u[j]*u[i];
	   pnt[Z] = first_pnt[Z] + V12[Z]*u[j] + V23[Z]*u[j]*u[i];

	   cross[X] = u[j]*u_vector[X];
	   cross[Y] = u[j]*u_vector[Y];
	   cross[Z] = u[j]*u_vector[Z];
	
           cross_norm = cross[X]*cross[X] + cross[Y]*cross[Y] +
			cross[Z]*cross[Z];
	   cross_norm = sqrt(cross_norm);

/*	   No matter what option return surface area */
	
	   quad_int[SUR] += cross_norm * wt[wt_cnt];
	
	   if(option IS MASS_PROPS)
	    {
              h_func = pnt[X]*cross[X] + pnt[Y]*cross[Y] + pnt[Z]*cross[Z];

              quad_int[VOL] += h_func * wt[wt_cnt];

              h_func = pnt[X] * pnt[X] * cross[X] * wt[wt_cnt];
              quad_int[MDX] += h_func;
              quad_int[MX2] += h_func * pnt[X];

              h_func = pnt[Y] * pnt[Y] * cross[Y] * wt[wt_cnt];
              quad_int[MDY] += h_func;
              quad_int[MY2] += h_func * pnt[Y];

              h_func = pnt[Z] * pnt[Z] * cross[Z] * wt[wt_cnt];
              quad_int[MDZ] += h_func;
              quad_int[MZ2] += h_func * pnt[Z];

              h_func = pnt[X] * pnt[Y] * pnt[Z];

              quad_int[MXY] += h_func * cross[Z] * wt[wt_cnt];

              quad_int[MYZ] += h_func * cross[X] * wt[wt_cnt];

              quad_int[MZX] += h_func * cross[Y] * wt[wt_cnt];
	    }
	   else if(option IS SURF_PROPS)
	    {
/*            da X px | (dp/du x dp/dv) | */
/*            da X2 px.px. | (dp/du x dp/dv) | */
	
	      quad_int[SRX] += cross_norm * pnt[X] * wt[wt_cnt];
	      quad_int[SX2] += cross_norm * pnt[X] * pnt[X] * wt[wt_cnt];

/*            da Y py | (dp/du x dp/dv) | */
/*            da Y2 py.py. | (dp/du x dp/dv) | */
	
	      quad_int[SRY] += cross_norm * pnt[Y] * wt[wt_cnt];
	      quad_int[SY2] += cross_norm * pnt[Y] * pnt[Y] * wt[wt_cnt];
	
/*            da XY px.py. | (dp/du x dp/dv) | */
	
	      quad_int[SXY] += cross_norm * pnt[X] * pnt[Y] * wt[wt_cnt];
	    }

	   wt_cnt ++;

         }		/* j loop */
      }		/* i loop */

     if(dotpr < 0.0)
      {
/*
 * Just negative the surface area contribution in line
 * with the comments made above. pp (11/22/88)
 */
        quad_int[SUR] = -quad_int[SUR];
        quad_int[SRX] = -quad_int[SRX];
        quad_int[SRY] = -quad_int[SRY];
        quad_int[SX2] = -quad_int[SX2];
        quad_int[SY2] = -quad_int[SY2];
        quad_int[SXY] = -quad_int[SXY];
      }

	for(i = 0; i < NUMB_PROPS; i ++)loc_loop_int[i] += quad_int[i];

	second_pnt = (IGRdouble *)third_pnt;
	V12[0] = V13[0];
	V12[1] = V13[1];
	V12[2] = V13[2];

   }	/* numb_pnts */

   /* 
    * if the reference vector was such that the area is negative, then
    * negate all the props.  jul-20-88   RV.
    * 
    * This should not be done. Only the area contribution should be
    * negatived becuase the volume and other mass property contributions
    * take care of themselves. 11/22/88 pp
    */

  if (loc_loop_int[SUR] < 0.0)
  {
     loc_loop_int[SUR] = -loc_loop_int[SUR];
     loc_loop_int[SRX] = -loc_loop_int[SRX];
     loc_loop_int[SRY] = -loc_loop_int[SRY];
     loc_loop_int[SX2] = -loc_loop_int[SX2];
     loc_loop_int[SY2] = -loc_loop_int[SY2];
     loc_loop_int[SXY] = -loc_loop_int[SXY];
  }
  for(i = 0; i < NUMB_PROPS; i ++) loop_int[i] += loc_loop_int[i];
  loop_int[MAS] = loop_int[VOL];

  return;
}		/* end of function */
