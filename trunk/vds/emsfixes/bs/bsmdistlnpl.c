/*

Copyright (C) 2000, Intergraph Corporation. All rights reserved.

Name
    BSmdistlnpl

Abstract
    Find the minumum distance between a line and a plane.

Synopsis
    void  BSmdistlnpl(line, plane, num, linepar, planeuv, lnpt, planept, dist, rc)

    struct IGRbsp_curve   *line
    struct IGRbsp_surface *plane
    IGRint                *num
    IGRdouble             linepar[2]
    IGRdouble             planeuv[2][2]
    IGRpoint              lnpt[2], planept[2]
    IGRdouble             *dist
    BSrc                  *rc

Description
    This routine inputs a line and a plane.  It outputs the number of points at minimum
distance(num), parameters and points at minimum distance, and the minimum distance.

Return Values
    A return code BSSUCC is returned if everything was successful, and an
error return code is returned if an error occurrs.

Notes
    This routine should always return at least 1 point.  You will get 2 points in overlap
and parallel cases.

Index
    md

Keywords

History
S.G. Catron  03/20/00  : Creation date.
JJ Malosse 21 April 2000: Introduced IGRlong.
S.G. Catron  04/24/00  : Changed to add num as output argument.  For overlap and parallel cases
                         we will return 2 points.
***************************************************************************
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
#endif
#include <math.h>
#define  BSVOID 
void BSmdistlnpl(struct IGRbsp_curve   *line, struct IGRbsp_surface *plane, IGRint *num,
                 IGRdouble linepar[2], IGRdouble planeuv[2][2], IGRpoint linept[2],
                 IGRpoint planept[2], IGRdouble *dist, BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bststcvdegn.h"
#include "bsmdistptsf.h"
#include "bsbx2.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsxlnpl.h"
#include "bsprptonln.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsdlsegs2.h"
#include "bsnorvec.h"
#endif 
   IGRpoint corners[5], linestartpt, lineendpt,
            intx, pt1, pt2;
   BSpair cornerpars[5];
   IGRdouble  linestartpar, lineendpar,
             dist_tol, u, v, uu, vv, mindist,
             ln_par, p1, p2, knot_tol;
   IGRboolean degen, onsurf,
            CoinOrParal=FALSE;
   IGRint ln_code;
   IGRvector norm, vec1, vec2;
   IGRint i,j, curind;
   
   *rc = BSSUCC;
   *num = 0;

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
   
   if( line->num_poles > 2 || plane->u_num_poles > 2 || plane->v_num_poles > 2  ||
       !plane->planar)
   {
      *rc = BSINARG;
      goto wrapup;
   }
   for(i=0; i<3; i++)
   {
      linestartpt[i] = line->poles[i];
      lineendpt[i] = line->poles[3+i];
   }
   BStstcvdegn(line,&degen,rc);
   if(BSERROR(*rc))
      goto wrapup;

   if( degen)
   {

      /* line is degenerate, so just find minimum distance from point to  
         surface  */

      (void)BSmdistptsf(rc,plane,linestartpt, &planeuv[0][0], &planeuv[0][1],
                        planept[0],dist);
      if(BSERROR(*rc))
         goto wrapup;
      for(i=0; i<3; i++)
         linept[0][i] = linestartpt[i];

      linepar[0] = line->knots[line->order -1];
      *num = 1;
      goto wrapup;
   }
   linestartpar = line->knots[line->order-1];
   lineendpar = line->knots[line->num_poles];   

   /* find the corners of the plane */
   u = plane->u_knots[plane->u_order-1];
   v = plane->v_knots[plane->v_order-1];
   uu = plane->u_knots[plane->u_num_poles];
   vv = plane->v_knots[plane->v_num_poles];

   cornerpars[0][0] = cornerpars[4][0] = u;
   cornerpars[0][1] = cornerpars[4][1] = v;
   if( plane->rational)
   {
      for(i=0; i< 3; i++)
      {
         corners[0][i] = corners[4][i] = plane->poles[i]/plane->weights[0];
         corners[1][i] = plane->poles[3+i]/plane->weights[1];
         corners[2][i] = plane->poles[9+i]/plane->weights[3];
         corners[3][i] = plane->poles[6+i]/plane->weights[2];	          
      }
   }
   else
   {
      for(i=0; i< 3; i++)
      {
         corners[0][i] = corners[4][i] = plane->poles[i];
         corners[1][i] = plane->poles[3+i];
         corners[2][i] = plane->poles[9+i];
         corners[3][i] = plane->poles[6+i];
      }
   }   
   cornerpars[1][0] = uu;
   cornerpars[1][1] = v;
   cornerpars[2][0] = uu;
   cornerpars[2][1] = vv;
   cornerpars[3][0] = u;
   cornerpars[3][1] = vv;


   /* find the plane normal */
   (void)BSmkvec(rc, vec1, corners[0], corners[1] );
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSmkvec(rc, vec2, corners[0], corners[3] );
   if(BSERROR(*rc))
      goto wrapup;
   (void)BScrossp(rc, vec1, vec2, norm );
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSnorvec(rc, norm );
   if(BSERROR(*rc))
      goto wrapup;
   /* find the intersection - this is the infinite line/plane */           
   BSxlnpl (rc, norm, corners[0], linestartpt, lineendpt, intx);
   if( BSERROR(*rc))
   {
      /* don't exit if coincident or no solution */
      if( *rc != BSCOINCIDENT && *rc != BSNOSOLUTION)
         goto wrapup;
      else
      {
         CoinOrParal = TRUE;
         *rc = BSSUCC;
       }
   }
   else
   {   
      /* check if intersection is on the bounded part */
      BSprptonln (linestartpt, lineendpt, intx, &ln_code, &ln_par, rc);
      if (BSERROR(*rc))
         goto wrapup;
      if( ln_code > 0 )
      {
         (void)BSprptonsf(rc, plane, intx, &u, &v, &onsurf );
         if(BSERROR(*rc))
            goto wrapup;
         if( onsurf )
         {
            /* Output the intersection points */
            for(i=0; i< 3; i++)
               planept[0][i] = linept[0][i] = intx[i];
            planeuv[0][0] = u;
            planeuv[0][1] = v;
            linepar[0] = linestartpar + ln_par * (lineendpar - linestartpar);
            *num = 1;
            *dist = 0;
            goto wrapup;
         }
      }            
   }

   /*  no intersection points or it's coincident/parallel, check endpoints of the line to the plane */

   (void)BSmdistptsf(rc,plane,linestartpt, &planeuv[0][0], &planeuv[0][1], planept[0], dist);
   if(BSERROR(*rc))
      goto wrapup;
   *linepar = linestartpar;
   (void)BSmdistptsf(rc,plane,lineendpt, &planeuv[1][0], &planeuv[1][1], planept[1], &mindist);
   if(BSERROR(*rc))
      goto wrapup;
   
   if( CoinOrParal && *dist < dist_tol  && mindist < dist_tol)
   {
      *num = 2;
      for(i=0; i< 3; i++)
      {
         linept[0][i] = linestartpt[i];         
         linept[1][i] = lineendpt[i];
      }
      linepar[0] = linestartpar;
      linepar[1] = lineendpar;
      goto wrapup;
   }
   if( mindist < *dist)
   {
      *dist = mindist;
      planeuv[0][0] = planeuv[1][0];
      planeuv[0][1] = planeuv[1][1];
      linepar[0] = lineendpar;      
      for(i=0; i< 3; i++)
      {
         planept[0][i] = planept[1][i];
         linept[0][i] = lineendpt[i];
      }
   }
   else
   {
      for(i=0; i< 3; i++)
         linept[0][i] = linestartpt[i];
   }      
   BScvkttol2(line->order, line->knots, line->num_poles,line->poles,
            line->weights,&knot_tol,rc);
   if(BSERROR(*rc))
      goto wrapup;

   *num = 1;
   curind = 0;
   /* now check line to edges of plane */
   for(i=0; i< 4; i++)
   {
      onsurf = FALSE;
      BSdlsegs2( linestartpt, lineendpt, corners[i], corners[i+1], &mindist,
                 pt1, pt2, &p1, &p2, rc );
      if(BSERROR(*rc))
         goto wrapup;
      if( CoinOrParal && fabs(mindist - *dist) < dist_tol)
      {
         /* do we have our second point */
         /* we do, if this point is not equal to point we already have */
         if( fabs(p1 - linepar[0] ) < knot_tol )
            continue;
         else
         {
            curind = 1;
            *num = 2;
            /* set onsurf=TRUE, so we can set our second point */
            onsurf = TRUE;
         }
      }
      if( mindist < *dist || onsurf)
      {
         if(CoinOrParal && !onsurf )
         {
            /* it's possible we had 2 minimum distance points, but we actually
               have an overlap */
            curind = 0;
            *num = 1;
         }
         *dist = mindist;
         linepar[curind] = p1;
         for(j=0; j< 3; j++)
         {
            linept[curind][j] = pt1[j];
            planept[curind][j] = pt2[j];
         }
         if( i == 0 || i == 2 )
         {	    	    
            planeuv[curind][0] = p2;
            planeuv[curind][1] = cornerpars[i][1];
         }
         else
         {
            planeuv[curind][0] = cornerpars[i][0];
            planeuv[curind][1] = p2;
         }               
      }
   }
   
   wrapup:
  
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmdistlnpl");
   return;
   }
}
