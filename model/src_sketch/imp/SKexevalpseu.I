class implementation SKexplicit;

#include "DIdef.h"

method SKevalpseudoeqn (IGRlong *msg; IGRushort opts;
                        struct SKsolvevars **solvedvars, *tosolvevar;
                        struct SKsolvevars **oversolv_vars, **nosolv_vars)
{
  IGRchar name[DI_PATH_MAX];
  IGRlong msg_loc, stat_OM;
  extern void SKaddvarlist();
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (ME.SKconstraint->props & SK_NOVALUE, *msg, EMS_E_InvalidCase,
   ret_end);

  if (SKvarlistinx (*solvedvars, my_id, VAR_SOMEVAL, NULL, NULL))
    {
    *msg = EMS_I_Redundant;
    goto ret_end;
    }
  else
    {
    stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc, 
               SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, name),
               targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_PSEUDO_VAL,
     my_id, my_id, my_id, &ME.expression->value, name);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  return (stat_OM);
}

end implementation SKexplicit;
