/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BScmpcvoff1

Abstract
    This routine offsets a composite curve with non-uniform options
(varying offset distances, preserve, linear varying) and it is used by 
BScmpcvoff.

Synopsis
    void BScmpcvoff1(num_valid, new_cvs, codes, index, sign, nor_vec, 
                     off_dist, fillet, closed, num_off_cvs, tran_off_cvs, 
                     off_table, rc)

    IGRint     num_valid;
    struct IGRbsp_curve **new_cvs;
    IGRint     *codes;
    IGRint     *index;
    IGRint     sign;
    IGRvector  nor_vec;
    IGRdouble  *off_dist;
    IGRboolean fillet;
    IGRboolean closed
    IGRint     *num_off_cvs;
    struct IGRbsp_curve **tran_off_cvs;
    IGRint     *off_table;
    BSrc       *rc;

Description
    Input Arguments:
         num_valid - number of valid input curves
         new_cvs - array of input curves
         codes - option code:
                    BSCONSTOFF( 51 ), offset with corresponding distances
                    BSPRESERVCVSHP( 52 ), preserve the curve
                    BSLINVAROFF( 53 ), linear varying offset
         index - array of indices to original curves
         sign - +1 or -1
         nor_vec - normal vector (should be (0, 0, 1))
         off_dist - array of offset distances
         fillet - 1: fillet option
                  0: extend option
                  2: if d1 or d2 == 0 then just connect end points
                     else extend to intersection linearly(not polynomially)
         closed

   Output Arguments:
         num_off_cvs - number of offset curves
         tran_off_cvs - array of offset curves
         off_table - offset table 
         rc - return code

Return Values
   If successful, rc = BSSUCC; else, rc returns error message.

Notes
   nor_vec should be set = (0, 0, 1).

Index
    md

Keywords

History
    Y. S. Sheng  01/08/88  : Creation date.
    Y. S. Sheng  01/21/88  : Modified to call exttrmBScmpcvoff1 if the two 
                             offset curves are supposed to intersect but
                             they do not.(extend one of the curves to intersect
                             the other one.)
    Y. S. Sheng  01/25/88  : Modified in preserve option to let the offset 
                             curve(if order = 2) extend to the end points
                             of the preserved curve instead of creating a 
                             gap curve. 
    Y. S. Sheng  01/26/88  : Change the code number in "codes" and "off_table"
                             in order to match the include file.
    Y. S. Sheng  01/28/88  : Modified to check if after_int = TRUE in
                             preserving option.
    Y. S. Sheng  03/14/88  : Modified when connect=2 and exttrmBScmpcvoff1 is
                             called,add an output curve to the output list if
                             lines[inx_lines] exists.
                             Modified to avoid calling BSmerge_cv in 
                             exttrmBScmpcvoff1.                         
    Y. S. Sheng  03/18/88  : Include "bscmpcvoff.h" to define "codes" and 
                             "off_table".
    S. C. Wood   10/17/88  : Changed parameter list of call to BSvarcvoff, 
                             to pass paremeter values rather than points
                             (changed min and max of type IGRpoint to minpar1 
                             and maxpar2 of type IGRdouble, respectively).
    S.G. Catron  03/15/89  : When offsetting linearly the first or last
                             curve in the closed composite case, use the 
                             previous distance and next distance.  This 
                             means we have to find the wrap around
                             distance.                             
    S.G. Catron  05/08/89  : If the curves are closed and the first curve
                             wants the perserve shape option, then we
                             will shift the curves.  Since there is not
                             suppose to be two perserve shape curves 
                             next to each other this would solve the
                             problem.  This is a problem only when it's 
                             the first curve, because you need the 
                             previous curve and next curve to perserve 
                             the shape of this particular curve.
    S. C. Wood   08/02/89  : Call exttrmBScmpcvoff1 after BScvint_trm if
                             rc = BSNOSOLUTION (indicating no intersection)
                             if returned from BScvint_trm as well as when
                             degen != 0.
    S. C. Wood   08/08/89  : Assign values to off_table[tab_inx] = index[i]
                             instead of i. (index[i] contains the indeces of
                             non-degenerate, valid curves). 
    S. C. Wood   08/09/89  : Calculate extension factor (ext_factor) for 
                             extending curves to intersection to be relative 
                             to the 2 offset distances; the closer the offset 
                             distances, the shorter the extension. Previously, 
                             used a constant factor regardless of offset
                             distances.
                             Call exttrmBScmpcvoff1 to extend tran_off_cvs
                             [tab_inx - 1] and tmp_off_cvs[i] to intersection 
                             if toff_dist[i-1] != toff_dist[i].  If 
                             toff_dist[i-1] = toff_dist[i] call BSlngen to 
                             construct line, lines[inx_lines],  connecting 
                             tmp_off_cvs[i - 1] and Tmp_off_cvs[i].
    S. C. Wood   08/23/89  : Changed call to BSlngen to generate a line 
                             from b1 to b instead of b to b1 in static
                             routine exttrmBScmpcvoff1. Also, modified
                             call to BSactivsplt in this static routine
                             to split line2 between parameters, ss and
                             line2->knots[line2->num_poles] instead of
                             between line2->knots[line2->order - 1] and ss.
    S. C. Wood   09/11/89  : Modified code to handle 3-D offset cases.
                             Included code when BSzigzag returns connect =
                             2 (offset curves should intersect), but 
                             BScvint_trm returns rc = BSNOSOLUTION to
                             try to intersect with the next previous curve.
                             Similar modification if the composite curve is 
                             closed and the first and last offset curves
                             should intersect.  If the next previous curve
                             is non-intersecting then try the next following
                             curve.
                             Made static routine, exttrmBScmpcvoff1, a
                             separate routine (BSexttrmcmp). Created 4
                             routines from code taken out of this routine: 
                             BScmpmrgoff, BScmpintoff, BScmpextoff, 
                             BScmpoffcls.
    S. C. Wood   09/28/89  : Replace call to BScvint_trm to BScvinttrmd
                             (copy of BScvint_trm with offset distances
                             as arguments). Modified call statement for
                             routines with argument list changes:
                             Bscmpextoff, BScmpintoff, BScmpmrgoff, 
                             BScmpoffcls. Set noff_dist to appropriate
                             offset distance each time off_table is set.
    S. C. Wood   11/17/89  : In the case of codes[i] = BSLINVAROFF, replace
                             call to BSvarcvoff to BSxycvoffwl to offset
                             tnew_cvs.  BSvarcvoff offsets a curve but does
                             not handle cusps and BSxycvoffwl breaks the
                             curve at cusps, offsets these sections and then
                             joins them appropriately.
    S. C. Wood   01/23/89  : When making sure that the curves of the composite
                             curve are closed when flag (closed) = TRUE, 
                             unweight poles of curve that the rational bit 
                             was checked for.  Previously checking tnew_cvs[0]
                             rational bit but was unweighting tnew_cvs
                             [num_valid - 1].  Also, if codes(index[0]) = 
                             BSPRESERVCVSHP use tnew_cvs[num_valid - 1] and
                             tnew_cuvs[num_valid - 2] when checking to make
                             sure that composite curve is closed when 
                             flag (closed) = TRUE.  Added note that nor_vec
                             should be passed in as (0, 0, 1) because this
                             is assumed to be true later in flow of routines.
    S. C. Wood   07/11/90  : Changed static routine trim1BScmpcvoff1 to call
                             BSmdstptcv instead of BSmdistptcv.
    S. C. Wood   11/01/90  : Fixed problem in accidentally setting 
                             tran_off_cvs[-1] to NULL.
    S. C. Wood   11/14/90  : Deleted unneeded argument in 2nd call to 
                             BScmpmrgoff and corrected apogee warnings.
    S. C. Wood   01/07/91  : When copying outcv1, outcv2, outcv3, outcv4, 
                             or outcv5 into an existing element (pointer
                             to curve structure) oftran_off_cvs, check
                             to see if that element of tran_off_cvs has
                             enough memory.  If not, free that element of
                             tran_off_cvs and allocate adequate memory.
                             Moved static routines above BScmpcvoff1.
                             Call BSEXTRACTPAR without status.
                             Typecast all IGRboolean BSroutines as void and
                             delete reference to status.
    S. C. Wood   01/24/92  : In case of codea[i] = BSPRESERVCVSHP, after
                             call to BScvinttrmd to trim tmp_off_cvs[i]
                             with off_cv, tmp_off_cvs[i] was never being
    S. C. Wood   06/23/92  : Modified section of code for preserving the
                             shape of a curve.  If the curve is a circular
                             arc and either of the bounding curves is not
                             a line, extend the offsets of these bounding
                             curves and then call BSfillet3d to create a 
                             fillet arc instead of just moving the arc 
                             based on vector from intersection of the two 
                             bounding offset curves to the intersection
                             of their corresponding original curves. 
                             Also, in chkzconnect, when checking distance
                             between the z values at par1 (for off1) and
                             par2 (for off2), divide by weights before doing
                             distance check.  Fix for TR# 92n5178.
    S. C. Wood   07/08/92  : Corrected allocation/deallocation mismatch.
    S. C. Wood   12/30/92  : Modified to not construct line segments to 
                             join curves. Move poles instead. Fix for
                             TR# 913056.
    S. C. Wood   02/16/93  : In chkzconnectBScmpcvoff1, good_z was mistakenly
                             dimensioned to good_z[1][4] instead of 
                             good_z[2][4].  Corrected this error.
    S. C. Wood   03/08/93  : In case of codes[i] = BSPRESERVCVSHP, BScvinttrmd
                             was being called with toff_dist[i] and 
                             toff_dist[i+1]. If i = num_valid - 1, this array
                             was out of bounds. In this case, toff_dist[0]
                             should be accessed instead of toff_dist[i+1].

    S.G. Catron  12/05/97  : Changed to check for NOSOLUTION from BSxycvoff,
                             which means that offset disappears with this
                             distance.  Skip to next curve.   Also check after
                             BScmpintoff, if NOSOLUTION and delete offset
                             from output(continue on).
    Vivian Y.Hsu 2/10/98   : Increased array z1[1][4], z2[1][4] to 
                             z1[2][4], z2[2][4] to avoid accessing
                             uninitialized memory. (purify problem).
    S.G. Catron  07/11/00  : When trying to decide about which connection to use
                             between curves(BSzigzag), make sure if we skipped the
                             last curve, that we don't use that one.
    S.G. Catron  07/27/00  : Just set outcv1, outcv2... to output array instead
                             of reallocating, copying, and freeing.
                             After call to BScmpextoff, check if rc=BSNOSOLTION
                             and do the same as after BScmpintoff.
    S.G. Catron  08/18/00  : Modified "fillet" argument to add another option.
                             2: if d1 or d2 == 0 then just connect end points
                             else extend to intersection linearly(not polynomially).
                             Added check, so that we don't go into the extend/trim
                             section if this distance and last distance = 0.0.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bsstackalloc.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "bsconic.h"
#include "bsmemory.h"
#endif
#include <math.h>
#define BSVOID

#define MAXNUM 100
#define BSVOID

/***************************************************************************/
/* This routine extends a curve a given distance.  If cv is a line, linear */
/* extension is done manually. If cv is a conic, BScncxtdst is called.     */
/* Otherwise, BSpolyxctdst is called.                                      */
/***************************************************************************/
static void extcvBScmpcvoff1(
struct IGRbsp_curve *cv,
IGRdouble           dist,
IGRdouble           par,
struct IGRbsp_curve **ext_cv,
BSrc                *rc )
{

#ifndef DONOTSPROTO
#include "bsnorvec.h"
#include "bsalloccv.h"
#include "bststcvfarc.h"
#include "bscncxtdst.h"
#include "bspolyxtdst.h"
#include "bscveval.h"
#endif 


   IGRint        type, i, num_der;
   IGRshort      arc_ind, order;
   IGRlong       npoles;
   IGRboolean    rational;
   IGRdouble     rad, arc_poles[20], arc_knots[10], arc_wts[7];
   IGRpoint      cen, pt;
   IGRvector     vec;
   struct
    IGRbsp_curve arc;
      
   *rc = BSSUCC;

   if (cv->num_poles == 2 && cv->order == 2)
   {
      /* Linear extension */
      if (cv->rational)
      {
         for (i = 0; i < 3; ++i)            
             vec[i] = cv->poles[i+3]/cv->weights[1] -
                         cv->poles[i]/cv->weights[0];
      }
      else
      {
         for (i = 0; i < 3; ++i)            
             vec[i] = cv->poles[i+3] - cv->poles[i];
      }
      
      (void)BSnorvec(rc, vec);
      if (BSERROR(*rc))
         goto wrapup;

      order = 2;
      npoles = 2;
      rational = FALSE;
      BSalloccv(order, npoles, rational, 0, ext_cv, rc);
      if(BSERROR(*rc)) 
        goto wrapup;

      /* Move last pole of line in direction of vec a distance of dist.
         Fill in rest of ext_cv structure. */
      (*ext_cv)->order = 2;
      (*ext_cv)->periodic = cv->periodic;
      (*ext_cv)->non_uniform = cv->non_uniform;
      (*ext_cv)->num_poles = 2;

      if (par == cv->knots[cv->order-1]) 
      {
         /* extend start of cv */
         for (i = 0; i < 3; ++i)
         {
             (*ext_cv)->poles[i] = cv->poles[i] - vec[i] * dist; 
             (*ext_cv)->poles[3+i] = cv->poles[3+i];
         }
      }
      else
      {
         /* extend end of cv */
         for (i = 0; i < 3; ++i)
         {
             (*ext_cv)->poles[i] = cv->poles[i];
             (*ext_cv)->poles[3+i] = cv->poles[3+i] + vec[i] * dist; ;
         }
      }   /* end if (par == cv->knots[cv->order-1]) */

      (*ext_cv)->num_knots = 4;
      (*ext_cv)->knots[0] = 0.0;
      (*ext_cv)->knots[1] = 0.0;
      (*ext_cv)->knots[2] = 1.0;
      (*ext_cv)->knots[3] = 1.0;

      (*ext_cv)->rational = FALSE;
      (*ext_cv)->weights = NULL;

      (*ext_cv)->planar = FALSE;
      (*ext_cv)->phy_closed = FALSE;
      (*ext_cv)->num_boundaries = 0;
   }
   else
   {
      /* Call BStstcvfarc to determine if cv is line, conic, or other. */
      arc.poles = arc_poles;
      arc.knots = arc_knots;
      arc.weights = arc_wts;
      BStstcvfarc(cv, &arc_ind, cen, &rad, &arc, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if (arc_ind == 1)
      {
         /* Circle--call BScncxtdst */
         order = 3;
         npoles = cv->num_poles + 12;
         rational = TRUE;
         BSalloccv(order, npoles, rational, 0, ext_cv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         type = BSCCIRCLE;
         BScncxtdst((IGRshort)type, cv, dist, par, *ext_cv, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }
      else
      {
         /* General--call BSpolyxtdst */
         order = cv->order;
         npoles = cv->num_poles + cv->order - 1;
         rational = cv->rational;
         BSalloccv(order, npoles, rational, 0, ext_cv, rc);
         if(BSERROR(*rc)) 
           goto wrapup;
        
         num_der = 0;
         BScveval(cv, par, num_der, (IGRpoint *)pt, rc);
         if (BSERROR(*rc))
            goto wrapup;

         BSpolyxtdst(cv, pt, dist, *ext_cv, rc);
         if (BSERROR(*rc))
            goto wrapup;

      }   /* end if (type == BSCIRCLE) */
   }   /* end if (cv->num_poles == 2 && cv->order == 2) */

   wrapup:




   return;
}

/************************************************************************/
static void trim1BScmpcvoff1(
struct IGRbsp_curve *cv1,
IGRpoint            ret_pt,
BSrc                *rc )
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
   IGRdouble      *z1_temp = NULL, z1_temp2[MAXNUM];
   IGRpoint       minpt;
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
   if(BSERROR(*rc)) goto wrapup;

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
      if(BSERROR(*rc)) 
        goto wrapup;
   }
   tsta0 = cv1->knots[cv1->order -1];
   tend0 = cv1->knots[cv1->num_poles];

   (void)BScv_copy(rc, act_cur,cv1);
   if(BSERROR(*rc)) 
     goto wrapup;

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
        act_cur = NULL;
     }

     if(BSOKAY(*rc) && BSERROR(rc1))
     {
        *rc = rc1;
     }

   return;
}


static void chkzconnectBScmpcvoff1(

IGRboolean          left_cv,
struct IGRbsp_curve *off1,
struct IGRbsp_curve *off2,
IGRdouble           *par1,
IGRdouble           *par2,
BSrc                *rc )
{
#ifndef DONOTSPROTO
#include "bscvarrev0w.h"
#include "bsalloccv.h"
#endif 

    struct
      IGRbsp_curve *tmp_cv = NULL;
    IGRint         ii, num_pars;
    IGRdouble      z1[1][4], z2[1][4], good_z[1][4];
    IGRint         z_flag;
    IGRdouble      dist, dist_tol, new_z1, new_z2;

   /* Evaluate off1 and off2 at par1 and par2, respectively, to determine 
      appropriate z value at apparent intersection point. (08/17/89) */

   num_pars = 1;
   BScvarrev0w(off1, num_pars, par1, (IGRdouble *)z1, rc);
   if (BSERROR(*rc))
       goto wrapup;

   BScvarrev0w(off2, num_pars, par2, (IGRdouble *)z2, rc);
   if (BSERROR(*rc))
      goto wrapup;

   /* Calculate distance between z-coordinates of z1 and 
      z2.  If this distance > dist_tol, construct linestring 
      (order = 2, N = 3), else construct line.  (08/17/89) */

   new_z1 = z1[0][2] / z1[0][3];
   new_z2 = z2[0][2] / z2[0][3];

   dist = ABS(new_z1 - new_z2);

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol); 

   /* if dist > dist_tol and off1 is order 2, poles curve, move last pole of
      off1 to z2.  Otherwise, construct vertical line connecting off1 and off2.
      (08/18/89) */
   if (dist > dist_tol)  
   {
      if (left_cv)
      {
         tmp_cv = off1;
         good_z[0][0] = z2[0][0];
         good_z[0][1] = z2[0][1];
         good_z[0][2] = z2[0][2];
         good_z[0][3] = z2[0][3];
         z_flag = 2;
      }
      else
      {
         tmp_cv = off2;
         good_z[0][0] = z1[0][0];
         good_z[0][1] = z1[0][1];
         good_z[0][2] = z1[0][2];
         good_z[0][3] = z1[0][3];
         z_flag = 1;
      }


      if (z_flag == 2)
      {
         if ( ! tmp_cv->rational)
         {
            for (ii = 0; ii < 3; ++ii)
                tmp_cv->poles[(tmp_cv->num_poles-1) * 3 + ii] = good_z[0][ii];
         }
         else
         {
            for (ii = 0; ii < 3; ++ii)
                tmp_cv->poles[(tmp_cv->num_poles-1)*3+ii] = 
                       good_z[0][ii] * good_z[0][3];
         }
      }
      else
      {
         if ( ! tmp_cv->rational)
         {
            for (ii = 0; ii < 3; ++ii)
                tmp_cv->poles[ii] = good_z[0][ii];
         }
         else
         {
            for (ii = 0; ii < 3; ++ii)
                tmp_cv->poles[ii] = good_z[0][ii] * good_z[0][3];
         }
      }  /* end if (good_z == z2) */

   }   /* end if(dist > dist_tol) */

   wrapup:

   return;
}

void BScmpcvoff1(

IGRint     num_valid,
struct IGRbsp_curve **new_cvs,
IGRint     *codes,
IGRint     *index,
IGRint     sign,
IGRvector  nor_vec,
IGRdouble  *off_dist,
IGRboolean fillet,
IGRboolean closed,
IGRint     *num_off_cvs,
struct IGRbsp_curve **tran_off_cvs,
IGRint     *off_table,
BSrc       *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsxycvoff.h"
#include "bscveval.h"
#include "bsexttrmcmp.h"
#include "bsalloccv.h"
#include "bscvinttrmd.h"
#include "bsofrparcv.h"
#include "bsofk3arc.h"
#include "bscvcvint.h"
#include "bsxycvoffwl.h"
#include "bsnorvec.h"
#include "bscv_copy.h"
#include "bszigzag.h"
#include "bslngen.h"
#include "bsxln.h"
#include "bscvoton.h"
#include "bsdistptpts.h"
#include "bstagsort.h"
#include "bscvarrev0w.h"
#include "bsptcvgen.h"
#include "bscmpintoff.h"
#include "bscmpmrgoff.h"
#include "bscmpextoff.h"
#include "bscmpoffcls.h"
#include "bsfreecv.h"
#include "bststcvfarc.h"
#include "bsfillet3d.h"
#endif 


   IGRboolean    after_int;
   IGRboolean    dummy1 = TRUE,dummy8,dummy9, closedd;
   IGRint        tab_inx;
   IGRint        connect,position,degen;   
   IGRint        i,j,numint,num_over, tint, tindex0, tcode0;
   IGRpoint      *dummy2=NULL, *dummy5=NULL;
   IGRdouble     dummy3,dummy4,dummy6,dummy7;
   IGRdouble     tpol,tdeg,dist_sqtol;
   IGRdouble     tsta0,tend0,tsta1,tend1;
   IGRdouble     d1,d2,scale = 1.0;
   IGRdouble     *int_pts = NULL,*par1 = NULL, *par2 = NULL;
   IGRdouble     *end_pts = NULL, *over1 = NULL, *over2 = NULL;
   IGRdouble     tmat[3][3], *ptr1, *ptr2;
   IGRdouble     minpar1=0.0, maxpar2=0.0, d;
   IGRpoint      eval_1[2],eval_2[2],p1,p2,p3;
   IGRpoint      pnt1,pnt2,pt1,pt2;
   IGRpoint      a,a1,b,b1,x1_pnt,x2_pnt;
   IGRpoint      ret_pt;
   IGRvector     trans_vec;
   struct
    IGRbsp_curve **tmp_off_cvs = NULL, *tn, *tnn;
   IGRboolean    alloc_tmp_off_cvs = FALSE;
   struct 
    IGRbsp_curve *org_cv, *off_cv, **tnew_cvs=NULL,
                 *atnew_cvs[MAXNUM];
   struct 
    IGRbsp_curve *outcv1 = NULL, *outcv2 = NULL, 
                 *outcv3 = NULL, *outcv4 = NULL, *outcv5 = NULL;
   IGRdouble     *toff_dist=NULL, atoff_dist[MAXNUM];
   IGRint        *tcodes=NULL, atcodes[MAXNUM];
   IGRint        *tindex=NULL, atindex[MAXNUM];
   IGRboolean    alloc_tcodes = FALSE, alloc_toff_dist = FALSE;
   IGRboolean    alloc_tindex = FALSE, alloc_tnew_cvs = FALSE;
   IGRdouble     *noff_dist = NULL, noff_dist2[MAXNUM];
   IGRboolean    alloc_noff_dist = FALSE;
   IGRdouble     *z1_temp = NULL, z1_temp2[MAXNUM];
   IGRdouble     *z2_temp = NULL, z2_temp2[MAXNUM];
   IGRboolean    alloc_z2_temp = FALSE, alloc_z1_temp = FALSE;
   IGRint        *subs = NULL, subs2[MAXNUM];
   IGRboolean    alloc_subs = FALSE;
   IGRshort      order;
   IGRlong       npoles;
   IGRdouble     rr, ss, t1_par[1], t2_par[1];   
   IGRboolean    left_cv;
   IGRint        tmp_tab_inx=0;
   struct
     IGRbsp_curve *tmp_cv = NULL, *good_cv1 = NULL, *good_cv2 = NULL;
   IGRboolean    alloc_tmp_cv = FALSE, tfillet;
   IGRboolean    alloc_good_cv1 = FALSE, alloc_good_cv2 = FALSE;
   IGRdouble     tmp_dist, tmp_dist1, tmp_dist2, tdist, ndist;
   IGRshort      arc_ind;
   IGRdouble     test_dist, par, ext_dist;
   IGRpoint      cen, dirpt, c1_pt, c2_pt;
   IGRint        ii, lasti;
   IGRboolean    rational, line1_flag, line2_flag;
   IGRdouble     arc_poles[20], arc_knots[10], arc_wts[7], rad;
   IGRvector     vec;
   struct 
    IGRbsp_curve *ext_trancv=NULL, *ext_offcv=NULL, arc,
                 *save_off_cv=NULL, *save_tran_off=NULL;
   BSrc          rc1 = BSSUCC;

   *rc = BSSUCC;

   tmp_dist = 0.0;
   tmp_dist1 = 0.0;
   tmp_dist2 = 0.0;

   tfillet = fillet == 1 ? 1 : 0;

   /* check if inputs are legal */

   if(codes[index[0]] == BSPRESERVCVSHP && !closed)
   {
      *rc = BSDGENRAT;
      goto wrapup;
   }

   if((codes[index[num_valid -1]] == BSPRESERVCVSHP) && (! closed))
   {
      *rc = BSDGENRAT;
      goto wrapup;
   }

   if(num_valid == 2 && codes[index[0]] == BSLINVAROFF && 
                             codes[index[num_valid -1]] == BSLINVAROFF)
   {
      *rc = BSDGENRAT;
      goto wrapup;
   }
   if( num_valid > MAXNUM )
   {
      tindex = (IGRint *)BSstackalloc((unsigned)( num_valid * sizeof(IGRint)));
      if(!tindex )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      alloc_tindex = TRUE;

      tcodes = (IGRint *)BSstackalloc((unsigned)( num_valid *
                                     sizeof(IGRint)));
      if(!tcodes )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      alloc_tcodes = TRUE;

      toff_dist = (IGRdouble *)BSstackalloc((unsigned)( num_valid *
                                        sizeof(IGRdouble)));
      if(!toff_dist )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      alloc_toff_dist = TRUE;

   }
   else
   {
      tindex = atindex;
      tcodes = atcodes;
      toff_dist = atoff_dist;
   }
   if( codes[index[0]] == BSPRESERVCVSHP )
   {
      /* then we need to shift everything by one */
      if( num_valid > MAXNUM )
      {
         tnew_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                              num_valid * sizeof(struct IGRbsp_curve *)));
         if(! tnew_cvs)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_tnew_cvs = TRUE;

      }
      else
      {
         tnew_cvs = atnew_cvs;
      }
      tn = new_cvs[0];
      BSMEMCPY((num_valid -1)*sizeof(struct IGRbsp_curve *),
               (IGRchar *) &new_cvs[1], (IGRchar *) tnew_cvs);
      tnew_cvs[num_valid-1] = tn;
      /* shift the indexs and codes */
      tindex0 = index[0];
      tcode0 = codes[index[0]];
      d1 = off_dist[index[0]];
      for(i=1; i< num_valid; i++)
      {
         tindex[i-1] = index[i];
         tcodes[i-1] = codes[index[i]];
         toff_dist[i-1] = off_dist[index[i]];
      }
      tindex[num_valid - 1] = tindex0;
      tcodes[num_valid - 1] = tcode0;
      toff_dist[num_valid -1] = d1;
   }
   else
   {
      tnew_cvs = new_cvs;
      for(i=0; i< num_valid; i++)
      {
         tindex[i] = index[i];
         tcodes[i] = codes[index[i]];
         toff_dist[i] = off_dist[index[i]];
      }
   }
      
   BSEXTRACTPAR(rc, BSTOLSQLENVEC, dist_sqtol);

   closedd = FALSE;
   if( closed )
   {
      /* check to see the input curves are closed */
      if( codes[index[0]] == BSPRESERVCVSHP )
      {
         ptr1 = &tnew_cvs[num_valid - 1]->poles[0];
         ptr2 = &tnew_cvs[num_valid - 2]->
                   poles[(tnew_cvs[num_valid - 2]->num_poles - 1) * 3];
      
         if( tnew_cvs[num_valid - 1]->rational)
         { 
            d = tnew_cvs[num_valid - 1]->weights[0];
            for(i=0; i<3; i++)
               pnt1[i] = *ptr1++ / d;
            ptr1 = pnt1;
         }
         if( tnew_cvs[num_valid - 2]->rational)
         {
            d = tnew_cvs[num_valid - 2]->weights[tnew_cvs[num_valid - 2]->
                   num_poles - 1];
            for(i=0; i<3; i++)
               pnt2[i] = *ptr2++ / d;
            ptr2 = pnt2;
         }
      }
      else
      {
         ptr1 = tnew_cvs[0]->poles;
         ptr2 = &tnew_cvs[num_valid-1]->poles[
                        (tnew_cvs[num_valid-1]->num_poles-1)*3];
      
         if( tnew_cvs[0]->rational)
         { 
            d = tnew_cvs[0]->weights[0];
            for(i=0; i<3; i++)
               pnt1[i] = *ptr1++ / d;
            ptr1 = pnt1;
         }
         if( tnew_cvs[num_valid-1]->rational)
         {
            d = tnew_cvs[num_valid - 1]->weights[tnew_cvs[num_valid - 1]->
                num_poles - 1];
            for(i=0; i<3; i++)
               pnt2[i] = *ptr2++ / d;
            ptr2 = pnt2;
         }
      }

      d = 0;
      for(i=0; i<3; i++)
      {
         d += (*ptr1 - *ptr2) * (*ptr1 - *ptr2);
         ptr1++;
         ptr2++;
      }
      if( d < dist_sqtol )
         closedd = TRUE;
   }
   /* assign values to tmat */

   for(i=0; i < 3; i++)
   {
      for(j=0; j < 3; j++)
      {
         tmat[i][j] = 0.0;
      }
   }
   tmat[0][0] = 1.0;
   tmat[1][1] = 1.0;
   tmat[2][2] = 1.0;

   /* Allocate memory for array, tmp_off_cvs, which will contain the initial
      offset curves which may or may not be modified later by BSpolyxcvcv  */

   tmp_off_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)(num_valid *
                   sizeof(struct IGRbsp_curve *)));
   if(! tmp_off_cvs)
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   alloc_tmp_off_cvs = TRUE;

   for(i=0; i < num_valid; i++)
   {
      tmp_off_cvs[i] = NULL;
   }

   /* Allocate memory for noff_dist which is an array containing offset
      distances associated with each curve in tran_off_cvs. (10/02/89) */
   if ((2 * num_valid) > MAXNUM)
   {
      noff_dist = (IGRdouble *)BSstackalloc((unsigned)((2 * num_valid)*
                                        sizeof(IGRdouble)));
      if(!noff_dist )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      alloc_noff_dist = TRUE;
   }
   else
   {
      noff_dist = noff_dist2;
   }

   /*----------------
      Initialization
   -------------------*/

   *num_off_cvs = 0;
   after_int = FALSE;
   tab_inx = 0;
   i = 0;

   while( i <=  num_valid -1 )
   {
      if( tcodes[i] == BSCONSTOFF)
      {
         /* offset with a distance */

         BSxycvoff(tnew_cvs[i], toff_dist[i], tfillet, nor_vec, sign,
             &tmp_off_cvs[i], rc);
         if(BSERROR(*rc))
         {
            if(*rc == BSNOSOLUTION )
            {
                i++;
                continue;
            }
            goto wrapup;
         }
         if( i > 1 && tab_inx == tmp_tab_inx )
            /* then last time, we didn't add an offset curve */
            lasti = i-2;
         else
            lasti = i-1;	       

         if( tab_inx == 0 || (toff_dist[i] == 0.0 && toff_dist[lasti] == 0.0) )
         {
            npoles = tmp_off_cvs[i]->num_poles + 2 * tmp_off_cvs[i]->order - 2;
            BSalloccv(tmp_off_cvs[i]->order, npoles, tmp_off_cvs[i]->rational,
                      0,  &tran_off_cvs[tab_inx], rc);
            if (BSERROR(*rc))
               goto wrapup;
            (void)BScv_copy(rc, tmp_off_cvs[i],tran_off_cvs[tab_inx]);
            if(BSERROR(*rc)) 
              goto wrapup;
	    off_table[tab_inx] = tindex[i];
	    noff_dist[tab_inx] = toff_dist[i];
            tab_inx++;
         }
         else
         {
            /* ckeck the connection type with the previous curve */

            tpol = tnew_cvs[lasti]->knots[tnew_cvs[lasti]->num_poles];
            tdeg = tnew_cvs[i]->knots[tnew_cvs[i]->order -1];
    
            BScveval(tnew_cvs[lasti], tpol, 1, eval_1, rc);
            if(BSERROR(*rc)) goto wrapup;

            BScveval(tnew_cvs[i], tdeg, 1, eval_2, rc);
            if(BSERROR(*rc)) goto wrapup;

            (void)BSnorvec(rc, eval_1[1]);
            if(BSERROR(*rc)) 
              goto wrapup;

            (void)BSnorvec(rc, eval_2[1]);
            if(BSERROR(*rc)) 
              goto wrapup;
              
            eval_1[0][2] = 0.0;
            eval_1[1][2] = 0.0;
            eval_2[0][2] = 0.0;
            eval_2[1][2] = 0.0;
    
            for(j=0; j < 3; j++)
            {
               p2[j] = eval_1[0][j];
               p1[j] = p2[j] - eval_1[1][j];
               p3[j] = p2[j] + eval_2[1][j];
            }

            (void)BSzigzag(rc, p1, p2, p3, nor_vec, &sign, &connect);
            if(BSERROR(*rc)) 
               goto wrapup;

            if(i == 1)
            {
               if(num_valid == 2)
               {
                  position = 3;
               }
               else
               {
                  position = 1;
               }
            }
            else if(i == num_valid - 1)
            {
               position = 3;
            }
            else
            {
               position = 2;
            }

            if(connect == 1)
            {
               /* connecting case(identical tangent at connecting points) */
               tmp_tab_inx = tab_inx;
               BScmpmrgoff(tran_off_cvs[tab_inx - 1], tmp_off_cvs[i],
                   noff_dist[tab_inx-1], toff_dist[i], tindex[i], &after_int,
                   ret_pt, &tab_inx, off_table, noff_dist, &outcv1, &outcv2,
                   &outcv3, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               /* Copy outcv1, outcv2, and outcv3 into appropriate 
                  tran_off_cvs curve and deallocate */

               if (outcv1)
               {
                  if (tran_off_cvs[tmp_tab_inx - 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx - 1] = NULL;
                  }
                  tran_off_cvs[tmp_tab_inx-1] = outcv1;
                  outcv1 = NULL;

               }
          
               if (outcv2)
               {
                  if (tran_off_cvs[tmp_tab_inx])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx] = outcv2;
                  outcv2 = NULL;
               }

               if (outcv3)
               {
                  if (tran_off_cvs[tmp_tab_inx + 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx + 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx+1] = outcv3;		      
                  outcv3 = NULL;
               }
            }
            else if(connect == 2)
            {
               if ((tab_inx - 2) >= 0)
               {
                  BSalloccv(tran_off_cvs[tab_inx - 2]->order,
                            tran_off_cvs[tab_inx - 2]->num_poles,  
                            tran_off_cvs[tab_inx - 2]->rational, 0, 
                            &tmp_cv, rc);
                  if (BSERROR(*rc))
                     goto wrapup;
                  alloc_tmp_cv = TRUE;

                  (void)BScv_copy(rc,tran_off_cvs[tab_inx-2], tmp_cv);
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  tmp_dist = noff_dist[tab_inx-2];
               }
               else
               {
                  alloc_tmp_cv = FALSE;
                  tmp_cv = NULL;
               }

               tmp_tab_inx = tab_inx;

               BScmpintoff(tmp_cv, tran_off_cvs[tab_inx-1], tmp_off_cvs[i],
                 position,tmp_dist,noff_dist[tab_inx-1],toff_dist[i],tindex[i],
                 &tab_inx, off_table, noff_dist, &after_int, ret_pt, &outcv1,
                 &outcv2, &outcv3, &outcv4, rc);
               if (BSERROR(*rc))
               {
                  if( *rc == BSNOSOLUTION  &&  (i < num_valid -1 || tab_inx > 1)  )
                  {
                     *rc = BSSUCC;
                     tab_inx--;
                     if( tran_off_cvs[tab_inx] )
                     {
                        (void)BSfreecv(rc, tran_off_cvs[tab_inx] );
                        if(BSERROR(*rc))
                           goto wrapup;
                        tran_off_cvs[tab_inx] = NULL;
                     }
                  }                      
                  else
                     goto wrapup;
               }
               /* Copy outcv1, outcv2, outcv3, and outcv4 into appropriate 
                  tran_off_cvs curve and deallocate */
               if (outcv1)
               {
                  if (tran_off_cvs[tmp_tab_inx - 2])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 2]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx - 2] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx-2] = outcv1;
                  outcv1 = NULL;
               }
          
               if (outcv2)
               {
                  if (tran_off_cvs[tmp_tab_inx - 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx - 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx-1] = outcv2;
                  outcv2 = NULL;
               }
               else
                  tmp_tab_inx -= 1;   /* offset curve2 degenerated */

               if (outcv3)
               {
                  if (tran_off_cvs[tmp_tab_inx])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx] = outcv3;
                  outcv3 = NULL;
               }

               if (outcv4)
               {
                  if (tran_off_cvs[tmp_tab_inx + 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx + 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx+1] = outcv4;
                  outcv4 = NULL;
               }

               if(alloc_tmp_cv && tmp_cv)
               {
                  alloc_tmp_cv = FALSE;
                  (void)BSfreecv(rc, tmp_cv);
                  if (BSERROR(*rc))
                     goto wrapup;
                  tmp_cv = NULL;
               }

            }   /* if (connect == 2) */
            else
            {
                /* filleting or extending case */

                tmp_tab_inx = tab_inx;
                BScmpextoff(tnew_cvs[lasti], tnew_cvs[i],tran_off_cvs[tab_inx-1],
                    tmp_off_cvs[i], fillet, noff_dist[tab_inx-1], toff_dist[i],
                    nor_vec, sign, tindex[i], &after_int, ret_pt, &tab_inx,
                    off_table, noff_dist, &outcv1, &outcv2, &outcv3, rc);
                if (BSERROR(*rc))
                {
                  if( *rc == BSNOSOLUTION  &&  (i < num_valid -1 || tab_inx > 1)  )
                  {
                     *rc = BSSUCC;
                     tab_inx--;
                     if( tran_off_cvs[tab_inx] )
                     {
                        (void)BSfreecv(rc, tran_off_cvs[tab_inx] );
                        if(BSERROR(*rc))
                           goto wrapup;
                        tran_off_cvs[tab_inx] = NULL;
                     }
                  }                      
                  else
                     goto wrapup;
                }
                /* Copy outcv1, outcv2, and outcv3 into appropriate 
                   tran_off_cvs curve and deallocate */

                if (outcv1)
                {
                   if (tran_off_cvs[tmp_tab_inx - 1])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                      if (BSERROR(*rc))
                         goto wrapup;
  
                      tran_off_cvs[tmp_tab_inx - 1] = NULL;
                   }

                   tran_off_cvs[tmp_tab_inx-1] = outcv1;
                   outcv1 = NULL;

                }
          
                if (outcv2)
                {
                   if (tran_off_cvs[tmp_tab_inx])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                      if (BSERROR(*rc))
                         goto wrapup;
 
                      tran_off_cvs[tmp_tab_inx] = NULL;
                   }

                   tran_off_cvs[tmp_tab_inx] = outcv2;
                   outcv2 = NULL;
                }

                if (outcv3)
                {
                   if (tran_off_cvs[tmp_tab_inx + 1])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                      if (BSERROR(*rc))
                         goto wrapup;
  
                      tran_off_cvs[tmp_tab_inx + 1] = NULL;
                   }
 
                   tran_off_cvs[tmp_tab_inx+1] = outcv3;
                   outcv3 = NULL;
                }
            }
         }                     
      } 
      else if( tcodes[i] == BSPRESERVCVSHP )
      {
         /*---------------------------------
            preserve the original curve shape
         ----------------------------------- */

         /* modified 1/28/88 */

         if(after_int)
         {
            /* trim tran_off_cvs[tab_inx - 1] */

            trim1BScmpcvoff1(tran_off_cvs[tab_inx - 1], ret_pt, rc);
            if(BSERROR(*rc)) goto wrapup;
         }                               
         after_int = FALSE;


         if(i < num_valid -1)       
         {
            BSxycvoff(tnew_cvs[i+1], toff_dist[i+1], tfillet, nor_vec, sign,
                &tmp_off_cvs[i+1], rc);
            if(BSERROR(*rc)) goto wrapup;
         
            org_cv = tnew_cvs[i+1];
            off_cv = tmp_off_cvs[i+1];
            test_dist = toff_dist[i+1];

            if (tnew_cvs[i+1]->num_poles == 2 && tnew_cvs[i+1]->order == 2)
               line2_flag = TRUE;
            else
               line2_flag = FALSE;
         }
         else
         {
            /* i = num_valid -1 and it is closed composite curve */

            org_cv = tnew_cvs[0];
            off_cv = tran_off_cvs[0];
            test_dist = toff_dist[0];

            if (tnew_cvs[0]->num_poles == 2 && tnew_cvs[0]->order == 2)
               line2_flag = TRUE;
            else
               line2_flag = FALSE;
         }                        


         if (tnew_cvs[i-1]->num_poles == 2 && tnew_cvs[i-1]->order == 2)
            line1_flag = TRUE;
         else
            line1_flag = FALSE;


         /******************************************************************/
         /* Call BStstcvfarc to determine if tnew_cvs[i] is a circ. arc. 
            If tnew_cvs[i] is an arc and tnew_cvs[i+1] and tnew_cvs[i-1]
            are not lines, call BSfillet instead of extending the previous
            and next offset curve (and associated original curves) to 
            intersection and translating curve.*/
         /******************************************************************/
         arc.poles = arc_poles;
         arc.knots = arc_knots;
         arc.weights = arc_wts;
         BStstcvfarc(tnew_cvs[i], &arc_ind, cen, &rad, &arc, rc);
         if (BSERROR(*rc))
            goto wrapup;

         if (arc_ind == 1 && (!line1_flag || !line2_flag))
         {
            BScvcvint(tran_off_cvs[tab_inx - 1], off_cv, dummy1, 0,0, 
               dummy2, &dummy3, &dummy4, dummy5, &dummy6, &dummy7, &numint,
               &num_over, &dummy8, &dummy9, (IGRpoint **)(&int_pts), &par1, 
               &par2, (IGRpoint **)(&end_pts), &over1, &over2, rc);
            if(BSERROR(*rc)) 
              goto wrapup;

	   
            /* Get c1_pt, c2_pt, dirpt to pass to BSfillet3d. */
            /* c1_pt = end point of previous offset curve */
            if (tran_off_cvs[tab_inx - 1]->rational)
            {
               for (ii = 0; ii < 3; ++ii)
                   c1_pt[ii] = tran_off_cvs[tab_inx-1]->poles
                                [(tran_off_cvs[tab_inx-1]->num_poles-1)*3+ii] /
                               tran_off_cvs[tab_inx-1]->weights
                                [(tran_off_cvs[tab_inx-1]->num_poles-1)];
            }
            else
            {
               for (ii = 0; ii < 3; ++ii)
                   c1_pt[ii] = tran_off_cvs[tab_inx-1]->poles
                                [(tran_off_cvs[tab_inx-1]->num_poles-1)*3+ii];
            }

            /* c2_pt = start point of next offset curve */
            if (off_cv->rational)
            {
               for (ii = 0; ii < 3; ++ii)
                   c2_pt[ii] = off_cv->poles[ii] / off_cv->weights[0];
            }
            else
            {
               for (ii = 0; ii < 3; ++ii)
                   c2_pt[ii] = off_cv->poles[ii];
            }

            /* Get dirpt */
            for (ii = 0; ii < 3; ++ii)
                dirpt[ii] = (c1_pt[ii] + c2_pt[ii]) * .5;

            /* If the bounding offset curves intersect (numint > 0), 
               mirror dirpt to other side of intersection point. */
            if (numint > 0)
            {
               for (ii = 0; ii < 3; ++ii)
               {
                  vec[ii] = int_pts[ii] - dirpt[ii];
                  dirpt[ii] = int_pts[ii] + vec[ii];
               }
            }

            if(int_pts) 
            {
              BSdealloc((char *)int_pts); 
              int_pts = NULL;
            }
            if(end_pts)
            { 
              BSdealloc((char *)end_pts); 
              end_pts = NULL;
            }
            if(over1)
            { 
              BSdealloc((char *) over1); 
              over1 = NULL;
            }
            if(over2) 
            {      
              BSdealloc((char *) over2); 
              over2 = NULL;
            }
            if (par1)
            {
               BSdealloc((char *) par1);
               par1 = NULL;
            }   
            if (par2)
            {
               BSdealloc((char *) par2);
               par2 = NULL;
            }   

            /* Extend tran_off_cvs[tab_inx] and off_cv before filleting 
               or moving of curve. */
            par = tran_off_cvs[tab_inx-1]->knots
                     [tran_off_cvs[tab_inx-1]->num_poles];
            if (noff_dist[tab_inx-1] > rad)
               ext_dist = 10 * noff_dist[tab_inx-1];
            else
               ext_dist = 10 * rad;

            extcvBScmpcvoff1(tran_off_cvs[tab_inx-1], ext_dist, par, 
                             &ext_trancv, rc);
            if (BSERROR(*rc))
               goto wrapup;

            /* Free original tran_off_cvs and set it = ext_trancv */
            if (tran_off_cvs[tab_inx-1])
            {
               (void)BSfreecv(rc, tran_off_cvs[tab_inx-1]); 
               if (BSERROR(*rc))
                  goto wrapup;
               tran_off_cvs[tab_inx-1] = NULL;
            }
            tran_off_cvs[tab_inx-1] = ext_trancv;
            ext_trancv = NULL;


            par = off_cv->knots[off_cv->order - 1];
            if (test_dist > rad)
               ext_dist = test_dist * 10;
            else
               ext_dist = rad * 10;
            extcvBScmpcvoff1(off_cv, ext_dist, par, &ext_offcv, rc);
            if (BSERROR(*rc))
               goto wrapup;

            /* Store off_cv pointer in temporary variable */
            save_off_cv = off_cv;
            off_cv = ext_offcv;

            if (test_dist > 0.0 || noff_dist[tab_inx-1] > 0.0)
            {
               /* At least 1 offset distance > 0.0. */
               order = 3;
               npoles = 7;
               rational = TRUE; 
               BSalloccv(order, npoles, rational, 0, &tmp_off_cvs[i], rc);
               if (BSERROR(*rc))
                  goto wrapup;
	
               (void)BSfillet3d(tran_off_cvs[tab_inx - 1], off_cv, rad, 
                             c1_pt, c2_pt, dirpt, nor_vec, tmp_off_cvs[i], rc);
               if (BSERROR(*rc))
                  goto wrapup;
            }
            else
            {
               /* Both offset distances are 0.0--Copy tnew_cvs[i] into 
                  tran_off_cvs[tab_inx] */
               BSalloccv(tnew_cvs[i]->order, tnew_cvs[i]->num_poles, 
                         tnew_cvs[i]->rational, 0, &tmp_off_cvs[i],
                         rc);
               if (BSERROR(*rc))
                  goto wrapup;

               (void)BScv_copy(rc, tnew_cvs[i],tmp_off_cvs[i]);
               if(BSERROR(*rc)) 
                  goto wrapup;
            }
         }
         else
         {
            /* find x-y (08/16/89) intersection between tnew_cvs[i-1] and
               tnew_cvs[i+1] */
            tpol = tnew_cvs[i-1]->knots[tnew_cvs[i-1]->num_poles];
            tdeg = org_cv->knots[org_cv->order -1];

            BScveval(tnew_cvs[i-1], tpol, 1, eval_1, rc);
            if(BSERROR(*rc)) goto wrapup;

            BScveval(org_cv, tdeg, 1, eval_2, rc);
            if(BSERROR(*rc)) goto wrapup;
   
            /* Set z-values of eval_1 and eval_2 = 0.0 (08/16/89) */
            eval_1[0][2] = 0.0;
            eval_1[1][2] = 0.0;
            eval_2[0][2] = 0.0;
            eval_2[1][2] = 0.0;

            for(j=0; j < 3; j++)
            {
               a[j] = eval_1[0][j];
               a1[j] = eval_1[0][j] + eval_1[1][j];
               b[j] = eval_2[0][j];
               b1[j] = eval_2[0][j] - eval_2[1][j];
            }

            (void)BSxln(rc, a, a1, b, b1, x1_pnt);
            if(BSERROR(*rc))
            {
               /* no intersection is found (two lines are parallel) */

               *rc = BSFAIL;
               goto wrapup;
            }

            /* find x-y (08/16/89) intersection between tran_off_cvs[tab_inx-1]
               and tmp_off_cvs[i+1] */

            tpol = tran_off_cvs[tab_inx - 1]->knots
                        [tran_off_cvs[tab_inx - 1]->num_poles];
            tdeg = off_cv->knots[off_cv->order -1];

            BScveval(tran_off_cvs[tab_inx - 1], tpol, 1, eval_1, rc);
            if(BSERROR(*rc)) goto wrapup;

            BScveval(off_cv, tdeg, 1, eval_2, rc);
            if(BSERROR(*rc)) goto wrapup;

            /* Set z-values of eval_1 and eval_2 = 0.0 (08/16/89) */
            eval_1[0][2] = 0.0;
            eval_1[1][2] = 0.0;
            eval_2[0][2] = 0.0;
            eval_2[1][2] = 0.0;

            for(j=0; j < 3; j++)
            {
               a[j] = eval_1[0][j];
               a1[j] = eval_1[0][j] + eval_1[1][j];
               b[j] = eval_2[0][j];
               b1[j] = eval_2[0][j] - eval_2[1][j];
            }

            (void)BSxln(rc, a, a1, b, b1, x2_pnt);
            if(BSERROR(*rc))
            {
               /* no intersection is found (two lines are parallel) */
   
               *rc = BSFAIL;
               goto wrapup;
            }

            /* find translation vector */
   
            for(j=0; j < 3; j++)
            {
               trans_vec[j] = x1_pnt[j] - x2_pnt[j];
            }

            /* translate tnew_cvs[i] to tmp_off_cvs[i] */
   
            BSalloccv(tnew_cvs[i]->order, tnew_cvs[i]->num_poles, 
                      tnew_cvs[i]->rational, 0, &tmp_off_cvs[i], rc);
            if(BSERROR(*rc)) goto wrapup;
   
            (void)BScvoton(rc, trans_vec, tmat, &scale, tnew_cvs[i], 
                          tmp_off_cvs[i]);
            if(BSERROR(*rc)) 
               goto wrapup;

         }   /* end if (arc_ind == 1 && (!line1_flag || !line2_flag)) */


         /*----------------------------------------------------------
           Insure connection between tran_off_cvs[tab_inx - 1] and 
           tmp_off_cvs[i].
         -----------------------------------------------------------*/
 
         /* Set z-values of tran_off_cvs[tab_inx - 1] and tmp_off_cvs[i]=0.0
            to check the connections between offset curves, if intersects,
            trim both curves; if no intersection, move poles to join. */

         if (tran_off_cvs[tab_inx - 1]->num_poles > MAXNUM)
         {
            z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
               (tran_off_cvs[tab_inx - 1]->num_poles * sizeof(IGRdouble)));
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

         for (j = 0; j < tran_off_cvs[tab_inx - 1]->num_poles; ++j)
         {
             z1_temp[j] = tran_off_cvs[tab_inx - 1]->poles[3 * j + 2];
             tran_off_cvs[tab_inx - 1]->poles[3 * j + 2] = 0.0;
         }

         if (tmp_off_cvs[i]->num_poles > MAXNUM)
         {
            z2_temp = (IGRdouble *)BSstackalloc((unsigned) 
                          (tmp_off_cvs[i]->num_poles * sizeof(IGRdouble)));
            if (! z2_temp)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
               alloc_z2_temp = TRUE;
         }
         else
         {
            z2_temp = z2_temp2;
         }

         for (j = 0; j < tmp_off_cvs[i]->num_poles; ++j)
         {
             z2_temp[j] = tmp_off_cvs[i]->poles[3 * j + 2];
             tmp_off_cvs[i]->poles[3 * j + 2] = 0.0;
         }
  
         BScvcvint(tran_off_cvs[tab_inx - 1], tmp_off_cvs[i], dummy1, 0,0, 
               dummy2, &dummy3, &dummy4, dummy5, &dummy6, &dummy7, &numint,
               &num_over, &dummy8, &dummy9, (IGRpoint **)(&int_pts), &par1, 
               &par2, (IGRpoint **)(&end_pts), &over1, &over2, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         /* Reset z-values back to original value. (08/15/89) */
         for (j = 0; j < tran_off_cvs[tab_inx - 1]->num_poles; ++j)
         {
             tran_off_cvs[tab_inx - 1]->poles[3 * j + 2] = z1_temp[j];
         }
 
         if (alloc_z1_temp)                
         {
            BSstackdealloc((char *) z1_temp);
            z1_temp = NULL;
         }
 
         for (j = 0; j < tmp_off_cvs[i]->num_poles; ++j)
             tmp_off_cvs[i]->poles[3 * j + 2] = z2_temp[j];
   
         if (alloc_z2_temp)                
         {
            BSstackdealloc((char *) z2_temp);
            z2_temp = NULL;
         }

         if(numint > 0)
         {
            if(numint > 1)
            {
               if (numint > MAXNUM)
               {
                  subs = (IGRint *)BSstackalloc((unsigned)(numint * 
                             sizeof(IGRint)));
                  if (! subs)
                  {
                     *rc = BSNOSTKMEMORY;
                     goto wrapup;
                  }
                  alloc_subs = TRUE;
               }
               else
               {
                  subs = subs2;
               }

               (void)BStagsort(rc, &numint, par1, subs);
               if(BSERROR(*rc))
                  goto wrapup;
   
               rr = par1[subs[numint -1]];
               ss = par2[subs[numint -1]];
            }
            else
            {
               rr = par1[0];
               ss = par2[0];
            }

            /* trim both curves */
            if(i == 1)
            {
               if(num_valid == 2)
               {
                  position = 3;
               }
               else
               {
                  position = 1;
               }
            }
            else if(i == num_valid - 1)
            {
               position = 3;
            }
            else
            {
               position = 2;
            }
 
            /* Set start and end parameters for tran_off_cvs[tab_inx-1] and
               tmp_off_cvs[i] for reparameterization following
               BScvinttrmd. */
            tsta0 = tran_off_cvs[tab_inx - 1]->knots
                         [tran_off_cvs[tab_inx - 1]->order -1];
            tend0 = tran_off_cvs[tab_inx - 1]->knots
                         [tran_off_cvs[tab_inx - 1]->num_poles];
            tsta1 = tmp_off_cvs[i]->knots[tmp_off_cvs[i]->order -1];
            tend1 = tmp_off_cvs[i]->knots[tmp_off_cvs[i]->num_poles];

            BScvinttrmd(noff_dist[tab_inx-1], toff_dist[i], 
                        tran_off_cvs[tab_inx-1], tmp_off_cvs[i], position,
                        ret_pt, &after_int, &degen, rc);
            if(BSERROR(*rc))
              goto wrapup;
         
            after_int = FALSE;

            t1_par[0] = rr;
            t2_par[0] = ss;
            /* Call static routine to check the z-coordinates of 
               tran_off_cvs[tab_inx - 1] and tmp_off_cvs[i]. If they differ,
               construct move poles */

            left_cv = TRUE;
            chkzconnectBScmpcvoff1(left_cv, tran_off_cvs[tab_inx - 1], 
                       tmp_off_cvs[i], t1_par, t2_par, rc);
            if (BSERROR(*rc))
               goto wrapup;

            /*--------------------------------------------------------
               Reparameterize tran_off_cvs[tab_inx - 1] and tmp_off_cvs[i]
            --------------------------------------------------------*/
            BSofrparcv(tran_off_cvs[tab_inx - 1], tsta0,tend0,rc);
            if(BSERROR(*rc)) 
               goto wrapup;
            BSofrparcv(tmp_off_cvs[i], tsta1,tend1,rc);
            if(BSERROR(*rc)) 
              goto wrapup;

            off_table[tab_inx] = tindex[i];
            noff_dist[tab_inx] = toff_dist[i];
            BSalloccv(tmp_off_cvs[i]->order, tmp_off_cvs[i]->
                      num_poles, tmp_off_cvs[i]->rational, 0, 
                      &tran_off_cvs[tab_inx], rc);
            if (BSERROR(*rc))
               goto wrapup;
            (void)BScv_copy(rc,tmp_off_cvs[i],tran_off_cvs[tab_inx]);
            if(BSERROR(*rc)) 
              goto wrapup;
            tab_inx = tab_inx + 1;      
         }
         else   /* if (numint > 0) */
         {
            if(tran_off_cvs[tab_inx - 1]->rational)
            {
               for(j=0; j < 3; j++)
               {
                  pt1[j] = tran_off_cvs[tab_inx - 1]->poles
                          [3 * (tran_off_cvs[tab_inx - 1]->num_poles -1) + j] /
                           tran_off_cvs[tab_inx - 1]->weights
                          [tran_off_cvs[tab_inx - 1]->num_poles -1];
               }
            }
            else
            {
               for(j=0; j < 3; j++)
               {
                  pt1[j] = tran_off_cvs[tab_inx - 1]->poles
                           [3 * (tran_off_cvs[tab_inx - 1]->num_poles -1) + j];
               }
            }

            if(tmp_off_cvs[i]->rational)
            {
               for(j=0; j < 3; j++)
                  pt2[j] = tmp_off_cvs[i]->poles[j] / tmp_off_cvs[i]->
                                weights[0];
            }
            else
            {
               for(j=0; j < 3; j++)
                  pt2[j] = tmp_off_cvs[i]->poles[j];
            }

            /* If order = 2 and num_poles = 2, move last pole to new
               position (pt2) */
            if(tran_off_cvs[tab_inx - 1]->rational)
            {
               for(j=0; j < 3; j++)
               {
                  tran_off_cvs[tab_inx - 1]->poles
                         [3 * (tran_off_cvs[tab_inx - 1]->num_poles -1) + j]
                     = pt2[j] *  tran_off_cvs[tab_inx - 1]->weights
                            [tran_off_cvs[tab_inx - 1]->num_poles -1];
               }
            }
            else
            {
               for(j=0; j < 3; j++)
               {
                  tran_off_cvs[tab_inx - 1]->poles[3 * (tran_off_cvs
                          [tab_inx - 1]->num_poles -1) + j] = pt2[j];
               }
            }
            off_table[tab_inx] = tindex[i];
            noff_dist[tab_inx] = toff_dist[i];
            BSalloccv(tmp_off_cvs[i]->order, tmp_off_cvs[i]->
                      num_poles, tmp_off_cvs[i]->rational, 0, 
                      &tran_off_cvs[tab_inx], rc);
            if (BSERROR(*rc))
               goto wrapup;
            (void)BScv_copy(rc,tmp_off_cvs[i],tran_off_cvs[tab_inx]);
            if(BSERROR(*rc)) 
              goto wrapup;
            tab_inx = tab_inx + 1;      

         }
   
         if(alloc_subs) 
         {
           BSdealloc((char *)subs); 
           subs = NULL;
         }
         if(int_pts) 
         {
           BSdealloc((char *)int_pts); 
           int_pts = NULL;
         }
         if(end_pts)
         { 
           BSdealloc((char *)end_pts); 
           end_pts = NULL;
         }
         if(over1)
         { 
           BSdealloc((char *) over1); 
           over1 = NULL;
         }
         if(over2) 
         {      
           BSdealloc((char *) over2); 
           over2 = NULL;
         }
         if (par1)
         {
            BSdealloc((char *) par1);
            par1 = NULL;
         }   
         if (par2)
         {
            BSdealloc((char *) par2);
            par2 = NULL;
         }   

         /*----------------------------------------------------------
           Insure connection between tmp_off_cvs[i] and off_cv.
         -----------------------------------------------------------*/

         /* Set z-values of tmp_off_cvs[i] and off_cv = 0.0 to
            check the connections between offset curves, if intersects,
            trim both curves; if no intersection, move poles to join. */


         if (tmp_off_cvs[i]->num_poles > MAXNUM)
         {
            z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
                     (tmp_off_cvs[i]->num_poles * sizeof(IGRdouble)));
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

         for (j = 0; j < tmp_off_cvs[i]->num_poles; ++j)
         {
             z1_temp[j] = tmp_off_cvs[i]->poles[3 * j + 2];
             tmp_off_cvs[i]->poles[3 * j + 2] = 0.0;
         }

         if (off_cv->num_poles > MAXNUM)
         {
            z2_temp = (IGRdouble *)BSstackalloc((unsigned) 
                          (off_cv->num_poles * sizeof(IGRdouble)));
            if (! z2_temp)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            alloc_z2_temp = TRUE;
         }
         else
         {
            z2_temp = z2_temp2;
         }

         for (j = 0; j < off_cv->num_poles; ++j)
         {
             z2_temp[j] = off_cv->poles[3 * j + 2];
             off_cv->poles[3 * j + 2] = 0.0;
         } 
         BScvcvint(tmp_off_cvs[i], off_cv, dummy1, 0,0, dummy2,
               &dummy3, &dummy4, dummy5, &dummy6, &dummy7, &numint, &num_over, 
               &dummy8, &dummy9, (IGRpoint **)(&int_pts), &par1, &par2, 
               (IGRpoint **)(&end_pts), &over1, &over2, rc);
         if(BSERROR(*rc)) 
           goto wrapup;

         /* Reset z-values back to original value. (08/15/89) */
         for (j = 0; j < tmp_off_cvs[i]->num_poles; ++j)
             tmp_off_cvs[i]->poles[3 * j + 2] = z1_temp[j];
 
         if (alloc_z1_temp)                
         {
            BSstackdealloc((char *) z1_temp);
            z1_temp = NULL;
         }  

         for (j = 0; j < off_cv->num_poles; ++j)
             off_cv->poles[3 * j + 2] = z2_temp[j];
   
         if (alloc_z2_temp)                
         {
            BSstackdealloc((char *) z2_temp);
            z2_temp = NULL;
         }

         if(numint > 0)
         {
            if(numint > 1)
            {
               subs = (IGRint *)BSstackalloc((unsigned)(numint * 
                          sizeof(IGRint)));
               if(! subs)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               alloc_subs = TRUE;

               (void)BStagsort(rc, &numint, par1, subs);
               if(BSERROR(*rc))
                  goto wrapup;

               rr = par1[subs[numint -1]];
               ss = par2[subs[numint -1]];
            }
            else
            {
               rr = par1[0];
               ss = par2[0];
            }

            /* trim both curves */
            if(i == num_valid - 2)
            {
               position = 3;
            }
            else
            {
               position = 2;
            }

            /* Set start and end parameters for tmp_off_cvs[i] and
               off_cv for reparameterization following BScvinttrmd. */
            tsta0 = tmp_off_cvs[i]->knots[tmp_off_cvs[i]->order -1];
            tend0 = tmp_off_cvs[i]->knots[tmp_off_cvs[i]->num_poles];
            tsta1 = off_cv->knots[off_cv->order -1];
            tend1 = off_cv->knots[off_cv->num_poles];

            if( i == num_valid -1 )
              ii = 0;
            else
              ii = i+1;
            BScvinttrmd(toff_dist[i], toff_dist[ii], tmp_off_cvs[i], 
                        off_cv, position, ret_pt, &after_int, &degen, rc);
            if(BSERROR(*rc)) 
               goto wrapup;
         
            t1_par[0] = rr;
            t2_par[0] = ss;

            /* Call static routine to check the z-coordinates of tmp_off_cvs[i]
               and off_cv.  If they differ, move poles to join. */

            left_cv = FALSE;
            chkzconnectBScmpcvoff1(left_cv, tmp_off_cvs[i], off_cv, t1_par, 
                                   t2_par, rc);
            if (BSERROR(*rc))
               goto wrapup;

            /*--------------------------------------------------------
               Reparameterize tmp_off_cvs[i] and tmp_off_cvs[i+1]
            --------------------------------------------------------*/

            BSofrparcv(tmp_off_cvs[i], tsta0,tend0,rc);
            if(BSERROR(*rc)) 
              goto wrapup;

            BSofrparcv(off_cv, tsta1,tend1,rc);
            if(BSERROR(*rc)) 
               goto wrapup;

            if (i < num_valid - 1)
            {
               if (tran_off_cvs[tab_inx - 1])
               {
                  (void)BSfreecv(rc, tran_off_cvs[tab_inx - 1]);
                  if (BSERROR(*rc))
                     goto wrapup;
   
                  tran_off_cvs[tab_inx - 1] = NULL;
               }

               BSalloccv(tmp_off_cvs[i]->order, tmp_off_cvs[i]->num_poles,
                         tmp_off_cvs[i]->rational, 0,
                         &tran_off_cvs[tab_inx-1], rc);
               if (BSERROR(*rc))
                  goto wrapup;

              (void)BScv_copy(rc, tmp_off_cvs[i], tran_off_cvs[tab_inx-1]);
              if(BSERROR(*rc)) 
                 goto wrapup;

               off_table[tab_inx - 1] = tindex[i];
               noff_dist[tab_inx - 1] = toff_dist[i];

               off_table[tab_inx] = tindex[i + 1];
               noff_dist[tab_inx] = toff_dist[i + 1];
               BSalloccv(off_cv->order, off_cv->num_poles, 
                         off_cv->rational, 0, &tran_off_cvs[tab_inx], rc);
               if (BSERROR(*rc))
                  goto wrapup;
               (void)BScv_copy(rc,off_cv,tran_off_cvs[tab_inx]);
               if(BSERROR(*rc)) 
                 goto wrapup;
               tab_inx = tab_inx + 1;      
            }
         }
         else
         {
            /* move poles */
            if(tmp_off_cvs[i]->rational)
            {
               for(j=0; j < 3; j++)
                  pt1[j] = tmp_off_cvs[i]->poles[3 * (tmp_off_cvs[i]->
                              num_poles -1) + j] / tmp_off_cvs[i]->weights
                              [tmp_off_cvs[i]->num_poles -1];
            }
            else
            {
               for(j=0; j < 3; j++)
                  pt1[j] = tmp_off_cvs[i]->poles[3 * (tmp_off_cvs[i]->
                               num_poles -1) + j];
            }

            if(off_cv->rational)
            {
               for(j=0; j < 3; j++)
                  pt2[j] = off_cv->poles[j] / off_cv->weights[0];
            }
            else
            {
               for(j=0; j < 3; j++)
                  pt2[j] = off_cv->poles[j];
            }

            if(off_cv->rational)
            {
               for(j=0; j < 3; j++)
                  off_cv->poles[j] = pt1[j] *  off_cv->weights[0];
            }
            else
            {
               for(j=0; j < 3; j++)
                  off_cv->poles[j] = pt1[j];
            }

            if( i < num_valid -1)
            {
               off_table[tab_inx] = tindex[i+1];
               noff_dist[tab_inx] = toff_dist[i+ 1];
               BSalloccv(off_cv->order, off_cv->num_poles, 
                         off_cv->rational, 0, &tran_off_cvs[tab_inx],rc);
               if (BSERROR(*rc))
                  goto wrapup;
               (void)BScv_copy(rc,off_cv,tran_off_cvs[tab_inx]);
               if(BSERROR(*rc)) 
                 goto wrapup;
               tab_inx = tab_inx + 1;      
            }
         }

         if(alloc_subs) 
         {
           BSdealloc((char *)subs); 
           subs = NULL;
         }
         if(int_pts) 
         {
           BSdealloc((char *)int_pts); 
           int_pts = NULL;
         }
         if(par1) 
         {        
           BSdealloc((char *)par1);  
           par1 = NULL;
         }
         if(par2) 
         {
           BSdealloc((char *)par2); 
           par2 = NULL;
         }
         if(end_pts)
         {           
           BSdealloc((char *)end_pts); 
	           end_pts = NULL;
         }
         if(over1) 
         {      
           BSdealloc((char *) over1); 
           over1 = NULL;
         }
         if(over2)
         { 
           BSdealloc((char *) over2); 
           over2 = NULL;
         }


         /* If save_off_cv contains off_cv original pointer (before extension),
            set off_cv back = save_off_cv and free ext_offcv */
         if (save_off_cv)
         {
            off_cv = save_off_cv;
            save_off_cv = NULL;
            if (ext_offcv)
            {
               (void)BSfreecv(rc, ext_offcv);
               if (BSERROR(*rc))
                  goto wrapup;
               ext_offcv = NULL;
            }
         }
         i = i + 1;
      }
      else if( tcodes[i] == BSLINVAROFF )
      {
         /*----------------------
            linear varying option
         -------------------------*/

         if(i == 0)
         {
            if( closedd )
               j = num_valid -1;
            else
               j = 0;

            BSxycvoffwl(tnew_cvs[i], toff_dist[j], toff_dist[1], TRUE, NULL, 
                        minpar1, maxpar2, tfillet, nor_vec, sign,
                        &tmp_off_cvs[i], rc);
            if (BSERROR(*rc))
               goto wrapup;

            off_table[tab_inx] = tindex[i];
            noff_dist[tab_inx] = toff_dist[i];
            BSalloccv(tmp_off_cvs[i]->order, tmp_off_cvs[i]->num_poles, 
                tmp_off_cvs[i]->rational, 0, &tran_off_cvs[tab_inx], rc);
            if (BSERROR(*rc))
               goto wrapup;
            (void)BScv_copy(rc,tmp_off_cvs[i],tran_off_cvs[tab_inx]);
            if(BSERROR(*rc)) 
              goto wrapup;
            tab_inx ++;
         }
         else
         {
            if(i == num_valid -1)
            {
                if( closedd )
                   j = 0;
                else
                   j = num_valid - 1;

                BSxycvoffwl(tnew_cvs[i], toff_dist[num_valid-2], toff_dist[j], 
                            TRUE, NULL, minpar1, maxpar2, tfillet, nor_vec,
                            sign, &tmp_off_cvs[i], rc);
                if (BSERROR(*rc))
                   goto wrapup;

                d1 = toff_dist[num_valid -2];
                d2 = toff_dist[num_valid -1];
            }
            else
            {
                BSxycvoffwl(tnew_cvs[i], toff_dist[i - 1], toff_dist[i + 1], 
                            TRUE, NULL, minpar1, maxpar2, tfillet, nor_vec,
                            sign, &tmp_off_cvs[i], rc);
                if (BSERROR(*rc))
                   goto wrapup;


                d1 = toff_dist[i-1];
                d2 = toff_dist[i+1];
            }

            /* ckeck the connection type with the previous offset curve */

            tpol = tnew_cvs[i-1]->knots[tnew_cvs[i-1]->num_poles];
            tdeg = tnew_cvs[i]->knots[tnew_cvs[i]->order -1];
    
            BScveval(tnew_cvs[i-1], tpol, 1, eval_1, rc);
            if(BSERROR(*rc)) goto wrapup;

            BScveval(tnew_cvs[i], tdeg, 1, eval_2, rc);
            if(BSERROR(*rc)) goto wrapup;

            (void)BSnorvec(rc, eval_1[1]);
            if(BSERROR(*rc)) 
              goto wrapup;

            (void)BSnorvec(rc, eval_2[1]);
            if(BSERROR(*rc))
              goto wrapup;

            /* Set z values of eval_1 and eval_2 = 0.0 (08/22/89) */
            eval_1[0][2] = 0.0;
            eval_1[1][2] = 0.0;
            eval_2[0][2] = 0.0;
            eval_2[1][2] = 0.0;

            for(j=0; j < 3; j++)
            {
               p2[j] = eval_1[0][j];
               p1[j] = p2[j] - eval_1[1][j];
               p3[j] = p2[j] + eval_2[1][j];
            }

            (void)BSzigzag(rc, p1, p2, p3, nor_vec, &sign, &connect);
            if(BSERROR(*rc)) 
              goto wrapup;


            if(connect == 1)
            {
               /* connecting case(identical tangent at connecting points) */
               tmp_tab_inx = tab_inx;

               BScmpmrgoff(tran_off_cvs[tab_inx - 1], tmp_off_cvs[i],
                   noff_dist[tab_inx-1], toff_dist[i], tindex[i], &after_int,
                   ret_pt, &tab_inx, off_table, noff_dist, &outcv1, &outcv2,
                   &outcv3, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               /* Copy outcv1, outcv2, and outcv3 into appropriate 
                  tran_off_cvs curve and deallocate */

               if (outcv1)
               {
                
                  if(tran_off_cvs[tmp_tab_inx - 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                     if (BSERROR(*rc))
                        goto wrapup;
 
                     tran_off_cvs[tmp_tab_inx - 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx-1] = outcv1;
                  outcv1 = NULL;
               }

               if (outcv2)
               {
                  if (tran_off_cvs[tmp_tab_inx])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                     if (BSERROR(*rc))
                        goto wrapup;
 
                     tran_off_cvs[tmp_tab_inx] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx] = outcv2;  
                  outcv2 = NULL;
               }

               if (outcv3)
               {
                  if (tran_off_cvs[tmp_tab_inx + 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                     if (BSERROR(*rc))
                        goto wrapup;
                        tran_off_cvs[tmp_tab_inx + 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx+1] = outcv3;  
                  outcv3 = NULL;
               }
            }  
            else if(connect == 2)
            {
               if(i == 1)
               {
                  if(num_valid == 2)
                  {
                     position = 3;
                  }
                  else
                  {
                     position = 1;
                  }
               }
               else if(i == num_valid - 1)
               {
                  position = 3;
               }
               else
               {
                  position = 2;
               }

               if ((tab_inx - 2) >= 0)
               {
                  BSalloccv(tran_off_cvs[tab_inx - 2]->order,
                            tran_off_cvs[tab_inx - 2]->num_poles,  
                            tran_off_cvs[tab_inx - 2]->rational, 0, 
                            &tmp_cv, rc);
                  if (BSERROR(*rc))
                     goto wrapup;
                  alloc_tmp_cv = TRUE;

                  (void)BScv_copy(rc,tran_off_cvs[tab_inx-2], tmp_cv);
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  tmp_dist = noff_dist[tab_inx - 2];
               }
               else
               {
                  alloc_tmp_cv = FALSE;
                  tmp_cv = NULL;
               }

               tmp_tab_inx = tab_inx;
               BScmpintoff(tmp_cv, tran_off_cvs[tab_inx-1], tmp_off_cvs[i],
                 position,tmp_dist,noff_dist[tab_inx-1],toff_dist[i],tindex[i],
                 &tab_inx, off_table, noff_dist, &after_int, ret_pt, &outcv1, 
                 &outcv2, &outcv3, &outcv4, rc);
               if (BSERROR(*rc))
               {
                  if( *rc == BSNOSOLUTION )
                     *rc = BSSUCC;
                  goto wrapup;
               }

               /* Copy outcv1, outcv2, outcv3, and outcv4 into appropriate 
                  tran_off_cvs curve and deallocate */

               if (outcv1)
               {
                  if (tran_off_cvs[tmp_tab_inx - 2])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 2]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx - 2] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx-2] = outcv1;  
                  outcv1 = NULL;
               }

               if (outcv2)
               {
                  if (tran_off_cvs[tmp_tab_inx - 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx - 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx-1] = outcv2;  
                  outcv2 = NULL;
               }

               if (outcv3)
               {
                  if (tran_off_cvs[tmp_tab_inx])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx] = outcv3;  
                  outcv3 = NULL;
               }

               if (outcv4)
               {
                  if (tran_off_cvs[tmp_tab_inx + 1])
                  {
                     (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                     if (BSERROR(*rc))
                        goto wrapup;

                     tran_off_cvs[tmp_tab_inx + 1] = NULL;
                  }

                  tran_off_cvs[tmp_tab_inx+1] = outcv4;  
                  outcv4 = NULL;
               }

               if(alloc_tmp_cv && tmp_cv) 
               {
                  alloc_tmp_cv = FALSE;
                  (void)BSfreecv(rc, tmp_cv);
                  if (BSERROR(*rc))
                     goto wrapup;
                  tmp_cv = NULL;
               }
            }
            else
            {
                /* filleting or extending case */

                tmp_tab_inx = tab_inx;
                BScmpextoff(tnew_cvs[i-1], tnew_cvs[i],tran_off_cvs[tab_inx-1],
                    tmp_off_cvs[i], fillet, d1, d2, nor_vec, sign, tindex[i],
                    &after_int, ret_pt, &tab_inx, off_table, noff_dist, 
                    &outcv1, &outcv2, &outcv3, rc);
                if (BSERROR(*rc))
                   goto wrapup;

                /* Copy outcv1, outcv2, and outcv3 in appropriate tran_off_cvs
                   curve and deallocate */

                if (outcv1)
                {
                   if (tran_off_cvs[tmp_tab_inx - 1])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
                      if (BSERROR(*rc))
                         goto wrapup;
 
                      tran_off_cvs[tmp_tab_inx - 1] = NULL;
                   }

                  tran_off_cvs[tmp_tab_inx-1] = outcv1;  
                   outcv1 = NULL;
                }

                if (outcv2)
                {
                   if (tran_off_cvs[tmp_tab_inx])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
                      if (BSERROR(*rc))
                         goto wrapup;
 
                      tran_off_cvs[tmp_tab_inx] = NULL;
                   }

                   tran_off_cvs[tmp_tab_inx] = outcv2;  
                   outcv2 = NULL;
                }

                if (outcv3)
                {
                   if (tran_off_cvs[tmp_tab_inx + 1])
                   {
                      (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx + 1]);
                      if (BSERROR(*rc))
                         goto wrapup;
  
                      tran_off_cvs[tmp_tab_inx + 1] = NULL;
                   }

                   tran_off_cvs[tmp_tab_inx+1] = outcv3;  
                   outcv3 = NULL;
                }

             }
          } /* end of if(i == 0) */
      } 
      else
      {
          *rc = BSINARG;
          goto wrapup;
      }/* end of if(tcodes[i] == 51) */

      i = i + 1;
   } /* end of while loop */

   if (closed && !(noff_dist[tab_inx - 1] == 0.0 && noff_dist[0] == 0.0) )
   {
      /* Set POINTERS of temporary curves (good_cv1, good_cv2) = correct 
         tran_off_cvs POINTER (tran_off_cvs[tab_inx - 2], tran_off_cvs[1])
         depending on number of valid curves in composite & tab_inx */

      if (tab_inx > 2)
      {
         BSalloccv(tran_off_cvs[tab_inx-2]->order, tran_off_cvs[tab_inx-2]->
                   num_poles, tran_off_cvs[tab_inx-2]->rational, 0, 
                   &good_cv1, rc);
         if (BSERROR(*rc))
            goto wrapup;
         alloc_good_cv1 = TRUE;

         (void)BScv_copy(rc,tran_off_cvs[tab_inx-2], good_cv1);
         if(BSERROR(*rc)) 
           goto wrapup;
         tmp_dist1 = noff_dist[tab_inx - 2];

         BSalloccv(tran_off_cvs[1]->order, tran_off_cvs[1]->num_poles,
                   tran_off_cvs[1]->rational, 0, &good_cv2, rc);
         if (BSERROR(*rc))
            goto wrapup;
         alloc_good_cv2 = TRUE;

         (void)BScv_copy(rc,tran_off_cvs[1], good_cv2);
         if(BSERROR(*rc)) 
           goto wrapup;

         tmp_dist2 = noff_dist[1];
      }

      tran_off_cvs[tab_inx] = NULL;
      tmp_tab_inx = tab_inx;
      BScmpoffcls(tnew_cvs[num_valid - 1], tnew_cvs[0], good_cv1,
         tran_off_cvs[tab_inx - 1], tran_off_cvs[0], good_cv2, tmp_dist1,
         noff_dist[tab_inx - 1], noff_dist[0], tmp_dist2, num_valid, fillet,
         nor_vec, sign, &tab_inx, off_table, noff_dist, &after_int, ret_pt,
         &outcv1, &outcv2, &outcv3, &outcv4,  &outcv5, rc);
      if (BSERROR(*rc))
         goto wrapup;

      /* Copy outcv1, outcv2, outcv3, outcv4, and outcv5 into appropriate    
         tran_off_cvs curve and deallocate */

      if (outcv1)
      {
         if (tran_off_cvs[tmp_tab_inx - 2])
         {
            (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 2]);
            if (BSERROR(*rc))
               goto wrapup;

            tran_off_cvs[tmp_tab_inx - 2] = NULL;
         }

         tran_off_cvs[tmp_tab_inx-2] = outcv1;  
         outcv1 = NULL;
      }

      if (outcv2)
      {
         if (tran_off_cvs[tmp_tab_inx - 1])
         {
            (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx - 1]);
            if (BSERROR(*rc))
               goto wrapup;

            tran_off_cvs[tmp_tab_inx - 1] = NULL;
         }

         tran_off_cvs[tmp_tab_inx-1] = outcv2;  
         outcv2 = NULL;
      }

      if (outcv3)
      {
         if (tran_off_cvs[0])
         {
            (void)BSfreecv(rc, tran_off_cvs[0]);
            if (BSERROR(*rc))
               goto wrapup;

            tran_off_cvs[0] = NULL;
         }

         tran_off_cvs[0] = outcv3;  
         outcv3 = NULL;
      }

      if (outcv4)
      {
         if (tran_off_cvs[1])
         {
            (void)BSfreecv(rc, tran_off_cvs[1]);
            if (BSERROR(*rc))
               goto wrapup;

            tran_off_cvs[1] = NULL;
         }

         tran_off_cvs[1] = outcv4;  
         outcv4 = NULL;
      }

      if (outcv5)
      {
         if (tran_off_cvs[tmp_tab_inx])
         {
            (void)BSfreecv(rc, tran_off_cvs[tmp_tab_inx]);
            if (BSERROR(*rc))
               goto wrapup;

            tran_off_cvs[tmp_tab_inx] = NULL;
         }

         tran_off_cvs[tmp_tab_inx] = outcv5;  
         outcv5 = NULL;
      }
   }

   *num_off_cvs = tab_inx;

   if( codes[index[0]] == BSPRESERVCVSHP )
   {
      /* reshuffle the output curves  */
      if( off_table[*num_off_cvs-1] != num_valid -1 )
      {
         /* then two curves need to be shuffled (offset curve and inserted
            line or arc). (08/30/89) */
         tn = tran_off_cvs[*num_off_cvs-1];
         tnn = tran_off_cvs[*num_off_cvs-2];
         BSMEMCPY((*num_off_cvs-2 ) * sizeof(struct IGRbsp_curve *),
                  (IGRchar *) tran_off_cvs, (IGRchar *) &tran_off_cvs[2]);
         tran_off_cvs[0] = tnn;
         tran_off_cvs[1] = tn;
         tint = off_table[*num_off_cvs - 1];
         tdist = noff_dist[*num_off_cvs - 1];
         numint = off_table[*num_off_cvs - 2];
         ndist = noff_dist[*num_off_cvs - 2];
         BSMEMCPY((*num_off_cvs-2) * sizeof(IGRint), (IGRchar *)off_table,
                  (IGRchar *) &off_table[2]);
         off_table[0] = numint;
         noff_dist[0] = ndist;
         off_table[1] = tint;
         noff_dist[1] = tdist;
      }
      else
      {
         /* shuffle by one */
         tn = tran_off_cvs[*num_off_cvs-1];
         BSMEMCPY((*num_off_cvs-1 ) * sizeof(struct IGRbsp_curve *),
                  (IGRchar *) tran_off_cvs, (IGRchar *) &tran_off_cvs[1]);
         tran_off_cvs[0] = tn;
         tint = off_table[*num_off_cvs - 1];
         tdist = noff_dist[*num_off_cvs - 1];
         BSMEMCPY((*num_off_cvs-1 ) * sizeof(IGRint),(IGRchar *)off_table,
                  (IGRchar *)&off_table[1]);
         off_table[0] = tint;
         noff_dist[0] = tdist;
      }
   }

   wrapup:
     if (save_tran_off)
     {
        (void)BSfreecv(&rc1, save_tran_off);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        save_tran_off = NULL;
        rc1 = BSSUCC;
     }

     if (save_off_cv)
     {
        (void)BSfreecv(&rc1, save_off_cv);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        save_off_cv = NULL;
        rc1 = BSSUCC;
     }

     if (ext_offcv)
     {
        (void)BSfreecv(&rc1, ext_offcv);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        ext_offcv = NULL;
        rc1 = BSSUCC;
     }

     if (ext_trancv)
     {
        (void)BSfreecv(&rc1, ext_trancv);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        ext_trancv = NULL;
        rc1 = BSSUCC;
     }

     if(alloc_good_cv2) 
     {
        (void)BSfreecv(&rc1, good_cv2);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        good_cv2 = NULL;
        rc1 = BSSUCC;
     }

     if(alloc_good_cv1) 
     {
        (void)BSfreecv(&rc1, good_cv1);
        if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
        good_cv1 = NULL;
        rc1 = BSSUCC;
     }

     if (alloc_noff_dist)
     {
        BSstackdealloc((char *)noff_dist);
        noff_dist = NULL;
     }

     if(alloc_tmp_off_cvs) 
     {
       for (i = 0; i < num_valid; ++i)
       {
           if (tmp_off_cvs[i])
           {
              (void)BSfreecv(&rc1, tmp_off_cvs[i]);
              if (BSERROR(rc1) && BSOKAY(*rc))
                 *rc = rc1;
              tmp_off_cvs[i] = NULL;
              rc1 = BSSUCC;
           }
       }
       BSstackdealloc((char *)tmp_off_cvs); 
       tmp_off_cvs = NULL;
     }
     if (alloc_toff_dist)
     {
        BSstackdealloc((char *)toff_dist);
        toff_dist = NULL;
     }
     if (alloc_tcodes)  
     {
        BSstackdealloc((char *)tcodes );
        tcodes = NULL;
     }
     if (alloc_tindex)
     {
        BSstackdealloc((char *)tindex );
        tindex = NULL;
     }
     if( codes[index[0]] == BSPRESERVCVSHP )
     {
        if( alloc_tnew_cvs)
           BSstackdealloc((char *)tnew_cvs);
     }

   if(BSERROR(*rc))
       BSdbgrc(*rc,"BScmpcvoff1");
   return;
}                

