/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRremove_member

Description
   This method is used to remove a member of the graphics set.  The
   member does not necessarily have to belong to the graphics set.

   *msg           IGRlong           return code
   *member_id     struct GRid       The member id

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   Gray Winn    04/21/88         Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSremove_member (IGRlong *msg; struct GRid *member_id)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Send the GSremove_member message to members.
    */

   om_msg = om$send(
            msg = message GRgrset.GSremove_member (msg, member_id), 
            p_chanselect = &chansel);

   return ( om_msg );
}
end implementation GRgrset;
