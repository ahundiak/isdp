#include <math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "PWapi/posptgm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/degengm.h"
#include "PWapi/samepts.h"
#include "PWapi/partol.h"
#include "PWapi/ptpargm.h"


/* Internal Prototypes */

static enum PWtopopostype get_pos_pt_seg
(
  double par,
  double *pt1,
  double *pt2,
  PWboolean is_3d,
  double tol
);

static enum PWtopopostype get_pos_pt_py
(
  struct PWcvparam *par,
  int numpts,
  double *pts,
  PWboolean is_3d,
  double tol
);


/*
  DESCRIPTION

  Topological Position of Pt-on-Seg:
  This function takes in a parameter of a point on a given segment and
  zero-length tolerance and returns the topological position of this point
  with respect to the ends of the segment (PWtopopos_start, PWtopopos_stop
  or PWtopopos_middle). In the pathological case where the input tolerance
  is large and the start/stop/middle regions on the segment are ambiguous,
  the pos is indeterminate. In this situation, the function returns 
  PWtopopos_unknown. Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.

  
  NOTES

  If the par is out of range (outside [0,1]), then the position is returned
  as start or stop depending on which side of the range the par exists.
*/

enum PWtopopostype pwGetPosPtSg2d
(
  double par,
  PWpoint2d pt1, 
  PWpoint2d pt2,
  double tol
)
{
  return (get_pos_pt_seg (par, (double *) pt1, (double *) pt2, FALSE, tol));
}

enum PWtopopostype pwGetPosPtSg
(
  double par,
  PWpoint pt1, 
  PWpoint pt2,
  double tol
)
{
  return (get_pos_pt_seg (par, (double *) pt1, (double *) pt2, TRUE, tol));
}

static enum PWtopopostype get_pos_pt_seg
(
  double par,
  double *pt1,
  double *pt2,
  PWboolean is_3d,
  double tol
)
{
  double partol;
  enum PWtopopostype outpos;

  if (par < 0.0)
    outpos = PWtopopos_start;
  else if (par > 1.0)
    outpos = PWtopopos_stop;
  else
  {
    partol = tol / (is_3d ? pwDistPtPt (pt1, pt2) : pwDistPtPt2d (pt1, pt2));
    if (partol >= 0.5)
      outpos = PWtopopos_unknown;
    else if (par < partol)
      outpos = PWtopopos_start;
    else if (par < (1.0 - partol))
      outpos = PWtopopos_stop;
    else
      outpos = PWtopopos_middle;
  }

  return (outpos);
}


/*
  DESCRIPTION

  Topological Position of Pt-on-Py:
  This function takes in a parameter of a point on a given polyline and a
  zero-length tolerance and returns the topological position of this point
  with respect to the ends of the polyline (PWtopopos_start, PWtopopos_stop
  or PWtopopos_middle). Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.
*/

enum PWtopopostype pwGetPosPtPy2d
(
  struct PWcvparam *par,
  int numpts, 
  PWpoint2d *pts,
  double tol
)
{
  return (get_pos_pt_py (par, numpts, (double *) pts, FALSE, tol));
}

enum PWtopopostype pwGetPosPtPy
(
  struct PWcvparam *par,
  int numpts, 
  PWpoint *pts,
  double tol
)
{
  return (get_pos_pt_py (par, numpts, (double *) pts, TRUE, tol));
}

static enum PWtopopostype get_pos_pt_py
(
  struct PWcvparam *par, 
  int numpts,
  double *pts,
  PWboolean is_3d,
  double tol
)
{
  int dim, spaninx;
  double spanpar;
  enum PWtopopostype pos;

  spaninx = par->spaninx;
  spanpar = par->spanpar;
  dim = is_3d ? 3 : 2;

  /*
   * Start by checking the pos on the input span. If it is in the middle
   * we are done. If it is at the start, see if the polyline is degenerate
   * upto the start of this span; if not, the pos is 'start'. If it is at stop,
   * see if the polyline is degenerate from the stop of this span onwards;
   * if not, the pos is 'stop'. If it is an unknown pos we got, then we
   * have to check for degeneracy on either side of this span - if the 
   * start side is not degenerate, the pos is 'stop'and if the stop side
   * is not degenerate, the pos is 'start'.
   */

  pos = get_pos_pt_seg (spanpar, 
         (double *) &pts[dim*spaninx], (double *) &pts[dim*(spaninx+1)],
         is_3d, tol);
  if (pos != PWtopopos_middle)
  {
    if (pos == PWtopopos_start)
    {
      if (spaninx > 0 && 
          !(is_3d ? pwIsDegenPy (spaninx+1, (PWpoint *) pts, tol) : 
                    pwIsDegenPy2d (spaninx+1, (PWpoint2d *) pts, tol)))
      {
        pos = PWtopopos_middle;
      }
    }
    else if (pos == PWtopopos_stop)
    {
      if (spaninx < numpts-2 && 
          !(is_3d ? pwIsDegenPy (numpts-(spaninx+1), 
                     (PWpoint *) (pts+(dim*(spaninx+1))), tol) : 
                    pwIsDegenPy2d (numpts-(spaninx+1), 
                     (PWpoint2d *) (pts+(dim*(spaninx+1))), tol)))
      {
        pos = PWtopopos_middle;
      }
    }
    else
    {
      if (! (is_3d ? pwIsDegenPy (spaninx+1, (PWpoint *) pts, tol) : 
                     pwIsDegenPy2d (spaninx+1, (PWpoint2d *) pts, tol)))
      {
        pos = PWtopopos_stop; 
      }
      else if (! (is_3d ? pwIsDegenPy (numpts-(spaninx+1), 
                           (PWpoint *) (pts+(dim*(spaninx+1))), tol) : 
                          pwIsDegenPy2d (numpts-(spaninx+1), 
                           (PWpoint2d *) (pts+(dim*(spaninx+1))), tol)))
      {
        pos = PWtopopos_start;
      }
    }
  }

  return (pos);
}


/*
  ABSTRACT

  This function determines if a given curve parameter lies at the specified
  logical end of the curve data. The curve data passed in could be reversed
  with respect to the logical flow of the geometry. The point-to-point, zero
  length tolerance is passed in. The function returns a TRUE if the condition
  is satisifed. A closed curve is specially treated in that the end specified
  is insignificant. In the case of a closed curve the function returns TRUE if
  the input parameter is found to be close to either "end" of the curve.


  NOTES

  The tolerance being passed in is NOT the parametric tolerance of the curve.
  This function internally extracts the parametric tolerance, if necessary,
  to do the proximity checks.
*/

PWboolean pwIsParAtCvEnd
(
  struct PWcvparam *par,
  PWboolean at_stop_end,
  struct PWcvdata *cvdata,
  PWboolean cv_reverse,
  double lentol
)
{
  PWboolean is_at_end=FALSE;
  double partol, endpar;
  PWpoint endpt2d, parpt2d;
  PWpoint endpt, parpt;
  struct IGRbsp_curve *bspcv;

  switch (cvdata->datatype)
  {
    case PWcvdata_pt2d:
    case PWcvdata_py2d:
      pwPtAtParCvdata (cvdata, par, parpt2d);
      pwGetEndPtCvdata (cvdata, cv_reverse, at_stop_end, endpt2d);
      is_at_end = pwIsSamePt2d (endpt2d, parpt2d, lentol);
      break;

    case PWcvdata_pt:
    case PWcvdata_py:
      pwPtAtParCvdata (cvdata, par, parpt);
      pwGetEndPtCvdata (cvdata, cv_reverse, at_stop_end, endpt);
      is_at_end = pwIsSamePt (endpt, parpt, lentol);
      break;

    case PWcvdata_bspcv:
    case PWcvdata_gmbspcv:
      if (cvdata->datatype == PWcvdata_gmbspcv)
        bspcv = cvdata->data.p_gmbspcv->bspcv;
      else
        bspcv = cvdata->data.p_bspcv;
      partol = pwGetParTolCv (bspcv, lentol);

      if ((!at_stop_end && !cv_reverse) || (at_stop_end && cv_reverse))
        endpar = bspcv->knots[bspcv->order-1];
      else
        endpar = bspcv->knots[bspcv->num_poles];

      if (fabs (endpar - par->spanpar) < partol)
        is_at_end = TRUE;
      else if (bspcv->phy_closed)
      {
        if ((!at_stop_end && !cv_reverse) || (at_stop_end && cv_reverse))
          endpar = bspcv->knots[bspcv->num_poles];
        else
          endpar = bspcv->knots[bspcv->order-1];
  
        if (fabs (endpar - par->spanpar) < partol)
          is_at_end = TRUE;
      }
      break;
  }

  return (is_at_end);
}
