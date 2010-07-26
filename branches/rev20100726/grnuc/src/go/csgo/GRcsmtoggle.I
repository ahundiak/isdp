/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name
        GRcsmgr.GRcstoggle_display

Description
        This method toggles the display of the coordinate system
        objects.  The properties bit in the coordinate system objects
        is inverted and a display message is sent to all the coordinate
        system objects on the to_components.

History
        11/08/86  Kumar Talluri  Design and Implementation.
        10/01/87  mrm            change channel usage
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "OMerrordef.h"

from GRgraphics import GRdisplay;
from GRvg       import GRchgprops;

method GRcstoggle_display (IGRlong          *msg;
                           struct GRmd_env  *module_info;
                           IGRint           *display_on)
{
    IGRlong         sts;                /* return code */
    IGRboolean      action;             /* set or clear */
    IGRshort        properties_mask;    /* toggle locate & display */
    enum GRdpmode   mode;               /* to display with */
    OM_S_CHANSELECT to_comp;            /* GRcmpowner.to_components */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    properties_mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comp);
    if (!(sts & 1))
    {
        goto finish;
    }

    if (me->display_status)
    {
        me->display_status = FALSE;
        mode = GRbe;
        action = FALSE;

        sts = om$send (msg = message GRgraphics.GRdisplay
                            (msg, 
                             &(module_info->md_env.matrix_type),
                             module_info->md_env.matrix,
                             &mode,
                             &(module_info->md_id)),
                       p_chanselect = &to_comp);

        if (!(sts & *msg & 1))
        {
            goto finish;
        }

        sts = om$send (msg = message GRvg.GRchgprops 
                            (msg, &action, &properties_mask),
                       p_chanselect = &to_comp);

        if (!(sts & *msg & 1))
        {
            goto finish;
        }
    }
    else
    {
        me->display_status = TRUE;
        mode = GRbd;
        action = TRUE;

        sts = om$send (msg = message GRvg.GRchgprops 
                            (msg, &action, &properties_mask),
                       p_chanselect = &to_comp);

        if (!(sts & *msg & 1))
        {
            goto finish;
        }

        sts = om$send (msg = message GRgraphics.GRdisplay
                            (msg, 
                             &(module_info->md_env.matrix_type),
                             module_info->md_env.matrix,
                             &mode,
                             &(module_info->md_id)),
                       p_chanselect = &to_comp);

        if (!(sts & *msg & 1))
        {
            goto finish;
        }
    }

    *display_on = me->display_status;

finish:

    return (sts);
}

end implementation GRcsmgr;
