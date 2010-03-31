/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMS.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMScpmgr_class_id;

IGRlong EMmanipentry (msg, os, tag, option, num, key, obj)
IGRlong *msg;
GRspacenum os;
IGRushort option;
IGRint num, tag;
GRobjid key[], obj[];
{
  IGRlong msg_loc, stat_OM;
  GRobjid MGRobj;
  IGRlong EMgetmgr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the object id of the counterpart-manager object for this 
   * object-space and tag-number.
   */

  stat_OM = EMgetmgr (&msg_loc, os, OPP_EMScpmgr_class_id, tag, &MGRobj);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Having obtained the objid of the manager send the appropriate message 
   * to it to manipulate the table of counterpart object-ids.
   */

  if (option & EMScpmanip_put)
    stat_OM = om$send (msg = message EMScpmgr.EMputentry (msg, option,
               num, key, obj), targetid = MGRobj, targetos = os,
               senderid = NULL_OBJID);
  else if (option & EMScpmanip_get)
    stat_OM = om$send (msg = message EMScpmgr.EMgetentry (msg, option,
               num, key, obj), targetid = MGRobj, targetos = os,
               senderid = NULL_OBJID);
  else if (option & EMScpmanip_del)
    stat_OM = om$send (msg = message EMScpmgr.EMdelentry (msg, option,
               num, key, obj), targetid = MGRobj, targetos = os,
               senderid = NULL_OBJID);
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMmanipcp");
  return (stat_OM);
}

end implementation EMScpmgr;
