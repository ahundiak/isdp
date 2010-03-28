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
#include "csmacros.h"

method GRclear_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{

    *msg = MSSUCC;
    gr$clear_active_owner (msg = msg, mod_id = &mod_env->md_id);
    cs$make_active (msg = msg, objid = NULL_OBJID, module = mod_env);
    return (OM_S_SUCCESS);
}
end implementation GRdrawview;
