class implementation EMSsfunitesf;

#include "emsdef.h"


/*

DESCRIPTION

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

HISTORY
   DLB   :  08/14/92  : Anand was not allocating memory for in_geom_ids!!!!
   AMD   :  07/14/92  : Creation


*/

method EMgetInGeomIds(IGRlong *EMmsg; 
                      GRobjid nodes_side_id; 
                      IGRboolean is_kd_on; 
                      IGRint *num_in_geom_ids; 
                      GRobjid **in_geom_ids; 
                      IGRushort options)
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  GRspacenum              dumosnum;
  OM_S_CHANSELECT         to_comps;
  GRobjid                 new_plane;
  OMuint                  count=0;

  *EMmsg = EMS_S_Success;

  *num_in_geom_ids = 0;

    EMmake_chanselect( GRcmpowner_to_components, &to_comps);

    OM_stat = om$get_channel_count(object = me,
                                   p_chanselect = &to_comps,
                                   count = &count); 
    EMerr_hndlr( !(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if(count < 2) goto wrapup;

    OM_stat = om$get_objid_at_index ( objid = my_id,
                                  p_chanselect = &to_comps,
                                  index = 1,
                                  objidaddr = &new_plane,
                                  osnumaddr = &dumosnum);
    EMomerr_hndlr (OM_stat, wrapup, "om$get_objid_at_index");  

    *in_geom_ids = (GRobjid *) om$malloc(size = sizeof(GRobjid));
    if (! *in_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    (*in_geom_ids)[0] = new_plane;

    (*num_in_geom_ids)++;


wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfunitesf.getInGmIds")
  return(OM_stat);
}
end implementation EMSsfunitesf;
