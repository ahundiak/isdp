/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
/*
ALGORITHM

Get connectable edges.  As a side effect, one gets the count of
connectable edges.

If there are any connectable edges, the surface is not closed.

Free any memory allocated for connectable edges.

HISTORY

16-May-1988 jBk Added env argument.
14-Apr-1988 jBk Genesis.
*/

/* EMS_OPT_CONNECTABLE */
# include "EMSopt.h"

/* EMS_E_FailIsSurfClosed */
# include "EMS_E.h"

method EMisClosed (
    IGRlong *EMmsg;
    struct GRmd_env env[1]; /* unused in this implementation */
    IGRboolean *isClosed
)
{
    EMSrc omrc;
    struct GRid *edges = NULL;
    IGRint buf_size = 0, num_edges = 0;

    omrc = om$send (
        msg = message EMSsurface.EMgetedges (
            EMmsg,
            (IGRlong)EMS_OPT_CONNECTABLE,
            &edges,
            &buf_size,
            &num_edges,
            NULL,
            NULL,
            NULL,
            NULL
        ),
        targetid = my_id
    );

    *isClosed = NOT num_edges;

    if (edges) om$dealloc (ptr = edges);

    if (EMSokay (omrc) AND EMSokay (*EMmsg))
    {
        omrc = OM_S_SUCCESS;
        *EMmsg = EMS_S_Success;
    }
    else
    {
        omrc = OM_E_ABORT;
        *EMmsg = EMS_E_FailIsSurfClosed;
    }

    return omrc;
}

end implementation EMSsurface;
