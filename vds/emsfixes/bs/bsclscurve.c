/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSclscurve

Abstract
    This function inputs a b-spline curve and closes it by just creating
a line segment between ends.    

Synopsis
    void BSclscurve(curve, ocurve, rc)

    struct IGRbsp_curve *curve
    struct IGRbsp_curve **ocurve
    BSrc                *rc

Description
    Input
       curve        b-spline curve

    Output       
       ocurve       closed b-spline curve
       
Return Values
    This routine returns BSSUCC, if all is successful, and an appropriate error
message if error occurrs.

Notes
    This routine will allocate output if *ocurve=NULL.  If *ocurve is NOT null, then we assume
that memory has been provided.

    If caller would like to allocate memory, then allocate num_poles + order -1.
    
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
#include "bsparameters.h"
# include "bsdefs.h"
# include "bserr.h"
#endif
#include <math.h>
# define BSVOID

void BSclscurve(struct IGRbsp_curve *curve, struct IGRbsp_curve **ocurve, BSrc *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsalloccv.h"
#include "bsmerge_cv.h"
#include "bschrdlkts.h"
#include "bscveval.h"
#include "bslngen.h"
#include "bscv_copy.h"
#include "bsdistptpt.h"
#endif 
   IGRint type, n;
   IGRpoint startpt, endpt;
   struct IGRbsp_curve *pcurve, line;
   IGRdouble lpoles[6], lknots[4], dist, dist_tol;
    
   *rc = BSSUCC;

   (void)BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
   
   if(! *ocurve )
   {
      n = curve->num_poles+curve->order-1;
      BSalloccv(curve->order, n, curve->rational,curve->num_boundaries,ocurve,rc);
      if(BSERROR(*rc))
         goto wrapup;
   }         
   pcurve = *ocurve;
   BScveval(curve,curve->knots[curve->order-1],0,&startpt,rc);
   if(BSERROR(*rc))
      goto wrapup;
   BScveval(curve,curve->knots[curve->num_poles],0,&endpt,rc);
   if(BSERROR(*rc))
      goto wrapup;
   dist = BSdistptpt(rc, startpt, endpt );
   
   if( curve->phy_closed || curve->order == 2 || dist < dist_tol)
   {
      (void)BScv_copy(rc,curve,pcurve);
      if(BSERROR(*rc))
         goto wrapup;
      /* if closed, we're finished */
      if( curve->phy_closed || dist < dist_tol)
         goto wrapup;

      /* we will just set last pole equal to first */
      n = curve->num_poles;
      pcurve->poles[n*3] = curve->poles[0];
      pcurve->poles[n*3+1] = curve->poles[1];
      pcurve->poles[n*3+2] = curve->poles[2];            
      if( curve->rational)
         pcurve->weights[n] = curve->weights[n-1];
      pcurve->num_poles += 1;
      pcurve->num_knots += 1;
      pcurve->phy_closed = TRUE;
      (void)BSchrdlkts(rc,&pcurve->num_poles,pcurve->poles,&pcurve->order,&pcurve->periodic,pcurve->knots);
      goto wrapup;
   }

   /* create line from end point to start point */
   line.poles = lpoles;
   line.knots = lknots;
   
   (void)BSlngen( rc, endpt, startpt, &line, &type );
   if(BSERROR(*rc))
      goto wrapup;
   
   (void)BSmerge_cv(rc,curve,&line,pcurve);
      
   wrapup:

   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSclscurve");
   return;
}         
