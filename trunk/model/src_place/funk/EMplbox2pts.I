/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a solid box by two points.
 *  The resultant box will be have sides aligned with the design cube.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/10/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMSblock;

#include "REpolyhdrn.h"
#include "bserr.h"
#include "bsnorvec.h"

#define BASE        0
#define WIDTH       1
#define HEIGHT      2
#define LENGTH      3
#define DIRECTION   4

IGRlong EMplace_box_by_2pts ( msg,
                              opts, 
                              mdenv, 
                              level, 
                              disp, 
                              dispattr, 
                              objname,
                              points,
                              boxobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * points;
    GRobjid                 * boxobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRpoint                loc_points[2];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[5];
    GRspacenum              constros;
    IGRint                  i, j;
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

    for (i=0; i<2; ++i)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, &points[i], loc_points[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    if (opts & EMSasconst_notassociative)
    {
        om_msg = om$construct(classid = OPP_EMSblock_class_id,
                              p_objid = boxobj,
                              osnum = constros);  
        if (1 & om_msg)
        {
          current_creator = *boxobj;
          om_msg = om$send(msg = message EMSblock.EMboxby2pt
                                            ( &msg_loc,
                                              &vgcnstr,
                                              loc_points[0],
                                              loc_points[1] ),
                           senderid = NULL_OBJID,
                           targetid = *boxobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }                           
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        struct EMSvector_info direction;
        struct EMSvalue_info  value[3];

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
        {
            value[i].type = EMSdatainfo_numeric;
            value[i].val = direction.vec[i] = loc_points[1][i] - loc_points[0][i];
            if (value[i].val < 0.0) value[i].val *= -1;
        }
        BSnorvec(&msg_loc, direction.vec);

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &points[0], &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        for (i=0, j=WIDTH; i<3; ++i, ++j)
        {
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &value[i], &parobjs[j]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[DIRECTION]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = om$construct(classid = OPP_EMSblock_class_id,
                              osnum = constros, 
                              p_objid = boxobj);
        if (1 & om_msg)
        {
          current_creator = *boxobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  5, 
                                                  parobjs, 
                                                  EMS_ASsolid_box_by_2pts, 
                                                  0, 
                                                  NULL, 
                                                  &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *boxobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_box_by_2pts");
        return (om_msg);
}

end implementation EMSblock;
