/*
Name
        COgetwin

Description
        This function will return the name and/or id of an active
        window, if any are present.  If more than one window is
        active, the one referenced by lastpoint in the dpb is
        returned.

History
        mrm     05/09/91    creation
*/

#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

IGRint COgetwin(msg, mod, window, name)
IGRint *msg;                /* <    return code */
struct GRmd_env *mod;       /* >    current mod info */
struct GRid *window;        /* <    window id/osnum */
IGRchar *name;              /* <    window name */
{
    IGRint sts, i, j, n;
    struct GRid windows[40];
    struct var_list vlist[2];
    struct EX_button point;

    /* check for active windows */

    sts = dp$get_gragad_id(msg = msg,
                           mod_GRid = mod,
                           name = "*",
                           array_size = 40,
                           total_num = &i,
                           numberofids = &n,
                           found_GRids = windows,
                           type_gragad = IGE_GG | ACTIVE_GG);
    if (sts & *msg & 1)
    {
        /* use the first window in the list */

        window->objid = windows[0].objid;
        window->osnum = windows[0].osnum;

        if (i > 1)
        {
            /*
                There is more than one window active.  Check whether
                the last one referenced is in the list of active
                windows (it could be invalid in a new design session)
                and use it. 
            */

            gr$get_last_point(buffer = &point);
            for (j = 0; j < n; j++)
            {
                if (windows[j].objid == point.objid &&
                    windows[j].osnum == point.osnum)
                {
                    window->objid = point.objid;
                    window->osnum = point.osnum;
                    break;
                }
            }
        }

        /* get the window name */

        vlist[0].var = GRAGAD_NAME;
        vlist[0].var_ptr =(IGRchar *)name;
        vlist[0].num_bytes = BUFSIZ;
        vlist[0].bytes_returned = (IGRlong *)&i;
        vlist[1].var = END_PARAM;

        sts = dp$inq_set_gragad(msg = msg,
                                which_error = &i,
                                osnum = window->osnum,
                                gragad_objid = window->objid,
                                var_list = vlist);
    }
    return (sts);
}
