/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface/solid of projection. These
 *  can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 */
class implementation EMSswcompsf;

#define CURVE       0
#define HEIGHT      1
#define DIRECTION   2

#include "REsfsolid.h"
#include "ma2ptdis.h"
#include "bserr.h"
#include "bsnorvec.h"

extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMSproject_class_id, 
                 OPP_EMSprjcompsf_class_id;

from EMSproject import EMplace_surface_of_projection;
from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_surf_of_projection ( msg, 
                                     opts, 
                                     mdenv, 
                                     level, 
                                     disp, 
                                     dispattr, 
                                     objname,
                                     curve, 
                                     base, 
                                     height, 
                                     is_solid,
                                     prjobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * curve;
    struct EMSpoint_info    * base, * height;
    IGRboolean                is_solid;
    GRobjid                 * prjobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRpoint                loc_base, loc_height;
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    IGRint                  i;
    GRobjid                 solidobj,tmpobj;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[3];
    GRspacenum              constros;
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

    om_msg = EMgetparpt_numeric (&msg_loc, base, loc_base);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
    om_msg = EMgetparpt_numeric (&msg_loc, height, loc_height);
    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    if (opts & EMSasconst_notassociative)
    {
        om_msg = om$construct( classid =  OPP_EMSproject_class_id,
                                msg = message EMSproject.EMplace_surface_of_projection(
                                              &vgcnstr,
                                              &curve->grid,
                                              &curve->env,
                                              NULL,
                                              NULL,
                                              loc_base,
                                              loc_height,
                                              TRUE,
                                              prjobj ),
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
                                                          prjobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *prjobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *prjobj = solidobj;
        }
    }
    else
    {
        struct EMSvector_info   direction;
        struct EMSvalue_info    height;

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = loc_height[i] - loc_base[i];
        BSnorvec (&msg_loc, direction.vec);

        height.type = EMSdatainfo_numeric;
        MA2ptdis (&msg_loc, loc_base, loc_height, &height.val);

        parobjs[CURVE] = *curve;

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &height, &parobjs[HEIGHT]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction, &parobjs[DIRECTION]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMSprjcompsf_class_id;
        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = prjobj);
        if (1 & om_msg)
        {
          current_creator = *prjobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                     ( &msg_loc,
                       opts & ~EMSasconst_recompute,
                       3, 
                       parobjs, 
                       is_solid ?
                       (convert_into_plane ? EMS_ASsolid_surface_of_projection1
                                          : EMS_ASsolid_surface_of_projection)
                                :
                       (convert_into_plane ? EMS_ASsurface_of_projection1
                                          : EMS_ASsurface_of_projection),
                       0, 
                       NULL, 
                       &vgcnstr ),
                      senderid = NULL_OBJID,
                      targetid = *prjobj,
                      targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *prjobj, constros);

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_surf_of_projection");
        return (om_msg);
}

end implementation EMSswcompsf;
