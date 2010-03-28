/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRchgprops

Description
    Given a mask, this method adjusts the object's properties word by
    clearing or setting the the properties word with the indicated mask.

    *msg       long            completion code
    *action     short          indictes what to do with properties 
                                    1 - set with mask
                                    0 - clear using mask
                                   -1 - replace
    *mask      unsigned short  properties mask

Return Values
    MSSUCC if successful

History
    Gray Winn       11/30/87    Creation Date
    jay wallingford 04/27/89    Optimized the way to_components
                                chanselect is made

\*/

class implementation GRowner;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "gocmacros.h"

extern int	GRget_comp_chansel();

method GRchgprops(long *msg; short *action; short *mask)
{
    long           om_msg;
    short          t_mask;
    short          t_action;
    OM_S_CHANSELECT   chansel;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;

    if ( om_msg = GRget_to_comp_chansel( & chansel ) ) 
    {
        if ((*mask & GRIS_LOCATABLE) || (*mask & GRIS_DISPLAYABLE)) 
        {
            t_action = (*action == -1) ? 1 : *action;

            t_mask = *mask & (GRIS_LOCATABLE | GRIS_DISPLAYABLE);
            om_msg = om$send ( msg = message GRgraphics.GRchgprops (msg, 
                                                                    &t_action, 
                                                                    &t_mask), 
                               p_chanselect = &chansel);
   
            if (*mask & ~(GRIS_LOCATABLE | GRIS_DISPLAYABLE)) 
            {
                t_mask = *mask & ~(GRIS_LOCATABLE | GRIS_DISPLAYABLE);

                om_msg = om$send (mode = OM_e_wrt_message,
                                  msg = message GRvg.GRchgprops (msg, 
                                                                 action, 
                                                                 &t_mask), 
                                  targetid = my_id);
            }
        }
        else 
        {
            om_msg = om$send (mode = OM_e_wrt_message,
                              msg = message GRvg.GRchgprops (msg, action, mask),
                              targetid = my_id);
        }

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return(om_msg);
}
end implementation GRowner;
