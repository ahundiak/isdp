/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRlocate_owner

Description
    This method performs the locate operation for owners.  This method
    is responsible for locating the owner and the component that sent 
    this message.

    *msg           IGRlong              completion code
    *cvl           struct GRlc_cvl      Module and action handler info
    *path          struct GRlc_path     The locate path of objects
    *path_position  IGRint              Position of calling object in
                                        the path structure.

Notes
    The msg should be initialized to GR_I_NO_RESPONSE.  Only
    legitimate owners can change the message setting.

Return Values
    MSSUCC            -  if successful completion 
    MSFAIL            -  if error occurred
    GR_I_NO_RESPONSE  -  If no legitimate owners.
\*/

class implementation GRdrawsheet;

#include "grimport.h"
#include "msdef.h"
#include "lcdef.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "godef.h"
#include "grerr.h"
#include "lcmacros.h"
#include "grgsdef.h"
#include "gocmacros.h"

extern IGRint GRget_to_owner_chansel();

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
    IGRlong           om_msg;
    GRclassid         classid;
    GRclassid         dsborder_classid;
    OM_S_CHANSELECT   chansel;

    GRget_to_owner_chansel(&chansel);

    om$get_classid ( osnum = path[*path_position].lc_info.located_obj.osnum,
                     objid = path[*path_position].lc_info.located_obj.objid,
                     p_classid = &classid );

    om$get_classid ( classname = "GRdsborder",
                     p_classid = &dsborder_classid );

    if (classid == dsborder_classid) 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRowner.GRlocate_owner ( msg, 
                                                                  cvl, 
                                                                  path,
                                                                  path_position),
                           targetid = my_id);
    }
    else 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRcmpowner.GRlocate_owner ( msg, 
                                                                     cvl, 
                                                                     path,
                                                                     path_position ),
                           targetid = my_id);
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_LOCATED);

    return (om_msg);
}
end implementation GRdrawsheet;
