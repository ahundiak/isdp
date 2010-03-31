/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "emsdef.h"         /*EMmake_chanselect def.*/
#include "EMSmsgdef.h"

extern OMuword OPP_EMSsubbs_class_id;

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
    DLB 11/08/90 Removed env param & added is_kd_on param.
    DLB 10/17/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            num_GRids=0, ii;
  struct GRid       *GRids=0, reject_GRid, from_GRid;
  OM_S_CHANSELECT   to_comps;
  

  *EMmsg = EMS_S_Success;

  /*Get the added surfs of this node.*/
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  from_GRid.objid = my_id;
  from_GRid.osnum = OM_Gw_current_OS;  
  reject_GRid.objid = nodes_side_id;
  reject_GRid.osnum = OM_Gw_current_OS;

  EFgetobjids(EMmsg, &from_GRid, &to_comps, &GRids, &num_GRids, 
              OPP_EMSsubbs_class_id, &reject_GRid, 1); 
  if (!(1 & *EMmsg)) goto wrapup;

  *num_in_geom_ids = 0;
  *in_geom_ids = NULL;

  if (num_GRids)
  {
    *in_geom_ids = (GRobjid *) om$malloc(size = num_GRids * sizeof(GRobjid));
    if (! *in_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  }
  else goto wrapup;

  /*Unwind the node ids into geometry GRobjids*/
  for(ii=0; ii<num_GRids; ii++)
  {
    (*in_geom_ids)[ii] = GRids[ii].objid;
  }
  *num_in_geom_ids = num_GRids;

  wrapup:
    if (GRids) om$dealloc(ptr = GRids);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfdpr.EMgetInGeomIds")
    return(OM_stat);
}
end implementation EMSsfdpr;
