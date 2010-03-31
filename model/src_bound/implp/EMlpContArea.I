/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

/*
NOTE

This method implementation uses the oid of the sender.

HISTORY
21 Sep 1990 Inasu : The commands Show/Remove Disjoint Regions used to fail 
                    due to a logical bug in the second method. It has been 
                    modified to take care of this problem.
29 Sep 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMStypedef.h"
# include "OMmacros.h"      /* IF_EQ_OBJID IF_NULL_OBJID */
# include "EMS_E.h"         /* EMS_E_OperationFailed */

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

method EMfindContiguousArea (
    IGRlong *rc;
    OM_S_OBJID adjPloopsScratchMemory[];
    struct EMStreeHeap **pp_area
)
{
    EMSrc omrc = OM_E_ABORT;
    int checkFamily = FALSE;
    int amPloop;
    OM_S_CHANSELECT chanselect;

    *rc = EMS_S_Success;

    amPloop = me^^EMSloop.lp_props & EMLP_PLOOP;

    EMSdbgMR (EMS_S_Success, "EMSloop.EMfindContiguousAreas entry");

    if (NOT *pp_area)
    {
        extern EMSrc EFtreeStart ();

        *rc = EFtreeStart (pp_area);
    }

    if (EMSokay (*rc))
    {
        if (amPloop)
        {
            extern EMSrc EFtreeAddNode ();
            extern int EFcmpInt ();

            *rc = EFtreeAddNode (
                (char *)my_id,
                EFcmpInt,
                *pp_area,
                NULL
            );

            if (*rc IS EMS_I_Found) /* already in set */
            {
                omrc = OM_S_SUCCESS;
            }
            else if (*rc IS EMS_S_Success) /* entered into set */
            {
                checkFamily = TRUE;

                omrc = EMmake_chanselect (EMSloop_to_inner, &chanselect                );

                if (EMSokay (omrc))
                {
                    /* propagate to loops adjacent to self */

                    omrc = om$send (
                        msg = message EMSloop.EMpropagateToAdjacentLoops (
                            rc,
                            adjPloopsScratchMemory,
                            message EMSloop.EMfindContiguousArea (
                                rc,
                                adjPloopsScratchMemory,
                                pp_area
                            )
                        ),
                        targetid = my_id
                    );
                }

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    /* propagate to loops adjacent to children */

                    omrc = om$send (
                        msg = message EMSloop.EMpropagateToAdjacentLoops (
                            rc,
                            adjPloopsScratchMemory,
                            message EMSloop.EMfindContiguousArea (
                                rc,
                                adjPloopsScratchMemory,
                                pp_area
                            )
                        ),
                        p_chanselect = &chanselect
                    );
                }
            } /* fi entered into set */
        }
        else /* I am a C-loop */
        {
            omrc = EMmake_chanselect (EMSloop_to_outter, &chanselect            );

            if (EMSokay (omrc)) /* made chanselect to P-loop */
            {
                OM_S_OBJECT_LINKAGE oLinkage;
                OMuint count;

                omrc = om$get_channel_objects (
                    object = me,
                    p_chanselect = &chanselect,
                    list = &oLinkage,
                    size = 1,
                    count = &count
                );
    
                if (EMSokay (omrc) AND count ISNT 1)
                {
                    omrc = OM_E_ABORT;
                }

                /*
                    Until messaging is so efficient as to be
                    quicker than this lookup, we shall check to
                    see if the P-loop is already in the list
                    before sending.

                    Simply removing this check ought to leave the
                    code working, since the P-loop's code also
                    does this check, but for more reasons.

                    Removing the next block means removing the
                    "AND *rc IS EMS_I_NotFound" clause from the
                    following if-statement.
                */

                if (EMSokay (omrc))
                {
                    extern EMSrc EFtreeFindNode ();
                    extern int EFcmpInt ();

                    *rc = EFtreeFindNode (
                        (char *)oLinkage.S_objid,
                        *pp_area,
                        EFcmpInt,
                        NULL,
                        NULL
                    );
                }

                if (EMSokay (omrc) AND *rc IS EMS_I_NotFound)
                {
                    /* send message to P-loop */

                    omrc = om$send (
                        msg = message EMSloop.EMfindContiguousArea (
                            rc,
                            adjPloopsScratchMemory,
                            pp_area
                        ),
                        targetid = oLinkage.S_objid
                    );
                }
            } /* end if made chanselect to P-loop */
        } /* end else I am a C-loop */
    }

    if (checkFamily AND EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$send (
            msg = message EMSloop.EMfindContiguousArea (
                rc,
                adjPloopsScratchMemory,
                pp_area
            ),
            p_chanselect = &chanselect
        );
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        *rc = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        if (*rc ISNT EMS_E_InsufficientDynamicMemory)
        {
            *rc = EMS_E_OperationFailed;
        }
        omrc = OM_E_ABORT;
    }

    EMSdbgMR (omrc, "EMSloop.EMfindContiguousAreas return");

    return omrc;
}

method EMpropagateToAdjacentLoops (
    IGRlong *rc;
    OM_S_OBJID adjPloopsScratchMemory[];
    OM_p_MESSAGE messageToPropagate
)
{
    IGRint numAdjLps, ii,size_of_buff;
    OM_S_OBJID *adjacentLoops,*adjacentLoopsbuff=NULL;
    EMSrc omrc;

    adjacentLoops = adjPloopsScratchMemory;

    EMSdbgMR (EMS_S_Success, "EMSloop.EMpropagateToAdjacentLoops entry");

    omrc = om$send (
        msg = message EMSloop.EMgetAdjacentLoops (
            rc              /* EMmsg */,
            NULL            /* master_list_lps */,
            NULL            /* num_master_list_lps */,
            adjacentLoops   /* adjacent_lps */,
            &numAdjLps      /* num_adj_lps */,
            NULL            /* mustHaveProps */,
            NULL            /* mustNotHaveProps */
        ),
        targetid = my_id
    );

    /* allocate memory to store the adjacent loop id's  and copy the loop
       id's into it. This is needed because  each recursive call to this
       method would overwrite the "adjPloopsScratchMemory[]" and  the current
       loop id's required for the for loop will be lost   */
  
    if(numAdjLps) 
    {
        size_of_buff = (numAdjLps * sizeof (GRobjid));

        adjacentLoopsbuff = (OM_S_OBJID *)om$malloc (
                                            size = (unsigned)( size_of_buff)
            			            );
        OM_BLOCK_MOVE(adjacentLoops,adjacentLoopsbuff,size_of_buff);
    }

    for (
        ii = 0;
        ii < numAdjLps AND EMSokay (*rc) AND EMSokay (omrc);
        ii++
    )
    {
        OM_S_OBJID adjacentLoop;

        adjacentLoop = *(adjacentLoopsbuff + ii);

        if (NOT IF_EQ_OBJID (sender_id, adjacentLoop))
        {
            omrc = om$send (
                msg = messageToPropagate,
                targetid = adjacentLoop
            );
        }
    }

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        *rc = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *rc = EMS_E_OperationFailed;
        omrc = OM_E_ABORT;
    }
   
    if (adjacentLoopsbuff) om$dealloc (ptr = adjacentLoopsbuff); 

    EMSdbgMR (omrc, "EMSloop.EMpropagateToAdjacentLoops return");

    return omrc;
}

end implementation EMSloop;
