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
   Gray Winn      05/02/88    Creation Date
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSremove_member (IGRlong *msg; struct GRid *member_id)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRfcset.clip_overlap";

   if (me->properties & GRIS_POST_PROCESSING)
   {
      /*
       *  Send the GSremove_member message to clip overlap members.
       */

      om_msg = om$send(
               msg = message GRgrset.GSremove_member (msg, member_id), 
               p_chanselect = &chansel);
   }

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRgrset.GSremove_member (msg, member_id),
            targetid = my_id);

   return ( om_msg );
}
end implementation GRfcset;
