/*
Abstract

    This file contains structure definitions for the various formats
    for storing surfaces of revolution.

Notes

    The properties bits for EMSrevolvedSurfaceHeader.rv_props
    are defined in EMSssprops.h

History

    06 November 87   AIC     Creation Date
*/

# ifndef EMSrevol_include
# define EMSrevol_include

/*
 * Structure for storing a surface of revolution. The poles, weights,
 * and knots of the revolved curve are stored at double_data.
 */
#ifndef __DDP__
struct EMSrevolvedSurfaceHeader
{
  unsigned char     rv_props;
  unsigned char     unused;
  unsigned short    order;
  unsigned int      num_poles;
  IGRdouble         double_data[1];
};
#endif

# endif
