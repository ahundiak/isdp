/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslslotfea;

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
        nodes_side_id - the component of this state that contains the
                        replacing node.  This is needed by some states 
                        such as booleans where in the added geometry can only
                        be determined relative to what has changed.  For local
                        operations this parameter MAY not be referenced.
        is_kd_on - indicates a known dependency and is an indicator of what is
                   added in a boolean op (which operand).
        num_in_geom_ids - returned num ids found.
        in_geom_ids - returned ids found.
        options - None so far.

History
    Tapadia 30/08/91  Creation.
*/
{
  IGRlong           OM_stat;
  GRobjid           GRids;
  OM_S_CHANSELECT   to_comps;
  OMuword           dum_os;
  OMuint 	    i,num_of_comps;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *num_in_geom_ids = 0;

  OM_stat = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  if(!(1& OM_stat)) goto wrapup;

  /* count the number of components */
  OM_stat = om$get_channel_count(objid = my_id, 
				p_chanselect = &to_comps,
				count = &num_of_comps); 

  if(!(1& OM_stat)) goto wrapup;

  if(num_of_comps > 1) {
  	*in_geom_ids = (GRobjid *) om$malloc(size = sizeof(GRobjid) *
				(num_of_comps - 1));
  	if(! *in_geom_ids) {
		*EMmsg = EMS_E_NoDynamicMemory;
		goto wrapup;
  	}
  }
  else 
   return (OM_S_SUCCESS);

  /* get the component ids */
  for(i = 1; i < num_of_comps; i++) {
 	OM_stat = om$get_objid_at_index(objid = my_id,
				p_chanselect = &to_comps,
				index = i,
				objidaddr = &GRids,
				osnumaddr = &dum_os);
  	if(!(1& OM_stat)) goto wrapup;

        (*in_geom_ids)[*num_in_geom_ids] = GRids;
        (*num_in_geom_ids)++;
  }


wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSslslotfea.getInGmIds")
  return(OM_stat);
}
end implementation EMSslslotfea;
