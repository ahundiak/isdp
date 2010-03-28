/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRis_component_removeable

Description
    This method determines if a component can be removed from an owner.
    The message is needed so that the owner can determine if a component
    can be removed before the component is highlighted for removal.

    *msg           IGRlong              completion code 
    *mod_env       struct GRmd_env      The owners module environment
    *comp_id       struct GRid          The component id
    *flag          IGRint               if 0 - component cannot be removed
                                        if 1 - component can be removed

Return Values
    MSSUCC  if successful
    MSFAIL  if failure
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"

extern IGRint GRget_to_comp_chansel();

method GRis_component_removeable ( IGRlong *msg; 
                                   struct GRmd_env *mod_env;
                                   struct GRid *comp_id; 
                                   IGRint *flag )
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;
    struct GRid       go_id;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    GRget_to_comp_chansel(&chansel);

    om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                            objid = my_id,
                            p_chanselect = &chansel, 
                            index = 0, 
                            objidaddr = &go_id.objid,
                            osnumaddr = &go_id.osnum );

    if ((go_id.objid == comp_id->objid) &&
        (go_id.osnum == comp_id->osnum))
    {
        *flag = FALSE;
    }
    else 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRowner.GRis_component_removeable ( msg,
                                                                             mod_env, 
                                                                             comp_id, 
                                                                             flag ),
                           targetid = my_id);
    }

    return (om_msg);
}
end implementation GRdrawview;
