/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
/*
ALGORITHM

If there is no loopset, make one.

Send message with respect to ancestor classes.

HISTORY

24-Aug-92   NP  Modified for ANSI compliance. Change "count" variable to "IGRuint".
19-May-1988 jBk Fixed an oversight in assignment of *EMmsg when
                a loopset is already present.
16-May-1988 jBk Genesis.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

/* EMS_E_FailIsSurfClosed */
# include "EMS_E.h"

method EMisClosed (
    IGRlong *EMmsg;
    struct GRmd_env env[1];
    IGRboolean *isClosed
)
{
    EMSrc omrc;

    /* intentional block */
    {
        OM_S_CHANSELECT EMSsubbs_to_loopset_addr;
        IGRuint count;

        EMSsubbs_to_loopset_addr.type = OM_e_addr;
        EMSsubbs_to_loopset_addr.u_sel.addr = &me^^EMSsubbs.to_loopset;

#       if DEBUG
            EFfprints (NULL, "get channel count\n");
#       endif

        omrc = om$get_channel_count (
            object = me,
            p_chanselect = &EMSsubbs_to_loopset_addr,
            count = &count
        );

#       if DEBUG
            EFfprints (NULL, "got channel count\n");
#       endif

        if (EMSokay (omrc))
        {
            *EMmsg = EMS_S_Success;

            if (count IS 0)
            {
#               if DEBUG
                    EFfprints (NULL, "make natural boundary\n");
#               endif

                omrc = om$send (
                    msg = message EMSsurface.EMmk_nat_bdry (
                        EMmsg,
                        &env->md_env,
                        NULL
                    ),
                    targetid = my_id
                );

#               if DEBUG
                    EFfprints (NULL, "made natural boundary\n");
#               endif
            } /* end if count IS 0 */
        }
    }

#   if DEBUG
        (void)EFmsgReport (NULL, omrc, "EMssClosed nat bdry omrc");
        (void)EFmsgReport (NULL, *EMmsg, "EMssClosed nat bdry rc");
#   endif

    if (EMSerror (omrc) OR EMSerror (*EMmsg))
    {
        omrc = OM_E_ABORT;
        *EMmsg = EMS_E_FailIsSurfClosed;
    }
    else
    {
        omrc = om$send (
            mode = OM_e_wrt_parent,
            msg = message EMSsubbs.EMisClosed (
                EMmsg,
                env,
                isClosed
            ),
            targetid = my_id
        );
    }

#   if DEBUG
        (void)EFmsgReport (NULL, omrc, "EMssClosed exit omrc");
        (void)EFmsgReport (NULL, *EMmsg, "EMssClosed exit rc");
#   endif

    return omrc;
}

end implementation EMSsubbs;
