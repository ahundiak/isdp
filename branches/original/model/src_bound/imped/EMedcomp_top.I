/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
method EMcompress_top(IGRlong *EMmsg;
		struct EMSpartolbasis *partolbasis;
		GRobjid	*newobjid)
/*
Description

Return values
    
History
  DLB 4/22/87
*/
{
  *EMmsg = EMS_S_Success;
  *newobjid = my_id;
  return (OM_S_SUCCESS);
}

end implementation EMSedge;
