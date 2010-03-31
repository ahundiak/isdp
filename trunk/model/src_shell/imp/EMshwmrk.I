/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshobjmgr;

#include "EMS.h"
method EMgetwatermark (IGRint *watermark)
{
  *watermark = me->watermark;
  return (OM_S_SUCCESS);
}

method EMchgwatermark (IGRint watermark)
{
  if (watermark < 1)
    watermark = 1;

  me->watermark = watermark;
  return (OM_S_SUCCESS);
}


end implementation EMSshobjmgr;
