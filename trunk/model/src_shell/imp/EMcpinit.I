/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMS.h"
#include "exmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMinit (IGRulong label; IGRchar *moreinfo)
{
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMSobjmgr.EMinit (label, moreinfo),
             mode = OM_e_wrt_message, targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
   
  ME.EMScpmgr->num_entries = 0;

ret_end:
  return (stat_OM);
}

end implementation EMScpmgr;
