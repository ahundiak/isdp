/* ###################   APOGEE COMPILED   ################## */
class specification ECfilletcv (1:0) of super_cmd;

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
# include "EMSfillet.h" /* needed for fil_crv_info_sd */

instance ECfilletcv
{
  IGRboolean            is_closed, hilite_subcrv;
  IGRint                num_subcrvs, subcrv_inx;
  IGRdouble             last_radius;
  GRobjid               compcv_id;
  struct GRlc_stack     locate_stack;
  struct GRlc_info      lc_obj;
  variable struct fil_crv_info_sd   fil_crv_info[];
};

override execute, init, sleep, wakeup, delete;

end specification ECfilletcv;
