/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy

Description
    This method will  send a message to each of its components to copy
    and then connect themselves to the new owner.  The new owner id will
    be returned in newobjid.

    *msg         IGRlong          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *target_env  struct GRmd_env  The target environment structure 
    *newobjid    GRobjid          Objid of the transformed object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn 11/23/88      Coding Date
\*/

class implementation GRdrawsheet;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

method GRcopy ( IGRlong *msg; 
                struct GRmd_env *mod_env;
                struct GRmd_env *target_env; 
                GRobjid *new_objid )
{
    IGRlong              om_msg;
    IGRint               save_active_owner;

    /*
     *  Temporary clear the active owner.
     */
    save_active_owner = GRactive_owner_temp_clear (NULL);

    om_msg = om$send ( mode = OM_e_wrt_message, 
                       msg = message GRowner.GRcopy ( msg, 
                                                      mod_env, 
                                                      target_env, 
                                                      new_objid ),
                       targetid = my_id);

    /*
     *  Restore the active owner.
     */
    GRactive_owner_temp_clear (&save_active_owner);

    return (om_msg);
}
end implementation GRdrawsheet; 
