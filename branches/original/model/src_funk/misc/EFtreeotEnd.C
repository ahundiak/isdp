/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
DESCRIPTION

EFtreeOfTreesEnd deallocates the memory used by the input tree of
trees.

ARGUMENT

p_tot:  pointer to a tree wherein the content pointers each point
to a tree.  Since EFtreeOfTreesEnd is implemented via repeated
calls to EFtreeEnd, it is all right for the content pointers of
the input tree to point to NULL instead of to trees.

RETURNED VALUES

EMS_S_Success if all goes well.

EMS_E_InvalidArg if p_tot is NULL.

DESCRIPTION

EFtreeOfEwlEnd deallocates the memory used by the input tree of
elements with lists.

ARGUMENT

p_toEwl:  pointer to a tree wherein the content pointers each
point to an element with a list.  If the nodeHeap field of
*p_toEwl is non-NULL, it is assumed to be the memory used for the
element-with-list structures in each node and will be deallocated
herein.

RETURNED VALUES

EMS_S_Success if all goes well.

EMS_E_InvalidArg if p_toEwl is NULL.

HISTORY

29 Nov 1988 jBk Genesis.
*/

/* for shared libraries */
# include "EMS.h"

/* om$dealloc */
# include "OMprimitives.h"

/* IS EMSokay */
# include "EMSlogic.h"

/* EMStreeNode EMStreeHeap EMSteInHeap */
# include "EMSadt.h"

/* EMS message code definitions */
# include "EMSmsgdef.h"

/* EMSrc */
# include "EMStypedef.h"

EMSrc EFtreeOfTreesEnd (p_tot)
    struct EMStreeHeap *p_tot;
{
    EMSrc rc;
    struct EMStreeHeap *p_tree;
    struct EMStreeNode *p_totnode = NULL;

    /*
        I set p_totnode to NULL and EFtreeLeftmostNode returns
        EMS_E_InvalidArg if both p_tot and p_totnode are NULL
    */

    /* intentional block */
    {
        extern EMSrc EFtreeLeftmostNode ();

        rc = EFtreeLeftmostNode (p_tot, &p_totnode, &p_tree);
    }

    while (rc IS EMS_I_Found)
    {
        rc = EFtreeEnd (p_tree);

        if (EMSokay (rc))
        {
            rc = EFnodeNextToRight (
                p_totnode,
                &p_totnode,
                &p_tree
            );
        }
    }

    if (EMSokay (rc))
    {
        rc = EFtreeEnd (p_tot);
    }

    return rc;
}

EMSrc EFtreeOfEwlEnd (p_toEwl)
    struct EMStreeHeap *p_toEwl;
{
    EMSrc rc;
    struct EMSelementWithList *p_ewl;
    struct EMStreeNode *p_toEwlNode = NULL;

    /*
        I set p_toEwlNode to NULL and EFtreeLeftmostNode returns
        EMS_E_InvalidArg if both p_toEwl and p_toEwlNode are NULL
    */

    /* intentional block */
    {
        extern EMSrc EFtreeLeftmostNode ();

        rc = EFtreeLeftmostNode (p_toEwl, &p_toEwlNode, &p_ewl);
    }

    while (rc IS EMS_I_Found)
    {
        if (p_ewl) rc = EFtreeEnd (p_ewl->list);

        if (EMSokay (rc))
        {
            rc = EFnodeNextToRight (
                p_toEwlNode,
                &p_toEwlNode,
                &p_ewl
            );
        }
    }

    if (EMSokay (rc))
    {
        if (p_toEwl->nodeHeap) om$dealloc (ptr = p_toEwl->nodeHeap);

        rc = EFtreeEnd (p_toEwl);
    }

    return rc;
}
