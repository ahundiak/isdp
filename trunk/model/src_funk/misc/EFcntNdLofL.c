/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
DESCRIPTION

Given a list of lists, EFcountNodesInListOfElementsWithLists
counts the total number of nodes in all the lists of the nodes of
the input list.

ARGUMENTS

p_list:  list of lists.

p_count:  pointer to returned count of nodes with non-NULL lists.

p_sCount:  pointer to returned count of nodes in lists of the
nodes of the input list.

RETURNED VALUES

EMS_S_Success for utter success.

EMS_I_NotFound if there are no nodes in the list.

EMS_E_InvalidArg if p_list is NULL.

NOTE

It is up to the caller to initialize the counts to zero or
whatever else he may desire.

HISTORY

04 Oct 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMSmsgdef.h"
# include "EMSadt.h"

EMSrc EFcountNodesInListOfElementsWithLists (p_list, p_count, p_sCount)
    struct EMStreeHeap *p_list;
    int *p_count;
    int *p_sCount;
{
    EMSrc rc;

    if (p_list)
    {
        struct EMStreeNode *p_node;
        struct EMSelementWithList *p_ewlist;
        extern EMSrc EFtreeLeftmostNode ();

        rc = EFtreeLeftmostNode (
            p_list,
            &p_node,
            (char **)&p_ewlist
        );

        while (rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeCountNodes ();

            if (p_ewlist->list)
            {
                (*p_count)++;

                rc = EFtreeCountNodes (p_ewlist->list, p_sCount);
            }

            if (EMSokay (rc))
            {
                extern EMSrc EFnodeNextToRight ();

                rc = EFnodeNextToRight (
                    p_node,
                    &p_node,
                    (char **)&p_ewlist
                );
            }
        }

        if (rc IS EMS_I_NotFound) rc = EMS_S_Success;
    }
    else
    {
        rc = EMS_E_InvalidArg;
    }

    return rc;
}
