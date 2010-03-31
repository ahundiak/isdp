#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "msdef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "bschangepar.h"
#include "bssfeval.h"
#include "bsmdstptcv.h"
#include "bsmergesort.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmdistptsf.h"
#include "bscveval.h"
#include "bsconstprcv.h"
#include "bscvcv_int.h"
#include "mabcendpts.h"
#include "bspartofcv.h"
#include "bsnorkts.h"
#include "bschgdeppar.h"
#include "bscv_copy.h"
#include "bsprptonsf.h"

#include "PWapi/printerr.h"
#include "PWapi/mapisocv.h"
#include "PWapi/partol.h"
#include "PWapi/cvgeom.h"
#include "PWapi/sfbnds.h"
#include "PWapi/degengm.h"
#include "PWapi/ptpargm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/rngbx.h"
#include "PWapi/samepts.h"
#include "PWapi/isopts.h"
#include "PWapi/pytocv.h"
#include "PWapi/refbdrypts.h"

/* Static functions */

static PWresult split_cv_at_degen_bdrys
(
  struct IGRbsp_curve *p_cv,
  struct IGRbsp_surface *p_sf,

  PWboolean degen_u0,
  PWboolean degen_u1,
  PWboolean degen_v0,
  PWboolean degen_v1,

  double xyztol,

  int *numcvs,
  struct IGRbsp_curve split_cvs[3]
);

static double getavgpar
(
  int        numpts,
  PWpoint2d  *sfuvpts,
  int        isodir
);

/* Internal Macros */

#define PARAM1  0.2
#define PARAM2  0.5
#define PARAM3  0.8

#define IsParOnSeam(par, min, max, tol) \
  ((par - min) < tol || (max - par) < tol)

/*
  ABSTRACT

    Given a xyz curve and the surface, it returns TRUE if the curve matches 
    one of the iso curves of the surface otherwise returns FALSE. If the 
    input curve is iso, it returns the bounds of the curve in UV space of
    the surface.  

  NOTES

    Two types of XYZ curves are supported i.e. polyline, B-Spline curves.

  HISTORY

    Sanjay  09/13/95  Creation
    Aditya  04/10/96  Fixes for the ACIS-EMS xlator. Do not error out if
                      the cv is away from the surface by more than xyztol
                      as it doesn't matter on the ems side. Added refinement
                      of mapped pts on degenerate boundaries. Replaced all
                      calls to BSmdistptsf() by calls to BSprptonsf()
                      as they use different methods to arrive at the uv
                      points. Further, non-iso mapping also uses
                      BSprptonsf(), and so we can maintain uniformity
                      of mapped points. Removed the call to BScvcvint()
                      that was finding overlaps. The end points that it
                      returns are not quite correct to within tol of
                      the actual end points of the curve. Now we are
                      forcing the end points and assume 1 overlap.
*/

PWresult pwSplitAndMapXyzCvIsoInUvOfSf
(
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_isocvs,
  PWpoint2d isocv_pts[6],

  int *num_non_isocvs,
  struct PWcvdata p_non_isocvs[3]
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC, BSmsg1=BSSUCC;
  PWboolean BSsts=TRUE;
  double uvtol=0, cvpartol=0, bastol=0;

  int numpts=0, knt=0, inx=0, npt=0;
  PWpoint cvxyzpts[5], sfxyzpts[5];
  PWpoint2d sfuvpts[5];
  double mincvpar, maxcvpar, cvpar[5];
  double totalpar=0, par=0, isopar=0, u_par[5], v_par[5], dist=0; 
  PWpoint tmppt;

  PWboolean degen_u0=FALSE, degen_u1=FALSE, degen_v0=FALSE, degen_v1=FALSE;
  PWboolean is_iso=FALSE;
  double cvpar_min=0, cvpar_max=0;

  int num_split_cvs=0, isodir=0;
  short opt=0;
  PWboolean tst_plan=FALSE, onsurf=FALSE;
  struct IGRbsp_curve *p_icv=NULL, *p_cv=NULL, u_isocv, v_isocv;
  struct IGRbsp_curve *p_split_cvs[3], split_cvs[3], *p_isocv=NULL;

  int n_int=0;
  long n_over=0;
  
  /*
   double *p_intpts=NULL, *p_endpts=NULL, *p_par0=NULL, *p_par1=NULL, 
         *p_over0=NULL, *p_over1=NULL;
  */
  double p_endpts[6], p_over0[2];

  double u_min=0, u_max=0, v_min=0, v_max=0;

  *num_isocvs = 0;
  *num_non_isocvs = 0;

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  uvtol = pwGetParTolSf (p_sf, xyztol); 
  BSEXTRACTPAR (&BSmsg, BSTOLBASIS, bastol);

  /*
   * For simplicity get the B-spline representation of the input Xyz Curve.
   */
  if (p_xyzcv->datatype == PWcvdata_bspcv)
  {
    p_icv = p_xyzcv->data.p_bspcv;
  }
  else if (p_xyzcv->datatype == PWcvdata_gmbspcv)
  {
    p_icv = p_xyzcv->data.p_gmbspcv->bspcv;
  } 
  else
  {
    p_icv = (struct IGRbsp_curve *) alloca (sizeof (struct IGRbsp_curve)); 
    PWsts = PW_AllocBspCvStack (p_xyzcv->data.py.num_pts, 2, 0, (*p_icv));
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    pwCnvtPyToCv (&p_xyzcv->data.py, xyztol, p_icv); 
  }

  /*
   * Split the curve at the degenerate natural boundaries.
   */
  PWsts = pwGetDegenNatBdrysOfSf (p_sf, xyztol, &degen_u0, &degen_u1, 
                                  &degen_v0, &degen_v1);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  if (degen_u0 || degen_u1 || degen_v0 || degen_v1)
  {
    int npoles=0;

    npoles = p_icv->num_poles + p_icv->order * 2 - 1;

    for (knt=0; knt<3; knt++)
    {
      PWsts = PW_AllocBspCvStack (npoles, p_icv->order, p_icv->rational, 
                                  split_cvs[knt]); 
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }
 
    PWsts = split_cv_at_degen_bdrys (p_icv, p_sf, degen_u0, degen_u1, degen_v0,
                               degen_v1, xyztol, &num_split_cvs, split_cvs);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
  }

  if (!num_split_cvs)
  {
    num_split_cvs = 1;
    p_split_cvs[0] = p_icv;
  }
  else
  {
    for (knt=0; knt<num_split_cvs; knt++)
      p_split_cvs[knt] = &split_cvs[knt]; 
  }

  PWsts = PW_AllocBspCvStack (p_sf->v_num_poles, p_sf->v_order, p_sf->rational,
                              u_isocv);
  PWsts = PW_AllocBspCvStack (p_sf->u_num_poles, p_sf->u_order, p_sf->rational,
                              v_isocv);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  for (knt=0; knt<num_split_cvs; knt++)
  {
    p_cv = p_split_cvs[knt];
    is_iso = FALSE;

    cvpartol = pwGetParTolCv (p_cv, xyztol);

    /*
     * get three sample points on the xyz curve and find the corresponding
     * points in the parametric space of the surface.
     */
    mincvpar = p_cv->knots [p_cv->order-1];
    maxcvpar = p_cv->knots [p_cv->num_poles];
    totalpar = maxcvpar - mincvpar;
 
    numpts = 5;
    cvpar[0] = mincvpar;
    cvpar[1] = mincvpar + PARAM1 * totalpar;
    cvpar[2] = mincvpar + PARAM2 * totalpar;
    cvpar[3] = mincvpar + PARAM3 * totalpar;
    cvpar[4] = maxcvpar;

 
    for (npt=0; npt<numpts; npt++)
    {
	  onsurf =FALSE;

      BScveval (p_cv, cvpar[npt], (int) 0, &cvxyzpts[npt], &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      BSprptonsf (&BSmsg, p_sf, cvxyzpts[npt], &sfuvpts[npt][U], 
                  &sfuvpts[npt][V], &onsurf);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                    PW_K_Internal), wrapup);

     /*
      BSsts = BSmdistptsf (&BSmsg, p_sf, cvxyzpts[npt], &sfuvpts[npt][U], 
                           &sfuvpts[npt][V], sfxyzpts[npt], &dist);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                    PW_K_Internal), wrapup);
     */
      
      /*
       * In EMS it is not necessary that the xyz curves lie on the surface. 
       * Don't error out if it is away from the surface by chttol.

      if (dist > xyztol)
      {
        pwDebugLine (PW_K_DebugWarning,
                     "pwSplitAndMapXyzCvIsoInUvOfSf: dist %lf  xyztol %lf\n",
                     dist, xyztol);
        PWsts = SetInfo (PW_K_Pathway, PW_K_Tolerance);
      }
    
      OnErrorState ((dist > xyztol), PWsts, SetError (PW_K_Pathway, 
                   PW_K_Tolerance), wrapup);   
      */
    }
  
    /*
     * If any of the above test points maps onto a degenerate natural boundary
     * of the surface, it could lie anywhere along the boundary. Therefore,
     * refine the point in uv so that it is close to acceptable.
     */
    PWsts = pwRefineUvPtsOnDegenBdrysOfSf (p_sf, numpts, sfuvpts, xyztol);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    if (p_sf->u_phy_closed)
    {
      for (npt=0; npt<numpts; npt++)
      {
        if ((u_max - sfuvpts[npt][U]) < uvtol)
		{
          sfuvpts[npt][U] = u_min;
		}
      }
    }
  
    if (p_sf->v_phy_closed)
    {
      for (npt=0; npt<numpts; npt++)
      {						  
        if ((v_max - sfuvpts[npt][V]) < uvtol)
		{
          sfuvpts[npt][V] = v_min;
		}
      }
    }

    if (pwIsUvPtsIso (numpts, sfuvpts, uvtol, &isodir))
    {
/*
 * We are for the moment doing away with the grand plan of using BScvcint()
 * to find the intersections and overlaps of the incoming curve and iso curve
 * with the aim of finding all the iso and non-iso curve segments.
 * The condition being forced is one where we assume one overlap and use the
 * original end points of the curve as there was a tolerance problem while
 * using the end pts returned by BScvcvint()
 */
	
      if (isodir == U)
      {
        opt = 1;
        isopar = getavgpar (numpts, sfuvpts, isodir);
        p_isocv = &u_isocv;
      }
      else
      {
        opt = 2;
        isopar = getavgpar (numpts, sfuvpts, isodir);
        p_isocv = &v_isocv;
      }
	/*
      BSsts = BSconstprcv (&BSmsg, p_sf, &opt, &isopar, &tst_plan, p_isocv);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      BSchgdeppar (xyztol, &BSmsg1);
      n_int = 0; n_over = 0;
      BSsts = BScvcv_int (&BSmsg, p_cv, p_isocv, &n_int, &p_intpts, &p_par0,
                          &p_par1, &n_over, &p_endpts, &p_over0, &p_over1);
      BSchgdeppar (bastol, &BSmsg1);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
	*/

      cvpar_min = p_cv->knots[p_cv->order-1];
      cvpar_max = p_cv->knots[p_cv->num_poles];

  n_over = 1;
  p_over0[0] = cvpar_min;
  p_over0[(n_over-1)*2+1] = cvpar_max;

  memcpy(&p_endpts[0], cvxyzpts[0], 3*sizeof(double));
  memcpy(&p_endpts[3], cvxyzpts[numpts-1], 3*sizeof(double));

      if ((n_over == 1 || n_over == 2) && 
          ((p_over0[(n_over-1)*2+1] - p_over0[0]) - (cvpar_max - cvpar_min)) < 
           cvpartol)
      {

        is_iso = TRUE;

        for (inx=0; inx<n_over; inx++)
        {
          if (isodir == U)
          {
            isocv_pts [(*num_isocvs) * 2][U] = isopar;
            isocv_pts [(*num_isocvs) * 2+1][U] = isopar;
          }
          else
          {
            isocv_pts [(*num_isocvs) * 2][V] = isopar;
            isocv_pts [(*num_isocvs) * 2+1][V] = isopar;
          }

          /*
          BSsts = BSmdistptsf (&BSmsg, p_sf, &p_endpts[(inx*2)*3], &u_par[0], 
                               &v_par[0], tmppt, &dist);
		  */
	  	  BSprptonsf (&BSmsg, p_sf, &p_endpts[(inx*2)*3], &u_par[0], &v_par[0], &onsurf);
          OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                        PW_K_Internal), wrapup);

          if (pwIsSamePt (&p_endpts[inx*2], &p_endpts[(inx*2+1)*3], xyztol))
          {
            if (isodir == V && p_sf->u_phy_closed && 
                IsParOnSeam (u_par[0], u_min, u_max, uvtol))
            {
             /* if ((sfuvpts[0][U] - u_min) < (u_max - sfuvpts[0][U])) */
			 if (sfuvpts[2][U] > sfuvpts[1][U])
              {
                u_par[0] = u_min;
                u_par[1] = u_max;
              }
              else
              {
                u_par[0] = u_max;
                u_par[1] = u_min;
              }
            }
            else
              u_par[1] = u_par[0];

            if (isodir == U && p_sf->v_phy_closed &&
                IsParOnSeam (v_par[0], v_min, v_max, uvtol))
            {
              /*if ((sfuvpts[0][V] - v_min) < (v_max - sfuvpts[0][V]))	*/
			  if (sfuvpts[2][V] > sfuvpts[1][V] )
              {
                v_par[0] = v_min;
                v_par[1] = v_max;
              }
              else
              {
                v_par[0] = v_max;
                v_par[1] = v_min;
              }
            }
            else
              v_par[1] = v_par[0];
          }
          else
          {
       /*
          BSsts = BSmdistptsf (&BSmsg, p_sf, &p_endpts[(inx*2+1)*3], 
                                 &u_par[1], &v_par[1], tmppt, &dist);
        */
            BSprptonsf (&BSmsg, p_sf, &p_endpts[(inx*2+1)*3], &u_par[1], 
                        &v_par[1], &onsurf);
            OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                          PW_K_Internal), wrapup);

            if ((isodir == U && p_sf->v_phy_closed && 
                 (IsParOnSeam (v_par[0], v_min, v_max, uvtol) ||
                  IsParOnSeam (v_par[1], v_min, v_max, uvtol))) ||
                ((isodir == V && p_sf->u_phy_closed) &&
                  (IsParOnSeam (u_par[0], u_min, u_max, uvtol) ||
                   IsParOnSeam (u_par[1], u_min, u_max, uvtol))))
            {
              par = (p_over0[inx*2] + p_over0[inx*2+1]) / 2.0;

              BScveval (p_cv, par, (int) 0, &tmppt, &BSmsg);
              OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                            PW_K_Internal), wrapup);

            /*
              BSsts = BSmdistptsf (&BSmsg, p_sf, tmppt, &u_par[2], &v_par[2], 
                                   tmppt, &dist);
            */
             BSprptonsf (&BSmsg, p_sf, tmppt, &u_par[2], &v_par[2], &onsurf);

             OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                          PW_K_Internal), wrapup);

              if (isodir == U)
              {
                if ((v_par[2] - v_min) < (v_max - v_par[2]))
                { 
                  if (IsParOnSeam (v_par[0], v_min, v_max, uvtol))
                    v_par[0] = v_min;
                  else
                    v_par[1] = v_min;
                } 
                else
                { 
                  if (IsParOnSeam (v_par[0], v_min, v_max, uvtol))
                    v_par[0] = v_max;
                  else
                    v_par[1] = v_max;
                } 
              }
              else
              {
                if ((u_par[2] - u_min) < (u_max - u_par[2]))
                { 
                  if (IsParOnSeam (u_par[0], u_min, u_max, uvtol))
                    u_par[0] = u_min;
                  else
                    u_par[1] = u_min;
                } 
                else
                { 
                  if (IsParOnSeam (u_par[0], u_min, u_max, uvtol))
                    u_par[0] = u_max;
                  else
                    u_par[1] = u_max;
                } 
              }
            }
          }

          if (isodir == U)
          {
            isocv_pts [(*num_isocvs) * 2][V] = v_par[0];
            isocv_pts [(*num_isocvs) * 2+1][V] = v_par[1];
          }
          else
          {
            isocv_pts [(*num_isocvs) * 2][U] = u_par[0];
            isocv_pts [(*num_isocvs) * 2+1][U] = u_par[1];
          }
    
          (*num_isocvs) ++;
        }
      }
    /*
      if (p_intpts) free (p_intpts);
      if (p_par0) free (p_par0);
      if (p_par1) free (p_par1);
      if (p_endpts) free (p_endpts);
      if (p_over0) free (p_over0);
      if (p_over1) free (p_over1);

      p_intpts = NULL; p_par0 = NULL; p_par1 = NULL;
      p_endpts = NULL; p_over0 = NULL; p_over1 = NULL;
    */
    }

    if (!is_iso && num_split_cvs != 1)
    {
      if (p_xyzcv->datatype == PWcvdata_py)
      {
        p_non_isocvs [(*num_non_isocvs)].datatype = PWcvdata_py;
        p_non_isocvs [(*num_non_isocvs)].data.py.num_pts = p_cv->num_poles;
        p_non_isocvs [(*num_non_isocvs)].data.py.p_pts = 
                     (PWpoint *) malloc (p_cv->num_poles * sizeof (PWpoint));
        memcpy (p_non_isocvs [(*num_non_isocvs)].data.py.p_pts, p_cv->poles,
                p_cv->num_poles * sizeof (PWpoint));
      }
      else
      {
        p_non_isocvs [(*num_non_isocvs)].datatype = PWcvdata_bspcv;
        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 0, 
                   &p_non_isocvs [(*num_non_isocvs)].data.p_bspcv, &BSmsg);
        OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                      PW_K_Internal), wrapup);

        BSsts = BScv_copy (&BSmsg, p_cv, 
                           p_non_isocvs [(*num_non_isocvs)].data.p_bspcv);
        OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                      PW_K_Internal), wrapup);
      }

      (*num_non_isocvs) ++;
    }
  }
  
wrapup :
  PW_Wrapup (PWsts, "pwSplitAndMapXyzCvIsoInUvOfSf");
  return PWsts;
} 

static PWresult split_cv_at_degen_bdrys
(
  struct IGRbsp_curve *p_cv,
  struct IGRbsp_surface *p_sf,

  PWboolean degen_u0,
  PWboolean degen_u1,
  PWboolean degen_v0,
  PWboolean degen_v1,

  double xyztol,

  int *numcvs,
  struct IGRbsp_curve split_cvs[3]
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;
  int knt=0, num_degen=0, mod_num_degen=0;
  PWpoint2d degen_uvpts[2];
  PWpoint degen_xyzpts[2], mod_degen_xyzpts[2], cvstart, cvstop, tmppt;
  double degen_cvpar[2], degen_dist[2], mod_degen_cvpar[2];
  double u_min=0, u_max=0, v_min=0, v_max=0, cvpar_min=0, cvpar_max=0;
  double split_cvpar[3][3];

  *numcvs = 0;

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  /*
   * get the uv points corresponding to the degenerate natural boundaries of
   * the surface and evaluate these points on the surface to get the XYZ 
   * points.
   */

  if (degen_u0 || degen_u1)
  {
    if (degen_u0)
    {
      degen_uvpts[num_degen][U] = u_min;
      degen_uvpts[num_degen][V] = v_min;
      num_degen ++;
    }

    if (degen_u1)
    {
      degen_uvpts[num_degen][U] = u_max;
      degen_uvpts[num_degen][V] = v_min;
      num_degen ++;
    }
  }
  else if (degen_v0 || degen_v1)
  {
    if (degen_v0)
    {
      degen_uvpts[num_degen][U] = u_min;
      degen_uvpts[num_degen][V] = v_min;
      num_degen ++;
    }

    if (degen_v1)
    {
      degen_uvpts[num_degen][U] = u_min;
      degen_uvpts[num_degen][V] = v_max;
      num_degen ++;
    }
  }

  for (knt=0; knt<num_degen; knt++)
  {
    BSsfeval (p_sf, degen_uvpts[knt][U], degen_uvpts[knt][V], (int) 0,
              &degen_xyzpts[knt], &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                  PW_K_Internal), wrapup);
  }

  /*
   * Discard all the points which matches with the input curve end points.
   */

  MAbcendpts (&BSmsg, p_cv, cvstart, cvstop);
  OnErrorState (BSmsg != MSSUCC, PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  mod_num_degen = 0;

  for (knt=0; knt<num_degen; knt++)
  {
    if (!pwIsSamePt (degen_xyzpts[knt], cvstart, xyztol) &&
        !pwIsSamePt (degen_xyzpts[knt], cvstop, xyztol))
    {
      memcpy (mod_degen_xyzpts[mod_num_degen], degen_xyzpts[knt], 
              sizeof (PWpoint));
      mod_num_degen ++;
    }
  }

  if (!mod_num_degen)
    goto wrapup;

  num_degen = mod_num_degen;
  memcpy (degen_xyzpts, mod_degen_xyzpts, mod_num_degen * sizeof (PWpoint));

  /*
   * Discard all the points away from the input curve and find the curve 
   * parameters corresponding to the one's which are on the curve.
   */
 
  for (knt=0; knt<num_degen; knt++)
  {
    BSmdstptcv (p_cv, degen_xyzpts[knt], &degen_cvpar[knt], tmppt, 
                &degen_dist[knt], &BSmsg);  
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);
  }

  mod_num_degen = 0;

  for (knt=0; knt<num_degen; knt++)
  {
    if (degen_dist[knt] < xyztol)
    {
      mod_degen_cvpar[mod_num_degen] = degen_cvpar[knt];
      mod_num_degen ++;
    }      
  }

  if (!mod_num_degen)
    goto wrapup;

  OnErrorState (num_degen > 2, PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  num_degen = mod_num_degen;
  memcpy (degen_cvpar, mod_degen_cvpar, mod_num_degen * sizeof (double));

  if (num_degen > 1)
    BSmergesort (degen_cvpar, num_degen, &BSmsg);

  /*
   * Split the curve at these degenerate points.
   */
    
  cvpar_min = p_cv->knots [p_cv->order-1];
  cvpar_max = p_cv->knots [p_cv->num_poles];

  
  if (num_degen == 2)
  {
    if (!p_cv->phy_closed)
    {
      *numcvs = 3;
      split_cvpar[0][0] = cvpar_min; split_cvpar[0][2] = degen_cvpar[0];
      split_cvpar[0][1] = (cvpar_min + degen_cvpar[0]) / 2.0;

      split_cvpar[1][0] = degen_cvpar[0]; split_cvpar[1][2] = degen_cvpar[1];
      split_cvpar[1][1] = (degen_cvpar[0] + degen_cvpar[1]) / 2.0;

      split_cvpar[2][0] = degen_cvpar[1]; split_cvpar[2][2] = cvpar_max;
      split_cvpar[2][1] = (degen_cvpar[1] + cvpar_max) / 2.0;
    }
    else
    {
      *numcvs = 2;
     
      split_cvpar[0][0] = degen_cvpar[0]; split_cvpar[0][2] = degen_cvpar[1]; 
      split_cvpar[0][1] = cvpar_min;

      split_cvpar[1][0] = degen_cvpar[0]; split_cvpar[1][2] = degen_cvpar[1]; 
      split_cvpar[1][1] = (degen_cvpar[0] + degen_cvpar[1]) / 2.0;
    }
  }
  else
  {
    *numcvs = 2;
    split_cvpar[0][0] = cvpar_min; split_cvpar[0][2] = degen_cvpar[0];
    split_cvpar[0][1] = (cvpar_min + degen_cvpar[0]) / 2.0;

    split_cvpar[1][0] = degen_cvpar[0]; split_cvpar[1][2] = cvpar_max;
    split_cvpar[1][1] = (degen_cvpar[0] + cvpar_max) / 2.0;
  }

  for (knt=0; knt<*numcvs; knt++)
  { 
    BSpartofcv (&BSmsg, p_cv, split_cvpar[knt][0], split_cvpar[knt][1],
                split_cvpar[knt][2], &split_cvs[knt]);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    BSsts = BSnorkts (&BSmsg, &split_cvs[knt].order, 
                      &split_cvs[knt].num_poles, split_cvs[knt].knots);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);
  }

wrapup :

  PW_Wrapup (PWsts, "split_cv_at_degen_bdrys");
  return PWsts;
}

static double getavgpar
(
  int        numpts,
  PWpoint2d  *sfuvpts,
  int        isodir
)
{
  int cnt=0;
  double sum=0.0;

  for (cnt=0; cnt<numpts; cnt++)
  {
    sum += sfuvpts[cnt][isodir];
  }
  return (sum/numpts);
}
