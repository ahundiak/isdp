/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmvcsnsfvc

Abstract
    This routine constructs a surface by moving a cross section 
    normal to the input surface along the input curve.

Synopsis
    void BSmvcsnsfvc(surf,dirpt,curve,crs,pt,vmat,vec,rhs_sys,abs_vec,v,
                     crs_surf,cv_on_sf,rc)
 
    IGRbsp_surface      *surf;
    IGRpoint            dirpt;
    IGRbsp_curve        *curve;
    IGRbsp_curve        *crs;
    IGRpoint            pt;
    IGRdouble           vmat[3][3];
    IGRvector           vec;
    IGRboolean          rhs_sys;
    IGRboolean          abs_vec;
    IGRvector           v;
    IGRbsp_surface      **crs_surf;
    IGRboolean          *cv_on_sf;
    BSrc                *rc;
 
Description
    Given a surface (surf), a direction point (dirpt) to define the 
    direction for the surface normals, a curve (curve) which is on the
    (surf), a cross section (crs) created in a view, a reference point (pt)
    to be moved along the curve, the view matrix (vmat), and a vector
    (vec) to define a local x-axis, a boolean flag (rhs_sys) will indicate
    the  surface (crs_surf) is created in a right_hand system or left_hand 
    system by moving the (crs) along the (curve), orienting it such that 
    the local coordinate system is normal to both the (curve) and the (surf).
    If the (curve) is not within 2 * chrdht_tol on the (surf), (cv_on_sf)
    will be set to FALSE, else it is set to TRUE.
       The reference point (pt) is the origin of the local system, (vec)
    defines the local x-axis and the view y-axis will be aligned with the
    surface normal at the node points of the (curve).the (vec) will be
    aligned with the cross product of the (curve) tangent with the (surf)
    normal if (abs_vec) is FALSE, else (vec) will be aligned with input
    vector (v). if (v) is NULL then it will be aligned with the cross
    product of the (curve) tangent at u = t[k - 1] with (surf) normal.
    
Return Values
    If successful, BSSUCC is returned.

Notes

Index
    em

Keywords

History
    Vivian W.Ye     08/01/89     : Creation date.
    Vivian W.Ye     08/15/89     : Pass num_knots,knots and pars into
                                   BSfitratcv to fit curves.
    Vivian W.Ye     11/16/89     : If pt is not a pole of crs, then add
                                   knot with multiplicity ( k - 1) to 
                                   crs.
    Vivian W.Ye     12/29/89     : Fixed an index error in the "for" loop
                                   when compareing par_uv with surface 
                                   cusps.
                                   If cv->order is 2 , keep all cusps
                                   to cmpare with surface cusps
    Vivian W.Ye     01/09/90     : Call BSfitratcv with code = 1.
    Vivian W.Ye     01/12/90     : Revised part of this routine for
                                   rational trace curve and rational
                                   cross section curve.
                                   Set pole_ind = 100000 if the pt is
                                   not on the trace curve.
    S.G. Catron     11/20/90     : Fixed the apogee errors.
    Vivian W.Ye     04/24/91     : Use the start and end poles of the
                                   trace curve to find tmat2.
    Vivian W.Ye     06/24/91     : If the trace curve starts or ends 
                                   (curve is not closed ) on the surface 
                                   cusps, go on to creat output surface 
                                   instead return BSINARG.
    Vivian W.Ye     02/18/92     : Using BSalloccv for crs1 to be consistent
                                   with free crs1 in BSadd_kt.

    S.G. Catron     10/15/92   : Made it work correctly for cross sections
                                 that were tilted 90 degrees and user
                                 gives y axis as local x vector.
    S.G. Catron     10/30/92   : Changed dist_tol before calling 
                                 BSfndsfcsp, so that the routine will work
                                 for surfaces with tiny cusps.  Also, it
                                 was not freeing allocated array "np".
    S.G. Catron     03/30/93   : Changed the positioning of the cross
                                 section when there is a cusp.  The 
                                 cross section is positioned using the
                                 left derivative, then projected onto the
                                 average tangent plane.
    S.G. Catron     12/08/93   : In above change, normalize the tangent
                                 vectors before taking the average.
                                 This fixes TR#119314168.
    Vivian Y. Hsu   03/12/98   : In case of BSINARG (where par_uv are ]
                                 same as cusp surface), I shifted par_uv 
                                 by 10 * sf_knot_tol and set rc1 = BSWARN 
                                 and continue. This is a kludge for VDS.

*/

#include "bs.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsstk.h"
#include "bsmemory.h"
#define BSVOID
#include "bsparameters.h"
#define  MAXNUM  100


void BSmvcsnsfvc(
struct  IGRbsp_surface      *surf,
IGRpoint                    dirpt,
struct  IGRbsp_curve        *curve,
struct  IGRbsp_curve        *crs,
IGRpoint                    pt,
IGRdouble                   vmat[3][3],
IGRvector                   vec,
IGRboolean                  rhs_sys,
IGRboolean                  abs_vec,
IGRvector                   v,
struct  IGRbsp_surface      **crs_surf,
IGRboolean                  *cv_on_sf,
BSrc                        *rc)
{
#include "bsdbgrc.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsproj1.h"
#include "bscnvtomkt.h"
#include "bslocalcord.h"
#include "bscvoton.h"
#include "bscvntoo.h"
#include "bsmdistptsf.h"
#include "bsptoldtnw.h"
#include "bscv_copy.h"
#include "bsfreecv.h"
#include "bscveval_b.h"
#include "bsactivsplt.h"
#include "bsprptoncv.h"
#include "bsadd_kt.h"
#include "bsfindspn.h"
#include "bscveval.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bsnodevals.h"
#include "bsprptsonsf.h"
#include "bssfarrevn.h"
#include "bsfitratcv.h"
#include "bsfndsfcsp.h"
#include "bsfndcvcsp.h"
#include "bstst_plan.h"
#include "bssfsetclsd.h"
#include "bssfkttol2.h"
#include "bscvkttol2.h"
#include "bsreparmcv.h"
#include "bsfndspnarr.h"
#include "bscvarrev0w.h"
#include "bschangepar.h"
#include "bsprj_cv_pl.h"
  struct IGRbsp_curve  *cv = NULL;
  struct IGRbsp_curve  *crs1 = NULL;
  struct IGRbsp_curve  *crs11 = NULL;
  struct IGRbsp_curve  **crs2 = NULL;
  struct IGRbsp_curve  **temp_cvs = NULL;
  IGRvector            *ttan = NULL,tan_array[MAXNUM];
  IGRvector            tanpoll,tanpolr,crvpoll,crvpolr;
  IGRvector            n,v2,nvec,avg_tan,crs_vec;
  IGRpoint             *points = NULL,points_array[MAXNUM];
  IGRpoint             *fit_pts = NULL,fit_pts_array[MAXNUM];
  IGRpoint             x,y,xx,yy;
  IGRpoint             p;
  IGRpoint             base,x_pt,origin,maxpt;
  IGRpoint             left_derv[2],right_derv[2];
  IGRdouble            *cspu = NULL,*cspv = NULL;
  IGRdouble            cspu_array[MAXNUM],cspv_array[MAXNUM];
  IGRdouble            *cv_csp = NULL,cv_csp_array[MAXNUM];
  IGRdouble            *nodvals = NULL,nodvals_array[MAXNUM];
  BSpair               *par_uv = NULL,par_uv_array[MAXNUM];
  IGRdouble            *fit_wts = NULL,fit_wts_array[MAXNUM];
  IGRdouble            *temp_knots = NULL,temp_knots_array[MAXNUM];
  IGRdouble            *pars = NULL,pars_array[MAXNUM];
  IGRdouble            tmat1[3][3],tmat2[3][3];
  IGRdouble            tolerance = 0,avgerr,maxerr;
  IGRdouble            s = 1;
  IGRdouble            dpu,dpv,dpdist,dot;
  IGRdouble            knot_tol,sf_knot_tol;
  IGRdouble            *pts_wts = NULL,pts_wts_array[4 * MAXNUM];
  IGRdouble            *trcv_wts = NULL,trcv_wts_array[MAXNUM];
  IGRint               *csp_ind = NULL,csp_ind_array[MAXNUM];
  IGRint               *spn_ind = NULL,spn_ind_array[MAXNUM];
  IGRint               *np = NULL,np_array[MAXNUM];
  IGRint               i,j,ii,jj,start = 0, end;
  IGRint               count,total_num=0;
  IGRint               ncspu,ncspv,ncv_csp,n_fitpts=0;
  IGRint               num_vals,num_par=0,num_derv = 1;
  IGRint               maxind,num_knots;
  IGRint               *spn = NULL,spn_array[MAXNUM];
  IGRboolean           tst_plan = FALSE,smooth = FALSE;
  IGRboolean           right_hand = TRUE,rational,input_vec;
  IGRboolean           side,eval_bound = TRUE,boundary;
  IGRdouble            parval,crs_knot_tol;
  IGRint               pole_ind,mul,code = 1;
  IGRboolean           on_cv;
  BSrc                 rc1;
  IGRdouble            dist_tol, sdist_tol;

  *rc = BSSUCC;
  rc1 = BSSUCC;

  *cv_on_sf = TRUE;
  input_vec = TRUE;
  if (abs_vec && v[0] == 0 && v[1] == 0 && v[2] == 0)
    input_vec = FALSE;

  BScvkttol2(curve->order,curve->knots,curve->num_poles,curve->poles,
             curve->weights,&knot_tol,rc);
  if (BSERROR(*rc))
    goto wrapup;

  BScvkttol2(crs->order,crs->knots,crs->num_poles,crs->poles,
             crs->weights,&crs_knot_tol,rc);
  if (BSERROR(*rc))
    goto wrapup;

  BSsfkttol2(surf->u_order,surf->v_order,surf->u_knots,surf->v_knots,
             surf->u_num_poles,surf->v_num_poles,surf->poles,
             surf->weights,&sf_knot_tol,rc);
  if (BSERROR(*rc))
    goto wrapup;

  /* If curve is periodic, Change to knots with multiple end knots */

  BSalloccv(curve->order,curve->num_poles,curve->rational,
            curve->num_boundaries,&cv,rc);
  if (BSERROR(*rc))
    goto wrapup;
  
  (void)BScv_copy(rc,curve,cv);
  if (BSERROR(*rc))
    goto wrapup;

  if (curve->periodic)
  {
    (void)BScnvtomkt(rc,cv);
    if (BSERROR(*rc))
      goto wrapup;
  }

  /* find surface,curve cusp */

  if (surf->u_num_poles - surf->u_order + 1 <= MAXNUM)
  {
    cspu = &cspu_array[0];
  }
  else
  { 
    cspu = (IGRdouble *)BSstackalloc((unsigned) 
           (surf->u_num_poles - surf->u_order + 1) * sizeof(IGRdouble));
    if (!cspu)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
  }

  if (surf->v_num_poles - surf->v_order + 1 <= MAXNUM)
  {
    cspv = &cspv_array[0];
  }
  else
  { 
    cspv = (IGRdouble *)BSstackalloc((unsigned) 
           (surf->v_num_poles - surf->v_order + 1) * sizeof(IGRdouble));
    if (!cspv)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
  }
  BSEXTRACTPAR(rc,BSTOLLENVEC,sdist_tol);
  dist_tol = sdist_tol * 10;
  (void)BSchangepar(rc, BSTOLLENVEC, dist_tol );
  if( BSERROR(*rc))
     goto wrapup;
  BSfndsfcsp(surf,&ncspu,cspu,&ncspv,cspv,rc);
  (void)BSchangepar(&rc1, BSTOLLENVEC, sdist_tol );
  if( BSERROR(rc1) && BSOKAY(*rc) )
  {
     *rc = rc1;
     goto wrapup;
  }
  if (BSERROR(*rc))
    goto wrapup;

  if (cv->num_poles - cv->order + 3 <= MAXNUM)
  {
    cv_csp = &cv_csp_array[0];
    spn_ind = &spn_ind_array[0];
    np = &np_array[0];
  }
  else
  {
    cv_csp = (IGRdouble *)BSstackalloc((unsigned)
             (cv->num_poles - cv->order + 3) * sizeof(IGRdouble));
    if (!cv_csp)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    spn_ind = (IGRint *)BSstackalloc((unsigned)
             (cv->num_poles - cv->order + 3) * sizeof(IGRint));
    if (!spn_ind)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    np = (IGRint *)BSstackalloc((unsigned)
             (cv->num_poles - cv->order + 3) * sizeof(IGRint));
    if (!np)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
  }

  BSfndcvcsp(cv,&ncv_csp,cv_csp,rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (ncv_csp == 0 )
  {
    smooth = TRUE;
    cv_csp[0] = cv->knots[cv->order - 1];
    cv_csp[1] = cv->knots[cv->num_poles];
    ncv_csp = 2;
  }
  else
  {
    if (ABS(cv_csp[0] - cv->knots[cv->order - 1]) > knot_tol)
    {
      smooth = TRUE;
      for (i = ncv_csp; i >= 1; --i)
      {
        cv_csp[i] = cv_csp[i - 1];
      }
      cv_csp[0] = cv->knots[cv->order - 1];
      ncv_csp++;
    }
    cv_csp[ncv_csp] = cv->knots[cv->num_poles];
    ncv_csp++;
  }


  /* transform the cross section to local system by vmat */

  BSalloccv(crs->order,crs->num_poles,crs->rational,crs->num_boundaries,
             &crs1,rc);
  if (!crs1)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  (void)BScv_copy(rc,crs,crs1);
  if (BSERROR(*rc))
    goto wrapup;

  /* find the parameter value corresponding to pt on crs 11/15/89 */

  (void)BSprptoncv(rc,crs,pt,&parval,&on_cv);
  if (BSERROR(*rc))
    goto wrapup;

  if (on_cv)
  {
    if (ABS(parval - crs->knots[crs->order - 1]) < crs_knot_tol)
      pole_ind = 0;
    else if (ABS(parval - crs->knots[crs->num_poles]) < crs_knot_tol)
      pole_ind = crs->num_poles - 1;
    else
    {
      mul = crs->order - 1;
      (void)BSadd_kt(rc,crs1,&parval,&mul);
      if (BSERROR(*rc))
        goto wrapup;
  
      (void)BSfindspn(rc,&crs1->order,&crs1->num_poles,crs1->knots,
                         &parval,&pole_ind);
      if (BSERROR(*rc))
        goto wrapup;
    }
  }
  else
  {
    pole_ind = 100000;
  }

  (void)BScvoton(rc,pt,vmat,&s,crs1,crs1);
  if (BSERROR(*rc))
    goto wrapup;

  (void)BSnorvec(rc,vec);
  if (BSERROR(*rc))
    goto wrapup;

  for (i = 0; i < 3; ++i)
  {
    x_pt[i] = pt[i] + vec[i];
  }

  (void)BSptoldtnw(rc,pt,vmat,&s,x_pt,x);
  if (BSERROR(*rc))
    goto wrapup;


  /* creat a local cordinate for cross section */

  x[2] = 0;
  if( ABS(x[0]) > ABS(x[1]) )
  {
    if( x[0] < 0) 
    {
      x[0] = -x[0];
      x[1] = -x[1];
    }
  }
  else
  {
    /* x[1] > x[0]  */
    if( x[1] > 0 )
    {
       x[0] = -x[0];
       x[1] = -x[1];
    }
  }
  y[0] = -x[1];
  y[1] = x[0];

  y[2] = 0;

  origin[0] = 0;
  origin[1] = 0;
  origin[2] = 0;

  (void)BSlocalcord(rc,origin,x,y,&right_hand,tmat1);
  if (BSERROR(*rc))
    goto wrapup;

  /* transform the cross section to local system */

  BSstkallocv(rc,crs11,crs1->num_poles,crs1->rational,crs1->num_knots,
                     crs1->num_boundaries);
  if (!crs11)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  (void)BScv_copy(rc,crs1,crs11);
  if (BSERROR(*rc))
    goto wrapup;

  (void)BScvoton(rc,origin,tmat1,&s,crs1,crs11);
  if (BSERROR(*rc))
    goto wrapup;

    
  /* find the node values of the curve */

  if ( cv->num_knots + (ncv_csp - 1) * 2 <= MAXNUM )
  {
    temp_knots = &temp_knots_array[0];
  }
  else
  {
    temp_knots = (IGRdouble *)BSstackalloc((unsigned)
                (cv->num_knots + (ncv_csp - 1) * 2) * sizeof(IGRdouble));
    if (!temp_knots)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
  }

  if (ncv_csp - 2 > 0)
  {
    BSfndspnarr(cv->order,cv->num_poles,ncv_csp,cv_csp,
                cv->knots,spn_ind,rc);
    if (BSERROR(*rc))
      goto wrapup;
    for (i = 1; i < ncv_csp - 1; ++i)
      spn_ind[i] += 1;
  }


  if ( cv->num_poles <= MAXNUM )
  {
    nodvals = &nodvals_array[0];
    par_uv = par_uv_array;
    points = points_array;
    ttan = tan_array;
    csp_ind = &csp_ind_array[0];
    pars = &pars_array[0];
  }
  else
  {
    nodvals = (IGRdouble *)BSstackalloc((unsigned)
                         (cv->num_poles * sizeof(IGRdouble)));
    if (!nodvals)    
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
    par_uv = (BSpair *)BSstackalloc((unsigned)
                         (cv->num_poles * sizeof(BSpair)));
    if (!par_uv)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    points= (IGRpoint *)BSstackalloc((unsigned)
                       (cv->num_poles * sizeof(IGRpoint)));
    if (!points)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }

    ttan = (IGRpoint *)BSstackalloc((unsigned)
                       (cv->num_poles * sizeof(IGRpoint)));
    if (!ttan)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
    csp_ind = (IGRint *)BSstackalloc((unsigned)
                       (cv->num_poles * sizeof(IGRint)));
    if (!csp_ind)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
    pars = (IGRdouble *)BSstackalloc((unsigned)
                            (cv->num_poles * sizeof(IGRdouble)));
    if (!pars)
    {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
    }
  }

  BSnodevals(cv->order,cv->num_knots,cv->knots,
                       0,&num_vals,nodvals,rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (cv->rational)
  {
    if (cv->num_poles <= MAXNUM)
    {
      pts_wts = &pts_wts_array[0];
      trcv_wts = &trcv_wts_array[0];
    }
    else
    {
      pts_wts = (IGRdouble *)BSstackalloc((unsigned)
                             (4 * cv->num_poles * sizeof(IGRdouble)));
      if (!pts_wts)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
      trcv_wts = (IGRdouble *)BSstackalloc((unsigned)
                            (cv->num_poles * sizeof(IGRdouble)));
      if (!trcv_wts)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
    }

    BScvarrev0w(cv,num_vals,nodvals,pts_wts,rc);
    if (BSERROR(*rc))
      goto wrapup;

    for (i = 0; i < num_vals; ++i)
      trcv_wts[i] = pts_wts[4 * i + 3];
  }
    
  crs2 = (struct IGRbsp_curve **)BSstackalloc((unsigned)
                             (num_vals * sizeof(struct IGRbsp_curve *)));  
  if (!crs2)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  for (i = 0; i < num_vals; i++)
  {
    crs2[i] = NULL;
  }

  /* move the cross section along the curve at each node point */

  if (ncv_csp - 2 > 0)
  {
    BSfndspnarr(cv->order,(cv->num_knots - cv->order),ncv_csp,
                cv_csp,cv->knots,spn_ind,rc);
    if (BSERROR(*rc))
      goto wrapup;
    np[0] = spn_ind[1] + 1;
    np[ncv_csp - 2] = num_vals - spn_ind[ncv_csp - 2];
    for (i = 1; i < ncv_csp - 2; ++i)
      np[i] = spn_ind[i + 1] - spn_ind[i] + 1;
  }
  else
  {
    np[0] = num_vals;
  }

  /* modified on 01/08/1990 */

  num_par = 0;
  csp_ind[0] = 0;

  for (i = 0; i < ncv_csp - 1; ++i)
  {
    start = i == 0 ? 0:start + np[i - 1] - 1;
    if (i == 0)
    {
      (void)BScveval_b(rc,cv,&nodvals[0],&num_derv,&eval_bound,
                        &boundary,left_derv,right_derv);
      if (BSERROR(*rc))
        goto wrapup;

      for (jj = 0; jj < 3; ++jj)
      {
        points[num_par][jj] = left_derv[0][jj];
        ttan[num_par][jj] = left_derv[1][jj];
      }
      pars[num_par] = nodvals[0];
      num_par++;
    }
    end = start + np[i];
    for (ii = start + 1; ii < end; ++ii)   
    {
      (void)BScveval_b(rc,cv,&nodvals[ii],&num_derv,&eval_bound,
                        &boundary,left_derv,right_derv);
      if (BSERROR(*rc))
        goto wrapup;

      for (jj = 0; jj < 3; ++jj)
        points[num_par][jj] = left_derv[0][jj];
      pars[num_par] = nodvals[ii];
      /* use the left derivative at cusp values(ii==end-1), because we  
         will position the cross section using the left derivative, then
         project onto the average tangent plane */
      if (!abs_vec && boundary && ii != end-1)
      {
        for (jj = 0; jj < 3; ++jj)
          ttan[num_par][jj] = (left_derv[1][jj] + right_derv[1][jj]) / 2;
      }
      else
      {
        for (jj = 0; jj < 3; ++jj)
          ttan[num_par][jj] = left_derv[1][jj];
      }
      num_par++;
    }
    csp_ind[i + 1] = num_par - 1;
  }

  if (!abs_vec && cv->phy_closed && !smooth)
  {
    (void)BSnorvec(rc,ttan[0]);
    if (BSERROR(*rc))
      goto wrapup;
    (void)BSnorvec(rc,ttan[num_par-1]);
    if (BSERROR(*rc))
      goto wrapup;
    for (j = 0; j < 3; ++j)
    {
      avg_tan[j] = (ttan[0][j] + ttan[num_par - 1][j]) / 2;
    }
    (void)BSnorvec(rc,avg_tan);
    if (BSERROR(*rc))
      goto wrapup;
 
    for (j = 0; j < 3; ++j)
    {
      ttan[0][j] = avg_tan[j];
      ttan[num_par - 1][j] = avg_tan[j];
    }
  }
  
  BSprptsonsf(num_par,points,surf,par_uv,cv_on_sf,rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (cv->phy_closed)
  {
    for (i = 0; i < ncv_csp; ++i)
    {
      for (j = 0; j < ncspu; ++j)
      {
        if (ABS(par_uv[csp_ind[i]][0] - cspu[j]) < sf_knot_tol)
        {
          /* To avoid error out, we give a warning and modify 
             par_uv by 10 * sf_knot_tol */
          
          par_uv[csp_ind[i]][0] += 10 * sf_knot_tol;
          rc1 = BSWARN;
        }
      }
    }

    for (i = 0; i < ncv_csp; ++i)
    {
      for (j = 0; j < ncspv; ++j)
      {
        if (ABS(par_uv[csp_ind[i]][1] - cspv[j]) < sf_knot_tol)
        {
          /* To avoid error out, we give a warning and modify 
             par_uv by 10 * sf_knot_tol */
          
          par_uv[csp_ind[i]][1] += 10 * sf_knot_tol;
          rc1 = BSWARN;
        }
      }
    }
  }
  else
  {
    for (i = 1; i < ncv_csp - 1; ++i)
    {
      for (j = 0; j < ncspu; ++j)
      {
        if (ABS(par_uv[csp_ind[i]][0] - cspu[j]) < sf_knot_tol)
        {
          /* To avoid error out, we give a warning and modify 
             par_uv by 10 * sf_knot_tol */
          
          par_uv[csp_ind[i]][0] += 10 * sf_knot_tol;
          rc1 = BSWARN;
        }
      }
    }

    for (i = 1; i < ncv_csp - 1; ++i)
    {
      for (j = 0; j < ncspv; ++j)
      {
        if (ABS(par_uv[csp_ind[i]][1] - cspv[j]) < sf_knot_tol)
        {
          /* To avoid error out, we give a warning and modify 
             par_uv by 10 * sf_knot_tol */
          
          par_uv[csp_ind[i]][1] += 10 * sf_knot_tol;
          rc1 = BSWARN;
        }
      }
    }
  }

  (void)BSmdistptsf(rc,surf,dirpt,&dpu,&dpv,base,&dpdist);
  if (BSERROR(*rc))
    goto wrapup;

  BSsfarrevn(rc,surf,1,&dpu,1,&dpv,(IGRdouble *)p,(IGRdouble *)n);
  if (BSERROR(*rc))
    goto wrapup;
  
  dot = (dirpt[0] - base[0]) * n[0] +
        (dirpt[1] - base[1]) * n[1] +
        (dirpt[2] - base[2]) * n[2];
  if (dot < 0)
    side = FALSE;
  else
    side = TRUE;

  ii = 0;
  for (i = 0; i < num_par; ++i)
  {
    BSsfarrevn(rc,surf,1,&par_uv[i][0],1,&par_uv[i][1],(IGRdouble *)p,
                                               (IGRdouble *)n);
    if (BSERROR(*rc))
      goto wrapup;
    
    if (!side)
    {
      n[0] = -n[0];
      n[1] = -n[1];
      n[2] = -n[2];
    }

    if (!abs_vec)
    {
      (void)BScrossp(rc,ttan[i],n,v2);
      if (BSERROR(*rc))
        goto wrapup;
     
      (void)BSnorvec(rc,v2);
      if (BSERROR(*rc))
        goto wrapup;
    }
    else
    {
      if (i == 0)
      {
        if (input_vec)
        {
          (void)BScrossp(rc,n,v,crs_vec);
          if (BSERROR(*rc))
            goto wrapup;

          (void)BScrossp(rc,crs_vec,n,v2);
          if (BSERROR(*rc))
            goto wrapup;
      
          (void)BSnorvec(rc,v2);
          if (BSERROR(*rc))
            goto wrapup;
        }
        else
        {   
          (void)BScrossp(rc,ttan[0],n,v2);
          if (BSERROR(*rc))
            goto wrapup;

          (void)BSnorvec(rc,v2);
          if (BSERROR(*rc))
            goto wrapup;
        }
      }
    }

    if (i == 0 )    
    {
      if (cv->rational)
      {
        for (j = 0; j < 3; ++j)
          p[j] = cv->poles[j] / cv->weights[0];
      }
      else
      {
        for (j = 0; j < 3; ++j)
          p[j] = cv->poles[j];
      }
    }
    else if (i == num_par - 1)
    {
      if (cv->rational)
      {
        for (j = 0; j < 3; ++j)
        {
          p[j] = cv->poles[3 * (cv->num_poles - 1) + j] / 
	           cv->weights[cv->num_poles - 1];
        }
      }
      else
      {
        for (j = 0; j < 3; ++j)
          p[j] = cv->poles[3 * (cv->num_poles - 1) + j];
      }
    }     
  
    if (rhs_sys)
    {
      for (j = 0; j < 3;++j)
      {
        xx[j] = p[j] + v2[j];
        yy[j] = p[j] + n[j];
      }
    }
    else
    {
      for (j = 0; j < 3;++j)
      {
        xx[j] = p[j] - v2[j];
        yy[j] = p[j] + n[j];
      }
    }      

    (void)BSlocalcord(rc,p,xx,yy,&right_hand,tmat2);
    if (BSERROR(*rc))
      goto wrapup;

    BSstkallocv(rc,crs2[i],crs11->num_poles,crs11->rational,
                           crs11->num_knots,crs11->num_boundaries);
    if (BSERROR(*rc))
      goto wrapup;
    
    (void)BScv_copy(rc,crs11,crs2[i]);
    if (BSERROR(*rc))
      goto wrapup;

    (void)BScvntoo(rc,p,tmat2,&s,crs11,crs2[i]);
    if (BSERROR(*rc))
      goto wrapup;
    /* at cusps: we want to project the cross section onto the average
       tangent plane(if not abs_vec)  */
    if(  i == csp_ind[ii] && !abs_vec)
    {
      ii++;
      if( i != 0 && i != num_par-1)
      {
        (void)BScveval_b(rc,cv,&nodvals[i],&num_derv,&eval_bound,
                         &boundary,left_derv,right_derv);
        if (BSERROR(*rc))
          goto wrapup;
        (void)BSnorvec(rc, left_derv[1] );
        if(BSERROR(*rc))
          goto wrapup;
        (void)BSnorvec(rc, right_derv[1] );
        if(BSERROR(*rc))
          goto wrapup;
        avg_tan[0] = (left_derv[1][0] + right_derv[1][0] ) / 2;
        avg_tan[1] = (left_derv[1][1] + right_derv[1][1] ) / 2;
        avg_tan[2] = (left_derv[1][2] + right_derv[1][2] ) / 2;
        (void)BSnorvec(rc, avg_tan );
        if(BSERROR(*rc))
          goto wrapup;
        (void)BSprj_cv_pl(rc, crs2[i], left_derv[0], avg_tan, 
                          left_derv[1], crs2[i] );
        if(BSERROR(*rc))
          goto wrapup;
      }
    }
  }

  if (cv->order > 2)
  {
    /* allocate temperoary curves for fit */

    total_num = crs1->num_poles * (ncv_csp - 1);
    temp_cvs = (struct IGRbsp_curve **)BSmalloc((unsigned)
                         (total_num * sizeof(struct IGRbsp_curve *)));
    if (!temp_cvs)
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }

    for (i = 0; i < total_num; ++i)
      temp_cvs[i] = NULL;

    if (num_par <= MAXNUM)
    {
      fit_pts = fit_pts_array;
      if (cv->rational && crs1->rational)
      {
        fit_wts = &fit_wts_array[0];
      }
      spn = &spn_array[0];
    }
    else
    {
      fit_pts = (IGRpoint *)BSstackalloc((unsigned)
                            (num_par * sizeof(IGRpoint)));
      if (!fit_pts)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
      if (cv->rational && crs1->rational)
      {
        fit_wts = (IGRdouble *)BSstackalloc((unsigned)
                                      (num_par * sizeof(IGRdouble)));
        if (!fit_wts)
        {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
        }
      }
      spn = (IGRint *)BSstackalloc((unsigned)
                                  (num_par * sizeof(IGRint)));
      if (!spn)
      {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
      }
    }
  
    /* constructs the output surface, first row is the part of curve */
  
    start = 0;
    for (i = 0; i < ncv_csp - 1; ++i)
    {
      for (j = 0; j < crs1->num_poles; ++j)
      {
        if (j == pole_ind || 
         (j == crs1->num_poles - 1 && pole_ind == 0 && crs1->phy_closed) )
        {
          BSalloccv(cv->order,cv->num_poles,cv->rational,0,
                    &temp_cvs[i * crs1->num_poles + j],rc);
          if (BSERROR(*rc))
            goto wrapup;

          (void)BSactivsplt(rc,cv,&cv_csp[i],&cv_csp[i + 1],
                           temp_cvs[i * crs1->num_poles + j],&tst_plan);
          if (BSERROR(*rc))
            goto wrapup;
        }
        else
        {  
          /* prepare array of points and weights for fitting */

          n_fitpts = 0;
          for(ii = csp_ind[i]; ii <= csp_ind[i + 1]; ++ii)
          {
            if (!cv->rational)
            {
              if (!crs1->rational)
              {
                for (jj = 0; jj < 3; ++jj)
                  fit_pts[n_fitpts][jj] = crs2[ii]->poles[j * 3 + jj];
              }
              else
              {
                for (jj = 0; jj < 3; ++jj)
                  fit_pts[n_fitpts][jj] = crs2[ii]->poles[j * 3 + jj] /
                                          crs2[ii]->weights[j];
              }
            }
            else
            {
              if (!crs1->rational)
              {
                for (jj = 0; jj < 3; ++jj)
                  fit_pts[n_fitpts][jj] = crs2[ii]->poles[j * 3 + jj] *
                                          trcv_wts[ii];
              }
              else
              {
                for (jj = 0; jj < 3; ++jj)
                  fit_pts[n_fitpts][jj] = crs2[ii]->poles[j * 3 + jj] *
                                          trcv_wts[ii];
                fit_wts[n_fitpts] = crs2[ii]->weights[j] * trcv_wts[ii];
              }
            }
            n_fitpts++;
          }

          if (ncv_csp > 2)
          {
            num_knots = cv->order;
            if (i == 0)
            {
              for (ii = 0; ii < cv->order; ++ii)
                temp_knots[ii] = cv->knots[spn_ind[i]];

              for (ii = spn_ind[i] + 1; ii < spn_ind[i + 1] + 1; ++ii)
              {
                temp_knots[num_knots] = cv->knots[ii];
                num_knots++;
              }
            }
            else
            {
              for (ii = 0; ii < cv->order; ++ii)
                temp_knots[ii] = cv->knots[spn_ind[i] + 1];
 
              for (ii = spn_ind[i] + cv->order; 
                                   ii < spn_ind[i + 1] + 1; ++ii)
              {
                temp_knots[num_knots] = cv->knots[ii];
                num_knots++;
              }
            }

            for (ii = 0;ii < cv->order; ++ii)
            {
              temp_knots[num_knots] = cv->knots[spn_ind[i + 1] + 1];
              num_knots++;
            }
          }
          else
          {
            num_knots = cv->num_knots;
            for (ii = 0; ii < num_knots; ++ii)
              temp_knots[ii] = cv->knots[ii];
          }

          BSfndspnarr(cv->order,n_fitpts,n_fitpts,&pars[start],
                      temp_knots,spn,rc);
          if (BSERROR(*rc))
            goto wrapup;


          BSfitratcv(n_fitpts, fit_pts, fit_wts, &pars[start], spn, cv->order,
                     num_knots,temp_knots,
                     cv->periodic, code, FALSE, FALSE, tanpoll, tanpolr, 
                     crvpoll,crvpolr, 0.0, 0.0, 0.0, 0.0, 1, tolerance,
                     &temp_cvs[i * crs1->num_poles + j], &avgerr,&maxerr,
                     &maxind, maxpt, rc);
          if (BSERROR(*rc))
            goto wrapup;

        }
      }
      start += n_fitpts - 1;

      for (j = 0;j < crs1->num_poles;++j)
      {
        BSreparmcv(temp_cvs[i * crs1->num_poles + j],cv_csp[i],
                   cv_csp[i + 1],temp_cvs[i * crs1->num_poles + j],rc);
        if (BSERROR(*rc))
          goto wrapup;
      }
    }
  } 

  /***** assign surface characteristices to the surface structure *****/

  rational = (crs1->rational || cv->rational) ? TRUE:FALSE;
  BSallocsf(crs1->order,cv->order,crs1->num_poles,cv->num_poles,
            rational,0,crs_surf,rc);
  if (BSERROR(*rc))
    goto wrapup;

  (*crs_surf)->u_order = crs1->order;
  (*crs_surf)->v_order = cv->order;
  (*crs_surf)->u_periodic = FALSE;
  (*crs_surf)->v_periodic = FALSE;
  (*crs_surf)->u_num_poles = crs1->num_poles;
  (*crs_surf)->v_num_poles = cv->num_poles;
  if ((*crs_surf)->u_order == (*crs_surf)->u_num_poles)
  {
    (*crs_surf)->u_non_uniform = FALSE;
  }
  else 
  {
    (*crs_surf)->u_non_uniform = TRUE;
  }
  if ((*crs_surf)->v_order == (*crs_surf)->v_num_poles)
  {
    (*crs_surf)->v_non_uniform = FALSE;
  }
  else
  {
    (*crs_surf)->v_non_uniform = TRUE;
  }

  if (cv->order > 2)
  {
    count = 0;
    for (i = 0; i < ncv_csp - 1; ++i)
    {
      for (ii = (i == 0) ? 0:1 ; 
           ii < temp_cvs[i * crs1->num_poles]->num_poles; ++ii)
      {
        for (j = 0; j < crs1->num_poles; ++j)
        {
          for (jj = 0; jj < 3; ++jj)
          {
            (*crs_surf)->poles[3 * (count * crs1->num_poles + j) + jj] = 
                temp_cvs[i * crs1->num_poles + j]->poles[3 * ii + jj];
          }
        }
        count++;
      }
    }
  }
  else 
  {
    for (i = 0; i < (*crs_surf)->v_num_poles; ++i)
    {
      for (j = 0; j < (*crs_surf)->u_num_poles; ++j)
      {
        for (jj = 0; jj < 3; ++jj)
        {
          (*crs_surf)->poles[3 * (i * (*crs_surf)->u_num_poles + j) + jj] 
                     = crs2[i]->poles[3 * j + jj];
        }
      }
    }
  }

  (*crs_surf)->u_num_knots = crs1->num_knots;
  for (i = 0; i < (*crs_surf)->u_num_knots; ++i)
  {
    (*crs_surf)->u_knots[i] = crs1->knots[i];
  }

  if (cv->order > 2)
  {
    (*crs_surf)->v_num_knots = (*crs_surf)->v_order + 
                               (*crs_surf)->v_num_poles;
    for (i = 0; i < (*crs_surf)->v_order; ++i)
    {
      (*crs_surf)->v_knots[i] = cv_csp[0];
      (*crs_surf)->v_knots[(*crs_surf)->v_num_poles + i] = 
                                            cv_csp[ncv_csp - 1];
    }

    count = cv->order;
    for (j = 0; j < ncv_csp - 1; ++j)
    {
      for (ii = cv->order; 
           ii < temp_cvs[j * crs1->num_poles]->num_knots - 1; ++ii)
      {
        (*crs_surf)->v_knots[count] = 
                     temp_cvs[j * crs1->num_poles]->knots[ii];
        count++;
      }
    }
  }
  else
  {
    (*crs_surf)->v_num_knots = cv->num_knots;
    for (i = 0; i < (*crs_surf)->v_num_knots; ++i)
    {
      (*crs_surf)->v_knots[i] = cv->knots[i];
    }
  }
  
  if (crs1->rational && cv->rational)
  {
    (*crs_surf)->rational = TRUE;
    if (cv->order > 2)
    {
      count = 0;
      for (i = 0; i < ncv_csp - 1; ++i)
      {
        for (ii = (i == 0) ? 0:1 ; 
             ii < temp_cvs[i * crs1->num_poles]->num_poles; ++ii)
        {
          for (j = 0; j < crs1->num_poles; ++j)
          {
            (*crs_surf)->weights[count * crs1->num_poles + j] = 
                temp_cvs[i * crs1->num_poles + j]->weights[ii];
          }
          count++;
        }
      }
    }
    else
    {
      for (i = 0; i < (*crs_surf)->v_num_poles; ++i)
      {
        for (j = 0; j < (*crs_surf)->u_num_poles; ++j)
        {
          (*crs_surf)->weights[i * (*crs_surf)->u_num_poles + j] = 
                       crs2[i]->weights[j];
        }
      }
    }
  }
  else if (cv->rational && !crs1->rational)
  {
    (*crs_surf)->rational = TRUE;
    for (i = 0; i < (*crs_surf)->v_num_poles; ++i)
    {
      for (j = 0; j < (*crs_surf)->u_num_poles; ++j)
      {
        (*crs_surf)->weights[i * (*crs_surf)->u_num_poles + j] = 
                       cv->weights[i];
      }
    }
  }
  else if (!cv->rational && crs1->rational)
  {
    (*crs_surf)->rational = TRUE;
    if (cv->order > 2)
    {
      for (i = 0; i < (*crs_surf)->v_num_poles; ++i)
      {
        for (j = 0; j < (*crs_surf)->u_num_poles; ++j)
        {
          (*crs_surf)->weights[i * (*crs_surf)->u_num_poles + j] = 
                               crs2[i]->weights[j];
          for (jj = 0; jj < 3; ++jj)
           (*crs_surf)->poles[3 * (i * (*crs_surf)->u_num_poles + j) + jj]
               *= (*crs_surf)->weights[i * (*crs_surf)->u_num_poles + j];
        }  
      }
    }
    else
    {
      for (i = 0; i < (*crs_surf)->v_num_poles; ++i)
      {
        for (j = 0; j < (*crs_surf)->u_num_poles; ++j)
        {
          (*crs_surf)->weights[i * (*crs_surf)->u_num_poles + j] = 
                               crs2[i]->weights[j];
        }  
      }
    }
  }
  else
  {
    (*crs_surf)->rational = FALSE;
    (*crs_surf)->weights = NULL;
  }
    
  BStst_plan(((*crs_surf)->u_num_poles * (*crs_surf)->v_num_poles),
             (*crs_surf)->poles,(*crs_surf)->weights,
             &(*crs_surf)->planar,nvec,rc);    

  (*crs_surf)->u_phy_closed = crs1->phy_closed;
  (*crs_surf)->v_phy_closed = cv->phy_closed;
  
  BSsfsetclsd(*crs_surf,rc);
  if (BSERROR(*rc))
    goto wrapup;

  (*crs_surf)->pos_orient = TRUE;
  (*crs_surf)->on_off = FALSE;
  (*crs_surf)->num_boundaries = 0;
  (*crs_surf)->bdrys = NULL;
  
  wrapup:
    if (BSOKAY(*rc) && BSERROR(rc1))
      *rc = rc1;

    if (num_par > MAXNUM)
    {
      if (spn)
        BSstackdealloc((char *) spn);
      if (cv->rational && crs1->rational && fit_wts)
        BSstackdealloc((char *) fit_wts);
      if (fit_pts)
        BSstackdealloc((char *) fit_pts);
    }

    if (temp_cvs)
    {
      for (i = total_num - 1; i >= 0; --i)
      {
        if (temp_cvs[i])
        {
          (void)BSfreecv(&rc1,temp_cvs[i]);
          if (BSERROR(rc) && BSOKAY(*rc))
            *rc = rc1;
        }
      }
      BSdealloc((char *) temp_cvs);
    }
    if (cv->rational)
    {
      if (cv->num_poles > MAXNUM)
      {
        if (trcv_wts)
          BSstackdealloc((char *) trcv_wts);
        if (pts_wts)
          BSstackdealloc((char *) pts_wts);
      }
    }

    if (cv->num_poles > MAXNUM)
    {
      if (pars)
        BSstackdealloc((char *) pars);
      if (csp_ind)
        BSstackdealloc((char *) csp_ind);
      if (ttan)
        BSstackdealloc((char *) ttan);
      if (points)
        BSstackdealloc((char *) points);
      if (par_uv)
        BSstackdealloc((char *) par_uv);
      if (nodvals)
        BSstackdealloc((char *) nodvals);
    }
    if ( cv->num_knots + (ncv_csp - 1) * 2 > MAXNUM )
    {
      if (temp_knots)
        BSstackdealloc((char *) temp_knots); 
    }
    if (crs2)
    {
      for (i = num_vals-1; i >= 0; i--)
      {
	if (crs2[i])
	{
           BSstkfreecv(&rc1,crs2[i]);
           if (BSERROR(rc1) && BSOKAY(*rc))
              *rc = rc1;
        }
      }
      BSstackdealloc((char *) crs2);
    }
    if (crs11)
    {
       BSstkfreecv(&rc1,crs11);
       if (BSERROR(rc1) && BSOKAY(*rc))
          *rc = rc1;
    }
    if (crs1)
    {
       BSfreecv(&rc1,crs1);
       if (BSERROR(rc1) && BSOKAY(*rc))
          *rc = rc1;
    }
    if (cv->num_poles - cv->order + 3 > MAXNUM && np)
      BSstackdealloc((char *) np);
    if (cv->num_poles - cv->order + 3 > MAXNUM && spn_ind)
      BSstackdealloc((char *) spn_ind);
    if (cv->num_poles - cv->order + 3 > MAXNUM && cv_csp)
      BSstackdealloc((char *) cv_csp);
    if (surf->v_num_poles - surf->v_order + 1 > MAXNUM && cspv)
      BSstackdealloc((char *) cspv);
    if (surf->u_num_poles - surf->u_order + 1 > MAXNUM && cspu)
      BSstackdealloc((char *) cspu);
    if (cv)
    {
      (void)BSfreecv(&rc1, cv);
      if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
    }
    {
    if(BSERROR(*rc))
        BSdbgrc(*rc,"BSmvcsnsfvc");
    return;
    }

} 
