/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
method EMget_location(IGRlong *EMmsg; IGRshort *location)
{
        *location = -3;
        *EMmsg = EMS_S_Success;
        return(OM_S_SUCCESS);
}

end implementation EMSedge;
