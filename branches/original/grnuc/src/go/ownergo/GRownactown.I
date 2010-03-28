/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRadd_to_active_owner

Description
   This method adds an owner to the active owner.  If the owner is a
   RIGID owner it is added to the active owner.  If the owner is a
   FLEXIBLE owner it is not added to the active owner.

   *msg           IGRlong              completion code
   *mod_env       struct GRmd_env      The owners module environment

Return Values
   MSSUCC  if successful
   MSFAIL  if failure
History
   Gray Winn      07/22/88    Creation Date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "grownmacros.h"

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong     ret_msg;
    IGRint      channel_type;
    IGRint      connection_type;

    *msg = MSSUCC;

    om$send ( msg = message GRowner.GRget_channel_type ( &ret_msg,
                                                         &channel_type, 
                                                         &connection_type ), 
              targetid = my_id );

   if (channel_type == GR_RIGID)
   {
      /*
       *  Add to the active owner.
       */
      gr$add_to_active_owner (msg = msg, mod_env = mod_env);
   }
   return (OM_S_SUCCESS);
}
end implementation GRowner;
