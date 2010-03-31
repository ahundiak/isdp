#include <stdio.h>
#include <malloc.h>
#include "bsvalues.h"
#include "bsgeom_cvsf.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWapi/linklist.h"
#include "PWapi/mdstptgm.h"


/*
  ABSTRACT

  Creates a new node and appends to the incoming linked list and 
  returns the node created. If the incoming list is pointing  to 
  NULL, it returns the new node as the starting node of the linked 
  list. 

  All the pointers are initialized to NULL and all the members are
  set to ZERO. If the node is appended, the 'prev' of this new node
  is set to the last node of the list.


  RETURN VALUES

  Created Node address - Success 
  NULL                 - Memory Overflow
*/

struct PWcvregion_list *pwCreateCvregionList
(
  struct PWcvregion_list **p_cvregions 
)
{

  return (struct PWcvregion_list *) pwCreateNode ((char  **) p_cvregions,
                                         sizeof(struct PWcvregion_list));
}
/*
  ABSTRACT

  Destroys the entire list starting from the given node.
  After calling this function, p_cvintpt will be pointing to NULL.
*/

void pwFreeCvregionList
(
  struct PWcvregion_list *p_cvregions 
)
{
  int                    i;
  struct PWcvregion_list *p_node, *p_next_node;

  /*
   * for each node in the linked list, till the end of the list is reached
   */ 
  for( p_node = p_cvregions; p_node; p_node = p_next_node )
  { 
    p_next_node = p_node->p_next;

    /*
     * Free the data on the PWcvregion field. This consists of two steps.
     *      o Free the attrib data on the cvintpt. This inturn consists of 
     *        three steps. 
     *          o Free the data on the cvpt.
     *          o Free the data on the sibling.
     *          o Free its own attrib data.
     *       o Free its own attrib data.
     */
    for(i=0; i<2; i++)
    {
      pwFreeAttribList(p_node->cvregion.regbounds[i].cvpt.p_attrib);
      pwFreeAttribList(p_node->cvregion.regbounds[i].sibling.p_attrib);
      pwFreeAttribList(p_node->cvregion.regbounds[i].p_attrib);
    }

    pwFreeAttribList(p_node->cvregion.p_attrib);

    /*
     * Free the data in PWcvregion_list structure.
     *      o Free the attrib dta on this node.
     */
    pwFreeAttribList(p_node->p_attrib);

    /*
     * Free the node it self.
     */
    free(p_node); p_node = NULL; 
  }
 
  p_cvregions = NULL; 
  return ;
}

/*
  ABSTRACT

  Disconnects the given node from the linked list, restores the integrity
  of the rest of the list and sets the 'prev' and 'next' pointers of the 
  disconnected node to NULL. 

  After calling this function, the 'next' and 'prev' pointers of 
  p_remove_node will be pointing to NULL.


  RETURN VALUES
 
  TRUE  - If the node is removed, else FALSE.
*/

PWboolean pwRemoveCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_remove_node
)
{
  return pwRemoveNode ((char **)p_cvregions, (char *)p_remove_node);
}

/*
  ABSTRACT

  Frees a given node from the linked list and restores the integrity of
  the rest of the list.

  This routine frees the given node in the linked list only if it exists
  in the list and while returning it sets the 'p_free_node' to NULL. If
  it is not there in the list, then it does not do any thing.


  RETURN VALUES
 
  TRUE  - If the node is freed, else FALSE.
*/    

PWboolean pwFreeNodeCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_free_node
)
{
  /*
   * if the node to be destroyed is NULL, just return
   */
  if( !p_free_node )
    return FALSE;

  /*
   * remove the node from the linked list
   */
  if( pwRemoveCvregionList(p_cvregions, p_free_node) )
  {
    /*
     * free the node data
     */
    pwFreeCvregionList(p_free_node); 
   
    return TRUE;
  }
  else
    return FALSE;
}


void pwInsertAtInxCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_insert_node,
  int                    index
)
{
  pwInsertNodeAtInx ((char **) p_cvregions, (char *) p_insert_node, index);
}

PWboolean pwSwapNodesCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_a_node,
  struct PWcvregion_list *p_b_node
)
{
  return pwSwapNodes ((char **) p_cvregions, (char *) p_a_node, 
                      (char *) p_b_node);
}

void pwAppendCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_append_node
)
{
  pwAppendNode ((char **) p_cvregions, (char *) p_append_node);
}

void pwPrefixCvregionList
(
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_prefix_node
)
{
  pwPrefixNode ((char **) p_cvregions, (char *) p_prefix_node);
}

/*
  ABSTRACT

  Returns the number of nodes in the list
  Number of nodes will be returned by assuming the given node as the 
  start of the list. So it is the caller's responsibility to move to
  head of the list to get the actual number of nodes in the list.


  RETURN VALUES

  number of nodes in the list. 
*/

int pwNumCvregionList
(
  struct PWcvregion_list *p_from_node
)
{
  return pwNumNodes ((char *) p_from_node);
}

/*
  ABSTRACT

  Returns the node at the given index 
  This function returns the node at the given index in the list by
  using 'next' pointer if index > 0 otherwise 'prev' pointer. If 
  the specified index is out of the range of the list, then NULL
  will be returned.


  RETURN VALUES
  pointer to node if the given index is in range, otherwise NULL.
*/

struct PWcvregion_list *pwNodeAtInxCvregionList
(
  struct PWcvregion_list *p_from_node,
  int                    index
)
{
  return (struct PWcvregion_list *) pwNodeAtInx ((char *) p_from_node, index);
}

/*
  ABSTRACT

  Given a node in the list from which the index to be calculated and a 
  node, it returns the index of the node from the given node.
  If the given node is not there in the list, then it returns PW_MAXINT.


  RETURN VALUES

  TRUE  - If node is in the list, else FALSE.
*/

PWboolean pwInxOfNodeCvregionList
(
  struct PWcvregion_list *p_from_node,
  struct PWcvregion_list *p_node,
  int                    *index
)
{
  return pwInxOfNode ((char *) p_from_node, (char *) p_node, index);
}

/*
  ABSTRACT

  Given a node in the list, it returns the head of the list.
  If the given node is NULL, then it returns NULL.


  RETURN VALUES

  Pointer to the head of the list.
*/

struct PWcvregion_list *pwHeadCvregionList
(
  struct PWcvregion_list *p_cvregions
)
{
  return (struct PWcvregion_list *) pwHead ((char *) p_cvregions);
}

/*
  ABSTRACT

  Given a node in the list, it returns the tail of the list.
  If the given is pointing to NULL, it returns NULL. In case, if there is
  only one node in the list then the head and tail remain the same.

  
  RETURN VALUES
  
  Pointer to the tail of the list.
*/

struct PWcvregion_list *pwTailCvregionList
(
  struct PWcvregion_list *p_cvregions
)
{
  return (struct PWcvregion_list *) pwTail ((char *) p_cvregions);
}


/*
 * Functions Associated with PWcvregion props field.
 *     Following are the properties which can be set on a PWregion :
 *         PW_CONTAIN_IN       |
 *         PW_CONTAIN_OUT      |
 *         PW_CONTAIN_ON       |     2 bits
 *         PW_CONTAIN_UNKNOWN  |   
 *
 *         PW_PROP_DEGENERATE  |     1 bit
 *
 *     These properties requires 3 bits :
 *       o CONTAINMENT of the region (stored in 0 and 1) 
 *       o 1 bit for whether the region is DEGENERATE (stored in 2)
 */

#define  CVREGION_P_CONTAIN   1 /* position of the  containment bits in the
                                   properties word */
#define  CVREGION_P_PROPS     2 /* end position of the specific properties
                                   bits in the properties word */


#define  CVREGION_N_CONTAIN   2 /* Number of bits the containment property
                                   requires */
#define  CVREGION_N_PROPS     1 /* Number of bits the specific properties 
                                   requires */

/*
 * Set CONTAIN properties
 */

void pwSetContainCvregion
(
  struct PWcvregion     *p_cvregion, 
  enum   PWcontaintype  containment
)
{
  if( containment == PWcontain_in )
    pwSetBits(&p_cvregion->props, CVREGION_P_CONTAIN, CVREGION_N_CONTAIN, 
              PW_CONTAIN_IN);
  else if( containment == PWcontain_out )
    pwSetBits(&p_cvregion->props, CVREGION_P_CONTAIN, CVREGION_N_CONTAIN, 
              PW_CONTAIN_OUT);
  else if( containment == PWcontain_on )
    pwSetBits(&p_cvregion->props, CVREGION_P_CONTAIN, CVREGION_N_CONTAIN, 
              PW_CONTAIN_ON);
  else
    pwSetBits(&p_cvregion->props, CVREGION_P_CONTAIN, CVREGION_N_CONTAIN, 
              PW_CONTAIN_UNKNOWN);
}

/*
 * Get the CONTAIN property
 */

enum PWcontaintype pwGetContainCvregion
(
  struct PWcvregion *p_cvregion
)
{
  unsigned int props;

  props = pwGetBits(p_cvregion->props, CVREGION_P_CONTAIN, 
                   CVREGION_N_CONTAIN);   
 
  if( props == PW_CONTAIN_IN )
    return (enum PWcontaintype) PWcontain_in;
  else if( props == PW_CONTAIN_OUT )
    return (enum PWcontaintype) PWcontain_out;
  else if( props == PW_CONTAIN_ON )
    return (enum PWcontaintype) PWcontain_on;
  else 
    return (enum PWcontaintype) PWcontain_unknown;
}

/*
 * Set the DEGENERATE property
 */

void pwSetDegenCvregion 
(
  struct PWcvregion *p_cvregion
)
{
  p_cvregion->props = p_cvregion->props | 
                      ((int) PW_PROP_DEGENERATE << (int) CVREGION_P_PROPS);
}

/*
 * Unset the DEGENERATE property
 */

void pwUnsetDegenCvregion
(
  struct PWcvregion *p_cvregion 
)
{
  p_cvregion->props = p_cvregion->props &
                      ~(((int) PW_PROP_DEGENERATE << (int) CVREGION_P_PROPS));
}

/*
 * IS the DEGENERATE property set 
 */

PWboolean pwIsDegenCvregion
(
  struct PWcvregion *p_cvregion
)
{
  return (PWboolean) ((p_cvregion->props &
         ((int) PW_PROP_DEGENERATE << (int) CVREGION_P_PROPS)) ? TRUE : FALSE);
}

