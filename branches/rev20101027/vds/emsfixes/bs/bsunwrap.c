/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSunwrap

Abstract
    This routine unwraps a B-spline surface.

Synopsis
    BSunwrap(surface,nu,nv,u_pars,v_pars,off_dist,flat_pts,rc)

    struct IGRbsp_surface *surface,
    IGRint                nu,
	IGRint                nv,
	IGRdouble             *u_pars,
	IGRdouble             *v_pars,
	IGRdouble             off_dist,
	IGRint                *nu_fltpts,
	IGRint                *nv_fltpts,
	IGRpoint              **flat_pts,
    BSrc                  *rc;
    

Description
    Input:
      surface - Surface need to be tesselated
      nu - number of points in u
	  nv - number of points in v
	  u_pars(nu) - array of parameters in u
	  v_pars(nv) - array of parameters in v
	  off_dist - offset distance

    Input/Output:

    Output:
      flat_pts(3,nu,nv) - Unfolded points
      *rc        Possible return codes include:

    Algorithm:

Return Values
    NA

Notes

Index
    ot

Keywords

History
    Vivian Y. Hsu   08/11/2000  : Creation date.
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
#endif

void BSunwrap(
struct IGRbsp_surface *surface,
IGRint nu,
IGRint nv,
IGRdouble *u_pars,
IGRdouble *v_pars,
IGRdouble off_dist,
IGRpoint *flat_pts,
BSrc *rc)

{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsmdstptssf.h"
#include "bsflatrelsf.h"
#endif

  IGRint i,j,nd,Nu,Nv;
  IGRdouble *f_pts = NULL;
  IGRdouble *uvs = NULL;
  IGRdouble *temp_u = NULL;
  IGRdouble *temp_v = NULL;
  IGRint add_u,add_v;
  IGRint temp_nu,temp_nv;

  /* Check if nu, nv are odd */

  if (nu % 2 == 0)
	  add_u = 1;
  else
	  add_u = 0;

  if (nv % 2 == 0)
	  add_v = 1;
  else
	  add_v = 0;

  temp_nu = nu + add_u;
  temp_nv = nv + add_v;

  /* Extends on both side */

  temp_nu += 2;
  temp_nv += 2;


  /* set the parameters array */

  uvs = (IGRdouble *)BSstackalloc((unsigned)(2 * temp_nu * temp_nv * sizeof(IGRdouble)));
  if (!uvs)
  {
	  *rc = BSNOSTKMEMORY;
	  goto wrapup;
  }
  f_pts = (IGRdouble *)BSstackalloc((unsigned)(3 * temp_nu * temp_nv * sizeof(IGRdouble)));
  if (!f_pts)
  {
	  *rc = BSNOSTKMEMORY;
	  goto wrapup;
  }

  temp_u = (IGRdouble *)BSstackalloc((unsigned)(temp_nu * sizeof(IGRdouble)));
  if (!temp_u)
  {
	*rc = BSNOSTKMEMORY;
	goto wrapup;
  }

  temp_v = (IGRdouble *)BSstackalloc((unsigned)(temp_nv * sizeof(IGRdouble)));
  if (!temp_v)
  {
	*rc = BSNOSTKMEMORY;
	goto wrapup;
  }

  if (add_u)
  {
	Nu = nu / 2;
	temp_u[0] = u_pars[0] - (u_pars[nu-1] - u_pars[nu-2]);
	for (i = 1; i <= Nu; ++i)
		temp_u[i] = u_pars[i-1];
	temp_u[Nu+1] = (u_pars[Nu - 1] + u_pars[Nu] ) / 2;

	for (i = Nu+2; i < temp_nu-1; ++i)
		temp_u[i] = u_pars[i - 2];
	temp_u[temp_nu-1] = u_pars[nu-1] + (u_pars[1] - u_pars[0]);
  }
  else
  {
	temp_u[0] = u_pars[0] - (u_pars[nu-1] - u_pars[nu-2]);
	for (i = 1; i <= nu; ++i)
		temp_u[i] = u_pars[i-1];
	temp_u[temp_nu-1] = u_pars[nu-1] + (u_pars[1] - u_pars[0]);
  }
	  

  if (add_v)
  {
	Nv = nv / 2;
	temp_v[0] = v_pars[0] - (v_pars[nv-1] - v_pars[nv-2]);
	for (i = 1; i <= Nv; ++i)
		temp_v[i] = v_pars[i-1];
	temp_v[Nv+1] = (v_pars[Nv - 1] + v_pars[Nv] ) / 2;

	for (i = Nv+2; i < temp_nv-1; ++i)
		temp_v[i] = v_pars[i - 2];
	temp_v[temp_nv-1] = v_pars[nv-1] + (v_pars[1] - v_pars[0]);
  }
  else
  {
	temp_v[0] = v_pars[0] - (v_pars[nv-1] - v_pars[nv-2]);
	for (i = 1; i <= nv; ++i)
		temp_v[i] = v_pars[i-1];
	temp_v[temp_nv-1] = v_pars[nv-1] + (v_pars[1] - v_pars[0]);
  }

  for (i = 0; i < temp_nv; ++i)
  {
	  for (j = 0; j < temp_nu; ++j)
	  {
		uvs[j * 2 + i * 2 * temp_nu] = temp_u[j];
		uvs[1 + j * 2 + i * 2 * temp_nu] = temp_v[i];
	  }
  }


  /* Call BSflatrelsf to get flattened points */

  BSflatrelsf(surface,temp_nu,temp_nv,uvs,off_dist,f_pts,rc);
  if (BSERROR(*rc))
    goto wrapup;

  /* If add_u or add_v is TRUE, we have to take a row or a column out. */
  /* Also take extended row and column out */

  Nv = temp_nv  / 2;
  if (add_v)
  {
	  /* Remove the center row */
	  
	  for (i = 1; i < Nv; ++i)
		  for (j = 1; j < temp_nu-1;++j)
			for (nd = 0; nd < 3; ++nd)
				f_pts[nd + 3*(j-1) + 3 * (i-1) * (temp_nu-2)] = f_pts[nd + 3*j + 3*i * temp_nu];

	  for (i = Nv+1; i < temp_nv-1; ++i)
		  for (j = 1; j < temp_nu-1;++j)
			for (nd = 0; nd < 3; ++nd)
				f_pts[nd + 3*(j-1) + 3*(i-2) * (temp_nu-2)] = f_pts[nd+3*j + 3*i * temp_nu];
  }
  else
  {
	  for (i = 1; i < temp_nv-1; ++i)
		  for (j = 1; j < temp_nu-1;++j)
			for (nd = 0; nd < 3; ++nd)
				f_pts[nd + 3*(j-1) + 3 * (i-1) * (temp_nu-2)] = f_pts[nd + 3*j + 3*i * temp_nu];
  
  }
  
  temp_nu -= 2;
  temp_nv -= 2;
  Nu = temp_nu  / 2;
  
  if (add_u)
  {
	  /* Remove the center column */
	  
	  for (i = 0; i < nv; ++i)
		  for (j = 0; j < Nu;++j)
			for (nd = 0; nd < 3; ++nd)
				flat_pts[j + i * nu][nd] = f_pts[nd + 3 * j + 3 * i * temp_nu];

	  for (i = 0; i < nv; ++i)
		  for (j = Nu+1; j < temp_nu;++j)
			for (nd = 0; nd < 3; ++nd)
				flat_pts[j-1 + i * nu][nd] = f_pts[nd + 3 * j + 3 * i * temp_nu];
  }
  else
  {
	  for (i = 0; i < nv; ++i)
		  for (j = 0; j < nu;++j)
			for (nd = 0; nd < 3; ++nd)
				flat_pts[j + i * nu][nd] = f_pts[nd + 3 * j + 3 * i * nu];
  }




wrapup:
  if (uvs)
    BSstackdealloc((char *) uvs);
  if (f_pts)
    BSstackdealloc((char *) f_pts);
  if (temp_u )
	BSstackdealloc((char *) temp_u);
  if (temp_v )
	BSstackdealloc((char *) temp_v);

  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSunwrap");

  return;
}
