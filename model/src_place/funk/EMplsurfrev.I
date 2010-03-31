/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid of revolution. These
 *  can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMSswcompsf;

#define CURVE       0
#define BASE        1
#define DIRECTION   2
#define START       3
#define SWEEP       4

#include "REsfsolid.h"
#include "bserr.h"
#include "bsnorvec.h"

extern GRclassid OPP_EMSrevol_class_id, OPP_EMSsfsolid_class_id, 
                 OPP_EMSrevcompsf_class_id;

from EMSrevol   import EMrevolve_curve;
from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_surf_of_revolution ( msg, 
                                     opts, 
                                     mdenv, 
                                     level, 
                                     disp, 
                                     dispattr, 
                                     objname,
                                     curve, 
                                     axis, 
                                     start, 
                                     sweep,
                                     is_solid,
                                     revobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * curve;
    struct EMSpoint_info    * axis;
    struct EMSvalue_info    * start, * sweep;
    IGRboolean                is_solid;
    GRobjid                 * revobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    GRobjid                 solidobj,tmpobj;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[5];
    GRspacenum              constros;
    IGRpoint                loc_axis[2];
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
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
        IGRlong             full_revolution;
        struct GRlc_info    lc_info;
        IGRdouble           loc_sweep, loc_start;

        lc_info.located_obj = curve->grid;
        lc_info.module_info = curve->env;

        om_msg = EMgetparval_numeric (&msg_loc, start, &loc_start);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        om_msg = EMgetparval_numeric (&msg_loc, sweep, &loc_sweep);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        full_revolution = (loc_sweep == 360.0);

        /*
         * Construct the cylinder. If a solid needs to be constructed, do
         * so by creating an sfsolid and capping it.
         */
        msg_loc = om$construct ( classid = OPP_EMSrevol_class_id,
                                 msg = message EMSrevol.EMrevolve_curve
                                                ( &vgcnstr,
                                                  &lc_info,
                                                  NULL,   
                                                  loc_axis,
                                                  loc_start,
                                                  loc_sweep,
                                                  full_revolution,
                                                  TRUE,   
                                                  revobj,
                                                  (IGRint *) &msg_loc ),              
                                 p_objid = &tmpobj,
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
                                                          revobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }
            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc, vgcnstr.env_info),
                         targetid = *revobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *revobj = solidobj;
        }
    }
    else
    {
        struct EMSvector_info direction;

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = loc_axis[1][i] - loc_axis[0][i];
        BSnorvec (&msg_loc, direction.vec);

        parobjs[CURVE] = *curve;

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &axis[0], &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[DIRECTION]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, start, &parobjs[START]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        om_msg = EMgetparval_object (&msg_loc, constros, NULL, sweep, &parobjs[SWEEP]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMSrevcompsf_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = revobj);
        if (1 & om_msg)
        {
          current_creator = *revobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative           
                       ( &msg_loc, 
                       opts & ~EMSasconst_recompute,
                       5, 
                       parobjs, 
                       is_solid ?
                       (convert_into_plane ? EMS_ASsolid_surface_of_revolution1
                                          : EMS_ASsolid_surface_of_revolution)
                                :
                       (convert_into_plane ? EMS_ASsurface_of_revolution1
                                          : EMS_ASsurface_of_revolution),
                       0, 
                       NULL, 
                       &vgcnstr ),
                      senderid = NULL_OBJID,
                      targetid = *revobj,
                      targetos = constros);
          current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *revobj, constros);

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_surf_of_revolution");
        return (om_msg);
}

end implementation EMSswcompsf;
