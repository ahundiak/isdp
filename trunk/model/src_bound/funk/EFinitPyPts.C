/* ###################   APOGEE COMPILED   ################## */
# include "EMS.h"
# include "OMminimum.h"     /* EMSpypoint   */
# include "igrtypedef.h"    /* EMSpypoint   */
# include "igetypedef.h"    /* EMSpypoint   */
# include "igr.h"           /* EMSpypoint   */
# include "gr.h"            /* EMSpypoint   */
# include "emsdattyp.h"     /* EMSpypoint   */
# include "emsdef.h"

/*
Abstract

    This function initializes a list or array of EMSpypoints for
    the boundary trim operation in order to minimize allocations.

Notes

    The elements sould either be 1) linked or 2) in a contiguous array
    having set all next pointers to NULL.

History

    AIC     01 August 87        Creation Date
    AIC     02 September 87     Allow for a pre-linked list.
*/

void EFinitPyPoints(py_points, number)

# define UNDEFINED -1;

struct EMSpypoint   *py_points;
IGRint              number;

{
  IGRint    i;
  struct EMSpypoint     *pypt;
  struct EMSpypoint     *last_valid_address, *next_address;

  last_valid_address = py_points + (number-1);
  pypt = py_points;
  for(i = 1; i < number; i ++)
  {
    if(! pypt->next) 
    {
      next_address = pypt + 1;
      if (next_address <= last_valid_address)
        pypt->next = pypt + 1;
      else
        break;
    }
    pypt->span_inx = UNDEFINED;
    pypt->info = NULL;
    pypt->props = EMS_PYPT_EMPTY;
    pypt = pypt->next;
  }
  pypt->next = NULL;
  pypt->span_inx = UNDEFINED;
  pypt->info = NULL;
  pypt->props = EMS_PYPT_EMPTY;
  return;
}
