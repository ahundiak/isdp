class implementation EMSexpcnstr;

#include <string.h>
#include "DIprims.h"

method EMputval (IGRlong *msg; IGRushort opts;
                 IGRdouble val; IGRchar *rhs)
{
  IGRchar *p_valstr, *p_name, name[DI_PATH_MAX], valstr[20];
  IGRchar save_pretty_print[EXP_MAX_LEN];
  IGRshort s_msg_loc;
  IGRlong stat_OM, stat_DI;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_DI = di$untranslate (objname = name, objid = my_id);
  if (stat_DI == DIR_S_SUCCESS)
    p_name = name;
  else
    p_name = NULL;

  if (rhs)
    p_valstr = rhs;
  else
    {
    sprintf (valstr, "%lf", val);
    p_valstr = valstr;
    }

  strncpy (save_pretty_print, ME.expression->pretty_print, EXP_MAX_LEN-1);
  save_pretty_print[EXP_MAX_LEN-1] = NULL;
  stat_OM = om$send (msg = message expression.modify (p_name, p_valstr,
             &s_msg_loc), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & s_msg_loc), *msg, EMS_E_Fail, ret_end);
  if (!strncmp (save_pretty_print, ME.expression->pretty_print, EXP_MAX_LEN))
    *msg = EMS_I_Useless;

  ME.expression->value = val;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSexpcnstr.EMputval");
  return(stat_OM);
}

end implementation EMSexpcnstr;
