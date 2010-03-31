#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"

#include "PWapi/dotp.h"
#include "PWapi/lenvec.h"

/*
  DESCRIPTION

  The following functions perform a dot-product between the two given
  vectors (separate functions for 2d and 3d). They take in a distance 
  tolerance and use it to correctly enumerate whether the second vector (v2)
  is aligned with, normal to, anit-aligned (opposed to) with, or simply
  pointing in the same general direction or pointing in the opposite direction
  of the first vector (v1).

  A 'normal' is returned if the projection of the second vector onto the first
  is less than tol. An aligned (or anti-aligned) is returned when the
  projection is the same size as input second vector (within tolerance).
  The exact algebraic value of the dot-product computation is returned too.

  The vectors should not be degenerate. If their magnitude is less than
  MINDOUBLE the relative enumeration is returned as 'unknonwn'.
*/

enum PWrelvectype pwDotLenTol2d 
(
  PWvector2d v1,
  PWvector2d v2,
  double tol,
  double *val
)
{
  double dotp, mag_a, proj_dist;

  *val = dotp = v1[X] * v2[X] + v1[Y] * v2[Y];
  mag_a = pwLenVec2d (v1);

  if (mag_a > MINDOUBLE)
  {
    proj_dist = fabs (dotp) / mag_a;

    if (proj_dist <= tol)
      return (PWrelvec_normal);
    else if (fabs (proj_dist - pwLenVec2d (v2)) <= tol)
      return (dotp > 0.0 ? PWrelvec_aligned : PWrelvec_anti_aligned);
    else if (dotp > 0)
      return (PWrelvec_fwd_pointing);
    else
      return (PWrelvec_bwd_pointing);
  }
  else
  {
    return (PWrelvec_unknown);
  }
}

enum PWrelvectype pwDotLenTol 
(
  PWvector v1,
  PWvector v2,
  double tol,
  double *val
)
{
  double dotp=0, len_v1=0, proj_dist=0;

  *val = dotp =  pwDot (v1, v2);
  len_v1 = pwLenVec (v1);

  if (len_v1 > MINDOUBLE)
  {
    proj_dist = fabs (dotp) / len_v1;

    if (proj_dist <= tol)
      return (enum PWrelvectype) PWrelvec_normal;
    else if (fabs (proj_dist - pwLenVec (v2)) <= tol)
      return (dotp > 0.0 ? PWrelvec_aligned : PWrelvec_anti_aligned);
    else if (dotp > 0.0)
      return (enum PWrelvectype) PWrelvec_fwd_pointing;
    else
      return (enum PWrelvectype) PWrelvec_bwd_pointing;
  }
  else
  {
    return (enum PWrelvectype) PWrelvec_unknown;
  }
}


/*
  DESCRIPTION
  
  The following functions simply perform the dot-product and return the
  result. No tolerancing is applied
*/

double pwDot2d
(
  PWvector2d v1,
  PWvector2d v2
)
{
  return (v1[X] * v2[X] + v1[Y] * v2[Y]);
}

double pwDot
(
  PWvector v1,
  PWvector v2
)
{
  return (v1[X] * v2[X] + v1[Y] * v2[Y] + v1[Z] * v2[Z]);
}
