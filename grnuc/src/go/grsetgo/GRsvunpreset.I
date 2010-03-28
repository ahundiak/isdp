/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSunpreset

Description
   This method collapses the channel set by the GSsvinit message.

   *msg            IGRlong         return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "lcmacros.h"

method GSunpreset (IGRlong *msg)
{
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om$channel_unpreset (p_chanselect = &chansel, collapse_flag = 1);
   return ( OM_S_SUCCESS );
}

end implementation GRsvset;
