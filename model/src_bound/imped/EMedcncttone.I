/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "emsmacros.h"

method EMconnect_to_ne(IGRlong *EMmsg; GRobjid *connect_id)
/*
Description

Return values
    
History
   DLB 4/23/87
*/
{

 *EMmsg = EMS_E_Fail;
 return (OM_E_ABORT);

}

end implementation EMSedge;
