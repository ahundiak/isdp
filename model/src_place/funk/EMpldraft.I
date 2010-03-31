/*
 * DESCRIPTION:
 *
 *  This is the function used to place a drafted surface/solid.
 *  These can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *  Sudha   06/30/93        Modified for BSprototypes ansification
 *
 *  Jack 11-Jan-93 Modified to call EFget_analytic_info() for analytic
 *          surface creation
 *  DLB  :  Set current creator in compsf draft case.
 *  NP   :  Converted draft angles from degrees to radians for the 
 *          non-associative case. This was causing wrong curve offsets 
 *          downstream, where radians are expected. The associative code takes
 *          care of this.
 *  DLB  :  add view_index in draft_sf struct. 9/17/91
 *  jhw  :  Creation  :  04/28/91
 */
class implementation EMSgencompsf;

#include "bsicmpcvoff.h"
#include "REsfsolid.h"
#include <values.h>   /* for M_PI */
#include "EMSanaltypes.h"
#include "ma2ptdis.h"
#include "bserr.h"
#include "bsnorvec.h"


#define CURVE       0
#define HEIGHT      1
#define DIRECTION   2

extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSgensolid_class_id;

from EMSsfsolid import EMcap_thyself;
from EMSsubbs   import EMdrafted_surface;

extern void     EFget_analytic_info();

IGRlong EMplace_drafted_surface ( msg, 
                                  opts, 
                                  mdenv, 
                                  level,
                                  disp,
                                  dispattr,
                                  objname,
                                  curve,
                                  vector,
                                  angles,
                                  codes,
                                  num_sides,
                                  is_uniform,
                                  is_fillet,
                                  is_right_side,
                                  is_solid,
                                  drfobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * curve;
    struct EMSpoint_info    * vector;
    struct EMSvalue_info    * angles;
    IGRint                  * codes;
    IGRint                    num_sides;
    IGRboolean                is_uniform;
    IGRboolean                is_fillet;
    IGRboolean                is_right_side;
    IGRboolean                is_solid;
    GRobjid                 * drfobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    GRobjid                 solidobj;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    OMuword                 classid;
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
    IGRint                  i, j;
    IGRpoint                loc_points[2];
    IGRvector               loc_vector;
    extern OM_S_OBJID       current_creator;
    OMuword                 new_classid;
    OM_S_OBJID              new_objid=NULL_OBJID;
    IGRint                  info_bits=0;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    if (is_uniform) num_sides = 1;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr,
                              objname, &vgcnstr); 
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    /* Get the vector points */
    for (i=0; i<2; ++i)
    {
        om_msg = EMgetparpt_numeric (&msg_loc, &vector[i], loc_points[i]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

    /* Get the draft vector */
    for (i=0; i<3; ++i) loc_vector[i] = loc_points[1][i] - loc_points[0][i];

    if (opts & EMSasconst_notassociative)
    {
        IGRdouble             * loc_angles;
        IGRint                * loc_codes;

        /* Get the draft angles */
        loc_angles = (IGRdouble *)alloca(num_sides * sizeof(IGRdouble));

        for (i=0; i<num_sides; ++i)
        {
            om_msg = EMgetparval_numeric (&msg_loc, &angles[i],
                                          &loc_angles[i]); 
            EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

	    loc_angles[i] *= M_PI / 180.0; /* radians, needed for tan(theta) 
				              used to calc. offsets */
        }

        /* Get the draft offset codes */
        if (codes) loc_codes = codes;
        else
        {
            loc_codes  = (IGRint *)alloca(num_sides * sizeof(IGRint));
            for (i=0; i<num_sides; ++i) loc_codes[i] = BSCONSTOFF;
        }

        /* Get the classid of the curve */
        om_msg = om$get_classid ( objid = curve->grid.objid,
                                  osnum = curve->grid.osnum,
                                  p_classid = &classid );
        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        /* 
         * If the curve is a composite ...
         */
        if (om$is_ancestry_valid (subclassid = classid,
                                  superclassid = OPP_EMScomposite_class_id)
            == OM_S_SUCCESS)
        {
            /*
             * Construct and define the general composite surface.
             */
            om_msg = om$construct(classid = OPP_EMSgencompsf_class_id,
                                  osnum = constros,
                                  p_objid = drfobj );                          
            if (1 & om_msg)
            {
              current_creator = *drfobj;
              om_msg = om$send(msg = message EMSgencompsf.EMproject_with_draft 
                                               ( &msg_loc, 
                                                 curve->grid.objid,
                                                 is_uniform,
                                                 loc_angles,
                                                 loc_vector,
                                                 is_fillet,
                                                 is_right_side,
                                                 loc_codes,
                                                 &vgcnstr ),
                               senderid = NULL_OBJID,
                               targetid = *drfobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }
        }
        else
        {
            struct GRlc_info loc_curve;

            loc_curve.located_obj = curve->grid;
            loc_curve.module_info = curve->env;
            
            /*
             * Let's try and found out if any analytic surface will be 
             * created by creating a ruled surface from the input curve.
             */
            info_bits = 0;  /* no input bits set */
            
            EFget_analytic_info(&msg_loc,               /* EMmsg */
                                *loc_angles,            /* draft_angle */
                                &loc_curve.located_obj, /* curve_id */
                                &loc_curve.module_info, /* curve_env */
                                 NULL,                  /* curve_geom */
                                 NULL,                  /* curve_type */
                                 loc_vector,            /* axis */
                                 0.0,                   /* rev_angle */
                                 0,                     /* const_os */
                                &new_classid,           /* new_classid */
                                &new_objid,             /* new_obj */
                                &info_bits);            /* info_bits */
            EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, ret_end);          

            if(new_objid == NULL_OBJID)
              /*
               * Construct and define the general surface if there was
               * no analytic surface possible.
               */
              om_msg = om$construct(classid = OPP_EMSgenbs_class_id,
                                    osnum = constros,
                                    p_objid = drfobj);
            else
             *drfobj = new_objid;
               
            if (1 & om_msg)
            {
              current_creator = *drfobj;
              om_msg = om$send(msg = message EMSsubbs.EMdrafted_surface
                                               ( &msg_loc,
                                                 NULL,
                                                 &loc_curve,
                                                 NULL,
                                                 loc_vector,
                                                 *loc_angles,
                                                 is_right_side,
                                                 is_fillet,
                                                 NULL,
                                                 TRUE,
                                                 drfobj,
                                                 &vgcnstr),
                               senderid = NULL_OBJID,
                               targetid = *drfobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }
        }

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
                                                          drfobj), 
                               senderid = NULL_OBJID,
                               targetid = solidobj,
                               targetos = constros);
              current_creator = NULL_OBJID;
            }

            if (EMSerror (om_msg & msg_loc))
            {
                om$send (msg = message GRgraphics.GRdelete ( &msg_loc,
                                                             vgcnstr.env_info),
                         targetid = *drfobj,
                         targetos = constros,
                         senderid = NULL_OBJID);
            }
            else *drfobj = solidobj;
        }
    }
    else
    {
        IGRint                    size;  
        struct d_s_codes_views    *as_c_v;
        struct EMSdrafted_surface *as_draft;
        struct EMSobject_info     *parobjs;
        struct EMSvector_info     direction;
        struct EMSvalue_info      height;

        direction.type = EMSdatainfo_numeric;
        BSnorvec (&msg_loc, loc_vector);
        memcpy (direction.vec, loc_vector, sizeof(IGRvector));

        height.type = EMSdatainfo_numeric;
        MA2ptdis (&msg_loc, loc_points[0], loc_points[1], &height.val);

        parobjs = (struct EMSobject_info *)
                  alloca((num_sides + 3) * sizeof(struct EMSobject_info)); 
        parobjs[CURVE] = *curve;

        om_msg = EMgetparval_object (&msg_loc, constros, NULL, &height,
                                     &parobjs[HEIGHT]); 
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = EMgetparvec_object (&msg_loc, mattyp, mat, constros,
                                     &direction, &parobjs[DIRECTION]); 
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        for (i=0,j=3; i<num_sides; ++i,++j)
        {
            om_msg = EMgetparval_object (&msg_loc, constros, NULL, &angles[i],
                                         &parobjs[j]); 
            EMerr_hndlr(EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail,ret_end);
        }

        size = sizeof(struct EMSdrafted_surface) + 
               (num_sides * sizeof(struct d_s_codes_views)) + 
               sizeof(IGRint); /*pad*/

        as_draft = (struct EMSdrafted_surface *)alloca(size);

        as_draft->props = 0;
        if (is_uniform)    as_draft->props |= EMS_IS_UNIFORM;
        if (is_fillet)     as_draft->props |= EMS_IS_FILLETED;
        if (is_right_side) as_draft->props |= EMS_IS_RIGHT_SIDE;

        as_draft->num_sides = num_sides;
        as_c_v = as_draft->codes_views;

        for (i=0; i<num_sides; ++i) 
        {
          as_c_v[i].as_code = (codes) ? codes[i] : BSCONSTOFF;
          as_c_v[i].view_index = NO_VIEW;
        }

        classid = is_solid ? OPP_EMSsfsolid_class_id : 
                             OPP_EMSgencompsf_class_id;

        om_msg = om$construct(classid = classid,
                              osnum = constros, 
                              p_objid = drfobj);
        if (1 & om_msg)
        {
          current_creator = *drfobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                      ( &msg_loc,
                        opts & ~EMSasconst_recompute,
                        3 + num_sides,
                        parobjs, 
                       is_solid ?
                       (convert_into_plane ? EMS_ASsolid_drafted_surface1
                                          : EMS_ASsolid_drafted_surface)
                                :
                       (convert_into_plane ? EMS_ASdrafted_surface1
                                          : EMS_ASdrafted_surface),
                       size,
                       (IGRchar *)as_draft, 
                       &vgcnstr ),
                       senderid = NULL_OBJID,
                       targetid = *drfobj,
                       targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *drfobj, constros);

ret_end:

    EMWRAPUP (*msg, om_msg, "EMplace_drafted_surface");

    return (om_msg);
}

end implementation EMSgencompsf;


