/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid ellipsoid.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  05/01/91
 */
class implementation EMAelpsoid;

#include "REsfsolid.h"

extern GRclassid OPP_EMSsfsolid_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_ellipsoid ( msg, 
                            opts, 
                            mdenv, 
                            level, 
                            disp, 
                            dispattr, 
                            objname,
                            type,
                            center_focus1,
                            major_focus2, 
                            radius_axis_length,
                            is_solid,
                            elpobj )  
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    IGRint                    type;
    struct EMSpoint_info    * center_focus1;
    struct EMSpoint_info    * major_focus2;
    struct EMSvalue_info    * radius_axis_length;
    IGRboolean                is_solid;
    GRobjid                 * elpobj;
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
    struct EMSobject_info   parobjs[3];
    GRspacenum              constros;
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRlong                 EMgetparptobj(), EMgetparvalobj();
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
        IGRpoint            loc_center_focus1, loc_major_focus2;
        IGRdouble           loc_radius_axis_length;
        struct EMesellpsd1  method1, * p_method1;
        struct EMesellpsd2  method2, * p_method2;
        
        om_msg = EMgetparpt_numeric (&msg_loc, center_focus1, loc_center_focus1);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparpt_numeric (&msg_loc, major_focus2, loc_major_focus2);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_numeric (&msg_loc, radius_axis_length, &loc_radius_axis_length);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
 
        switch (type)
        {
        case EMS_ASellipsoid_by_center_axis_radius:
            memcpy (method1.center, loc_center_focus1, sizeof(IGRpoint));
            for (i=0; i<3; ++i) 
                method1.semi_axis[i] = loc_major_focus2[i] - loc_center_focus1[i];
            method1.radius = loc_radius_axis_length;
            p_method1 = &method1;
            p_method2 = NULL;
            break;

        case EMS_ASellipsoid_by_foci_axis_len:
            memcpy (method2.focus0, loc_center_focus1, sizeof(IGRpoint));
            memcpy (method2.focus1, loc_major_focus2, sizeof(IGRpoint));
            method2.major_axis_length = loc_radius_axis_length;
            p_method1 = NULL;
            p_method2 = &method2;
            break;

        default:
            msg_loc = MSINARG;
            om_msg = OM_E_ABORT;
        }

        if (om_msg & msg_loc & 1)
        {
            om_msg = om$construct( classid =  OPP_EMSelpsoid_class_id,
                                   msg = message EMSelpsoid.EMelpsd
                                                        ( p_method1,
                                                          p_method2,
                                                          &vgcnstr,
                                                          &msg_loc ),
                                   p_objid = elpobj,
                                   osnum = constros );  
        }
        
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
                                                          elpobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }
            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *elpobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *elpobj = solidobj;
        }
    }
    else
    {
        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, center_focus1, &parobjs[0]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, major_focus2, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, radius_axis_length, &parobjs[2]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (is_solid)
        {
            classid = OPP_EMSsfsolid_class_id;
            type = (type == EMS_ASellipsoid_by_center_axis_radius) ?
                   EMS_ASsolid_ellipsoid_by_center_axis_radius :
                   EMS_ASsolid_ellipsoid_by_foci_axis_len;
        }
        else classid = OPP_EMAelpsoid_class_id;

        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = elpobj);
        if (1 & om_msg)
        {
          current_creator = *elpobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  3,
                                                  parobjs, 
                                                  type,
                                                  0, 
                                                  NULL, 
                                                  &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *elpobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMplace_ellipsoid");
    return (om_msg);
}

end implementation EMAelpsoid;


