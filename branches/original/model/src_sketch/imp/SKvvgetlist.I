class implementation SKvalvar;

#define EMomerr_exit(sts, label) if EMSerror (sts, label) goto label;

method SKgetvarlist (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars **varlist)
{
  IGRchar varname[DI_PATH_MAX];
  IGRint duminx;
  IGRlong stat_OM, msg_loc;
  struct SKsolvevars *dumptr;
  extern void SKaddvarlist();
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the options indicate this execution is ineligible then,
   * simply return.
   */

  if (opts & SK_GETVR_NDCHILDREN && ME.SKvariable->props & SK_VAR_READEXPR)
    goto ret_end;
  else if (opts & SK_GETVR_VALVAR && ME.SKvariable->props & SK_VAR_READEXPR)
    goto ret_end;

  /*
   * If the option is simply to check if either of these two variables
   * is in the system, then do so.
   */

  if (opts & SK_GETVR_FIND)
    {
    if (SKvarlistinx (*varlist, my_id, VAR_VAL, &dumptr, &duminx))
      {
      *msg = EMS_I_Found;
      stat_OM = OM_I_STOP_SENDING;
      }
    goto ret_end;
    }

  /*
   * Add myself to the list of variables. The name of the expression-variable
   * is obtained and put into the list too.
   */

  stat_OM = om$send (msg = message SKvalvar.SKgetname (&msg_loc, 
             SK_GETVR_SIGNIFNAME, varname), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  SKaddvarlist (&msg_loc, opts, varlist, VAR_VAL, my_id, NULL, NULL,
   &ME.expression->value, varname);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKvalvar.SKgetvarlist");
  return (stat_OM);
}

end implementation SKvalvar;

