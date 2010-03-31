class specification ECfixsup (1:0) of COconst;

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

instance ECfixsup
{
  variable GRobjid  sids[]; 
  IGRint            current_sid;
  struct GRid       model_GRid;
  struct GRmd_env   env;
  struct GRlc_stack locate_stack;
  struct GRevent    event;
};

override
        execute,
        wakeup,
        sleep;

end specification ECfixsup;
