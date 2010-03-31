/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "emsdef.h"

method EMgetInGeomIds(IGRlong *EMmsg; 
                      GRobjid nodes_side_id; 
                      IGRboolean is_kd_on; 
                      IGRint *num_in_geom_ids; 
                      GRobjid **in_geom_ids; 
                      IGRushort options)
/*
Description
    This message will get the geometry added by this operation.  The main user
    of this message will be the EMcheckRngOverlap message.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        node_id  - the added node which is being checked against.
        nodes_side_id - the component of this state that contains the
                        replacing node.  This is needed by some states 
                        such as booleans where in the added geometry can only
                        be determined relative to what has changed.  For local
                        operations this parameter MAY not be referenced.
        num_in_geom_ids - returned num ids found.
        in_geom_ids - returned ids found.
        options - None so far.

History
    DLB 05/25/91    If im in a NULL_STATE return 0.
    DLB 03/29/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  

  *EMmsg = EMS_S_Success;

  if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
  {
    *num_in_geom_ids = 0;
  }
  else
  {
    if (nodes_side_id == NULL_OBJID)
    {
      /*Get the added surfs of this node.*/
      OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
      nodes_side_id = ssi->lft_info.sf_lifted_ids[0];
    }
  
    /*Get all the surfaces I generated.*/
    OM_stat = om$send(mode = OM_e_wrt_parent,
                      msg = message EMSlift.EMgetInGeomIds(EMmsg,
                            nodes_side_id, is_kd_on, num_in_geom_ids,
                            in_geom_ids, options),
                      targetid = my_id);
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "lft.getInGmIds")
  return(OM_stat);
}
end implementation EMSlift;
