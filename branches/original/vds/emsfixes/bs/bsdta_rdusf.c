/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSdta_rdusf

Abstract
    This routine given a b-spline surface, will remove as many knots as 
possible and still have the approximated surface within chord height 
tolerance.

Synopsis
    void BSdta_rdusf(surf, option, tanl, tanr, tant, tanb, erropt,
                     maxerr, avgerr, uvpar, pt, auvpar, apt, appsurf, rc)
 
    struct IGRbsp_surface *surf
    IGRint                option
    IGRint                tanl,
                          tanr,
                          tant,
                          tanb
    IGRboolean            erropt
    IGRdouble             *maxerr, 
                          *avgerr
    IGRdouble             uvpar[2],
                          auvpar[2]
    IGRpoint              pt, apt
    struct IGRbsp_surface **appsurf
    BSrc                  *rc

Description
    This routine inputs b-spline surface(surf), an option whether to do 
data reduction in the u-direction, v_direction or both(option:  0-for u, 
1-for v, and 2 for both), and whether tangent constraints on the ends are 
desired(tanl, tanr, tant, and tanb: explained further in notes).  It 
outputs the approximated surface(appsurf) with as many knots removed from 
the input surface as possible and still be within the chord height 
tolerance.  Also if "erropt" = TRUE, then we will output the maximum and 
average errors between the input and output surfaces, plus the parameters 
and points on each surface at the maxerr (uvpar, pt, auvpar, apt).

Return Values
    This routine returns BSSUCC, if successful and an appropriate error message
if an error occurs.

Notes
    Tanl corresponds to the left side of the surface.  - option=0,1
    Tanr corresponds to the right side of the surface. - option=0,1 
    Tant corresponds to the top of the surface.  - option=0,1
    Tanb corresponds to the bottom of the surface. - option=0,1
    (0-for no tangent constraints, 1-for constraints)

    This routine extracts the chord height tolerance, so the user can set
it by calling BSchangepar.  

Index
    em

Keywords

History
    S.G. Catron  07/08/88  : Creation date.
    S.G. Catron  08/04/88  : Changed argument list to only input one value
                             for tangent conditions on each side of the 
                             surface.
    S.G. Catron  08/11/88  : Changed to call BSr_approxs instead of 
                             BSnr_approx. Also added arguments to output 
                             the maximum and average errors between the 
                             input and output surfaces.
    S.G. Catron  09/07/88  : There was a problem in assigning the 
                             characteristics, when the option was 2 and
                             we started in the v-direction.
    S.G. Catron  09/15/88  : Changed call BSr_approxs to BSbrapproxs,
                             which calls BSr_approxs inside it.  
                             BSbrapproxs is a new routine which is better
                             for big data cases.
    S.G. Catron  10/06/88  : Change the knot_tol before calling 
                             BSrkv_f_kts, because BSrkv_f_kts extracts
                             the knot_tol.
    S.G. Catron  10/18/88  : Forgot to set ranks and ranks2 to NULL.
    S.G. Catron  10/19/88  : The sizes calculated for use of the static
                             memory for the poles and knots of the
                             arrays of curves were wrong.  These were
                             variables "size", "sizeb", "size2", and
                             "sizeb2".
    S.G. Catron  12/16/88  : There was a typo in the use of sizeb2, it
                             was using sizeb instead.
    S.G. Catron  02/22/89  : Changed the Notes section which explains the
                             tant, tanb, tanl, tanr.
    S.G. Catron  03/07/89  : Before calling BSrkv_f_kts, to rank the
                             knot vector of one of the curves, find a 
                             curve which is not degenerate.           
    C.S. Kirby   08/23/89  : Correct lint errors : illegal pointer 
                             combination.
    D. Breden    10/17/89  : Initialize boundary data in temporary curves
                             and surfaces.
    S.G. Catron  11/06/91  : Moved BSchangepar to wrapup when there is an
                             error.  Also don't use rc if rc is already 
                             an error, use rc2.
    S.G. Catron  12/24/91  : When ranking a row of the surface, find the
                             two longest rows and rank both.  Then only
                             remove knots where both rank vectors are
                             zero.
    AH           05/22/98  : TR179801101 Memory problems causing core dumps.
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
#include "bsstk.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#endif

#define  BSVOID
#include <math.h>
#define  MAXNUM 200
#define  MAXNUMS 20
#define  CLOSETOZERO  1.0e-10

void BSdta_rdusf(
struct IGRbsp_surface *surf,
IGRint                option,
IGRint                tanl,
IGRint                      tanr,
IGRint                      tant,
IGRint	tanb,
IGRboolean            erropt,
IGRdouble             *maxerr,
IGRdouble             	*avgerr,
IGRdouble             uvpar[2],
IGRpoint              pt,
IGRdouble	auvpar[2],
 IGRpoint	 apt,
struct IGRbsp_surface **appsurf,
BSrc                  *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsdtarducvs.h"
#include "bsrkv_f_kts.h"
#include "bscvkttol2.h"
#include "bsbrapproxs.h"
#include "bssf_copy.h"
#include "bsmdistptsf.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bschangepar.h"
#include "bsdistptpt.h"
#include "bststcvdegn.h"
#include "bsallocsf.h"
#endif 

   IGRint i,j,k, nsubknots=0, nsubknots2=0;
   struct IGRbsp_curve **curves=NULL,**curves2=NULL,
             *acurves[MAXNUM],*acurves2[MAXNUM],
             **appcurves=NULL,**bcurves=NULL, 
             **bcurves2=NULL,
             *aappcurves[MAXNUM], *abcurves[MAXNUM],
             *abcurves2[MAXNUM];
   IGRdouble knots[MAXNUMS*(MAXNUM+MAX_ORDER)],
             bknots[MAXNUMS*(MAXNUM+MAX_ORDER)],
             weights[MAXNUMS*MAXNUM],
             bweights[MAXNUMS*MAXNUM],
             *subknots=NULL, asubknots[MAXNUM],
             *subknots2=NULL,asubknots2[MAXNUM],
             knot_tol, sknot_tol,chrdht_tol, hchrdht_tol,
             *tangent=NULL, *ptr1=NULL, *ptr2=NULL, *ptr3,
             *ptr4;
   IGRpoint  poles[MAXNUM*MAXNUMS],
             bpoles[MAXNUM*MAXNUMS];
   BSrc      rc2;
   IGRint    num=0, u_num_poles, v_num_poles,
             num2=0,count,n_poles, n_knots,
             nint1=0, nint2=0, size2=0, size1=0, sizeb=0,
             end1=0, end2=0, endb=0, endb2=0, tan1[1], tan2[1],
             sizeb2=0;
   IGRshort  u_order, v_order;
   IGRboolean rational, zero_rank,
              temptanl=FALSE, temptanr=FALSE, option2=0,
              same=TRUE;
   IGRvector *ranks=NULL, *ranksb=NULL, aranks[MAXNUM], 
             *ranks2=NULL, *ranks2b=NULL, aranks2[MAXNUM];
   IGRdouble par, max, avg, dist, sum, sum1;
   IGRpoint  pt1, pt2, pt3, pt4;
   IGRint    cvind, cvi1, cvi2,delta;
      
   *rc = BSSUCC;

   u_num_poles = surf->u_num_poles;
   v_num_poles = surf->v_num_poles;
   u_order = surf->u_order;
   v_order = surf->v_order;
   rational = surf->rational;
   hchrdht_tol = -1.0;
   BSEXTRACTPAR(rc, BSTOLKNOT, sknot_tol);
   BSEXTRACTPAR(rc, BSTOLCHRDHT, chrdht_tol);
   if( erropt )
   {
      *maxerr = 0.0;
      *avgerr = 0.0;
      uvpar[0] = surf->u_knots[u_order -1];
      uvpar[1] = surf->v_knots[v_order -1];
      auvpar[0] = uvpar[0];
      auvpar[1] = uvpar[1];
      for(i=0; i<3; i++)
      {
         if( rational )
            pt[i] = surf->poles[i]/surf->weights[0];
         else
            pt[i] = surf->poles[i];
         apt[i] = pt[i];
      }
   }
 
   /* take care of all the special cases  */
   if( option == 0 && u_order == u_num_poles )
   {
      BSallocsf(u_order, v_order,u_num_poles, v_num_poles,rational,
                surf->num_boundaries,appsurf,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      (void)BSsf_copy(rc,surf,*appsurf);
         goto wrapup;
   }
   else
   {
      if( option == 1 && v_order == v_num_poles )
      {
         BSallocsf(u_order, v_order,u_num_poles, v_num_poles,rational,
                   surf->num_boundaries,appsurf,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         (void)BSsf_copy(rc,surf,*appsurf);
            goto wrapup;
      }
      else
      {
         if( option == 2 && u_order == u_num_poles &&
             v_order == v_num_poles )
         {
            BSallocsf(u_order, v_order,u_num_poles, v_num_poles,rational,
                      surf->num_boundaries,appsurf,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            (void)BSsf_copy(rc,surf,*appsurf);
               goto wrapup;
         }
      }
   }

   if( option == 2 )
   {
      hchrdht_tol = chrdht_tol * .5;
      (void)BSchangepar(rc, BSTOLCHRDHT, hchrdht_tol);
      if(BSERROR(*rc))
         goto wrapup;
      /* decide which direction we'ld like to do first */
      if( surf->u_num_poles > surf->v_num_poles )
         option2 = 0;
      else
         option2 = 1;
   }

   /* set up to curves to call BSdtarducvs */
   if( option == 0 || (option == 2 && option2 == 0 ) )
   {
      num = v_num_poles;  /* number of curves */
      /* allocate space for the curves */
      if( num > MAXNUM )
      {
         curves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num * 
                           sizeof(struct IGRbsp_curve  *)));
         if( !curves )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         curves = &acurves[0];
      }   
      size1 = MIN(MAXNUM * MAXNUMS / u_num_poles,
                  MAXNUMS * (MAXNUM + MAX_ORDER)/ surf->u_num_knots);
             /* how many curves you can get
                out of declared memory */
      if( size1 > 0  )
      {
         if( num < size1 )
            end1 = num;
         else
            end1 = size1;
         for(i=0; i< end1; i++)
         {
            curves[i] = NULL;
            curves[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                        (struct IGRbsp_curve )));
            if(!curves[i])
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            curves[i]->poles = &poles[i*u_num_poles][0];
            curves[i]->knots = &knots[i*surf->u_num_knots];
            curves[i]->weights = NULL;
            curves[i]->bdrys = NULL;
            if( rational )
               curves[i]->weights = &weights[i*u_num_poles];
         }
      }
      if( num > size1 )
      {
         for(i=size1; i< num; i++)
         {
            curves[i] = NULL;
            BSstkallocv(rc,curves[i],u_num_poles,rational,surf->u_num_knots,
                        NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
      for(i=0; i< num; i++)
      {
         curves[i]->order = u_order;
         curves[i]->num_poles = u_num_poles;
         curves[i]->num_knots = surf->u_num_knots;
         curves[i]->non_uniform = surf->u_non_uniform;
         curves[i]->periodic = surf->u_periodic;
         curves[i]->rational = rational;
         curves[i]->phy_closed = surf->u_phy_closed;
         curves[i]->planar = surf->planar;
         curves[i]->num_boundaries = 0;
         curves[i]->bdrys = NULL;
         for(k=0; k< surf->u_num_knots; k++)
            curves[i]->knots[k] = surf->u_knots[k];
         if( rational)
         {
            ptr1 = curves[i]->weights;
            ptr2 = &surf->weights[i*u_num_poles];
         }
         ptr3 = curves[i]->poles;
         ptr4 = &surf->poles[i*u_num_poles*3];
         for(j=0; j< u_num_poles; j++)
         {
            if( rational)
               *ptr1++ = *ptr2++;
            for(k=0; k<3; k++)
            {
               *ptr3++ = *ptr4++;
            }
         }
      }
      tan1[0] = tanl;
      tan2[0] = tanr;
   }
   else
   {
      num = u_num_poles;  /* number of curves */
      /* allocate space for the curves */
      if( num > MAXNUM )
      {
         curves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num  * 
                           sizeof(struct IGRbsp_curve  *)));
         if( !curves )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         curves = &acurves[0];
      }   
      size1 = MAXNUM * MAXNUMS / v_num_poles;   /* how many curves you can get
                                                   out of declared memory */
      if( size1 > 0 )
      {
         if( num < size1 )
            end1 = num;
         else
            end1 = size1;
         for(i=0; i< end1; i++)
         {
            curves[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                        (struct IGRbsp_curve )));
            if(!curves[i])
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            curves[i]->poles = &poles[i*v_num_poles][0];
            curves[i]->knots = &knots[i*surf->v_num_knots];
            curves[i]->weights = NULL;
            curves[i]->bdrys = NULL;
            if( rational )
               curves[i]->weights = &weights[i*v_num_poles];
         }
      }
      if( num > size1)
      {
         for(i=size1; i< num; i++)
         {
            BSstkallocv(rc,curves[i],v_num_poles,rational,surf->v_num_knots,
                        NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
      for(i=0; i< num; i++)
      {
         curves[i]->order = v_order;
         curves[i]->num_poles = v_num_poles;
         curves[i]->num_knots = surf->v_num_knots;
         curves[i]->non_uniform = surf->v_non_uniform;
         curves[i]->periodic = surf->v_periodic;
         curves[i]->rational = rational;
         curves[i]->phy_closed = surf->v_phy_closed;
         curves[i]->planar = surf->planar;
         curves[i]->num_boundaries = 0;
         curves[i]->bdrys = NULL;
         for(k=0; k< surf->v_num_knots; k++)
            curves[i]->knots[k] = surf->v_knots[k];
         ptr1 = curves[i]->weights;
         ptr2 = curves[i]->poles;
         for(j=0; j< v_num_poles; j++)
         {
            if( rational)
               *ptr1++ = surf->weights[j*surf->u_num_poles+i];
            for(k=0; k<3; k++)
            {
               *ptr2++ = surf->poles[(j*surf->u_num_poles+i)*3 +k];      
            }
         }
      }
      tan1[0] = tant;
      tan2[0] = tanb;
   }
   if( num > MAXNUM )
   {
      appcurves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num * sizeof
                                    (struct IGRbsp_curve *)));
      if(! appcurves )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      appcurves = &aappcurves[0];
   }
   /* -------------------------------------------
     * TR179801101 Before, only set num item to null
     * but later on, num2 items are used for some things
     * the wrapup routine can core dump when trying to free
     * num2 items, so just clear them all
     */
   {
      int ix = num;
      if (ix < MAXNUM) ix = MAXNUM;

      for(i=0; i < ix; i++)
        appcurves[i] = NULL;
   }

   /* remove all zero rank vectors */
   nint1 = curves[0]->num_poles - curves[0]->order;
   if( 2*nint1 > MAXNUM)
   {
      ranks = (IGRvector *)BSstackalloc((unsigned)(2*nint1 * sizeof(IGRvector)));
      if(!ranks)
      {
         *rc = BSNOSTKMEMORY;
      }
      ranksb = (IGRvector *)&ranks[nint1][0];
   }
   else
   {
      ranks = aranks;
      ranksb = (IGRvector *)&aranks[nint1][0];
   }
   BScvkttol2(curves[0]->order, curves[0]->knots, curves[0]->num_poles, 
              curves[0]->poles, curves[0]->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   
   (void)BSchangepar(rc, BSTOLKNOT, knot_tol);
   if(BSERROR(*rc))
      goto wrapup;   

   /* try to find the two longest rows and rank them...
      then only remove the knots which both rows have zero rank vectors */
   cvi1 = 0;
   cvi2 = 1;
   if( num > 1 )
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
      for(i=1; i< num; i++)
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
         {
            cvi2 = cvi1;
            cvi1 = i;
            sum = sum1;
         }
      }
   }
   /* find the first non-degerate curve 
   for(i=0; i< num; i++)
   {
      BStstcvdegn(curves[i], &degen, rc);
      if( BSERROR(*rc))
         goto wrapup;
      if( ! degen )
         break;
   }  */
   BSrkv_f_kts(curves[cvi1],ranks,rc);
   if(BSERROR(*rc))
      goto wrapup;
   BSrkv_f_kts(curves[cvi2],ranksb,rc);
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSchangepar(rc, BSTOLKNOT, sknot_tol);
   if(BSERROR(*rc))
      goto wrapup;   
   nsubknots = curves[0]->num_knots;
   if( nsubknots > MAXNUM )
   {
      subknots = (IGRdouble *)BSstackalloc((unsigned)( nsubknots * 
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
   count = curves[0]->order;
   for(i=0; i< nint1; i++)
   {
      zero_rank = TRUE;
      for(j=0; j<3; j++)
      {
         if( ranks[i][j] > CLOSETOZERO || ranksb[i][j] > CLOSETOZERO )
         {
            zero_rank = FALSE;
            break;
         }
      }
      if( !zero_rank )
      {
         subknots[count] = curves[0]->knots[curves[0]->order + i];
         count += 1;
      }
   }   
   if( count < curves[0]->num_poles )
   {
      /* we did have some knots with rank vector zero */
      for(i=0; i< curves[0]->order; i++)
      {
         subknots[i] = curves[0]->knots[i];
         subknots[count + i] = curves[0]->knots[curves[0]->num_poles +i];
      }
      if( num > MAXNUM )
      {
         bcurves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num * 
                           sizeof(struct IGRbsp_curve  *)));
         if( !bcurves )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         bcurves = &abcurves[0];
      }   
      n_knots = count + curves[0]->order;
      /* how many curves you can get out of declared memory */
      sizeb = MIN(MAXNUM * MAXNUMS / count,
                  MAXNUMS * (MAXNUM + MAX_ORDER)/ n_knots);
      if( sizeb > 0  )
      {
         if( num < sizeb )
            endb = num;
         else
            endb = sizeb;
         for(i=0; i< endb; i++)
         {
            bcurves[i] = NULL;
            bcurves[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                        (struct IGRbsp_curve )));
            if(!bcurves[i])
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            bcurves[i]->poles = &bpoles[i*count][0];
            bcurves[i]->knots = &bknots[i*n_knots];
            bcurves[i]->weights = NULL;
            bcurves[i]->bdrys = NULL;
            if( rational )
               bcurves[i]->weights = &bweights[i*count];
         }
      }
      if( num > sizeb )
      {
         for(i=sizeb; i< num; i++)
         {
            bcurves[i] = NULL;
            BSstkallocv(rc,bcurves[i],count,rational,n_knots,NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }

      BSbrapproxs(num,curves,count,subknots,temptanl,temptanr,bcurves,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      for(i=0; i< num; i++)
      {
         (void)BScv_copy(rc, bcurves[i], curves[i]);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
      }
   }

   BSdtarducvs(num, curves, same, tan1, tan2, (IGRvector *)tangent, 
               (IGRvector *)tangent, erropt, maxerr, avgerr, &cvind, 
               &par, pt1, &par, pt2, appcurves, rc);
   if(BSERROR(*rc))
      goto wrapup;

   *appsurf = (struct IGRbsp_surface *)BSmalloc((unsigned)( sizeof
                                  (struct IGRbsp_surface )));
   if(! *appsurf )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   /* --------------------------------------------------
   * TR179801101 Clear it otherwise an error return
   * can cause a core dump when memory is freed
   */
   memset(*appsurf,0,sizeof(struct IGRbsp_surface));

   if( option == 2 )
   {
      /* allocate space for the curves */
      num2 = appcurves[0]->num_poles;
      if( option2 == 0 )
      {   
         tan1[0] = tant;
         tan2[0] = tanb;
         n_poles = v_num_poles;
         n_knots = n_poles + v_order;
         size2 = MIN(MAXNUM * MAXNUMS / v_num_poles,
                     MAXNUMS * (MAXNUM + MAX_ORDER) / n_knots);
      }
      else
      {
         tan1[0] = tanl;
         tan2[0] = tanr;
         n_poles = u_num_poles;
         n_knots = n_poles + u_order;
         size2 = MIN(MAXNUM * MAXNUMS / u_num_poles,
                     MAXNUMS * (MAXNUM + MAX_ORDER) / n_knots);
      }
      if( num2 > MAXNUM )
      {
         curves2 = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num2 
                              * sizeof(struct IGRbsp_curve  *)));
         if( !curves2 )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         curves2 = &acurves2[0];
      }   
      if( size2 > 0)
      {
         if( num2 < size2 )
            end2 = num2;
         else
            end2 = size2;
         for(i=0; i< end2; i++)
         {
            curves2[i] = NULL;
            curves2[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                        (struct IGRbsp_curve )));
            if(!curves2[i])
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            curves2[i]->poles = &poles[i*n_poles ][0];
            curves2[i]->knots = &knots[i*n_knots];
            curves2[i]->weights = NULL;
            curves2[i]->bdrys = NULL;
            if( rational )
               curves2[i]->weights = &weights[i*n_poles];
         }
      }
      if( num2 > size2 )
      {
         for(i=size2; i< num2; i++)
         {
            curves2[i] = NULL;
            BSstkallocv(rc,curves2[i],n_poles,rational,n_knots,NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
      for(i=0; i< num2; i++)
      {
         if( option2 == 0 )
         {
            curves2[i]->order = v_order;
            curves2[i]->num_poles = v_num_poles;
            curves2[i]->num_knots = surf->v_num_knots;
            curves2[i]->non_uniform = surf->v_non_uniform;
            curves2[i]->periodic = surf->v_periodic;
            curves2[i]->phy_closed = surf->v_phy_closed;
            for(k=0; k< surf->v_num_knots; k++)
               curves2[i]->knots[k] = surf->v_knots[k];
         }
         else
         {
            curves2[i]->order = u_order;
            curves2[i]->num_poles = u_num_poles;
            curves2[i]->num_knots = surf->u_num_knots;
            curves2[i]->non_uniform = surf->u_non_uniform;
            curves2[i]->periodic = surf->u_periodic;
            curves2[i]->phy_closed = surf->u_phy_closed;
            for(k=0; k< surf->u_num_knots; k++)
               curves2[i]->knots[k] = surf->u_knots[k];
         }
         curves2[i]->num_boundaries = 0;
         curves2[i]->bdrys = NULL;
         curves2[i]->planar = surf->planar;
         curves2[i]->rational = rational;
         if( rational)
            ptr1 = curves2[i]->weights;
         ptr2 = curves2[i]->poles;
         for(j=0; j< n_poles; j++)
         {
            if( rational)
               *ptr1++ = appcurves[j]->weights[i];
            for(k=0; k<3; k++)
            {
               *ptr2++ = appcurves[j]->poles[i*3 +k];      
            }
         }
      }
      if( option2 == 0 )
      {
         /* copy the knots into the output surface */
         (*appsurf)->u_knots = (IGRdouble *)BSmalloc((unsigned)( 
                           appcurves[0]->num_knots * sizeof(IGRdouble )));
         if(! (*appsurf)->u_knots)
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }
         for(i=0; i< appcurves[0]->num_knots; i++)
         {
            (*appsurf)->u_knots[i] = appcurves[0]->knots[i];
         }
         (*appsurf)->u_non_uniform = appcurves[0]->non_uniform;
         (*appsurf)->u_phy_closed = appcurves[0]->phy_closed;
      }
      else
      {
         /* copy the knots into the output surface */
         (*appsurf)->v_knots = (IGRdouble *)BSmalloc((unsigned)( 
                           appcurves[0]->num_knots * sizeof(IGRdouble )));
         if(! (*appsurf)->v_knots)
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }
         for(i=0; i< appcurves[0]->num_knots; i++)
         {
            (*appsurf)->v_knots[i] = appcurves[0]->knots[i];
         }
         (*appsurf)->v_non_uniform = appcurves[0]->non_uniform;
         (*appsurf)->v_phy_closed = appcurves[0]->phy_closed;
      }
      /* free appcurves */
      for(i=0; i< num; i++)
      {
         if( appcurves[i] )
         {
            (void)BSfreecv(rc, appcurves[i]);
            if(BSERROR(*rc))
               goto wrapup;
            appcurves[i] = NULL;
         }
      }      
      if( num > MAXNUM && num2 > num)
      {
         BSstackdealloc((char *)appcurves);
         appcurves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( 
                                  num2 * sizeof(struct IGRbsp_curve *)));
         if(! appcurves )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         if( num2 > MAXNUM )
         {
            appcurves = (struct IGRbsp_curve **)BSstackalloc((unsigned)( 
                                 num2 * sizeof(struct IGRbsp_curve *)));
            if(! appcurves )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
      }
         
      nint2 = curves2[0]->num_poles - curves2[0]->order;
      if( 2*nint2 > MAXNUM)
      {
         ranks2 = (IGRvector *)BSstackalloc((unsigned)(2* nint2 * 
                                                   sizeof(IGRvector)));
         if(!ranks2)
         {
            *rc = BSNOSTKMEMORY;
         }
         ranks2b = (IGRvector *)&ranks2[nint2][0];
      }
      else
      {
         ranks2 = aranks2;
         ranks2b = (IGRvector *)&aranks2[nint2][0];
      }
      BScvkttol2(curves2[0]->order, curves2[0]->knots, 
                 curves2[0]->num_poles, curves2[0]->poles, 
                 curves2[0]->weights, &knot_tol, rc);
      if(BSERROR(*rc))
         goto wrapup;
      (void)BSchangepar(rc, BSTOLKNOT, knot_tol);
      if(BSERROR(*rc))
         goto wrapup;   
      /* try to find the two longest rows and rank them...
      then only remove the knots which both rows have zero rank vectors */
      cvi1 = 0;
      cvi2 = 1;
      if( num2 > 1 )
      {
         delta = curves2[0]->num_poles / 20 + 1;
         sum = 0;
         for(j=0; j< curves2[0]->num_poles -1; j+=delta)
         {
            for(k=0; k<3; k++)
            {
               sum += fabs(curves2[0]->poles[j*3+k] - 
                           curves2[0]->poles[(j+1)*3+k] );
            }
         }
         for(i=1; i< num2; i++)
         {
            sum1 = 0;
            for(j=0; j< curves2[i]->num_poles -1; j+=delta)
            {
               for(k=0; k<3; k++)
               {
                  sum1 += fabs(curves2[i]->poles[j*3+k] - 
                              curves2[i]->poles[(j+1)*3+k] );
               }
            }
            if( sum1 > sum )
            {
               cvi2 = cvi1;
               cvi1 = i;
               sum = sum1;
            }
         }
      }
      /* find the first non-degenerate curve 
      for(i=0; i< num2; i++)
      {
         BStstcvdegn(curves2[i], &degen, rc);
         if( BSERROR(*rc))
            goto wrapup;
         if( ! degen )
            break;
      }*/  
      BSrkv_f_kts(curves2[cvi1],ranks2,rc);
      if(BSERROR(*rc))
         goto wrapup;
      BSrkv_f_kts(curves2[cvi2],ranks2b,rc);
      if(BSERROR(*rc))
         goto wrapup;
      (void)BSchangepar(rc, BSTOLKNOT, sknot_tol);
      if(BSERROR(*rc))
         goto wrapup;   
      nsubknots2 = curves2[0]->num_knots;
      if( nsubknots2  > MAXNUM )
      {
         subknots2 = (IGRdouble *)BSstackalloc((unsigned)( 
                               nsubknots2 * sizeof(IGRdouble )));
         if(!subknots2)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         subknots2 = &asubknots2[0];
      }
      count = curves2[0]->order;
      for(i=0; i< nint2; i++)
      {
         zero_rank = TRUE;
         for(j=0; j<3; j++)
         {
            if( ranks2[i][j] > CLOSETOZERO || ranks2b[i][j] > CLOSETOZERO)
            {
               zero_rank = FALSE;
               break;
            }
         }
         if( !zero_rank )
         {
            subknots2[count] = curves2[0]->knots[curves2[0]->order + i];
            count += 1;
         }
      }   

   
      if( count < curves2[0]->num_poles )
      {
         /* we did have some knots with rank vector zero */

         for(i=0; i< curves2[0]->order; i++)
         {
            subknots2[i] = curves2[0]->knots[i];
            subknots2[count + i] = curves2[0]->knots[curves2[0]->num_poles +i];
         }
         if( num2 > MAXNUM )
         {
            bcurves2 = (struct IGRbsp_curve **)BSstackalloc((unsigned)( num2 * 
                              sizeof(struct IGRbsp_curve  *)));
            if( !bcurves2 )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
         else
         {
            bcurves2 = &abcurves2[0];
         }   
         n_knots = count + curves2[0]->order;
         /* how many curves you can get out of declared memory */
         sizeb2 = MIN(MAXNUM * MAXNUMS / count,
                      MAXNUMS * (MAXNUM + MAX_ORDER) / n_knots);
         if( sizeb2 > 0  )
         {
            if( num2 < sizeb2 )
               endb2 = num2;
            else
               endb2 = sizeb2;
            for(i=0; i< endb2; i++)
            {
               bcurves2[i] = NULL;
               bcurves2[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( 
                                            sizeof(struct IGRbsp_curve )));
               if(!bcurves2[i])
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               bcurves2[i]->poles = &bpoles[i*count][0];
               bcurves2[i]->knots = &bknots[i*n_knots];
               bcurves2[i]->weights = NULL;
               bcurves2[i]->bdrys = NULL;
               if( rational )
                  bcurves2[i]->weights = &bweights[i*count];
            }
         }
         if( num2 > sizeb2 )
         {
            for(i=sizeb2; i< num2; i++)
            {
               bcurves2[i] = NULL;
               BSstkallocv(rc,bcurves2[i],count,rational,n_knots,NULL);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
            }
         }
         BSbrapproxs(num2,curves2,count,subknots2,temptanl,temptanr,
                     bcurves2,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         for(i=0; i< num2; i++)
         {
            (void)BScv_copy(rc, bcurves2[i], curves2[i]);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }

      BSdtarducvs(num2, curves2, same, tan1, tan2, (IGRvector *)tangent, 
                  (IGRvector *)tangent, erropt, &max, &avg, &cvind, &par,
                  pt3, &par, pt4, appcurves, rc);
      if(BSERROR(*rc))
         goto wrapup;
      if( option2 == 0 )
      {
         (*appsurf)->u_num_poles = num2;
         (*appsurf)->v_num_poles = appcurves[0]->num_poles;
      }
      else
      {
         (*appsurf)->u_num_poles = appcurves[0]->num_poles;
         (*appsurf)->v_num_poles = num2;
      }
   }
   else
   {
      if( option == 0 )
      {
         (*appsurf)->u_num_poles = appcurves[0]->num_poles;
         (*appsurf)->v_num_poles = num;
      }
      else
      {
         (*appsurf)->u_num_poles = num;
         (*appsurf)->v_num_poles = appcurves[0]->num_poles;
      }
   }                  
   (*appsurf)->poles = (IGRdouble *)BSmalloc((unsigned)((*appsurf)->u_num_poles
                          * (*appsurf)->v_num_poles * 3 * sizeof(IGRdouble )));
   if(! (*appsurf)->poles )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   if( rational)
   {
      (*appsurf)->weights = (IGRdouble *)BSmalloc((unsigned)(
        (*appsurf)->u_num_poles * (*appsurf)->v_num_poles *sizeof(IGRdouble )));
      if(! (*appsurf)->weights )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
   }
   else
   {
      (*appsurf)->weights = NULL;
   }

   /* move appcurves into the output appsurf */
   if( option == 0 || (option == 2 && option2 == 1 ) )
   {
      ptr1 = (*appsurf)->weights;
      ptr3 = (*appsurf)->poles;
      for(i=0; i< (*appsurf)->v_num_poles; i++)
      {
         ptr2 = appcurves[i]->weights;
         ptr4 = appcurves[i]->poles;
         for(j=0; j< (*appsurf)->u_num_poles; j++)
         {
            if( rational )
            {
               *ptr1++ = *ptr2++;
            }
            for(k=0; k<3; k++)
            {
               *ptr3++ = *ptr4++;
            }
         }
      }
      (*appsurf)->u_knots = (IGRdouble *)BSmalloc((unsigned)( 
                           appcurves[0]->num_knots * sizeof(IGRdouble )));
      if(! (*appsurf)->u_knots )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      ptr1 = (*appsurf)->u_knots;
      ptr2 = appcurves[0]->knots;
      for(i=0; i< appcurves[0]->num_knots; i++)
      {
         *ptr1++ = *ptr2++;
      }
      if(option == 0 )
      {
         (*appsurf)->v_knots = (IGRdouble *)BSmalloc((unsigned)( 
                  ( (*appsurf)->v_num_poles + v_order ) * sizeof(IGRdouble )));
         if(! (*appsurf)->v_knots )
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }
         ptr1 = (*appsurf)->v_knots;
         ptr2 = surf->v_knots;        
         for(i=0; i< surf->v_num_knots; i++)
         {
            *ptr1++ = *ptr2++;
         }
      }
      (*appsurf)->u_order = u_order;
      (*appsurf)->v_order = v_order;
      (*appsurf)->u_periodic = appcurves[0]->periodic;
      (*appsurf)->v_periodic = surf->v_periodic;
      (*appsurf)->u_non_uniform = appcurves[0]->non_uniform;
      (*appsurf)->v_non_uniform = surf->v_non_uniform;
      (*appsurf)->u_num_knots = appcurves[0]->num_knots;
      (*appsurf)->v_num_knots = (*appsurf)->v_num_poles + v_order;
      (*appsurf)->rational = rational;
      (*appsurf)->planar = surf->planar;
      (*appsurf)->u_phy_closed = appcurves[0]->phy_closed;
      (*appsurf)->v_phy_closed = surf->v_phy_closed;
      (*appsurf)->num_boundaries = surf->num_boundaries;
      (*appsurf)->bdrys = NULL;
      (*appsurf)->pos_orient = TRUE;
      (*appsurf)->on_off = TRUE;
   }
   else
   {
      /* option = 1 or 2 */

      for(i=0; i< (*appsurf)->u_num_poles; i++)
      {
         ptr1 = appcurves[i]->weights;
         ptr2 = appcurves[i]->poles;
         for(j=0; j< (*appsurf)->v_num_poles; j++)
         {
            if( rational )
            {
               (*appsurf)->weights[j* (*appsurf)->u_num_poles +i] = *ptr1++;
            }
            for(k=0; k<3; k++)
            {
               (*appsurf)->poles[(j* (*appsurf)->u_num_poles+i)*3+k] = *ptr2++;
            }
         }
      }
      (*appsurf)->v_knots = (IGRdouble *)BSmalloc((unsigned)( 
                     ((*appsurf)->v_num_poles + v_order )*sizeof(IGRdouble)));
      if(! (*appsurf)->v_knots )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      ptr1 = (*appsurf)->v_knots;
      ptr2 = appcurves[0]->knots;
      for(i=0; i< appcurves[0]->num_knots; i++)
      {
         *ptr1++ = *ptr2++;
      }
      if( option == 1 )
      {
         (*appsurf)->u_knots = (IGRdouble *)BSmalloc((unsigned)( 
                            surf->u_num_knots * sizeof(IGRdouble )));
         if(! (*appsurf)->u_knots )
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }
         ptr1 = (*appsurf)->u_knots;
         ptr2 = surf->u_knots;
         for(i=0; i< surf->u_num_knots; i++)
         {
            *ptr1++ = *ptr2++;
         }
      }
      (*appsurf)->u_order = u_order;
      (*appsurf)->v_order = v_order;
      (*appsurf)->u_num_knots = (*appsurf)->u_num_poles + u_order;
      (*appsurf)->v_num_knots = appcurves[0]->num_knots;
      (*appsurf)->u_periodic = FALSE;
      (*appsurf)->v_periodic = FALSE;
      (*appsurf)->rational = rational;
      (*appsurf)->v_non_uniform = appcurves[0]->non_uniform;
      (*appsurf)->planar = surf->planar;
      if( option == 1 )
      {
         (*appsurf)->u_non_uniform = surf->u_non_uniform;
         (*appsurf)->u_phy_closed = surf->u_phy_closed;
      }
      (*appsurf)->v_phy_closed = appcurves[0]->phy_closed;
      (*appsurf)->num_boundaries = 0;
      (*appsurf)->pos_orient = TRUE;
      (*appsurf)->on_off = TRUE;
      (*appsurf)->bdrys = NULL;
   }      
   if( erropt )
   {
      /* find the output error data */
      
      
      if( option == 2 && max > *maxerr )
      {
         for(i=0; i< 3; i++)
         {
            pt1[i] = pt3[i];
            pt2[i] = pt4[i];
         }
         *avgerr += avg;
         *avgerr /= 2;
      }
      (void)BSmdistptsf(rc, surf, pt1, &uvpar[0], &uvpar[1], pt, &dist);
      if(BSERROR(*rc))
        goto wrapup;
      (void)BSmdistptsf(rc, *appsurf, pt2, &auvpar[0], &auvpar[1], apt, 
                        &dist);
      if(BSERROR(*rc))
         goto wrapup;
      *maxerr = BSdistptpt(rc, pt, apt);
   }
         
   wrapup:
   if( BSERROR(*rc))
      (void)BSchangepar(&rc2, BSTOLKNOT, sknot_tol);

   if( option == 2 && hchrdht_tol > 0 )
   {
      (void)BSchangepar(&rc2, BSTOLCHRDHT, chrdht_tol);
      if(BSERROR(rc2) && BSOKAY(*rc))
         *rc = rc2;
   }
   if( option == 2)
   {
      if( bcurves2 )
      {
         if( num2 > sizeb2 )
         {
            for(i=num2-1; i>=sizeb2; i--)
            {
               if( bcurves2[i])
               {
                  BSstkfreecv(&rc2,bcurves2[i]);
                  if(BSOKAY(*rc) && BSERROR(rc2 ) )
                     *rc = rc2;
               }
            }
         }
         if( sizeb2 > 0  )
         {
            for(i=endb2-1; i>=0; i--)
            {
               if(bcurves2[i] )
                  BSstackdealloc((char *) bcurves2[i]);
            }
         }
         if( num2 > MAXNUM )
         {
            BSstackdealloc((char *)bcurves2 );
         }
      }
      if( nsubknots2 > MAXNUM && subknots2)
         BSstackdealloc((char *)subknots2);
      if( 2*nint2 > MAXNUM && ranks2 && ranks2 != aranks2)
         BSstackdealloc((char *)ranks2);      
      if( appcurves )
      {
         for(i=0; i<num2; i++)
         {
            if( appcurves[i] )
            {
               (void)BSfreecv(&rc2, appcurves[i]);
               if(BSERROR(rc2) && BSOKAY(*rc) )
                  *rc = rc2;
            }
         }
         if( num2 > MAXNUM )
         {
            BSstackdealloc((char *)appcurves);
         }
         else
         {
            if( num > MAXNUM )
               BSstackdealloc((char *)appcurves);
         }
      }
   }      
   else
   {
      if( appcurves )
      {
         for(i=0; i<num; i++)
         {
            if( appcurves[i] )
            {
               (void)BSfreecv(&rc2, appcurves[i]);
               if(BSERROR(rc2) && BSOKAY(*rc) )
                  *rc = rc2;
            }
         }
         if( num > MAXNUM )
            BSstackdealloc((char *)appcurves);
      }
   }      
   if( option == 2 && curves2 )
   {
      if( num2 > size2 )
      {
         for(i=num2-1; i>=size2; i--)
         {
            if( curves2[i] )
               BSstkfreecv(&rc2,curves2[i]);
               if( BSERROR(rc2) && BSOKAY(*rc))
                   *rc = rc2;
         }
      }
      if( size2 > 0 )
      {
         for(i=end2-1; i>= 0; i--)
         {
            if( curves2[i])
               BSstackdealloc((char *)curves2[i] );
         }
      }
      if( num2 > MAXNUM )
      {
         BSstackdealloc((char *)curves2 );
      }   
   }

   if( bcurves )
   {
      if( num > sizeb )
      {
         for(i=num -1; i>=sizeb; i--)
         {
            if( bcurves[i])
            {
               BSstkfreecv(&rc2,bcurves[i]);
               if(BSOKAY(*rc) && BSERROR(rc2 ) )
                  *rc = rc2;
            }
         }
      }
      if( sizeb > 0  )
      {
         for(i=endb -1; i>=0; i--)
         {
            if(bcurves[i] )
               BSstackdealloc((char *) bcurves[i]);
         }
      }
      if( num > MAXNUM )
      {
         BSstackdealloc((char *)bcurves );
      }
   }
   if( nsubknots > MAXNUM && subknots)
      BSstackdealloc((char *)subknots);
   if( 2*nint1 > MAXNUM && ranks && ranks != aranks)
      BSstackdealloc((char *)ranks);      

   if( curves )
   {
      if( num > size1)
      {
         for(i=num-1; i>=size1; i--)
         {
            if( curves[i] )
            {
               BSstkfreecv(&rc2,curves[i]);
               if( BSERROR(rc2) && BSOKAY(*rc))
                   *rc = rc2;
            }
         }
      }
      if( size1 > 0 )
      {
         for(i=end1-1; i>= 0; i--)
         {
            if( curves[i] )
               BSstackdealloc((char *)curves[i] );
         }
      }   
      if( num > MAXNUM )
      {
         BSstackdealloc((char *)curves );
      }
   }
   
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSdta_rdusf");
   return;
   }
}   
