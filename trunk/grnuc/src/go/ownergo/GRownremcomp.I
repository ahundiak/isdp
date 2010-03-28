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

History
    Gray Winn       07/22/88    Creation Date
    jay wallingford 04/29/89    Optimized the making of chansel
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "grownerdef.h"

extern IGRint   GRget_to_comp_chansel();

method GRis_component_removeable ( IGRlong *msg; 
                                   struct GRmd_env *mod_env;
                                   struct GRid *comp_id; 
                                   IGRint *flag)
{
    IGRlong              om_msg;
    OM_S_CHANSELECT      chansel;

    *msg = MSSUCC;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) {
        om_msg = om$is_objid_on_channel ( osnum_c = OM_Gw_current_OS,
                                          objid_c = my_id, 
                                          p_chanselect = &chansel,
                                          objid = comp_id->objid, 
                                          osnum2 = comp_id->osnum);

        *flag = (om_msg & 1) ? 1 : 0;
    }

    return (OM_S_SUCCESS);
}
end implementation GRowner;
