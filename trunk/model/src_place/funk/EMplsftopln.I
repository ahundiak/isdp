/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface to plane solid of projection.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/15/91
 */
class implementation EMSgensolid;

#include "REgensolid.h"

IGRlong EMplace_surface_to_plane_solid_of_proj 
                             ( msg, 
                               opts, 
                               mdenv, 
                               level,
                               disp,
                               dispattr,
                               objname,
                               surface,
                               projection_vector,
                               plane,
                               solobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * surface;
    struct EMSvector_info   * projection_vector;
    struct EMSplane_info    * plane;
    GRobjid                 * solobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[3];
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
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
        struct GRlc_info lc_info;
        IGRpoint         loc_point;
        IGRvector        loc_vector, loc_normal;
    
        lc_info.module_info = surface->env;
        lc_info.located_obj = surface->grid;

        om_msg = EMgetparvec_numeric (&msg_loc, projection_vector, loc_vector);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (plane->type == EMSdatainfo_numeric)
        {
            memcpy(loc_point, plane->pt, sizeof(IGRpoint));
            memcpy(loc_normal, plane->normal, sizeof(IGRvector));
        }
        else
        {
            struct IGRplane loc_plane;

            loc_plane.point  = loc_point;
            loc_plane.normal = loc_normal;

            om_msg = om$send ( msg = message GRvg.GRdetplane
                                                ( &msg_loc,
                                                  &plane->plobj.env.md_env.matrix_type,
                                                  plane->plobj.env.md_env.matrix,
                                                  &loc_plane ),
                               senderid = NULL_OBJID,
                               targetid = plane->plobj.grid.objid,
                               targetos = plane->plobj.grid.osnum );

            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        }            

        /*
         * Construct the solid of projection.
         */
        om_msg = om$construct(classid = OPP_EMSgensolid_class_id,
                              p_objid = solobj,
                              osnum   = constros);
        if (1 & om_msg)
        {
          current_creator = *solobj;
          om_msg = om$send(msg = message EMSsolid.EMproj_4_bnd_on_plane
                                        ( &msg_loc, 
                                          NULL, 
                                          &lc_info,
                                          loc_point,
                                          loc_normal, 
                                          loc_vector,
                                          &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *solobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        parobjs[0] = *surface;

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, projection_vector, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        /*
         * KLUDGE: There is no support for parameter planes yet!
         */
        if (plane->type == EMSdatainfo_numeric)
        {
            om_msg = OM_E_ABORT;
            *msg = EMS_E_Fail;
            printf("No support for parameter planes yet! Sorry.\n");
            goto ret_end;
        }

        parobjs[2] = plane->plobj;

        om_msg = om$construct(classid = OPP_EMSgensolid_class_id,
                              osnum = constros, 
                              p_objid = solobj);
        if (1 & om_msg)
        {
          current_creator = *solobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                   ( &msg_loc,
                    EMSasconst_no_autodimension,
                    3, 
                    parobjs,
                    convert_into_plane ? EMS_ASsurface_to_plane_solid_of_proj1
                                      : EMS_ASsurface_to_plane_solid_of_proj, 
                    0,
                    NULL, 
                    &vgcnstr ),
                    senderid = NULL_OBJID,
                    targetid = *solobj,
                    targetos = constros);
          current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *solobj, constros);


    ret_end:

     EMWRAPUP (*msg, om_msg, "EMplace_surface_to_plane_solid_of_proj");

     return (om_msg);
}

end implementation EMSgensolid;


