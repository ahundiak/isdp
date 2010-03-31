/*
Abstract

    This file contains the definition of the format for storing a
    cone in the canonical format.

Notes

    EMSconeHeader uses the unsed bits in the ss_props field of
    the instance data of EMSsubbs. The bits are defined in EMSssprops.h.

History

    06 November 87   AIC     Creation Date
*/

# ifndef EMScone_include
# define EMScone_include

/*
 * Structure for storing a cone that is not rotationally oriented.
 */
struct EMSunorientedCone
{
  IGRpoint      center;         /* Center point         */
  IGRvector     height;         /* Height vector        */
  IGRdouble     base_radius;    /* Base radius value    */
  IGRdouble     top_radius;     /* Top radius value     */
};

/*
 * Structure for storing a cone that is rotationally oriented.
 */
struct EMSorientedCone
{
  IGRpoint      center;         /* Center point         */
  IGRvector     height;         /* Height vector        */
  IGRvector     base_radius;    /* Base radius vector   */
  IGRdouble     top_radius;     /* Top radius value     */
};

/*
 * Union of structures for storing a cone.
 */
union EMSconeHeader
{
  struct EMSorientedCone    oriented_format;
  struct EMSunorientedCone  unoriented_format;
};

# endif
