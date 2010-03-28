/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdisyourself

Description
    This method sets up display for the components of a drawing view.

    *msg         IGRlong        completion code:
    *mx_type     IGRshort       type of matrix 
    matrix       IGRmatrix      environment transformation matrix
    *mode        GRdpmode       the display mode 
    *alt_symb    struct IGRaltdisplay 
    *sp_info     struct DP_information
    range_key    OM_p_KEY_DESC  range of the grahic object

Notes 
    It is necessary to respond to the GRhhdo, GRheo, and GRhdo modes
    even if the object is not displayable.

Return Values
    MSSUCC - successful completion
    MSFAIL - failure of routine
 
History
    Gray Winn   06/20/88    Creation Date
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

#define HIGHLIGHT       0x1
#define NOT_HIGHLIGHT   0x2

extern IGRint GRget_to_comp_chansel();

method GRdisyourself ( IGRlong *msg; 
                       IGRshort *mx_type; 
                       IGRmatrix matrix;  
                       enum GRdpmode *mode;
                       struct IGRaltdisplay *alt_symb; 
                       struct DP_information *sp_info;
                       OM_p_KEY_DESC range_key )
{
    IGRlong           om_msg;
    IGRint            flag=0;
    OM_S_CHANSELECT   chansel;
    enum GRdpmode     nh_mode;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    GRget_to_comp_chansel(&chansel);

    switch (*mode) 
    {
    case GRhd:
    case GRhe:
    case GRhhd:
    case GRhdo:
    case GRhhdo:
    case GRheo:
        flag = HIGHLIGHT;
        break;

    case GRbd:
    case GRbdhd:
    case GRbdhe:
    case GRbdheo:
        flag = HIGHLIGHT | NOT_HIGHLIGHT;
        nh_mode = GRbd;
        break;

    case GRbe:
    case GRbehe:
    case GRbehd:
    case GRbeheo:
        flag = HIGHLIGHT | NOT_HIGHLIGHT;
        nh_mode = GRbe;
        break;
    }

    if (flag & HIGHLIGHT) 
    {
        /* 
         *  Send the display message only to drawing view attachment.
         */
        om$send ( msg = OPPmargs, 
                  p_chanselect = &chansel, 
                  from = 0, 
                  to= 0 );
    }

    if (flag & NOT_HIGHLIGHT) 
    {
        om$send ( msg = message GRgraphics.GRdisyourself ( msg, 
                                                           mx_type,
                                                           matrix,
                                                           &nh_mode, 
                                                           alt_symb, 
                                                           sp_info, 
                                                           range_key ),
                  p_chanselect = &chansel, 
                  from = 1, 
                  to = OM_K_MAXINT );
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DISPLAYED);
    
    if ( !(om_msg & 1) ) om_msg = OM_W_ABORT;

    return (om_msg);
}   
end implementation GRdrawview;
