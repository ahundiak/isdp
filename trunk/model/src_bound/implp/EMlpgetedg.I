/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include "emsmacros.h"

method EMget_edges(
        IGRlong        *EMmsg;
        IGRint         tree_depth;
        IGRlong        option;
        struct GRid    **edges;
        IGRint         *array_size;
        IGRint         *num_edges)
/*
Notes
  Upon exit the return code may be

        - EMS_S_Success   if success
        - EMS_E_LoopError if an error occurs when a loop 
                          method is invoked.
        - EMS_E_EdgeError if an error occurs during a call
                          to an EMget_edges at EMSedge level
        _ EMS_E_OMerror   if an error occurs during an om call

  The space will be allocated to store edges. The caller
  has the responsibility of deallocating this space.

  If this method is invoked by an outsider (i.e, it is 
  not invoked recursively by a loopet or a outer loop),
  *array_size and *num_edges should be initialized to 0.

  The current options available for edge selection are

  EMS_OPT_ALL:            return all edges.
  EMS_OPT_NATURAL:        return only natural edges.
  EMS_OPT_CONNECTABLE:    return all connectable edges (ones that can
                          be connected across common edge channel)
  EMS_OPT_NATURAL_NONDEG: return only natural non_degenerate edges.
  EMS_OPT_NONDEG_NONSEAM: return edges that are not non_degenerate
                          and  not seam edges.
  EMS_OPT_STITCHED:       return edges that are non_degenerate, non_seam
                          and donot have a common edge.
  EMS_OPT_NON_DEG_SEAM_XYZCLSD : return edges that are 
                          non_degenerate, non_seam and are not closed
                          in model space.
  EMS_OPT_SEAM:           return seam edges.

  These options are includes in EMSopt.h file.
  Any other option can be added upon request.

  The tree_depth is number of loop nestings (including this loop), the 
  caller wants to visit. If the caller wants to visit this loop only,
  tree_depth should be set to 1. If the caller wants to visit this
  and its one level down loops,it should be set to 2 and so on. 
  If the caller wishes to visit all of the loops the tree_depth 
  should be set MAXINT. The tree_depth should always be >= 1.

History
	RC	03/26/87	Creation date
    RC  03/02/88    Added tree_depth argument and code.
    SAM 07-Apr-88   Added EMS_OPT_SEAM option to return seam edges.

Algorithm
     o Pass the message to the edges in the logical loop direction.
     o Pass the message to the inner loops provided tree_depth is 
       > 0.

*/
{
  IGRlong         OM_stat;
  IGRlong         mthd_stat;
  IGRint          ed_idx, i, incr;
  OMuint          num_lp_edges;
  OM_S_CHANSELECT to_edges, to_inner;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  EMerr_hndlr (tree_depth <= 0, *EMmsg, EMS_E_InvalidArg, wrapup);

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  OM_stat = om$get_channel_count (object = me,
                p_chanselect = &to_edges, count = &num_lp_edges);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

  ed_idx = (me->lp_props & EMLP_REVERSED) ? (num_lp_edges-1) : 0;
  incr = (me->lp_props & EMLP_REVERSED) ? -1 : 1;

  for (i = 0; i < num_lp_edges; i++, ed_idx +=incr )
  {
    OM_stat = om$send(msg = message EMSboundary.EMget_edges (&mthd_stat,
                     tree_depth, option, edges, array_size, num_edges),
                    p_chanselect = &to_edges, from = ed_idx, to = ed_idx);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup); 

  } /* for (i = 0; i < num_lp_edges; i++, (ed_idx + incr) ) */

  tree_depth--;

  if(tree_depth)
  {
    to_inner.type = OM_e_addr;
    to_inner.u_sel.addr = &ME.EMSloop->to_inner;

    OM_stat = om$send(msg = message EMSboundary.EMget_edges (&mthd_stat,
                       tree_depth,option, edges, array_size, num_edges),
                      p_chanselect = &to_inner);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
  }

wrapup:

  EMWRAPUP(*EMmsg, OM_stat, "In EMSloop.EMget_edges")

  return(OM_stat);
}

end implementation EMSloop;
