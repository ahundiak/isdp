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
#include "bsmdistcvcv.h"
#include "bscveval.h"
#include "bsconstprcv.h"
#include "bscvcv_int.h"
#include "mabcendpts.h"
#include "bspartofcv.h"
#include "bsnorkts.h"
#include "bschgdeppar.h"
#include "bscv_copy.h"

#include "PWapi/mapseamcv.h"
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
#include "PWapi/rngbx.h"

/* Static functions */

static PWresult split_and_map_cv_on_seam_of_sf
(
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  int seam,

  int *num_seamcvs,
  PWpoint2d **p_seamcvpts,

  int *num_splitcvs,
  struct PWcvdata **p_splitcvs
);


static void get_split_segpars
(
  int n_int,
  int n_over,
  double *p_par,
  double *p_over,

  double minpar,
  double maxpar,
  double partol,

  int *n_seg,
  double *p_segpar
);

/* Internal Macros */

#define IsParOnSeam(par, min, max, tol) \
  ((par - min) < tol || (max - par) < tol)

/*
  ABSTRACT

  NOTES

    Two types of XYZ curves are supported i.e. polyline, B-Spline curves.

  HISTORY

    Sanjay  09/13/95  Creation
*/

PWresult pwSplitAndMapXyzCvSeamInUvOfSf
(
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_seamcvs,
  PWpoint2d **p_seamcvpts,

  int *num_splitcvs,
  struct PWcvdata **p_splitcvs
)
{
  PWresult PWsts=PW_K_Success;

  int knt=0, inx=0, i=0;
  int num_u_splits=0, num_u_seams=0, *num_v_splits=0, *num_v_seams=0;
  PWpoint2d *p_u_seampts=NULL, **p_v_seampts=NULL;
  struct PWcvdata *p_u_splitcvs=NULL, **p_v_splitcvs=NULL;

  int num_total_seams=0;
  int num_total_splits=0;

  /* Initialize output */

  *num_seamcvs = 0;
  *num_splitcvs = 0;
  *p_seamcvpts = NULL;
  *p_splitcvs = NULL;

  OnErrorState (!p_sf->u_phy_closed && !p_sf->v_phy_closed, PWsts, 
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  if (p_sf->u_phy_closed)
  {
    PWsts = split_and_map_cv_on_seam_of_sf (p_sf, p_xyzcv, xyztol, V, 
                  &num_u_seams, &p_u_seampts, &num_u_splits, &p_u_splitcvs);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 
  }

  if (!num_u_seams && !num_u_splits)
  {
    num_u_splits = 1;
    p_u_splitcvs = p_xyzcv;
  }

  p_v_seampts = (PWpoint2d **) alloca (num_u_splits * sizeof (PWpoint2d *));
  p_v_splitcvs = (struct PWcvdata **) alloca (num_u_splits * 
                                       sizeof (struct PWcvdata *));
  num_v_seams = (int *) alloca (num_u_splits * sizeof (int));
  num_v_splits = (int *) alloca (num_u_splits * sizeof (int));

  for (knt=0; knt<num_u_splits; knt++)
  {
    num_v_seams[knt] = 0;
    num_v_splits[knt] = 0;
    p_v_seampts[knt] = NULL;
    p_v_splitcvs[knt] = NULL;
  }

  if (p_sf->v_phy_closed)
  {
    for (knt=0; knt<num_u_splits; knt++)
    {
      PWsts = split_and_map_cv_on_seam_of_sf (p_sf, &p_u_splitcvs[knt], xyztol,
                   U, &num_v_seams[knt], &p_v_seampts[knt], &num_v_splits[knt], 
                   &p_v_splitcvs[knt]);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 
    }
  }

  num_total_seams = num_u_seams;
  for (knt=0; knt<num_u_splits; knt++)
  {
    num_total_seams += num_v_seams[knt];
  }

  num_total_splits = num_u_splits;
  for (knt=0; knt<num_u_splits; knt++)
  {
    if (num_v_splits[knt])
      num_total_splits += (num_v_splits[knt]-1);
  }

  if (!num_total_seams && !num_total_splits)
    goto wrapup;

  for (knt=0; knt<num_u_splits; knt++)
  {
    if (!num_v_seams[knt] && !num_v_splits[knt])
    {
      num_v_seams[knt] = 0;
      num_v_splits[knt] = 1;
      p_v_splitcvs[knt] = &p_u_splitcvs[knt];
    }
  }

  if (num_total_seams)
  {
    (*p_seamcvpts) = (PWpoint2d *) malloc ((num_total_seams + 2) * 
                                           sizeof (PWpoint2d));

    for (knt=0; knt<num_u_seams; knt++)
    {
      (*p_seamcvpts)[knt*2][U] = p_u_seampts[knt*2][U];
      (*p_seamcvpts)[knt*2][V] = p_u_seampts[knt*2][V];
      (*p_seamcvpts)[knt*2+1][U] = p_u_seampts[knt*2+1][U];
      (*p_seamcvpts)[knt*2+1][V] = p_u_seampts[knt*2+1][V];
    }

    inx = num_u_seams;

    for (knt=0; knt<num_u_splits; knt++)
    {
      for (i=0; i<num_v_seams[knt]; i++)
      {
        (*p_seamcvpts)[(i+inx)*2][U] =  p_v_seampts[knt][i*2][U];
        (*p_seamcvpts)[(i+inx)*2][V] =  p_v_seampts[knt][i*2][V];
        (*p_seamcvpts)[(i+inx)*2+1][U] =  p_v_seampts[knt][i*2+1][U];
        (*p_seamcvpts)[(i+inx)*2+1][V] =  p_v_seampts[knt][i*2+1][V];
      }
      inx += num_v_seams[knt];
    }

    *num_seamcvs = num_total_seams;
  }

  if (num_total_splits)
  {
    (*p_splitcvs) = (struct PWcvdata *) malloc (num_total_splits * 
                                                 sizeof (struct PWcvdata));
    inx = 0;
    for (knt=0; knt<num_u_splits; knt++)
    {
      for (i=0; i<num_v_splits[knt]; i++)
      {
        memcpy (&(*p_splitcvs)[inx], &p_v_splitcvs[knt][i], 
                sizeof (struct PWcvdata));
        inx ++;
      }
    }

    *num_splitcvs = inx;
  }
  
wrapup :

  if (p_u_seampts) free (p_u_seampts);

  if (num_total_seams && p_v_seampts)
  {
    for (i=0; i<num_u_splits; i++) 
      if (p_v_seampts[i]) free (p_v_seampts[i]);
  }

  if (num_total_splits && p_v_splitcvs)
  {
    for (i=0; i<num_u_splits; i++)
      if (p_v_splitcvs[i] && p_v_splitcvs[i] != (&p_u_splitcvs[i]))
        free (p_v_splitcvs[i]);
  }

  if (num_total_splits && p_u_splitcvs && p_u_splitcvs != p_xyzcv)
  {
    free (p_u_splitcvs);
  }

  PW_Wrapup (PWsts, "pwSplitAndMapXyzCvSeamInUvOfSf");
  return PWsts;
} 

static PWresult split_and_map_cv_on_seam_of_sf
(
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  int seam,

  int *num_seamcvs,
  PWpoint2d **p_seamcvpts,

  int *num_splitcvs,
  struct PWcvdata **p_splitcvs
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC, BSmsg1=BSSUCC;
  PWboolean BSsts=TRUE;

  int knt=0, npoles=0, order=0;
  short opt=0;
  double isopar=0, u_min=0, v_min=0, u_max=0, v_max=0, bastol=0;
  struct IGRbsp_curve seamcv, *p_incv=NULL, partcv;

  int n_int=0;
  long n_over=0;
  double *p_intpts=NULL, *p_endpts=NULL, *p_par0=NULL, *p_par1=NULL, 
         *p_over0=NULL, *p_over1=NULL, *p_segpar=NULL;
  PWboolean tst_plan=FALSE;

  int n_seg=0;
  double cvpar_min=0, cvpar_max=0, cvpar_tol=0;
  double u_par[2], v_par[2], dist=0;
  PWpoint tmppt;
  PWrange incv_rng, isocv_rng;

  *num_seamcvs = 0;
  *num_splitcvs = 0;
  *p_seamcvpts = NULL;
  *p_splitcvs = NULL;

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  /*
   * extract the seam curve.
   */
  if (seam == U)
  {
    npoles = p_sf->u_num_poles;
    order = p_sf->u_order;
    opt = 2;
    isopar = v_min;
  }
  else
  {
    npoles = p_sf->v_num_poles;
    order = p_sf->v_order;
    opt = 1;
    isopar = u_min;
  }
  
  PWsts = PW_AllocBspCvStack (npoles, order, p_sf->rational, seamcv);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  BSsts = BSconstprcv (&BSmsg, p_sf, &opt, &isopar, &tst_plan, &seamcv);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  if (p_xyzcv->datatype == PWcvdata_bspcv)
  {
    p_incv = p_xyzcv->data.p_bspcv;
  }
  else if (p_xyzcv->datatype == PWcvdata_gmbspcv)
  {
    p_incv = p_xyzcv->data.p_gmbspcv->bspcv;
  }
  else
  {
    p_incv = (struct IGRbsp_curve *) alloca (sizeof (struct IGRbsp_curve));
    PWsts = PW_AllocBspCvStack (p_xyzcv->data.py.num_pts, 2, 0, (*p_incv));
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    pwCnvtPyToCv (&p_xyzcv->data.py, xyztol, p_incv);
  }

  /*
   * Get the range of the incoming and the seam iso curve and do a range
   * intersection check before going on to do the curve-curve intersection.
   */
  pwGetCvRange ( p_incv, incv_rng);
  pwExpandRange( incv_rng, xyztol);
  pwGetCvRange ( &seamcv, isocv_rng);
  pwExpandRange( isocv_rng, xyztol);

  if(!pwIsOverlapRngRng( incv_rng, isocv_rng)) goto wrapup;

  BSEXTRACTPAR (&BSmsg, BSTOLBASIS, bastol);
  BSchgdeppar (xyztol, &BSmsg1);
  BSsts = BScvcv_int (&BSmsg, p_incv, &seamcv, &n_int, &p_intpts, &p_par0,
                      &p_par1, &n_over, &p_endpts, &p_over0, &p_over1);
  BSchgdeppar (bastol, &BSmsg1);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  if (!n_over && !n_int)
  {
    /*
	 * If neither overlaps nor intersections are found, it might be because
	 * the tolerance is coarse enough to miss the closest points between the
	 * curves even if they are within specified xyztol. In such a situation do a
	 * minimum distance check between the curves and accept the minimum distance
	 * points if min_dist < xyztol.
	 */
    int num_mindist=0;
	double min_dist=0.0;
	PWpoint *p_points1=NULL, *p_points2=NULL;

    BSchgdeppar (xyztol, &BSmsg1);
	BSmdistcvcv(p_incv, &seamcv, &num_mindist, &p_par0, &p_par1,
	            &p_points1, &p_points2, &min_dist, &BSmsg);
    BSchgdeppar (bastol, &BSmsg1);

	/*
	 * BSmdistcvcv handles overlap by returning BSINARG as there will be
	 * an infinite number of intersection points. Thus this piece of code can be
	 * construed to be a desperate attempt to find "intersections", i.e. points
	 * that are within xyzchttol of each other.
	 */

	if(min_dist > xyztol || (BSmsg == BSINARG))
	{
	  if(p_par0) free(p_par0);
	  if(p_par1) free(p_par1);
	  if(p_points1) free(p_points1);
	  if(p_points2) free(p_points2);
	  goto wrapup;
	}
	else
	{
	  if(p_par0) free(p_par0);
	  if(p_par1) free(p_par1);
	  if(p_points1) free(p_points1);
	  if(p_points2) free(p_points2);

      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                   wrapup);
	}

   /* Take over the new points. */
	n_over =0;
	n_int = num_mindist;
	p_endpts = (double *)p_points1;
	if(p_points2) free(p_points2);

  }
  

  if (n_over)
  {
    *p_seamcvpts = (PWpoint2d *) malloc (n_over * 2 * sizeof (PWpoint2d));
    OnErrorState (!*p_seamcvpts, PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);

    *num_seamcvs = n_over;
  }

  for (knt=0; knt<n_over; knt++)
  {
    BSsts = BSmdistptsf (&BSmsg, p_sf, &p_endpts[(knt*2)*3], &u_par[0],
                         &v_par[0], tmppt, &dist);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    BSsts = BSmdistptsf (&BSmsg, p_sf, &p_endpts[(knt*2+1)*3], &u_par[1],
                         &v_par[1], tmppt, &dist);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    if (seam == U)
    {
      (*p_seamcvpts) [knt*2][U] = u_par[0];
      (*p_seamcvpts) [knt*2][V] = isopar;
      (*p_seamcvpts) [knt*2+1][U] = u_par[1];
      (*p_seamcvpts) [knt*2+1][V] = isopar;
    }
    else
    {
      (*p_seamcvpts) [knt*2][U] = isopar;
      (*p_seamcvpts) [knt*2][V] = v_par[0];
      (*p_seamcvpts) [knt*2+1][U] = isopar;
      (*p_seamcvpts) [knt*2+1][V] = v_par[1];
    }
  }

  p_segpar = (double *) alloca ((n_int + n_over * 2 + 2) * 2 * sizeof (double));
  OnErrorState (!p_segpar, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup); 

  cvpar_min = p_incv->knots[p_incv->order - 1];
  cvpar_max = p_incv->knots[p_incv->num_poles];
  cvpar_tol = pwGetParTolCv (p_incv, xyztol);

  get_split_segpars (n_int, n_over, p_par0, p_over0, cvpar_min, cvpar_max,
                     cvpar_tol, &n_seg, p_segpar);

  if (n_seg)
  {
    (*p_splitcvs) = (struct PWcvdata *) malloc (n_seg * 
                                        sizeof (struct PWcvdata));
    PWsts = PW_AllocBspCvStack (p_incv->num_poles + 2 * p_incv->order - 1, 
                                p_incv->order, p_incv->rational, partcv);

    *num_splitcvs = n_seg;
  }

  for (knt=0; knt<n_seg; knt++)
  {
    BSpartofcv (&BSmsg, p_incv, p_segpar[knt*2], 
                (p_segpar[knt*2] + p_segpar[knt*2+1]) / 2.0, p_segpar[knt*2+1],
                &partcv);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    BSnorkts (&BSmsg, &partcv.order, &partcv.num_poles, partcv.knots);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    if (p_xyzcv->datatype == PWcvdata_py)
    {
      (*p_splitcvs)[knt].datatype = PWcvdata_py;
      (*p_splitcvs)[knt].data.py.num_pts = partcv.num_poles;
      (*p_splitcvs)[knt].data.py.p_pts = (PWpoint *) 
          malloc (partcv.num_poles * sizeof (PWpoint));
      memcpy ((*p_splitcvs)[knt].data.py.p_pts, partcv.poles, 
              partcv.num_poles * sizeof (PWpoint));
    }
    else
    {
      (*p_splitcvs)[knt].datatype = PWcvdata_bspcv;
      BSalloccv (partcv.order, partcv.num_poles, partcv.rational, 0,
                 &(*p_splitcvs)[knt].data.p_bspcv, &BSmsg); 
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      BSsts = BScv_copy (&BSmsg, &partcv, (*p_splitcvs)[knt].data.p_bspcv);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
    }
  }
  
wrapup :

  PW_Wrapup (PWsts, "split_and_map_cv_on_seam_of_sf");
  return PWsts;
}

static void get_split_segpars
(
  int n_int,
  int n_over, 
  double *p_par,
  double *p_over,

  double minpar, 
  double maxpar, 
  double partol,

  int *n_seg,
  double *p_segpar  
)
{
  int loc_nseg=0, knt=0, i=0;
  BSrc BSmsg=BSSUCC;
  double *p_loc_segpar=NULL;
  PWboolean overlap=FALSE;

  p_loc_segpar = (double *) alloca ((n_int + n_over * 2 + 2) * sizeof (double));

  *n_seg = 0;

  if (n_int)
    memcpy (p_loc_segpar, p_par, n_int * sizeof (double));

  if (n_over)
    memcpy (&p_loc_segpar[n_int], p_over, n_over * 2 * sizeof (double));

  loc_nseg = n_int + n_over * 2;

  BSmergesort (p_loc_segpar, loc_nseg, &BSmsg);

  if ((p_loc_segpar[0] - minpar) > partol)
  {
    memmove (&p_loc_segpar[1], &p_loc_segpar[0], loc_nseg * sizeof (double));
    p_loc_segpar[0] = minpar;
    loc_nseg ++;
  }

  if ((maxpar - p_loc_segpar[loc_nseg-1]) > partol)
  {
    p_loc_segpar[loc_nseg] = maxpar;
    loc_nseg++;
  }

  if (loc_nseg == 2 && (p_loc_segpar[0] - minpar) < partol &&
      (maxpar - p_loc_segpar[1]) < partol)
    return;  

  for (knt=0; knt<loc_nseg-1; knt++)
  {
    overlap = FALSE;

    for (i=0; i<n_over; i++)
    {
      if (fabs (p_loc_segpar[knt] - p_over[i*2]) < partol) 
      {
        overlap = TRUE;
        break;
      }
    }

    if (!overlap)
    {
      p_segpar [(*n_seg) * 2] = p_loc_segpar[knt];
      p_segpar [(*n_seg) * 2+1] = p_loc_segpar[knt+1];
      (*n_seg) ++;
    }

  }

  return;
}

