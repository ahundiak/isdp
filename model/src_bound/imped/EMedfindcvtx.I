/*
  DESCRIPTION

    This method can be used to find the vertex in a given loop (search
    loop) at which a given edge (mostly on a different surface) is also
    incident. The message is sent to an edge of the search loop and the
    search direction specified (right or left). If such a vertex is found,
    the two object ids of the edges (in the search loop) that make up the
    vertex, are returned. The order of the object-ids is consistent with
    the search direction.

  ARGUMENTS

    commedge		- Input: The given edge which must be incident
                           at a vertex of the search loop.
    commedge_right	- Input: Whether the common vertex in question
			   is at the right end (TRUE) or left end of the
			   commedge.
    search_right	- Input: If TRUE the search direction proceeds
                           in the logical direction of this edge.
    cvtxeds		- Output: An array of size 2 that must be allocated
                           by the caller. Contains the edge-ids that
                           make up the "found" vertex. Can be NULL.

  RETURN VALUE

    If successful a code of EMS_S_Success is returned. If no such vertex
    was found EMS_I_Fail is returned. On error a code of EMS_E_EdgeError
    or EMS_E_LoopError is returned.
    
  HISTORY

    SS    : 10/03/89 : The edge-closure should be checked against XYZ_CLOSED
		       and not only against OPEN (as was the case previously).
    SS    : 01/21/89 : Fixed a bug in the check for edge match. If the
                       edge is closed, the part fo the check for end-match
                       is skipped.
    gupta : 05/12/88 : added arguement to EMvtxedges call.
    SS    : 02/02/87 : Creation
*/

class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsgeteddef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMnext_edge;

method EMfind_commvtx (IGRlong *msg; 
                       GRobjid commedge; IGRboolean commedge_right;
                       IGRboolean search_right; GRobjid *cvtxeds)
{
  IGRboolean vtxed_found, *right_vertices;
  IGRushort ed_props;
  IGRint stat_OM, i, num_vtxeds;
  IGRlong msg_loc, send_rc;
  GRobjid *vtxeds, curr_search_edge;
  IGRint EMsend_loops();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  vtxeds = NULL;
  right_vertices = NULL;

  curr_search_edge = my_id;
  vtxed_found = FALSE;
  do
    {
    num_vtxeds = 0;
    stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
               NULL, search_right, 0, &num_vtxeds, &vtxeds, &right_vertices),
               targetid = curr_search_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    for (i=0; i<num_vtxeds; i++)
      if (IF_EQ_OBJID (commedge, vtxeds[i]))
        {
        ed_props = ME.EMSedge->ed_props;
        if (! (ed_props & EMED_XYZ_CLOSED))
          {
          stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                     &ed_props), targetid = commedge);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          }
 
        if (ed_props & EMED_XYZ_CLOSED ||
            commedge_right == right_vertices[i])
          {
          if (cvtxeds)
            cvtxeds[0] = curr_search_edge;
          vtxed_found = TRUE;
          break;
          }
        }

    if (vtxeds)
      {
      om$dealloc (ptr = vtxeds);
      vtxeds = NULL;
      }
    if (right_vertices)
      {
      om$dealloc (ptr = right_vertices);
      right_vertices = NULL;
      }

    stat_OM = EMsend_loops (&send_rc, message EMSloop.EMnext_edge
               (&msg_loc, search_right ? EMGetEd_Next : EMGetEd_Previous,
               curr_search_edge, &curr_search_edge), curr_search_edge, 0, 0,
               EMLP_ACTIVE, NULL, NULL);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (send_rc | msg_loc), *msg, EMS_E_LoopError, ret_end);

    if (vtxed_found && cvtxeds)
      cvtxeds[1] = curr_search_edge;
    }
  while (! IF_EQ_OBJID (curr_search_edge, my_id) && ! vtxed_found);

  if (!vtxed_found)
    *msg = EMS_I_Fail;

ret_end:
  if (vtxeds)
    om$dealloc (ptr = vtxeds);
  if (right_vertices)
    om$dealloc (ptr = right_vertices);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMfindcvtx");
  return (stat_OM);
}

end implementation EMSedge;
