/* $Id: bsspnoffset.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bsspnoffset.c
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: bsspnoffset.c,v $
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
         BSspnoffset

Abstract
         This routine offsets a B-spline span by given an offset distance
         and a unit vector normal to the plane containing the span.

Synopsis
         void   BSspnoffset(in_cur,d,normal,right_side,off_cur,rc)
         struct IGRbsp_curve *in_cur
         IGRdouble           d
         IGRvector           normal
         IGRint              right_side
         struct IGRbsp_curve *off_cur
         BSrc                *rc

Description
         The routine inputs a B-spline curve "in_cur",an offset curve 
         "off_cur", an offset distance "d", "right_side" to specify the 
         right offset direction and a unit vector "normal" normal to the 
         plane that "in_cur" lies in. It returns "off_cur" within the 
         specified tolerance.

Return Values
         When successful, rc = BSSUCC will be returned; if failed, rc will
         return an error message(ex: BSFAIL).
Notes

         The caller should allocate all memory for off_cur to be the same as
         in_cur.

         This routine only concerns the offset of x,y coordinates
         of the curve.
Index
    md

Keywords

History
         Y. S. Sheng  01/15/87  : Creation date.
         Y. S. Sheng  02/27/87  : Replace sp with num_pars when reallocate
                                  space span_inx.
                                  Change cumsq_tol from dividing 1000 to 
                                  100.
                                  Add the checking parameters before 
                                  calling BScvarrevt.                
         Y. S. Sheng  07/15/87  : Add a call to BStstcvdegn to test if the
                                  off_cur is degenerated.
         Y. S. Sheng  08/20/87  : If curve->order = 3, set num_insert = 2.
         Y. S. Sheng  09/15/87  : Modified to offset the x and y 
                                  coordinates of the curve.
         S.G. Catron  09/30/88  : Before calling BSadd_kt, change the 
                                  knot_tol(BSchangepar), so that BSadd_kt
                                  can extract the tolerance.
         S. C. Wood   10/14/88  : Changed while loop checking if curve is
                                  within tolerance to stop after 10 iter-
                                  ations and return an error code.  This 
                                  occurs if the input curve has a cusp.
         Vivian W.Ye  10/24/88  : Add extra code in case of input curve
                                  is an arc.
         Vivian W.Ye  10/25/88  : Use BSCIRCLE_NUM_POLES_MAX and BSCIRCLE_
                                  ORDER to allocate space for arc. 
         S.G. Catron  12/22/88  : If off_cur happens to be degenerate,
                                  the z coordinate still needs to be set.
         S.G. Catron  02/28/89  : There doesn't need to be a temporary
                                  array for "pars", just to get the 
                                  interior parameters.
         S. C. Wood   07/19/89  : Calculate vector (nvec) normal to in_cur.
                                  Perform special calculation of arc offset
                                  only if the curve is planar and the curve
                                  normal and view normal are same. 
         S. C. Wood   08/29/89  : Set z-values of curve = 0.0 prior to 
                                  calculating cummulative distance in order
                                  to have x-y distance only.  This distance
                                  is used to calculate cumsq_tol which is
                                  passed into BStstspn1 to determine if
                                  the offset curve (off_cur) is within 
                                  tolerance.
         S. C. Wood   01/23/90  : Included code to insure the generation of
                                  a point curve offset only if offsetting to
                                  to the inside of the arc when rad = d.
         S. C. Wood   02/13/90  : If curve->order = 3, set num_insert = 5
                                  instead of 2 to generate better offset.
         S.R. Meeth   10/10/90  : Changed declaration and typecasting of
                                  "tangent" for allocation.
         S. C. Wood   06/05/91  : Changed declaration of deg from IGRint
                                  to IGRshort.
         S. C. Wood   08/21/91  : When determining if curve is an arc, check
                                  if fabs(1.0 - ABS(dotp)) < dot_tol to account
                                  for nvec (returned from BStst_plan) being 
                                  opposite of given normal.
         S. C. Wood   03/28/96  : Modified algorithm to continue to insert
                                  knots until offset curve is within tolerance.
                                  Previously, we assumed that the offset
                                  curve was within tolerance when the
                                  points at node and midnodes were within
                                  tolerance.
         S. C. Wood   04/18/96  : Corrected uninitialized memory read
				  in checking if the last elemente in
 			          pars array is the same as the knot
				  value at (num_poles - 1).  Check 
				  pars[num_tst] instead of pars[num_tst-1].
*/
#include <math.h>
# include "bsdefs.h"
# include "bserr.h"
# include "bsmalloc.h"
# include "bsstackalloc.h"
#define   BSVOID
# include "bsparameters.h"
# include "bsconic.h"
# include "bsmemory.h"

# define MAXNUM 100

void    BSspnoffset(
struct IGRbsp_curve *in_cur,
IGRdouble  d,               
IGRvector  normal,          
IGRint     right_side,
struct IGRbsp_curve *off_cur,   
BSrc       *rc)                 
{
#include "bsdbgrc.h"
#include "bssetspn.h"
#include "bsadd_kt.h"
#include "bscv_copy.h"
#include "bscumdist.h"
#include "bsfreecv.h"
#include "bschangepar.h"
#include "bsnodevals.h"
#include "bststspn1.h"
#include "bscvkttol2.h"
#include "bsalloccv.h"
#include "bscvarrevt.h"
#include "bststcvdegn.h"
#include "bststcvfarc.h"
#include "bschgcvewts.h"
#include "bstst_plan.h"
#include "bsptcvgen.h"
#include "bsarc3pts.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsupthe_deg.h"
#include "bsdotp.h"
#include "bstagsort.h"


    IGRboolean status,in_tol=TRUE,degen;         
    struct IGRbsp_curve *curve = NULL,*arc = NULL;
    IGRvector  nvec;
    IGRint     i,j, count=0;
    IGRint     mul;
    IGRint     num_inx = 0,num_tst = 0,num_add = 0;
    IGRint     *span_inx = NULL;
    IGRdouble  *mid_t = NULL;
    IGRint     num_insert,num_pars, new_num_pars, cnt;
    IGRint     *sort_ind = NULL, sort_ind2[MAXNUM];
    IGRboolean alloc_sort_ind=FALSE;
    IGRpoint   *tangent= NULL;
    IGRdouble  *points = NULL, *tmp_points = NULL;
    IGRdouble  display,knot_tol, sknot_tol;
    IGRdouble  *pars = NULL, *new_pars = NULL, *tmp_pars = NULL;
    IGRdouble  dist,cumsq_tol;
    IGRvector  tan_vec,cross_vec,center_vec,dir_vec;
    IGRboolean arc_ind;
    IGRpoint   center,of_pt[3],result[3][2];
    IGRvector  vec,crs_vec[3];
    IGRdouble  rad,par[3],dist_tol,dot_tol;
    IGRshort     deg;
    IGRboolean planar;
    IGRdouble  dotp = 0.0;
    IGRdouble  *z1_temp = NULL, z1_temp2[MAXNUM];
    IGRboolean alloc_z1_temp = FALSE;
    IGRint     num_alloc_pars=0, num_alloc_tangent=0, num_alloc_points=0,
               num_alloc_span_inx=0, num_alloc_mid_t=0, num_alloc_new_pars=0,
               num_alloc_tmp_pars=0, num_alloc_tmp_points=0, factor=10;
    BSrc       rc1 = BSSUCC;

    *rc = BSSUCC;

    BSEXTRACTPAR(rc, BSTOLKNOT, sknot_tol);
    BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
    BSEXTRACTPAR(rc, BSTOLORTHOVEC, dot_tol);

    BSalloccv(in_cur->order, in_cur->num_poles, in_cur->rational,
             0, &curve, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    status = BScv_copy(rc, in_cur, curve);
    if (! status) 
      goto wrapup;

    /* determine vector normal to planar curve */

    BStst_plan(curve->num_poles, curve->poles, curve->weights, &planar, 
               nvec, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    if (planar)
    {
       dotp = BSdotp(rc, normal, nvec);
       if(BSERROR(*rc)) 
         goto wrapup;
    }

    /* special code for arc */

    if (planar && curve->rational && curve->order > 3 && 
        fabs(1.0 - ABS(dotp)) < dot_tol)
    {
      BSalloccv(BSCIRCLE_ORDER,BSCIRCLE_NUM_POLES_MAX,1,0,&arc,rc);
      if (BSERROR(*rc))
        goto wrapup;
      BStstcvfarc(curve,&arc_ind,center,&rad,arc,rc);
      if (BSERROR(*rc))
        goto wrapup;
      if (arc_ind)
      {
        for (i = 0; i < 3; ++i)
        {
            if (curve->rational)
            {
               tan_vec[i] = curve->poles[i + 3] / curve->weights[1] -
                            curve->poles[i] / curve->weights[0];
            }
            else
            {
               tan_vec[i] = curve->poles[i + 3] - curve->poles[i];
            }

            center_vec[i] = center[i] - (curve->poles[i] / curve->weights[0]);
        }

        status = BScrossp(rc, tan_vec, normal, dir_vec);
        if (!status)
           goto wrapup;
 
        for (i = 0; i < 3; ++i)
        {
            dir_vec[i] = dir_vec[i] * right_side;
        }

        dotp = BSdotp(rc, center_vec, dir_vec);

        /* Generate a point curve only when offsetting to the inside of an
           arc when rad = d. */
        if ( ABS(rad - d) < dist_tol && dotp > 0.0)
        {
          BSptcvgen(center,curve->order,curve->rational,off_cur,rc);
          if (BSERROR(*rc))
            goto wrapup;
        }
        else
        {
          par[0] = curve->knots[curve->order - 1];
          par[1] = (curve->knots[curve->order - 1] + 
                     curve->knots[curve->num_poles]) / 2;
          par[2] = curve->knots[curve->num_poles];
      
          BScvarrevt(curve,par,3,1.0,result,rc);
          if (BSERROR(*rc))
            goto wrapup;
       
          for (i = 0;i < 3; ++i)
          {
            for (j = 0; j < 3; ++j)
              vec[j] = result[i][1][j] - result[i][0][j];
       
            status = BScrossp(rc,vec,normal,crs_vec[i]);
            if (!status)
              goto wrapup;
            status = BSnorvec(rc,crs_vec[i]);
            if (!status)
              goto wrapup;
      
            for (j = 0; j < 3; ++j)
              of_pt[i][j] = result[i][0][j] + 
                            crs_vec[i][j] * d * right_side;
          }
      
          status = BSarc3pts(rc,of_pt[0],of_pt[1],of_pt[2],off_cur);
          if (!status)
            goto wrapup;
          
          deg = curve->order - 1;
          status = BSupthe_deg(rc,off_cur,&deg);
          if (!status)
            goto wrapup;
        }
        goto wrapup;
      }
    }

    BScvkttol2(curve->order, curve->knots, curve->num_poles, curve->poles,
               curve->weights, &knot_tol, rc);
    if(BSERROR(*rc)) 
       goto wrapup;

    status = BScv_copy(rc, in_cur, off_cur);
    if(! status) 
       goto wrapup;

    /** Calculate cumsq_tol used for BStstspn1 **/

    /* Set z-values of curve->poles = 0.0 to calculate cummulative x-y 
       distance. (08/29/89) */
    if (curve->num_poles > MAXNUM)
    {
       z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
                              (curve->num_poles * sizeof(IGRdouble)));
       if (! z1_temp)
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_z1_temp = TRUE;
    }
    else
    {
       z1_temp = z1_temp2;
    }

    for (j = 0; j < curve->num_poles; ++j)
    {
        z1_temp[j] = curve->poles[3 * j + 2];
        curve->poles[3 * j + 2] = 0.0;
    }

    status = BScumdist(rc, &curve->num_poles, curve->poles,
                       curve->weights, &dist);
    if(! status) 
      goto wrapup;
 
    cumsq_tol = dist / 100;

    /* Reset z-values of curve->poles back to original values. (08/29/89) */
    for (j = 0; j < curve->num_poles; ++j)
    {
        curve->poles[3 * j + 2] = z1_temp[j];
    }


    /** Offset the polygon of "curve" **/

    for(i= curve->order -1; i <= curve->num_poles -1; i++)
    {
        BSsetspn(i, curve, d, normal, right_side, off_cur,rc);
        if(BSERROR(*rc)) 
           goto wrapup;

    }

   /*************
        if off_cur is degenerated, then skip the test and return
        the off_cur.
    ******************/

    BStstcvdegn(off_cur,&degen,rc);
    if(BSERROR(*rc)) 
       goto wrapup;
    if (degen || off_cur->order == 2)
    {
      /* We are done */
      goto set_zcord;
    }

    /*******
     Check if the "off_cur" is within tolerance, if not, add knots 
     on "curve" and reoffset again until it meets the tolerance
     requirement.
    ********/   

    /****
     Find node and mid-node parameters on "curve".
    *****/
  
    num_insert= 1;        


    /* SCW 03/01/96: Use malloc instead of stackalloc so we
       can realloc later */

    num_alloc_pars = ((curve->num_poles  - 1) * 
                                (num_insert + 1) + 1) * factor;
    pars = (IGRdouble *)BSmalloc((unsigned) num_alloc_pars * 
                       sizeof(IGRdouble ));
    if(! pars)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
 
    BSnodevals(curve->order, curve->num_knots, curve->knots, 
               num_insert, &num_pars, pars, rc);
    if(BSERROR(*rc))
    {
      status = FALSE;
      goto wrapup;
    }
    
    /* SCW 03/01/96: Use malloc instead of stackalloc so we
       can realloc later */

    num_alloc_tangent = 10*num_pars;
    tangent = (IGRpoint *)BSmalloc((unsigned)(num_alloc_tangent *
                          sizeof(IGRpoint)));
    if(! tangent) 
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    display = 1.0;
    if(fabs(pars[0] - curve->knots[curve->order -1]) < knot_tol)
    {
      pars[0] = curve->knots[curve->order -1];
    }
    
    if(fabs(pars[num_pars - 1] - curve->knots[curve->num_poles]) 
        < knot_tol)
    {
       pars[num_pars - 1] = curve->knots[curve->num_poles];
    }

    BScvarrevt(curve, pars, num_pars, display, (IGRpoint (*)[2])tangent,
               rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    /* SCW 03/01/96: Use malloc instead of stackalloc so we
       can realloc later */

    num_alloc_points = (num_pars - 2) * 3 * factor;
    points = (IGRdouble *)BSmalloc((unsigned)(num_alloc_points * 
             sizeof(IGRdouble)));

    if(! points) 
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    for(i=1; i <= (num_pars - 2); i++)
    {
      status = BSmkvec(rc,tan_vec,tangent[2*i],tangent[2*i+1]);
      if(! status) 
        goto wrapup;

      tan_vec[2] = 0.0;  /** set z to be zero **/

      status = BScrossp(rc, tan_vec, normal, cross_vec);
      if(! status)
        goto wrapup;

      status = BSnorvec(rc,cross_vec);
      if(! status) 
        goto wrapup;

      points[(i-1) * 3] =  tangent[2*i][0] + d * 
                                right_side * cross_vec[0];
      points[(i-1) * 3 +1] =  tangent[2*i][1] + d * 
                                right_side * cross_vec[1];
      points[(i-1) * 3 + 2] = 0.0;
    }
  
    num_alloc_span_inx = num_pars * factor;
    span_inx = (IGRint *)BSmalloc((unsigned)(num_alloc_span_inx * 
               sizeof(IGRint)));
    if(! span_inx)
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }

    /********
     Test only interior parameters
    *********/

    num_pars = num_pars - 2; 
        
    BStstspn1(num_pars,cumsq_tol,&pars[1],(IGRpoint *)points,
              curve,off_cur,&num_inx,span_inx,&num_tst,&in_tol,
              rc);
    if (BSERROR(*rc))
      goto wrapup;
      
    while( !in_tol && count < 15 )
    {
      /* SCW 03/01/96 : Add code to store mid pars into new_pars*/
    
      if (count == 0)
      {
        num_alloc_mid_t = (num_inx + 1) * factor;
        mid_t = (IGRdouble *)BSmalloc((unsigned)(num_alloc_mid_t *
                 sizeof(IGRdouble)));
        if(! mid_t)
        {
          *rc = BSNOMEMORY;
          goto wrapup;
        }

        num_alloc_new_pars = num_inx * 10;
        new_pars = (IGRdouble *)BSmalloc((unsigned)
                   (num_alloc_new_pars * sizeof(IGRdouble)));
        if(! new_pars) 
        {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
        }

        /* If count == 0, mid_t is already in pars array as
           mid-node values. ?????*/

        for(i=0; i < num_inx; i++)
        {
          mid_t[i] = (curve->knots[span_inx[i]] + 
          curve->knots[span_inx[i] + 1 ]) * 0.5;
          new_pars[i*2] = (curve->knots[span_inx[i]] + 
			      mid_t[i] ) * 0.5;
          new_pars[i*2+1] = (mid_t[i] + 
          curve->knots[span_inx[i] + 1 ]) * 0.5;
        }         
      }
      else
      {
         /* count != 0 */

         for(i=0; i < num_inx; i++)
         {
           mid_t[i] = (curve->knots[span_inx[i]] + 
           curve->knots[span_inx[i] + 1 ]) * 0.5;
           new_pars[i*3] = (curve->knots[span_inx[i]] + 
			      mid_t[i] ) * 0.5;
           new_pars[i*3+1] = mid_t[i];
           new_pars[i*3+2] = (mid_t[i] + 
           curve->knots[span_inx[i] + 1 ]) * 0.5;
         }         
      }
    
      num_add = num_inx;

      /**********
       If the last node in "pars" is the same as knot value at
       (num_poles - 1) then we insert mid-knots at both the
       span we  are supposed to insert and also the next span.
       ***********/
 
      /* SCW 04/18/96: Test pars[num_tst] instead of pars[num_tst-1]
         because we pass in pars[1] into BStstspn1 which returns
 	 num_tst as the number of pars returned that need to be
         retested. */

      if(fabs(pars[num_tst] - curve->knots[curve->num_poles - 1]) < knot_tol)
      {
        mid_t[num_inx] = (curve->knots[curve->num_poles -1] +
        curve->knots[curve->num_poles]) * 0.5;
        num_add = num_add + 1;

        if (count == 0)
        {
          new_pars[i*2] = (curve->knots[curve->num_poles - 1] + 
			      mid_t[num_inx] ) * 0.5;
          new_pars[i*2+1] = (mid_t[num_inx] + 
          curve->knots[curve->num_poles]) * 0.5;
        }
        else
        {
          new_pars[i*3] = (curve->knots[curve->num_poles - 1] + 
			      mid_t[num_inx] ) * 0.5;
          new_pars[i*3+1] = mid_t[i];
          new_pars[i*3+1] = (mid_t[num_inx] + 
          curve->knots[curve->num_poles]) * 0.5;
        }
      }

      /* call BSchangepar, so that BSadd_kt
         can extract the tolerance */

      status = BSchangepar(rc, BSTOLKNOT, knot_tol);
      if(BSERROR(*rc))
         goto wrapup;
     
      for(i=0; i < num_add; i++)
      {
        mul = 1;

        status = BSadd_kt(rc, curve, &mid_t[i], &mul);
        if(! status) 
          goto wrapup;
      }

      status = BSchangepar(rc, BSTOLKNOT, sknot_tol);
      if(BSERROR(*rc))
         goto wrapup;

      /** reallocate space for "off_cur" **/

      off_cur->poles = (IGRdouble *)BSrealloc((char*)
                        off_cur->poles,(unsigned)(curve->num_poles
                        * sizeof(IGRpoint)));
      if(! off_cur->poles)
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }

      if(off_cur->rational)
      {
        off_cur->weights = (IGRdouble *)BSrealloc((char*)
                            off_cur->weights,(unsigned)(
                            curve->num_poles * sizeof(IGRdouble)));
        if(! off_cur->weights)
        {
          *rc = BSNOMEMORY;
          goto wrapup;
        }
      }
    
      off_cur->knots = (IGRdouble *)BSrealloc((char*)
                        off_cur->knots,(unsigned)(curve->num_knots
                        * sizeof(IGRdouble)));
      if(! off_cur->knots)
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }
         
      status = BScv_copy(rc, curve, off_cur);
      if(! status) 
         goto wrapup;
    
      /** Offset the polygon of "curve" **/

      for(i= curve->order -1; i <= curve->num_poles -1; i++)
      {
        BSsetspn(i, curve, d, normal, right_side, off_cur,rc);
        if(BSERROR(*rc))
          goto wrapup;
      }

      /* SCW 03/01/96: Set num_pars to account for values
         to be inserted */

      if (count == 0)
         num_pars = num_tst + num_inx * 2;
      else
         num_pars = num_tst + num_inx * 3;

      if (num_pars > num_alloc_span_inx)
      {
         num_alloc_span_inx = num_pars * factor;
         span_inx = (IGRint *)BSrealloc((char *)span_inx,(unsigned)
                    (num_alloc_span_inx * sizeof(IGRint)));
         if(! span_inx)
         {
           *rc = BSNOSTKMEMORY;
           goto wrapup;
         }
      }

      /* SCW 03/01/96: Set up new pars, points, and tangent 
         array to include new_pars */
      if (num_pars+1 > num_alloc_pars)
      {
         num_alloc_pars = (num_pars + 1) * factor;
         pars = (IGRdouble *)BSrealloc((char *)pars,(unsigned)(
        (num_alloc_pars) * sizeof(IGRdouble)));
         if(! pars)
         {
           *rc = BSNOMEMORY;
           goto wrapup;
         }
      }

      new_num_pars = num_pars - num_tst;
      if (num_pars * 3 > num_alloc_points)
      {
        num_alloc_points = num_pars * 3 * factor;
        points = (IGRdouble *)BSrealloc((char *)points,(unsigned)(
                 (num_alloc_points) * sizeof(IGRdouble)));
        if(! points)
        {
           *rc = BSNOMEMORY;
           goto wrapup;
        }
      }

      if (new_num_pars*2 > num_alloc_tangent)
      {
        num_alloc_tangent = new_num_pars * 10;
        tangent = (IGRpoint *)BSrealloc((char *)tangent,(unsigned)(
        (num_alloc_tangent) * sizeof(IGRpoint)));
        if(! tangent)
        {
          *rc = BSNOMEMORY;
          goto wrapup;
        }
      }

      BSMEMCPY(new_num_pars * sizeof (IGRdouble), 
              (IGRchar *)&new_pars[0], (IGRchar *)&pars[num_tst+1]);

      BScvarrevt(curve, new_pars, new_num_pars, display, 
      (IGRpoint (*)[2])tangent, rc);
      if (BSERROR(*rc)) 
        goto wrapup;
   
      cnt = 0;
      for (i = num_tst+1; i <= num_pars; ++i)
      {
        status = BSmkvec(rc,tan_vec,tangent[2*cnt],tangent[2*cnt+1]);
        if (! status) 
          goto wrapup;
        tan_vec[2] = 0.0;  /** set z to be zero **/

        status = BScrossp(rc, tan_vec, normal, cross_vec);
        if (! status) 
          goto wrapup;

        status = BSnorvec(rc,cross_vec);
        if (! status) 
          goto wrapup;

        points[(i-1) * 3] =  tangent[2*cnt][0] + d * right_side * cross_vec[0];
        points[(i-1) * 3 +1] =  tangent[2*cnt][1]+d*right_side * cross_vec[1];
        points[(i-1) * 3 + 2] = 0.0;
        ++cnt;
      }

      /* Sort indexes of pars and points based on pars. */

      num_alloc_tmp_pars = (num_pars + 1) * factor;
      tmp_pars = (IGRdouble *)BSmalloc((unsigned)(num_alloc_tmp_pars *
                  sizeof(IGRdouble)));
      if(! tmp_pars)
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }

      num_alloc_tmp_points = (num_pars+1) * 3 * factor;
      tmp_points = (IGRdouble *)BSmalloc((unsigned)
                    num_alloc_tmp_points * sizeof(IGRdouble));
      if(! tmp_points)
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }

      if (num_pars + 1 > MAXNUM)
      {
        sort_ind = (IGRint *)BSstackalloc((unsigned)((num_pars + 1)* 
                   sizeof(IGRint)));
        if(! sort_ind)
        {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
        }
        alloc_sort_ind = TRUE;
      }
      else
      {
        sort_ind = sort_ind2;
      }

      BStagsort(rc, &num_pars, &pars[1], sort_ind);
      if (BSERROR(*rc))
        goto wrapup;

      tmp_pars[0] = pars[0];
      for (i = 1; i < num_pars+1; ++i)
      {
        tmp_pars[i] = pars[sort_ind[i-1]+1];
        tmp_points[(i-1)*3] = points[sort_ind[i-1]*3];
        tmp_points[(i-1)*3+1] = points[sort_ind[i-1]*3+1];
        tmp_points[(i-1)*3+2] = points[sort_ind[i-1]*3+2];
      }

      /* Deallocate pars and points and reset = tmp_pars and 
        tmp_points */

      if (pars)
      {
        BSdealloc((char *) pars);
        pars = tmp_pars;
      }

      if (points)
      {
        BSdealloc((char *) points);
        points = tmp_points;
      }

      if (sort_ind && alloc_sort_ind)
      {
        BSstackdealloc((char *) sort_ind);
        sort_ind = NULL;
        alloc_sort_ind = FALSE;
      }
 
      BStstspn1(num_pars,cumsq_tol,&pars[1],(IGRpoint *)points,
                curve, off_cur,&num_inx,span_inx,&num_tst,&in_tol, rc);
      if(BSERROR(*rc)) 
        goto wrapup;

  
      if (num_inx + 1 > num_alloc_mid_t)
      {
        num_alloc_mid_t = (num_inx + 1) * factor;
        mid_t = (IGRdouble *)BSrealloc((char *)mid_t,(unsigned)(
                 (num_alloc_mid_t) * sizeof(IGRdouble))); 
        if(! mid_t)
        {
          *rc = BSNOMEMORY;
          goto wrapup;
        }
      }

      if ((num_inx + 1) * 3 > num_alloc_new_pars)
      {
        num_alloc_new_pars = (num_inx + 1) * 3 * factor;
        new_pars = (IGRdouble *)BSrealloc((char *)new_pars,(unsigned)(
        num_alloc_new_pars * sizeof(IGRdouble)));
        if(! new_pars)
        {
          *rc = BSNOMEMORY;
          goto wrapup;
         }
      }
      count++;

    } /** end of "while" **/
            
    if (count == 15)
      *rc = BSWARN; 

 set_zcord:

    /**----------------------------------------------
        Assign the z-coordinate back to the offset span
     --------------------------------------------------**/

    for(i=0; i < curve->num_poles; i++)
    {
      off_cur->poles[3 * i + 2] = curve->poles[3 * i + 2];
    }

  wrapup:

     /* if no error then it's already been changed */
     if( curve->order >= 3 && BSERROR(*rc))
        status = BSchangepar(&rc1, BSTOLKNOT, sknot_tol);
       
     if(mid_t) 
        BSdealloc((char*)mid_t);
     if(span_inx) 
        BSdealloc((char *)span_inx);
     if(points) 
        BSdealloc((char*)points);
     if(tangent) 
        BSdealloc((char*)tangent);
     if(pars) 
        BSdealloc((char*)pars);
     if (alloc_z1_temp)                
     {
        BSstackdealloc((char *) z1_temp);
        z1_temp = NULL;
     }
     if(curve)
     {
         status = BSfreecv(&rc1,curve);
     }
     if(BSERROR(*rc))
     {
         status = FALSE;
     }
     if(BSERROR(rc1))
     {
         *rc = rc1;
         status = FALSE;
     }
     if (arc)
     {
       status = BSfreecv(&rc1,arc);
       if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
     }
     if(new_pars) 
     {
        BSdealloc((char*)new_pars);
        new_pars = NULL;
     }

     if (tmp_pars && tmp_pars != pars)
     {
        BSdealloc((char*)tmp_pars);
        tmp_pars = NULL;
     }
     if (tmp_points && tmp_points != points)
     {
        BSdealloc((char*)tmp_points);
        tmp_points = NULL;
     }
     if (sort_ind && alloc_sort_ind)
     {
        BSstackdealloc((char *) sort_ind);
        sort_ind = NULL;
     }

     {
     if(BSERROR(*rc))
         BSdbgrc(*rc,"BSspnoffset");
     return;
     }
}         
