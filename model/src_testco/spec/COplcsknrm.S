/* ###################   APOGEE COMPILED   ################## */
class specification COplcsknrm (1:0) of CObuild;

/* include "lc.h"*/

/* lc.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMlimits_include
# include "OMlimits.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
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

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef lc_include
# include "lc.h"
# endif

# ifndef lcmacros_include
# include "lcmacros.h"
# endif

/* end of lc.h replacement */

instance COplcsknrm
 {
  struct        GRevent locate_event;
  struct        GRlc_stack locate_stack;
  struct	GRlc_info surface, trace, cross_section;
  IGRmatrix	view_matrix, rhs_matrix, lhs_matrix;
  IGRpoint      side_pnt, ref_pnt;
  IGRpoint      vector_pnts[2], absolute_pnts[2];
  IGRboolean	have_surface, have_side_pnt, have_trace, have_trace_pnt;
  IGRboolean    have_cross_section, have_ref_pnt, have_vector;
  IGRboolean	is_left_hand_system, absolute_orientation;
 };
 
override wakeup, execute, sleep;

end specification COplcsknrm;

