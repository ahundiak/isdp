/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcomponent_disconnecting

Description
    This method notifies a owner that one of his components is disconnecting
    from the "GRcmpowner.to_components" channel.

    *msg        IGRlong           completion code
    *mod_env    struct GRmd_env   environment information
    *comp_id    struct GRid       Object id of the component

Notes
    The owner is responsible for disconnecting the components if the
    owner is deleting himself.  If the owner does not disconnect the
    components before a delete then an infinite loop could occur.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn      04/19/87    Creation date
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"
#include "godef.h"

method GRcomponent_disconnecting ( IGRlong *msg;
                                   struct GRmd_env *mod_env;
                                   struct GRid *comp_id)
{
    IGRlong           om_msg;
    GRclassid         classid;
    GRclassid         da_classid;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;

    om$get_classid ( osnum = comp_id->osnum, 
                     objid = comp_id->objid,
                     p_classid = &classid );

    om$get_classid ( classname = "GRdvattach",
                     p_classid = &da_classid );

    if (da_classid == classid) 
    {
        /*
         *  If the drawing attachment is disconnecting delete the
         *  owner.
         */
        om$send ( mode = OM_e_wrt_message,
                  msg = message GRflxown.GRcomponent_disconnecting ( msg,
                                                                     mod_env,
                                                                     comp_id ),
                  targetid = my_id);

        om$send ( msg = message GRowner.GRdelete_owner (msg, mod_env),
                  targetid = my_id);
    }
    else 
    {
        om$send ( mode = OM_e_wrt_message,
                  msg = message GRflxown.GRcomponent_disconnecting ( msg,
                                                                     mod_env, 
                                                                     comp_id ),
                  targetid = my_id);
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);

    return (om_msg);
}
end implementation GRdrawview;
