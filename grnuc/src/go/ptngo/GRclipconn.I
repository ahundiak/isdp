/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRclip_connect

Description
        This function calls GRgraphics.GRclip with the input parameters
        and takes care of connecting and/or deleting objects totally inside
        or outside the prism, according to in_id or out_id.

History
        mrm     10/05/88    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRgraphics;

#include "grimport.h"
#include "grerr.h"

#define NO_MESSAGE  0
#define CONNECT     1
#define DELETE      2

from GRconnector import GRrigidconn;

IGRint GRclip_connect (msg, current_mod, target_mod, prism,
                       in, out, ovl, clip_flags, index, clip_obj)

IGRlong             *msg;           /* return code */
struct GRmd_env     *current_mod;   /* module information */
struct GRmd_env     *target_mod;    /* module information */
IGRchar             *prism;         /* clipping prism */
struct GRid         *in;            /* object to connect inside pieces to */
struct GRid         *out;           /* object to connect outside pieces to */
struct GRid         *ovl;           /* object to connect overlap pieces to */
IGRlong             *clip_flags;    /* specifying clipping action */
IGRlong             *index;         /* to connect objects */
struct GRid         *clip_obj;      /* object to clip */

{
    IGRint          which_msg;      /* connect or delete */
    IGRlong         sts;            /* return code */
    struct GRid     connect_id;     /* object to send connect msg to */

    sts = OM_S_SUCCESS;

    sts = om$send (msg = message GRgraphics.GRclip
                        (msg, current_mod, target_mod, prism,
                         in, out, ovl, clip_flags),
                   senderid = NULL_OBJID,
                   targetid = clip_obj->objid,
                   targetos = clip_obj->osnum);

    if (sts & *msg & 1)
    {
        if (*msg == GR_I_OBJINSIDE)
        {
            which_msg = (in) ? CONNECT : DELETE;
            if (in) connect_id = *in;
#ifdef DEBUG
            printf ("GRclip_connect: object inside, ");
#endif
        }
        else if (*msg == GR_I_OBJOUTSIDE)
        {
            which_msg = (out) ? CONNECT : DELETE;
            if (out) connect_id = *out;
#ifdef DEBUG
            printf ("GRclip_connect: object outside, ");
#endif
        }
        else
        {
            which_msg = NO_MESSAGE;
#ifdef DEBUG
            printf ("GRclip_connect: object clipped\n");
#endif
        }

        if (which_msg == CONNECT)
        {
#ifdef DEBUG
            printf ("connecting\n");
#endif
            sts = om$send (msg = message GRconnector.GRrigidconn
                                (msg, &connect_id, index),
                           senderid = NULL_OBJID,
                           targetid = clip_obj->objid,
                           targetos = clip_obj->osnum);
        }
        else if (which_msg == DELETE)
        {
#ifdef DEBUG
            printf ("deleting\n");
#endif
            sts = om$send (msg = message GRgraphics.GRdelete (msg, current_mod),
                           senderid = NULL_OBJID,
                           targetid = clip_obj->objid,
                           targetos = clip_obj->osnum);
        }
    }

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRclip_connect: msg = %#x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}
end implementation GRgraphics;
