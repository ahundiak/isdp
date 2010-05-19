/*****************************************************************************
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdptbscv1

Abstract
    This routine computes the minimum distance between points
    and a B-spline curve. 

Synopsis
    void BSmdptbscv1(ndeg,ndim,irat,npoles,poles,knots,npt,pt,tol,
                     dsup,mdist,par,bas_pt,rc)

    IGRint                ndeg,
    IGRint                ndim,
    IGRint                irat,
    IGRint                npoles,
    IGRdouble             *poles,
    IGRdouble             *knots,
    IGRint                npt,
    IGRdouble             *pt,
    IGRdouble             tol,
    IGRdouble             dsup,
    IGRdouble             *mdist,
    IGRdouble             *par,
    IGRdouble             *bas_pt,
    BSrc                  *rc;

Description
    Input:
      ndeg - degree of the curve
      npoles - number of poles of the curve
      ndim - dimension of the curve
      irat - 1, rational curve; 0, non-rational curve
      poles - coefficients of the curve, stored in a C-array
              poles[ndim+irat][npoles]
      knots[ndeg + npoles + 1] - knots of the B-spline curve
      pt - the given point
      tol - tolerance
      dsup - upper bounds of distance, dsup
              we only look for solutions with mdist < dsup

    Input/Output:

    Output:
      mdist - new minimum distances.
      par  - parameter yielding the minimum distances.
      bas_pts - points on the curve that yield the minimum distances.
      *rc - return codes
            == BSSUCC if successful

    Algorithm:
      Given a non-uniform B-spline curve, this routine repeatly sbdivides
      the curve until obtaining a Bezier curve which yields a minimum 
      distance.

Return Values
    NA

Notes
    We do not necessarily find all solutions. See BSmdptbscv as
    the actual function doing this job.

Index
    md

Keywords
    minimum distance point B-spline curve.

History
    M. Rahmig  06/24/1996  : created, derived from mindstBSmdptbscv
    Vivian Hsu 05/05/1997  : To Avoid overflow problem, if dsup[i]
                             is MAXDOUBLE, Should not do any
                             operation with it.
    Vivian Hsu 3/26/1998   : Modified from BSmdptbscvg but only for one
                             point temporary.
******************************************************************************
*/

#include <math.h>
#include "bs.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bsvalues.h"

#define MAXPBAGSIZE 1000000
#define MAXUBAGSIZE 1000000

/* Main routine */

void BSmdptbscv1(
IGRint                ndeg,
IGRint                ndim,
IGRint                irat,
IGRint                npoles,
IGRdouble             *poles,
IGRdouble             *knots,
IGRint                npt,
IGRdouble             *pt,
IGRdouble             tol,
IGRdouble             dsup,
IGRdouble             *mdist,
IGRdouble             *par,
IGRdouble             *bas_pt,
BSrc                  *rc
                )

{
#include "bsdbgrc.h"
#include "bshlfbspcv.h"
#include "bsmdptbzcv.h"
#include "bsminmaxbsc.h"
#include "bsdcdbsp12.h"

  IGRdouble           tmin,tmax;
  IGRint              loc_npoles,loc_nknots;
  IGRint              npole_lt,npole_rt;
  IGRint              istk,jj;
  IGRint              left ;
  IGRboolean          ifound = FALSE;
  IGRboolean          isol;
  IGRint              order;
  IGRint              max_curv;
  IGRint              nknots;
  IGRint              sz_polebagr;
  IGRint              sz_knotbagr;
  IGRdouble           **polebag = NULL;
  IGRdouble           **knotbag = NULL;
  IGRdouble           *polebagr = NULL;
  IGRdouble           *knotbagr = NULL;
  IGRdouble           *pole_lt = NULL;
  IGRdouble           *pole_rt = NULL;
  IGRdouble           *knot_lt = NULL;
  IGRdouble           *knot_rt = NULL;
  IGRdouble           *pole_ptr = NULL;
  IGRdouble           *knot_ptr = NULL;
  IGRdouble           dmin2;
  IGRdouble           dmax2;
  IGRdouble           loc_dsup;
  IGRchar             *bigspace1 = NULL;
  IGRchar             *big_space = NULL;
  IGRint              *npoltab = NULL;
  IGRchar             iok = 1;
  IGRint              ndimrat;
  IGRint              sz_poles,sz_bez,npoldim,nkts;
  IGRint              total_poles,total_knots;
  BSrc                rc1 = BSSUCC;

  *rc = BSSUCC;
  jj = npt; /* To avoid compiler warning */

  order = ndeg + 1 ;
  ndimrat = ndim + irat;
  max_curv = npoles - ndeg;
  nknots = npoles + order;
  sz_poles = npoles*ndimrat ;
  sz_bez = order * ndimrat;
  sz_polebagr = sz_bez * max_curv;
  sz_knotbagr = 2 * order * max_curv;

/*
 * Handle special case Bezier curve
 */
  if (npoles == order) 
  {
    BSmdptbzcv(ndeg,ndim,irat,poles,1,pt,tol,&dsup,mdist,&iok,&loc_dsup,
               mdist,par,bas_pt,&rc1,rc);
    if (*rc == BSSUCC && rc1 == BSSUCC)
    {
      ifound = TRUE ;
    }
    goto wrapup;
  }


/*
 * Reduce the bagsizes if the upper limits are exceeded
 */
  if (sz_polebagr > MAXPBAGSIZE)
    sz_polebagr = MAXPBAGSIZE;
  if (sz_knotbagr > MAXUBAGSIZE)
    sz_knotbagr = MAXUBAGSIZE;

/*
 * Allocate memory
 */

  big_space = BSstackalloc((unsigned)(3 * max_curv * sizeof(IGRint)));
  if (!big_space)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  polebag = (IGRdouble **)big_space;
  knotbag = (IGRdouble **)polebag + max_curv;
  npoltab = (IGRint *)knotbag + max_curv;

  bigspace1 = BSstackalloc((unsigned)(sz_polebagr + sz_knotbagr + 
                        2 * sz_poles + 2 * nknots) * sizeof(IGRdouble));
  if (!bigspace1)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  polebagr = (IGRdouble *)bigspace1;
  knotbagr = (IGRdouble *)polebagr + sz_polebagr;
  pole_lt = (IGRdouble *)knotbagr + sz_knotbagr;
  pole_rt = (IGRdouble *)pole_lt + sz_poles;
  knot_lt = (IGRdouble *)pole_rt + sz_poles;
  knot_rt = (IGRdouble *)knot_lt + nknots;

/*
 * Initialize
 */
  istk = 0;
  knotbag[0] = knotbagr;
  polebag[0] = polebagr;  
  npoltab[0] = npoles;
  total_poles = 0;
  total_knots = 0;
  loc_dsup = dsup;
  BSMEMCPY((IGRint)(sz_poles * sizeof(IGRdouble)),
           (IGRchar *)poles,(IGRchar *)polebag[0]);
  BSMEMCPY((IGRint)(nknots * sizeof(IGRdouble)),
           (IGRchar *)knots,(IGRchar *)knotbag[0]);

/*
 * Nonrecursive loop starts here
 */
debut:
  while (istk >= 0)
  {
    loc_npoles = npoltab[istk];
    loc_nknots = loc_npoles + order;
    pole_ptr = polebag[istk];
    knot_ptr = knotbag[istk];
    tmin = knot_ptr[0];
    tmax = knot_ptr[loc_nknots-1];

/*
 * Find min-max distances for each point
 */
    isol = FALSE ;
    BSminmaxbsc(ndeg,loc_npoles,ndim,irat,knot_ptr,pole_ptr,1,pt,&iok,
                &dmin2, &dmax2, rc) ;
    if (BSERROR(*rc))
      goto wrapup;

    if (loc_dsup == MAXDOUBLE)
    {
      isol = TRUE;
      loc_dsup = sqrt(dmax2);
    }
    else
    {
      if (dmin2 <= loc_dsup*loc_dsup)
      {
        isol = TRUE ;
        if (dmax2 < loc_dsup*loc_dsup)
          loc_dsup = sqrt(dmax2) ;
      }
    }

    /* Point is not in the box */

    if (FALSE == isol)
    {
      if (istk > 0)
      {
        total_poles -= npoltab[istk-1] * ndimrat;
        total_knots -= (npoltab[istk-1] + order);
      }
      istk--;
      goto debut;
    }

/*
 * Check if B-spline curve degenerates to a Bezier curve
 */
    if (loc_npoles == order)
    {
      BSmdptbzcv(ndeg,ndim,irat,pole_ptr,1,pt,tol,&loc_dsup,mdist,
                 &iok,&loc_dsup,mdist,par,bas_pt,&rc1,rc);
      if (*rc != BSSUCC && *rc != BSNOSOLUTION)
         goto wrapup;
      if (BSSUCC == rc1)
      {
        *par = (tmax - tmin) * *par + tmin ;
        ifound = TRUE;
      }
      *rc = BSSUCC;
      if (istk > 0)
      {
        total_poles -= npoltab[istk-1] * ndimrat;
        total_knots -= (npoltab[istk-1] + order);
      }
      istk--;
      goto debut;
    }

/*
 * Repeatly halve the curve
 */

/*
 * Subdivide the curve  
 */
    jj = loc_nknots / 2;

    BShlfbspcv(ndimrat,ndeg,loc_npoles,pole_ptr,knot_ptr,jj,&npole_lt,
               pole_lt,knot_lt,&npole_rt,pole_rt,knot_rt,rc);
    if (BSERROR(*rc))
      goto wrapup;

/*
 * Determine which halved segment is a candidate
 */
    BSdcdbsp12(ndim,irat,npole_lt,pole_lt,npole_rt,pole_rt,1,pt,&iok,
               &left,rc);
    if (BSERROR(*rc))
      goto wrapup;

    if (left)   /* add the right first */
    {
      npoltab[istk] = npole_rt;
      knot_ptr = knot_rt;
      pole_ptr = pole_rt;
    }
    else
    {
      npoltab[istk] = npole_lt;
      knot_ptr = knot_lt;
      pole_ptr = pole_lt;
    }

    /* Push pole_ptr into polebag[istk][*] */
    /* We do not need check whether the memory is enough, because
       half curve has less poles,knots than the original curve */

    npoldim = npoltab[istk] * ndimrat;
    nkts = npoltab[istk] + order;
    BSMEMCPY((IGRint)(npoldim * sizeof(IGRdouble)),(IGRchar *)pole_ptr,
             (IGRchar *)polebag[istk]);

    /* Push knot_ptr into knotbag[istk][*] */

    BSMEMCPY((IGRint)(nkts * sizeof(IGRdouble)),(IGRchar *)knot_ptr,
            (IGRchar *)knotbag[istk]);

    /* Set address for polebag[istk+1] and knotbag[istk+1] */

    polebag[istk+1] = (IGRdouble *)polebag[istk] + npoldim;
    knotbag[istk+1] = (IGRdouble *)knotbag[istk] + nkts;
    total_poles += npoldim;
    total_knots += nkts;
    istk++;


    /* Now we push the second piece to the bag. */

    if (left)
    {
      npoltab[istk] = npole_lt;
      pole_ptr = pole_lt;
      knot_ptr = knot_lt;
    }
    else
    {
      npoltab[istk] = npole_rt;
      pole_ptr = pole_rt;
      knot_ptr = knot_rt;
    }

    /* We need to check whether there are enough space for
       poles and knots */

    npoldim = npoltab[istk] * ndimrat;
    nkts = npoltab[istk] + order;
    if ((total_poles + npoldim > sz_polebagr) || 
        (total_knots + nkts > sz_knotbagr))
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }

    /* Push pole_ptr into polebag[istk][*] */

    BSMEMCPY((IGRint)(npoldim * sizeof(IGRdouble)),(IGRchar *)pole_ptr,
                 (IGRchar *)polebag[istk]);

    /* Push knot_ptr into knotbag[istk][*] */

    BSMEMCPY((IGRint)(nkts * sizeof(IGRdouble)),(IGRchar *)knot_ptr,
              (IGRchar *)knotbag[istk]);
  }

wrapup:
  if (big_space)
    BSstackdealloc((char *) big_space);

  if (bigspace1)
    BSstackdealloc(bigspace1);

  if (*rc == BSSUCC && ifound == FALSE)
     *rc = BSNOSOLUTION;
  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSmdptbscv1");
  return;
}
