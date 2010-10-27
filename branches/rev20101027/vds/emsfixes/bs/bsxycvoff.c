/* $Id: bsxycvoff.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bsxycvoff.c
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: bsxycvoff.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/06/24  14:51:46  pinnacle
 * tr179801103
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/24/98  ah      TR179801103 Offset curve, code modified by bspmath group
 ***************************************************************************/

/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
      BSxycvoff

Abstract
      This routine offsets the curve only on xy plane. (used by BScvoffset)

Synopsis
      void BSxycvoff(cv, d, code1, normal, right_side, off_cv, rc)
      struct IGRbsp_curve *cv
      IGRdouble           d
      IGRboolean          code1
      IGRvector           normal
      IGRint              right_side
      struct IGRbsp_curve **off_cv
      BSrc                *rc

Description
      Input:
         cv - a B-spline curve
         d - offset distance
         code1 - FALSE, if extending
                 TRUE, if filleting
         normal - if 2-D, normal to the planar curve
                  if 3-D, view normal
         right_side - 1, if T x normal = offset direction.(T is tangent of
                         a point on cv.
                      -1, if T x normal = opposite to offset direction.

      Output:
         off_cv - the offset curve
         rc - return error message

Return Values
      If succeed, rc = BSSUCC; else, rc = error message.

Notes

Index
    md

Keywords

History
      Y. S. Sheng 10/29/87 : Creation date.
      Y. S. Sheng 12/17/87 : modified to make special case for single
                             span offset.
      Y. S. Sheng 12/22/87 : Set all the pointers to NULL after free.
      Y. S. Sheng 01/04/88 : If offset distance = 0, copy the input curve 
                             to the output curve.
      Vivian W.Ye 05/12/88 : Free curve last and span.
      C. S. Kirby 09/07/88 : Remove unused variables to correct lint
                             errors.
      D. Breden   10/19/88:  Fixed problem in setting *rc in case of
                             going to wrapup because of an error and
                             then freeing span[i] using rc1.
     S.G. Catron  02/16/89 : It was not freeing the curve "last", when an
                             error occurred.
     S.G. Catron  02/22/89 : Changed BSmdistptcv to BSmdstptcv, so only
                             one parameter is returned and no overlaps.
     S. C. Wood   07/14/89 : Added code to handle 3-D offset cases by checking
                             distance between consecutive offset curves if
                             BS2cvsoffpg returns after_int = TRUE meaning
                             these 2 offset curves intersect.  If distance
                             > dist_tol, this is an apparent intersection
                             (intersect in relation to x & y but not z);
                             therefore, construct a line joining these 2
                             curves and merge.  Also, copied last offset
                             curve into new curve (off2_temp) and set z 
                             values of off2_temp equal 0.0 when calling
                             BSmdstptcv to find the parameter at minimum
                             distance from off2_temp and ret_pt.
     S. C. Wood   02/13/90 : Added code to add 5 knots to cv if cv->order=3
                             and cv->num_poles = 3 and the angle of the
                             polygon <= 10 degrees when number of multiple
                             knots of (order - 1) = 0.  This modification 
                             results in better original offset; therefore, 
                             reaching desired offset with less iterations
                             for very steep, k=3, N=3 curves.  Perform same
                             operation on each "span" resulting from breaking
                             input curve at each multiple knot of (order - 1)
                             prior to calling BS2cvsoffpg.
     S. C. Wood   03/01/90 : Insert knots for steep, order 3, 3 pole curves
                             only if dotp < -.9848 (cosine of 170 degrees)
                             in addktsBSxycvoff.
     S. C. Wood   07/12/90 : Corrected lint errors.
     S. C. Wood   08/14/90 : Initialize curves in new_span array to NULL. 
     S. C. Wood   01/14/92 : If current merged offset curves (off1) has
                             phy_closed bit = TRUE, set bit = FALSE before
                             calling BScomb2cvs.  Offset of a curve should
                             only be closed at end of curve.
     S. C. Wood   07/20/93 : When splitting last span of offset curve at 
                             intersection with previous span of offset curve, 
                             check to be sure that parameter of split point
                             is not end of last span before calling
                             BSactivsplt.  If at start or end, call BScv_copy
                             instead of BSactivsplt.
     S.G. Catron  09//97   : Added code to help with offsets becoming degenerate.
                             Checks after BS2cvsoffpg.
    Vivian Y.Hsu 12/10/97  :  Fixed compile warning of gcc in PCSOL.
    S.G. Catron  02/05/98  : Not freeing all memory for certain cases.
                             At wrapup, check if off12 curve needs to 
                             be freed.
    Vivian Y.Hsu 06/05/98  : If rc = BSWARN returned from BS2cvsoffpg,
                             go on to the end, then return it.
*/
#include <math.h>
#define BSVOID
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#include "bsstackalloc.h"


static void addktsBSxycvoff(
struct
  IGRbsp_curve *incv,
struct
  IGRbsp_curve **outcv,
BSrc           *rc )
{
#include "bsnorvec.h"
#include "bscv_copy.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsadd_kts.h"
#include "bsalloccv.h"

   IGRint     i;
   IGRvector  vec1, vec2;
   IGRpoint   point1, point2, point3;
   IGRdouble  dist1, dist2, new_knots[11], delta, dotp;
   IGRlong    npoles;
   IGRboolean status;

   /* If incv->order == 3 and incv->num_poles == 3 and if angle < 10 degrees, 
      insert knots in neighborhood of parameter associated with turning point
      of incv in order to generate a desired offset for steep curves. */

   if (incv->order == 3 && incv->num_poles == 3)
   {
      for (i = 0; i < 3; ++i)
      {
          if (!incv->rational)
          {
             vec1[i] = incv->poles[i + 3] - incv->poles[i];
             vec2[i] = incv->poles[i + 6] - incv->poles[i + 3];
          }
          else
          {
             vec1[i] = incv->poles[i + 3] / incv->weights[1] - 
                          incv->poles[i] / incv->weights[0];
             vec2[i] = incv->poles[i + 6] / incv->weights[2] - 
                          incv->poles[i + 3] / incv->weights[1];
          }
      }

      status = BSnorvec(rc, vec1);
      if (BSERROR(*rc))
         goto wrapup;

      status = BSnorvec(rc, vec2);
      if (BSERROR(*rc))
         goto wrapup;

      dotp = BSdotp(rc, vec1, vec2);

      /* Note: cosine of 10 degrees = .9848077 */
      if (dotp < -.9848)
      {
         for (i = 0; i < 3; ++i)
         {
             if (incv->rational)
             {
                point1[i] = incv->poles[i] / incv->weights[0];
                point2[i] = incv->poles[i+3] / incv->weights[1];
                point3[i] = incv->poles[i+6] / incv->weights[2];
             }
             else
             {
                point1[i] = incv->poles[i];
                point2[i] = incv->poles[i+3];
                point3[i] = incv->poles[i+6];
             }
         }

         dist1 = BSdistptpt(rc, point1, point2);
         if (BSERROR(*rc)) 
            goto wrapup;

         dist2 = BSdistptpt(rc, point2, point3);
         if (BSERROR(*rc)) 
            goto wrapup;

         /* Calculate new knot vector with 5 new knots in the neighborhood
            of the peak of the curve. */
         new_knots[0] = 0.0;
         new_knots[1] = 0.0;
         new_knots[2] = 0.0;

         new_knots[5] = dist1 / (dist1 + dist2);
   
         delta = new_knots[5] / 100;
         new_knots[4] = new_knots[5] - delta;
         new_knots[3] = new_knots[5] - 2.5 * delta;

         delta = (1.0 - new_knots[5]) / 100;
         new_knots[6] = new_knots[5] + delta;
         new_knots[7] = new_knots[5] + 2.5 * delta;

         new_knots[8] = 1.0;
         new_knots[9] = 1.0;
         new_knots[10] = 1.0;

         npoles = incv->num_poles + 5;
         BSalloccv(incv->order, npoles, incv->rational, 0, outcv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         BSadd_kts(incv, npoles, new_knots, *outcv, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }
      else
      { 
         BSalloccv(incv->order, incv->num_poles, incv->rational, 0, outcv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         status = BScv_copy(rc, incv, *outcv);
         if(! status) 
            goto wrapup;
      }   /* end if (ABS(dotp) > .9848) */
   }
   else
   {
      BSalloccv(incv->order, incv->num_poles, incv->rational, 0, outcv, rc);
      if(BSERROR(*rc)) 
        goto wrapup;

      status = BScv_copy(rc, incv, *outcv);
      if(! status) 
         goto wrapup;
   }   /* end if (incv->order == 3 && incv->num_poles == 3) */

   wrapup:

   return;
}

void BSxycvoff(
struct IGRbsp_curve *cv,
IGRdouble           d,
IGRboolean          code1,
IGRvector           normal,
IGRint              right_side,
struct IGRbsp_curve **off_cv,
BSrc                *rc )
{
#include "bsdbgrc.h"
#include "bsspnoffset.h"
#include "bscvkttol2.h"
#include "bsofrparcv.h"
#include "bsalloccv.h"
#include "bs2cvsoffpg.h"
#include "bsofupdeg.h"
#include "bsofmkcls.h"
#include "bsmdstptcv.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bsmergecvnn.h"
#include "bscomb2cvs.h"
#include "bsadd_kts.h"
#include "bsfreecv.h"
#include "bsnorvec.h"
#include "bscv_copy.h"
#include "bsbreakcv.h"
#include "bscvsplit.h"
#include "bsactivsplt.h"
#include "bsfindmkts.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

    IGRboolean status = TRUE;
    IGRboolean rat, gap, planar = TRUE;
    IGRboolean after_int, tst_plan = FALSE;
    IGRshort   order;
    IGRint     i, j, k = 0, l = 0, ii;
    IGRint     degen,num_span,num_mul;
    IGRint     *index = NULL;
    IGRint     position;
    IGRint     nr_poles;
    IGRdouble  ts, te, tt, tmid = 0.0;
    IGRdouble  *tmul = NULL, *rmul = NULL;
    IGRdouble  knot_tol,knot_tol2,zero_tol,dist,par;
    IGRpoint   ret_pt, point;
    IGRdouble  dist_tol, temp;
    IGRint     n1 = 0, n2 = 0, wt1 = 0, wt2 = 0;
    IGRlong    npoles;
    struct IGRbsp_curve *off1 = NULL, *off2 = NULL,
                        *off3 = NULL, *off12 = NULL,
                        *off23 = NULL, *temp_cv = NULL,
                        *act_cur = NULL, *last = NULL;
    struct IGRbsp_curve *tmp_off3 = NULL,
                        *temp1_cv = NULL, **span = NULL, 
                        **new_span = NULL, *off2_temp = NULL, 
                        *new_cv = NULL;
    BSrc      rc1 = BSSUCC, rco = BSSUCC;

    *rc = BSSUCC;
    *off_cv = NULL;
    
    BSEXTRACTPAR(rc, BSTOLCLOSETOZERO, zero_tol);

   if( fabs(d) < zero_tol )
   {
     BSalloccv(cv->order, cv->num_poles, cv->rational, 0, off_cv, rc);
     if(BSERROR(*rc)) 
       goto wrapup;
   
     status = BScv_copy(rc, cv, *off_cv);
     if(! status) 
       goto wrapup;
   }
   else
   {
      /*****************
        Break the curve at multiple knots of multiplicity of order - 1
      ******************/

      if(cv->num_poles > cv->order)
      {
        tmul = (IGRdouble *)BSstackalloc((unsigned)(cv->num_knots * sizeof
                         (IGRdouble)));
        if(! tmul)
        {
           *rc = BSNOSTKMEMORY;
           goto wrapup;
        }

        index = (IGRint *)BSstackalloc((unsigned)(cv->num_knots * sizeof(
                    IGRint)));
        if(! index)
        {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
        }

        BScvkttol2(cv->order, cv->knots, cv->num_poles, cv->poles,
                          cv->weights, &knot_tol2, rc);
        if(BSERROR(*rc)) 
          goto wrapup;

        status = BSfindmkts(rc, &cv->order, &cv->num_poles, cv->knots,
                    &knot_tol2, &num_mul, tmul, index);
        if(! status) 
          goto wrapup;
     }
     else
     {
        num_mul = 0;
        num_span = 1;
     }

     if(num_mul == 0)
     {
         num_span = 1;

         /* If cv->order == 3 and cv->num_poles == 3 and if angle < 10 
            degrees, insert knots in neighborhood of parameter associated with
            turning point of cv in order to generate a desired offset for
            steep curves. */

         addktsBSxycvoff(cv, &new_cv, rc);
         if (BSERROR(*rc))
            goto wrapup;

         BSalloccv(new_cv->order, new_cv->num_poles, new_cv->rational, 0, 
                   &last, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         BSspnoffset(new_cv, d, normal, right_side, last, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         goto make_closed;    
     }
     else
     {
         /**------------------------
           more than one span exists
         ---------------------------**/

         status = BSbreakcv(rc,cv,&num_span,&span,&planar);
         if(! status) 
            goto wrapup;

         new_span = (struct IGRbsp_curve **)BSmalloc((unsigned)
                        (num_span * sizeof(struct IGRbsp_curve *)));
         for (i = 0; i < num_span; ++i)
         {
             new_span[i] = NULL;
         }

         npoles = 0;         

         for (i = 0; i < num_span; ++i)
         {
           addktsBSxycvoff(span[i], &new_span[i], rc);
           if (BSERROR(*rc))
              goto wrapup;
           npoles = npoles + new_span[i]->num_poles;
         }
 
         /********
            Reparameterize the knot vectors for broken spans
         *********/

         rmul = (IGRdouble *)BSstackalloc((unsigned)((num_mul + 2) * 
                      sizeof( IGRdouble)));
         if(! rmul)
         {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
         }

         rmul[0] = cv->knots[cv->order -1];
         rmul[num_mul + 1] = cv->knots[cv->num_poles];
         for(i=0; i < num_mul; i++)
         {
             rmul[i+1] = tmul[i];
         }

         for(i=0; i <= num_mul; i++)
         {
             ts = rmul[i];
             te = rmul[i+1];

             BSofrparcv(span[i],ts,te,rc);
             if(BSERROR(*rc)) 
               goto wrapup;
         }

         BSalloccv(cv->order, npoles, cv->rational, 0, &off1, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         BSalloccv(cv->order, npoles, cv->rational, 0, &off2, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         position = 1;
         degen = 4;
         i = 0;
         j = 1;                            
         after_int = FALSE;

         /** offset the 1st two spans **/

         while((i <= num_span -2) && (j <= num_span -1) && (degen != 0))
         {
             BS2cvsoffpg(new_span[i], new_span[j], position, d, code1,
                         right_side, normal, &after_int, ret_pt, off1, off2,
                         &gap, &off12, &degen, rc);
             if (*rc == BSWARN)
             {
               /* rc = BSWARN means that we have a solution with question.
                  The offset curve is not within the tolerance.
                  V.Hsu 6/5/98 */
                  
               rco = *rc;
               *rc = BSSUCC;
             }
             if(BSERROR(*rc)) 
               goto wrapup;

             if( degen == 2)
             {
                /** new_span[j] is degenerated **/

                j = j + 1;
             }
             else if(degen == 1)
             {
                /** new_span[i] is degenerated **/

                i = i + 1;
                j = j + 1;
             }
             else if(degen == 3)
             {
                /** both spans are degenerated **/
                if( num_span == 2 )
                {
                    *rc = BSNOSOLUTION;
                    goto wrapup;
                }
                i = i + 2;
                j = j + 2;
             }
             else
             {
                /** reparameterise off1 **/

                ts = cv->knots[cv->order -1];
                tmid = (new_span[i]->knots[new_span[i]->num_poles] + 
                          new_span[j]->knots[new_span[j]->order -1]) / 2;
                if(gap)
                {
                    BScvkttol2(off12->order,off12->knots,off12->num_poles,
                          off12->poles, off12->weights,&knot_tol, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    knot_tol = knot_tol * 1.1;
                    tmid = tmid - knot_tol;
                }

                BSofrparcv(off1, ts,tmid, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                k = j;
                l = j + 1;
             }
             /**--------------------------------------------------------
               Don't merge the offset spans yet, because the information
               for the spans will be used for modification during the
               next call.
             ---------------------------------------------------------**/
         }  /** end of while loop **/                          

         if( j < num_span -1 )
         {
            /** keep on offsetting and merging **/

            position = 2;  /** middle spans **/

            while((k <= num_span - 2) && (l <= num_span -1))
            {
               BSalloccv(new_span[l]->order, new_span[l]->num_poles, 
                         new_span[l]->rational, 0, &off3, rc);
               if(BSERROR(*rc)) 
                 goto wrapup;

               if(after_int)
               {
                  /** previous case is intersection case and off2 will be
                      remodified in this call to BS2cvsoffpg **/

                  BS2cvsoffpg(new_span[k], new_span[l], position, d, code1, 
                              right_side, normal, &after_int, ret_pt, 
                              off2, off3, &gap, &off23, &degen, rc);
                  if (*rc == BSWARN)
                  {
                    /* rc = BSWARN means that we have a solution 
                       with question. The offset curve is not within 
                       the tolerance.
                       V.Hsu 6/5/98 */
                  
                    rco = *rc;
                    *rc = BSSUCC;
                  }
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  if( degen == 2)
                  {
                     /** new_span[l] is degenerated **/
                     status = BSfreecv(rc, off3);
                     if(! status) 
                       goto wrapup;
                     off3 = NULL;
                     l = l + 1;
                  }
                  else if(degen == 1)
                  {
                     /** new_span[k] is degenerated **/
                     position = 5;
                     BS2cvsoffpg(new_span[k-1], new_span[l], position, 
                                 d, code1, 
                                 right_side, normal, &after_int, ret_pt, 
                                 off1, off3, &gap, &off23, &degen, rc);

                     if (*rc == BSWARN)
                     {
                       /* rc = BSWARN means that we have a solution 
                          with question. The offset curve is not within 
                          the tolerance. V.Hsu 6/5/98 */
                  
                       rco = *rc;
                       *rc = BSSUCC;
                     }
                     if(BSERROR(*rc)) 
                       goto wrapup;
		       
                     status = BSfreecv(rc, off2);
                     if(! status) 
                       goto wrapup;
                     off2 = off3;
                     off3 = NULL;
                     position = 2;                     
                     l = l + 1;
                     k = k + 1;
                  }
                  else if(degen == 3)
                  {
                     /** both spans are degenerated **/
                     if( num_span == 2 )
                     {
                        *rc = BSNOSOLUTION;
                        goto wrapup;
                     }
                     status = BSfreecv(rc, off3);
                     if(! status) 
                       goto wrapup;
                     off3 = NULL;

/*                     l = l + 1;
                     status = BSfreecv(rc, off3);
                     if(! status) 
                       goto wrapup;
                     off3 = NULL;

                     BSalloccv(new_span[l]->order, new_span[l]->num_poles, 
                               new_span[l]->rational, 0, &off3, rc);
                     if(BSERROR(*rc)) 
                        goto wrapup;
                     
                     BS2cvsoffpg(new_span[k-1], new_span[l], position, d, code1, 
                                 right_side, normal, &after_int, ret_pt, 
                                 off1, off3, &gap, &off23, &degen, rc);
                     if(BSERROR(*rc)) 
                       goto wrapup;
		       
                     status = BSfreecv(rc, off2);
                     if(! status) 
                       goto wrapup;
                     off2 = off3;
                     off3 = NULL;

                     k = k + 2;
                     l = l + 1;
*/ 		     
                     k = k + 2;
                     l = l + 2;
                  }
                  else
                  {

            /* Determine which end of off1 and off2 join with manually 
               constructed line for apparent intersections which actually
               do not intersect with respect to z-coordinated.
               Set n1 = pole number of off1 and n2 = pole number of off2
               at which to construct line. */

                     BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

                     /* Calculate x-y distance between end pole of off1 and
                        start pole of off2 */
                     dist = 0.0;
                     for (ii = 0; ii < 2; ++ii)
                     {
                         if (off1->rational && off2 ->rational)
                         {
                            temp = fabs(off1->poles[(off1->num_poles-1)*3+ii]/ 
                                        off1->weights[off1->num_poles - 1] -
                                        off2->poles[ii] / off2->weights[0]);
                         } 
                         else
                         {
                            if (off1->rational && !off2->rational)
                            {
                               temp = 
                                fabs(off1->poles[(off1->num_poles-1)*3+ii]/
                                     off1->weights[off1->num_poles - 1] -
                                     off2->poles[ii]);
                            }
                            else
                            {
                               if ( !off1->rational && off2->rational)
                               {
                                  temp = 
                                    fabs(off1->poles[(off1->num_poles-1)*3+ii]-
                                         off2->poles[ii] / off2->weights[0]);
                               }
                               else
                               {

                            /* off1 is non-rational and off2 is non-rational */
                                  temp = 
                                    fabs(off1->poles[(off1->num_poles-1)*3+ii]-
                                         off2->poles[ii]);
                               }
                            }
                         }
                         dist += (temp * temp);

                     }  /* end for ii loop */
                     dist = sqrt(dist);
                     
                     if (dist < dist_tol)
                     {
                        n1 = (off1->num_poles - 1) * 3;
                        wt1 = off1->num_poles - 1;
                        n2 = 0;
                        wt2 = 0;
	             }
	             else
	             {
		        /* Calculate x-y distance between end pole of off1 and
                           end pole of off2 */
                        dist = 0.0;
                        for (ii = 0; ii < 2; ++ii)
                        {
                            if (off1->rational && off2 ->rational)
                            {
                               temp = 
                                 fabs(off1->poles[(off1->num_poles-1)*3+ii]/ 
                                      off1->weights[off1->num_poles - 1] -
                                      off2->poles[(off2->num_poles-1)*3+ii] / 
                                      off2->weights[off2->num_poles - 1]);
                            } 
                            else
                            {
                               if (off1->rational && !off2->rational)
                               {
                                  temp = 
                                   fabs(off1->poles[(off1->num_poles-1)*3+ii]/
                                        off1->weights[off1->num_poles - 1] -
                                        off2->poles[(off2->num_poles-1)*3+ii]);
                               }
                               else
                               {
                                  if ( !off1->rational && off2->rational)
                                  {
                                     temp = 
                                       fabs
                                        (off1->poles[(off1->num_poles-1)*3+ii]-
                                        off2->poles[(off2->num_poles-1)*3+ii] /
                                        off2->weights[off2->num_poles-1]);
                                  }
                                  else
                                  {

                            /* off1 is non-rational and off2 is non-rational */
                                     temp = 
                                      fabs 
                                      (off1->poles[(off1->num_poles-1)*3+ii]-
                                       off2->poles[(off2->num_poles-1)*3+ii]);
                                  }
                               }
                            }
                            dist += (temp * temp);
   
                        }  /* end for ii loop */
                        dist = sqrt(dist);

                        if (dist < dist_tol)
                        {
                           n1 = (off1->num_poles - 1) * 3;
                           wt1 = off1->num_poles - 1;
                           n2 = (off2->num_poles - 1) * 3;
                           wt2 = off2->num_poles - 1;
	                }
	                else
	                {
                        /* Calculate x-y distance between start pole of off1 
                           and end pole of off2 */
                           dist = 0.0;
                           for (ii = 0; ii < 2; ++ii)
                           {
                               if (off1->rational && off2 ->rational)
                               {
                                  temp = 
                                    fabs(off1->poles[ii] / off1->weights[0] -
                                         off2->poles[(off2->num_poles-1)*3+ii]
                                        / off2->weights[off2->num_poles - 1]);
                               } 
                               else
                               {
                                  if (off1->rational && !off2->rational)
                                  {
                                     temp = 
                                      fabs(off1->poles[ii] / off1->weights[0] -
                                        off2->poles[(off2->num_poles-1)*3+ii]);
                                  }
                                  else
                                  {
                                     if ( !off1->rational && off2->rational)
                                     {
                                        temp = 
                                          fabs
                                           (off1->poles[ii]-
                                          off2->poles[(off2->num_poles-1)*3+ii]
                                          / off2->weights[off2->num_poles-1]);
                                     }
                                     else
                                     {

                            /* off1 is non-rational and off2 is non-rational */
                                        temp = 
                                        fabs(off1->poles[ii] -
                                        off2->poles[(off2->num_poles-1)*3+ii]);
                                     }
                                  }
                               }
                               dist += (temp * temp);
   
                           }  /* end for ii loop */
                           dist = sqrt(dist);

                           if (dist < dist_tol)
                           {
                              n1 = 0;
                              wt1 = 0;
                              n2 = (off2->num_poles - 1) * 3;
                              wt2 = off2->num_poles - 1;
	                   }
	                   else
	                   {
                           /* Calculate x-y distance between start pole of off1
                              and start pole of off2 */
                              dist = 0.0;
                              for (ii = 0; ii < 2; ++ii)
                              {
                                  if (off1->rational && off2 ->rational)
                                  {
                                     temp = 
                                     fabs(off1->poles[ii]/off1->weights[0] -
                                          off2->poles[ii]/off2->weights[0]);
                                  } 
                                  else
                                  {
                                     if (off1->rational && !off2->rational)
                                     {
                                        temp = fabs(off1->poles[ii] /
                                                    off1->weights[0] -
                                                    off2->poles[ii]);
                                     }
                                     else
                                     {
                                        if ( !off1->rational && 
                                              off2->rational)
                                        {
                                           temp = fabs(off1->poles[ii]-
                                                       off2->poles[ii] /
                                                       off2->weights[0]);
                                        }
                                        else
                                        {

                            /* off1 is non-rational and off2 is non-rational */
                                           temp = 
                                           fabs(off1->poles[ii] -
                                                off2->poles[ii]);
                                        }
                                     }
                                  }
                                  dist += (temp * temp);
      
                              }  /* end for ii loop */
                              dist = sqrt(dist);
                              if (dist < dist_tol)
                              {
                                 n1 = 0;
                                 wt1 = 0;
                                 n2 = 0;
                                 wt2 = 0;
                              }

                           }   /* end if dist */
                        }   /* end if dist */

                     }   /* end if dist */

            /* Calculate x-y-z distance between appropriate off1 pole and
               appropriate off2 pole (calc. above, indicated by n1 & n2).
               If this distance > dist_tol, construct a line between off1 
               and off2 */

                     dist = 0.0;
                     for (ii = 0; ii < 3; ++ii)
                     {
                         if (off1->rational && off2 ->rational)
                         {
                            temp = fabs(off1->poles[n1 + ii] /
                                        off1->weights[wt1] -
                                        off2->poles[n2 + ii] / 
                                        off2->weights[wt2]);
                         } 
                         else
                         {
                            if (off1->rational && !off2->rational)
                            {
                               temp = 
                                fabs(off1->poles[n1 + ii] / off1->weights[wt1]
                                     - off2->poles[n2 + ii]);
                            }
                            else
                            {
                               if ( !off1->rational && off2->rational)
                               {
                                  temp = 
                                    fabs(off1->poles[n1 + ii] -
                                         off2->poles[n2 + ii] / 
                                         off2->weights[wt2]);
                               }
                               else
                               {

                            /* off1 is non-rational and off2 is non-rational */
                                  temp = 
                                    fabs(off1->poles[n1 + ii] -
                                         off2->poles[n2 + ii]);
                               }
                            }
                         }
                         dist += (temp * temp);
                     }
                     dist = sqrt(dist);

                     if (dist > dist_tol)
                     {
                       /* Construct line connecting off1 and off2 */
   
                        BSalloccv(2, 2, FALSE, 0, &off12, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        off12->order = 2;
                        off12->num_poles = 2;
                        off12->periodic = 0;
                        off12->non_uniform = 1;

                        if (! off1->rational)
                        {
                           off12->poles[0] = off1->poles[n1];
                           off12->poles[1] = off1->poles[n1 + 1];
                           off12->poles[2] = off1->poles[n1 + 2];
                        }
                        else
                        {
                           off12->poles[0] = off1->poles[n1] /
                                               off1->weights[wt1];
                           off12->poles[1] = off1->poles[n1 + 1] /
                                               off1->weights[wt1];
                           off12->poles[2] = off1->poles[n1 + 2] /
                                               off1->weights[wt1];
                        }

                        if (! off2->rational)
                        {
                           off12->poles[3] = off2->poles[n2];
                           off12->poles[4] = off2->poles[n2 + 1];
                           off12->poles[5] = off2->poles[n2 + 2];
                        }
                        else
                        {
                           off12->poles[3] = off2->poles[n2] / 
                                               off2->weights[wt2];
                           off12->poles[4] = off2->poles[n2 + 1] / 
                                               off2->weights[wt2];
                           off12->poles[5] = off2->poles[n2 + 2] / 
                                               off2->weights[wt2];
                        }

                        off12->rational = 0;
                        off12->num_knots = 4;
                        off12->knots[0] = 0.0;   
                        off12->knots[1] = 0.0;
                        off12->knots[2] = 1.0;
                        off12->knots[3] = 1.0;

                        off12->planar = 0;
                        off12->phy_closed = 0;
                        off12->num_boundaries = 0;


                        /** merge off1,off12 and off2 and assign the result 
                            curve to off1 for the next merge **/

                        BSofupdeg(off1, off12, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc))
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp1_cv, rc);
                        if(BSERROR(*rc))
                          goto wrapup;

                        BScvkttol2(off12->order,off12->knots,off12->num_poles,
                          off12->poles, off12->weights,&knot_tol, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        knot_tol = knot_tol * 1.1;
                        te = new_span[k]->knots[new_span[k]->order -1] +
                               knot_tol;
                        BSofrparcv(off12, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSmergecvnn(off1, off12, temp1_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BSfreecv(rc, off1);
                        if(! status) 
                          goto wrapup;
                        off1 = NULL;

                        status = BSfreecv(rc, off12);
                        if(! status) 
                          goto wrapup;
                        off12 = NULL;
                   
                        BSofupdeg(temp1_cv, off2, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        tmid = te;
                        te = (new_span[k]->knots[new_span[k]->num_poles] +
                               new_span[l]->knots[new_span[l]->order -1]) / 2;
                        if(gap)
                        {
                            BScvkttol2(off23->order,off23->knots,
                              off23->num_poles, off23->poles, off23->weights,
                              &knot_tol, rc);
                            if(BSERROR(*rc)) 
                              goto wrapup;

                            knot_tol = knot_tol * 1.1;
                            te = te - knot_tol;
                        }
                       
                        BSofrparcv(off2, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSmergecvnn(temp1_cv, off2, temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        off1 = temp_cv;

                        status = BSfreecv(rc, temp1_cv);
                        if(! status) 
                          goto wrapup;
                        temp1_cv = NULL;

                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = NULL;

                        tmid = te;

                        BSalloccv(off3->order, off3->num_poles, off3->rational,
                             0, &tmp_off3, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BScv_copy(rc, off3, tmp_off3);
                        if(! status) 
                          goto wrapup;

                        off2 = tmp_off3;

                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        off12 = off23;

                     }
                     else
                     {
	
                     /** merge off1 and off2 and assign the result curve
                         to off1 for the next merge **/

                         BSofupdeg(off1, off2, &order, &rat,
                                   (IGRlong *) &nr_poles, rc);
                         if(BSERROR(*rc)) 
                           goto wrapup;

                         BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                         if(BSERROR(*rc)) 
                           goto wrapup;

                        te = (new_span[k]->knots[new_span[k]->num_poles] + 
                                new_span[l]->knots[new_span[l]->order -1])/ 2;
                        if(gap)
                        {
                           BScvkttol2(off23->order,off23->knots,
                                      off23->num_poles,off23->poles, 
                                      off23->weights,&knot_tol, rc);
                           if(BSERROR(*rc)) 
                             goto wrapup;

                           knot_tol = knot_tol * 1.1;
                           te = te - knot_tol;
                         }
                         BSofrparcv(off2, tmid, te, rc);
                         if(BSERROR(*rc)) 
                           goto wrapup;

                         BSmergecvnn(off1, off2, temp_cv, rc);
                         if(BSERROR(*rc)) 
                           goto wrapup;
  
                         status = BSfreecv(rc, off1);
                         if(! status) 
                           goto wrapup;
                         off1 = NULL;
   
                         status = BSfreecv(rc, off2);
                         if(! status) 
                           goto wrapup;
                         off2 = NULL;
                      
                         tmid = te;

                         off1 = temp_cv;
  
                         off2 = off3;

                         off3 = NULL;

                         if( gap)
                         {
                            off12 = off23;
                         }
          
                     }
                     k = l;
                     l = l + 1;
                  }
               }
               else
               {
                  /** non-intersect case **/

                  if( gap )
                  {
                     /** extend or filleting case **/

                     BS2cvsoffpg(new_span[k], new_span[l], position, d, code1, 
                       right_side,normal, &after_int, ret_pt, off2, off3, 
                       &gap, &off23, &degen, rc);
                     if (*rc == BSWARN)
                     {
                       /* rc = BSWARN means that we have a solution 
                       with question. The offset curve is not within 
                       the tolerance.
                       V.Hsu 6/5/98 */
                  
                       rco = *rc;
                       *rc = BSSUCC;
                     }
                     if(BSERROR(*rc)) 
                       goto wrapup;

                     if( degen == 2)
                     {
                        /** new_span[l] is degenerated **/
                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        l = l + 1;
                     }
                     else if(degen == 1)
                     {
                        /** new_span[k] is degenerated **/
                        position = 5;
                        BS2cvsoffpg(new_span[k-1], new_span[l], position, d, code1, 
                                    right_side, normal, &after_int, ret_pt, 
                                   off1, off3, &gap, &off23, &degen, rc);
                        if (*rc == BSWARN)
                        {
                          /* rc = BSWARN means that we have a solution 
                          with question. The offset curve is not within 
                          the tolerance.
                          V.Hsu 6/5/98 */
                  
                          rco = *rc;
                          *rc = BSSUCC;
                        }
                        if(BSERROR(*rc)) 
                          goto wrapup;
                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = off3;
                        off3 = NULL;
                        position = 2;                     
                        l = l + 1;
                        k = k + 1;
                     }
                     else if(degen == 3)
                     {
                        /** both spans are degenerated **/
                        if( num_span == 2 )
                        {
                           *rc = BSNOSOLUTION;
                           goto wrapup;
                        }
                     status = BSfreecv(rc, off3);
                     if(! status) 
                       goto wrapup;
                     off3 = NULL;

/*                        l = l + 1;
                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        BSalloccv(new_span[l]->order, new_span[l]->num_poles, 
                                  new_span[l]->rational, 0, &off3, rc);
                        if(BSERROR(*rc)) 
                           goto wrapup;
                     
                        BS2cvsoffpg(new_span[k-1], new_span[l], position, d, code1, 
                                    right_side, normal, &after_int, ret_pt, 
                                    off1, off3, &gap, &off23, &degen, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;
		       
                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = off3;
                        off3 = NULL;
 
                        k = k + 2;
                        l = l + 1;
*/
                        k = k+2;
                        l = l + 2;			
                     }
                     else
                     {
                        /** merge off1,off12 and off2 and assign the result 
                            curve to off1 for the next merge **/
                     
                        BSofupdeg(off1, off12, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp1_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BScvkttol2(off12->order,off12->knots,off12->num_poles,
                          off12->poles, off12->weights,&knot_tol, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        knot_tol = knot_tol * 1.1;
                        te = new_span[k]->knots[new_span[k]->order -1] +
                                knot_tol;
                        BSofrparcv(off12, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;


                        BSmergecvnn(off1, off12, temp1_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BSfreecv(rc, off1);
                        if(! status) 
                          goto wrapup;
                        off1 = NULL;

                        status = BSfreecv(rc, off12);
                        if(! status) 
                          goto wrapup;
                        off12 = NULL;
                   
                        BSofupdeg(temp1_cv, off2, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        tmid = te;
                        te = (new_span[k]->knots[new_span[k]->num_poles] +
                               new_span[l]->knots[new_span[l]->order -1]) / 2;
                        if(gap)
                        {
                            BScvkttol2(off23->order,off23->knots,
                              off23->num_poles, off23->poles, off23->weights,
                              &knot_tol, rc);
                            if(BSERROR(*rc)) 
                              goto wrapup;

                            knot_tol = knot_tol * 1.1;
                            te = te - knot_tol;
                        }
                       
                        BSofrparcv(off2, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSmergecvnn(temp1_cv, off2, temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        off1 = temp_cv;

                        status = BSfreecv(rc, temp1_cv);
                        if(! status) 
                          goto wrapup;
                        temp1_cv = NULL;

                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = NULL;

                        tmid = te;

                        BSalloccv(off3->order, off3->num_poles, off3->rational,
                             0, &tmp_off3, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BScv_copy(rc, off3, tmp_off3);
                        if(! status) 
                          goto wrapup;

                        off2 = tmp_off3;

                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        off12 = off23;

                        k = l;
                        l = l + 1;
                     }
                  }
                  else
                  {
                     /** merge case **/

                     BS2cvsoffpg(new_span[k], new_span[l], position, d, code1, 
                       right_side, normal, &after_int, ret_pt, off2, off3, 
                       &gap, &off23, &degen, rc);
                     if (*rc == BSWARN)
                     {
                       /* rc = BSWARN means that we have a solution 
                       with question. The offset curve is not within 
                       the tolerance.
                       V.Hsu 6/5/98 */
                  
                       rco = *rc;
                       *rc = BSSUCC;
                     }
                     if(BSERROR(*rc)) 
                       goto wrapup;

                     if( degen == 2)
                     {
                        /** new_span[l] is degenerated **/
                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        l = l + 1;
                     }
                     else if(degen == 1)
                     {
                        /** new_span[k] is degenerated **/
                        position = 5;
                        BS2cvsoffpg(new_span[k-1], new_span[l], position, d, code1, 
                                    right_side, normal, &after_int, ret_pt, 
                                   off1, off3, &gap, &off23, &degen, rc);
                        if (*rc == BSWARN)
                        {
                          /* rc = BSWARN means that we have a solution 
                          with question. The offset curve is not within 
                          the tolerance.
                          V.Hsu 6/5/98 */
                  
                          rco = *rc;
                          *rc = BSSUCC;
                        }

                        if(BSERROR(*rc)) 
                          goto wrapup;
                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = off3;
                        off3 = NULL;
                        position = 2;
                        l = l + 1;
                        k = k + 1;
                     }
                     else if(degen == 3)
                     {
                        /** both spans are degenerated **/
                        if( num_span == 2 )
                        {
                           *rc = BSNOSOLUTION;
                           goto wrapup;
                        }
                     status = BSfreecv(rc, off3);
                     if(! status) 
                       goto wrapup;
                     off3 = NULL;

/*                        l = l + 1;
                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                        BSalloccv(new_span[l]->order, new_span[l]->num_poles, 
                                  new_span[l]->rational, 0, &off3, rc);
                        if(BSERROR(*rc)) 
                           goto wrapup;
                     
                        BS2cvsoffpg(new_span[k-1], new_span[l], position, d, code1, 
                                    right_side, normal, &after_int, ret_pt, 
                                    off1, off3, &gap, &off23, &degen, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;
		       
                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = off3;
                        off3 = NULL;
 
                        k = k + 2;
                        l = l + 1;
*/
                        k = k+2;
                        l = l + 2;			

                     }
                     else
                     {
                        /** merge off1 and off2 and assign the result curve
                            to off1 for the next merge **/
  
                        BSofupdeg(off1, off2, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        te = (new_span[k]->knots[new_span[k]->num_poles] + 
                                new_span[l]->knots[new_span[l]->order -1]) / 2;
                        if(gap)
                        {
                          BScvkttol2(off23->order,off23->knots,
                             off23->num_poles, off23->poles, off23->weights,
                             &knot_tol, rc);
                          if(BSERROR(*rc)) 
                            goto wrapup;

                          knot_tol = knot_tol * 1.1;
                          te = te - knot_tol;
                          off12 = off23;
                        }
                        BSofrparcv(off2, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        if (off1->phy_closed)
                           off1->phy_closed = FALSE;

                        BScomb2cvs(off1, off2, temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BSfreecv(rc, off1);
                        if(! status) 
                          goto wrapup;
                        off1 = NULL;

                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = NULL;
                   
                        tmid = te;

                         BSalloccv(off3->order, off3->num_poles, 
                             off3->rational, 0, &tmp_off3, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BScv_copy(rc, off3, tmp_off3);
                        if(! status) 
                          goto wrapup;

                        off2 = tmp_off3;
                        off1 = temp_cv;
                        status = BSfreecv(rc, off3);
                        if(! status) 
                          goto wrapup;
                        off3 = NULL;

                         k = l;
                         l = l + 1;
                      }
                  } /** end of if(gap) **/
               } /** end of if(after_int) **/
            } /** end of while loop **/
         } /** end of if(j < num_span -1) **/

          /**--------------------------------
                Connect the last offset span
          ----------------------------------**/

          if( degen > 0 )
          {
              if( degen == 3 && i == num_span-1 )
              {
                 BSalloccv(new_span[i]->order, new_span[i]->num_poles, new_span[i]->rational, 0, 
                           &last, rc);
                 if(BSERROR(*rc)) 
                    goto wrapup;
                 BSspnoffset(new_span[i], d, normal, right_side, last, rc);
                 if(BSERROR(*rc)) 
                    goto wrapup;
              }
              else
              {
                 if( i == num_span -1 && degen == 1)
                 {
                    last = off2;
                    off2 = NULL;
                 }		    
                 else
                 {
                    last = off1;
                    off1 = NULL;
                 }		 
              }
          }
          else
          {
              if( after_int )
              {

             /* Split off2 at point in curve corresponding to intersection
                (or apparent intersection -- intersects in x & y but not z)*/

                 BSalloccv(off2->order, off2->num_poles, off2->rational,
                           0, &off2_temp, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 status = BScv_copy(rc, off2, off2_temp);
                 if(! status) 
                   goto wrapup;

                 for (i = 0; i < off2_temp->num_poles; ++i)
                      off2_temp->poles[3 * i + 2] = 0.0;

                 BSmdstptcv(off2_temp, ret_pt, &par, point, &dist, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 if(off2_temp)
                 {
                    status = BSfreecv(&rc1, off2_temp);
                    off2_temp = NULL;
                 }

                 BSalloccv(off2->order, off2->num_poles, off2->rational, 0, 
                           &act_cur, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 BScvkttol2(off2->order,off2->knots, off2->num_poles, 
                            off2->poles, off2->weights, &knot_tol, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;
                    
                 tt = off2->knots[off2->num_poles];
                 if (fabs(par - tt) < knot_tol)
                 {
                    status = BScv_copy(rc, off2, act_cur);
                    if(! status) 
                      goto wrapup;
                 }
                 else
                 {
                    status = BSactivsplt(rc, off2, &par, &tt, act_cur, 
                                         &tst_plan);
                    if(! status) 
                      goto wrapup;
                 }

            /* Determine which end of off1 and act_cur to join with manually 
               constructed line for apparent intersections which actually
               do not intersect with respect to z-coordinated.
               Set n1 = pole number of off1 and n2 = pole number of act_cur
               at which to construct line. */

                 BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

                 /* Calculate x-y distance between end pole of off1 and
                    start pole of act_cur */
                 dist = 0.0;
                 for (ii = 0; ii < 2; ++ii)
                 {
                     if (off1->rational && act_cur ->rational)
                     {
                        temp = fabs(off1->poles[(off1->num_poles-1)*3+ii]/ 
                                    off1->weights[off1->num_poles - 1] -
                                    act_cur->poles[ii] / act_cur->weights[0]);
                     } 
                     else
                     {
                        if (off1->rational && !act_cur->rational)
                        {
                           temp = 
                            fabs(off1->poles[(off1->num_poles-1)*3+ii]/
                                 off1->weights[off1->num_poles - 1] -
                                 act_cur->poles[ii]);
                        }
                        else
                        {
                           if ( !off1->rational && act_cur->rational)
                           {
                              temp = 
                                fabs(off1->poles[(off1->num_poles-1)*3+ii]-
                                     act_cur->poles[ii] / act_cur->weights[0]);
                           }
                           else
                           {

                        /* off1 is non-rational and act_cur is non-rational */
                              temp = 
                                fabs(off1->poles[(off1->num_poles-1)*3+ii]-
                                     act_cur->poles[ii]);
                           }
                        }
                     }
                     dist += (temp * temp);

                 }  /* end for ii loop */
                 dist = sqrt(dist);
                     
                 if (dist < dist_tol)
                 {
                    n1 = (off1->num_poles - 1) * 3;
                    wt1 = off1->num_poles - 1;
                    n2 = 0;
                    wt2 = 0;
                 }
                 else
	         {
		    /* Calculate x-y distance between end pole of off1 and
                       end pole of act_cur */
                    dist = 0.0;
                    for (ii = 0; ii < 2; ++ii)
                    {
                        if (off1->rational && act_cur ->rational)
                        {
                           temp = 
                             fabs(off1->poles[(off1->num_poles-1)*3+ii]/ 
                                  off1->weights[off1->num_poles - 1] -
                                  act_cur->poles[(act_cur->num_poles-1)*3+ii] /
                                  act_cur->weights[act_cur->num_poles - 1]);
                        } 
                        else
                        {
                           if (off1->rational && !act_cur->rational)
                           {
                              temp = 
                               fabs(off1->poles[(off1->num_poles-1)*3+ii]/
                                  off1->weights[off1->num_poles - 1] -
                                  act_cur->poles[(act_cur->num_poles-1)*3+ii]);
                           }
                           else
                           {
                              if ( !off1->rational && act_cur->rational)
                              {
                                 temp = 
                                   fabs
                                     (off1->poles[(off1->num_poles-1)*3+ii] -
                                      act_cur->poles
                                           [(act_cur->num_poles-1)*3+ii] /
                                      act_cur->weights[act_cur->num_poles-1]);
                              }
                              else
                              {

                        /* off1 is non-rational and act_cur is non-rational */
                                 temp = 
                                  fabs 
                                  (off1->poles[(off1->num_poles-1)*3+ii]-
                                   act_cur->poles
                                      [(act_cur->num_poles-1)*3+ii]);
                              }
                           }
                       }
                       dist += (temp * temp);
   
                    }  /* end for ii loop */
                    dist = sqrt(dist);

                    if (dist < dist_tol)
                    {
                       n1 = (off1->num_poles - 1) * 3;
                       wt1 = off1->num_poles - 1;
                       n2 = (act_cur->num_poles - 1) * 3;
                       wt2 = act_cur->num_poles - 1;
                    }
                    else
                    {
                   /* Calculate x-y distance between start pole of off1 
                      and end pole of act_cur */
                       dist = 0.0;
                       for (ii = 0; ii < 2; ++ii)
                       {
                           if (off1->rational && act_cur ->rational)
                           {
                              temp = 
                                fabs(off1->poles[ii] / off1->weights[0] -
                                   act_cur->poles
                                       [(act_cur->num_poles-1)*3+ii] /
                                   act_cur->weights[act_cur->num_poles - 1]);
                           } 
                           else
                           {
                              if (off1->rational && !act_cur->rational)
                              {
                                 temp = 
                                  fabs(off1->poles[ii] / off1->weights[0] -
                                       act_cur->poles
                                          [(act_cur->num_poles-1)*3+ii]);
                              }
                              else
                              {
                                 if ( !off1->rational && act_cur->rational)
                                 {
                                    temp = 
                                      fabs
                                       (off1->poles[ii]-
                                          act_cur->poles
                                             [(act_cur->num_poles-1)*3+ii] /
                                          act_cur->weights
                                             [act_cur->num_poles-1]);
                                 }
                                 else
                                 {

                       /* off1 is non-rational and act_cur is non-rational */
                                    temp = 
                                    fabs(off1->poles[ii] -
                                        act_cur->poles
                                           [(act_cur->num_poles-1)*3+ii]);
                                 }
                              }
                           }
                           dist += (temp * temp);
   
                       }  /* end for ii loop */
                       dist = sqrt(dist);

                       if (dist < dist_tol)
                       {
                          n1 = 0;
                          wt1 = 0;
                          n2 = (act_cur->num_poles - 1) * 3;
                          wt2 = act_cur->num_poles - 1;
                       }
	               else
	               {
                       /* Calculate x-y distance between start pole of off1
                          and start pole of act_cur */
                          dist = 0.0;
                          for (ii = 0; ii < 2; ++ii)
                          {
                              if (off1->rational && act_cur ->rational)
                              {
                                 temp = 
                                  fabs(off1->poles[ii]/off1->weights[0] -
                                    act_cur->poles[ii]/act_cur->weights[0]);
                              } 
                              else
                              {
                                 if (off1->rational && !act_cur->rational)
                                 {
                                    temp = fabs(off1->poles[ii] /
                                                off1->weights[0] -
                                                act_cur->poles[ii]);
                                 }
                                 else
                                 {
                                    if ( !off1->rational &&  act_cur->rational)
                                    {
                                       temp = fabs(off1->poles[ii]-
                                                   act_cur->poles[ii] /
                                                   act_cur->weights[0]);
                                    }
                                    else
                                    {

                         /* off1 is non-rational and act_cur is non-rational */
                                       temp = 
                                       fabs(off1->poles[ii] -
                                            act_cur->poles[ii]);
                                    }
                                 }
                              }
                              dist += (temp * temp);

                          }  /* end for ii loop */
                          dist = sqrt(dist);
                          if (dist < dist_tol)
                          {
                             n1 = 0;
                             wt1 = 0;
                             n2 = 0;
                             wt2 = 0;
                          }
                       }   /* end if dist */
                    }   /* end if dist */
                 }   /* end if dist */

            /* Calculate x-y-z distance between appropriate off1 pole and
               appropriate act_cur pole (calc. above, indicated by n1 & n2).
               If this distance > dist_tol, construct a line between off1 
               and act_cur */

                 dist = 0.0;
                 for (ii = 0; ii < 3; ++ii)
                 {
                     if (off1->rational && act_cur ->rational)
                     {
                        temp = fabs(off1->poles[n1 + ii] /
                                    off1->weights[wt1] -
                                    act_cur->poles[n2 + ii] / 
                                    act_cur->weights[wt2]);
                     } 
                     else
                     {
                        if (off1->rational && !act_cur->rational)
                        {
                           temp = 
                            fabs(off1->poles[n1 + ii] / off1->weights[wt1]
                                 - act_cur->poles[n2 + ii]);
                        }
                        else
                        {
                           if ( !off1->rational && act_cur->rational)
                           {
                              temp = 
                                fabs(off1->poles[n1 + ii] -
                                     act_cur->poles[n2 + ii] / 
                                     act_cur->weights[wt2]);
                           }
                           else
                           {
                      /* off1 is non-rational and act_cur is non-rational */
                              temp = 
                                fabs(off1->poles[n1 + ii] -
                                     act_cur->poles[n2 + ii]);
                           }
                        }
                     }
                     dist += (temp * temp);
                 }
                 dist = sqrt(dist);

                 if (dist > dist_tol)
                 {
                  /* Construct line connecting off1 and act_cur */
   
                    BSalloccv(2, 2, FALSE, 0, &off12, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    off12->order = 2;
                    off12->num_poles = 2;
                    off12->periodic = 0;
                    off12->non_uniform = 1;

                    if (! off1->rational)
                    {
                       off12->poles[0] = off1->poles[n1];
                       off12->poles[1] = off1->poles[n1 + 1];
                       off12->poles[2] = off1->poles[n1 + 2];
                    }
                    else
                    {
                       off12->poles[0] = off1->poles[n1] /
                                           off1->weights[wt1];
                       off12->poles[1] = off1->poles[n1 + 1] /
                                           off1->weights[wt1];
                       off12->poles[2] = off1->poles[n1 + 2] /
                                           off1->weights[wt1];
                    }
   
                    if (! act_cur->rational)
                    {
                       off12->poles[3] = act_cur->poles[n2];
                       off12->poles[4] = act_cur->poles[n2 + 1];
                       off12->poles[5] = act_cur->poles[n2 + 2];
                    }
                    else
                    {
                       off12->poles[3] = act_cur->poles[n2] / 
                                           act_cur->weights[wt2];
                       off12->poles[4] = act_cur->poles[n2 + 1] / 
                                           act_cur->weights[wt2];
                       off12->poles[5] = act_cur->poles[n2 + 2] / 
                                           act_cur->weights[wt2];
                    }
                    off12->rational = 0;
                    off12->num_knots = 4;
                    off12->knots[0] = 0.0;   
                    off12->knots[1] = 0.0;
                    off12->knots[2] = 1.0;
                    off12->knots[3] = 1.0;

                    off12->planar = 0;
                    off12->phy_closed = 0;
                    off12->num_boundaries = 0;
      
                    BSofupdeg(off1, off12, &order, &rat,
                              (IGRlong *) &nr_poles, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
    
                    BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    BScvkttol2(off12->order,off12->knots, off12->num_poles,
                               off12->poles, off12->weights,&knot_tol, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    knot_tol = knot_tol * 1.1;

                    te = new_span[k]->knots[new_span[k]->order -1] + knot_tol;
                    BSofrparcv(off12, tmid, te, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
 
                    BSmergecvnn(off1, off12, temp_cv, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
                    status = BSfreecv(rc, off1);
                    if(! status) 
                      goto wrapup;
                    off1 = NULL;
 
                    status = BSfreecv(rc, off12);
                    if(! status) 
                      goto wrapup;
                    off12 = NULL;
                   
                    BSofupdeg(temp_cv, act_cur, &order, &rat, 
                              (IGRlong *) &nr_poles, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    BSalloccv(order, nr_poles, rat, 0, &last, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    tmid = te;
                    te = new_span[k]->knots[new_span[k]->num_poles];
                    BSofrparcv(act_cur, tmid, te, rc);
                    if(BSERROR(*rc)) 
                       goto wrapup;
 
                    BSmergecvnn(temp_cv, act_cur, last, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                /** reparameterize the last curve **/

                    tmid = temp_cv->knots[temp_cv->order -1];
                    te = act_cur->knots[act_cur->num_poles];
 
                    BSofrparcv(last, tmid, te, rc);
                    if(BSERROR(*rc)) 
                       goto wrapup;

                    status = BSfreecv(rc, temp_cv);
                    if(! status) 
                      goto wrapup;
                    temp_cv = NULL;

                    status = BSfreecv(rc, off2);
                    if(! status) 
                      goto wrapup;
                    off2 = NULL;
 
                    status = BSfreecv(rc, act_cur);
                    if(! status) 
                      goto wrapup;
		    act_cur = NULL;
                 }
                 else
                 {
                    BSofupdeg(off1, act_cur, &order, &rat, 
                              (IGRlong *) &nr_poles, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
                    BSalloccv(order, nr_poles, rat, 0, &last, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
 
                    te = new_span[k]->knots[new_span[k]->num_poles];
                    BSofrparcv(act_cur, tmid, te, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
  
                    BSmergecvnn(off1, act_cur, last, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
 
                    /** reparameterize the last curve **/
  
                    tmid = off1->knots[off1->order -1];
                    te = act_cur->knots[act_cur->num_poles];
 
                    BSofrparcv(last, tmid, te, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;
   
                    status = BSfreecv(rc, off1);
                    if(! status) 
                      goto wrapup;
                    off1 = NULL;
 
                    status = BSfreecv(rc, off2);
                    if(! status) 
                      goto wrapup;
                    off2 = NULL;
 
                    status = BSfreecv(rc, act_cur);
                    if(! status) 
                      goto wrapup;
		    act_cur = NULL;
                 }
              }
              else
              {
                    if( gap )
                    {
                        BSofupdeg(off1, off12, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BScvkttol2(off12->order,off12->knots,off12->num_poles,
                          off12->poles, off12->weights,&knot_tol, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        knot_tol = knot_tol * 1.1;

                        te = new_span[k]->knots[new_span[k]->order -1] + 
                               knot_tol;
                        BSofrparcv(off12, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSmergecvnn(off1, off12, temp_cv, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BSfreecv(rc, off1);
                        if(! status) 
                          goto wrapup;
                        off1 = NULL;

                        status = BSfreecv(rc, off12);
                        if(! status) 
                          goto wrapup;
                        off12 = NULL;
                   
                        BSofupdeg(temp_cv, off2, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &last, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        tmid = te;
                        te = new_span[k]->knots[new_span[k]->num_poles];
                        BSofrparcv(off2, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;


                        BSmergecvnn(temp_cv, off2, last, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        /** reparameterize the last curve **/

                        tmid = temp_cv->knots[temp_cv->order -1];
                        te = off2->knots[off2->num_poles];

                        BSofrparcv(last, tmid, te, rc);
                        if(BSERROR(*rc)) 
                           goto wrapup;

                        status = BSfreecv(rc, temp_cv);
                        if(! status) 
                          goto wrapup;
                        temp_cv = NULL;

                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = NULL;
                    }
                    else
                    {
                        BSofupdeg(off1, off2, &order, &rat,
                                  (IGRlong *) &nr_poles, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        BSalloccv(order, nr_poles, rat, 0, &last, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        te = new_span[k]->knots[new_span[k]->num_poles];
                        BSofrparcv(off2, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        if (off1->phy_closed)
                           off1->phy_closed = FALSE;

                        BScomb2cvs(off1, off2, last, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        /** reparameterize the last curve **/

                        tmid = off1->knots[off1->order -1];
                        te = off2->knots[off2->num_poles];

                        BSofrparcv(last, tmid, te, rc);
                        if(BSERROR(*rc)) 
                          goto wrapup;

                        status = BSfreecv(rc, off1);
                        if(! status) 
                          goto wrapup;
                        off1 = NULL;

                        status = BSfreecv(rc, off2);
                        if(! status) 
                          goto wrapup;
                        off2 = NULL;
                    }
              }  /** end of if(after_int) **/
          }  /** end of if(degen > 0) **/         
     }

make_closed:

     if( cv->phy_closed )
     {
       if (num_span == 1)
       {        	
         BSofmkcls(cv, last, cv, cv, normal, code1, 
             d,right_side, off_cv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;
       }
       else
       {
         BSofmkcls(cv, last, new_span[num_span -1], new_span[0], normal, 
                   code1, d,right_side, off_cv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;
       }
     }             
     else
     {
         *off_cv = last;
     }
   }

   wrapup:
       if( cv->phy_closed || BSERROR(*rc) )
       {
         if (last)
         {
           (void)BSfreecv(&rc1,last);         
           if (BSERROR(rc1) && BSOKAY(*rc) )
             *rc = rc1;
           rc1 = BSSUCC;
         }
       }             

       if(rmul) BSstackdealloc((char *)rmul);
       if (span)
       {
	 for (i = num_span - 1; i >= 0; --i)
	 {
           if (span[i])
           {
             (void)BSfreecv(&rc1, span[i]);
             if (BSERROR(rc1) && BSOKAY(*rc))
               *rc = rc1;
             span[i] = NULL;
           }
	 }
         BSdealloc((char *) span);
         span = NULL;
       }

       if (new_span)
       {
	 for (i = num_span - 1; i >= 0; --i)
	 {
           if (new_span[i])
           {
             (void)BSfreecv(&rc1, new_span[i]);
             if (BSERROR(rc1) && BSOKAY(*rc))
               *rc = rc1;
             new_span[i] = NULL;
           }
	 }
         BSdealloc((char *) new_span);
         new_span = NULL;
       }
       if( off12 )
       {
          status = BSfreecv(rc, off12);
          if(! status) 
             goto wrapup;
          off12 = NULL;
      }
      if ( off1 )
      {
          (void)BSfreecv(&rc1, off1);
          if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
          off1 = NULL;
      }
      if ( off2 )
      {
          (void)BSfreecv(&rc1, off2);
          if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
          off2 = NULL;
      }

      if ( off3 )
      {
          (void)BSfreecv(&rc1, off3);
          if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
          off3 = NULL;
      }

      if (new_cv)
      {
        (void)BSfreecv(&rc1,new_cv);         
        if (BSERROR(rc1) && BSOKAY(*rc) )
          *rc = rc1;
      }

      if(index) 
      {
         BSstackdealloc((char *)index);
         index = NULL;
      }

      if(tmul)
      {
         BSstackdealloc((char *)tmul);
         tmul = NULL;
      }
      if (BSERROR(rco) && BSOKAY(*rc))
        *rc = rco;
      {
      if(BSERROR(*rc))
          BSdbgrc(*rc,"BSxycvoff");
      return;
      }
}

