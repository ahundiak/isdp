/* ###################   APOGEE COMPILED   ################## */
class implementation EMSopenloop;

#include "EMS.h"
method EMnesting(IGRlong *EMmsg;struct EMSnest_info *nesting;
                  struct EMSpartolbasis *partolbasis)
{
  *EMmsg = EMS_I_OpenLoop;
  return(OM_S_SUCCESS);
}

end implementation EMSopenloop;
