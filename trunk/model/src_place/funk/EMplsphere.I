/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid sphere by center
 *  point and radius. These can be placed as associative or non-associative 
 *  entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMAsphere;

#define CENTER 0
#define RADIUS 1

#include "REsfsolid.h"

extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMAsphere_class_id, 
                 OPP_EMSsphere_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_sphere_by_center_and_radius ( msg, 
                                              opts, 
                                              mdenv, 
                                              level, 
                                              disp, 
                                              dispattr, 
                                              objname,
                                              center, 
                                              radius, 
                                              is_solid,
                                              sphobj )  
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * center;
    struct EMSvalue_info    * radius;
    IGRboolean                is_solid;
    GRobjid                 * sphobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRdouble               loc_center[3], loc_radius; 
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    GRobjid                 solidobj;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[2];
    GRspacenum              constros;
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
        om_msg = EMgetparpt_numeric (&msg_loc, center, loc_center);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        om_msg = EMgetparval_numeric (&msg_loc, radius, &loc_radius);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        /*
         * Construct the sphere. If a solid needs to be constructed, do
         * so by creating an sfsolid and capping it.
         */
        om_msg = om$construct( classid =  OPP_EMSsphere_class_id,
                                msg = message EMSsphere.EMsphere_by_center_radius
                                            ( &vgcnstr,
                                              loc_center,
                                              loc_radius ),
                                p_objid = sphobj,
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
                                                          sphobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *sphobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *sphobj = solidobj;
        }
    }
    else
    {
        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, center, &parobjs[CENTER]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        om_msg = EMgetparval_object (&msg_loc, constros, NULL, radius, &parobjs[RADIUS]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMAsphere_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = sphobj);
        if (1 & om_msg)
        {
          current_creator = *sphobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                                         ( &msg_loc,
                                           opts & ~EMSasconst_recompute,
                                           2,
                                           parobjs, 
                                           (is_solid) ?
                                           EMS_ASsolid_sphere_by_center_and_radius :
                                           EMS_ASsphere_by_center_and_radius,
                                           0, 
                                           NULL, 
                                           &vgcnstr ),
                           senderid = NULL_OBJID,
                           targetid = *sphobj,
                           targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_sphere_by_center_and_radius");
        return (om_msg);
}

end implementation EMAsphere;
