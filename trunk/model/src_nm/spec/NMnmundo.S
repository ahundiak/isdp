class specification NMnmundo (1:0) of COconst;

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

instance NMnmundo
{
 struct GRlc_info  nm_info;     /*located solid info*/
 struct GRlc_stack locate_stack;   /*for locate purposes*/
 struct GRevent    locate_event;   /*for locate purposes*/
};

override execute, wakeup, sleep;

end specification NMnmundo;
