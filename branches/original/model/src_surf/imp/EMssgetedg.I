/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "emsmacros.h"

from EMSboundary import EMget_edges;

method EMget_edges(
        IGRlong         *EMmsg;
        IGRint          tree_depth;
        IGRlong         option;
        struct GRmd_env *md_env;
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

History
	RC	11/14/87	Creation date
	SAM 07-Apr-88   Added EMS_OPT_SEAM option to return seam edges.
        pp  10/07/91    Environment was being passed in for environment info
                        for calling make natural boundary
Algorithm
        Make a natural loopset, one does not exist.
	Pass this message to the loops I own.

*/

{
  IGRlong         OM_stat;
IGRlong   mthd_stat;
  OM_S_CHANSELECT to_loopset;
  OMuint          chan_count;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  to_loopset.type = OM_e_addr;
  to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  OM_stat = om$get_channel_count (object = me, 
               p_chanselect = &to_loopset, count = &chan_count);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  
  /*
   * If there is no loopset, make one.
   */

  if (!chan_count)
  {
    OM_stat = om$send (msg = message EMSsubbs.EMmk_nat_bdry (&mthd_stat,
                        &md_env->md_env, NULL),
                       targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  
  } /* if (!chan_count) */

  OM_stat = om$send(msg = message EMSboundary.EMget_edges( &mthd_stat, 
                     tree_depth, option, edges, array_size, num_edges),
                    p_chanselect = &to_loopset);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMget_edges")
  return(OM_stat);
}

end implementation EMSsubbs;
