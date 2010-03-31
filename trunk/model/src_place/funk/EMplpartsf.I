/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a fillet between 2 sufaces. These
 *  can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMSgencompsf;

#include "DIdef.h"
#include "EMSfillet.h"
#include "OMmacros.h"

from EMSsubbs import EMpartsf;

IGRlong EMplace_partial_surface
                       ( msg, 
                         opts, 
                         mdenv, 
                         level, 
                         disp, 
                         dispattr, 
                         objname,
                         surface,
                         start_point,
                         end_point,
                         mid_point,
                         trimming_required,
                         prtobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * surface;
    struct EMSpoint_info    * start_point;
    struct EMSpoint_info    * end_point;
    struct EMSpoint_info    * mid_point;
    IGRboolean                trimming_required;
    GRobjid                 * prtobj;
{
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg, stat_DI;
    IGRdouble             * mat, radval;
    GRobjid                 filobjs;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    IGRchar                 loc_name[DI_PATH_MAX];
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[4];
    GRspacenum              constros;
    IGRint                  i;
    struct GRprops          geomprops;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
    IGRlong                 EMgetparptobj(), EMgetparvalobj();
    extern OM_S_OBJID       current_creator;
        struct GRevent          loc_points[3];
        struct GRlc_info        loc_surface;
        struct EMSpoint_info    loc_mid_point;
        IGRint  numobjs;
        IGRlong as_partial;


    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    om_msg = om$send ( msg = message GRvg.GRgeomprops ( &msg_loc,
                                                        &mattyp,
                                                        mat,
                                                        &geomprops ),
                       senderid = NULL_OBJID,
                       targetid = surface->grid.objid,
                       targetos = surface->grid.osnum );

    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    if (geomprops.phy_closed && !mid_point)
    {
        *msg = MSINARG;
        om_msg = OM_E_ABORT;
        goto ret_end;
    }


        loc_surface.module_info = surface->env;
        loc_surface.located_obj = surface->grid;
        



/************* start fix for the command - Nirmal */

    if (opts & EMSasconst_notassociative)
    {

        om_msg = om$send ( msg = message EMSsubbs.EMpartsf 
                             ( &msg_loc,
                               &vgcnstr,
                          &start_point->ptevent->located_object[0].geom_parms.u,
                          &mid_point->ptevent->located_object[0].geom_parms.u,
                          &end_point->ptevent->located_object[0].geom_parms.u,
                               2,
                               prtobj,
                               NULL,
                               trimming_required,
                               TRUE ),
                           senderid = NULL_OBJID,
                           targetid = surface->grid.objid,
                           targetos = surface->grid.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
        numobjs = 3;
        parobjs[0] = *surface;

       om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, start_point,                &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, end_point,                  &parobjs[2]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        if(mid_point)
        {
           numobjs = 4;
           om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, 
                     mid_point, &parobjs[3]);
           EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
/************* end fix for the command - Nirmal */

        as_partial = trimming_required;

        om_msg = om$construct(classid = OPP_EMSgencompsf_class_id,
                              osnum = constros, 
                              p_objid = prtobj);
        if (1 & om_msg)
        {
          current_creator = *prtobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                   ( &msg_loc,
                     opts & ~EMSasconst_recompute,
                     numobjs, 
                     parobjs, 
                     (convert_into_plane ? EMS_ASextracted_partial_surface1
                                         : EMS_ASextracted_partial_surface),
                     sizeof(IGRlong), 
                     (IGRchar *)&as_partial,
                     &vgcnstr ),
                     senderid = NULL_OBJID,
                     targetid = *prtobj,
                     targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *prtobj, constros);

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_partial_surface");
        return (om_msg);
}



end implementation EMSgencompsf;

