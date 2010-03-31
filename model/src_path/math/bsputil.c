#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "PWminimum.h"

#include "PWapi/bsputil.h"

/*
  ABSTRACT

  Functions to unweight poles that define B-spline geometry. The 
  'unweighted_poles' and the 'poles' can point to the same memory location.
*/

static void unweight_poles
(
  int num_poles,
  double *poles,
  double *weights,
  double *unweighted_poles,
  PWboolean is_3d
);

void pwUnweightPoles 
(
  int num_poles,
  PWpoint *poles,
  double *weights,
  PWpoint *unweighted_poles
)
{
  unweight_poles (num_poles, (double *) poles, weights, 
   (double *) unweighted_poles, TRUE);
  return;
}

void pwUnweightPoles2d
(
  int num_poles,
  PWpoint2d *poles,
  double *weights,
  PWpoint2d *unweighted_poles
)
{
  unweight_poles (num_poles, (double *) poles, weights, 
   (double *) unweighted_poles, FALSE);
  return;
}

static void unweight_poles
(
  int num_poles,
  double *poles,
  double *weights,
  double *unweighted_poles,
  PWboolean is_3d
)
{
  int i, j, k, dim;

  dim = is_3d ? 3 : 2;
  for (i=0, j=0; i<num_poles; i++, j+=dim)
    for (k=0; k<dim; k++)
      unweighted_poles[j+k] = poles[j+k] / (weights ? weights[i] : 1.0); 

  return;
}
