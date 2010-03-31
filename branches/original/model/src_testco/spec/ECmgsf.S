class specification ECmgsf(1:0) of COconst;

/*

 This command object class has been created for the Unite surface state

HISTORY

 October, 1991 : AMD : Creation 
 07/09/92      : AMD : Added sleep, init, wakeup

*/

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


instance ECmgsf
{
 struct     GRevent     lc_event;
 struct     GRlc_stack  lc_stack;
 variable  struct GRid  surf_ids[];
 struct     GRid        active_GRid;
 IGRint                 num_surfs;
 IGRboolean             associative;
 };

override init, sleep, wakeup, execute;

end specification ECmgsf;           


