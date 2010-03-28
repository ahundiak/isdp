/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcomponent_idchanged

Description
    This method notifies a owner that one of his components id changed.

    *msg              IGRlong           completion code
    *num_comp_ids     IGRshort          number of new ids
    *comp_ids         struct GRid       new object ids

Notes
    The original component whose id changed will be deleted.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn      04/19/87    Creation date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"
#include "godef.h"

method GRcomponent_idchanged (IGRlong *msg; 
                              IGRshort *num_comp_ids;
                              struct GRid *comp_ids)
{
    IGRlong           om_msg;
    IGRint            i;
    IGRint            channel_type;
    IGRint            connection_type;
    struct GRid       my_GRid;

    *msg = MSSUCC;

    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    om_msg = om$send (msg = message GRowner.GRget_channel_type (msg,
                                                                &channel_type, 
                                                                &connection_type),
                      targetid = my_id);

    for (i=0; i < *num_comp_ids; ++i) 
    {
        /*
         *  Connect the new components.
         */
        om_msg = GRconnect_object ( msg, 
                                    comp_ids[i].osnum, 
                                    comp_ids[i].objid,
                                    &my_GRid, 
                                    channel_type,
                                    connection_type, 
                                    OM_K_MAXINT,
                                    OM_K_MAXINT);
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);

    return (om_msg);
}
end implementation GRowner;
