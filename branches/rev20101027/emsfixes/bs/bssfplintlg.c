/*

Copyright 1995, Intergraph Corporation. All rights reserved.

Name
    BSsfplintlg

Abstract
    This routine finds the intersections between a surface and a plane.
    It returns B-spline interseciton curves and parametric curves in 
    Legender basis.

Synopsis
    void BSsfplintlg(point,normal,sf,cvscode,order,tol,
                    num_cvs,cmpcvs,bsp_cvs,rc)

    IGRpoint      point;
    IGRvector     normal;
    struct IGRbsp_surface  *sf;
    IGRshort      cvscode;
    IGRint        order;
    IGRdouble     tol;
    IGRint        *num_cvs;
    struct BScmplgd_cv **cmpcvs;
    struct IGRbsp_curve   ***bsp_cvs;
    BSrc          *rc;

Description
    Input :
      point - point on the plane
      normal - normal vector of the plane
      sf - the B-spline surface
      cvscode - (0) none
                (1) xyz_cvs (model space)
                (2) uv_cvs (uv space)
                (3) both xyz_cvs and uv_cvs
      order - the model space curve order
      tol - the tolerance
      
    Output:
      num_cvs - the number of intersection curves

      cmpcvs1 - the structure (BScmplgd_cv) contains all information of 
                the composite intersection curves in Legendre basis
        numgrps - the number group of intersection curves
        ncvs[numgrps] - the number of curves in each group
        ndegtab[numgrps][ncvs[]] - the degree of the parametric curves
                        in Legendre basis
        rattab[numgrps][ncvs[]] - 0,nonrational. 1, rational in u.
                        2, rational in v. 3 rational in u,v.
        cvlgd[numgrps][ncvs[]][(ndegtab[]+1)*dim] - the coefficients of
                        the parametric curves in Legendre basis. dim = 2
                        if rattab[] = 0, dim = 3 if rattab[] = 1 or 2.
                        dim = 4 if rattab[] = 3.
      bsp_cvs[0:num_cvs-1] - the intersection B-spline curves              
Return Values
    If successful then a message BSSUCC, is returned, else an appropriate 
    error message is returned.

Notes
    

Index
    em

Keywords

History
    Vivian W.Ye          05/07/1991  : Creation Data.
    Vivian W.Ye          07/22/1991  : Fixed bugs when computing
                                       start and end parameters
                                       for rational Legendre curve.
    Vivian W.Ye          07/31/1991  : Replace BSmergncvs by BSmergncvdo,
                                       so it merges curves with different
                                       order.
    Vivian W.Ye          08/06/91    : Remove redundent solution on the   
                                       boundary of a closed surface.
    Vivian W.Ye          08/08/91    : Call BSchkcvdegn to test 
                                       degeneracity of the output curve.
    Vivian W.Ye          08/13/91    : If there are two identical 
                                       intersection curves, return
                                       rc = BSOUTOFDESN.
    Vivian W.Ye          08/26/91    : Handle case of ndeg2 == 0.
    Vivian W.Ye          08/28/91    : Remove degenerate curve if it is
                                       on the end of a non-degenerate 
                                       curve.
    Vivian W.Ye          08/30/91    : Fixed an error when computing
                                       d1 and d2.
    Vivian W.Ye          09/05/91    : Modifed allocation for lgd_cvs
                                       and mod_cvs.
    Vivian W.Ye          09/18/91    : Call BSrev_lgd to reverse Legendre
                                       series.
    Vivian W.Ye          01/15/92    : Allocate space for cv_ind instead
                                       of reusing pch_ind.
    Vivian W.Ye          04/10/92    : Move remove_num = 0 up and update 
                                       it if we found interior iso point.
    Vivian W.Ye          07/22/92    : Modified structure of poly_cvs and
                                       using uv_start and uv_end returned
                                       from BSintplcar for linking curves.
    Vivian W.Ye          08/04/92    : Modified end poles of the output
                                       intersection curves to insure they
                                       are on the surface.
    Vivian W.Ye          08/13/92    : Return intersection curves if 
                                       linking process failed.
    Vivian W.Ye          08/21/92    : Remove identical curves returned
                                       from the solver.
    Vivian W.Ye          08/27/92    : Introduce cvmax1 = 
                                       npchsol*(ndegu+ndegv)^2
                                       and cvmax = MIN(cvmax1,100),
                                       use cvmax1 to allocate big_space1.
                                       and use cvmax to allocate space
                                       for lgd_cvs and mod_cvs.
    Vivian W.Ye          01/05/93    : Set up uv_start and uv_end for
                                       degenerate point.  
    Vivian W.Ye          01/12/93    : Set rc2 = rc if rc is BSOUTOFDESN
                                       returned from BSintplcar, then go
                                       on for rest of patches. At the end
                                       of this routine, returns results
                                       with rc = BSOUTOFDESN.
    Vivian W.Ye          02/03/93    : After removing redundent curve, 
                                       check if number of solution is 
                                       zero. If so,do not allocate space 
                                       and set num_cvs = 0,goto wrapup.
    Vivian W.Ye          02/25/93    : Initialize planar,closed to FALSE.
    Vivian W.Ye          04/28/93    : Initialize num_cvs = 0;
    Vivian W.Ye          06/07/93    : Compute loc_tol for linking routine
                                       BSlnkcvgrph.                
    Vivian W.Ye          10/28/93    : Adjust the start and end poles of 
                                       each curve to make sure they are 
                                       on the boundary of each Bezier 
                                       patch.

    Vivian W.Ye          12/10/93    : Link intersection curves as far as
                                       possible even there are selfinter-
                                       section points or curves are not
                                       starting from the boundary.
    Vivian W.Ye          12/27/93    : Replace global tolerace zero_tol
                                       by local defined zero_tol = 1e-14
                                       * MAX(du,dv) for evaluation of 
                                       points on the surface.
    Vivian W.Ye          01/27/1994  : Changed argument list of calls to  
                                       BSlnkcvgrph and BSgraphsort.
    Vivian W.Ye          03/01/1994  : Replace dist_sqtol by tol*tol.
                                       Added tol to input argument list
                                       of BSchkcvdegn and BSoutputcvs.
    Vivian W.Ye          03/15/1994  : Continue process even if there is
                                       an error found in one of patches.
    Vivian W.Ye          03/16/1994  : Fixed a bug when remove redundent
                                       curve returned from BSintplcar.
    Vivian Y.Hsu         01/18/1995  : Replaced structures BSwrkcv by
                                       BSlgd_curve and BScmplgd_cv.
    Vivian Y.Hsu         12/05/1995  : Reset rco = BSSUCC when we are try
                                       to run it again with new tolerance.
*/

#include <math.h>
#include "bs.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bsstk.h"
#include "bsplpchlgd.h"
#define BSVOID
#define KEEP 100000
#define REMOVE 20000
#define BSMAXDEG 127

/* 
    This routine checks if the parameters are in the range of 
    surface u,v knots within zero tolerance. Then evaluate them
    to get points on the surface.

    Input :
      sf - B-spline surface
      num - the number of parameters to be evaluated
      uvpars[0:num-1,0:1] - u and v parameters
    
    Output :
      points[0:num-1,0:2] - points on the surface corresponding to 
                            the parameters.
*/

static void sfevalBSsfplintlg(
struct IGRbsp_surface *sf,
struct IGRbsp_surface *bez,
IGRint                num,
BSpair                *uvpars,
IGRdouble             *points,
BSrc                  *rc)
{
  #include "bssfptseval.h"
  IGRdouble           zero_tol = 1.0e-14;
  IGRint              uorder,vorder;
  IGRint              sf_unump,sf_vnump;
  IGRint              bez_unump,bez_vnump;
  IGRint              i;
  IGRdouble           max,du,dv;
     

  uorder = sf->u_order;
  vorder = sf->v_order;
  sf_unump = sf->u_num_poles;
  sf_vnump = sf->v_num_poles;
  du = sf->u_knots[sf_unump] - sf->u_knots[uorder-1];
  dv = sf->v_knots[sf_vnump] - sf->v_knots[vorder-1];
  max = MAX(du,dv);
  zero_tol *= max;
  bez_unump = bez->u_num_poles;
  bez_vnump = bez->v_num_poles;

  /* If uvpars are on the boundary of a B-spline surface Within
     zero_tol, set to the boundary knot value. Because there are
     numerical noise coming from the normalization */

  for (i = 0; i < num; ++i)
  {
    if (ABS(uvpars[i][0] - bez->u_knots[uorder-1]) < zero_tol)
      uvpars[i][0] = bez->u_knots[uorder-1];
    else if (ABS(uvpars[i][0] - bez->u_knots[bez_unump]) < zero_tol)
      uvpars[i][0] = bez->u_knots[bez_unump];

    if(ABS(uvpars[i][1] - bez->v_knots[vorder-1]) < zero_tol)
      uvpars[i][1] = bez->v_knots[vorder-1];
    else if (ABS(uvpars[i][1] - bez->v_knots[bez_vnump]) < zero_tol )
      uvpars[i][1] = bez->v_knots[bez_vnump];
  }

  BSsfptseval(bez,num,(IGRdouble *)uvpars,points,rc);

  return;
}

/* 
   This routine finds the arc length of an iso curve of a B-spline
   surface.

   Input :
     cv - B-spline curve
   
   Ouput :
     len - the arc length of the curve
*/

static void arclenBSsfplintlg(
struct IGRbsp_curve       *cv,
IGRdouble                 *len,
BSrc                      *rc)
{
#include "bsextrtlgd.h"
#include "bscveval.h"
#include "bsintegval.h"

  IGRdouble     *roottab;
  IGRdouble     lentab[20];
  IGRdouble     u,bidon;
  IGRpoint      eval[4];
  IGRint        ndegl,i;

  *rc = BSSUCC;

  ndegl = 10;
  BSextrtlgd(ndegl,&roottab,rc);
  if (BSERROR(*rc))
    goto wrapup;

  for (i = 0; i < 10; ++i)
  {
    u = (roottab[i] + 1) / 2;
    BScveval(cv,u,1,eval,rc);
    bidon = eval[1][0] * eval[1][0] + eval[1][1] * eval[1][1] + 
                eval[1][2] * eval[1][2];
    lentab[i] = sqrt(bidon);
  }

  BSintegval(10,lentab,len,rc);

  wrapup:
  return;
}
  
void BSsfplintlg(
IGRpoint      point,
IGRvector     normal,
struct IGRbsp_surface  *sf,
IGRshort      cvscode,
IGRint        order,
IGRdouble     tol,
IGRint        *num_cvs,
struct BScmplgd_cv    **cmpcvs,
struct IGRbsp_curve   ***bsp_cvs,
BSrc          *rc)
{
#include "bsdbgrc.h"
#include "bstrans2.h"
#include "bsunwght_p.h"
#include "bsptsoldtnw.h"
#include "bsspntbzpch.h"
#include "bsintplcar.h"
#include "bslnkcvgrph.h"
#include "bsgraphsort.h"
#include "bsmergncvdo.h"
#include "bscvtstclsd.h"
#include "bsrev_poles.h"
#include "bsrmdbbdry.h"
#include "bschkcvdegn.h"
#include "bsidentcvlg.h"
#include "bsrev_lgd.h"
#include "bsoutputcvs.h"
#include "bschkconti.h"
#include "bsdistwpwp.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bsalllgdcvs.h"
#include "bsfrelgdcvs.h"
#include "bsallbspcvs.h"
#include "bsfrebspcvs.h"
#include "bscpylgdcvs.h"
#include "bscpybspcvs.h"

  struct BSlgd_curve  *poly_cvs = NULL;
  struct BSlgd_curve  *lgd_cvs = NULL;
  struct BSlgd_curve  *lgd_cvs1 = NULL;
  struct BSbsp_curve  *bs_cvs = NULL;
  struct BSbsp_curve  *mod_cvs = NULL;
  struct BSbsp_curve  *mod_cvs1 = NULL;
  struct IGRbsp_surface  *bez = NULL;
  IGRdouble         tmat[3][3];
  IGRdouble         *tran_poles = NULL;
  IGRdouble         *polybez = NULL;
  IGRdouble         *ptr1,*ptr2,*ptr3,*ptr4 = NULL,*ptr_sf,*wts_ptr;
  IGRdouble         *uvlgd = NULL,*uvlgd2 = NULL;
  IGRdouble         a1,a2,b1,b2;
  IGRdouble         **poles = NULL,**knots = NULL;
  IGRdouble         *outpoles = NULL,*outknots = NULL;
  BSpair            *u_knots = NULL,*v_knots = NULL;
  IGRdouble         d1,d2;
  IGRpoint          *degn_pt = NULL;
  IGRint            num_degn;
  IGRint            *p_ind = NULL,*pch_ind = NULL,*cv_ind = NULL;
  IGRint            npchsol,ind1,ind2,i,j;
  IGRint            ndegu,ndegv;
  IGRint            cvmax,cvmax1,nsol,indu,indv;
  IGRint            k,l,m,n,num_poles,nu,nv;
  IGRint            dim,dim2,ndeg2,rat2,ndeg22,rat22;
  IGRint            *ncvs = NULL,*ind = NULL;
  IGRint            *num_pol = NULL,*rat = NULL;
  IGRint            *ord = NULL;
  IGRint            ii,jj,numcv,order1;
  IGRint            *conti = NULL;
  IGRshort          *degn = NULL;
  IGRboolean        *rev = NULL;
  IGRboolean        found,pos = TRUE,overlap,status;
  IGRboolean        planar = FALSE,closed = FALSE,rational;
  IGRchar           *big_space1 = NULL;
  IGRchar           *big_space2 = NULL;
  IGRint            *isocv = NULL;
  IGRdouble         *uv = NULL;
  IGRint            count,remove_num;
  IGRboolean        iden;
  IGRint            first = 0;
  IGRdouble         temp_uvlgd[4];
  BSrc              rc1 = BSSUCC;
  BSrc              rc2 = BSSUCC;
  BSpair            *uv_start = NULL,*uv_end = NULL;
  IGRint            *nb1 = NULL,*nb2 = NULL;
  IGRint            *start_end1 = NULL,*start_end2 = NULL;
  IGRint            start;
  IGRdouble         pt1[3],pt2[3];
  IGRdouble         **opoles = NULL,**oknots = NULL;
  IGRint            *orat = NULL,*npoles = NULL,*oord = NULL;
  IGRdouble         par,du,dv,d,loc_tol;
  IGRint            max_ord,max_num_poles;
  IGRshort          opt;
  struct IGRbsp_curve  *cv = NULL;
  IGRboolean        start_bound, end_bound;
  IGRboolean        rcw;
  BSrc              rco;
  IGRint            coefmax; 

  start:

  *rc = BSSUCC;
  rc1 = BSSUCC;
  rc2 = BSSUCC;
  *num_cvs = 0;
  rcw = FALSE; /* rc of OUTOFDESN,WARN */
  rco = BSSUCC;

  ndegu = sf->u_order - 1;
  ndegv = sf->v_order - 1;
  k = sf->u_order;
  l = sf->v_order;
  n = sf->u_num_poles;
  m = sf->v_num_poles;
  num_poles = n * m;
  nu = n - k + 1;
  nv = m - l + 1;

  /* find the transformation matrix tmat */

  BStrans2(normal,TRUE,tmat,rc);
  if (BSERROR(*rc))
    goto wrapup;

  /* allocate space for transformed poles tran_poles */

  tran_poles = (IGRdouble *)BSstackalloc((unsigned)
                     (num_poles * 3 * sizeof (IGRdouble)));
  if (!tran_poles)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  if (sf->rational)
  {
    status = BSunwght_p(rc,sf->poles,sf->weights,(IGRlong *)&num_poles,
                        tran_poles);
    if (BSERROR(*rc))
      goto wrapup;
  }
  else
  {
    BSMEMCPY(num_poles * 3 * sizeof(IGRdouble),(IGRchar *)sf->poles,
             (IGRchar *)tran_poles);
  }


  BSptsoldtnw(point,tmat,1.0,num_poles,FALSE,(IGRpoint *)tran_poles,NULL,
              (IGRpoint *)tran_poles,rc);
  if (BSERROR(*rc))
    goto wrapup;


  /* allocate space for p_ind */

  p_ind = (IGRint *)BSstackalloc((unsigned)(nu * nv * sizeof(IGRint)));
  if (!p_ind)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  /* search patchs to find ones with solutions */

  npchsol = 0;
  for (i = 0; i < nv; ++i)
  {
    if (sf->v_knots[l - 1 + i] != sf->v_knots[l - 1 + i + 1])
    {
      /* loop over non-degenerate patch */

      for (j = 0; j < nu; ++j)
      {
        if (sf->u_knots[k - 1 + j] != sf->u_knots[k - 1 + j + 1])
        {
          /* loop over non-degenerate patch */

          ind1 = 3 * (i * n + j);
          if (tran_poles[ind1 + 2] > tol)
            pos = TRUE;
          else if (tran_poles[ind1 + 2] < -tol)
            pos = FALSE;
     
          found = FALSE;
          for (ii = i; ii < i + l; ++ii)
          {
            for (jj = j; jj < j + k; ++jj)
            {
              ind2 = 3 * (ii * n + jj);
              if ((tran_poles[ind2 + 2] < tol && pos) ||
                  (tran_poles[ind2 + 2] > -tol && !pos) )
              {
                p_ind[npchsol] = i * nu + j;
                npchsol++;
                found = TRUE;
                break;
              }
            }
            if (found)
              break;
          }
        }
      }
    }
  }

  if (npchsol == 0)
  {
    *num_cvs = 0;
    goto wrapup;
  }

  /* allocate space for pch_ind */

  pch_ind = (IGRint *)BSstackalloc((unsigned)(npchsol * sizeof(IGRint)));
  if (!pch_ind)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  BSMEMCPY(npchsol * sizeof(IGRint),(IGRchar *)p_ind,(IGRchar *)pch_ind);
  
  /* deallocate space for p_ind */

  if (p_ind)
  {
    BSstackdealloc((char *) p_ind);
    p_ind = NULL;
  }

  /* allocate space for overlap */

  dim = 3;
  polybez = (IGRdouble *)BSstackalloc((unsigned)
                      (dim + sf->rational) * k * l * sizeof(IGRdouble));
  if (!polybez)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  BSstkallosf(rc,bez,sf->u_order,sf->v_order,sf->rational,
              (sf->u_order + sf->u_order), (sf->v_order + sf->v_order),0);
  if (BSERROR(*rc))
    goto wrapup;

  /* allocate big bag for output intersection curves */

  cvmax1 = npchsol * (ndegu + ndegv) * (ndegu + ndegv); 
  cvmax = MIN(cvmax1,100);
  coefmax = 4 * (BSMAXDEG + 1);

  if (npchsol > 1)
  {
    BSalllgdcvs(cvmax,coefmax,&lgd_cvs,rc);
    if (BSERROR(*rc))
      goto wrapup;

    BSallbspcvs(cvmax,100,116,&mod_cvs,rc);
    if (BSERROR(*rc))
      goto wrapup;

  }

  big_space1 = BSstackalloc((unsigned)
                           (2 * cvmax1 * sizeof(BSpair)));
  if (!big_space1)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
 
  u_knots = (BSpair *)big_space1;
  v_knots = (BSpair *)&big_space1[cvmax1 * sizeof(BSpair)];

  cv_ind = (IGRint *)BSstackalloc((unsigned)(cvmax1 * sizeof(IGRdouble)));
  if (!cv_ind)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  overlap = FALSE;
  nsol = 0;
  for (i = 0; i < npchsol; ++i)
  {
    indv = pch_ind[i] / nu;
    indu = pch_ind[i] - indv * nu;
    indv += l - 1;
    indu += k - 1;

    status = BSspntbzpch(rc,&indu,&indv,sf,bez,&planar,&closed);
    if (!status)
      goto wrapup;

    /* rearrange the poles to call BSintplcar */

    ptr1 = polybez;
    ptr2 = &polybez[(ndegu + 1) * (ndegv + 1)];
    ptr3 = &polybez[2 * (ndegu + 1) * (ndegv + 1)];
    if (sf->rational)
      ptr4 = &polybez[3 * (ndegu + 1) * (ndegv + 1)];
    ptr_sf = bez->poles;
    wts_ptr = bez->weights;
    for (ii = 0; ii <= ndegv; ++ii)
    {
      for (jj = 0; jj <= ndegu; ++jj)
      {
        *ptr1++ = *ptr_sf++;
        *ptr2++ = *ptr_sf++;
        *ptr3++ = *ptr_sf++;
      }
      if (bez->rational)
      {
        for (jj = 0; jj <= ndegu; ++jj)
          *ptr4++ = *wts_ptr++;
      }
    }

    if (cvscode == 3)
    {  
      /* output uv and model space curves */

      BSintplcar(point,normal,ndegu,ndegv,sf->rational,polybez,order,
                 tol,&poly_cvs,&bs_cvs,rc);
      if (BSERROR(*rc))
      {
        if (rco == BSSUCC || rco == BSOUTOFDESN ||
            rco == BSCOINCIDENT)
          rco = *rc;
        *rc = BSSUCC;
        goto label;
      }
    }
    else
    {
      *rc = BSOUTOFDESN;
      goto wrapup;
    }
  
    if (*rc == BSCOINCIDENT)
    {
      *rc = BSSUCC;
      overlap = TRUE;
    }
    else
    {
      if (poly_cvs->num_cvs != 0)
      {
        remove_num = 0;
        for (jj = 0; jj < poly_cvs->num_cvs; ++jj)
          cv_ind[jj] = jj;

        for (jj = 0; jj < poly_cvs->num_cvs; ++jj)
        {    
          ndeg2 = poly_cvs->ndegtab[jj];
          rat2 = poly_cvs->rattab[jj];
          uvlgd = poly_cvs->cvlgd[jj];
          for (j = jj + 1; j < poly_cvs->num_cvs; ++j)
          {
            ndeg22 = poly_cvs->ndegtab[j];
            rat22 = poly_cvs->rattab[j];
            uvlgd2 = poly_cvs->cvlgd[j];

            BSidentcvlg(ndeg2,rat2,uvlgd,ndeg22,rat22,uvlgd2,&iden);
            if (iden)
            {
              if (cv_ind[j] != REMOVE)
              {
                cv_ind[j] = REMOVE;  
                remove_num++;
              }
            }
          }
        }

        for (j = 0; j < poly_cvs->num_cvs; ++j)
        {
          if (cv_ind[j] != REMOVE)
          {
            u_knots[nsol][0] = sf->u_knots[indu];
            u_knots[nsol][1] = sf->u_knots[indu + 1];
            v_knots[nsol][0] = sf->v_knots[indv];
            v_knots[nsol][1] = sf->v_knots[indv + 1];
            nsol++;
          }
        }

        if (npchsol > 1)
        {
          if (remove_num > 0)
          {
            ii = 0;
            n = poly_cvs->num_cvs - remove_num;
            for (j = 0; j < poly_cvs->num_cvs; ++j)
            {
              if (cv_ind[j] != REMOVE)
              {
                cv_ind[ii] = j;
                ii++;
              }
            }
          }
          else
            n = poly_cvs->num_cvs;
        
          if (n > 0)
          {
            BScpylgdcvs(n,cv_ind,poly_cvs,&lgd_cvs,rc);
            if (BSERROR(*rc))
              goto wrapup;
            BScpybspcvs(n,cv_ind,bs_cvs,&mod_cvs,rc);
            if (BSERROR(*rc))
              goto wrapup;

          }
        }
        else
        {
          lgd_cvs = poly_cvs;
          poly_cvs = NULL;
          mod_cvs = bs_cvs;
          bs_cvs = NULL;
        }

      }
    }


    label:
    if (poly_cvs)
    {
      BSfrelgdcvs(poly_cvs,rc); 
      if (BSERROR(*rc))
        goto wrapup;
      poly_cvs = NULL;
    }
    if (bs_cvs)
    {
      BSfrebspcvs(bs_cvs,rc);
      if (BSERROR(*rc))
        goto wrapup;
      bs_cvs = NULL;
    }
  }

  if (nsol == 0 && overlap)
  {
    *rc = BSCOINCIDENT;
    goto wrapup;
  }
  else if (nsol == 0 && !overlap)
  {
    *num_cvs = 0;
    goto wrapup;
  }

  /* find and remove redudent iso curves */
  
  isocv = (IGRint *)BSstackalloc((unsigned) 
                             (nsol * 3 * sizeof(IGRint)));
  if (!isocv)
  {
    *rc =  BSNOSTKMEMORY;
    goto wrapup;
  }
  uv = (IGRdouble *)BSstackalloc((unsigned)
                       (3 * nsol * sizeof(IGRdouble)));
  if (!uv)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
    
  count = 0;  
  remove_num = 0;
  for (i = 0; i < nsol; ++i)
  {
    ndeg2 = lgd_cvs->ndegtab[i];
    rat2 = lgd_cvs->rattab[i];
    uvlgd= lgd_cvs->cvlgd[i];

    if (ndeg2 == 0)
    {
      temp_uvlgd[0] = uvlgd[0];
      temp_uvlgd[1] = uvlgd[1];
    }
    if (ndeg2 == 1)
    {
      temp_uvlgd[0] = uvlgd[0];
      temp_uvlgd[1] = uvlgd[1];
      temp_uvlgd[2] = uvlgd[2];
      temp_uvlgd[3] = uvlgd[3];
    }
  
    /* normalize the uvlgd between knots line */

    a1 = (u_knots[i][0] + u_knots[i][1]) / 2.0;
    b1 = (u_knots[i][1] - u_knots[i][0]) / 2.0;
    a2 = (v_knots[i][0] + v_knots[i][1]) / 2.0;
    b2 = (v_knots[i][1] - v_knots[i][0]) / 2.0;

    for (j = 0; j <= ndeg2; ++j)
    {
      uvlgd[j] *= b1;
      uvlgd[ndeg2 + 1 + j] *= b2;
    }

    if (rat2 == 0)
    {
      uvlgd[0] += a1;
      uvlgd[ndeg2 + 1] += a2;
    }
    else if (rat2 == 1)
    {
      for (j = 0; j <= ndeg2; ++j)
        uvlgd[j] += a1 * uvlgd[2 * (ndeg2 + 1) + j];
      uvlgd[ndeg2 + 1] += a2;
    }
    else if (rat2 == 2)
    {
      uvlgd[0] += a1;           
      for (j = 0; j <= ndeg2; ++j)
        uvlgd[ndeg2 + 1 + j] += a2 * uvlgd[2 * (ndeg2 + 1) + j];
    }
    else if (rat2 == 3)
    {
      for (j = 0; j <= ndeg2; ++j)
        uvlgd[j] += a1 * uvlgd[2 * (ndeg2 + 1) + j];
      for (j = 0; j <= ndeg2; ++j)
        uvlgd[ndeg2 + 1 + j] += a2 * uvlgd[3 * (ndeg2 + 1) + j];
    }

    /* temporary these case are not handled */

    if (ndeg2 == 0)
    {
      if (temp_uvlgd[0] == -1)
        uvlgd[0] = u_knots[i][0];
      else if (temp_uvlgd[0] == 1)
        uvlgd[0] = u_knots[i][1];

      if (temp_uvlgd[1] == -1)
        uvlgd[1] = v_knots[i][0];
      else if (temp_uvlgd[1] == 1)
        uvlgd[1] = v_knots[i][1];
      
      if (uvlgd[0] == sf->u_knots[0] || 
          uvlgd[0] == sf->u_knots[sf->u_num_poles] ||
          uvlgd[1] == sf->v_knots[0] || 
          uvlgd[1] == sf->v_knots[sf->v_num_poles])
      {
        isocv[3 * count] = i;
        isocv[3 * count + 1] = 2;  /* iso point */ 
        isocv[3 * count + 2] = KEEP;
        uv[3 * count] = uvlgd[0];
        uv[3 * count + 1] = uvlgd[1];
        count++;
      }
      else
      {
        isocv[3 * count] = i;
        isocv[3 * count + 1] = 2;  /* iso point */ 
        isocv[3 * count + 2] = REMOVE;
        uv[3 * count] = uvlgd[0];
        uv[3 * count + 1] = uvlgd[1];
        count++;
        remove_num++;
      }
    }
    else if (ndeg2 == 1)
    {
      if (temp_uvlgd[0] == -1 && temp_uvlgd[1] == 0)
        uvlgd[0] = u_knots[i][0];
      else if (temp_uvlgd[0] == 1 && temp_uvlgd[1] == 0)
        uvlgd[0] = u_knots[i][1];

      if (temp_uvlgd[2] == -1 && temp_uvlgd[3] == 0)
        uvlgd[2] = v_knots[i][0];
      else if (temp_uvlgd[2] == 1 && temp_uvlgd[3] == 0)
        uvlgd[2] = v_knots[i][1];

      if (uvlgd[1] == 0 && (uvlgd[0] == u_knots[i][0] ||
          uvlgd[0] == u_knots[i][1]) )
      {
        isocv[3 * count] = i;
        isocv[3 * count + 1] = 0;  /* u knots line */ 
        isocv[3 * count + 2] = NULL;
        uv[3 * count] = uvlgd[0];
        uv[3 * count + 1] = uvlgd[2];
        uv[3 * count + 2] = uvlgd[3];
        count++;
      }
      else if (uvlgd[3] == 0 && (uvlgd[2] == v_knots[i][0] ||
               uvlgd[2] == v_knots[i][1]) )
      {
        /* reject for isolated curve */

        isocv[3 * count] = i;
        isocv[3 * count + 1] = 1;  /* v knots line */
        isocv[3 * count + 2] = NULL;
        uv[3 * count] = uvlgd[2];
        uv[3 * count + 1] = uvlgd[0];
        uv[3 * count + 2] = uvlgd[1];
        count++;          

      }
    }
  }


  /* find  redudent iso curves */


  for (i = 0; i < count; ++i)
  {
    if (isocv[3 * i + 2] == NULL)
    {
      isocv[3 * i + 2] = KEEP;
      for (j = i + 1; j < count; ++j)
      {
        if (isocv[3 * j + 2] == NULL && 
            isocv[3 * j + 1] == isocv[3 * i + 1] &&
            uv[3 * j] == uv[3 * i] && uv[3 * j + 1] == uv[3 * i + 1] &&
            uv[3 * j + 2] == uv[3 * i + 2])
        {
          isocv[3 * j + 2] = REMOVE;
          remove_num++;
        }
      }
    }
  }

  /* remove redudent iso curves */

  if (remove_num > 0)
  {
    n = nsol - remove_num;
    ii = 0;
    for (i = 0; i < nsol; ++i)
    {
      cv_ind[ii] = i;
      ii++;
      for (j = 0; j < count; ++j)
      {
        if ( i == isocv[3 * j] && isocv[3 * j + 2] == REMOVE)
        {
          ii--;
          break;
        }
      }
    }

    /* remove corresponding u_knots and v_knots */

    for (i = 0; i < n; ++i)
    {
      u_knots[i][0] = u_knots[cv_ind[i]][0];
      u_knots[i][1] = u_knots[cv_ind[i]][1];
      v_knots[i][0] = v_knots[cv_ind[i]][0];
      v_knots[i][1] = v_knots[cv_ind[i]][1];
    }

    if (n > 0)
    {
      BSalllgdcvs(n,coefmax,&lgd_cvs1,rc);
      if (BSERROR(*rc))
        goto wrapup;
      BSallbspcvs(n,100,116,&mod_cvs1,rc);
      if (BSERROR(*rc))
        goto wrapup;

      BScpylgdcvs(n,cv_ind,lgd_cvs,&lgd_cvs1,rc);
      if (BSERROR(*rc))
        goto wrapup;
      BScpybspcvs(n,cv_ind,mod_cvs,&mod_cvs1,rc);
      if (BSERROR(*rc))
        goto wrapup;

      if (mod_cvs)
      {
        BSfrebspcvs(mod_cvs,&rc1);
        if (BSERROR(rc1) && BSOKAY(*rc))
          *rc = rc1;
        mod_cvs = mod_cvs1;
        mod_cvs1 = NULL;
      }
      if (lgd_cvs)
      {
        BSfrelgdcvs(lgd_cvs,&rc1);
        if (BSERROR(rc1) && BSOKAY(*rc))
          *rc = rc1;
        lgd_cvs = lgd_cvs1;
        lgd_cvs1 = NULL;
      }
    }
  }

  nsol -= remove_num;
  if (nsol == 0)
  {
    *num_cvs = 0;
    goto wrapup;
  }
  
  /* allocate space for ord,num_pol,poles,knots */

  ord = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!ord)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  num_pol = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!num_pol)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  rat = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!rat)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  poles = (IGRdouble **)BSstackalloc((unsigned)
                             (nsol * sizeof(IGRdouble *)));
  if (!poles)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  knots = (IGRdouble **)BSstackalloc((unsigned)
                             (nsol * sizeof(IGRdouble *)));
  if (!knots)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  degn = (IGRshort *)BSstackalloc((unsigned)
                          (nsol * sizeof(IGRshort)));
  if (!degn)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  degn_pt = (IGRpoint *)BSstackalloc((unsigned)
                          (nsol * sizeof(IGRpoint)));
  if (!degn_pt)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  /* allocate space for ncvs,ind and rev */

  ncvs = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!ncvs)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  ind = (IGRint *)BSstackalloc((unsigned)(2 * nsol * sizeof(IGRint)));
  if (!ind)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  rev = (IGRboolean *)BSstackalloc((unsigned)
                              (2 * nsol * sizeof(IGRboolean)));
  if (!rev)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  /* find degenerated intersection curve and compute the
     degenerate point */

  num_degn = 0;
  for (i = 0; i < nsol; ++i)
  {
    ord[i] = mod_cvs->ndegtab[i] + 1;
    dim = mod_cvs->dimtab[i];
    num_pol[i] = mod_cvs->npoltab[i];
    rat[i] = mod_cvs->rattab[i];
    poles[i] = mod_cvs->poles[i];
    knots[i] = mod_cvs->knots[i];

    BSchkcvdegn(dim,rat[i],num_pol[i],poles[i],tol,&degn[i],rc);
    if (BSERROR(*rc))
      goto wrapup;

    if (degn[i])
    {
      if (rat[i])
      {      
        for (j = 0; j < dim; ++j)
          degn_pt[num_degn][j] = poles[i][j * num_pol[i]] /
                                 poles[i][dim * num_pol[i]];
      }
      else
      {
        for (j = 0; j < dim; ++j)
          degn_pt[num_degn][j] = poles[i][j * num_pol[i]];
      }
      num_degn++;
    }
  }

  /* remove degenerate point if it is a extremity point of 
     anther intersection */
     
  num_degn = 0;
  remove_num = 0;
  for (i = 0; i < nsol; ++i)
  {
    if (degn[i])
    {
      for (j = 0; j < nsol; ++j)
      {
        if (!degn[j])
        {
          if (!rat[j])
          {
            d1 = 0;
            d2 = 0;
            for (ii = 0; ii < dim; ++ii)
            {
              d1 += (poles[j][ii * num_pol[j]] - degn_pt[num_degn][ii]) * 
                    (poles[j][ii * num_pol[j]] - degn_pt[num_degn][ii]);
              d2 += (poles[j][ii * num_pol[j] + num_pol[j]-1] - 
                     degn_pt[num_degn][ii]) * 
                    (poles[j][ii * num_pol[j] + num_pol[j]-1] - 
                     degn_pt[num_degn][ii]);
            }
          }
          else
          {
            d1 = 0;
            d2 = 0;
            for (ii = 0; ii < dim; ++ii)
            {
              d1 += (poles[j][ii * num_pol[j]] - poles[j][dim * num_pol[j]]
                     * degn_pt[num_degn][ii]) * 
                    (poles[j][ii * num_pol[j]] - poles[j][dim * num_pol[j]]
                     * degn_pt[num_degn][ii]);
              d2 += (poles[j][ii * num_pol[j] + num_pol[j]-1] - 
                     poles[j][dim * num_pol[j] + num_pol[j] - 1] * 
                     degn_pt[num_degn][ii]) * 
                    (poles[j][ii * num_pol[j] + num_pol[j]-1] - 
                     poles[j][dim * num_pol[j] + num_pol[j]-1] * 
                     degn_pt[num_degn][ii]);
            }
          }
          if (d1 < tol*tol || d2 < tol*tol)
          {
            /* degn[i] = 2 means removing this degenerate point */

            degn[i] = 2;
            remove_num++;
            break;
          }
        }
      }
      num_degn++;
    }
  }

  uv_start = (BSpair *)BSstackalloc((unsigned)(nsol * sizeof(BSpair)));
  uv_end = (BSpair *)BSstackalloc((unsigned)(nsol * sizeof(BSpair)));

  for (i = 0; i < nsol; ++i)
  {
    if (degn[i] != 2)
    {
      uv_start[i][0] = lgd_cvs->uv_start[i][0];
      uv_start[i][1] = lgd_cvs->uv_start[i][1];
      uv_end[i][0] = lgd_cvs->uv_end[i][0];
      uv_end[i][1] = lgd_cvs->uv_end[i][1];
    }
    else
    {
      uv_start[i][0] = REMOVE + i;
      uv_start[i][1] = REMOVE + i;
      uv_end[i][0] = REMOVE + i;
      uv_end[i][1] = REMOVE + i;
    }
  }


  /* find start and end parameters for each curves */

  for (i = 0; i < nsol; ++i)
  {
    start_bound = FALSE;
    end_bound = FALSE;
    if (degn[i] != 2)
    {
      if (uv_start[i][0] == -1 || uv_start[i][0] == 1 ||
          uv_start[i][1] == -1 || uv_start[i][1] == 1)
        start_bound = TRUE;

      if (uv_end[i][0] == -1 || uv_end[i][0] == 1 ||
          uv_end[i][1] == -1 || uv_end[i][1] == 1)
        end_bound = TRUE;
             
      /* normalize uv_start and uv_end between knots line */

      a1 = u_knots[i][0];
      b1 = u_knots[i][1];
      a2 = v_knots[i][0];
      b2 = v_knots[i][1];
      uv_start[i][0] = (b1 - a1) * uv_start[i][0] / 2 + (b1 + a1) / 2;
      uv_start[i][1] = (b2 - a2) * uv_start[i][1] / 2 + (b2 + a2) / 2;
      uv_end[i][0] = (b1 - a1) * uv_end[i][0] / 2 + (b1 + a1) / 2;
      uv_end[i][1] = (b2 - a2) * uv_end[i][1] / 2 + (b2 + a2) / 2;

      /* Adjust the start and end poles of each curve to make sure */
      /* they are on the boundary of each Bezier patch. 10/28/93   */
      /* find indu and indv through u_knots[i] and v_knots[i]      */

      if (start_bound || end_bound)
      {
        for (j = sf->u_order-1; j <= sf->u_num_poles; ++j)
        {
          if (sf->u_knots[j] != sf->u_knots[j + 1] && 
              sf->u_knots[j] == u_knots[i][0])
          {
            indu = j;
            break;
          }
        }
        for (j = sf->v_order-1; j <= sf->v_num_poles; ++j)
        {
          if (sf->v_knots[j] != sf->v_knots[j + 1] && 
              sf->v_knots[j] == v_knots[i][0])
          {
            indv = j;
            break;
          }
        }

        /* Get the Bezier patch */
  
        status = BSspntbzpch(rc,&indu,&indv,sf,bez,&planar,&closed);
        if (!status)
          goto wrapup;
    
        if (start_bound)
        {
          sfevalBSsfplintlg(sf,bez,1,(BSpair *)uv_start[i],pt1,rc);
          if (BSERROR(*rc))
            goto wrapup;

          /* Set the starting pole of intersection b-spline 
             curve of each Bezier patch */

          if (rat[i])
          {
            num_poles = num_pol[i];
            poles[i][0] = pt1[0] * poles[i][dim * num_poles];
            poles[i][num_poles] = pt1[1] * poles[i][dim * num_poles];
            poles[i][2 * num_poles] = pt1[2] * poles[i][dim * num_poles];

          }
          else
          {
            num_poles = num_pol[i];
            poles[i][0] = pt1[0];
            poles[i][num_poles] = pt1[1];
            poles[i][2 * num_poles] = pt1[2];
          }
        }

        if (end_bound)
        {        
          sfevalBSsfplintlg(sf,bez,1,(BSpair *)uv_end[i],pt2,rc);
          if (BSERROR(*rc))
            goto wrapup;

          /* Set the end pole of intersection b-spline 
             curve of each Bezier patch */

          if (rat[i])
          {
            num_poles = num_pol[i];
            poles[i][num_poles - 1] = 
                 pt2[0] * poles[i][dim * num_poles + num_poles - 1];
            poles[i][2 * num_poles - 1] = 
                 pt2[1] * poles[i][dim * num_poles + num_poles - 1];
            poles[i][3 * num_poles - 1] = 
                 pt2[2] * poles[i][dim * num_poles + num_poles - 1];
          }
          else
          {
            num_poles = num_pol[i];
            poles[i][num_poles - 1] = pt2[0];
            poles[i][2 * num_poles - 1] = pt2[1];
            poles[i][3 * num_poles - 1] = pt2[2];
          }
        }
      }
    }
  }

  /* find curve graph */

  big_space2 = BSstackalloc((unsigned)(4 * nsol * sizeof(IGRint)));
  if (!big_space2)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  nb1 = (IGRint *)big_space2;
  nb2 = (IGRint *)&big_space2[nsol * sizeof(IGRint)];
  start_end1 = (IGRint *)&big_space2[2 * nsol * sizeof(IGRint)];
  start_end2 = (IGRint *)&big_space2[3 * nsol * sizeof(IGRint)];

  /* find local tolerance for linking */

  opt = 2;
  par = sf->v_knots[0];
  max_ord = MAX(sf->u_order,sf->v_order);
  max_num_poles = MAX(sf->u_num_poles,sf->v_num_poles);

  BSstkallocv(rc,cv,max_num_poles,sf->rational,max_ord+max_num_poles,0);
  if (BSERROR(*rc))
    goto wrapup;
  (void)BSconstprcv(rc,sf,&opt,&par,&planar,cv);
  if (BSERROR(*rc))
    goto wrapup;
  arclenBSsfplintlg(cv,&du,rc);
  if (BSERROR(*rc))
    goto wrapup;
  opt = 1;
  par = sf->u_knots[0];
  (void)BSconstprcv(rc,sf,&opt,&par,&planar,cv);
  arclenBSsfplintlg(cv,&dv,rc);
  if (BSERROR(*rc))
    goto wrapup;
  
  d = MAX(du,dv);
  loc_tol = 10 * tol / d;
  BSlnkcvgrph(2,nsol,(IGRdouble *)uv_start,(IGRdouble *)uv_end,
              loc_tol,nb1,nb2,start_end1,start_end2,rc);
  if (*rc == BSINOTUNIQUE)
  {
    /* If there are selfintersection points, try with smaller tolerance */

    rc2 = *rc;
    *rc = BSSUCC;
    if (BSOKAY(rco))
    {
      first += 1;
      if (first <=1)
        goto wrapup;
    }
  }

  /* Check if the curve is starting and ending on the boundary */
  /* If rc2 = BSINOTUNIQUE, than skip this part of code, go to */
  /* call BSgraphsort to try link curves */

  if (rc2 == BSSUCC)
  {     
    u_knots[0][0] = sf->u_knots[0];
    u_knots[0][1] = sf->u_knots[sf->u_num_poles];
    v_knots[0][0] = sf->v_knots[0];
    v_knots[0][1] = sf->v_knots[sf->v_num_poles];

    BSchkconti(nsol,nb1,nb2,uv_start,uv_end,u_knots[0],v_knots[0],rc);
    if (*rc == BSNOTCONTINUOUS)
    {
      rc2 = *rc;
      *rc = BSSUCC; 
      first += 1;
      if (first <= 1)
        goto wrapup;
    }
  }

  BSgraphsort(nsol,nb1,nb2,start_end1,start_end2,num_cvs,ncvs,ind,rev,rc);
  if (BSERROR(*rc) && rc[0] != BSFAIL)
    goto wrapup;


  /* subtract the degenerate points to be removed from the 
     total number intersection curves */

  *num_cvs -= remove_num;

  /* allocate space for orat,npoles,opoles and oknots */

  npoles = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!npoles)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  orat = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!orat)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  oord = (IGRint *)BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
  if (!oord)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  opoles = (IGRdouble **)BSmalloc((unsigned)
                             (nsol * sizeof(IGRdouble *)));
  if (!opoles)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }
  oknots = (IGRdouble **)BSmalloc((unsigned)
                             (nsol * sizeof(IGRdouble *)));
  if (!oknots)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }
  for (i = 0; i < nsol; ++i)
  {
    opoles[i] = NULL;
    oknots[i] = NULL;
  }

  /* merge b_spline curves */

  ind1 = 0;
  count = 0;
  start = 0;
  for (i = 0; i < *num_cvs + remove_num; ++i)
  {
    if (ncvs[i] > 1 && ind[ind1] == ind[ind1 + ncvs[i] - 1])
    {
      numcv = ncvs[i] - 1;

      if (numcv == 2)
      {
        /* rev[ind[ind1 + 1]] bit may not be set correct by BSgraphsort.
           Reset rev[ind[ind1 + 1]] bit by computing the distance between
           end parameters */

        d1 = 0;
        d1 += (uv_end[ind[ind1]][0] - uv_start[ind[ind1 + 1]][0]) *
              (uv_end[ind[ind1]][0] - uv_start[ind[ind1 + 1]][0]) +
              (uv_end[ind[ind1]][1] - uv_start[ind[ind1 + 1]][1]) *
              (uv_end[ind[ind1]][1] - uv_start[ind[ind1 + 1]][1]);
        d2 = 0;
        d2 += (uv_end[ind[ind1]][0] - uv_end[ind[ind1 + 1]][0]) *
              (uv_end[ind[ind1]][0] - uv_end[ind[ind1 + 1]][0]) +
              (uv_end[ind[ind1]][1] - uv_end[ind[ind1 + 1]][1]) *
              (uv_end[ind[ind1]][1] - uv_end[ind[ind1 + 1]][1]);
        if (d1 < tol * tol)
          rev[ind1 + 1] = 0;
        else
          rev[ind1 + 1] = 1;
      }
    }
    else
      numcv = ncvs[i];

    if (degn[ind[ind1]] != 2)
    {

      for (j = 0; j < numcv; ++j)
      {
        ord[j] = mod_cvs->ndegtab[ind[ind1 + j]] + 1;
        dim = mod_cvs->dimtab[ind[ind1 + j]];
        num_pol[j] = mod_cvs->npoltab[ind[ind1 + j]];
        rat[j] = mod_cvs->rattab[ind[ind1 + j]];
        poles[j] = mod_cvs->poles[ind[ind1 + j]];
        knots[j] = mod_cvs->knots[ind[ind1 + j]];

        if (rev[ind1 + j])
        {
          BSrev_poles((dim + rat[j]),num_pol[j],poles[j]);

          ndeg2 = lgd_cvs->ndegtab[ind[ind1 + j]];
          rat2 = lgd_cvs->rattab[ind[ind1 + j]];
          uvlgd = lgd_cvs->cvlgd[ind[ind1 + j]];
          dim2 = 2;
          BSrev_lgd(dim2,ndeg2,rat2,uvlgd);

        }
      }
    
      
      BSmergncvdo(numcv,dim,ord,num_pol,rat,poles,knots,conti,
                  &order1,&num_poles, &rational,&outpoles,&outknots,rc);
      if (BSERROR(*rc))
        goto wrapup;

      oord[count] = order1;
      orat[count] = rational;
      npoles[count] = num_poles;
      opoles[count] = outpoles;
      outpoles = NULL;
      oknots[count] = outknots;
      outknots = NULL;
      count++;
    }
    ind1 += ncvs[i];
  }

  BSoutputcvs(*num_cvs + remove_num,ncvs,ind,degn,lgd_cvs,oord,npoles,
              orat,opoles,oknots,tol,cmpcvs,bsp_cvs,rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (oknots)
  {
    for (i =0; i < *num_cvs; ++i)
    {
      if (oknots[i])
      {
        BSdealloc((char *) oknots[i]);
        oknots[i] = NULL;
      }
    }
    BSdealloc((char *) oknots);
    oknots = NULL;
  }
  if (opoles)
  {
    for (i =0; i < *num_cvs; ++i)
    {
      if (opoles[i])
      {
        BSdealloc((char *) opoles[i]);
        opoles[i] = NULL;
      } 
    }
    BSdealloc((char *) opoles);
    opoles = NULL;
  }


  /* remove redundent solution on the boundary of a closed surface */

  if (sf->u_phy_closed && sf->v_phy_closed)
  {
    BSrmdbbdry(*num_cvs,2,*cmpcvs,*bsp_cvs,&numcv,rc);
     *num_cvs = numcv;
  }
  if (sf->u_phy_closed)
  {
    BSrmdbbdry(*num_cvs,0,*cmpcvs,*bsp_cvs,&numcv,rc);
     *num_cvs = numcv;
  }
  else if (sf->v_phy_closed)
  {
     BSrmdbbdry(*num_cvs,1,*cmpcvs,*bsp_cvs,&numcv,rc);
     *num_cvs = numcv;
  }
     
  wrapup:
  if (cv)
  {
    BSstkfreecv(&rc1,cv);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    cv = NULL;
  }

  if (oknots)
  {
    for (i =0; i < *num_cvs; ++i)
    {
      if (oknots[i])
      {
        BSdealloc((char *) oknots[i]);
        oknots[i] = NULL;
      }
    }
    BSdealloc((char *) oknots);
    oknots = NULL;
  }
  if (opoles)
  {
    for (i =0; i < *num_cvs; ++i)
    {
      if (opoles[i])
      {
        BSdealloc((char *) opoles[i]);
        opoles[i] = NULL;
      }
    }
    BSdealloc((char *) opoles);
    opoles = NULL;
  }
  if (oord)
  {
    BSstackdealloc((char *) oord);
    oord = NULL;
  }
  if (orat)
  {
    BSstackdealloc((char *) orat);
    orat = NULL;
  }
  if (npoles)
  {
    BSstackdealloc((char *) npoles);
    npoles = NULL;
  }

  if (uv_start)
  {
    BSstackdealloc((char *) uv_start);
    uv_start = NULL;
  }
  if (uv_end)
  {
    BSstackdealloc((char *) uv_end);
    uv_end = NULL;
  }

  if (degn_pt)
  {
    BSstackdealloc((char *) degn_pt);
    degn_pt = NULL;
  }
  if (degn)
  {
    BSstackdealloc((char *) degn);
    degn = NULL;
  }
  if (isocv)
  {
    BSstackdealloc((char *) isocv);
    isocv = NULL;
  }
  if (uv)
  {
    BSstackdealloc((char *) uv);
    uv = NULL;
  }
  if (outpoles)
  {
    BSdealloc((char *) outpoles);
    outpoles = NULL;
  }

  if (outknots)
  {
    BSdealloc((char *) outknots);
    outknots = NULL;
  }
  if (ncvs)
  {
    BSstackdealloc((char *) ncvs);
    ncvs = NULL;
  }
  if (ind)
  {
    BSstackdealloc((char *) ind);
    ind = NULL;
  }
  if (rev)
  {
    BSstackdealloc((char *) rev);
    rev = NULL;
  }
  if (ord)
  {
    BSstackdealloc((char *) ord);
    ord = NULL;
  }
  if (num_pol)
  {
    BSstackdealloc((char *) num_pol);
    num_pol = NULL;
  }
  if (rat)
  {
    BSstackdealloc((char *) rat);
    rat = NULL;
  }
  if (poles)
  {
    BSstackdealloc((char *) poles);
    poles = NULL;
  }
  if (knots)
  {
    BSstackdealloc((char *) knots);
    knots = NULL;
  }
  if (big_space1)
  {
    BSstackdealloc((char *) big_space1);
    big_space1 = NULL;
  }
  if (big_space2)
  {
    BSstackdealloc((char *) big_space2);
    big_space2 = NULL;
  }
  if (polybez)
  {
    BSstackdealloc((char *) polybez);
    polybez = NULL;
  }
  if (cv_ind)
  {
    BSstackdealloc((char *) cv_ind);
    cv_ind = NULL;
  }
  if (pch_ind)
  {
    BSstackdealloc((char *) pch_ind);
    pch_ind = NULL;
  }
  if (p_ind)
  {
    BSstackdealloc((char *) p_ind);
    p_ind = NULL;
  }
  if (tran_poles)
  {
    BSstackdealloc((char *) tran_poles);
    tran_poles = NULL;
  }
  if (bez)
  {
    BSstkfreesf(&rc1,bez);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    bez = NULL;
  }

  if (mod_cvs)
  {
    BSfrebspcvs(mod_cvs,&rc1);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    mod_cvs = NULL;
  }
  if (lgd_cvs)
  {
    BSfrelgdcvs(lgd_cvs,&rc1);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    lgd_cvs = NULL;
  }
  if (poly_cvs)
  {
    BSfrelgdcvs(poly_cvs,&rc1);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    poly_cvs = NULL;
  }
  if (bs_cvs)
  {
    BSfrebspcvs(bs_cvs,&rc1);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    bs_cvs = NULL;
  }

  if (rc2 == BSNOTCONTINUOUS || rc2 == BSINOTUNIQUE)
  {
    if (first == 1)
    {
      /* Might have found geometric singlarity, treat as
         a general case */

      tol /= 1000;
      goto start;
    }
    else
      rcw = TRUE;
  }

  if (BSERROR(rco))
    *rc = rco;
  else if (BSOKAY(*rc) && BSOKAY(rco) && rcw)
    *rc = BSWARN;

  if(BSERROR(*rc))
    BSdbgrc(*rc,"BSsfplintlg");
  return;
}
