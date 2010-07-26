/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"

extern GRget_to_owner_chansel();

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;
    ex$message(msgnumb = GR_I_DrwAtt, buff = info->type);
    return(OM_S_SUCCESS);
}

method GRget_drawing_view_id (IGRlong *msg; struct GRid *dv_id)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;
 
    GRget_to_owner_chansel(&chansel);

    om$get_objid_at_index ( objid = my_id, 
                            p_chanselect = &chansel,
                            index = 0, 
                            objidaddr = &dv_id->objid,
                            osnumaddr = &dv_id->osnum );

    return(om_msg);
}

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    *msg = MSSUCC;   
    return (OM_S_SUCCESS);
}

method GRget_drawing_attachment_id (IGRlong *msg; struct GRid *da_id)
{
    *msg = MSSUCC;
    da_id->osnum = OM_Gw_current_OS;
    da_id->objid = my_id;
    return (OM_S_SUCCESS);
}
end implementation GRdvattach;
