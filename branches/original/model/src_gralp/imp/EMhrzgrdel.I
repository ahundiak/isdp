class implementation EMShorizon;


method GRdelete(IGRlong *msg; 
                 struct GRmd_env *md_env)
/*
Abstract: 
        This method deletes the graphics object from
        the object space.

Arguments
     *md_env      GRmd_env        structure containing context info
     *msg         IGRlong        completion code

Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure

History
    Jack   11/18/91   Created, send Root.delete to myself.

*/

{
 IGRlong sts;

 *msg = EMS_S_Success;

  sts =  om$send(msg      = message Root.delete(1),
                 targetid = my_id,
                 targetos = OM_Gw_current_OS);

 return (sts);
}

end implementation EMShorizon;

