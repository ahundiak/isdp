/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"

method EMgetUnevalIds(IGRlong *EMmsg; GRobjid uneval_sender_id; IGRboolean
                      is_kd_on; IGRushort options;
                      IGRint *num_ids; GRobjid **ids)
/*
Description
    This message returns the array of ids that should have managers added 
    as a result of a deactivation of this state.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      uneval_sender_id - the id of the node that defines the path of
                         deactivation. 
      is_kd_on  - indicates whether this node recieved a EMdeactivateState
                  message with the KD flag turned on.
      options - currently unused.
      num_ids - number of ids in ids array.
      ids - array of ids malloc'd by this message.  This array should be
            freed using om$dealloc.

History
    DLB 12/13/88 Creation.
*/

{
  IGRlong OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_E_InvalidSend;

  EMWRAPUP(*EMmsg, OM_stat, "EMSsfstitch.EMaddManager")
  return(OM_stat);
}
end implementation EMSsfstitch;
