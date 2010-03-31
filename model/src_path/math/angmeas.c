#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"

#include "PWapi/dotp.h"

#define  sqr(x)  ((x) * (x))

/*
  DESCRIPTION
 
  These functions returns the angle measure from vec1 to vec2, measured
  counter-clockwise in the plane of the two vectors. The vectors must be
  passed in normalized. Two separate functions are provided to handle the
  2d and the 3d case. In the case of 3d, ambiguity arises as to the viewing
  direction of the plane to determine clockwise from counter-clockwise.
  In this case, a view vector pointing towards the eye of the observer is
  also input. This view vector need not be exactly perpendicular to the
  plane, but must have a component in the correct perpendicular direction.
  If this view vector is input as NULL, then the right-hand rule is used
  to obtain it (vec1 X vec2).

  
  NOTES

  Angle-measure is NOT the TRUE angle but a monotonically increasing value
  between 0 to 4 (mapping to 0 to 2*PI). This increase is non-linear (actually
  varies as the cosine). A value of 4 is never returned, instead
  0 is favored. The functions snap to perpendicular and collinear
  if the cosines (or the sines) of the included angles are within MINDOUBLE
  of 0 or 1.

  An angle measure of 0 (or 4) indicates the vectors were aligned pointing
  the same way. An angle measure of 1 indicates a 90-degree angle between
  them. Angle measure of 2 indicates collinear vectors but opposed.
  Angle measure of 3 indicates an angle of 270-degrees. Values vary
  monotonically in between and can be used to sort.

  Call the function pwAngleFromAngmeas to convert this angle measure
  to radians (0 to 2*PI) or to degress (0 to 360). What this function does
  is simply taking the cosine-inverse (or the sine-inverse) and manipulating
  it with PI (or 180).
*/

double pwAngmeas2d 
(
  PWvector2d nvec1, 
  PWvector2d nvec2
)
{
  PWboolean collinear, perpendicular;
  double dotp, crossp, angmeas;

  dotp = nvec1[X] * nvec2[X] + nvec1[Y] * nvec2[Y];
  if (fabs (dotp) <= MINDOUBLE)
    perpendicular = TRUE;
  else
    perpendicular = FALSE;

  crossp = nvec1[X] * nvec2[Y] - nvec1[Y] * nvec2[X];
  if (fabs (crossp) <= MINDOUBLE)
    collinear = TRUE;
  else  
    collinear = FALSE;

  if (collinear)
  {
    if (dotp > 0.0)
      angmeas = 0.0;
    else
      angmeas = 2.0;
  }
  else if (crossp > 0.0)
  {
    if (perpendicular)
      angmeas = 1.0;
    else
      angmeas = 1.0 - dotp;
  }
  else
  {
    if (perpendicular)
      angmeas = 3.0;
    else
      angmeas = 3.0 + dotp;
  }
  
  return (angmeas);
}

double pwAngmeas 
(
  PWvector nvec1, 
  PWvector nvec2,
  double *dirvec
)
{
  PWvector  crossvec;  
  PWboolean collinear, perpendicular;
  double    dotp, crossp, angmeas;

  dotp = pwDot (nvec1, nvec2);
  if (fabs (dotp) <= MINDOUBLE)
    perpendicular = TRUE;
  else
    perpendicular = FALSE;

  crossvec[X] = nvec1[Y] * nvec2[Z] - nvec1[Z] * nvec2[Y];
  crossvec[Y] = nvec1[Z] * nvec2[X] - nvec1[X] * nvec2[Z];
  crossvec[Z] = nvec1[X] * nvec2[Y] - nvec1[Y] * nvec2[X];

  crossp = sqrt (sqr (crossvec[X]) + sqr (crossvec[Y]) + sqr (crossvec[Z]));
  if (fabs (crossp) <= MINDOUBLE)
    collinear = TRUE;
  else
    collinear = FALSE;

  if (pwDot (crossvec, dirvec) < 0.0)
    crossp *= -1.0;

  if (collinear)
  {
    if (dotp > 0.0)
      angmeas = 0.0;
    else
     angmeas = 2.0;
  }
  else if (crossp > 0.0)
  {
    if (perpendicular)
      angmeas = 1.0;
    else
      angmeas = 1.0 - dotp;
  }
  else
  {
    if (perpendicular)
      angmeas = 3.0;
    else
      angmeas = 3.0 + dotp;
  }

  return (angmeas);
}

/*
  DESCRIPTION

  This function returns the angle (in radians) correspindig to an input
  angle-measure. The value of the angle returned could range from 0 to 2*PI.
  Angle-measures are assumed to be >= 0.0 and <= 4.0.
*/

double pwGetAngFromAngmeas 
(
  double angmeas
)
{
  double ang;

  if (fabs (angmeas) <= MINDOUBLE)
    ang = 0.0;
  else if (fabs (angmeas - 1.0) <= MINDOUBLE)
    ang = M_PI / 2.0;
  else if (fabs (angmeas - 2.0) <= MINDOUBLE)
    ang = M_PI;
  else if (fabs (angmeas - 3.0) <= MINDOUBLE)
    ang = M_PI * (3.0 / 2.0);
  else if (fabs (angmeas - 4.0) <= MINDOUBLE)
    ang = 2.0 * M_PI;
  else if (angmeas < 2.0)
    ang = acos (1.0 - angmeas);
  else
    ang = acos (angmeas - 3.0);

  return (ang);
}
