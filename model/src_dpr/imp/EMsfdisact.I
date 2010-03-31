/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"
method EMisactive(IGRlong *EMmsg; IGRboolean *active_state, *active_path)
/*
Description
   This method should be sent to an object indicating a state on the 
   state tree.  The method is used to determine if a particular state is
   active or in the active path.

Return Values
   EMS_S_Success always.

   active_state - TRUE if state represented by the object is active.
   active_path - TRUE is this state is in the active path.

History
   DLB 11/03/87 Modified for version 1.1.0
   DLB 04/01/87 creation
*/
{
 *EMmsg = EMS_S_Success;                
 *active_state = (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE) ? TRUE : FALSE;
 if (active_path)
  *active_path = (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) ? TRUE : FALSE; 
 return(OM_S_SUCCESS);
}
end implementation EMSsfdpr;

