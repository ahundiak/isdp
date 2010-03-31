/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"

method EMislm(IGRlong *EMmsg; IGRboolean *is_lm)
/*
Description
   This method will return is_lm true if send to any object considered to be
   an object residing within the local modification stack of the dpr tree.

   Note that even surfaces, and composites will return true here since they
   are part of the local modification stack.

Return Values
   EMS_S_Success if all is well

History
   DLB 08/12/88 Creation.
*/

{
  *EMmsg = EMS_S_Success;
  *is_lm = TRUE;
  return(OM_S_SUCCESS);
}
end implementation EMSsurface;
