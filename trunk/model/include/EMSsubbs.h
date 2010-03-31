/*
Abstract

    This file contains the definition of the format for storing a
    surface in the bspline format.

Notes

    The properties bits for EMSprojectedSurfaceHeader.pj_props
    are defined in EMSssprops.h

History

    29 October 87   AIC     Creation Date
*/

# ifndef EMSsubbs_include
# define EMSsubbs_include

/*
 * Structure for storing a surface in the bspline format.
 */
#ifndef __DDP__
struct EMSbsplineSurfaceHeader
{
  IGRuchar      u_order;
  IGRuchar      v_order;
  IGRuchar      bs_props;
  IGRuchar      unused;
  IGRushort     u_num_poles;
  IGRushort     v_num_poles;
  IGRdouble             double_data[1];
};
#endif

# endif
