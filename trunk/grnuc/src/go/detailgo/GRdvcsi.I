/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdvcs;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "OMmacros.h"
#include "csmacros.h"

extern IGRint GRget_to_owner_info();

method GRdelete(IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong              om_msg;
    IGRint               count;
    IGRint               i;
    IGRint               dv_owner;
    IGRchar              *buffer;
    GRclassid            sender_classid;
    GRclassid            classid;
    GRclassid            dv_classid;
    OM_S_CHANSELECT      chansel;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;
    buffer = (IGRchar *)NULL;

    GRget_to_owner_info(&chansel, OM_Gw_current_OS, my_id, &count);

    om$get_classid ( osnum = sender_os, 
                     objid = sender_id,
                     p_classid = &sender_classid );

    om$get_classid ( classname = "GRdvattach",
                     p_classid = &dv_classid);

    if ((sender_classid == dv_classid) || (!count)) 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRgencs.GRdelete(msg, mod_env),
                           targetid = my_id);
    }
    else if (buffer = om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE) * count)) 
    {
            om$get_channel_objects ( object = me, 
                                     p_chanselect = &chansel, 
                                     list = (OM_S_OBJECT_LINKAGE *)buffer, 
                                     size = (OMuint)count, 
                                     count = (OMuint *)&count );

            dv_owner = FALSE;
            for (i=0; i < count ; ++i) 
            {
                om$get_classid ( osnum = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum,
                                 objid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                                 p_classid = &classid );

                if (classid == dv_classid) 
                {
                    dv_owner = TRUE;
                    break;
                }
            }

            if (!dv_owner) 
            {
                om_msg = om$send ( mode = OM_e_wrt_message,
                                   msg = message GRgencs.GRdelete(msg, mod_env),
                                   targetid = my_id);
            }
            else *msg = MSFAIL;
    }
    else *msg = MSFAIL;

    if (buffer) om$dealloc (ptr = buffer);

    return(om_msg);
}

method GRset_active_cs (IGRlong *msg; struct GRmd_env *mod_env)
{
    *msg = MSSUCC;

    /*
     *  Define the coordinate system as the active coordinate system.
     */
    return(cs$make_active (msg = msg, objid = my_id, module = mod_env));
}
end implementation GRdvcs;
