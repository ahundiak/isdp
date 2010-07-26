/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy_owner

Description
    The method is used to copy the header object and not the components.

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The module environment
    *target_env    struct GRmd_env      The target environment
    *owner_id      GRobjid              The new owner

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      07/06/87    Creation Date
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

method GRcopy_owner ( IGRlong *msg;
                      struct GRmd_env *mod_env;
                      struct GRmd_env *target_env;
                      GRobjid *owner_id)
{
    IGRlong              om_msg;
    IGRchar              string[3];

    *msg = MSSUCC;
    string[0] = '\0';

    om$send ( mode = OM_e_wrt_message,
              msg = message GRowner.GRcopy_owner ( msg, 
                                                   mod_env, 
                                                   target_env,
                                                   owner_id),
              targetid = my_id);

    om_msg = om$send ( msg = message GRdrawview.GRput_drawview_description
                                                ( msg, string ), 
                       targetid = *owner_id,
                       targetos = target_env->md_id.osnum);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);

    return (om_msg);
}
end implementation GRdvattach;
