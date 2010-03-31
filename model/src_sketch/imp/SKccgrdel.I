/* ###################   APOGEE COMPILED   ################## */
class implementation SKcompcurve;

method GRdelete (IGRlong *msg; struct GRmd_env *md_env)
{
  IGRlong stat_OM, msg_loc;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

/*
 * Added by pp 06/21/91  so that dependents can react to this delete
 */
  {
   OM_S_CHANSELECT to_children;
   struct GRid src_grid;
   extern char NDgraph_mode;
   extern IGRboolean ASbroadcast_in_progress;

   if (!ASbroadcast_in_progress)
   {
    EMmake_chanselect(NDchildren_children, &to_children);

/*
 * Send a NDmove_to_root message to my children.
 */
    
    om$send (msg = message NDnode.NDmove_to_root(&msg_loc, &src_grid,
                  md_env),
             p_chanselect = &to_children);
    }
   }
/* end pp */

  stat_OM = om$send (mode = OM_e_wrt_message, 
             msg = message GRcompcurve.GRdelete (&msg_loc, md_env),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcompcurve.GRdelete");
  return (stat_OM);
}
end implementation SKcompcurve;
