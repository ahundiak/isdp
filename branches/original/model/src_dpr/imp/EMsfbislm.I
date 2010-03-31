/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSerrordef.h"

method EMislm(IGRlong *EMmsg; IGRboolean *is_lm)
/*
Description
   See description in EMSsurface.S

Return Values
   EMS_S_Success if all is well

History
   DLB 08/12/88 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  *is_lm = FALSE;
  return(OM_S_SUCCESS);
}
end implementation EMSsfboolean;
