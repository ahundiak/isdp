/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSinqcount 

Description
   This method is used to return the number of components owned 
   by the graphics set.

   *msg         IGRlong        return code
   *count       IGRint         Number of object owned by set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"

method GSinqcount (IGRlong *msg; IGRint *count)
{
IGRlong           om_msg;
OM_S_CHANSELECT chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the channel count of the members channel.
    */

   om_msg = om$get_channel_count (osnum = OM_Gw_current_OS,
            object= me, p_chanselect = &chansel, count = (IGRuint *) count);
   return ( om_msg );
}

end implementation GRsvset;
