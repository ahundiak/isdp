/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSpolyxcvcv

Abstract
    This routine extends two b-spline curves polynomially to intersection.

Synopsis
    void BSpolyxcvcv(cv1, cv2, input_side, xcv1, xcv2, rc);

    struct IGRbsp_curve   *cv1,
                          *cv2,
    IGRint                input_side[2]
    struct IGRbsp_curve   *xcv1,
                          *xcv2
    BSrc                  *rc

Description
    This routine inputs two b-spline curves(cv1 and cv2) and which side
to extend on(0:extend at start, 1: extend at end, side[0] is for cv1 and 
side[1] is for cv2).  It tries to extend both polynomially till they 
intersect.  It outputs the extended(or de-extended) curves(xcv1 and xcv2).

Return Values
    BSSUCC is returned if all is successful.

Notes
    The caller should allocate space for the output curves.
The size should be - (num_poles + 2 * order - 2) for each curve.

Index
    md

Keywords

History
    S.G. Catron    02/08/89  : Creation date.
    S.G. Catron    07/10/89  : P1 and p2 was not initialized so sometimes
                               it was junk.  Also I set the joining poles
                               to be exactly the same.
    S. C. Wood     08/04/89  : Set rc = BSNOSOLUTION if BScvcvint returns
                               n_int = 0 and n_over = 0.
    S.G. Catron    08/18/89  : Xcurve1 and xcurve2 did not have enough
                               memory sometimes.
    S.G. Catron    08/28/89  : Using bcurve for both cv1 and cv2 leads to
                               problems sometimes, if the first curve
                               is non-rational and it sets bcurve.weights
                               to NULL.  Then if cv2 needs weights it has
                               none.  So, just set the bcurve.weights back
                               to the static memory in the cv2 section.
    S.G. Catron    08/31/89  : Set variable planar to TRUE before calling
                               BSactivsplt the last time so that the 
                               planar bit for the output curves will be
                               set correctly.
    D. Breden      12/16/89  : Initialize boundaries in static curves.
    S.G. Catron    01/04/91  : Fixed apogee errors.
    S.G. Catron    05/10/91  : Changed code that finds the correct
                               intersection point returned from BScvcvint.
                               Now it uses the points instead of the
                               parameters.  It also uses both curve
                               distances(from extension point to intersec-
                               tion point) summed together to find the 
                               minimum one.
    S.G. Catron    06/05/91  : Made changes to port to sun.  Added another
                               variable for "side" which was a boolean.
    S.G. Catron    01/21/92  : Moved the setting of endpt1 and endpt2
                               up, so that if curve is linear they still
                               get set.
    S.C. Wood      04/21/92  : Call BSmdstptcv and check minimum distance
                               returned against dist_tol*10 instead of calling
                               BSprptoncv.
    S.G. Catron    08/21/99  : Added code at the beginning to check if curves
                               are already touching at endpoints.  We don't have
                               to do anything, but copy to output.  This improves
                               composite curve off alot, when we have 0 offset
                               distances.
    S.G. Catron    07/27/00  : Moved setting of ptr4 inside if rational, so we're
                               not accessing memory out of bounds.                            
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
#include "bsmalloc.h"
#include "bsstackalloc.h"
#endif
#include <math.h>
#define  BSVOID

#define MAXNUM  100
#define MAXOVER  20

void BSpolyxcvcv(
struct IGRbsp_curve *cv1,
struct IGRbsp_curve 	*cv2,

IGRint              input_side[2],
struct IGRbsp_curve *xcv1,
struct IGRbsp_curve 	*xcv2,

BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsptlnplan.h"
#include "bscomb2cvs.h"
#include "bschgcvewts.h"
#include "bscveval.h"
#include "bscvcvint.h"
#include "bsmdstptcv.h"
#include "bspoly_ext.h"
#include "bsactivsplt.h"
#include "bsextrcvspn.h"
#include "bscnvtomkt.h"
#include "bsdistptpt.h"
#include "bscv_copy.h"
#endif 


   IGRboolean planar, closed, rem_dup,
             out_over_alloc, out_pt_alloc,
             status;
   IGRpoint  bpoles[2 * MAX_ORDER],midpt,
             xpoles1[MAXNUM], endpt1, 
             xpoles2[MAXNUM], endpt2,
             point,first_pt, last_pt,
             int_pts[MAXNUM], endpts[MAXOVER*2],
             *xint_pts=NULL, *xend_pts=NULL, base_pt;
   IGRdouble *ptr1, *ptr2=NULL, *ptr3, *ptr4=NULL,
             u1, uu1, u2, uu2, par1[MAXNUM],
             par2[MAXNUM], over1[MAXOVER*2],
             over2[MAXOVER*2], *xpar1=NULL,
             *xpar2=NULL, *xover1=NULL, 
             *xover2=NULL, dist, mindist, mindist2,
             tdeg, tnp, bknots[3*MAX_ORDER],
             xknots1[MAXNUM],
             xknots2[MAXNUM],
             xweights1[MAXNUM],
             xweights2[MAXNUM],
             bweights[2*MAX_ORDER-1], u_diff,
             p1, p2, avg, dist1, dist2, dist_tol;
   IGRint    code, n_int, n_over, ind, i, j,
             k, deg, maxnum1 = 0, maxnum2=0, N1=0, N2=0;
   IGRvector vec; 
   struct IGRbsp_curve bcurve, xcurve1, xcurve2;
   IGRboolean side[2];

   side[0] = (short) input_side[0];
   side[1] = (short) input_side[1];

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

   *rc = BSSUCC;

   if( cv1->phy_closed || cv2->phy_closed)
   {
      *rc = BSINARG;
      goto wrapup;
   }

   if( !side[0] )
   {
      if( cv1->rational )
         for(i=0; i<3; i++)
            endpt1[i] = cv1->poles[i] / cv1->weights[0];
      else
         for(i=0; i<3; i++)
            endpt1[i] = cv1->poles[i];
   }
   else
   {
		  N1 = cv1->num_poles-1;
      if( cv1->rational )
         for(i=0; i<3; i++)
            endpt1[i] = cv1->poles[N1*3+i] / 
                        cv1->weights[N1];
      else
         for(i=0; i<3; i++)
            endpt1[i] = cv1->poles[N1*3+i];
   }
   if( !side[1] )
   {
      if( cv2->rational )
         for(i=0; i<3; i++)
            endpt2[i] = cv2->poles[i] / cv2->weights[0];
      else
         for(i=0; i<3; i++)
            endpt2[i] = cv2->poles[i];
   }
   else
   {
		  N2 = cv2->num_poles-1;
      if( cv2->rational )
         for(i=0; i<3; i++)
            endpt2[i] = cv2->poles[N2*3+i] / 
                        cv2->weights[N2];
      else
         for(i=0; i<3; i++)
            endpt2[i] = cv2->poles[N2*3+i];
   }
	 /* check if our curves already intersect, then we don't need to do anything */
	 if( BSdistptpt(rc, endpt1, endpt2 ) < dist_tol )
	 {
     /* copy the input and set the poles exactly equal */
     (void)BScv_copy(rc,cv1,xcv1);
		 if(BSERROR(*rc))
			 goto wrapup;
     (void)BScv_copy(rc,cv2,xcv2);
		 if(BSERROR(*rc))
			 goto wrapup;

     midpt[0] = (endpt1[0] + endpt2[0] ) * 0.5;
     midpt[1] = (endpt1[1] + endpt2[1] ) * 0.5;
		 midpt[2] = (endpt1[2] + endpt2[2] ) * 0.5;
     if( !side[0] )
		 {
			 if( xcv1->rational )
         for(i=0; i<3; i++)
				   xcv1->poles[i] = midpt[i] * xcv1->weights[0];
       else
         for(i=0; i<3; i++)
				   xcv1->poles[i] = midpt[i];
				 
		 }
     else
		 {
			 if( xcv1->rational )
         for(i=0; i<3; i++)
				   xcv1->poles[N1*3+i] = midpt[i] * xcv1->weights[N1];
       else
         for(i=0; i<3; i++)
				   xcv1->poles[N1*3+i] = midpt[i];
		 }      
     if( !side[1] )
		 {
			 if( xcv2->rational )
         for(i=0; i<3; i++)
				   xcv2->poles[i] = midpt[i] * xcv2->weights[0];
       else
         for(i=0; i<3; i++)
				   xcv2->poles[i] = midpt[i];
				 
		 }
     else
		 {
			 if( xcv2->rational )
         for(i=0; i<3; i++)
				   xcv2->poles[N2*+i] = midpt[i] * xcv2->weights[N2];
       else
         for(i=0; i<3; i++)
				   xcv2->poles[N2*+i] = midpt[i];
		 } 
		 goto wrapup;
   }
   planar = FALSE;
   closed = TRUE;
   rem_dup = TRUE;
   bcurve.poles = &bpoles[0][0];
   bcurve.knots = &bknots[0];
   bcurve.weights = &bweights[0];
   bcurve.bdrys = NULL;

   maxnum1 = cv1->num_poles + 2 * cv1->order - 2;
   if( maxnum1 > MAXNUM )
   {
      xcurve1.poles = (IGRdouble *)BSstackalloc((unsigned)( maxnum1 *
                                        sizeof(IGRpoint)));
      if(! xcurve1.poles )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      if( cv1->rational)
      {
         xcurve1.weights = (IGRdouble *)BSstackalloc((unsigned)( maxnum1 *
                                        sizeof(IGRdouble)));
         if(! xcurve1.weights )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
   }
   else
   {
      xcurve1.poles = &xpoles1[0][0];
      if( cv1->rational)
         xcurve1.weights = &xweights1[0];         
   }
   xcurve1.bdrys = NULL;
   if( maxnum1 + cv1->order > MAXNUM )
   {
      xcurve1.knots = (IGRdouble *)BSstackalloc((unsigned)( (maxnum1 +
                                      cv1->order) * sizeof(IGRdouble)));
      if(! xcurve1.knots )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      xcurve1.knots = &xknots1[0];
   }
   maxnum2 = cv2->num_poles + 2 * cv2->order - 2;
   if( maxnum2 > MAXNUM )
   {
      xcurve2.poles = (IGRdouble *)BSstackalloc((unsigned)( maxnum2 *
                                        sizeof(IGRpoint)));
      if(! xcurve2.poles )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      if( cv2->rational)
      {
         xcurve2.weights = (IGRdouble *)BSstackalloc((unsigned)( maxnum2 *
                                        sizeof(IGRdouble)));
         if(! xcurve2.weights )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
   }
   else
   {
      xcurve2.poles = &xpoles2[0][0];
      if( cv2->rational)
         xcurve2.weights = &xweights2[0];         
   }
   if( maxnum2 + cv2->order > MAXNUM )
   {
      xcurve2.knots = (IGRdouble *)BSstackalloc((unsigned)( (maxnum2 +
                                      cv2->order) * sizeof(IGRdouble)));
      if(! xcurve2.knots )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      xcurve2.knots = &xknots2[0];
   }
   xcurve2.bdrys = NULL;

   BSptlnplan( cv1->num_poles, cv1->rational, (IGRpoint *) cv1->poles,
               cv1->weights, &code, vec, rc );
   if (BSERROR(*rc))
       goto wrapup;


   if (code == 2)
   {
      /**** Special code for linear curve ****/      
      ptr1 = cv1->poles;
      ptr2 = cv1->weights;
      ptr3 = &cv1->poles[(cv1->num_poles-1)*3];

      if (cv1->rational)
      {
         ptr4 = &cv1->weights[cv1->num_poles-1];
         for (j=0;j < 3;j++)
         {
            first_pt[j] = *ptr1++ / *ptr2;
            last_pt[j] = *ptr3++ / *ptr4;
         }
         ptr1 = first_pt;
         ptr3 = last_pt;
      }
      for (j=0;j < 3;j++)
      {
         vec[j] = ((*ptr3++ - *ptr1++) * 10.0) / 
                   (cv1->order - 1);
      }
      ptr1 -= 3;
      ptr3 -= 3;
      bcurve.order = cv1->order;
      bcurve.periodic = FALSE;
      bcurve.non_uniform = FALSE;
      bcurve.num_poles = cv1->order;
      bcurve.rational = FALSE;
      bcurve.weights = NULL;
      bcurve.num_knots = cv1->order * 2;
      bcurve.planar = FALSE;
      bcurve.phy_closed = FALSE;
      bcurve.num_boundaries = 0;
      tdeg = cv1->knots[cv1->order-1];
      tnp = cv1->knots[cv1->num_poles];
      u_diff = (tnp - tdeg) * 10;

      if( side[0] )
      {
         u1 = tnp;   
         uu1 = tdeg;   
         for (i=0; i < cv1->order; i++)
         {
            for (j=0;j < 3;j++)
            {
               bcurve.poles[i * 3 + j] = *ptr3++ + (vec[j] * i);
            }
            ptr3 -= 3;
         }

         for (j=0;j < cv1->order;j++)
         {
            bcurve.knots[j] = tnp;
            bcurve.knots[j + cv1->order] = tnp + u_diff;
         }
         BScomb2cvs( cv1, &bcurve, &xcurve1, rc );
         if(BSERROR(*rc))
            goto wrapup;

         if( xcurve1.rational )
            BSchgcvewts(&xcurve1, &xcurve1, rc);
      }
      else
      {
         /* side[0] = 0  */
         u1 = tdeg;      
         uu1 = tnp;      
         for (i=0,k=(cv1->order - 1); k>=0; k--,i++)
         {
            for (j=0;j < 3;j++)
            {
               bcurve.poles[k * 3 + j] = *ptr1++ - (vec[j] * i);
            }
            ptr1 -= 3;
         }

         for (j=0;j < cv1->order;j++)
         {
            bcurve.knots[j] = tdeg - u_diff;
            bcurve.knots[j + cv1->order] = tdeg;
         }

         BScomb2cvs( &bcurve, cv1, &xcurve1, rc );
         if (BSERROR(*rc))
             goto wrapup;

         if( xcurve1.rational )
            BSchgcvewts(&xcurve1, &xcurve1, rc);
      }
   }
   else
   {
      /* cv1 is not a linear */
      if( !side[0] )
      {
         u1 = cv1->knots[cv1->order-1];
         uu1 = cv1->knots[cv1->num_poles];
         if( cv1->num_poles > cv1->order)
         {
            /* extract the first span  */
            deg = cv1->order -1;
            status = BSextrcvspn(rc,&deg,cv1,&bcurve,&planar,&closed);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BScnvtomkt(rc,&bcurve);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            /* find the polynomial extension of first span */
            status = BSpoly_ext(rc,&bcurve,&side[0],&xcurve1);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BSactivsplt(rc, &xcurve1, &u1, &xcurve1.knots[
                                 xcurve1.order-1], &bcurve, &planar);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            BScomb2cvs( &bcurve, cv1, &xcurve1, rc );
            if(BSERROR(*rc))
            {
               goto wrapup;
            } 
         }
         else
         {
            /* find the polynomial extension of the curve*/
            status = BSpoly_ext(rc,cv1,&side[0],&xcurve1);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
      else
      {
         /* side[0] = 1 */
         u1 = cv1->knots[cv1->num_poles];
         uu1 = cv1->knots[cv1->order -1];
         if(cv1->num_poles > cv1->order)
         {
            /* extract the last span  */
            n_int = cv1->num_poles -1;
            status = BSextrcvspn(rc, &n_int, cv1, &bcurve, &planar,
                                 &closed);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BScnvtomkt(rc,&bcurve);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            /* find the polynomial extension of the last span */
            status = BSpoly_ext(rc,&bcurve,&side[0],&xcurve1);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BSactivsplt(rc, &xcurve1, &u1, &xcurve1.knots[
                                 xcurve1.num_poles], &bcurve, &planar);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            /* combine the input curve with the extended part */
            BScomb2cvs( cv1, &bcurve, &xcurve1, rc );
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
         else
         {
            /* find the polynomial extension of the curve on the end*/
            status = BSpoly_ext(rc,cv1,&side[0],&xcurve1);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
   }
   /* now extend cv2 */
   /* reset these weights incase cv1 used them, or rather did not use
      them and set them to NULL */
   bcurve.weights = bweights; 
   BSptlnplan( cv2->num_poles, cv2->rational, (IGRpoint *) cv2->poles,
               cv2->weights, &code, vec, rc );
   if (BSERROR(*rc))
       goto wrapup;

   if (code == 2)
   {
      /**** Special code for linear curve ****/      
      ptr1 = cv2->poles;
      ptr2 = cv2->weights;
      ptr3 = &(cv2->poles[(cv2->num_poles-1)*3]);
      if (cv2->rational)
      {
         ptr4 = &cv2->weights[cv2->num_poles-1];
         for (j=0;j < 3;j++)
         {
            first_pt[j] = *ptr1++ / *ptr2;
            last_pt[j] = *ptr3++ / *ptr4;
         }
         ptr1 = first_pt;
         ptr3 = last_pt;
      }
      for (j=0;j < 3;j++)
      {
         vec[j] = ((*ptr3++ - *ptr1++) * 10.0) / 
                   (cv2->order - 1);
      }
      ptr1 -= 3;
      ptr3 -= 3;
      bcurve.order = cv2->order;
      bcurve.periodic = FALSE;
      bcurve.non_uniform = FALSE;
      bcurve.num_poles = cv2->order;
      bcurve.rational = FALSE;
      bcurve.weights = NULL;
      bcurve.num_knots = cv2->order * 2;
      bcurve.planar = FALSE;
      bcurve.phy_closed = FALSE;
      bcurve.num_boundaries = 0;
      tdeg = cv2->knots[cv2->order-1];
      tnp = cv2->knots[cv2->num_poles];
      u_diff = (tnp - tdeg) * 10;

      if( side[1] )
      {
         uu2 = tdeg;   
         for (i=0; i < cv2->order; i++)
         {
            for (j=0;j < 3;j++)
            {
               bcurve.poles[i * 3 + j] = *ptr3++ + (vec[j] * i);
            }
            ptr3 -= 3;
         }

         for (j=0;j < cv2->order;j++)
         {
            bcurve.knots[j] = tnp;
            bcurve.knots[j + cv2->order] = tnp + u_diff;
         }

         BScomb2cvs( cv2, &bcurve, &xcurve2, rc );
         if(BSERROR(*rc))
            goto wrapup;
         if( xcurve2.rational )
            BSchgcvewts(&xcurve2, &xcurve2, rc);
      }
      else
      {
         /* side[1] = 0  */
         uu2 = tnp;      
         for (i=0,k=(cv2->order - 1); k>=0; k--,i++)
         {
            for (j=0;j < 3;j++)
            {
               bcurve.poles[k * 3 + j] = *ptr1++ - (vec[j] * i);
            }
            ptr1 -= 3;
         }

         for (j=0;j < cv2->order;j++)
         {
            bcurve.knots[j] = tdeg - u_diff;
            bcurve.knots[j + cv2->order] = tdeg;
         }

         BScomb2cvs( &bcurve, cv2, &xcurve2, rc );
         if (BSERROR(*rc))
             goto wrapup;

         if( xcurve2.rational )
            BSchgcvewts(&xcurve2, &xcurve2, rc);
      }
   }
   else
   {
      /* cv2 is not linear */
      if( !side[1] )
      {
         u2 = cv2->knots[cv2->order-1];
         uu2 = cv2->knots[cv2->num_poles];
         if( cv2->num_poles > cv2->order)
         {
            /* extract the first span  */
            deg = cv2->order -1;
            status = BSextrcvspn(rc,&deg,cv2,&bcurve,&planar,&closed);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BScnvtomkt(rc,&bcurve);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            /* find the polynomial extension of first span */
            status = BSpoly_ext(rc,&bcurve,&side[1],&xcurve2);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BSactivsplt(rc,&xcurve2,&u2, &xcurve2.knots[
                                 xcurve2.order-1], &bcurve, &planar);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            BScomb2cvs( &bcurve, cv2, &xcurve2, rc );
            if(BSERROR(*rc))
            {
               goto wrapup;
            } 
         }
         else
         {
            /* find the polynomial extension of the curve*/
            status = BSpoly_ext(rc,cv2,&side[1],&xcurve2);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
      else
      {
         /* side[1] = 1 */
         u2 = cv2->knots[cv2->num_poles-1];
         uu2 = cv2->knots[cv2->order-1];
         if(cv2->num_poles > cv2->order)
         {
            /* extract the last span  */
            n_int = cv2->num_poles -1;
            status = BSextrcvspn(rc, &n_int, cv2, &bcurve, &planar,
                                 &closed);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BScnvtomkt(rc,&bcurve);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            /* find the polynomial extension of the last span */
            status = BSpoly_ext(rc,&bcurve,&side[1],&xcurve2);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            status = BSactivsplt(rc,&xcurve2, &u2, &xcurve2.knots[
                                 xcurve2.num_poles], &bcurve, &planar);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            BScomb2cvs( cv2, &bcurve, &xcurve2, rc );
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
         else
         {
            /* find the polynomial extension of the curve on the end*/
            status = BSpoly_ext(rc,cv2,&side[1],&xcurve2);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
   }

   /* find the intersection between the extended curves */
   BScvcvint(&xcurve1, &xcurve2, rem_dup, MAXNUM, MAXOVER, int_pts,
             par1, par2, endpts, over1, over2, &n_int, &n_over, 
             &out_pt_alloc, &out_over_alloc, &xint_pts, &xpar1, &xpar2,
             &xend_pts, &xover1, &xover2, rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }

   if( n_int == 0 && n_over == 0 )
   {
      *rc = BSNOSOLUTION;
      goto wrapup;
   }
   if( n_int > 0 )
   {
      /* choose parameter closest to boundary knot before extension */
      ind = 0;
      if( out_pt_alloc )
      {
         mindist = BSdistptpt(rc, xint_pts[0], endpt1 );
         if(BSERROR(*rc))
            goto wrapup;
         mindist2 = BSdistptpt(rc, xint_pts[0], endpt2);
         if(BSERROR(*rc))
            goto wrapup;
         mindist += mindist2;
         p1 = xpar1[0];
         for(i=1; i< n_int; i++)
         {
            dist = BSdistptpt(rc, xint_pts[i], endpt1 );
            if(BSERROR(*rc))
               goto wrapup;
            dist2 = BSdistptpt(rc, xint_pts[i], endpt2 );
            if(BSERROR(*rc))
               goto wrapup;
            dist += dist2;
            if(dist < mindist )
            {
               mindist = dist;
               p1 = xpar1[i];
               ind = i;
            }
         }
         p2 = xpar2[ind];
      }
      else
      {
         mindist = BSdistptpt(rc, int_pts[0], endpt1 );
         if(BSERROR(*rc))
            goto wrapup;
         mindist2 = BSdistptpt(rc, int_pts[0], endpt2);
         if(BSERROR(*rc))
            goto wrapup;
         mindist += mindist2;
         p1 = par1[0];
         for(i=1; i< n_int; i++)
         {
            dist = BSdistptpt(rc, int_pts[i], endpt1 );
            if(BSERROR(*rc))
               goto wrapup;
            dist2 = BSdistptpt(rc, int_pts[i], endpt2);
            if(BSERROR(*rc))
               goto wrapup;
            dist += mindist2;
            if( dist < mindist )
            {
               mindist = dist;
               p1 = par1[i];
               ind = i;
            }
         }
         p2 = par2[ind];
      }
   }
   else
   {
      /* there's an overlap */
      if( side[1] )
      {
         ptr1 = &cv2->poles[(cv2->num_poles-1)*3];
         ptr2 = &cv2->weights[cv2->num_poles-1];
         if (cv2->rational)
         {
            for (j=0;j < 3;j++)
            {
               last_pt[j] = *ptr1++ / *ptr2;
            }
            ptr1 = last_pt;
         }
      }
      else
      {
         ptr1 = cv2->poles;
         ptr2 = cv2->weights;
         if (cv2->rational)
         {
            for (j=0;j < 3;j++)
            {
               first_pt[j] = *ptr1++ / *ptr2;
            }
            ptr1 = first_pt;
         }
      }        

      BSmdstptcv(&xcurve1, ptr1, &p1, base_pt, &dist1, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if(dist1 > dist_tol*10)
      {
         *rc = BSFAIL;
         goto wrapup;
      }

      p1 = (p1 + u1 ) / 2.0;
      i = 0;
      BScveval(&xcurve1, p1, i, (IGRpoint *) &point, rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }

      BSmdstptcv(&xcurve2, point, &p2, base_pt, &dist2, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if(dist2 > dist_tol*10)
      {
         *rc = BSFAIL;
         goto wrapup;
      }
   }
   /* now split off the curves */
   planar = TRUE;
   status = BSactivsplt(rc,&xcurve1,&p1, &uu1, xcv1, &planar);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   status = BSactivsplt(rc,&xcurve2,&p2, &uu2, xcv2, &planar);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   /* set the poles exactly equal */
   if( side[0] )
   {
      ptr1 = &xcv1->poles[(xcv1->num_poles-1)*3];   
      if( xcv1->rational)
         ptr2 = &xcv1->weights[xcv1->num_poles-1];
   }
   else
   {
      ptr1 = xcv1->poles;
      if( xcv1->rational )
         ptr2 = xcv1->weights;
   }
   if( side[1] )
   {
      ptr3 = &xcv2->poles[(xcv2->num_poles-1)*3];   
      if( xcv2->rational)
         ptr4 = &xcv2->weights[xcv2->num_poles-1];
   }
   else
   {
      ptr3 = xcv2->poles;
      if( xcv2->rational )
         ptr4 = xcv2->weights;
   }
   for(i=0; i<3; i++)
   {
      if( xcv1->rational)
         *ptr1 /= *ptr2;
      if( xcv2->rational)
         *ptr3 /= *ptr4;
      avg = (*ptr1 + *ptr3) / 2.0;
      *ptr1 = avg;
      *ptr3 = avg;
      if( xcv1->rational)
         *ptr1 *= *ptr2;
      if( xcv2->rational)
         *ptr3 *= *ptr4;
      ptr1++;
      ptr3++;      
   }
               
   status = status;        
   wrapup:

   if( out_pt_alloc)
   {
      if( xint_pts)
      {
         BSdealloc((char *)xint_pts);
      }
      if( xpar1)
      {
         BSdealloc((char *)xpar1);
      }
      if( xpar2)
      {
         BSdealloc((char *)xpar2);
      }
   }
   if( out_over_alloc)
   {
      if( xend_pts)
      {
         BSdealloc((char *)xend_pts);
      }
      if( xover1)
      {
         BSdealloc((char *)xover1);
      }
      if( xover2)
      {
         BSdealloc((char *)xover2);
      }
   }
   if( maxnum1 > MAXNUM )
   {
      if( xcurve1.poles)
         BSstackdealloc((char *) xcurve1.poles );
      if( cv1->rational)
      {
         if( xcurve1.weights )
            BSstackdealloc((char *) xcurve1.weights );
      }
   }
   if( maxnum1 + cv1->order > MAXNUM )
   {
      if( xcurve1.knots)
         BSstackdealloc((char *) xcurve1.knots );
   }
   if( maxnum2 > MAXNUM )
   {
      if( xcurve2.poles )
         BSstackdealloc((char *) xcurve2.poles );
      if( cv2->rational)
      {
         if( xcurve2.weights)
            BSstackdealloc((char *) xcurve2.weights );
      }
   }
   if( maxnum2 + cv2->order > MAXNUM )
   {
      if( xcurve2.knots)
         BSstackdealloc((char *) xcurve2.knots );
   }

   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSpolyxcvcv");
   return;
   }
}
