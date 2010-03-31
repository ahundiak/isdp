/*
Name
	EMsfimpbnd.EMgetInGeomIds

Description
	This method is overridden to indicate that no geometry is
        added by the impose boundary state.

History
	mrm     06/07/91   creation
*/

class implementation EMSsfimpbnd;

method EMgetInGeomIds(IGRlong *EMmsg; 
                      GRobjid nodes_side_id; 
                      IGRboolean is_kd_on; 
                      IGRint *num_in_geom_ids; 
                      GRobjid **in_geom_ids; 
                      IGRushort options)
{
    *EMmsg = EMS_S_Success;
    *num_in_geom_ids = 0;
    return(OM_S_SUCCESS);
}

end implementation EMSsfimpbnd;
