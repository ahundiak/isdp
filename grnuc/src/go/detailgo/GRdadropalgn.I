/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdrop_alignment

Description
    This method drops the drawing view alignment between all drawing
    views.

Arguments
    *msg           IGRlong           return code

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

from GRdvalign import GRdvalign_drop_alignment;

method GRdrop_alignment (IGRlong *msg)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   notify_chansel;

    notify_chansel.type = OM_e_name;
    notify_chansel.u_sel.name = "GRnotify.notification";

    om_msg = om$send (msg = message GRdvalign.GRdvalign_drop_alignment(msg),
                      p_chanselect = &notify_chansel);

    return (om_msg);
}
end implementation GRdvattach;
