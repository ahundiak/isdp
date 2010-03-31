# ifndef EMSellpsd_include
# define EMSellpsd_include 1

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

struct EMesellpsd1
 {
  IGRpoint      center;
  IGRvector     semi_axis;
  IGRdouble     radius;
 };
struct EMesellpsd2
 {
  IGRpoint      focus0;
  IGRpoint      focus1;
  IGRdouble     major_axis_length;
 };

# endif /* EMSellpsd_include */
