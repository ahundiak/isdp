/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSdpr.h"
#include "emsdef.h"

method EMnodeBrokeApart(IGRlong *EMmsg; 
                        GRobjid original_node_id;
                        GRobjid new_node_id;         
                        IGRint num_comp_moved;
                        GRobjid *comp_moved_ids;
                        IGRushort options)
/*
Description
    This message notifies and owner DPR nodes that a node in history broke
    apart.  Any node that is interested, needs to override this message in
    order to update its SSI.

    The standard response to this message is a pass on to the owner.    

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      original_node_id - id of the node that has broken apart.
      node_node_id - the node created from the original.
      num_comp_moved - number of component nodes that were moved to the new
                       node.
      comp_moved_ids - the moved component nodes.
      options - currently unused.

History
    DLB 01/09/89 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_owners;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$send(msg = OPPmargs,
                    p_chanselect = &to_owners);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup; 

  OM_stat = OM_S_SUCCESS;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMnodeBrokeApart")
    return(OM_stat);
}
end implementation EMSdpr;

