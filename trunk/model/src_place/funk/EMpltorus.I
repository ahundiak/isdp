/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid torus by axis, center
 *  and radius. These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/12/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMAtorus;

#include "EMSstruct.h"
#include "REsfsolid.h"
#include "bsnorvec.h"

extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMAtorus_class_id,
                 OPP_EMStorus_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_torus_by_axis_center_and_radius
                                       ( msg, 
                                         opts, 
                                         mdenv, 
                                         level, 
                                         disp, 
                                         dispattr, 
                                         objname,
                                         axis,
                                         center,
                                         radius, 
                                         is_solid,
                                         trsobj )  
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * axis;
    struct EMSpoint_info    * center;
    struct EMSvalue_info    * radius;
    IGRboolean                is_solid;
    GRobjid                 * trsobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    GRobjid                 solidobj;
    GRclassid               classid;
    IGRpoint                loc_axis[2];
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[4];
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

    for (i=0; i<2; ++i)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, &axis[i], loc_axis[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    if (opts & EMSasconst_notassociative)
    {
        IGRpoint         loc_center;
        struct EMSradius loc_radius;
        
        om_msg = EMgetparpt_numeric (&msg_loc, center, loc_center);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_numeric (&msg_loc, radius, &loc_radius.input.value);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        loc_radius.select = 0;

        om_msg = om$construct( classid =  OPP_EMStorus_class_id,
                               msg = message EMStorus.EMtorus_by_axis_center_rad
                                            ( &vgcnstr,
                                              loc_axis[0],
                                              loc_axis[1],
                                              loc_center,
                                              &loc_radius ),
                                p_objid = trsobj,
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
                                                          trsobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *trsobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *trsobj = solidobj;
        }
    }
    else
    {
        struct EMSvector_info   direction;

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &axis[0], &parobjs[0]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = loc_axis[1][i] - loc_axis[0][i];
        BSnorvec (&msg_loc, direction.vec);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, center, &parobjs[2]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, radius, &parobjs[3]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMAtorus_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = trsobj);
        if (1 & om_msg)
        {
          current_creator = *trsobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                    ( &msg_loc,
                                      opts & ~EMSasconst_recompute,
                                      4,
                                      parobjs, 
                                      (is_solid) ?
                                      EMS_ASsolid_torus_by_axis_center_and_radius :
                                      EMS_AStorus_by_axis_center_and_radius,
                                      0, 
                                      NULL, 
                                      &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *trsobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMS_AStorus_by_axis_center_and_radius");
    return (om_msg);
}

end implementation EMAtorus;
