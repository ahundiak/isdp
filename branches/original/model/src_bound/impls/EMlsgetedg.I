/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emsmacros.h"

method EMget_edges(
        IGRlong         *EMmsg;
        IGRint          tree_depth;
        IGRlong         option;
        struct GRid     **edges;
        IGRint          *array_size;
        IGRint          *num_edges)
/*
Notes
    Upon exit the return code may be
      - EMS_S_Success if success
      - EMS_E_LoopError if an error occurs.
	
  The current options available for edge selection are

  EMS_OPT_ALL:              return all edges.
  EMS_OPT_NATURAL:          return only natural edges.
  EMS_OPT_CONNECTABLE:      return all connectable edges (ones that can
                            be connected across common edge channel)
  EMS_OPT_NATURAL_NONDEG:   return only natural non_degenerate edges.
  EMS_OPT_NONDEG_NONSEAM:   return edges that are not non_degenerate
                            and  not seam edges.
  EMS_OPT_NON_DEG_SEAM_XYZCLSD : return edges that are 
                             non_degenerate, non_seam and are not closed
                             in model space.
  EMS_OPT_SEAM :            return seam edges.

  These options are includes in EMSopt.h file.

  Any other option can be added upon request.

  The space will be allocated to store edges. The caller
  has the responsibility of deallocating this space.

  The caller should intialize *array_size and *num_edges to 0.

  The tree_depth is number of loop nestings, the caller wants to visit.
  For example, if the caller wants to visit the top_most loops only,
  it should be set to 1. For top_most loops and their inner_loops,
  it should be set to 2. If the caller wishes to visit all of the loops
  the tree_depth should be set MAXINT. The tree_depth should always
  be >= 1.

History
	RC	03/26/87	Creation date
        RC  03/01/88    Added tree_depth argument and code.
	SAM 07-Apr-88   Added EMS_OPT_SEAM option to return seam edges.
        SM  19-Mar-92   initialize mthd_stat
Algorithm
	Pass this message to the loops I own.

*/

{
  IGRlong         OM_stat = OM_S_SUCCESS;
  IGRlong         mthd_stat = EMS_S_Success;
  OM_S_CHANSELECT to_loops;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  EMerr_hndlr (tree_depth < 1, *EMmsg, EMS_E_InvalidArg, wrapup );

  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  OM_stat = om$send(msg = message EMSboundary.EMget_edges( &mthd_stat, 
                     tree_depth, option, edges, array_size, num_edges),
                    p_chanselect = &to_loops);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSloopset.EMget_edges")
  return(OM_stat);
}

end implementation EMSloopset;
