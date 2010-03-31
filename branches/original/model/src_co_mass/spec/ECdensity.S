/* ###################   APOGEE COMPILED   ################## */
class specification ECdensity (1:0) of super_cmd;
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

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdef_include
# include "igrdef.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef madef_include
# include "madef.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif


# ifndef dp_include
# include "dp.h"
# endif

# ifndef gr_include
# include "gr.h"
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

# ifndef lc.h
# include "lc.h"
# endif

/*
 * History
 * 10/06/89 : Gupta : Creation
 */

instance ECdensity
   {
	struct GRmd_env         ModuleInfo;
	struct GRlc_stack       stack;
	struct GRevent		    event_1;
    IGRboolean              is_uniform;
    IGRint                  num_objects;
    variable struct GRid    mass_prop_obj[1];
    variable IGRdouble      density[1];
    struct IGRdisplay       active_display;
    IGRshort                active_level;    
   };

override init, wakeup, execute, sleep;

end specification ECdensity;
