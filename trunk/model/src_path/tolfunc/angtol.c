/*
  FILE DESCRIPTION

  Contains the functionality to handle angle tolerancing. An initialzed
  default of 0.05 degrees is set up and can be manipulated with the functions
  within this file. 

  This tolerance is to be used to check if two vectors have the same direction
  (as in a tangency check for 2 surfaces, etc). It is typically passed into
  the functions that perform the cross-products and dot-products and return an
  enumeration of how the vectors are directionally positioned with respect to
  each other. This tolerance is not to be used when distances are involved.
  Usually, normalized vectors are used for the purpose.
*/

#include <math.h>
#include "PWminimum.h"
#include "bsvalues.h"

static double curr_zeroangle_radians=0.05 * (M_PI / 180.0);
static double curr_cosine_zeroangle=MAXDOUBLE;
static double curr_sine_zeroangle=MAXDOUBLE;
static double curr_zeroangle_degrees=0.05;

/*
  DESCRIPTION
  
  These functions allow the user to get and set the zero-angle tolerance
  either in radians or degrees. Functions are also provided to return
  the corresponding cosine or the sine of this 'zeroangle'. The sine
  and the cosine cannot be set externally. Since the cosine and the sine
  are stored statically, these are returned without any computation overhead.
*/
double pwGetZeroAngTolDeg
(
)
{
  return (curr_zeroangle_degrees);
}

double pwGetZeroAngTolRad
(
)
{
  return (curr_zeroangle_radians);
}

void pwSetZeroAngTolDeg 
(
  double angtol
)
{
  curr_zeroangle_degrees = angtol;
  curr_zeroangle_radians = angtol * (M_PI / 180.0);
  curr_cosine_zeroangle = cos (curr_zeroangle_radians);
  curr_sine_zeroangle = sin (curr_zeroangle_radians);
  return;
}

void pwSetZeroAngTolRad 
(
  double angtol
)
{
  curr_zeroangle_radians = angtol;
  curr_zeroangle_degrees = angtol * (180.0 / M_PI);
  curr_cosine_zeroangle = cos (curr_zeroangle_radians);
  curr_sine_zeroangle = sin (curr_zeroangle_radians);
  return;
}

double pwGetCosZeroAngTol
(
)
{
  if (curr_cosine_zeroangle == MAXDOUBLE)
    curr_cosine_zeroangle = cos (curr_zeroangle_radians);
  return (curr_cosine_zeroangle);
}

double pwGetSinZeroAngTol
(
)
{
  if (curr_sine_zeroangle == MAXDOUBLE)
    curr_sine_zeroangle = sin (curr_zeroangle_radians);
  return (curr_sine_zeroangle);
}
