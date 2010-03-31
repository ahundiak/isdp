class implementation SKvariable;

method SKgetmgr (IGRlong *EMmsg; OM_S_OBJID *sk_mgr_id)
{
  OM_S_CHANSELECT      vars_mgr_chan;
  OM_S_OBJECT_LINKAGE  mgr_list;

  IGRlong    OM_stat;
  OMuint     count;

  /* **************************************************************** */
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_I_NotFound;

  OM_stat = om$make_chanselect (channame = "SKvariable.to_mgr",
                                p_chanselect = &vars_mgr_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_objects (object = me, 
               p_chanselect = &vars_mgr_chan, list = &mgr_list,
               size = 1, count = &count);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  if (count == 1)
   {
    (*sk_mgr_id) = mgr_list.S_objid;
    *EMmsg = EMS_I_Found;
   }
  else
   *EMmsg = EMS_I_NotFound;
  
  wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "SKvariable.SKgetmgr");
  return (OM_stat);
 }

end implementation SKvariable;
