/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrndbool;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "emsdef.h"         /*EMmake_chanselect def.*/
#include "EMSmsgdef.h"


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

* History :-

  Inasu : Sept 06, 91  : Creation.
*/
{
  IGRlong           om_stat;
  OMuint            num_ids, ii;
  OM_S_CHANSELECT   to_comps;
  GRspacenum        osnum;
  

  *EMmsg = EMS_S_Success;
  om_stat= OM_S_SUCCESS;


  num_ids          = 0;
  *num_in_geom_ids = 0;
  *in_geom_ids     = NULL;

  /*Get the added surfs of this node.*/

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  om_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &num_ids); 
  EMerr_hndlr( !(1 & om_stat), *EMmsg, EMS_E_OMerror, wrapup);

  if (num_ids)
  {
    *in_geom_ids = (GRobjid *) om$malloc(size = num_ids * sizeof(GRobjid));
    if (! *in_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  }
  else goto wrapup;

  /* Return only the objects starting from index=1, onwards */

  *num_in_geom_ids = num_ids - 1;

  for(ii=1; ii< num_ids; ii++)
  {
    om_stat = om$get_objid_at_index( object       = me,
                                     p_chanselect = &to_comps,
                                     index        = ii,
                                     objidaddr    = &(*in_geom_ids)[ii-1],
                                     osnumaddr    = &osnum);
    EMerr_hndlr( !(1 & om_stat), *EMmsg, EMS_E_OMerror, wrapup);
  }


 wrapup:

    EMWRAPUP(*EMmsg, om_stat, "EMSsfrndbool.EMgetInGeomIds")
    return(om_stat);
}
end implementation EMSsfrndbool;
