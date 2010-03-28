/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpachsym

Description
        This function gets the symbology of the master element (at position
        zero on the input channel) and sends a GRvg.GRchgdp message using
        that symbology to the remaining elements on the channel.

Synopsis
        IGRint GRpachsym (msg, caller, to_comp)

        IGRlong             *msg;       return code
        GRobjid             *caller;    calling object's id
        OM_S_CHANSELECT     *to_comp;   channel to master element & components

History
        mrm     11/25/87    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"

IGRint GRpachsym (msg, caller, to_comp)

IGRlong             *msg;       /* return code */
GRobjid             *caller;    /* calling object's id */
OM_S_CHANSELECT     *to_comp;   /* channel to master element & components */

{
    IGRlong             sts;        /* return code */
    struct GRsymbology  symbology;  /* master element's display symbology */

    sts = OM_S_SUCCESS;

    /*
     *  get the symbology of the master element
     */

    sts = om$send (msg = message GRvg.GRgetsymb (msg, &symbology),
                   senderid = *caller,
                   p_chanselect = to_comp,
                   from = 0,
                   to = 0);

    if ((sts & *msg & 1))
    {
        /*
         *  change the components' display symbology to that of
         *  the master element
         */

        sts = om$send (msg = message GRvg.GRchgdp
                            (msg, &symbology.display_attr),
                       senderid = *caller,
                       p_chanselect = to_comp,
                       from = 1);

        if ((sts & *msg & 1))
        {
            /*
             *  change the components' layer to that of the master element
             */

            sts = om$send (msg = message GRvg.GRchglevel
                                (msg, &symbology.level),
                           senderid = *caller,
                           p_chanselect = to_comp,
                           from = 1);
        }
    }

    return (sts);
}

end implementation GRpa;
