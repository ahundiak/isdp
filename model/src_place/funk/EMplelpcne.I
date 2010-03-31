/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid cone by axis and
 *  radii. These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMAelpcone;

extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMAelpcyl_class_id;

from EMSsfsolid import EMcap_thyself;

#include "REsfsolid.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

#define BASE            0
#define HEIGHT          1
#define HEIGHT_DIR      2
#define BASE_MAJOR      3
#define BASE_MINOR      4
#define BASE_MAJOR_DIR  5
#define HEIGHT_MAJOR    6

IGRlong EMplace_elliptical_cone ( msg, 
                                  opts, 
                                  mdenv, 
                                  level, 
                                  disp, 
                                  dispattr, 
                                  objname,
                                  base,
                                  height,
                                  base_major,
                                  base_minor,
                                  height_major,
                                  is_solid,
                                  cneobj )  
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * base;
    struct EMSpoint_info    * height;
    struct EMSpoint_info    * base_major;
    struct EMSpoint_info    * base_minor;
    struct EMSpoint_info    * height_major;
    IGRboolean                is_solid;
    GRobjid                 * cneobj;
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
    struct EMSobject_info   parobjs[7];
    GRspacenum              constros;
    IGRint                  i, type;
    IGRpoint                loc_points[5];
    IGRint                  is_cone;
    IGRdouble               base_major_val, base_minor_val, height_major_val;
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

    om_msg = EMgetparpt_numeric (&msg_loc, base, loc_points[0]);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    om_msg = EMgetparpt_numeric (&msg_loc, height, loc_points[1]);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    om_msg = EMgetparpt_numeric (&msg_loc, base_major, loc_points[2]);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    om_msg = EMgetparpt_numeric (&msg_loc, base_minor, loc_points[3]);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    base_major_val = BSdistptpt (&msg_loc, loc_points[0], loc_points[2]);
    base_minor_val = BSdistptpt (&msg_loc, loc_points[0], loc_points[3]);

    if (is_cone = (height_major) ? TRUE : FALSE)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, height_major, loc_points[4]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        height_major_val = BSdistptpt (&msg_loc, loc_points[1], loc_points[4]);
    }

    if (opts & EMSasconst_notassociative)
    {
        IGRvector   height_vc, major_vc, minor_vc;
        IGRdouble   scale;

        if (is_cone)
        {
            scale = (base_major_val == 0.0) ? 1.0 : height_major_val/base_major_val;
        }
        else scale = 1.0;

        for (i=0; i<3; ++i)
        {
            major_vc[i]  = loc_points[2][i] - loc_points[0][i];
            minor_vc[i]  = loc_points[3][i] - loc_points[0][i];
            height_vc[i] = loc_points[1][i] - loc_points[0][i];
        }

        om_msg = om$construct( classid = (is_cone) ? 
                               OPP_EMSelpcone_class_id : OPP_EMSelpcyl_class_id,
                               msg = message EMSelpcone.EMconstruct_elliptical_cone
                                            ( &msg_loc,
                                              &vgcnstr,
                                              loc_points[0],
                                              major_vc,
                                              minor_vc,
                                              height_vc,
                                              scale ),
                               p_objid = cneobj,
                               osnum = constros );  

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
                                                          cneobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }                               

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *cneobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *cneobj = solidobj;
        }
    }
    else
    {
        IGRint                  numobjs = 6;
        struct EMSvector_info   direction, b_major_vec;
        struct EMSvalue_info    height, b_major, b_minor, h_major;

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = loc_points[1][i] - loc_points[0][i];
        BSnorvec (&msg_loc, direction.vec);

        height.type = EMSdatainfo_numeric;
        height.val = BSdistptpt (&msg_loc, loc_points[0], loc_points[1]);

        b_major.type = b_minor.type = EMSdatainfo_numeric;
        b_major.val = base_major_val;
        b_minor.val = base_minor_val;

        b_major_vec.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            b_major_vec.vec[i] = loc_points[2][i] - loc_points[0][i];
        BSnorvec (&msg_loc, b_major_vec.vec);

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, base, &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &height, &parobjs[HEIGHT]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[HEIGHT_DIR]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &b_major, &parobjs[BASE_MAJOR]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &b_minor, &parobjs[BASE_MINOR]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &b_major_vec, &parobjs[BASE_MAJOR_DIR]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (is_cone)
        {
            h_major.type = EMSdatainfo_numeric;
            h_major.val = height_major_val;

            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &h_major, &parobjs[HEIGHT_MAJOR]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

            numobjs = 7;

            if (is_solid)
            {
                classid = OPP_EMSsfsolid_class_id;
                type = EMS_ASsolid_right_elliptical_cone;
            }
            else
            {
                classid = OPP_EMAelpcone_class_id;
                type = EMS_ASright_elliptical_cone;
            }
        }
        else
        {
            if (is_solid)
            {
                classid = OPP_EMSsfsolid_class_id;
                type = EMS_ASsolid_right_elliptical_cylinder;
            }
            else
            {
                classid = OPP_EMAelpcyl_class_id;
                type = EMS_ASright_elliptical_cylinder;
            }
        }

        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = cneobj);
        if (1 & om_msg)
        {
          current_creator = *cneobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                            ( &msg_loc,
                                              opts & ~EMSasconst_recompute,
                                              numobjs,
                                              parobjs, 
                                              type,
                                              0, 
                                              NULL, 
                                              &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *cneobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMplace_elliptical_cone");
    return (om_msg);
}

end implementation EMAelpcone;


