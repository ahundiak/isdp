/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
  DESCRIPTION
   
    Given the extents of a 2D-rectangle and a point that lies on it,
    this function determines if alternate point(s) exist depending on
    which of the side-pairs are to be treated as topologically closed.
    U-direction goes left-to-right and V-direction goes bottom-to-top.

    There can be a maximum of two alternate points. This, when closure
    exists in both U and V and the point lies at one of the corners.
*/

#include "igrtypedef.h"

#define U 0
#define V 1

IGRint EM2dtpyaltpt (u_low, u_high, v_low, v_high, u_closed, v_closed,
                     lentol, inpt, outpts)
IGRdouble u_low, u_high, v_low, v_high;
IGRboolean u_closed, v_closed;
IGRdouble lentol, *inpt, *outpts;
{
  IGRint numpts;

  numpts = 0;
  if (inpt[U] < u_low+lentol && u_closed)
    {
    *outpts++ = u_high;
    *outpts++ = inpt[V];
    numpts++;
    }
  if (inpt[V] < v_low+lentol && v_closed)
    {
    *outpts++ = inpt[U];
    *outpts++ = v_high;
    numpts++;
    }
  if (numpts < 2 && inpt[V] > v_high-lentol && v_closed)
    {
    *outpts++ = inpt[U];
    *outpts++ = v_low;
    numpts++;
    }
  if (numpts < 2 && inpt[U] > u_high-lentol && u_closed)
    {
    *outpts++ = u_low;
    *outpts++ = inpt[V];
    numpts++;
    }

  return (numpts);
}
