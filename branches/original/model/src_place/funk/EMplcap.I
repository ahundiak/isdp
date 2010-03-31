/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a solid by capping a surface.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/12/91
 */
class implementation EMSsfsolid;

IGRlong EMplace_solid_by_capping_surface
                             ( msg, 
                               opts, 
                               mdenv, 
                               level,
                               disp,
                               dispattr,
                               objname,
                               surface,
                               solobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * surface;
    GRobjid                 * solobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg, stat_DI;
    IGRdouble             * mat;
    GRobjid                 tmpobj;
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

    if (opts & EMSasconst_notassociative)
    {
        om_msg = om$construct(classid = OPP_EMSsfsolid_class_id,
                              p_objid = solobj,
                              osnum = constros);
        if (1 & om_msg)
        {
          current_creator = *solobj;
          om_msg = om$send(msg = message EMSsfsolid.EMcap_thyself 
                                                      ( &msg_loc, 
                                                        &vgcnstr,
                                                        &surface->grid.objid),
                           senderid = NULL_OBJID,
                           targetid = *solobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }                                                        
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        om_msg = om$construct(classid = OPP_EMSsfsolid_class_id,
                              osnum = constros, 
                              p_objid = solobj);
        if (1 & om_msg)
        {
          current_creator = *solobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                              ( &msg_loc,
                                                opts & ~EMSasconst_recompute,
                                                1,
                                                surface, 
                                                EMS_ASsolid_by_capping_surface,
                                                0, 
                                                NULL, 
                                                &vgcnstr),
                           senderid = NULL_OBJID,
                           targetid = *solobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_solid_by_capping_surface");
        return (om_msg);
}

end implementation EMSsfsolid;


