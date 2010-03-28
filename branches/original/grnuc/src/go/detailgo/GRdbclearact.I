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

class implementation GRdsborder;

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
    unsigned char     weight;
    enum GRdpmode     dpmode;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    /*
     *  Erase the border.
     */
    dpmode = GRbe;
    om_msg = om$send (msg = message GRgraphics.GRdisplay 
                                                ( msg, 
                                                  &mod_env->md_env.matrix_type, 
                                                  mod_env->md_env.matrix,
                                                  &dpmode, 
                                                  &mod_env->md_id ),
                      p_chanselect = &chansel, 
                      from = 0, 
                      to = 0);

    /*
     *  Change the weight.
     */
    weight = 0;
    om_msg = om$send ( msg = message GRvg.GRchgweight ( msg, &weight ),
                       p_chanselect = &chansel,     
                       from = 0, 
                       to = 0 );

    /*
     *  Redraw the border.
     */
    dpmode = GRbd;
    om_msg = om$send ( msg = message GRgraphics.GRdisplay 
                                            ( msg, 
                                              &mod_env->md_env.matrix_type, 
                                              mod_env->md_env.matrix,
                                              &dpmode, 
                                              &mod_env->md_id ),
                       p_chanselect = &chansel, 
                       from = 0, 
                       to = 0 );

    return (om_msg);
}
end implementation GRdsborder;
