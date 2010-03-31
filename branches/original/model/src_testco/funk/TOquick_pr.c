#include <stdio.h>
#include <math.h>

#include "bs.h"
#include "bsparameters.h"


void TOquick_pr_pt_cv (struct IGRbsp_curve *crv,
                       IGRdouble          start,
                       IGRdouble            end,
                       IGRint           num_pts,
                       IGRdouble     *input_pts,
                       IGRdouble    *output_pts,
                       IGRdouble    *output_par,
                       IGRdouble     *distances,
                       IGRint            *max_i,
                       IGRdouble      *max_dist,
                       IGRint            *err_i,
                       IGRlong             *ret)

/* 
 
  Abstract:     TOquick_pr_pt_cv projects a number of points
                normally onto a curve.

     Input:     crv                - pointer to curve
                start              - start parameter of the curve interval
                end                - end parameter of the curve interval
                num_pts            - number of points to project
                input_pts          - array of 3D points 
                                    (input_pts[0]  - x component of first point,
                                              [1]  - y component of first point)
            
    Output:     output_pts         - array of 3D points on the curve which
                                     are the projection points
                output_par         - array of parameters of output points
                distances          - array of distances between input_pts
                                     and output_points 
                max_i              - point number where distance is maximum
                max_dist           - maximum distance
                err_i              - point number where processing failed
                ret                - return code 
                                     (ret = 1  - success,
                                            0  - failure in iteration 
                                           -1  - BScveval failed)

  Assumptions:  This routine has been written to serve as a fast projection
                routine within this EMS function. The following is assumed:
                1)  The curve has been created using the points, that is the
                    points are reasonably close to the curve and are dense.
                2)  The points are ordered, that is the first point is in the
                    vicinity of the start of the curve, the last point at the
                    end of the curve. The projected points have increasing
                    parameters.
                3)  The curve has order > 2.

  History:      08/01/94    Created    THW.
*/

{
   IGRdouble    *i_pts;
   IGRdouble    *o_pts;
   IGRdouble    *o_par;
   IGRdouble    *o_dist;
   IGRdouble    pt[3];
   IGRdouble    u, u_next=0.0;
   IGRint       num_deriv = 2;
   IGRpoint     eval[3];
   IGRdouble    ptcv[3];
   IGRdouble    ptcv_sq=0.0;
   IGRdouble    tan[3];
   IGRdouble    tan_sq;
   IGRdouble    func, dfunc;
   IGRdouble    afunc_sq;
   IGRdouble    dist=0.0;
   IGRint       n_iter;
   IGRdouble    step, step_old=0.0;


   IGRint       i,j;
   BSrc         rc;

   IGRdouble    chrdht_tol;
   IGRdouble    same_angle_tol_sq;
   IGRint       max_iter = 20;
 
   IGRdouble    mach_eps;
   IGRdouble    eps_root;


#define abs(a)   ((a)<0?(-a):(a))

/****************************************************************************
 *
 *     Start of executable code
 *
 *************************************************************************** */

/* check input */
   *ret   = -1; 
   *err_i = NULL;

   if ((crv == NULL) | (num_pts < 1)) goto wrapup;
   if (crv->order < 3)                goto wrapup;

/* set up data */

   BSEXTRACTPAR (&rc,BSTOLCHRDHT,chrdht_tol);
   same_angle_tol_sq = chrdht_tol*chrdht_tol;

   *max_dist = -1.0e6;
   *max_i    = 0;
   mach_eps  = 1.0e-5;
   do
     {
      mach_eps = 0.5*mach_eps;
      u        = mach_eps + 1.0;
     }
      while (u > 1.0);
   mach_eps   *= 2.0;
   eps_root    = sqrt(mach_eps);

   i_pts   = input_pts;
   o_pts   = output_pts;
   o_par   = output_par;
   o_dist  = distances; 

/* loop thru all points */

   for (i=0; i<num_pts; i++)
      {
       pt[0]   = *(i_pts++);
       pt[1]   = *(i_pts++);
       pt[2]   = *(i_pts++);
       afunc_sq= 10.0*same_angle_tol_sq;
       n_iter  = 0;

       if (i == 0)
         u_next=start;
       if (i == num_pts-1)
         u_next=end;

       while ((afunc_sq > same_angle_tol_sq) && (n_iter < max_iter))
             {
              u     = u_next;

              BScveval (crv, u, num_deriv, &eval[0], &rc);
              if (rc != BSSUCC)
              {
                *ret = -1;
                goto wrapup;
              }

              func  = 0.0;
              dfunc = 0.0;
              for (j=0; j<3; j++) 
                 {          
                  ptcv[j]   = pt[j]-eval[0][j];
                  func     += ptcv[j]*eval[1][j];
                  tan[j]    = eval[1][j]*eval[1][j];
                  dfunc    += -tan[j] + ptcv[j]*eval[2][j]; 
                 }
              if (abs(dfunc) < eps_root)
                dfunc    = eps_root;
             
              step       = func/dfunc;

              if (n_iter == 0)
                 step_old= step;
              else
                 if (abs(step) > abs(step_old))
                   step = step_old;
              step_old = step;
              u_next     = u - step;

              if (u_next < start) 
                u_next = start;

              if (u_next > end)
                u_next = end;

               ptcv_sq  = ptcv[0]*ptcv[0] + ptcv[1]*ptcv[1] + ptcv[2]*ptcv[2];
               dist     = ptcv_sq;
               if (ptcv_sq < eps_root)
                 ptcv_sq= eps_root;
               tan_sq   = tan[0] + tan[1] + tan[2];
               afunc_sq = (func*func)/((ptcv_sq)*tan_sq);
               n_iter++;
             }
       /*iteration was not succesfull; return the number of the point where
         operation failed*/
       if((afunc_sq > same_angle_tol_sq) && (n_iter >= max_iter))
       {
          *err_i = i;
          *ret   = NULL; 
          goto wrapup;
       }

       for (j=0; j<3; j++)
          *(o_pts++) = eval[0][j];

       *(o_par++)= u;
       u_next=  u;
 
       dist  = sqrt(dist);
       *(o_dist++) = dist;
       if (i == 0)
         {
          *max_dist = dist;
          *max_i    = 0;
         }
       else
         {
          if (*max_dist < dist)
            {
              *max_dist = dist;
              *max_i    = i;
            }
         }  

      }

   *ret   = 1L;  


/*  wrapup */

wrapup:
   return;
}
