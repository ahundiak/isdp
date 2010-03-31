/* ###################   APOGEE COMPILED   ################## */
#include    "EMS.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"bsparameters.h"
#include	"bserr.h"
#include	"emsmass.h"
#include	"wanginc.h"
#include    "OMmacros.h"
#include "bsptnorpch.h"
#include "bsnorvec.h"
#include "bsavgpts.h"

#define OUT_TRIANGLE 0

MSnon_planar_quadint (option, numb_pnts, pnts, surface, patch_data,
                      loop_int)

IGRlong 	          option, numb_pnts;
IGRdouble	          *pnts;
struct IGRbsp_surface *surface;
struct BNpatch        *patch_data;
IGRdouble             *loop_int;

{
/*
 		       C	       D
             -------------
            |             |
            |  7   8   9  |
            |             |
            |  4   5   6  |
            |             | 
            |  1   2   3  |
            |             | 
		    v-------------
            |  A           B
            |
            ---- u
   Let:
   P = B-A      = V12
   Q = C-A      = 0 if C=A
   R = A + D - B - C    = D - B if C = A	= V23

   Then:
   P(u,v) = A + Pu + Qv + Ruv	= A + Pu + Ruv
   dpdu   = P + Rv		= P + Rv
   dpdv   = Q + Ru		= Ru

   cross = dpdu x dpdv

     = (P x Q) + (P x R)u + (R x Q)v

     = (P x R)u

   cross  =   | i    j    k  |  + u | i   j   k  |  + v | i   j   k  |
              | Px   Py   Pz |	    | Px  Py  Pz |	    | Rx  Ry  Rz |
              | Qx   Qy   Qz |	    | Rx  Ry  Rz |	    | Qx  Qy  Qz |
	
	      = V12 x V23 u
History:
    gupta 11/28/88  modified gk's MSloopint. This function does the
                    integration over a SOLID facet and only if it is
                    non-planar. 
	gk    03/09/88	Creation

	Sudha 06/28/93  Modified for BSprototype ansification

*/

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

#define CROSS_PR(A, B, C)       \
 {                              \
  C[X] = A[Y]*B[Z] - B[Y]*A[Z]; \
  C[Y] = A[Z]*B[X] - B[Z]*A[X]; \
  C[Z] = A[X]*B[Y] - B[X]*A[Y]; \
 }

  IGRlong          msg;
  IGRint	       i, j, k, wt_cnt;
  IGRint           num_found;
  IGRboolean       status;
  extern IGRdouble sqrt(), fabs();
  IGRdouble        tria_pnts[12];
  IGRdouble	       pnt[3], cross[3], u_vector[3], value, h_func,
                   V12[3], V13[3], V23[3],
                   ref_vec[3], dir_vec[3], dotpr,
                   quad_int[NUMB_PROPS], loc_loop_int[NUMB_PROPS],
                   cross_norm, delta_area;
  IGRdouble        avg_uv[2], u_par, v_par, dist;

  IGRdouble        temp_V12[3], temp_V13[3], dottol;
  static IGRdouble
  u[3]  = { 0.1127016653792585, 0.5000000000000000, 0.8872983346207415},

  wt[9] = { 0.3086419753086424, 0.4938271604938275, 0.3086419753086424,
            0.4938271604938275, 0.7901234567901235, 0.4938271604938275,
            0.3086419753086424, 0.4938271604938275, 0.3086419753086424};

  IGRpoint avg_point, start_point;

/*------------------------------------------------------------------*/

  for(i=0; i<NUMB_PROPS; i++)
      loc_loop_int[i] = 0.0;

  status = BSavgpts (&msg, numb_pnts, pnts, NULL, avg_point);

  avg_uv[0] = (patch_data->us + patch_data->ud) / 2;
  avg_uv[1] = (patch_data->vs + patch_data->vd) / 2;

  BSptnorpch (avg_point, surface, avg_uv, &num_found, &dist, &u_par,
              &v_par, start_point, &msg);

  if (! num_found)
      OM_BLOCK_MOVE (avg_point, start_point, sizeof (IGRpoint));


#if OUT_TRIANGLE

for (i=0; i<(numb_pnts - 1); i++)
 {
  for (k=0; k<3; k++)
   {
    tria_pnts[k] = start_point[k];
    tria_pnts[k+3] = pnts[(3*i) + k];
    tria_pnts[k+6] = pnts[(i+1) * 3 + k];
    tria_pnts[k+9] = start_point[k];
   }
  outtng(tria_pnts);
 }
#endif


  /* compute the best reference vector */

  for (i=0; i<3; i++)
   {
    temp_V12[i] = pnts[i] - start_point[i];
    temp_V13[i] = pnts[i + 3] - start_point[i];
   }

  CROSS_PR(temp_V12, temp_V13, ref_vec);    

  BSnorvec(&msg, ref_vec);

  BSEXTRACTPAR(&msg, BSTOLCOLLINVEC, dottol);

  for (i=0; i<3; i++)
       V12[i] = pnts[i] - start_point[i];
  
/* If option is AREA_ONLY then no need to go through the mess */

  if(option == AREA_ONLY)
   {
    for(k=0; k<(numb_pnts-1); k++)
     {
      for(i=0; i<3; i++)
       {
        V13[i] = pnts[(k+1) * 3 + i] - start_point[i];
        pnt[i] = start_point[i] + pnts[(k*3) + i] + pnts[(k+1)*3 + i];
       }
 
      CROSS_PR(V12, V13, dir_vec);

      cross_norm = dir_vec[0] * dir_vec[0] + dir_vec[1] * dir_vec[1] +
                   dir_vec[2] * dir_vec[2];

      value = sqrt(cross_norm);

      dotpr = ref_vec[0] * dir_vec[0] + ref_vec[1] * dir_vec[1] +
              ref_vec[2] * dir_vec[2];

      /*
       * ignore contribution if dotpr is almost zero , i.e., the three
       * points define a plane perpendicular to the refernce vector
       * OR are collinear : RV jul-20-88
       */

      if (fabs (dotpr) < dottol)
          delta_area = 0.0;
	  else
          delta_area = (dotpr >= 0.0) ? (value) : ( - value);

      loc_loop_int[SUR] += delta_area;
      loc_loop_int[SRX] += (delta_area * pnt[X]);
      loc_loop_int[SRY] += (delta_area * pnt[Y]);
      loc_loop_int[SRZ] += (delta_area * pnt[Z]);

      for (i=0; i<3; i++)
           V12[i] = V13[i];
     }

    if (loc_loop_int[SUR] < 0.0)
     {
      for(i=0; i<NUMB_PROPS; i++)
          loc_loop_int[i] = -loc_loop_int[i];
     }

    for(i=0; i<NUMB_PROPS; i++)
        loop_int[i] += loc_loop_int[i];
 
    return;
   }	/* AREA_ONLY */


  for(k=0; k<(numb_pnts-1); k++)
   {
    for (i=0; i<3; i++)
         V13[i] = pnts[(k+1)*3 + i] - start_point[i];

    CROSS_PR(V12, V13, dir_vec);

    dotpr = ref_vec[0] * dir_vec[0] + ref_vec[1] * dir_vec[1] +
            ref_vec[2] * dir_vec[2];

    /*
     * ignore contribution if dotpr is almost zero , i.e., the three
     * points define a plane perpendicular to the refernce vector
     * OR are collinear : RV jul-20-88
     */

    if (fabs(dotpr) < dottol)
     {
      for (i=0; i<3; i++)
           V12[i] = V13[i];
      continue;
     }

    for (i=0; i<3; i++)
         V23[i] = pnts[(k+1)*3 + i] - pnts[(k*3) + i];

    CROSS_PR(V12, V23, u_vector);

    for(i=0; i<NUMB_PROPS; i++)
        quad_int[i] = 0.0;

    wt_cnt = 0;

    for(i = 0; i < 3; i++)	       /* v varies */
     {
      for(j = 0; j < 3; j++)	   /* u varies */
       {
        pnt[X] = start_point[X] + V12[X]*u[j] + V23[X]*u[j]*u[i];
        pnt[Y] = start_point[Y] + V12[Y]*u[j] + V23[Y]*u[j]*u[i];
        pnt[Z] = start_point[Z] + V12[Z]*u[j] + V23[Z]*u[j]*u[i];

        cross[X] = u[j] * u_vector[X];
        cross[Y] = u[j] * u_vector[Y];
        cross[Z] = u[j] * u_vector[Z];
	
        cross_norm = cross[X] * cross[X] + cross[Y] * cross[Y] +
                     cross[Z] * cross[Z];
        cross_norm = sqrt(cross_norm);

        /* No matter what option return surface area */
	
        quad_int[SUR] += cross_norm * wt[wt_cnt];
	
        if (option == MASS_PROPS)
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
        else
        if (option == SURF_PROPS)
         {
          /* da X px | (dp/du x dp/dv) |      */   
          /* da X2 px.px. | (dp/du x dp/dv) | */
	
          quad_int[SRX] += cross_norm * pnt[X] * wt[wt_cnt];
          quad_int[SX2] += cross_norm * pnt[X] * pnt[X] * wt[wt_cnt];

          /* da Y py | (dp/du x dp/dv) |      */
          /* da Y2 py.py. | (dp/du x dp/dv) | */
	
          quad_int[SRY] += cross_norm * pnt[Y] * wt[wt_cnt];
          quad_int[SY2] += cross_norm * pnt[Y] * pnt[Y] * wt[wt_cnt];
	
          /* da XY px.py. | (dp/du x dp/dv) | */
	
          quad_int[SXY] += cross_norm * pnt[X] * pnt[Y] * wt[wt_cnt];
         }

        wt_cnt ++;

       }    /* j loop */
     }      /* i loop */

    if(dotpr < 0.0)
       quad_int[SUR] = -quad_int[SUR];

    for(i=0; i<NUMB_PROPS; i++)
        loc_loop_int[i] += quad_int[i];

    for (i=0; i<3; i++)
         V12[i] = V13[i];
   }   /* numb_pnts */

  if (loc_loop_int[SUR] < 0.0)
   {
    loc_loop_int[SUR] = -loc_loop_int[SUR];
   }

  for(i=0; i<NUMB_PROPS; i++)
      loop_int[i] += loc_loop_int[i];
  loop_int[MAS] = loop_int[VOL];

  return;
}
