#include <math.h>
#include "PWminimum.h"

/*
  DESCRIPTION

  These functions perform the test for two points being within a given 
  tolerance. A trivial rejection is attempted before computing the square-root.
  There is a 2d and a 3d version of the function.
*/

PWboolean pwIsSamePt2d 
(
  PWpoint2d pt1,
  PWpoint2d pt2,
  double tol
)
{
  double delx, dely;

  if (fabs (delx = pt1[X] - pt2[X]) > tol)
    return (FALSE);
  if (fabs (dely = pt1[Y] - pt2[Y]) > tol)
    return (FALSE);
  if (delx*delx + dely*dely > tol*tol)
    return (FALSE);
  else
    return (TRUE);
}

PWboolean pwIsSamePt 
(
  PWpoint pt1,
  PWpoint pt2,
  double tol
)
{
  double delx, dely, delz;

  if (fabs (delx = pt1[X] - pt2[X]) > tol)
    return (FALSE);
  if (fabs (dely = pt1[Y] - pt2[Y]) > tol)
    return (FALSE);
  if (fabs (delz = pt1[Z] - pt2[Z]) > tol)
    return (FALSE);
  if (delx*delx + dely*dely + delz*delz > tol*tol)
    return (FALSE);
  else
    return (TRUE);
}
