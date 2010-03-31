#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "ma.h"
#include "bs.h"

#include "ma.h"
#include "maatan2.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/lenvec.h"
#include "PWapi/normvec.h"

/*
 * DESCRIPTION
 *
 * These functions returns the angle between vec1 and vec2, from vec1 to vec2, 
 * measured counter-clockwise in the plane of the two vectors. The vectors need 
 * passed in need not normalized. Two separate functions are provided to handle 
 * the 2d and the 3d case. In the case of 3d, ambiguity arises as to the viewing
 * direction of the plane to determine clockwise from counter-clockwise. In this
 * case, a view vector pointing towards the eye of the observer is also input. 
 * This view vector need not be exactly perpendicular to the plane, but must 
 * have a component in the correct perpendicular direction. If this view vector
 * is NULL, then the right-hand rule is used to obtain it (vec1 X vec2). The
 * view vector must be normalized.
 *
 * NOTES
 *
 * Angle is the TRUE angle between the input vectors and it varies between 0 to
 * 2*PI.
 *
 */

PWresult pwAngle2d
(
  PWvector2d  vec_a,
  PWvector2d  vec_b,
  double      *radians 
)
{
  BSrc    rc;
  double  len_a, len_b, a_dot_b, a_cross_b, sine, cosine;

  len_a = pwLenVec2d (vec_a);
  if (len_a < MINDOUBLE)
    return SetError (PW_K_PathwayMath, PW_K_Degenerate);

  len_b = pwLenVec2d (vec_b);
  if (len_b < MINDOUBLE)
    return SetError (PW_K_PathwayMath, PW_K_Degenerate);

  a_dot_b = pwDot2d (vec_a, vec_b);

  a_cross_b = pwCross2d (vec_a, vec_b);

  cosine = a_dot_b / (len_a * len_b);
  sine   = fabs(a_cross_b) / (len_a * len_b);

  if (a_cross_b < -MINDOUBLE) 
    sine = -sine;

  *radians = MAatan2 (&rc, &sine, &cosine);
  if (rc == MSFAIL)
    return SetError (PW_K_PathwayMath, PW_K_Internal);

  return PW_K_Success;
}

PWresult pwAngle
(
  PWvector  vec_a,
  PWvector  vec_b,
  PWvector  ndirvec,
  double    *radians
)
{
  BSrc     rc=MSSUCC;
  double   len_a, len_b, a_dot_b, sine, cosine, len_a_cross_b;
  PWvector a_cross_b;

  len_a = pwLenVec (vec_a);
  if (len_a < MINDOUBLE)
    return SetError (PW_K_PathwayMath, PW_K_Degenerate);

  len_b = pwLenVec (vec_b);
  if (len_b < MINDOUBLE)
    return SetError (PW_K_PathwayMath, PW_K_Degenerate);

  a_dot_b = pwDot (vec_a, vec_b);

  pwCross (vec_a, vec_b, a_cross_b);
  len_a_cross_b = pwLenVec (a_cross_b);

  cosine = a_dot_b / (len_a * len_b);
  sine   = len_a_cross_b / (len_a * len_b);

  pwNormVec (a_cross_b, a_cross_b);

  if (pwDot (a_cross_b, ndirvec) < 0.0)
  {
    sine = -sine;
  }

  *radians = MAatan2 (&rc, &sine, &cosine);
  if (rc == MSFAIL)
    return SetError (PW_K_PathwayMath, PW_K_Internal);

  return PW_K_Success;
}
