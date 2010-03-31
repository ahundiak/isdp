/*
 * DESCRIPTION:
 *
 *  This is the function used to place a plane tangent to a curve or
 *  surface or normal to a curve. These can be placed as associative 
 *  or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  05/01/91
 */
class implementation EMAplane;


IGRlong EMplace_plane_tangent_normal
                               ( msg, 
                                 opts, 
                                 mdenv, 
                                 level,
                                 disp,
                                 dispattr,
                                 objname,
                                 type,
                                 length,
                                 width,
                                 curve,
                                 point,
                                 plnobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    IGRint                    type;
    struct EMSvalue_info    * length;
    struct EMSvalue_info    * width;
    struct EMSobject_info   * curve;
    struct EMSpoint_info    * point;
    GRobjid                 * plnobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[4];
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    if (opts & EMSasconst_notassociative)
    {
        IGRpoint  loc_point;
        IGRdouble loc_width, loc_length;
        struct GRevent   event;
        struct GRlc_info lcinfo;

        om_msg = EMgetparval_numeric (&msg_loc, length, &loc_length);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_numeric (&msg_loc, width, &loc_width);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparpt_numeric (&msg_loc, point, loc_point);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        lcinfo.module_info = curve->env;
        lcinfo.located_obj = curve->grid;

        event.subtype = GRst_REGULAR;
        event.event.button.objid = NULL_OBJID;
        memcpy(&event.event.button.x, loc_point, sizeof(IGRpoint));
        om_msg = EFpoint_on_object (&lcinfo, &event, NULL_OBJID, &msg_loc);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        /*
         * Construct the plane.
         */
        om_msg = om$construct ( classid = OPP_EMSplane_class_id,
                                msg = message EMSplane.EMplane_normal_and_tangent_to
                                    ( !(type == EMS_ASplane_normal_to_curve),
                                      !(type == EMS_ASplane_tangent_to_surface),
                                      TRUE,
                                      &lcinfo,
                                      &event.located_object[0].geom_parms,
                                      loc_length,
                                      loc_width,
                                      &vgcnstr ),
                                 p_objid = plnobj,
                                 osnum = constros );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        om_msg = EMgetparval_object (&msg_loc, constros, NULL, length, &parobjs[0]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, width, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        parobjs[2] = *curve;

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, point, &parobjs[3]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = om$construct ( classid = OPP_EMAplane_class_id,
                                msg = message EMSassoc.EMinit_associative 
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  4, 
                                                  parobjs, 
                                                  type,
                                                  0,
                                                  NULL, 
                                                  &vgcnstr ),
                                osnum = constros, 
                                p_objid = plnobj );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_plane_tangent_normal");
        return (om_msg);
}

end implementation EMAplane;
