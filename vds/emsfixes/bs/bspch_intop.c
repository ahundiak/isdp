/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSpch_intop

Abstract
    This routine performs the patch-patch intersection for surface-surface
intersection with the option to use a different iteration method if the
node points have been offset.

Synopsis
    void BSpch_intop( s1, s2, unum1, unum2, vnum1, vnum2, upar1, vpar1, 
                      upar2, vpar2, urng1, vrng1, urng2, vrng2, netpt1,
                      netpt2, midpt1, midpt2, insert1, insert2, lookup,
                      num_look, look_ct, knot_tol1, knot_tol2, off_opt,
                      n1, n2, off1, off2, numarr, numseg, pchseg, rc )

    struct IGRbsp_surface      *s1, *s2
    IGRint                     unum1, unum2, vnum1, vnum2
    IGRdouble                  *upar1, *vpar1, *upar2, *vpar2
    IGRdouble                  urng1[2], vrng1[2], urng2[2], vrng2[2]
    IGRpoint                   *netpt1, *netpt2
    IGRpoint                   *midpt1, *midpt2
    IGRint                     *insert1, *insert2
    IGRint                     **lookup
    IGRint                     num_look
    IGRint                     look_ct
    IGRdouble                  knot_tol1, knot_tol2
    IGRboolean                 off_opt
    IGRboolean                 n1, n2
    IGRdouble                  off1, off2
    IGRint                     *numarr
    IGRint                     *numseg
    struct BSlnseg             ***pchseg
    BSrc                       *rc

Description
    Input:
      s1, s2               B-spline surfaces
      unum1, unum2         Number of node values in the u direction
      vnum1, vnum2         Number of node values in the v direction
      upar1, vpar1,        Arrays of node values
      upar2, vpar2
      urng1, vrng1,        Parametric range values
      urng2, vrng2
      netpt1, netpt2       Array of node points (offsetted if off_opt = 1)
      midpt1, midpt2       Arrays of midpoints (offsetted if off_opt = 1)
      insert1, insert2     Insert tables for cht
      lookup               Intersection lookup table
      num_look             Number of arrays in lookup
      look_ct              Number of indices in last lookup array
      knot_tol1, knot_tol2 Knot tolerance values
      off_opt              (0) Node points and midpoints have not been offset
                           (1) Node points and midpoints have been offset
      n1, n2               If off_opt = 1, indicators for natural normals
      off1, off2           If off_opt = 1, offset distances for both surfaces

    Output:
      pchseg               Array of pointers to arrays of intersection segments
      numarr               Number of segment arrays
      numseg               Number of segments in last pchseg arrays

Return Values
    If no memory can be allocated, rc returns BSNOSTKMEMORY or BSNOMEMORY.
If no errors occur, rc returns BSSUCC.

Notes
    This is a specialized routine for surface-surface intersection.

Index
    md

Keywords

History
    C. S. Kirby    08/07/89   : Creation date. (Copied and modified from
                                original BSpch_int).
    C. S. Kirby    12/14/90   : Correct apogee warnings.
    C. S. Kirby    07/24/91   : Add a check in sameBSpch_intop to check
                                for same segment length within tolerance
                                before checking all point distances.
    C. S. Kirby    08/08/91   : When checking for points in the save array,
                                use minimum and maximum values that are
                                slightly modified by the knot tolerance.
    C. S. Kirby    09/03/91   : Reset the closed indicators if the surface
                                parametric range is greater than the given
                                parametric range.
    C. S. Kirby    04/03/92   : Always call BSxcvsfbxop if nint = 2 and
                                the squared distance between int_pts <
                                same_dist_sqtol.
    C. S. Kirby    07/15/92   : Modify call to BSpch_trcop in order to provide
                                temporary working memory and consolidate
                                argument list.
    C. S. Kirby    08/10/92   : In sameBSpch_intop - check (int_dist - dist)
                                against (dist_sqtol * 100000) instead of 
                                (dist_sqtol * 10). This check is a preliminary
                                screen for the following checks and we do 
                                not want to miss deleting any segment which
                                should be deleted. Use indicators in order
                                to not throw out a segment because both
                                endpoints of one segment were within tolerance
                                of the SAME endpoint of the other segment.
    C. S. KIRBY    08/21/92   : Use stack allocation/deallocation for no_int.
    S.G. Catron    04/27/00   : VDS TR 179901421 - the tolerance used to check if 
                                this segment length is the same as previous segment
                                lengths was wrong(sameBSpch_intop).
                                
    S.G. catron    10/11/00   : VDS TR179902068 - fix in BSquadln2 causes problems
                                to sfsf(sur_sur.d157).  Cludge for now is to rename
                                old BSquadln2 to BSsquadln2 and call.
    S.G. Catron    01/04/00   : VDS TR4115-In section which intersects quad1 lines with quad2, use
                                quad_tol, if save_ct, but use dist_tol if not save_ct.
                                The idea is, if this is a new group, then use a tighter
                                tolerance, and if this is part of another group a looser
                                tolerance.
                                Also, changed same_dist_sqtol to dist_sqtol instead of 10
                                times dist_sqtol.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bssfsf_int2.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#include "bsmemory.h"
#endif
#define  BSVOID
#include <math.h>
#define  PCHSEGNUM 50
#define  NOINTNUM 100


static void saveBSpch_intop(

IGRint           savemax,
IGRpoint         save_pts[200],
BSpair           save_par1[200],
BSpair           save_par2[200],
IGRint           save_connect[200],
IGRdouble        u1,
IGRdouble        v1,
IGRdouble        u2,
IGRdouble        v2,
IGRpoint         int_pt,
IGRdouble        dist_sqtol,
IGRint           *index )

{

IGRint           i,j;                  
IGRboolean       same;
IGRdouble        dist, dx, dy, dz;

same = FALSE;

if (save_connect[0] != -1)
 {
   i=0;
   do
    {
       dx = int_pt[0] - save_pts[i][0];
       dy = int_pt[1] - save_pts[i][1];
       dz = int_pt[2] - save_pts[i][2];
       dist = dx * dx + dy * dy + dz * dz;
       if (dist < dist_sqtol)
       {
          same = TRUE;
          *index = i;
          if (save_connect[i] == 2)
           {
             save_connect[i] = 0;
           }
          break;
       }
      i++;
    } while ((i < savemax) && (save_connect[i] != -1));
 }       

if (! same)
 {
   for (i=0;i < savemax;i++)
    {
      if ((save_connect[i] == 2) || (save_connect[i] == -1))
       {
         *index = i;
         for (j=0;j < 3;j++)
          {
             save_pts[*index][j] = int_pt[j];
          }
         save_par1[*index][0] = u1;
         save_par1[*index][1] = v1;
         save_par2[*index][0] = u2;
         save_par2[*index][1] = v2;
         save_connect[*index] = 0;
         break;
       }
    }
 }
return;
}

/* this function tries to determine if we have the same segment as one
   already in the list.   */
static void sameBSpch_intop(

IGRint      *numarr,
IGRint      *numseg,
struct
 BSlnseg    ***pchseg,
IGRpoint    int_pts[2],
IGRdouble   dist_sqtol,
IGRint      *same_ct )

{

IGRint      i, k, tnum, temp;
struct
 BSlnseg    *npoint;
IGRdouble   dx, dy, dz, dist, int_dist;
IGRint      temp_ct;
IGRdouble   temp_dist_sqtol, temp_tol,chrdht_tol;
IGRboolean  beg1, end1, beg2, end2;    /* indicators that points are within */
                                       /*  tolerance and should not be      */
                                       /*  rechecked                        */
BSrc rc;

BSEXTRACTPAR( &rc, BSTOLCHRDHT, chrdht_tol );
*same_ct = 0;
temp_dist_sqtol = dist_sqtol * 10;
temp_tol = dist_sqtol * 100000;

dx = int_pts[0][0] - int_pts[1][0];
dy = int_pts[0][1] - int_pts[1][1];
dz = int_pts[0][2] - int_pts[1][2];
int_dist = dx * dx + dy * dy + dz * dz;

for (i=0;i <= *numarr;i++)
 {
   if (*numarr == i)
      temp = *numseg;
   else
      temp = 50;

   for (k=0;k < temp;k++)
    {
      /* These indicators are used in order to keep from throwing */
      /*  out a segment because the endpoints of one segment are  */
      /*  within tolerance of the SAME endpoint of the other      */
      /*  segment. This is necessary because different tolerances */
      /*  are used for checking invalid segments (degenerate) and */
      /*  duplicate segments (checked by this static function).   */

      beg1 = end1 = beg2 = end2 = FALSE;

      *same_ct = 0;
      temp_ct = 0;
      npoint = &((*pchseg)[i][k]);
      tnum = npoint->num - 1;

      /* First check for a segment of equal length */

      dx = npoint->pts[0][0] - npoint->pts[tnum][0];
      dy = npoint->pts[0][1] - npoint->pts[tnum][1];
      dz = npoint->pts[0][2] - npoint->pts[tnum][2];
      dist = dx * dx + dy * dy + dz * dz;

      /* 04/27/00 - modified tolerance - sur_sur.d151-d153 */
      /* |d - d'| <= chrdht_tol,
           2     2
          d  - d' =  (d + d')(d - d') ~= 2(d) ( d - d')
           2    2
         |d - d' | <= 2 * d * chrdht_tol
         **remember int_dist and dist are the squared distance
      */         
      if (fabs(int_dist - dist) > sqrt(dist) * 20.0 * chrdht_tol)
         continue;

      /*********************************************/

      dx = int_pts[0][0] - npoint->pts[0][0];
      dy = int_pts[0][1] - npoint->pts[0][1];
      dz = int_pts[0][2] - npoint->pts[0][2];
      dist = dx * dx + dy * dy + dz * dz;
      if (dist < dist_sqtol)
       {
         *same_ct += 1;
         beg1 = TRUE;
         beg2 = TRUE;
       }
      else if (dist < temp_dist_sqtol)
       {
         temp_ct += 1;
         beg1 = TRUE;
         beg2 = TRUE;
       }
      /*********************************************/

      if (! beg1)
       {
         dx = int_pts[0][0] - npoint->pts[tnum][0];
         dy = int_pts[0][1] - npoint->pts[tnum][1];
         dz = int_pts[0][2] - npoint->pts[tnum][2];
         dist = dx * dx + dy * dy + dz * dz;
         if (dist < dist_sqtol)
          {
            *same_ct += 1;
            end2 = TRUE;
            if (*same_ct == 2) 
              goto wrapup2;

            if (temp_ct > 0)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
         else if (dist < temp_dist_sqtol)
          {
            temp_ct += 1;
            end2 = TRUE;
            if (*same_ct == 1)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
       }

      /*********************************************/

      if (! beg2)
       {      
         dx = int_pts[1][0] - npoint->pts[0][0];
         dy = int_pts[1][1] - npoint->pts[0][1];
         dz = int_pts[1][2] - npoint->pts[0][2];
         dist = dx * dx + dy * dy + dz * dz;
         if (dist < dist_sqtol)
          {
            *same_ct += 1;
            end1 = TRUE;
            if (*same_ct == 2) 
               goto wrapup2;
 
            if (temp_ct > 0)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
         else if (dist < temp_dist_sqtol)
          {
            temp_ct += 1;
            end1 = TRUE;
            if (*same_ct == 1)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
       }

      /*********************************************/

      if (! end1 && !end2)
       {
         dx = int_pts[1][0] - npoint->pts[tnum][0];
         dy = int_pts[1][1] - npoint->pts[tnum][1];
         dz = int_pts[1][2] - npoint->pts[tnum][2];
         dist = dx * dx + dy * dy + dz * dz;
         if (dist < dist_sqtol)
          {
            *same_ct += 1;
            if (*same_ct == 2)
               goto wrapup2;

            if (temp_ct > 0)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
         else if (dist < temp_dist_sqtol)
          {
            temp_ct += 1;
            if (*same_ct == 1)
             {
               *same_ct = 2;
               goto wrapup2;
             }
          }
       }

      /*********************************************/

    } /* end for */
 }      
wrapup2:return;
}

static void parBSpch_intop(

IGRdouble     min,
IGRdouble     max,
IGRdouble     smin,
IGRdouble     smax,
IGRdouble     knot_tol,
IGRboolean    closed,
IGRdouble     *par,
IGRboolean    *out )

{

*out = FALSE;
if ((*par < (min - knot_tol)) || (*par > (max + knot_tol)))
 {
   if (closed)
    {
      if (fabs(min - smin) < knot_tol)
       {
         if (fabs(*par - smax) > knot_tol)
            *out = TRUE;
         else
            *par = min;

         if (fabs(max - smax) < knot_tol)
          {
            if (fabs(*par - smin) > knot_tol)
               *out = TRUE;
            else
               *par = max;
          }
       }
      else
         *out = TRUE;
    }
   else
      *out = TRUE;
 }
return;
}

/* Main Routine */

void BSpch_intop(

struct
 IGRbsp_surface  *s1,
struct
 IGRbsp_surface  *s2,
IGRint           unum1,
IGRint           unum2,
IGRint           vnum1,
IGRint           vnum2,
IGRdouble        *upar1,
IGRdouble        *vpar1,
IGRdouble        *upar2,
IGRdouble        *vpar2,
IGRdouble        urng1[2],
IGRdouble        vrng1[2],
IGRdouble        urng2[2],
IGRdouble        vrng2[2],
IGRpoint         *netpt1,
IGRpoint         *netpt2,
IGRpoint         *midpt1,
IGRpoint         *midpt2,
IGRint           *insert1,
IGRint           *insert2,
IGRint           **lookup,
IGRint           num_look,
IGRint           look_ct,
IGRdouble        knot_tol1,
IGRdouble        knot_tol2,
IGRboolean       off_opt,
IGRboolean       n1,
IGRboolean       n2,
IGRdouble        off1,
IGRdouble        off2,
IGRint           *numarr,
IGRint           *numseg,
struct
 BSlnseg         ***pchseg,
BSrc             *rc )

{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscvsfiter.h"
#include "bspch_trcop.h"
#include "bscvsfckrng.h"
#include "bsxcvsfbxop.h"
#include "bssquadln.h"
#include "bsofcvsfitr.h"
#include "bspchnminst.h"
#endif 

IGRint           i,j,ii,jj,iii,jjj, /* loop counters                         */
                 k,qq,q;
IGRint           temp1,temp2,tnum;  /* temporary variables                   */
IGRpoint         qpt1[4],qpt2[4];   /* quad points                           */
IGRint           option[2];         /* numbers indicating which parameter    */
                                    /*  value is constant: (0)u1, (1)v1,     */
                                    /*  (2)u2, (3)v2                         */
IGRint           constt[2];         /* indicator for parameter held constant*/
IGRdouble        tempu1[2],         /* temporary parameter values            */
                 tempv1[2],
                 tempu2[2],
                 tempv2[2];
IGRint           out_of_range;      /* indicator for parameter value out of  */
                                    /*  range                                */
IGRint           n_int;              /* number of intersection points         */
IGRpoint         int_pts[2];        /* intersection points                   */
IGRdouble        u1min,u1max,       /* minimum and maximum parameter values  */
                 v1min,v1max,       /*  for intersecting patches             */
                 u2min,u2max,
                 v2min,v2max;
IGRint           savemax=200;       /* maximum for save arrays               */
IGRpoint         save_pts[200];     /* save array of points                  */
BSpair           save_par1[200],    /* save arrays of parameter values       */
                 save_par2[200];    
IGRint           save_connect[200]; /* save array of number of connections   */
IGRint           **no_int = NULL;   /* indices of boxes that overlap but do  */
                                    /*  not intersect                        */
IGRint           no_num;            /* number of arrays of indices           */
IGRint           no_ct;             /* counter for no_int                    */
IGRboolean       pt_found;          /* indicator for point returned from     */
                                    /*  BSxcvsfbxop                          */
IGRboolean       isuccess;          /* indicator for successful iteration    */
IGRint           num_out;           /* number of parameters out of range     */
IGRint           t_ind[2];          /* index of first available slot in save */
                                    /*  array                                */
IGRint           xnum;              /* number of points returned from        */
                                    /*  BSsquadln                             */
IGRint           tot_xout;          /* total number of points returned from  */
                                    /*  BSsquadln that are out of range       */
IGRpoint         temp_pts[2];       /* temporary quad points                 */
IGRpoint         xpts[8];           /* intersection points returned from     */
                                    /*  BSsquadln                             */
IGRdouble        paru1[8], parv1[8],/* parameter values returned from        */
                 paru2[8], parv2[8];/*  BSsquadln                             */
IGRboolean       xout[8];           /* indicators for points returned from   */
                                    /*  BSsquadln that are out of range       */
IGRint           xoption[8];        /* option numbers for points out of range*/
IGRint           xconst[8];         /* constant numbers for points out of    */
                                    /*  range                                */
IGRboolean       same;              /* flag used to test for repeated points */
IGRint           save_found[2];     /* number indicating that intersection   */
                                    /*  point already exists in save array   */
IGRint           save_ct;           /* counter for points found in save array*/
IGRint           save_ind[2];       /* indexes of save_pts used              */
IGRboolean       save_used;         /* indicator that save_pt has been used  */
IGRint           sub0,sub1,sub2,    /* temporary subscripts                  */
                 sub3;
IGRint           var1,var2;         /* temporary variables                   */
IGRint           same_ct;           /* counter for duplicate points          */
IGRint           net1,net2;         /* temporary subscripts for netpt1,netpt2*/
IGRdouble        save_const[2];     /* constant parameters of points found in*/
                                    /*  save array                           */
IGRboolean       pt_iter;           /* indicator to do iteration on point    */
IGRint           ncount, tcount;    /* temporary loop variable               */
IGRdouble        dist_sqtol;        /* squared distance tolerance value      */
IGRdouble        dist, dist1, dist2;/* distance variable                     */
IGRdouble        dx, dy, dz;        /* coordinate delta values               */
IGRpoint         avgpt1, avgpt2;
IGRdouble        chrdht_tol;
IGRdouble        s1_umin, s1_umax,
                 s1_vmin, s1_vmax,
                 s2_umin, s2_umax,
                 s2_vmin, s2_vmax;
IGRboolean       u1_closed, v1_closed,
                 u2_closed, v2_closed, out;
IGRdouble        same_dist_sqtol;
IGRdouble        qdist[4], quad_tol = 0;
IGRint           temp_const = -1;
IGRint           nalloc_noint, nalloc_pchseg,
                 new_alloc;
IGRint           **new_noint = NULL;
struct BSlnseg   **new_pchseg = NULL;
IGRboolean       all_pch = FALSE;
IGRint           tmax1, tmax2;
IGRdouble        temp_u1min, temp_u1max,
                 temp_v1min, temp_v1max,
                 temp_u2min, temp_u2max,
                 temp_v2min, temp_v2max;
IGRdouble        diff1, diff2;

IGRint           nalloc_ind = 21,   /* allocation numbers for index and      */
                 nalloc_pts = 21;   /*  working space                        */
IGRdouble        sq_cht;            /* squared chord height tolerance        */
IGRdouble        min_max[8];        /* consolidation of min and max pars     */
IGRint           tinsert[4];        /* consolidation of insert numbers       */
IGRdouble        rngs[8];           /* consolidation of range values         */
IGRint           *index = NULL;     /* index used by BSpch_trcuv             */
IGRdouble        *wrk_space = NULL; /* working space for points and pars from*/
                                    /*  BSpch_trcuv                          */

*rc = BSSUCC;
*numseg = 0;
*numarr = 0;
no_num = 0;
no_ct = 0;
nalloc_noint = NOINTNUM;
nalloc_pchseg = PCHSEGNUM;




/* Set the physically closed indicators. If a surface is closed */
/*  in a direction, but the range in that direction is less than*/
/*  the entire surface knot range in that direction, the closed */
/*  indicator is set to FALSE.                                  */

u1_closed = s1->u_phy_closed;
v1_closed = s1->v_phy_closed;
u2_closed = s2->u_phy_closed;
v2_closed = s2->v_phy_closed;

rngs[0] = urng1[0];
rngs[1] = urng1[1];
rngs[2] = vrng1[0];
rngs[3] = vrng1[1];
rngs[4] = urng2[0];
rngs[5] = urng2[1];
rngs[6] = vrng2[0];
rngs[7] = vrng2[1];

if (u1_closed)
 {
   diff1 = fabs(s1->u_knots[s1->u_num_poles] - s1->u_knots[s1->u_order - 1]);
   diff2 = fabs(urng1[1] - urng1[0]);
   if (fabs(diff1 - diff2) > knot_tol1)
      u1_closed = FALSE;
 }

if (v1_closed)
 {
   diff1 = fabs(s1->v_knots[s1->v_num_poles] - s1->v_knots[s1->v_order - 1]);
   diff2 = fabs(vrng1[1] - vrng1[0]);
   if (fabs(diff1 - diff2) > knot_tol1)
      v1_closed = FALSE;
 }

if (u2_closed)
 {
   diff1 = fabs(s2->u_knots[s2->u_num_poles] - s2->u_knots[s2->u_order - 1]);
   diff2 = fabs(urng2[1] - urng2[0]);
   if (fabs(diff1 - diff2) > knot_tol2)
      u2_closed = FALSE;
 }

if (v2_closed)
 {
   diff1 = fabs(s2->v_knots[s2->v_num_poles] - s2->v_knots[s2->v_order - 1]);
   diff2 = fabs(vrng2[1] - vrng2[0]);
   if (fabs(diff1 - diff2) > knot_tol2)
      v2_closed = FALSE;
 }

BSEXTRACTPAR( rc, BSTOLSQLENVEC, dist_sqtol );
BSEXTRACTPAR( rc, BSTOLCHRDHT, chrdht_tol );
same_dist_sqtol = dist_sqtol;
sq_cht = chrdht_tol * chrdht_tol;

*pchseg = (struct BSlnseg **)BSmalloc((unsigned)
                                (PCHSEGNUM * sizeof(struct BSlnseg *)));
if (! *pchseg)
 {
   *rc = BSNOMEMORY;
   goto wrapup;
 }

(*pchseg)[0] = (struct BSlnseg *)BSmalloc((unsigned)
                                            (50 * sizeof(struct BSlnseg )));
if (! (*pchseg)[0])
 {
   *rc = BSNOMEMORY;
   goto wrapup;
 }

no_int = (IGRint **)BSstackalloc((unsigned)(NOINTNUM * sizeof(IGRint *)));
if (! no_int)
 {
   *rc = BSNOSTKMEMORY;
   goto wrapup;
 }

no_int[0] = (IGRint *)BSstackalloc((unsigned)(400 * sizeof(IGRint)));
if (! no_int[0])
 {
   *rc = BSNOSTKMEMORY;
   goto wrapup;
 }

if (off_opt)
 {
    /* Recalculate the number of insert points */

    BSpchnminst( s1, unum1, vnum1, upar1, vpar1, all_pch, off_opt,
                 insert1, &tmax1, &tmax2, rc );
    if (BSERROR(*rc))
      goto wrapup;

    BSpchnminst( s2, unum2, vnum2, upar2, vpar2, all_pch, off_opt,
                 insert2, &tmax1, &tmax2, rc );
    if (BSERROR(*rc))
      goto wrapup;
 }
else
 {
    /* Set up the memory for index and wrk_space - these must be */
    /*  malloced in case of reallocation.                        */

    index = (IGRint *)BSmalloc((unsigned)(nalloc_ind * sizeof(IGRint)));
    if (! index)
     {
       *rc = BSNOMEMORY;
       goto wrapup;
     }
    tnum = nalloc_pts * 7;
    wrk_space = (IGRdouble *)BSmalloc((unsigned)(tnum * sizeof(IGRdouble)));
    if (! wrk_space)
     {
       *rc = BSNOMEMORY;
       goto wrapup;
     }
 }

for (i=0;i < savemax;i++)
    save_connect[i] = -1;

for (qq=0;qq <= num_look;qq++)
 {
    if (qq == num_look)
       ncount = look_ct;
    else
       ncount = 400;

    for (q=0;q < ncount;q += 4)
     {
        iii = lookup[qq][q];
        jjj = lookup[qq][q + 1];
        ii = lookup[qq][q + 2];
        jj = lookup[qq][q + 3];

        net1 = jjj * unum1 + iii;
        net2 = jj * unum2 + ii;

        min_max[0] = u1min = upar1[iii];
        min_max[4] = u1max = upar1[iii + 1];
        min_max[1] = v1min = vpar1[jjj];
        min_max[5] = v1max = vpar1[jjj + 1];
        min_max[2] = u2min = upar2[ii];
        min_max[6] = u2max = upar2[ii + 1];
        min_max[3] = v2min = vpar2[jj];
        min_max[7] = v2max = vpar2[jj + 1];

        /* Set up range values that are slightly modified */
        /*  by the knot tolerance                         */

        temp_u1min = u1min - knot_tol1;
        temp_u1max = u1max + knot_tol1;
        temp_v1min = v1min - knot_tol1;
        temp_v1max = v1max + knot_tol1;
        temp_u2min = u2min - knot_tol2;
        temp_u2max = u2max + knot_tol2;
        temp_v2min = v2min - knot_tol2;
        temp_v2max = v2max + knot_tol2;

        n_int = 0;
        save_ct = 0;
        save_found[0] = -1;
        save_found[1] = -1;
        tempu1[0] = -1000;
        tempv1[0] = -1000;
        tempu2[0] = -1000;
        tempv2[0] = -1000;
        i=0;
        save_used = FALSE;
        do
         {
            if ((save_connect[i] == 0) || (save_connect[i] == 1))
             {
                if (fabs(save_par1[i][0] - u1min) < knot_tol1) 
                 {
                    if ((save_par1[i][1] >= temp_v1min) && 
                        (save_par1[i][1] <= temp_v1max) &&
                        (save_par2[i][0] >= temp_u2min) &&
                        (save_par2[i][0] <= temp_u2max) &&
                        (save_par2[i][1] >= temp_v2min) &&
                        (save_par2[i][1] <= temp_v2max))
                     {
                       for (k=0;k < 3;k++)
                        {
                           int_pts[save_ct][k] = save_pts[i][k];
                        }
                       tempu1[save_ct] = save_par1[i][0];
                       tempv1[save_ct] = save_par1[i][1];
                       tempu2[save_ct] = save_par2[i][0];
                       tempv2[save_ct] = save_par2[i][1];
                       save_ind[save_ct] = i;
                       save_found[save_ct] = 2;
                       save_const[save_ct] = u1min;
                       save_used = TRUE;
                       save_ct++;
                     }
                 }
                if ((fabs(save_par1[i][0] - u1max) < knot_tol1) &&
                    (save_connect[i] < 2) && (!save_used))
                 {
                   if ((save_par1[i][1] >= temp_v1min) &&
                       (save_par1[i][1] <= temp_v1max) &&
                       (save_par2[i][0] >= temp_u2min) &&
                       (save_par2[i][0] <= temp_u2max) &&
                       (save_par2[i][1] >= temp_v2min) &&
                       (save_par2[i][1] <= temp_v2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_found[save_ct] = 3;
                      save_const[save_ct] = u1max;
                      save_ind[save_ct] = i;
                      save_used = TRUE;
                      save_ct++;
                    }
                 }
                if ((fabs(save_par1[i][1] - v1min) < knot_tol1) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par2[i][0] >= temp_u2min) &&
                       (save_par2[i][0] <= temp_u2max) &&
                       (save_par2[i][1] >= temp_v2min) &&
                       (save_par2[i][1] <= temp_v2max))
                     {
                       for (k=0;k < 3;k++)
                        {
                          int_pts[save_ct][k] = save_pts[i][k];
                        }
                       tempu1[save_ct] = save_par1[i][0];
                       tempv1[save_ct] = save_par1[i][1];
                       tempu2[save_ct] = save_par2[i][0];
                       tempv2[save_ct] = save_par2[i][1];
                       save_found[save_ct] = 0;
                       save_const[save_ct] = v1min;
                       save_ind[save_ct] = i;
                       save_used = TRUE;
                       save_ct++;
                     }
                 }
                if ((fabs(save_par1[i][1] - v1max) < knot_tol1) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par2[i][0] >= temp_u2min) &&
                       (save_par2[i][0] <= temp_u2max) &&
                       (save_par2[i][1] >= temp_v2min) &&
                       (save_par2[i][1] <= temp_v2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_ind[save_ct] = i;
                      save_found[save_ct] = 1;
                      save_const[save_ct] = v1max;
                      save_used = TRUE;
                      save_ct++;
                    }
                 }
                if ((fabs(save_par2[i][0] - u2min) < knot_tol2) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par1[i][1] >= temp_v1min) &&
                       (save_par1[i][1] <= temp_v1max) &&
                       (save_par2[i][1] >= temp_v2min) &&
                       (save_par2[i][1] <= temp_v2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_found[save_ct] = 6;
                      save_const[save_ct] = u2min;
                      save_ind[save_ct] = i;
                      save_used = TRUE;
                      save_ct++;
                    }
                 }
                if ((fabs(save_par2[i][0] - u2max) < knot_tol2) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par1[i][1] >= temp_v1min) &&
                       (save_par1[i][1] <= temp_v1max) &&
                       (save_par2[i][1] >= temp_v2min) &&
                       (save_par2[i][1] <= temp_v2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_ind[save_ct] = i;
                      save_found[save_ct] = 7;
                      save_const[save_ct] = u2max;
                      save_used = TRUE;
                      save_ct++;
                    }
                 }
                if ((fabs(save_par2[i][1] - v2min) < knot_tol2) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par1[i][1] >= temp_v1min) &&
                       (save_par1[i][1] <= temp_v1max) &&
                       (save_par2[i][0] >= temp_u2min) &&
                       (save_par2[i][0] <= temp_u2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_ind[save_ct] = i;
                      save_found[save_ct] = 4;
                      save_const[save_ct] = v2min;
                      save_used = TRUE;
                      save_ct++;
                    }
                 }
                if ((fabs(save_par2[i][1] - v2max) < knot_tol2) &&
                    (save_connect[i] < 2) && (! save_used))
                 {
                   if ((save_par1[i][0] >= temp_u1min) &&
                       (save_par1[i][0] <= temp_u1max) &&
                       (save_par1[i][1] >= temp_v1min) &&
                       (save_par1[i][1] <= temp_v1max) &&
                       (save_par2[i][0] >= temp_u2min) &&
                       (save_par2[i][0] <= temp_u2max))
                    {
                      for (k=0;k < 3;k++)
                       {
                         int_pts[save_ct][k] = save_pts[i][k];
                       }
                      tempu1[save_ct] = save_par1[i][0];
                      tempv1[save_ct] = save_par1[i][1];
                      tempu2[save_ct] = save_par2[i][0];
                      tempv2[save_ct] = save_par2[i][1];
                      save_ind[save_ct] = i;
                      save_found[save_ct] = 5;
                      save_const[save_ct] = v2max;
                      save_ct++;
                    }
                 }
             }
            i++;
            save_used = FALSE;
         } while ((i < savemax) && (save_connect[i] != -1) && (save_ct < 2));

        tot_xout = 0;
        if (save_ct == 2)
         {
           if (save_found[0] == save_found[1])
              save_ct = 0;
           else
              n_int = 2;

         }
        if (save_ct < 2)
         {
           dist1 = 0;
           dist2 = 0;
           temp1 = jjj * (unum1 - 1) + iii;
           temp2 = jj * (unum2 - 1) + ii;
           for (k=0;k < 3;k++)
            {
              qpt1[0][k] = netpt1[net1][k];
              qpt1[1][k] = netpt1[net1 + 1][k];
              qpt1[2][k] = netpt1[net1 + unum1][k];
              qpt1[3][k] = netpt1[net1 + unum1 + 1][k];

              qpt2[0][k] = netpt2[net2][k];
              qpt2[1][k] = netpt2[net2 + 1][k];
              qpt2[2][k] = netpt2[net2 + unum2][k];
              qpt2[3][k] = netpt2[net2 + unum2 + 1][k];

              avgpt1[k] = (qpt1[0][k] + qpt1[1][k] + qpt1[2][k] +
                           qpt1[3][k]) / 4.0;
              dist = midpt1[temp1][k] - avgpt1[k];
              dist1 += (dist * dist);

              avgpt2[k] = (qpt2[0][k] + qpt2[1][k] + qpt2[2][k] +
                           qpt2[3][k]) / 4.0;
              dist = midpt2[temp2][k] - avgpt2[k];
              dist2 += (dist * dist);
            }
           dist1 = sqrt(dist1);
           dist2 = sqrt(dist2);
           if (dist1 < chrdht_tol)
              dist1 = chrdht_tol;

           if (dist2 < chrdht_tol)
              dist2 = chrdht_tol;
           
           if (dist2 > dist1)  /* Use maximum distance */
              dist1 = dist2;

           /* NOTE: The distance passed into BSsquadln is the largest  */
           /*       distance between the average of the four quad     */
           /*       points and the corresponding evaluated midpoint   */
           /*       on the surface. If this distance is less than     */
           /*       chord height tolerance, it is set to chord height */
           /*       tolerance                                         */

           /* Calculate proper quad tolerance for similar points */

           qdist[0] = 0;
           qdist[1] = 0;
           qdist[2] = 0;
           qdist[3] = 0;

           for (i=0;i < 3;i++)
            {
               dx = qpt1[1][i] - qpt1[0][i];
               qdist[0] += (dx * dx);
               dx = qpt1[2][i] - qpt1[0][i];
               qdist[1] += (dx * dx);

               dx = qpt2[1][i] - qpt2[0][i];
               qdist[2] += (dx * dx);
               dx = qpt2[2][i] - qpt2[0][i];
               qdist[3] += (dx * dx);
            }
           quad_tol = 10000;
           for (i=0;i < 3;i++)
            {
              if ((qdist[i] < quad_tol) && (qdist[i] >= dist_sqtol))
                 quad_tol = qdist[i];
            }
           quad_tol /= 100;

           for (i=0;i < 8;i++)
               xout[i] = FALSE;

           n_int = save_ct;

           if (fabs(v2min - tempv2[0]) > knot_tol2)
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt2[0][k];
                 temp_pts[1][k] = qpt2[1][k];
               }

              BSsquadln( qpt1, temp_pts, dist1, &xnum, xpts[0], 
                        &paru1[0], &parv1[0], &paru2[0], &xout[0], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[0])
                  {
                    tempu1[n_int] = u1min + paru1[0] * (u1max - u1min);
                    tempv1[n_int] = v1min + parv1[0] * (v1max - v1min);
                    tempu2[n_int] = u2min + paru2[0] * (u2max - u2min);
                    tempv2[n_int] = v2min;
   
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[0][0];
                        dy = int_pts[0][1] - xpts[0][1];
                        dz = int_pts[0][2] - xpts[0][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if (dist < quad_tol)
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 4;
                       option[n_int] = 3;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[0][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[0] = 3;
                     xconst[0] = 4;
                     paru1[0] = u1min + paru1[0] * (u1max - u1min);
                     parv1[0] = v1min + parv1[0] * (v1max - v1min);
                     paru2[0] = u2min + paru2[0] * (u2max - u2min);
                     parv2[0] = v2min;
                  }
               }
              else
                 xout[0] = FALSE;
            }

           if ((fabs(v2max - tempv2[0]) > knot_tol2) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt2[2][k];
                 temp_pts[1][k] = qpt2[3][k];
               }
              BSsquadln( qpt1, temp_pts, dist1, &xnum, xpts[1], 
                        &paru1[1], &parv1[1], &paru2[1], &xout[1], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[1])
                  {
                    tempu1[n_int] = u1min + paru1[1] * (u1max - u1min);
                    tempv1[n_int] = v1min + parv1[1] * (v1max - v1min);
                    tempu2[n_int] = u2min + paru2[1] * (u2max - u2min);
                    tempv2[n_int] = v2max;
   
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[1][0];
                        dy = int_pts[0][1] - xpts[1][1];
                        dz = int_pts[0][2] - xpts[1][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if (dist < quad_tol)
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 5;
                       option[n_int] = 3;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[1][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[1] = 3;
                     xconst[1] = 5;
                     paru1[1] = u1min + paru1[1] * (u1max - u1min);
                     parv1[1] = v1min + parv1[1] * (v1max - v1min);
                     paru2[1] = u2min + paru2[1] * (u2max - u2min);
                     parv2[1] = v2max;
                  }        
               }
              else
                 xout[1] = FALSE;
            }

           if ((fabs(u2min - tempu2[0]) > knot_tol2) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt2[0][k];
                 temp_pts[1][k] = qpt2[2][k];
               }
              BSsquadln( qpt1, temp_pts, dist1, &xnum, xpts[2], 
                        &paru1[2], &parv1[2], &parv2[2], &xout[2], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[2])
                  {
                    tempu1[n_int] = u1min + paru1[2] * (u1max - u1min);
                    tempv1[n_int] = v1min + parv1[2] * (v1max - v1min);
                    tempu2[n_int] = u2min;
                    tempv2[n_int] = v2min + parv2[2] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[2][0];
                        dy = int_pts[0][1] - xpts[2][1];
                        dz = int_pts[0][2] - xpts[2][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if (dist < quad_tol)
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 6;
                       option[n_int] = 2;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[2][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[2] = 2;
                     xconst[2] = 6;
                     paru1[2] = u1min + paru1[2] * (u1max - u1min);
                     parv1[2] = v1min + parv1[2] * (v1max - v1min);
                     paru2[2] = u2min;
                     parv2[2] = v2min + parv2[2] * (v2max - v2min);
                  }        
               }
              else
                 xout[2] = FALSE;
            }

           if ((fabs(u2max - tempu2[0]) > knot_tol2) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt2[1][k];
                 temp_pts[1][k] = qpt2[3][k];
               }
              BSsquadln( qpt1, temp_pts, dist1, &xnum, xpts[3], 
                        &paru1[3], &parv1[3], &parv2[3], &xout[3], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[3])
                  {
                    tempu1[n_int] = u1min + paru1[3] * (u1max - u1min);
                    tempv1[n_int] = v1min + parv1[3] * (v1max - v1min);
                    tempu2[n_int] = u2max;
                    tempv2[n_int] = v2min + parv2[3] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[3][0];
                        dy = int_pts[0][1] - xpts[3][1];
                        dz = int_pts[0][2] - xpts[3][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if (dist < quad_tol)
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 7;
                       option[n_int] = 2;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[3][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[3] = 2;
                     xconst[3] = 7;
                     paru1[3] = u1min + paru1[3] * (u1max - u1min);
                     parv1[3] = v1min + parv1[3] * (v1max - v1min);
                     paru2[3] = u2max;
                     parv2[3] = v2min + parv2[3] * (v2max - v2min);
                  }        
               }
              else
                 xout[3] = FALSE;
            }

           if ((fabs(v1min - tempv1[0]) > knot_tol1) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt1[0][k];
                 temp_pts[1][k] = qpt1[1][k];
               }
              BSsquadln( qpt2, temp_pts, dist1, &xnum, xpts[4], 
                        &paru2[4], &parv2[4], &paru1[4], &xout[4], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[4])
                  {
                    tempu1[n_int] = u1min + paru1[4] * (u1max - u1min);
                    tempv1[n_int] = v1min;
                    tempu2[n_int] = u2min + paru2[4] * (u2max - u2min);
                    tempv2[n_int] = v2min + parv2[4] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[4][0];
                        dy = int_pts[0][1] - xpts[4][1];
                        dz = int_pts[0][2] - xpts[4][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if ((dist < quad_tol && save_ct != 0 ) || 
                             (save_ct == 0 && dist < dist_sqtol) )
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 0;
                       option[n_int] = 1;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[4][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[4] = 1;
                     xconst[4] = 0;
                     paru1[4] = u1min + paru1[4] * (u1max - u1min);
                     parv1[4] = v1min;
                     paru2[4] = u2min + paru2[4] * (u2max - u2min);
                     parv2[4] = v2min + parv2[4] * (v2max - v2min);
                  }        
               }
              else
                 xout[4] = FALSE;
            }

           if ((fabs(v1max - tempv1[0]) > knot_tol1) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt1[2][k];
                 temp_pts[1][k] = qpt1[3][k];
               }
              BSsquadln( qpt2, temp_pts, dist1, &xnum, xpts[5], 
                        &paru2[5], &parv2[5], &paru1[5], &xout[5], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {    
                 if ( !xout[5])
                  {
                    tempu1[n_int] = u1min + paru1[5] * (u1max - u1min);
                    tempv1[n_int] = v1max;
                    tempu2[n_int] = u2min + paru2[5] * (u2max - u2min);
                    tempv2[n_int] = v2min + parv2[5] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[5][0];
                        dy = int_pts[0][1] - xpts[5][1];
                        dz = int_pts[0][2] - xpts[5][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if ((dist < quad_tol && save_ct != 0 ) || 
                             (save_ct == 0 && dist < dist_sqtol) )
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 1;
                       option[n_int] = 1;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[5][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[5] = 1;
                     xconst[5] = 1;
                     paru1[5] = u1min + paru1[5] * (u1max - u1min);
                     parv1[5] = v1max;
                     paru2[5] = u2min + paru2[5] * (u2max - u2min);
                     parv2[5] = v2min + parv2[5] * (v2max - v2min);
                  }        
               }
              else
                 xout[5] = FALSE;
            }

           if ((fabs(u1min - tempu1[0]) > knot_tol1) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt1[0][k];
                 temp_pts[1][k] = qpt1[2][k];
               }
              BSsquadln( qpt2, temp_pts, dist1, &xnum, xpts[6], 
                        &paru2[6], &parv2[6], &parv1[6], &xout[6], rc);
              if (BSERROR(*rc))
                 goto wrapup;

              if (xnum > 0) 
               {
                 if (! xout[6])
                  {
                    tempu1[n_int] = u1min;
                    tempv1[n_int] = v1min + parv1[6] * (v1max - v1min);
                    tempu2[n_int] = u2min + paru2[6] * (u2max - u2min);
                    tempv2[n_int] = v2min + parv2[6] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[6][0];
                        dy = int_pts[0][1] - xpts[6][1];
                        dz = int_pts[0][2] - xpts[6][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if ((dist < quad_tol && save_ct != 0 ) || 
                             (save_ct == 0 && dist < dist_sqtol) )
                          same = TRUE;
                     }
                    if (! same)
                     {
                       constt[n_int] = 2;
                       option[n_int] = 0;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[6][i];

                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[6] = 0;
                     xconst[6] = 2;
                     paru1[6] = u1min;
                     parv1[6] = v1min + parv1[6] * (v1max - v1min);
                     paru2[6] = u2min + paru2[6] * (u2max - u2min);
                     parv2[6] = v2min + parv2[6] * (v2max - v2min);
                  }        
               }
              else
                 xout[6] = FALSE;
            }

           if ((fabs(u1max - tempu1[0]) > knot_tol1) && (n_int < 2))
            {
              for (k=0;k < 3;k++)
               {
                 temp_pts[0][k] = qpt1[1][k];
                 temp_pts[1][k] = qpt1[3][k];
               }
              BSsquadln( qpt2, temp_pts, dist1, &xnum, xpts[7], 
                        &paru2[7], &parv2[7], &parv1[7], &xout[7], rc);
              if (BSERROR(*rc))
                 goto wrapup;
   
              if (xnum > 0) 
               {
                 if (! xout[7])
                  {
                    tempu1[n_int] = u1max;
                    tempv1[n_int] = v1min + parv1[7] * (v1max - v1min);
                    tempu2[n_int] = u2min + paru2[7] * (u2max - u2min);
                    tempv2[n_int] = v2min + parv2[7] * (v2max - v2min);
                    same = FALSE;
                    if (n_int > 0)
                     {
                        dx = int_pts[0][0] - xpts[7][0];
                        dy = int_pts[0][1] - xpts[7][1];
                        dz = int_pts[0][2] - xpts[7][2];
                        dist = dx * dx + dy * dy + dz * dz;
                        if ((dist < quad_tol && save_ct != 0 ) || 
                             (save_ct == 0 && dist < dist_sqtol) )
                          same = TRUE;
                     }
                    if (! same)
                     {                                     
                       constt[n_int] = 3;
                       option[n_int] = 0;
                       for (i=0;i<3;i++)
                          int_pts[n_int][i] = xpts[7][i];
                       n_int++;
                     }
                  }
                 else
                  {
                     tot_xout++;
                     xoption[7] = 0;
                     xconst[7] = 3;
                     paru1[7] = u1max;
                     parv1[7] = v1min + parv1[7] * (v1max - v1min);
                     paru2[7] = u2min + paru2[7] * (u2max - u2min);
                     parv2[7] = v2min + parv2[7] * (v2max - v2min);
                  }        
               }
              else
                  xout[7] = FALSE;
            }
         }
          
        i = 0;
        while ((n_int < 2) && (i < 8) && (tot_xout > 0))
         {
            if (xout[i])
             {
                same = FALSE;
                if (n_int > 0)
                 {
                    dx = int_pts[0][0] - xpts[i][0];
                    dy = int_pts[0][1] - xpts[i][1];
                    dz = int_pts[0][2] - xpts[i][2];
                    dist = dx * dx + dy * dy + dz * dz;
                    if (dist < quad_tol)
                      same = TRUE;
                 }
                if (! same)
                 {
                   constt[n_int] = xconst[i];
                   option[n_int] = xoption[i];
                   tempu1[n_int] = paru1[i];
                   tempv1[n_int] = parv1[i];
                   tempu2[n_int] = paru2[i];
                   tempv2[n_int] = parv2[i];
                   for (j=0;j < 3;j++)
                      int_pts[n_int][j] = xpts[i][j];
                   n_int++;
                   tot_xout--;
                 }
             }
            i++;
         }

        pt_iter = TRUE;
        if (save_ct == 2)
          goto two_points;

        zero:if (n_int == 0) 
         {
           no_int[no_num][no_ct] = iii;
           no_int[no_num][no_ct + 1] = jjj;
           no_int[no_num][no_ct + 2] = ii;
           no_int[no_num][no_ct + 3] = jj;                     
           no_ct += 4;

           if (no_ct == 400)
            {
               if (no_num == (nalloc_noint - 1))
                {
                   new_alloc = nalloc_noint + NOINTNUM;
                   new_noint = (IGRint **)BSstackalloc((unsigned)
                         (new_alloc * sizeof(IGRint *)));
                   if (! new_noint)
                    {
                       *rc = BSNOMEMORY;
                       goto wrapup;
                    }
                   BSMEMCPY( (nalloc_noint * sizeof(IGRint *)),
                             (IGRchar *) no_int, (IGRchar *) new_noint );
                   BSstackdealloc((char *)no_int);
                   no_int = new_noint;
                   nalloc_noint += NOINTNUM;
                }
              no_num++;
              no_ct = 0;
              no_int[no_num] = (IGRint *)BSstackalloc((unsigned)
                                               (400 * sizeof(IGRint)));
            }
         }
        else if (n_int > 0)
         {
           num_out = 0;
           if (save_ct == n_int)
            {
              BSxcvsfbxop( s1, s2, u1min, u1max, v1min, v1max, u2min, 
                           u2max, v2min, v2max, urng1, vrng1, urng2, vrng2,
                           knot_tol1, knot_tol2, off_opt, n1, n2, off1,
                           off2, int_pts[0], save_found[0], &pt_found,
                           int_pts[1], &tempu1[1], &tempv1[1], &tempu2[1],
                           &tempv2[1], rc );
              if (BSERROR(*rc))
                 goto wrapup;
                                 
              if (pt_found)
                 n_int++;
              else
               {
                 n_int -= 1;
                 goto zero;
               }
            }
           else if (pt_iter)
            {
              for (k=save_ct;k < n_int;k++)
               {
                 if (off_opt)
                  {
                    BSofcvsfitr( s1, s2, urng1, vrng1, urng2, vrng2, option[k],
                                 off1, off2, n1, n2, knot_tol1, knot_tol2,
                                 int_pts[k], &tempu1[k], &tempv1[k],
                                 &tempu2[k], &tempv2[k], &isuccess, rc );
                    if (BSERROR(*rc))
                       goto wrapup;
                  }
                 else
                  {
                    BScvsfiter( s1, s2, option[k], u1_closed, v1_closed,
                                u2_closed, v2_closed, knot_tol1, knot_tol2, 
                                int_pts[k], &tempu1[k], &tempv1[k],
                                &tempu2[k], &tempv2[k], &isuccess, rc );
                    if (BSERROR(*rc))
                       goto wrapup;
                  }

                 if (! isuccess)
                  {
                    if ((n_int == 2) && (save_ct == 0))
                     {
                       if (k == 0)
                        {
                          tempu1[0] = tempu1[1];
                          tempv1[0] = tempv1[1];
                          tempu2[0] = tempu2[1];
                          tempv2[0] = tempv2[1];
                          int_pts[0][0] = int_pts[1][0];
                          int_pts[0][1] = int_pts[1][1];
                          int_pts[0][2] = int_pts[1][2];
                          constt[0] = constt[1];
                          option[0] = option[1];
                        }
                       else
                          pt_iter = FALSE;
                     }
                    n_int -= 1;
                    goto zero;
                  }

                 BScvsfckrng( u1min, u1max, v1min, v1max, u2min, u2max,
                              v2min, v2max, knot_tol1, knot_tol2, &tempu1[k], 
                              &tempv1[k], &tempu2[k], &tempv2[k], &num_out, 
                              &out_of_range, rc );
                 if (BSERROR(*rc))
                    goto wrapup;

                 if (num_out > 0)
                  {
                    if (num_out == 1)
                     {
                       if ((constt[k] == 0) || (constt[k] == 1))
                          tempv1[k] = .5 * (v1min + v1max);
                       else if ((constt[k] == 2) || (constt[k] == 3))
                          tempu1[k] = .5 * (u1min + u1max);
                       else if ((constt[k] == 4) || (constt[k] == 5))
                          tempv2[k] = .5 * (v2min + v2max);
                       else
                          tempu2[k] = .5 * (u2min + u2max);

                       num_out = 0;

                       if (off_opt)
                        {
                          BSofcvsfitr( s1, s2, urng1, vrng1, urng2, vrng2,
                                       out_of_range, off1, off2, n1,
                                       n2, knot_tol1, knot_tol2, int_pts[k],
                                       &tempu1[k], &tempv1[k], &tempu2[k],
                                       &tempv2[k], &isuccess, rc );
                          if (BSERROR(*rc))
                             goto wrapup;
                        }
                       else
                        {
                          BScvsfiter( s1, s2, out_of_range, u1_closed,
                                      v1_closed, u2_closed, v2_closed,
                                      knot_tol1, knot_tol2, int_pts[k],
                                      &tempu1[k], &tempv1[k], &tempu2[k],
                                      &tempv2[k], &isuccess, rc );
                          if (BSERROR(*rc))
                             goto wrapup;
                        }
                     }
                    if ((! isuccess) || (num_out > 1))
                     {
                       if ((n_int == 2) && (save_ct == 0))
                        {
                          if (k == 0)
                           {
                             tempu1[0] = tempu1[1];
                             tempv1[0] = tempv1[1];
                             tempu2[0] = tempu2[1];
                             tempv2[0] = tempv2[1];
                             int_pts[0][0] = int_pts[1][0];
                             int_pts[0][1] = int_pts[1][1];
                             int_pts[0][2] = int_pts[1][2];
                             constt[0] = constt[1];
                             option[0] = option[1];
                           }
                          else
                             pt_iter = FALSE;
                        }
                       n_int -= 1;
                       goto zero;
                     }

                    BScvsfckrng( u1min, u1max, v1min, v1max, u2min, u2max, 
                                 v2min, v2max, knot_tol1, knot_tol2, 
                                 &tempu1[k], &tempv1[k], &tempu2[k], 
                                 &tempv2[k], &num_out, &out_of_range, rc );
                    if (BSERROR(*rc))
                       goto wrapup;

                    if (num_out > 0)
                     {
                       if ((n_int == 2) && (save_ct == 0)) 
                        {
                          if (k == 0)
                           {
                             tempu1[0] = tempu1[1];
                             tempv1[0] = tempv1[1];
                             tempu2[0] = tempu2[1];
                             tempv2[0] = tempv2[1];
                             int_pts[0][0] = int_pts[1][0];
                             int_pts[0][1] = int_pts[1][1];
                             int_pts[0][2] = int_pts[1][2];
                             constt[0] = constt[1];
                             option[0] = option[1];
                           }
                          else
                             pt_iter = FALSE;
                        }
                       n_int -= 1;
                       goto zero;

                     } /* num_out > 0 */
                  } /* num_out > 0 */
               } /* end for */
            } /* else pt_iter */

           if (n_int == 2)
            {
              dx = int_pts[0][0] - int_pts[1][0];
              dy = int_pts[0][1] - int_pts[1][1];
              dz = int_pts[0][2] - int_pts[1][2];
              dist = dx * dx + dy * dy + dz * dz;
              if (dist < same_dist_sqtol)
               {
                 BSxcvsfbxop( s1, s2, u1min, u1max, v1min, v1max, u2min, 
                              u2max, v2min, v2max, urng1, vrng1, urng2, 
                              vrng2, knot_tol1, knot_tol2, off_opt, n1,
                              n2, off1, off2, int_pts[0], temp_const,
                              &pt_found, int_pts[1], &tempu1[1],
                              &tempv1[1], &tempu2[1], &tempv2[1], rc );
                 if (BSERROR(*rc))
                    goto wrapup;
                                 
                 if (! pt_found)
                  {
                    n_int = 0;
                    goto zero;
                  }
               }
            }

           if ((save_ct == 0) && (n_int == 1))
            {
              BSxcvsfbxop( s1, s2, u1min, u1max, v1min, v1max, u2min, 
                           u2max, v2min, v2max, urng1, vrng1, urng2, vrng2,
                           knot_tol1, knot_tol2, off_opt, n1, n2, off1, off2,
                           int_pts[0], constt[0], &pt_found, int_pts[1],
                           &tempu1[1], &tempv1[1], &tempu2[1], &tempv2[1],
                           rc );
              if (BSERROR(*rc))
                 goto wrapup;
                                 
              if (pt_found)
                 n_int++;
              else
               {
                 n_int = 0;
                 goto zero;
               }
            }
         } /* n_int > 0 */

        two_points:if (n_int == 2)
         {
            dx = int_pts[0][0] - int_pts[1][0];
            dy = int_pts[0][1] - int_pts[1][1];
            dz = int_pts[0][2] - int_pts[1][2];
            dist = dx * dx + dy * dy + dz * dz;
            if (dist > same_dist_sqtol)
             {

               sameBSpch_intop( numarr, numseg, pchseg, int_pts, 
                              same_dist_sqtol, &same_ct );

               if (same_ct < 2)
                {
                  var1 = jjj * 2 * (unum1 - 1) + (iii * 2);
                  var2 = jj * 2 * (unum2 - 1) + (ii * 2);

                  tinsert[0] = insert1[var1];
                  tinsert[1] = insert1[var1 + 1];
                  tinsert[2] = insert2[var2];
                  tinsert[3] = insert2[var2 + 1];

                  BSpch_trcop( s1, s2, tempu1, tempv1, tempu2, tempv2, 
                               int_pts, min_max, rngs, knot_tol1, knot_tol2,
                               tinsert, off_opt, off1, off2, n1, n2,
                               sq_cht, &nalloc_ind, &index, &nalloc_pts,
                               &wrk_space, &(*pchseg)[*numarr][*numseg], rc );
                  if (*rc == BSNOSOLUTION)
                     *rc = BSSUCC;
                  else if (BSERROR(*rc))
                     goto wrapup;
                  else
                   {
                     for (i=0;i < n_int;i++)
                      {
                        saveBSpch_intop( savemax, save_pts, save_par1, 
                                       save_par2, save_connect, 
                                       tempu1[i], tempv1[i], tempu2[i],
                                       tempv2[i], int_pts[i], 
                                       same_dist_sqtol, &t_ind[i] );
                      }
                     for (k=0;k < save_ct;k++)
                        save_connect[save_ind[k]] += 1;

                     for (k=save_ct;k < n_int;k++)
                        save_connect[t_ind[k]] += 1;

                     (*numseg)++;
                   }
                  if (*numseg == 50)
                   {
                      if (*numarr == (nalloc_pchseg - 1))
                       {
                          new_alloc = nalloc_pchseg + PCHSEGNUM;
                          new_pchseg = 
                           (struct BSlnseg **)BSmalloc((unsigned)(new_alloc * 
                                 sizeof(struct BSlnseg *)));
                          if (! new_pchseg)
                           {
                              *rc = BSNOMEMORY;
                              goto wrapup;
                           }
                          BSMEMCPY((nalloc_pchseg * sizeof(struct BSlnseg *)),
                                  (IGRchar *) *pchseg, (IGRchar *) new_pchseg);
                          BSdealloc((char *)*pchseg);
                          *pchseg = new_pchseg;
                          nalloc_pchseg += PCHSEGNUM;
                       }
                      (*numarr)++;
                      *numseg = 0;
                      (*pchseg)[*numarr] = 
                        (struct BSlnseg *)BSmalloc((unsigned)
                        (50 * sizeof(struct BSlnseg)));
                      if (! (*pchseg)[*numarr])
                       {
                         *rc = BSNOMEMORY;
                         goto wrapup;
                       }
                   }
                } /* Check for duplicate end points */
               else
                {
                  n_int = 0;
                  goto zero;
                }
             } /* same_ct < 2 */
            else
             {
                n_int = 0;
                goto zero;
             }
         } /* n_int == 2 */
     } /* q loop */
 } /* qq loop */

/* Recover any points remaining in save array which are in the */
/*  range of overlapping boxes that had no intersections       */

s1_umin = upar1[0];
s1_umax = upar1[unum1 - 1];
s1_vmin = vpar1[0];
s1_vmax = vpar1[vnum1 - 1];

s2_umin = upar2[0];
s2_umax = upar2[unum2 - 1];
s2_vmin = vpar2[0];
s2_vmax = vpar2[vnum2 - 1];

for (i=0;i <= no_num;i++)
 {
    if (i == no_num)
       tcount = no_ct;
    else
       tcount = 400;

    for (j=0;j < tcount;j=j+4)
     {
        sub0 = no_int[i][j];
        sub1 = no_int[i][j + 1];
        sub2 = no_int[i][j + 2];
        sub3 = no_int[i][j + 3];

        n_int = 0;

        min_max[0] = u1min = upar1[sub0];
        min_max[4] = u1max = upar1[sub0 + 1];
        min_max[1] = v1min = vpar1[sub1];
        min_max[5] = v1max = vpar1[sub1 + 1];
        min_max[2] = u2min = upar2[sub2];
        min_max[6] = u2max = upar2[sub2 + 1];
        min_max[3] = v2min = vpar2[sub3];
        min_max[7] = v2max = vpar2[sub3 + 1];

        k=0;
        do
         {
            if ((save_connect[k] == 0) || (save_connect[k] == 1))
             {
                parBSpch_intop( u1min, u1max, s1_umin, s1_umax, knot_tol1,
                              u1_closed, &save_par1[k][0], &out );
                if (! out )
                 {
                    parBSpch_intop( v1min, v1max, s1_vmin, s1_vmax, 
                                  knot_tol1, v1_closed, &save_par1[k][1], 
                                  &out );
                    if (! out )
                     {
                        parBSpch_intop( u2min, u2max, s2_umin, s2_umax,
                                      knot_tol2, u2_closed, 
                                      &save_par2[k][0], &out );
                        if (! out )
                         {
                            parBSpch_intop( v2min, v2max, s2_vmin, s2_vmax,
                                          knot_tol2, v2_closed,
                                          &save_par2[k][1], &out );
                         }
                     }
                 }
 
                if (! out )
                 {
                   tempu1[n_int] = save_par1[k][0];
                   tempv1[n_int] = save_par1[k][1];
                   tempu2[n_int] = save_par2[k][0];
                   tempv2[n_int] = save_par2[k][1];
                   for (ii=0;ii < 3;ii++)
                    {
                       int_pts[n_int][ii] = save_pts[k][ii];
                    }
                   save_found[n_int] = k;
                   n_int++;
                   if (n_int == 2)
                      break;
                 }
             }
            k++;
         } while ((k < savemax) && (save_connect[k] != -1));
        if (n_int == 2)
         {
           sameBSpch_intop( numarr, numseg, pchseg, int_pts, 
                          same_dist_sqtol, &same_ct );

           if (same_ct < 2)
            {
               save_connect[save_found[0]] += 1;
               save_connect[save_found[1]] += 1;
               temp1 = sub1 * 2 * (unum1 - 1) + (sub0 * 2);
               temp2 = sub3 * 2 * (unum2 - 1) + (sub2 * 2);

               tinsert[0] = insert1[temp1];
               tinsert[1] = insert1[temp1 + 1];
               tinsert[2] = insert2[temp2];
               tinsert[3] = insert2[temp2 + 1];

               BSpch_trcop( s1, s2, tempu1, tempv1, tempu2, tempv2, int_pts, 
                            min_max, rngs, knot_tol1, knot_tol2, tinsert, 
                            off_opt, off1, off2, n1, n2, sq_cht, &nalloc_ind,
                            &index, &nalloc_pts, &wrk_space, 
                            &(*pchseg)[*numarr][*numseg], rc );
               if (BSERROR(*rc))
                  goto wrapup;
  
               (*numseg)++;
               if (*numseg == 50)
                {
                   if (*numarr == (nalloc_pchseg - 1))
                    {
                       new_alloc = nalloc_pchseg + PCHSEGNUM;
                       new_pchseg = (struct BSlnseg **)BSmalloc((unsigned)
                       (new_alloc * sizeof(struct BSlnseg *)));
                       if (! new_pchseg)
                        {
                           *rc = BSNOMEMORY;
                           goto wrapup;
                        }
                       BSMEMCPY((nalloc_pchseg * sizeof (struct BSlnseg *)),
                                 (IGRchar *) *pchseg, (IGRchar *) new_pchseg );
                       BSdealloc((char *)*pchseg);
                       *pchseg = new_pchseg;
                       nalloc_pchseg += PCHSEGNUM;
                    }
                   (*numarr)++;
                   *numseg = 0;
                   (*pchseg)[*numarr] = 
                      (struct BSlnseg *)BSmalloc((unsigned)
                      (50 * sizeof(struct BSlnseg)));
                   if (! (*pchseg)[*numarr])
                    {
                      *rc = BSNOMEMORY;
                      goto wrapup;
                    }
                }
             }
         }
     }
 }
wrapup:
 if (wrk_space)
   BSdealloc((char *)wrk_space );
 if (index)
   BSdealloc((char *)index );

 for (i=0;i <=no_num;i++)
  {
     if (no_int[i])
        BSstackdealloc((char *)no_int[i]);
  }
 if (no_int)
    BSstackdealloc((char *)no_int);

 if(BSERROR(*rc))
    BSdbgrc(*rc,"BSpch_intop");
 return;
}
