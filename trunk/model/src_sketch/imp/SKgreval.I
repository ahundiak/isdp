class implementation SKground;

#include "OMmacros.h"
#include "DIdef.h"

from SKvariable import SKgetvar;
from SKvalvar import SKgetname;
from SKexplicit import SKgetname;

#define X 0
#define Y 1

method SKevaluate (IGRlong *msg; IGRushort options;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  IGRchar name[DI_PATH_MAX];
  IGRushort vprops;
  IGRlong stat_OM, msg_loc;
  IGRpoint fixed_var;
  GRobjid var_id;
  GRspacenum dum_os;
  struct SKsolvevars *varnode;
  OM_S_CHANSELECT chan_to_vars;
  extern void SKaddvarlist();
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  om$make_chanselect (channame = "SKconstraint.to_variables",
                      p_chanselect = &chan_to_vars);

  stat_OM = om$get_objid_at_index (object = me, 
             p_chanselect = &chan_to_vars, index = 0,
             objidaddr = &var_id, osnumaddr = &dum_os);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, *msg, EMS_E_InvalidCase, ret_end);

  if (SKvarlistinx (*solvedvars, var_id, tosolvevar->props, &varnode, NULL))
  {
    *msg = EMS_I_Redundant;
    goto ret_end;
  }

  stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
             NULL, NULL, NULL, fixed_var), targetid = var_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  vprops = tosolvevar->props;

  if ((vprops & VAR_PT) == VAR_PT && options & SK_UPDATE_COMPRESSED)
  {
    SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_PT, var_id, my_id, my_id,
                  fixed_var, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    if (vprops & VAR_X)
    {
      SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_X, var_id, my_id, my_id,
       &fixed_var[X], NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    if (vprops & VAR_Y)
    {
      SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_Y, var_id, my_id, my_id,
                    &fixed_var[Y], NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    if (vprops & VAR_SOMEVAL)
    {
      if (vprops & VAR_PSEUDO_VAL)
        stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc, 
                   SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, name),
                   targetid = var_id);
      else
        stat_OM = om$send (msg = message SKvalvar.SKgetname (&msg_loc, 
                   SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, name),
                   targetid = var_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      SKaddvarlist (&msg_loc, NULL, solvedvars,
                    vprops & VAR_SOMEVAL, var_id, my_id, my_id, fixed_var, name);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  }

ret_end:
  EMWRAPUP(*msg, stat_OM, "SKground.SKevaluate");
  return (stat_OM);
}

end implementation SKground;
