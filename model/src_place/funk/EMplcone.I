/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid cone by axis and
 *  diameters. These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMAcone;

#define BASE            0
#define HEIGHT          1 
#define DIRECTION       2
#define BASE_DIAMETER   3
#define HEIGHT_DIAMETER 4

#include "REsfsolid.h"
#include "ma2ptdis.h"
#include "bsnorvec.h"

extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMAcone_class_id, 
                 OPP_EMScone_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_cone_by_axis_and_diams ( msg, 
                                         opts, 
                                         mdenv, 
                                         level, 
                                         disp, 
                                         dispattr, 
                                         objname,
                                         axis,
                                         diameters, 
                                         is_solid,
                                         cneobj )  
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * axis;
    struct EMSvalue_info    * diameters;
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
    struct EMSobject_info   parobjs[5];
    GRspacenum              constros;
    IGRint                  i;
    IGRpoint                loc_axis[2];
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
        om_msg = EMgetparpt_numeric (&msg_loc, &axis[i], loc_axis[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    if (opts & EMSasconst_notassociative)
    {
        IGRdouble   loc_radii[2];
        
        for (i=0; i<2; ++i)
        {
            om_msg = EMgetparval_numeric (&msg_loc, &diameters[i], &loc_radii[i]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
            loc_radii[i] /= 2.0;
        }

        om_msg = om$construct( classid =  OPP_EMScone_class_id,
                                msg = message EMScone.EMcone
                                            ( (IGRint *) &msg_loc,
                                              &vgcnstr,
                                              loc_axis,
                                              loc_radii ),
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
        struct EMSvector_info   direction;
        struct EMSvalue_info    height;

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = loc_axis[1][i] - loc_axis[0][i];
        BSnorvec (&msg_loc, direction.vec);

        height.type = EMSdatainfo_numeric;
        MA2ptdis (&msg_loc, loc_axis[0], loc_axis[1], &height.val);
        
        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &axis[0], &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &height, &parobjs[HEIGHT]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[DIRECTION]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &diameters[0], &parobjs[BASE_DIAMETER]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &diameters[1], &parobjs[HEIGHT_DIAMETER]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMAcone_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = cneobj);
        if (1 & om_msg)
        {
          current_creator = *cneobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                              ( &msg_loc,
                                                opts & ~EMSasconst_recompute,
                                                5,
                                                parobjs, 
                                                (is_solid) ?
                                                EMS_ASsolid_cone_by_axis_and_diameters :
                                                EMS_AScone_by_axis_and_diameters,
                                                0, 
                                                NULL, 
                                                &vgcnstr),
                           senderid = NULL_OBJID,
                           targetid = *cneobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMplace_cone_by_axis_and_dias");
    return (om_msg);
}

end implementation EMAcone;


