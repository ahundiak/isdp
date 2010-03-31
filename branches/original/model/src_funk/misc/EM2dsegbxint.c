/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
  This functions uses the Cohen-Sutherland type procedure to trivially 
  reject 2-dimensional line segments lying outside a 2D-dimensional rectangle. 

  Note: Only those edges that can be trivially rejected by a simple zone-bit
  check are rejected. This function DOES NOT guarantee that an intersection
  will occur with this rectangle if the segment is not rejected.
*/


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

#define FIRST_BIT   0x01
#define SECOND_BIT  0x02
#define THIRD_BIT   0x04
#define FOURTH_BIT  0x08

IGRboolean EM2dsegbxint (seg, bx)
IGRdouble seg[4];
IGRdouble bx[4];
{
  IGRuchar zone1, zone2;

  zone1 = 0;
  zone2 = 0;

  if (seg[0] < bx[0]) zone1 = FIRST_BIT;
  else if (seg[0] > bx[2]) zone1 = SECOND_BIT;
  if (seg[1] < bx[1]) zone1 = zone1 | THIRD_BIT;
  else if (seg[1] > bx[3]) zone1 = zone1 | FOURTH_BIT;

  if (seg[2] < bx[0]) zone2 = FIRST_BIT;
  else if (seg[2] > bx[2]) zone2 = SECOND_BIT;
  if (seg[3] < bx[1]) zone2 = zone2 | THIRD_BIT;
  else if (seg[3] > bx[3]) zone2 = zone2 | FOURTH_BIT;
  
  if (zone1 & zone2) return (FALSE);
  else return (TRUE);
}
