/*
Abstract

    This file contains the definition of the format for storing a
    sphere in the canonical format.

Notes

    EMSsphereHeader uses the unsed bits in the ss_props field of
    the instance data of EMSsubbs. The bits are defined in EMSssprops.h.

History

    06 November 87   AIC     Creation Date
*/

# ifndef EMSsphere_include
# define EMSsphere_include

/*
 * Structure for storing a sphere that is not rotationally oriented.
 */
struct EMSunorientedSphere
{
  IGRpoint      center;     /* Center point */
  IGRdouble     radius;     /* Radius value */
};

/*
 * Structure for storing a sphere that is rotationally oriented.
 */
struct EMSorientedSphere
{
  IGRpoint      arc_base;
  IGRpoint      arc_midpoint;
  IGRpoint      arc_top;
};

/*
 * Union of structures for storing a sphere.
 */
union EMSsphereHeader
{
  struct EMSorientedSphere      oriented_format;
  struct EMSunorientedSphere    unoriented_format;
};

# endif
