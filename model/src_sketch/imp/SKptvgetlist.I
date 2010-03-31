/* ###################   APOGEE COMPILED   ################## */
class implementation SKptvar;

#define X 0
#define Y 1

method SKgetvarlist (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars **varlist)
{
  IGRushort props;
  IGRint duminx;
  IGRlong stat_OM, msg_loc;
  struct SKsolvevar *dumptr;
  extern void SKaddvarlist();
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the options makes this execution ineligible, simply
   * return
   */

  if (opts & SK_GETVR_NDCHILDREN)
    goto ret_end;
  else if (opts & SK_GETVR_VALVAR)
    goto ret_end;

  /*
   * If the option is simply to check if either of these two variables
   * is in the system, then do so.
   */

  if (opts & SK_GETVR_FIND)
    {
    if (SKvarlistinx (*varlist, my_id, VAR_PT, &dumptr, &duminx))
      {
      *msg = EMS_I_Found;
      stat_OM = OM_I_STOP_SENDING;
      }
    goto ret_end;
    }

  /*
   * Add myself to the list of variables
   */

  if (opts & SK_GETVR_COMPRESSED)
    props = VAR_PT;
  else
    props = VAR_X;

  SKaddvarlist (&msg_loc, opts, varlist, props, my_id, NULL, NULL,
   ME.SKptvar->pt, NULL);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (! (opts  & SK_GETVR_COMPRESSED))
    {
    SKaddvarlist (&msg_loc, opts, varlist, VAR_Y, my_id, NULL, NULL,
     &ME.SKptvar->pt[Y], NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKptvar.SKgetvarlist");
  return (stat_OM);
}

end implementation SKptvar;

