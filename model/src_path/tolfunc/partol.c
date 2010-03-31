#include "PWminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bscvkttol2.h"
#include "bssfkttol2.h"

/*
  DESCRIPTION
 
  This function returns the tolerance in the u-space of the input curve.
  The u-tol being returned is a map of the input xyztol, ie, it's equivalent
  in the parametric space of the curve. 
*/
double pwGetParTolCv 
(
  struct IGRbsp_curve *cv,
  double xyztol
)
{
  long rc;
  double curr_bastol, knot_tol, partol;

  BScvkttol2 (cv->order, cv->knots, cv->num_poles, cv->poles, 
   cv->rational ? cv->weights : NULL, &knot_tol, &rc);

  BSEXTRACTPAR (&rc, BSTOLLENVEC, curr_bastol);
  partol = knot_tol * (xyztol / curr_bastol);

  return (partol);
}

/*
  DESCRIPTION
 
  This function returns the tolerance in the uv-space of the input surface.
  The uv-tol being returned is a map of the input xyztol, ie, it's equivalent
  in the parametric space of the surface.
*/
double pwGetParTolSf 
(
  struct IGRbsp_surface *sf,
  double xyztol
)
{
  long rc;
  double curr_bastol, knot_tol, partol;

  BSsfkttol2 (sf->u_order, sf->v_order, sf->u_knots, sf->v_knots,
   sf->u_num_poles, sf->v_num_poles, sf->poles, 
   sf->rational ? sf->weights : NULL, &knot_tol, &rc);

  BSEXTRACTPAR (&rc, BSTOLLENVEC, curr_bastol);
  partol = knot_tol * (xyztol / curr_bastol);

  return (partol);
}


