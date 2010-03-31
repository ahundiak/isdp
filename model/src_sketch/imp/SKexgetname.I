class implementation SKexplicit;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method SKgetname (IGRlong *msg; IGRushort opts; IGRchar *name)
{
  IGRchar loc_name[DI_PATH_MAX];
  IGRlong stat_OM, stat_DI;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (name)
    name[0] = NULL;

  /*
   * If I am eligible to return my name, do so.
   */

  if (name)
    {
    stat_DI = di$untranslate (objname = loc_name, objid = my_id);
    EMerr_hndlr (stat_DI != DIR_S_SUCCESS, *msg, EMS_I_NotFound, ret_end);

    if (opts & SK_GETVR_SIGNIFNAME)
      {
      stat_DI = di$split (pathname = loc_name, name = name);
      EMerr_hndlr (stat_DI != DIR_S_SUCCESS, *msg, EMS_E_InvalidCase, ret_end);
      }
    else
      strcpy (name, loc_name);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexgetname");
  return (OM_S_SUCCESS);
}

end implementation SKexplicit;
