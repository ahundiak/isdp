/* #################   APOGEE  COMPILED   ######################### */
/*
  DESCRIPTION

    The edge checks to see if it can be elliminated. For now, the message
    is assumed to be coming from the loop. This edge is considered to
    have no bindings if i) it has no connection on it's notification channel,
    ii) no connections on it's common-edge channel if it is not a seam-edge 
    and iii) if it has a model-space counterpart that can be reclaimed as a
    shell-object or no model-space counterpart at all.

  HISTORY

    SS  :  08/16/88  :  Creation
*/

#include "EMSobjmgrdef.h"
#include "EMSlcdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

class implementation EMSedge;

method EMchkbindings (IGRlong *msg; IGRushort options;
                      GRobjid *components)
{
  OMuint check_count;
  IGRlong stat_OM, msg_loc;
  GRobjid mscobj;
  OM_S_CHANSELECT check_chan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * If there is anything on the common-edge channel if this edge is
   * not a seam-edge, this edge is bound.
   */

  if (! (ME.EMSedge->ed_props & EMED_SEAM))
    {
    stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &check_chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (object = me, p_chanselect = &check_chan,
               count = &check_count);
    EMomerr_exit (stat_OM, ret_end);

    if (check_count)
      {
      *msg = EMS_I_EdgeError;
      stat_OM = OM_I_STOP_SENDING;
      goto ret_end;
      }
    }

  /*
   * If there is anything other than an associative model-space counterpart
   * on the notification channel, this edge is bound.
   */

  stat_OM = EMmake_chanselect (GRnotify_notification, &check_chan);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &check_chan,
             count = &check_count);
  EMomerr_exit (stat_OM, ret_end);

  /* if the edge has an associative model-space counterpart, it is connected
   * to the edge on the notification channel so this connection should be
   * disregarded
   */

  if ((ME.EMSedge->ed_props & EMLP_MSCEXISTS) &&
      check_count)
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
      check_count--;
    }

  if (check_count)
    {
    *msg = EMS_I_EdgeError;
    stat_OM = OM_I_STOP_SENDING;
    goto ret_end;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSedge.EMchkbindings");
  return (stat_OM);
}

end implementation EMSedge;
