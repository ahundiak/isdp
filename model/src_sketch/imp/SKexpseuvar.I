class implementation SKexplicit;

#include "DIdef.h"

method SKgetpseudovarlist (IGRlong *msg; IGRushort opts;
                           struct SKsolvevars **varlist)
{
  IGRchar varname[DI_PATH_MAX];
  IGRlong msg_loc, stat_OM;
  IGRdouble val;
  extern void SKaddvarlist();
  extern IGRboolean SKisvarlinlist();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Check the options for eligibility
   */

  if (opts & SK_GETVR_NDCHILDREN &&
      !(ME.SKconstraint->props & SK_PARAMETER_DIM))
    goto ret_end;
  else if (opts & SK_GETVR_VALVAR)
    goto ret_end;

  /*
   * If this constraint does not have a "fixed" value, ie, marked as
   * NOVALUE, it implies that this constraint is a variable in the system.
   * So, return myself as a pseudo-variable.
   */

  if (ME.SKconstraint->props & SK_NOVALUE)
    {
    if (! SKvarlistinx (*varlist, my_id, VAR_SOMEVAL, NULL, NULL))
      {
      if (! (opts & SK_GETVR_FIND))
        {
        val = ME.expression->value;

        stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc,
                   SK_GETVR_SIGNIFNAME, varname), targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
         ret_end);

        SKaddvarlist (&msg_loc, NULL, varlist, VAR_PSEUDO_VAL, my_id,
         NULL, NULL, &val, varname);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    else if (opts & SK_GETVR_FIND)
      {
      *msg = EMS_I_Found;
      stat_OM = OM_I_STOP_SENDING;
      goto ret_end;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.SKgetpseudo");
  return (stat_OM);
}

end implementation SKexplicit;
