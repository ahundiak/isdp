# ifndef EMSconstruct_include
# define EMSconstruct_include 1

#ifndef bsdefs_include
#include "bsdefs.h"
#endif

# include "EMSprop.h"

#define MAX_NO_OF_FACES 10    /* used in establishing topology during
                                 constructions */
#define NO_OF_EDGES_PER_FACE 4

#define REVERSED EMED_REVERSE_CONNECT
#define SEAM_EDGE (EMED_REVERSE_CONNECT | EMED_SEAM)
#define NOT_REVERSED 0

#define EMS_GET_POS_ORIENT 0x0001
#define EMS_SET_POS_ORIENT 0x0002
#define EMS_POINT_OUT_OF_SOLID 0x0004

/* **************************************************************************

   The following defintions are used during classification of a point with
   respect to a solid.

   ************************************************************************** */


#define EMS_S_INSOLID  1  /* If the point is inside the solid */
#define EMS_S_OUTSOLID 2  /* If the point is outside the solid */
#define EMS_S_ONSOLID  3  /* If the point is on the solid */ 
#define EMS_S_UNKNOWN  4  /* If the location of a point with respect to
                             the solid is unknown */

/* ***********************************************************************

   These definitions are used while determining the characteristics of a ray
   as it pierces the surface. It takes into account the natural normal of
   the surface together with the surface->pos_orient bit while determining
   the solid side of the surface.

   *********************************************************************** */

#define EMS_S_SOLID_HOLE 5  /* If the ray naturally proceeds from solid region
                               to the hole region */ 
#define EMS_S_HOLE_SOLID 6  /* If the ray naturally proceeds from hole region
                               to solid region */

#define EMS_CONSTRUCT_TOP_CAP 0
#define EMS_CONSTRUCT_BOTTOM_CAP 1
#define EMS_CONSTRUCT_BOTH_CAPS 2
# endif
