class implementation SKvalvar;

method SKputvar (IGRlong *msg; IGRushort opts;
                 IGRshort *mattyp; IGRdouble *matrix;
                 IGRdouble *var)
{
  IGRchar double_str[40], fullvarname[DI_PATH_MAX];
  IGRlong msg_loc, stat_dir, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (! (ME.SKvariable->props & SK_VAR_READEXPR))
    {
    stat_dir = di$untranslate (objname = fullvarname, objid = my_id);
    EMerr_hndlr (stat_dir != DIR_S_SUCCESS, *msg, EMS_E_InvalidCase, ret_end);

    sprintf (double_str, "%lf", *var);

    stat_OM = om$send (msg = message expression.modify (fullvarname, 
               double_str, (short *) &msg_loc), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    ME.expression->value = *var;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKvalvar.SKputvar");
  return (stat_OM);
}

end implementation SKvalvar;
