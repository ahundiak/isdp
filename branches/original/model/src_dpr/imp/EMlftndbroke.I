/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "EMSdpr.h"
#include "OMmacros.h"
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
    DLB 01/10/89 Creation.
*/
{
  IGRlong                  OM_stat=OM_S_SUCCESS;
  union EMSssi_table       *ssi=NULL;
  struct EMSlftssi_table   *my_info;
  OM_S_CHANSELECT          to_owners;
  IGRboolean               SSI_changed=FALSE, composite_added=FALSE;
  void                     EFcompositeSSIchanged();


  *EMmsg = EMS_S_Success;

  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_info = &ssi->lft_info;

  EFcompositeSSIchanged(EMmsg,
                        &my_info->num_composites, 
                        &my_info->composite_ids,
                        &my_info->num_surfaces_out,
                        my_info->surface_out_ids,
                        my_info->composite_indices,
                        num_comp_moved,
                        comp_moved_ids,
                        original_node_id,
                        new_node_id,
                        &SSI_changed, &composite_added);
  if (!(1 & *EMmsg)) goto wrapup;                               

  if (SSI_changed)
  {
    OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  /*Send on up.*/
  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$send(msg = OPPmargs,
                    p_chanselect = &to_owners);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  OM_stat = OM_S_SUCCESS;

  wrapup:
    if (composite_added) 
    {
      if (my_info->composite_ids) om$dealloc(ptr = my_info->composite_ids);
      if (my_info->num_surfaces_out) 
                                  om$dealloc(ptr = my_info->num_surfaces_out);
    }
    if (ssi) om$dealloc(ptr = ssi);

    EMWRAPUP(*EMmsg, OM_stat, "EMSlift.EMnodeBrokeApart")
    return(OM_stat);
}
end implementation EMSlift;

