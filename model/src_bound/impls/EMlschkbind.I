/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    The loopset checks to see if it can be elliminated. For this it must
    be natural and not have any connections on any of it's channels 
    except it's "to_surface" one. A similar check needs to be performed
    by all it's loops.

  HISTORY

    SS  :  08/16/88  :  Creation
*/

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

class implementation EMSloopset;

#include "EMS.h"
method EMchkbindings (IGRlong *msg; IGRushort options; 
                      GRobjid *components)
{
  OMuint check_count;
  IGRlong stat_OM;
  OM_S_CHANSELECT check_chan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the loopset is not natural, then the loopset is bound.
   */

  if (! (ME.EMSloopset->ls_props & EMLS_NATURAL))
    {
    *msg = EMS_I_LoopsetError;
    goto ret_end;
    }

  /*
   * If there is someone connected on the notification channel,
   * the loopset is bound.
   */

  stat_OM = EMmake_chanselect (GRnotify_notification, &check_chan);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &check_chan,
             count = &check_count);
  EMomerr_exit (stat_OM, ret_end);

  if (check_count)
    {
    *msg = EMS_I_LoopsetError;
    goto ret_end;
    }
  
  /*
   * Send the message on down for the loops to evaluate 
   * themselves.
   */

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &check_chan);
  EMomerr_exit (stat_OM, ret_end);
  
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &check_chan);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMchkbindings");
  return (stat_OM);
}

end implementation EMSloopset;
