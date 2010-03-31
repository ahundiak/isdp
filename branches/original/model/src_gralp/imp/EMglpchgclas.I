class implementation EMSgraloop;

#include "EMS.h"
method EMchangeClass(IGRlong *EMmsg; OMuword new_classid;
                     OM_p_MESSAGE messg; GRobjid *newobjid)
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSgraloop;
