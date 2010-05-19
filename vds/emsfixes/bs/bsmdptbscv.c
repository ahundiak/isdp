/*****************************************************************************
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdptbscv

Abstract
    This routine computes the minimum distance between points
    and a B-spline curve. We set the distance to infinity if
    it is greater than the input upper bound.

Synopsis
    void BSmdptbscv(ndeg,npoles,ndim,irat,poles,knots,npt,pt,tol,dsupai,mdisti,
                    dsupa,mdist,par,bas_pt,rc)

    IGRint                ndeg,
    IGRint                npoles,
    IGRint                ndim,
    IGRint                irat,
    IGRdouble             *poles,
    IGRdouble             *knots,
    IGRint                npt,
    IGRdouble             *pt,
    IGRdouble             tol,
    IGRdouble             *dsupai,
    IGRdouble             *mdisti,
    IGRdouble             *dsupa,
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
      npt - number of points
      pt - the given points, stored in a C-array [npt][ndim]
      tol - tolerance
      dsupai - upper bounds of distance, dsupai[npt],
               we only look for solutions with mdist[i] < dsupai[i]
      mdisti - minimum distances, mdisti[npt],
               we only look for solutions with mdist[i] < mdisti[i],
               mdist[i] is to be preset to mdisti[i] >= dsupai[i]

    Input/Output:

    Output:
      dsupa- new upper bounds of distance, dsupa[npt]
             to be allocated by the caller, dsupa and dsupai may be
             passed with the same address
      mdist - new minimum distances, mdist[npt],
              to be allocated by the caller, mdist and mdisti may be
              passed with the same address
      par  - parameter yielding the minimum distances, par[npt],
             to be allocated by the caller
      bas_pts - points on the curve that yield the minimum distances,
                corresponding to a C array bas_pts[npt][ndim]; to be
                allocated by the caller
      *rc - return codes
            == BSSUCC if successful

    Algorithm:

Return Values
    NA

Notes

Index
    md

Keywords
    minimum distance point B-spline curve.

History
    Vivian Y. Hsu   02/01/1996  : Creation date.
    M. Rahmig       05/30/1996  : added special processing of 2D circles
    M. Rahmig       06/12/1996  : fixed bug in testing for a circle curve
    Vivian Y. Hsu   07/02/1996  : In static function chkcornBSmdptbscv
                                  free memory big_space.
    Vivian Y. Hsu   07/03/1996  : Normalise parameter with knots in case
                                  of input curve is Bezier.
                                  In case of rc = BSNOSOLUTION returned
                                  from BSmdptcrcv, set rc = BSSUCC and
                                  try the general case.
    Y.M. LI         07/09/1996  : Use loc_tol=tol/2 to check corner.
    Vivian Y.Hsu    07/11/1996  : Set loc_dsup = dsup if dsup = MAXDOUBLE
                                  to avoid overflow.
    M. Rahmig       08/01/1996  : changed from one to many points, moved
                                  mindstBSmdptbscv to BSmdptbscvg
    Vivian Y.Hsu    01/02/1997  : In CheckcornBSmdptbscv, added loc_dsup
                                  to determine if we want the boundary
                                  solution. 
    Vivian Y.Hsu    01/06/1997  : Set dsupa[i] = MAXDOUBLE if rc =
                                  NOSOLUTION returned from BSmdptbscvg.
    Vivian Y.Hsu    01/07/1997  : Take the above fix out which is not
                                  correct.
    Vivian Y.Hsu    01/14/1997  : Added tol as input argument to static
                                  function chkcornBSmdptbscv. Set loc_tol
                                  to be 0.5 * tol in chkcornBSmdptbscv.
    Vivian Y. Hsu   03/27/1998  : Replace BSmdptbscvg by loop over
                                  BSmdptbscv1. This is a temporary fix
                                  for a TR from VDS which runs out of
                                  memory in BSmdptbscvg.
******************************************************************************
*/
#define _debug2(x) 
#include <stdio.h>

#include <math.h>
#include "bs.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bsvalues.h"

#define SZ_JUNK1 300

/* 
  This routine checks whether one of the corner points may
  yield the minimum distance.

  Input:
    ndeg   - degree of curve
    npoles - number of poles
    ndim - dimension of the curve
    irat - 1, rational curve; 0, non-rational curve
    poles - coefficients of the curve, stored in a C-array
            poles[ndim+irat][npoles]
    knots[npoles + ndeg + 1] - knots of B-spline curve
    npt - number of points
    pt - the given points, stored in a C-array [npt][ndim]
    tol - tolerance
    dsupi - upper bounds of distance, dsupi[npt],
            we only look for solutions with mdist[i] < dsupi[i]
    mdisti - minimum distances, mdisti[npt],
             we only look for solutions with mdist[i] < mdisti[i],
             mdist[i] is to be preset to mdisti[i] >= dsupi[i]

  Input/Output:

  Output:
    dsup - new upper bounds of distance, dsup[npt]
           to be allocated by the caller, dsup and dsupi may be
           passed with the same address
    mdist - new minimum distances, mdist[npt],
            to be allocated by the caller, mdist and mdisti may be
            passed with the same address
    par  - parameter yielding the minimum distances, par[npt],
           to be allocated by the caller
    bas_pts - points on the curve that yield the minimum distances,
              corresponding to a C array bas_pts[npt][ndim]; to be
              allocated by the caller
    *rc - return codes
           == BSSUCC if successful
*/

static void chkcornBSmdptbscv(
IGRint                ndeg,
IGRint                npoles,
IGRint                ndim,
IGRint                irat,
IGRdouble             *poles,
IGRdouble             *knots,
IGRint                npt,
IGRdouble             *pt,
IGRdouble             tol,
IGRdouble             *dsupi,
IGRdouble             *mdisti,
IGRdouble             *dsup,
IGRdouble             *mdist,
IGRdouble             *par,
IGRdouble             *bas_pt,
BSrc                  *rc)
{
#define MAXSIZE 200

  IGRint      i, num, icount, n, nd, nknot, *multi_p;
  IGRdouble   array[MAXSIZE] ;
  IGRdouble   bidon, temp_dist, *wt_ptr = NULL;
  IGRdouble   *point;
  IGRdouble   loc_tol,loc_dsup;
  IGRboolean  ifound;
  IGRchar     *big_space=NULL;
  IGRint      j;
  IGRint      sz ;

  *rc = BSSUCC;
  loc_tol = 0.5 * tol;

  ifound = FALSE;
  if (dsupi != dsup)
  {
    BSMEMCPY((IGRint)(npt*sizeof(IGRdouble)),
             (IGRchar *)dsupi,(IGRchar *)dsup);
  }
  if (mdisti != mdist)
  {
    BSMEMCPY((IGRint)(npt*sizeof(IGRdouble)),
             (IGRchar *)mdisti,(IGRchar *)mdist);
  }

  /* Allocate space */
  sz = ndim*sizeof(IGRdouble) + npoles*sizeof(IGRint) ;
  if (sz <= (MAXSIZE*sizeof(IGRdouble)))
     point = array ;
  else
  {
     big_space = BSstackalloc((unsigned)(ndim * sizeof(IGRdouble) +
                                         npoles * sizeof(IGRint)));
     if (!big_space)
     {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
     }
     point = (IGRdouble *)big_space;
  }
  multi_p = (IGRint *)(point+ndim) ;

  /* Decide how many points on the curve need consideration */
  nknot = npoles + ndeg + 1;
  icount = 0;
  num = 0;
  i = 1;
  for (n=1; n<nknot-1; n++)
  {
     if (knots[n] == knots[i])
     {
        icount++;
        if (icount == ndeg)
        {
           multi_p[num] = n - ndeg;
           num++;
           i = n + 1;
           icount = 0;
        }
     }
     else
     {
        i = n;
        icount = 1;
     }
  }

  if (irat)
     wt_ptr = poles + ndim * npoles;
  for (i=num-1; i>=0; i--)
  {
     n = multi_p[i];
     if (irat)
     {
        for (nd=0; nd<ndim; nd++)
           point[nd] = poles[nd*npoles + n] / wt_ptr[n];
     }
     else
     {
        for (nd=0; nd<ndim; nd++)
           point[nd] = poles[nd*npoles + n];
     }

     for (j=0; j<npt; j++)
     {
       temp_dist = 0.0;
       for (nd=0; nd<ndim; nd++)
       {
          bidon = point[nd] - pt[j*ndim+nd];
          temp_dist += bidon * bidon;
       }
       temp_dist = sqrt(temp_dist);

       if (dsup[j] == MAXDOUBLE)
         loc_dsup = dsup[j];
       else
         loc_dsup = dsup[j] + loc_tol;

       if (temp_dist < loc_dsup)
       {         
          dsup[j] = temp_dist;
          mdist[j] = dsup[j] = temp_dist;
          par[j] = knots[n + 1];
          for (nd = 0; nd < ndim; ++nd)
            bas_pt[j*ndim+nd] = point[nd];
          ifound = TRUE;

_debug2(
  printf("_bscv pt!! p-sol p[%d] u=%lf mdist=%lf\n",j,par[j],mdist[j]);
      )

       }
     }
  }

wrapup:

  if (big_space)
  {
    BSstackdealloc(big_space);
  }
  if (*rc == BSSUCC && ifound == FALSE)
    *rc = BSNOSOLUTION;
  return;
}

/* Main routine */

void BSmdptbscv(
IGRint                ndeg,
IGRint                npoles,
IGRint                ndim,
IGRint                irat,
IGRdouble             *poles,
IGRdouble             *knots,
IGRint                npt,
IGRdouble             *pt,
IGRdouble             tol,
IGRdouble             *dsupai,
IGRdouble             *mdisti,
IGRdouble             *dsupa,
IGRdouble             *mdist,
IGRdouble             *par,
IGRdouble             *bas_pt,
BSrc                  *rc)
{
#include "bsdbgrc.h"
#include "bsgeocrcbsp.h"
#include "bsmdptcrcv.h"
#include "bsmdptbscv1.h"

  BSrc  rc1 = BSSUCC;

  IGRint                  icirc = 0 ;
  IGRdouble               mpoint[2];
  IGRdouble               center[2];
  IGRdouble               angle;
  IGRdouble               *circ = NULL ;
  IGRchar                 *bigspace1 = NULL ;
  IGRdouble               junk1[SZ_JUNK1] ;
  IGRint                  sz_circ;
  IGRint                  i;

  *rc = BSSUCC;
  if (dsupai != dsupa)
  {
    BSMEMCPY((IGRint)(npt*sizeof(IGRdouble)),
             (IGRchar *)dsupai,(IGRchar *)dsupa);
  }
  if (mdisti != mdist)
  {
    BSMEMCPY((IGRint)(npt*sizeof(IGRdouble)),
             (IGRchar *)mdisti,(IGRchar *)mdist);
  }

/*
 * Check whether we have a planar circle
 */
  if (2 == ndim && 1 == irat && 2 == ndeg)
  {
    sz_circ = 3*npoles ;
    if (sz_circ > SZ_JUNK1)
    {
      bigspace1 = BSstackalloc((unsigned) sz_circ*sizeof(IGRdouble)) ;
      if (!bigspace1)
      {
        *rc = BSNOSTKMEMORY ;
        goto wrapup;
      }
      circ = (IGRdouble*)bigspace1 ;
    }
    else
    {
      circ = junk1 ;
    }

    BSgeocrcbsp(ndeg, npoles, knots, ndim, irat, poles, tol,
                &icirc, center, mpoint, circ, &angle, rc);
    if (BSERROR(*rc))
      goto wrapup;
    if (0 != icirc)
    {
      for (i=0; i<npt; i++)
      {
        BSmdptcrcv( npoles, knots, circ, center, mpoint, angle,
                    &pt[i*ndim], &mdist[i], 
                    &bas_pt[i*ndim], &par[i], rc);
        if (BSOUTOFDESN == *rc || BSNOSOLUTION == *rc)
        {
          rc1 = BSOUTOFDESN ;
          *rc = BSSUCC ;
        }
        else if(BSERROR(*rc))
        {
          goto wrapup;
        }
        else
        {
          if (dsupa[i] > mdist[i])
            dsupa[i] = mdist[i] ;
        }
      }
      if (BSOUTOFDESN != rc1)
        goto wrapup;                       /* done */
    }
  }

/*
 * Do the general case:
 * Halves the B-spline curve repeatly, find minimum distance to
 * Bezier curve candidates
 */

  for (i = 0; i < npt; ++i)
  {
    BSmdptbscv1(ndeg,ndim,irat,npoles,poles,knots,1,
                &pt[i*ndim],tol,dsupai[i],&mdist[i],&par[i],
                &bas_pt[ndim*i],rc);
    if (*rc != BSSUCC && *rc != BSNOSOLUTION)
      goto wrapup;
    if (*rc == BSNOSOLUTION)
    {
      dsupa[i] = dsupai[i];
      *rc = BSSUCC;
    }
    else if (BSOKAY(*rc))
      dsupa[i] = MIN(mdist[i],dsupai[i]);
  }

/*
 * Check corner and multiple knots points
 */

  rc1 = BSSUCC ;
  chkcornBSmdptbscv(ndeg,npoles,ndim,irat,poles,knots,
                    npt,pt,tol,dsupa,mdist,dsupa,mdist,par,bas_pt,&rc1);
  if (rc1 == BSSUCC && *rc != BSSUCC)
    *rc = rc1;

wrapup:

  if (bigspace1)
  {
    BSstackdealloc(bigspace1);
  }
  if (BSERROR (*rc))
     BSdbgrc (*rc, "BSmdptbscv");
  return;
}
