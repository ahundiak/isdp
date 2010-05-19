/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSptsdlcv

Abstract
    This function accepts a curve with a base point and a distance
and finds a point on the curve or an extension of the curve at a given
distance in arclength from the given point.

Synopsis
    IGRboolean BSptsdlcv(rc,curve,basepar,p,distance,q)

    BSrc                *rc
    struct IGRbsp_curve *curve
    IGRdouble           *basepar
    IGRpoint            p
    IGRdouble           *distance
    IGRpoint            q
 
Description
    Given a B-spline curve (curve), the parameter of the base point on
this curve (basepar), a proximity point on the curve (p) and the 
distance at which to compute the new point (distance), this routine
returns the point on the curve at the given distance from the base
point (q).

Return Values
    If no errors occur, rc = BSSUCC.

Notes

Index
    md

Keywords

History
    David Paul Stevens  11/11/85  : Creation date.
    T.-S. Jeffrey Liu   01-21-87  : Delete unused dist.
    C. S. Kirby         08/30/88  : Change header to new format.
    Vivian W.Ye         01/16/89  : Add codes for finding the point
                                    on the extension of the curve.
    D. Breden           06/07/89  : Added call to BSchgcvewts after
                                    calling BSpoly_ext.
    C. S. Kirby         06/05/91  : Use i_side (IGRboolean) for call to
                                    BSpoly_ext instead of side (IGRint).
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
# include "bs.h" 
# include "bsparameters.h"
#endif

# define  BSVOID

IGRboolean BSptsdlcv(
BSrc *rc,
struct IGRbsp_curve *curve,
IGRdouble *basepar,
IGRpoint p,
IGRdouble *distance,
IGRpoint q)
 {
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsiarcln.h"
#include "bscveval.h"
#include "bsperpa.h"
#include "bsextrcvspn.h"
#include "bspoly_ext.h"
#include "bscnvtomkt.h"
#include "bsarclen.h"
#include "bschgcvewts.h"
#include "bsfreecv.h"
#include "bsalloccv.h"
#endif 

  struct IGRbsp_curve   *cv_spn = NULL,*excurve = NULL;
  IGRboolean status;            /* return status                    */
  IGRpoint b;                   /* base point                       */
  IGRint side;                  /* either endpoint or interior      */
  IGRboolean i_side ;             
  IGRshort num_par;             /* number of parameters from BSperpa*/
  IGRdouble proximity;          /* parameter value for point p      */
  IGRdouble half;               /* midpoint of curve domain         */
  IGRdouble a;                  /* degree-th knot                   */
  IGRdouble bb;                 /* knot[curve->num_poles            */
  IGRdouble end;                /* parameter for search direction   */
  IGRdouble w;                  /* parameter value for point q      */
  IGRint   spnind;
  IGRboolean planar = TRUE,closed = TRUE;
  IGRdouble dir,length,dist_tol,dist, bas_tol;
  IGRint int_div;
  BSrc  rc1 = BSSUCC;

  status = TRUE;                /* initialize status and return codes  */
  *rc = BSSUCC;
  
  BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);
  BSEXTRACTPAR(rc,BSTOLBASIS,bas_tol);  

  a = curve->knots[curve->order - 1];
  bb = curve->knots[curve->num_poles];


  /* Call BScveval to find the point on the curve corresponding to the
     parameter, basepar. */

  BScveval(curve,*basepar,0,(IGRpoint *)b,rc);
  if( BSERROR( *rc ) )
  {
    status = FALSE;
    goto wrapup;
  }


  /* Call BSperpa to get parameter value for proximity point, p.*/
  
  status = BSperpa(rc,curve,p,p,&num_par,&proximity,&side);
  if( status ==FALSE ) goto wrapup;

  /*  Determine if the search is to proceed in the direction
      of increasing of decreasing parameter.*/

  if( curve->phy_closed )             
  {
    half = ( a + bb ) / 2;
    if( *basepar > ( a + half ) )
    {
      if( ( *basepar - half ) < proximity && proximity < *basepar )
      {
        end = a;
      }
      else
      {
        end = bb;
      }
    }
    else
    {
      if( *basepar < proximity && proximity < ( *basepar + half ) )
      {
        end =bb;
      }
      else
      {
        end = a;
      }
    }
  }
  else
  {
    if( proximity < *basepar )
    {
      end = a;
    }
    else
    {
      end = bb;
    }
  }

  /* Call BSarclen to find the arc length from basepar to end */

  dir = (*basepar + end) / 2;
  length = BSarclen(rc,&status,curve,basepar,&end,&dir,&length);
  if (BSERROR(*rc))
    goto wrapup;
  if( length <= bas_tol )
  {
    status = FALSE;
    *rc = BSINCONSISTENT;
    goto wrapup;
  }    

  if (length - *distance > dist_tol)
  {

    /*   Call BSiarcln to find the parameter value, w, corresponding
    to a point distance units in arclength in the direction of end. */

    status = BSiarcln(rc,curve,basepar,distance,&end,&w);
    if( status == FALSE ) goto wrapup;

    /* Call BScveval to get the curve evaluation at parameter w. */

    BScveval(curve,w,0,(IGRpoint *)q,rc);
    if( BSERROR( *rc ) )
     {
      status = FALSE;
      goto wrapup;  /* exit if an error occurred in the function call */
     }
  }
  else
  {
    dist = *distance - length;
    if (curve->phy_closed)
    {
      if (end == a)
      {
        dir = (end + bb) / 2;
        length = BSarclen(rc,&status,curve,&end,&bb,&dir,&length);
        if (BSERROR(*rc))
          goto wrapup;
 
        int_div = (IGRint) (dist / length);
        dist -= int_div * length;

        status = BSiarcln(rc,curve,&bb,&dist,&end,&w);
        if( !status ) 
          goto wrapup;

        BScveval(curve,w,0,(IGRpoint *)q,rc);
        if( BSERROR( *rc ) )
        {
          status = FALSE;
          goto wrapup; 
        }
      }
      else if (end == bb)
      {
        dir = (end + a) / 2;
        length = BSarclen(rc,&status,curve,&end,&a,&dir,&length);
        if (BSERROR(*rc))
          goto wrapup;
 
        int_div = (IGRint) (dist / length);
        dist -= int_div * length;

        status = BSiarcln(rc,curve,&a,&dist,&end,&w);
        if( !status ) 
          goto wrapup;

        BScveval(curve,w,0,(IGRpoint *)q,rc);
        if( BSERROR( *rc ) )
        {
          status = FALSE;
          goto wrapup; 
        }
      }
    }
    else
    {
      if (end == a)
      {
        spnind = curve->order - 1;
        BSalloccv(curve->order,curve->num_poles,curve->rational,0,
                  &cv_spn,rc);
        if (BSERROR(*rc))
          goto wrapup;

        status = BSextrcvspn(rc,&spnind,curve,cv_spn,&planar,&closed);
        if (!status)
          goto wrapup;

        status = BScnvtomkt(rc,cv_spn);
        if (!status)
          goto wrapup;

        BSalloccv(cv_spn->order,(2 * cv_spn->order - 1),cv_spn->rational,0,
                  &excurve,rc);
        if (BSERROR(*rc))
          goto wrapup;

        i_side = 0;
        status = BSpoly_ext(rc,cv_spn,&i_side,excurve);
        if (!status)
          goto wrapup;

        if( excurve->rational )
        {
           BSchgcvewts(excurve, excurve, rc);
           if(BSERROR(*rc))
              status = FALSE;
        }

        dir = (excurve->knots[excurve->order - 1] + 
               curve->knots[curve->order - 1]) / 2;

        length = BSarclen(rc,&status,excurve,
                          &excurve->knots[excurve->order - 1],
                          &curve->knots[curve->order - 1],
                          &dir,&length);
        if (BSERROR(*rc))
          goto wrapup;

        if (length - dist < dist_tol)
        {
          *rc = BSINARG;
          status = FALSE;
          goto wrapup;
        }

        end = excurve->knots[excurve->order - 1];
        status = BSiarcln(rc,excurve,&curve->knots[curve->order - 1],
                          &dist,&end,&w);
        if( status == FALSE ) goto wrapup;
      }
      else if ( end == bb)
      {
        spnind = curve->num_poles - 1;
        BSalloccv(curve->order,curve->num_poles,curve->rational,0,
                  &cv_spn,rc);
        if (BSERROR(*rc))
          goto wrapup;

        status = BSextrcvspn(rc,&spnind,curve,cv_spn,&planar,&closed);
        if (!status)
          goto wrapup;

        status = BScnvtomkt(rc,cv_spn);
        if (!status)
          goto wrapup;


        BSalloccv(cv_spn->order,(2 * cv_spn->order - 1),cv_spn->rational,0,
                  &excurve,rc);
        if (BSERROR(*rc))
          goto wrapup;

        i_side = 1;
        status = BSpoly_ext(rc,cv_spn,&i_side,excurve);
        if (!status)
          goto wrapup;

        if( excurve->rational )
        {
           BSchgcvewts(excurve, excurve, rc);
           if(BSERROR(*rc))
              status = FALSE;
        }

        dir = (curve->knots[curve->num_poles] + 
               excurve->knots[excurve->num_poles]) / 2;

        length = BSarclen(rc,&status,excurve,
                          &curve->knots[curve->num_poles],
                          &excurve->knots[excurve->num_poles],
                          &dir,&length);
        if (BSERROR(*rc))
          goto wrapup;

        if (length - dist < dist_tol)
        {
          *rc = BSINARG;
          status = FALSE;
          goto wrapup;
        }

        end = excurve->knots[excurve->num_poles];
        status = BSiarcln(rc,excurve,&curve->knots[curve->num_poles],
                          &dist,&end,&w);
        if( status == FALSE ) goto wrapup;
      }

      /* Call BScveval to get the curve evaluation at parameter w.*/

      BScveval(excurve,w,0,(IGRpoint *)q,rc);
      if( BSERROR( *rc ) )
      {
        status = FALSE;
        goto wrapup;  /* exit if an error occurred in the function call */
      }
    }
  }

  wrapup:
   if (cv_spn)
     (void)BSfreecv(&rc1,cv_spn);
   if (excurve)
     (void)BSfreecv(&rc1,excurve);

  {
  if(BSERROR(*rc))
      BSdbgrc(*rc,"BSptsdlcv");
  return( status );
  }
 }
