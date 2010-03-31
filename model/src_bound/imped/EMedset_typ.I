/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"

method EMset_type (IGRlong *EMmsg; IGRuchar curve_type)

{
  IGRlong stat_OM;

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ME.EMSedge->curve_type = curve_type;

  return (stat_OM);
}

end implementation EMSedge;
