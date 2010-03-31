#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"

/*
  DESCRIPTION

  Functions that normalize 2d and 3d vectors (vec) and return it as output
  (nvec). If the input vectors have a magnitude less than or equal to MINDOUBLE
  the function returns an error code indicating failure due to degeneracy.
  The input and output argument can be the same.
*/

PWresult pwNormVec2d 
(
  PWvector2d vec,
  PWvector2d nvec
)
{
  double mag;
  PWresult result=PW_K_Success;

  mag = sqrt (vec[X] * vec[X] + vec[Y] * vec[Y]);
  if (mag > MINDOUBLE)
  {
    nvec[X] = vec[X]/mag;
    nvec[Y] = vec[Y]/mag;
  }
  else
  {
    result = SetError(PW_K_PathwayMath, PW_K_Degenerate);
  }

  return (result);
}

PWresult pwNormVec 
(
  PWvector vec,
  PWvector nvec
)
{
  double mag;
  PWresult result=PW_K_Success;

  mag = sqrt (vec[X] *vec[X] + vec[Y] * vec[Y] + vec[Z] * vec[Z]);
  if (mag > MINDOUBLE)
  {
    nvec[X] = vec[X]/mag;
    nvec[Y] = vec[Y]/mag;
    nvec[Z] = vec[Z]/mag;
  }
  else
  {
    result = SetError(PW_K_PathwayMath, PW_K_Degenerate);
  }

  return (result);
}
