/* ###################   APOGEE COMPILED   ################## */
class specification ECmassmanip (1:0) of super_cmd;

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

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
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
 * ??/??/87 : GK : Creation
 * 11/01/88 : PP : made modifications to output triad into the
 *                 database as an option
 */

instance ECmassmanip
   {
	struct GRmd_env         ModuleInfo;
	struct GRlc_stack       stack;
	struct GRevent          event_1;
	struct GRsymbology	    active_symbology;
    struct GRid             designator_id;
	IGRint                  in_orient;
    IGRint                  op_type;
	IGRdouble               in_origin[3];
	IGRdouble               in_glo_loc[9];
	IGRchar	                dest_file_name[40];
	IGRlong	                dest_orient;
	IGRdouble               dest_origin[3];
	IGRdouble               dest_glo_loc[9];
    IGRdouble               prin_glo_loc[6];
	IGRdouble               x[3];
	IGRdouble               prop[20];
    IGRboolean              stderr_only;
    struct GRvg_construct   construct_list;
    struct GRmd_env         construct_env;
    struct IGRdisplay       display;
    IGRdouble               density, sld;
    IGRlong                 msg;
   };

override wakeup, execute, init, sleep;

end specification ECmassmanip;

