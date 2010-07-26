/* #######################    APOGEE COMPILED   ######################## */
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
#include "godef.h"
#include "detail.h"

from GRdvalign import GRdvalign_pass_msg;

/*\
Name
    GRget_alignment_count
 
Description
    This method returns the number of drawing views aligned with this
    drawing view.

Arguments
    *msg           IGRlong              completion code 
    *count         IGRint               number of drawing views aligned

Notes
    Initialize count to zero

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      08/24/88    Creation Date
\*/

method GRget_alignment_count (IGRlong *msg; IGRint *count)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    om_msg = om$send (msg = message GRdvalign.GRdvalign_pass_msg
                                                 ( msg, OPPmargs), 
                      p_chanselect = &chansel);

    return (om_msg);
}

/*\
Name
    GRget_alignment_objects

Description
    This method returns the drawing views aligned with this drawing view.

Arguments
    *msg           IGRlong              completion code 
    size           IGRint               number of GRids
    *count         IGRint               number of GRids returned
    objects[]      struct GRid          the drawing views

Notes
    Initialize count to zero

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn         08/24/88       Creation Date
\*/

method GRget_alignment_objects ( IGRlong *msg;
                                 IGRint size;
                                 IGRint *count;
                                 struct GRid objects[])
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    om_msg = om$send (msg = message GRdvalign.GRdvalign_pass_msg
                                                ( msg,OPPmargs), 
                      p_chanselect = &chansel);
    return (om_msg);
}
end implementation GRdvattach;
