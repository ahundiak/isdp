#include "PWminimum.h"
#include "PWapi/revvec.h"

/*
  DESCRIPTION
 
  The following functions, reverses a given vector. Seperate functions
  are available for 2d and 3d. Input and output could be same.
*/

void pwRevVec2d
(
  PWvector2d vec,
  PWvector2d outvec
)
{
  outvec[X] = vec[X] * -1.0;
  outvec[Y] = vec[Y] * -1.0;
  return;
}

void pwRevVec
(
  PWvector vec,
  PWvector outvec
)
{
  outvec[X] = vec[X] * -1.0;
  outvec[Y] = vec[Y] * -1.0;
  outvec[Z] = vec[Z] * -1.0;
 
  return;
}
