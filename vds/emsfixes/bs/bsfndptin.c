/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSfndptin

Abstract
    This function accepts data defining a B-spline curve.  It finds a point inside
the curve.

Synopsis
    void BSfndptin(curve,pointIn, rc)

    struct IGRbsp_curve *curve
    IGRpoint            pointIn
    BSrc                *rc

Description
    This routine inputs a b-spline curve(curve) and outputs a point inside the curve.
If the curve is open, then it will be temporarily closed and a point within that curve
is returned. 

Return Values
    This routine returns BSSUCC, if all is successful, and an appropriate error
message if error occurrs.

Notes

Index
    md

Keywords

History
    S. G. Catron 11/20/00  : Creation date.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
# include "bsdefs.h"
# include "bserr.h"
#include "bsstackalloc.h"
#include "bsstk.h"
#include "bsmalloc.h"
#include "bsvalues.h"
#endif
#include <math.h>
# define BSVOID
#define MAXINT 10

void BSfndptin(struct IGRbsp_curve *curve, IGRpoint pointIn, BSrc *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bslsqptlnpl.h"
#include "bsroto.h"
#include "bsbx2.h"
#include "bsprj_cv_pl.h"
#include "bsorthovec.h"
#include "bsmklnintbx.h"
#include "bsclscurve.h"
#include "bscvcvint.h"
#include "bssrtptslnv.h"
#endif 
   IGRint    option=3, code, n, n_int, nover, count=0,
             *sort_ind=NULL, asort_ind[MAXINT], nk;
   IGRpoint  pt, min, max, *xint_pts=NULL,
             *ptrpts, int_pts[MAXINT], axis,
             end_pts[2*MAXINT],*xend_pts=NULL;
   IGRvector ortho, normal;
   IGRdouble alpha, lpoles[6], lknots[4], par0[MAXINT],
             par1[MAXINT], over0[2*MAXINT], over1[2*MAXINT],
             *xpar0=NULL, *xpar1=NULL, err,
	     *xover0=NULL, *xover1=NULL;
   struct IGRbsp_curve *s_curve=NULL, *proj_curve=NULL,
                       *pcurve, line;
   IGRboolean out_pt_alloc=FALSE, out_over_alloc=FALSE, full_line, Q0_to_Q1=TRUE;
   BSrc rc1;

   *rc = BSSUCC;

   if( !curve->phy_closed )
   {
      /* close the curve*/
      n = curve->num_poles+curve->order-1;
      nk = n + curve->order;
      BSstkallocv(rc,s_curve,n, curve->rational,nk,0);
      if (BSERROR(*rc))
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      BSclscurve(curve, &s_curve, rc );
      if(BSERROR(*rc))
         goto wrapup;
      pcurve = s_curve;
   }
   else
      pcurve = curve;
      
   /* find out if the curve is planar */
   BSlsqptlnpl(pcurve->num_poles, pcurve->poles, pcurve->weights, option, &code,
               pt, normal, &err, rc);
   if(BSERROR(*rc))
      goto wrapup;
   if( code == 2 )
   {
      *rc = BSINARG;
      goto wrapup;
   }      
   if( code == 1 )
   {
      /* degenerate */
      pointIn[0] = pt[0];
      pointIn[1] = pt[1];
      pointIn[2] = pt[2];
      goto wrapup;
   }
      
   if( code == 4 )
   {
      /* project curve to plane */
      BSstkallocv(rc,proj_curve,pcurve->num_poles, pcurve->rational,pcurve->num_knots,0);
      if (BSERROR(*rc))
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      (void)BSprj_cv_pl(rc, pcurve, pt, normal, normal, proj_curve);
      if(BSERROR(*rc))
         goto wrapup;
      pcurve = proj_curve;
   }

   /* now find a orthogonal vector to normal */
   (void)BSorthovec(rc,normal,ortho);
   if(BSERROR(*rc))
      goto wrapup;

   /* create line which will intersect the curve */
   (void) BSbx2(rc, &pcurve->num_poles, (IGRpoint*)pcurve->poles, pcurve->weights, min, max);
   if(BSERROR(*rc))
      goto wrapup;
   full_line=TRUE;
   line.poles = lpoles;
   line.knots = lknots;
   BSmklnintbx(pt,ortho,min,max,full_line,&line,rc);
   if(BSERROR(*rc))
      goto wrapup;

   BScvcvint( pcurve, &line, TRUE, MAXINT, MAXINT, int_pts, par0, par1, end_pts, over0, over1, &n_int, &nover, 
              &out_pt_alloc, &out_over_alloc, &xint_pts, &xpar0, &xpar1, &xend_pts, &xover0, &xover1, rc );
   if(BSERROR(*rc))
      goto wrapup;
   axis[0] = pt[0] + normal[0];
   axis[1] = pt[1] + normal[1];
   axis[2] = pt[2] + normal[2];
   alpha = M_PI / 8.0;
   
   /* if we find NO intersections, then rotate line by "alpha" and
      intersect again....keep doing this till we find an intersection or
      rotate 2PI */
   while((n_int < 2 || nover ) && count < 16)
   {
      /* rotate line about average point - pt */
      (void)BSroto( rc, pt, axis, &Q0_to_Q1, &alpha, &line.poles[3], &line.poles[3] );
      if(BSERROR(*rc))
         goto wrapup;
      (void)BSroto( rc, pt, axis, &Q0_to_Q1, &alpha, line.poles, line.poles );
      if(BSERROR(*rc))
         goto wrapup;
      if( out_pt_alloc )
      {
         /* free the previous results */
         if( xint_pts)
            BSdealloc((char *) xint_pts);
         if( xpar0)
            BSdealloc((char *) xpar0);
         if( xpar1)
            BSdealloc((char *) xpar1);
         xint_pts = NULL;
         xpar0 = xpar1 = NULL;
      }            
      if( out_over_alloc )
      {
         /* free the previous results */
         if( xend_pts)
            BSdealloc((char *) xend_pts);
         if( xover0)
            BSdealloc((char *) xover0);
         if( xover1)
            BSdealloc((char *) xover1);
         xend_pts = NULL;
         xover0 = xover1 = NULL;
      }            
      BScvcvint( pcurve, &line, TRUE, MAXINT, MAXINT, int_pts, par0, par1, end_pts, over0, over1, &n_int, &nover, 
              &out_pt_alloc, &out_over_alloc, &xint_pts, &xpar0, &xpar1, &xend_pts, &xover0, &xover1, rc );
      if(BSERROR(*rc))
         goto wrapup;
      count += 1;         
   }
   /* error if we looped and never found at least 2 intersections */
   if( count == 16 || n_int < 2)
   {
      *rc = BSFAIL;
      goto wrapup;
   }

   if( out_pt_alloc )
      ptrpts = xint_pts;
   else
      ptrpts = int_pts;
   if( n_int > MAXINT)
   {
      sort_ind = (IGRint *)BSstackalloc((unsigned)( n_int * sizeof(IGRint)));
      if(! sort_ind )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
      sort_ind = asort_ind;

   /* sort the intersection points with respect to the line */
   BSsrtptslnv(n_int,ptrpts,FALSE,NULL,ortho,sort_ind,rc);
   if(BSERROR(*rc))
      goto wrapup;
            
   /* now just average the first 2 points, which should give us a point inside the curve */
   pointIn[0] = (ptrpts[sort_ind[0]][0] + ptrpts[sort_ind[1]][0]) * 0.5;
   pointIn[1] = (ptrpts[sort_ind[0]][1] + ptrpts[sort_ind[1]][1]) * 0.5;
   pointIn[2] = (ptrpts[sort_ind[0]][2] + ptrpts[sort_ind[1]][2]) * 0.5; 
         
   wrapup:
   if( out_pt_alloc )
   {
      /* free the previous results */
      if( xint_pts)
         BSdealloc((char *) xint_pts);
      if( xpar0)
         BSdealloc((char *) xpar0);
      if( xpar1)
         BSdealloc((char *) xpar1);
      xint_pts = NULL;
      xpar0 = xpar1 = NULL;
   }            
   if( out_over_alloc )
   {
      /* free the previous results */
      if( xend_pts)
         BSdealloc((char *) xend_pts);
      if( xover0)
         BSdealloc((char *) xover0);
      if( xover1)
         BSdealloc((char *) xover1);
      xend_pts = NULL;
      xover0 = xover1 = NULL;
   }            

   if( sort_ind && sort_ind != asort_ind)
      BSstackdealloc((char *) sort_ind );

   if(s_curve)
   {
      BSstkfreecv(&rc1,s_curve);
      if(BSERROR(rc1))
         *rc = rc1;
   }
   if(proj_curve)
   {
      BSstkfreecv(&rc1,proj_curve);
      if(BSERROR(rc1))
         *rc = rc1;
   }

   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSfndptin");
   return;
}         
