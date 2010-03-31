/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
DESCRIPTION

EFtree, EFnode -- tree manipulation functions

NOTE

All references to the comparison function refer to a
caller-defined function which looks like this:

int func (thing1, thing2)
char *thing1, *thing2;

The comparison function returns a negative number if what is
represented by thing1 occurs before what is represented by thing2
in an ordering, zero if they occur at the same place in an
ordering, and a positive number if thing1 occurs after thing2 in
an ordering.

Strcmp, described in string (3C), is a well-known example of such
a comparison function.

If the tree data structure is being used as a stack or unordered
list, the comparison function ought return a positive number for
no match and zero for a match.

SYNOPSIS

EMSrc EFtreeStart (p_p_tree)
struct EMStreeHeap **p_p_tree;

ARGUMENT

p_p_tree:  address of output pointer to newly allocated and
initialized tree (struct EMStreeHeap).

RETURNED VALUE

EMS_S_Success if the dynamic memory allocation is successful.

EMS_E_InsufficientDynamicMemory if there was a problem with the
memory allocation.

SYNOPSIS

EMSrc EFtreeInit (p_tree)
struct EMStreeHeap *p_tree;

ARGUMENT

p_tree:  pointer to tree to be initialized by EFtreeInit.
Invoked by EFtreeStart.

RETURNED VALUE

EMS_S_Success.

SYNOPSIS

EMSrc EFtreeAddNode (p_content, p_compare, p_tree, p_p_node)
char *p_content;
int (*p_compare)();
struct EMStreeHeap *p_tree;
struct EMStreeNode **p_p_node;

ARGUMENTS

p_content:  the content which is desired to be added as a node of
the tree.

p_compare:  pointer to the comparison function.

p_tree:  pointer to the tree.

p_p_node:  if non-NULL, pointer to returned address of node which
is added or found.

RETURNED VALUES

EMS_S_Success if all is successful.

EMS_I_Found if the content to be added is compares to be the same
as an already resident tree member.

EMS_E_InsufficientDynamicMemory if there was a problem with
memory allocation.

SYNOPSIS

EMSrc EFnodeAdd (p_content, p_compare, p_stopNode, p_newNode)
char *p_content;
int (*p_compare)();
struct EMStreeNode *p_stopNode;
struct EMStreeNode *p_newNode;

ARGUMENTS

p_content:  pointer to value desired to be entered into the tree.

p_compare:  pointer to comparison function.

p_stopNode:  pointer to node of tree where search (for node
already representing the same value as pointed to by p_content)
was determined to be futile.

p_newNode:  pointer to node which will be added to the tree and
be made to contain the value represented by p_content.

NOTE

EFnodeAdd is not intended for use by other than EFtreeAddNode

RETURNED VALUES

SYNOPSIS

EMSrc EFtreeFindNode (p_content, p_tree, p_compare, p_p_node, p_p_content)
char *p_content;
struct EMStreeHeap *p_tree;
int (*p_compare)();
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_content:  pointer to value whose node is to be located in the
tree.

p_tree:  pointer to tree.  If p_tree is NULL, the search will
start at the node pointed to by *p_p_node.

p_compare:  the comparison function.

p_p_node:  can be used as input as described in description of
p_tree; as output, it is a pointer to the address of the node
containing the value represented by p_content.  If a matching
node was not found, p_p_node is a pointer to the address of the
node where the search was terminated.  P_p_node can be NULL if
the address of said node is not desired.

p_p_content:  pointer to value (content) field of node.  Can be
NULL.

RETURNED VALUES

EMS_I_Found if a matching node is found.

EMS_I_NotFound if a matching node is not found.

SYNOPSIS

EMSrc EFtreeLeftmostNode (p_tree, p_p_node, p_p_content)
struct EMStreeHeap *p_tree;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_tree:  pointer to tree.  Can be NULL.

p_p_node:  as output, p_p_node is a pointer to the address of the
leftmost node in the tree.  If p_tree is NULL, *p_p_node is used
for input as the address of a node at which to start a search for
the leftmost node in the subtree of which said input node is the
root.  If p_tree is non-NULL and there are no nodes in *p_tree,
then *p_p_node is set to NULL.  P_p_node can be NULL.

p_p_content:  pointer to returned value field of leftmost node.
Can be NULL.

RETURNED VALUES

EMS_I_Found if the leftmost node is returned.

EMS_I_NotFound if there are no nodes in the tree.

EMS_E_InvalidArg if both p_tree and *p_p_node are NULL.

SYNOPSIS

EMSrc EFtreeRightmostNode (p_tree, p_p_node, p_p_content)
struct EMStreeHeap *p_tree;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

Same as EFtreeLeftmostNode, but for the rightmost node.

RETURNED VALUES

Same as EFtreeLeftmostNode, but for the rightmost node.

SYNOPSIS

EMSrc EFnodeUpAndToRight (p_this_node, p_parent, p_p_node, p_p_content)
struct EMStreeNode *p_this_node;
struct EMStreeNode *p_parent;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_this_node:  pointer to the node at which to start the search.

p_parent:  pointer to the parent of the starting node.

p_p_node:  pointer to returned address of node just to the right
of the starting node in the part of the tree which is above the
starting node.

p_p_content:  pointer to returned value field of **p_p_node.  Can
be NULL.

RETURNED VALUES

EMS_I_Found if the search was able to find a node in the direct
ancestry of the start node from which the start node is in the
left descendency.

EMS_I_NotFound if not such node is found.

SYNOPSIS

EMSrc EFnodeNextToRight (p_this_node, p_p_node, p_p_content)
struct EMStreeNode *p_this_node;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_this_node:  address of start node.

p_p_node:  address of returned pointer to node immediately to the
right of the start node in the ordering of the tree.

p_p_content:  address of returned value field of *p_p_node.

RETURNED VALUES

EMS_I_Found if there is a node found immediately to the right of
the start node in the ordering of the tree.

EMS_I_NotFound if no such node is found.

SYNOPSIS

EMSrc EFtreeEmpty (p_tree)
struct EMStreeHeap *p_tree;

ARGUMENT

p_tree:  address of lead heap in tree.

RETURNED VALUE

EMS_S_Success when the members of the tree are returned to a
state of containing no used nodes.

SYNOPSIS

EMSrc EFtreeEnd (p_tree)
struct EMStreeHeap *p_tree;

ARGUMENT

p_tree:  address of lead heap in tree.  Not a valid pointer upon
return.

RETURNED VALUE

EMS_S_Success when EFtreeEnd has deallocated all the heap memory
used by the tree.

SYNOPSIS

EMSrc EFtreeExciseNode (p_tree, p_node)
struct EMStreeHeap *p_tree;
struct EMStreeNode *p_node;

ARGUMENTS

p_tree:  address of tree from which node is to be excised.

p_node:  address of node to excise from tree.  Address can be
derived by using EFtreeFindNode.

RETURNED VALUE

EMS_S_Success when the *p_node has been removed from the tree,
the tree has been rearranged to accomodate the removal, and
*p_node has been returned to the freelist of the *p_tree.

SYNOPSIS

EMSrc EFstackPushNode (p_content, p_stack)
char *p_content;
struct EMStreeHeap *p_stack;

ARGUMENTS

p_content:  the content which is desired to be pushed as a node
onto the stack.

p_tree:  pointer to the stack.

RETURNED VALUES

EMS_S_Success if all is successful.

EMS_E_InsufficientDynamicMemory if there was a problem with
memory allocation.

EMSrc EFstackTop (p_stack, p_p_node, p_p_content)
struct EMStreeHeap *p_stack;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_stack:  pointer to stack.  Can be NULL.

p_p_node:  as output, p_p_node is a pointer to the address of the
topmost node in the stack.  If there are no nodes in *p_stack,
then *p_p_node is set to NULL.  P_p_node can be NULL.

p_p_content:  pointer to returned value field of topmost node.
Can be NULL.

RETURNED VALUES

EMS_I_Found if the topmost node is returned.

EMS_I_NotFound if there are no nodes in the stack.

SYNOPSIS

EMSrc EFnodeNextInStack (p_this_node, p_p_node, p_p_content)
struct EMStreeNode *p_this_node;
struct EMStreeNode **p_p_node;
char **p_p_content;

ARGUMENTS

p_this_node:  address of start node.

p_p_node:  address of returned pointer to next node down into the
stack.

p_p_content:  address of returned value field of *p_p_node.

RETURNED VALUES

EMS_I_Found if there is a node found immediately beneath the
start node in the ordering of the stack.

EMS_I_NotFound if no such node is found.

SYNOPSIS

EMSrc EFtreeCountNodes (p_tree, p_count)
struct EMStreeHeap *p_tree;
int *p_count;

ARGUMENTS

p_tree:  pointer to tree, stack, etc.

p_count:  pointer to returned count of nodes in tree, stack, etc.
P_count is incremented at every encountered node.  P_count must
be initialized to zero before inital invocation if the caller
desires to start counting at zero.

RETURNED VALUES

EMS_S_Success for success.

EMS_E_InvalidArg if p_tree is NULL.

SYNOPSIS

EMSrc EFnodeCountSubtreeNodes (p_node, p_count)
struct EMStreeNode *p_node;
int *p_count;

ARGUMENTS

p_node:  pointer to node.

p_count:  pointer to returned count of nodes in subtree, -stack,
etc.  Is incremented at every encountered node.

RETURNED VALUES

Currently always EMS_S_Success.

HISTORY

05 Jan 1989 jBk Changed EFtreeCountNodes to return an error if it
                is given a NULL tree.
12 Dec 1988 jBk Changed EFtreeCountNodes function to count from
                whatever is input in the count variable.
30 Nov 1988 jBk Added six explicit declarations of functions in
                this file which are called by other functions in
                this file.  Moved three other declarations closer
                to their usages.  It is nice to be consistent.
04 Oct 1988 jBk Added argument to EFtreeAddNode.
29 Sep 1988 jBk Added EFnodeCountSubtreeNodes and
                EFtreeCountNodes functions.
27 Sep 1988 jBk Added EFstackPushNode, EFstackTop and
                EFnodeNextInStack functions to facilitate
                treating an EMStreeHeap as a stack or unordered
                list.
14 Sep 1988 jBk Genesis.
*/

/* for shared libraries */
# include "EMS.h"

# ifndef STANDALONE
# define STANDALONE 0
# endif

# if STANDALONE
    /* malloc free */
#   include <malloc.h>

#   define jmalloc(nbytes) malloc ((unsigned)(nbytes))
#   define jfree(pointer) free ((char *)pointer)
# else
    /* om$malloc om$dealloc */
#   include "OMprimitives.h"

#   define jmalloc(nbytes) om$malloc (size = (unsigned)(nbytes))
#   define jfree(pointer) om$dealloc (ptr = pointer)
# endif

/* IS EMSokay */
# include "EMSlogic.h"

/* EMStreeNode EMStreeHeap EMSteInHeap */
# include "EMSadt.h"

/* EMS message code definitions */
# include "EMSmsgdef.h"

/* EMS message code definitions with corresponding strings */
# include "EMS_E.h"

/* EMSrc */
# include "EMStypedef.h"

EMSrc EFtreeStart (p_p_tree)
    struct EMStreeHeap **p_p_tree;
{
    EMSrc rc = EMS_E_InsufficientDynamicMemory;

    *p_p_tree = (struct EMStreeHeap *)jmalloc (sizeof (**p_p_tree));

    if (*p_p_tree) rc = EMS_S_Success;

    if (EMSokay (rc))
    {
        EMSrc EFtreeInit ();

        rc = EFtreeInit (*p_p_tree);
    }

    return rc;
}

EMSrc EFtreeInit (p_tree)
    struct EMStreeHeap *p_tree;
{
    int ii = EMSteInHeap - 2;
    struct EMStreeNode *next, *current;

    current = p_tree->elements;
    next = current + 1;

    p_tree->freeElements = current;
    p_tree->usedElements = NULL;
    p_tree->nextHeap = NULL;
    p_tree->nodeHeap = NULL;

    do
    {
        (current++)->pnf.nextFree = next++;
    } while (ii--);

    current->pnf.nextFree = NULL;

    return EMS_S_Success;
}

EMSrc EFtreeAddNode (p_content, p_compare, p_tree, p_p_node)
    char *p_content;
    int (*p_compare)();
    struct EMStreeHeap *p_tree;
    struct EMStreeNode **p_p_node;
{
    EMSrc rc = EMS_I_NotFound;
    struct EMStreeNode *p_stopNode;

    if (p_stopNode = p_tree->usedElements)
    {
        EMSrc EFtreeFindNode ();

        rc = EFtreeFindNode (
            p_content,
            (struct EMStreeHeap *)NULL,
            p_compare,
            &p_stopNode,
            NULL
        );
    }

    if (rc IS EMS_I_NotFound)
    {
        if (NOT p_tree->freeElements)
        {
            EMSrc EFtreeStart ();
            struct EMStreeHeap *p_newHeap;

            rc = EFtreeStart (&p_newHeap);

            if (EMSokay (rc))
            {
                p_tree->freeElements = p_newHeap->freeElements;
                p_newHeap->nextHeap = p_tree->nextHeap;
                p_tree->nextHeap = p_newHeap;
            }
        }

        if (EMSokay (rc))
        {
            struct EMStreeNode *p_newNode;

            p_newNode = p_tree->freeElements;
            p_tree->freeElements = p_newNode->pnf.nextFree;

            if (p_stopNode)
            {
                EMSrc EFnodeAdd ();

                rc = EFnodeAdd (
                    p_content,
                    p_compare,
                    p_stopNode,
                    p_newNode
                );
            }
            else
            {
                rc = EMS_S_Success;

                p_tree->usedElements = p_newNode;
                p_newNode->pnf.parent = NULL;
                p_newNode->right = NULL;
                p_newNode->left = NULL;
                p_newNode->content = p_content;
            }

            p_stopNode = p_newNode; /* to leave value for return */
        }
    } /* end if (rc IS EMS_I_NotFound) */

    if (p_p_node) *p_p_node = p_stopNode;

    return rc;
}

EMSrc EFnodeAdd (p_content, p_compare, p_stopNode, p_newNode)
    char *p_content;
    int (*p_compare)();
    struct EMStreeNode *p_stopNode;
    struct EMStreeNode *p_newNode;
{
    EMSrc rc = EMS_S_Success;
    int comparison;

    p_newNode->content = p_content;
    p_newNode->pnf.parent = p_stopNode;
    p_newNode->left = NULL;
    p_newNode->right = NULL;

    comparison = (*p_compare)(p_content, p_stopNode->content);

    if (comparison < 0)
    {
        if (p_stopNode->left)
            rc = EMS_E_Fail;
        else
            p_stopNode->left = p_newNode;
    }
    else if (comparison > 0)
    {
        if (p_stopNode->right)
            rc = EMS_E_Fail;
        else
            p_stopNode->right = p_newNode;
    }
    else /* (comparison IS 0) */
    {
        rc = EMS_E_InvalidArg;
    }

    return rc;
}

EMSrc EFtreeFindNode (p_content, p_tree, p_compare, p_p_node, p_p_content)
    char *p_content;
    struct EMStreeHeap *p_tree;
    int (*p_compare)();
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc rc;
    
    if (p_tree)
    {
        struct EMStreeNode *loc_p_node;
        char *loc_p_content;

        loc_p_node = p_tree->usedElements;
        rc = EFtreeFindNode (
            p_content,
            (struct EMStreeHeap *)NULL,
            p_compare,
            &loc_p_node,
            &loc_p_content
        );
        if (p_p_node) *p_p_node = loc_p_node;
        if (p_p_content) *p_p_content = loc_p_content;
    }
    else
    {
        int comparison;
        char *loc_p_content;

        loc_p_content = (*p_p_node)->content;
        if (p_p_content) *p_p_content = loc_p_content;
        comparison = (*p_compare)(p_content, loc_p_content);

        if (comparison)
        {
            struct EMStreeNode *p_branchNode;

            if (comparison > 0)
                p_branchNode = (*p_p_node)->right;
            else /* (comparison < 0) */
                p_branchNode = (*p_p_node)->left;

            if (p_branchNode)
            {
                *p_p_node = p_branchNode;
                rc = EFtreeFindNode (
                    p_content,
                    (struct EMStreeHeap *)NULL,
                    p_compare,
                    p_p_node,
                    p_p_content
                );
            }
            else
            {
                rc = EMS_I_NotFound;
            }
        }
        else
        {
            rc = EMS_I_Found;
        }
    }

    return rc;
}

EMSrc EFtreeLeftmostNode (p_tree, p_p_node, p_p_content)
    struct EMStreeHeap *p_tree;
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc rc;

    if (p_tree)
    {
        struct EMStreeNode *loc_p_node;

        if (loc_p_node = p_tree->usedElements)
        {
            rc = EFtreeLeftmostNode (
                (struct EMStreeHeap *)NULL,
                &loc_p_node,
                p_p_content
            );
        }
        else
        {
            rc = EMS_I_NotFound;
            if (p_p_content) *p_p_content = NULL;
        }

        if (p_p_node) *p_p_node = loc_p_node;
    }
    else if (*p_p_node)
    {
        struct EMStreeNode *p_branchNode;

        p_branchNode = (*p_p_node)->left;

        if (p_branchNode)
        {
            *p_p_node = p_branchNode;
            rc = EFtreeLeftmostNode (
                (struct EMStreeHeap *)NULL,
                p_p_node,
                p_p_content
            );
        }
        else
        {
            if (p_p_content) *p_p_content = (*p_p_node)->content;
            rc = EMS_I_Found;
        }
    }
    else
    {
        rc = EMS_E_InvalidArg;
    }

    return rc;
}

EMSrc EFtreeRightmostNode (p_tree, p_p_node, p_p_content)
    struct EMStreeHeap *p_tree;
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc rc;

    if (p_tree)
    {
        struct EMStreeNode *loc_p_node;

        loc_p_node = p_tree->usedElements;

        rc = EFtreeRightmostNode (
            (struct EMStreeHeap *)NULL,
            &loc_p_node,
            p_p_content
        );
        if (p_p_node) *p_p_node = loc_p_node;
    }
    else if (*p_p_node)
    {
        struct EMStreeNode *p_branchNode;

        p_branchNode = (*p_p_node)->right;

        if (p_branchNode)
        {
            *p_p_node = p_branchNode;
            rc = EFtreeRightmostNode (
                (struct EMStreeHeap *)NULL,
                p_p_node,
                p_p_content
            );
        }
        else
        {
            if (p_p_content) *p_p_content = (*p_p_node)->content;
            rc = EMS_I_Found;
        }
    }
    else
    {
        rc = EMS_E_InvalidArg;
    }

    return rc;
}

EMSrc EFnodeUpAndToRight (p_this_node, p_parent, p_p_node, p_p_content)
    struct EMStreeNode *p_this_node;
    struct EMStreeNode *p_parent;
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc rc = EMS_I_NotFound;

    if (p_parent)
    {
        struct EMStreeNode *p_rightBranch;

        p_rightBranch = p_parent->right;

        if (p_rightBranch ISNT p_this_node) /* am left child */
        {
            if (p_p_node) *p_p_node = p_parent;
            if (p_p_content) *p_p_content = p_parent->content;

            rc = EMS_I_Found;
        }
        else /* am right child or no right sibling */
        {
            rc = EFnodeUpAndToRight (
                p_parent,
                p_parent->pnf.parent,
                p_p_node,
                p_p_content
            );
        }
    }

    return rc;
}

EMSrc EFnodeNextToRight (p_this_node, p_p_node, p_p_content)
    struct EMStreeNode *p_this_node;
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc rc;
    struct EMStreeNode *p_right_branch;

    p_right_branch = p_this_node->right;

    if (p_right_branch) /* there is a right child */
    {
        EMSrc EFtreeLeftmostNode ();

        rc = EFtreeLeftmostNode (
            (struct EMStreeHeap *)NULL,
            &p_right_branch,
            p_p_content
        );

        if (p_p_node) *p_p_node = p_right_branch;
    }
    else /* no right child */
    {
        EMSrc EFnodeUpAndToRight ();

        rc = EFnodeUpAndToRight (
            p_this_node,
            p_this_node->pnf.parent,
            p_p_node,
            p_p_content
        );
    } /* end else no right child */

    return rc;
}

EMSrc EFtreeEmpty (p_tree)
    struct EMStreeHeap *p_tree;
{
    EMSrc rc = EMS_S_Success;

    if (p_tree)
    {
        struct EMStreeHeap *next;

        next = p_tree->nextHeap;

        rc = EFtreeEmpty (next);

        if (EMSokay (rc))
        {
            EMSrc EFtreeInit ();

            rc = EFtreeInit (p_tree);
        }

        if (EMSokay (rc) AND next)
        {
            p_tree->nextHeap = next;
            p_tree->elements[EMSteInHeap-1].pnf.nextFree =
                next->freeElements;
        }
    }

    return rc;
}

EMSrc EFtreeEnd (p_tree)
    struct EMStreeHeap *p_tree;
{
    EMSrc rc = EMS_S_Success;

    if (p_tree)
    {
        rc = EFtreeEnd (p_tree->nextHeap);

        if (EMSokay (rc))
        {
            jfree ((char *)p_tree);
        }
    }

    return rc;
}

EMSrc EFtreeExciseNode (p_tree, p_node)
    struct EMStreeHeap *p_tree;
    struct EMStreeNode *p_node;
{
    EMSrc rc = EMS_S_Success;
    struct EMStreeNode *parent, **p_p_child, *left, *right;

    parent = p_node->pnf.parent;
    left = p_node->left;
    right = p_node->right;

    if (parent)
    {
        if (parent->left IS p_node)
        {
            p_p_child = &parent->left;
        }
        else /* parent->right IS p_node */
        {
            p_p_child = &parent->right;
        }
    }
    else
    {
        if (left)
        {
            p_tree->usedElements = left;
        }
        else
        {
            p_tree->usedElements = right;
        }
    }

    if (left AND right)
    {
        EMSrc EFtreeRightmostNode ();
        struct EMStreeNode *rightMost;

        rightMost = left;

        rc = EFtreeRightmostNode (
            (struct EMStreeHeap *)NULL,
            &rightMost,
            NULL
        );

        if (EMSokay (rc))
        {
            rc = EMS_S_Success;

            if (parent) *p_p_child = left;
            left->pnf.parent = parent;

            rightMost->right = right;
            right->pnf.parent = rightMost;
        }
    }
    else if (left)
    {
        if (parent) *p_p_child = left;
        left->pnf.parent = parent;
    }
    else if (right)
    {
        if (parent) *p_p_child = right;
        right->pnf.parent = parent;
    }
    else /* I have no children */
    {
        if (parent) *p_p_child = NULL;
    }

    p_node->pnf.nextFree = p_tree->freeElements;
    p_tree->freeElements = p_node;

    return rc;
}

EMSrc EFstackPushNode (p_content, p_stack)
    char *p_content;
    struct EMStreeHeap *p_stack;
{
    EMSrc rc = EMS_S_Success;

    if (NOT p_stack->freeElements)
    {
        EMSrc EFtreeStart ();
        struct EMStreeHeap *p_newHeap;

        rc = EFtreeStart (&p_newHeap);

        if (EMSokay (rc))
        {
            p_stack->freeElements = p_newHeap->freeElements;
            p_newHeap->nextHeap = p_stack->nextHeap;
            p_stack->nextHeap = p_newHeap;
        }
    }

    if (EMSokay (rc))
    {
        struct EMStreeNode *p_newNode, *p_topNode;

        p_topNode = p_stack->usedElements;
        p_newNode = p_stack->freeElements;

        p_stack->freeElements = p_newNode->pnf.nextFree;
        p_stack->usedElements = p_newNode;

        if (p_topNode)
        {
            p_topNode->pnf.parent = p_newNode;
        }

        p_newNode->pnf.parent = NULL;
        p_newNode->right = p_topNode;
        p_newNode->left = NULL;
        p_newNode->content = p_content;
    }

    return rc;
}

EMSrc EFstackTop (p_stack, p_p_node, p_p_content)
struct EMStreeHeap *p_stack;
struct EMStreeNode **p_p_node;
char **p_p_content;
{
    EMSrc rc = EMS_I_NotFound;
    struct EMStreeNode *loc_p_node = NULL;
    char *loc_p_content = NULL;

    if (p_stack)
    {
        if (loc_p_node = p_stack->usedElements)
        {
            rc = EMS_I_Found;
            loc_p_content = loc_p_node->content;
        }
    }

    if (p_p_node) *p_p_node = loc_p_node;
    if (p_p_content) *p_p_content = loc_p_content;

    return rc;
}

EMSrc EFnodeNextInStack (p_this_node, p_p_node, p_p_content)
    struct EMStreeNode *p_this_node;
    struct EMStreeNode **p_p_node;
    char **p_p_content;
{
    EMSrc EFnodeNextToRight ();

    return EFnodeNextToRight (p_this_node, p_p_node, p_p_content);
}

EMSrc EFtreeCountNodes (p_tree, p_count)
    struct EMStreeHeap *p_tree;
    int *p_count;
{
    EMSrc rc = EMS_E_InvalidArg;
    EMSrc EFnodeCountSubtreeNodes ();

    if (p_tree)
    {
        rc = EFnodeCountSubtreeNodes (p_tree->usedElements, p_count);
    }

    return rc;
}

EMSrc EFnodeCountSubtreeNodes (p_node, p_count)
    struct EMStreeNode *p_node;
    int *p_count;
{
    EMSrc rc = EMS_S_Success;

    if (p_node)
    {
        (*p_count)++;

        rc = EFnodeCountSubtreeNodes (p_node->left, p_count);

        if (EMSokay (rc))
            rc = EFnodeCountSubtreeNodes (p_node->right, p_count);
    }

    return rc;
}
