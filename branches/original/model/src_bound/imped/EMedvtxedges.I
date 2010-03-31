/*
  DESCRIPTION
    
    This method provides the functionality  of a vertex. It obtains as
    a group, all the edges ending on a given end of an edge. Options
    provide the means of filtering out different kinds of edges, and
    also providing different criteria for the search.

    Options supported (include file - EMSopt.h):

    EMSvtxedges_nodegenerate	- This when set, excludes degenerate edges
                                  from being returned in the group.
    EMSvtxedges_noseamedge	- This when set, excludes all edges
                                  that are seam edges from being output.
    EMSvtxedges_notangent	- Edges whose normals from the two adjacent
				  surfaces line up are not selected. This
				  condition does not apply to edges w/o
				  common edges.
    EMSvtxedges_onlydominant	- This when set, will return only that edge
                                  out of a pair of common edges which is
                                  the dominant one. An edge not having a
                                  common-edge is regarded as dominant.
    EMSvtxedges_onlythissurf    - This when set, will return only those edges
                                  that lie on this surface.
    EMSvtxedges_onlycommon	- Only those edges with common edges are
				  selected.

    The user can pass to this method buffers for output. The number of
    edges for which these buffers are large enough is noted in "num_buff".
    When buffers are passed, "*edges" and "*is_rightend" are assumed to
    able to accomodate "num_buff" edges. If the requirement for memory
    exceeds what has been provided, this method will malloc memory and
    "*edges" and "*is_rightend" will point to malloced locations, respectively.

    Before the call, num_buff and num_edges must be initialized.

  ALGORITHM

    o Check to see if this edge (or the first non-degenerate edge in the
      direction of either the left or the right vertex) is already in the
      output buffer. If so, then exit this method as the search has circled
      back to the starting point. If not, put this edge into the output
      buffer.

    o Get the next edge (or next non-degenerate edge) in the direction of
      either the left or right vertex. Check to see if this next-edge is
      already in the output buffer (only in some special cases will it already
      be in the buffer - closed edges, some degenerate-edge cases, etc.).
      If not in the buffer, put this edge in the buffer.
    
    o Repeat the previous step until a non-degenerate edge is reached, if
      it hasn't been reached already.

    o Send this message across the non-degenerate edge's common-edge channel.
      If no such common edge exists, continue the search on the common
      edge channel of the first edge. If this does not have a common
      edge then terminate.

  NOTES

    This implementation assumes that there is atleast one non-degenerate
    edge in the boundary-loop of this edge. If there isn't any non-degenerate
    edge in this loop, this method goes into an infinite 'loop'.

    The output arguments must be properly initialized to zero or NULL,
    since with recursive calls of this method, the output is appended
    to the arguments.

  HISTORY

   AMD 02/11/92     Fix to prevent infinite recursion.
   AMD 10/18/91     Fixed a malloc problem.
    SS 04/07/91     Changed the name of this method and modified the argument
                    list to accept buffers. Also options replaces three Boolean
                    flags.
    SS 09/19/90     Moved the sent_across_edge=TRUE so that it is now
                    unconditional when a non-degenerate is the next edge.
                    Previously, it was set only when a message send was
                    attempted across common-edges (in the case of the
                    first-edge being degenerate, no send across common-edge is
                    attempted but the logic must assume that this attempt was 
                    made).
    gupta 11/23/87  Changed the logic. Now it can be used for 
                    composites too
    SM	02-Dec-87 option changes to EMnext_edge.

    gupta 03/20/88  Added an arguement include_common_edge. If this is
                    TRUE, it will work as before -- returning all the
                    edges sharing the vertex. If FALSE, only one edge 
                    will be buffered from each edge-common_edge pair.
    SS 10/21/88     Made the function EMgetnextedges, accessible to the
                    outside world. Modified it so that it now returns
  		    upto a specified number of neighboring degenerate edges
  		    or upto a non-degenerate edge (in the specified direction),
                    whichever comes first.
    SS 05/07/91     Changed the name of EMgetnextedges to EMgetnxtedges and
                    put include_degenerate argument into props. Also
		    removed the no_common_edge option and added the 
		    noseamedge option.
    SM 03/25/92     In EMgetnxtedges(), if no next edge found (as in open
		    loop case), exit.
    SM 02/02/93     added another check to the above - if the next edge is
                    same as the ref_edge, exit.
    Sudha 06/04/93  modified to include BSprototype header files
    Aditya 06/13/95 Added a static global to store the first incoming edge,
                    which will help in detecting the end of cycle.
    Subha 10/17/95  If the first edge is a degenerate one then flip the
                    search direction to prevent infinite recursion.
*/

class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "REgencompsf.h"
#include "maidmx.h"

#define BUFF_INCR 6

%safe
static GRobjid start_edge=(OM_S_OBJID)-1;
%endsafe

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetvtxedges (IGRlong *msg; IGRushort options;
                      IGRboolean right_vtx;
                      IGRint num_buff;
                      IGRint *num_edges; 
                      GRobjid **edges; IGRboolean **is_rightend)
{
  IGRboolean sent_across_edge, edge_in_buffer, is_neutral, is_convex;
  IGRboolean my_loc, next_loc;
  IGRushort include_nodegenerate, include_noseamedge;
  IGRushort include_onlydominant, include_onlythissurf;
  IGRushort include_onlycommon, include_notangent;
  IGRushort edprops, fe_props;
  IGRshort mattyp;
  IGRuint dum_count;
  IGRint stat_OM, i;
  IGRint has_common, comm_edge_count, num_found, num_skipped;
  IGRlong msg_loc;
  IGRmatrix mat;
  GRobjid first_edge, current_edge, next_edge;
  OM_S_CHANSELECT chan_to_common_edge;
  OM_S_OBJECT_LINKAGE comm_edge;
  IGRlong EMgetnxtedges();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If my_id is the start egde and num_edges is zero,
   * then, we have reached the end of cycle. So exit.
   */
  if ((my_id == start_edge) && !(*num_edges))
  {
    goto ret_end;
  }

  include_nodegenerate = options & EMSvtxedges_nodegenerate;
  include_noseamedge = options & EMSvtxedges_noseamedge;
  include_onlydominant = options & EMSvtxedges_onlydominant;
  include_onlythissurf = options & EMSvtxedges_onlythissurf;
  include_onlycommon = options & EMSvtxedges_onlycommon;
  include_notangent = options & EMSvtxedges_notangent;

  /*
   * Check if this edge (or next non-degenerate edge) is already
   * there in the incoming list. If so, the search has circled
   * back to the starting point. Return.
   */

  fe_props = ME.EMSedge->ed_props;
  if (include_nodegenerate && fe_props & EMED_DEGENERATE)
    {
    stat_OM = EMgetnxtedges (&msg_loc, include_nodegenerate, my_id,
               OM_Gw_current_OS, right_vtx, 1, &num_found, &first_edge,
               &fe_props, &num_skipped);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
    EMerr_hndlr (!num_found, *msg, EMS_I_NotFound, ret_end);

    /*
     * If the start edge is a degenerate one then flip the direction of
     * search to avoid infinite recursion. --Subhasish
     */
    if (start_edge == NULL_OBJID)
      my_loc = !right_vtx;
    else
      my_loc = right_vtx;
    }
  else
  {
    first_edge = my_id;
    my_loc = right_vtx;
  }

  /*
   * We know that initially, start_edge is initialised to NULL_OBJID.
   * So, instantiate this variable the first time it comes into this
   * function.
   */
  if (start_edge == NULL_OBJID)
    start_edge = first_edge;

  for (i=0; i<(*num_edges); i++)
    if (IF_EQ_OBJID (first_edge, (*edges)[i]))
      goto ret_end;

  /*
   * Put this edge into the output buffer if it satisfies all the options.
   * Buffer is incremented if needed.
   */

  if (include_notangent)
    {
    is_neutral = FALSE;
    mattyp = MAIDMX;
    MAidmx (&msg_loc, mat);

#ifndef BASE_EMS
    om$send (msg = message EMSedge.EMchkconvex (&msg_loc, NULL, &mattyp, mat,
     EMS_ZEROANGLE_DEG_MAX, &is_convex, &is_neutral, NULL), 
     targetid = first_edge);

#endif /* NT */

    }
  if (include_onlycommon)
    {
    has_common = 0;
    EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
    om$get_channel_count (objid = first_edge,
     p_chanselect = &chan_to_common_edge, count = (OMuint *)&has_common);
    }

  if (!(include_onlydominant && fe_props & EMED_SUBORDINATE) &&
      !(include_noseamedge && fe_props & EMED_SEAM) &&
      (include_notangent ? !is_neutral : TRUE) &&
      (include_onlycommon ? has_common : TRUE))
    {
    if (! ((*num_edges) % BUFF_INCR))
      {
      if (! *num_edges)
        {
        *edges = (GRobjid *) om$malloc (size = BUFF_INCR * 
                  sizeof (GRobjid));
        *is_rightend = (IGRboolean *) om$malloc (size = BUFF_INCR *
                        sizeof (IGRboolean));
        }
      else
        {
        *edges = (GRobjid *) om$realloc (ptr = (IGRchar *)*edges, size = 
                  (*num_edges + BUFF_INCR) * sizeof (GRobjid));
       *is_rightend = (IGRboolean *) om$realloc (ptr = (IGRchar *)*is_rightend,
                 size = (*num_edges + BUFF_INCR) * sizeof (IGRboolean));
        }
      EMerr_hndlr (! *edges || ! *is_rightend, *msg, EMS_E_NoDynamicMemory,
       ret_end);
      }
    (*edges)[(*num_edges)] = first_edge;
    (*is_rightend)[(*num_edges)] = right_vtx;
    (*num_edges)++;
    }

  /*
   * The number of edges corresponding to this vertex, include all the
   * degenerate edges occurring here. If degenerate edges are to be included
   * in the output, get these and keep processing for "next edges" until
   * a non-degenerate edge is found. Only at this point are we leaving
   * this vertex. Before placing the edge into the output buffer perform a
   * check to see if this edge is not already in the output buffer (a safety
   * check). Also, this edge is put into the output buffer only if satisfies
   * all the options, After the "true" next edge has been found and placed into
   * the output invoke this same message on the common-edge of this next-edge.
   */
  
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);

  sent_across_edge = FALSE;
  current_edge = first_edge;
  do
    {
    stat_OM = EMgetnxtedges (&msg_loc, include_nodegenerate, current_edge,
               OM_Gw_current_OS, right_vtx, 1, &num_found, &next_edge,
               &edprops, &num_skipped);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
    if (!num_found)
      goto ret_end;
    next_loc = ! right_vtx;

    edge_in_buffer = FALSE;
    for (i=0; i<(*num_edges); i++)
      if (IF_EQ_OBJID (next_edge, (*edges)[i]))
       {
        edge_in_buffer = TRUE;
        if(i != ((*num_edges)-1)) goto ret_end; /* AMD : 02/11/92 */
       }

    if (include_notangent)
      {
      is_neutral = FALSE;

#ifndef BASE_EMS

      om$send (msg = message EMSedge.EMchkconvex (&msg_loc, NULL,
       &mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex, &is_neutral, NULL),
       targetid = next_edge);

#endif /* NT */

      }
    if (include_onlycommon)
      {
      has_common = 0;
      om$get_channel_count (objid = next_edge,
       p_chanselect = &chan_to_common_edge, count = (OMuint *)&has_common);
      }

    if (!edge_in_buffer &&
        !(include_onlydominant && edprops & EMED_SUBORDINATE) &&
        !(include_noseamedge && edprops & EMED_SEAM) &&
        (include_notangent ? !is_neutral : TRUE) &&
        (include_onlycommon ? has_common : TRUE))
      {
      if (! ((*num_edges) % BUFF_INCR))
      {
       if (! *num_edges)
        {
        *edges = (GRobjid *) om$malloc (size = BUFF_INCR * 
                  sizeof (GRobjid));
        *is_rightend = (IGRboolean *) om$malloc (size = BUFF_INCR *
                        sizeof (IGRboolean));
        }
       else
        {
        *edges = (GRobjid *) om$realloc (ptr = (IGRchar *)*edges, size = 
                  (*num_edges + BUFF_INCR) * sizeof (GRobjid));
        *is_rightend = (IGRboolean *) om$realloc(ptr = (IGRchar *)*is_rightend,
                 size = (*num_edges + BUFF_INCR) * sizeof (IGRboolean));
        EMerr_hndlr(! *edges || ! *is_rightend, *msg, 
                    EMS_E_NoDynamicMemory, ret_end);
        }
       }
      (*edges)[(*num_edges)] = next_edge;
      (*is_rightend)[(*num_edges)] = next_loc;
      (*num_edges)++;
      }

    if (! (edprops & EMED_DEGENERATE) && !include_onlythissurf)
      {
      stat_OM = om$get_channel_count (objid = next_edge,
                 p_chanselect = &chan_to_common_edge, 
                 count = (OMuint *)&comm_edge_count);
      EMomerr_exit (stat_OM, ret_end);

      if (comm_edge_count)
        {
        /*
         * This message should be sent across the next edges common-edge
         * channel, to fetch all the other remaining coterminal edges.
         * But the common-edges relative direction to this edge needs to be
         * known. If it is opposite, then the 'right_vtx' flag is logically
         * negated. NB: A check is put here (awaiting a re-working of this,
         * now very messy, code) to prevent infinite recursion in certain
         * cases (eg: when this message is first to the seam edge of a sphere,
         * with the vertex as the apex and include_nodegenerate is on and
         * include_onlydominant is on).
         */
 
        dum_count = 0;
        om$get_channel_objects (objid = next_edge,
         p_chanselect = &chan_to_common_edge, list = &comm_edge,
         size = 1, count = &dum_count);
        if (dum_count && 
            (current_edge == comm_edge.S_objid ||
             my_id == comm_edge.S_objid)) 
          break;
     
        if (edprops & EMED_REVERSE_CONNECT)
          right_vtx = ! next_loc;
        else
          right_vtx = next_loc;

        stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
                   options, right_vtx, num_buff,
                   num_edges, edges, is_rightend),
                   p_chanselect = &chan_to_common_edge,
                   senderid = next_edge);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);
        }
      else
        {
        /*
         * Since the next edge did not have a common edge, the path
         * has to be reversed and the processing continues through
         * the first edge, which may be my_id
         */

        if (! (fe_props & EMED_DEGENERATE))
          {
          if (fe_props & EMED_REVERSE_CONNECT)
            right_vtx = ! my_loc;
          else
            right_vtx = my_loc;

          stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
                     options, right_vtx, num_buff,
                     num_edges, edges, is_rightend), 
                     p_chanselect = &chan_to_common_edge,
                     senderid = first_edge);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc),*msg, EMS_E_EdgeError,
           ret_end);
          }
        }
      sent_across_edge = TRUE;
      }
    current_edge = next_edge;
    }
  while (!(sent_across_edge || include_onlythissurf));

ret_end:
  start_edge = NULL_OBJID;
  EMWRAPUP (*msg, stat_OM, "EMSedge.EMgetvtxedges");
  return (stat_OM);
}

end implementation EMSedge;
