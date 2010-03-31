class specification ECmassp (1:0) of super_cmd;

# include "igrtypedef.h"
# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "ex.h"
# include "igr.h"
# include "igrdef.h"
# include "igrdp.h"
# include "madef.h"
# include "godef.h"
# include "dp.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"


/*
 * History
 * ??/??/87 : GK : Creation
 * 11/01/88 : PP : made modifications to output triad into the
 *                 database as an option
 * 2/8/93   : SM : Added 'group_objs' to the instance data as this is used
                   in the command object across different states, hence has
                   a problem with command stacking, unless captured in the
                   instance data.
 */

instance ECmassp
   {
	struct GRmd_env         ModuleInfo;
	struct GRlc_stack       stack;
	struct GRevent		    event_1;
    variable IGRdouble      density[1];
	IGRlong	                numb_accumulated;
	struct GRlc_info        current_obj;
    IGRint                  num_objects;
    variable struct GRid    mass_prop_obj[1];
	variable struct GRid    accumulated_objs[];
    IGRboolean              is_uniform;
    IGRboolean              stderr_only;
    IGRboolean              area_only;
	IGRdouble               acc_prop[20];
	IGRdouble               max_sld;
	IGRchar	                file_name[40];
    struct GRvg_construct   construct_list;
    struct GRmd_env         construct_env;
    struct IGRdisplay       display;
    IGRlong                 msg;
    IGRlong                 option;
    IGRlong                 option1;
    variable struct GRlc_info group_objs[1];
    
   };


override wakeup, execute, init, sleep;

end specification ECmassp;

