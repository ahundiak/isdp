/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

/*
HISTORY

29 Sep 1988 jBk Genesis.
21 Aug 1992 NP  Modified for ANSI compliance.

*/

# include "EMS.h"       /* for sharables */

# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include <stdio.h>
#   include "EMScmacros.h"

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
# else
#   define EMSdbgMR(rc, string)
# endif

# include "EMSopt.h"    /* EMS_OPT_PLOOP */

from EMSloop import EMfindContiguousArea;

method EMgetContiguousAreas (
    EMSrc *rc;
    struct EMStreeHeap **pp_areas
)
{
    EMSrc omrc;
    struct EMStreeHeap *p_ploops = NULL;
    int totalNumPloops = 0;

    EMSdbgMR (EMS_S_Success, "EMSsurface.EMgetContiguousAreas entry");

    omrc = om$send (
        msg = message EMSsurface.EMgetLoops (
            rc,
            EMS_OPT_PLOOP,
            &totalNumPloops,
            &p_ploops
        ),
        targetid = my_id
    );

    EMSdbgMR (omrc, "EMSsurface.EMgetPloops omrc");
    EMSdbgMR (*rc, "EMSsurface.EMgetPloops *rc");
    EMSdbgMR (*rc, p_ploops ? "p_ploops okay" : "p_ploops NULL");

    if (p_ploops AND EMSokay (omrc) AND EMSokay (*rc))
    /* got list of P-loops */
    {
        OM_S_OBJID *adjacentLoops = NULL;

        if (NOT *pp_areas)
        {
            extern EMSrc EFtreeStart ();

            *rc = EFtreeStart (pp_areas);
        }

        if (EMSokay (*rc))
        {
            adjacentLoops = (OM_S_OBJID *) om$malloc (
                size = (unsigned)(totalNumPloops * 2 * sizeof (GRobjid))
            );

            if (NOT adjacentLoops) *rc = EMS_E_NoDynamicMemory;
        }

        if (EMSokay (*rc)) do
        /* until there are no elements left in set of P-loops */
        {
            extern EMSrc EFtreeLeftmostNode ();
            OM_S_OBJID ploop;

            *rc = EFtreeLeftmostNode (p_ploops, NULL, (char **)&ploop);

            if (*rc IS EMS_I_Found)
            /* got leftmost node in set P-loops */
            {
                struct EMStreeHeap *p_area = NULL;
                struct EMStreeNode *p_ploopnodeInArea;

                omrc = om$send (
                    msg = message EMSloop.EMfindContiguousArea (
                        (IGRlong *)rc,  /* rc */
                        adjacentLoops,  /* adjPloopsScratchMemory */
                        &p_area         /* pp_area */
                    ),
                    targetid = ploop
                );

                EMSdbgMR (omrc, "EMSloop.EMfindContiguousArea omrc");
                EMSdbgMR (*rc, "EMSloop.EMfindContiguousArea *rc");

                if (EMSokay (*rc) AND EMSokay (omrc))
                /* got area contiguous to ploop */
                {
                    if (p_area)
                    {
                        EMSrc EFstackPushNode ();

                        *rc = EFstackPushNode ((char *)p_area, *pp_areas);
                    }
                    else
                    {
                        *rc = EMS_E_Fail;
                    }
                }
                /* fi got area contiguous to ploop */

                if (EMSokay (*rc) AND EMSokay (omrc))
                {
                    extern EMSrc EFtreeLeftmostNode ();

                    *rc = EFtreeLeftmostNode (
                        p_area,
                        &p_ploopnodeInArea,
                        (char **)&ploop
                    );
                }

                if (EMSokay (omrc)) while (*rc IS EMS_I_Found)
                /* iterate over each member of p_area */
                {
                    extern EMSrc EFtreeFindNode ();
                    extern int EFcmpInt ();
                    struct EMStreeNode *p_node;

                    *rc = EFtreeFindNode (
                        (char *)ploop,
                        p_ploops,
                        EFcmpInt,
                        &p_node,
                        NULL
                    );

                    if (*rc IS EMS_I_Found)
                    {
                        extern EMSrc EFtreeExciseNode ();

                        *rc = EFtreeExciseNode (p_ploops, p_node);
                    }
                    else
                    {
                        *rc = EMS_E_Fail;
                    }

                    if (EMSokay (*rc))
                    {
                        extern EMSrc EFnodeNextToRight ();

                        *rc = EFnodeNextToRight (
                            p_ploopnodeInArea,
                            &p_ploopnodeInArea,
                            (char **)&ploop
                        );

                        if (*rc IS EMS_I_NotFound)
                        {
                            *rc = EMS_S_Success;
                        }
                    }
                }
                /* done iterate over each member of p_area */
            }
            /* fi got leftmost node in set P-loops */
        } while (*rc IS EMS_S_Success AND EMSokay (omrc));
        /* until there are no elements left in set of P-loops */

        if (adjacentLoops)
        {
            om$dealloc (ptr = adjacentLoops);
        }
    }
    /* fi got list of P-loops */

    if (p_ploops)
    {
        extern EMSrc EFtreeEnd ();

        (void)EFtreeEnd (p_ploops);
    }

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        *rc = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        if (*rc ISNT EMS_E_NoDynamicMemory)
            *rc = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    EMSdbgMR (omrc, "EMSsurface.EMgetContiguousAreas return");

    return omrc;
}

end implementation EMSsurface;
