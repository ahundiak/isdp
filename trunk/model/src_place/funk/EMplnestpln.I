/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a plane encompassing a list of curves.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMAplane;


IGRlong EMplace_nested_plane ( msg, 
                               opts, 
                               mdenv, 
                               level,
                               disp,
                               dispattr,
                               objname,
                               num_curves,
                               curves,
                               plnobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    IGRint                    num_curves;
    struct EMSobject_info   * curves;
    GRobjid                 * plnobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRint                  i;
    extern OM_S_OBJID       current_creator;


    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    if ((opts & EMSasconst_notassociative) && num_curves)
    {
        struct GRlc_info * loc_curves;

        loc_curves = (struct GRlc_info *)stackalloc(num_curves * sizeof(struct GRlc_info));

        for (i=0; i<num_curves; ++i)
        {
            loc_curves[i].module_info = curves[i].env;
            loc_curves[i].located_obj = curves[i].grid;
        }

        /*
         * Construct the plane.
         */
        om_msg = EFplace_nested_plane ( num_curves,
                                        loc_curves,
                                        &vgcnstr,
                                        FALSE,
                                        NULL_OBJID,
                                        plnobj,
                                        &msg_loc );
                                     
        stackfree (loc_curves);

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        om_msg = om$construct(classid = OPP_EMAplane_class_id,
                              osnum = constros, 
                              p_objid = plnobj);
        if (1 & om_msg)
        {
          current_creator = *plnobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                           ( &msg_loc,
                                             opts & ~EMSasconst_recompute,
                                             num_curves, 
                                             curves, 
                                             EMS_ASplane_encompassing_curves, 
                                             0,
                                             NULL, 
                                             &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *plnobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_nested_plane");
        return (om_msg);
}

end implementation EMAplane;


