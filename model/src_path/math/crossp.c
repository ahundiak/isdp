#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"

/*
  DESCRIPTION

  The following functions perform a cross-product between the two given
  vectors (separate functions for 2d and 3d). They take in a distance 
  tolerance and use it to correctly enumerate whether the second vector (vec2)
  is to the left of or the right of or lies along the first vector (vec1).
  The orientation vector used in the 2d case is the 'Z' vector defined by
  a right-handed co-ordinate system. In the case of 3d, we still use the
  right-handed co-ordinate system and the direction vector ('Z' vector) in
  this case is constructed as (vec1 X vec2).

  An 'along' is returned of the tip of the second vector is within 'tol'
  of the line defined by the first vector. The exact algebraic value of
  the cross-product computation is returned too.

  The vectors should not be degenerate. If their magnitude is less than
  MINDOUBLE the direction is returned as 'unknonwn'.

  NOTES

  The 'left', 'right' and 'along' are defined with respect to a person
  standing aligned with the orientation vector and viewing down vec1. Note
  that 'along' simply means lying along the same LINE as defined by vec1
  (this could also mean that vec2 is opposed to vec1 but lies in the same
  line).
*/
#define TOL_ADJUST 1.111
enum PWdirtype pwCrossProd2d 
(
  PWvector2d vec1, 
  PWvector2d vec2,
  double tol, 
  double *val
)
{
  double crossp, mag_a, perp_dist;

  *val = crossp = vec1[X] * vec2[Y] - vec1[Y] * vec2[X];
  mag_a = sqrt (vec1[X] * vec1[X] + vec1[Y] * vec1[Y]);

  if (mag_a > MINDOUBLE)
  {
    perp_dist = fabs (crossp) / mag_a;
    if (perp_dist <= tol/TOL_ADJUST)
      return (PWdir_along);
    else if (crossp > 0)
          return (PWdir_left);
    else
       return (PWdir_right);
  } 
  else
  {
    printf("un_known\n");
    return (PWdir_unknown);
  }
}

/* ARGSUSED */
enum PWdirtype pwCrossProd 
(
  PWvector vec1,
  PWvector vec2,
  double tol,
  double *val
)
{
  /*  TBD  */
  return (PWdir_unknown);
}


/*
  DESCRIPTION

  The following functions perform a cross-product between the two given
  vectors (separate functions for 2d and 3d). They take in an angle tolerance,
  that is, the angle within which the two vectors are considered equal, and
  use it to correctly enumerate whether the second vector (vec2) lies along
  the first vector (vec1). The angle tolerance is input in radians. If vec1
  is found not lying along the vector, then it is classified as lying either
  to the left or to the right. The exact algebraic value of the cross-product
  computation is returned too.

  The orientation vector used in the 2d case is the 'Z' vector defined by
  a right-handed co-ordinate system. In the case of 3d, an orientation vector
  is input. If this input is NULL, then one is constructed as (vec1 X vec2).

  The vectors should not be degenerate. If their magnitude is less than
  MINDOUBLE the direction is returned as 'unknonwn'.


  NOTES

  The 'left', 'right' and 'along' are defined with respect to a person
  standing aligned with the orientation vector and viewing down vec1. Note
  that 'along' simply means lying along the same LINE as defined by vec1
  (this could also mean that vec2 is opposed to vec1 but lies in the same
  line).
*/

enum PWdirtype pwCrossProdAngTol2d 
(
  PWvector2d vec1,
  PWvector2d vec2,
  double atol,
  double *val
)
{
  double crossp, mag_ab, sinang, sinatol;
  
  *val = crossp = vec1[X] * vec2[Y] - vec1[Y] * vec2[X];
  mag_ab = sqrt (vec1[X] * vec1[X] + vec1[Y] * vec1[Y]) *
            sqrt (vec2[X] * vec2[X] + vec2[Y] * vec2[Y]);

  if (mag_ab > MINDOUBLE )
  {
    sinang = fabs (crossp) / mag_ab;

    sinatol = sin (atol);
    if (sinang <= sinatol)
      return (PWdir_along);
    else if (crossp > 0)
      return (PWdir_left);
    else
      return (PWdir_right);
  }
  else
  {
    return (PWdir_unknown);
  }
}

/* ARGSUSED */
enum PWdirtype pwCrossProdAngTol 
(
  PWvector vec1,
  PWvector vec2,
  double atol,
  double *val
)
{
  /*  TBD  */
  return (PWdir_unknown);
}

/*
  DESCRIPTION

  The following functions simply perform the cross-product and return the
  vector. No tolerancing is applied
*/

double pwCross2d
(
  PWvector2d v1,
  PWvector2d v2
)
{
  return v1[X] * v2[Y] - v1[Y] * v2[X];
}

void pwCross
(
  PWvector v1,
  PWvector v2,
  PWvector cv
)
{
  cv[X] = v1[Y] * v2[Z] - v1[Z] * v2[Y];
  cv[Y] = v1[Z] * v2[X] - v1[X] * v2[Z];
  cv[Z] = v1[X] * v2[Y] - v1[Y] * v2[X];

  return;
}

