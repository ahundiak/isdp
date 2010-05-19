/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSpt_in_plg

Abstract
    This routine determines if the input point is inside a polygon.

Synopsis
    void BSpt_in_plg(polygon,pt,orient_known,pos_orient,ind,rc)
    IGRpolyline      polygon;
    IGRpoint         pt;
    IGRboolean       orient_known;
    IGRboolean       *pos_orient;
    IGRint           *ind;
    BSrc             *rc;

Description
    This routine determines whether the input point is inside a polygon.
    if it is inside, then ind = 1, if it is on the polygon, then ind = 2.
    If it is ouside, ind = 0. Also, if the caller know the orientation of
    the polygon, then orient_known should be set to TRUE and pos_orient 
    hould be set to TRUE if the orientation is countclockwise, or FALSE if
    the orientation is clockwise. Otherwise, orient_known = FALSE, then
    this routine will compute it and return it as output.

Return Values
    if successful, BSSUCC is returned. If no stack space was available,
    BSNOSTKMEMORY is returned. if the input polygon is not closed, then
    BSINARG is recieved. if the left turns equal to  the right turns of 
    the polygon , BSDGENRAT is returned.

Notes

Index
    md

Keywords

History
    Vivian W.Ye     11/18/1986  : Creation date.
    Vivian W.Ye     3/2/1987    : Call BSfndstrort to determine the 
                                  orientation of the polygon.
    Vivian W.Ye     3/11/1987   : take out last pole before call BSfndstrort.
    Vivian W.Ye     8/25/1988   : Use a static array for poles and knots
                                  if num_points + 2 <= SIZE.
    Vivian W.Ye     7/21/1989   : Add code to handle the case of which
                                  the minmum distance point is a cusp
                                  point.
    Vivian W.Ye     10/17/1989  : If the minimum distance point is the
                                  starting point of the polygon, call 
                                  BScveval at t(k - 1) and t(n) to find
                                  left_derv and right_derv.
    Vivian W.Ye     10/18/1989  : If pos_orient is FALSE and left_derv[1]
                                  cross right_derv[1] opposite to (0 0 1)
                                  then using left_derv cross (0 0 1) 
                                  instead of right_derv.
    Vivian W.Ye     11/30/1989  : If the minimum distance point is the
                                  cusp point, then this input point is
                                  inside fence if pos_orient = TRUE and
                                  crs_vec[2] < 0 or pos_orient = FALSE 
                                  and crs_vec[2] > 0.
    Vivian W.Ye     02/12/1990  : Replace BSmdistptcv by BSmdstptcv.
    Vivian W.Ye     02/27/1990  : Check the cross product of left_derv[1]
                                  and right_derv[1] to determine boolean
                                  flag "boundary".
    Vivian W.Ye     03/02/1990  : If boundary is TRUE then check the 
                                  cross product of left_derv[1]
                                  and right_derv[1] to determine boolean
                                  flag "boundary".
    S.G. Catron     12/11/2000  : VDS TR# 4284  Wasn't working if polyline had duplicate points.
                                  I added a call to BSrmdblpts, before creating
                                  the line string.
	Vivian Y. Hsu   08/06/2001  : Call BSfndstrort with polygon.num_points instead of 
	                              polygon.num_points - 1 to be consistant with new design of BSfndstrort.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bs.h"
#include "bsparameters.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#endif

#define  BSVOID
#define SIZE 100

void BSpt_in_plg(
struct IGRpolyline      polygon,
IGRpoint                pt,
IGRboolean              orient_known,
IGRboolean              *pos_orient,
IGRint                  *ind,
BSrc                    *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsbx2.h"
#include "bsfindspn.h"
#include "bsptlnplan.h"
#include "bsrmdblpts.h"
#include "bslftorrght.h"
#include "bscveval_b.h"
#include "bscrossp.h"
#include "bslenvec.h"
#include "bsfndstrort.h"
#include "bsmdistptcv.h"
#include "bsmdstptcv.h"
#include "bscveval.h"
#include "bscvkttol2.h"
#include "bschrdlkts.h"
#endif 
  struct IGRbsp_curve   *ln;
  IGRpoint              poles_array[SIZE];
  IGRdouble             knots_array[SIZE];
  IGRint                num_points;
  IGRdouble             dist,dist_tol,s1,s2,knot_tol;
  IGRpoint              min,max,p1,p2;
  IGRpoint              left_derv[2],right_derv[2];
  IGRvector             crs_vec;
  IGRint                num_deriv = 1;
  IGRboolean            inbox = FALSE,evel_bound = TRUE,boundary;
  IGRint                j;
  IGRboolean            status;
  IGRint                xcord,ycord,turn;
  IGRint                span_index, code;
  IGRpoint              base;
  IGRdouble             par;
  IGRshort              np, new_np;
  IGRvector             nvec;

  *rc = BSSUCC;
  ln = NULL;
  num_points = polygon.num_points;
  BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

  /* check if the polygon is closed */

  if (ABS(polygon.points[0] - polygon.points[3 * num_points - 3]) > dist_tol ||
      ABS(polygon.points[1] - polygon.points[3 * num_points - 2]) > dist_tol ||
      ABS(polygon.points[2] - polygon.points[3 * num_points - 1]) > dist_tol )
  {
    *rc = BSINARG;
    goto wrapup;
  }

 
  /* check if the input point is in the box */

  status = BSbx2(rc,(IGRlong *)&num_points,(IGRpoint *)polygon.points,NULL,min,max);
  if (!status)
    goto wrapup;
  inbox = TRUE;
  j = 0;
  while(inbox && j < 3)
  {
    s1 = min[j] - (dist_tol / 100);
    s2 = max[j] + (dist_tol / 100);
    if (pt[j] < s1 || s2 < pt[j])
    {
      inbox = FALSE;
    }
    ++j;
  }
  if (!inbox)
  {
    *ind = 0;
    goto wrapup;
  }
  else
  {
    /* allocate space for the line */
 
    ln = (struct IGRbsp_curve *)BSstackalloc((unsigned)
                              sizeof(struct IGRbsp_curve));
    if (!ln)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    ln->poles = NULL;
    ln->knots = NULL;
    ln->weights = NULL;
    ln->num_boundaries = 0;
    ln->bdrys = NULL;

    if (num_points + 2 <= SIZE)
    {
      ln->poles = (IGRdouble *)poles_array;
      ln->knots = &knots_array[0];
    }
    else
    {
      ln->poles = (IGRdouble *)BSstackalloc((unsigned)
                        (num_points * sizeof(IGRpoint)));
      if (!ln->poles)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
      ln->knots = (IGRdouble *)BSstackalloc((unsigned)
                              (2 + num_points) * sizeof(IGRdouble));
      if (!ln->knots)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
    }
    np = num_points;
    BSrmdblpts(rc, np, (IGRpoint *)polygon.points, &new_np, 
               (IGRpoint *)ln->poles);
    if(BSERROR(*rc))
      goto wrapup;
    ln->num_poles = new_np;
    ln->order = 2;
    ln->periodic = FALSE;
    ln->non_uniform = TRUE;  
    ln->rational = FALSE;    
    ln->weights = NULL;
    ln->bdrys = NULL;
    ln->num_boundaries = 0;
    ln->num_knots = 0;

    BSptlnplan( ln->num_poles, 0, (IGRpoint *) ln->poles, NULL, &code, nvec, rc );
    if (BSERROR(*rc))
      goto wrapup;
    if (code == 1)     /* points are coincident */
    {
      *rc = BSINARG;     
      goto wrapup;
    }
    if (code == 3)
      ln->planar = TRUE;
    else                    /* non-coplanar or collinear */
      ln->planar = FALSE;

    (void)BSchrdlkts(rc,&ln->num_poles,ln->poles,&ln->order,&ln->periodic,ln->knots);
    if (BSERROR(*rc))
      goto wrapup;

    BSmdstptcv(ln,pt,&par,base,&dist,rc);
    if (BSERROR(*rc))
      goto wrapup;

    if (dist < dist_tol)
    {
      *ind = 2;
      goto wrapup;
    }

    BScvkttol2(ln->order,ln->knots,ln->num_poles,ln->poles,ln->weights,
               &knot_tol,rc);
    if (BSERROR(*rc))
      goto wrapup;
  
    /* find the orientation of the polygon */

    xcord = 0;
    ycord = 1;
    if (!orient_known)
    {
       BSfndstrort(xcord,ycord,polygon.num_points,
                   (IGRpoint *)polygon.points,pos_orient,rc);
       if (BSERROR(*rc))
          goto wrapup;
    }

    status = BSfindspn(rc,&ln->order,&ln->num_poles,
                     ln->knots,&par,&span_index);
    if (!status)
      goto wrapup;

    if (ABS(par - ln->knots[ln->order - 1]) < knot_tol)
    {
      BScveval(ln,ln->knots[ln->order - 1],num_deriv,right_derv,rc);
      if (BSERROR(*rc))
        goto wrapup;

      BScveval(ln,ln->knots[ln->num_poles],num_deriv,left_derv,rc);
      if (BSERROR(*rc))
        goto wrapup;

      status = BScrossp(rc,left_derv[1],right_derv[1],crs_vec);
      if (!status)
        goto wrapup;

      dist = BSlenvec(rc,crs_vec);
      if (dist < dist_tol)
        boundary = FALSE;
      else
        boundary = TRUE;  
    }
    else
    { 
      status = BScveval_b(rc,ln,&par,&num_deriv,&evel_bound,
                          &boundary,left_derv,right_derv);
      if (!status)
        goto wrapup;

      if (boundary)
      {      
        status = BScrossp(rc,left_derv[1],right_derv[1],crs_vec);
        if (!status)
          goto wrapup;

        dist = BSlenvec(rc,crs_vec);
        if (dist < dist_tol)
          boundary = FALSE;
      }
    }
   
    if (!boundary)
    {
      if (ABS(par - ln->knots[ln->order - 1]) < knot_tol)
      {
        BScveval(ln,ln->knots[ln->num_poles - 1],0,(IGRpoint *)p1,rc);
        if (BSERROR(*rc))
          goto wrapup;
      }
      else
      {
        BScveval(ln,ln->knots[span_index],0,(IGRpoint *)p1,rc);
        if (BSERROR(*rc))
          goto wrapup;
      }

      for (j = 0; j < 3; ++j)
        p2[j] = left_derv[0][j];

      status = BSlftorrght(rc,p1,p2,pt,&xcord,&ycord,&turn);
      if (!status)
        goto wrapup;

      if ((turn == 1 && *pos_orient) || (turn == 2 && !(*pos_orient)))
        *ind = 1;
      else
        *ind = 0;
    }
    else
    {
      status = BScrossp(rc,left_derv[1],right_derv[1],crs_vec);
      if (!status)
        goto wrapup;
     
      if ( (*pos_orient && crs_vec[2] < 0) ||
           ( !(*pos_orient) && crs_vec[2] > 0))
        *ind = 1;
      else
        *ind = 0;
    }
  }

  wrapup:
    if (inbox)
    {
      if (num_points + 2 > SIZE)
      {
        if (ln->knots)
          BSstackdealloc((char *) ln->knots);
        if (ln->poles)
          BSstackdealloc((char *) ln->poles);
      }
      if (ln)
        BSstackdealloc((char *) ln);
    }
    {
    if(BSERROR(*rc))
        BSdbgrc(*rc,"BSpt_in_plg");
    return;
    }
}
