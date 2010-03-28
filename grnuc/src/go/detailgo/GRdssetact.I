/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRset_active_owner

Description
    This method defines the owner as the active owner.

    *msg           IGRlong              completion code 
    *mod_env       struct GRmd_env      The owners module environment

Return Values
    MSSUCC  if successful
    MSFAIL  if failure
\*/

class implementation GRdrawsheet;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "grownmacros.h"

extern IGRint GRget_to_comp_chansel();

method GRset_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    struct GRid       my_GRid;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    GRget_to_comp_chansel(&chansel);

    /*
     *  Inform the border object that the drawing sheet is active.
     */
    om_msg = om$send ( msg = message GRowner.GRset_active_owner ( msg, 
                                                                  mod_env),
                       p_chanselect = &chansel, 
                       from = 0, 
                       to = 0 );
    
    /*
     *  Define the owner as active.
     */
    om_msg = gr$put_active_owner ( msg = msg, 
                                   mod_id = &mod_env->md_id,
                                   active_owner = &my_GRid );

    return (om_msg);
}
end implementation GRdrawsheet;
