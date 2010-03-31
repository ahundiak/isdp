/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
DESCRIPTION

Copy information from tree of elements with lists to arrays.

ARGUMENTS

p_treeOfEwl:  input list of elements with lists.

contents:  array of copies of content pointers of those nodes
which have non-NULL sublist pointers.

ewlNumNodes:  array of number of elements in each non-NULL
sublist.

ewlContents:  array of copies of content pointers of the
sublists.

NOTE

Memory for all these lists must be allocated prior to invocation
of this function.

HISTORY

13 Dec 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMSmsgdef.h"
# include "EMSlogic.h"
# include "EMSadt.h"
# include "EMStypedef.h"

EMSrc EFtreeOfEwlToArrays (
    p_treeOfEwl,
    contents,
    ewlNumNodes,
    ewlContents
)
    struct EMStreeHeap *p_treeOfEwl;
    char **contents;
    int *ewlNumNodes;
    char **ewlContents;
{
    EMSrc rc;
    extern EMSrc EFtreeLeftmostNode ();
    extern EMSrc EFnodeNextToRight ();
    struct EMStreeNode *p_node;
    struct EMSelementWithList *p_ewl;

    rc = EFtreeLeftmostNode (
        p_treeOfEwl,
        &p_node,
        &p_ewl
    );

    while (rc IS EMS_I_Found)
    {
        if (p_ewl->list)
        {
            int localEwlNumNodes = 0;
            struct EMStreeNode *p_subNode;
            char *p_subContent;

            *contents++ = p_ewl->content;

            rc = EFtreeLeftmostNode (
                p_ewl->list,
                &p_subNode,
                &p_subContent
            );

            while (rc IS EMS_I_Found)
            {
                localEwlNumNodes++;
                *ewlContents++ = p_subContent;

                rc = EFnodeNextToRight (
                    p_subNode,
                    &p_subNode,
                    &p_subContent
                );
            }

            *ewlNumNodes++ = localEwlNumNodes;
        }

        if (EMSokay (rc))
        {
            rc = EFnodeNextToRight (
                p_node,
                &p_node,
                &p_ewl
            );
        }
    }

    return rc;
}
