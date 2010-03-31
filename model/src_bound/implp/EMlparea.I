/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION 
  
    This message can be used to determine the area enclosed by this loop
    If the loop is open, the area value returned is undefined for all
    practical purposes. Actually, it will be the area of the shape
    defined by joining the end-points of the open loop to the [0,0]
    point. A clockwise direction of the loop yields a positive area,
    whereas a counterclockwise direction yields a negative one.

  NOTES
 
    The area returning argument must be set to zero by the caller as the
    computation might proceed by a piece-wise computation. For example:
    the computation of a loop's area is done by successively adding
    the area-computation for each of it's edges to the existing value
    in the argument.

  RETURN VALUE

    EMS_S_Success - if all went well,

    EMS_I_Open - If the boundary element was open
    EMS_I_LoopError - If the message was sent to a loop and the sign on
      area shows a mismatch between the existing loop-direction and the
      bit indicating a P-loop.

    EMS_E_NoDynamicMemory - Just that
    EMS_E_EdgeError - Just that
    
  HISTORY

    SS  :  05/23/88  :  Creation
*/

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

class implementation EMSloop;

#include "EMS.h"
method EMarea (IGRlong *msg; IGRdouble *area)
{
  IGRushort lp_props;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_edges;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  chan_to_edges.type = OM_e_addr;
  chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_edges);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_EdgeError, ret_end);

  lp_props = ME.EMSloop->lp_props;
  EMerr_hndlr (lp_props & EMLP_OPEN, *msg, EMS_I_Open, ret_end);
  EMerr_hndlr (*area < 0.0 && lp_props & EMLP_PLOOP, *msg, EMS_I_LoopError,
   ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMarea");
  return (stat_OM);
}

end implementation EMSloop;

