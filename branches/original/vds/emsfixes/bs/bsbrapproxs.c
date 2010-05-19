/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSbrapproxs

Abstract
    This routine given a set of compatible b-spline curves and 
a knot vector which is a subset of the curve knots, finds a least 
square approximation of the curves with the new knot vector.

Synopsis
    void BSbrapproxs(numcvs, curves, num, knots, tanl, tanr, 
                     appcurves, rc)

    IGRint              numcvs
    struct IGRbsp_curve *curves[]
    IGRint              num
    IGRdouble           *knots
    IGRboolean          tanl
    IGRboolean          tanr
    struct IGRbsp_curve *appcurves[]
    BSrc                *rc

Description
    Input is the number of curves(numcvs), a set of b-spline curves(curves), 
the desired number of new poles(num), the desired new knot sequence(knots), 
if tangent constraints on the ends are desired(tanl and tanr) and if tanl or 
tanr, then the second or next to last output pole is entered through output 
curve(appcurves, also the weights if rational).  Using a least 
square approximation with the old curves and the new knots, we find the new 
curves(appcurves).

Return Values
    BSSUCC, is returned if all is successful and an appropriate error message
if an error occurrs.

Notes
    The caller has to allocate space for the output curve, since it is
obviously known what size it should be. It's size is:
    num_poles = num
    order = curve->order
    
    If you send in the poles(2nd pole or next to last pole) for appcurve and 
it is rational, then the poles should be weighted and the weights are passed 
also.

Index
    md

Keywords

History
    S.G. Catron  09/15/88  : Creation date.
    C.S. Kirby   10/11/88  : Removed unnecessary variables to correct
                             lint errors.
    S.G. Catron  07/11/89  : Changed "const" to "constt" because it is a 
                             reserve word on some systems.
    S.G. Catron  07/31/89  : There was an error, when only two 
                             blocks were left after deleting for 
                             tangent constraints.  The "bsst_col"
                             was not changed correctly after
                             deletions.
    S.G. Catron  12/12/90  : Fixed apogee errors.
    S.G. Catron  12/07/95  : Added code to check if weights are negative,
                             and error.
    S.G. Catron  02/03/97  : Added code to not check for multiple knots
                             past knots[num_poles], when setting up
                             matrix.  TR 30843.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsstackalloc.h"
#endif
#include <math.h>
#define MAXNUM 100
#define MAXNUMS 50
#define  WEIGHT_TOL  1e-3
/* find the insertion matrix but only the non-zero part */

static void insrtBSbrapproxs(
IGRshort  order,
IGRint    rnum_poles,
IGRdouble *rknots,
IGRint    num_poles,
IGRdouble *knots,
IGRdouble *imat,
BSrc      *rc )

{
   IGRdouble *lambda=NULL;
   IGRint i,j,r;
   IGRdouble beta,beta_l,tj,
             d1,d2;
   IGRint u,u2;   

   *rc = BSSUCC;

   lambda = (IGRdouble *)BSstackalloc((unsigned)( rnum_poles * sizeof
                                                       (IGRdouble )));
   if(!lambda)
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   u = order - 1;
   for(j=0; j< num_poles; j++)
   {
      /* find out where knot[i] is in rknot[]'s */
      for(i=u; i< rnum_poles; i++)
      {
         if( knots[j] >= rknots[i] && knots[j] < rknots[i+1] )
         {
            u = i;
            break;
         }
      }
      lambda[0] = 1;
      u2 = u;
      for(r=1; r<= order -1; r++)
      {
         beta_l = 0;
         tj = knots[j + r];
         for(i=u2; i<= u; i++)
         {
            d1 = tj - rknots[i];
            d2 = rknots[i+r] - tj;
            beta = lambda[i-u2]/(d1 + d2);
            lambda[i-u2] = d2 * beta + beta_l;
            beta_l = d1 * beta;
         }
         lambda[u -u2 +1] = beta_l;
         u2 -= 1;
      }
      /* put array of values for this knots[j] into correct place in
         imat */
      for(r=0; r< order; r++)
      {
         imat[j * order + r] = lambda[r];
      }
   }
   wrapup:
   if(lambda)
   {
      BSstackdealloc((char *)lambda);
   }     
   return;
}            


void BSbrapproxs(
IGRint              numcvs,
struct IGRbsp_curve *curves[],
IGRint              num,
IGRdouble           *knots,
IGRboolean          tanl,
IGRboolean          tanr,
struct IGRbsp_curve *appcurves[],
BSrc                *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsinsrt_mat.h"
#include "bsbndhshold.h"
#include "bscvkttol2.h"
#include "bsr_approxs.h"
#include "bscumdist.h"
#include "bscv_copy.h"
#endif 



   IGRint   i,j,ll,c,c1,three,k,n,ii, 
            nrtsd,constt, sum, endj, jj,kk,
            shift;
   IGRdouble *q=NULL,aq[MAXNUMS*MAXNUM],
             *g=NULL,ag[MAXNUMS],
             *l=NULL,al[MAXNUM],
             *b=NULL,ab[MAXNUMS*MAXNUM*4],
             knot_tol,*ptr1, *ptr2, 
             qq, qq1, qq2,qq3;
   IGRint    *st_col=NULL, ast_col[MAXNUM],
             sst_col[3],bsst_col[3],stcol,
             *sz_bl=NULL, asz_bl[MAXNUM],
             n_bl, delbnbl,delenbl,lastspn, thisspn,
             leftincr, deg, num_poles, width;
   IGRshort   order;
   IGRboolean rational;

   *rc = BSSUCC;

   order = curves[0]->order;
   num_poles = curves[0]->num_poles;
   if( num - 4 < order )
   {
      /* this routine is used for the smaller data */
      BSr_approxs(numcvs,curves,num,knots,tanl,tanr,appcurves,rc);
      goto wrapup;
   } 
   /* this routine must be used when (num - 4) >= order  */

   deg = order -1;
   rational = curves[0]->rational;
   n = num_poles -1;
   BScvkttol2((IGRshort)order, curves[0]->knots, (IGRlong)num_poles,
              curves[0]->poles, curves[0]->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;

   if( num_poles == num)
   {
      for(i=0; i< numcvs; i++)
      {
         /* if there are no knots to be removed, then just output input curve */
         (void)BScv_copy(rc,curves[i],appcurves[i]);
         if(BSERROR(*rc ))
            goto wrapup;
      }
      goto wrapup;
   }
   if((!tanl && !tanr && num > 2) || ((!tanl || !tanr) && num > 3 ) ||
      (tanl && tanr && num > 4 ) )
   {
      if(num_poles * order > MAXNUM * MAXNUMS)
      {
         q = (IGRdouble *)BSstackalloc((unsigned)( num_poles * order* 
                                          sizeof(IGRdouble )));
         if(!q)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         q = &aq[0];
      }
      /* find the insertion matrix  */
      insrtBSbrapproxs(order,num,knots,num_poles,curves[0]->knots,q,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      /* find the span indices for curve->knots */
      /* also find the starting columns of the blocks, how many blocks and
         the size of each block */
      if( num_poles > MAXNUM )
      {
         st_col = (IGRint *)BSstackalloc((unsigned)( num_poles * 
                  sizeof(IGRint )));
         if(!st_col )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         sz_bl = (IGRint *)BSstackalloc((unsigned)( num_poles * 
                  sizeof(IGRint )));
         if(!sz_bl )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         st_col = &ast_col[0];
         sz_bl = &asz_bl[0];
      }
      st_col[0] = 0;
      n_bl = 1;
      sz_bl[0] = 1;
      i = deg;
      lastspn = deg;
      for(j=1; j< num_poles; j++)
      {
         for(; i< num ; i++)
         {
            if( (curves[0]->knots[j] >= knots[i] && 
                curves[0]->knots[j] < knots[i+1] && 
                fabs(knots[i] - knots[i+1]) >
                knot_tol) || i == num-1)
            {
               thisspn = i;
               if( thisspn != lastspn )
               {
                  st_col[n_bl] = thisspn - deg;
                  sz_bl[n_bl] = 1;
                  n_bl += 1;
               }
               else
               {
                  sz_bl[n_bl -1] += 1;
               }
               lastspn = thisspn;       
               break;
            }
         }
      }
      

      /* allocate it big enough to handle matrix returned from BShousehld */
      if( num_poles > MAXNUM )
      {
         l = (IGRdouble *)BSstackalloc((unsigned)(num_poles 
                                                  * sizeof(IGRdouble )));
         if(!l )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         l = &al[0];
      } 
      ptr1 = &(curves[0]->knots[order]);
      ptr2 = curves[0]->knots;
      for(i=0; i< num_poles; i++)
      {
         l[i] = (*ptr1++ - *ptr2++) / order;
         l[i] = sqrt(l[i]);
      }
      if( num > MAXNUMS )
      {
         g = (IGRdouble *)BSstackalloc((unsigned)( num * sizeof(IGRdouble )));
         if(!g )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         g = &ag[0];
      }
      ptr1 = &knots[order];
      ptr2 = knots;
      for(i=0; i< num; i++)
      {
         g[i] = (*ptr1++ - *ptr2++) / order;
         g[i] = 1 / sqrt(g[i]);
      }

      /* allocate it at least curve->num_poles by 3, so we can use it later for
         poles */
      if( numcvs * num_poles > MAXNUM * MAXNUMS)
      {
         b = (IGRdouble *)BSstackalloc((unsigned)(numcvs * num_poles
                                           * 4 * sizeof(IGRdouble )));
         if(!b)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         b = &ab[0];
      }

      ptr1 = q;
      for(i=0; i< num_poles; i++)
      {
         for(j=0; j< order; j++)
         {
            *ptr1 = l[i] * *ptr1;
            ptr1++;
         }
      }
      ptr1 = q;
      k = 0;
      sum = 1;
      for(i=0; i< num_poles; i++)
      {
         j = st_col[k];
         endj = j + order;
         for(; j< endj; j++)
         {
            *ptr1 = *ptr1 * g[j];
            ptr1++;
         }
         if( sum == sz_bl[k] )
         {
            k += 1;
            sum = 1;
         }
         else
            sum += 1;
      }

      /* start loop at 1 because b isn't even used for the first pole, due
         to constraint on end poles(likewise for last pole). */
      if( rational )
         three = 4;
      else
         three = 3;
      
      ptr1 = &b[numcvs * three];
      for(i=1; i< n; i++)
      {
         for(k=0; k< numcvs; k++)
         {
            for(j=0; j<3; j++)
            {
               *ptr1++ = l[i] * curves[k]->poles[i*3+j];
            }
            if( rational )
            {
               *ptr1++ = l[i] * curves[k]->weights[i];
            }
         }
      }

      /* constrain the end poles, so that they'll be the same as the input
         end poles */   
      
      ii=1;
      if( tanl)
      {
         ii=2;
      }
      if( tanr)
      {
         n = num_poles -2;
      }

      ptr1 = &b[ii * numcvs * three];
      sum = ii;
      ll = 0;
      for(i=ii; i< n; i++)
      {
         if(sum == sz_bl[ll] )
         {
            ll += 1;
            sum = 0;
         }
         if( st_col[ll] > 0 )
            qq = 0.0;
         else
            qq = q[i*order];
         if( st_col[ll] > 1 )
            qq1 = 0.0;
         else
            qq1 = q[i*order+1-st_col[ll]];
         if( st_col[ll] + order  == num )
            qq2 = q[i*order+deg];
         else
            qq2 = 0.0;
         if( st_col[ll] + order >= num - 1 )
         {
            if( st_col[ll] + order == num )
               c = order -2;
            else
               c = deg;
            qq3 = q[i*order + c];
         }
         else
            qq3 = 0.0;
         sum += 1;
         for(k=0; k< numcvs; k++)
         {
            for(j=0; j< 3; j++)
            {
               *ptr1 -= (curves[k]->poles[j] / g[0] * qq + 
                           curves[k]->poles[(num_poles - 1) *3 + j]
                           / g[num - 1] * qq2 );
               if( tanl)
               {
                  *ptr1 -= 
                          ( appcurves[k]->poles[3 + j] / g[1] * qq1);
               }
               if( tanr)
               {
                  *ptr1 -= 
                           (appcurves[k]->poles[(num - 2) * 3 + j]/
                           g[num - 2] * qq3 );
               }
               ptr1++;
            }
            if( rational )
            {
               *ptr1 -= (curves[k]->weights[0] / g[0] * qq + 
                         curves[k]->weights[num_poles - 1]/
                         g[num - 1] * qq2);
               if( tanl)
               {
                  *ptr1 -= (appcurves[k]->weights[1] / g[1] * 
                            qq1);
               }
               if( tanr)
               {
                  *ptr1 -= (appcurves[k]->weights[num - 2]/
                            g[num - 2] * qq3);
               }
               ptr1++;               
            }
         }
      }
      /* after putting on constraints, we don't need the first row, first
         column, last row or last column of q[] */
      /* save the last three st_col */
      delbnbl = 0;
      delenbl = 0;
      if( n_bl > 2 )
      {
         sst_col[0] = st_col[n_bl - 3];
         sst_col[1] = st_col[n_bl - 2];
         sst_col[2] = st_col[n_bl - 1];
         bsst_col[0] = st_col[0];
         bsst_col[1] = st_col[1];
         bsst_col[2] = st_col[2];
      }
      else
      {
         if(n_bl > 1  )
         {
            sst_col[0] = st_col[n_bl - 2];
            sst_col[1] = st_col[n_bl - 1];
            bsst_col[0] = st_col[0];
            bsst_col[1] = st_col[1];
         }
         else
         {
            sst_col[0] = st_col[n_bl -1];
            bsst_col[0] = st_col[0];
         }
      }
      for(i=1; i< n_bl; i++)
         st_col[i] -= 1;
      c = num_poles -2;
      k = 1;
      c1 = num - 2;
      width = order;
      if( n_bl == 1 )
      {
         if( tanl )
         {
            c -= 1;
            c1 -= 1;
            k += 1;
         }
         if( tanr )
         {
            c -= 1;
            c1 -= 1;
         }         
         sz_bl[0] = c;
      }
      else
      {
         /* correct the starting columns and the sizes */
         if( sz_bl[0] == 1 )
         {
            /* delete this block */
            n_bl -= 1;
            for(ii = 0; ii< n_bl; ii++)
            {
               sz_bl[ii] = sz_bl[ii + 1];
               st_col[ii] = st_col[ii + 1];
            }               
            delbnbl = 1;
         }
         else
         {
            sz_bl[0] -= 1;
         }
         leftincr = 0;
         if( tanl)
         {
            leftincr += 1;
            c -= 1;
            c1 -= 1;
            k += 1;
            /* correct the starting columns and the sizes */
            if( sz_bl[0] == 1 )
            {
               /* delete this block */
               n_bl -= 1;
               for(ii = 0; ii< n_bl; ii++)
               {
                  sz_bl[ii] = sz_bl[ii + 1];
                  st_col[ii] = st_col[ii + 1];
               }               
               delbnbl += 1;
            }
            else
            {
               sz_bl[0] -= 1;
            }
            for(ii = 1; ii< n_bl; ii++)
            {
               st_col[ii] -= 1;
               if( st_col[ii] < 0 )
                  st_col[ii] = 0;
            }               
         }
         /* correct the starting columns and the sizes */
      
         st_col[n_bl -1] -= 1;
         if( st_col[n_bl -1] < 0 )
            st_col[n_bl -1] = 0;
         if( tanr)
         {
            c -= 1;
            c1 -= 1;

            /* correct the starting columns and the sizes */
            /* subtract one from starting column for the tangent constraints */
            st_col[n_bl -1] -= 1;
            if( st_col[n_bl -1] < 0 )
               st_col[n_bl -1] = 0;
            if( num - (st_col[n_bl -2] + leftincr + 1 + order) <
                2)
            {
               /* subtract one from starting column for the tangent
                  constraints */
               st_col[n_bl -2] -= 1;
               if( st_col[n_bl -2] < 0 )
                  st_col[n_bl -2] = 0;
            }               
            if( sz_bl[n_bl -1] == 1 )
            {
               /* delete this block */
               n_bl -= 1;
               delenbl = 1;
            }
            else
            {
               sz_bl[n_bl - 1] -= 1;
            }
         }
         if( sz_bl[n_bl -1] == 1 )
         {
            /* delete this block */
            n_bl -= 1;
            delenbl += 1;
         }
         else
         {
            sz_bl[n_bl - 1] -= 1;
         }
      }
      if( width > c1 )
         width = c1;

      if( delenbl > 0 && n_bl > 2)
      {
         if( delenbl == 1 )
         {
            sst_col[2] = sst_col[1];
            sst_col[1] = sst_col[0];
            sst_col[0] = st_col[n_bl -3] + k;
         }
         else
         {
            /* deleted two blocks */
            sst_col[2] = sst_col[0];
            sst_col[1] = st_col[n_bl -2] + k;
            sst_col[0] = st_col[n_bl -3] + k;
         }            
      }
      if( delbnbl > 0 )
      {
         if( n_bl > 2)
         {
            if( delbnbl == 1 )
            {
               bsst_col[0] = bsst_col[1];
               bsst_col[1] = bsst_col[2];
               bsst_col[2] = st_col[2] + k;
            }
            else
            {
               /* deleted two blocks */
               bsst_col[0] = bsst_col[2];
               bsst_col[1] = st_col[1] + k;
               bsst_col[2] = st_col[2] + k;
            }            
         }
         else
         {
            if( n_bl == 2 && delbnbl == 1 )
            {
               bsst_col[0] = bsst_col[1];
               bsst_col[1] = bsst_col[2];
            }
         }
      }
      /* this part here is to fix first and last rows which are 
         influenced by the end or tangent constraints */
      jj = 0;
      kk = 0;
      ll = num_poles - c - k;  /* number of right sides deleted */
      for(ii=0; ii< c; ii++)
      {
         /* find out which block we are on */
         if( jj == sz_bl[kk] )
         {
            jj = 0;
            kk += 1;
         }
         if( kk == 0 || kk == 1 || kk == 2 )
            stcol = bsst_col[kk];
         else
         {
            if( kk == n_bl - 1 || kk == n_bl -2 || kk == n_bl -3)
               stcol = sst_col[kk-n_bl+3];
            else
               stcol = st_col[kk] + k;
         }
         if( stcol < k )
         {
            shift = k - stcol;
            for(j=0; j< width; j++)
            {
               /* this is the first few rows which need to be shifted */
               if( shift + j >= order )
                  q[(ii+k) * width + j] = 0.0;
               else
                  q[(ii+k) * width + j] = q[(ii+k) * order + j  + shift];
            }
         }
         else
         {
            if( stcol + order > num - ll  )
            {
               shift = ll - (num - (stcol + order));
               for(j=width -1; j>=0; j--)
               {
                  /* this is the last few rows which must be shifted*/
                  if( stcol + order > num - ll +j )
                     q[(ii+k) * width + j] = 0.0;
                  else
                     q[(ii+k) * width + j] = q[(ii+k) * order + j - shift];
               }
            }  
         }
         jj += 1;
      }
      nrtsd = three * numcvs;
      BSbndhshold(&q[k*order], n_bl, sz_bl, width, st_col, nrtsd, 
                  &b[k*nrtsd], rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }

      for(i = 0; i< numcvs; i++)
      {
         ptr1 = &(appcurves[i]->poles[k * 3]);
         ptr2 = &(appcurves[i]->weights[k]);
         for(ii=0; ii< c1; ii++)
         {
            constt = ((ii + k) * numcvs + i) * three;
            for(j=0; j<3; j++)
            {
               *ptr1++ = g[ii + k]  * b[constt + j];
            }
            if( rational )
            {
               *ptr2 = g[ii+k] * b[constt + 3];
               /* check for negative/zero weights */
               if( *ptr2 < WEIGHT_TOL )
               {
                  *rc = BSINVALIDWEIGHT;
                  goto wrapup;
               }
               ptr2++;
            }
         }
      }
   }  /* end of if */
      
   /* set other characteristics of appcurve */

   for(i=0; i< numcvs; i++)
   {
      for(j=0; j<3; j++)
      {
         appcurves[i]->poles[j] = curves[i]->poles[j];
         appcurves[i]->poles[(num-1)*3+j] = curves[i]->poles[(num_poles-1)*3+j];
      }
      if( rational )
      {
         /* check for negative/zero weights */
         if( curves[i]->weights[0] < WEIGHT_TOL )
         {
            *rc = BSINVALIDWEIGHT;
            goto wrapup;
         }
         if( curves[i]->weights[num_poles-1] < WEIGHT_TOL )
         {
            *rc = BSINVALIDWEIGHT;
            goto wrapup;
         }

         appcurves[i]->weights[0] = curves[i]->weights[0];
         appcurves[i]->weights[num -1] = curves[i]->weights[num_poles -1];
      }
      appcurves[i]->order = order;
      appcurves[i]->num_poles = num;
      appcurves[i]->non_uniform = TRUE;
      appcurves[i]->rational = rational;
      if( !rational )
         appcurves[i]->weights = NULL;
      appcurves[i]->num_boundaries = 0;
      appcurves[i]->bdrys = NULL;
      appcurves[i]->periodic = curves[i]->periodic;
      appcurves[i]->planar = curves[i]->planar;
      appcurves[i]->phy_closed = curves[i]->phy_closed;
      appcurves[i]->num_knots = num + order;
      for(k=0; k< appcurves[i]->num_knots; k++)
      {
         appcurves[i]->knots[k] = knots[k];
      }
   }

   wrapup:
   if( numcvs * num_poles > MAXNUM * MAXNUMS)
      if( b)
         BSstackdealloc((char *)b);
   if( num > MAXNUMS )
      if(g)
         BSstackdealloc((char *)g);
   if( num_poles > MAXNUM )
   {
      if(l)
         BSstackdealloc((char *)l);
      if( sz_bl )
         BSstackdealloc((char *)sz_bl);
      if( st_col )
         BSstackdealloc((char *)st_col);
   }
   if( num_poles * order > MAXNUM * MAXNUMS)
      if(q)
         BSstackdealloc((char *)q);
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSbrapproxs");
   return;
   }
}   

