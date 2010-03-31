/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"

method EMtoggleKDFlag(IGRlong *EMmsg; IGRboolean *turn_off)
/*
Description
    This message will indicate the ability to turn off the KNOWN DEPENDENT
    flag.

Return Values
    EMS_S_Success is always returned.

Notes
    About parameters:
      turn_off - if true the KD flag may be turned off.
                 if false it must remain on.

History
    DLB 12/10/88 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  *turn_off = FALSE;
  return(OM_S_SUCCESS);
}
end implementation EMSsfdpr;
