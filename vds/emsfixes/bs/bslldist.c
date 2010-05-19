/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSlldist

Abstract
    This function accepts data defining two infinite lines.
It returns the minimum distance between the two infinite 
lines and the points on each line where the minimum distance
occurs.  It also returns whether the two curves are parallel.

Synopsis
    IGRboolean BSlldist(rc,point1,point2,unit1,unit2,parallel,dist,p1,p2)

    IGRpoint   point1
    IGRpoint   point2
    IGRvector  unit1
    IGRvector  unit2
    IGRboolean *parallel
    IGRdouble  *dist
    IGRpoint   p1
    IGRpoint   p2
    BSrc       *rc

Description
    This routine inputs data defining two infinite lines.  First a point 
on each line(point1 and point2), then the unit directional vector defining
each line (unit1 and unit2).  It returns the minimum distance between each
line(dist), whether the lines are parallel(parallel), and the points on
each line at minimum distance(p1 and p2).

Return Values
    BSSUCC is returned if all successful.

Notes

Index
    md

Keywords

History

    S. G. Catron  10/04/85  : Creation date.
    D. Breden     07/08/87  : Replaced dot_tol by zero_tol.
    S. G. Catron  07/28/88  : Changed to new header format.
    D. Breden     12/08/88  : Changed algorithm to return correct
                              results if input vectors are not 
                              unit vectors.
    P.R. Slubicki 01/06/93  : Replaced zero_tol by BSSMALLRELTO1.
    S.C. Wood     02/05/93  : Change tolerance check from BSSMALLRELTO1 to
                              BSSMALLRELTO1*10. Fix for TR# 9300230.
    David Ratner  02/10/93  : Change "abs" to "ABS" for previous fix.
    D. Breden     09/14/94  : Redesigned algorithm to use a Householder
                              algorithm to solve the system of 3 equations
                              with two unknowns instead of solving the 
                              normal equations with a determinant method.
    D. Breden     05/03/95  : Set zero_tol = BSSMALLRELTO1 * 10. Avoid
                              dividing by zero by checking cmat[3] before
                              backward substitution.

*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
# include "bstypes.h"
# include "bsdefs.h"
# include "bserr.h"
# include "bsparameters.h"
# include "bsvalues.h"
#endif
# include <math.h>
# define  BSVOID


#define SIGN(x) ( x < 0 ? -1 : 1 )

static void househldBSlldist(
BSrc            *rc,
IGRdouble       cmat[6],
IGRdouble       rmat[3],
IGRdouble       sol[2])
{
IGRint          si;
IGRdouble       a1,s1,sk,sk2;
IGRdouble       sum1;
IGRdouble       zero_tol;

*rc = BSSUCC;

zero_tol = BSSMALLRELTO1 * 10.0;

/* j=0 */

sk2 = cmat[0] * cmat[0] + cmat[2] * cmat[2] + cmat[4] * cmat[4];

if (ABS(cmat[0]) < zero_tol)
   si = 1;
else
   si = - SIGN(cmat[0]);

sk = si * sqrt(sk2);
if (ABS(sk) < zero_tol)
{
   *rc = BSFAIL;
   goto wrapup;
}
a1 = sk2 - cmat[0] * sk;
if (ABS(a1) > zero_tol)
{
   cmat[0] -= sk;
   sum1 = cmat[0] * cmat[1] + cmat[2] * cmat[3] + cmat[4] * cmat[5];

   s1 = sum1 / a1;
   cmat[1] -= (cmat[0] * s1);
   cmat[3] -= (cmat[2] * s1);
   cmat[5] -= (cmat[4] * s1);

   sum1 = cmat[0] * rmat[0] + cmat[2] * rmat[1] + cmat[4] * rmat[2];

   s1 = sum1 / a1;
   rmat[0] -= (cmat[0] * s1);
   rmat[1] -= (cmat[2] * s1);
   rmat[2] -= (cmat[4] * s1);

   cmat[0] = sk;
}

/* j=1 */

sk2 = cmat[3] * cmat[3] + cmat[5] * cmat[5];

if (ABS(cmat[3]) < zero_tol)
   si = 1;
else
   si = - SIGN(cmat[3]);

sk = si * sqrt(sk2);
if (ABS(sk) < zero_tol)
{
   *rc = BSFAIL;
   goto wrapup;
}
a1 = sk2 - cmat[3] * sk;
if (ABS(a1) > zero_tol)
{
   cmat[3] -= sk;

   sum1 = cmat[3] * rmat[1] + cmat[5] * rmat[2];

   s1 = sum1 / a1;
   rmat[1] -= cmat[3] * s1;
   rmat[2] -= cmat[5] * s1;

   cmat[3] = sk;
}

/* Backward substitution */

if (ABS(cmat[3]) < BSSMALLRELTO1)
{
   *rc = BSZDIV;
   goto wrapup;
}  
sol[1] = rmat[1] / cmat[3];
sol[0] = (rmat[0] - cmat[1] * sol[1]) / cmat[0];

wrapup:

return;
}            

/* Main routine */

IGRboolean BSlldist(
BSrc   *rc,
IGRpoint point1,     
IGRpoint point2,     
IGRvector unit1,     
IGRvector unit2,     
IGRboolean *parallel,
IGRdouble *dist,     
IGRpoint p1,         
IGRpoint p2)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#endif 

   IGRdouble det;
   IGRdouble po1, po2;
   IGRdouble dot12, dot11, dot22;
   IGRvector dir1, dir2, vec1;
   IGRint    i;
   IGRdouble cmat[6], rmat[3], sol[2];

   *rc = BSSUCC;

   vec1[0] = point2[0] - point1[0];
   vec1[1] = point2[1] - point1[1];
   vec1[2] = point2[2] - point1[2];

   dot11= unit1[0] * unit1[0] + unit1[1] * unit1[1] + unit1[2] * unit1[2];
   dot22= unit2[0] * unit2[0] + unit2[1] * unit2[1] + unit2[2] * unit2[2];

   dot11 = sqrt(dot11);
   dot22 = sqrt(dot22);

   if (dot11 < BSSMALLRELTO1 * 10.0 || dot22 < BSSMALLRELTO1 * 10.0)
   {
       *rc = BSDGENRAT;
       goto wrapup;
   }

   dot12 = 0.0;
   for (i=0; i<3; i++)
   {
      dir1[i] = unit1[i] / dot11;
      dir2[i] = unit2[i] / dot22;
      dot12  += dir1[i] * dir2[i];
   }
   det = 1.0 - dot12 * dot12;

   if( ABS(det) < BSSMALLRELTO1 * 10.0 )
   {
      *parallel = TRUE;
      po1 = 0.5 * ( vec1[0] * dir1[0] + vec1[1] * dir1[1] + 
                    vec1[2] * dir1[2] );
      po2 = 0.5 * ( vec1[0] * dir2[0] + vec1[1] * dir2[1] +
                    vec1[2] * dir2[2] );
      *dist = 0;
      for(i=0; i<3; i++)
      {
         p1[i] = point1[i] + po1 * dir1[i];
         p2[i] = point2[i] - po2 * dir2[i];
         *dist += (p2[i] - p1[i]) * (p2[i] - p1[i]);
      }
      *dist = sqrt(*dist);
   }
   else
   {
      *parallel = FALSE;

      cmat[0] = dir1[0];
      cmat[1] = -dir2[0];
      cmat[2] = dir1[1];
      cmat[3] = -dir2[1];
      cmat[4] = dir1[2];
      cmat[5] = -dir2[2];

      rmat[0] = vec1[0];
      rmat[1] = vec1[1];
      rmat[2] = vec1[2];

      househldBSlldist(rc,cmat,rmat,sol);
      if (BSERROR(*rc))
      {
         if (*rc == BSZDIV)
         {
            *rc = BSSUCC;
            *parallel = TRUE;
            po1 = 0.5 * ( vec1[0] * dir1[0] + vec1[1] * dir1[1] + 
                          vec1[2] * dir1[2] );
            po2 = 0.5 * ( vec1[0] * dir2[0] + vec1[1] * dir2[1] +
                          vec1[2] * dir2[2] );
            *dist = 0;
            for(i=0; i<3; i++)
            {
               p1[i] = point1[i] + po1 * dir1[i];
               p2[i] = point2[i] - po2 * dir2[i];
               *dist += (p2[i] - p1[i]) * (p2[i] - p1[i]);
            }
            *dist = sqrt(*dist);
         }
         goto wrapup;
      }

      po1 = sol[0];
      po2 = sol[1];

      *dist = 0;
      for(i=0; i<3; i++)
      {
         p1[i] = point1[i] + po1 * dir1[i];
         p2[i] = point2[i] + po2 * dir2[i];
         *dist += (p2[i] - p1[i]) * (p2[i] - p1[i]);
      }
      *dist = sqrt(*dist);
   }
wrapup:

if(BSERROR(*rc))
    BSdbgrc(*rc,"BSlldist");

return(TRUE);
}
