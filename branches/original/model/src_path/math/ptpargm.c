/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *    This file contains all the utility functions which does the conversion
 *    between the parametric space and cartesian space and also the functions
 *    to evaluate the tangent vectors at the given parameter values.
 *
 * NOTES
 *
 */

/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "bsvalues.h"                 /* Standard C library Includes */
#include "igrtypedef.h"
#include "igr.h"        /* BS Include Stuff */
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"                /* PATHWAY Include Stuff */
#include "PWerror.h"                

/* Prototypes */

#include "bscveval.h"
#include "bsmdstptcv.h"             /* BS */
#include "mabcendpts.h"

#include "PWapi/mkvec.h"
#include "PWapi/memfunc.h"          /* PATHWAY */
#include "PWapi/mdstptgm.h"
#include "PWapi/revvec.h"
#include "PWapi/rngbx.h"

/* Internal Prototypes */

static PWresult get_pt_at_par_py
(
  int               numpts,
  double            *p_pts,
  struct PWcvparam  *p_par,
  PWboolean         is_3d,
  double            *pt
);

static PWresult get_poly_tangent
(
  int              num_pts,
  double           *p_pts,
  int              spaninx,
  PWboolean        reverse,
  PWboolean        is_3d,
  double           *tangent
);


/*
 * DESCRIPTION 
 *
 *    Given a curve and the parameter, the following retuns determines the 
 *    point at the given parameter value. There are seperate routines for
 *    poly line, B-spline curves and the general curve data structure.
 */

/* ------------------------------------------------------------------------- */
/*                              Poly Line                                    */
/* ------------------------------------------------------------------------- */
PWresult pwPtAtParPy2d
(
  int               numpts,
  PWpoint2d         *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
)
{
  return get_pt_at_par_py (numpts, (double *) p_pts, p_par, FALSE, pt);
}

PWresult pwPtAtParPy
(
  int               numpts,
  PWpoint           *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
)
{
  return get_pt_at_par_py (numpts, (double *) p_pts, p_par, TRUE, pt);
}

static PWresult get_pt_at_par_py
(
  int               numpts,
  double            *p_pts,
  struct PWcvparam  *p_par, 
  PWboolean         is_3d,
  double            *pt
)
{
  int       inx;
  PWvector  vec;

  /* validate the incoming arguments */
  if (!p_pts || !p_par || !pt || p_par->spaninx < 0 || 
      p_par->spaninx > (numpts-1) || p_par->spanpar < 0.0 ||
      p_par->spanpar > 1.0) 
    return SetError (PW_K_PathwayMath, PW_K_InvalidArg);


  if (is_3d)
    pwMakeVec (&p_pts[p_par->spaninx * 3], &p_pts[(p_par->spaninx+1) * 3],
               vec);
  else
    pwMakeVec2d (&p_pts[p_par->spaninx * 2], &p_pts[(p_par->spaninx+1) * 2],
                 vec);

  inx = (is_3d) ? 3 : 2;

  pt[X] = p_pts[p_par->spaninx * inx + X] + p_par->spanpar * vec[X]; 
  pt[Y] = p_pts[p_par->spaninx * inx + Y] + p_par->spanpar * vec[Y]; 
  if (is_3d)
    pt[Z] = p_pts[p_par->spaninx * inx + Z] + p_par->spanpar * vec[Z]; 

  return PW_K_Success;
 
}

/* ------------------------------------------------------------------------- */
/*                          B-spline curve                                   */
/* ------------------------------------------------------------------------- */

PWresult pwPtAtParCv
(
  struct IGRbsp_curve  *p_bspcv,
  double               par,
  double               *p_pt
)
{
  BSrc  rc;

  (void) BScveval (p_bspcv, par, 0, (IGRpoint *)&p_pt[0], &rc);
  if (rc) 
    return SetError (PW_K_PathwayMath, PW_K_InvalidArg);
  else
    return PW_K_Success;
}

/* ------------------------------------------------------------------------- */
/*                             Curve Data Structure                          */
/* ------------------------------------------------------------------------- */

PWresult pwPtAtParCvdata
(
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_par,
  double            *p_pt
)
{
  /*
   * Validate the incoming arguments 
   */
  if (!p_cvdata || p_cvdata->datatype == PWcvdata_null || !p_par || !p_pt)
    return (SetError (PW_K_PathwayMath, PW_K_InvalidArg));

  /*
   * Evaluate the point 
   */
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
      memcpy (p_pt, p_cvdata->data.pt2d, sizeof(PWpoint2d));
      break;

    case PWcvdata_pt :
      memcpy (p_pt, p_cvdata->data.pt, sizeof(PWpoint));
      break;

    case PWcvdata_py2d : 
      return pwPtAtParPy2d (p_cvdata->data.py2d.num_pts, 
                            p_cvdata->data.py2d.p_pts, p_par, p_pt);

    case PWcvdata_py :
      return pwPtAtParPy (p_cvdata->data.py.num_pts, 
                          p_cvdata->data.py.p_pts, p_par, p_pt);

    case PWcvdata_bspcv : 
    case PWcvdata_gmbspcv :
    { 
      BSrc   BSmsg=BSSUCC;
      struct IGRbsp_curve *p_cv=NULL;

      p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
                                              p_cvdata->data.p_gmbspcv->bspcv;

      (void) BScveval (p_cv, p_par->spanpar, 0, (IGRpoint *)&p_pt[0], &BSmsg);
      if (BSERROR(BSmsg))
        return SetError (PW_K_PathwayMath, PW_K_Internal);
    }
    break; 
  }

  return PW_K_Success;
}


/*
 * DESCRIPTION
 *
 *    Given a curve and the parameter info, the following returns the tangent
 *    to the curve. Seperate routines are available for poly lines, B-spline 
 *    curves and the general curve data structure.
 */

/* ------------------------------------------------------------------------- */
/*                              Poly Line                                    */
/* ------------------------------------------------------------------------- */

PWresult pwGetTangentPy2d
(
  struct PWpoly2d  *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector2d       tangent
)
{
  return get_poly_tangent (p_py->num_pts, (double *) p_py->p_pts, spaninx, 
                           reverse, FALSE, tangent); 
}

PWresult pwGetTangentPy
(
  struct PWpoly    *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector         tangent
)
{  
  return get_poly_tangent (p_py->num_pts, (double *) p_py->p_pts, spaninx, 
                           reverse, TRUE, tangent); 
}

static PWresult get_poly_tangent
(
  int              num_pts,
  double           *p_pts,
  int              spaninx,
  PWboolean        reverse,
  PWboolean        is_3d,
  double           *tangent         
)
{
  PWresult  PWsts=PW_K_Success;

  if (spaninx > num_pts - 2)
    return SetError (PW_K_PathwayMath, PW_K_InvalidArg);

  if (is_3d)
  {
    pwMakeVec (&p_pts[spaninx*3], &p_pts[(spaninx + 1)*3], tangent);
    if (reverse) pwRevVec (tangent, tangent);
  }
  else
  {
    pwMakeVec2d (&p_pts[spaninx*2], &p_pts[(spaninx + 1)*2], tangent);
    if (reverse) pwRevVec2d (tangent, tangent);
  }

  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                          B-spline curve                                   */
/* ------------------------------------------------------------------------- */

PWresult pwGetTangentCv
(
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse,
  PWvector             tangent
)
{
  PWresult  PWsts=PW_K_Success;
  BSrc      BSmsg;
  PWpoint   points[2];

  BScveval (p_cv, par, 1, points, &BSmsg);
  if (BSERROR(BSmsg))
    return SetError (PW_K_PathwayMath, PW_K_Internal);

  memcpy (tangent, points[1], sizeof (PWpoint));

  if (reverse)
    pwRevVec (tangent, tangent);

  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                             Curve Data Structure                          */
/* ------------------------------------------------------------------------- */

PWresult pwGetTangentCvdata 
(
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar,
  PWboolean        reverse,
  double           *p_tangent
)
{
  /*
   * Validate the incoming arguments
   */
  if (!p_cvdata || !p_cvpar || !p_tangent)
    return (SetError (PW_K_PathwayMath, PW_K_InvalidArg));

  /*
   * Evaluate the point
   */
  switch (p_cvdata->datatype)
  {
    case PWcvdata_py2d :
      return pwGetTangentPy2d (&p_cvdata->data.py2d, p_cvpar->spaninx,
                               reverse, p_tangent);

    case PWcvdata_py :
      return pwGetTangentPy (&p_cvdata->data.py, p_cvpar->spaninx,
                               reverse, p_tangent);

    case PWcvdata_bspcv :
    case PWcvdata_gmbspcv :
    {
      BSrc    BSmsg=BSSUCC;
      struct  IGRbsp_curve *p_cv=NULL;
      PWpoint tmppt[2];

      p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
                                              p_cvdata->data.p_gmbspcv->bspcv;

      (void) BScveval (p_cv, p_cvpar->spanpar, 1, tmppt, &BSmsg);
      if (BSERROR(BSmsg))
        return SetError (PW_K_PathwayMath, PW_K_Internal);

      memcpy (p_tangent, tmppt[1], sizeof (PWpoint));

      if (reverse) pwRevVec (p_tangent, p_tangent);
    }
    return PW_K_Success;

    default :
      return SetError (PW_K_PathwayMath, PW_K_InvalidArg);
  }
}


/*
  DESCRIPTION
 
    Given the curve data and a point on the curve this function calculates
    the parameter at the given point. The input must lie with in the input
    tolerance 'tol'.

  NOTES 

    All the memory for the output must be allocated by the caller depending
    on the data type (2D or 3D).
*/

PWresult pwParAtPtCvdata
(
  struct PWcvdata  *p_cvdata,
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  double           tol,         /* The input must be lying on the input geom
                                   with in this tolerance */
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_cvpar
)
{
  PWresult  PWsts=PW_K_Success;

  /*
   * Validate the incoming arguments
   */
  if (!p_cvdata || !p_pt || !p_cvpar)
    return (SetError (PW_K_PathwayMath, PW_K_InvalidArg));

  /*
   * Evaluate the point
   */
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
    {
      if (pwDistPtPt2d (p_pt, p_cvdata->data.pt2d) > tol)
        OnErrorState (TRUE, PWsts, SetError (PW_K_PathwayMath, PW_K_Bounds), 
                      wrapup);
      memcpy (p_minpt, p_cvdata->data.pt2d, sizeof (PWpoint2d));
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = 0.0;
    }
    break;
   
    case PWcvdata_pt :
    {
      if (pwDistPtPt (p_pt, p_cvdata->data.pt) > tol)
        OnErrorState (TRUE, PWsts, SetError (PW_K_PathwayMath, PW_K_Bounds),
                      wrapup);
      memcpy (p_minpt, p_cvdata->data.pt, sizeof (PWpoint));
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = 0.0;
    }
    break;
 
    case PWcvdata_py2d :
    {
      PWsts = pwProjPtRngPy2d (p_pt, p_cvdata->data.py2d.num_pts, 
                               p_cvdata->data.py2d.p_pts, tol, p_minpt, 
                               p_cvpar);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }    
    break;

    case PWcvdata_py :
    {
      PWsts = pwProjPtRngPy (p_pt, p_cvdata->data.py.num_pts,
                             p_cvdata->data.py.p_pts, tol, p_minpt,
                             p_cvpar);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }
    break;

    case PWcvdata_bspcv :
    case PWcvdata_gmbspcv :
    {
      BSrc   rc=BSSUCC;
      struct IGRbsp_curve *p_cv=NULL;
      double mdist=0.0;

      p_cvpar->spaninx = 0;

      p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
                                              p_cvdata->data.p_gmbspcv->bspcv;
      
      BSmdstptcv (p_cv, p_pt, &p_cvpar->spanpar, p_minpt, &mdist, &rc);
      OnErrorState (rc, PWsts, SetError (PW_K_BspMath, PW_K_Internal), wrapup);
      OnErrorState ((mdist > tol), PWsts, 
                    SetError (PW_K_PathwayMath, PW_K_Internal), wrapup);

    }
    break;
  
    default :
      OnErrorState (TRUE, PWsts, SetError (PW_K_PathwayMath, PW_K_Internal), 
                    wrapup);
  }

wrapup : 
  
  return PWsts; 
}

/*
  DESCRIPTION

    The following function works on curve data structure. Given the curve 
    data this function extracts the start or stop point of the curve. 
    
  NOTES

    Output memory is allocated by the caller. One thing worth noting here is
    some times it requires 2 doubles and some times it is 3 doubles depending
    on whether the curve data is 2D or 3D.
*/

void pwGetEndPtCvdata
(
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean	  stop_end,
  double          *p_pt
)
{
  int npts;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d : 
      memcpy (p_pt, p_cvdata->data.pt2d, sizeof (PWpoint2d));
      break;

    case PWcvdata_pt : 
      memcpy (p_pt, p_cvdata->data.pt, sizeof (PWpoint));
      break;

    case PWcvdata_py2d : 
      npts = p_cvdata->data.py2d.num_pts;
      if ((stop_end && !reversed) || (!stop_end && reversed))
        memcpy (p_pt, p_cvdata->data.py2d.p_pts[npts-1], sizeof(PWpoint2d));
      else
        memcpy (p_pt, p_cvdata->data.py2d.p_pts[0], sizeof (PWpoint2d));
      break;
  
    case PWcvdata_py : 
      npts = p_cvdata->data.py.num_pts;
      if ((stop_end && !reversed) || (!stop_end && reversed))
        memcpy (p_pt, p_cvdata->data.py.p_pts[npts-1], sizeof(PWpoint));
      else
        memcpy (p_pt, p_cvdata->data.py.p_pts[0], sizeof (PWpoint));
      break;
 
    case PWcvdata_bspcv : 
    {
      BSrc    BSmsg=BSSUCC;
      PWpoint start, stop;

      MAbcendpts (&BSmsg, p_cvdata->data.p_bspcv, start, stop);
      if ((stop_end && !reversed) || (!stop_end && reversed))
        memcpy (p_pt, stop, sizeof (PWpoint));
      else 
        memcpy (p_pt, start, sizeof (PWpoint));
    }
    break;
  
    case PWcvdata_gmbspcv : 
    {
      BSrc    BSmsg=BSSUCC;
      PWpoint start, stop;

      MAbcendpts (&BSmsg, p_cvdata->data.p_gmbspcv->bspcv, start, stop);
      if ((stop_end && !reversed) || (!stop_end && reversed))
        memcpy (p_pt, stop, sizeof (PWpoint));
      else
        memcpy (p_pt, start, sizeof (PWpoint));
    }
    break;

    default :
      break;
  }

  return;
}


/*
  DESCRIPTION

    The following function works on curve data structure. Given the curve 
    data this function extracts the start and stop point of the curve. 
    
  NOTES

    Output memory is allocated by the caller. One thing worth noting here is
    some times it requires 2 X 2 doubles and some times it is 2 X 3 doubles 
    depending on whether the curve data is 2D or 3D.
*/

void pwGetEndPtsCvdata
(
  struct PWcvdata *p_cvdata,
  double          *p_startpt,
  double          *p_endpt
)
{
  int npts;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d : 
      memcpy (p_startpt, p_cvdata->data.pt2d, sizeof (PWpoint2d));
      memcpy (p_endpt, p_cvdata->data.pt2d, sizeof (PWpoint2d));
      break;

    case PWcvdata_pt : 
      memcpy (p_startpt, p_cvdata->data.pt, sizeof (PWpoint));
      memcpy (p_endpt, p_cvdata->data.pt, sizeof (PWpoint));
      break;

    case PWcvdata_py2d : 
      npts = p_cvdata->data.py2d.num_pts;
      memcpy (p_startpt, p_cvdata->data.py2d.p_pts[0], sizeof (PWpoint2d));
      memcpy (p_endpt, p_cvdata->data.py2d.p_pts[npts-1], sizeof(PWpoint2d));
      break;
  
    case PWcvdata_py : 
      npts = p_cvdata->data.py.num_pts;
      memcpy (p_startpt, p_cvdata->data.py.p_pts[0], sizeof (PWpoint));
      memcpy (p_endpt, p_cvdata->data.py.p_pts[npts-1], sizeof(PWpoint));
      break;
 
    case PWcvdata_bspcv : 
    {
      BSrc    BSmsg=BSSUCC;

      MAbcendpts (&BSmsg, p_cvdata->data.p_bspcv, p_startpt, p_endpt);
    }
    break;
  
    case PWcvdata_gmbspcv : 
    {
      BSrc    BSmsg=BSSUCC;

      MAbcendpts (&BSmsg, p_cvdata->data.p_gmbspcv->bspcv, 
                  p_startpt, p_endpt);
    }
    break;

    default :
      break;
  }

  return;
}

/*
  DESCRIPTION

    The following function works on curve data structure. Given the curve
    data this function extracts the start or stop curve parameter of the
    curve.

  NOTES

    All the memory for the output must be allocated by the caller.
*/

void pwGetEndCvparCvdata
(
  struct PWcvdata *p_cvdata,
  PWboolean reversed,
  PWboolean stop_end,
  struct PWcvparam *p_cvpar
)
{
  PWboolean is_start=FALSE;

  is_start = ((stop_end && !reversed) || (!stop_end && reversed)) ? 
                                                      FALSE : TRUE;
  if (is_start)
    pwGetMinParCvdata (p_cvdata, p_cvpar);
  else
    pwGetMaxParCvdata (p_cvdata, p_cvpar);
}

/*
  DESCRIPTION

    The following function works on curve data structure. Given the curve
    data this function extracts the start or stop curve point of the curve.

  NOTES

    All the memory for the output must be allocated by the caller. Reversed
    bit is related to the geometry and stop_end is topological.
*/

void pwGetEndCvptCvdata
(
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean       stop_end,
  struct PWcvpt   *p_cvpt
)
{
  if (stop_end)
    pwSetTopoposCvpt (p_cvpt, PWtopopos_stop);
  else
    pwSetTopoposCvpt (p_cvpt, PWtopopos_start);

  memset (p_cvpt->pt, 0, sizeof (PWpoint));
  pwGetEndPtCvdata (p_cvdata, reversed, stop_end, p_cvpt->pt);
  pwGetEndCvparCvdata (p_cvdata, reversed, stop_end, &p_cvpt->cvparam);
}

