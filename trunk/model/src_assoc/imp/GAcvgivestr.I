/* ###################   APOGEE COMPILED   ################## */
class implementation GAcurve;
method NDgive_structure (IGRlong *EMmsg; struct ret_struct *str;
                         struct GRmd_env *md_env)
/* ********************************************************
Description
 This override returns the objects type and geometry.

History
 Creation : WBC :03/08/91
*********************************************************** */
{
 *EMmsg = MSSUCC;

 return(ASgo_give_structure(my_id, OM_Gw_current_OS, md_env ,str));
}
end implementation GAcurve;
