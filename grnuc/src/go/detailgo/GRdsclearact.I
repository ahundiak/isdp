/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRclear_active_owner

Description
    This method is sent to the active owner when another owner is defined
    or when the active owner is cleared.

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

method GRclear_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    /*
     *  Inform the border object that the drawing sheet is active.
     */
    om_msg = om$send (msg = message GRowner.GRclear_active_owner 
                                            ( msg, mod_env ),
                      p_chanselect = &chansel, 
                      from = 0, 
                      to = 0 );

    /*
     *  Clear the active owner.
     */
    gr$clear_active_owner (msg = msg, mod_id = &mod_env->md_id);

    return (OM_S_SUCCESS);
}
end implementation GRdrawsheet;
