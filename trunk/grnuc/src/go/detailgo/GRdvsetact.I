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
#include "exmacros.h"
#include "grownmacros.h"

from GRdvcs    import   GRset_active_cs;

method GRset_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong        om_msg;
    struct GRid    my_GRid;

    *msg = MSSUCC;
    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    /*
     *  Define the owner as active.
     */
    gr$put_active_owner ( msg = msg, 
                          mod_id = &mod_env->md_id,
                          active_owner = &my_GRid );

    /*
     *  Define the coordinate system as active.
     */
    om_msg = GRcomponent_pass_fun ( msg, 
                                    message GRdvcs.GRset_active_cs (msg, mod_env), 
                                    GR_DV_CS, 
                                    my_id, 
                                    OM_Gw_current_OS );

    return (om_msg);
}
end implementation GRdrawview;
