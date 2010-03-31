/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method checks the validity of the shell-object managers attached
    to this object. It simply performs a pass-on of a similar message
    on the EMSobjmgr class. If the return code is EMS_I_InvalidCase, there is
    a problem in atleast one of the managers.

    The severity number returned indicates the extent of the damage. Lowest
    severity is 1 and increases with the number of errors found.

  HISTORY

    SS  :  08/09/89  :  Creation
*/

class implementation EMScleaner;

#include "OMerrordef.h"
#include "emsdef.h"
#include "EMSobjmgrdef.h"
#include "emserr.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSobjmgr import EMvalidate;

method EMvalidate_objmgr (IGRlong *msg; IGRushort options;
                          FILE *logfile; IGRchar *info; IGRint *severity)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_objmgr;

  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect (EMScleaner_to_objmgr, &chan_to_objmgr);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message EMSobjmgr.EMvalidate (msg, options,
             logfile, info, severity), p_chanselect = &chan_to_objmgr);
  
ret_end:
  return (stat_OM);
}

end implementation EMScleaner;
