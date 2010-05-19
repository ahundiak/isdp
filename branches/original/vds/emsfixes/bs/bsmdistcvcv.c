/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdistcvcv

Abstract
    This function finds the minimum distance between two curves.

Synopsis
    void BSmdistcvcv(curve1,curve2,num,par1,par2,pt1,pt2,dist,rc)
    struct IGRbsp_curve        *curve1
    struct IGRbsp_curve        *curve2
    IGRint                     *num
    IGRdouble                  **par1
    IGRdouble                  **par2
    IGRpoint                   **pt1
    IGRpoint                   **pt2
    IGRdouble                  *dist
    BSrc                       *rc

Description
    This function finds the minimum distance, dist, between the two curves,
curve1 and curve2.  The num is the number of points at which the minimum 
distance occurs, and the par1 and par2 are the parameter values of the
points, pt1 and pt2, at which the minimum distance occurs on curve1 and curve2,
respectively.

Return Values
    When successful, a completion message of BSSUCC is received.  In the case
of a completion message of BSINARG, the input curves had infinitely many points
at which the minimum distance occurred.  Other values are possible if a called
function fails.

Notes
    If curve1 and curve2 intersect, then num may be greater than one; 
otherwise, num will be equal to one.

Index
    md

Keywords

History
    David Paul Stevens       10/6/86  :  Creation date.
    Y. S. Sheng              03/04/87 :  Modifify the allocations for par1,
                                         par2,pt1,pt2 in order to fix the
                                         lint problem.
    Y. S. Sheng              05/06/87 :  Correct lint error. 
    Y. S. Sheng              06/01/87 :  Replace BSktvals with BScvnodpts.
                                         Call BSmdstptarr and BScvkttol2.
                                         Replace BSmdistptcv with BSmdstptcv.
    S.G. Catron              06/16/87 :  Rewrote much of the routine, to make
                                         it more efficient.
    S.G. Catron              06/18/87 :  To check for degenerate curves.
    S.G. Catron              06/23/87 :  If BSlnn2cvs doesn't work, then
                                         call BSmdstccgtc.
    S.G. Catron              06/25/87 :  Call new routine BSfndneighb to find 
                                         the interval around the parameter.
                                         Also changed so we don't allocate space
                                         for temporary line structure.
    S.G. Catron              07/15/87 :  Added check before calling BSfndcvcsp
                                         to see if num_poles > order.
    Y. S. Sheng              10/05/87 :  Replace BScvcv_int with BScvcvint.
    S.G. Catron              11/10/87 :  Added call to BSmdstccgtc, when 
                                         BSlnn2cvs works, but the distance is 
                                         not less than the distance already 
                                         found.
    S.G. Catron              03/31/88 :  Added code when both curves are degen,
                                         to return the distance and output.
    S.G. Catron              07/07/88 :  If BScvcvint does not find anything 
                                         and the two curves are lines, call
                                         BSdlsegs2 to find the output.
    S.G. Catron              06/09/89 :  Changed the calculations of the 
                                         insertion values.  It was insert-
                                         ing too many values for some 
                                         cases.  Added special code for
                                         order 2, and if the average pole 
                                         distance is less than a chord 
                                         height tolerance.
    D. Breden                12/16/89  : Initialize boundaries in static 
                                         curve.

    S.G. Catron              01/02/90  : When there is a big order 2 curve
                                         and a much smaller order 2 curve,
                                         more nodes is needed.   Also 
                                         when going into the section of
                                         code using p1bool and p2bool, you
                                         need to use the saved output,
                                         because that is the data that was
                                         used to set p1bool and p2bool.
    S.G. Catron              07/12/90  : Change constant insert value for
                                         order 2 curves.
    S.G. Catron              08/18/92  : Made special code for both curves
                                         being order 2.  It finds the
                                         minimum distance between the
                                         poles of each curve and the other
                                         curve.  This is the minimum
                                         distance if the curves are 
                                         co-planar.  If they're not, then
                                         using closest poles and surround-
                                         ing segments call BSdlsegs2 to
                                         find exact answer.
    S.G. Catron              09/01/92  : Added an extra check after call
                                         to BSmdistccgtc, to check the
                                         closest cusp points(to answer 
                                         thus far), for a better minimum 
                                         distance.
    S.G. Catron              10/08/92  : There was a problem in the code
                                         added recently for line strings.
                                         I was checking for co-planar
                                         curves, but needed an extra dot
                                         product to make sure they weren't
                                         in parallel planes.
                                         Then I added code above cvcvint
                                         to check for parallel planar
                                         curves and move them to the same
                                         plane.  Continue as usual until
                                         solution is found, then find
                                         correct xyz point with parame-
                                         ters.
   S.G. Catron               10/21/92  : There was a bug in the allocation
                                         for pcurve1 and pcurve2.
                                         Changed MAXBLOCK to 3*MAXNUM,
                                         and changed top value to 
                                         MIN(top, 12).
   S.G. Catron               02/16/96  : Changed BSmdistptcv to
                                         BSmdstptcv.
   S.G. Catron               01/24/2001: etl#5135 and TR#4499 in JTS.
                                         Problem is the longer curve(which
                                         is NOT order2) is not stroked enough, then
                                         our guess value to BSlnn2cvs is not good enough.
                                         The guess value for the order2 curve is the
                                         problem.  It's in the wrong span.  We had special
                                         case code when the longer curve was order 2, but
                                         for this case our longer curve is order 4 and
                                         the other curve is order 2. Added code to check
                                         for such case and call static routine chknoddisBSmdistcvcv
                                         to use average distance of smaller curve to make sure
                                         our distance between stroked points was not larger than this.
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
#include "bsmalloc.h"
#endif

#define  BSVOID
#include <math.h>
#define NULL 0
#define MAXNUM 100
#define MAXBLOCK 3*MAXNUM

/* checking between node points, to see if distance is greater than average distance between
   poles of other curve */
static void chknoddisBSmdistcvcv(IGRint numvals, IGRdouble *points,
                                 IGRdouble avg, IGRint *insert, IGRint *sum)
{
#ifndef DONOTSPROTO
#include "bsdistptpts.h"
#endif
  IGRint i;
  IGRdouble dist, avgsq;
  BSrc rc;

  *sum = 0;
  avgsq = avg * avg;
  for(i=0; i< numvals-1; i++)
  {
    insert[i] = 0;
    dist = BSdistptpts(&rc, &points[i*3], &points[(i+1)*3]);
    if( dist > avgsq )
    {
      dist = sqrt(dist);
      insert[i] = (int)(dist/avg);
      *sum += insert[i];
    }
  }

  return;
}
		      
static  void  ord2BSmdistcvcv(
struct IGRbsp_curve *curve1,
struct IGRbsp_curve *curve2,
IGRdouble knot_tol1,
IGRdouble	 knot_tol2,
IGRboolean planar,
IGRdouble           *par1,
IGRdouble           	 *par2,
IGRpoint            pt1,
IGRpoint	 pt2,
IGRdouble           *dist,
BSrc                *rc)
{
#ifndef DONOTSPROTO
   #include "bsmdstptscv.h"   
   #include "bsdlsegs2.h"
#endif 
   IGRint i, j,n,  ii, jj, n1, n2;
   IGRint              ind0, ind1;
   IGRdouble *ptr, *dists=NULL,
             *u=NULL, adists[MAXNUM],
             au[MAXNUM], *tptr1, *tptr2, *wptr,
             *tpoles1=NULL, atpoles1[MAXNUM*3],
             *tpoles2=NULL, atpoles2[MAXNUM*3], tpar1,
             tpar2, dist2;
   IGRpoint  *pts=NULL, apts[MAXNUM], tpt1, 
             tpt2, p1, p2, p3, p4, p5, p6;
   IGRboolean all_on_curve;

   *rc = BSSUCC;

   n1 = curve1->num_poles;
   n2 = curve2->num_poles;
   n = MAX(n1, n2 );
   if( n > MAXNUM )
   {
      dists = (IGRdouble *)BSstackalloc((unsigned)(n * sizeof
                                                      (IGRdouble )));
      if(! dists )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      u = (IGRdouble *)BSstackalloc((unsigned)(n * sizeof
                                                      (IGRdouble )));
      if(! u )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      pts = (IGRpoint *)BSstackalloc((unsigned)(n * sizeof
                                                      (IGRpoint )));
      if(! pts )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      dists = adists;
      u = au;
      pts = apts;
   }

   /* find the minimum distance from the poles of one curve to the other
      curve and then vice-versa */

   ind1 = -1;
   if( !curve1->rational)
   {
      BSmdstptscv(n1, (IGRpoint *)curve1->poles, curve2, 
                  u, pts, dists, &all_on_curve, rc);
      if(BSERROR(*rc))
         goto wrapup;
      tptr1 = curve1->poles;
   }
   else
   {
      if( n1 > MAXNUM )
      {
         tpoles1 = (IGRdouble *)BSstackalloc((unsigned)(n1
                                         * sizeof(IGRpoint )));
         if(! tpoles1)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
         tpoles1 = atpoles1;
      ptr = curve1->poles;
      wptr = curve1->weights;
      tptr1 = tpoles1;
      for(i=0; i<n1; i++,wptr++)
         for(j=0; j<3; j++,tptr1++,ptr++)
            *tptr1 = *ptr/ *wptr;
      BSmdstptscv(n1, (IGRpoint *)tpoles1, curve2, 
                  u, pts, dists, &all_on_curve, rc);
      if(BSERROR(*rc))
         goto wrapup;
      tptr1 = tpoles1;
   }
      
   *dist = dists[0];  
   *par1 = curve1->knots[1];
   *par2 = u[0];
   ptr = tptr1;
   pt1[0] = *ptr++;
   pt1[1] = *ptr++;
   pt1[2] = *ptr;
   pt2[0] = pts[0][0];
   pt2[1] = pts[0][1];
   pt2[2] = pts[0][2];
   ind0 = 1;
   for(i=1; i<n1; i++)
   {
      if( dists[i] < *dist )
      {
         *dist = dists[i];  
         *par1 = curve1->knots[i+1];
         *par2 = u[i];
         ind0 = i+1;
         ptr = &tptr1[i*3];
         pt1[0] = *ptr++;
         pt1[1] = *ptr++;
         pt1[2] = *ptr;
         pt2[0] = pts[i][0];
         pt2[1] = pts[i][1];
         pt2[2] = pts[i][2];
      }
   }

   if( !curve2->rational)
   {
      BSmdstptscv(n2, (IGRpoint *)curve2->poles, curve1, 
                  u, pts, dists, &all_on_curve, rc);
      if(BSERROR(*rc))
         goto wrapup;
      tptr2 = curve2->poles;
   }
   else
   {
      if( n2 > MAXNUM )
      {
         tpoles2 = (IGRdouble *)BSstackalloc((unsigned)(n2
                                             * sizeof(IGRpoint )));
         if(! tpoles2 )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
         tpoles2 = atpoles2;
      ptr = curve2->poles;
      wptr = curve2->weights;
      tptr2 = tpoles2;
      for(i=0; i<n2; i++,wptr++)
         for(j=0; j<3; j++,tptr2++,ptr++)
            *tptr2 = *ptr/ *wptr;
      BSmdstptscv(n2, (IGRpoint *)tpoles2, curve1, 
                  u, pts, dists, &all_on_curve, rc);
      if(BSERROR(*rc))
         goto wrapup;
      tptr2 = tpoles2;
   }
   for(i=0; i<n2; i++)
   {
      if( dists[i] < *dist )
      {
         *dist = dists[i];  
         *par2 = curve2->knots[i+1];
         *par1 = u[i];
         ind1 = i+1;
         ind0 = -1;
         ptr = &tptr2[i*3];
         pt2[0] = *ptr++;
         pt2[1] = *ptr++;
         pt2[2] = *ptr;
         pt1[0] = pts[i][0];
         pt1[1] = pts[i][1];
         pt1[2] = pts[i][2];
      }
   }

   /* if curves are not co-planar, then we may not have the minimum
      distance....using the pole of one curve and the point on the
      other curve, find the surrounding segments and intersect them */
   if( !planar )
   {
      j = -1;
      jj = -1;
      /* ind0 and ind1 are set up with ind0 being for the first curve and
         ind1 being for the second curve...if the minimum distance
         found was for curve1, then ind0 contains the indice into the 
         knots at minimum distance and ind1= -1...vice versa if minimum
         at curve2 */
      if( ind0 != -1 )
      {
         /* minimum distance was found at curve1->knots[ ind0 ] ...
            when minimum distance is at a pole, take the segment
            before and after the pole to intersect with...be careful
            about minimum distance at P[0], if closed then chose 
            two segments(one before closure and one after), but if open 
            the intersect only with first segment  */
         if( ind0 == n1 && curve1->phy_closed )
            ind0 = 1;
         if( ind0 == 1 && curve1->phy_closed)
         {
            ptr = &tptr1[(n1-2)*3];
            p1[0] = *ptr++;
            p1[1] = *ptr++;
            p1[2] = *ptr;
            ptr = tptr1;
            i = n1-1;
            j = ind0;
         }
         else
         {
            if( ind0 == 1 )
            {
               i = 1;
               j = -1;
               ptr = &tptr1[(ind0-1)*3]; 
            }
            else
            {
               i = ind0-1;
               j = ind0;
               ptr = &tptr1[(ind0-2)*3]; 
            }
            p1[0] = *ptr++;
            p1[1] = *ptr++;
            p1[2] = *ptr++;
         }
         if( j == n1 )
            j = -1;
         p2[0] = *ptr++;
         p2[1] = *ptr++;
         p2[2] = *ptr++;
         if( j != -1 )
         {
            p3[0] = *ptr++;
            p3[1] = *ptr++;
            p3[2] = *ptr;
         }
      }
      else
      {
         /* minimum distance was found at pole of curve2 and somewhere
            on curve1...find the knot indice, this is the segment to
            intersect with...check if par1 is exactly a knot and if so,
            then we already have the answer */
         for(i=1; i<n1; i++)
         {
            if( fabs(*par1 - curve1->knots[i+1]) < knot_tol1 ) 
               goto wrapup;
               
            if(*par1 < curve1->knots[i+1] )
            {
               ptr = &tptr1[(i-1)*3];
               p1[0] = *ptr++;
               p1[1] = *ptr++;
               p1[2] = *ptr++;
               p2[0] = *ptr++;
               p2[1] = *ptr++;
               p2[2] = *ptr;
               break;
            }
         }   
      }  
      /* do the same thing for curve2 as above */
      if( ind1 != -1 )
      {
         if( ind1 == n2 && curve2->phy_closed )
            ind1 = 1;
         if( ind1 == 1 )
         {
            ptr = &tptr2[(n2-2)*3];
            p4[0] = *ptr++;
            p4[1] = *ptr++;
            p4[2] = *ptr;
            ptr = tptr2;
            ii = n2-1;
            jj = ind1;
         }
         else
         {

            if( ind1 == 1 )
            {
               ii = 1;
               jj = -1;
               ptr = &tptr2[ii*3]; 
            }
            else
            {
               ii = ind1-1;
               jj = ind1;
               ptr = &tptr2[(ind1-2)*3]; 
            }
            p4[0] = *ptr++;
            p4[1] = *ptr++;
            p4[2] = *ptr++;
         }
         p5[0] = *ptr++;
         p5[1] = *ptr++;
         p5[2] = *ptr++;
         p6[0] = *ptr++;
         p6[1] = *ptr++;
         p6[2] = *ptr;
      }
      else
      {
         for(ii=1; ii<n2; ii++)
         {
            if( fabs(*par2 - curve2->knots[i+1]) < knot_tol2 ) 
               goto wrapup;
            if(*par2 < curve2->knots[ii+1]) 
            {
               ptr = &tptr2[(ii-1)*3];
               p4[0] = *ptr++;
               p4[1] = *ptr++;
               p4[2] = *ptr++;
               p5[0] = *ptr++;
               p5[1] = *ptr++;
               p5[2] = *ptr;
               break;
            }
         }   
      }  

      /* now intersect segments */
      BSdlsegs2( p1, p2, p4, p5, &dist2, tpt1, tpt2, &tpar1, &tpar2, rc);
      if(BSERROR(*rc))
         goto wrapup;
      /* see if this distance is any smaller than one already found */
      if( dist2 < *dist )
      {
         *dist = dist2; 
         *par1 = curve1->knots[i] + (curve1->knots[i+1]-
                      curve1->knots[i]) * tpar1;
         *par2 = curve2->knots[ii] + (curve2->knots[ii+1] -
                      curve2->knots[ii]) * tpar2;
         for(i=0; i< 3; i++)
         {
            pt1[i] = tpt1[i];
            pt2[i] = tpt2[i];
         }
      }
      /* for other intersection, we have to see which curve had the
         minimum distance pole...also check if minimum pole was at 0
         and not closed(j or jj will equal -1 )   */         
      if( ind0 != -1 )
      {
         if( j != -1 )
         {
            BSdlsegs2( p2, p3, p4, p5, &dist2, tpt1, tpt2, &tpar1, &tpar2,
                       rc);
            if(BSERROR(*rc))
               goto wrapup;
         }
         jj = -1;
      }
      else
      {
         if( jj != -1)
         {
            BSdlsegs2( p1, p2, p5, p6, &dist2, tpt1, tpt2, &tpar1, &tpar2,
                       rc);
            if(BSERROR(*rc))
               goto wrapup;
         }
         j = -1;
      }
      if( j != -1 || jj != -1 )
      {
         if( dist2 < *dist )
         {
            *dist = dist2; 
            if( j != -1 )
               *par1 = curve1->knots[j] + (curve1->knots[j+1]-
                            curve1->knots[j]) * tpar1;
            else
               *par1 = curve1->knots[i] + (curve1->knots[i+1]-
                            curve1->knots[i]) * tpar1;
            if( jj != -1 )
               *par2 = curve2->knots[jj] + (curve2->knots[jj+1] -
                            curve2->knots[jj]) * tpar2;
            else
               *par2 = curve2->knots[ii] + (curve2->knots[ii+1] -
                            curve2->knots[ii]) * tpar2;
            for(i=0; i< 3; i++)
            {
               pt1[i] = tpt1[i];
               pt2[i] = tpt2[i];
            }
         }
      }
   }

   wrapup:
   if( tpoles1 && tpoles1 != atpoles1 )
      BSstackdealloc((char *) tpoles1 );
   if( tpoles2 && tpoles2 != atpoles2 )
      BSstackdealloc((char *) tpoles2 );
   if( pts && pts != apts )
      BSstackdealloc((char *) pts );
   if( u && u != au )
      BSstackdealloc((char *) u );
   if( dists && dists != adists )
      BSstackdealloc((char *) dists );

   return;
}


/* Main */

void BSmdistcvcv(
struct IGRbsp_curve *curve1,     
struct IGRbsp_curve *curve2,
IGRint *num,
IGRdouble **par1,
 IGRdouble 	**par2,
IGRpoint **pt1,
 IGRpoint 	**pt2,
IGRdouble *dist,
BSrc *rc)
 {
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscvnodpts.h"
#include "bsmdstccgtc.h"
#include "bscveval.h"
#include "bsdlsegs2.h"
#include "bsmdstptarr.h"
#include "bscvkttol2.h"
#include "bststcvdegn.h"
#include "bsfndneighb.h"
#include "bsfndcvcsp.h"
#include "bsmdstptcv.h"
#include "bslnn2cvs.h"
#include "bsavgpts.h"
#include "bscvcvint.h"
#include "bsdistptpt.h"
#include "bsavgdispts.h"
#include "bsplanar2.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bslsqptlnpl.h"
#include "bsprj_cv_pl.h"
#include "bsinspararr.h"
#include "bscvarreval.h"
#endif 
   IGRdouble knot_tol1,knot_tol2; /* tolerance for checking knot values       */
   IGRint i,j;                    /* loop counters                            */
   IGRdouble dist2;               /* temporary  copy of minimum distance      */
   IGRboolean p1bool,p2bool;      /* are par1 and par2 multiple knots?            */
   IGRint ind1,ind2;              /* indices of closest knot values           */
   IGRdouble tpar1,tpar2;
   IGRint n_int=0;                /* number of single intersection points     */
   IGRdouble *intpts;             /* intersection points                      */
   IGRdouble *par00,*par01;
   IGRint nover=0,tnover;         /* number of overlap points                 */
   IGRdouble *endpts;             /* overlap endpoints                        */
   IGRdouble *over1,*over2;       /* parameters of overlap points             */
   IGRint insert,insert1,insert2; /* number of times to insert between knots  */
   IGRint numvals1,numvals2;      /* number of knot values for each curve     */
   IGRdouble *ndvals1,
             *ndvals2;            /* arrays of knot values for curve1, curve2 */
   IGRdouble *points1,*points2;   /* curve evaluations at knot values         */
   IGRdouble *tmul,dist_tol,chrdht_tol;
   IGRint mlnum;                  /* number of multiple knots                 */
   struct IGRbsp_curve line1;
   IGRpoint poles[4];
   IGRdouble knots[4];
   IGRpoint tpt1,tpt2;            /* temporary points corresp. to p1 and p2   */
   IGRboolean degen1,degen2;
   IGRint num_deriv = 0, div, top;
   IGRshort  order1, order2;
   IGRdouble neig1[2],neig2[2];
   IGRboolean dummy1 = TRUE;
   IGRpoint   *dummy2=NULL, *dummy5=NULL;
   IGRdouble  dummy3,
              dummy4,
              dummy6,
              dummy7;
   IGRboolean dummy8,
              dummy9, 
              planar=0;
   IGRpoint   p1, p2, p3, p4;
   IGRdouble  savedist, savepar1, 
              savepar2, avg1, avg2, tdot, 
              *wts=NULL, dot_tol, err;
   IGRpoint   savept1, savept2;
   IGRint     code1, code2, four=4, option,
              np1, np2, counter;
   IGRvector  N1, N2, N, vec;
   IGRboolean closecusp1=FALSE,
              closecusp2=FALSE;
   IGRdouble  closecusp1par=0, closecusp2par=0,
              d=0, d1, block[MAXBLOCK];
   IGRboolean p1poles=FALSE, p1weights=FALSE, p1knots=FALSE,
              p2poles=FALSE, p2weights=FALSE, p2knots=FALSE;
   struct IGRbsp_curve *pcurve1=NULL, *pcurve2=NULL,
                       cv[2];
   IGRint *insertarr1=NULL, *insertarr2=NULL, newnumvals, sum;
   IGRdouble *newndvals=NULL;
                       
   *rc = BSSUCC;                  

   par00 = NULL;             /* put pointers to NULL before memory allocation */
   par01 = NULL;
   over1 = NULL;
   over2 = NULL;
   intpts = NULL;
   endpts = NULL;
   ndvals1 = NULL;
   ndvals2 = NULL;
   points1 = NULL;
   points2 = NULL;
   tmul = NULL;
   line1.weights = NULL;
   line1.bdrys = NULL;
   order1 = curve1->order;
   order2 = curve2->order;
   np1 = curve1->num_poles;
   np2 = curve2->num_poles;

   BStstcvdegn(curve1,&degen1,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   
   BStstcvdegn(curve2,&degen2,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   if( degen1 || degen2 )
   {
      *par1 = (IGRdouble *)BSmalloc((unsigned)(1 * sizeof(IGRdouble)));
      if( ! *par1 )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *par2 = (IGRdouble *)BSmalloc((unsigned)(1 * sizeof(IGRdouble)));
      if( ! *par2 )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *pt1 = (IGRpoint *)BSmalloc((unsigned)(1 * sizeof(IGRpoint)));
      if( ! *pt1 )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *pt2 = (IGRpoint *)BSmalloc((unsigned)(1 * sizeof(IGRpoint)));
      if( ! pt2 )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      if( degen1 )
      {
         /* find the average point */
         (void)BSavgpts(rc, np1, curve1->poles, curve1->weights,
                        **pt1);
         if(BSERROR(*rc))
            goto wrapup;
         (*par1)[0] = (curve1->knots[order1 -1] + 
                      curve1->knots[np1] ) /2;
      }
      if( degen2 )
      {
         /* find the average point */
         (void)BSavgpts(rc, np2, curve2->poles, curve2->weights,
                        **pt2);
         if(BSERROR(*rc))
            goto wrapup;
         (*par2)[0] = (curve2->knots[order2 -1] + 
                      curve2->knots[np2]) /2;
      }
      if( degen1 && degen2 )
      {
         *num = 1;
         *dist = BSdistptpt(rc, **pt1, **pt2);
      }
      else
      {
         if( degen1 )
         {
            BSmdstptcv(curve2,**pt1,&(*par2)[0],(*pt2)[0],dist,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            *num = 1;
            goto wrapup;
         }
         else
         {                                     
            BSmdstptcv(curve1,**pt2,&(*par1)[0],(*pt1)[0],dist,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            *num = 1;
            goto wrapup;
         }
      }
      goto wrapup;
   }
   BSEXTRACTPAR(rc,BSTOLORTHOVEC,dot_tol);   
   /* check to see if curves are planar and in parallel planes */
   option = 3;
   /* code = 3 means co-planar */
   BSlsqptlnpl(np1, curve1->poles, curve1->weights, 
               option, &code1, tpt1, N1, &err, rc );
   if(BSERROR(*rc))
      goto wrapup;
   BSlsqptlnpl(np2, curve2->poles, curve2->weights, 
               option, &code2, tpt2, N2, &err, rc );
   if(BSERROR(*rc))
      goto wrapup;
   /* if code not equal to linear or planar, then planes can't be
      coplanar */
   if( (code2 !=3 && code2 != 2 ) || (code1 !=3 && code1 != 2 )  || 
        (code2 == 2 && code1 == 2) )
      planar = FALSE;
   else
   {
      if( code2 == 2 || code1 == 2 )
      {
         /* we have one line and one planar curve...
            check to see if the line is in the plane of the other 
            curve */
         if( code1 == 2 )
         {
            if( !curve1->rational)
               for(i=0; i<3; i++)
                  N[i] = curve1->poles[i] - curve1->poles[3+i];
            else
               for(i=0; i<3; i++)
                  N[i] = curve1->poles[i]/curve1->weights[0] - 
                         curve1->poles[3+i]/curve1->weights[1];
            (void)BSnorvec(rc, N );
            if(BSERROR(*rc))
               goto wrapup;
            tdot = BSdotp(rc, N, N2 );
            if( ABS(tdot) < dot_tol )
            {
               /* make sure the line is in the plane and not just
                  parallel to the plane */
               vec[0] = tpt1[0] - tpt2[0];
               vec[1] = tpt1[1] - tpt2[1];
               vec[2] = tpt1[2] - tpt2[2];
               tdot = BSdotp( rc, vec, N2 );
               if( fabs(tdot) > dot_tol)
                  planar = 2;
               else
                  planar = 1;
            }
            else
               planar = 0;
         }
         else
         {
            if( !curve2->rational)
               for(i=0; i<3; i++)
                  N[i] = curve2->poles[i] - curve2->poles[3+i];
            else
               for(i=0; i<3; i++)
                  N[i] = curve2->poles[i]/curve2->weights[0] - 
                         curve2->poles[3+i]/curve2->weights[1];
            (void)BSnorvec(rc, N );
            if(BSERROR(*rc))
               goto wrapup;
            tdot = BSdotp(rc, N, N1 );
            if( ABS(tdot) < dot_tol )
            {
               /* see if the line is in the plane or just
                  parallel to the plane */
               vec[0] = tpt1[0] - tpt2[0];
               vec[1] = tpt1[1] - tpt2[1];
               vec[2] = tpt1[2] - tpt2[2];
               tdot = BSdotp( rc, vec, N1 );
               if( fabs(tdot)  > dot_tol)
                  planar = 2;  /* parallel */
               else
                  planar = 1;
            }
            else
               planar = 0;
         }
      }
      else
      {
         /* both are planar curves */
         tdot = BSdotp( rc, N1, N2 );
         if(fabs(fabs(tdot) - 1) > dot_tol)
            planar = 0;
         else
         {
            /* now make sure that the planes are the same plane and
               not parallel */
            vec[0] = tpt1[0] - tpt2[0];
            vec[1] = tpt1[1] - tpt2[1];
            vec[2] = tpt1[2] - tpt2[2];
            tdot = BSdotp( rc, vec, N2 );
            if( fabs(tdot) > dot_tol)
               planar = 2; /* parallel  */
            else
               planar = 1;
         }
      }
      if( planar == 2 )
      {
         /* curves are in parallel planes, project them to the same
            plane, then contiune with code as usual */
         /* set memory for pcurve1 and pcurve2 */
         counter = 0;
         pcurve1 = &cv[0];
         pcurve2 = &cv[1];
         pcurve1->poles = NULL;
         pcurve1->weights = NULL;
         pcurve1->knots = NULL;
         pcurve2->poles = NULL;
         pcurve2->weights = NULL;
         pcurve2->knots = NULL;
         if( np1*3 > MAXBLOCK )
         {
            pcurve1->poles = (IGRdouble *)BSstackalloc((unsigned)( np1 *
                                    3* sizeof(IGRdouble )));
            if(!pcurve1->poles )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            p1poles = TRUE;
         }
         else
         {
            pcurve1->poles = &block[counter];
            counter += np1*3;
         }
         p1weights = FALSE;
         if( curve1->rational )
         {
            if( counter + np1 > MAXBLOCK )
            {
               pcurve1->weights = (IGRdouble *)BSstackalloc((unsigned)(np1
                                       * sizeof(IGRdouble )));
               if(!pcurve1->weights)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               p1weights = TRUE;
            }
            else
            {
               pcurve1->weights = &block[counter];
               counter += np1;
            }
         }
         if( curve1->num_knots+counter > MAXBLOCK )
         {
            pcurve1->knots = (IGRdouble *)BSstackalloc((unsigned)( 
                              curve1->num_knots* sizeof(IGRdouble )));
            if(!pcurve1->knots )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            p1knots = TRUE;
         }
         else
         {
            pcurve1->knots = &block[counter];
            counter += curve1->num_knots;
         }

         if( np2*3+counter > MAXBLOCK )
         {
            pcurve2->poles = (IGRdouble *)BSstackalloc((unsigned)( np2 *
                                    3* sizeof(IGRdouble )));
            if(!pcurve2->poles )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            p2poles = TRUE;
         }
         else
         {
            pcurve2->poles = &block[counter];
            counter += np2*3;
         }
         if( curve2->rational )
         {
            if( counter + np2 > MAXBLOCK )
            {
               pcurve2->weights = (IGRdouble *)BSstackalloc((unsigned)(np2
                                       * sizeof(IGRdouble )));
               if(!pcurve2->weights)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               p2weights = TRUE;
            }
            else
            {
               pcurve2->weights = &block[counter];
               counter += np2;
            }
         }
         if( curve2->num_knots+counter > MAXBLOCK )
         {
            pcurve2->knots = (IGRdouble *)BSstackalloc((unsigned)( 
                              curve2->num_knots* sizeof(IGRdouble )));
            if(!pcurve2->knots )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            p2knots = TRUE;
         }
         else
         {
            pcurve2->knots = &block[counter];
            counter += curve2->num_knots;
         }

         /* curves are in parallel planes...
            make sure that if we have a line, we don't use that normal */
         if( code1 != 2 )
         {
            (void)BSprj_cv_pl(rc, curve1, tpt1, N1, N1, pcurve1 );
            if(BSERROR(*rc))
               goto wrapup;
            (void)BSprj_cv_pl(rc, curve2, tpt1, N1, N1, pcurve2 );
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            (void)BSprj_cv_pl(rc, curve1, tpt2, N2, N2, pcurve1 );
            if(BSERROR(*rc))
               goto wrapup;
            (void)BSprj_cv_pl(rc, curve2, tpt2, N2, N2, pcurve2 );
            if(BSERROR(*rc))
               goto wrapup;
         }
      }
   }
   if( planar != 2 )
   {
      pcurve1 = curve1;
      pcurve2 = curve2;
   }

   /*
   *   Invoke BScvcvint to determine if the two input curves intersect
   */

   BScvcvint(pcurve1, pcurve2, dummy1, 0, 0,dummy2,&dummy3,&dummy4,dummy5,
             &dummy6, &dummy7, &n_int, &nover, &dummy8, &dummy9, 
             (IGRpoint **)&intpts, &par00, &par01, (IGRpoint **)&endpts, 
             &over1, &over2, rc);
   if(BSERROR(*rc)) goto wrapup;

   if( n_int > 0 || nover > 0 )
   {
      *dist = 0;
      *num = n_int + 2 * nover;
      *par1 = (IGRdouble *)BSmalloc((unsigned)(*num * sizeof(IGRdouble)));
      if( ! *par1 )
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }
      *par2 = (IGRdouble *)BSmalloc((unsigned)(*num * sizeof(IGRdouble)));
      if( ! *par2 )
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }
      *pt1 = (IGRpoint *)BSmalloc((unsigned)(*num * sizeof(IGRpoint)));
      if( ! *pt1 )
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }
      *pt2 = (IGRpoint *)BSmalloc((unsigned)(*num * sizeof(IGRpoint)));
      if( ! *pt2 )
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }

      for( i = 0; i < n_int; ++i )
      {
         (*par1)[i] = par00[i];
         (*par2)[i] = par01[i];
         if( planar != 2 )
         {
            for( j = 0; j < 3; ++j )
            {
              (*pt1)[i][j] = intpts[3*i + j];
              (*pt2)[i][j] = intpts[3*i + j];
            }
         }
         else
         {
            /* planar == 2, means that the original curves were in
               parallel planes and were projected to the same plane..
               therefore we have to evalute the parameters with the
               original curves to get correct points */
            BScveval(curve1, (*par1)[i], num_deriv, (IGRpoint *)(*pt1)[0],
                     rc);
            if(BSERROR(*rc))
               goto wrapup;
            BScveval(curve2, (*par2)[i], num_deriv, (IGRpoint *)(*pt2)[0],
                     rc);
            if(BSERROR(*rc))
               goto wrapup;
            *dist = BSdistptpt(rc,(*pt1)[0],(*pt2)[0]);
            *num = 1;
            break;
         }
      }
      tnover = nover;
      if( planar == 2 && n_int)
         tnover = 0;

      if( tnover > 0 )
      {
         for( i = 0; i < 2 * nover; ++i )
         {
            (*par1)[n_int + i] = over1[i];
            (*par2)[n_int + i] = over2[i];
            if( planar != 2 )
            {
               for( j = 0; j < 3; ++j )
               {
                  (*pt1)[n_int + i][j] = endpts[3*i + j];
                  (*pt2)[n_int + i][j] = endpts[3*i + j];
               }
            }
            else
            {
               /* planar == 2, means that the original curves were in
                  parallel planes and were projected to the same plane..
                  therefore we have to evalute the parameters with the
                  original curves to get correct points */
               BScveval(curve1, (*par1)[0],num_deriv,
                        (IGRpoint *)(*pt1)[0], rc);
               if(BSERROR(*rc))
                  goto wrapup;
               BScveval(curve2,(*par2)[0],num_deriv, 
                        (IGRpoint *)(*pt2)[0], rc);
               if(BSERROR(*rc))
                  goto wrapup;
               *dist = BSdistptpt(rc,(*pt1)[0],(*pt2)[0]);
               *num = 1;
               break;
            }
         }
      }   /* end of case: nover > 0                      */
      goto wrapup;
   }    /* end of case: curve1 and curve2 intersected  */

/*
*   Output is now at most one point and one parameter on each curve
*/

   *num = 0;
   *par1 = (IGRdouble *)BSmalloc((unsigned)(1 * sizeof(IGRdouble)));
   if( ! *par1 )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *par2 = (IGRdouble *)BSmalloc((unsigned)(1 * sizeof(IGRdouble)));
   if( ! *par2 )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *pt1 = (IGRpoint *)BSmalloc((unsigned)(1 * sizeof(IGRpoint)));
   if( ! *pt1 )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *pt2 = (IGRpoint *)BSmalloc((unsigned)(1 * sizeof(IGRpoint)));
   if( ! pt2 )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }

   /* see if both are lines */
   if( order1 == 2 && np1 == 2 && 
       order2 == 2 && np2 == 2 )
   {
      if( pcurve1->rational )
      {
         for(i=0; i<3; i++)
         {
            p1[i] = pcurve1->poles[i] / pcurve1->weights[0];
            p2[i] = pcurve1->poles[i+3] / pcurve1->weights[1];
         }
      }
      else
      {
         for(i=0; i<3; i++)
         { 
            p1[i] = pcurve1->poles[i];
            p2[i] = pcurve1->poles[i+3];
         }
      }
      if( pcurve2->rational )
      {
         for(i=0; i<3; i++)
         {
            p3[i] = pcurve2->poles[i] / pcurve2->weights[0];
            p4[i] = pcurve2->poles[i+3] / pcurve2->weights[1];
         }
      }
      else
      {
         for(i=0; i<3; i++)
         {
            p3[i] = pcurve2->poles[i] ;
            p4[i] = pcurve2->poles[i+3] ;
         }
      }
      BSdlsegs2( p1, p2, p3, p4, dist, **pt1, **pt2, *par1, *par2, rc);
      if( BSOKAY(*rc))
         *num = 1;
      goto wrapup;
   }
   line1.poles = &poles[0][0];
   line1.knots = &knots[0];

   BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

   if( !pcurve1->rational)
   {
      pcurve1->weights = NULL;
   }
   BScvkttol2(order1, pcurve1->knots, np1, pcurve1->poles,
             pcurve1->weights, &knot_tol1, rc);
   if(BSERROR(*rc)) goto wrapup;
   if( !pcurve2->rational)
   {
      pcurve2->weights = NULL;
   }
   BScvkttol2(order2, pcurve2->knots, np2, pcurve2->poles,
               pcurve2->weights, &knot_tol2, rc);
   if(BSERROR(*rc)) goto wrapup;

   if( order1 == 2 && order2 == 2 )
   {
      /* check for lines being in the same plane */
      if( code1 == 2 && code2 == 2 )
      {
         /* both curves are lines, put points in array to call 
            BSplanar2 with */
         for(i=0; i<3; i++)
         {
            if( pcurve1->rational)
            {
               poles[0][i] = pcurve1->poles[i]/pcurve1->weights[0];
               poles[1][i] = pcurve1->poles[3+i]/pcurve1->weights[1];
            }
            else
            {
               poles[0][i] = pcurve1->poles[i];
               poles[1][i] = pcurve1->poles[3+i];
            }
            if( pcurve2->rational)
            {
               poles[2][i] = pcurve2->poles[i]/pcurve2->weights[0];
               poles[3][i] = pcurve2->poles[3+i]/pcurve2->weights[1];
            }
            else
            {
               poles[2][i] = pcurve2->poles[i];
               poles[3][i] = pcurve2->poles[3+i];
            }
         }
         BSplanar2(four, poles, wts, &code2, N, rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( code2 != 3 )
            planar = FALSE;
         else
            planar = TRUE;
      }
      if( planar )
      {
         ord2BSmdistcvcv(pcurve1, pcurve2, knot_tol1, knot_tol2, planar, 
                         *par1, *par2, **pt1, **pt2, dist, rc);
         if( BSOKAY(*rc))
            *num = 1;
         if( planar == 2 )
         {
            /* planar == 2, means that the original curves were in
               parallel planes and were projected to the same plane..
               therefore we have to evalute the parameters with the
               original curves to get correct points */
            BScveval(curve1, (*par1)[0],num_deriv,(IGRpoint *)(*pt1)[0], rc);
            if(BSERROR(*rc))
               goto wrapup;
            BScveval(curve2,(*par2)[0],num_deriv, (IGRpoint *)(*pt2)[0], rc);
            *dist = BSdistptpt(rc,(*pt1)[0],(*pt2)[0]);
         }
         goto wrapup;
      }
   }

   /*
    *   Determine an insert value for computing nodes, mid-nodes, etc. 
        (default = 2)
    */

   insert = 2;
   ind1 = ( np1 + order1 - 1 ) * ( insert + 1 );
   ind2 = ( np2 + order2 - 1 ) * ( insert + 1 );
   i = ind1;         /* i will be maximum of ind1 and ind2  */
   if( i < ind2 )
   {
      i = ind2;
   }
   if( ind1 == i )
   {
     insert1 = 2;
   }
   else
   {
      insert1 = i / ( np1 + order1 - 1 ) - 1;
   }
   if( ind2 == i )
   {
      insert2 = 2;
   }
   else
   {
      insert2 = i / ( np2 + order2 - 1 ) - 1;
   }
   if( order1 == 2 && ((insert1 < 6 && np1 < 10) ||
                              (insert1 > 10 ) ) )
   {
      /* if insert is too great or too small compared to it's number of
         poles, set to 6(which is a guess) */
      insert1 = 6;
   }
   if( order2 == 2 && ( (insert2 < 6 && np2 < 10 ) ||
                               (insert1 > 10 ) ) )
   {
      insert2 = 6;
   }
   BSavgdispts(np1, pcurve1->poles, pcurve1->weights, &avg1,
               rc);
   if(BSERROR(*rc))
      goto wrapup;
   BSavgdispts(np2, pcurve2->poles, pcurve2->weights, &avg2,
               rc);
   if(BSERROR(*rc))
      goto wrapup;
   BSEXTRACTPAR(rc,BSTOLCHRDHT,chrdht_tol);

   if( avg1 < 100 * chrdht_tol )
   {
      if( avg1 < 10 * chrdht_tol )
         insert1 = 0;
      else
         insert1 = 1;
   }
   if( avg2 < 100 * chrdht_tol )
   {
      if( avg2 < 10 * chrdht_tol )
         insert2 = 0;
      else
         insert2 = 1;
   }
   /* when one curve is alot bigger than the other more nodes is needed
      in the bigger one */
   if( order2 == 2 )
   {
      div = (IGRint)(avg2 / avg1);
      if( div > 5  && np2 < 50)
      {
         top = div / 2;
         top = MIN(top, 12);
         insert2 += top;
      }
   }
   if( order1 == 2 )
   {
      div = (IGRint)(avg1 / avg2);
      if( div > 5  && np1 < 50)
      {
         top = div / 2;
         top = MIN(top, 12);
         insert1 += top;
      }
   }

   /*
    *  Allocate space for ndvals arrays
   */
   i = (np1 - 1) * (insert1 + 1 ) + 1;
   ndvals1 = (IGRdouble *)BSstackalloc((unsigned)( i * sizeof(IGRdouble)));
   if( !ndvals1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points1 = (IGRdouble *)BSstackalloc((unsigned)(3 * i * 
                 sizeof(IGRdouble)));
   if( !points1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

   i = (np2 - 1) * (insert2 + 1 ) + 1;
   ndvals2 = (IGRdouble *)BSstackalloc((unsigned)( i * sizeof(IGRdouble)));
   if( !ndvals2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points2 = (IGRdouble *)BSstackalloc((unsigned)(3 * i * 
                sizeof(IGRdouble)));
   if( !points2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

/*
*   Invoke BScvnodpts to evaluate pcurve1 and pcurve2 for the ndvals arrays
*/

   BScvnodpts(pcurve1, insert1, &numvals1, ndvals1, points1, rc);
   if(BSERROR(*rc)) goto wrapup;

   BScvnodpts(pcurve2, insert2, &numvals2, ndvals2, points2, rc);
   if(BSERROR(*rc)) goto wrapup;

   /* we already have special case code for order 2 curves which are much longer than
      the other curve, this is for order > 2 and the distance between points is more than
      twice that of the other curve, also noting that problems seen with guess values,
      have been with order 2 curves, so only do this if the other curve is order2 */
   if( avg1/avg2 > 2 && pcurve1->order != 2 && pcurve2->order == 2)
/*   if( avg1/avg2 > 2 ) */
   {
     insertarr1 = (IGRint *)BSstackalloc((unsigned)( numvals1 * sizeof(IGRint)));
     if( !insertarr1 )
     {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
     }
     chknoddisBSmdistcvcv(numvals1, points1, avg2, insertarr1, &sum );
     if( sum > 0 )
     {
       newndvals = (IGRdouble *)BSstackalloc((unsigned)( (numvals1+sum) * sizeof(IGRdouble)));
       if( !newndvals )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       BSinspararr(numvals1,ndvals1,insertarr1,&newnumvals,newndvals,rc);
       if(BSERROR(*rc))
         goto wrapup;
       BSstackdealloc((char *)points1);
       BSstackdealloc((char *)ndvals1);
       ndvals1 = newndvals;
       numvals1 = newnumvals;
       newndvals = NULL;
       points1 = (IGRdouble *)BSstackalloc((unsigned)(3 * numvals1 * 
                     sizeof(IGRdouble)));
       if( !points1 )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       
       BScvarreval( rc, pcurve1, ndvals1, numvals1, 0, points1 );
       if (BSERROR(*rc))
         goto wrapup;
     }
   }       
   if( avg2/avg1 > 2 && pcurve2->order != 2)
/*   if( avg2/avg1 > 2 ) */
   {
     insertarr2 = (IGRint *)BSstackalloc((unsigned)( numvals2 * sizeof(IGRint)));
     if( !insertarr2 )
     {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
     }
     chknoddisBSmdistcvcv(numvals2, points2, avg1, insertarr2, &sum );
     if( sum > 0 )
     {
       newndvals = (IGRdouble *)BSstackalloc((unsigned)( (numvals2+sum) * sizeof(IGRdouble)));
       if( !newndvals )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       BSinspararr(numvals2,ndvals2,insertarr2,&newnumvals,newndvals,rc);
       if(BSERROR(*rc))
         goto wrapup;
       BSstackdealloc((char *)points2);
       points2 = NULL;
       BSstackdealloc((char *)ndvals2);
       ndvals2 = newndvals;
       numvals2 = newnumvals;    
       newndvals = NULL;

       points2 = (IGRdouble *)BSstackalloc((unsigned)(3 * numvals2 * 
                     sizeof(IGRdouble)));
       if( !points2 )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
     
       BScvarreval( rc, pcurve2, ndvals2, numvals2, 0, points2 );
       if (BSERROR(*rc))
         goto wrapup;
     }
   }       

/*
*   Find which two points are closest together
*/

   BSmdstptarr(numvals1, (IGRpoint *)points1, numvals2, (IGRpoint *)points2,
               &ind1, &ind2, dist, rc);
   if(BSERROR(*rc)) goto wrapup;

   (*par1)[0] = ndvals1[ind1];
   (*par2)[0] = ndvals2[ind2];
   for( i = 0; i < 3; ++i )
   {
      (*pt1)[0][i] = points1[3*ind1 + i];
      (*pt2)[0][i] = points2[3*ind2 + i];
   }
   if( *dist < dist_tol )
   {
      *num = 1;
      goto wrapup;
   }
      
/*
*   Invoke BSfndcvcsp twice to determine if the closest points are cusp points 
    or endpoints
*/

   p1bool = FALSE;
   p2bool = FALSE;
   if( np1 > order1 || np2 > order2 )
   {
      mlnum = np1- order1;
      if( mlnum < np2 - order2)
      {
         mlnum = np2 - order2;
      }
      tmul = (IGRdouble *)BSstackalloc((unsigned)((mlnum +1) * sizeof(IGRdouble)));
      if( !tmul )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      if( np1 > order1 )
      {
         BSfndcvcsp(pcurve1,&mlnum,tmul,rc);
         if(BSERROR(*rc))
           goto wrapup;
         if( mlnum > 0 )
         {
            closecusp1 = TRUE;
            for( i = 0; i < mlnum; ++i )
            {
               if( fabs( (*par1)[0]- tmul[i] ) < knot_tol1 )
               {
                  p1bool = TRUE;
                  closecusp1 = FALSE;
                  break;
               }
               else
               {
                  d1 = fabs( (*par1)[0] - tmul[i] );
                  if( d1 < d || i == 0)
                  {
                     d = d1;
                     closecusp1par = tmul[i];
                  }
               }
            }
         }
      }
      if( np2 > order2 )
      {
         BSfndcvcsp(pcurve2,&mlnum,tmul,rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( mlnum > 0 )
         {
            closecusp2 = TRUE;
            for( i = 0; i < mlnum; ++i )
            {
               if( fabs( (*par2)[0] - tmul[i] ) < knot_tol2)
               {
                  p2bool = TRUE;
                  closecusp2 = FALSE;
                  break;
               }
               else
               {
                  d1 = fabs( (*par2)[0] - tmul[i] );
                  if( d1 < d || i == 0)
                  {
                     d = d1;
                     closecusp2par = tmul[i];
                  }
               }
            }
         }
      }
   }
   if( !pcurve1->phy_closed && !p1bool )
   {
      if( fabs( (*par1)[0] - pcurve1->knots[order1-1] ) < knot_tol1 ||
          fabs( (*par1)[0] - pcurve1->knots[np1] ) < knot_tol1 )
      {
         p1bool = TRUE;
      }
   }
   if( !pcurve2->phy_closed && !p2bool )
   {
      if( fabs( (*par2)[0] - pcurve2->knots[order2-1] ) < knot_tol2 ||
          fabs( (*par2)[0] - pcurve2->knots[np2] ) < knot_tol2 )
      {
         p2bool = TRUE;
      }
   }
   /* save output */
   savepar1 = (*par1)[0];
   savepar2 = (*par2)[0];
   for(i=0; i<3; i++)
   {
      savept1[i] = (*pt1)[0][i];
      savept2[i] = (*pt2)[0][i];
   }
   savedist = *dist;


   /*
    *   Invoke BSlnn2cvs to find line normal to both curves between closest knots
   */

   (void)BSlnn2cvs(rc,pcurve1,pcurve2,*pt1[0],*pt2[0],&line1,&tpar1,&tpar2);
   if(BSERROR(*rc))
   {
      if( *rc == BSNOSOLUTION || *rc == BSFAIL)
      {
         *rc = BSSUCC;


         /* find neighborhoods around (*par1)[0] and (*par2)[0]  */
         BSfndneighb((*par1)[0],numvals1,ndvals1,ind1,knot_tol1,
                     pcurve1->phy_closed,neig1,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         BSfndneighb((*par2)[0],numvals2,ndvals2,ind2,knot_tol2,
                      pcurve2->phy_closed,neig2,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         BSmdstccgtc(pcurve1,pcurve2,neig1,neig2,knot_tol1,knot_tol2,
                    &(*par1)[0],&(*par2)[0],(*pt1)[0],(*pt2)[0],dist,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         if( closecusp1 )
         {
            BScveval(pcurve1,closecusp1par,num_deriv,(IGRpoint *)tpt1,rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSmdstptcv(pcurve2,tpt1,&tpar2,tpt2,&dist2,rc);
            if( BSERROR( *rc ) ) goto wrapup;
            if( dist2 < *dist )
            {            
               *dist = dist2; 
               (*par1)[0] = closecusp1par;
               (*par2)[0] = tpar2;
               for(i=0; i< 3; i++)
               {
                  (*pt1)[0][i] = tpt1[i];
                  (*pt2)[0][i] = tpt2[i];
               }
            }
         }
         if( closecusp2 )
         {
            BScveval(pcurve2,closecusp2par,num_deriv,(IGRpoint *)tpt2,rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSmdstptcv(pcurve1,tpt2,&tpar1,tpt1,&dist2,rc);
            if( BSERROR( *rc ) ) goto wrapup;
            if( dist2 < *dist )
            {            
               *dist = dist2; 
               (*par1)[0] = tpar1;
               (*par2)[0] = closecusp2par;
               for(i=0; i< 3; i++)
               {
                  (*pt1)[0][i] = tpt1[i];
                  (*pt2)[0][i] = tpt2[i];
               }
            }
         }
         if( savedist < *dist )
         {
            (*par1)[0] = savepar1 ;
            (*par2)[0] = savepar2 ;
            for(i=0; i<3; i++)
            {
               (*pt1)[0][i] = savept1[i] ;
               (*pt2)[0][i] = savept2[i] ;
            }
            *dist = savedist ;
            *num = 1;
         }
         *num =1 ;
      }   
   }
   else
   {
      /* we did find a solution */
      dist2 = BSdistptpt(rc,line1.poles,&line1.poles[3]);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      if( dist2 < *dist )
      {
         *num = 1;
         *dist = dist2; 
         (*par1)[0] = tpar1;
         (*par2)[0] = tpar2;
         for(i=0; i< 3; i++)
         {
            (*pt1)[0][i] = line1.poles[i];
            (*pt2)[0][i] = line1.poles[i+3];
         }
      }
      else
      {
         /* find neighborhoods around (*par1)[0] and (*par2)[0]  */

         BSfndneighb((*par1)[0],numvals1,ndvals1,ind1,knot_tol1,
                     pcurve1->phy_closed,neig1,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         BSfndneighb((*par2)[0],numvals2,ndvals2,ind2,knot_tol2,
                      pcurve2->phy_closed,neig2,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }

         BSmdstccgtc(pcurve1,pcurve2,neig1,neig2,knot_tol1,knot_tol2,
                     &(*par1)[0],&(*par2)[0],(*pt1)[0],(*pt2)[0],dist,rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         if( closecusp1 )
         {
            BScveval(pcurve1,closecusp1par,num_deriv,(IGRpoint *)tpt1,rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSmdstptcv(pcurve2,tpt1,&tpar2,tpt2,&dist2,rc);
            if( BSERROR( *rc ) ) goto wrapup;
            if( dist2 < *dist )
            {            
               *dist = dist2; 
               (*par1)[0] = closecusp1par;
               (*par2)[0] = tpar2;
               for(i=0; i< 3; i++)
               {
                  (*pt1)[0][i] = tpt1[i];
                  (*pt2)[0][i] = tpt2[i];
               }
            }
         }
         if( closecusp2 )
         {
            BScveval(pcurve2,closecusp2par,num_deriv,(IGRpoint *)tpt2,rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSmdstptcv(pcurve1,tpt2,&tpar1,tpt1,&dist2,rc);
            if( BSERROR( *rc ) ) goto wrapup;
            if( dist2 < *dist )
            {            
               *dist = dist2; 
               (*par1)[0] = tpar1;
               (*par2)[0] = closecusp2par;
               for(i=0; i< 3; i++)
               {
                  (*pt1)[0][i] = tpt1[i];
                  (*pt2)[0][i] = tpt2[i];
               }
            }
         }
         *num = 1;
      }
   }
   if( p1bool && !p2bool )
   {
      BSmdstptcv(pcurve2,savept1,&tpar2,tpt2,&dist2,rc);
      if( BSERROR( *rc ) ) goto wrapup;
      if( dist2 < *dist )
      {
         *num = 1;
         *dist = dist2; 
         (*par2)[0] = tpar2;
         (*par1)[0] = savepar1;
         for(i=0; i< 3; i++)
         {
            (*pt2)[0][i] = tpt2[i];
            (*pt1)[0][i] = savept1[i];
         }
      }
      else
      {
         *num = 1;
      }
   }
   else
   {
      if( !p1bool && p2bool )
      {
         BSmdstptcv(pcurve1,savept2,&tpar1,tpt1,&dist2,rc);
         if( BSERROR( *rc ) ) goto wrapup;
         if( dist2 < *dist )
         {
            *num = 1;
            *dist = dist2; 
            (*par1)[0] = tpar1;
            (*par2)[0] = savepar2;
            for(i=0; i< 3; i++)
            {
               (*pt1)[0][i] = tpt1[i];
               (*pt2)[0][i] = savept2[i];
            }
         }
         else
         {
            *num = 1;
         }
      }
      else
      {
         if( p1bool && p2bool )
         {   
            if( savedist < *dist )
            {
               (*par1)[0] = savepar1 ;
               (*par2)[0] = savepar2 ;
               for(i=0; i<3; i++)
               {
                  (*pt1)[0][i] = savept1[i] ;
                  (*pt2)[0][i] = savept2[i] ;
               }
               *dist = savedist ;
               *num = 1;
            }
         }
      }
   }  
   if( planar == 2 )
   {
      /* planar == 2, means that the original curves were in
         parallel planes and were projected to the same plane..
         therefore we have to evalute the parameters with the
         original curves to get correct points */
      BScveval(curve1, (*par1)[0],num_deriv,(IGRpoint *)(*pt1)[0], rc);
      if(BSERROR(*rc))
         goto wrapup;
      BScveval(curve2,(*par2)[0],num_deriv, (IGRpoint *)(*pt2)[0], rc);
      *dist = BSdistptpt(rc,(*pt1)[0],(*pt2)[0]);
   }
         

      
   wrapup:
  
   if( BSERROR(*rc))
   {
      if( *par1 )
         BSdealloc((char *)*par1 );
      if( *par2 )
         BSdealloc((char *)*par2 );
      if( *pt1 )
         BSdealloc((char *)*pt1 );
      if( *pt2 )
         BSdealloc((char *)*pt2 );
   }
    
   if( tmul )
   {
      BSstackdealloc((char *)tmul);
   }
   if( points2 )
   {
      BSstackdealloc((char *)points2);
   }
   if( ndvals2)
   {
      BSstackdealloc((char *)ndvals2);
   }
   if( points1 )
   {
      BSstackdealloc((char *)points1);
   }
   if( ndvals1)
   {   
      BSstackdealloc((char *)ndvals1);
   }
   if( insertarr1 )
   {
      BSstackdealloc((char *) insertarr1 );
   }      
   if( insertarr2 )
   {
      BSstackdealloc((char *) insertarr2 );
   }      
   if( n_int > 0 || nover > 0 || degen1 || degen2)
   {
      if( par00 )
      {
         BSdealloc((char *)par00);
      }
      if( par01 )
      {
         BSdealloc((char *)par01 );
      }
      if(over1 )
      {
         BSdealloc((char *)over1 );
      }
      if( over2 )
      {
         BSdealloc((char *)over2 );
      }
      if( intpts )
      {
         BSdealloc((char *)intpts);
      }
      if( endpts )
      {
         BSdealloc((char *)endpts);
      }
   }
   if( planar == 2 )
   {
      if( p2knots && pcurve2->knots)
         BSstackdealloc((char *)pcurve2->knots );
      if( p2weights && pcurve2->weights)
         BSstackdealloc((char *)pcurve2->weights );
      if( p2poles && pcurve2->poles)
         BSstackdealloc((char *)pcurve2->poles );
      if( p1knots && pcurve1->knots)
         BSstackdealloc((char *)pcurve1->knots );
      if( p1weights && pcurve1->weights)
         BSstackdealloc((char *)pcurve1->weights );
      if( p1poles && pcurve1->poles)
         BSstackdealloc((char *)pcurve1->poles );
   }

  if(BSERROR(*rc))
      BSdbgrc(*rc,"BSmdistcvcv");
  return;
 }
