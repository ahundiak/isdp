/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface box by four points.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 *  Sudha   06/30/93     Modified for BSprototypes ansification
 *  Jack :  07/21/93  :  Modified to create a composite surface of 
 *                       projection for the surface box. (Phoenix)
 */
class implementation EMAgenbs;

#include "REpolyhdrn.h"
#include "REgenbs.h"
#include "ma2ptdis.h"
#include "bsnorvec.h"
#include "OMmacros.h"

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

extern GRclassid OPP_EMAgenbs_class_id, OPP_EMSgenbs_class_id,
                 OPP_EMSblock_class_id, OPP_EMSproject_class_id;

extern IGRlong EMcreate_composite_curve();

from EMSblock   import EMboxbyhwd;
from EMSproject import EMplace_surface_of_projection;

IGRlong EMplace_box_by_4pts ( msg,
                              opts, 
                              mdenv, 
                              level, 
                              disp, 
                              dispattr, 
                              objname,
                              points,
                              is_solid,
                              boxobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * points;
    IGRboolean                is_solid;
    GRobjid                 * boxobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRpoint                loc_points[4];
    IGRshort                mattyp;
    IGRlong                 msg_loc, om_msg = OM_S_SUCCESS, stat_func;
    IGRdouble             * mat;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[7];
    GRspacenum              constros;
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRlong                 EMgetparptobj(), EMgetparvalobj();
    extern OM_S_OBJID       current_creator;
    struct GRid             comp_cv_obj;
    IGRpoint                temp_points[4];
    IGRint                  ii = 0;
    GRobjid                 tmpobj = NULL_OBJID;

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
        if (is_solid)
        {
            IGRdouble   height_vc[3], width_vc[3], depth_vc[3];
 
            for (i=0; i<3; ++i)
            {
                height_vc[i] = loc_points[1][i] - loc_points[0][i];
                width_vc [i] = loc_points[2][i] - loc_points[0][i];
                depth_vc [i] = loc_points[3][i] - loc_points[0][i];
            }

            om_msg = om$construct( classid =  OPP_EMSblock_class_id,
                                   p_objid = boxobj,
                                   osnum = constros );  

            if (om_msg & 1)
            {
                current_creator = *boxobj;
                om_msg = om$send ( msg = message EMSblock.EMboxbyhwd
                                            ( &msg_loc,
                                              &vgcnstr,
                                              (IGRdouble * )loc_points,
                                              height_vc,
                                              width_vc,
                                              depth_vc ),
                                   senderid = NULL_OBJID,
                                   targetid = *boxobj,
                                   targetos = constros );
                current_creator = NULL_OBJID;
            }

            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else
        {

           /*
            * load up the points for the composite curve in the correct order.
            * we have the first, second, and fourth, need to calculate the third
            */
           OM_BLOCK_MOVE(loc_points[0], temp_points[0], sizeof(IGRpoint));
           OM_BLOCK_MOVE(loc_points[1], temp_points[1], sizeof(IGRpoint));
           OM_BLOCK_MOVE(loc_points[2], temp_points[3], sizeof(IGRpoint));           
 
           for( ii=0; ii < 3; ii++)
            {
              temp_points[2][ii] = (loc_points[2][ii] - loc_points[0][ii]) +
                                    loc_points[1][ii];
            }


           /*
            * call function that returns a composite curve when given a set of
            * points
            */
            om_msg = EMcreate_composite_curve(&msg_loc,
                                               mdenv,
                                               4,
                                               temp_points,
                                               TRUE,
                                               constros,
                                              &comp_cv_obj);
            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

           /*
            * create a composite surface of projection from the comp.
            * curve.  this will represent our box that is open at 2 ends.
            */
           om_msg = om$construct( classid =  OPP_EMSproject_class_id,
                 msg = message EMSproject.EMplace_surface_of_projection(
                                             &vgcnstr,
                                             &comp_cv_obj,
                                              mdenv,
                                              NULL,
                                              NULL,
                                              loc_points[0],
                                              loc_points[3],
                                              TRUE,
                                              boxobj ),
                                p_objid = &tmpobj,
                                osnum = constros );

         /*
          * delete the composite curve, we are done with it.
          */
         om_msg = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                            mdenv),
                      senderid = NULL_OBJID,
                      targetos = comp_cv_obj.osnum,
                      targetid = comp_cv_obj.objid);
         EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

         comp_cv_obj.objid = NULL;  /* deleted */


        }
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

        classid = is_solid ? OPP_EMSblock_class_id : OPP_EMAgenbs_class_id,
        om_msg = om$construct ( classid = classid, 
                                osnum = constros, 
                                p_objid = boxobj );

        if (om_msg & 1)
        {
            current_creator = *boxobj;
            om_msg = om$send ( msg = message EMSassoc.EMinit_associative 
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  7, 
                                                  parobjs, 
                                                  (is_solid) ?
                                                  EMS_ASsolid_box_by_4pts :
                                                  EMS_ASbox_by_4pts,
                                                  0, 
                                                  NULL, 
                                                  &vgcnstr ),
                               senderid = NULL_OBJID,
                               targetid = *boxobj,
                               targetos = constros );

            current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_box_by_4pts");
        return (om_msg);
}

end implementation EMAgenbs;
