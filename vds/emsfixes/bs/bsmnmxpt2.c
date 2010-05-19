/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmnmxpt2

Abstract
    This routine computes minimum, maximum and average distances between
    a point and a parallelogram defined by Cent + lam * uvec + mu * vvec.
    lam,mu are in [-1,1].

Synopsis
    void BSmnmxpt2(ndim,cent,uvec,vvec,pt,dmin2,dmax2,rc)

    IGRint                ndim,
    IGRdouble             *cent,
    IGRdouble             *uvec,
    IGRdouble             *vvec,
    IGRdouble             *pt,
    IGRdouble             *dmin2,
    IGRdouble             *dmax2,
    BSrc                  *rc,

Description
    Input:
      ndim - Dimension of the space (to be 2 or 3)
      cent[0:ndim-1] - center of the segment
      uvec[0:ndim-1] - the vector u
      vvec[0:ndim-1] - the vector v
      pt[0:ndim-1] - the given point

    Input/Output:

    Output:
      dmin2 - square of minimum distance
      dmax2 - square of maximum distance

    Algorithm:

Return Values
    NA

Notes

Index
    md

Keywords
    minimum distance, surface, point, local.

History
    Vivian Y. Hsu   02/29/1996 : Creation date.    
    Vivian Y. Hsu   06/24/1996 : Removed output "dmid2".
    M. Rahmig       09/16/1996 : Improved efficiency (special code for 2D, 3D)
    Vivian Y. Hsu   03/25/1998 : Removed M.Rahmig's improvement which
                                 is not stable for singular case. We go
                                 back to the original design.
******************************************************************************
*/

#include "bs.h"
#include "bsvalues.h"
#include "bsstackalloc.h"

void BSmnmxpt2(

IGRint                ndim,
IGRdouble             *cent,
IGRdouble             *uvec,
IGRdouble             *vvec,
IGRdouble             *pt,
IGRdouble             *dmin2,
IGRdouble             *dmax2,
BSrc                  *rc)

{
#include "bsdbgrc.h"
#include "bsmnmxpt1.h"
  IGRdouble         *bidvec = NULL,*veclu = NULL,*veclv = NULL;
  IGRdouble         bidvecl[3],veclul[3],veclvl[3];
  IGRdouble         d1,d2,bid,bid2;
  IGRdouble         dmid,s1,s2,bidon;
  IGRdouble         amat0, amat1, amat2, amat3, sol0, sol1;
  IGRdouble         c[3];
  IGRdouble         det;
  IGRint            nd;
  IGRchar           *big_space = NULL;
  
  *rc = BSSUCC;

  if (ndim <= 3)
  {
    bidvec = bidvecl;
    veclu = veclul;
    veclv = veclvl;
  }
  else
  {
    big_space = BSstackalloc((unsigned)(3 * ndim * sizeof(IGRdouble)));
    if (!big_space)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    bidvec = (IGRdouble *)big_space;
    veclu = (IGRdouble *)bidvec + ndim;       
    veclv = (IGRdouble *)veclu + ndim;       
  }

  /* Push uvec, vvec to veclu, veclv, compute bidvec = P - C */

  for (nd = 0; nd < ndim; ++nd)
  {
    veclu[nd] = uvec[nd];
    veclv[nd] = vvec[nd];
    bidvec[nd] = pt[nd] - cent[nd];
  }

  /* Compute dmid^2 = bidvec * bidvec */
  /* Compute s1 = bidvec * veclu and s2 = bidvec * veclv */

  s1 = 0;
  s2 = 0;
  dmid = 0;
  for (nd = 0; nd < ndim; ++nd)
  {
    dmid += bidvec[nd] * bidvec[nd];
    s1 += bidvec[nd] * veclu[nd];
    s2 += bidvec[nd] * veclv[nd];
  }

  /* Set matrix */

  amat0 = 0.0;
  amat1 = 0.0;
  amat3 = 0.0;
  for (nd = 0; nd < ndim; ++nd)
  {
    amat0 += uvec[nd] * uvec[nd];
    amat1 += uvec[nd] * vvec[nd];
    amat3 += vvec[nd] * vvec[nd];

  }
  amat2 = amat1;

  /* Compute dmax */

  bidon = dmid + amat0 + amat3;

  *dmax2 =  bidon + 2 * (amat1 + s1 + s2);
  bid =  bidon + 2 * (-amat1 +  s1 - s2);
  if (bid > *dmax2)
    *dmax2 = bid;
  bid =  bidon + 2 * (-amat1 - s1 + s2);
  if (bid > *dmax2)
    *dmax2 = bid;
  bid =  bidon + 2 * (amat1 - s1 - s2);
  if (bid > *dmax2)
    *dmax2 = bid;

  /* Inverse the matrix, Solve the linear system */

  det = amat0 * amat3 - amat1 * amat1;
  if (det == 0.0)
    sol0 = 0.0;
  else
    sol0 = (amat3 * s1 - amat1 * s2) / det;

  sol1 = (s2 - amat1 * sol0)/amat3;

/*
    sol1 = (amat2 * s1 + amat3 * s2) * det;   
*/

  if (sol0 < 0)
  {
    for (nd = 0; nd < ndim; ++nd)
      veclu[nd] = -veclu[nd];
    sol0 = -sol0;
  }

  if (sol1 < 0)
  {
    for (nd = 0; nd < ndim; ++nd)
      veclv[nd] = -veclv[nd];
    sol1 = -sol1;
  }

  if (sol0 <= 1.0 && sol1 <= 1.0)
  {
    *dmin2 = 0.0;
    for (nd = 0; nd < ndim; ++nd)
    {
      bid = bidvec[nd] - sol0 * veclu[nd] - sol1 * veclv[nd];
      *dmin2 += bid * bid;
    }     
    goto wrapup;
  }

  /* Then minimum distance is necessarily on one of boundary */

  for (nd = 0; nd < ndim; ++nd)
    c[nd] = cent[nd] + veclu[nd];

  BSmnmxpt1(ndim,c,veclv,pt,&d1,&bid2);

  for (nd = 0; nd < ndim; ++nd)
    c[nd] = cent[nd] + veclv[nd];

  BSmnmxpt1(ndim,c,veclu,pt,&d2,&bid2);
  *dmin2 = MIN(d1,d2);

  wrapup:
    if (big_space)
      BSstackdealloc((char *) big_space);

    if (BSERROR(*rc))
      BSdbgrc(*rc, "BSmnmxpt2");
  return;
}
