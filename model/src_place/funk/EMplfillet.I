/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a fillet between 2 sufaces. These
 *  can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  Janaka : set 'loc_fillets = NULL' : 10/05/92
 *  DLB  : support txt-w-leader  9/15/91
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMSgencompsf;

#include "DIdef.h"
#include "EMSfillet.h"

from EMSsubbs import EMgetfillet;

IGRlong EMplace_fillet ( msg, 
                         opts, 
                         mdenv, 
                         level, 
                         disp, 
                         dispattr, 
                         objname,
                         surface1,
                         natural_normal1,
                         surface2,
                         natural_normal2,
                         start_point,
                         start_radius,
                         end_point,
                         end_radius,
                         variation_curve,
                         rho_value,
                         is_chamfer,
                         filobj ,
                         ext_ind,
                         cnv_ind,
                         cnc_ind)
                         
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * surface1;
    IGRboolean                natural_normal1;
    struct EMSobject_info   * surface2;
    IGRboolean                natural_normal2;
    struct EMSpoint_info    * start_point;
    struct EMSvalue_info    * start_radius;
    struct EMSpoint_info    * end_point;
    struct EMSvalue_info    * end_radius;
    IGRchar                 * variation_curve;
    IGRdouble               rho_value;
    IGRboolean                is_chamfer;
    GRobjid                 * filobj;
    IGRint                  ext_ind,cnv_ind,cnc_ind;
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
    struct EMSobject_info   parobjs[8];
    GRspacenum              constros;
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRlong                 EMgetparptobj(), EMgetparvalobj();

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
        IGRdouble               rho;
        struct GRlc_info        lc_info;
        IGRint                  num_fillets;
        GRobjid               * loc_fillets;
        IGRpoint                loc_start_point, loc_end_point;
        IGRdouble               loc_start_radius, loc_end_radius;
        struct IGRbsp_curve   * law_curve;
        IGRlong                 law_curve_index;
        extern void             EMget_lawcurve();

        lc_info.module_info = surface2->env;
        lc_info.located_obj = surface2->grid;

        om_msg = EMgetparpt_numeric (&msg_loc, start_point, loc_start_point);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_numeric (&msg_loc, start_radius, &loc_start_radius);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (end_point)
        {
            om_msg = EMgetparpt_numeric (&msg_loc, end_point, loc_end_point);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
        else memcpy(loc_end_point, loc_start_point, sizeof(IGRpoint));

        if (end_radius)
        {
            om_msg = EMgetparval_numeric (&msg_loc, end_radius, &loc_end_radius);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
        else loc_end_radius = loc_start_radius;

        if (variation_curve)
        {
           EMget_lawcurve ( &msg_loc,
                            variation_curve,
                            &law_curve_index,
                            &law_curve );

           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else law_curve = NULL;

        rho = rho_value;
        rho = (is_chamfer) ? 0.0 :  rho_value;
        
        /*
         * Following required by EMcrfilletsurf().  Otherwise, it assumes
         * allocated memory.
         */
            loc_fillets = NULL;

        om_msg = om$send ( msg = message EMSsubbs.EMgetfillet 
                                 ( &msg_loc,
                                   &mattyp,
                                   mat,
                                   natural_normal1,     /* Natural side of surf1 */
                                   &lc_info,            /* Other Surface */      
                                   natural_normal2,     /* Natural side of surf2 */
                                   loc_start_point,     /* Starting point */
                                   loc_start_radius,    /* Starting radius */
                                   loc_end_point,       /* Ending point */
                                   loc_end_radius,      /* Ending radius */
                                   NULL,                /* Direction point */
                                   law_curve,           /* Law curve */
                                   rho,                 /* Rho */
                                   &vgcnstr,            /* Construction list */
                                   NULL,                /* Options */
                                   &num_fillets,        /* Number of output fillets */
                                   &loc_fillets,        /* Output fillet surfaces */
                                   ext_ind,
                                   cnv_ind,
                                   cnc_ind),

                           senderid = NULL_OBJID,
                           targetid = surface1->grid.objid,
                           targetos = surface1->grid.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (num_fillets > 1)
        {
            om_msg = EFbuild_graphic_group ( num_fillets, 
                                             loc_fillets, 
                                             NULL, 
                                             &vgcnstr,
                                             filobj,
                                             &msg_loc );

            if (EMSerror (om_msg & msg_loc))
            {
                for (i=0; i<num_fillets; ++i)
                    om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                                 vgcnstr.env_info),
                             targetid = loc_fillets[i],
                             targetos = constros,
                             senderid = NULL_OBJID);
            }
        }
        else *filobj = *loc_fillets;

        if (loc_fillets) free(loc_fillets);
    }
    else
    {
        IGRint                      len, num_objs;
        struct EMSfillet_surface *  fil = 0;
        IGRdouble                   loc_start_radius, loc_end_radius;

        parobjs[0] = *surface1;
        parobjs[1] = *surface2;

        om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, start_point, &parobjs[2]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
        om_msg = EMgetparval_object (&msg_loc, constros, NULL, start_radius, &parobjs[3]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparval_numeric (&msg_loc, start_radius, &loc_start_radius);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (end_radius)
        {
            om_msg = EMgetparval_numeric (&msg_loc, end_radius, &loc_end_radius);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
        else loc_end_radius = loc_start_radius;

        if (loc_end_radius != loc_start_radius)
        {
            om_msg = EMgetparpt_object (&msg_loc, mattyp, mat, constros, end_point, &parobjs[4]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
      
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, end_radius, &parobjs[5]);
            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        
            num_objs = 6;
        }
        else num_objs = 4;

        len = sizeof(struct EMSfillet_surface) + ((variation_curve) ? strlen(variation_curve)+1 : 0);
        fil = (struct EMSfillet_surface *)alloca(len);
        fil->props = 0;

        if (natural_normal1) fil->props |= EMS_NATURAL_NORMAL1;
        if (natural_normal2) fil->props |= EMS_NATURAL_NORMAL2;
        if (end_radius)      fil->props |= EMS_VARIABLE_FILLET;

        fil->rho_value =0.0;
        if (is_chamfer) 
              fil->props |= EMS_CHAMFER_FILLET;
        else
              fil->rho_value = rho_value;

        if(ext_ind == 0)
          fil->props |= EMS_NO_EXT_FILLET;
        else if(ext_ind == 2)
          fil->props |= EMS_EXT_EXD_FILLET;
        else if(ext_ind == 1)
          fil->props |= EMS_EXT_ROLL_BALL_FILLET;

        if(cnv_ind == 2)
          fil->props |= EMS_INT_EXD_FILLET;
        else if(cnv_ind == 1)
          fil->props |= EMS_INT_ROLL_BALL_FILLET;
       
        
        if (variation_curve) 
        {
            fil->props |= EMS_LAW_CURVE;
            strcpy(fil + sizeof(struct EMSfillet_surface),variation_curve);
        }

        fil->view_index = NO_VIEW;

        om_msg = om$construct ( classid = OPP_EMSgencompsf_class_id,
                                 msg = message EMSassoc.EMinit_associative 
                                                ( &msg_loc,
                                                  opts & ~EMSasconst_recompute,
                                                  num_objs, 
                                                  parobjs, 
                                           EMS_ASfillet_by_surfaces_and_radii, 
                                                  len, 
                                                  (IGRchar *)fil,
                                                  &vgcnstr ),
                                 osnum = constros, 
                                 p_objid = filobj );

        /* stackfree (fil); */

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_fillet");
        return (om_msg);
}

end implementation EMSgencompsf;
