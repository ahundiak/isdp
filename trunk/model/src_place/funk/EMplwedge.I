/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a solid right angle wedge.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/10/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMSwedge;

#include "REpolyhdrn.h"
#include "ma2ptdis.h"
#include "bserr.h"
#include "bsnorvec.h"

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

IGRlong EMplace_right_angle_wedge ( msg,
                                    opts, 
                                    mdenv, 
                                    level, 
                                    disp, 
                                    dispattr, 
                                    objname,
                                    points,
                                    wdgobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * points;
    GRobjid                 * wdgobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRpoint                loc_points[4];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg = OM_S_SUCCESS;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[4];
    GRspacenum              constros;
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
    IGRlong                 EMgetparptobj(), EMgetparvalobj();
    extern OM_S_OBJID       current_creator;

    *msg = EMS_S_Success;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    for (i=0; i<4; ++i)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, &points[i], loc_points[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    if (opts & EMSasconst_notassociative)
    {
        IGRdouble   height_vc[3], width_vc[3], depth_vc[3];

        for (i=0; i<3; ++i)
        {
            height_vc[i] = loc_points[1][i] - loc_points[0][i];
            width_vc [i] = loc_points[2][i] - loc_points[0][i];
            depth_vc [i] = loc_points[3][i] - loc_points[0][i];
        }

        om_msg = om$construct(classid =  OPP_EMSwedge_class_id,
                              p_objid = wdgobj,
                              osnum = constros);  
        if (1 & om_msg)
        {
          current_creator = *wdgobj;
          om_msg = om$send(msg = message EMSwedge.EMrtwedge
                                            ( &msg_loc,
                                              &vgcnstr,
                                              loc_points[0],
                                              height_vc,
                                              width_vc,
                                              depth_vc ),
                           senderid = NULL_OBJID,
                           targetid = *wdgobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }                           
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        IGRint                j, k;
        struct EMSvector_info vector[3];
        struct EMSvalue_info  value[3];

        for (i=0, j=1; i<3; ++i, ++j)
        {
            vector[i].type = EMSdatainfo_numeric;
            for (k=0; k<3; ++k)
                vector[i].vec[k] = loc_points[j][k] - loc_points[0][k];
            BSnorvec (&msg_loc, vector[i].vec);

            value[i].type = EMSdatainfo_numeric;
            MA2ptdis (&msg_loc, loc_points[0], loc_points[j], &value[i].val);
        }

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &points[0], &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        for (i=0, j=WIDTH, k=WIDTH_VEC; i<3; ++i, j+=2, k+=2)
        {
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &value[i], &parobjs[j]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

            om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &vector[i], &parobjs[k]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }

        om_msg = om$construct(classid = OPP_EMSwedge_class_id,
                              osnum = constros, 
                              p_objid = wdgobj);
        if (1 & om_msg)
        {
          current_creator = *wdgobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                      ( &msg_loc,
                        opts & ~EMSasconst_recompute,
                        7, 
                        parobjs, 
                        convert_into_plane ? EMS_ASsolid_right_angle_wedge1
                                            : EMS_ASsolid_right_angle_wedge, 
                        0, 
                        NULL, 
                        &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *wdgobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *wdgobj, constros);

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_right_angle_wedge");
        return (om_msg);
}

end implementation EMSwedge;
