/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class manages the active owner.

History
   Gray Winn   03/25/88    Design and Coding Date.
\*/

class specification GRactownmgr (1:1) of global_class, GRcmpowner;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "dpdef.h"

override wake_up, sleep, connect, GRcomponent_disconnecting;

/*\
Name
   GRget_active_owner

Description
   This method returns the active owner.

Arguments
   *msg         IGRlong          o   completion code
   *actown_id   struct GRid      o   object id of the active owner.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRget_active_owner (IGRlong *msg; struct GRid *actown_id);

/*\
Name
   GRput_active_owner

Description
   This method defines the given owner as the active owner.

Arguments
   *msg         IGRlong          o   completion code
   *actown_id   struct GRid      i   object id of the active owner

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRput_active_owner (IGRlong *msg; struct GRid *actown_id);

/*\
Name
   GRclear_active_owner

Description
   This method clears the active owner.

Arguments
   *msg         IGRlong          o   completion code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRclear_active_owner (IGRlong *msg);

end specification GRactownmgr;
