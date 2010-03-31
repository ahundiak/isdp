/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
#include "igrtypedef.h"

void EM2dpyarea (num_points, points, area)
IGRint num_points;
IGRdouble *points, *area;
{
  IGRint i, j, lim;
  IGRdouble sum;

  lim = (num_points-1)*2;
  sum = 0.0;
  for (i=0, j=2; i<lim; i+=2, j+=2)
    sum += (points[i] * points[j+1] - points[i+1] * points[j]);
  *area = -(sum / 2);

  return;  
}

