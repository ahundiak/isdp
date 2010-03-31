/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

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
    DLB 01/09/89 Creation.
*/
{
  IGRlong                  OM_stat=OM_S_SUCCESS;
  IGRint                   ii;
  union EMSssi_table       *ssi=NULL;
  struct EMSsspssi_table   *my_info;
  IGRboolean               found_moved=FALSE;


  *EMmsg = EMS_S_Success;

  my_info = NULL;
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_info = &ssi->spl_info;

  /*See if any the out surface is also comp_moved_id*/
  if (my_info->srf_owner_ids[0] == original_node_id)
  {
    /*Possible affected case.*/
    for(ii=0; ii<num_comp_moved; ii++)
    {
      if (my_info->srf_ids[0] == comp_moved_ids[ii])
      {
        /*Got a moved surface out*/
        found_moved = TRUE;
        break;
      }
    } 
  }

  if (!found_moved)
  {
    OM_S_CHANSELECT to_owners;

    /*No moved component is removed by this node.*/

    EMmake_chanselect(GRconnector_to_owners, &to_owners);

    OM_stat = om$send(msg = OPPmargs,
                      p_chanselect = &to_owners);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    OM_stat = OM_S_SUCCESS;
  }                      
  else
  {
    my_info->srf_owner_ids[0] = new_node_id;
    OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfsplit.EMnodeBrokeApart")
    return(OM_stat);
}
end implementation EMSsfsplit;

