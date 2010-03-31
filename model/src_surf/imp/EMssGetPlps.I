/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY

29 Sep 1988 jBk Genesis.
25 Aug 1992 NP  Modified for ANSI compliance. Typecast "rc" to "IGRlong *" in the
		message send "EMSloopset.EMget_loops".
*/

# include "EMS.h"
# include "EMS_E.h"

from EMSloopset import EMget_loops;

method EMgetLoops (
    EMSrc *rc;
    IGRlong option;
    int *p_count;
    struct EMStreeHeap **pp_oloops
)
{
    EMSrc omrc;
    OM_S_CHANSELECT chansel;
    GRobjid *p_loopoids = NULL;
    IGRint count = 0;

    *rc = EMS_E_OperationFailed;

    omrc = EMmake_chanselect (EMSsubbs_to_loopset, &chansel    );

    if (EMSokay (omrc))
    {
        IGRint maxint = OM_K_MAXINT;
        IGRint size = 0;

        /*
            If only the count is desired, then there is no need
            to get loop_ids, so when pp_oloops is NULL, NULL is
            passed as the loop_ids argument.
        */

        omrc = om$send (
            msg = message EMSloopset.EMget_loops (
                (IGRlong *)rc                   /* EMmsg */,
                option                          /* option */,
                &maxint                         /* depth */,
                pp_oloops ? &p_loopoids : NULL  /* loop_ids */,
                NULL                            /* props */,
                &size                           /* buf_size */,
                &count                          /* count */
            ),
            p_chanselect = &chansel
        );
    }

    if (count AND EMSokay (omrc) AND EMSokay (*rc))
    {
        if (pp_oloops AND NOT *pp_oloops)
        {
            extern EMSrc EFtreeStart ();

            *rc = EFtreeStart (pp_oloops);
        }

        if (p_count) *p_count += count;
    }

    if (pp_oloops AND EMSokay (omrc) AND EMSokay (*rc) AND count)
    {
        int ii;
        GRobjid *ptr;

        for (ptr = p_loopoids, ii = 0; ii < count AND EMSokay (*rc); ii++)
        {
            extern EMSrc EFtreeAddNode ();
            extern int EFcmpInt ();

            *rc = EFtreeAddNode (
                (char *)(*ptr++),
                EFcmpInt,
                *pp_oloops,
                NULL
            );
        }

        om$dealloc (ptr = p_loopoids);
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }
    else
    {
        omrc = OM_E_ABORT;
        switch (*rc)
        {
            case EMS_E_InsufficientDynamicMemory:
                break;
            case EMS_E_DynamicMemoryAllocated:
                *rc = EMS_E_InsufficientDynamicMemory;
                break;
            default:
                *rc = EMS_E_OperationFailed;
        }
    }

    return omrc;
}

end implementation EMSsubbs;
