/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include "emserr.h"

method EMdebug_display (IGRlong *msg; struct GRmd_env *mdenv; 
                        struct IGRdisplay *display_attr;
                        enum GRdpmode display_mode)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT genchan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (ME.EMSloop->lp_props & EMLS_NATURAL, *msg, EMS_E_Fail,
   ret_end);

  genchan.type = OM_e_addr;

  genchan.u_sel.addr = &ME.EMSbd_owner->to_comps;
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &genchan);
  
  genchan.u_sel.addr = &ME.EMSloop->to_inner;
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &genchan);

ret_end:
  EMWRAPUP(*msg, stat_OM, "EMSloop.EMdebug_display")
  return (stat_OM);
}

end implementation EMSloop;

