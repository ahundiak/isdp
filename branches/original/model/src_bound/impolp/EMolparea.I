/* ###################   APOGEE COMPILED   ################## */
class implementation EMSopenloop;

#include "EMS.h"
method EMarea (IGRlong *msg; IGRdouble *area)
{
  *msg = EMS_I_Degenerate;
  *area = 0.0;
  return (OM_S_SUCCESS);
}

end implementation EMSopenloop;

