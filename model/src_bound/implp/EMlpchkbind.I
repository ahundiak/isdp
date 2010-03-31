/* #################   APOGEE  COMPILED   ######################### */
/*
  DESCRIPTION

    The loop checks to see if it can be elliminated. For now, the message
    is assumed to be coming from the loopset. This loop is considered
    to have no bindings if i) it has no one one on the notification and
    the helpers channel, ii) if it has a model-space counterpart
    the counterpart must not have any bindings and iii) it's edges respond
    positively to their own check.

  HISTORY

    SS  :  08/16/88  :  Creation
*/

#include "EMSobjmgrdef.h"
#include "EMSlcdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

class implementation EMSloop;

method EMchkbindings (IGRlong *msg; IGRushort options;
                      GRobjid *components)
{
  OMuint check_count;
  IGRint  i;
  IGRlong stat_OM, msg_loc;
  GRobjid mscobj;
  OM_S_CHANSELECT check_chan;
  OM_S_OBJECT_LINKAGE objlink[4];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * If there is anything on the to-helpers channel, this loop is
   * bound.
   */

  stat_OM = EMmake_chanselect (EMSrequester_to_helpers, &check_chan);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &check_chan,
             count = &check_count);
  EMomerr_exit (stat_OM, ret_end);

  if (check_count)
    {
    *msg = EMS_I_LoopError;
    stat_OM = OM_I_STOP_SENDING;
    goto ret_end;
    }

  /*
   * If there is anything other than an associative model-space counterpart
   * on the notification channel, this loop is bound.
   */

  stat_OM = EMmake_chanselect (GRnotify_notification, &check_chan);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &check_chan,
             count = &check_count);
  EMomerr_exit (stat_OM, ret_end);

  /* if the loop has an associative model-space counterpart, it is connected
   * to the loop on the notification channel so this connection should be
   * disregarded
   */

  if ((ME.EMSloop->lp_props & EMLP_MSCEXISTS) &&
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

    if (mscobj != NULL_OBJID)
      check_count--;
    }

  if (check_count)
    {
    *msg = EMS_I_LoopError;
    stat_OM = OM_I_STOP_SENDING;
    goto ret_end;
    }

  /*
   * Send the message to the edges to evaluate themselves.
   */

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &check_chan);
  EMomerr_exit (stat_OM, ret_end);
  
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &check_chan);

  /*
   * Assuming that the invoker of this method is the loopset, if 
   * there are no binding things on the loopset, put my object-id
   * and the object-ids of the edges on the output argument.
   */

  if (*msg == EMS_S_Success && components)
    {
    stat_OM = om$get_channel_objects (object = me, 
               p_chanselect = &check_chan, list = objlink, size = 4,
               count = &check_count);
    EMomerr_exit (stat_OM, ret_end);

    components[0] = my_id;
    for (i=1; i<5; i++)
      components[i] = objlink[i-1].S_objid;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMchkbindings");
  return (stat_OM);
}

end implementation EMSloop;
