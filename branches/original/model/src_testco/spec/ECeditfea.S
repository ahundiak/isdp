class specification ECeditfea (1:0) of COconst;

# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "igrdp.h"
# include "go.h"
# include "ex.h"
# include "griodef.h"
# include "grio.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"

/*
History:
    DLB  06/31/91   Creation date.
*/

struct EMSfea_info
{
  struct GRid       grid;
  struct GRid       group_comp_grid;
  struct GRmd_env   env;
  IGRuint           num_deps;
  struct GRid       *dep_grids;
};

instance ECeditfea
{
  variable struct EMSfea_info fea_info[];
  IGRuint              num_feas;
  struct GRlc_stack    locate_stack;
  struct GRevent       event;
};

override
        execute,
        wakeup,
        sleep,
        delete;

end specification ECeditfea;
