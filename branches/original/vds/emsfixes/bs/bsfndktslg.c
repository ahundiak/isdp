/*****************************************************************************
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSfndktslg

Abstract
    This routine finds the knot vector for a curve in Legendre or 
    a surface being a Legendre series in u and a B-spline in v.


Synopsis
    void BSfndktslg(ndeg,npolev,ndim,curve,order,mcont,prec,nspan,span,rc)

    IGRint                ndeg;
    IGRint                npolev;
    IGRint                ndim;
    IGRdouble             *curve;
    IGRint                order;
    IGRint                mcont;
    IGRdouble             prec;
    IGRint                *nspan;
    IGRdouble             **span; 
    BSrc                  *rc;

Description
    Input:
      ndeg - degree of the Legendre series
      npolev - Number of poles in v
      ndim - dimension of the space
      curve[0:ndeg,0:npolev-1,0:ndim-1] - Legendre series
      order - the order of the B-spline curve
      mcont - order of continuity m
      prec - the precision of approximation

    Input/Output:

    Output:
      nspan - the number of span obtained
      span[0:nspan] - the knots vector
      *rc        Possible return codes include:

    Algorithm:

Return Values
    NA

Notes

Index
    md

Keywords
    Approximation, Legendre, B-spline, knot vector, internal

History
    Vivian W.Ye       08/03/1994   : Creation date.
    Vivian Y. Hsu     08/15/1997   : Revised algorithm.
    Vivian Y. Hsu     01/25/1998   : If u = hmin - 2*h < -1 then u = -1.0
                                     if u = hmax + 2*h > 1 then u = 1.0
    Vivian Y. Hsu     01/29/1999   : TR2836.Due to the problem of VC++5.0 global
	                             optimization. I changed maximum number 
			             (10000) in 2 while loops to (9999).
  JJ Malosse 13 October 1999: Fixed case where h0 = + Infinite.
  JJ Malosse 19 January 2000: Fixed another case of h = + Infinite.
******************************************************************************
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bs.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bsmalloc.h"
#endif

#include <math.h>


/* static function

Name
    fndktslgh

Abstract
    Given f(u,v) of Legendre in u and B-spline in v, finds 
    ||der(k)f(u,v)|| at a given u.

Synopsis
    void BSfndktslg(ndeg,npolev,ndim,surface,upar,fval)

    IGRint                ndeg;
    IGRint                npolev;
    IGRint                ndim;
    IGRdouble             *surface;
    IGRdouble             upar;
    IGRdouble             fval;

Description
    Input:
      ndeg - degree of the Legendre series
      npolev - Number of poles in v
      ndim - dimension of the space
      surface[0:ndeg,0:npolv-1,0:ndim-1] - The coefficients of
             f(u,v) of Legendre in u and B-spline in v.
      upar - The parameter u considered.

    Input/Output:

    Output:
      fval - The value of ||der(k)f(u,v)|| at given upar.
      *rc        Possible return codes include:

*/

static void fndktslghBSfndktslg(

IGRint                ndeg,
IGRint                npolev,
IGRint                ndim,
IGRdouble             *surface,
IGRdouble             upar,
IGRdouble             *fval)

{
#ifndef DONOTSPROTO
  #include "bshornlgd.h"
#endif 

  IGRint         j,nd;
  IGRdouble      bidon,bid;

  /* We compute each derivative der(k)f(u,v) in u = upar and
     we take the greatest in module */

  *fval = 0;

  for (j = 0; j < npolev; ++j)
  {
    bidon = 0.0;
    for (nd = 0; nd < ndim; ++nd)
    {
      BShornlgd(ndeg,&surface[j * (ndeg + 1) + nd * (ndeg + 1) * npolev],
                upar, &bid);
      bidon += bid * bid;
    }
    bidon = sqrt(bidon);
    if (bidon > *fval)
      *fval = bidon;
  }

  return;
}

  
void BSfndktslg(
IGRint                ndeg,
IGRint                npolev,
IGRint                ndim,
IGRdouble             *curve,
IGRint                order,
IGRint                mcont,
IGRdouble             prec,
IGRint                *nspan,
IGRdouble             **span, 
BSrc                  *rc)
{

#ifndef DONOTSPROTO
  #include "bsdbgrc.h"
  #include "bsderlgdpol.h"
  #include "bskroot.h"
#endif 

  IGRdouble  *curved = NULL;
  IGRdouble  *bidtab1 = NULL;
  IGRdouble  *bidtab2 = NULL;
  IGRdouble  aleft[10000];
  IGRdouble  aright[10000];
  IGRdouble  bidon,x,y,z,r,h,a,b;
  IGRdouble  xnorm,xnorm0,xnorm1,xnorm2,h0,hmil,hmin,hmax;
  IGRint     nright,nleft;
  IGRint     i,j,nd,n,m,k;
  IGRint     sz_curved,sz_bidtab1,sz_bidtab2;
  IGRchar    *big_space1 = NULL;
  IGRdouble  u;

  *rc = BSSUCC;
  k = order;
  n = k - 1;
  m = mcont;

  /* if ndeg < order, exit with nspan = 0 */

  if (ndeg < order)
  {
    *nspan = 0;
    goto wrapup;
  }

  /* Allocate space for curved, bidtab1,bidtab2 */

  sz_curved = ndim * (ndeg - k + 1) * npolev;
  sz_bidtab1 = ndeg + 1;
  sz_bidtab2 = ndeg + 1; 

  big_space1 = BSstackalloc((unsigned)(sz_curved + 
               sz_bidtab1 + sz_bidtab2) * sizeof(IGRdouble));
  if (!big_space1)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  curved = (IGRdouble *)big_space1;
  bidtab1 = (IGRdouble *)big_space1 + sz_curved;
  bidtab2 = (IGRdouble *)bidtab1 + sz_bidtab1;

  /* Compute the kth derivative of f (curve) */

  for (nd = 0; nd < ndim; ++nd)
  {
    for (j = 0; j < npolev; ++j)
    {
      BSMEMCPY((IGRint)((ndeg + 1) * sizeof(IGRdouble)),
             (IGRchar *)&curve[j * (ndeg + 1) + nd * (ndeg + 1) * npolev],
             (IGRchar *)bidtab1);

      for (i = 0; i < k - 1; ++i)
      {
        BSderlgdpol(ndeg - i,bidtab1,bidtab2);

        BSMEMCPY((IGRint)((ndeg - i) * sizeof(IGRdouble)),
               (IGRchar *)bidtab2,(IGRchar *)bidtab1);
      }

      BSderlgdpol(ndeg - k + 1,bidtab1,
              &curved[j * (ndeg - k + 1) + nd * (ndeg - k + 1) * npolev]);
    }
  }

  /* Computation of l_n+1 */

  x = 1;
  for (i = 2; i <= k; ++i)
    x *= (2 * i - 1);

  y = 1;
  for (i = 2; i <= n - m; ++i)
    y *= i;

  z = y;
  for (i = n - m + 1; i <= n + 1; ++i)
    z *= i;

  r = (n + 1) *y * x / z;

  /* We now can stat to subdivide [-1,1]. We start from the
     middle in order to get a symmetric response.
     We compute the derivative at x = 0 */

  fndktslghBSfndktslg(ndeg - k,npolev,ndim,curved,0.0,&xnorm0);
  if (xnorm0 == 0.0)
     h0 = 1;
  else
  {
    bidon = r * prec / xnorm0;
    BSkroot(bidon,k,&h0,rc);
    if (BSERROR(*rc)) goto wrapup;
    if (h0 > 1.0) h0 = 1.0;
  }

  /* When the Legendre series converges slowly. ||f|| can
     vary heavily. To circumvent the problem, we compute
     ||f(+-h0)|| */

  fndktslghBSfndktslg(ndeg - k,npolev,ndim,curved,-h0,&xnorm1);
  fndktslghBSfndktslg(ndeg - k,npolev,ndim,curved,h0,&xnorm2);
  xnorm = MAX(xnorm0,xnorm1);
  xnorm = MAX(xnorm,xnorm2);

  /* We recompute h */

  if (xnorm != xnorm0)
  {
    if (xnorm != 0.0)
    {
      bidon = r * prec / xnorm;
      BSkroot(bidon,k,&hmil,rc);
      if (BSERROR(*rc)) goto wrapup;
    }
    else
      hmil = 1.0;
  }
  else
    hmil = h0;
  
  /* We now consider the left side [0,1] */
  /* nleft is the number of left interval */
  /* nright is the number of right interval */

  hmin = -hmil;
  aleft[0] = hmin;
  nleft = 0;

  xnorm = xnorm1;
  while (hmin > -1.0 && nleft < 9999 )
  {
    if (xnorm != 0.0)
    {
      bidon = r * prec / xnorm;
      BSkroot(bidon,k,&h,rc);
      if (BSERROR(*rc)) goto wrapup;
    }
    else
      h = 1.0;

    u = hmin - 2 * h;
    if (u < -1.0) u = -1.0;

    fndktslghBSfndktslg(ndeg-k,npolev,ndim,curved,u,&xnorm2);
    if (xnorm2 > xnorm)
    {
      bidon = r * prec / xnorm2;
      BSkroot(bidon,k,&h,rc);
      if (BSERROR(*rc))
        goto wrapup;
    }
    xnorm = xnorm2;
    hmin -= 2 * h;
	nleft++;
    aleft[nleft] = hmin;
 
  }
  
  if (hmin > -1.0 && nleft == 9999)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  nright = 0;
  hmax = hmil;
  aright[0] = hmax;
  xnorm = xnorm2;
  while (hmax <= 1 && nright < 9999)
  {

    if (xnorm != 0.0)
    {
      bidon = r * prec / xnorm;
      BSkroot(bidon,k,&h,rc);
      if (BSERROR(*rc)) goto wrapup;
    }
    else
      h = 1.0;

    u = hmax + 2 * h;
    if (u > 1.0) u = 1.0;
    fndktslghBSfndktslg(ndeg-k,npolev,ndim,curved,u,&xnorm2);
 
    if (xnorm2 > xnorm)
    {
      bidon = r * prec / xnorm2;
      BSkroot(bidon,k,&h,rc);
      if (BSERROR(*rc))
        goto wrapup;
    }
    xnorm = xnorm2;
    hmax += 2 * h;
    nright++;
    aright[nright] = hmax;
  }

  if (hmax <= 1.0 && nright == 9999)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }  
  
  *nspan = nleft + nright + 1;

  /* allocate space for output span */

  (*span) = (IGRdouble *)BSmalloc((unsigned)((*nspan + 1)* 
                   sizeof(IGRdouble)));
  if (!(*span))
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  for (i = 0; i <= nleft; ++i)
    (*span)[i] = aleft[nleft - i];

  for (i = nleft + 1; i <= *nspan; ++i)
    (*span)[i] = aright[i - nleft - 1];

  /* Normalize span to [-1,1] */

  a = (hmax + hmin) / 2;
  b = 2 / (hmax - hmin);
  (*span)[0] = -1.0;
  for (i = 1; i < *nspan; ++i)
    (*span)[i] = b * ((*span)[i] - a);
  (*span)[*nspan] = 1.0;
   
wrapup:
  if (big_space1)
    BSstackdealloc((char *) big_space1);

  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSfndktslg");

  return;
}
