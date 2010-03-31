/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparameter;

method EMparam_delete(IGRlong *EMmsg; 
                      struct GRmd_env *md_env)
/*
Description
    Delete me.

Notes
    None.

History
    DLB 04/19/91    Creation.
*/
{
    *EMmsg = EMS_S_Success;

    return(om$send(msg = message Root.delete(NULL),
                   targetid = my_id));  
}
end implementation EMSparameter;
