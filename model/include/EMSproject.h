/*
Abstract

    This file contains structure definitions for the various formats
    for storing surfaces of projection.

Notes

    The properties bits for EMSprojectedSurfaceHeader.pj_props
    are defined in EMSssprops.h

History

    29 October 87   AIC     Creation Date
*/

# ifndef EMSproject_include
# define EMSproject_include

/*
 * Format for storing a projection normal to the plane of a planar
 * curve. (+/- for direction)
 */
#ifndef __DDP__
struct EMSorthagonalProjection
{
  IGRdouble                         magnitude;
  IGRdouble                         end_of_data[1];
};
#endif

/*
 * Format for storing a standard projection.
 */
#ifndef __DDP__
struct EMSvectorProjection
{
  IGRvector                         projection;
  IGRdouble                         end_of_data[1];
};
#endif

/*
 * Format for storing a scaled projection.
 */
#ifndef __DDP__
struct EMSscaledProjection
{
  IGRpoint                          from_point;
  IGRpoint                          to_point;
  IGRdouble                         scale;
  IGRdouble                         end_of_data[1];
};
#endif

/*
 * Union of all formats for storing the projection data
 */
union EMSprojectionFormat
{
  struct EMSorthagonalProjection    ortho_format;
  struct EMSvectorProjection        vector_format;
  struct EMSscaledProjection        scaled_format;
};

/*
 * Format for storing a surface of projection. The poles, weights,
 * and knots of the projected curver are stored at
 *   EMSprojectedSurfaceHeader.EMSprojectionFormat.*_format.end_of_data
 */
struct EMSprojectedSurfaceHeader
{
  unsigned char             pj_props;
  unsigned char             order;
  unsigned short            num_poles;
  unsigned int              unused;
  union EMSprojectionFormat projection_data;
};

# endif
