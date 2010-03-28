/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdrop

Description
    This method is used to drop the grouping status (i.e. dissolve 
    the group).

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The module environment
 
Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      09/15/87    Creation date
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

method GRdrop  (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    /*
     *  Send drop to drawing attachment.
     */
    om$send ( msg = message GRowner.GRdrop (msg, mod_env),
              p_chanselect = &chansel, 
              from = 0, 
              to = 0 );

    om$send ( mode = OM_e_wrt_message,
              msg = message GRowner.GRdrop (msg, mod_env),
              targetid = my_id );
    
    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);

    return (om_msg);
}
end implementation GRdrawview;
