/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emserr.h"

method EMdebug_display (IGRlong *msg; struct GRmd_env *mdenv; 
                        struct IGRdisplay *display_attr;
                        enum GRdpmode display_mode)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (ME.EMSloopset->ls_props & EMLS_NATURAL, *msg, EMS_E_Fail,
   ret_end);

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);
  
ret_end:
  EMWRAPUP(*msg, stat_OM, "EMSloopset.EMdebug_display")
  return (stat_OM);
}

end implementation EMSloopset;

