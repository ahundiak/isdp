/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"

method EMcanRecompute(IGRlong *EMmsg; IGRboolean *can_rc)
/*
Description
    This message will indicate the ability of this node to recompute. 

Return Values
    EMS_S_Success is always returned.

Notes
    About parameters:
      can_rc - if true this node can recompute.

History
    DLB 06/12/89 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  *can_rc = TRUE;  
  return(OM_S_SUCCESS);
}
end implementation EMSsfhist;
