#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"

/*
  DESCRIPTION


  NOTES

*/

void pwMakeVec 
(
  PWpoint   frompt,
  PWpoint   topt,
  PWvector  vec
)
{
  vec[X] = topt[X] - frompt[X];
  vec[Y] = topt[Y] - frompt[Y];
  vec[Z] = topt[Z] - frompt[Z];
}

void pwMakeVec2d
(
  PWpoint2d   frompt,
  PWpoint2d   topt,
  PWvector2d  vec
)
{
  vec[X] = topt[X] - frompt[X];
  vec[Y] = topt[Y] - frompt[Y];
}


