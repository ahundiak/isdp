/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamvl;

#include "nddef.h"

#define SUPPORT_ONLY_WORKS_FOR_MACROS 0

method EMconstruct (IGRlong *msg; IGRushort opts;
                    IGRdouble val; IGRchar *name)
{
  IGRboolean stat_func;
  IGRchar *nameptr, name_mem[DI_PATH_MAX], valchar[25];
  IGRchar mask, n_state;
  IGRlong msg_loc, stat_OM;
  IGRboolean EMdefnewname();

  *msg = EMS_S_Success;
  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain a name for myself if it has not been passed in.
   */

  if (!name)
    {
    nameptr = name_mem;
    stat_func = EMdefnewname (nameptr, OM_Gw_current_OS, EMSscalar);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);
    }
  else
    nameptr = name;

  /*
   * Create the expression as simply the constant value
   */

  sprintf (valchar, "%20.9lf", val);

  /*
   * Invoke the expression-create method, with my name and value
   */

  stat_OM = om$send (msg = message expression.create (nameptr, valchar,
             (IGRshort *) &msg_loc), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

#if SUPPORT_ONLY_WORKS_FOR_MACROS
/*
 * Change my state such that it gets deleted only if there is nobody 
 * depending on me.
 * pp 09/26/91
 */
  mask = ~0;
  n_state = ND_DEL_NO_CH;

  om$send (msg = message NDnode.NDchg_state(mask, n_state),
           targetid = my_id);

#endif
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparamvl.EMconst");
  return (stat_OM);
}

end implementation EMSparamvl;
