# ifndef ems_include
# define ems_include 1

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


/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef EMmsg_obj_include
# include "EMmsg_obj.h"
# endif

/* go.h and ems_inter.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

/*
 * This structure is used to form a linked list that 
 * would represent a chain of points on a linestring.
 * Besides the "true value" of the point, the structure
 * also supplies information about it's topological
 * placement along the linestring. For example: if the
 * linked list were to represent intersections on a 
 * linestring, it would be a simple matter to sort them
 * with respect to their occurence on the linestring as we
 * traverse it.
 */

struct EMpypoint
  {
  IGRlong pt_inx;             /* The point lies between the point
                                 with index "pt_inx" and point with index
                                 "pt_inx+1" */
  IGRdouble param;            /* If the segment between "pt_inx" and
                                 "pt_inx+1" was linearly parameterized
                                 from 0 to 1, the exact point is 
                                 at this parameter value */
  IGRpoint point;             /* The actual point. It is the evaluation
                                 of the point using the above two pieces
                                 of data */
  struct EMpypoint *next;     /* Pointer to the next point, if any */
  };

/*
 * This enumerated type is used to classify intersections, 
 * specifically between linestrings.
 */

enum EMpyint_type
  {
  EMint_MIDDLE,           /* Intersection at middle of
                             segment */
  EMint_END_NOTCOLL,      /* At endpoint and intersecting segment is 
                             not collinear */
  EMint_END_COLL          /* At endpoint and intersecting segment is
                             collinear with this or the following segment
                             of the polyline */
  };

#endif 
