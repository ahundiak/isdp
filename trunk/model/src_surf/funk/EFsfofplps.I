/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

/*
DESCRIPTION

Given a list of boundary objects, EFsurfacesWithBoundaryLists
makes a list of the surfaces which reference the boundaries. 
Each node in the surface list has a sublist of the boundaries
which reference the surface of the node.  The first (and,
hopefully, only) heap of each sublist is part of allocated memory
pointed to by the nodeHeap field of the first heap of the surface
list.

Given a list of things (A), a function for find the first A, a
function for finding the next A and a message to send to a
thing to find a related thing (B), EFsurfacesGatheringBoundaryLists
makes a list of B's which are related to the A's.  If the
nodeHeap field of the A list is non-NULL, then the content field
of each node of the A list is assumed to point to an element
containing a sublist of B's to which the B's referencing the A of
the node are added.

ARGUMENTS

rc:  pointer to returned message code.

firstThing:  pointer to function returning the node and content
of the first appropriate element of the input list.

nextThing:  pointer to function returning the node and content
of the next appropriate element of the input list.

thingMessage:  message to send to a thing (A) to get its related
thing (B) in whose output list the A is supposed to appear.

p_relatedId:  pointer to OM_S_OBJID used in thingMessage.

osnum:  object space of the loop objects.

p_ploops:  list of loop objects.  Possibly modified by the
finding functions used in EFsurfacesGatheringBoundaryLists, but
not as used by EFsurfacesWithBoundaryLists.

pp_surfs:  pointer to returned list of surfaces.  From
EFsurfacesGatheringBoundaryLists with a non-NULL nodeHeap and from
EFsurfacesWithBoundaryLists, the surface list has sublists of
referencing boundaries.

ALGORITHM

EFsurfacesWithBoundaryLists invokes
EFsurfacesGatheringBoundaryLists to create alist of referenced
surfaces.  Then it invokes EFsimpleToListNodes to change the
nodes of the referenced surface list to be nodes containing
initialized, empty sublists.  EFsurfacesGatheringBoundaryLists is
invoked again to fill each sublist with the referencing
boundaries of its node's referenced surface.

NOTE

The boundary objects are referenced by variables named something
like "ploop" because this function was originally conceived to
work for P-loops.  The boundary objects could be of any subclass
of EMSboundary.

HISTORY

04 Oct 1988 jBk Genesis.
27 Aug 1992 NP  Modified for ANSI compliance.
*/

# include "EMS.h"
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMSmsgdef.h"
# include "EMSadt.h"

EMSrc EFsurfacesWithBoundaryLists (rc, osnum, p_ploops, pp_surfs)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_ploops;
    struct EMStreeHeap **pp_surfs;
{
    EMSrc omrc;
    EMSrc EFsurfacesGatheringBoundaryLists ();
    OM_S_OBJID relatedId;
    OM_S_MESSAGE thingMessage;
    struct EMSboundary_EMgetsurface_info_Msg thingArglist;

    *rc = EMS_E_Fail;

    thingArglist.EMmsg = (IGRlong *)rc;
    thingArglist.srfid = &relatedId;
    thingArglist.partolbasis = NULL;

    omrc = om$make_message (
        classname = "EMSloop",
        methodname = "EMgetsurface_info",
        size = sizeof (struct EMSboundary_EMgetsurface_info_Msg),
        p_arglist = &thingArglist,
        p_msg = &thingMessage
    );

    if (EMSokay (omrc))
    {
        EMSrc EFsfWBdLtFirstThing (), EFsfWBdLtNextThing ();

        omrc = EFsurfacesGatheringBoundaryLists (
            rc,
            EFsfWBdLtFirstThing,
            EFsfWBdLtNextThing,
            &thingMessage,
            &relatedId,
            osnum,
            p_ploops,
            pp_surfs
        );
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        extern EMSrc EFsimpleToListNodes ();

        *rc = EFsimpleToListNodes (*pp_surfs);

        if (EMSokay (*rc))
        {
            EMSrc EFsfWBdLtFirstThing (), EFsfWBdLtNextThing ();

            omrc = EFsurfacesGatheringBoundaryLists (
                rc,
                EFsfWBdLtFirstThing,
                EFsfWBdLtNextThing,
                &thingMessage,
                &relatedId,
                osnum,
                p_ploops,
                pp_surfs
            );
        }
    }

    return omrc;
}

EMSrc EFsfWBdLtFirstThing (rc, osnum, p_ltA, pp_ltANode, pp_ltAContent)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeHeap *p_ltA;
    struct EMStreeNode **pp_ltANode;
    char **pp_ltAContent;
{
    EMSrc omrc;
    extern EMSrc EFtreeLeftmostNode ();

    /* osnum is ignored by this function */

    *rc = EFtreeLeftmostNode (p_ltA, pp_ltANode, pp_ltAContent);

    if (EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
    }

    return omrc;
}

EFsfWBdLtNextThing (rc, osnum, p_currentNode, pp_nextNode, pp_nextContent)
    EMSrc *rc;
    OMuword osnum;
    struct EMStreeNode *p_currentNode;
    struct EMStreeNode **pp_nextNode;
    char **pp_nextContent;
{
    EMSrc omrc;
    extern EMSrc EFnodeNextToRight ();

    /* osnum is ignored by this function */

    *rc = EFnodeNextToRight (p_currentNode, pp_nextNode, pp_nextContent);

    if (EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
    }

    return omrc;
}

EMSrc EFsurfacesGatheringBoundaryLists (
    rc,
    firstThing,
    nextThing,
    thingMessage,
    p_relatedId,
    osnum,
    p_ploops,
    pp_surfs
)
    EMSrc *rc;
    EMSrc (*firstThing) ();
    EMSrc (*nextThing) ();
    OM_p_MESSAGE thingMessage;
    OM_S_OBJID *p_relatedId;
    OMuword osnum;
    struct EMStreeHeap *p_ploops;
    struct EMStreeHeap **pp_surfs;
{
    EMSrc omrc = OM_E_ABORT;
    struct EMStreeNode *p_node;
    OM_S_OBJID ploop;

    omrc = firstThing (rc, osnum, p_ploops, &p_node, (char **)&ploop);

    if (*rc IS EMS_I_Found)
    {
        if (NOT *pp_surfs)
        {
            extern EMSrc EFtreeStart ();

            *rc = EFtreeStart (pp_surfs);
        }

        if (EMSokay (*rc))
        {
            int nodeHeapExists = FALSE;

            nodeHeapExists = (int)(**pp_surfs).nodeHeap;

        do
        {
            omrc = om$send (
                msg = thingMessage,
                targetid = ploop,
                targetos = osnum,
                senderid = NULL_OBJID
            );

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                extern EMSrc EFtreeAddNode ();
                extern int EFcmpStarInt (), EFcmpInt ();
                int (*cmpFunction) ();
                struct EMSelementWithList surfoidlist;
                struct EMStreeNode *p_surfoidlistnode;
                char *charPtr;

                if (nodeHeapExists)
                {
                    surfoidlist.content = (char *)(*p_relatedId);
/*                  surfoidlist.list does not matter here */
                    cmpFunction = EFcmpStarInt;
                    charPtr = (char *)&surfoidlist;
                }
                else
                {
                    cmpFunction = EFcmpInt;
                    charPtr = (char *)(*p_relatedId);
                }

                *rc = EFtreeAddNode (
                    charPtr,
                    cmpFunction,
                    *pp_surfs,
                    &p_surfoidlistnode
                );

                if (nodeHeapExists AND EMSokay (*rc))
                {
                    if (*rc ISNT EMS_I_Found)
                    {
                        *rc = EMS_E_Fail;
                    }
                    else
                    {
                        extern int EFcmpInt ();
                        struct EMSelementWithList *p_surfelem;
                        struct EMStreeHeap *p_surflplist;

                        p_surfelem = (struct EMSelementWithList *)
                            p_surfoidlistnode->content;

                        p_surflplist = p_surfelem->list;

                        *rc = EFtreeAddNode (
                            (char *)ploop,
                            EFcmpInt,
                            p_surflplist,
                            NULL
                        );
                    }
                }

                if (EMSokay (*rc))
                {
                    omrc = nextThing (
                        rc,
                        osnum,
                        p_node,
                        &p_node,
                        (char **)&ploop
                    );
                }
            }
        } while (EMSokay (omrc) AND *rc IS EMS_I_Found);
        }
    }

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
