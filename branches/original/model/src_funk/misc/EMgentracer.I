/*
  DESCRIPTION:

    This routine is used to reorder elements, such that positional continuity
    between successive elements is maintained as far as possible. The elements
    themselves are not known to this function. Only that information about
    the element that is required for this trace is supplied - endpoints,
    end-tangents (optional; these always point into the curve), etc. 

    A separate array of character pointers having one-to-one correspondence 
    with the set of end-points can also be specified (or a NULL-pointer passed 
    in). This array will be reordered exactly to correspond with the trace. In 
    this way, arbitrary records can be reordered, based on their end-points 
    key.

    The reordering could mean splitting up the elements into groups that have 
    positional continuity between it's elements but not across groups. This 
    would happen when no element from the rest of the set has positional 
    continuity with the group being built. 

    If more than one element becomes a candidate to be added on to the
    end of the current group, the tie is broken by using the following
    criteria: 

      - If end-point tangents are input, this information is instrumental
        in breaking the tie. The criteria used in order of priority is
        as follows:
          i) If an element is degenerate, and it has continuity with other
             element(s), this continuity is chosen over the possibility
             of closing off the degenerate piece. For example: if out of the
             possible elements that can continue the trace, there is a
             degenerate element, this element is chosen over the
             others. The degeneracy has to be flagged by the input trace
             information.
         ii) If (i) does not apply and if the current group potentially closes,
             it is closed regardless of the other candidates. 
        iii) If there are two possible elements that can continue the trace
             forward and iff one of them is a start point (as opposed to a
             stop point of a particular element), this element is chosen.
             The reverse applies in the case the trace is being continued
             backward.
         iv) Out of the possible elements that can continue the trace,
             the one whose end-point tangent subtends the greatest (or
             smallest) angle with the end-point tangent at the start (or stop)
             of the current group, is chosen. The angle is measured counter-
             clockwise w.r.t to the +Z-axis - [0,0,1]. If one were to travel
             along an element, the next element to be picked up by the trace
             will be the "rightmost" out of a set of possible elements.
        This method of breaking the tie elliminates self-intersecting groups.
        
      - If no end-point tangents are input, there is not enough information
        to chose the "good" candidate based on the above criteria. The
        criteria in this case is as follows:
          i) If the current group potentially can be extended (as opposed
             to closed), it is extended regardless of the possibility of 
             closure.
         ii) If out of the possible elements that can continue the trace,
             there is an element whose end-points are within tolerance
             (closed or degenerate), this element is chosen over the
             others.
        iii) If (ii) does not apply then the element whose end-point has the
             minimum distance with the end-point of the current group is
             chosen.
        This method of breaking the tie extends the trace as much as possible,
        with the maximum number of elements possible in a single group.
    
    There is an override capability for all of the above criteria. If the
    caller knows beforehand the contiguity (or the definite lack of it)
    among certain or all of the elements, these can be specified by the
    "forward and backward" index pointers available in the EMStraceinfo
    structure.

    Interpretation of the output:
    ----------------------------
    num_grps - gives the number of groups
    num_elems_grp[i] - gives the number of elements in the ith group
    elems[i][j] - holds the character pointer that corresponds to the
                  jth element in the ith group. If no character pointers
                  were input (NULL pointer) then this 2-dimensional array
                  is not output at all.
    elem_rev[i][j] - if TRUE, means that the jth element in the ith 
                     group needs to be reversed to maintain continuity.
    grp_closed[i] - if TRUE, means that the ith group is closed.

  NOTES
 
    No output argument can have it's memory allocated by the user. The
    memory will be malloced within this function. A function is provided
    for deallocating the memory allocated in this function -
    EMgentracer_free.

  RETURN VALUE

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
          all went well
      - EMS_I_Ambiguous
          the trace involved an ambiguous situation (more than one
          non-degenerate path or multiple degenerate paths possible from
	  an end-point) but was resolved using appropriate criteria listed
	  above.

      Error codes:
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
    
  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
    SS  :  05/23/89  :  Modified the way the handling of a search node
                        known both at it's start and stop was being handled.
    SS  :  05/10/89  :  The old dot-product criteria used when end-tangents
                        were supplied has been replaced by the minimum-maximum
                        angle rule, as described in the description above.
    SS  :  03/28/89  :  If a choice of trace paths occur with non-degenerate
			elements or with multiple degenerate elements, this
                        condition is indicated in the return code.
    SS  :  02/22/89  :  Changed the logic to not look for closure if
                        there is any kind of continuity information.
    SS  :  02/13/89  :  Added the return code EMS_I_Ambiguous in cases
                        where more than one path was found for tracing,
                        but was resolved in favor of one.
    SS  :  02/24/88  :  Modified so that, when no tangent vectors are supplied
                        the trace will pick the best continuity candidate
                        as the one that causes the maximum number of elements
                        to get included within a group. Also the minimum
                        distance criterion is maintained.
    SS  :  03/01/87  :  Creation  
*/

class implementation Root;

#include "EMS.h"
#include <stdio.h>
%safe
#include <math.h>
%endsafe

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSstruct.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bscrossp.h"

/*
 * Local structures, for use only by this 
 * function.
 */

struct work_loc1
  {
  /*
   * Input
   */

  IGRdouble endpts[6];
  IGRdouble tanvecs[6];
  IGRchar *elemptr;
  IGRboolean degenerate;
  IGRboolean no_fwd_search;
  IGRboolean no_bwd_search;
  struct work_loc1 *conn_fwd;
  struct work_loc1 *conn_bwd;
  struct work_loc1 *no_conn_fwd;
  struct work_loc1 *no_conn_bwd;

  /*
   * Output
   */

  IGRboolean elem_rev;
  IGRboolean end_of_string;
  IGRboolean string_closed;
  struct work_loc1 *next;
  struct work_loc1 *prev;
  };

struct work_loc2
  {
  IGRboolean atstart;
  IGRdouble dist;
  struct work_loc1 *node;
  };

#define START  0
#define STOP   1

#define FIRST  0
#define SECOND 1

%safe
static void ANG(), DIST();
static IGRboolean contatstart();
%endsafe

void EMgentracer (msg, num_elems, dim, endpts, tanvecs, elemptrs, tol, trcinfo,
                  num_grps, num_elems_grp, elems, elem_rev, grp_closed)
IGRlong *msg;
IGRint num_elems;
IGRshort dim;
IGRdouble *endpts, *tanvecs, tol;
IGRchar *elemptrs[];
struct EMStraceinfo *trcinfo;
IGRint *num_grps, **num_elems_grp;
IGRchar ****elems;
IGRboolean ***elem_rev, **grp_closed;
{
  IGRboolean search_start, closed_condition, degen_condition;
  IGRboolean first_consistent, second_consistent;
  IGRboolean curr_start_atstart, curr_stop_atstart, curr_atstart[2];
  IGRboolean best_atstart, best_knownnode, no_cont, already_found;
  IGRboolean use_mdist_criterion, this_node_known;
  IGRboolean continue_search_start, continue_search_stop;
  IGRushort degen_flag[2];
  IGRshort incr, numends_process;
  IGRint i, j, inx, endinx, offinx, num, blk_size;
  IGRint nodes_atend_blksize[2], num_nodes_atend[2];
  IGRint num_processed;
  IGRdouble *endpt[2], *tanvec[2], *search_endpt[2];
  IGRdouble dist, mindist, dist_end, dist_start, dist_stop;
  IGRdouble ang, minmaxang, ang_start, ang_stop;
  struct work_loc1 *records, *curr_start_node, *curr_stop_node, *curr_node[2];
  struct work_loc1 *cont_node, *nocont_node;
  struct work_loc1 *nextproc_node, *search_node, *bestnode;
  struct work_loc2 *nodes_atend[2];


  *msg = EMS_S_Success;

  records = NULL;
  nodes_atend[START] = NULL;
  nodes_atend[STOP] = NULL;

  *num_grps = 0;
  EMerr_hndlr (!num_elems, *msg, EMS_I_NoSolution, ret_end);

  /*
   * Copy the input into a local data-structure that
   * can be directly used in the manipulations ahead.
   * The data-structure is a linked list of structures. A
   * dummy node is put at the head of the list, so that
   * the real head is just a typical node (for ease of processing).
   */

  records = (struct work_loc1 *) om$malloc (size = (num_elems+1) *
             sizeof (struct work_loc1));
  EMerr_hndlr (!records, *msg, EMS_E_NoDynamicMemory, ret_end);

  records[0].prev = NULL;
  records[0].next = &records[1];
  for (i=1; i<num_elems; i++)
    {
    records[i].prev = &records[i-1];
    records[i].next = &records[i+1];
    }
  records[num_elems].prev = &records[num_elems-1];
  records[num_elems].next = NULL;

  for (i=1, j=0; j<num_elems; i++, j++)
    {
    records[i].degenerate = FALSE;
    records[i].conn_fwd = NULL;
    records[i].conn_bwd = NULL;
    records[i].no_fwd_search = FALSE;
    records[i].no_bwd_search = FALSE;
    records[i].no_conn_fwd = NULL;
    records[i].no_conn_bwd = NULL;

    if (trcinfo)
      {
      records[i].degenerate = trcinfo[j].degenerate;

      if (trcinfo[j].known_fwd_cont)
        records[i].conn_fwd = &records[trcinfo[j].fwd_cont+1];
      if (trcinfo[j].known_bwd_cont)
        records[i].conn_bwd = &records[trcinfo[j].bwd_cont+1];

      if (trcinfo[j].known_no_fwd_cont)
        {
        if (trcinfo[j].no_fwd_cont < 0)
          records[i].no_fwd_search = TRUE;
        else
          records[i].no_conn_fwd = &records[trcinfo[j].no_fwd_cont+1];
        }
      if (trcinfo[j].known_no_bwd_cont)
        {
        if (trcinfo[j].no_bwd_cont < 0)
          records[i].no_bwd_search = TRUE;
        else
          records[i].no_conn_bwd = &records[trcinfo[j].no_bwd_cont+1];
        }
      }
    }

  incr = 2 * dim;
  blk_size = incr * sizeof (IGRdouble);
  for (i=1, j=0; i<num_elems+1; i++, j+=incr)
    {
    OM_BLOCK_MOVE (&endpts[j], records[i].endpts, blk_size);
    if (tanvecs)
      OM_BLOCK_MOVE (&tanvecs[j], records[i].tanvecs, blk_size);
    if (elemptrs)
      records[i].elemptr = elemptrs[i-1];
    records[i].elem_rev = FALSE;
    records[i].end_of_string = FALSE;
    records[i].string_closed = FALSE;
    }

  /*
   * Setup the control variables, like current string (denoted by curr_node
   * - [START] and [STOP]), it's end-points, etc. Then enter the iterative 
   * processing. For programming convenience, some redundant arrays 
   * containing the curr node information and their open ends, are also
   * initialized and maintained, viz., curr_node[2] and curr_atstart[2].
   */

  curr_start_node = &records[1];
  curr_stop_node = &records[1];
  endpt[START] = &curr_start_node->endpts[0];
  endpt[STOP] = &curr_stop_node->endpts[dim];
  curr_start_atstart = TRUE;
  curr_stop_atstart = FALSE;

  curr_node[START] = curr_start_node;
  curr_node[STOP] = curr_stop_node;
  curr_atstart[START] = curr_start_atstart;
  curr_atstart[STOP] = curr_stop_atstart;

  if (tanvecs)
    {
    tanvec[START] = &curr_start_node->tanvecs[0];
    tanvec[STOP] = &curr_stop_node->tanvecs[dim];
    }
  nextproc_node = curr_stop_node->next;
  num_processed = 0;


  for (endinx=START; endinx<=STOP; endinx++)
    {
    nodes_atend_blksize[endinx] = 3;
    nodes_atend[endinx] = (struct work_loc2 *) om$malloc (size = 3 *  
                           sizeof (struct work_loc2));
    EMerr_hndlr (!nodes_atend[endinx], *msg, EMS_E_NoDynamicMemory,
     ret_end);
    }

  /*
   * Begin the iterative procedure for rearranging the
   * local linked list. Information about closure and
   * reversal of element is added in as it becomes
   * available.
   */

  while (num_processed < num_elems)
    {
    search_node = nextproc_node;
    num_nodes_atend[START] = 0;
    num_nodes_atend[STOP] = 0;

    /*
     * See if the continuity information present indicates that the
     * current string is closed. If so, flag this condition and stop
     * the search for the next node.
     */

    closed_condition = FALSE;
    continue_search_start = TRUE;
    continue_search_stop = TRUE;
    for (endinx=START; endinx<=STOP; endinx++)
      {
      if (curr_node[endinx] && 
          (curr_atstart[endinx] ? 
            curr_node[endinx]->conn_bwd :
            curr_node[endinx]->conn_fwd) == curr_node[! endinx])
        {
        closed_condition = TRUE;
        continue_search_start = FALSE;
        continue_search_stop = FALSE;
        break;
        }
      }

    /*
     * If tangent-vectors have been supplied and the current string is
     * not degenerate and no continuity information at the string's end-points
     * is present, do a geometric check to see if the current string is
     * closed on itself. If closed, the string may be terminated as closed.
     * On the other hand, if no tangent-vectors have been supplied the search
     * must be carried out through the remaining elements for continuity. 
     */

    degen_condition = FALSE;
    no_cont = FALSE;
    cont_node = NULL;

    degen_condition = curr_node[START] == curr_node[STOP] && 
                       curr_node[START]->degenerate;
    for (endinx=START; endinx<=STOP; endinx++)
      {
      no_cont = curr_atstart[endinx] ? 
                 curr_node[endinx]->no_bwd_search : 
                 curr_node[endinx]->no_fwd_search;
      cont_node = curr_atstart[endinx] ? 
                   curr_node[endinx]->conn_bwd : 
                   curr_node[endinx]->conn_fwd;
      if (no_cont || cont_node)
        break;
      }

    if ((continue_search_start || continue_search_stop) && 
        tanvecs && !(degen_condition || no_cont || cont_node))
      {
      DIST (dim, endpt[START], endpt[STOP], &dist_end);
      if (dist_end <= tol)
        {
        closed_condition = TRUE;
        continue_search_start = FALSE;
        continue_search_stop = FALSE;
        }
      }

    /*
     * Search the remaining set of nodes for a candidate (or all the
     * candidates) that might have continuity at the current string's 
     * endpoints. Both the endpoints are processed simultaneously, unless
     * dictated otherwise within this search. 
     */

    numends_process = START + STOP;
    while ((continue_search_start || continue_search_stop) && search_node)
      {
      this_node_known = FALSE;
      search_endpt[START] = &search_node->endpts[0];
      search_endpt[STOP] = &search_node->endpts[dim];
      for (endinx=START; endinx<=numends_process; endinx++)
        {
        if (!continue_search_start)
          break;

        no_cont = curr_atstart[endinx] ? 
                   curr_node[endinx]->no_bwd_search : 
                   curr_node[endinx]->no_fwd_search;
        if (no_cont)
          {
          /*
           * It has been indicated that no continuity needs to be
           * looked for at this particular end of the current-string.
           * So continue on to the other end or (if both ends say the same
           * thing) terminate the for-loop.
           */

          continue;
          }

        cont_node = curr_atstart[endinx] ? 
                     curr_node[endinx]->conn_bwd : 
                     curr_node[endinx]->conn_fwd;
        if (cont_node)
          {
          /*
           * The continuity at this end has been indicated already
           * by the caller. If the current search node happens to be this
           * node then pick it up and treat it like the best node. 
           * The logic does not handle the same node being known at both ends
           * during the same iteration. Therefore, if "cont_node" is already
           * known at either end, break. This cont_node will definitely be
           * picked up in the next iteration. Ambiguity can arise if both the
           * fwd and bwd connections from the search_node are to the curr_node
           * (in the case of two element, closed groups). In this latter case,
           * resort to minimum distance/min-max angle subtension criterion to
           * pick the correct end. 
           */
         
          if (cont_node != search_node)
            break;

          already_found = FALSE;
          for (i=START; i<=STOP; i++)
            for (j=0; j<num_nodes_atend[i]; j++)
              if (cont_node == nodes_atend[i][j].node)
                already_found = TRUE;
          if (already_found)
            break;

          if (search_node->conn_fwd == curr_node[endinx])
            {
            if (search_node->conn_bwd == curr_node[endinx])
              search_start = contatstart (dim, tol, tanvecs, search_node,
                              curr_node[endinx], curr_atstart[endinx], endinx);
            else
              search_start = FALSE;
            }
          else
            search_start = TRUE;

          mindist = -MAXDOUBLE;
          best_knownnode = TRUE;
          if (endinx == START)
            continue_search_start = FALSE;
          else
            continue_search_stop = FALSE;
          }
        else
          {
          /*
           * No continuity has been indicated by the caller. So conduct
           * distance check with the current candidate and determine
           * continuity. Do not pick up an end of the search-node that has
           * continuity already indicated on it. It will be picked up
           * by the continuity-pointer check. Also, do not pick up an
           * end of the search-node that has NO-continuity indicated with
           * current end of this node. Further, if both the end-points
           * of this search-node were potential candidates, an ambiguous
           * trace path has occurred. Indicate this in the return code.
           * Also, resolve this ambiguity amicably using min-max angle
           * criteria when tanvecs is supplied and the element is 
           * non-degenerate.
           */

          nocont_node = curr_atstart[endinx] ? 
                         curr_node[endinx]->no_conn_bwd : 
                         curr_node[endinx]->no_conn_fwd;
          if (!search_node->conn_bwd &&
              (!nocont_node || search_node->no_conn_bwd != curr_node[endinx]))
            DIST (dim, endpt[endinx], search_endpt[START], &dist_start);
          else
            dist_start = MAXDOUBLE;
     
          if (!search_node->conn_fwd &&
              (!nocont_node || search_node->no_conn_fwd != curr_node[endinx]))
            DIST (dim, endpt[endinx], search_endpt[STOP], &dist_stop);
          else
            dist_stop = MAXDOUBLE;

          search_start = dist_start < dist_stop;
          mindist = search_start ? dist_start : dist_stop;
          best_knownnode = FALSE;

          if (dist_start <= tol && dist_stop <= tol &&
              !search_node->degenerate)
            {
            if (tanvecs)
              {
              ANG (dim, tanvec[endinx], search_node->tanvecs, 
               &ang_start);
              ANG (dim, tanvec[endinx], &search_node->tanvecs[dim], 
               &ang_stop);
              search_start = endinx == START ? 
                              ang_start > ang_stop : ang_start < ang_stop;
              mindist = search_start ? dist_start : dist_stop;
              }
            *msg = EMS_I_Ambiguous;
            }
          }

        if (mindist <= tol || best_knownnode)
          {
          /*
           * The processing of these nodes assumes that the nodes at each end
           * of the current string are unique. Therefore the same node should
           * not be known twice at the two ends. But it is possible that the
           * best candidate for the two ends of the current string is this
           * very search node. So if we simply do not add this node to
           * the list of nodes known at the other end and yet go ahead
           * and process both ends, a not so good node may get selected for
           * the other end (the best out of the group that does get known
           * at this other end). The fix for this is as follows:
           * Determine if the current search node is known at both ends.
           * If so all further processing will process for only the start end
           * and completely ignore the stop end. This is done so that the stop
           * end will get a chance to attach to this search node in the next
           * iteration.
           */

          if (this_node_known)
            {
            numends_process = START;
            break;
            }
          else
            this_node_known = TRUE; 

          num = (num_nodes_atend[endinx]+=1);
          if (nodes_atend_blksize[endinx] < num)
            {
            nodes_atend[endinx] = (struct work_loc2 *) om$realloc
                  (ptr = (IGRchar *)nodes_atend[endinx], size = num * 
                  sizeof (struct work_loc2));
            nodes_atend_blksize[endinx] = num;
            }
          nodes_atend[endinx][num-1].atstart = search_start;
          nodes_atend[endinx][num-1].dist = mindist;
          nodes_atend[endinx][num-1].node = search_node;

          /*
           * Assign priority to these continuities by appropriately
           * altering the minimum-distance. The order of priorities is
           * listed in the notes above.
           */

          if (search_node->degenerate)
            nodes_atend[endinx][num-1].dist = -(2*tol-mindist);
          else if (!tanvecs && !best_knownnode)
            {
            DIST (dim, search_endpt[START], search_endpt[STOP], &dist_end);
            if (dist_end <= tol)
              nodes_atend[endinx][num-1].dist = -(tol-mindist);
            }
          }
        }
      search_node = search_node->next;
      }

    /*
     * Rearrange the local linked list and
     * update the control information to reflect
     * an advance in the iterative process. 
     */

    for (endinx=START; endinx<=numends_process; endinx++)
      {
      if (num_nodes_atend[endinx])
        {
        if (num_nodes_atend[endinx] > 1)
          {
          /*
           * Pick the one node out of the set of search_nodes that best fits
           * the criteria. If this multiplicity of trace paths is caused
           * simply because of a single degenerate search-node, then do
           * not flag ambiguity, (the resolution is quite clear); in all other
           * cases indicate that an ambiguous situation occurred. 
           *
           * If tangent-vectors have been supplied and no candidate is
           * degenerate:
           * the one which has the maximum angle (if at start end of current
           * string) or minimum angle (if at stop end of current string) with
           * the current endpoints tangent-vector is chosen. For this, 
           * the variables, minmaxang, bestnode and the Boolean best_atstart 
           * are maintained.
           *
           * If the tangent-vectors have not been supplied or atleast
           * one of the candidates is degenerate:
           * the one with the smallest distance to the current end-point
           * is chosen.
           */
    
          if (num_nodes_atend[endinx] == 2)
            {
            for (i=FIRST; i<=SECOND; i++)
              degen_flag[i] = nodes_atend[endinx][i].node->degenerate ? 
                               0x1 : 0x0;
            if (!(degen_flag[FIRST] ^ degen_flag[SECOND]))
              *msg = EMS_I_Ambiguous;
            }
          else
            *msg = EMS_I_Ambiguous;

          if (tanvecs)
            {
            use_mdist_criterion = FALSE;
            for (i=0; i<num_nodes_atend[endinx]; i++)
              if (nodes_atend[endinx][i].node->degenerate)
                {
                use_mdist_criterion = TRUE;
                break;
                }
            }
          else
            use_mdist_criterion = TRUE;
           
          bestnode = nodes_atend[endinx][FIRST].node;
          best_atstart = nodes_atend[endinx][FIRST].atstart;

          already_found = FALSE;
          if (num_nodes_atend[endinx] == 2 &&
              !(degen_flag[FIRST] || degen_flag[SECOND]))
            {
            first_consistent = curr_atstart[endinx] ^
                                best_atstart;
            second_consistent = curr_atstart[endinx] ^
                                 nodes_atend[endinx][SECOND].atstart;
            if (first_consistent ^ second_consistent)
              {
              inx = first_consistent ? FIRST : SECOND;
              bestnode = nodes_atend[endinx][inx].node;
              best_atstart = nodes_atend[endinx][inx].atstart;
              already_found = TRUE;
              }
            }
          
          if (!already_found)
            {
            offinx = best_atstart ? 0 : dim;
            if (use_mdist_criterion)
              mindist = nodes_atend[endinx][0].dist;
            else
              ANG (dim, tanvec[endinx], &bestnode->tanvecs[offinx], 
               &minmaxang);

            for (i=1; i<num_nodes_atend[endinx]; i++)
              {
              search_node = nodes_atend[endinx][i].node;
              offinx = nodes_atend[endinx][i].atstart ? 0 : dim;
              if (use_mdist_criterion)
                dist = nodes_atend[endinx][i].dist;
              else
                ANG (dim, tanvec[endinx], &search_node->tanvecs[offinx], 
                 &ang);
  
              if (use_mdist_criterion ? 
                   dist < mindist : 
                   endinx == START ? ang > minmaxang : ang < minmaxang)
                {
                best_atstart = nodes_atend[endinx][i].atstart;
                bestnode = search_node;
                if (use_mdist_criterion)
                  mindist = dist;
                else
                  minmaxang = ang;
                }
              }
            }
          }
        else
          {
          /*
           * There is only one candidate node in the set
           * of search_nodes for this end. Therefore this
           * node is treated as the one having the minimum/maximum 
           * angle.
           */

          bestnode = nodes_atend[endinx][0].node;
          best_atstart = nodes_atend[endinx][0].atstart;
          }

        /*
         * Rearrange the linked list according to the
         * information - bestnode and best_atstart. Also
         * update the control information.
         */

        if (bestnode->prev)
          bestnode->prev->next = bestnode->next;
        if (bestnode->next)
          bestnode->next->prev = bestnode->prev;

        if (endinx == START)
          {
          bestnode->prev = curr_start_node->prev;
          bestnode->next = curr_start_node;
          if (curr_start_node->prev)
            curr_start_node->prev->next = bestnode;
          curr_start_node->prev = bestnode;

          if (best_atstart)
            {
            bestnode->elem_rev = TRUE;
            endpt[START] = &bestnode->endpts[dim];
            curr_start_atstart = FALSE;
            if (tanvecs)
              tanvec[START] = &bestnode->tanvecs[dim];
            }
          else
            {
            endpt[START] = &bestnode->endpts[0];
            curr_start_atstart = TRUE;
            if (tanvecs)
              tanvec[START] = &bestnode->tanvecs[0];
            }
          curr_start_node = bestnode;
          num_processed++;

          curr_node[START] = curr_start_node;
          curr_atstart[START] = curr_start_atstart;
          }
        else
          {
          bestnode->prev = curr_stop_node;
          bestnode->next = curr_stop_node->next;
          if (curr_stop_node->next)
            curr_stop_node->next->prev = bestnode;
          curr_stop_node->next = bestnode;

          if (!best_atstart)
            {
            bestnode->elem_rev = TRUE;
            endpt[STOP] = &bestnode->endpts[0];
            curr_stop_atstart = TRUE;
            if (tanvecs)
              tanvec[STOP] = &bestnode->tanvecs[0];
            }
          else
            {
            endpt[STOP] = &bestnode->endpts[dim];
            curr_stop_atstart = FALSE;
            if (tanvecs)
              tanvec[STOP] = &bestnode->tanvecs[dim];
            }
          curr_stop_node = bestnode;
          num_processed++;

          curr_node[STOP] = curr_stop_node;
          curr_atstart[STOP] = curr_stop_atstart;
          }
        nextproc_node = curr_stop_node->next;
        }
      }

    if (!num_nodes_atend[START] && !num_nodes_atend[STOP])
      {
      /*
       * The current string has no continuation as none
       * of the remaining nodes have endpoint continuity 
       * here. Terminate this string. In the case, where there
       * was no degenrate-condition and no tangent-vectors were
       * specifed, the "closed" state has not been looked at
       * before this step. Do so, in this case and set the
       * "closed" flag correctly.
       */

      if (!closed_condition)
        {
        if (!degen_condition && !tanvecs)
          {
          DIST (dim, endpt[START], endpt[STOP], &dist_end);
          if (dist_end <= tol)
            closed_condition = TRUE;
          }
        }
      curr_stop_node->string_closed = closed_condition;
      curr_stop_node->end_of_string = TRUE;

      /*
       * Start the new string.
       */

      if (nextproc_node)
        {
        curr_start_node = nextproc_node;
        curr_stop_node = nextproc_node;
        endpt[START] = &curr_start_node->endpts[0];
        endpt[STOP] = &curr_stop_node->endpts[dim];
        curr_start_atstart = TRUE;
        curr_stop_atstart = FALSE;
  
        curr_node[START] = curr_start_node;
        curr_node[STOP] = curr_stop_node;
        curr_atstart[START] = curr_start_atstart;
        curr_atstart[STOP] = curr_stop_atstart;

        if (tanvecs)
          {
          tanvec[START] = &curr_start_node->tanvecs[0];
          tanvec[STOP] = &curr_stop_node->tanvecs[dim];
          }
        nextproc_node = curr_stop_node->next;
        }
      num_processed++;
      (*num_grps)++;
      }
    }

  for (endinx=START; endinx<=STOP; endinx++)
    if (nodes_atend[endinx])
      {
      om$dealloc (ptr = nodes_atend[endinx]);
      nodes_atend[endinx] = NULL;
      }

  /*
   * The information in the local data-structure is
   * converted into the output format and the function
   * exits.
   */

  *num_elems_grp = (IGRint *) om$malloc (size = *num_grps * 
                    sizeof (IGRint));
  if (elemptrs)
    *elems = (IGRchar ***) om$malloc (size = *num_grps *
              sizeof (IGRchar **));
  *elem_rev = (IGRboolean **) om$malloc (size = *num_grps *
               sizeof (IGRboolean *));
  *grp_closed = (IGRboolean *) om$malloc (size = *num_grps * 
                 sizeof (IGRboolean));
  EMerr_hndlr (!*num_elems_grp || (elemptrs ? !*elems : FALSE) ||
               !*elem_rev || !*grp_closed, *msg, EMS_E_NoDynamicMemory, 
               ret_end);

  search_node = records[0].next;
  for (i=0; i<*num_grps; i++)
    {
    num_processed = 1;
    while (!search_node->end_of_string)
      {
      search_node = search_node->next;
      num_processed++;
      }
    (*num_elems_grp)[i] = num_processed;
    (*grp_closed)[i] = search_node->string_closed;
    search_node = search_node->next;
    if (elemptrs)
      (*elems)[i] = (IGRchar **) om$malloc (size = num_processed *
                     sizeof (IGRchar *));
    (*elem_rev)[i] = (IGRboolean *) om$malloc (size = num_processed *
                      sizeof (IGRboolean));
    EMerr_hndlr ((elemptrs ? !(*elems)[i] : FALSE) || !(*elem_rev)[i], 
     *msg, EMS_E_NoDynamicMemory, ret_end);
    }

  search_node = records[0].next;
  for (i=0; i<*num_grps; i++)
    {
    for (j=0; j<(*num_elems_grp)[i]; j++)
      {
      if (elemptrs)
        (*elems)[i][j] = search_node->elemptr;
      (*elem_rev)[i][j] = search_node->elem_rev;
      search_node = search_node->next;
      }
    }

ret_end:
  /*
   * Deallocate any work memory that has been
   * allocated here.
   */

  if (records) 
    om$dealloc (ptr = records);
  for (endinx=0; endinx<2; endinx++)
    if (nodes_atend[endinx])
      {
      om$dealloc (ptr = nodes_atend[endinx]);
      nodes_atend[endinx] = NULL;
      }
  if (EMSerror (*msg))
    {
    fprintf (stderr, "EMgentracer\n");
     EFprintcode (stderr, *msg);
    }
}



/*
 * Support functions used within this file. Not intended
 * for general use.
 */

static void DIST (dim, pt1, pt2, dist)
IGRshort dim;
IGRdouble *pt1, *pt2, *dist;
{
  IGRint i;
  IGRdouble temp, dist_loc;

  dist_loc = 0.0;
  for (i=0; i<dim; i++)
    dist_loc += ((temp = pt2[i]-pt1[i]), temp*temp);
  *dist = sqrt (dist_loc);
}

#define ZERO 0
#define NEGATIVE 1
#define POSITIVE 2

static void ANG (dim, vec1, vec2, ang)
IGRshort dim;
IGRdouble *vec1, *vec2, *ang;
{
  IGRshort crossp_sign, dotp_sign;
  IGRint i;
  IGRlong msg_loc;
  IGRdouble dotp;
  IGRvector crossvec;
  extern IGRshort EM2dcrossp();

  dotp = 0.0;
  for (i=0; i<dim; i++)
    dotp += vec1[i] * vec2[i];
  dotp_sign = dotp == 0.0 ? ZERO : dotp > 0.0 ? POSITIVE : NEGATIVE;

  if (dim == 2)
    crossp_sign = EM2dcrossp (NULL, vec1, vec2, NULL, NULL);
  else if (dim == 3)
    {
    BScrossp (&msg_loc, vec1, vec2, crossvec);
    if (crossvec[Z] == 0.0)
      crossp_sign = ZERO;
    else if (crossvec[Z] > 0.0)
      crossp_sign = POSITIVE;
    else
      crossp_sign = NEGATIVE;
    }
  else
    crossp_sign = ZERO;

  if (crossp_sign == POSITIVE)
    *ang = 1.0 - dotp;
  else
    *ang = 3.0 + dotp;
  return;
}

static IGRboolean contatstart (dim, tol, tanvecs, 
                               search_node, curr_node, curr_node_atstart,
                               curr_string_atstart)
IGRshort dim;
IGRdouble tol, *tanvecs;
struct work_loc1 *search_node, *curr_node;
IGRboolean curr_node_atstart, curr_string_atstart;
{
  IGRdouble start_dist, stop_dist;
  IGRdouble start_ang, stop_ang;
  IGRdouble *curr_pts, *search_pts;
  IGRdouble *curr_tan, *search_tan;

  curr_pts = &curr_node->endpts[curr_node_atstart ? 0 : dim];
  search_pts = search_node->endpts;
  DIST (dim, search_pts, curr_pts, &start_dist);
  search_pts = &search_node->endpts[dim];
  DIST (dim, search_pts, curr_pts, &stop_dist);
  if (!tanvecs || fabs (start_dist - stop_dist) > tol)
    return (start_dist < stop_dist);
  else
    {
    curr_tan = &curr_node->tanvecs[curr_node_atstart ? 0 : dim];
    search_tan = search_node->tanvecs;
    ANG (dim, search_tan, curr_tan, &start_ang);
    search_tan = &search_node->tanvecs[dim];
    ANG (dim, search_tan, curr_tan, &stop_ang);
    return (curr_string_atstart ? start_ang > stop_ang : start_ang < stop_ang);
    }   
}




/*
  ABSTRACT:
   
   This function should be used to deallocate memory that has
   been allocated in the trace-function, EMgentracer.
*/

void EMgentracer_free (numgrps, numelem_grp, grps, elem_rev, grps_closed)
IGRint numgrps, *numelem_grp, **grps, **elem_rev, *grps_closed;
{
  IGRint i;

  if (numgrps)
    {
    if (numelem_grp) om$dealloc (ptr = numelem_grp);
    if (grps_closed) om$dealloc (ptr = grps_closed);
    if (grps)
      {
      for (i=0; i<numgrps; i++)
        if (grps[i]) 
          om$dealloc (ptr = grps[i]);
      om$dealloc (ptr = grps);
      }
    if (elem_rev)
      {
      for (i=0; i<numgrps; i++)
        if (elem_rev[i]) om$dealloc (ptr = elem_rev[i]);
      om$dealloc (ptr = elem_rev);
      }
    }
}

end implementation Root;
