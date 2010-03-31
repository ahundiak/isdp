/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EMSsfstitch.EMgetInGeomIds

Description
        This method is overridden to indicate that the stitch operation
        adds no geometry to the dpr.  The implementation which would
        otherwise be inherited from EMSsfdpr returns all of the objects
        (surfaces) on the to_components channel.  During a recompute
        operation, this would result in the disconnection of the
        surfaces from the stitch - bad! bad! - and the stitch would be
        lost.

History
        mrm     03/26/91    creation
*/

class implementation EMSsfstitch;

method EMgetInGeomIds(IGRlong *EMmsg; 
                      OM_S_OBJID nodes_side_id;
                      IGRboolean is_kd_on;
                      IGRint *num_in_geom_ids;
                      OM_S_OBJID **in_geom_ids;
                      IGRushort options)
{
    *EMmsg = EMS_S_Success;
    *num_in_geom_ids = 0;
    *in_geom_ids = NULL;

    return(OM_S_SUCCESS);
}

end implementation EMSsfstitch;

