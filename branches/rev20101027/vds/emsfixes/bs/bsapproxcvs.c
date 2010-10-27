/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSapproxcvs

Abstract
    This routine given an array of curves will reduce a maximum number of 
knots while staying within a given chord height tolerance.  It also will 
output the maximum error, and the average error.

Synopsis
    void BSapproxcvs(numcvs, origcurves,curves,allsame,tanl,tanr,tandirl,
                     tandirr,option, maxerr, avgerr, cvind, opar, apar, 
                     opt, apt, appcurves, rc)
 
    IGRint              numcvs
    struct IGRbsp_curve *origcurves[]
    struct IGRbsp_curve *curves[]
    IGRboolean          allsame
    IGRboolean          *tanl
    IGRboolean          *tanr
    IGRpoint            *tandirl,
                        *tandirr
    IGRboolean          option
    IGRdouble           *maxerr
    IGRdouble           *avgerr
    IGRint              *cvind
    IGRdouble           *opar
    IGRdouble           *apar
    IGRpoint            opt
    IGRpoint            apt
    struct IGRbsp_curve *appcurves[]
    BSrc                *rc

Description
    This routine inputs the number of curves(numcvs), the original b-spline 
curves(origcurves), the approximated curves with reduced knots(curves), and 
whether tangent constraints on the ends are desired(tanl and tanr).  If 
constraints, then the left tangent (tandirl) or right tangent (tandirr) is 
input and also an option to say that all the tangents options are the same
(allsame:0 or 1).  It outputs the curves(appcurve) with as many knots removed 
as possible and still have all the curves within given tolerance of input 
curves.  The orignal curves is only used to calculate the approximation error
and the other input curves is the one we do data reduction on.  Also output if
"option" = true, is the maximum error(maxerr), the average error(avgerr), the
parameter values and points on each curve at maximum error(par1, pt1, par2, and 
pt2), and the index to which curve has the maximum error(cvind).

Notes
    If allsame is FALSE, then an array(tanl[] and tanr[]) is input with an 
option on each curve, but if allsame = TRUE then the array is only one value, 
meaning that the array is all the same value.

    The caller must allocate space for the output curves, an upper limit is
the same size as the input curves(curves).

    The tolerance used is the chord height tolerance, so if the caller wishes
to change it he can call BSchangepar.

    Initially the "curves" are the same as the "origcurves".

Return Values
    This routine returns BSSUCC, if successful and an appropriate error message
if an error occurrs.

Index
    md

Keywords

History
    S.G. Catron  06/23/88  : Creation date.
    S.G. Catron  08/04/88  : Changed argument list so that you could only 
                             send in one value for tanl and tanr, if all 
                             the values were the same.
    S.G. Catron  08/08/88  : Typo in setting point2 for tanr.  It was 
                             setting point instead of point2.  Added 
                             arguments to output the maximum and average 
                             errors.  Also made this routine work for one 
                             curve.
    S.G. Catron  09/15/88  : Changed call BSr_approxs to BSbrapproxs
                             which calls BSr_approxs inside it.  
                             BSbrapproxs was made better for large data
                             cases.
    S.G. Catron  09/20/88  : Argument list of BSnrm_2_cvs changed so
                             that we no longer need to input node values.
    S.G. Catron  10/06/88  : Instead of always ranking the first curve,
                             rank the longest.  Also check for degenerate
                             curves and don't do anything with them until
                             the end and we know how many poles we need.
                             Also before calling BSrkv_f_kts call 
                             BSchangepar to change the knot_tol, so that
                             BSrkv_f_kts can just extract it.
    S.G. Catron  10/19/88  : Calculation of the size of static memory
                             used for the poles, knots, and weights in
                             curves save, and c1, was wrong.
    S.G. Catron  10/20/88  : Take out call to BSchrdlkts and put it in 
                             upper level routine BSdta_rducv.
    S.G. Catron  03/07/89  : In the case where we copy the saved curves
                             to the output curves and the curve is
                             degenerate, don't use nsub as the number of
                             poles, but save the previous nsub(number of
                             poles) and use that one.  
                             Also, if no knots were removed, then always
                             copy the input curves to the output curves, 
                             even if it's the degenerate case.
    C. S. Kirby  08/22/89  : Correct lint errors for illegal pointer
                             combination.
    V.W.Ye       10/16/89  : Set num_boundaries = 0 and bdrys = NULL.
    S.G. Catron  12/12/90  : Fixed apogee errors.  Found a memory problem
                             by running with max defines different.  It
                             wasn't initializing count and i when size was
                             0.  Thus not allocating c1 curves correctly.
    S.G. Catron  09/30/91  : When setting the output curves to the
                             previous saved curves, there was a problem
                             when the first curve was degenerate.  The
                             knots were not being set right.
    S.G. Catron  12/08/93  : Make sure the cht is not 0.0.  This will
                             prevent problems later in BSrk_rkvecs of
                             dividing by 0.0.
    S.G. Catron  12/09/93  : Initialize tnint=0.
    S.G. Catron  01/25/00  : VDS 179900956, JTS 10197 - dta_rducv.d40(bad 
                             parameterization), dta_rducv.d41(nice).  Modified to
                             send in the tolerance to BSnrm_2_cvs, so that it
                             can break out if it finds an error greater than
                             our tolerance.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsstk.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#endif
#include <math.h>
#define BSVOID
#define  MAXNUM 500
#define  MAXNUMS 10
#define  CLOSETOZERO 1.0e-10

static void  degenBSapproxcvs(

IGRshort            order,
IGRint              num_poles,
IGRdouble           *poles,
IGRdouble           *weights,
IGRboolean          rational, 
IGRdouble           *knots,
struct IGRbsp_curve *appcurve,
BSrc                *rc )
{
   IGRpoint pt;
   IGRint i,j;

   *rc = BSSUCC;

   appcurve->order = order;
   appcurve->num_poles = num_poles;
   appcurve->num_knots = num_poles + order;
   appcurve->non_uniform = TRUE;
   appcurve->periodic = FALSE;
   appcurve->phy_closed = TRUE;
   appcurve->planar = FALSE;
   appcurve->rational = rational;
   appcurve->num_boundaries = 0;
   appcurve->bdrys = NULL;

   if( rational )
   {
      for(i=0; i<3; i++)
         pt[i] = poles[i] / weights[0];
   }
   else
   {
      for(i=0; i<3; i++)
         pt[i] = poles[i];
   }

   for(i=0; i< num_poles; i++)
   {
      for(j=0; j<3; j++)
         appcurve->poles[i*3+j] = pt[j];
      if( rational )
         appcurve->weights[i] = 1.0;

   }
   for(i=0; i< appcurve->num_knots; i++)
   {
      appcurve->knots[i] = knots[i];
   }

   return;
}

void BSapproxcvs(

IGRint              numcvs,
struct IGRbsp_curve *origcurves[],
struct IGRbsp_curve *curves[],
IGRboolean          allsame,
IGRboolean          *tanl,
IGRboolean          *tanr,
IGRpoint            *tandirl,
IGRpoint            *tandirr,
IGRboolean          option,
IGRdouble           *maxerr,
IGRdouble           *avgerr,
IGRint              *cvind,
IGRdouble           *opar, 
IGRpoint            opt,
IGRdouble           *apar,
IGRpoint            apt,
struct IGRbsp_curve *appcurves[],
BSrc                *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscv_copy.h"
#include "bstagsort.h"
#include "bschangepar.h"
#include "bsknot_rem2.h"
#include "bststcvdegn.h"
#include "bscvkttol2.h"
#include "bsrk_rkvecs.h"
#include "bsbrapproxs.h"
#include "bsrkv_f_kts.h"
#include "bscvarrev0w.h"
#include "bsnrm_2_cvs.h"
#include "bsdistptpt.h"
#endif 


   IGRint tnint=0,nrem,lessnrem,morenrem,i,j,l,k,
          count=numcvs, bnum_poles=0, bnum_knots, ncvs;
   IGRboolean done,remove, rational,
              ttan[2], zero_rank, temptanl,
              temptanr, *degen=NULL, adegen[MAXNUM];
   struct IGRbsp_curve **c1=NULL,**save=NULL,
                       *ac1[MAXNUM], *asave[MAXNUM],
                       *bcurve=NULL;
   IGRvector aranks[MAXNUM],*ranks=NULL;
   IGRint aweights[MAXNUM],*weights=NULL,*array=NULL,n,nsub,
          *subs=NULL,asubs[MAXNUM],nd, index, saveind=0,
          cvi, delta, oldnsub=0;
   IGRdouble akts_to_rem[MAXNUM],*kts_to_rem=NULL,
             asubknots[MAXNUM],*subknots=NULL,
             dist,par_tol, wts_pts[4], sknot_tol,
             c1_knots[MAXNUMS*(MAXNUM+MAX_ORDER)],
             c1_weights[MAXNUMS*MAXNUM], knot_tol,
             save_weights[MAXNUMS*MAXNUM],
             save_knots[MAXNUMS*(MAXNUM+MAX_ORDER)],
             bknots[MAXNUM+MAX_ORDER],bweights[MAXNUM],
             avg, par1, par2, saveopar=0.0, saveapar=0.0,
             savemax=0, saveavg=0.0, sum, sum1;
   IGRpoint  c1_poles[MAXNUMS*MAXNUM],save_poles[MAXNUMS*MAXNUM],
             point, point2,bpoles[MAXNUM], pt1, pt2, saveopt, saveapt;
   IGRdouble nodu, chrdht_tol;
   IGRint    ind, size=0, end,
             num_poles, num_knots, snum_knots=0, snint=0;
   IGRshort  order;
   BSrc rc2;

   *rc = BSSUCC;

   BSEXTRACTPAR(rc, BSTOLKNOT, sknot_tol);
   BSEXTRACTPAR(rc, BSTOLCHRDHT, chrdht_tol);
   if( chrdht_tol <= 0.0 )
   {
      *rc = BSINVCHT;
      goto wrapup;
   }

   tnint = curves[0]->num_poles - curves[0]->order;
   nd = 1;
   order = curves[0]->order;
   num_poles = curves[0]->num_poles;
   num_knots = curves[0]->num_knots;
   rational = curves[0]->rational;
   ncvs = 1;
   if( option )
   {
      *maxerr = 0.0;
      *avgerr = 0.0;
      *opar = curves[0]->knots[order -1];   
      *apar = *opar;   
      for(i=0; i<3; i++)
      {
         if( rational )
         {
            opt[i] = curves[0]->poles[i]/curves[0]->weights[0];   
            apt[i] = opt[i];
         }
         else
         {
            opt[i] = curves[0]->poles[i];
            apt[i] = opt[i];
         }
      }
   }

   if( allsame )
   {
      ttan[0] = tanl[0];
      ttan[1] = tanr[0];
   }
   else
   {
      ttan[0] = FALSE;
      for(i=0; i< numcvs; i++)
      {
         if( tanl[i] )
         {
            ttan[0] = TRUE;
            break;
         }
      }
      ttan[1] = FALSE;
      for(i=0; i< numcvs; i++)
      {
         if( tanr[i] )
         {
            ttan[1] = TRUE;
            break;
         }
      }
   }
   /* take care of all the special cases  */
   if( tnint == 0 ||
       (ttan[0] && ttan[1] && num_poles <= 4) || 
       ((ttan[0] || ttan[1]) && num_poles <= 3) )
   {
      
      for(i=0; i< numcvs; i++)
      {
         (void)BScv_copy(rc,curves[i],appcurves[i]);
         if(BSERROR(*rc))
            goto wrapup;
      }
      goto wrapup;
   }


   snint = tnint;
   if( tnint > MAXNUM)
   {
      ranks = (IGRvector *)BSstackalloc((unsigned)(tnint * sizeof(IGRvector)));
      if(!ranks)
      {
         *rc = BSNOSTKMEMORY;
      }
   }
   else
   {
      ranks = aranks;
   }
   /* choose the longest curve to do the ranking on 
      this hopefully will be a fairly good choice */

   cvi = 0;
   if( numcvs > 1 )
   {
      delta = curves[0]->num_poles / 20 + 1;
      sum = 0;
      for(j=0; j< curves[0]->num_poles -1; j+=delta)
      {
         for(k=0; k<3; k++)
         {
            sum += fabs(curves[0]->poles[j*3+k] - 
                        curves[0]->poles[(j+1)*3+k] );
         }
      }
      for(i=1; i< numcvs; i++)
      {
         sum1 = 0;
         for(j=0; j< curves[i]->num_poles -1; j+=delta)
         {
            for(k=0; k<3; k++)
            {
               sum1 += fabs(curves[i]->poles[j*3+k] - 
                           curves[i]->poles[(j+1)*3+k] );
            }
         }
         if( sum1 > sum )
            cvi = i;
      }
   }
   BScvkttol2(order, curves[cvi]->knots, num_poles, curves[cvi]->poles,
              curves[cvi]->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSchangepar(rc, BSTOLKNOT, knot_tol);
   if(BSERROR(*rc))
      goto wrapup;
   BSrkv_f_kts(curves[cvi],ranks,rc);
   if(BSERROR(*rc))
   {
      (void)BSchangepar(&rc2, BSTOLKNOT, sknot_tol);
      goto wrapup;
   }
   (void)BSchangepar(rc, BSTOLKNOT, sknot_tol);
   if(BSERROR(*rc))
      goto wrapup;
   snum_knots = num_knots;
   if( num_knots > MAXNUM )
   {
      subknots = (IGRdouble *)BSstackalloc((unsigned)( num_knots * 
                                                      sizeof(IGRdouble )));
      if(!subknots)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      subknots = &asubknots[0];
   }
   /* count the ranks which are near CLOSETOZERO, also
      count the ranks which are greater than chrdht_tol */
   if( numcvs == 1 )
   {
      /* we can remove all zero rank vectors */
      /* this can't be done to more than one curve, because they all don't
         share the same rank vectors */
      count = order;
      for(i=0; i< tnint; i++)
      {
         zero_rank = TRUE;
         for(j=0; j<3; j++)
         {
            if( ranks[i][j] > CLOSETOZERO  )
            {
               zero_rank = FALSE;
               break;
            }
         }
         if( !zero_rank )
         {
            subknots[count] = curves[cvi]->knots[order + i];
            count += 1;
         }
      }
      if( count < num_poles )
      {
         bnum_poles = count; /* used later for deallocing */
         bnum_knots = bnum_poles + order;
         if( bnum_poles > MAXNUM )
         {
            BSstkallocv(rc,bcurve,bnum_poles,rational,bnum_knots,  
                        curves[cvi]->num_boundaries);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
         else
         {
            bcurve = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof(
                                          struct IGRbsp_curve )));
            if(!bcurve)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            bcurve->poles = &bpoles[0][0];
            bcurve->knots = &bknots[0];
            bcurve->weights = NULL;      
            if( rational )
               bcurve->weights = &bweights[0];
         }
         /* we did have some knots with rank vector zero */
         for(i=0; i< order; i++)
         {
            subknots[i] = curves[cvi]->knots[i];
            subknots[count + i] = curves[cvi]->knots[num_poles +i];
         }
         temptanl = FALSE;
         temptanr = FALSE;      
         BSbrapproxs(ncvs, &curves[cvi], count, subknots, temptanl, 
                     temptanr, &bcurve, rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         tnint = bcurve->num_poles - order;
         if( tnint == 0 ||
             (ttan[0] && ttan[1] && bcurve->num_poles < 4) || 
             ((tanl || tanr) && bcurve->num_poles < 3) )
         {
            (void)BScv_copy(rc,bcurve,appcurves[0]);
            goto wrapup;
         }
         else
         {
            (void)BScv_copy(rc, bcurve, curves[0]);
            if(BSERROR(*rc))
               goto wrapup;
            num_poles = bcurve->num_poles;
            num_knots = bcurve->num_knots;
         }
         (void)BSchangepar(rc, BSTOLKNOT, knot_tol);
         if(BSERROR(*rc))
            goto wrapup;
         BSrkv_f_kts(bcurve,ranks,rc);
         if(BSERROR(*rc))
         {
            (void)BSchangepar(&rc2, BSTOLKNOT, sknot_tol);
            goto wrapup;
         }
         (void)BSchangepar(rc, BSTOLKNOT, sknot_tol);
         if(BSERROR(*rc))
            goto wrapup;
      }
   }

   if( tnint > MAXNUM)
   {
      weights = (IGRint *)BSstackalloc((unsigned)( tnint * sizeof(IGRint )));
      if(!weights)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      weights = &aweights[0];
   }
   BSrk_rkvecs(tnint,ranks,chrdht_tol,chrdht_tol,chrdht_tol,weights,&n,
               &array,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   /* check for degenerate curves */
   if( numcvs > MAXNUM )
   {
      degen = (IGRboolean *)BSstackalloc((unsigned)( numcvs * sizeof
                                     (IGRboolean )));
      if(!degen )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      degen = &adegen[0];
   }
   j = 0;
   for(i=0; i< numcvs; i++)
   {
      BStstcvdegn(curves[i], &degen[i], rc);
      if(BSERROR(*rc))
         goto wrapup;
      if( degen[i] )
         j += 1;
   }
   
   if( numcvs > MAXNUM )
   {
      c1 = (struct IGRbsp_curve **)BSstackalloc((unsigned)( numcvs * sizeof
                                              (struct IGRbsp_curve *)));
      if(!c1 )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      save = (struct IGRbsp_curve **)BSstackalloc((unsigned)( numcvs * sizeof
                                              (struct IGRbsp_curve *)));
      if( !save )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      save = asave;
      c1 = ac1;
   }
   for(i=0; i<numcvs; i++)
   {
      save[i] = NULL;   
      c1[i] = NULL;   
   }

   /* how many curves you can get out of declared memory */
   size = MIN(MAXNUM * MAXNUMS / num_poles,
              MAXNUMS * (MAXNUM + MAX_ORDER)/ num_knots);
   if( size > 0  )
   {
      end = 0;
      for(i=0; i< numcvs; i++)
      {
         if( degen[i] )
            continue;
         if( end == size )
            break;
         c1[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                     (struct IGRbsp_curve )));
         if(!c1[i])
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         c1[i]->poles = &c1_poles[end*num_poles][0];
         c1[i]->knots = &c1_knots[end*num_knots];
         c1[i]->weights = NULL;
         if( rational )
            c1[i]->weights = &c1_weights[end*num_poles];
         c1[i]->num_boundaries = 0;
         c1[i]->bdrys = NULL;
         save[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                     (struct IGRbsp_curve )));
         if(!save[i])
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         save[i]->poles = &save_poles[end*num_poles][0];
         save[i]->knots = &save_knots[end*num_knots];
         save[i]->weights = NULL;
         if( rational )
            save[i]->weights = &save_weights[end*num_poles];
         save[i]->num_boundaries = 0;
         save[i]->bdrys = NULL;
         /* count the curves we allocate */
         end += 1;
      }
      count = i;
   }
   else
   {
      count = 0;
      i = 0;
   }
   if( count != numcvs )
   {
      for(; i< numcvs; i++)
      {
         if( degen[i] )
            continue;
         BSstkallocv(rc,c1[i],num_poles,rational,num_knots,NULL);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         BSstkallocv(rc,save[i],num_poles,rational,num_knots,NULL);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
      }
   }
   if( tnint > MAXNUM)
   {   
      kts_to_rem = (IGRdouble *)BSstackalloc((unsigned)( tnint * 
                                                    sizeof(IGRdouble )));
      if(!kts_to_rem)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }   
   }
   else
   {
      kts_to_rem = &akts_to_rem[0];
   }
   BSEXTRACTPAR(rc,BSTOLPARAM,par_tol);

   if( tnint > MAXNUM)
   {
      subs = (IGRint *)BSstackalloc((unsigned)( tnint * sizeof(IGRint )));
      if(!subs)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      subs = &asubs[0];
   }

   morenrem = tnint;
   if( order < 4 )
   {
      if( ttan[0] && ttan[1])
      {
         morenrem = MIN(morenrem, num_poles -4);
      }
      else
      {
         if( (ttan[0] || ttan[1] ) && order < 3 )
         {
           morenrem = MIN(morenrem, num_poles -3);
         }
      }
   }         
   nrem = (morenrem +1 ) / 2;
   lessnrem = 0;
   done = FALSE;
   ind = 0;
   while (! done  )
   {
      BSknot_rem2(curves[cvi]->knots,order,num_poles,weights,array,n,
                  nrem,kts_to_rem,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      /* find new knot vector with removed knots */
      nsub = num_poles - nrem;
      for(i=0; i< order; i++)
      {
         subknots[i] = curves[cvi]->knots[i];
         subknots[nsub +i] = curves[cvi]->knots[num_poles + i];
      }
      if( nrem != 1 )
      {
         (void)BStagsort(rc,&nrem,kts_to_rem,subs);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
      }
      else
      {
         subs[0] = 0;
      }
      l = order;
      for(i=order,j = 0; i < num_poles; i++)
      {
         remove = FALSE;
         if( j != nrem )
         {
            if( fabs(curves[cvi]->knots[i] - kts_to_rem[subs[j]] ) 
                 < par_tol )
            {
               j += 1;
               remove = TRUE;
            }
         }
         if( !remove)
         {
            subknots[l] = curves[cvi]->knots[i];
            l += 1;
         }
      } 
      *maxerr = 0;
      *avgerr = 0;
      for(i=0; i< numcvs; i++)
      {
         if( degen[i] )
            continue;
         if( allsame )
            index = 0;
         else
            index = i;
         if( tanl[index])
         {
            if( fabs(subknots[order] - curves[i]->knots[order]) > knot_tol)
            { 
               /* first interior knot is being removed */
               nodu = ((order -2) * subknots[order -1] + 
                       subknots[order] ) / ( order -1 );
               BScvarrev0w(curves[i],nd,&nodu,wts_pts,rc);
               if(BSERROR(*rc))
                  goto wrapup;
               if( rational )
               {
                  for(j=0; j<3; j++)
                  {
                     wts_pts[j] /= wts_pts[3];
                     point[j] = curves[i]->poles[j] / curves[i]->weights[0];
                  }
                  c1[i]->weights[1] = wts_pts[3];
               }
               else
               {
                  for(j=0; j<3; j++)
                     point[j] = curves[i]->poles[j];
               }         
               dist = BSdistptpt(rc, wts_pts, point);
               if(BSERROR(*rc))
                  goto wrapup;
               for(j=0; j<3; j++)
               {
                  if( rational )
                     c1[i]->poles[3+j] = (dist * 1.1 * tandirl[i][j] + point[j]) *
                                       c1[i]->weights[1];
                  else
                     c1[i]->poles[3+j] = dist * 1.1 * tandirl[i][j] + 
                                         point[j];
               }
            }
            else
            {
               /* first interior knot is not being removed */
               if( rational )
               {
                  for(j=0; j<3; j++)
                  {
                     point[j] = curves[i]->poles[j] / curves[i]->weights[0];
                     point2[j] = curves[i]->poles[j+3] / curves[i]->weights[1];
                  }
                  c1[i]->weights[1] = curves[i]->weights[1];
               }
               else
               {
                  for(j=0; j<3; j++)
                  {
                     point[j] = curves[i]->poles[j];
                     point2[j] = curves[i]->poles[j+3];
                  }
               }         
               dist = BSdistptpt(rc, point, point2);
               if(BSERROR(*rc))
                  goto wrapup;
               for(j=0; j<3; j++)
               {
                  if( rational )
                     c1[i]->poles[3+j] = (dist * tandirl[i][j] + point[j]) *
                                       c1[i]->weights[1];
                  else
                     c1[i]->poles[3+j] = dist * tandirl[i][j] + 
                                         curves[i]->poles[j];
               }
            }
         }
         if( tanr[index])
         {
            if( fabs(subknots[nsub -1] - curves[i]->knots[num_poles - 1]) >
                knot_tol )
            {
               nodu = ((order -2) * subknots[nsub] + 
                       subknots[nsub -1] ) / ( order -1 );
               BScvarrev0w(curves[i],nd,&nodu,wts_pts,rc);
               if(BSERROR(*rc))
                  goto wrapup;
               if( rational )
               {
                  for(j=0; j<3; j++)
                  {
                     wts_pts[j] /= wts_pts[3];
                     point[j] = curves[i]->poles[(num_poles -1)*3+j] / 
                                curves[i]->weights[num_poles -1];
                  }
                  c1[i]->weights[nsub -2] = wts_pts[3];
               }
               else
               {
                  for(j=0; j<3; j++)
                     point[j] = curves[i]->poles[(num_poles -1)*3+j];
               }         
               dist = BSdistptpt(rc, wts_pts, point);
               if(BSERROR(*rc))
                  goto wrapup;
               for(j=0; j<3; j++)
               {
                  if( rational )
                  {
                     c1[i]->poles[(nsub-2)*3+j] = (dist * 1.1 * (-tandirr[i][j])
                                          + point[j]) * c1[i]->weights[nsub -2];
                  }
                  else
                  {
                     c1[i]->poles[(nsub-2)*3+j] = dist * 1.1 * (-tandirr[i][j])
                                       + point[j];
                  }
               }
            }     
            else
            {
               if( rational )
               {
                  for(j=0; j<3; j++)
                  {
                     point[j] = curves[i]->poles[(num_poles -1)*3+j] / 
                                curves[i]->weights[num_poles -1];
                     point2[j] = curves[i]->poles[(num_poles -2)*3+j] / 
                                curves[i]->weights[num_poles -2];
                  }
                  c1[i]->weights[nsub -2] = curves[i]->weights[num_poles-2];
               }
               else
               {
                  for(j=0; j<3; j++)
                  {
                     point[j] = curves[i]->poles[(num_poles -1)*3+j];
                     point2[j] = curves[i]->poles[(num_poles -2)*3+j];
                  }
               }         
               dist = BSdistptpt(rc, point, point2);
               if(BSERROR(*rc))
                  goto wrapup;
               for(j=0; j<3; j++)
               {
                  if( rational )
                  {
                     c1[i]->poles[(nsub-2)*3+j] = (dist *  (-tandirr[i][j]) + 
                                            point[j]) * c1[i]->weights[nsub -2];
                  }
                  else
                  {
                     c1[i]->poles[(nsub-2)*3+j] = dist * (-tandirr[i][j]) + 
                                            point[j];
                  }
               }
            }     
         }         
         BSbrapproxs(ncvs,&curves[i],nsub, subknots, tanl[index], tanr[index],
                     &c1[i], rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         avg = -3.0;
         dist = chrdht_tol;
         BSnrm_2_cvs(origcurves[i],c1[i], &dist, &avg, &par1, pt1, &par2, pt2, rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         if( dist > chrdht_tol )
            break;
         if( option )
         {
            *avgerr += avg;
            if( dist > *maxerr )
            {
               *cvind = i;
               *maxerr = dist;
               *opar = par1;
               *apar = par2;
               for(j=0; j<3; j++)
               {
                  opt[j] = pt1[j];
                  apt[j] = pt2[j];
               }
            }
         }
      }

      if( dist < chrdht_tol)
      {
         if( nrem == morenrem)
         {
            done = TRUE;
            for(i=0; i< numcvs; i++)
            {
               if( degen[i] )
               {
                  /* fix output curve */
                  degenBSapproxcvs(order, nsub, curves[i]->poles, 
                                   curves[i]->weights, rational, subknots,
                                   appcurves[i], rc);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  (void)BScv_copy(rc,c1[i],appcurves[i]);
                  if( BSERROR(*rc))
                      goto wrapup;
               }
            }
         } 
         else
         {
            if( ind == 2 )
            {
               /* then last time nrem > chrdht_tol, but this time it's less */
               done = TRUE;
               for(i=0; i< numcvs; i++)
               {
                  if( degen[i] )
                  {
                     /* fix output curve */
                     degenBSapproxcvs(order, nsub, curves[i]->poles, 
                                   curves[i]->weights, rational, subknots,
                                   appcurves[i], rc);
                     if(BSERROR(*rc))
                        goto wrapup;
                  }
                  else
                  {
                     (void)BScv_copy(rc,c1[i],appcurves[i]);
                     if( BSERROR(*rc))
                         goto wrapup;
                  }
               }
            }
            else
            {
               /* try more knots */
               lessnrem = nrem;
               if( morenrem - lessnrem == 1)
               {
                  nrem += 1;
               }
               else
               {
                  nrem = nrem + (morenrem - lessnrem )/2;
               }

               for(i=0; i< numcvs; i++)
               {
                  if(!degen[i] )
                  {
                     oldnsub = i;
                     (void)BScv_copy(rc,c1[i],save[i]);
                     if( BSERROR(*rc))
                         goto wrapup;
                  }
               }
               if( option )
               {
                  saveind = *cvind;
                  saveavg = *avgerr;
                  savemax = *maxerr;
                  saveopar = *opar;
                  saveapar = *apar;
                  for(j=0; j<3; j++)
                  {
                     saveopt[j] = opt[j];
                     saveapt[j] = apt[j];
                  }
               }
            }
         }
         ind = 1;
      }
      else
      {
         /* dist > chrdht_tol  */

         if( ind == 1 )
         {
            for(i=0; i< numcvs; i++)
            {
               if( degen[i] )
               {
                  /* fix output curve */
                  degenBSapproxcvs(order,(IGRint)save[oldnsub]->num_poles,
                                   curves[i]->poles, curves[i]->weights, 
                                   rational, save[oldnsub]->knots,
                                   appcurves[i], rc);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  (void)BScv_copy(rc,save[i],appcurves[i]);
                  if( BSERROR(*rc))
                     goto wrapup;
               }
            }
            if( option )
            {
               *cvind = saveind;
               *avgerr = saveavg;
               *maxerr = savemax;
               *opar = saveopar;
               *apar = saveapar;
               for(j=0; j<3; j++)
               {
                  opt[j] = saveopt[j];
                  apt[j] = saveapt[j];
               }
            }
            done = TRUE;
         }
         else
         {
            morenrem = nrem;            
            if( nrem == 1)
            {
               done = TRUE;
               for(i=0; i< numcvs; i++)
               {
                  (void)BScv_copy(rc,curves[i],appcurves[i]);
                  if( BSERROR(*rc))
                      goto wrapup;
               }
            }
            else
            {
               nrem -= (morenrem - lessnrem)/2;
            }
         }
         ind = 2;
      }
   }
   if( option  )
      *avgerr /= numcvs;

   wrapup:

   if( tnint > MAXNUM)
   {
      if( subs)
         BSstackdealloc((char *)subs);
      if( kts_to_rem)
         BSstackdealloc((char *) kts_to_rem);
   }
   if( c1 && save)
   {
      if( count != numcvs )
      {
         for(i=numcvs -1; i>=count; i--)
         {
            if( degen[i] )
               continue;
               /* we didn't allocate for degenerates */
            if( save[i] )
            {
               BSstkfreecv(&rc2,save[i]);
               if(BSERROR(rc2) && BSOKAY(*rc) )
                  *rc = rc2;
            }
            if( c1[i])
            {
               BSstkfreecv(&rc2,c1[i]);
               if(BSERROR(rc2) && BSOKAY(*rc) )
                  *rc = rc2;
            }
         }
      }

      if( size > 0  )
      {
         for(i=count-1; i>=0; i--)
         {
            if( degen[i] )
               continue;
               /* we didn't allocate for degenerates */
            if(save[i])
               BSstackdealloc((char *)save[i]);
            if(c1[i])
               BSstackdealloc((char *)c1[i]);
         }
      }
   }
   if( numcvs > MAXNUM )
   {
      if( c1 )
         BSstackdealloc((char *) c1 );
      if( save )
         BSstackdealloc(( char *)save);
   }
   if( bcurve )
   {
      if( bnum_poles > MAXNUM )
      {
         BSstkfreecv(&rc2,bcurve);
         if(BSERROR(rc2) && BSOKAY(*rc) )
            *rc = rc2;
      }
      else
      {
         BSstackdealloc((char *)bcurve );
      }
   }
      
   if( tnint > MAXNUM )
   {
      if( weights)
         BSstackdealloc((char *)weights);
   }
   if( snum_knots > MAXNUM )
   {
      if( subknots)
         BSstackdealloc((char *) subknots);
   }
   if( snint > MAXNUM )
   {
      if( ranks)
         BSstackdealloc((char *)ranks);
   }
   if( array)
   {
      /* array was malloced in BSrk_rkvecs */
      BSdealloc((char *)array);
   }
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSapproxcvs");
   return;
   }
}
                
