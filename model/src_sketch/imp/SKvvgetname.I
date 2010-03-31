class implementation SKvalvar;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method SKgetname (IGRlong *msg; IGRushort opts; IGRchar *name)
{
  IGRchar fullname[DI_PATH_MAX];
  OMuint count;
  IGRlong stat_OM, stat_dir;
  OM_S_OBJECT_LINKAGE objlist;
  OM_S_CHANSELECT chan_to_constrs, chan_to_father;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (name)
    name[0] = NULL;

  /*
   * If I am eligible to return my name, do so.
   */

  if (name)
    {
    if (ME.SKvariable->props & SK_VAR_READEXPR)
      {
      om$make_chanselect (channame = "SKvariable.to_constraints",
       p_chanselect = &chan_to_constrs);

      stat_OM = om$get_channel_objects (object = me,
                 p_chanselect = &chan_to_constrs, list = &objlist,
                 size = 1, count = &count);
      EMerr_hndlr (EMSerror (stat_OM) || count != 1, *msg, EMS_E_InvalidCase,
       ret_end);

      om$make_chanselect (channame = "NDfather.father", 
       p_chanselect = &chan_to_father);

      stat_OM = om$get_channel_objects (objid = objlist.S_objid,
                 p_chanselect = &chan_to_father, list = &objlist, size = 1,
                 count = &count);
      EMerr_hndlr (EMSerror (stat_OM) || count != 1, *msg, EMS_E_InvalidCase,
       ret_end);

      stat_dir = di$untranslate (objname = fullname,
                  objid = objlist.S_objid, osnum = objlist.osnum);
      EMerr_hndlr (stat_dir != DIR_S_SUCCESS, *msg, EMS_I_NotFound,
       ret_end);
      }
    else
      {
      stat_dir = di$untranslate (objname = fullname, objid = my_id);
      EMerr_hndlr (stat_dir != DIR_S_SUCCESS, *msg, EMS_I_NotFound,
       ret_end);
      }

    if (opts & SK_GETVR_SIGNIFNAME)
      {
      stat_dir = di$split (pathname = fullname, name = name);
      EMerr_hndlr (stat_dir != DIR_S_SUCCESS, *msg, EMS_E_InvalidCase, ret_end);
      }
    else
      strcpy (name, fullname);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKvvgetname");
  return (OM_S_SUCCESS);
}

end implementation SKvalvar;
