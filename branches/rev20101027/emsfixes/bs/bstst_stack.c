/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BStst_stack

Abstract
    This function accepts a stack containing portions of two B-spline
curves. It tests and subdivides until a pair of sub-segments is obtained
whose curve-polygons both do not self intersect.
The stack is updated in the process so as to contain all remaining
unexamined cases. 

Synopsis
    IGRboolean BStst_stack(rc,num,stack,a_copy,b_copy)

    BSrc       *rc
    IGRint     *num
    struct IGRbsp_curve 
               ***stack
    struct IGRbsp_curve 
               *a_copy,
               *b_copy

Description
    This routine inputs the number of curves in the stack(num) and a stack of
curves(stack, is a pointer to an array of pointers to curves ).  It outputs
a modified stack of curves.

Return Values
    BSSUCC is returned if all is successful.

Notes
    The caller needs to allocate the space for a_copy and b_copy
which have the same size as the two last curves in the
stack.

Index
    md

Keywords

History
    Y. S. Sheng  01/09/86  : Creation date.
    Y. S. Sheng   12/19/86 : Replace BScvkttol to BScvkttol2. 
    Y. S. Sheng   01/13/87 : Remove the error message if the
                             split point is close to the end point
                             of the curve.
    Y. S. Sheng   03/05/87 : Replace knot_tol with dist_tol when
                             checking degenerated curves.
    Y. S. Sheng   05/06/87 : Common out the statements containing
                             split2 for avoiding lint error.
    Y. S. Sheng   06/25/87 : Add checking criteria for splitting
                             curves to be "if(dist2 > dist_tol)".
    S.G. Catron   05/04/88 : Changed to use static arrays instead of allocating.
    S.G. Catron   04/07/89 : There is no need to allocate array[i] since
                             we are setting array[i] = p2_cur.
    Vivian.Y.Hsu  04/07/98 : Fixed a crash for a VDS TR. In case of tmid
                             is very close to end knots, set split1(2) to
                             be FALSE. Do not call BScvsplit in this case 
                             because it can not split and returns only
                             one curve.
*/
#include <math.h>
#define  BSVOID
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsparameters.h"

#ifndef NULL
#define NULL 0
#endif

IGRboolean BStst_stack(
BSrc      *rc,               
IGRint     *num,              
struct IGRbsp_curve ***stack,  
struct IGRbsp_curve *a_copy,  
struct IGRbsp_curve *b_copy)  
{
#include "bsdbgrc.h"
#include "bsls_slfint.h"
#include "bscvsplit.h"
#include "bsunwght_p.h"
#include "bscv_copy.h"
#include "bsendptinbx.h"
#include "bscumdist.h"
#include "bscvkttol2.h"
    IGRboolean status;
    IGRboolean int1,int2;
    IGRboolean inbox1,inbox2;
    IGRboolean split1 = TRUE;
    IGRdouble  a_poles[MAX_ORDER * 3];
    IGRdouble  b_poles[MAX_ORDER * 3];
    IGRdouble  tmid;
    IGRdouble  knot_tol1,knot_tol2;
    IGRdouble  dist1,dist2,dist_tol;

    struct IGRbsp_curve **array;
    struct IGRbsp_curve *p_cur,*q_cur;
    struct IGRbsp_curve *p1_cur,*q1_cur,
                       *p2_cur,*q2_cur;
    IGRlong    mp,mq;
    IGRint     i;
    IGRboolean planar = FALSE;

    status = TRUE;
    *rc = BSSUCC;

    BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

    array = *stack;

    /**********************
         find the last two curves of the stack
    ***********************/
         
    p_cur = array[*num - 2];
    q_cur = array[*num - 1];

    /***********************
         copy curves p_cur and q_cur
    ************************/

    status = BScv_copy(rc,p_cur,a_copy);
    if(! status) goto wrapup;

    status = BScv_copy(rc,q_cur,b_copy);
    if(! status) goto wrapup;

    BSdealloc((char *)p_cur->poles);
    BSdealloc((char *)p_cur->knots);
    if(p_cur->rational)
    {
         BSdealloc((char *)p_cur->weights);
    }
    BSdealloc((char *)array[*num - 2]);

    BSdealloc((char *)q_cur->poles);
    BSdealloc((char *)q_cur->knots);
    if(q_cur->rational)
    {
         BSdealloc((char *)q_cur->weights);
    }
    BSdealloc((char *)array[*num - 1]);

    *num = *num - 2;

    mp = a_copy->num_poles;
    mq = b_copy->num_poles;


    /***********************
         test if a_copy has self intersection
    ************************/

    if(a_copy->rational)
    {
         status = BSunwght_p(rc,a_copy->poles,a_copy->weights,
                               &mp,a_poles);
         if(! status) goto wrapup;
    }
    else
    {
         for(i=0; i < (3 * mp); i++)
         {
             a_poles[i] = a_copy->poles[i];
         }
    }

    status = BSls_slfint(rc,(IGRint *)&mp,a_poles,&int1);
    if(! status) goto wrapup;        

    /***********************
        test if b_copy has self intersection
    ************************/

    if(b_copy->rational)
    {
        status = BSunwght_p(rc,b_copy->poles,b_copy->weights,
                              &mq,b_poles);
        if(! status) goto wrapup;
    }
    else
    {
        for(i=0; i < (3 * mq); i++)
        {
             b_poles[i] = b_copy->poles[i];
        }
    }

    status = BSls_slfint(rc,(IGRint *)&mq,b_poles,&int2);
    if(! status) goto wrapup;        

    /****************
        find the tolerance for a_copy and b_copy
    ******************/

    BScvkttol2(a_copy->order, a_copy->knots, mp, a_copy->poles, 
               a_copy->weights, &knot_tol1,rc);
    if(BSERROR(*rc)) goto wrapup;

    BScvkttol2(b_copy->order, b_copy->knots, mq, b_copy->poles, 
               b_copy->weights, &knot_tol2,rc);
    if(BSERROR(*rc)) goto wrapup;


    if(int1)
    {
         tmid = (a_copy->knots[0] +
                   a_copy->knots[mp]) / 2.0;

         status = BScumdist(rc,&a_copy->num_poles,a_copy->poles,
                   a_copy->weights,&dist1);
         if(! status) goto wrapup;

         if(dist1 < dist_tol ||
            fabs(a_copy->knots[0] - tmid) < knot_tol1 ||
            fabs(a_copy->knots[mp] - tmid) < knot_tol1)
         {
             split1 = FALSE;
         }
         else
         {
             split1 = TRUE;
             p1_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                   IGRbsp_curve)));
             if (! p1_cur)
             {
                 *rc = BSNOMEMORY;
                 status = FALSE;
                 goto wrapup;
             }
             p1_cur->poles = NULL;
             p1_cur->weights = NULL;
             p1_cur->knots = NULL;
             p1_cur->num_boundaries = 0;
             p1_cur->bdrys = NULL;

             q1_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                   IGRbsp_curve)));
             if (! q1_cur)
             {
                 *rc = BSNOMEMORY;
                 status = FALSE;
                 goto wrapup;
             }
             q1_cur->poles = NULL;
             q1_cur->weights = NULL;
             q1_cur->knots = NULL;
             q1_cur->num_boundaries = 0;
             q1_cur->bdrys = 0;

             status = BScvsplit(rc,a_copy,&tmid,p1_cur,q1_cur,&planar);
             if(! status) goto wrapup;

             /****************************
                  put p1_cur and q1_cur into the stack
             *****************************/

             array[*num] = p1_cur;
             array[*num + 1] = q1_cur;
             *num = *num + 2;
         }
     }
     else
     {
         status = BSendptinbx(rc,a_copy,&inbox1);
         if(! status) goto wrapup;

         if(inbox1)
         {
             tmid = (a_copy->knots[0] +
                     a_copy->knots[mp]) / 2.0;

             status = BScumdist(rc,&a_copy->num_poles,a_copy->poles,
                       a_copy->weights,&dist1);
             if(! status) goto wrapup;

             if(dist1 < dist_tol ||
                fabs(a_copy->knots[0] - tmid) < knot_tol1 ||
                fabs(a_copy->knots[mp] - tmid) < knot_tol1)
             {
                 split1 = FALSE;
             }
             else
             {
                 split1 = TRUE;
                 p1_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                                    IGRbsp_curve)));
                 if (! p1_cur)
                 {
                    *rc = BSNOMEMORY;
                    status = FALSE;
                    goto wrapup;
                 }
                 p1_cur->poles = NULL;
                 p1_cur->weights = NULL;
                 p1_cur->knots = NULL;
                 p1_cur->num_boundaries = 0;
                 p1_cur->bdrys = NULL;
   
                 q1_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                           IGRbsp_curve)));
                 if (! q1_cur)
                 {
                    *rc = BSNOMEMORY;
                    status = FALSE;
                    goto wrapup;
                 }
                 q1_cur->poles = NULL;
                 q1_cur->weights = NULL;
                 q1_cur->knots = NULL;
                 q1_cur->num_boundaries = 0;
                 q1_cur->bdrys = NULL;

                 status = BScvsplit(rc,a_copy,&tmid,p1_cur,q1_cur,&planar);
                 if(! status) goto wrapup;

                 /****************************
                       put p1_cur and q1_cur into the stack
                 *****************************/
 
                 array[*num] = p1_cur;
                 array[*num + 1] = q1_cur;

                 *num = *num + 2;
             }
         }
     }
     if(int2)
     {
         tmid = (b_copy->knots[0] +
                   b_copy->knots[mq]) / 2.0;

         status = BScumdist(rc,&b_copy->num_poles,b_copy->poles,
                   b_copy->weights,&dist2);
         if(! status) goto wrapup;

      /* if(dist2 < dist_tol)
         {
             split2 = FALSE;
         }
         else
         {
             split2 = TRUE;
      */
         if(dist2 > dist_tol &&
            fabs(b_copy->knots[0] - tmid) > knot_tol2 &&
            fabs(b_copy->knots[mq] - tmid) > knot_tol2)
         {
             p2_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                         IGRbsp_curve)));
             if (! p2_cur)
             {
                *rc = BSNOMEMORY;
                status = FALSE;
                goto wrapup;
             }
             p2_cur->poles = NULL;
             p2_cur->weights = NULL;
             p2_cur->knots = NULL;
             p2_cur->num_boundaries = 0;
             p2_cur->bdrys = NULL;

             q2_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                         IGRbsp_curve)));
             if (! q2_cur)
             {
                *rc = BSNOMEMORY;
                status = FALSE;
                goto wrapup;
             }
             q2_cur->poles = NULL;
             q2_cur->weights = NULL;
             q2_cur->knots = NULL;
             q2_cur->num_boundaries = 0;
             q2_cur->bdrys = NULL;

             status = BScvsplit(rc,b_copy,&tmid,p2_cur,q2_cur,&planar);
             if(! status) goto wrapup;
    
             if((int1 || inbox1) && split1)
             {

                 *num = *num + 2;

                 /** reallocate pointers **/

                 *stack = (struct IGRbsp_curve **)BSrealloc((char *)*stack,
                             (unsigned)(*num * sizeof(struct IGRbsp_curve *)));
                 if (! *stack)
                 {
                     *rc = BSNOMEMORY;
                     status = FALSE;
                     goto wrapup;
                 }

                 array = *stack;

                 /*** allocate the space for curve structures ***/

/*
                 m = *num;
                 for(i=m; i < *num; i++)
                 {
                     array[i] = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof
                               (struct IGRbsp_curve)));
                     if (! array[i])
                     {
                         *rc = BSNOMEMORY;
                         status = FALSE;
                         goto wrapup;
                     }
                 } */

                 array[*num - 2] = p2_cur;
                 array[*num - 1] = q2_cur;
              }
              else
              {
                  array[*num] = p2_cur;
                  array[*num + 1] = q2_cur;
                  *num = *num + 2;
              }
         }
     }
     else
     {
          status = BSendptinbx(rc,b_copy,&inbox2);
          if(! status) goto wrapup;

          if(inbox2)
          {
              tmid = (b_copy->knots[0] +
                      b_copy->knots[mq]) / 2.0;

              status = BScumdist(rc,&b_copy->num_poles,b_copy->poles,
                       b_copy->weights,&dist2);
              if(! status) goto wrapup;

       /*     if(dist2 < dist_tol)
              {
                  split2 = FALSE;
              }
              else
              {
                  split2 = TRUE;
       */

              if(dist2 > dist_tol &&
                 fabs(b_copy->knots[0] - tmid) > knot_tol2 &&
                 fabs(b_copy->knots[mq] - tmid) > knot_tol2)
              {
                  p2_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                                 IGRbsp_curve)));
                  if (! p2_cur)
                  {
                     *rc = BSNOMEMORY;
                     status = FALSE;
                     goto wrapup;
                  }
                  p2_cur->poles = NULL;
                  p2_cur->weights = NULL;
                  p2_cur->knots = NULL;
                  p2_cur->num_boundaries = 0;
                  p2_cur->bdrys = NULL;

                  q2_cur = (struct IGRbsp_curve *)BSmalloc((unsigned)(sizeof(struct 
                               IGRbsp_curve)));
                  if (! q2_cur)
                  {
                     *rc = BSNOMEMORY;
                     status = FALSE;
                     goto wrapup;
                  }
                  q2_cur->poles = NULL;
                  q2_cur->weights = NULL;
                  q2_cur->knots = NULL;
                  q2_cur->num_boundaries = 0;
                  q2_cur->bdrys = NULL;

                  status = BScvsplit(rc,b_copy,&tmid,p2_cur,q2_cur,&planar);
                  if(! status) goto wrapup;

                  if((int1 || inbox1) && split1)
                  {

                       *num = *num + 2;

                       /** reallocate pointers **/

                       *stack = (struct IGRbsp_curve **)BSrealloc((char *)*stack,
                            (unsigned)(*num * sizeof(struct IGRbsp_curve *)));
                       if (! *stack)
                       {
                           *rc = BSNOMEMORY;
                           status = FALSE;
                           goto wrapup;
                       }

                       array = *stack;

                       /*** allocate the space for curve structures ***/

/*                       for(i=m; i < *num; i++)
                       {
                           array[i] = (struct IGRbsp_curve *)BSmalloc((unsigned)
                                      (sizeof(struct IGRbsp_curve)));
                           if (! array[i])
                           {
                               *rc = BSNOMEMORY;
                               status = FALSE;
                               goto wrapup;
                           }
                       }
*/
                       array[*num - 2] = p2_cur;
                       array[*num - 1] = q2_cur;
                   }
                   else
                   {
                       array[*num] = p2_cur;
                       array[*num + 1] = q2_cur;
                       *num = *num + 2;
                   }
              } 
          }
     }
     wrapup:

     {
     if(BSERROR(*rc))
         BSdbgrc(*rc,"BStst_stack");
     return(status);
     }
}                          
