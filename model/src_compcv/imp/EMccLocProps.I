/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
# include "grownerdef.h"

method GRget_locate_properties(IGRlong *EMmsg; IGRint *properties)
{
  IGRlong   sts;

  sts = om$send(mode = OM_e_wrt_message, msg = message
                EMScomposite.GRget_locate_properties(EMmsg, properties),
                targetid = my_id);
  *properties |= GR_LC_CHECK_PLANAR;
  return(sts);
}

end implementation GRcompcurve;
