/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdisplay_drawing_views

Description
    This method displays all drawing views associated with this
    drawing view.

Arguments
    *msg           IGRlong           return code
    *matrix_type   IGRshort          matrix type
    matrix         IGRmatrix         display matrix
    *dpmode        enum GRdpmode     display mode
    *display_id    struct GRid       display object
    display_flag   IGRint            if 1 display drawing view
                                    if 0 display drawing attachment only

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

method GRdisplay_drawing_views ( IGRlong *msg;
                                 IGRshort *matrix_type;
                                 IGRmatrix matrix;
                                 enum GRdpmode *dpmode;
                                 struct GRid *display_id;
                                 IGRint display_flag)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    if (!display_flag) 
    {
        om_msg = om$send (msg = message GRgraphics.GRdisplay ( msg, 
                                                               matrix_type, 
                                                               matrix, 
                                                               dpmode, 
                                                               display_id),
                          targetid = my_id);
    }

    om_msg = om$send (msg = message GRdvalign.GRdvalign_pass_msg ( msg,
                                                                   OPPmargs),
                      p_chanselect = &chansel);

    return (om_msg);
}
end implementation GRdvattach;
