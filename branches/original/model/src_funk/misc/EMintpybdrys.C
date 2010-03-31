/*
  DESCRIPTION

    This method does a Boolean intersection between boundaries on a
    line-string, the boundaries being specified in the form -
    span-inx/parameter pairs. The boundaries are sorted in the ascending
    order of parameterization.

  ARGUMENTS
    bdrya		- Input: pointer to list a, containing boundary pairs
    bdryb		- Input: pointer to list b, containing boundary pairs
    partol		- Input: zero-length tolerance in the 'parameter' 
                           space. Used to check for coincidence between 
                           point parameters.
    free_func		- Input: the function that needs to be called on the
                           "info" field of EMSpypoint-structures to free
                           anything that's there. If NULL, then the field is
   	                   deallocated using om$dealloc.
    options		- Input: Currently none. Formerly EMS_INTER_MINPOINTS
                           was supported to process the coincident points such
                           that they produce the minimum number of boundaries
                           as opposed to the maximum number of boundaries. Now
                           the problem is looked at more topologically
                           and a consistent set of boundaries is returned.
    num_outbdry		- Output: number of overlaps
    outbdry		- Output: pointer to overlap list

  ALGORITHM

    Each of the two incoming lists are nodes containing (index, param) pairs.
    Also, the nodes occur as doublets ie., one for left of the segment and
    other for its right. Thus there are 2(m+n) number of nodes. These nodes
    are arranged in increasing order of (index+param), along with whether it
    is left or right of the segment. Assign +1 for left and -1 for
    right end of the segment. As we go down the arrangement, add
    these values. When the sum is 2, we have a overlap starting at
    that node. This is immediately followed by a 'right end' node,
    meaning the overlap terminates there. When a tie develops, special
    handling is required and is detailed in-line.

    examples:  
	
    list a		-----     ------   --    -----    
    list b	      -----     ---------------  -- --
    overlap             ...       ......   ..    .. ..

    arrangement:      L L R R   L L    R   LR R  LR LR    
                      b a b a   b a    a   aa b  ab ba
                                                 L   R
                                                 b   b
  HISTORY
  
    gk   12/10/86:	design date
    ss   02/10/87:      added the ptr_arr association-list.
    ss   03/01/88:      changed so that degenerate boundaries are
		        returnable if they occur. The argument list change.
    sm   09/24/92:      Added a no-op loop. See inline comment.
    ss   01/06/93:      Re-wrote the function since it's handling of
                        coincident cases was not quite right.
*/

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "OMmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"


/*
 * Locally used to structure to store relevant information
 * about the nodes.
 */

struct loc_struct
  {
  IGRshort start_dgnpair;
  struct EMSpypoint *ptr;
  IGRshort bin;
  };

#define NONE   0
#define START  1
#define STOP  -1

#define FIRST  0

static void proc_coinc_bdrys();

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
void EMintpybdrys (msg, bdrya, bdryb, partol, num_outbdry, outbdry,
                   free_func_info, options)
IGRlong	*msg;
struct EMSpypoint *bdrya;
struct EMSpypoint *bdryb;
IGRdouble partol;
IGRint *num_outbdry;
struct EMSpypoint **outbdry;
void (*free_func_info)();
IGRushort options;
{
  IGRshort a_end, b_end, curr_state;
  IGRint num_nodes;
  IGRint anum, bnum, inx;
  IGRdouble a_value, b_value;
  struct loc_struct *node_info;
  struct EMSpypoint *lista, *listb, head_node, *ptr, *bdry_ptr;
  extern void EMpypoint_free();

  *msg = EMS_S_Success;

  *outbdry = NULL;
  *num_outbdry = 0;

  /*
   * Count the number of elements in the two input
   * lists. While visiting each of these nodes set the NXTCOINC property
   * if it applies.
   */

  anum = 0;
  lista = bdrya;
  while (lista)
    {
    if (lista->next &&
        fabs ((lista->span_inx + lista->param) - 
              (lista->next->span_inx + lista->next->param)) <= partol)
      lista->props |= EMS_PYPT_NXTCOINC;

    lista = lista->next;
    anum++;
    }   
  anum /= 2;

  bnum = 0;
  listb = bdryb; 
  while (listb)
    {
    if (listb->next &&
        fabs ((listb->span_inx + listb->param) - 
              (listb->next->span_inx + listb->next->param)) <= partol)
      listb->props |= EMS_PYPT_NXTCOINC;

    listb = listb->next;
    bnum++;
    }   
  bnum /= 2;

  /*
   * If any one of them is empty the intersection
   * is the NULL-set.
   */

  if (!anum || !bnum)
    goto ret_end;

  /*
   * Obtain a merged sequencing of the two lists. In case where each of
   * the nodes has a unique parametrization, the problem is trivial. If
   * the nodes are coincident within and across the lists, then the
   * sequencing is to be handled specially. This is encoded in the local
   * static function.
   */

  num_nodes = 2 * (anum + bnum);
  node_info = (struct loc_struct *) alloca (sizeof (struct loc_struct) *
               num_nodes);
  inx = 0;

  lista = bdrya;
  listb = bdryb;
  a_end = START;
  b_end = START;
  a_value = lista->span_inx + lista->param;
  b_value = listb->span_inx + listb->param;
  curr_state = NULL;

  while (lista || listb)
    {
    /*
     * Out of the current component of A and B, see who goes on first into
     * the local buffer. In the case of a tie, we have to process specially.
     */

    if (a_value < (b_value-partol))      
      {
      /*
       * The current node in list-A occurs before the one in B. Add this
       * to the list, updating the local variables.
       */

      node_info[inx].start_dgnpair = FALSE;
      node_info[inx].bin = a_end;
      node_info[inx++].ptr = lista;

      curr_state += a_end;
      a_end = (a_end == START ? STOP : START);
      lista = lista->next;
      if (lista == NULL)
        a_value = MAXDOUBLE;
      else
        a_value = lista->span_inx + lista->param;
      }
    else if (b_value < (a_value-partol)) 
      {
      /*
       * The current node in list-B occurs before the one in A. Add this
       * to the list, updating the local variables.
       */

      node_info[inx].start_dgnpair = FALSE;
      node_info[inx].bin = b_end;
      node_info[inx++].ptr = listb;
	
      curr_state += b_end;
      b_end = (b_end == START ? STOP : START);
      listb = listb->next;
      if (listb == NULL)
        b_value = MAXDOUBLE;
      else
        b_value = listb->span_inx + listb->param;
      }
    else
      {
      /*
       * The two nodes are coincident within tolerance. There may be other
       * nodes adjacent in the two lists which are also coincident at this
       * point. All these nodes are gathered and processed all at once.
       * The following function call adds info into the node_info array
       * and updates the local variables.
       */

      proc_coinc_bdrys (&lista, &listb, node_info, &inx, &a_end, &b_end,
       &a_value, &b_value, &curr_state);
      }
    }

  /*
   * Using the array "node_info", create the output linked list. Those
   * elements that are not part of the output are deleted.
   */

  bdry_ptr = (struct EMSpypoint *) &head_node;
  inx = FIRST;
  curr_state = node_info[FIRST].bin;
  while (inx < num_nodes)
    {
    if (curr_state == START+START)
      {
      /*	
       * This node and the subsequent node should define an overlap
       * that is part of the output.
       */
      
      EMerr_hndlr (node_info[inx+1].bin != STOP, *msg, EMS_E_Fail, ret_end);
      bdry_ptr->next = node_info[inx].ptr;
      bdry_ptr->next->next = node_info[inx+1].ptr;
      bdry_ptr = bdry_ptr->next->next;
      (*num_outbdry)++;
      curr_state += STOP;

      inx += 2;
      curr_state += node_info[inx].bin;
      }
    else 
      {
      /*
       * This node has nothing to do with the overlap. Delete/free this
       * node.
       */

      ptr = node_info[inx].ptr;
      if (ptr->info)
        {
        if (free_func_info)
          (*free_func_info)(ptr->info, 1);
        else
          om$dealloc (ptr = ptr->info);
        ptr->info = NULL;
        }
      EMpypoint_free (ptr, 1);
 
      inx++;
      curr_state += node_info[inx].bin;
      }
    } 
  bdry_ptr->next = NULL;
  (*outbdry) = head_node.next;

ret_end:
  return;
}



#define A  0
#define B  1

static void  proc_coinc_bdrys (lista, listb, 
                               node_info, node_info_inx, 
                               a_end, b_end, a_value, b_value,
                               curr_state)
struct EMSpypoint **lista, **listb;
struct loc_struct *node_info;
IGRint *node_info_inx;
IGRshort *a_end, *b_end;
IGRdouble *a_value, *b_value;
IGRshort *curr_state;
{
  IGRboolean found;
  IGRshort i, k, s, list_inx, end[2], outend[2], state, prev_end;
  IGRint j, num_inx, tmpinx, num_nodes, num[2];
  struct EMSpypoint *ptr, *list[2], *outlist[2];
  struct loc_struct *dgninfo[2];

  list[A] = *lista;
  list[B] = *listb;
  end[A] = *a_end;
  end[B] = *b_end;

  for (i=A; i<=B; i++)
    {
    num[i] = 1;
    for (ptr=list[i]; ptr->props & EMS_PYPT_NXTCOINC; ptr=ptr->next)
      num[i]++;
    outlist[i] = ptr->next;
    outend[i] = (num[i] % 2) ? (end[i] == START ? STOP : START) : end[i];
    dgninfo[i] = (struct loc_struct *) alloca (num[i] * 
                  sizeof (struct loc_struct));

    dgninfo[i][FIRST].start_dgnpair = FALSE;
    dgninfo[i][FIRST].bin = prev_end = end[i];
    dgninfo[i][FIRST].ptr = list[i];
    for (j=1, ptr=list[i]->next; j<num[i]; j++, ptr=ptr->next)
      {
      if (prev_end == START)
        dgninfo[i][j-1].start_dgnpair = TRUE;
      dgninfo[i][j].start_dgnpair = FALSE;
      dgninfo[i][j].bin = prev_end = (prev_end == START ? STOP : START);
      dgninfo[i][j].ptr = ptr;
      }
    }

  /*
   * The tendency here is to NOT output overlaps as far as possible, UNLESS
   * there are "pairs". In the case when there are "pairs" present, we
   * WANT TO to output these pairs as overlaps. We must also be trying
   * to build any overlaps using elements from list-A as far as possible.
   * Using these governing ideas the following code may be derived.
   */
 
  num_nodes = 0;
  num_inx = 0;
  state = *curr_state;
  while (num[A] || num[B])
    {
    if (state == NULL)
      {
      /*
       * You have to START. If there is a "pair" lurking in these parts
       * somewhere, you want to give it a chance to become an overlap. If
       * there is no "pair" then you want to give the element from degn-set-A
       * to become a part of any overlap. So:
       * Look for a "pair" in degn-set-A or in degn-set-B (in this order).
       * If found, look for a START as first element in
       *  degn-set-B or in degn-set-A, respectively.
       * If no "pair" found or no corresponding START in the other 
       *  degn-set found, then,
       *  look for START as first element in current degn-set-B.
       * If not found must find START as first element in current degn-set-A.
       */

      list_inx = 0;
      found = FALSE;
      for (i=A; i<=B && !found; i++)
        for (j=FIRST; j<num[i] && !found; j++)
          if (dgninfo[i][j].start_dgnpair)
            {
            found = TRUE;
            list_inx = (i == A ? B : A);
            }
  
      num_nodes = 1;
      if (!found || !num[list_inx] || !(dgninfo[list_inx][FIRST].bin == START))
        {
        if (num[B] && dgninfo[B][FIRST].bin == START)
          list_inx = B;
        else
          list_inx = A;
        }
      num_inx = FIRST;
      }
    else if (state == START+START)
      {
      /* 
       * You have to STOP. So:
       * Look for STOP as first element in current degn-set-A.
       * If not found must find STOP as first element in current degn-set-B.
       */

      num_nodes = 1;
      if (num[A] && dgninfo[A][FIRST].bin == STOP)
        list_inx = A;
      else
        list_inx = B;
      num_inx = FIRST;
      }
    else if (state == START)
      {
      /*
       * You could START or STOP. So:
       * Look for a "pair" in current degn-set-A.
       * If not found look for a "pair" in current degn-set-B.
       * If not found look for a STOP in current degn-set-A.
       * If not found look for a STOP in current degn-set-B.
       * If not found look for a START in current degn-set-A.
       * If not found must find a START in current degn-set-B.
       */

      found = FALSE;
      for (i=A; i<=B && !found; i++)
        for (j=FIRST; j<num[i] && !found; j++)
          if (dgninfo[i][j].start_dgnpair)
            {
            found = TRUE;
            num_nodes = 2;
            list_inx = i;
            num_inx = j;
            }

      if (!found)
        for (k=0, s=STOP; k<2 && !found; k++, s=START)
          for (i=A; i<=B && !found; i++)
            for (j=FIRST; j<num[i] && !found; j++)
              if (dgninfo[i][j].bin == s)
                {
                found = TRUE;
                num_nodes = 1;
                list_inx = i;
                num_inx = j;
                }
      }

    OM_BLOCK_MOVE (&dgninfo[list_inx][num_inx], &node_info[*node_info_inx],
      num_nodes * sizeof (struct loc_struct));
    if ((tmpinx = num_inx + num_nodes) != num[list_inx])
      OM_BLOCK_MOVE (&dgninfo[list_inx][tmpinx], &dgninfo[list_inx][num_inx],
        (num[list_inx]-tmpinx) * sizeof (struct loc_struct));

    for (i=0; i<num_nodes; i++)
      state += node_info[*node_info_inx+i].bin;
    *node_info_inx += num_nodes;
    num[list_inx] -= num_nodes;
    }

  *lista = outlist[A];
  *listb = outlist[B];
  *a_end = outend[A];
  *b_end = outend[B];
  if (*lista)
    *a_value = (*lista)->span_inx + (*lista)->param;
  else
    *a_value = MAXDOUBLE;
  if (*listb)
    *b_value = (*listb)->span_inx + (*listb)->param;
  else
    *b_value = MAXDOUBLE;
  *curr_state = state;

  return;
}

