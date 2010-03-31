/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  Given an IGRpolyline, this function reverses the order
  of the first "num" points of the list, in place. If "num" is NULL,
  the entire set of points is reversed. The dimension of the points is
  specified by the number "dimension".
*/  

#include "OMmacros.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"

void EMrevpyline (msg, inpoly, dim, num)
IGRlong *msg;
struct IGRpolyline *inpoly;
IGRshort dim;
IGRint num;
{
  IGRint size, i, j, count;
  IGRdouble temp[3];

  *msg = EMS_S_Success;
  if (!inpoly || num < 0 || dim < 1 || dim > 3)
    {
    *msg = EMS_E_InvalidArg;
    goto ret_end; 
    }

  size = dim * sizeof (IGRdouble);
  num = (num > inpoly->num_points ? inpoly->num_points : num);
  count = ((num ? num : inpoly->num_points) / 2) * dim;
  for (i=0, j=(inpoly->num_points-1)*dim; i<count; i+=dim, j-=dim)
    {
    OM_BLOCK_MOVE (&inpoly->points[i], temp, size);
    OM_BLOCK_MOVE (&inpoly->points[j], &inpoly->points[i], size);
    OM_BLOCK_MOVE (temp, &inpoly->points[j], size);
    }

ret_end:;
}
