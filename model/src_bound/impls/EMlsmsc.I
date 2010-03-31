/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSobjmgrdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMremmsc (IGRlong *msg; IGRushort options)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMremmsc");
  return (stat_OM);
}

method EMsendtomsc (IGRlong *msg; OM_p_MESSAGE messg; IGRushort opt)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (opt & (EMSmsc_edges | EMSmsc_innerloops))
    {
    stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMsendtomsc");
  return (stat_OM);
}

end implementation EMSloopset;
