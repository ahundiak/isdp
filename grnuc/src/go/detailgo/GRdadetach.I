/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdetach_model

Description
    This method detaches a model from teh drawing view.

Arguments
    *msg           IGRlong           return code
    *mod_env       struct GRmd_env   module environment

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"

from GRdvalign import GRdvalign_pass_msg;

method GRdetach_model (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    /*
     *  Delete the reference file object.
     */
    om$send (msg = message GRdrawview.GRcomponent_delete ( msg,
                                                           mod_env,
                                                           GR_DV_REFFILE), 
             targetid = my_id);

    om_msg = om$send (msg = message GRdvalign.GRdvalign_pass_msg ( msg,
                                                                   OPPmargs ),
                      p_chanselect = &chansel);

    return (om_msg);
}
end implementation GRdvattach;
