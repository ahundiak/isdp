/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
DESCRIPTION

Given a list whose elements are surfaces objects with boundary
lists, EFcompositeSurfacesWithSurfaceLists makes a list of the
composite surfaces which reference the surfaces that have all
their active loops in their list.  For elements in the input list
whose surfaces have all their loops in their sublists, their
sublists of loops shall be removed and deallocated.

Each node in the composite surface list has a sublist of the
surfaces (that had all their loops in their sublists) which
reference the composite surface of the node.  The first (and,
hopefully, only) heap of each sublist is part of allocated memory
pointed to by the nodeHeap field of the first heap of the
composite surface list.

ARGUMENTS

rc:  pointer to returned message code.

osnum:  object space of the loop objects.

p_surfs:  list of surface objects with sublists of loops.  Can be
modified if any of the sublists contain all the loops of their
surfaces.  In these cases, the sublist is removed and
deallocated.

pp_comps:  pointer to returned list of composite surfaces. 
*pp_comps will remain unchanged if there are no surfaces which
have all their loops in their sublists.

ALGORITHM

EFcompositeSurfacesWithSurfaceLists invokes
EFsurfacesGatheringBoundaryLists to create alist of referenced
composite surfaces.  Then it invokes EFsimpleToListNodes to
change the nodes of the referenced composite surface list to be
nodes containing initialized, empty sublists. 
EFsurfacesGatheringBoundaryLists is invoked again to fill each
sublist with the referencing surfaces of its node's referenced
composite surface.

HISTORY

27 Aug 1992 NP    Modified for ANSI compliance. Added typecast.
20 july '90 Inasu Initialized the return code 'omrc to OM_S_SUCCESS'
                  in the function EFcsWSfLtNextThingAlter().
                  (Fix for TR 90n1532).

05 Jan 1989 jBk If *pp_comps is NULL after the first pass through
                EFsurfacesGatheringBoundaryLists, then further
                processing by this function is unnecessary.
                Therefore, I added a check for *pp_comps at that
                point.
09 Dec 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMSmsgdef.h"
# include "EMSadt.h"
# include "EMSopt.h" /* EMS_OPT_ALL */

EMSrc EFcompositeSurfacesWithSurfaceLists (rc, osnum, p_surfs, pp_comps)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_surfs;
    struct EMStreeHeap **pp_comps;
{
    EMSrc omrc;
    extern EMSrc EFsurfacesGatheringBoundaryLists ();
    OM_S_OBJID relatedId;
    OM_S_MESSAGE thingMessage;
    struct EMSsubbs_EMgetowner_Msg thingArglist;

    *rc = EMS_E_Fail;

    thingArglist.EMmsg = (IGRlong *)rc;
    thingArglist.owner_id = &relatedId;
    thingArglist.immediate_owner = TRUE;

    omrc = om$make_message (
        classname = "EMSsubbs",
        methodname = "EMgetowner",
        size = sizeof (struct EMSsubbs_EMgetowner_Msg),
        p_arglist = &thingArglist,
        p_msg = &thingMessage
    );

    if (EMSokay (omrc))
    {
        EMSrc EFcsWSfLtFirstThingAlter (), EFcsWSfLtNextThingAlter ();

        omrc = EFsurfacesGatheringBoundaryLists (
            rc,
            EFcsWSfLtFirstThingAlter,
            EFcsWSfLtNextThingAlter,
            &thingMessage,
            &relatedId,
            osnum,
            p_surfs,
            pp_comps
        );
    }

    if (*pp_comps AND EMSokay (omrc) AND EMSokay (*rc))
    {
        extern EMSrc EFsimpleToListNodes ();

        *rc = EFsimpleToListNodes (*pp_comps);

        if (EMSokay (*rc))
        {
            EMSrc EFcsWSfLtFirstThingCheck (), EFcsWSfLtNextThingCheck ();

            omrc = EFsurfacesGatheringBoundaryLists (
                rc,
                EFcsWSfLtFirstThingCheck,
                EFcsWSfLtNextThingCheck,
                &thingMessage,
                &relatedId,
                osnum,
                p_surfs,
                pp_comps
            );
        }
    }

    return omrc;
}

EMSrc EFcsWSfLtTestCounts (rc, surfId, surfOs, p_lpList, p_different)
    EMSrc *rc;
    OM_S_OBJID surfId;
    OMuword surfOs;
    struct EMStreeHeap *p_lpList;
    IGRboolean *p_different;
{
    EMSrc omrc = OM_E_ABORT;
    int ndCount = 0, msCount = 0;
    extern EMSrc EFtreeCountNodes ();

    *rc = EFtreeCountNodes (
        p_lpList,
        &ndCount
    );

    if (*rc IS EMS_S_Success)
    {
        omrc = om$send (
            msg = message EMSsurface.EMgetLoops (
                rc,
                (IGRlong)EMS_OPT_ALL,
                &msCount,
                NULL
            ),
            senderid = NULL_OBJID,
            targetid = surfId,
            targetos = surfOs
        );

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            *p_different = msCount ISNT ndCount;
        }
    }

    return omrc;
}

/*
    Except that EFcsWSfLtNextThingAlter calls EFnodeNextToRight
    instead of EFtreeLeftmostNode, it is identical to
    EFcsWSfLtFirstThingAlter.
*/

EMSrc EFcsWSfLtFirstThingAlter (
    rc,
    osnum,
    p_ltA,
    pp_ltANode,
    p_surf
)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_ltA;
    struct EMStreeNode **pp_ltANode;
    OM_S_OBJID *p_surf;
{
    EMSrc omrc = OM_S_SUCCESS;
    extern EMSrc EFtreeLeftmostNode ();
    struct EMSelementWithList *p_sfWLps;

    *rc = EFtreeLeftmostNode (p_ltA, pp_ltANode, &p_sfWLps);

    if (*rc IS EMS_I_Found) /* found left most node */
    {
        IGRboolean different;
        EMSrc EFcsWSfLtTestCounts ();

        *p_surf = (OM_S_OBJID)p_sfWLps->content;

        omrc = EFcsWSfLtTestCounts (
            rc,
            *p_surf,
            osnum,
            p_sfWLps->list,
            &different
        );

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            if (different)
            {
                EMSrc EFcsWSfLtNextThingAlter ();

                omrc = EFcsWSfLtNextThingAlter (
                    rc,
                    osnum,
                    *pp_ltANode,
                    pp_ltANode,
                    p_surf
                );
            }
            else
            {
                extern EMSrc EFtreeEnd ();

                *rc = EFtreeEnd (p_sfWLps->list);

                if (*rc IS EMS_S_Success)
                {
                    p_sfWLps->list = NULL;
                    *rc = EMS_I_Found;
                }
            }
        }
    } /* end if found left most node */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
    }

    return omrc;
}

EMSrc EFcsWSfLtNextThingAlter (
    rc,
    osnum,
    p_currentNode,
    pp_nextNode,
    p_surf
)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeNode *p_currentNode;
    struct EMStreeNode **pp_nextNode;
    OM_S_OBJID *p_surf;
{
    EMSrc omrc = OM_S_SUCCESS ;
    extern EMSrc EFnodeNextToRight ();
    struct EMSelementWithList *p_sfWLps;

    *rc = EFnodeNextToRight (p_currentNode, pp_nextNode, &p_sfWLps);

    if (*rc IS EMS_I_Found) /* found next node */
    {
        IGRboolean different;
        EMSrc EFcsWSfLtTestCounts ();

        *p_surf = (OM_S_OBJID)p_sfWLps->content;

        omrc = EFcsWSfLtTestCounts (
            rc,
            *p_surf,
            osnum,
            p_sfWLps->list,
            &different
        );

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            if (different)
            {
                EMSrc EFcsWSfLtNextThingAlter ();

                omrc = EFcsWSfLtNextThingAlter (
                    rc,
                    osnum,
                    *pp_nextNode,
                    pp_nextNode,
                    p_surf
                );
            }
            else
            {
                extern EMSrc EFtreeEnd ();

                *rc = EFtreeEnd (p_sfWLps->list);

                if (*rc IS EMS_S_Success)
                {
                    p_sfWLps->list = NULL;
                    *rc = EMS_I_Found;
                }
            }
        }
    } /* end if found next node */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
    }

    return omrc;
}

/*
    Except that EFcsWSfLtNextThingCheck calls EFnodeNextToRight
    instead of EFtreeLeftmostNode, it is identical to
    EFcsWSfLtFirstThingCheck.
*/

EMSrc EFcsWSfLtFirstThingCheck (
    rc,
    osnum,
    p_ltA,
    pp_ltANode,
    p_surf
)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_ltA;
    struct EMStreeNode **pp_ltANode;
    OM_S_OBJID *p_surf;
{
    extern EMSrc EFtreeLeftmostNode ();
    struct EMSelementWithList *p_sfWLps;

    *rc = EFtreeLeftmostNode (p_ltA, pp_ltANode, &p_sfWLps);

    if (*rc IS EMS_I_Found) /* found left most node */
    {
        if (p_sfWLps->list) /* has a list; try again */
        {
            EMSrc EFcsWSfLtNextThingCheck ();

            (void)EFcsWSfLtNextThingCheck (
                rc,
                osnum,
                *pp_ltANode,
                pp_ltANode,
                p_surf
            );
        }
        else
        {
            *p_surf = (OM_S_OBJID)p_sfWLps->content;
        }
    } /* end if found left most node */

    return OM_S_SUCCESS;
}

EFcsWSfLtNextThingCheck (
    rc,
    osnum,
    p_currentNode,
    pp_nextNode,
    p_surf
)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeNode *p_currentNode;
    struct EMStreeNode **pp_nextNode;
    OM_S_OBJID *p_surf;
{
    extern EMSrc EFnodeNextToRight ();
    struct EMSelementWithList *p_sfWLps;

    *rc = EFnodeNextToRight (p_currentNode, pp_nextNode, &p_sfWLps);

    if (*rc IS EMS_I_Found) /* found next node */
    {
        if (p_sfWLps->list) /* has a list; try again */
        {
            EMSrc EFcsWSfLtNextThingCheck ();

            (void)EFcsWSfLtNextThingCheck (
                rc,
                osnum,
                *pp_nextNode,
                pp_nextNode,
                p_surf
            );
        }
        else
        {
            *p_surf = (OM_S_OBJID)p_sfWLps->content;
        }
    } /* end if found next node */

    return OM_S_SUCCESS;
}

end implementation EMSsubbs;
