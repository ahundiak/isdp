/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsflm;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"

method EMislmintree(IGRlong *EMmsg; IGRboolean *flag)
/*
Description

History
   DLB    06/8/87   Creation
*/

{
 *EMmsg = EMS_S_Success;
 *flag = TRUE;
 return(OM_I_STOP_SENDING);
}
end implementation EMSsflm;
