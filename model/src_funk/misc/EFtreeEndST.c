/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMSmsgdef.h"
# include "EMSadt.h"

EMSrc EFtreeEndSubTrees (p_treeOfTrees)
struct EMStreeHeap *p_treeOfTrees;
{
    extern EFtreeLeftmostNode ();
    EMSrc rc;
    struct EMStreeNode *p_node = NULL;
    struct EMStreeHeap *p_subTree = NULL;

    rc = EFtreeLeftmostNode (
        p_treeOfTrees,
        &p_node,
        &p_subTree
    );

    while (rc IS EMS_I_Found)
    {
        extern EMSrc EFtreeEnd ();

        p_node->content = NULL;

        rc = EFtreeEnd (p_subTree);

        if (EMSokay (rc))
        {
            extern EMSrc EFnodeNextToRight ();

            rc = EFnodeNextToRight (
                p_node,
                &p_node,
                &p_subTree
            );
        }
    }

    return rc;
}
