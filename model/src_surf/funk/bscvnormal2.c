/*

Name
    BScvnormal2

Abstract
    This routine determines the unit normal vector to a planar curve.

Synopsis
    IGRboolean BScvnormal2(rc,curve,normal) 

    BSrc                  *rc
    struct IGRbsp_curve   *curve
    IGRvector             normal

Description
    Given a planar B-spline curve (curve), this routine returns the unit normal
vector (normal) to the curve.

Return Values
    If (curve->poles < 3) or (code != 3), rc = BSFAIL. If memory cannot be
allocated, rc = BSNOSTKMEMORY. If no errors occur, rc = BSSUCC.

Notes

History
    C.S.SAMUELS  03/11/86  : Creation date.
    C.S.SAMUELS  07/13/87  : Change rc to BSNONPLANAR instead of BSFAIL.
    C.S.KIRBY    07/18/88  : Modify header.
    Sudha        07/06/93  : Modified for BSprototypes ansification

*/

# define  BSVOID
# include "bs.h"
# include "bsstackalloc.h"
# include "bsparameters.h"
#include "bsnorvec.h"
#include "bsgaussu.h"
#include "bsdistptpts.h"
#include "bscrossp.h"
#include "bscollinmn2.h"
#include "bschangepar.h"
#include "bsbx2.h"
#include "bsavgpts.h"

IGRboolean BScvnormal2(rc,curve,normal)

BSrc           *rc;             /* output - completion message               */
struct
 IGRbsp_curve  *curve;          /* input  - structure for bspline curve      */
IGRvector      normal;          /* output - normal vector to planar curve    */

{

extern IGRdouble    sqrt();

IGRboolean    status;          /* return status                             */
IGRboolean    linear;          /* linearity indicator                       */
IGRboolean    degen;           /* degenerate indicator                      */
IGRdouble     sqdist;          /* squared distance                          */
IGRpoint      tpt;             /* temporary point                           */
IGRpoint      avgpt;           /* average point                             */
IGRvector     vec1, vec2;      /* temporary vectors                         */
IGRint        gauss_code;      /* return code for BSgaussu                  */
IGRshort      mat_order;       /* order of matrix                           */
IGRdouble     mat[4][4];       /* matrix of sums                            */
IGRdouble     mag;             /* vector magnitude or length                */
IGRint        i,j;             /* loop counter                              */
IGRdouble     dist, zero_tol,
              dist_tol, dist_sqtol,
              save_zero_tol, *ptr, x, y, z;
IGRpoint      orig, min, max;
BSrc          rc1;
IGRint        code;
IGRdouble     coeffs[4];

*rc = BSSUCC;
status = TRUE;

BSEXTRACTPAR( rc, BSTOLSQLENVEC, dist_sqtol );
BSEXTRACTPAR( rc, BSTOLLENVEC, dist_tol );
BSEXTRACTPAR( rc, BSTOLCLOSETOZERO, zero_tol );

if (curve->num_poles < 3)  
 {
   *rc = BSNONPLANAR;
   status = FALSE;
   goto wrapup;
 }

for (i=0;i < 3;i++)
   normal[i] = 0.0;

/* Test for degenerate points */

(void)BSavgpts( rc, curve->num_poles, curve->poles, curve->weights, avgpt );
if (BSERROR(*rc))
 {
   status = FALSE;
   goto wrapup;
 }

degen = TRUE;
for (i = 0; i < curve->num_poles;i++)
 {
  if (curve->rational)
   {
      for (j=0;j < 3;j++)
         tpt[j] = curve->poles[i * 3 + j] / curve->weights[i];
      sqdist = BSdistptpts( rc, avgpt, tpt );
   }
  else
      sqdist = BSdistptpts( rc, avgpt, &curve->poles[i * 3] );

  if (sqdist > dist_sqtol)
   {
      degen = FALSE;
      break;
   }
 }

if (degen)
 {
   *rc = BSNONPLANAR;
   status = FALSE;
   goto wrapup;
 }

if ((! degen) && (curve->num_poles == 2))
 {
   *rc = BSNONPLANAR;
   status = FALSE;
   goto wrapup;
 }

/* find out if the points are collinear */

BScollinmn2(curve->num_poles, (IGRpoint *)curve->poles, curve->weights, &linear, rc);
if (BSERROR(*rc)) 
 {
   status = FALSE;
   goto wrapup;
 }

if (linear)
 {
   *rc = BSNONPLANAR;
   status = FALSE;
   goto wrapup;
 }

if (curve->num_poles == 3)
 {
   code = 3;
   if( curve->rational )
    {
      for(i=0; i<3; i++)
       {
         vec1[i] = curve->poles[i + 3] / curve->weights[1] -
                   curve->poles[i] / curve->weights[0];
         vec2[i] = curve->poles[i + 6] / curve->weights[2] -
                   curve->poles[i] / curve->weights[0];
       }
    }
   else
    {
      for(i=0; i<3; i++)
       {
         vec1[i] = curve->poles[i + 3] - curve->poles[i];
         vec2[i] = curve->poles[i + 6] - curve->poles[i];
       }
    }
   (void)BScrossp( rc, vec1, vec2, normal );
   (void)BSnorvec( rc, normal );
 }
else
 {
   for (i=0;i< 4;i++)
    {
       for (j=0;j < 4;j++)
           mat[i][j] = 0;
    }    

   /* find the box around the input points */

   status = BSbx2(rc, &curve->num_poles, (IGRpoint *)curve->poles, curve->weights,
                  min, max);
   if (BSERROR(*rc))
    {
      status = FALSE;
      goto wrapup;
    }

   /* find the middle point of min and max points */

   orig[0] = (min[0] + max[0])/ 2.0;
   orig[1] = (min[1] + max[1]) / 2.0;
   orig[2] = (min[2] + max[2] ) / 2.0;

   /* find the distance between min and max */

   dist = (min[0] - max[0]) * (min[0] - max[0]) +
          (min[1] - max[1]) * (min[1] - max[1]) +
          (min[2] - max[2]) * (min[2] - max[2]);
   dist = sqrt(dist);
   if( dist < zero_tol )
      dist = 1.0;

   /* when accessing the input points subtract the obtained origion */

   if(! curve->rational)
   {
      for (i=0;i < curve->num_poles;i++)
      {
         x = curve->poles[i*3];
         y = curve->poles[i*3+1];
         z = curve->poles[i*3+2];
         /* sum of x*x terms  */
         mat[0][0] += (x - orig[0]) * (x - orig[0]); 
         /* sum of x*y terms  */
         mat[0][1] += (x - orig[0]) * (y - orig[1]);
         /* sum of x*z terms  */
         mat[0][2] += (x - orig[0]) * (z - orig[2]);
         /* sum of x terms    */
         mat[0][3] += (x - orig[0]);
         /* sum of y*y terms  */
         mat[1][1] += (y - orig[1]) * (y - orig[1]);
         /* sum of y*z terms  */
         mat[1][2] += (y - orig[1]) * (z - orig[2]);
         /* sum of y terms    */
         mat[1][3] += (y - orig[1]);
         /* sum of z*z terms  */
         mat[2][2] += (z - orig[2]) * (z - orig[2]);
         /* sum of z terms    */
         mat[2][3] += (z - orig[2]);
      } 
   }
   else
   {
      ptr = &curve->weights[0];
      for (i=0;i< curve->num_poles;i++)
      {
         x = curve->poles[i*3];
         y = curve->poles[i*3+1];
         z = curve->poles[i*3+2];
         /* sum of x*x terms  */
         mat[0][0] += (x / *ptr - orig[0]) * (x / *ptr - orig[0]); 
         /* sum of x*y terms  */
         mat[0][1] += (x / *ptr - orig[0]) * (y / *ptr - orig[1]);
         /* sum of x*z terms  */
         mat[0][2] += (x / *ptr - orig[0]) * (z / *ptr - orig[2]);
         /* sum of x terms    */
         mat[0][3] += (x / *ptr - orig[0]);
         /* sum of y*y terms  */
         mat[1][1] += (y / *ptr - orig[1]) * (y / * ptr - orig[1]);
         /* sum of y*z terms  */
         mat[1][2] += (y / *ptr - orig[1]) * (z / * ptr - orig[2]);
         /* sum of y terms    */
         mat[1][3] += (y / *ptr - orig[1]);
         /* sum of z*z terms  */
         mat[2][2] += (z / *ptr - orig[2]) * (z / *ptr - orig[2]);
         /* sum of z terms    */
         mat[2][3] += (z / *ptr++ - orig[2]);
      }   
   }

   mat[1][0] = mat[0][1];
   mat[2][0] = mat[0][2];
   mat[2][1] = mat[1][2];
   mat[3][0] = mat[0][3];
   mat[3][1] = mat[1][3];
   mat[3][2] = mat[2][3];
   mat[3][3] = curve->num_poles;

   /* find the average point of input points */

   for(i=0; i< 3; i++)
      avgpt[i] = (mat[i][3] / curve->num_poles) + orig[i];

   save_zero_tol = zero_tol;
   zero_tol *= dist;
   (void)BSchangepar(rc, BSTOLCLOSETOZERO, zero_tol);
   if (BSERROR(*rc))
    {
      status = FALSE;
      goto wrapup;
    }

   mat_order = 4;
   status = BSgaussu(rc,&mat_order,mat,coeffs,&gauss_code);
   status = BSchangepar(&rc1, BSTOLCLOSETOZERO, save_zero_tol);
   if (BSERROR(*rc) || BSERROR(rc1))
    {
      status = FALSE;
      goto wrapup;
    }

   if (gauss_code == 1 || gauss_code == 0)
    {
      mag = 0;
      for (i=0;i<3;i++)
         mag += coeffs[i] * coeffs[i];
      mag = sqrt(mag);
      if (mag > zero_tol)
      {
         for (i=0;i<4;i++)
            coeffs[i] = coeffs[i] / mag;
      }

      for (i=0;i<3;i++)
        normal[i] = coeffs[i];

      if (gauss_code == 1)
      {
        code = 3;
      }
      else
      {
        *rc = BSNONPLANAR;
        status = FALSE;
        goto wrapup;
      }
      coeffs[3] = 0;
      for (i=0;i<3;i++)
        coeffs[3] -= (normal[i] * avgpt[i]);
    }
   else
    {
      for (i=0;i<3;i++)
        normal[i] = mat[i][3] + orig[i];

      *rc = BSNONPLANAR;
      status = FALSE;
      goto wrapup;
    }

   if (code == 3)
    {
      /* find the distance between the points and the least square plane
         (that was found) and if the distance > dist_tol, then set to 
         non-coplanar2, otherwise it's planar2 */

      ptr = &curve->poles[0];
      for (i=0;i < curve->num_poles; i++)
       {
          dist = 0;
          if( curve->rational )
           {
             for (j=0;j<3;j++)
                 dist += *ptr++/curve->weights[i] * coeffs[j];
           }
          else
           {
             for (j=0;j<3;j++)
                 dist += *ptr++ * coeffs[j];
           }
          dist += coeffs[3];
          if (ABS(dist) >= dist_tol)
          {
             *rc = BSNONPLANAR;
             status = FALSE;
             goto wrapup;
           }
       }
    }

   if (code != 3)
    {
      *rc = BSNONPLANAR;
      status = FALSE;
    }
 }

wrapup:return(status);
}
