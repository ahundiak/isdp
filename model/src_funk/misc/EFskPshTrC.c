/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*

DESCRIPTION

Push the contents of a tree onto a stack.

ARGUMENTS

p_toBePushed:  tree whose contents are to be pushed onto the
stack.

p_stack:  stack onto which the contents of the tree are to be
pushed.

HISTORY

05 Dec 1988 jBk Genesis.
*/

# include "EMS.h"           /* for shared libraries */
# include "EMSadt.h"        /* struct EMStree.... */
# include "EMStypedef.h"    /* EMSrc */
# include "EMSlogic.h"      /* EMSokay IS */
# include "EMSmsgdef.h"     /* EMS_I_Found */

EMSrc EFstackPushTreeContents (p_toBePushed, p_stack)
    struct EMStreeHeap *p_toBePushed, *p_stack;
{
    EMSrc rc;
    struct EMStreeNode *p_treenode;
    char *p_treenodecontent;

    /* intentional block */
    {
        EMSrc EFtreeLeftmostNode ();

        rc = EFtreeLeftmostNode (
            p_toBePushed,
            &p_treenode,
            &p_treenodecontent
        );
    }

    while (rc IS EMS_I_Found)
    {
        /* intentional block */
        {
            EMSrc EFstackPushNode ();

            rc = EFstackPushNode (
                p_treenodecontent,
                p_stack
            );
        }

        if (EMSokay (rc))
        {
            EMSrc EFnodeNextToRight ();

            rc = EFnodeNextToRight (
                p_treenode,
                &p_treenode,
                &p_treenodecontent
            );
        }

    } /* end while */

    return rc;
}
