/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSflatrelsf

Abstract
    This routine unwraps a B-spline surface.

Synopsis
    void BSflatrelsf(surface,nu,nv,uvpars,off_dist,fltpts,rc)

    struct IGRbsp_surface *surface,
    IGRint                nu;
	IGRint                nv;
	IGRdouble             *uvpars;
	IGRdouble             off_dist;
    IGRdouble             *fltpts;
    BSrc                  *rc;
    

Description
    Input:
      surfaceinp - Surface need to be flattened
      nu - number of points in u for tesselation
	  nv - number of points in v for tesselation
	  uvpars(2,nu,nv) - array of parameters of the tesselation points
      off_dist - offset distance

    Input/Output:

    Output:
      fltpts(3,nu,nv) - flattened points
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
    Vivian Y. Hsu   08/16/2000  : Modified input/output argument list.
	Vivian Y. Hsu   08/29/2000  : Using least square method to find angle.

******************************************************************************
*/

#include <math.h>

#ifdef DONOTSPROTO
#include "ubspmp.h"
#endif

#ifdef NT
#include "ubspm.h"
#else
#include "bsvalues.h"
#include "bsdefs.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsmemory.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#endif

/* Static Routine

Name
    averageBSflatrelsf

Abstract
    This routine rotates array f_pts2 to match array f_pts1. Then average these 2 sets of points.

Synopsis
    void averageBSflatrelsf(nu,nv,f_pts1,f_pts2,fltpts,rc)

    IGRint                nu,
	IGRint                nv,
	IGRdouble             *f_pts1,
	IGRdouble             *f_pts2,
	IGRdouble             *fltpts,
	BSrc                  *rc;
    

Description
    Input:
	  nu - number of point in u
	  nv - number of point in v
	  f_pts1(2,nu,nv) - flat points from unwrapping extended input surface
	  f_pts2(2,nu,nv) - flat points from unwrapping extended input surface with reversed v.


    Input/Output:

    Output:
      fltpts(2,nu,nv) - average flat points from above 2 sets.
      *rc        Possible return codes include:
*/

static void  averageBSflatrelsf(
IGRint nu,
IGRint nv,
IGRdouble *f_pts1,
IGRdouble *f_pts2,
IGRboolean perm_uv,
IGRdouble *fltpts,
BSrc *rc)
{

#ifndef DONOTSPROTO
#include "bscrossp.h"
#include "bslenvec.h"
#include "bsdotp.h"
#endif

	IGRint i,j,nd;
	IGRdouble tmat[2][2];
	IGRdouble tempx,tempy;
	IGRdouble *pointP1 = NULL, *pointP2 = NULL;
/*	IGRdouble P0[2],P1[2],Q1[2];
	IGRvector V1,V2,Cross;
	IGRdouble CrossLen,Dot; 
	IGRint Nu,Nv; 
*/
    IGRdouble x1,x2,tan_angle,angle;
	IGRdouble I1,I2,sina,cosa,sinap,cosap;

	/* Find the angle by least square mathod */

	/* I(alpha) = sum(i=0,nu*nv-1)(MP - Q)^2 */

	x1 = 0.0;
	x2 = 0.0;

	for (i = 0; i < nu * nv; ++i)
	{
		x1 += (f_pts2[2 * i] * f_pts1[2 * i + 1] - f_pts2[2 * i + 1] * f_pts1[2 * i]);
		x2 += (f_pts1[2 * i] * f_pts2[2 * i]  + f_pts1[2 * i + 1] * f_pts2[2 * i + 1]);
	}

	tan_angle = x1 / x2;


	/* find the rotation matrix */
/*
	Nu = nu/2;
	Nv = nv/2;
	
	pointP1 = f_pts1 + 2*(Nu + Nv * nu);
	pointP2 = f_pts2 + 2*(Nu + Nv * nu);
	P0[0] = pointP1[0];
	P0[1] = pointP1[1];
	P1[0] = pointP1[2];
	P1[1] = pointP1[3];
	Q1[0] = pointP2[2];
	Q1[1] = pointP2[3];

	for (nd = 0; nd < 2; ++nd)
	{
		V1[nd] = P1[nd] - P0[nd];
		V2[nd] = Q1[nd] - P0[nd];
	}
	V1[2] = 0.0;
	V2[2] = 0.0;

	(void)BScrossp(rc, V1, V2, Cross );
	if(BSERROR(*rc))
		goto wrapup;

	CrossLen = BSlenvec(rc, Cross );
	if(BSERROR(*rc))
		goto wrapup;
  
	Dot = BSdotp(rc, V1, V2 );
	if(BSERROR(*rc))
		goto wrapup;
  */
	/* find the angle between 0,2PI using atan2 function  */
/*
	angle = atan2(CrossLen , Dot);	
*/
	angle = atan(tan_angle); 
	
	/* check I(a) and I(a + PI), find the smallest I */

	sina = sin(angle);
	cosa = cos(angle);
	sinap = sin(angle + M_PI);
	cosap = cos(angle + M_PI);

	I1 = 0.0;
	I2 = 0.0;
	
	for (i = 0; i < nu * nv; ++i)
	{
		I1 += (cosa * f_pts2[2 * i] - sina * f_pts2[2 * i + 1] - f_pts1[2 * i]) * 
			  (cosa * f_pts2[2 * i] - sina * f_pts2[2 * i + 1] - f_pts1[2 * i]) + 
			  (sina * f_pts2[2 * i] + cosa * f_pts2[2 * i + 1] - f_pts1[2 * i + 1]) * 
			  (sina * f_pts2[2 * i] + cosa * f_pts2[2 * i + 1] - f_pts1[2 * i + 1]);

		I2 += (cosap * f_pts2[2 * i] - sinap * f_pts2[2 * i + 1] - f_pts1[2 * i]) * 
			  (cosap * f_pts2[2 * i] - sinap * f_pts2[2 * i + 1] - f_pts1[2 * i]) + 
			  (sinap * f_pts2[2 * i] + cosap * f_pts2[2 * i + 1] - f_pts1[2 * i + 1]) * 
			  (sinap * f_pts2[2 * i] + cosap * f_pts2[2 * i + 1] - f_pts1[2 * i + 1]);
	}

	if (I2 < I1)
		angle += M_PI;
/*
	if (perm_uv)
		angle = -angle;
*/
	tmat[0][0] = cos(angle);
	tmat[0][1] = -sin(angle);
	tmat[1][0] = sin(angle);
	tmat[1][1] = cos(angle);

	/* Transform f_pts22 */

	for (i=0;i < nu * nv;i++)
    {
       tempx = f_pts2[2 * i];
       tempy = f_pts2[1 + 2 * i];
       f_pts2[2 * i] = (tempx * tmat[0][0] + tempy * tmat[0][1]);
       f_pts2[1 + 2 * i] = (tempx * tmat[1][0] + tempy * tmat[1][1]);
    }

	/* Now average these 2 set points and get the final output */

	for (j = 0; j < nv; ++j)
	{
		for (i = 0; i < nu; ++i)
		{
			for (nd = 0; nd < 2; ++nd)
			{
				fltpts[nd + 2 * i + j * 2 * nu] = (f_pts2[nd + 2 * i + j * nu * 2] + 
					          f_pts1[nd + 2 * i + j * 2 * nu] ) / 2;
			}
		}
	}
	return;
}


/* Static Routine

Name
    avgunwrapBSflatrelsf

Abstract
    This routine unwraps the input B-spline surface, then reverse then input surface v 
	and unwrap it again. Finds the average of two unwrapping results.

Synopsis
    void avgunwrapBSflatrelsf(surface,nu,nv,uvpars,perm_uv,off_dist,fltpts,rc)

    struct IGRbsp_surface *surface,
    IGRint                nu;
	IGRint                nv;
	IGRdouble             *uvpars;
	IGRboolean            perm_uv;
	IGRdouble             off_dist;
    IGRdouble             *fltpts;
    BSrc                  *rc;
    

Description
    Input:
      surface - Surface need to be flattened
      nu - number of points in u for tessalation
	  nv - number of points in v for tessalation
	  uvpars(2,nu,nv) - array of parameters of tesselation points
	  perm_uv - TRUE, permuted u and v
	  off_dist - offset distance

    Input/Output:

    Output:
      fltpts(2,nu,nv) - flattened points
      *rc        Possible return codes include:
*/

static void avgunwrapBSflatrelsf(
struct IGRbsp_surface *surface_ext,
IGRint                nu,
IGRint                nv,
IGRdouble             *uvpars,
IGRboolean            perm_uv,
IGRdouble             off_dist,
IGRdouble             *fltpts,
BSrc                  *rc)

{
#ifndef DONOTSPROTO
#include "bsflatbspsf.h"
#include "bsallocsf.h"
#include "bsfreesf.h"
#endif

	struct IGRbsp_surface *surf_rv = NULL;
	IGRint i,j,nd;
	IGRdouble *f_pts21 = NULL;
	IGRdouble *f_pts22 = NULL;
	BSrc rc1 = BSSUCC;
	IGRint Nu,Nv;
    IGRdouble dist_tol = 1.0e-6;
	IGRdouble temp_pt[3];


	*rc = BSSUCC;

	f_pts21 = (IGRdouble *)BSstackalloc((unsigned)(nu * nv * 2 * sizeof(IGRdouble)));
	if (!f_pts21)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	if (!perm_uv)
	{
	    BSflatbspsf(surface_ext,nu,nv,uvpars,FALSE,off_dist,f_pts21,rc);
		if (BSERROR(*rc))
			goto wrapup;
	}
	else
	{
	    BSflatbspsf(surface_ext,nu,nv,uvpars,TRUE,off_dist,f_pts21,rc);
		if (BSERROR(*rc))
			goto wrapup;
	}


	/* Now we reverse surface in v, then unwrap it again */

	BSallocsf(surface_ext->u_order,surface_ext->v_order,surface_ext->u_num_poles,surface_ext->v_num_poles,
             surface_ext->rational,0,&surf_rv,rc);
	if (BSERROR(*rc))
		goto wrapup;

	(void)BSsf_copy(rc,surface_ext,surf_rv);
				
	(void)BSrevsf_v(rc,surf_rv);

	f_pts22 = (IGRdouble *)BSstackalloc((unsigned)(nu * nv * 2 * sizeof(IGRdouble)));
	if (!f_pts22)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	if (!perm_uv)
	{
	    BSflatbspsf(surf_rv,nu,nv,uvpars,TRUE,off_dist,f_pts22,rc);
		if (BSERROR(*rc))
			goto wrapup;
	}
	else
	{
	    BSflatbspsf(surf_rv,nu,nv,uvpars,FALSE,off_dist,f_pts22,rc);
		if (BSERROR(*rc))
			goto wrapup;
	}

	/* Reverse f_pts22  */

	Nu = nu/2;
	Nv = nv/2;
	
	for (j = 0; j < Nv; ++j)
	{
		for (i = 0; i < nu; ++i)
		{
			for (nd = 0; nd < 2; ++nd)
			{
				temp_pt[nd] = f_pts22[nd + 2 * i + (nv - 1 - j) * nu * 2];
				f_pts22[nd + 2 * i + (nv - 1 - j) * nu * 2] = f_pts22[nd + 2 * i + j * 2 * nu];
				f_pts22[nd + 2 * i + j * 2 * nu] = temp_pt[nd];
			}
		}
	}


	/* Find the average flat points between f_pts1 and f_pts3 */

	averageBSflatrelsf(nu,nv,f_pts21,f_pts22,FALSE,fltpts,rc);
	if (BSERROR(*rc))
		goto wrapup;

wrapup:
	if (surf_rv)
	{
		BSfreesf(&rc1,surf_rv);
	    if (BSERROR(rc1) && BSOKAY(*rc))
			*rc = rc1;
	}
	if (f_pts21)
		BSstackdealloc((char *) f_pts21);
	if (f_pts22)
		BSstackdealloc((char *) f_pts22);
	return;
}

	  

void BSflatrelsf(
struct IGRbsp_surface *surface,
IGRint                nu,
IGRint                nv,
IGRdouble             *uvpars,
IGRdouble             off_dist,
IGRdouble             *fltpts,
BSrc                  *rc)

{
#ifndef DONOTSPROTO
#include "bsallocsf.h"
#include "bsexch_u_v.h"
#include "bsfreesf.h"
#include "bsdbgrc.h"
#endif

#include <math.h>

	struct IGRbsp_surface *surf_pu = NULL;
	struct IGRbsp_surface *surf_rv = NULL;
	struct IGRbsp_surface *surf_puv = NULL;
	IGRint i,j,nd;
	IGRdouble *f_pts1 = NULL;
	IGRdouble *f_pts2 = NULL;
	IGRdouble *f_pts3 = NULL;
    IGRint temp_nu, temp_nv;
	BSrc rc1 = BSSUCC;
	IGRdouble *per_uvpars = NULL;

	*rc = BSSUCC;

	if (nu % 2 == 0 || nv % 2 == 0)
	{
		*rc = BSINARG;
		goto wrapup;
	}

	temp_nu = nu;
	temp_nv = nv;


	/* Extend surface */
/*
	extsf4sidesBSflatrelsf(surfaceinp,nu,nv,&surface,rc);
	if (BSERROR(*rc))
		goto wrapup;

	temp_nu = nu + 2;
	temp_nv = nv + 2;
*/

	/* Find average unwrapping points between input surface and input surface reverse v */

	f_pts1 = (IGRdouble *)BSstackalloc((unsigned)(temp_nu * temp_nv * 3 * sizeof(IGRdouble)));
	if (!f_pts1)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	avgunwrapBSflatrelsf(surface,temp_nu,temp_nv,uvpars,FALSE,off_dist,f_pts1,rc);
	if (BSERROR(*rc))
		goto wrapup;

	/* Now we permute surface u,v, then unwrap it again */

	BSallocsf(surface->v_order,surface->u_order,surface->v_num_poles,surface->u_num_poles,
             surface->rational,0,&surf_pu,rc);
	if (BSERROR(*rc))
		goto wrapup;

	(void)BSexch_u_v(rc,surface,surf_pu);
	if (BSERROR(*rc))
		goto wrapup;

	per_uvpars = (IGRdouble *)BSstackalloc((unsigned)(temp_nu * temp_nv * 2 * sizeof(IGRdouble)));
	if (!per_uvpars)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	f_pts2 = (IGRdouble *)BSstackalloc((unsigned)(temp_nu * temp_nv * 2 * sizeof(IGRdouble)));
	if (!f_pts2)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}	
	
	/* Exchange uvpars */

	for (i = 0; i < temp_nv; ++i)
	{
		for (j = 0; j < temp_nu; ++j)
		{
			per_uvpars[i * 2 + j * temp_nv * 2] = uvpars[1 + j * 2 + i * temp_nu * 2];
			per_uvpars[1 + i * 2 + j * temp_nv * 2] = uvpars[j * 2 + i * temp_nu * 2];
		}
	}

	avgunwrapBSflatrelsf(surf_pu,temp_nv,temp_nu,per_uvpars,TRUE,off_dist,f_pts2,rc);
	if (BSERROR(*rc))
		goto wrapup;

	/* Now permute f_pts2, then average with f_pts1 */

	f_pts3 = (IGRdouble *)BSstackalloc((unsigned)(temp_nu * temp_nv * 2 * sizeof(IGRdouble)));
	if (!f_pts3)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}	

	for (i = 0; i < temp_nv; ++i)
		for (j = 0; j < temp_nu; ++j)
			for (nd = 0; nd < 2; ++nd)
				f_pts3[nd + j * 2 + i * temp_nu * 2] = f_pts2[nd + i * 2 + j * temp_nv * 2];

	/* Find the average flat points between f_pts1 and f_pts3 */

	averageBSflatrelsf(temp_nu,temp_nv,f_pts1,f_pts3,TRUE,f_pts3,rc);
	if (BSERROR(*rc))
		goto wrapup;

	/* Set output uvparn and fltpts */

	for (i = 0; i < temp_nv; ++i)
	{
		for (j = 0; j < temp_nu; ++j)
		{
			for (nd = 0; nd < 2; ++nd)
				fltpts[nd + 3 * j + 3 * nu * i] = (f_pts1[nd + 2 * j + 2 * temp_nu * i] + 
															f_pts3[nd + 2 * j + 2 * temp_nu * i]) / 2;
			fltpts[2 + 3 * j + 3 * nu * i] = 0.0;
		}
	}


wrapup:
	if (surf_pu)
	{
		BSfreesf(&rc1,surf_pu);
	    if (BSERROR(rc1) && BSOKAY(*rc))
			*rc = rc1;
	}
	if (per_uvpars)
		BSstackdealloc((char *) per_uvpars);
	if (f_pts1)
		BSstackdealloc((char *) f_pts1);
	if (f_pts2) 
		BSstackdealloc((char *) f_pts2);
	if (f_pts3) 
		BSstackdealloc((char *) f_pts3);

if (BSERROR (*rc)) BSdbgrc (*rc, "BSflatrelsf");
  
  return;
}
