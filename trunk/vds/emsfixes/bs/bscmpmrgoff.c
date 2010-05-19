/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
   BScmpmrgoff

Abstract
   This routine merges (polynomially, or linearly extends if gap exists) two
   offset curves of consecutive curves of a composite curve. Designed to be
   called by BScmpcvoff1.

Synopsis
    void BScmpmrgoff(off1, off2, d1, d2, cv_index, after_int, ret_pt,  
                     tab_inx, off_table, noff_dist, outcv1, outcv2, outcv3, rc)

    IGRbsp_curve    *off1
    IGRbsp_curve    *off2
    IGRdouble       d1, d2
    IGRint          cv_index
    IGRboolean      *after_int
    IGRpoint        ret_pt
    IGRint          *tab_inx
    IGRint          *off_table 
    IGRdouble       *noff_dist
    IGRbsp_curve    **outcv1
    IGRbsp_curve    **outcv2
    IGRbsp_curve    **outcv3
    BSrc            *rc
    
Description
    
    Input:
      *off1............offset curve to be merged with off2 or joined by 
                       manually constructed line.
      *off2............offset curve to be merged with off1 or joined by 
                       manually constructed line.
      d1...............offset distance for off1.
      d2...............offset distance for off2.
      cv_index.........index of current curve which will be stored in 
                       appropriate element of off_table.
      *after_int.......TRUE if off1 and previous curve intersect; therefore, 
                              trim off1.
                       FALSE otherwise.
      ret_pt...........point at which to trim off1 if after_int = TRUE
      *tab_inx.........current index for off_table (equal number of entries
                       in off_table - 1).
      *off_table.......table of the indeces for the offset curves 
                       corresponding to original curves.
      *noff_dist.......array of offset distances associated with each offset
                       curve

    Output:
      *after_int........TRUE if off1 and previous curve intersect; therefore, 
                              trim off1.
                        FALSE otherwise.
      *tab_inx..........new index for off_table (equal new number of entries
                        in off_table - 1).
      *off_table........table of the indeces for the offset curves 
                        corresponding to original curves.
      *noff_dist.......array of offset distances associated with each offset
                       curve
      **outcv1..........first merged output curve
      **outcv2..........second merged output curve
      **outcv3..........third merged output curve (exists only if line is
                        constructed; otherwise returned = NULL)
      *rc...............return code

Return Values
     BSSUCC, if successful.BSNOSTKMEMORY if no memory is allocated.

Notes
     if line IS NOT constructed:
     {
       Memory for outcv1 and  outcv2 is allocated in this routine.

       outcv1 corresponds to off1, outcv2 corresponds to off2.
     }
  
     if line IS constructed:
     {
        Memory for outcv1, outcv2, and outcv3 is allocated in this routine.

        outcv1 corresponds to off1, outcv2 corresponds to off2, 
        outcv3 corresponds to constructed line, and 
        outcv4 corresponds to off3.
     }

Index
    md

Keywords

History
     S. C. Wood   09/07/89  : Creation date.
     S. C. Wood   10/02/89  : Added array, noff_dist, to argument list.
                              This array contains the offset distances
                              associated with each offset curve and is
                              set to appropriate offset distance each time
                              off_table is set.
     S. C. Wood   10/10/89  : Changed name of static routine from
                              and trim1BScmpcvoff1 to trim1BScmpmrgoff.
     S. C. Wood   07/11/90  : Changed static routine trim1BScmpmrgoff to call
                              BSmdstptcv instead of BSmdistptcv.
     S. C. Wood   12/30/92  : Modified to not construct line segments to
                              join offset curves. Move poles instead.
                              Fix for TR# 913056.
     S.G. Catron  12/05/97  : Check return code after call to
BSexttrmcmp for
                              NOSOLUTION and set gap.
     S.G. Catron  07/07/2000: Problem if parallel lines, d1=d2, and we've had to
                              skip the previous curve.  Check for this case and
                              go into section which calls BSexttrmcmp.  Also took
                              out Alloc/Copy of mrg_off to outcv.  Just assign
                              mrg_off to outcv.
     S.G. Catron  08/18/2000: Took out useless allocation/free/copy.  Took out
                              "gap" boolean which was also useless.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
# include "bsdefs.h"
# include "bserr.h"
# include "bsstackalloc.h"
# include "bsmalloc.h"
# include "bsicmpcvoff.h"
# include "bsparameters.h"
#endif
#include <math.h>
# define BSVOID
# define MAXNUM 100

static void trim1BScmpmrgoff(
struct IGRbsp_curve *cv1,
IGRpoint            ret_pt,
BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bsalloccv.h"
#include "bscvkttol2.h"
#include "bsmdstptcv.h"
#include "bsptcvgen.h"
#include "bsofrparcv.h"
#include "bsfreecv.h"
#include "bsactivsplt.h"
#include "bscv_copy.h"
#endif 

   IGRboolean     planar = TRUE;
   IGRshort       i;
   IGRdouble      knot_tol,dist,par;
   IGRdouble      tsta0,tend0;
   struct IGRbsp_curve *act_cur = NULL;
   IGRpoint       minpt;
   IGRdouble      *z1_temp = NULL, z1_temp2[MAXNUM];
   IGRboolean     alloc_z1_temp = FALSE;
   BSrc           rc1;

   
   rc1 = BSSUCC;  
   BSalloccv(cv1->order, cv1->num_poles, cv1->rational, 0, &act_cur, rc);
   if(BSERROR(*rc)) goto wrapup;

   BScvkttol2(cv1->order, cv1->knots, cv1->num_poles, cv1->poles, 
              cv1->weights, &knot_tol, rc);
   if(BSERROR(*rc)) goto wrapup;

   /* Set z-values of cv1 = 0.0 for 3-D. (08/10/89) */
   if (cv1->num_poles > MAXNUM)
   {
      z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
                    (cv1->num_poles * sizeof(IGRdouble)));
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

   for (i = 0; i < cv1->num_poles; ++i)
   {
       z1_temp[i] = cv1->poles[3 * i + 2];
       cv1->poles[3 * i + 2] = 0.0;
   }

   BSmdstptcv(cv1, ret_pt, &par, minpt, &dist, rc);
   if(BSERROR(*rc)) 
     goto wrapup;

   /* Reset z-values back to original value. (08/10/89) */
   for (i = 0; i < cv1->num_poles; ++i)
   {
       cv1->poles[3 * i + 2] = z1_temp[i];
   }
                
   /*----------------------------------------------------------
       If  cv1 is degenerated after trimming, make it 
       to be point curve
   ------------------------------------------------------------*/

   if(fabs(par - cv1->knots[cv1->num_poles]) < knot_tol)
   {
      BSptcvgen(ret_pt, cv1->order, cv1->rational, act_cur, rc);
      if(BSERROR(*rc)) goto wrapup;
   }
   else
   {
      (void)BSactivsplt(rc,cv1,&par,&cv1->knots[cv1->num_poles],
                           act_cur,&planar);
      if(BSERROR(*rc)) goto wrapup;
   }
   tsta0 = cv1->knots[cv1->order -1];
   tend0 = cv1->knots[cv1->num_poles];

   (void)BScv_copy(rc, act_cur,cv1);
   if(BSERROR(*rc)) goto wrapup;

   /*------------------------
       Reparameterize cv1
   ---------------------------*/

   BSofrparcv(cv1, tsta0,tend0,rc);
   if(BSERROR(*rc)) goto wrapup;

   wrapup:
     if (alloc_z1_temp)
     {
        BSstackdealloc((char *) z1_temp);
        z1_temp = NULL;
     }

     if(act_cur) 
     {
        (void)BSfreecv(&rc1,act_cur);
     }

     if(BSOKAY(*rc) && BSERROR(rc1))
     {
        *rc = rc1;
     }
     return;
}

void BScmpmrgoff(
struct
  IGRbsp_curve *off1,
struct
  IGRbsp_curve *off2,
IGRdouble      d1,
 IGRdouble	 d2,
IGRint         cv_index,
IGRboolean     *after_int,
IGRpoint       ret_pt,
IGRint         *tab_inx,
IGRint         *off_table,
IGRdouble      *noff_dist,
struct
  IGRbsp_curve **outcv1,
struct
  IGRbsp_curve **outcv2,
struct
  IGRbsp_curve **outcv3,
BSrc           *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscv_copy.h"
#include "bsexttrmcmp.h"
#include "bsdistptpts.h"
#include "bsofrparcv.h"
#include "bslngen.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bscveval.h"
#include "bsmkvec.h"
#endif 

   IGRint          j, ii, type;
   struct 
     IGRbsp_curve *tmp_off1 = NULL, *tmp_off2 = NULL;
   struct 
     IGRbsp_curve *new_tmp_off1 = NULL, *new_tmp_off2 = NULL;
   struct 
     IGRbsp_curve *mrg_off1 = NULL, *mrg_off2 = NULL;
   IGRboolean     alloc_new_tmp_off1 = FALSE, alloc_new_tmp_off2 = FALSE;
   IGRboolean     alloc_tmp_off1 = FALSE, alloc_tmp_off2 = FALSE;
   struct 
     IGRbsp_curve *line = NULL;
   IGRpoint       pnt1, pnt2,eval_1[2];
   IGRdouble      dist_sqtol, dist_tol, dot_tol, dot;
   IGRdouble      tsta0, tend0, tsta1, tend1;
   IGRboolean     polyext;
   IGRint         npoles;
   IGRboolean     ln=FALSE;
   IGRint         gap;
   BSrc           rc1 = BSSUCC, rc2 = BSSUCC, rc3 = BSSUCC, rc4 = BSSUCC, 
                  rc5 = BSSUCC, rc6 = BSSUCC, rc7 = BSSUCC, rc8 = BSSUCC;
   IGRshort       lord;
   IGRlong        lnpoles;
   IGRvector      vec;
   
   *rc = BSSUCC;

   /* Copy off1 into tmp_off1 and off2 into tmp_off2 */
   BSalloccv(off1->order, off1->num_poles, off1->rational, 0, &tmp_off1, rc);
   if (BSERROR(*rc))
       goto wrapup;
   alloc_tmp_off1 = TRUE;

   BSalloccv(off2->order, off2->num_poles, off2->rational, 0, &tmp_off2, rc);
   if (BSERROR(*rc))
      goto wrapup;
   alloc_tmp_off2 = TRUE;

   (void)BScv_copy(rc, off1, tmp_off1);
   if (BSERROR(*rc))
      goto wrapup;
   (void)BScv_copy(rc, off2, tmp_off2);
   if (BSERROR(*rc))
      goto wrapup;

   if(*after_int)
   {
     /* trim tmp_off1 */
     trim1BScmpmrgoff(tmp_off1, ret_pt, rc);
     if(BSERROR(*rc)) 
       goto wrapup;
   }
   *after_int = FALSE;

  /*----------------------------------------------------------------------
     Check the end points for tmp_off1 and tmp_off2, if they are not 
     coincident, make a line in between.
    ----------------------------------------------------------------------*/

   if(tmp_off1->rational)
   {
     for(j=0; j < 3; j++)
     {
        pnt1[j] = tmp_off1->poles[3 * (tmp_off1->num_poles - 1) + j] /
                    tmp_off1->weights[tmp_off1->num_poles -1];
     }
   }
   else
   {
     for(j=0; j < 3; j++)
     {
        pnt1[j] = tmp_off1->poles[3 * (tmp_off1->num_poles - 1) + j];
     }
   }

   if(tmp_off2->rational)
   {
     for(j=0; j < 3; j++)
     {
        pnt2[j] = tmp_off2->poles[j] / tmp_off2->weights[0];
     }
   }
   else
   {
     for(j=0; j < 3; j++)
     {
        pnt2[j] = tmp_off2->poles[j];
     }
   }

   /* Allocate memory for mrg_off1 and mrg_off2 */

   BSEXTRACTPAR(rc, BSTOLSQLENVEC, dist_sqtol);
   if (BSdistptpts(rc,pnt1,pnt2) < dist_sqtol)
   {
      gap = 0;
      mrg_off1 = tmp_off1;
      mrg_off2 = tmp_off2;
      alloc_tmp_off1 = FALSE;
      alloc_tmp_off2 = FALSE;      
   }
   else
   {
      /*--------------------------------------------------------
         Call BSexttrmcmp to extend tmp_off1 and tmp_off2 to inter-
         section if d1 != d2.  If d1 = d2 call BSlngen to construct line
         connecting tmp_off1 and tmp_off2.
       ---------------------------------------------------------*/

      BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
      BSEXTRACTPAR(rc, BSTOLORTHOVEC, dot_tol);      

      /* we know the tangents are equal, but we could have skipped over
         our previous curve, and our tangents could be parallel, meaning our
         curves are parallel-- if the vector connecting the endpoints is
         coincident with the tangent, then okay...just move end pole...otherwise
         let's go into BSexttrmcmp */
      (void)BSmkvec(rc,vec, pnt2, pnt1 );
      if(BSERROR(*rc))  goto wrapup;
      BScveval(tmp_off1, tmp_off1->knots[tmp_off1->num_poles-1], 1, eval_1, rc);
      if(BSERROR(*rc)) goto wrapup;   
      dot = BSdotp(rc, eval_1[1], vec);
      if(BSERROR(*rc)) goto wrapup;   
      
      if (ABS(d1 - d2) > dist_tol || fabs(fabs(dot) - 1.0) > dot_tol )
      {

         npoles = tmp_off1->num_poles + 2 + (2 * tmp_off1->order - 2);
         BSalloccv(tmp_off1->order, npoles, tmp_off1->rational, 0, 
                   &new_tmp_off1, rc);
         if (BSERROR(*rc))
            goto wrapup;
         alloc_new_tmp_off1 = TRUE;

         npoles = tmp_off2->num_poles + 2 + (2 * tmp_off2->order - 2);
         BSalloccv(tmp_off2->order, npoles, tmp_off2->rational, 0, 
                   &new_tmp_off2, rc);
         if (BSERROR(*rc))
            goto wrapup;
         alloc_new_tmp_off2 = TRUE;
	
         /* Store parameters for reparameterization of curves returned from
            BSexttrmcmp */
         tsta0 = tmp_off1->knots[tmp_off1->order -1];
         tend0 = tmp_off1->knots[tmp_off1->num_poles];
         tsta1 = tmp_off2->knots[tmp_off2->order -1];
         tend1 = tmp_off2->knots[tmp_off2->num_poles];

         BSexttrmcmp(tmp_off1, tmp_off2, d1, d2, after_int, ret_pt, &line, 
                     &polyext, new_tmp_off1, new_tmp_off2, rc);
         if(BSERROR(*rc))
         {
           if( *rc == BSNOSOLUTION )
           {
             *rc = BSSUCC;
             ln = TRUE;             
           }             
           else
             goto wrapup;
         }

         /*-----------------------------------------------------
           Reparameterize new_tmp_off1 and new_tmp_off2.
         -----------------------------------------------------*/
         BSofrparcv(new_tmp_off1, tsta0, tend0, rc);
         if(BSERROR(*rc))
           goto wrapup;

         BSofrparcv(new_tmp_off2, tsta1,tend1, rc);
         if(BSERROR(*rc))
           goto wrapup;

         mrg_off1 = new_tmp_off1;
         mrg_off2 = new_tmp_off2;	 
         alloc_new_tmp_off1 = FALSE;
         alloc_new_tmp_off2 = FALSE;	 
         if (polyext)
         {
            gap = 1;
         }
         else if(line || ln)
         {
            gap = 2;
         }
         else
         {
            gap = 0;
         }
      }
      else
      {
         /* Move end pole of tmp_off1 to start pole of tmp_off2 */
         if (tmp_off2->rational)
         {
            if (tmp_off1->rational)
            {
               for (ii = 0; ii < 3; ++ii)
                  tmp_off1->poles[(tmp_off1->num_poles - 1) * 3 + ii]=
                          tmp_off2->poles[ii] / tmp_off2->weights[0] *
                          tmp_off1->weights[tmp_off1->num_poles-1];
            }
            else
            {
               for (ii = 0; ii < 3; ++ii)
                  tmp_off1->poles[(tmp_off1->num_poles - 1) * 3 + ii]=
                          tmp_off2->poles[ii] / tmp_off2->weights[0];
            }
         }
         else
         {
            if (tmp_off1->rational)
            {
               for (ii = 0; ii < 3; ++ii)
                   tmp_off1->poles[(tmp_off1->num_poles - 1) * 3 + ii]=
                            tmp_off2->poles[ii] * 
                            tmp_off1->weights[tmp_off1->num_poles-1];
            }
            else
            {
               for (ii = 0; ii < 3; ++ii)
                   tmp_off1->poles[(tmp_off1->num_poles - 1) * 3 + ii]=
                            tmp_off2->poles[ii];
            }
         }

         gap = 0;
         mrg_off1 = tmp_off1;
         mrg_off2 = tmp_off2;
         alloc_tmp_off1 = FALSE;
         alloc_tmp_off2 = FALSE;      
      }
   }

   if (gap == 2 && (ln || line))
   {
      /* Linear extension or line construction to join curves */
      off_table[*tab_inx] = BSCVLINE;
      if (d1 > d2)
         noff_dist[*tab_inx] = d1;
      else
         noff_dist[*tab_inx] = d2;
      off_table[*tab_inx + 1] = cv_index;
      noff_dist[*tab_inx + 1] = d2;
      *outcv1 = mrg_off1;
      lord = 2;
      lnpoles = 2;
      BSalloccv(lord, lnpoles, FALSE, 0, outcv2, rc);
      if (BSERROR(*rc))
         goto wrapup;
      if( line )
         (void)BScv_copy(rc, line, *outcv2 );
      else
         (void)BSlngen(rc, pnt1, pnt2, *outcv2, &type);
      if(BSERROR(*rc))  goto wrapup;
      *outcv3 = mrg_off2;
      *tab_inx = *tab_inx + 2;
   }
   else
   {
      /* gap=0,1 or 2 and !ln or !line */
      off_table[*tab_inx] = cv_index;
      noff_dist[*tab_inx] = d2;
      *outcv1 = mrg_off1;
      *outcv2 = mrg_off2;
      *tab_inx = *tab_inx + 1;
   }

   wrapup:
   if (alloc_new_tmp_off2)
   {
      (void)BSfreecv(&rc2, new_tmp_off2);
      new_tmp_off2 = NULL;
   }
   if (alloc_new_tmp_off1)
   {
      (void)BSfreecv(&rc3, new_tmp_off1);
      new_tmp_off1 = NULL;
   }
   if (alloc_tmp_off2)
   {
      (void)BSfreecv(&rc4, tmp_off2);
      tmp_off2 = NULL;
   }
   if (alloc_tmp_off1)
   {
      (void)BSfreecv(&rc5, tmp_off1);
      tmp_off1 = NULL;
   }

   if (line)
   {
      (void)BSfreecv(&rc7, line);
      line = NULL;
   }

   if(BSERROR(rc1) || BSERROR(rc2) || BSERROR(rc3) || BSERROR(rc4) ||
        BSERROR(rc5) || BSERROR(rc6) || BSERROR(rc7) || BSERROR(rc8))
      *rc = BSFAIL;

   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BScmpmrgoff");
   return;
   }
} 
