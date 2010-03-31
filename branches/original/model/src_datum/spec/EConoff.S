/* ###################   APOGEE COMPILED   ################## */
class specification EConoff (1:0) of COconst;

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

instance EConoff
 {
  IGRint        datum_count;
  struct        GRmd_env        display_env;
  struct        GRevent         locate_event;
  struct        GRid            mgr_GRid;
  struct        GRlc_stack      locate_stack;
  struct        GRlc_info       datum_info;
  variable struct GRid            datum_GRids[5];
 };
 
override execute, wakeup,sleep;
message make_datums_locatable(IGRint on);
message display_datum(struct GRid datum_GRid;
                     enum GRdpmode display_mode);

end specification EConoff;
