/* --------------------                                   ------------------ *
 * FOR Project PATHWAY                                                       *
 *                                                        Sanjay  : Creation *
 * --------------------                                   ------------------ */

/*
 * OVERVIEW
 *   
 *     The functions available in this file, finds the magnitudes of the 
 *     vectors. Seperate functions are available for 2d and 3d.
 *
 * NOTES
 */

#include <stdio.h>
#include <alloca.h>
#include <math.h>

#include "PWminimum.h"
#include "PWerror.h"


double pwLenVec2d 
(
  PWvector2d vec
)
{
  return sqrt (vec[X] * vec[X] + vec[Y] * vec[Y]); 
}

double pwLenVec
(
  PWvector vec
)
{
  return sqrt (vec[X] * vec[X] + vec[Y] * vec[Y] + vec[Z] * vec[Z]);
}

double pwLenSqVec2d
(
  PWvector2d vec
)
{
  return (vec[X] * vec[X] + vec[Y] * vec[Y]);
}

double pwLenSqVec
(
  PWvector vec
)
{
  return (vec[X] * vec[X] + vec[Y] * vec[Y] + vec[Z] * vec[Z]);
}

