/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This file contains the overrides for the methods that affect the symbology
    of a surface (color, level, weight, style). These overrides have been
    warranted due to model-space coutnerparts of edges/loops, which would
    also have to change their symbologies correspondingly.

  HISTORY

    SS  :  09/11/89  :  Creation
    WBC :  09/16/93  :  Now sending the symbology change message on to the
                        surface's horizon curves, it any.
    WBC :  10/29/93  :  Not returning the OM return code from the horizon
                        curve message sends since they are sent out the
                        notification channel and non-horizon curve objects
                        may return an error status (I/Fold WS#3722382).
    WBC :  11/22/93  :  When passing the message to the horizon curves, sending
                        the message individually to each object on the
                        notification channel instead of just doing a channel
                        send since a non-horizon curve object could return
                        and error code and terminate the send.

*/

class implementation EMSsubbs;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMShrzcvs import EMpasson;

void EMhrzcvs_passon();


method GRchgcolor(IGRlong *msg; IGRuint *rgb_value; 
                  IGRushort *color)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRchgcolor
             (&msg_loc, rgb_value, color), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.color");
  return (stat_OM);
}

method GRchglevel(IGRlong *msg; IGRshort *level)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRchglevel
             (&msg_loc, level), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.level");
  return (stat_OM);
}

method GRchgstyle(IGRlong *msg; IGRuchar *style)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRchgstyle
             (&msg_loc, style), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.style");
  return (stat_OM);
}

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRchgweight
             (&msg_loc, weight), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.weight");
  return (stat_OM);
}

method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_info)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRchgdp
             (&msg_loc, dp_info), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.dp");
  return (stat_OM);
}

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRvg.GRputsymb
             (&msg_loc, symb), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsurface.EMpostsymmod (msg, NULL,
             NULL, NULL, OPPmargs, NULL), targetid = my_id);

  /* send the message to the surface's horizon curves */

  EMhrzcvs_passon(my_id, OM_Gw_current_OS, OPPmargs);

ret_end:
  EMWRAPUP (*msg, stat_OM, "sf.symb");
  return (stat_OM);
}

/*

Name
  EMhrzcvs_passon

Abstract
    This function sends the specified message to all the objects on the
  notification channel of the specified object.

Synopsis

      Type        Name        I/O                 Description
 ------------ --------------- --- -------------------------------------------
 GRobjid      surf_id          I  object id of the surface
 GRspacenum   surf_os          I  object space number of the surface
 OM_p_MESSAGE pass_msg         I  message to be sent to the surface's horizon
                                  curve's which reside on the surface's
                                  notification channel
Description
    This function sends the specified message to all the objects on the
  notification channel of the specified object.  It does a direct send to
  each object instead of just sending down the channel since an object on
  the channel may return an error code which would terminate the send.


Keywords
    function

History
  11/22/93 : WBC : Creation

*/

void EMhrzcvs_passon(surf_id, surf_os, pass_msg)

GRobjid      surf_id;
GRspacenum   surf_os;
OM_p_MESSAGE pass_msg;
{
  IGRlong               sts;
  OMuint                num_on_channel,
                        index;
  OM_S_CHANSELECT       notify_chan;
  OM_S_OBJECT_LINKAGE  *channel_objects;

  /* get the list of objects on the surface's notification channel and send
   * the pass_on message to each one, ignoring any error messages since some
   * of the objects may not handle the pass_on message
   */

  sts = EMmake_chanselect(GRnotify_notification, &notify_chan);

  if (1 & sts)
  {
    sts = om$get_channel_count(osnum = surf_os,
                               objid = surf_id,
                               p_chanselect = &notify_chan,
                               count = &num_on_channel);
    if ((1 & sts) &&
        (num_on_channel))
    {
      channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(num_on_channel *
                                               sizeof( OM_S_OBJECT_LINKAGE ));

      if (channel_objects)
      {
        sts = om$get_channel_objects(osnum = surf_os,
                                     objid = surf_id,
                                     p_chanselect = &notify_chan,
                                     list = channel_objects,
                                     size = num_on_channel,
                                     count = &num_on_channel);
        if (1 & sts)
        {
          for (index = 0; index < num_on_channel; index++)
          {
            om$send(msg = message EMShrzcvs.EMpasson(pass_msg),
                    senderid = NULL_OBJID,
                    targetid = channel_objects[index].S_objid,
                    targetos = channel_objects[index].osnum);
          }
        }
      }
    }
  }
}

end implementation EMSsubbs;
