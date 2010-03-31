/* ###################   APOGEE COMPILED   ################## */
class implementation EMSobjmgr;

#include "EMS.h"

method EMgetinfo (IGRlong *msg; IGRulong *label)
{
  *msg = EMS_S_Success;

  *label = ME.EMSobjmgr->label;

  return (OM_S_SUCCESS);
}

end implementation EMSobjmgr;

