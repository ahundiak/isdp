/* ###################   APOGEE COMPILED   ################## */
class implementation EMScleaner;

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSobjmgr import EMwakeup, EMsleep;

method global_class.sleep (IGRint type_sleep)
{
  IGRint file_write;
  IGRlong stat_OM;
  GRobjid mdobjid;
  OM_S_CHANSELECT chan_to_objmgr;

  stat_OM = ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mdobjid);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = ex$file_status (modid = mdobjid, modos = OM_Gw_current_OS,
             mode = &file_write);
  EMomerr_exit (stat_OM, ret_end);
  
  stat_OM = EMmake_chanselect (EMScleaner_to_objmgr, &chan_to_objmgr);
  EMomerr_exit (stat_OM, ret_end);

  om$send (msg = message EMSobjmgr.EMsleep (type_sleep,
   file_write == EX_WRITE_FILE ? TRUE : FALSE),
   p_chanselect = &chan_to_objmgr);

ret_end:
  return (stat_OM);
}

method wake_up ()
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_objmgr;

  stat_OM = EMmake_chanselect (EMScleaner_to_objmgr, &chan_to_objmgr);
  EMomerr_exit (stat_OM, ret_end);

  om$send (msg = message EMSobjmgr.EMwakeup (ex$is_temp_wakeup()), 
   p_chanselect = &chan_to_objmgr);

ret_end:
  return (stat_OM);
}

end implementation EMScleaner;
