/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

/*
DESCRIPTION

Given a list of P-loops and their osnum, add their C-loops, if
any, to the list.

NOTE

This function modifies the input list of P-loops.

HISTORY

07 Dec 1988 jBk Genesis.
*/

# include "EMS.h" /* for shared libraries */

# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include <stdio.h>
#   include "EMScmacros.h"

extern int EFfprints ();

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

EMSrc EFploopListAddCloops (rc, osnum, p_list)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_list;
{
    EMSrc omrc;
    OM_S_CHANSELECT toCloops;

    /* it does not matter that *rc is not initialized */

    omrc = EMmake_chanselect (EMSloop_to_inner, &toCloops    );
    EMSdbgMR (omrc, "EFplpLtAdClp.I EMmake_chanselect");

    if (EMSokay (omrc)) /* if channel selector is okay */
    {
        extern EMSrc EFtreeLeftmostNode ();
        struct EMStreeNode *p_lpnode;
        OM_S_OBJID loop;

        *rc = EFtreeLeftmostNode (p_list, &p_lpnode, &loop);

        EMSdbgMR (*rc, "EFplpLtAdClp.I EFtreeLeftmostNode");

        while (*rc IS EMS_I_Found AND EMSokay (omrc))
        {
            IGRushort props;

            omrc = om$send (
                msg = message EMSloop.EMget_props (
                    (IGRlong *)rc,
                    &props
                ),
                targetid = loop,
                targetos = osnum,
                senderid = NULL_OBJID
            );

            EMSdbgEPS (props & EMLP_PLOOP ? "P-loop\n" : "C-loop\n");
            EMSdbgMR (*rc, "EFplpLtAdClp.I EMSloop.EMget_props *rc");
            EMSdbgMR (omrc, "EFplpLtAdClp.I EMSloop.EMget_props omrc");

            if (props & EMLP_PLOOP AND EMSokay (*rc) AND EMSokay (omrc))
            {
                omrc = om$send (
                    msg = message Rootmsg.EMaddSelfToList (
                        rc,
                        p_list
                    ),
                    targetos = osnum,
                    senderid = loop,
                    p_chanselect = &toCloops
                );

                EMSdbgMR (*rc, "EFplpLtAdClp.I EMaddSelfToList *rc");
                EMSdbgMR (omrc, "EFplpLtAdClp.I EMaddSelfToList omrc");
            }

            if (EMSokay (*rc) AND EMSokay (omrc))
            {
                extern EMSrc EFnodeNextToRight ();

                *rc = EFnodeNextToRight (p_lpnode, &p_lpnode, &loop);
            }
        }

    } /* end if channel selector is okay */

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        *rc = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *rc = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    return omrc;
}

end implementation EMSloop;
