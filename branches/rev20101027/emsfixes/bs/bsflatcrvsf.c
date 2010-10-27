/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSflatcrvsf

Abstract
    This routine unwraps a B-spline surface.

Synopsis
    void BSflatcrvsf(surface,uvs,npoint,pointmim1,pointpim1,pointpi,rev_norm,off_dist,pointp,rc)

	struct IGRbsp_surface *surface,
	IGRdouble *uvs,
	IGRint npoint,
	IGRdouble *pointmim1,
	IGRdouble *pointpim1,
	IGRdouble *pointpi,
	IGRboolean rev_norm,
	IGRdouble off_dist,
	IGRdouble *pointp,
	BSrc *rc,
    

Description
    Input:
      surface - Surface need to be flattened
	  uvs(2,npoint+1) - The array of (u,v) where we unfold
	  npoint - Number of points (+1) we unfold
	  pointmim1(3) - The previous point on the surface
	  pointpim1(2) - The unfolded point i - 1 
	  pointpi(2) - The  unfolded point i 
	  rev_norm - TRUE, normal is reversed
	  off_dist - offset distance from the original surface

    Input/Output:

    Output:
	  pointp(2,npoint+1) - The point after flattening.
      *rc        Possible return codes include:

    Algorithm:

Return Values
    NA

Notes

Index
    ot

Keywords

History
    Jean-Jacques Mallosse   05/23/2000  : Creation date.
	Vivian Y. Hsu           07/27/2000  : Added one input argument "rev_norm".
	VIvian Y. Hsu           08/08/2000  : Modified input arguments.
******************************************************************************
*/

#ifdef DONOTSPROTO
#include "ubspmp.h"
#endif

#ifdef NT
#include "ubspm.h"
#else
#include "bsdefs.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#endif


void BSflatcrvsf(
struct IGRbsp_surface *surface,
IGRdouble *uvs,
IGRint npoint,
IGRdouble *pointmim1,
IGRdouble *pointpim1,
IGRdouble *pointpi,
IGRboolean rev_norm,
IGRdouble off_dist,
IGRdouble *pointp,
BSrc *rc)
{
#ifndef DONOTSPROTO
#include "bssfevaln.h"
#include "bsrelaxope.h"
#include "bsdbgrc.h"
#endif

IGRint i,ibid,nd,npt;
IGRdouble *bidmp = NULL;
IGRdouble u,v;
IGRdouble *bidp,*bidm;
IGRdouble xnorm[3],xnormn[3];
IGRdouble prec = 1.e-6;

*rc = BSSUCC;

/*  Array for bidm and bidp   */

bidmp = (IGRdouble *) BSstackalloc((unsigned)(5*(npoint+2)*sizeof(IGRdouble)));
if (!bidmp)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  Fortran arrays 1:npoint  */

bidm = bidmp + 3;
bidp = bidmp + 3 * (npoint+2) + 2;

for (nd=0;nd<3;nd++)
  bidm[nd - 3] = pointmim1[nd];

BSsfevaln(surface,uvs[0],uvs[1],4,&ibid,bidm,&xnorm,rc);
if (BSERROR(*rc)) goto wrapup;
if (rev_norm)
{
  for (nd = 0; nd < 3; ++nd)
	xnorm[nd] = -xnorm[nd];
}

  for (nd = 0; nd < 3; ++nd)
	bidm[nd] += off_dist * xnorm[nd];

for (nd=0;nd<2;nd++)
  bidp[nd - 2] = pointpim1[nd];
for (nd=0;nd<2;nd++)
  bidp[nd] = pointpi[nd];


for (npt=1;npt<=npoint;npt++)
{
  u = uvs[2 * npt];
  v = uvs[1 + 2 * npt];
  BSsfevaln(surface,u,v,4,&ibid,&bidm[3*npt],&xnormn,rc);  
  if (rev_norm)
  {
	for (nd = 0; nd < 3; ++nd)
		xnormn[nd] = -xnormn[nd];
  }
  for (nd = 0; nd < 3; ++nd)
    bidm[nd + 3 * npt] += off_dist * xnormn[nd];

  BSrelaxope(&bidm[3*(npt-2)],&bidm[3*(npt-1)],&bidm[3*npt],xnorm
            ,&bidp[2*(npt-2)],&bidp[2*(npt-1)],prec,&bidp[2*npt],rc);
  if (BSERROR(*rc)) goto wrapup;
  for (nd=0;nd<3;nd++)
    xnorm[nd] = xnormn[nd];
}

for (i=0;i<2*(npoint+1);i++)
  pointp[i] = bidp[i];

wrapup:
if (bidmp) BSstackdealloc((char *) bidmp);

if (BSERROR (*rc)) BSdbgrc (*rc, "BSflatcrvsf");
  
return;
}
