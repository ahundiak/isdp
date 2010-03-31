class implementation SKconstraint;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method SKgetmgr (IGRlong *msg; GRobjid *mgrid)
{
  IGRint i;
  OMuint  count;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_mgr, chan_to_super;
  OM_S_OBJECT_LINKAGE objlist;

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  om$make_chanselect (channame = "SKconstraint.to_mgr", 
   p_chanselect = &chan_to_mgr);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_mgr,
   count = &count, size = 1, list = &objlist);
  
  if (count)
    {
    *mgrid = objlist.S_objid;
    *msg = EMS_I_Found;
    goto ret_end;
    }
  else
    {
    om$make_chanselect (channame = "SKconstraint.to_super_constrs",
     p_chanselect = &chan_to_super);

    om$get_channel_count (object = me, p_chanselect = &chan_to_super,
     count = &count);
  
    for (i=0; i<count; i++)
      {
      om$send (msg = message SKconstraint.SKgetmgr (msg, mgrid),
       p_chanselect = &chan_to_super, from = i, to = i);

      if (*msg == EMS_I_Found)
        goto ret_end;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKconstraint.SKgetmgr");
  return (stat_OM);
}

end implementation SKconstraint;
