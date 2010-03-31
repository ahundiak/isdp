/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

EFsimpleToListNodes changes a list's nodes from from simple
usages of the content pointer as the content to using the content
pointer to point at an element-with-list structure which has an
initialized list as its content.

ARGUMENT

p_lists:  a list of simple nodes which needs to be changed to a
list of nodes with lists.

RETURNED VALUES

EMS_S_Success for utter success.

EMS_I_NotFound if there were no nodes in the input list.

EMS_E_InsufficientDynamicMemory for problems allocating memory.

EMS_E_Fail if, for some reason, there are nodes in the tree but
processing them failed for reasons other than a shortage of
memory.

HISTORY

04 Oct 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMSmsgdef.h"
# include "EMS_E.h"
# include "EMSadt.h"
# include "OMprimitives.h"

EMSrc EFsimpleToListNodes (p_lists)
    struct EMStreeHeap *p_lists;
{
    EMSrc rc;
    extern EMSrc EFtreeCountNodes ();
    int count = 0;
    struct EMSelementWithList *nodeMemory = NULL;

    rc = EFtreeCountNodes (p_lists, &count);

    if (EMSokay (rc)) /* ostensibly, it is always EMS_S_Success */
    {
        if (count)
        {
            nodeMemory = (struct EMSelementWithList *)om$malloc (size =
                (unsigned)(count * sizeof (struct EMSelementWithList))
            );

            if (NOT nodeMemory)
            {
                rc = EMS_E_InsufficientDynamicMemory;
            }
        }
        else
        {
            rc = EMS_I_NotFound;
        }
    }

    if (nodeMemory)
    {
        extern EMSrc EFtreeLeftmostNode ();
        char *p_content;
        struct EMStreeNode *p_node;
        int atLeastOneWasProcessed = FALSE;

        p_lists->nodeHeap = (char *)nodeMemory;

        rc = EFtreeLeftmostNode (p_lists, &p_node, &p_content);

        while (rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeStart ();

            nodeMemory->content = p_content;

            rc = EFtreeStart (&nodeMemory->list);

            p_node->content = (char *) nodeMemory++;

            if (EMSokay (rc))
            {
                extern EMSrc EFnodeNextToRight ();

                atLeastOneWasProcessed = TRUE;

                rc = EFnodeNextToRight (p_node, &p_node, &p_content);
            }
        }

        if (EMSokay (rc))
        {
            if (atLeastOneWasProcessed)
            {
                rc = EMS_S_Success;
            }
            else
            {
                rc = EMS_E_Fail;
            }
        }
    }

    return rc;
}
