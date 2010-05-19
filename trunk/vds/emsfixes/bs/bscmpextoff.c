/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
   BScmpextoff

Abstract
   This routine extends two offset curves of consecutive curves of a composite
   curve to point of intersection or creates a fillet between the 2 offset
   curves.  Designed to be called by BScmpcvoff1.

Synopsis
    void BScmpextoff(incv1, incv2, offcv1, offcv2, fillet, d1, d2, nor_vec, 
                     sign, cv_index, after_int, ret_pt, tab_inx, off_table, 
                     noff_dist, outcv1, outcv2, outcv3, rc)

    IGRbsp_curve    *incv1
    IGRbsp_curve    *incv2
    IGRbsp_curve    *offcv1
    IGRbsp_curve    *offcv2
    IGRboolean      fillet
    IGRdouble       d1, d2
    IGRvector       nor_vec
    IGRint          sign
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
      *incv1...........curve of input composite curve associated with offset
                       curve, offcv1.
      *incv2...........curve of input composite curve associated with offset
                       curve, offcv2.
      *offcv1..........offset curve associated with curve of input composite
                       curve (incv1).
      *offcv2..........offset curve associated with curve of input composite
                       curve (incv2).
      fillet...........1 = fillet option,
                       0 = extend option.
                       2 = if d1 or d2 == 0 then just connect end points
                           else extend to intersection linearly(not polynomially)
      d1...............offset distance for offcv1.
      d2...............offset distance for offcv2.
      nor_vec..........normal vector
      sign.............(-1) = tangent vector x nor_vec != side to offset to.
                       (+1) = tangent vector x nor_vec = side to offset to.
      cv_index.........index of current curve which will be stored in 
                       appropriate element of off_table.
      *after_int........TRUE = previous curves were intersecting.
      ret_pt...........point of intersection of previous curves if 
                       after_int = TRUE.
      *tab_inx.........counter for number of entries in off_table    
      *off_table.......table of indeces for each offset curve indicating
                       which curve of the input composite curve it
                       corresponds to.
      *noff_dist.......array of offset distances associated with each offset
                       curve
    Output:
      *tab_inx.........counter for number of entries in off_table.
      *off_table.......table of indeces for each offset curve indicating
                       which curve of the input composite curve it
                       corresponds to.
      *noff_dist.......array of offset distances associated with each offset
                       curve
      **outcv1.........new offset curve corresponding to offcv1.
      **outcv2.........the constructed fillet arc, if fillet = TRUE;
                       extended off2, otherwise.                       
      **outcv3.........extended off2, if fillet = FALSE;
                       NULL, otherwise.
      *rc...............return code

Return Values
     BSSUCC, if successful.BSNOSTKMEMORY if no memory is allocated.

Notes
     If line or arc IS constructed:
     {
        Memory for outcv1, outcv2, and outcv3 is allocated in this routine.

        outcv1 corresponds to off1, outcv2 corresponds to constructed curve, 
        and outcv3 corresponds to off2.
     }

     If neither line nor arc is constructed:
     {
        Memory for outcv1 and outcv2 is allocated in this routine.
 
        outcv1 corresponds to off1,  outcv2 corresponds to off2.
     }
 
Index
    md

Keywords

History
     S. C. Wood   09/14/89  : Creation date.
     S. C. Wood   10/02/89  : Added array, noff_dist, to argument list.
                              This array contains the offset distances 
                              associated with each offset curve and is
                              set to appropriate offset distance each time
                              off_table is set.
     S. C. Wood   10/10/89  : Changed name of static routine from
                              and trim1BScmpcvoff1 to trim1BScmpextoff.
     S. C. Wood   07/11/90  : Changed static routine trim1BScmpextoff to call
                              BSmdstptcv instead of BSmdistptcv.
     S. C. Wood   05/04/92  : Modified to call BSpolyxcvcv to perform a 
                              polynomial extension of the offset curves
                              if fillet = FALSE.
     S. C. Wood   08/14/92  : When trimming polynomial extension of tmp_off2
                              (returned from BSpolyxcvcv), trim parameter
                              (tmp_off2_stpar) was mistakenly being set
                              based on tmp_off1->order instead of tmp_off2->
                              order.  Corrected this mistake.
     S. C. Wood   08/31/92  : When reinstating z values of extended section
                              of extcv1 and extcv2, if the extended section
                              is rational, multiply the z value by the
                              appropriate weight.
     S. C. Wood   08/31/92  : Store unweighted z values of tmp_off1 and
                              tmp_off2 to use when reinstating z values
                              to extension curves (lcv,rcv). Multiply
                              these unweighted z values by appropriate
                              weight for lcv and rcv (if they are rational).
     S. C. Wood   10/01/92  : When setting memory for extcv2 (extension of
                              tmp_off1), tmp_off1->num_poles and tmp_off1->
                              order were mistakenly being used instead
                              of tmp_off2->num_poles and tmp_off2->order.
                              Fix for TR# 119220480.
     S. C. Wood   04/26/94  : Modified to deallocate z2_unwt and z1_unwt.
                              Mistakenly attempting to deallocate z2_temp
                              and z1_temp for a second time instead.
                              Fixed abort in WS# 4413618.
     S. C. Wood   06/20/95  : When setting z poles of extcv1 and extcv2
                              poles to z poles of tmp_off1 and tmp_off2,
                              respectively, if extcv1 (extcv2) is rational,
                              unweight tmp_off1 (tmp_off2) poles and then
                              "weight" the poles by extcv1.weights 
                              (extcv2.weights). Fix for TR# 9525006.
     S.G. Catron  08/21/99  : There was a tolerance problem after calling BSpolyxcvcv.
                              The if which checked whether to split or not.
     S.G. Catron  08/18/00  : Modified "fillet" argument to add another option.
                              2: if d1 or d2 == 0 then just connect end points
                              else extend to intersection linearly(not polynomially).
                              For fillet=2, added call to new function BSlinconcvs.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
# include "bsdefs.h"
# include "bserr.h"
# include "bsparameters.h"
# include "bsstackalloc.h"
# include "bsmalloc.h"
# include "bsicmpcvoff.h"
#endif

# define  BSVOID
# include <math.h>

# define MAXNUM 100

static void trim1BScmpextoff(
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
   IGRboolean     status = TRUE;
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
      status = BSactivsplt(rc,cv1,&par,&cv1->knots[cv1->num_poles],
                           act_cur,&planar);
      if(! status) goto wrapup;
   }
   tsta0 = cv1->knots[cv1->order -1];
   tend0 = cv1->knots[cv1->num_poles];

   status = BScv_copy(rc, act_cur,cv1);
   if(! status) goto wrapup;

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
        status = BSfreecv(&rc1,act_cur);
     }

     if(BSOKAY(*rc) && BSERROR(rc1))
     {
        *rc = rc1;
     }
     return;
}

void BScmpextoff(
struct
  IGRbsp_curve    *incv1,
struct
  IGRbsp_curve    *incv2,
struct
  IGRbsp_curve    *offcv1,
struct
  IGRbsp_curve    *offcv2,
IGRboolean      fillet,
IGRdouble       d1,
 IGRdouble	 d2,
IGRvector       nor_vec,
IGRint          sign,
IGRint          cv_index,
IGRboolean      *after_int,
IGRpoint        ret_pt,
IGRint          *tab_inx,
IGRint          *off_table,
IGRdouble       *noff_dist,
struct
  IGRbsp_curve    **outcv1,
struct
  IGRbsp_curve    **outcv2,
struct
  IGRbsp_curve    **outcv3,
BSrc           *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscv_copy.h"
#include "bscvsplit.h"
#include "bsofk3arc.h"
#include "bsalloccv.h"
#include "bspolyxcvcv.h"
#include "bscomb2cvs.h"
#include "bsnorkts.h"
#include "bscvkttol2.h"
#include "bsfreecv.h"
#include "bslinconcvs.h"
#endif 

   IGRint         j;
   struct 
     IGRbsp_curve *tmp_off1 = NULL, *tmp_off2 = NULL;
   struct 
     IGRbsp_curve *tmp_arc = NULL, extcv1, extcv2, lcv, rcv;
   IGRpoint       extcv1_poles[MAXNUM], extcv2_poles[MAXNUM];
   IGRdouble      extcv1_weights[MAXNUM], extcv2_weights[MAXNUM];
   IGRdouble      extcv1_knots[MAXNUM], extcv2_knots[MAXNUM];
   IGRdouble      *z1_temp = NULL, z1_temp2[MAXNUM];
   IGRdouble      *z1_unwt = NULL, z1_unwt2[MAXNUM];
   IGRdouble      *z2_temp = NULL, z2_temp2[MAXNUM], tst_z, zero_tol=1e-10;
   IGRdouble      *z2_unwt = NULL, z2_unwt2[MAXNUM];
   IGRdouble      tmp_off1_endpar, extcv1_endpar, tmp_off2_stpar, extcv2_stpar;
   IGRboolean     alloc_z1_temp = FALSE, alloc_z2_temp = FALSE,
                  alloc_z1_unwt = FALSE, alloc_z2_unwt = FALSE;
   IGRboolean     alloc_tmp_off1 = FALSE, alloc_tmp_off2 = FALSE;
   IGRboolean     keep_going = FALSE, rational;
   IGRboolean     out1_3d = FALSE, out2_3d = FALSE, plan = FALSE;
   IGRboolean     alloc_extcv1_poles=FALSE, alloc_extcv1_weights=FALSE, 
                  alloc_extcv1_knots=FALSE;
   IGRboolean     alloc_extcv2_poles=FALSE, alloc_extcv2_weights=FALSE, 
                  alloc_extcv2_knots=FALSE;
   IGRint         arc_type, side[2];
   IGRlong        npoles, npoles1, npoles2;
   IGRboolean     status;
   IGRint         connect;
   BSrc           rc1 = BSSUCC, rc2 = BSSUCC, rc3 = BSSUCC;
   IGRdouble      knot_tol;
   
   status = TRUE;
   *rc = BSSUCC;

   /* Initialize pointers in lcv, rcv, extcv1, and extcv2 curve structures = 
      NULL. */
   lcv.poles = NULL;
   lcv.weights = NULL;
   lcv.knots = NULL;
   lcv.bdrys = NULL;

   rcv.poles = NULL;
   rcv.weights = NULL;
   rcv.knots = NULL;
   rcv.bdrys = NULL;

   extcv1.poles = NULL;
   extcv1.weights = NULL;
   extcv1.knots = NULL;
   extcv1.bdrys = NULL;

   extcv2.poles = NULL;
   extcv2.weights = NULL;
   extcv2.knots = NULL;
   extcv2.bdrys = NULL;

      
   /* Copy offcv1 into tmp_off1 and offcv2 into tmp_off2 */
   BSalloccv(offcv1->order, offcv1->num_poles, offcv1->rational, 0,
             &tmp_off1, rc);
   if (BSERROR(*rc))
       goto wrapup;
   alloc_tmp_off1 = TRUE;

   BSalloccv(offcv2->order, offcv2->num_poles, offcv2->rational, 0, 
             &tmp_off2, rc);
   if (BSERROR(*rc))
      goto wrapup;
   alloc_tmp_off2 = TRUE;

   status = BScv_copy(rc, offcv1, tmp_off1);
   if (BSERROR(*rc))
      goto wrapup;
   status = BScv_copy(rc, offcv2, tmp_off2);
   if (BSERROR(*rc))
      goto wrapup;

   if(*after_int)
   {
     /* trim tmp_off1 */
     trim1BScmpextoff(tmp_off1, ret_pt, rc);
     if(BSERROR(*rc)) 
       goto wrapup;
   }
   *after_int = FALSE;
   connect = -1;
   if( fillet == 2 )
   {
      if( d1 == 0.0 || d2 == 0.0  )
         connect = d1 == 0.0 ? 2 : 3;
      else
         connect = 0;  
   }
     
   if (fillet == 0  )
   {
      /* Attempt polynomial extension:
          1) Project tmp_off1 and tmp_off2 onto xy plane.
          2) Call BSpolyxcvcv to extend the projection curves (extcv1, extcv2)
          3) Split ext1 and ext2 at point correlating to end of prj1 and
             prj2, respectively, keeping extended section (splt1, splt2).
          4) Reinstate z values of poles of ext1 and ext2 correlating to
             tmp_off1 and tmp_off2.
          5) Set the z values of splt1 = z values of last pole of tmp_off1
             and z values of splt2 = z values of 1st pole of tmp_off2.
          6) Merge ext1 with splt1 and ext2 with splt2.
      */

      if (tmp_off1->num_poles > MAXNUM)
      {
         z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
                       (tmp_off1->num_poles * sizeof(IGRdouble)));
         if (! z1_temp)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_z1_temp = TRUE;

         z1_unwt = (IGRdouble *)BSstackalloc((unsigned) 
                       (tmp_off1->num_poles * sizeof(IGRdouble)));
         if (! z1_unwt)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_z1_unwt = TRUE;
      }
      else
      {
         z1_temp = z1_temp2;
         z1_unwt = z1_unwt2;
      }

      for (j = 0; j < tmp_off1->num_poles; ++j)
      {
          z1_temp[j] = tmp_off1->poles[3 * j + 2];
          tmp_off1->poles[3 * j + 2] = 0.0;
      }

      if (tmp_off1->rational)
      {
         for (j = 0; j < tmp_off1->num_poles; ++j)
             z1_unwt[j] = z1_temp[j] / tmp_off1->weights[j];
      }
      else
      {
         for (j = 0; j < tmp_off1->num_poles; ++j)
             z1_unwt[j] = z1_temp[j];
      }

      if (tmp_off2->num_poles > MAXNUM)
      {
         z2_temp = (IGRdouble *)BSstackalloc((unsigned) 
                       (tmp_off2->num_poles * sizeof(IGRdouble)));
         if (! z2_temp)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_z2_temp = TRUE;

         z2_unwt = (IGRdouble *)BSstackalloc((unsigned) 
                       (tmp_off2->num_poles * sizeof(IGRdouble)));
         if (! z2_unwt)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_z2_unwt = TRUE;
      }
      else
      {
         z2_temp = z2_temp2;
         z2_unwt = z2_unwt2;
      }

      for (j = 0; j < tmp_off2->num_poles; ++j)
      {
          z2_temp[j] = tmp_off2->poles[3 * j + 2];
          tmp_off2->poles[3 * j + 2] = 0.0;
      }

      if (tmp_off2->rational)
      {
         for (j = 0; j < tmp_off2->num_poles; ++j)
             z2_unwt[j] = z2_temp[j] / tmp_off2->weights[j];
      }
      else
      {
         for (j = 0; j < tmp_off2->num_poles; ++j)
             z2_unwt[j] = z2_temp[j];
      }

      npoles1 = tmp_off1->num_poles + 2 * tmp_off1->order - 2;
      if(npoles1 > MAXNUM )
      {
         extcv1.poles = (IGRdouble *)BSstackalloc((unsigned)(npoles1 *
                             sizeof(IGRpoint)));
         if(! extcv1.poles )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_extcv1_poles = TRUE;

         if(tmp_off1->rational)
         {
            extcv1.weights = (IGRdouble *)BSstackalloc((unsigned)(npoles1 *
                                  sizeof(IGRdouble)));
            if(! extcv1.weights )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            alloc_extcv1_weights = TRUE;
         }
      }
      else
      {
         extcv1.poles = &extcv1_poles[0][0];
         if( tmp_off1->rational)
            extcv1.weights = extcv1_weights;
      }
      extcv1.bdrys = NULL;
      if( npoles1 + tmp_off1->order > MAXNUM )
      {
         extcv1.knots = (IGRdouble *)BSstackalloc((unsigned)( (npoles1 +
                             tmp_off1->order) * sizeof(IGRdouble)));
         if(! extcv1.knots )
         { 
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_extcv1_knots = TRUE;
      }
      else
      {
         extcv1.knots = extcv1_knots;
      }


      npoles2 = tmp_off2->num_poles + 2 * tmp_off2->order - 2;
      if(npoles2 > MAXNUM )
      {
         extcv2.poles = (IGRdouble *)BSstackalloc((unsigned)(npoles2 *
                             sizeof(IGRpoint)));
         if(! extcv2.poles )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_extcv2_poles = TRUE;

         if(tmp_off2->rational)
         {
            extcv2.weights = (IGRdouble *)BSstackalloc((unsigned)(npoles2 *
                                  sizeof(IGRdouble)));
            if(! extcv2.weights )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            alloc_extcv2_weights = TRUE;
         }
      }
      else
      {
         extcv2.poles = &extcv2_poles[0][0];
         if( tmp_off2->rational)
            extcv2.weights = extcv2_weights;
      }
      extcv2.bdrys = NULL;
      if( npoles2 + tmp_off2->order > MAXNUM )
      {
         extcv2.knots = (IGRdouble *)BSstackalloc((unsigned)( (npoles2 +
                             tmp_off1->order) * sizeof(IGRdouble)));
         if(! extcv2.knots )
         { 
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_extcv2_knots = TRUE;
      }
      else
      {
         extcv2.knots = extcv2_knots;
      }

      side[0] = 1;
      side[1] = 0;
      BSpolyxcvcv(tmp_off1, tmp_off2, side, &extcv1, &extcv2, rc);
      if (BSERROR(*rc) && *rc != BSNOSOLUTION)
         goto wrapup;

      /* Reinstate z values for tmp_off1 and tmp_off2 */
      for (j = 0; j < tmp_off1->num_poles; ++j)
           tmp_off1->poles[3 * j + 2] = z1_temp[j];

      for (j = 0; j < tmp_off2->num_poles; ++j)
           tmp_off2->poles[3 * j + 2] = z2_temp[j];

      if (*rc != BSNOSOLUTION)
      {
         /* Check if extcv1 is extension of tmp_off1 or trimmed tmp_off1. 
            If extension:
               Split extcv1 at tmp_off1->knots[tmp_off1->num_poles].
               Set z values of "left" side (corresponds to tmp_off1) = z 
               values of tmp_off1.
               Set z vales of "right" side (corresponds to extension) =
               z value of last pole of tmp_off1.
               Merge these curves together.

            If trimmed:
               Split tmp_off1 at extcv1->knots[extcv1->num_poles].
               Set z values of extcv1 = z values of "left" side of split 
               tmp_off1.
      
            Similar for tmp_off2.
         */

         BScvkttol2(incv1->order, incv1->knots, incv1->num_poles, incv1->poles, 
              incv1->weights, &knot_tol, rc);
         if(BSERROR(*rc)) goto wrapup;

         tmp_off1_endpar = tmp_off1->knots[tmp_off1->num_poles];
         if (tmp_off1_endpar < extcv1.knots[extcv1.num_poles] - knot_tol)
         {
            /* extcv1 is extension of tmp_off1 */

            (void)BScvsplit(rc, &extcv1, &tmp_off1_endpar, &lcv, &rcv, &plan);
            if (BSERROR(*rc))
               goto wrapup;

            if (lcv.num_poles > 0)
            {
               if (lcv.rational) 
               {
                  for (j = 0; j < tmp_off1->num_poles; ++j)
                      lcv.poles[3 * j + 2] = z1_unwt[j] * lcv.weights[j];
               }
               else
               {
                  for (j = 0; j < tmp_off1->num_poles; ++j)
                      lcv.poles[3 * j + 2] = z1_unwt[j];
               }
            }
 
            /* Note: rcv will always exist because we have already checked
                     tmp_off1_endpar against end par of extcv1. */
            if (rcv.rational)
            {
               for (j = 0; j < rcv.num_poles; ++j)
                   rcv.poles[3 * j + 2] = z1_unwt[tmp_off1->num_poles-1] *
                                             rcv.weights[j];
            }
            else
            {
               for (j = 0; j < rcv.num_poles; ++j)
                   rcv.poles[3 * j + 2] = z1_unwt[tmp_off1->num_poles-1];
            }

            /* Call BScomb2cvs to merge lcv and rcv */

            if (lcv.num_poles > 0)
            {
               if (lcv.rational || rcv.rational)
                  rational = TRUE;
              else
                  rational = FALSE;
            }
            else
               rational = rcv.rational;

            if (lcv.num_poles > 0)
            {
               npoles = lcv.num_poles + rcv.num_poles - 1;	
               BSalloccv(rcv.order, npoles, rational, 0, outcv1, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               BScomb2cvs(&lcv, &rcv, *outcv1, rc);
               if (BSERROR(*rc))
                  goto wrapup;
            }
            else
            {
               /* Copy rcv into outcv1 */
               npoles = rcv.num_poles;
               BSalloccv(rcv.order, npoles, rational, 0, outcv1, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               status = BScv_copy(rc, &rcv, *outcv1);
               if(! status) 
                  goto wrapup;
            }

            if (lcv.poles)
            {
               BSdealloc((char *) lcv.poles);
               lcv.poles = NULL;
            }

            if (lcv.weights)
            {
               BSdealloc((char *) lcv.weights);
               lcv.weights = NULL;
            }

            if (lcv.knots)
            {
               BSdealloc((char *) lcv.knots);
               lcv.knots = NULL;
            }

            if (rcv.poles)
            {
               BSdealloc((char *) rcv.poles);
               rcv.poles = NULL;
            }

            if (rcv.weights)
            {
               BSdealloc((char *) rcv.weights);
               rcv.weights = NULL;
            }

            if (rcv.knots)
            {
               BSdealloc((char *) rcv.knots);
               rcv.knots = NULL;
            }
         }
         else
         {
            /* extcv1 is trimmed version of tmp_off1 */

            extcv1_endpar = extcv1.knots[extcv1.num_poles];
            (void)BScvsplit(rc, tmp_off1, &extcv1_endpar, &lcv, &rcv, &plan);
            if (BSERROR(*rc))
               goto wrapup;

            /* SCW-fix TR#9525006 */
	    if (extcv1.rational)
            {
               for (j = 0; j < extcv1.num_poles; ++j)
                   extcv1.poles[3 * j + 2] = (lcv.poles[3 * j + 2] /
                                              lcv.weights[j]) * 
                                              extcv1.weights[j];
            }
            else
            {
               for (j = 0; j < extcv1.num_poles; ++j)
                   extcv1.poles[3 * j + 2] = lcv.poles[3 * j + 2];
            }

            /* Copy extcv1 into outcv1 */
            BSalloccv(extcv1.order, extcv1.num_poles, extcv1.rational, 0, 
                      outcv1, rc);
            if (BSERROR(*rc))
               goto wrapup;

            status = BScv_copy(rc, &extcv1, *outcv1);
            if(! status) 
               goto wrapup;

            if (lcv.poles)
            {
               BSdealloc((char *) lcv.poles);
               lcv.poles = NULL;
            }

            if (lcv.weights)
            {
               BSdealloc((char *) lcv.weights);
               lcv.weights = NULL;
            }

            if (lcv.knots)
            {
               BSdealloc((char *) lcv.knots);
               lcv.knots = NULL;
            }

            if (rcv.poles)
            {
               BSdealloc((char *) rcv.poles);
               rcv.poles = NULL;
            }

            if (rcv.weights)
            {
               BSdealloc((char *) rcv.weights);
               rcv.weights = NULL;
            }

            if (rcv.knots)
            {
               BSdealloc((char *) rcv.knots);
               rcv.knots = NULL;
            }

         }

         BScvkttol2(incv2->order, incv2->knots, incv2->num_poles, incv2->poles, 
              incv2->weights, &knot_tol, rc);
         if(BSERROR(*rc)) goto wrapup;

         tmp_off2_stpar = tmp_off2->knots[tmp_off2->order - 1];
         if (tmp_off2_stpar > extcv2.knots[extcv2.order - 1] + knot_tol)
         {
            /* extcv2 is extension of tmp_off2 */

            (void)BScvsplit(rc, &extcv2, &tmp_off2_stpar, &lcv, &rcv, &plan);
            if (BSERROR(*rc))
               goto wrapup;

            if (rcv.num_poles > 0)
            {
               if (rcv.rational)
               {
                  for (j = 0; j < tmp_off2->num_poles; ++j)
                      rcv.poles[3 * j + 2] = z2_unwt[j] * rcv.weights[j];
               }
               else
               {
                  for (j = 0; j < tmp_off2->num_poles; ++j)
                      rcv.poles[3 * j + 2] = z2_unwt[j];
               }
            }

            /* Note: lcv will always exist because we have already checked
                     tmp_off2_stpar against extcv2 start par. */

            if (lcv.rational)
            {
               for (j = 0; j < lcv.num_poles; ++j)
                   lcv.poles[3 * j + 2] = z2_unwt[0] * lcv.weights[j];
            }
            else
            {
               for (j = 0; j < lcv.num_poles; ++j)
                   lcv.poles[3 * j + 2] = z2_unwt[0];
            }

            /* Call BScomb2cvs to merge lcv and rcv */

            if (rcv.num_poles > 0)
            {
               if (lcv.rational || rcv.rational)
                  rational = TRUE;
               else
                  rational = FALSE;
            }
            else
               rational = lcv.rational;


            if (rcv.num_poles > 0)
            {
               npoles = lcv.num_poles + rcv.num_poles - 1;	
               BSalloccv(lcv.order, npoles, rational, 0, outcv2, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               BScomb2cvs(&lcv, &rcv, *outcv2, rc);
               if (BSERROR(*rc))
                  goto wrapup;
            }
            else
            {
               /* Copy lcv into outcv2 */
               npoles = lcv.num_poles;
               BSalloccv(lcv.order, npoles, rational, 0, outcv2, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               status = BScv_copy(rc, &lcv, *outcv2);
               if(! status) 
                  goto wrapup;
            }

            if (lcv.poles)
            {
               BSdealloc((char *) lcv.poles);
               lcv.poles = NULL;
            }

            if (lcv.weights)
            {
               BSdealloc((char *) lcv.weights);
               lcv.weights = NULL;
            }

            if (lcv.knots)
            {
               BSdealloc((char *) lcv.knots);
               lcv.knots = NULL;
            }

            if (rcv.poles)
            {
               BSdealloc((char *) rcv.poles);
               rcv.poles = NULL;
            }

            if (rcv.weights)
            {
               BSdealloc((char *) rcv.weights);
               rcv.weights = NULL;
            }

            if (rcv.knots)
            {
               BSdealloc((char *) rcv.knots);
               rcv.knots = NULL;
            }

         }
         else
         {
            /* extcv2 is trimmed version of tmp_off2 */

            extcv2_stpar = extcv2.knots[extcv2.order - 1];
            (void)BScvsplit(rc, tmp_off2, &extcv2_stpar, &lcv, &rcv, &plan);
            if (BSERROR(*rc))
               goto wrapup;

            /* SCW-fix TR#9525006 */
	    if (extcv2.rational)
            {
               for (j = 0; j < extcv2.num_poles; ++j)
                   extcv2.poles[3 * j + 2] = (rcv.poles[3 * j + 2] /
                                              rcv.weights[j]) * 
                                              extcv2.weights[j];
            }
            else
            {            
               for (j = 0; j < extcv2.num_poles; ++j)
                   extcv2.poles[3 * j + 2] = rcv.poles[3 * j + 2];
            }

            /* Copy extcv2 into outcv2 */
            BSalloccv(extcv2.order, extcv2.num_poles, extcv2.rational, 0, 
                      outcv2, rc);
            if (BSERROR(*rc))
               goto wrapup;

            status = BScv_copy(rc, &extcv2, *outcv2);
            if(! status) 
               goto wrapup;

            if (lcv.poles)
            {
               BSdealloc((char *) lcv.poles);
               lcv.poles = NULL;
            }

            if (lcv.weights)
            {
               BSdealloc((char *) lcv.weights);
               lcv.weights = NULL;
            }

            if (lcv.knots)
            {
               BSdealloc((char *) lcv.knots);
               lcv.knots = NULL;
            }

            if (rcv.poles)
            {
               BSdealloc((char *) rcv.poles);
               rcv.poles = NULL;
            }

            if (rcv.weights)
            {
               BSdealloc((char *) rcv.weights);
               rcv.weights = NULL;
            }

            if (rcv.knots)
            {
               BSdealloc((char *) rcv.knots);
               rcv.knots = NULL;
            }

         }

         /* Normalize knot vectors for outcv1 and outcv2 */
         if (*outcv1)
         {
            (void)BSnorkts(rc, &(*outcv1)->order, &(*outcv1)->num_poles, 
                           (*outcv1)->knots);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (*outcv2)
         {
            (void)BSnorkts(rc, &(*outcv2)->order, &(*outcv2)->num_poles, 
                           (*outcv2)->knots);
            if (BSERROR(*rc))
                goto wrapup;
         }


/*???*/
         /* If tmp_off1 and/or tmp_off2 are curves of order 2, 2 poles,
            and not 3D and BSpolyxcvcv returns extensions of these curves 
            which are order 2, 3 poles, manually force the extensions (outcv1,
            outcv2) to only have 2 poles. (08/29/89) */

         /* Check if outcv1 and outcv2 are 2D or 3D curves. */
         if ((*outcv1))
         {
            if ((*outcv1)->rational)
            {
               tst_z = (*outcv1)->poles[2] / (*outcv1)->weights[0];
               j = 1;
               out1_3d = FALSE;
               while (j < (*outcv1)->num_poles && !out1_3d)
               {
                  if (ABS((*outcv1)->poles[3*j+2]/(*outcv1)->weights[j]-tst_z)
                       > zero_tol)
                     out1_3d = TRUE;
                  ++j;
               }
            }
            else
            {
               tst_z = (*outcv1)->poles[2];
               j = 1;
               out1_3d = FALSE;
               while (j < (*outcv1)->num_poles && !out1_3d)
               {
                   if (ABS((*outcv1)->poles[3*j+2] - tst_z) > zero_tol)
                      out1_3d = TRUE;
                   ++j;
               }
            }

            if (tmp_off1->order == 2 && tmp_off1->num_poles == 2 && !out1_3d)
            {
               if ((*outcv1)->order == 2 && (*outcv1)->num_poles == 3)
               {
                  (*outcv1)->non_uniform = 0;
                  (*outcv1)->num_poles = 2;
                  (*outcv1)->poles[3] = (*outcv1)->poles[6];
                  (*outcv1)->poles[4] = (*outcv1)->poles[7];
                  (*outcv1)->poles[5] = (*outcv1)->poles[8];
                  (*outcv1)->num_knots = 4;
                  (*outcv1)->knots[2] = (*outcv1)->knots[3];
                  (*outcv1)->knots[3] = (*outcv1)->knots[4];
               }
            }
         }   /* end if ((*outcv1)) */

         if ((*outcv2))
         {
            if ((*outcv2)->rational)
            {
               tst_z = (*outcv2)->poles[2] / (*outcv2)->weights[0];
               j = 1;
               out2_3d = FALSE;
               while (j < (*outcv2)->num_poles && !out2_3d)
               {
                  if (ABS((*outcv2)->poles[3*j+2]/(*outcv2)->weights[j]-tst_z)
                       > zero_tol)
                  out2_3d = TRUE;
                  ++j;
               }
            }
            else
            {
               tst_z = (*outcv2)->poles[2];
               j = 1;
               out2_3d = FALSE;
               while (j < (*outcv2)->num_poles && !out2_3d)
               {
                   if (ABS((*outcv2)->poles[3*j+2] - tst_z) > zero_tol)
                      out2_3d = TRUE;
                   ++j;
               }
            }
  
            if (tmp_off2->order == 2 && tmp_off2->num_poles == 2 && !out2_3d)
            {
               if ((*outcv2)->order == 2 && (*outcv2)->num_poles == 3)
               {
                  (*outcv2)->non_uniform = 0;	
                  (*outcv2)->num_poles = 2;
                  (*outcv2)->poles[3] = (*outcv2)->poles[6];
                  (*outcv2)->poles[4] = (*outcv2)->poles[7];
                  (*outcv2)->poles[5] = (*outcv2)->poles[8];
                  (*outcv2)->num_knots = 4;
                  (*outcv2)->knots[2] = (*outcv2)->knots[3];
                  (*outcv2)->knots[3] = (*outcv2)->knots[4];
               }
            }
         }   /* end if ((*outcv2)) */
	
         off_table[*tab_inx] = cv_index;
         noff_dist[*tab_inx] = d2;
         ++*tab_inx;

         goto wrapup;
      }
      else
      {
         /* Polynomial extension failed, continue processing */
         keep_going = TRUE;
      }
   }
   else
   {
      if( connect != -1 )
      {
         BSlinconcvs(tmp_off1, tmp_off2,  connect, outcv1, outcv2, outcv3, rc );
         if(BSERROR(*rc))
            goto wrapup;
           
         if( !*outcv3 )
         {
            off_table[*tab_inx] = cv_index;
            noff_dist[*tab_inx] = d2;
            ++*tab_inx;
         }
         else
         {
            /* create the line between startpoint and endpoint */
            off_table[*tab_inx] = BSCVLINE;
            if (d1 > d2)
               noff_dist[*tab_inx] = d1;
            else
               noff_dist[*tab_inx] = d2;
            off_table[*tab_inx + 1] = cv_index;
            noff_dist[*tab_inx + 1] = d2;
            *tab_inx =  *tab_inx + 2;
         }
      }
      else
         keep_going = TRUE;
   }


   if (keep_going)
   {
	
      /* Call BSofk3arc to construct fillet arc between or extend tmp_off1
         and tmp_off2 */
      tmp_arc = NULL;
      BSofk3arc(incv1, incv2, tmp_off1, tmp_off2, fillet, d1, d2, nor_vec, 
                sign, &arc_type, &tmp_arc, rc);
      if(BSERROR(*rc)) 
        goto wrapup;

      if(tmp_arc)
      {
         off_table[*tab_inx] = arc_type;
         if (d1 > d2)
         {
            noff_dist[*tab_inx] = d1;
         }
         else
         {
            noff_dist[*tab_inx] = d2;
         }
         off_table[*tab_inx + 1] = cv_index;
         noff_dist[*tab_inx + 1] = d2;
         BSalloccv(tmp_off1->order, tmp_off1->num_poles, tmp_off1->rational, 0,
                   outcv1, rc);
         if (BSERROR(*rc))
            goto wrapup;
         status = BScv_copy(rc, tmp_off1, *outcv1);
         if(! status) 
            goto wrapup;

         BSalloccv(tmp_arc->order, tmp_arc->num_poles, tmp_arc->rational, 0, 
                   outcv2, rc);
         if (BSERROR(*rc))
            goto wrapup;
         status = BScv_copy(rc,tmp_arc, *outcv2);
         if(! status) 
            goto wrapup;
  
         BSalloccv(tmp_off2->order, tmp_off2->num_poles, tmp_off2->rational, 0,
                   outcv3, rc);
         if (BSERROR(*rc))
            goto wrapup;
         status = BScv_copy(rc, tmp_off2, *outcv3);
         if(! status) 
            goto wrapup;
         *tab_inx =  *tab_inx + 2;
      }
      else
      {
         off_table[*tab_inx] = cv_index;
         noff_dist[*tab_inx] = d2;
         BSalloccv(tmp_off1->order, tmp_off1->num_poles, tmp_off1->rational, 0,
                   outcv1, rc);
         if (BSERROR(*rc))
            goto wrapup;
         status = BScv_copy(rc,tmp_off1, *outcv1);
         if(! status) 
            goto wrapup;

         BSalloccv(tmp_off2->order, tmp_off2->num_poles, tmp_off2->rational, 0,
                   outcv2, rc);
         if (BSERROR(*rc))
            goto wrapup;
         status = BScv_copy(rc,tmp_off2, *outcv2);
         if(! status) 
            goto wrapup;
         *tab_inx = *tab_inx + 1;
      }
   }   /* end if (keep_going) */

  
   wrapup:
   if (alloc_tmp_off2)
   {
      status = BSfreecv(&rc1, tmp_off2);
      tmp_off2 = NULL;
   }
   if (alloc_tmp_off1)
   {
      status = BSfreecv(&rc2, tmp_off1);
      tmp_off1 = NULL;
   }
   if(tmp_arc) 
   {
      status = BSfreecv(&rc3,tmp_arc);
      tmp_arc = NULL;
   }
   
   if(BSERROR(rc1) || BSERROR(rc2) || BSERROR(rc3))
      *rc = BSFAIL;

   if (lcv.poles)
   {
      BSdealloc((char *) lcv.poles);
      lcv.poles = NULL;
   }

   if (lcv.weights)
   {
      BSdealloc((char *) lcv.weights);
      lcv.weights = NULL;
   }

   if (lcv.knots)
   {
      BSdealloc((char *) lcv.knots);
      lcv.knots = NULL;
   }

   if (rcv.poles)
   {
      BSdealloc((char *) rcv.poles);
      rcv.poles = NULL;
   }

   if (rcv.weights)
   {
      BSdealloc((char *) rcv.weights);
      rcv.weights = NULL;
   }

   if (rcv.knots)
   {
      BSdealloc((char *) rcv.knots);
      rcv.knots = NULL;
   }

   if (alloc_extcv2_knots)
      BSstackdealloc((char *) extcv2.knots);

   if (alloc_extcv2_weights)
      BSstackdealloc((char *) extcv2.weights);

   if (alloc_extcv2_poles)
      BSstackdealloc((char *) extcv2.poles);

   if (alloc_extcv1_knots)
      BSstackdealloc((char *) extcv1.knots);

   if (alloc_extcv1_weights)
      BSstackdealloc((char *) extcv1.weights);

   if (alloc_extcv1_poles)
      BSstackdealloc((char *) extcv1.poles);

   if (alloc_z2_temp)   
      BSstackdealloc((char *) z2_temp);

   if (alloc_z1_temp)   
      BSstackdealloc((char *) z1_temp);

   if (alloc_z2_unwt)   
      BSstackdealloc((char *) z2_unwt);

   if (alloc_z1_unwt)   
      BSstackdealloc((char *) z1_unwt);

   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BScmpextoff");
   return;
   }
} 
