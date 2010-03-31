#include <stdio.h>
#include <malloc.h>
#include "bsvalues.h"
#include "bsgeom_cvsf.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWapi/linklist.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/samepts.h"

static void RearrangeList
(
  struct PWcvintpt_list **p_cvintpts,
  double tol,
  struct PWcvintpt_list **p_unamb_node
);
static PWboolean IsListAmbiguous
(
  struct PWcvintpt_list *p_cvintpts
);
static int NumCoincNodes
(
  struct PWcvintpt_list *p_node,
  double tol
);
static void RearrangeCoincNodes
(
  struct PWcvintpt_list **p_cvintpts,
  int n_nodes,
  struct PWcvintpt_list **p_unamb_node
);

#define AreToggle(x, y) ( ((x) == (y)) ? ((x) != PWcontain_unknown) : FALSE )

static int rearr_cnt;
#define REARR_MAX_CNT 88

/*
  ABSTRACT

  Creates a new node and appends to the incoming linked list and
  returns the node created. If the incoming list is pointing  to
  NULL, it returns the new node as the starting node of the linked
  list.

  All the pointers are initialized to NULL and all the members are
  set to ZERO.
*/

struct PWcvintpt_list *pwCreateCvintptList
(
  struct PWcvintpt_list **p_cvintpts
)
{
  return (struct PWcvintpt_list *) pwCreateNode( (char **) p_cvintpts,
   sizeof(struct PWcvintpt_list));
}


/*
  ABSTRACT

  Destroys the entire list starting from the given node.
  After calling this function, p_cvintpt will be pointing to NULL.
*/

void pwFreeCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  struct PWcvintpt_list *p_node, *p_next_node;

  /*
   * for each node in the linked list, till the end of the list is reached
   */
  for( p_node = p_cvintpts; p_node; p_node = p_next_node )
  {
    p_next_node = p_node->p_next;

    /*
     * Free the data on PWcvintpt field. This consists of three steps.
     *      o Free the attrib data on the cvpt.
     *      o Free the attrib data on the sibling.
     *      o Free its own attrib data.
     */
    pwFreeAttribList(p_node->intpt.cvpt.p_attrib);
    pwFreeAttribList(p_node->intpt.sibling.p_attrib);
    pwFreeAttribList(p_node->intpt.p_attrib);

    /*
     * Free the data in PWcvintpt_list structure.
     *      o Free the attrib dta on this node.
     */
    pwFreeAttribList(p_node->p_attrib);

    /*
     * Free the node it self.
     */
    free(p_node); p_node = NULL;
  }

  p_cvintpts = NULL;
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

  TRUE - If the node is removed, else FALSE.
*/

PWboolean pwRemoveCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_remove_node
)
{
  return pwRemoveNode ((char **)p_cvintpts, (char *)p_remove_node);
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

PWboolean pwFreeNodeCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_free_node
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
  if( pwRemoveCvintptList(p_cvintpts, p_free_node) )
  {
    /*
     * free the node data
     */
    pwFreeCvintptList(p_free_node);

    return TRUE;
  }
  else
    return FALSE;
}


void pwInsertAtInxCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_insert_node,
  int                   index
)
{
  pwInsertNodeAtInx ((char **) p_cvintpts, (char *) p_insert_node, index);
}

PWboolean pwSwapNodesCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_a_node,
  struct PWcvintpt_list *p_b_node
)
{
  return pwSwapNodes ((char **) p_cvintpts, (char *) p_a_node,
                      (char *) p_b_node);
}

void pwAppendCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_append_node
)
{
  pwAppendNode ((char **) p_cvintpts, (char *) p_append_node);
}

void pwPrefixCvintptList
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_prefix_node
)
{
  pwPrefixNode ((char **) p_cvintpts, (char *) p_prefix_node);
}

/*
  ABSTRACT

  Returns the number of nodes in the list. Number of nodes will be returned
  by assuming the given node as the start of the list. So it is the caller's
  responsibility to move to head of the list to get the actual number of
  nodes in the list.


  RETURN VALUES

  Number of nodes in the list.
*/

int pwNumCvintptList
(
  struct PWcvintpt_list *p_from_node
)
{
  return pwNumNodes ((char *) p_from_node);
}

/*
  ABSTRACT

  Returns the node at the given index.
  This function returns the node at the given index in the list by
  using 'next' pointer if index > 0 otherwise 'prev' pointer. If
  the specified index is out of the range of the list, then NULL
  will be returned.


  RETURN VALUES

  pointer to node if the given index is in range, otherwise NULL.
*/

struct PWcvintpt_list *pwNodeAtInxCvintptList
(
  struct PWcvintpt_list *p_from_node,
  int                   index
)
{
  return (struct PWcvintpt_list *) pwNodeAtInx ((char *) p_from_node, index);
}

/*
  ABSTRACT

  Given a node in the list from which the index to be calculated and a
  node, it returns the index of the node from the given node.
  If the given node is not there in the list, then it returns PW_MAXINT.


  RETURN VALUES

  TRUE - If node is in the list, else FALSE.
*/

PWboolean pwInxOfNodeCvintptList
(
  struct PWcvintpt_list *p_from_node,
  struct PWcvintpt_list *p_node,
  int                   *index
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

struct PWcvintpt_list *pwHeadCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  return (struct PWcvintpt_list *) pwHead ((char *) p_cvintpts);
}

/*
  ABSTRACT

  Given a node in the list, it returns the tail of the list.
  If the given is pointing to NULL, it returns NULL. In case, if there is
  only one node in the list then the head and tail remain the same.


  RETURN VALUES

  Pointer to the tail of the list.
*/

struct PWcvintpt_list *pwTailCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  return (struct PWcvintpt_list *) pwTail ((char *) p_cvintpts);
}


/*
 * Functions Associated with PWcvintpt props field.
 *     Following are the properties which can be set on a PWcvintpt :
 *         PW_CONTAIN_IN       |
 *         PW_CONTAIN_OUT      |
 *         PW_CONTAIN_ON       |     2 bits ( Category #1 - Left )
 *         PW_CONTAIN_UNKNOWN  |     2 bits ( Category #2 - Right )
 *
 *         PW_PROP_NOSIBLING   |     1 bit
 *
 *     These properties requires 7 bits :
 *       o 2 for LEFT CONTAINMENT  (stored in 0 and 1)
 *       o 2 for RIGHT CONTAINMENT (stored in 2 and 3)
 *       o 1 bit to determine whether the node contains the sibling
 *           information or not.
 */

#define  CVINTPT_P_LEFTCONTAIN   1 /* position of the left containment bits in
                                      the properties word */
#define  CVINTPT_P_RIGHTCONTAIN  3 /* position of the right containment bits in
                                      the properties word */
#define  CVINTPT_P_PROPS         4 /* end position of the properties bits in
                                      the properties word */

#define  CVINTPT_N_CONTAIN       2 /* Number of bits the containment property
                                      requires */
#define  CVINTPT_N_PROPS         1 /* Number of bits the properties fields
                                      requires */


/*
 * Set the CONTAIN property
 */

void pwSetContainCvintpt
(
  struct PWcvintpt      *p_cvintpt,
  int                   side,
  enum   PWcontaintype  containment
)
{
  unsigned int pos;

  if( side == LEFT )
    pos = CVINTPT_P_LEFTCONTAIN;
  else
    pos = CVINTPT_P_RIGHTCONTAIN;

  if( containment == PWcontain_in )
    pwSetBits(&p_cvintpt->props, pos, CVINTPT_N_CONTAIN, PW_CONTAIN_IN);
  else if( containment == PWcontain_out )
    pwSetBits(&p_cvintpt->props, pos, CVINTPT_N_CONTAIN, PW_CONTAIN_OUT);
  else if( containment == PWcontain_on )
    pwSetBits(&p_cvintpt->props, pos, CVINTPT_N_CONTAIN, PW_CONTAIN_ON);
  else
    pwSetBits(&p_cvintpt->props, pos, CVINTPT_N_CONTAIN, PW_CONTAIN_UNKNOWN);
}


/*
 * Get the CONTAIN property
 */

enum PWcontaintype  pwGetContainCvintpt
(
  struct PWcvintpt      *p_cvintpt,
  int                   side
)
{
  unsigned int props;

  if( side == LEFT )
    props = pwGetBits(p_cvintpt->props, CVINTPT_P_LEFTCONTAIN,
                     CVINTPT_N_CONTAIN);
  else
    props = pwGetBits(p_cvintpt->props, CVINTPT_P_RIGHTCONTAIN,
                     CVINTPT_N_CONTAIN);

  if (props == PW_CONTAIN_IN)
    return (enum PWcontaintype) PWcontain_in;
  else if (props == PW_CONTAIN_OUT)
    return (enum PWcontaintype) PWcontain_out;
  else if (props == PW_CONTAIN_ON)
    return (enum PWcontaintype) PWcontain_on;
  else
    return (enum PWcontaintype) PWcontain_unknown;
}

/*
 * Set the NOSIBLING property
 */

void pwSetNoSiblingCvintpt
(
  struct PWcvintpt *p_cvintpt
)
{
  p_cvintpt->props = p_cvintpt->props |
                      ((int) PW_PROP_NOSIBLING << (int) CVINTPT_P_PROPS);
}

/*
 * Unset the NOSIBLING property
 */

void pwUnsetNoSiblingCvintpt
(
  struct PWcvintpt *p_cvintpt
)
{
  p_cvintpt->props = p_cvintpt->props &
                      ~(((int) PW_PROP_NOSIBLING << (int) CVINTPT_P_PROPS));
}

/*
 * IS the NOSIBLING property set
 */

PWboolean pwIsNoSiblingCvintpt
(
  struct PWcvintpt *p_cvintpt
)
{
  return (PWboolean) ((p_cvintpt->props &
         ((int) PW_PROP_NOSIBLING << (int) CVINTPT_P_PROPS)) ? TRUE : FALSE);
}


/*
 * Functions Associated with PWcvintpt_list props field.
 *
 *     Following are the properties which can be set on a PWcvintpt_list :
 *         PW_CONTAIN_IN       |
 *         PW_CONTAIN_OUT      |
 *         PW_CONTAIN_ON       |     2 bits ( Category #1 - Left )
 *         PW_CONTAIN_UNKNOWN  |     2 bits ( Category #2 - Right )
 *
 *         PW_PROP_ARBSEQUNCE  |     1 bit
 *         PW_PROP_COINCNEXT   |     1 bit
 *         PW_PROP_COINCPREV   |     1 bit
 *
 *     These properties requires 7 bits :
 *       o 2 for LEFT CONTAINMENT  (stored in 0 and 1)
 *       o 2 for RIGHT CONTAINMENT (stored in 2 and 3)
 *       o 1 bit for whether the node is in ARBSEQ list (stored in 4)
 *       o 1 bit for deciding whether this node COINCIDENT with the NEXT node
 *         (stored in 5)
 *       o 1 bit for deciding whether this node COINCIDENT with the PREV node
 *         (stored in 6)
 */

/* Position of the bits */

#define  CVINTLIST_P_LEFTCONTAIN   1 /* position of the left containment bits
                                        in the properties word */
#define  CVINTLIST_P_RIGHTCONTAIN  3 /* position of the right containment bits
                                        in the properties word */
#define  CVINTLIST_P_PROPS         4 /* end position of the properties bits in
                                        the properties word */

/* Number of bits */

#define  CVINTLIST_N_CONTAIN       2 /* Number of bits the containment property
                                        requires */
#define  CVINTLIST_N_PROPS         4 /* Number of bits the properties fields
                                        requires */

/*
 * Set CONTAIN properties
 */

void pwSetContainCvintptList
(
  struct PWcvintpt_list *p_cvintpts,
  int                   side,
  enum   PWcontaintype  containment
)
{
  unsigned int pos;

  if( side == LEFT )
    pos = CVINTLIST_P_LEFTCONTAIN;
  else
    pos = CVINTLIST_P_RIGHTCONTAIN;

  if( containment == PWcontain_in )
    pwSetBits(&p_cvintpts->props, pos, CVINTLIST_N_CONTAIN, PW_CONTAIN_IN);
  else if( containment == PWcontain_out )
    pwSetBits(&p_cvintpts->props, pos, CVINTLIST_N_CONTAIN, PW_CONTAIN_OUT);
  else if( containment == PWcontain_on )
    pwSetBits(&p_cvintpts->props, pos, CVINTLIST_N_CONTAIN, PW_CONTAIN_ON);
  else
    pwSetBits(&p_cvintpts->props, pos, CVINTLIST_N_CONTAIN, PW_CONTAIN_UNKNOWN);
}

/*
 * Get the CONTAIN property
 */

enum PWcontaintype pwGetContainCvintptList
(
  struct PWcvintpt_list *p_cvintpts,
  int                   side
)
{
  unsigned int props;

  if( side == LEFT )
    props = pwGetBits(p_cvintpts->props, CVINTLIST_P_LEFTCONTAIN,
                     CVINTLIST_N_CONTAIN);
  else
    props = pwGetBits(p_cvintpts->props, CVINTLIST_P_RIGHTCONTAIN,
                     CVINTLIST_N_CONTAIN);

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
 * Set the ARBSEQUNCE property
 */

void pwSetArbSeqCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  p_cvintpts->props = p_cvintpts->props |
                      ((int) PW_PROP_ARBSEQUENCE << (int) CVINTLIST_P_PROPS);
}

/*
 * Unset the ARBSEQUENCE property
 */

void pwUnsetArbSeqCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  p_cvintpts->props = p_cvintpts->props &
                      ~(((int) PW_PROP_ARBSEQUENCE << (int) CVINTLIST_P_PROPS));
}

/*
 * IS the ARBSEQUENCE property set
 */

PWboolean pwIsArbSeqCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  return (PWboolean) ((p_cvintpts->props &
      ((int) PW_PROP_ARBSEQUENCE << (int) CVINTLIST_P_PROPS)) ? TRUE : FALSE);
}

/*
 * Set the COINC property
 */

void pwSetCoincCvintptList
(
  struct PWcvintpt_list *p_cvintpts,
  int                   side
)
{
  int   props;

  if( side == PREV )
    props = PW_PROP_COINCPREV;
  else
    props = PW_PROP_COINCNEXT;

  p_cvintpts->props = p_cvintpts->props | (props << (int) CVINTLIST_P_PROPS);

}


/*
 * Unset the COINC property
 */

void pwUnsetCoincCvintptList
(
  struct PWcvintpt_list *p_cvintpts,
  int                   side
)
{
  int   props;

  if( side == PREV )
    props = PW_PROP_COINCPREV;
  else
    props = PW_PROP_COINCNEXT;

  p_cvintpts->props = p_cvintpts->props & ~((props << (int) CVINTLIST_P_PROPS));

}

/*
 * IS the COINC property set
 */

PWboolean pwIsCoincCvintptList
(
  struct PWcvintpt_list *p_cvintpts,
  int                   side
)
{
  int   props;

  if( side == PREV )
    props = PW_PROP_COINCPREV;
  else
    props = PW_PROP_COINCNEXT;

  return (PWboolean) ((p_cvintpts->props & (props << (int) CVINTLIST_P_PROPS)) ?
                     TRUE : FALSE);
}

/*
 * Set the INFONODE property
 */

void pwSetInfoNodeCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  p_cvintpts->props = p_cvintpts->props |
                      ((int) PW_PROP_INFONODE << (int) CVINTLIST_P_PROPS);
}

/*
 * Unset the INFONODE property
 */

void pwUnsetInfoNodeCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  p_cvintpts->props = p_cvintpts->props &
                      ~(((int) PW_PROP_INFONODE << (int) CVINTLIST_P_PROPS));
}

/*
 * IS the INFONODE property set
 */

PWboolean pwIsInfoNodeCvintptList
(
  struct PWcvintpt_list *p_cvintpts
)
{
  PWboolean temp_info=0;
  unsigned int infonode= PW_PROP_INFONODE, pprops = CVINTLIST_P_PROPS;

  temp_info = ((p_cvintpts->props) &	(unsigned int)(infonode <<  pprops)) ? (TRUE) : (FALSE);
  return(temp_info);

/*
  return (PWboolean) ((p_cvintpts->props &
        ((int) PW_PROP_INFONODE << (int) CVINTLIST_P_PROPS)) ? TRUE : FALSE);
*/
}

/*
  ABSTRACT

  Given an intersection list on an intersection curve, it returns the
  sorted (ascending order of the paramaeter values) intersection list.

  Sorts the input intersection list in the ascending order of the parameter
  values. If there are any coincident nodes in the input list, it sets the
  COINCNEXT or COINCPREV properties depending on whether the node is coinc-
  ident with the next or prev node. If possible it tries to arrange the co-
  inc nodes set properly taking the help from the adjacent nodes to the co-
  inc set. If the coincident set cannot be arranged properly, then it sets
  'ArbSeq' property to all the nodes in the set and returns PW_K_Ambiguous
  otherwise it returns PW_K_Success.

  The output list is a sorted intersection list.


  RETURN VALUES

  PW_K_Success    - Success
  PW_K_Ambiguous  - Ambiguity
  PW_K_InvalidArg - Invalid Input Arguments
*/

PWresult pwSortCvintptList
(
  struct PWcvintpt_list  **p_cvintpts,    /*  I/O  */
  double                 tol               /*   I   */
)
{
  /* loop variables */
  int  inx1, inx2;

  /* general variables */
  int  n_int = 0, spinx, next_spinx;
  double sppar, next_sppar;

  /* cvintpt_list variables */
  struct PWcvintpt_list *p_head=NULL, *p_node=NULL, *p_next_node=NULL;
  struct PWcvintpt_list *p_prev_node=NULL;

  /*
   * validate the incoming arguments
   */
  if( !p_cvintpts || !*p_cvintpts )
    return (SetError(PW_K_Pathway, PW_K_InvalidArg));

  p_prev_node = (*p_cvintpts)->p_prev;
  (*p_cvintpts)->p_prev = NULL;

  /*
   * get the number of nodes in the list, and if the number of nodes is one
   * then just return the success.
   */
  p_head = p_node = *p_cvintpts;

  /*
   * first unset ArbSeq and Coinc properties on the incoming list.
   */
  while (p_node)
  {
    pwUnsetArbSeqCvintptList (p_node);
    if (p_node->p_prev)
      pwUnsetCoincCvintptList (p_node, PREV);
    pwUnsetCoincCvintptList (p_node, NEXT);
    p_node = p_node->p_next;
  }

  n_int = pwNumCvintptList(p_head);
  if( n_int == 1 )
  {
    (*p_cvintpts)->p_prev = p_prev_node;
    if (p_prev_node)
      p_prev_node->p_next = *p_cvintpts;
    return PW_K_Success;
  }

  /*
   * loop over all the nodes and arrange them in the ascending order of their
   * parameter values.
   */
  for(inx1=0; inx1<n_int-1; inx1++)
  {
    p_node = *p_cvintpts;
    for(inx2=0; inx2<n_int-inx1-1; inx2++)
    {
      /*
       * get the span index and span parameters of a pair of nodes. This pair
       * consists of the current node and it's next node.
       */
      spinx  = p_node->intpt.cvpt.cvparam.spaninx;
      sppar  = p_node->intpt.cvpt.cvparam.spanpar;

      p_next_node = p_node->p_next;
      next_spinx  = p_next_node->intpt.cvpt.cvparam.spaninx;
      next_sppar  = p_next_node->intpt.cvpt.cvparam.spanpar;

      /*
       * if this node is greater than the next_node then swap the nodes
       * and make the next_node as this current node as swapping occured.
       */
      if( (spinx > next_spinx) ? TRUE :
          ((spinx == next_spinx) ? (sppar > next_sppar) : FALSE) )
      {
        pwSwapNodesCvintptList(p_cvintpts, p_node, p_next_node);
      }
      else
      {
        /*
         * move on to the next pair of nodes
         */
        p_node = p_node->p_next;
      }
    }
  }


  /*
   * Now the above sorted list may consists of coincident nodes, i.e. nodes
   * with the same span indices and parameters and these needs to be arrang-
   * ed properly taking the help of the properties bits set on these nodes.
   * So rearrange the list, so that the coincident nodes gets arranged prop-
   * perly, if unable to arrange them properly then set the Ambiguous prope-
   * on those nodes.
   */
  rearr_cnt = 0;
  RearrangeList(p_cvintpts, tol, NULL);

  /*
   * It may so happen that *p_cvintpts may now not be the head of this
   * sub-list. Traverse and reset *p_cvintpts as the head.
   */
  *p_cvintpts = pwHeadCvintptList(*p_cvintpts);

  /*
   * Reset the "Previous Node" pointer to the head of the list.
   */
  (*p_cvintpts)->p_prev = p_prev_node;
  if (p_prev_node)
    p_prev_node->p_next = *p_cvintpts;

  /*
   * If there is a node in the list with ambiguous property set, return PW_K_
   * Ambiguous otherwise return PW_K_Success.
   */
  if( IsListAmbiguous(*p_cvintpts) )
    return (SetInfo(PW_K_Pathway, PW_K_Ambiguous));
  else
    return PW_K_Success;
}

/*------------------------STATIC FUNCTIONS ---------------------------------*/

/*
 * ABSTRACT
 *    Rearrages the sorted Intersection list so that the Coinc Sets toggles
 *    properly with the adjacent nodes. If the Coinc Set is not toggles pr-
 *    perly then it sets the ArbSeq property to the Coinc Set.
 *
 * SYNOPSIS
 *    struct PWcvintpt_list **p_cvintpts    I/O  header of the list.
 *    double                tol              I   tolerance
 *    struct PWcvintpt_list **p_unamb_node  I   unambiguous node. When first
 *                                               time this function called it
 *                                               can be set to NULL.
 * NOTES / ALGORITHM
 *    This is a recursive function call. First time it is called on the header
 *    of the list with unambiguous node set to NULL.
 *    It checks, whether there are any nodes coincident with the given node
 *    (*p_cvintpts).
 *
 *    o  If the number of coincident nodes is zero, it calls this function
 *       recursively passing next node as the header of the list and present
 *       node as the unambiguous node.
 *    o  else if there are any coincident nodes and there is an unambiguous
 *       node provided, it tries to rearrange the coincident set with the
 *       help of the unambiguous node. If failed to rearragne, it sets the
 *       ArbSeq property to all nodes in the list otherwise if able to rear-
 *       the list properly it gets the next unambiguous node. Then, get the
 *       next node after the coincident list and call this function recursi-
 *       vely on this node.
 *    o  else if there are any coincident nodes and there is no unambiguous
 *       node, get the node after the coincident set and call this routine
 *       recursively with unambiguous node set to NULL. Then use the unamb-
 *       iguous node coming out of this function call to rearrange this co-
 *       incident set.
 */

static void RearrangeList
(
  struct PWcvintpt_list **p_cvintpts,
  double                tol,
  struct PWcvintpt_list **p_unamb_node
)
{
  /*
   * local variable declaration
   */
  int n_coinc_nodes = 0;
  struct PWcvintpt_list *p_u_node=NULL,*p_node, *p_next_node;

  /*
   * validate the incoming arguments
   */
  if( !p_cvintpts || !*p_cvintpts )
    return;
  /*   * HF: 05/16/2001 - OBSOLETED by Fix for TR# MP4946
  if ( rearr_cnt++ > REARR_MAX_CNT )
    return;
  */
  if(p_unamb_node)
    p_u_node = *p_unamb_node;

  /* get the number of nodes coincident with the current node */
  p_node = *p_cvintpts;

  n_coinc_nodes = NumCoincNodes(p_node, tol);

  if( !n_coinc_nodes )
  {
    /*
     * If there are no coincident nodes, call this routine recursively
     * on the next node with unambiguous node as present node
     */
    p_u_node = p_node;
    RearrangeList(&p_node->p_next, tol, &p_u_node);
    if(p_unamb_node) *p_unamb_node = p_u_node;
  }
  else if( p_u_node )
  {
    /*
     * If there are coincident nodes and unambiguous node is provided:
     *    o Rearrange the coinc set with the help of unambiguous node.
     *    o Get the node after the coinc set.
     *    o Call this function recursively on this node.
     */
    RearrangeCoincNodes(&p_node, n_coinc_nodes, &p_u_node);
    p_next_node = pwNodeAtInxCvintptList(p_node, (n_coinc_nodes+1));
    RearrangeList(&p_next_node, tol, &p_u_node);
    if(p_unamb_node) *p_unamb_node = p_u_node;
  }
  else
  {
    /*
     * If there are coincident nodes and unambiguous node is not provided:
     *    o Get the node after the coinc set.
     *    o Call this function recursively on this node.
     *    o Rearrange the coinc set with the help of unambiguous node which
     *      is the output of the previous function call.
     */
    p_next_node = pwNodeAtInxCvintptList(p_node, (n_coinc_nodes+1));
    RearrangeList(&p_next_node, tol, &p_u_node);
    RearrangeCoincNodes(&p_node, n_coinc_nodes, &p_u_node);
    if(p_unamb_node) *p_unamb_node = p_u_node;
  }

  return;
}

/*
 * ABSTRACT
 *    Given a node in the list and tolerance, it returns the number nodes
 *    with in 'tol' from this node and also sets the COINCNEXT or COINCPREV
 *    properties on the corresponding nodes.
 *
 * SYNOPSIS
 *    struct PWcvintpt_list *p_cvintpts   I/O  intersection node
 *    double                tol            I   tolerance
 *
 * NOTES
 *    It only searches in the forward direction, from the given node.
 *
 * RETURN VALUES
 *    int  -  Number of nodes coincident with the given node.
 */

static int NumCoincNodes
(
  struct PWcvintpt_list *p_cvintpts,
  double                tol
)
{
  int                   n_coinc_nodes=0;
  struct PWcvintpt_list *p_node;

  if( !p_cvintpts || !p_cvintpts->p_next )
    return 0;

  p_node = p_cvintpts;

  while( p_node->p_next )
  {
    if ((pwGetTopoposCvpt (&p_node->intpt.cvpt) ==
         pwGetTopoposCvpt (&p_node->p_next->intpt.cvpt)) &&
        pwIsSamePt (p_node->intpt.cvpt.pt, p_node->p_next->intpt.cvpt.pt, tol))
    {
      n_coinc_nodes++;
      pwSetCoincCvintptList(p_node, NEXT);
      pwSetCoincCvintptList(p_node->p_next, PREV);
    }
    else
      break;

    p_node = p_node->p_next;
  }

  return n_coinc_nodes;
}

/*
 * ABSTRACT
 *    Rearranges the COINCIDENT SET given an unambiguous node. If failed to
 *    rearrange or no unambiguous node given it sets the 'ArbSeq' property
 *    to all the nodes in the list.
 *
 * SYNOPSIS
 *    struct PWcvintpt_list  **p_cvintpts     I/O  Coincident List start node
 *    int                    n_nodes            I   Number of coinc nodes
 *    struct PWcvintpt_list  **p_unamb_node   I/O  Unambiguous node
 *
 * DESCRIPTION
 *
 * NOTES
 *    p_unamb_node could be NULL. Unambiguous node could be just before or
 *    just after the COINC SET.
 *
 * RETURN VALUES
 *     None
 */

static void RearrangeCoincNodes
(
  struct PWcvintpt_list **p_cvintpts,
  int                   n_nodes,
  struct PWcvintpt_list **p_unamb_node
)
{
  /*
   * local variable declaration
   */
  int                   i,j,pos,pos1;
  PWboolean             found = FALSE;
  enum PWcontaintype    rel, unamb_rel;
  struct PWcvintpt_list *p_node=*p_cvintpts, *p_u_node;
  struct PWcvintpt_list **p_pointers=NULL, *t_pointer=NULL;

  /*
   * HF: 05/16/2001 - Fix for TR# MP4946
   * Decrease n_nodes by 1. I don't see any reason for processing (n_nodes+1) nodes !?!?
   */
  n_nodes--;
  /*
   * If there is no unambiguous node, set 'ArbeSeq' property on all the nodes
   * of the list and return.
   */
  if( !p_unamb_node || !*p_unamb_node )
  {
    for(i=0; i<=n_nodes; i++)
    {
      pwSetArbSeqCvintptList(p_node);
      p_node = p_node->p_next;
    }

    return;
  }

  p_u_node = *p_unamb_node;

  /*
   * Depending on the position of the unambiguous node, select the POSITION
   * of CONTAINMENT bits compare for toggling.
   */
  if( p_node->p_prev == p_u_node )
  {
    pos  = LEFT;
    pos1 = RIGHT;
  }
  else
  {
    pos  = RIGHT;
    pos1 = LEFT;
  }

  unamb_rel = pwGetContainCvintpt(&p_u_node->intpt, pos1);

  /*
   * store all the coinc node pointers in an array
   */
  p_pointers = (struct PWcvintpt_list **) malloc((n_nodes+1) *
                                          sizeof(struct PWcvintpt_list *));
  for(i=0; i<=n_nodes; i++)
  {
    p_pointers[i] = p_node;
    p_node = p_node->p_next;
    /****
    if( pos == LEFT )
      p_node = p_node->p_next;
    else
      p_node = p_node->p_prev;
    ****/
  }


  /*
   * for each node in the coinc set, try to find a match so that it toggles
   * properly with the unamb_rel.
   */
  for(i=0; i<=n_nodes; i++)
  {
    found = FALSE;
    for(j=i; j<=n_nodes; j++)
    {
      rel = pwGetContainCvintpt(&p_pointers[j]->intpt, pos);
      if( AreToggle(rel, unamb_rel) )
      {
        found = TRUE;
        unamb_rel = pwGetContainCvintpt(&p_pointers[j]->intpt, pos1);
        if(i != j)
        {
          t_pointer = p_pointers[i];
          p_pointers[i] = p_pointers[j];
          p_pointers[j] = t_pointer;
        }
        break;
      }
    }
    if(!found)
      break;
  }
  /*
   * If able to found the match for all the coincident nodes, then swap
   * the nodes to their respective positions.
   */
  if(found)
  {
    if( pos==LEFT )
    {
      if(p_unamb_node) *p_unamb_node = p_pointers[0];
      p_node = p_u_node;

      for(i=0; i<=n_nodes; i++)
      {
        pwRemoveCvintptList(p_cvintpts, p_pointers[i]);
        pwInsertAtInxCvintptList(&p_node, p_pointers[i], (i+1));
      }
    }
    else
    {
      if(p_unamb_node) *p_unamb_node = p_pointers[n_nodes];
      p_node = p_u_node;

      for(i=0; i<=n_nodes; i++)
      {
        pwRemoveCvintptList(p_cvintpts, p_pointers[i]);
        pwInsertAtInxCvintptList(&p_node, p_pointers[i], -(i+1));
      }
    }
  }
  /*
   * Else set the 'ArbSeq' property to the COINC SET.
   */
  else
  {
    p_node = *p_cvintpts;
    for(i=0; i<=n_nodes; i++)
    {
      pwSetArbSeqCvintptList(p_node);
      p_node = p_node->p_next;
    }
  }

  if(p_pointers) free(p_pointers);
  return;
}

/*
 * ABSTRACT
 *    Given an intersection list, it returns TRUE if any node in the
 *    intersection list is set with 'ArbSeq' property otherwise FALSE.
 *
 * SYNOPSIS
 *    struct PWcvintpt_list *p_cvintpts  I header of the list
 *
 * RETURN VALUES
 *     PWboolean : TRUE  - List is Ambiguous
 *                 FALSE - List is not Ambiguous
 */

static PWboolean IsListAmbiguous
(
  struct PWcvintpt_list *p_cvintpts
)
{
  struct PWcvintpt_list *p_node = p_cvintpts;

  while(p_node)
  {
    if(pwIsArbSeqCvintptList(p_node))
      return TRUE;
    p_node = p_node->p_next;
  }

  return FALSE;
}
