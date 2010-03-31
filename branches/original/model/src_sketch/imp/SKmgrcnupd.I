class implementation SKmgr;

#define IMPLICIT 0
#define EXPLICIT 1

from SKconstraint import SKpass_by_class_type, SKrecompute_yourself;

method SKconstr_update (IGRlong *msg; IGRushort opts;
                        struct SKsolvevars *chg_vars;
                        struct GRmd_env *mod_env)
{
  IGRshort mattyp_to_lxyz, inx;
  IGRlong msg_loc, stat_OM;
  IGRmatrix mat_to_lxyz;
  enum GRdpmode disp_mode;
  OM_S_CHANSELECT chan_to_constrs;
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
             SK_OPT_GET_XY_TO_LXYZ, NULL, NULL, &mattyp_to_lxyz,
             mat_to_lxyz), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (SKmgr_to_constrs, &chan_to_constrs);
  for (inx=IMPLICIT; inx<=EXPLICIT; inx++)
    {
    if (opts & (inx == IMPLICIT ? SK_UPDATE_IMPCONSTRS : SK_UPDATE_EXPCONSTRS))
      {
      if (opts & SK_UPDATE_ERASE)
        {
        disp_mode = GRbehe;
        stat_OM = om$send (msg = message SKconstraint.SKpass_by_class_type
                   (&msg_loc,
                   message GRgraphics.GRdisplay (&msg_loc,
                   &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                   &disp_mode, &mod_env->md_id),
                   inx == IMPLICIT ? SK_PASS_IMPLICIT_CLASS
                                   : SK_PASS_EXPLICIT_CLASS),
                   p_chanselect = &chan_to_constrs);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      if (! (opts & SK_UPDATE_DONOTPOST))
        {
        stat_OM = om$send (msg = message SKconstraint.SKpass_by_class_type
                   (&msg_loc,
                   message SKconstraint.SKrecompute_yourself (&msg_loc,
                   mod_env, &mattyp_to_lxyz, mat_to_lxyz), 
                   inx == IMPLICIT ? SK_PASS_IMPLICIT_CLASS 
                                   : SK_PASS_EXPLICIT_CLASS),
                   p_chanselect = &chan_to_constrs);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      if (opts & SK_UPDATE_DRAW)
        {
        disp_mode = GRbd;
        stat_OM = om$send (msg = message SKconstraint.SKpass_by_class_type
                   (&msg_loc,
                   message GRgraphics.GRdisplay (&msg_loc,
                   &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                   &disp_mode, &mod_env->md_id),
                   inx == IMPLICIT ? SK_PASS_IMPLICIT_CLASS 
                                   : SK_PASS_EXPLICIT_CLASS),
                   p_chanselect = &chan_to_constrs);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKconstrupdate");
  return (stat_OM);
}

end implementation SKmgr;
