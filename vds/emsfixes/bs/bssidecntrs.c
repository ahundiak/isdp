/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsidecntrs

Abstract
    Input a number of input curves, We want to know how many "cusps" 
    are there.
    The input curves are not in correct order and orientation.

Synopsis
    void BSsidecntrs(ncvs,cvtab,opt_int,prec,ncvdisc,cvdisc,rc)

    IGRint                ncvs;
    struct IGRbsp_curve   **cvtab;
    IGRboolean            opt_int;
    IGRdouble             prec;
    IGRint                *ncvdisc;
    struct IGRbsp_curve   ***cvdisc;    
    BSrc                  *rc;

Description
    Input:
      ncvs - Number of discontinuous curves.
      cvdisc(ncvs) - The array of discontinuous curves in B-spline format.
      opt_int - TRUE, this routine will consider the internal cusps as
                well. (Internal cusps means the interior cusps of input 
                curve)
                FALSE, This routine only consider the cusps at the merge
                point of 2 curves.
      prec - The angle tolerance.

    Input/Output:

    Output:
      ncvdisc - Number of discontinuous curves
      cvdisc(ncvdisc) - The array of discontnuous curves in B-spline 
                        format.      
      *rc        Possible return codes include:
                 BSNOTCOUTINUOUS - If the input contour is discontinuous

    Algorithm:

Return Values
    NA

Notes
    Caller should free memory of cvdisc as:
    if (cvdisc)
    {
      For (i=0; i < ncvdics+1; ++i)
        BSfreecv(rc,cvdisc[i]);
      BSdealloc((char *) cvdisc);
    }

Index
    lg

Keywords
    Approximation, cusps, kludge

History
    Vivian Y. Hsu   4/09/1998   : Creation date.
    Vivian Y. Hsu   5/12/1998   : Typecast out_order to be short.
	Vivian Y. Hsu   5/15/2000   : Fixed a coding error in computing v1,v2.
JJ Malosse 06 November 2000: Changed behaviour of BSgraphsort.
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
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#endif

#include <math.h>

void BSsidecntrs(

IGRint                ncvs,
struct IGRbsp_curve   **cvtab,
IGRboolean            opt_int,
IGRdouble             prec,
IGRint                *ncvdisc,
struct IGRbsp_curve   ***cvdisc,
BSrc                  *rc)

{

#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bslnkcvgrph.h"
#include "bsgraphsort.h"
#include "bsmergncvdo.h"
#include "bsdercvbs.h"
#include "bsfindmkts.h"
#include "bssplitncvs.h"
#include "bstagsort.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsplktbspcv.h"
#include "bsrev_poles.h"
#endif 

  IGRdouble  **poltab = NULL;
  IGRdouble  **knottab = NULL;
  IGRdouble  *out_poles = NULL;
  IGRdouble  *out_knots = NULL;
  IGRdouble  *dpoles = NULL;
  IGRdouble  *xnorm = NULL;
  IGRdouble  *tmul = NULL;
  IGRdouble  *pars = NULL;
  IGRdouble  *p1 = NULL,*p2 = NULL;
  IGRdouble  *d = NULL;
  IGRdouble  b1,b2;
  IGRdouble  par_tol,delta;
  IGRint     *ordtab = NULL;
  IGRint     *npoltab = NULL;
  IGRint     *rattab = NULL;
  IGRint     *conti = NULL;
  IGRint     *iad = NULL;
  IGRint     *kbid = NULL;
  IGRint     *nb1 = NULL,*nb2 = NULL;
  IGRint     *start_end1 = NULL, *start_end2 = NULL;
  IGRint     **index = NULL;
  IGRint     total_npoles;
  IGRint     total_nknots;
  IGRint     out_order,num_poles;
  IGRint     i,j,k,n,dim,id,jd;
  IGRint     num_dpoles,ik,nk,nd;
  IGRint     sz_dpoles,sz_xnorm,sz_p;
  IGRint     *subs = NULL;
  IGRboolean **irev = NULL;
  IGRchar    *big_spaced = NULL;
  IGRchar    *big_spacei = NULL;
  IGRchar    *big_space1 = NULL;
  IGRchar    *big_space2 = NULL;
  IGRchar    *big_space3 = NULL;
  IGRchar    *big_space4 = NULL;
  IGRboolean rational;
  IGRshort   ord;
  IGRlong    npol;
  IGRint     nloop = 0;
  IGRvector  v1,v2,cross_vec;
  
  *rc = BSSUCC;
  *ncvdisc = 0;
*cvdisc = NULL;
  
  /* Check if all input curves are polynomial, if it is not. exit */

  for (i = 0; i < ncvs; ++i)
  {
    if (cvtab[i]->rational)
    {
      *rc = BSINARG;
      goto wrapup;
    }
  }

  dim = 3;

  /* Allocate space for p1,p2,nb1,nb2,start_end1,start_end2 */

  sz_p = ncvs * dim;
  big_spaced = BSstackalloc((unsigned)(2 * sz_p * sizeof(IGRdouble)));
  if (!big_spaced)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  p1 = (IGRdouble *)big_spaced;
  p2 = (IGRdouble *)p1 + sz_p;

  big_spacei = BSstackalloc((unsigned)(8 * ncvs * sizeof(IGRint)));
  if (!big_spacei)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  nb1 = (IGRint *)big_spacei;
  nb2 = (IGRint *)nb1 + ncvs;
  start_end1 = (IGRint *)nb2 + ncvs;
  start_end2 = (IGRint *)start_end1 + ncvs;

/*  We set up the next address: ncvs+1   */

irev = (IGRboolean **)BSstackalloc((unsigned)(2*(ncvs+1)*sizeof(IGRboolean *)));
if (!irev)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: ncvs+1   */

*irev = (IGRboolean *)BSstackalloc((unsigned)(3*(ncvs+1)*sizeof(IGRboolean)));
if (!*irev)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: ncvs+1   */

index = (IGRint **)BSstackalloc((unsigned)(2*(ncvs+1)*sizeof(IGRint *)));
if (!index)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: ncvs+1   */

*index = (IGRint *)BSstackalloc((unsigned)(3*(ncvs+1)*sizeof(IGRint)));
if (!*index)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

  /* Get the extremity point of each curve */

  for (i = 0; i < ncvs; ++i)
  {
    for (nd = 0; nd < dim; ++nd)
    {
      p1[nd + i * dim] = cvtab[i]->poles[nd];
      p2[nd + i * dim] = cvtab[i]->poles[nd +(cvtab[i]->num_poles-1)*3];
    }
  }

  BSlnkcvgrph(dim,ncvs,p1,p2,prec,nb1,nb2,start_end1,start_end2,rc);
  if (BSERROR(*rc))
    goto wrapup;

  BSgraphsort(ncvs,nb1,nb2,start_end1,start_end2,&n,&kbid,index,irev,rc);
  if (BSERROR(*rc)) goto wrapup;

 k = kbid[0]-1;

  if (n != 1 || k != ncvs || index[0][0] != index[0][k])
  {
    /* Curves are not connected */
    *rc = BSINARG;
    goto wrapup;
  }

  /* Allocate space for ordtab,npoltab,rattab,conti,poltab,knottab */

  big_space1 = BSstackalloc((unsigned)(6 * ncvs * sizeof(IGRint)));
  if (!big_space1)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  ordtab = (IGRint *)big_space1;
  npoltab = (IGRint *)ordtab + ncvs;
  rattab = (IGRint *)npoltab + ncvs;
  conti = (IGRint *)rattab + ncvs;
  poltab = (IGRdouble **)conti + ncvs;
  knottab = (IGRdouble **)poltab + ncvs;

  
  total_npoles = 0;
  total_nknots = 0;
  for (i = 0; i < ncvs; ++i)
  {
    total_npoles += cvtab[i]->num_poles;
    total_nknots += cvtab[i]->num_knots;
  }

  big_space2 = BSstackalloc((unsigned)(total_npoles*dim+total_nknots)
                       * sizeof(IGRdouble));
  if (!big_space2)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  poltab[0] = (IGRdouble *)big_space2;
  knottab[0] = (IGRdouble *)poltab[0] + total_npoles * dim;
    
  /* Arrange curve in correct order and reverse them if neccessary */

start:
  *ncvdisc = 0;

  for (i = 0; i < ncvs; ++i)
  {
    ordtab[i] = cvtab[index[0][i]]->order;
    rattab[i] = cvtab[index[0][i]]->rational;
    npoltab[i] = cvtab[index[0][i]]->num_poles;
    conti[i] = 0;
    
    for (j = 0; j < cvtab[index[0][i]]->num_poles; ++j)
      for (k = 0; k < 3; ++k)
        poltab[i][j + k * npoltab[i]] = cvtab[index[0][i]]->poles[k + j * 3];

    for (j = 0; j < cvtab[index[0][i]]->num_knots; ++j)
      knottab[i][j] = cvtab[index[0][i]]->knots[j];

    if (irev[0][index[0][i]])
       BSrev_poles(ordtab[i],dim,npoltab[i],poltab[i],knottab[i]);

    if (i != ncvs - 1)
    {
      poltab[i+1] = (IGRdouble *)poltab[i] + npoltab[i] * dim;
      knottab[i + 1] = (IGRdouble *)knottab[i] + npoltab[i] + ordtab[i];
    }
  }


  /* Call BSmergncvdo */
 
  BSmergncvdo(ncvs,dim,ordtab,npoltab,rattab,poltab,knottab,conti,
              &out_order,&num_poles,&rational,&out_poles,&out_knots,rc);
  if (BSERROR(*rc))
    goto wrapup;

  /* Now differentiate the curve by calling BSdercvbs */
  /* Allocate space for dpoles and xnorm,tmul,iad */

  num_dpoles = num_poles - 1;
  sz_dpoles = num_dpoles * dim;
  sz_xnorm = num_dpoles;

  big_space3 = BSstackalloc((unsigned)(sz_dpoles + 4 * sz_xnorm ) * 
               sizeof(IGRdouble));
  if (!big_space3)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  dpoles = (IGRdouble *)big_space3;
  xnorm = (IGRdouble *)dpoles + sz_dpoles;
  tmul = (IGRdouble *)xnorm + sz_xnorm;
  pars = (IGRdouble *)tmul + sz_xnorm;
  d = (IGRdouble *)pars + sz_xnorm;

  big_space4 = BSstackalloc((unsigned)(2 * sz_xnorm ) * sizeof(IGRint));
  if (!big_space4)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  iad = (IGRint *)big_space4;
  subs = (IGRint *)iad + sz_xnorm;

  BSdercvbs((IGRshort)out_order,num_poles,dim,out_poles,out_knots,dpoles);

  /* Find interior knots with mutiplicity of (order - 1) */

  ord = out_order;
  npol = num_poles;
  par_tol = 1.e-12;
  BSfindmkts(rc,&ord,&npol,out_knots,&par_tol,&nk,tmul,iad);
  if (BSERROR(*rc))
    goto wrapup;

  /* If opt_int = FALSE, we don't want to conside any of interior
     cusps, so remove them from the tmul */

  if (opt_int == FALSE)
  {
    n = 0;
    delta = (IGRdouble)(1.0 / (IGRdouble)(ncvs));
    j = 1;
    i = 0;
    while (j * delta < 1.0) 
    { 
      /* After merge, the knots are between [0,1] */

      while (i < nk)
      {
        if (fabs(tmul[i] - j * delta) < par_tol)
        {
          /* keep it tmul */
          tmul[n] = tmul[i];
          iad[n] = iad[i];
          n++;
          break;
        }
        i++;
      }
      j++;
    }
    nk = n;

  }

  /* Note the knot vector for the derivative start at out_knots[1] */  

  for (i = 0; i < nk; ++i)
    iad[i] -= 1;

  /* Find left and right tangent vector at give parameters of
     derivative curve */

  for (ik = 0; ik < nk; ++ik)
  {
    i = iad[ik] - 1;
    b1 = 0.0;
    b2 = 0.0;
    for (nd = 0; nd < dim; ++nd)
    {
      v1[nd] = dpoles[i + nd * num_dpoles];
      v2[nd] = dpoles[i + 1 + nd * num_dpoles];
               
    }
    BSnorvec(rc,v1);
    if (BSERROR(*rc))
      goto wrapup;

    BSnorvec(rc,v2);
    if (BSERROR(*rc))
      goto wrapup;

    BScrossp(rc,v1,v2,cross_vec);
    if (BSERROR(*rc))
      goto wrapup;

    d[ik] = 0;
    for (nd = 0; nd < dim; ++nd)
      d[ik] += cross_vec[nd] * cross_vec[nd];

    if (d[ik] > prec * prec)
    {
      pars[*ncvdisc] = tmul[ik];      
      *ncvdisc += 1;
    }
  }
      
  /* we have to check whether the last and first curve are tangent. 
     It it is, we start from next curve. We do it recursively. */

  if (nloop < ncvs)
  {
    nloop++;
    id = num_dpoles - 1;
    jd = 0;
    for (nd = 0; nd < dim; ++nd)
    {
      v1[nd] = dpoles[id+nd*num_dpoles];
      v2[nd] = dpoles[jd+nd*num_dpoles];
    }

    BSnorvec(rc,v1);
    if (BSERROR(*rc))
      goto wrapup;

    BSnorvec(rc,v2);
    if (BSERROR(*rc))
      goto wrapup;

    BScrossp(rc,v1,v2,cross_vec);
    if (BSERROR(*rc))
      goto wrapup;

    d[nk] = 0;
    for (nd = 0; nd < dim; ++nd)
      d[nk] += cross_vec[nd] * cross_vec[nd];

    if (d[nk] < prec * prec)
    {
      /* goto start */

      k = index[0][0];
      BSMEMCPY(ncvs*sizeof(IGRint),&index[0][1],index[0]);
      index[0][ncvs - 1] = k;
      k = irev[0][0];
      BSMEMCPY(ncvs*sizeof(IGRint),&irev[0][1],irev[0]);
      irev[0][ncvs-1] = k;

      /* Free out_poles, out_knots */

      if (out_poles)
      {
        BSdealloc((char *) out_poles);
        out_poles = NULL;
      }
      if (out_knots)
      {
        BSdealloc((char *) out_knots);
        out_knots = NULL;
      }
      if (big_space3)
      {
        BSstackdealloc((char *) big_space3);
        big_space3 = NULL;
      }
      if (big_space4)
      {
        BSstackdealloc((char *) big_space4);
        big_space3 = NULL;
      }
      goto start;
    }
  }

  /* Now split the curve and return them */

  BSsplitncvs(out_order-1,num_poles,dim+rational,out_poles,out_knots,
              *ncvdisc,pars,&npoltab,&poltab,&knottab,rc);
  if (BSERROR(*rc))
    goto wrapup;

  /* Set these curves to B-spline structure */

  *cvdisc = (struct IGRbsp_curve **)BSmalloc((unsigned)((*ncvdisc+1)*
                   sizeof(struct IGRbsp_curve *)));
  if (!(*cvdisc))
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  for (i = 0; i < *ncvdisc + 1; ++i)
  {
    BSplktbspcv(out_order,dim,rational,npoltab[i],poltab[i],
                knottab[i],1.0e-5,&(*cvdisc)[i],rc);
    if (BSERROR(*rc))
      goto wrapup;
  }

wrapup:

  if (index)
  {
    if (*index) BSstackdealloc((char *) *index);
    BSstackdealloc((char *) index);
    index = NULL;
  }
  if (irev)
  {
    if (*irev) BSstackdealloc((char *) *irev);
    BSstackdealloc((char *) irev);
    irev = NULL;
  }

if (kbid) BSdealloc((char *) kbid);

  if (out_poles)
    BSdealloc((char *) out_poles);
  if (out_knots)
    BSdealloc((char *) out_knots);
  if (big_spaced)
    BSstackdealloc((char *) big_spaced);
  if (big_spacei)
    BSstackdealloc((char *) big_spacei);
  if (big_space1)
    BSstackdealloc((char *) big_space1);
  if (big_space2)
    BSstackdealloc((char *) big_space2);
  if (big_space3)
    BSstackdealloc((char *) big_space3);
  if (big_space4)
    BSstackdealloc((char *) big_space4);
  if (npoltab)
    BSdealloc((char *) npoltab);
  if (poltab)
  {
    if (poltab[0])
      BSdealloc((char *) poltab[0]);
    BSdealloc((char *) poltab);
  }

  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSsidecntrs");

    return;
}
