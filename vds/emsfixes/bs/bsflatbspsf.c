/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSflatbspsf

Abstract
    This routine unwraps a B-spline surface.

Synopsis
    void BSflatbspsf(surface,nu,nv,uvpars,rev_norm,off_dist,fltpts,rc)

    struct IGRbsp_surface *surfaceinp,
    IGRint                npointu;
	IGRint                npointv;
	IGRdouble             *uvpars,
	IGRboolean            rev_norm;
	IGRdouble             off_dist,
    IGRdouble             *fltpts;
    BSrc                  *rc;
    

Description
    Input:
      surface - Surface need to be flattened
      npointu - number of points in u for tesselation
	  npointv - number of points in v for tesselation
	  uvpars(2,npointu,npointv) - uv parameters for tesselation points
	  rev_norm - TRUE, reverse norm
	  off_dist - offset distance from the original surface.

    Input/Output:

    Output:
      fltpts(2,npointu,npointv) - flattened points
      *rc        Possible return codes include:

    Algorithm:

Return Values
    NA

Notes

Index
    ot

Keywords

History
    Vivian Y. Hsu   05/23/2000  : Creation date.
    Vivian Y. Hsu   06/20/2000  : Add one input argument "rev_norm"
******************************************************************************
*/
#include <math.h>

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

void BSflatbspsf(
struct IGRbsp_surface *surfaceinp,
IGRint                npointu,
IGRint                npointv,
IGRdouble             *uvpars,
IGRboolean            rev_norm,
IGRdouble             off_dist,
IGRdouble             *fltpts,
BSrc                  *rc)

{
#ifndef DONOTSPROTO
#include "bsallocsf.h"
#include "bssf_copy.h"
#include "bsfreesf.h"
#include "bssfevaloff.h"
#include "bsflatcrvsf.h"
#include "bsdbgrc.h"
#endif

	struct IGRbsp_surface *surface=NULL;
	struct IGRbsp_surface *surf1 = NULL;
	struct IGRbsp_surface *surf2 = NULL;
	struct IGRbsp_surface *surf3 = NULL;
	IGRvector normal;
	IGRint i,j,Nu,Nv,nd,n_uvs;
	IGRdouble d;
	IGRdouble *pointP;
	IGRpoint pointMm1,pointM,pt;
	IGRdouble *bidpts = NULL;
	IGRdouble *biduv = NULL;
	IGRboolean turn = TRUE;
	IGRdouble *uvs = NULL;
	IGRdouble *uvPtr = NULL;
	IGRdouble u,v;
	BSrc rc1 = BSSUCC;

	*rc = BSSUCC;

	if (npointu % 2 == 0 || npointv % 2 == 0)
	{
	  *rc = BSINARG;
	  goto wrapup;
	}

	BSallocsf(surfaceinp->u_order,surfaceinp->v_order
			 ,surfaceinp->u_num_poles,surfaceinp->v_num_poles
			 ,surfaceinp->rational,0,&surface,rc);
	if (BSERROR(*rc)) goto wrapup;

	BSsf_copy(rc,surfaceinp,surface);

	Nu = npointu/2;
	Nv = npointv/2;

	n_uvs = MAX(Nu,Nv) + 1;
	uvs = (IGRdouble *)BSstackalloc((unsigned)(2 * n_uvs * sizeof(IGRdouble)));

	if (2*Nu + 1 - npointu != 0 || 2*Nv + 1 - npointv != 0)
	{
	  *rc = BSINARG;
	  goto wrapup;
	}

	pointP = fltpts + 2*(Nu + Nv * npointu);
	uvPtr = uvpars + 2*(Nu + Nv * npointu);

	u = uvPtr[-2 * npointu];
	v = uvPtr[1 - 2 * npointu];

	if(!rev_norm)
		BSsfevaloff(surface,u,v,off_dist,pt,normal,pointMm1,rc);
	else
		BSsfevaloff(surface,u,v,-off_dist,pt,normal,pointMm1,rc);
	if (BSERROR(*rc))
		goto wrapup;


	u = uvPtr[0];
	v = uvPtr[1];

	if(!rev_norm)
		BSsfevaloff(surface,u,v,off_dist,pt,normal,pointM,rc);
	else
		BSsfevaloff(surface,u,v,-off_dist,pt,normal,pointM,rc);
	if (BSERROR(*rc))
		goto wrapup;

	d = 0.0;
	for (nd=0;nd<3;nd++)
	  d += (pointM[nd] - pointMm1[nd]) * (pointM[nd] - pointMm1[nd]);
	d = sqrt(d);

	pointP[-2*npointu] = 0.0;
	pointP[1-2*npointu] = -d;
	pointP[0] = 0.0;
	pointP[1] = 0.0;

	bidpts = (IGRdouble *) BSstackalloc((unsigned)(3*(Nu+Nv+1)*sizeof(IGRdouble)));
	if (!bidpts)
	{
	  *rc = BSNOSTKMEMORY;
	  goto wrapup;
	}

	biduv = (IGRdouble *) BSstackalloc((unsigned)(2*(Nu+Nv+1)*sizeof(IGRdouble)));
	if (!biduv)
	{
	  *rc = BSNOSTKMEMORY;
	  goto wrapup;
	}

	for (i = 0; i <= Nv; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd + 2 * i * npointu];

	BSflatcrvsf(surface,uvs,Nv,pointMm1,&pointP[-2*npointu],&pointP[0]
			   ,rev_norm,off_dist,bidpts,rc);
	if (BSERROR(*rc)) goto wrapup;

	for (i=1;i<=Nv;i++)
	{
	  pointP[2*i*npointu] = bidpts[2*i];
	  pointP[1+2*i*npointu] = bidpts[1+2*i];
	}

	u = uvPtr[2 * npointu];
	v = uvPtr[1 + 2 * npointu];

	if(!rev_norm)
		BSsfevaloff(surface,u,v,off_dist,pt,normal,pointMm1,rc);
	else
		BSsfevaloff(surface,u,v,-off_dist,pt,normal,pointMm1,rc);
	if (BSERROR(*rc))
		goto wrapup;

	for (i = 0; i <= Nv; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd - 2 * i * npointu];

	BSflatcrvsf(surface,uvs,Nv,pointMm1,&pointP[2*npointu],&pointP[0]
				,rev_norm,off_dist,bidpts,rc);

	if (BSERROR(*rc)) goto wrapup;

	for (i=1;i<=Nv;i++)
	{
	  pointP[-2*i*npointu] = bidpts[2*i];
	  pointP[1-2*i*npointu] = bidpts[1+2*i];
	}


	u = uvPtr[-2 * (Nv - 1) * npointu];
	v = uvPtr[1-2 * (Nv - 1) * npointu];
	
	if(!rev_norm)
		BSsfevaloff(surface,u,v,off_dist,pt,normal,pointMm1,rc);
	else
		BSsfevaloff(surface,u,v,-off_dist,pt,normal,pointMm1,rc);
	if (BSERROR(*rc))
		goto wrapup;

	for (i = 0; i <= Nu; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd + 2 * (-Nv * npointu + i)];

	BSflatcrvsf(surface,uvs,Nu,pointMm1,&pointP[-(Nv-1)*2*npointu]
			   ,&pointP[-Nv*2*npointu],rev_norm,off_dist,&pointP[-Nv*2*npointu],rc);

	if (BSERROR(*rc)) goto wrapup;

	for (i = 0; i <= Nu; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd + 2 * (-Nv * npointu - i)];

	BSflatcrvsf(surface,uvs,Nu,pointMm1,&pointP[-(Nv-1)*2*npointu]
			   ,&pointP[-Nv*2*npointu],rev_norm,off_dist,bidpts,rc);

	if (BSERROR(*rc)) goto wrapup;

	for (i=1;i<=Nu;i++)
	{
	  pointP[-2*i-Nv*2*npointu] = bidpts[2*i];
	  pointP[1-2*i-Nv*2*npointu] = bidpts[1+2*i];
	}

	/*  General loop   */

	for (j=-Nv+1;j<=Nv;j++)
	{
	 
      u = uvPtr[2 * (j - 1) * npointu];
	  v = uvPtr[1 + 2 * (j - 1) * npointu];
	  if(!rev_norm)
		BSsfevaloff(surface,u,v,off_dist,pt,normal,pointMm1,rc);
	  else
		BSsfevaloff(surface,u,v,-off_dist,pt,normal,pointMm1,rc);
	  if (BSERROR(*rc))
		goto wrapup;

	  for (i = 0; i <= Nu; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd + 2 * (j * npointu + i)];

	  BSflatcrvsf(surface,uvs,Nu,pointMm1,&pointP[(j-1)*2*npointu],
		  &pointP[j*2*npointu],rev_norm,off_dist,&pointP[j*2*npointu],rc);
	  if (BSERROR(*rc)) goto wrapup;
	  for (i = 0; i <= Nu; ++i)
		for (nd = 0; nd < 2; ++nd)
			uvs[nd + i * 2] = uvPtr[nd + 2 * (j * npointu - i)];

	  BSflatcrvsf(surface,uvs,Nu,pointMm1,&pointP[(j-1)*2*npointu]
				 ,&pointP[j*2*npointu],rev_norm,off_dist,bidpts,rc);
	  if (BSERROR(*rc)) goto wrapup;

	  for (i=1;i<=Nu;i++)
	  {
		pointP[-2*i+j*2*npointu] = bidpts[2*i];
		pointP[1-2*i+j*2*npointu] = bidpts[1+2*i];
	  }

	}

wrapup:

	if (uvs)
		BSstackdealloc((char *) uvs);
	if (biduv) 
		BSstackdealloc((char *) biduv);
	if (bidpts) 
		BSstackdealloc((char *) bidpts);
	if (surface)
	{
		BSfreesf(&rc1,surface);
		if (BSOKAY(*rc) && BSERROR(rc1))
			*rc = rc1;
	}

	if (BSERROR (*rc)) BSdbgrc (*rc, "BSflatbspsf");
  
  return;
}
