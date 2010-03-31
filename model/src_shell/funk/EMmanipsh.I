/* ###################   APOGEE COMPILED   ################## */
/*
   DESCRIPTION

     The following functions provides a means of obtaining shell
     objects for a given class, putting shell-objects into the shell-manager,
     removing the shell's from a shell-manager's data-base. The object-space
     in which the object exists is specified, in addition to the 
     shell-manager's label. For the case of "get", depending on an option,
     a) a new object of the correct class is created, regardless or b) an
     object-id may be returned which may have been previously constructed but
     is part of a LIFO system which reuses object-ids. The usefulness of this
     function lies in the latter option. 

   EXAMPLES

     The "get" function can be used to obtain objects of a specific class
     when it is known that only a limited set of such objects must
     continue to exist at the same time. For example, model-space
     curves which are counterparts of parametric-space edges on
     surfaces.

   HISTORY

     SS  :  04/04/88  :  Creation
     SS  :  09/23/88  :  Added the EMputshobj function.
     SS  :  09/27/88  :  Added the EMremshobj function.
*/

class implementation EMSshobjmgr;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSshobjmgr_class_id;

IGRlong EMgetshobj (msg, options, classid, label, os, constarg, constfunc,
                    validarg, validfunc, obj)
IGRlong *msg;
IGRushort options;
GRclassid classid;
IGRulong label;
GRspacenum os;
IGRchar *constarg, *validarg;
IGRboolean (*constfunc)(), (*validfunc)();
GRobjid *obj;
{
  IGRlong msg_loc, stat_OM;
  GRobjid MGRobj;
  extern IGRlong EMgetmgr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the object id of the curve-manager object for this 
   * object-space.
   */

  stat_OM = EMgetmgr (&msg_loc, os, OPP_EMSshobjmgr_class_id, label, &MGRobj);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Having obtained the objid of the manager send the message 
   * to it to obtain the shell-object ids.
   */

  stat_OM = om$send (msg = message EMSshobjmgr.EMgetshobj (msg,
             classid, options, constarg, constfunc, validarg, validfunc, obj),
             targetid = MGRobj, targetos = os, senderid = NULL_OBJID);
  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetshobj");
  return (stat_OM);
}



IGRlong EMputshobj (msg, options, label, os, validfunc, obj)
IGRlong *msg;
IGRushort options;
IGRulong label;
GRspacenum os;
IGRboolean (*validfunc)();
GRobjid obj;
{
  IGRlong msg_loc, stat_OM;
  GRobjid MGRobj;
  extern IGRlong EMgetmgr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the object id of the curve-manager object for this 
   * object-space.
   */

  stat_OM = EMgetmgr (&msg_loc, os, OPP_EMSshobjmgr_class_id, label, &MGRobj);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Having obtained the objid of the manager send the message 
   * to it to put the shell-object ids.
   */

  stat_OM = om$send (msg = message EMSshobjmgr.EMputshobj (msg,
             obj, validfunc), targetid = MGRobj, targetos = os,
             senderid = NULL_OBJID);
  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMputshobj");
  return (stat_OM);
}



IGRlong EMremshobj (msg, options, label, os, obj)
IGRlong *msg;
IGRushort options;
IGRulong label;
GRspacenum os;
GRobjid obj;
{
  IGRlong msg_loc, stat_OM;
  GRobjid MGRobj;
  extern IGRlong EMgetmgr();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the object id of the curve-manager object for this 
   * object-space.
   */

  stat_OM = EMgetmgr (&msg_loc, os, OPP_EMSshobjmgr_class_id, label, &MGRobj);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Having obtained the objid of the manager send the message 
   * to it to remove the shell-object id.
   */

  stat_OM = om$send (msg = message EMSshobjmgr.EMremshobj (msg,
             obj), targetid = MGRobj, targetos = os, senderid = NULL_OBJID);
  if (!EMSerror (stat_OM))
    stat_OM = OM_S_SUCCESS;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMremshobj");
  return (stat_OM);
}

end implementation EMSshobjmgr;
