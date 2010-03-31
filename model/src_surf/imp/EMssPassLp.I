/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/* 
HISTORY:

   Creation:  ??:  Long, long ago.
   08/25/92:  NP:  Modified for ANSI compliance. Modified declarations of "stat_OM"
		   and "count".

*/
#include "EMS.h"
#include <stdio.h>

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMpassloop (IGRlong *send_rc; OM_p_MESSAGE messg)
{
  IGRlong stat_OM;
  IGRuint count;
  OM_S_CHANSELECT chan_to_loopset;

  *send_rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  chan_to_loopset.type = OM_e_addr;
  chan_to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  stat_OM = om$get_channel_count (p_chanselect = &chan_to_loopset,
             object = me, count = &count);
  EMomerr_exit (stat_OM, ret_end);

  if (count)
    {
    stat_OM = om$send (msg = messg, p_chanselect = &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);
    }
  else
    {
    *send_rc = EMS_I_Fail;
    stat_OM = OM_I_CHAN_EMPTY;
    }   

ret_end:
  EMWRAPUP (*send_rc, stat_OM, "EMSsubbs.EMpassloop");
  return (stat_OM);
}

end implementation EMSsubbs;
