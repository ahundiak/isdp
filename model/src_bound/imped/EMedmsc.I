/* #################   APOGEE  COMPILED   ######################### */
class implementation EMSedge;

#include "EMSobjmgrdef.h"
#include "EMSlcdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMremmsc (IGRlong *msg; IGRushort options)
{
  *msg = EMS_S_Success;

  ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;

  return (OM_S_SUCCESS);
}


method EMputmsc (IGRlong *msg; IGRushort options; GRobjid mscobj)
{
  *msg = EMS_S_Success;

  ME.EMSedge->ed_props |= EMED_MSCEXISTS;

  return (OM_S_SUCCESS);
}

method EMsendtomsc (IGRlong *msg; OM_p_MESSAGE messg; IGRushort opt)
{
  IGRlong stat_OM, msg_loc;
  GRobjid mscobj;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (ME.EMSedge->ed_props & EMED_MSCEXISTS)
    {
    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (msg_loc != EMS_I_NotFound)
      stat_OM = om$send (msg = messg, targetid = mscobj);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSedge.EMsendtomsc");
  return (stat_OM);
}

end implementation EMSedge;
