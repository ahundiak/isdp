/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpadelcomp

Description
            This function deletes the components of the pattern, assuming
        they are on the indicated channel beginning at index 1.

History
        mrm     01/26/88    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

IGRint GRpadelcomp (msg, caller, chan, mod)

IGRlong             *msg;       /* return code */
struct GRid         *caller;    /* pattern header id */
OM_S_CHANSELECT     *chan;      /* channel to delete on */
struct GRmd_env     *mod;       /* component module */

{
    IGRint          i;          /* loop index */
    OMuint          count;      /* number of components + master */
    IGRlong         sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    count = 0;

    /*
     *  get count of components
     */

    sts = om$get_channel_count (objid = caller->objid,
                                osnum = caller->osnum,
                                p_chanselect = chan,
                                count = &count);

    if (!(sts & 1) || (count < 1))
    {
#ifdef DEBUG
        printf ("GRpadelcomp: om$get_channel_count = %d\n", count);
#endif
        goto finish;
    }

    /*
     *  delete the channel components
     */

    for (i = count - 1; i > 0; i--)
    {
        sts = om$send (msg = message GRgraphics.GRdelete (msg, mod),
                       senderid = caller->objid,
                       p_chanselect = chan,
                       from = i,
                       to = i);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpadelcomp: failed to delete component # %d\n", i);
#endif
            goto finish;
        }
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRpadelcomp: msg = 0x%x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRpa;
