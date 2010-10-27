/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSnrm_2_cvs

Abstract
    This routine finds the approximate maximum and average distance 
between two curves.  

Synopsis
    void BSnrm_2_cvs(cv1, cv2, maxerr, avgerr, par1, pt1, par2, pt2,
                     rc) 
    struct IGRbsp_curve *cv1,*cv2
    IGRdouble           *maxerr, *avgerr
    IGRdouble           *par1, *par2
    IGRpoint            pt1, pt2
    BSrc                *rc

Description
    Input for this routine is: 
    cv1                 b-spline curve
    cv2                 b-spline curve, but cv2 knots is a subset of cv1
                        knots

    Input/Output to this routine is:
    avgerr              if set to -3.0, then maxerr contains our tolerance
                        used to break/quit if error gets larger than
    maxerr              tolerance, which our error can't be larger than
        
    Output to this routine is:
    maxerr              the approximate maximum distance between curves
    avgerr              the approximate average error between curves
    par1, par2          parameters on cv1 and cv2 at maximum distance
    pt1, pt2            points at maximum distance
    rc                  BSSUCC is returned if successful
    

Return Values
    None

Notes
    Does not work for periodic curves if they are sent without
converting to multiple end knots.

Index
    md

Keywords

History
    S.G. Catron   07/27/87  : Creation date.
    S.G. Catron   02/04/88  : Before calling BScvkttol2 set the
                              weights to NULL if cv1 is non-rational.
    S.G. Catron   02/08/88  : Changed calculation of distance error.  Now
                              we find node values of one curve and call
                              BSperpa to find parameter on other curve, 
                              then calculate distance between two points.
                              Deleted section about neighborhood and 
                              iterating to find a better error.
    S.G. Catron   03/11/88  : Changed argument list to pass in node values
                              for first curve.  Then also to extract the 
                              correct span of cv2 before calling BSperpa.
                              Also based upon number of poles, to skip 
                              over some of the node values.  For big 
                              curves it's not necessary to check so many 
                              points.
    S.G. Catron   06/23/88  : If d1 > toobigdist, and nodevals[i] is in 
                              the middle of the span, test the d1 against
                              *dist anyway.  Also if the second try to 
                              find a span does not work and the first try 
                              was successful, test the d1 against *dist 
                              anyway.
    S.G. Catron   08/09/88  : Added arguments to output the maximum error,
                              the average error and the parameter values 
                              and points on each curve at maxerr.
    K.Krishna     08/27/88  : Changed the algorithm idea.  Instead of
                              calling BSperpa for the node values, 
                              pick poles with the maximum difference
                              at several sections of the curve and then
                              call BSperpa at the corresponding node
                              points.  Also call BSperpa for the cusp 
                              points.
    S.G. Catron    11/03/88 : Moved call to BScvkttol2 out of loop.
    S.G. Catron    07/11/89 : Changed "const" to "constt" because it is a
                              reserve word on some systems.
    D. Breden      12/16/89 : Initialize boundaries in static curve.
    S.G. Catron    11/02/90 : Check to see if the index found for polygon
                              happens to correspond to a multiple knot,
                              and if so...set index = index-1.
    S.G. Catron    06/05/91 : Array knots was not big enough and arguments
                              planar and closed were not set before 
                              calling BSextrcvspn.
    S.G. Catron    06/18/91 : Need to intialize output errors.  Also there
                              was a problem with choosing the wrong 
                              BSperpa answer for same node_pt.
    S.G. Catron    11/26/91 : There was a problem with static routine
                              distBSnrm_2_cvs when cv2 was a bezier curve.
                              There's no need to look for another span if
                              BSperpa doesn't find a solution.  Also in
                              main routine, for order 2, the index was
                              not right.  It did not need to be adjusted.
    S.G. Catron    02/25/92 : Changed to send in the first curve to static
                              routine distBSnrm_2_cvs.  Had a problem with
                              reduced curve having a zinger at a node 
                              value, so if you use the zinger point to 
                              find a minimum distance point to cv1, then
                              the distance will be greater .
                              Also in distBSnrm_2_cvs, if BSperpa doesn't
                              find anything after trying again, then
                              call BSmdstptscv.  Fixes TR#92n1163.
    S.G. Catron    01/24/94 : Modified to use index as is if it's on a
                              multiple knot and to also use(index-1).
                              This fixes a problem from NC.(dta_rdusf.d18)
    S.G. Catron    01/25/00 : VDS 179900956, JTS 10197 - dta_rducv.d40(bad 
                             parameterization), dta_rducv.d41(nice).  Modified to
                             alloc input of the tolerance used in data reduction.
                             That way we can break out if it finds an error 
			     greater than our tolerance.  Also modified to check
			     if pole difference is tooo large, indicating we might
			     have zingers.  We will shrink the delta to order.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsstackalloc.h"
#endif
#define  BSVOID
#include <math.h>

#define CLOSE_TO_ZERO 1.0e-11
#define MAXNUM  100

static void distBSnrm_2_cvs(
IGRint              span,
struct IGRbsp_curve *cv2,
IGRpoint            node_pt,
IGRdouble           nodval,
IGRdouble           toobigdist,
IGRdouble           knot_tol,
IGRint              *sum,
IGRdouble           *avgerr,
IGRdouble           *maxerr,
IGRdouble           *par1,
IGRdouble           	 *par2,
IGRpoint            pt1,
IGRpoint	 pt2,
BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bsextrcvspn.h"
#include "bsperpa.h"
#include "bscveval.h"
#include "bsdistptpts.h"
#include "bsmdstptscv.h"
#endif 


   IGRboolean planar=TRUE, closed=TRUE,
              tryagain, on_cv;
   struct IGRbsp_curve bez;
   IGRpoint            poles[MAX_ORDER],
                       cv_pt2;
   IGRdouble           weights[MAX_ORDER],
                       knots[2*MAX_ORDER];
   IGRint              savenum_par, side,
                       num_derv, numb=1,
                       k, l, tryspan;
   IGRshort num_par;
   IGRdouble           saved1=0, det, d1, d2;
   IGRdouble           par;

   *rc = BSSUCC;

   num_derv = 0;
   bez.poles = &poles[0][0];
   bez.knots = &knots[0];
   if( cv2->rational )
      bez.weights = &weights[0];
   else
      bez.weights = NULL;
   bez.bdrys = NULL;
   d1 = 0.0;
        
   (void)BSextrcvspn(rc, &span, cv2, &bez, &planar, &closed);
   if(BSERROR(*rc))
      goto wrapup;
   tryagain = TRUE;
   
   (void)BSperpa(rc, &bez, node_pt, node_pt, &num_par, &par,&side);
   if (BSERROR(*rc))
      goto wrapup;
   if( cv2->num_poles == cv2->order && num_par == 0)
   {
      /* it's bezier already and trying to find another span won't help ,
         the minimum distance must be to endpoints */
      for(k=0; k<3; k++)
      {
         if(cv2->rational )
         {
            pt1[k] = cv2->poles[k]/cv2->weights[0];
            pt2[k] = cv2->poles[(cv2->num_poles-1)*3+k] /
                     cv2->weights[cv2->num_poles-1];
         }
         else
         {
            pt1[k] = cv2->poles[k];
            pt2[k] = cv2->poles[(cv2->num_poles-1)*3+k];
         }
      }
      d1 = BSdistptpts(rc, node_pt, pt1);      
      d2 = BSdistptpts(rc, node_pt, pt2);      
      if( d2 < d1)
      {
         d1 = d2;
         par = cv2->knots[cv2->num_poles];
         for(k=0; k<3; k++)
            pt1[k] = pt2[k];
      }
      else
         par = cv2->knots[cv2->order-1];

      tryagain = FALSE;
      *avgerr += d1;
      *sum += 1;
      if ( d1 > *maxerr )
      {
         *maxerr = d1;
         *par1 = nodval;
         *par2 = par;
         for(k=0;k<3;k++)
         {
            pt2[k] = pt1[k];
            pt1[k] = node_pt[k];
         }
      } 
      goto wrapup;
   }
   savenum_par = num_par;
   if (num_par == 1)
   {
      BScveval(&bez, par, num_derv, (IGRpoint *) &cv_pt2, rc);
      if (BSERROR(*rc))
         goto wrapup;
      d1 = BSdistptpts(rc, node_pt, cv_pt2);
      if( d1 < toobigdist)
      {
         tryagain = FALSE;
         *avgerr += d1;
         *sum += 1;
         if ( d1 > *maxerr )
         {
            *maxerr = d1;
            *par1 = nodval;
            *par2 = par;
            for(k=0;k<3;k++)
            {
               pt1[k] = node_pt[k];
               pt2[k] = cv_pt2[k];
            }
         }
      }
      else
      {
         /* if node value is close to span boundaries, then we need to
            check neighbor spans for answer */
         det = (cv2->knots[span+1] - cv2->knots[span] ) / 10;
         if(nodval - cv2->knots[span] > det || 
             cv2->knots[span+1] - nodval > det )
         {
            *avgerr += d1;
            *sum += 1;
            tryagain = FALSE;
            if( d1 > *maxerr )
            {
               *par1 = nodval;
               *par2 = par;
               for(k=0; k<3; k++)
               {
                  pt1[k] = node_pt[k];
                  pt2[k] = cv_pt2[k];
               }
               *maxerr = d1;
            }
         }
         else
         {
            saved1 = d1;
         }
      }
   }
   if( tryagain )
   {
      /* didn't find a normal; try next or previous span,  whichever
         is closer to the nodval
       */
      if( nodval - cv2->knots[span] < cv2->knots[span+1] - nodval )
      {
         tryspan = 0;
         for(l=span-1; l>=cv2->order-1; l--)
         {
            if( fabs( cv2->knots[l] - cv2->knots[l+1] ) > knot_tol )
            {
               tryspan = l;
               break;
            }
         }
      }
      else
      {
         tryspan = 0;
         for( l=span+1; l<cv2->num_poles; l++ )
         {
            if( fabs( cv2->knots[l] - cv2->knots[l+1] ) > knot_tol )
            {
               tryspan = l;
               break;
            }
         }
      }
      if(tryspan != 0)
      {
         (void)BSextrcvspn(rc, &tryspan, cv2, &bez, &planar, &closed);
         if(BSERROR(*rc))
            goto wrapup;
         (void)BSperpa(rc, &bez, node_pt, node_pt, &num_par, &par, 
                       &side);
         if (BSERROR(*rc))
            goto wrapup;
         if (num_par == 1)
         {
            BScveval(&bez, par, num_derv, (IGRpoint *) &cv_pt2, rc);
            if (BSERROR(*rc))
               goto wrapup;
            d1 = BSdistptpts(rc, node_pt, cv_pt2);
            *avgerr += d1;
            *sum += 1;
            if ( d1 > *maxerr )
            {
               *maxerr = d1;
               *par1 = nodval;
               *par2 = par;
               for(k=0;k<3;k++)
               {
                  pt1[k] = node_pt[k];
                  pt2[k] = cv_pt2[k];
               }
            }
         }
         else
         {
            /* BSperpa found no solution, 
               so use previous one found */
            if( savenum_par == 1 )
            {
               *avgerr += d1;
               *sum += 1;
               if( saved1 > *maxerr )
               {
                  *par1 = nodval;
                  *par2 = par;
                  for(k=0; k<3; k++)
                  {
                     pt1[k] = node_pt[k];
                     pt2[k] = cv_pt2[k];
                  }
                  *maxerr = saved1;
               }
            }
            else
            {
               BSmdstptscv(numb, (IGRpoint *) node_pt, cv2, &par,
                           (IGRpoint *) &cv_pt2, &d1, &on_cv, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               /* because other distances are the squared distances */
               d1 = d1 * d1;
               *avgerr += d1;
               *sum += 1;
               if ( d1 > *maxerr )
               {
                  *maxerr = d1;
                  *par1 = nodval;
                  *par2 = par;
                  for(k=0;k<3;k++)
                  {
                     pt2[k] = cv_pt2[k];
                     pt1[k] = node_pt[k];
                  }
               } 
            }
         }  /* else num_par == 0 */
      }  /* tryagain != 0  */
   } 
   wrapup:
   return;
}


void BSnrm_2_cvs(
struct IGRbsp_curve *cv1,
 struct IGRbsp_curve 	*cv2,
IGRdouble           *maxerr,
 IGRdouble           	 *avgerr,
IGRdouble           *par1,
IGRpoint            pt1,
 IGRdouble           	 *par2,
 IGRpoint	 pt2,
BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscveval.h"
#include "bsadd_kts.h"
#include "bsfndcvcsp.h"
#include "bscvkttol2.h"
#include "bsfindmkts.h"
#endif 

   IGRdouble knot_tol;
   struct IGRbsp_curve bez;
   IGRpoint poles[MAX_ORDER];
   IGRdouble knots[MAX_ORDER + MAX_ORDER];
   IGRdouble weights[MAX_ORDER];
   IGRint span, npars, pindex=-1;
   struct IGRbsp_curve ocurve;
   IGRboolean tmulalloc=FALSE, indalloc=FALSE,
              parsalloc = FALSE, mul;
   IGRpoint opoles[MAXNUM];
   IGRdouble oweights[MAXNUM], *tmul=NULL,
             atmul[MAXNUM],
             oknots[MAXNUM + MAX_ORDER];
   IGRint i,j,imax,ii,k, index=0, num_derv,
          num, j_delta, sum, constt,
          *ind=NULL, aind[MAXNUM];
   IGRdouble max, temp, tempw, temp1[3], temp2[3], nodval, 
             *pars=NULL, apars[MAXNUM],chrdht_tol, toobigdist;
   IGRdouble max_err, maxtol;
   IGRpoint  node_pt;
   IGRboolean checktol=FALSE;

   *rc = BSSUCC;
   
   BSEXTRACTPAR(rc, BSTOLCHRDHT, chrdht_tol);

   /* if avgerr == -3.0, then we want to break out
      of checking when our maximum error is larger than
      given tolerance */
   if( *avgerr == -3.0 )
   {
      checktol = TRUE;
      /* we use the squared tolerance, because we're calculating
         squared distances */
      maxtol = *maxerr * *maxerr;
   }

   /* initialize output, because if maxerr is never bigger than tolerance
      "CLOSE_TO_ZERO", then the  output doesn't get set */
   *maxerr = 0.0;
   *avgerr = 0.0;
   *par1 = 0.0;
   *par2 = 0.0;   
   for(i=0; i<3; i++)
   {
      if(cv1->rational )
         pt1[i] = cv1->poles[i]/cv1->weights[0];
      else
         pt1[i] = cv1->poles[i];
      if(cv2->rational )
         pt2[i] = cv2->poles[i]/cv2->weights[0];
      else
         pt2[i] = cv2->poles[i];
   }
   toobigdist = chrdht_tol * 5;  
   bez.poles = &poles[0][0];
   bez.knots = &knots[0];
   if( cv2->rational )
      bez.weights = &weights[0];
   else
      bez.weights = NULL;
   if( !cv2->rational)
      cv2->weights = NULL;
   bez.bdrys = NULL;

   ocurve.weights = NULL;
   ocurve.bdrys = NULL;
   if( cv1->num_poles > MAXNUM )
   {
      ocurve.poles = (IGRdouble *)BSstackalloc((unsigned)( 
                       cv1->num_poles * sizeof(IGRpoint)));
      if(!ocurve.poles )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      if( cv1->rational )
      {
         ocurve.weights = (IGRdouble *)BSstackalloc((unsigned)( 
                          cv1->num_poles * sizeof(IGRdouble)));
         if(!ocurve.weights )
         { 
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      ocurve.knots = (IGRdouble *)BSstackalloc((unsigned)( 
                       cv1->num_knots * sizeof(IGRdouble)));
      if(!ocurve.knots )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      ocurve.poles = &opoles[0][0];
      ocurve.knots = &oknots[0];
      if( cv1->rational )
         ocurve.weights = &oweights[0];
   }

   BSadd_kts(cv2, cv1->num_poles, cv1->knots, &ocurve, rc);
   if (BSERROR(*rc))
       goto wrapup;
   

   *maxerr = 0.0;
   num_derv = 0;
   BScvkttol2(cv2->order, cv2->knots, cv2->num_poles, cv2->poles, 
              cv2->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   /* constants 15 and 12 were found by trial and error */
   if (cv1->num_poles < 15)
      j_delta = 1;
   else
      j_delta = cv1->num_poles/12; 
   if( cv1->num_poles > MAXNUM)
   {
      tmul = (IGRdouble *)BSstackalloc((unsigned)( cv1->num_poles *
                                  sizeof(IGRdouble )));
      if(! tmul )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      tmulalloc = TRUE;
      ind = (IGRint *)BSstackalloc((unsigned)( cv1->num_poles * 
                                             sizeof(IGRint )));
      if(!ind )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      indalloc = TRUE;
   }
   else
   {
      tmul = atmul;
      ind = aind;
   }
   (void)BSfindmkts(rc, &cv1->order, &cv1->num_poles, cv1->knots, 
                    &knot_tol, &num, tmul, ind);
   if(BSERROR(*rc))
      goto wrapup;

   *avgerr = 0.0;
   *par1 = 0.0;
   *par2 = 0.0;   
   sum = 0;
   span = cv2->order -1;
   for (j=1; j< cv1->num_poles-1; j += j_delta)
   {
      imax = MIN( (j+j_delta), cv1->num_poles );
      max_err = 0.0;

      for (i=j; i< imax; i++)
      {   
         max = 0.0;
         constt = i * 3;
         for (k=0; k<3; k++)
         {   
            if (cv1->rational)
               temp1[k] = cv1->poles[constt+k]/cv1->weights[i];
            else
               temp1[k] = cv1->poles[constt+k];

            if (ocurve.rational)
               temp2[k] = ocurve.poles[constt+k]/ocurve.weights[i];
            else
               temp2[k] = ocurve.poles[constt+k];

            temp = fabs(temp1[k] - temp2[k]);
            if (temp > max)    
               max = temp;
         }
         if( cv1->rational && ocurve.rational)
         {
            tempw = fabs(cv1->weights[i] - ocurve.weights[i]);
            if( tempw > max)
               max = tempw;
         }

         if (max > max_err)
         {
            max_err = max;
            index = i;
         }
      }
      /* if max_err is toooo large, then we are likely to have zingers
         we need to decrease our delta */
      if( j_delta > cv1->order &&  max_err > toobigdist * 10.0 )   
      {
         j_delta = cv1->order;
         j = 1;
         continue;
      }

      if (max_err > CLOSE_TO_ZERO)
      {
         nodval = 0.0;
         for (i=1; i< cv1->order; i++)
         {
            nodval += cv1->knots[index+i]; 
         }
         nodval /= (cv1->order - 1);
  
         BScveval(&ocurve, nodval, num_derv, (IGRpoint *) &node_pt, rc);
         if (BSERROR(*rc))
            goto wrapup;

         /** needs some tuning of the indices **/
         for (i=span; i<= cv1->num_poles; i++)
         {
            if ( nodval <= cv1->knots[i+1] && nodval > cv1->knots[i] &&
                 fabs(cv1->knots[i] - cv1->knots[i+1]) > knot_tol )
            {
               span = i;
               break;
            }
         }
         /* 02/25/92 changed to send in the first curve to find closest
            point from cv2 node value...had a problem with reduced
            curve having a zinger at a node value, so if you use the
            zinger point to find a minimum distance point to cv1, then
            the distance will be greater  */
         distBSnrm_2_cvs(span, cv1, node_pt, nodval, toobigdist,
                         knot_tol, &sum, avgerr, maxerr, par2, par1, pt2, 
                         pt1, rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( index > 1 && index-1 != pindex )
         {
            mul = FALSE;
            if( cv1->order > 2 )
            {
               for(i=0; i< num; i++)
               {
                  if( index >= ind[i]-1 )
                  {
                     if( index == ind[i]-1 )
                     {
                        mul = TRUE;
                        break;
                     }
                  }
                  else
                     break;
               }
            }
            if( mul )
            {
               /* try index-1 */
               index -= 1;
               nodval = 0.0;
               for (i=1; i< cv1->order; i++)
                  nodval += cv1->knots[index+i]; 
               nodval /= (cv1->order - 1);
   
               BScveval(&ocurve, nodval,num_derv,(IGRpoint *)&node_pt,rc);
               if (BSERROR(*rc))
                  goto wrapup;
   
               /** needs some tuning of the indices **/
               for (i=span; i<= cv1->num_poles; i++)
               {
                  if ( nodval <= cv1->knots[i+1] && nodval > cv1->knots[i]
                     && fabs(cv1->knots[i] - cv1->knots[i+1]) > knot_tol )
                  {
                     span = i;
                     break;
                  }
               }
               distBSnrm_2_cvs(span, cv1, node_pt, nodval, toobigdist,
                         knot_tol, &sum, avgerr, maxerr, par2, par1, pt2, 
                         pt1, rc);
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         pindex = index;
         if( checktol && *maxerr > maxtol )
         {
            /* we can stop, because we're already greater than our desired tolerance */
            break;
         }
      }  /* max_err > CLOSE_TO_ZERO */      
   }  /* for loop  */
   if( ! (checktol && *maxerr > maxtol ) )
   {

      npars = cv1->num_poles - cv1->order +1;
      if( npars > MAXNUM )
      {
         pars = (IGRdouble *)BSstackalloc((unsigned)( npars
                                                *  sizeof(IGRdouble )));
         if(!pars)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         parsalloc = TRUE;
      }
      else
      {
         pars = &apars[0];
      }
      
      BSfndcvcsp(cv1, &num, pars, rc);
      if (BSERROR(*rc))
         goto wrapup;
   
      span = cv2->order -1;   
      for (ii=0; ii < num; ii++)
      {
         BScveval(cv1, pars[ii], num_derv, (IGRpoint *) &node_pt, rc);
         for (i=span; i<cv2->num_poles; i++)
         {
             if ( pars[ii] <= cv2->knots[i+1] && pars[ii] > cv2->knots[i] &&
                  fabs(cv2->knots[i] - cv2->knots[i+1]) > knot_tol )
             {
                 span = i;
                 break;
             }
         }
   
         distBSnrm_2_cvs(span, cv2, node_pt, pars[ii], toobigdist,
                         knot_tol, &sum, avgerr, maxerr, par1, par2, pt1, 
                         pt2, rc);
         if(BSERROR(*rc))
            goto wrapup;
      }
   }
   if (sum > 0)
   {
      *avgerr = *avgerr/sum;
   }
   *maxerr = sqrt(*maxerr);    
   *avgerr = sqrt(*avgerr);


   wrapup:

   if ( pars && parsalloc)
     BSstackdealloc((char *) pars);
   if( cv1->num_poles > MAXNUM )
   {
      if( ocurve.knots )
         BSstackdealloc((char *)ocurve.knots);
      if( ocurve.rational && ocurve.weights)
         BSstackdealloc((char *)ocurve.weights);   
      if( ocurve.poles )
         BSstackdealloc((char *)ocurve.poles);
   }
   if( indalloc && ind )
      BSstackdealloc((char *) ind);
   if( tmulalloc && tmul)
      BSstackdealloc((char *)tmul);
   if( BSERROR(*rc))
      BSdbgrc(*rc, "BSnrm_2_cvs");

   return;
}     
