class specification ECdelbnd (1:0) of COconst;

# include "OMminimum.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "griodef.h"
# include "grio.h"
# include "dp.h"
# include "lcdef.h"     /* needed for lc.h */
# include "lc.h"        /* GRlc_stack */


instance ECdelbnd
{
 struct     GRevent     lc_event;
 struct     GRlc_stack  lc_stack;
 variable  struct GRid  loop_ids[];
 struct     GRmd_env    module_info;
 struct     GRid        active_GRid;
 GRobjid                delete_dprid;
 IGRboolean             got_solid;
 IGRint                 num_loops;
 IGRboolean             associative;
 };

override init, sleep, wakeup, execute;

end specification ECdelbnd;           
