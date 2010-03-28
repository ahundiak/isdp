/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdelete

Description
   This method will delete the owner object.  First the object 
   will delete all of the components by sending the delete message 
   out the "to_components" channel.  Second the method will delete 
   the header object by sending the delete owner message.

   *msg         IGRlong               Completion code
   *mod_env     struct GRmd_env       Module environment structure 

Note
   This method will replace the module id with a NULL_OBJID so
   that their is not an attempt to remove the members from any
   index objects.

Return Values
   MSSUCC            if successful
   MSFAIL            if failure
   GR_I_INV_REQUEST  Can not delete because it is owned.

History
   Gray Winn   09/09/87    Creation date
   scw         07/22/92    ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"

method GRdelete (IGRlong *msg; struct GRmd_env *mod_env)
{
IGRlong           om_msg;
OMuint            count;
struct GRmd_env   temp_env;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRconnector.to_owners";

   om_msg = om$get_channel_count(object = me, p_chanselect = &chansel,
            count = &count);

   if ((om_msg & 1) && (!count))
   {
      temp_env = *mod_env;
      temp_env.md_id.objid = NULL_OBJID;

      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRowner.GRdelete (msg, &temp_env),
               senderid = my_id, targetid = my_id);
   }else
   {
      *msg = GR_I_INV_REQUEST;
   }
   return (om_msg);
}
end implementation GRsmdfhdr;
