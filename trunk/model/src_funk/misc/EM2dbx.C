/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
  This function accepts a set of 2D-points and determines the min-max box that
  contains them.

  The min and max components of the min-max box are initially
  set equal to the first point in the point sequence, and are later
  tested against the other points.
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

#define X 0
#define Y 1

void EM2dbx(num_points, pts, range)
IGRlong num_points;
IGRdouble *pts;  
IGRdouble range[4];
{
  IGRint i, blk_size, inx;
  IGRdouble *min, *max;

  /*
   * Initialize the min and max
   * arguments.
   */

  blk_size = 2 * sizeof (IGRdouble);
  min = &range[0];
  max = &range[2]; 
  OM_BLOCK_MOVE (pts, min, blk_size);
  OM_BLOCK_MOVE (pts, max, blk_size);

  inx = num_points*2;
  for (i=0; i<inx; i+=2)
    {
    if (pts[i] < min[X]) min[X] = pts[i];
    if (pts[i+1] < min[Y]) min[Y] = pts[i+1];
    if (pts[i] > max[X]) max[X] = pts[i];
    if (pts[i+1] > max[Y]) max[Y] = pts[i+1];
    }
}
        
