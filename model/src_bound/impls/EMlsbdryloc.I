/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "msdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMbdrylocate (IGRlong *msg; struct EMSsfinfo *sfinfo;
                     struct EMSlcinput *lcin;
                     struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key;
                     struct EMSlcoutput *lcout)
{
  IGRlong stat_OM, *cvlmsg;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMbdrylocate");
  if (EMSerror (*msg))
    *cvlmsg = MSFAIL;
  return (stat_OM);
}

end implementation EMSloopset;
