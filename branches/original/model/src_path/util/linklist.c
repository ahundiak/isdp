/* --------------------                                   ------------------ *
 * FOR Project PATHWAY 					                     *	
 *                                                        Sanjay  : Creation *
 * --------------------                                   ------------------ */

/*
 * OVERVIEW
 *     This file contains "generic functions" for linked list creation/
 *     deletion/manipulation.
 *
 * NOTES
 *    
 *     C++ IN C
 *     --------
 *     What this means? In C++ (OOP) there will be a class which defines
 *     the linked list. So, any class which requires to be a linked list
 *     will subclass from linked list class and it can access all the me
 *     ssages defined under it. 
 */

#include <stdio.h>

#include "PWminimum.h"

#include "PWapi/linklist.h"

/*
 * The following structure defintion, will provide the access to prev and 
 * next pointers of any linked list data structure.
 */

struct PWlist
{
  struct PWlist *p_prev;
  struct PWlist *p_next;
};

/* ------------------------------------------------------------------------- */
/*                           TYPE  : CREATION                                */
/* ------------------------------------------------------------------------- */

/*
 * DESCRIPTION
 *
 *   Given the size, Creates a new node and appends it to the list and returns
 *   the address to the new node. If the incoming list is NULL, then it does 
 *   not do any thing.
 */

char *pwCreateNode
(
  char **p_list,
  unsigned int  size
)
{
  char *p_newnode=NULL;

  /*
   * allocate the memory for the new node. If there is any failure, return
   * NULL otherwise intialize the allocated memory to ZERO.
   */
  p_newnode = (char *) malloc (size);
  if (!p_newnode)
    return (char *) NULL;

  memset (p_newnode, 0, size);

  /*
   * Append the new node to the end of the incoming linked list.
   */
  pwAppendNode ((char **)p_list, (char *)p_newnode);

  /*
   * Return the newly created node
   */
  return (char *) p_newnode;
}

/* ------------------------------------------------------------------------- */
/*                           TYPE  : DELETION                                */
/* ------------------------------------------------------------------------- */

/*
 * DESCRIPTION 
 *
 *   Disconnects the given node from the linked list, restores the integrity 
 *   of the rest of the list and sets the 'prev' and 'next' fields of the 
 *   disconnected node to NULL. This function returns TRUE, if the node is
 *   from the given list otherwise FALSE.
 */

PWboolean pwRemoveNode
(
  char **p_list,
  char *p_remove_node
)
{
  int           inx=0;
  char          *p_head=NULL;
  struct PWlist *p_node=NULL, *p_next_node=NULL, *p_prev_node=NULL;

  /*
   * If the node to be removed is pointing to NULL, return FALSE
   */
  if (!p_remove_node)
    return FALSE;

  /*
   * Check whether the given node is from the list or not. If not return
   * otherwise continue
   */
  p_head = pwHead (*p_list);

  if (!pwInxOfNode (p_head, (char *)p_remove_node, &inx))
    return FALSE;

  /*
   * get the adjacent nodes to this node
   */
  p_node = (struct PWlist *) p_remove_node;
  p_prev_node = p_node->p_prev;
  p_next_node = p_node->p_next;

  /*
   * rearrange the 'prev' and 'next' pointers of the adjacent nodes to point
   * to one another. prev_node is NULL means, the head of the list is being
   * removed, so update the head of the list.
   */
  if (p_prev_node)
    p_prev_node->p_next = p_next_node;
  else /* head of the list is being removed, so update the head */
    *p_list = (char *) p_next_node;

  if (p_next_node)
    p_next_node->p_prev = p_prev_node;

  /*
   * make the 'prev' and 'next' pointers of this node to point to NULL
   */
  p_node->p_prev = NULL; 
  p_node->p_next = NULL; 

  return  TRUE; 
}

/* ------------------------------------------------------------------------- */
/*                             TYPE  : QUERY                                 */
/* ------------------------------------------------------------------------- */

/*
 * DESCRIPTION
 *
 *   Returns the number of nodes in the list from the given node as the base.
 */

int pwNumNodes
(
  char *p_from_node
)
{
  int            num=0;
  struct PWlist  *p_node=NULL;

  p_node = (struct PWlist *) p_from_node;
  while (p_node)
  {
    num++;
    p_node = p_node->p_next;
  }

  return num;
}

/*
 * DESCRIPTION
 *
 *   Returns the node at the given index in the list from the given node by 
 *   using 'next' pointer if index > 0 otherwise 'prev' pointer. If the sp-
 *   cified index is out of range of the list, it returns NULL.
 */

char *pwNodeAtInx
(
  char *p_from_node,
  int  index
)
{
  struct PWlist *p_node=NULL;

  p_node = (struct PWlist *) p_from_node;

  if(index > 0)
  {
    while (index-- && p_node)
      p_node = p_node->p_next;
  }
  else
  {
    while (index++ && p_node)
      p_node = p_node->p_prev; 
  }

  return (char *) p_node;
}


/*
 * DESCRIPTION
 *
 *   Given a node in the list and the node from which the index to be calc-
 *   lated, it returns the index of the node from the given node 'from_node'.
 *   If the node is not found in the list, returns FALSE, otherwise TRUE. 
 *   Only if the return value is TRUE, the returned value index is valid. 
 */

PWboolean pwInxOfNode
(
  char *p_from_node,
  char *p_node,
  int  *index
)
{
  struct PWlist *p_fnode=NULL;

  /*
   * Validate the incoming arguments
   */
  if (!p_from_node || !p_node || !index)
    return FALSE;
 
  *index = 0;
  p_fnode = (struct PWlist *) p_from_node;
  
  while (p_fnode)
  {
    if (p_node == (char *) p_fnode)
      return TRUE;
    (*index)++; 
    p_fnode = p_fnode->p_next;
  }
 
  *index = 0;
  p_fnode = (struct PWlist *) p_from_node;

  while (p_fnode)
  {
    if (p_node == (char *) p_fnode)
      return TRUE;
    (*index) --;
    p_fnode = p_fnode->p_prev;
  }

  return FALSE;
}

/*
 * DESCRIPTION
 *
 *   Returns the head of the linked list given a node in the list.
 */

char *pwHead
(
  char *p_list
)
{
  struct PWlist *p_node=NULL;

  if(!p_list)
    return (char *) NULL;

  p_node = (struct PWlist *) p_list;
  
  while (p_node->p_prev)
    p_node = p_node->p_prev;

  return (char *) p_node;
}

/*
 * DESCRIPTION
 *
 *   Returns the tail of the linked list given a node in the list.
 */

char *pwTail
(
  char *p_list
)
{
  struct PWlist *p_node=NULL;

  if(!p_list)
    return (char *) NULL;

  p_node = (struct PWlist *) p_list;
  
  while (p_node->p_next)
    p_node = p_node->p_next;

  return (char *) p_node;
}

/* ------------------------------------------------------------------------- */
/*                           TYPE  : MANIPULATION                            */
/* ------------------------------------------------------------------------- */

/*
 * DESCRIPTION
 *   
 *   Given the list, node to be inserted, and index at which it needs to be 
 *   inserted, the given node will be inserted from the given node at the 
 *   given index. If the index is out of range, the given node is either ap-
 *   pended or prepended depending either index > 0 or < 0.
 */

void pwInsertNodeAtInx
(
  char **p_list,
  char *p_insert_node,
  int  index
)
{
  struct PWlist *p_node=NULL;

  /*
   * Validate the incoming arguments 
   */
  if (!p_list || !p_insert_node)
    return;

  /* 
   * Get the node at the given index
   */
  p_node = (struct PWlist *) pwNodeAtInx (*p_list, index);

  /*
   * If the node is pointing to NULL, in other way if the index is out of 
   * range then append or prepend the given node depending on whether the
   * index is greater than 0 or less than 0
   */
  if (!p_node || index == 0)
  {
    if (index > 0)
      pwAppendNode (p_list, p_insert_node);
    else 
      pwPrefixNode (p_list, p_insert_node);
  }
  else
  {
    struct PWlist *p_inode, *p_prev_node;

    p_inode = (struct PWlist *) p_insert_node;

    /*
     * insert the given node so that the node at this index becomes the 
     * next node to the inserted node.
     */
    p_prev_node = p_node->p_prev;
    p_inode->p_next = p_node;
    p_inode->p_prev = p_prev_node;
    p_node->p_prev = p_inode;
    if (p_prev_node)
      p_prev_node->p_next = p_inode;
  }

  return;
}

/*
 * DESCRIPTION
 *   
 *   Swaps the given nodes in the list and returns TRUE. Returns FALSE if the
 *   nodes are not from the given linked list.
 */

PWboolean pwSwapNodes
(
  char **p_list,
  char *p_a_node,
  char *p_b_node
)
{
  int  inx1=0, inx2=0;
  char *p_head=NULL;

  /*
   * Validate the incoming arguments
   */
  if (!p_list || !*p_list || !p_a_node || !p_b_node)
    return FALSE;

  /*
   * Check whether the given nodes 'p_a_node' and 'p_b_node' are from the 
   * list 'p_list' or not. If not return FALSE, otherwise continue.
   */ 
  p_head = pwHead (*p_list);

  if (!pwInxOfNode (p_head, p_a_node, &inx1))
    return FALSE;

  if (!pwInxOfNode (p_head, p_b_node, &inx2))
    return FALSE;

  if (inx1 == inx2)
    return FALSE;

  pwRemoveNode (p_list, p_a_node);
  pwRemoveNode (p_list, p_b_node);

  if (inx1 < inx2)
  {
    pwInsertNodeAtInx (p_list, p_b_node, inx1);
    pwInsertNodeAtInx (p_list, p_a_node, inx2);
  }
  else
  {
    pwInsertNodeAtInx (p_list, p_a_node, inx2);
    pwInsertNodeAtInx (p_list, p_b_node, inx1);
  }

  return TRUE;
}

/*
 * DESCRIPTION
 *   
 *   Appends the give node to the end of the list. 
 */

void pwAppendNode
(
  char **p_list,
  char *p_append_node
)
{

  /* 
   * Validate the incoming arguments
   */
  if (!p_list || !p_append_node)
    return;

  if (!*p_list)
  {
    *p_list = p_append_node;
  }
  else
  { 
    struct PWlist *p_tail=NULL, *p_anode=NULL;

    /*
     * get the tail of the list
     */
    p_tail = (struct PWlist *) pwTail (*p_list);

    /*
     * Append the given node to the list, so that the given node 'p_append_node'
     * becomes the tail of the list.
     */
    p_anode = (struct PWlist *) p_append_node;

    p_tail->p_next  = p_anode;
    p_anode->p_prev = p_tail;
  }

  return;
}

/*
 * DESCRIPTION
 *
 *   Prepends the give node to the end of the list.
 */

void pwPrefixNode
(
  char **p_list,
  char *p_prefix_node
)
{
  /*
   * Validate the incoming arguments 
   */
  if (!p_list || !p_prefix_node)
    return;

  if (!*p_list)
  {
    *p_list = p_prefix_node;
  }
  else
  {
    struct PWlist *p_head=NULL, *p_pnode=NULL;

    /*
     * get the head of the list
     */
    p_head = (struct PWlist *) pwHead (*p_list);

    /*
     * Prefix the given node to the list, so that 'p_prefix_node' becomes the
     * head of the list.
     */
    p_pnode = (struct PWlist *) p_prefix_node;   

    p_pnode->p_next = p_head;
    p_head->p_prev  = p_pnode;
   
    *p_list = (char *) p_pnode;
  }

  return;
}


/* ------------------------------------------------------------------------- */
/*                                   EOF                                     */
/* ------------------------------------------------------------------------- */
