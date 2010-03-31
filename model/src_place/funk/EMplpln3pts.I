/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a plane by three points.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMAplane;

#include "ma2ptdis.h"
#include "bsnorvec.h"


#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4

IGRlong EMplace_plane_by_3pts  ( msg, 
                                 opts, 
                                 mdenv, 
                                 level,
                                 disp,
                                 dispattr,
                                 objname,
                                 points,
                                 is_parallelogram,
                                 plnobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * points;
    IGRboolean                is_parallelogram;
    GRobjid                 * plnobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[5];
    struct EMSpoint_info    tmp;
    GRspacenum              constros;
    IGRint                  i, j, k;
    IGRpoint                loc_points[3];
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

    if (!(opts & EMSasconst_notassociative) && is_parallelogram)
    {
        tmp = points[0];
        points[0] = points[1];
        points[1] = tmp;
    }

    for (i=0; i<3; ++i)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, &points[i], loc_points[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }
    if (opts & EMSasconst_notassociative)
    {
        /*
         * Construct the plane.
         */
        om_msg = om$construct ( classid = OPP_EMSplane_class_id,
                                 msg = message EMSplane.EMplane 
                                                        ( (IGRint *) &msg_loc,
                                                          &vgcnstr,
                                                          loc_points,
                                                          is_parallelogram ),
                                 p_objid = plnobj,
                                 osnum = constros );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        struct EMSvector_info vector[2];
        struct EMSvalue_info  value[2];


        for (i=0, j=1; i<2; ++i, ++j)
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

        for (i=0, j=WIDTH, k=WIDTH_VEC; i<2; ++i, j+=2, k+=2)
        {
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &value[i], &parobjs[j]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

            om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &vector[i], &parobjs[k]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }

        om_msg = om$construct ( classid = OPP_EMAplane_class_id,
                                osnum = constros, 
                                p_objid = plnobj );

        if (om_msg & 1)
        {
            om_msg = om$send ( msg = message EMSassoc.EMinit_associative 
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  5, 
                                                  parobjs, 
                                                  (is_parallelogram) ? 
                                                  EMS_ASparallelogram_by_3pts :
                                                  EMS_ASplane_by_3pts, 
                                                  0,
                                                  NULL, 
                                                  &vgcnstr ),
                              senderid = NULL_OBJID,
                              targetid = *plnobj,
                              targetos = constros );
        
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_plane_by_3pts");
        return (om_msg);
}

end implementation EMAplane;
