/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

# include "igrtypedef.h"
# include "igr.h"

# define ZERO   0.0
# define ONE    1.0

void EFknotVector(order, num_poles, knot_vector)

IGRshort    order;
IGRlong     num_poles;
IGRdouble   *knot_vector;
/*
Abstract

    This function fills out a uniform, normalized knot vector.

Arguments

    order - input
        The order for which the knot vector is required.

    num_poles - input
        The number of poles for which the knot vector is required.

    knot_vector - output
        The knot vector.

Notes

    The knot_vector array must have order + num_poles elements.

History

    10 Mar 88   AIC     Creation Date.
*/
{
  IGRint        i;
  IGRdouble     *knot_ptr;
  IGRdouble     knot_increment, knot = ZERO;

  knot_ptr = knot_vector;
  for (i = 0; i < order; i ++) *knot_ptr ++ = ZERO;

  knot_increment = ONE / (num_poles - order + 1);
  for(i = order; i < num_poles; i++)
  {
    knot += knot_increment;
    *knot_ptr ++ = knot;
  }

  for(i = 0; i < order; i++) *knot_ptr ++ = ONE;
}
