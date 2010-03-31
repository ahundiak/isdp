/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a tube.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMAgenbs;

#include "REgenbs.h"
#include "REsfsolid.h"

extern GRclassid OPP_EMSsfsolid_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_tube ( msg, 
                       opts, 
                       mdenv, 
                       level,
                       disp,
                       dispattr,
                       objname,
                       curve,
                       radius,
                       num_bend_radii,
                       bend_radii,
                       is_solid,
                       tbeobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * curve;
    struct EMSvalue_info    * radius;
    IGRint                    num_bend_radii;
    struct EMSvalue_info    * bend_radii;
    IGRboolean                is_solid;
    GRobjid                 * tbeobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    GRobjid                 solidobj;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRint                  i, j;
    extern OM_S_OBJID       current_creator;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    if (!bend_radii) num_bend_radii = 0;

    if (opts & EMSasconst_notassociative)
    {
        IGRdouble  * loc_radii;

        if (!num_bend_radii || !bend_radii)
        {
            struct IGRbsp_curve * curve_info;
            enum EMSdatatype      curve_type;

            om_msg = EMgetvggeom ( &msg_loc, 
                                   &curve->env.md_env.matrix_type,
                                   curve->env.md_env.matrix,
                                   &curve->grid,
                                   &curve_info,
                                   &curve_type );
            if (curve_info->order > 2)
            {
                om_msg = OM_E_ABORT;
                goto ret_end;
            }

            num_bend_radii = curve_info->num_poles - 2;
        }

        loc_radii = (IGRdouble *)alloca(num_bend_radii * sizeof(IGRdouble));

        if (bend_radii) 
        {
            for (i=0; i<num_bend_radii; ++i) loc_radii[i] = bend_radii[i].val;
        }
        else
        {
            for (i=0; i<num_bend_radii; ++i) loc_radii[i] = radius->val;
        }

        /*
         * Construct the tube.
         */
        om_msg = om$construct ( classid = OPP_EMSgenbs_class_id,
                                osnum = constros,
                                msg = message EMSgenbs.EMplctbesrf
                                               ( &msg_loc, 
                                                 &curve->env,
                                                 curve->grid,
                                                 radius->val,
                                                 loc_radii,
                                                 &vgcnstr ),
                                p_objid = tbeobj );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (is_solid)
        {
            om_msg = om$construct(classid = OPP_EMSsfsolid_class_id,
                                  p_objid = &solidobj,
                                  osnum = constros);
            if (1 & om_msg)
            {
              current_creator = solidobj;
              om_msg = om$send(msg = message EMSsfsolid.EMcap_thyself 
                                                        ( &msg_loc, 
                                                          &vgcnstr,
                                                          tbeobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *tbeobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *tbeobj = solidobj;
        }
    }
    else
    {
        struct EMSobject_info * parobjs;

        parobjs = (struct EMSobject_info *)alloca((num_bend_radii + 2) * sizeof(struct EMSobject_info));

        parobjs[0] = *curve;

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, radius, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        for (i=0, j=2; i<num_bend_radii; ++i, ++j)
        {
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &bend_radii[i], &parobjs[j]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMAgenbs_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = tbeobj);
        if (1 & om_msg)
        {
          current_creator = *tbeobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                            ( &msg_loc,
                                              opts & ~EMSasconst_recompute,
                                              2 + num_bend_radii,
                                              parobjs, 
                                              (is_solid) ?
                                              EMS_ASsolid_tube_by_linear_and_radii : 
                                              EMS_AStube_by_linear_and_radii, 
                                              0,
                                              NULL, 
                                              &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *tbeobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_tube");
        return (om_msg);
}

end implementation EMAgenbs;


