/*
  DESCRIPTION

    This method may be used to obtain all the variables and/or constraints
    that are part of this system governed by this manager object.

  HISTORY

    SS  :  08/18/90  :  Creation
*/

class implementation SKmgr;

from SKvariable import SKgetvarlist;
from SKconstraint import SKgetconstrs, SKgetpseudovarlist;

method SKgetvarconstrs  (IGRlong *msg; IGRushort opts;
                         struct SKsolvevars **varlist;
                         IGRint *num_constrs; struct SKconstrinfo **constrs)
{
  IGRint num_constrs_mem;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_vars, chan_to_constrs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (varlist)
    {
    /*
     * Obtain the list of variables.
     */

    if (! (opts & SK_GETVR_FIND))
      *varlist = NULL;

    EMmake_chanselect (SKmgr_to_vars, &chan_to_vars);
    msg_loc = EMS_S_Success;
    stat_OM = om$send (msg = message SKvariable.SKgetvarlist (&msg_loc, opts,
               varlist), p_chanselect = &chan_to_vars);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (opts & SK_GETVR_FIND && msg_loc == EMS_I_Found)
      {
      *msg = msg_loc;
      goto ret_end;
      }
      
    EMmake_chanselect (SKmgr_to_constrs, &chan_to_constrs);
    msg_loc = EMS_S_Success;
    stat_OM = om$send (msg = message SKconstraint.SKgetpseudovarlist (&msg_loc,
               opts, varlist), p_chanselect = &chan_to_constrs);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (opts & SK_GETVR_FIND && msg_loc == EMS_I_Found)
      {
      *msg = msg_loc;
      goto ret_end;
      }
    }

  if (num_constrs || constrs)
    {
    /*
     * Obtain the list of constraints
     */

    EMmake_chanselect (SKmgr_to_constrs, &chan_to_constrs);

    if (! (opts & SK_GETCN_FIND))
      {
      *num_constrs = 0;
      if (constrs)
        *constrs = NULL;
      }

    num_constrs_mem = 0;
    msg_loc = EMS_S_Success;
    stat_OM = om$send (msg = message SKconstraint.SKgetconstrs (&msg_loc,
               opts, varlist ? *varlist : NULL, num_constrs,
               &num_constrs_mem, constrs), p_chanselect = &chan_to_constrs);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (opts & SK_GETCN_FIND && msg_loc == EMS_I_Found)
      {
      *msg = msg_loc;
      goto ret_end;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgetvarconstrs");
  return (stat_OM);
}

end implementation SKmgr;
