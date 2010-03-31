/* ###################   APOGEE COMPILED   ################## */
class implementation EMAsubbs;

method EMdisplay_geomparam (IGRlong *msg; IGRushort opts;
                            IGRshort *mattyp; IGRmatrix mat;
                            IGRushort param_types;
                            struct GRid *disp_id)
{
  IGRlong msg_loc, stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Send w.r.t message to invoke the default invocation which displays
   * the parents alone.
   */

  stat_OM = om$send (mode = OM_e_wrt_message,
             msg = message EMSassoc.EMdisplay_geomparam (&msg_loc, opts,
             mattyp, mat, param_types, disp_id), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, msg_loc, ret_end);

  /*
   * Display this surface in half-highlight disregarding boundaries.
   * This would be the primitive surface as it was first placed.
   */

  stat_OM = om$send (msg = message EMSsubbs.EMnobdrydisp (&msg_loc, NULL,
             mattyp, mat, GRhhd, disp_id), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMAsubbs.EMdispgmpar");
  return (stat_OM);
}

end implementation EMAsubbs;
