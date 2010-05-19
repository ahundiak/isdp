/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BScmpcvoffl

Abstract
    This routine offsets a composite curve and removes loops from the offset
    curve as desired by the input parameter (rm_loop).  The user has the
    option of not removing loops, removing loops and returning array of
    loops, and removing loops but not returning array of loops as specified
    by rm_loop.

Synopsis
    void BScmpcvoffl(num_cvs, cvs, right_side, nor_vec, off_dist, 
                    off_uniform, codes,fillet, rm_loop, closed, 
                    num_offcvs, off_cvs, off_table, num_loops, numcvs_lp, 
                    loops, loop_table, rc)
    IGRint     num_cvs
    struct IGRbsp_curve **cvs
    IGRboolean right_side
    IGRvector  nor_vec
    IGRdouble  *off_dist
    IGRboolean off_uniform
    IGRint     *codes
    IGRboolean fillet
    IGRshort   rm_loop
    IGRboolean closed
    IGRint     *num_offcvs
    struct IGRbsp_curve **off_cvs
    IGRint     *off_table
    IGRint     *num_loops
    IGRint     *numcvs_lp
    struct IGRbsp_curve **loops
    IGRint     *loop_table     
    BSrc       *rc

Description
    Input:
        num_cvs - number of B-spline curves to form a composite curve.

        cvs - pointer to an array of pointers to B-spline curves.

        right_side - If TRUE, T x nor_vec = offset direction
                     else, opposite to offset direction.

        nor_vec - If 2-D, normal to the plane contains cvs
                  If 3-D, view normal

        off_dist - pointer to an array of distances. If off_uniform = 
                   TRUE, only off_dist[0] will be used.

        off_uniform - TRUE, offset with single offset distance
                      FALSE, each curve will offset with corresponding
                      distance or option.

        fillet -  1: fillet option
                  0: extend option
                  2: if d1 or d2 == 0 then just connect end points
                     else extend to intersection linearly(not polynomially)

        rm_loop - 0 = do not remove loops
                  1 = remove loops and return the array of loops
                  2 = remove loops but do not return the array of loops

        closed - TRUE, closed case at end of composite curve.
                 FALSE, open case at end of composite curve.

        codes - options for different type of offset
                BSCONSTOFF( 51 ): offset with distance
                BSPRESERVCVSHP( 52 ): preserve the original curve shape
                BSLINVAROFF( 53 ): use linear varying offset

    Output:
        num_offcvs - number of offset curves.
        off_cvs - pointer to an array of pointers to offset curves.
        off_table - table of the indices for the offset curves 
                    corresponding to original curves.
        num_loops - number of loops.
        numcvs_lp - array of number of curves per loop.
        loops - pointer to an array of pointers to loop curves
        loop_table - table of the indices for the loops corresponding to
                     original curves.
      
Return Values
    
Notes
    1. If there is a gap between two offset curves, it will be represented
       as follows in off_table:

       BSCVLINE( -61 ) : a line
       BSCVLINESTR( -62 ): a line string
       BSCVCIRCARC( -63 ): a circular arc
       BSCVGENCONC( -64 ): a general conic
       BSCVGENBSPC( -65 ): a general B-spline

    2. Caller needs to allocate space for the array of pointers to curves 
       for off_cvs ,off_table, numcvs_lp, loops and loop_table.
       space needed for the variables are:

       off_cvs   : (2 * num_cvs +1) * (pointer to curve)
       off_table : (2 * num_cvs +1) * IGRint
       numcvs_lp : (2 * num_cvs +1) * (pointers to IGRint)   
       loops     : (2 * num_cvs +1) * (pointer to curves)
       loop_table: (2 * num_cvs +1) * (pointers to IGRint)   

Index
    md

Keywords

History
    Y. S. Sheng  11/23/87  : Creation date.
    Y. S. Sheng  12/10/87  : use rc1 instead of rc after "wrapup".
    Y. S. Sheng  12/22/87  : Modified to extend the order 2 offset curve 
                             to the extending point instead of returning 
                             an extra curve segment.
                             Add a new input argument "codes".
    Y. S. Sheng  01/11/88  : Use BScmpcvoff1 to take care of non-uniform
                             offsetting.                           
    Y. S. Sheng  01/19/88  : Set act_cur = NULL after BSfreecv is called.
    Y. S. Sheng  01/26/88  : Change the code number in "codes" and 
                             "off_table" to represent different options
                             and type of curves. 
    Y. S. Sheng  03/18/88  : Include bscmpcvoff.h for defining input 
                             offset options and output curve types.
    Vivian W.Ye  05/12/88  : Initialize and free array of curves 
                             tmp_off_cvs, tran_off_cvs,tmp_arc and lines.
    D. Breden    07/20/88  : Return with *rc=BSINARG if input number of 
                             curves is less than two. 
                             Free tran_cv_offs[] at wrapup only if they 
                             are output from BScmpcvoff1, not if addresses
                             of other curves had been assigned to them.
    C. S. Kirby  10/17/88  : Remove unnecessary variable.
    S.G. Catron  02/15/89  : Instead of creating a line in between two
                             offset curves, polynomially extend both to
                             intersection.  Also at the end, check to see
                             if all the offset curves are connected
                             properly(call routine BStstcvcnct).
    S.G. Catron  03/14/89  : Don't overwrite the return code after
                             wrapup.
    S.G. Catron  06/07/89  :There was error after the call to BSpolyxcvcv.
                             There was an if statement to check if rc 
                             wasn't successful, but there was no statement
                             to go to wrapup.
    S.G. Catron  07/10/89  : If BSpolyxcvcv extends the two offset curves,
                             then on the next time through loop, that 
                             second curve was not being used as the first
                             curve.
    S. C. Wood   08/02/89  : Initialize num_offcvs and num_loops = 0 before
                             attempting to offset.
    S. C. Wood   08/03/89  : Added code when off_uniform = TRUE (uniform
                             offset distance for all curves), to call new
                             static routine, exttrmBScmpcvoff, if BScvint_trm
                             returns rc = BSNOSOLUTION or degen = 2 to extend
                             one of the offset curves to intersection point, 
                             or generate a line between the two curves.
                             The offset curves and the constructed line, along
                             with their indexes, are returned and stored in 
                             appropriate index of tran_off_cvs and off_table.
    S. C. Wood   08/09/89  : Call BScmpcvoff1 to perform ALL offsets (uniform
                             and non-uniform) instead of having separate
                             code to perform uniform offset.
    S. C. Wood   08/30/89  : If off_uniform = TRUE, set codes and off_dist
                             of all input curves = codes[0] and off_dist[0], 
                             respectively.
    S. C. Wood   09/15/89  : If off_uniform = TRUE, create temporary arrays
                             (tmp_codes, tmp_off_dist).  Set all elements
                             of tmp_codes = codes[0] and all elements of
                             tmp_off_dist = off_dist[0].  Create 2 more
                             pointers (good_codes, good_off_dist).  Set
                             these pointers = tmp_codes and tmp_off_dist
                             if off_uniform = TRUE; otherwise, set = 
                             codes and off_dist.
    S. C. Wood   09/25/89  : Set z-values of input curves (cvs) = 0.0 prior
                             to calling BStstcvdegn to test for degeneracy &
                             reset z-values of input curves back to original
                             values after call to BStstcvdegn to adapt to
                             3-D offsets.
    S. C. Wood   11/14/89  : Added argument for number of curves per loop
                             (numcvs_lp) to argument list. Changed declaration
                             from ***loops to **loops and **loop_table to
                             *loop_table.  Added code to remove loops if
                             rm_loop = TRUE.                             
    S. C. Wood   11/20/89  : Changed name from BScmpcvoff to BScmpcvoffl
                             to perform loop removal if desired.  This
                             routine is now called by BScmpcvoff.
    S. C. Wood   12/07/89  : Changed construction of line in remove loop
                             section to be constructed from a little past the 
                             start parameter (start parameter + knot_tol * 100)
                             of the first curve of the input composite curve 
                             (cvs[0]) to a little past the start parameter of
                             the merged offset curve (tmp_mrg_offcv).  Pre-
                             viously constructed from exact start parameters 
                             and was using new_cvs[0] (transformed to new 
                             coordinates) instead of cvs[0] (original
                             coordinates).
    S. C. Wood   12/12/89  : Normalize knot vector for all loop curves and
                             curves in main part of offset curve.
    S. C. Wood   12/19/89  : Perform x-y transformation on cvs before
                             testing cvs for degeneracy so z-values will
                             be set to 0.0 before testing for degeneracy
                             after cvs are transformed to x-y plane.
    S. C. Wood   01/05/90  : If a loop is contained within one curve, then
                             return only one curve, i.e. after removing loop, 
                             merge the 2 curves back together and reference
                             appropriate curve of input composite curve.
    S. C. Wood   01/17/90  : Initialize each element of off_cvs = NULL.
    S. C. Wood   02/26/89  : When removing loops, only remove loops from
                             main part of curve if BSpreploop returns 
                             num_loop_sets > 0 and generate array of loop
                             curves only if BSpreploop returns num_loops > 0.
                             If offset curve of final curve of composite curve
                             is degenerate, BScv_slfint returns nint = 1
                             but no real loop exists; therefore, BSpreploop
                             returns no loops.
    S. C. Wood   07/17/90  : Normalize knots of off_cvs when removing loops
                             all at one time after for loop. Calculate mid 
                             parameter between last parameter of temp_cvold
                             and first parameter of temp_cvnew and set these
                             parameters to this mid parameter before calling 
                             BSmergecvnn.
    S. C. Wood   09/11/90  : Correct allocation of tmp_off_table -- allocate
                             (2 * num_valid) * sizeof(IGRint).
    S. C. Wood   04/23/91  : Index j was getting incremented in a nested
                             for loop along with getting incremented in 
                             outer loop.  Changed inner for loop to use
                             k instead of j.
    S. C. Wood   06/05/91  : Changed call to BScvsplit from tst_plan to
                             &tst_plan.
    S. C. Wood   02/28/92  : If all offset distances = 0.0, copy input
                             curves into output curves and set other output
                             appropriately then go to wrapup.
                             Move deallocation of tran_off_cvs inside 
                             if (tran_off_cvs).
                             Use BSdealloc instead of BSstackdealloc to
                             deallocate arrays allocated and  returned from
                             BScv_slfint, BScvcvint, and BSpreploop.
    S. C. Wood   07/01/92  : After call to BSmergarrcv to merge shuff_cvs
                             into mrg_shuff_cv, if the 1st or last shuff_cvs
                             is degenerate, check to see if mrg_shuff_cv
                             is closed and set bit appropriately because
                             BSmergarrcv may not set it correctly for these
                             cases.  
                             After call to BScv_slfint, if mrg_shuff_cvs
                             is closed and there exists a self-intersecting
                             point at the start or end of the curve but the
                             associated parameters are not 0.0 and 1.0, remove
                             this point before continuing in loop removal.
    S. C. Wood   06/29/92  : Fixed "pointer reserve" problem in deallocation
                             of tmp_off_cvs2 by incorporating free_tcvs2
                             boolean array.
    S. C. Wood   07/30/93  : Make sure parameter arrays for intersections
                             and overlaps from BScv_slfint are deallocated.
    S. C. Wood   04/26/94  : Deallocate z1_temp.
    D. Breden    01/11/95  : Updated memory requirements for off_cvs ,
                             off_table, numcvs_lp, loops and loop_table
                             and increased allocation of tmp_off_cvs2, 
                             tran_off_cvs, tmp_off_table, and free_tcvs2
                             from 2*num_cvs to (2*num_cvs+1).
    S. C. Wood   06/04/95  : When removing loops (after call to BSpreploop), 
                             do not split the curve (merged offset curves) at 
                             the last loop parameter if this parameter is the 
                             end of the curve. Fix for TR# 9525705.
    S.G. Catron  01/03/96  : In rm_loop code, only call BSmergcvarr
                             if( *num_offcvs > 1 ). cmpcvoffl.d79
    S.G. Catron  08/13/97  : In creating line(con_line) to call BScvcvint with,
                             make sure knot_tol is no smaller than 1.0e-6.
                             Problem arises because SE sets knot_tol=1.0e-10.
                             This does not only us a large enough step, from
                             the end of the curve for BScvcvint to find the
                             intersection away from start/end point. TR 33421.
    S.G. Catron  08/18/99  : When shuffling curves, it calls BScv_slfint and assumes
		                         that there are intersections, which there are not always.
														 So, we need to not call tagsort and use values.
JJ Malosse 20 July 2000: Suppressed #include bscvint_trm.h
    S.G. Catron  08/18/00  : Modified "fillet" argument to add another option.
                             2: if d1 or d2 == 0 then just connect end points
                             else extend to intersection linearly(not polynomially)
*****************************************************************************
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
#include "bsicmpcvoff.h"
#include "bsvalues.h"
#include "bsmemory.h"
#include "bsparameters.h"
#endif
#include <math.h>
#define BSVOID
#define  MAXNUM  100
#define  TRY_NUM 3

void BScmpcvoffl(
IGRint     num_cvs,
struct IGRbsp_curve **cvs,
IGRboolean right_side,
IGRvector  nor_vec,
IGRdouble  *off_dist,
IGRboolean off_uniform,
IGRint     *codes,
IGRboolean fillet,
IGRshort   rm_loop,
IGRboolean closed,
IGRint     *num_offcvs,
struct IGRbsp_curve **off_cvs,
IGRint     *off_table,
IGRint     *num_loops,
IGRint     *numcvs_lp,
struct IGRbsp_curve **loops,
IGRint     *loop_table,     
BSrc       *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bststcvdegn.h"
#include "bstrans2.h"
#include "bscveval.h"
#include "bscmpcvoff1.h"
#include "bsxycvoff.h"
#include "bsofk3arc.h"
#include "bsalloccv.h"
#include "bsmdstptcv.h"
#include "bscvkttol2.h"
#include "bsofrparcv.h"
#include "bsactivsplt.h"
#include "bscv_copy.h"
#include "bszigzag.h"
#include "bscvoton.h"
#include "bscvntoo.h"
#include "bsnorvec.h"
#include "bsnorkts.h"
#include "bsfreecv.h"
#include "bslngen.h"
#include "bscvsplit.h"
#include "bsmerge_cv.h"
#include "bstagsort.h"
#include "bsdistptpts.h"
#include "bspolyxcvcv.h"
#include "bststcvcnct.h"
#include "bsmergarrcv.h"
#include "bscv_slfint.h"
#include "bspreploop.h"
#include "bscvcvint.h"
#include "bsmergecvnn.h"
#endif 

    IGRboolean status = TRUE;
    IGRboolean degn, degen1, degen2;
    IGRint  i,j,k,ii;
    IGRint  num_valid = 0;
    IGRint  *index = NULL, index2[MAXNUM];
    IGRint  *tmp_codes = NULL, tmp_codes2[MAXNUM];
    IGRdouble  *tmp_off_dist = NULL, tmp_off_dist2[MAXNUM];
    IGRdouble  dist_tol, dist_sqtol, sq_dist;
    IGRlong    npoles;
    IGRint  *good_codes = NULL;
    IGRdouble  *good_off_dist = NULL;
    IGRboolean  alloc_index = FALSE;
    IGRboolean  alloc_tmp_codes = FALSE, alloc_tmp_off_dist = FALSE;
    IGRint  sign;
    IGRpoint pzero;
    IGRvector normal;
    IGRdouble tmat[3][3];
    IGRdouble s = 1.0;
    struct IGRbsp_curve **new_cvs = NULL, 
                        **tnew_cvs = NULL,  
                        **tmp_off_cvs2 = NULL,
                        **tran_off_cvs = NULL,
                        *tmp_mrg_offcv = NULL, **shuff_cvs = NULL, 
                        *mrg_shuff_cv = NULL, *new_offcv0 = NULL, *t_cv = NULL,
                        *temp_cvnew = NULL, *temp_cvold = NULL;
    BSrc   rc1 = BSSUCC;
    IGRint  *ordgaprev=NULL, aordgaprev[MAXNUM*3], numpts;
    IGRpoint *pts=NULL, apts[MAXNUM];
    IGRlong   max_poles;
    IGRdouble *z1_temp = NULL, z1_temp2[MAXNUM];
    IGRint    numint, nover;
    IGRdouble *a_par = NULL, *b_par = NULL;
    IGRdouble *c_over = NULL, *d_over = NULL, *e_over = NULL, *f_over = NULL;
    IGRint    num_loop_sets;
    IGRdouble *set_pars = NULL, *loop_pars = NULL;
    IGRint    *nloop_pars = NULL;
    IGRint    num, p1, p2, p3, p4, prev_par, par_index;
    IGRdouble ratio1, ratio2, ratio3, ratio4;
    IGRboolean tst_plan = FALSE;
    IGRint     tmp_numoffcvs, old_numoffcvs = 0;
    IGRboolean cvsplit = FALSE,  
               *free_tcvs2=NULL, free_tcvs2_2[MAXNUM], alloc_free_tcvs2=FALSE;
    IGRdouble  new_par0, par;
    IGRint     int_new_par0;
    IGRint     num_deriv, type;
    IGRpoint   eval_cv[1], eval_off[1];
    struct
      IGRbsp_curve *con_line = NULL;
    IGRint     num_alloc_int, num_alloc_over;
    IGRpoint   int_pts[10], *xint_pts = NULL;
    IGRpoint   over_pts[10], *xover_pts = NULL;
    IGRdouble  par0[10], par1[10], *xpar0 = NULL, *xpar1 = NULL;
    IGRdouble  over0[20], over1[20], *xover0 = NULL, *xover1 = NULL;
    IGRboolean out_pt_alloc = FALSE, out_over_alloc = FALSE;
    IGRboolean shuffle = FALSE, cpy_cvs;
    IGRboolean alloc_tmp_pars = FALSE, alloc_ind = FALSE, alloc_z1_temp=FALSE;
    IGRint     num_values, *ind = NULL, ind2[MAXNUM];
    IGRdouble  *tmp_pars = NULL, tmp_pars2[MAXNUM];
    IGRlong    num_poles;
    IGRshort   order;
    IGRboolean rational;
    IGRint     *tmp_off_table = NULL, tmp_off_table2[MAXNUM];
    IGRboolean alloc_tmp_off_table = FALSE;
    IGRdouble  knot_tol, mid_par;

    *rc = BSSUCC;
    *num_loops = 0;

    for (i = 0; i < 2 * num_cvs +1; ++i)
    {
        off_cvs[i] = NULL;
    }
   
    if (num_cvs < 2)
    {
	*rc = BSINARG;
	goto wrapup;
    }


    /* If all offset distances = 0.0 (< dist_tol), copy input curves
       into output curves and goto wrapup. */

    BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);
    BSEXTRACTPAR(rc,BSTOLSQLENVEC,dist_sqtol);

    cpy_cvs = TRUE;
    i = 0; 
    if (!off_uniform)
    {
       while (i < num_cvs && cpy_cvs)  
       {
          if (off_dist[i] > dist_tol)
             cpy_cvs = FALSE;
          ++i;
       }
    }

    if ((off_uniform && off_dist[0] < dist_tol) || (!off_uniform && cpy_cvs))
    {
       for (i = 0; i < num_cvs; ++i)
       {
           BSalloccv(cvs[i]->order, cvs[i]->num_poles, cvs[i]->rational, 0, 
                     &off_cvs[i], rc);
           if(BSERROR(*rc)) 
             goto wrapup;

           status = BScv_copy(rc, cvs[i], off_cvs[i]);
           if(! status) 
              goto wrapup;

           off_table[i] = i;
       }

       *num_offcvs = num_cvs;
       *num_loops = 0;

       goto wrapup;
    }

    

    /*  Continue offset if any offset distance > dist_tol */
    if(right_side)
    {
       sign = 1;
    }
    else
    {
       sign = -1;
    }    

    /**-----------------------------------------
       Find the transformation matrix for cvs
    ------------------------------------------**/

    BStrans2(nor_vec, TRUE, tmat, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    normal[0] = 0.0;  /** transformed normal **/
    normal[1] = 0.0;
    normal[2] = 1.0;

    /**-------------------------------------------------------------
       Transform cvs to tnew_cvs using normal as z-axis for the new 
       coordinate system
    ---------------------------------------------------------------**/

    tnew_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)
                      (num_cvs * sizeof(struct IGRbsp_curve *)));
    if(! tnew_cvs)
    {
       *rc = BSNOMEMORY;
       goto wrapup;
    }

    for (i = 0; i < num_cvs; ++i)
    {
      tnew_cvs[i] = NULL;
    }

    tmp_off_cvs2 = (struct IGRbsp_curve **)BSstackalloc((unsigned)
                   ((2 * num_cvs +1) * sizeof(struct IGRbsp_curve *)));
    if(! tmp_off_cvs2)
    {
       *rc = BSNOMEMORY;
       goto wrapup;
    }

    if (num_cvs*2 > MAXNUM)
    {
       free_tcvs2 = (IGRboolean *)BSstackalloc((unsigned)((2 * num_cvs +1) * 
                        sizeof(IGRboolean)));
       if(! free_tcvs2)
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_free_tcvs2 = TRUE;
    }
    else
    {
       free_tcvs2 = free_tcvs2_2;
    }

    for (i = 0; i < (2 * num_cvs +1); ++i)
    {
      tmp_off_cvs2[i] = NULL;
      free_tcvs2[i] = FALSE;
    }

    pzero[0] = 0.0;
    pzero[1] = 0.0;
    pzero[2] = 0.0;

    for(i=0; i < num_cvs; i++)
    {
       BSalloccv(cvs[i]->order,cvs[i]->num_poles, cvs[i]->rational, 0, 
                 &tnew_cvs[i], rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       status = BScvoton(rc, pzero, tmat, &s, cvs[i], tnew_cvs[i]);
       if(! status) 
         goto wrapup;
    }

   /* Allocate temporary arrays */

    if (num_cvs > MAXNUM)
    {
       index = (IGRint *)BSstackalloc((unsigned)(num_cvs * sizeof(IGRint)));
       if(! index)
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_index = TRUE;
    }
    else
    {
       index = index2;
    }

    if (off_uniform)
    {
       if (num_cvs > MAXNUM)
       {
          tmp_codes = (IGRint *)BSstackalloc((unsigned)
                               (num_cvs * sizeof(IGRint)));
          if(! tmp_codes)
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
          alloc_tmp_codes = TRUE;

          tmp_off_dist = (IGRdouble *)BSstackalloc((unsigned)
                               (num_cvs * sizeof(IGRdouble)));
          if(! tmp_off_dist)
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
          alloc_tmp_off_dist = TRUE;
       }
       else
       {
          tmp_codes = tmp_codes2;
          tmp_off_dist = tmp_off_dist2;
       }
    }

    /**----------------------------------------------------------------------
       Find the indices for non-degenerated curves and if off_uniform = TRUE, 
       set values of tmp_codes and tmp_off_dist 
    -----------------------------------------------------------------------**/

    /* Calculate max_poles for allocation purposes. (08/10/89) */
    max_poles = 0;
    for (i = 0; i < num_cvs; ++i)
    {
        if (tnew_cvs[i]->num_poles > max_poles)
           max_poles = tnew_cvs[i]->num_poles;
    }

    /* Allocate temporary arrays for storing z coordinates of cvs[i].
       (08/10/89) */
    if (max_poles > MAXNUM)
    {
       z1_temp = (IGRdouble *)BSstackalloc((unsigned) 
                     (max_poles * sizeof(IGRdouble)));
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
    num_valid = 0;
    for(i=0; i < num_cvs; i++)
    {
       /* Set z values of poles of tnew_cvs[i]=0.0 for 3-D offset (08/10/89) */
       for (j = 0; j < tnew_cvs[i]->num_poles; ++j)
       {
           z1_temp[j] = tnew_cvs[i]->poles[3 * j + 2];
           tnew_cvs[i]->poles[3 * j + 2] = 0.0;
       }

       BStstcvdegn(tnew_cvs[i], &degn, rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       if(! degn)
       {
           index[num_valid] = i;
           num_valid++;
       }

       /* Reset z-values back to original value. (08/10/89) */
       for (j = 0; j < tnew_cvs[i]->num_poles; ++j)
       {
           tnew_cvs[i]->poles[3 * j + 2] = z1_temp[j];
       }

       /* If off_uniform, set values of tmp_codes and tmp_off_dist = codes[0]
          and off_dist[0], respectively. (09/15/89) */
       if (off_uniform)
       {
          tmp_codes[i] = codes[0];
          tmp_off_dist[i] = off_dist[0];
       }
    }

    /** Initialize num_offcvs and num_loops = 0 **/
    *num_offcvs = 0;
    *num_loops = 0;

    /************************************
     Begin offset
    *************************************/

    tran_off_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)((2 * 
                    num_cvs +1) * sizeof(struct IGRbsp_curve *)));
    if(! tran_off_cvs)
    {
       *rc = BSNOSTKMEMORY;
       goto wrapup;
    }

    for (j = 0; j < 2 * num_cvs +1; ++j)
    {
      tran_off_cvs[j] = NULL;
    }

    if (off_uniform)
    {
       good_codes = tmp_codes;
       good_off_dist = tmp_off_dist;       
    }
    else
    {
       good_codes = codes;
       good_off_dist = off_dist;       
    }

    if ((2* num_valid +1) > MAXNUM)
    {
       tmp_off_table = (IGRint *)BSstackalloc((unsigned)((2 * num_valid+1)
                                 * sizeof(IGRint)));
       if(! tmp_off_table)
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_tmp_off_table = TRUE;
    }
    else
    {
       tmp_off_table = tmp_off_table2;
    }

    new_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)
                      (num_valid * sizeof(struct IGRbsp_curve *)));
    if(! new_cvs)
    {
       *rc = BSNOMEMORY;
       goto wrapup;
    }

    for(i=0; i < num_valid; i++)
    {
       BSalloccv(tnew_cvs[index[i]]->order, tnew_cvs[index[i]]->num_poles, 
                 tnew_cvs[index[i]]->rational, 0, &new_cvs[i], rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       status = BScv_copy(rc, tnew_cvs[index[i]], new_cvs[i]);
       if(! status) 
          goto wrapup;
    }

    BScmpcvoff1(num_valid, new_cvs, good_codes, index, sign, normal, 
                good_off_dist, fillet, closed, num_offcvs, tran_off_cvs, 
                tmp_off_table, rc);
    if(BSERROR(*rc)) 
      goto wrapup;


    old_numoffcvs = *num_offcvs;


    /**-----------------------------------------
       Transform back all the offset curves
    --------------------------------------------**/


    for(i=0; i < *num_offcvs; i++)
    {
       BSalloccv(tran_off_cvs[i]->order,tran_off_cvs[i]->num_poles,
           tran_off_cvs[i]->rational, 0, &tmp_off_cvs2[i], rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       status = BScvntoo(rc, pzero, tmat, &s, tran_off_cvs[i],tmp_off_cvs2[i]);
       if(! status) 
         goto wrapup;

       free_tcvs2[i] = TRUE;
    }  


    /* Allocate more temporary memory */
    shuff_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)
                 ((*num_offcvs + 1) * sizeof(struct IGRbsp_curve *)));
    if(! shuff_cvs)
    {
       *rc = BSNOSTKMEMORY;
       goto wrapup;
    }
    for (i = 0; i < (*num_offcvs + 1); ++i)          
    {
        shuff_cvs[i] = NULL;
    }

    if( *num_offcvs > MAXNUM )
    {
       ordgaprev = (IGRint *)BSstackalloc((unsigned)( *num_offcvs * 3 *
                               sizeof(IGRint)));
       if( !ordgaprev )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       pts = (IGRpoint *)BSstackalloc((unsigned)( *num_offcvs * sizeof
                                                   (IGRpoint)));
       if(! pts )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
    }
    else
    {
       ordgaprev = &aordgaprev[0];
       pts = apts;
    }

    /* Copy tmp_off_table into off_table */
    for (i = 0; i < *num_offcvs; ++i)
    {
        off_table[i] = tmp_off_table[i];
    }

    /* Remove loops if rm_loop == 1 (return array of loops) or rm_loop == 2 
       (do not return array of loops) */
    if (rm_loop == 1 || rm_loop == 2)
    {
       /* Merge curves in composite into temporary curve (tmp_mrg_offcv) and
          find the parameters associated points of self-intersection of
          tmp_mrg_offcv. */

       if( *num_offcvs > 1 )
       {
          BSmergarrcv(*num_offcvs, tmp_off_cvs2, &tmp_mrg_offcv, rc);
          if (BSERROR(*rc))
             goto wrapup;
       }
       else
       {
          /* copy to tmp_mrg_offcv  */
          BSalloccv(tmp_off_cvs2[0]->order, tmp_off_cvs2[0]->num_poles, 
                    tmp_off_cvs2[0]->rational, 0, &tmp_mrg_offcv, rc);
          if(BSERROR(*rc))
             goto wrapup;
          status = BScv_copy(rc, tmp_off_cvs2[0], tmp_mrg_offcv);
          if(! status) 
             goto wrapup;
       }

       int_new_par0 = 0;

        /* If input composite curve is closed, determine if start parameter
           of tmp_mrg_offcv is on part that you want to keep when removing
           loops.  If it is not, shuffle the curve. */
        if (closed)
        {
           BSEXTRACTPAR(rc,BSTOLKNOT,knot_tol);
           if( knot_tol < 1.0e-6 )
             knot_tol = 1.0e-6;
           num_deriv = 0;
           par = cvs[0]->knots[cvs[0]->order - 1] + knot_tol * 100;
           BScveval(cvs[0], par, num_deriv, eval_cv, rc);
           if (BSERROR(*rc))
              goto wrapup;

           par = tmp_mrg_offcv->knots[tmp_mrg_offcv->order - 1] + 
                 knot_tol * 100;    
           BScveval(tmp_mrg_offcv, par, num_deriv, eval_off, rc);
           if (BSERROR(*rc))
              goto wrapup;
            
           BSalloccv(2, 2, FALSE, 0, &con_line, rc);
           if (BSERROR(*rc))
              goto wrapup;

           /* Generate a line connecting points on tmp_off_cvs2[0] and 
              tmp_mrg_offcv associated with the start parameter */
           status = BSlngen(rc, eval_cv[0], eval_off[0], con_line, &type);
           if (BSERROR(*rc))
              goto wrapup;
    
           num_alloc_int = 10;
           num_alloc_over = 10;


           /* If the constructed line intersects tmp_mrg_offcv more than once
              and these intersections are not the desired start and end points
              of tmp_mrg_offcv, shuffle the curve */

           BScvcvint(con_line, tmp_mrg_offcv, FALSE, num_alloc_int, 
                     num_alloc_over, int_pts, par0, par1, over_pts, over0,
                     over1, &numint, &nover, &out_pt_alloc, &out_over_alloc,
                     &xint_pts, &xpar0, &xpar1, &xover_pts, &xover0, &xover1,
                     rc);
           if (BSERROR(*rc))
              goto wrapup;

           if (numint > 1)
           {
              if (numint == 2)
              {
                 if (! out_pt_alloc)
                 {
                    /* If tmp_mrg_offcv is closed, and par = start parameter of
                       tmp_mrg_offcv, BScvcvint will return 2 intersection
                       points for con_line and tmp_mrg_offcv -- the start AND
                       end  point of tmp_off_cv. */
                    if (par1[0] == tmp_mrg_offcv->knots[tmp_mrg_offcv->order-1]
                          && par1[numint-1] == 
                              tmp_mrg_offcv->knots[tmp_mrg_offcv->num_poles])
                    {
                        shuffle = FALSE;
                    }
                    else
                    {
                       shuffle = TRUE;
                    }
                 }
                 else
                 {
                    if(xpar1[0] == tmp_mrg_offcv->knots[tmp_mrg_offcv->order-1]
                       && xpar1[numint-1] == 
                            tmp_mrg_offcv->knots[tmp_mrg_offcv->num_poles])
                    {
                        shuffle = FALSE;
                    }
                    else
                    {
                       shuffle = TRUE;
                    }
                 }
              }
              else
              {
                 shuffle = TRUE;
              }   /* end if (numint == 2) */
           }   /* if (numint > 1) */

           if (off_uniform && off_dist[0] == 0.0)
              shuffle = FALSE;

           if (shuffle)
           {
              /* INCLUDE CODE TO SHUFFLE CURVE !!!!! */
              status = BScv_slfint(rc, tmp_mrg_offcv, &numint, &a_par, &b_par,
                            &nover, &c_over, &d_over, &e_over, &f_over);
              if (BSERROR(*rc))
                 goto wrapup;

              /* Unnormalize the parameters of tmp_mrg_offcv and parameters
                 returned from BScv_slfint */
              for (i = 0; i < tmp_mrg_offcv->num_knots; ++i)
              {
                  tmp_mrg_offcv->knots[i] = tmp_mrg_offcv->knots[i] * 
                                               (*num_offcvs);
              }

              for (i = 0; i < numint; ++i)   
              {
                  a_par[i] = a_par[i] * (*num_offcvs);
                  b_par[i] = b_par[i] * (*num_offcvs);
              }

              for (i = 0; i < nover; ++i)
              {
                  c_over[i] = c_over[i] * (*num_offcvs);
                  d_over[i] = d_over[i] * (*num_offcvs);
                  e_over[i] = e_over[i] * (*num_offcvs);
                  f_over[i] = f_over[i] * (*num_offcvs);
              }

              if ((numint * 2) > MAXNUM)
              {
                 tmp_pars = (IGRdouble *)BSstackalloc((unsigned)
                                (numint * 2) * sizeof(IGRdouble));
                 if (! tmp_pars)
                 {
                    *rc = BSNOSTKMEMORY;
                    goto wrapup;
                 }
                 alloc_tmp_pars = TRUE;

                 ind = (IGRint *)BSstackalloc((unsigned)(numint*2) * 
                           sizeof(IGRint));
                 if (! ind)
                 {
                    *rc = BSNOSTKMEMORY;
                    goto wrapup;
                 }
                 alloc_ind = TRUE;
              }
              else
              {
                 tmp_pars = tmp_pars2;
                 ind = ind2;
              }

              /* Create array containing all intersection parameters and
                 sort */
              i = 0;
              j = 0;
              while (i < (numint * 2))
              {
                  tmp_pars[i] = a_par[j];
                  tmp_pars[i + 1] = b_par[j];
                  j = j + 1;
                  i = i + 2;
              }
              num_values = numint * 2;
              /* Deallocate arrays returned from BScv_slfint */
              if (a_par)
              {
                 BSdealloc((char *) a_par);
                 a_par = NULL;
              }
              if (b_par)
              {
                 BSdealloc((char *) b_par);
                 b_par = NULL;
              }
              if (c_over)
              {
                 BSdealloc((char *) c_over);
                 c_over = NULL;
              }
              if (d_over)
              {
                 BSdealloc((char *) d_over);
                 d_over = NULL;
              }
              if (e_over)
              {
                 BSdealloc((char *) e_over);
                 e_over = NULL;
              }
              if (f_over)
              {
                 BSdealloc((char *) f_over);
                 f_over = NULL;
              }
							new_par0 = 0.0;
              if (num_values > 0)
              {
                status = BStagsort(rc, &num_values, tmp_pars, ind);
                if (BSERROR(*rc))
                   goto wrapup;
              /* Calculate new start parameter at which the shuffled 
                 composite curve is to start */
                new_par0 = (tmp_pars[ind[0]] + tmp_pars[ind[1]]) / 2;
              }
							int_new_par0 = (IGRint)new_par0;


              /* If the start parameter of the 1st curve of the composite
                 offset (tmp_off_cvs2[0]) < new_par0 AND the end parameter
                 tmp_off_cvs2[0] > new_par0, split tmp_off_cvs2[0] at
                 new_par0 and shuffle appropriately, maintaining the left
                 portion of the split curve as the 1st curve of the shuffled
                 curves (shuff_cvs[0]). */

              if ((tmp_off_cvs2[0]->knots[tmp_off_cvs2[0]->order - 1] < 
                   new_par0) &&
                  (tmp_off_cvs2[0]->knots[tmp_off_cvs2[0]->num_poles] >
                   new_par0))
              {
                 cvsplit = TRUE;
                 BSalloccv(tmp_off_cvs2[0]->order,tmp_off_cvs2[0]->
                           num_poles, tmp_off_cvs2[0]->rational, 0, 
                           &shuff_cvs[*num_offcvs], rc);
                 if(BSERROR(*rc)) 
                    goto wrapup;

                 BSalloccv(tmp_off_cvs2[0]->order,tmp_off_cvs2[0]->
                           num_poles, tmp_off_cvs2[0]->rational, 0, 
                           &shuff_cvs[0], rc);
                 if(BSERROR(*rc)) 
                    goto wrapup;

                 /* Split tmp_off_cvs2[0] at new_par0 */
                 status = BScvsplit(rc, tmp_off_cvs2[0], &new_par0, 
                            shuff_cvs[*num_offcvs], shuff_cvs[0], &tst_plan);
                 if(BSERROR(*rc)) 
                    goto wrapup;

                 /* Normalize the knot vectors of shuff_cvs[*num_offcvs]
                    and shuff_cvs[0] */
                 status = BSnorkts(rc, &shuff_cvs[*num_offcvs]->order, 
                                   &shuff_cvs[*num_offcvs]->num_poles, 
                                   shuff_cvs[*num_offcvs]->knots);
                 if(BSERROR(*rc)) 
                    goto wrapup;

                 status = BSnorkts(rc, &shuff_cvs[0]->order, &shuff_cvs[0]->
                                   num_poles, shuff_cvs[0]->knots);
                 if(BSERROR(*rc)) 
                    goto wrapup;

                 /* Store tmp_off_cvs2 into appropriate shuff_cvs */
                 BSMEMCPY((*num_offcvs - 1) * sizeof(struct IGRbsp_curve *),
                          (IGRchar *)&tmp_off_cvs2[1],
                          (IGRchar *)&shuff_cvs[1]);
                 for (i = 1; i < *num_offcvs; ++i)
                     free_tcvs2[i] = FALSE;

                 /* Merge array of curves (shuff_cvs) into mrg_shuff_cv */
                 num = *num_offcvs + 1;
                 BSmergarrcv(num, shuff_cvs, &mrg_shuff_cv, rc);
                 if (BSERROR(*rc))
                    goto wrapup;

                 /* If shuff_cvs[0] or shuff_cvs[num-1] is degenerate, check
                    if mrg_shuff_cv is closed because it may not be set
                    correctly inside BSmergarrcv (BScomb2cvs). */     
                 BStstcvdegn(shuff_cvs[0], &degen1, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 BStstcvdegn(shuff_cvs[num-1], &degen2, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 if (degen1 || degen2)
                 {
                    npoles = mrg_shuff_cv->num_poles;
                    if (mrg_shuff_cv->rational)
                    {
                       for (i = 0; i < 3; ++i)
                       {
                           sq_dist = (mrg_shuff_cv->poles[(npoles - 1)*3+i] /
                                       mrg_shuff_cv->weights[npoles-1] - 
                                     mrg_shuff_cv->poles[i] / 
                                       mrg_shuff_cv->weights[0]) *
                                     (mrg_shuff_cv->poles[(npoles - 1)*3+i] /
                                       mrg_shuff_cv->weights[npoles-1] - 
                                     mrg_shuff_cv->poles[i] / 
                                       mrg_shuff_cv->weights[0]);
                       }
                    }
                    else
                    {
                       for (i = 0; i < 3; ++i)
                       {
                           sq_dist = (mrg_shuff_cv->poles
                                      [(mrg_shuff_cv->num_poles - 1)*3+i] - 
                                     mrg_shuff_cv->poles[i]) *
                                     (mrg_shuff_cv->poles
                                      [(mrg_shuff_cv->num_poles - 1)*3+i] - 
                                     mrg_shuff_cv->poles[i]);
                       }
                    }
                  
                    if (sq_dist < dist_sqtol)
                       mrg_shuff_cv->phy_closed = TRUE;
                 }
              }
              else   
              {
                 /* If int_new_par0 == 0, set int_new_par0 = 1 to indicate
                    that tmp_off_cvs2[1] begins within the loop that is NOT
                    to be removed */
                 if (int_new_par0 == 0)
                 {
                    int_new_par0 = 1;
                 }
 
                 cvsplit = FALSE;

                 /* Store tmp_off_cvs2 into appropriate shuff_cvs */
                 BSMEMCPY((*num_offcvs - int_new_par0) *
                          sizeof (struct IGRbsp_curve *), 
                          (IGRchar *) &tmp_off_cvs2[int_new_par0],
                          (IGRchar *) &shuff_cvs[0]);
                 for (i = int_new_par0; i < *num_offcvs; ++i)
                     free_tcvs2[i] = FALSE;
 
                 BSMEMCPY((int_new_par0) * sizeof(struct IGRbsp_curve *), 
                         (IGRchar *) &tmp_off_cvs2[0],
                         (IGRchar *) &shuff_cvs[(*num_offcvs - int_new_par0)]);
                 for (i = 0; i < int_new_par0; ++i)
                     free_tcvs2[i] = FALSE;

                 /* Merge array of curves (shuff_cvs) into mrg_shuff_cv */
                 num = *num_offcvs;
                 BSmergarrcv(num, shuff_cvs, &mrg_shuff_cv, rc);
                 if (BSERROR(*rc))
                    goto wrapup;

                 /* If shuff_cvs[0] or shuff_cvs[num-1] is degenerate, check
                    if mrg_shuff_cv is closed because it may not be set
                    correctly inside BSmergarrcv (BScomb2cvs). */     
                 BStstcvdegn(shuff_cvs[0], &degen1, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 BStstcvdegn(shuff_cvs[num-1], &degen2, rc);
                 if(BSERROR(*rc)) 
                   goto wrapup;

                 if (degen1 || degen2)
                 {
                    npoles = mrg_shuff_cv->num_poles;
                    if (mrg_shuff_cv->rational)
                    {
                       for (i = 0; i < 3; ++i)
                       {
                           sq_dist = (mrg_shuff_cv->poles[(npoles - 1)*3+i] /
                                       mrg_shuff_cv->weights[npoles-1] - 
                                     mrg_shuff_cv->poles[i] / 
                                       mrg_shuff_cv->weights[0]) *
                                     (mrg_shuff_cv->poles[(npoles - 1)*3+i] /
                                       mrg_shuff_cv->weights[npoles-1] - 
                                     mrg_shuff_cv->poles[i] / 
                                       mrg_shuff_cv->weights[0]);
                       }
                    }
                    else
                    {
                       for (i = 0; i < 3; ++i)
                       {
                           sq_dist = (mrg_shuff_cv->poles
                                      [(mrg_shuff_cv->num_poles - 1)*3+i] - 
                                     mrg_shuff_cv->poles[i]) *
                                     (mrg_shuff_cv->poles
                                      [(mrg_shuff_cv->num_poles - 1)*3+i] - 
                                     mrg_shuff_cv->poles[i]);
                       }
                    }
                  
                    if (sq_dist < dist_sqtol)
                       mrg_shuff_cv->phy_closed = TRUE;

                 }   /* end if (degen1 || degen2) */
              }   /* end if (int_new_par0 == 0) */
           }

           else   /* if (shuffle) */
           {
              /* Do not shuffle -- just copy tmp_off_cvs2 into shuff_cvs
                 and tmp_mrg_offcv into mrg_shuff_cv */

              if (a_par)
              {
                 BSdealloc((char *) a_par);
                 a_par = NULL;
              }
              if (b_par)
              {
                 BSdealloc((char *) b_par);
                 b_par = NULL;
              }
              if (c_over)
              {
                 BSdealloc((char *) c_over);
                 c_over = NULL;
              }
              if (d_over)
              {
                 BSdealloc((char *) d_over);
                 d_over = NULL;
              }
              if (e_over)
              {
                 BSdealloc((char *) e_over);
                 e_over = NULL;
              }
              if (f_over)
              {
                 BSdealloc((char *) f_over);
                 f_over = NULL;
              }

              for (i = 0; i < *num_offcvs; ++i)
              {
                  BSalloccv(tmp_off_cvs2[i]->order, tmp_off_cvs2[i]->
                            num_poles, tmp_off_cvs2[i]->rational, 0, 
                            &shuff_cvs[i], rc);
                  if(BSERROR(*rc))
                     goto wrapup;

                  status = BScv_copy(rc, tmp_off_cvs2[i], shuff_cvs[i]);
                  if(! status) 
                     goto wrapup;
              }

              BSalloccv(tmp_mrg_offcv->order, tmp_mrg_offcv->num_poles, 
                        tmp_mrg_offcv->rational, 0, &mrg_shuff_cv, rc);
              if(BSERROR(*rc))
                 goto wrapup;

              status = BScv_copy(rc, tmp_mrg_offcv, mrg_shuff_cv);
              if(! status) 
                 goto wrapup;

           }   /* end if (shuffle) */

        }
        else
        {
           /* If input composite curve is NOT closed, no shuffling of curves
              is necessary; therefore, just copy tmp_off_cvs2 into shuff_cvs
              and tmp_mrg_offcv into mrg_shuff_cv */

           for (i = 0; i < *num_offcvs; ++i)
           {
               BSalloccv(tmp_off_cvs2[i]->order, tmp_off_cvs2[i]->
                         num_poles, tmp_off_cvs2[i]->rational, 0, 
                         &shuff_cvs[i], rc);
               if(BSERROR(*rc))
                  goto wrapup;

               status = BScv_copy(rc, tmp_off_cvs2[i], shuff_cvs[i]);
               if(! status) 
                  goto wrapup;
           }

           BSalloccv(tmp_mrg_offcv->order, tmp_mrg_offcv->num_poles, 
                     tmp_mrg_offcv->rational, 0, &mrg_shuff_cv, rc);
           if(BSERROR(*rc))
              goto wrapup;

           status = BScv_copy(rc, tmp_mrg_offcv, mrg_shuff_cv);
           if(! status) 
              goto wrapup;

        }   /* end if (closed) */

        status = BScv_slfint(rc, mrg_shuff_cv, &numint, &a_par, &b_par,
                             &nover, &c_over, &d_over, &e_over, &f_over);
        if (BSERROR(*rc))
           goto wrapup;

        /* If numint > 0, mrg_shuff_cv contains loops -> Remove
           appropriate loops */
        if (numint > 0 || (mrg_shuff_cv->phy_closed && numint > 1))
        {
           /* If mrg_shuff_cv is closed and a_par[0] = 0.0 but b_par[0] != 1.0
              or b_par[0] = 1.0 and a_par[0] != 0.0, remove these parameters
              a_par and b_par. */
           if (mrg_shuff_cv->phy_closed &&
               (a_par[0] == 0.0 && b_par[0] != 1.0) ||
               (a_par[0] != 0.0 && b_par[0] == 1.0))
           {
               --numint;
               BSMEMCPY(numint * sizeof(IGRdouble), (IGRchar *) &a_par[1],
                          (IGRchar *) &a_par[0]);

               BSMEMCPY(numint * sizeof(IGRdouble), (IGRchar *) &b_par[1],
                          (IGRchar *) &b_par[0]);
           }

           /* Unnormalize parameters of mrg_shuff_cv and parameters returned 
              from BScv_slfint */
           if (cvsplit)
           {
              tmp_numoffcvs = *num_offcvs + 1;
           }
           else
           {
              tmp_numoffcvs = *num_offcvs;
           }

           for (i = 0; i < mrg_shuff_cv->num_knots; ++i)
           {
               mrg_shuff_cv->knots[i] = mrg_shuff_cv->knots[i] * tmp_numoffcvs;
           }
 
           for (i = 0; i < numint; ++i)   
           {
               a_par[i] = a_par[i] * tmp_numoffcvs;
               b_par[i] = b_par[i] * tmp_numoffcvs;
           }

           for (i = 0; i < nover; ++i)
           {
               c_over[i] = c_over[i] * tmp_numoffcvs;
               d_over[i] = d_over[i] * tmp_numoffcvs;
               e_over[i] = e_over[i] * tmp_numoffcvs;
               f_over[i] = f_over[i] * tmp_numoffcvs;
           }

           /* Call BSpreploop to return the number of loop curves that are NOT
              removed (num_loops) and the parameters defining these loop curves
              (loop_pars). */
           BSpreploop(rc, mrg_shuff_cv, &numint, a_par, b_par, &nover, c_over,
                      d_over, e_over, f_over, &num_loop_sets, &set_pars,
                      num_loops, &nloop_pars, &loop_pars);
           if (BSERROR(*rc))
              goto wrapup;

           /* Deallocate arrays returned from BScv_slfint */
           if (a_par)
           {
              BSdealloc((char *) a_par);
              a_par = NULL;
           }
           if (b_par)
           {
              BSdealloc((char *) b_par);
              b_par = NULL;
           }
           if (c_over)
           {
              BSdealloc((char *) c_over);
              c_over = NULL;
           }
           if (d_over)
           {
              BSdealloc((char *) d_over);
              d_over = NULL;
           }
           if (e_over)
           {
              BSdealloc((char *) e_over);
              e_over = NULL;
           }
           if (f_over)
           {
              BSdealloc((char *) f_over);
              f_over = NULL;
           }

          /* If rm_loop == 1, build numcvs_lp, loops, and loop_table arrays */
          if (rm_loop == 1 && *num_loops > 0)
          {
             par_index = 0;
             j = 0;
             for (i = 0; i < *num_loops; ++i)
             {
                 numcvs_lp[i] = 0;
                 if (nloop_pars[i] == 2)
                 {
                    p1 = (IGRint)loop_pars[par_index];
                    p2 = (IGRint)loop_pars[par_index + 1];
   
                    /* Translate parameters */
                    ratio1 = shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1] +
                             (loop_pars[par_index] - p1) *
                             (shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles] -
                              shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1]);

                    ratio2 = shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1] +
                             (loop_pars[par_index + 1] - p2) *
                             (shuff_cvs[p2]->knots[shuff_cvs[p2]->num_poles] -
                              shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1]);
 
                    if (p1 == p2)  /* on same curve in shuff_cvs */
                    {
                       numcvs_lp[i] = numcvs_lp[i] + 1;

                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                          goto wrapup;
             
                       status = BSactivsplt(rc, shuff_cvs[p1], &ratio1,
                                            &ratio2, loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;
       
                       if (p1 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p1] is associated with a curve that was
                             originally at the beginning of composite offset
                             curve, but due to shifting is now at the end */

                          loop_table[j] = 
                               tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p1 + int_new_par0];
                       }
                       j = j + 1;
                    }
                    else
                    {
                       numcvs_lp[i] = numcvs_lp[i] + (p2 - p1 + 1);
   
                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;
   
                       status = BSactivsplt(rc, shuff_cvs[p1], &ratio1,
                                       &shuff_cvs[p1]->knots[shuff_cvs[p1]->
                                       num_poles], loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;
                
                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p1 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p1] is associated with a curve that was
                             originally at the beginning of composite offset
                             curve, but due to shifting is now at the end */

                          loop_table[j] = 
                               tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p1 + int_new_par0];
                       }
                       j = j + 1;
  
                       for (ii = 0; ii < (numcvs_lp[i] - 2); ++ii)
                       {
                           BSalloccv(shuff_cvs[p1+ii+1]->order,
                                   shuff_cvs[p1+ii+1]->num_poles, 
                                   shuff_cvs[p1+ii+1]->rational, 0, &loops[j], 
                                   rc);
                           if(BSERROR(*rc)) 
                             goto wrapup;
   
                           status = BScv_copy(rc,shuff_cvs[p1+ii+1],loops[j]);
                           if(BSERROR(*rc)) 
                             goto wrapup;
                
                           if ((p1 + ii + 1) >= (*num_offcvs - int_new_par0))
                           {
                              /* Shuff_cvs[p1+ii+1] is associated with curve 
                                 that was originally at the beginning of the 
                                 composite offset curve, but due to shifting 
                                 is now at the end */

                              loop_table[j] = tmp_off_table[p1+ii+1 - 
                                                 (*num_offcvs-int_new_par0)];
                           }
                           else
                           {
                              loop_table[j] = tmp_off_table[p1+ii+1 + 
                                                            int_new_par0];
                           }
                             j = j + 1;
                       }   /* end for ii loop */
   
                       BSalloccv(shuff_cvs[p2]->order,shuff_cvs[p2]->num_poles,
                                 shuff_cvs[p2]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSactivsplt(rc, shuff_cvs[p2], &shuff_cvs[p2]->
                                      knots[shuff_cvs[p2]->order - 1], &ratio2,
                                      loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p2 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p2] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the
                             end */
  
                          loop_table[j] = 
                               tmp_off_table[p2 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p2 + int_new_par0];
                       }
                       j = j + 1;

                    }   /* end if (p1 == p2) */
 
                    par_index = par_index + 2;

                 }   /* else if (nloop_pars[i] == 2) */
                 else
                 {
                    /* nloop_pars[i] == 4 */
 
                    p1 = (IGRint)loop_pars[par_index];
                    p2 = (IGRint)loop_pars[par_index + 1];
                    p3 = (IGRint)loop_pars[par_index + 2];
                    p4 = (IGRint)loop_pars[par_index + 3];

                    /* Translate parameters */
                    ratio1 = shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1] +
                             (loop_pars[par_index] - p1) *
                             (shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles] -
                              shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1]);
 
                    ratio2 = shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1] +
                             (loop_pars[par_index + 1] - p2) *
                             (shuff_cvs[p2]->knots[shuff_cvs[p2]->num_poles] -
                             shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1]);
  
                    ratio3 = shuff_cvs[p3]->knots[shuff_cvs[p3]->order - 1] +
                             (loop_pars[par_index + 2] - p3) *
                             (shuff_cvs[p3]->knots[shuff_cvs[p3]->num_poles] -
                              shuff_cvs[p3]->knots[shuff_cvs[p3]->order - 1]);

                    ratio4 = shuff_cvs[p4]->knots[shuff_cvs[p4]->order - 1] +
                             (loop_pars[par_index + 3] - p4) *
                             (shuff_cvs[p4]->knots[shuff_cvs[p4]->num_poles] -
                              shuff_cvs[p4]->knots[shuff_cvs[p4]->order - 1]);

                    if (p1 == p2)
                    {
                       numcvs_lp[i] = numcvs_lp[i] + 1;
 
                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, 
                                            &ratio2, loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p1 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p1] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the 
                             end*/

                          loop_table[j] = 
                               tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p1 + int_new_par0];
                       }
                       j = j + 1;
                    }
                    else
                    {
                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, 
                                    &shuff_cvs[p1]->knots[shuff_cvs[p1]->
                                    num_poles], loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p1 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p1] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the
                             end*/
   
                          loop_table[j] = 
                               tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p1 + int_new_par0];
                       }
                       j = j + 1;

                       num = p2 - p1 + 1;
                       numcvs_lp[i] = numcvs_lp[i] + num;
 
                       for (ii = 0; ii < (num - 2); ++ii)
                       {
                           BSalloccv(shuff_cvs[p1+ii+1]->order, shuff_cvs
                                     [p1+ii+1]->num_poles, shuff_cvs[p1+ii+1]->
                                     rational, 0, &loops[j], rc);
                           if(BSERROR(*rc)) 
                             goto wrapup;

                           status = BScv_copy(rc,shuff_cvs[p1+ii+1],loops[j]);
                           if(BSERROR(*rc)) 
                             goto wrapup;

                           if ((p1 + ii + 1) >= (*num_offcvs - int_new_par0))
                           {
                              /* Shuff_cvs[p1+ii+1] is associated with curve 
                                 that was originally at the beginning of the
                                 composite offset curve, but due to shifting
                                 is now at the end */

                              loop_table[j] = tmp_off_table[p1+ii+1 - 
                                                 (*num_offcvs-int_new_par0)];
                           }
                           else
                           {
                              loop_table[j] = tmp_off_table[p1+ii+1 + 
                                                            int_new_par0];
                           }
                           j = j + 1;
                       }
    
                       BSalloccv(shuff_cvs[p2]->order,shuff_cvs[p2]->num_poles,
                                 shuff_cvs[p2]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;
   
                       status = BSactivsplt(rc, shuff_cvs[p2], &shuff_cvs[p2]->
                                      knots[shuff_cvs[p2]->order - 1], &ratio2,
                                      loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;
 
                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p2 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p2] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the 
                             end */

                          loop_table[j] = 
                               tmp_off_table[p2 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p2 + int_new_par0];
                       }
                       j = j + 1;

                    }   /* end if (p1 == p2) */

                    if (p3 == p4)
                    {
                       numcvs_lp[i] = numcvs_lp[i] + 1;

                       BSalloccv(shuff_cvs[p3]->order,shuff_cvs[p3]->num_poles,
                                 shuff_cvs[p3]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSactivsplt(rc, shuff_cvs[p3], &ratio3,
                                            &ratio4, loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p3 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p3] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the 
                             end */

                          loop_table[j] = 
                               tmp_off_table[p3 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p3 + int_new_par0];
                       }
                       j = j + 1;
                    }
                    else
                    {
                       BSalloccv(shuff_cvs[p3]->order,shuff_cvs[p3]->num_poles,
                                 shuff_cvs[p3]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;
 
                       status = BSactivsplt(rc, shuff_cvs[p3], &ratio3,
                                        &shuff_cvs[p3]->knots[shuff_cvs[p3]->
                                        num_poles], loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p3 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p3] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the 
                             end */

                          loop_table[j] =
                               tmp_off_table[p3 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p3 + int_new_par0];
                       }
                       j = j + 1;

                       num = p4 - p3 + 1;
                       numcvs_lp[i] = numcvs_lp[i] + num;
 
                       for (ii = 0; ii < (num - 2); ++ii)
                       {
                           BSalloccv(shuff_cvs[p3+ii+1]->order, shuff_cvs
                                     [p3+ii+1]->num_poles, shuff_cvs[p3+ii+1]->
                                     rational, 0, &loops[j], rc);
                           if(BSERROR(*rc)) 
                             goto wrapup;

                           status = BScv_copy(rc,shuff_cvs[p3+ii+1],loops[j]);
                           if(BSERROR(*rc)) 
                             goto wrapup;

                           if ((p3 + ii + 1) >= (*num_offcvs - int_new_par0))
                           {
                              /* Shuff_cvs[p3+ii+1] is associated with curve
                                 that was originally at the beginning of the 
                                 composite offset curve, but due to shifting 
                                 is now at the end */
  
                              loop_table[j] = tmp_off_table[p3+ii+1 - 
                                                 (*num_offcvs-int_new_par0)];
                           }
                           else
                           {
                              loop_table[j] = tmp_off_table[p3+ii+1 + 
                                                            int_new_par0];
                           }
                           j = j + 1;
                       }

                       BSalloccv(shuff_cvs[p4]->order,shuff_cvs[p4]->num_poles,
                                 shuff_cvs[p4]->rational, 0, &loops[j], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       status = BSactivsplt(rc, shuff_cvs[p4], &shuff_cvs[p4]->
                                      knots[shuff_cvs[p4]->order - 1], &ratio4,
                                      loops[j], &tst_plan);
                       if(BSERROR(*rc)) 
                         goto wrapup;
   
                       status = BSnorkts(rc, &loops[j]->order, &loops[j]->
                                         num_poles, loops[j]->knots);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       if (p4 >= (*num_offcvs - int_new_par0))
                       {
                          /* Shuff_cvs[p4] is associated with a curve that 
                             was originally at the beginning of the composite
                             offset curve, but due to shifting is now at the 
                             end */

                          loop_table[j] = 
                               tmp_off_table[p4 - (*num_offcvs-int_new_par0)];
                       }
                       else
                       {
                          loop_table[j] = tmp_off_table[p4 + int_new_par0];
                       }
                       j = j + 1;
   
                    }   /* end if (p3 == p4) */
   
                    par_index = par_index + 4;
   
                 }   /* end if (nloop_pars[i] == 2) */
 
             }   /* end for (i = 0; i < *num_loops; ++i) */
          }   /* end if (rm_loop == 1 && *num_loops > 0) */

          /****************************************************************
             Return only main portion of composite curve in off_cvs -- do
             not include any loops in off_cvs!
          ****************************************************************/

          if (num_loop_sets > 0)
          {
             tmp_numoffcvs = 0;
             p1 = (IGRint)set_pars[0];

             /* Copy curves of shuff_cvs that precede the loops into off_cvs */
             for (i = 0; i < p1; ++i)
             {
                BSalloccv(shuff_cvs[i]->order,shuff_cvs[i]->num_poles,
                          shuff_cvs[i]->rational, 0, &off_cvs[i], rc);
                if(BSERROR(*rc)) 
                  goto wrapup;
 
                status = BScv_copy(rc, shuff_cvs[i], off_cvs[i]);
                if(BSERROR(*rc)) 
                   goto wrapup;

                if (i >= (*num_offcvs - int_new_par0))
                {
                   /* Shuff_cvs[i] is associated with a curve that was origi-
                      nally at the beginning of the composite offset curve,
                      but due to shifting is now at the end */

                   off_table[tmp_numoffcvs] = 
                             tmp_off_table[i - (*num_offcvs-int_new_par0)];
                }
                else
                {
                   off_table[tmp_numoffcvs] = tmp_off_table[i + int_new_par0];
                }
                tmp_numoffcvs = tmp_numoffcvs + 1;
             }
   
             ratio1 = shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1] +
                       (set_pars[0] - p1) *
                         (shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles] -
                           shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1]);

             /* Split off left portion of curve at first loop parameter */
             BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles, 
                      shuff_cvs[p1]->rational, 0, &off_cvs[tmp_numoffcvs], rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             status = BSactivsplt(rc, shuff_cvs[p1], &shuff_cvs[p1]->knots
                                  [shuff_cvs[p1]->order - 1], &ratio1, 
                                  off_cvs[tmp_numoffcvs], &tst_plan);
             if(BSERROR(*rc)) 
                goto wrapup;
    
             if (p1 >= (*num_offcvs - int_new_par0))
             {
                /* Shuff_cvs[p1] is associated with a curve that was originally
                   at the beginning of the composite offset curve, but due to 
                   shifting is now at the end */
   
                off_table[tmp_numoffcvs] = 
                          tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
             }
             else
             {
                off_table[tmp_numoffcvs] = tmp_off_table[p1 + int_new_par0];
             }
         
             /* Keep up with previous curve that has been split (prev_par) to 
                remove loops so that the split pieces of the same curve can be
                merged together later. */
             prev_par = p1;
             tmp_numoffcvs = tmp_numoffcvs + 1;      

             j = 1;
             for (i = 1; i < num_loop_sets; ++i)
             {
                 p1 = (IGRint)set_pars[j];
                 p2 = (IGRint)set_pars[j + 1];

                 ratio1 = shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1] +
                           (set_pars[j] - p1) *
                             (shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles] -
                               shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1]);

                 ratio2 = shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1] +
                           (set_pars[j + 1] - p2) *
                             (shuff_cvs[p2]->knots[shuff_cvs[p2]->num_poles] -
                               shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1]);
 

                 if (p1 == p2)
                 {
                    BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->num_poles, 
                              shuff_cvs[p1]->rational, 0, &temp_cvnew, rc);
                    if(BSERROR(*rc)) 
                       goto wrapup;

                    status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, &ratio2, 
                                         temp_cvnew, &tst_plan);
                    if(BSERROR(*rc)) 
                       goto wrapup;
  
                    /* If loop is contained within a single curve, merge the
                       2 split curves together after removing loop. */
                    if (p1 == prev_par)
                    {
                       tmp_numoffcvs = tmp_numoffcvs - 1;
                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &temp_cvold, rc);
                       if(BSERROR(*rc)) 
                          goto wrapup;

                       status = BScv_copy(rc, off_cvs[tmp_numoffcvs], 
                                          temp_cvold);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                          reallocate enough space to handle merged curves. */
                       if (off_cvs[tmp_numoffcvs])
                       {
                          status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                          off_cvs[tmp_numoffcvs] = NULL;
                          if (BSERROR(*rc))
                             goto wrapup;
                       }

                       if (temp_cvold->order == temp_cvnew->order)
                       {
                          order = temp_cvold->order;
                          num_poles = temp_cvold->num_poles + 
                                           temp_cvnew->num_poles - 1;
                       }
                       else
                       {
                          if (temp_cvold->order > temp_cvnew->order)
                          {
                             order = temp_cvold->order;
                             num_poles = temp_cvold->num_poles +  
                                           temp_cvnew->num_poles + 
                                          ((temp_cvnew->num_poles - 
                                           temp_cvnew->order + 2) *
                                          temp_cvold->order-temp_cvnew->order);
                          }
                          else
                          {
                             order = temp_cvnew->order;
                             num_poles = temp_cvnew->num_poles +  
                                          temp_cvold->num_poles + 
                                          ((temp_cvold->num_poles - 
                                           temp_cvold->order + 2) *
                                          temp_cvnew->order-temp_cvold->order);
                          }
                       }
                       if (temp_cvold->rational || temp_cvnew->rational)
                       {
                             rational = TRUE;
                       }
                       else
                       {
                          rational = FALSE;
                       }

                       BSalloccv(order, num_poles, rational, 0, 
                                 &off_cvs[tmp_numoffcvs], rc);
                       if(BSERROR(*rc))   
                          goto wrapup;

                       /* Calculate mid parameter between last parameter
                          of temp_cvold and first parameter of temp_cvnew
                          and set these parameters to this mid parameter
                          before calling BSmergecvnn. */

                       mid_par = (temp_cvold->knots[temp_cvold->num_poles]
                                 + temp_cvnew->knots[temp_cvnew->order-1] ) /
                                 2.0;

                       for (k = 0; k < temp_cvold->order; ++k)
                           temp_cvold->knots[temp_cvold->num_poles + k] = 
                             mid_par;

                       for (k = 0; k < temp_cvnew->order; ++k)  
                           temp_cvnew->knots[k] = mid_par;

                       BSmergecvnn(temp_cvold, temp_cvnew, 
                                   off_cvs[tmp_numoffcvs], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;
                    }
                    else
                    {
                       /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                          reallocate. */
                       if (off_cvs[tmp_numoffcvs])
                       {
                          status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                          off_cvs[tmp_numoffcvs] = NULL;
                          if (BSERROR(*rc))
                             goto wrapup;
                       }

                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0,
                                 &off_cvs[tmp_numoffcvs], rc);
                       if(BSERROR(*rc)) 
                          goto wrapup;
  
                       status = BScv_copy(rc, temp_cvnew, off_cvs
                                          [tmp_numoffcvs]);
                       if(BSERROR(*rc)) 
                         goto wrapup;
                    }
                
                    if (temp_cvold)
                    {
                       status = BSfreecv(rc, temp_cvold);
                       temp_cvold = NULL;
                       if (BSERROR(*rc))
                          goto wrapup;
                    }

                    if (temp_cvnew)
                    {
                       status = BSfreecv(rc, temp_cvnew);
                       temp_cvnew = NULL;
                       if (BSERROR(*rc))
                          goto wrapup;
                    }

                    if (p1 >= (*num_offcvs - int_new_par0))
                    {
                       /* Shuff_cvs[p1] is associated with a curve that was 
                          originally at the beginning of the composite offset
                          curve, but due to shifting is now at the end */

                       off_table[tmp_numoffcvs] = 
                                tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                    }
                    else
                    {
                       off_table[tmp_numoffcvs]=tmp_off_table[p1+int_new_par0];
                    }
                    tmp_numoffcvs = tmp_numoffcvs + 1;       
                 }
                 else
                 {
                    /* p1 != p2 */
	   
                    BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->num_poles, 
                              shuff_cvs[p1]->rational, 0, &temp_cvnew, rc);
                    if(BSERROR(*rc)) 
                       goto wrapup;

                    status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, 
                               &shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles],
                               temp_cvnew, &tst_plan);
                    if(BSERROR(*rc)) 
                       goto wrapup;
              
                    /* If loop is contained within a single curve, merge the
                       2 split curves together after removing loop. */
                    if (p1 == prev_par)
                    {
                       tmp_numoffcvs = tmp_numoffcvs - 1;
                       BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                                 shuff_cvs[p1]->rational, 0, &temp_cvold, rc);
                       if(BSERROR(*rc)) 
                          goto wrapup;

                       status = BScv_copy(rc, off_cvs[tmp_numoffcvs],
                                          temp_cvold);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                          reallocate enough space to handle merged curves. */
                       if (off_cvs[tmp_numoffcvs])
                       {
                          status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                          off_cvs[tmp_numoffcvs] = NULL;
                          if (BSERROR(*rc))
                             goto wrapup;
                       }

                       if (temp_cvold->order == temp_cvnew->order)
                       {
                          order = temp_cvold->order;
                          num_poles = temp_cvold->num_poles + 
                                           temp_cvnew->num_poles - 1;
                       }
                       else
                       {
                          if (temp_cvold->order > temp_cvnew->order)
                          {
                             order = temp_cvold->order;
                             num_poles = temp_cvold->num_poles +  
                                          temp_cvnew->num_poles + 
                                          ((temp_cvnew->num_poles - 
                                           temp_cvnew->order + 2) *
                                           temp_cvold->order -
                                            temp_cvnew->order);
                          }
                          else
                          {
                             order = temp_cvnew->order;
                             num_poles = temp_cvnew->num_poles +  
                                          temp_cvold->num_poles + 
                                          ((temp_cvold->num_poles - 
                                           temp_cvold->order + 2) *
                                           temp_cvnew->order -      
                                            temp_cvold->order);
                          }
                       }
                       if (temp_cvold->rational || temp_cvnew->rational)
                       {
                          rational = TRUE;
                       }
                       else
                       {
                          rational = FALSE;
                       }
                       BSalloccv(order, num_poles, rational, 0, 
                                 &off_cvs[tmp_numoffcvs], rc);
                       if(BSERROR(*rc)) 
                          goto wrapup;
   
                       /* Calculate mid parameter between last parameter
                          of temp_cvold and first parameter of temp_cvnew
                          and set these parameters to this mid parameter
                          before calling BSmergecvnn. */

                       mid_par = (temp_cvold->knots[temp_cvold->num_poles]
                                 + temp_cvnew->knots[temp_cvnew->order-1] ) /
                                 2.0;

                       for (k = 0; k < temp_cvold->order; ++k)
                           temp_cvold->knots[temp_cvold->num_poles + k] = 
                             mid_par;

                       for (k = 0; k < temp_cvnew->order; ++k)             
                           temp_cvnew->knots[k] = mid_par;

                       BSmergecvnn(temp_cvold, temp_cvnew, 
                                   off_cvs[tmp_numoffcvs], rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;
                    }
                    else
                    {
                       /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                          reallocate. */
                       if (off_cvs[tmp_numoffcvs])
                       {
                          status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                          off_cvs[tmp_numoffcvs] = NULL;
                          if (BSERROR(*rc))
                             goto wrapup;
                       }
   
                        BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->
                                  num_poles, shuff_cvs[p1]->rational, 0, 
                                  &off_cvs[tmp_numoffcvs], rc);
                        if(BSERROR(*rc)) 
                           goto wrapup;

                        status = BScv_copy(rc, temp_cvnew,
                                           off_cvs[tmp_numoffcvs]);
                        if(BSERROR(*rc)) 
                          goto wrapup;
                    }
   
                    if (temp_cvold)
                    {
                       status = BSfreecv(rc, temp_cvold);
                       temp_cvold = NULL;
                       if (BSERROR(*rc))
                          goto wrapup;
                    }

                    if (temp_cvnew)
                    {
                       status = BSfreecv(rc, temp_cvnew);
                       temp_cvnew = NULL;
                       if (BSERROR(*rc))
                          goto wrapup;
                    }

                    if (p1 >= (*num_offcvs - int_new_par0))
                    {
                       /* Shuff_cvs[p1] is associated with a curve that was
                          originally at the beginning of the composite offset
                          curve, but due to shifting is now at the end */

                       off_table[tmp_numoffcvs] = 
                                tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                    }
                    else
                    {
                       off_table[tmp_numoffcvs]=tmp_off_table[p1+int_new_par0];
                    }
                    tmp_numoffcvs = tmp_numoffcvs + 1;       

                    num = p2 - p1 + 1;
                    for (ii = 0; ii < (num - 2); ++ii)              
                    {
                        BSalloccv(shuff_cvs[p1+ii+1]->order, 
                                  shuff_cvs[p1+ii+1]->num_poles,
                                  shuff_cvs[p1+ii+1]->rational, 0,
                                  &off_cvs[tmp_numoffcvs], rc);
                        if(BSERROR(*rc)) 
                           goto wrapup;

                        status = BScv_copy(rc, shuff_cvs[p1+ii+1],
                                           off_cvs[tmp_numoffcvs]);
                        if(BSERROR(*rc)) 
                          goto wrapup;
   
                        if ((p1+ii+1) >= (*num_offcvs - int_new_par0))
                        {
                           /* Shuff_cvs[p1+ii+1] is associated with curve that
                              was originally at the beginning of the composite
                              offset curve, but due to shifting is now at the
                              end */

                           off_table[tmp_numoffcvs] = tmp_off_table[p1+ii+1 - 
                                                   (*num_offcvs-int_new_par0)];
                        }
                        else
                        {
                           off_table[tmp_numoffcvs] = 
                                     tmp_off_table[p1+ii+1 + int_new_par0];
                        }
                        tmp_numoffcvs = tmp_numoffcvs + 1;             
                    }

                    BSalloccv(shuff_cvs[p2]->order, shuff_cvs[p2]->num_poles, 
                           shuff_cvs[p2]->rational, 0, &off_cvs[tmp_numoffcvs],
                           rc);
                    if(BSERROR(*rc)) 
                       goto wrapup;

                    status = BSactivsplt(rc, shuff_cvs[p2],
                               &shuff_cvs[p2]->knots[shuff_cvs[p2]->order - 1],
                               &ratio2, off_cvs[tmp_numoffcvs], &tst_plan);
                    if(BSERROR(*rc)) 
                       goto wrapup;
                 
                    if (p2 >= (*num_offcvs - int_new_par0))
                    {
                       /* Shuff_cvs[p2] is associated with a curve that was 
                          originally at the beginning of the composite offset
                          curve, but due to shifting is now at the end */

                       off_table[tmp_numoffcvs] =
                                tmp_off_table[p2 - (*num_offcvs-int_new_par0)];
                    }
                    else
                    {
                       off_table[tmp_numoffcvs]=tmp_off_table[p2+int_new_par0];
                    }
                    tmp_numoffcvs = tmp_numoffcvs + 1;             

                 }   /* end if (p1 == p2) */
                 j = j + 2;
                 prev_par = p2;

             }   /* end for (i = 1; i < num_loop_sets; ++i) */

             /* Split curve at last loop parameter */
             if (set_pars[j] == mrg_shuff_cv->knots[mrg_shuff_cv->num_poles])
                goto testing;

             p1 = (IGRint)set_pars[j];
             ratio1 = shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1] +
                       (set_pars[j] - p1) *
                         (shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles] -
                           shuff_cvs[p1]->knots[shuff_cvs[p1]->order - 1]);
   
             if (! cvsplit)
             {
                BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->num_poles, 
                         shuff_cvs[p1]->rational, 0, &temp_cvnew, rc);
                if(BSERROR(*rc)) 
                   goto wrapup;
   
                status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, 
                              &shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles], 
                              temp_cvnew, &tst_plan);
                if(BSERROR(*rc)) 
                   goto wrapup;

                if (p1 == prev_par)
                {
                  tmp_numoffcvs = tmp_numoffcvs - 1;
   
                   BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->num_poles, 
                             shuff_cvs[p1]->rational, 0, &temp_cvold, rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   status = BScv_copy(rc, off_cvs[tmp_numoffcvs], temp_cvold);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                      reallocate enough space to handle merged curves. */
                   if (off_cvs[tmp_numoffcvs])
                   {
                      status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                      off_cvs[tmp_numoffcvs] = NULL;
                      if (BSERROR(*rc))
                         goto wrapup;
                   }

                   if (temp_cvold->order == temp_cvnew->order)
                   {
                      order = temp_cvold->order;
                      num_poles = temp_cvold->num_poles + 
                                    temp_cvnew->num_poles - 1;
                   }
                   else
                   {
                      if (temp_cvold->order > temp_cvnew->order)
                      {
                         order = temp_cvold->order;
                         num_poles = temp_cvold->num_poles +  
                                      temp_cvnew->num_poles + 
                                      ((temp_cvnew->num_poles - 
                                       temp_cvnew->order + 2) *
                                       temp_cvold->order - temp_cvnew->order);
                      }
                      else
                      {
                          order = temp_cvnew->order;
                          num_poles = temp_cvnew->num_poles +  
                                      temp_cvold->num_poles + 
                                      ((temp_cvold->num_poles - 
                                       temp_cvold->order + 2) *
                                       temp_cvnew->order - temp_cvold->order);
                      }
                   }
                   if (temp_cvold->rational || temp_cvnew->rational)
                   {
                      rational = TRUE;
                   }
                   else
                   {
                      rational = FALSE;
                   }
                   BSalloccv(order, num_poles, rational, 0,
                             &off_cvs[tmp_numoffcvs], rc);
                   if(BSERROR(*rc)) 
                      goto wrapup;
   
                   /* Calculate mid parameter between last parameter
                      of temp_cvold and first parameter of temp_cvnew
                      and set these parameters to this mid parameter
                      before calling BSmergecvnn. */

                   mid_par = (temp_cvold->knots[temp_cvold->num_poles]
                             + temp_cvnew->knots[temp_cvnew->order-1] ) /
                             2.0;

                   for (j = 0; j < temp_cvold->order; ++j)
                       temp_cvold->knots[temp_cvold->num_poles + j] = 
                         mid_par;

                   for (j = 0; j < temp_cvnew->order; ++j)             
                       temp_cvnew->knots[j] = mid_par;

                   BSmergecvnn(temp_cvold, temp_cvnew, off_cvs[tmp_numoffcvs],
                               rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;
                }
                else
                {
                   /* Deallocate memory for off_cvs[tmp_numoffcvs] and 
                      reallocate. */
                   if (off_cvs[tmp_numoffcvs])
                   {
                      status = BSfreecv(rc, off_cvs[tmp_numoffcvs]);
                      off_cvs[tmp_numoffcvs] = NULL;
                      if (BSERROR(*rc))
                         goto wrapup;
                   }

                   BSalloccv(shuff_cvs[p1]->order, shuff_cvs[p1]->num_poles, 
                             shuff_cvs[p1]->rational, 0, &off_cvs[
                             tmp_numoffcvs], rc);
                   if(BSERROR(*rc)) 
                      goto wrapup;

                   status = BScv_copy(rc, temp_cvnew,off_cvs[tmp_numoffcvs]);
                   if(BSERROR(*rc)) 
                     goto wrapup;
                }

                if (temp_cvold)
                {
                   status = BSfreecv(rc, temp_cvold);
                   temp_cvold = NULL;
                   if (BSERROR(*rc))
                      goto wrapup;
                }
 
                if (temp_cvnew)
                {
                   status = BSfreecv(rc, temp_cvnew);
                   temp_cvnew = NULL;
                   if (BSERROR(*rc))
                     goto wrapup;
                }

                if (p1 >= (*num_offcvs - int_new_par0))
                {
                   /* Shuff_cvs[p1] is associated with a curve that was 
                      originally at the beginning of the composite offset
                      curve, but due to shifting is now at the end */

                    off_table[tmp_numoffcvs] =
                              tmp_off_table[p1 - (*num_offcvs-int_new_par0)];
                }
                else
                {
                    off_table[tmp_numoffcvs]=tmp_off_table[p1 + int_new_par0];
                }
                tmp_numoffcvs = tmp_numoffcvs + 1;             
   
                /* Copy shuff_cvs that follow the last loop into off_cvs*/
                for (i = p1; i < (*num_offcvs - 1); ++i)
                {
                   BSalloccv(shuff_cvs[i + 1]->order,shuff_cvs[i+1]->num_poles,
                             shuff_cvs[i + 1]->rational, 0, &off_cvs
                             [tmp_numoffcvs], rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   status = BScv_copy(rc, shuff_cvs[i+1],
                                      off_cvs[tmp_numoffcvs]);
                   if(BSERROR(*rc)) 
                      goto wrapup;
         
                   if ((i + 1) >= (*num_offcvs - int_new_par0))
                   {
                      /* Shuff_cvs[i + 1] is associated with a curve that was 
                         originally at the beginning of the composite offset
                         curve, but due to shifting is now at the end */
   
                       off_table[tmp_numoffcvs] =
                             tmp_off_table[i + 1 - (*num_offcvs-int_new_par0)];
                   }
                   else
                   {
                       off_table[tmp_numoffcvs] = 
                                             tmp_off_table[i+1+int_new_par0];
                   }
                   tmp_numoffcvs = tmp_numoffcvs + 1;             
                }   /* end for i loop */
             }
             else
             {
                /* tmp_off_cvs2[0] was split forming shuff_cvs[*num_offcvs]
                   and shuff_cvs[0]; therefore, merge these 2 curves together
                   to create off_cvs[0] */
 
                BSalloccv(shuff_cvs[p1]->order,shuff_cvs[p1]->num_poles,
                          shuff_cvs[p1]->rational, 0, &t_cv, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BSactivsplt(rc, shuff_cvs[p1], &ratio1, 
                              &shuff_cvs[p1]->knots[shuff_cvs[p1]->num_poles], 
                              t_cv, &tst_plan);
                if(BSERROR(*rc)) 
                   goto wrapup;
   
                /* Merge t_cv and off_cvs[0] to form new_offcv0 */
                num_poles = tmp_off_cvs2[0]->num_poles +
                               tmp_off_cvs2[0]->order - 1;
                BSalloccv(tmp_off_cvs2[0]->order, num_poles, tmp_off_cvs2[0]->
                          rational, 0, &new_offcv0, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BSmerge_cv(rc, t_cv, off_cvs[0], new_offcv0);
                if(BSERROR(*rc)) 
                   goto wrapup;

                /* Deallocate old off_cvs[0] and allocate again and copy 
                   new_offcv0 into off_cvs[0] */
                if (off_cvs[0])
                {
                   status = BSfreecv(rc, off_cvs[0]);
                   off_cvs[0] = NULL;
                   if (BSERROR(*rc))
                      goto wrapup;
                }
                BSalloccv(new_offcv0->order, new_offcv0->num_poles, 
                          new_offcv0->rational, 0, &off_cvs[0], rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BScv_copy(rc, new_offcv0, off_cvs[0]);
                if(BSERROR(*rc)) 
                   goto wrapup;

             }   /* end if (! cvsplit) */

testing:
             /* Set num_offcvs = new number of offset curves after removing 
                loops */
             *num_offcvs = tmp_numoffcvs;

             /* Normalize knots of all off_cvs */
             for (j = 0; j < *num_offcvs; ++j)
             {
                 status = BSnorkts(rc, &off_cvs[j]->order, &off_cvs[j]->
                                   num_poles, off_cvs[j]->knots);
                 if(BSERROR(*rc)) 
                    goto wrapup;
             }  
          }
          else
          { 
             /* If BScv_slfint returns numint > 0 but BSpreploop returns
                num_loop_sets = 0, then there are no real loops.  Copy
                tmp_off_cvs2 into off_cvs to be returned. */
             for(i=0; i < *num_offcvs; i++)
             {
                BSalloccv(tmp_off_cvs2[i]->order,tmp_off_cvs2[i]->num_poles,
                          tmp_off_cvs2[i]->rational, 0, &off_cvs[i], rc);
                if(BSERROR(*rc)) 
                  goto wrapup;
 
                status = BScv_copy(rc, tmp_off_cvs2[i], off_cvs[i]);
                if(BSERROR(*rc)) 
                   goto wrapup;
             }  
          }   /* end if (num_loop_sets > 0) */
      
       }   /* if (numint > 0) */
       else
       {
          /* numint == 0 -> No loops to remove so copy tmp_off_cvs2 into 
             off_cvs to be returned */
          for(i=0; i < *num_offcvs; i++)
          {
             BSalloccv(tmp_off_cvs2[i]->order,tmp_off_cvs2[i]->num_poles,
                       tmp_off_cvs2[i]->rational, 0, &off_cvs[i], rc);
             if(BSERROR(*rc)) 
               goto wrapup;
 
             status = BScv_copy(rc, tmp_off_cvs2[i], off_cvs[i]);
             if(BSERROR(*rc)) 
                goto wrapup;
          }  
       }   /* end if (numint > 0) */
    }   /* if (rm_loop == 1 || rm_loop == 2) */
    else
    {
       /* Copy tmp_off_cvs2 into off_cvs to be returned */
       for(i=0; i < *num_offcvs; i++)
       {
          BSalloccv(tmp_off_cvs2[i]->order,tmp_off_cvs2[i]->num_poles,
                    tmp_off_cvs2[i]->rational, 0, &off_cvs[i], rc);
          if(BSERROR(*rc)) 
            goto wrapup;

          status = BScv_copy(rc, tmp_off_cvs2[i], off_cvs[i]);

          if(BSERROR(*rc)) 
             goto wrapup;
       }  
    }   /* end if (rm_loop == 1 || rm_loops == 2) */


    /* check to see the curves have any gaps in between them */

    BStstcvcnct(*num_offcvs, off_cvs, closed, ordgaprev, &numpts, pts, rc);
    if(BSERROR(*rc))
       goto wrapup;
    if( numpts > 0 )
    {
       /* there are gaps in the offset curves */
       *rc = BSNOTCONNECTED;
    }


    wrapup:

      if (a_par)
      {
         BSdealloc((char *) a_par);
         a_par = NULL;
      }
      if (b_par)
      {
         BSdealloc((char *) b_par);
         b_par = NULL;
      }
      if (c_over)
      { 
         BSdealloc((char *) c_over);
         c_over = NULL;
      }
      if (d_over)
      {
         BSdealloc((char *) d_over);
         d_over = NULL;
      }
      if (e_over)
      {
         BSdealloc((char *) e_over);
         e_over = NULL;
      }
      if (f_over)
      {
         BSdealloc((char *) f_over);
         f_over = NULL;
      }

      if(new_offcv0)
      {
         status = BSfreecv(&rc1, new_offcv0);
         if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
          new_offcv0 = NULL;
      }
      if(t_cv)
      {
         status = BSfreecv(&rc1, t_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
          t_cv = NULL;
      }
      if(mrg_shuff_cv)
      {
         status = BSfreecv(&rc1, mrg_shuff_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
          mrg_shuff_cv = NULL;
      }
      if (out_over_alloc)
      {
         if (xover_pts)
         {
            BSdealloc((char *) xover_pts);
            xover_pts = NULL;
         }
         if (xover0)
         {
            BSdealloc((char *) xover0);
            xover0 = NULL;
         }
         if (xover1)
         {
            BSdealloc((char *) xover1);
            xover1 = NULL;
         }
      }
      if (out_pt_alloc)
      {
         if (xint_pts)
         {
            BSdealloc((char *) xint_pts);
            xint_pts = NULL;
         }
         if (xpar0)
         {
            BSdealloc((char *) xpar0);
            xpar0 = NULL;
         }
         if (xpar1)
         {
            BSdealloc((char *) xpar1);
            xpar1 = NULL;
         }
      }
      if(con_line)
      {
         status = BSfreecv(&rc1, con_line);
         if (BSERROR(rc1) && BSOKAY(*rc))
           *rc = rc1;
         con_line = NULL;
      }

      if (set_pars)
      {
         BSdealloc((char *) set_pars);
         set_pars = NULL;
      }
      if (nloop_pars)
      {
         BSdealloc((char *) nloop_pars);
         nloop_pars = NULL;
      }
      if (loop_pars)
      {
         BSdealloc((char *) loop_pars);
         loop_pars = NULL;
      }
      if (tmp_mrg_offcv)
      {
         status = BSfreecv(&rc1, tmp_mrg_offcv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
         tmp_mrg_offcv = NULL;
      }
      if (alloc_ind)
      {
        if(ind)
         {
            BSstackdealloc((char *) ind);
            ind = NULL;
         }
      }
      if (alloc_tmp_pars)
      {
        if(tmp_pars)
         {
            BSstackdealloc((char *) tmp_pars);
            tmp_pars = NULL;
         }
      }
      if( *num_offcvs > MAXNUM )
      {
         if(ordgaprev )
         {
            BSstackdealloc((char *)ordgaprev);
            ordgaprev = NULL;
         }
         if(pts )
         {
            BSstackdealloc((char *) pts);
            pts = NULL;
         }
      }
      if (alloc_tmp_off_table)
      {
         if (tmp_off_table)
         {
            BSstackdealloc((char *) tmp_off_table);
            tmp_off_table = NULL;
         }
      }
      if (alloc_tmp_off_dist)
      {
         if (tmp_off_dist)
         {
            BSstackdealloc((char *) tmp_off_dist);
            tmp_off_dist = NULL;
         }
      }
      if (alloc_tmp_codes)
      {
         if (tmp_codes)
         {
            BSstackdealloc((char *) tmp_codes);
            tmp_codes = NULL;
         }
      }
      if (alloc_index)
      {
         if(index) 
         {
           BSstackdealloc((char *)index);
           index = NULL;
         }
      }
      if(new_cvs)
      {
         for(i=0; i < num_valid; i++)
         {
            if(new_cvs[i])
            {
               (void)BSfreecv(&rc1, new_cvs[i]);
               if (BSERROR(rc1) && BSOKAY(*rc))
                *rc = rc1;
               new_cvs[i] = NULL;
            }
         }
         BSstackdealloc((char *)new_cvs);
         new_cvs = NULL;
      }
      if(shuff_cvs) 
      {
        for(i=0; i < (old_numoffcvs + 1); i++)
        {
           if(shuff_cvs[i])
           {
              status = BSfreecv(&rc1, shuff_cvs[i]);
              if (BSERROR(rc1) && BSOKAY(*rc))
                *rc = rc1;
              shuff_cvs[i] = NULL;
           }
        }
        BSstackdealloc((char *) shuff_cvs);
        shuff_cvs = NULL;
      }

      if (tmp_off_cvs2)
      {
         for(i=0; i < (2 * num_valid +1); i++)
         {
            if(tmp_off_cvs2[i] && free_tcvs2[i])
            {
               (void)BSfreecv(&rc1, tmp_off_cvs2[i]);
               if (BSERROR(rc1) && BSOKAY(*rc))
                 *rc = rc1;
               tmp_off_cvs2[i] = NULL;
            }
         }
         BSstackdealloc((char *)tmp_off_cvs2);
         tmp_off_cvs2 = NULL;
      }

      if (alloc_free_tcvs2)
      {
         BSstackdealloc((char *) free_tcvs2);
         free_tcvs2 = NULL;
      }


      if(tnew_cvs)
      {
         for(i=0; i < num_cvs; i++)
         {
            if(tnew_cvs[i])
            {
               (void)BSfreecv(&rc1, tnew_cvs[i]);
               if (BSERROR(rc1) && BSOKAY(*rc))
                *rc = rc1;
               tnew_cvs[i] = NULL;
            }
         }
         BSstackdealloc((char *)tnew_cvs);
         tnew_cvs = NULL;
      }
      if(tran_off_cvs) 
      {
        for(i=0; i < 2 * num_cvs +1; i++)
        {
           if(tran_off_cvs[i])
           {
              (void)BSfreecv(&rc1, tran_off_cvs[i]);
              if (BSERROR(rc1) && BSOKAY(*rc))
                 *rc = rc1;
              tran_off_cvs[i] = NULL;
           }
        }
        BSstackdealloc((char *)tran_off_cvs);
        tran_off_cvs = NULL;
      }

      if (alloc_z1_temp)
      {
         if (z1_temp)
         {
            BSstackdealloc((char *) z1_temp);
            z1_temp = NULL;
         }
      }

      if(BSERROR(*rc))
          BSdbgrc(*rc,"BScmpcvoffl");
      return;          
}


