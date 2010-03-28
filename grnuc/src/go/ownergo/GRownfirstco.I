/* #######################    APOGEE COMPILED   ######################## */
/*\
Description   
    The following methods will return the information from the
    first component.

History
    Gray Winn       10/15/87    Design and Creation date
    jay wallingford 04/28/89    Optimized the making of chansel
\*/

class implementation GRowner;

#include "grimport.h"
#include "gocmacros.h"
#include "grerr.h"
#include "msdef.h"

extern int   GRget_to_comp_chansel();

method GRgethprops(long *msg; unsigned int *props)
{
    long         om_msg;
    OM_S_CHANSELECT chansel;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRgraphics.GRgethprops (msg, props),
                          p_chanselect = &chansel, 
                          from = 0, 
                          to = 0);
    }

    return (om_msg);
}

method GRgeomprops(long *msg; short *matrix_type; IGRmatrix
                  matrix; struct GRprops *properties)
{
    long           om_msg;
    short          local_mx_type;
    IGRmatrix         local_matrix;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Get the component matrix.
         */
        om_msg = om$send(msg = message GRowner.GRget_matrix (msg, 
                                                             matrix_type,
                                                             matrix, 
                                                             &local_mx_type, 
                                                             local_matrix), 
                         targetid = my_id);

        om_msg = om$send(msg = message GRvg.GRgeomprops (msg, 
                                                         &local_mx_type, 
                                                         local_matrix, 
                                                         properties), 
                         p_chanselect = &chansel, 
                         from = 0, 
                         to = 0);
    }

    return (om_msg);
}

method GRgetsymb(long *msg; struct GRsymbology *symb)
{
    long           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    
    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send(msg = message GRvg.GRgetsymb (msg, symb),
                         p_chanselect = &chansel, 
                         from = 0, 
                         to = 0);

        if ( !(om_msg & *msg & 1)) *msg = GR_I_NO_LAYER;
    }

    return (om_msg);
}
end implementation GRowner;

