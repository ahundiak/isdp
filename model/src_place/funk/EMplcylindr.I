/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This is the function used to place a cylinder/solid-cylinder. These
    can be placed as associative or non-associative entities.

  HISTORY

    SS  :  03/05/91  : Creation
    jhw :  06/15/91  : Changed parameterization.
    Sudha  06/30/93  : Modified for BSprototypes ansification
*/

class implementation EMAcylindr;

#define BASE        0
#define HEIGHT      1
#define DIRECTION   2
#define DIAMETER    3

#include "REsfsolid.h"
#include "ma2ptdis.h"
#include "bsnorvec.h"

extern GRclassid OPP_EMSsfsolid_class_id;

from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_cylinder ( msg, 
                           opts, 
                           mdenv, 
                           level, 
                           disp, 
                           dispattr, 
                           objname,
                           basept, 
                           heightpt, 
                           diameter, 
                           is_solid,
                           cylobj)
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSpoint_info    * basept, * heightpt;
    struct EMSvalue_info    * diameter;
    IGRboolean                is_solid;
    GRobjid                 * cylobj;
{
    IGRchar                 loc_name[DI_PATH_MAX];
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, stat_OM;
    IGRdouble             * mat, radval;
    GRobjid                 solidobj;
    GRclassid               classid;
    struct GRmd_env         loc_mdenv;
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   parobjs[4];
    struct EMSradius        radstruct;
    GRspacenum              constros;
    IGRpoint                base_point, height_point;
    IGRint                  i;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr();
    IGRlong                 EMgetparptobj(), EMgetparvalobj(), EMgetparvecobj();
    extern OM_S_OBJID       current_creator;

    *msg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;

    /*
     * Obtain the construction environment. There are some pointer fields in the
     * vg-construct list which cannot be NULL (for default). These are assigned
     * pointers to respective structures via the init. All defaults obtain the
     * current values in the system.
     */
    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    stat_OM = EMgetparpt_numeric (&msg_loc, basept, base_point);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  
    stat_OM = EMgetparpt_numeric (&msg_loc, heightpt, height_point);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

    if (opts & EMSasconst_notassociative)
    {
        /*
         * The numeric values is extracted from the parameters being passed
         * in. The method for the non-associative cylinder is then invoked.
         */
        stat_OM = EMgetparval_numeric (&msg_loc, diameter, &radval);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        radval /= 2.0;
        radstruct.select = 0;
        radstruct.input.value = radval;

        /*
         * Construct the cylinder. If a solid needs to be constructed, do
         * so by creating an sfsolid and capping it.
         */
        stat_OM = om$construct ( classid = OPP_EMScylindr_class_id,
                                 msg = message EMScylindr.EMcylinder_by_axis_n_radius
                                                ( &vgcnstr, 
                                                  base_point, 
                                                  height_point, 
                                                  &radstruct ), 
                                 p_objid = cylobj,
                                 osnum = constros );

        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (is_solid)
        {
            stat_OM = om$construct ( classid = OPP_EMSsfsolid_class_id,
                                     p_objid = &solidobj, 
                                     osnum = constros );

            if (1 & stat_OM)
            {
                current_creator = solidobj;
                stat_OM = om$send ( msg = message EMSsfsolid.EMcap_thyself 
                                                ( &msg_loc,
                                                  &vgcnstr,
                                                  cylobj ),
                                    senderid = NULL_OBJID,
                                    targetid = solidobj,
                                    targetos = constros );
                current_creator = NULL_OBJID;
            }

            if (EMSerror (stat_OM & msg_loc))
            {
                om$send ( msg = message GRgraphics.GRdelete (&msg_loc, vgcnstr.env_info), 
                          targetid = *cylobj, 
                          targetos = constros,
                          senderid = NULL_OBJID);
            }
            else *cylobj = solidobj;
        }
    }
    else
    {
        struct EMSvector_info   direction;
        struct EMSvalue_info    height;

        direction.type = EMSdatainfo_numeric;
        for (i=0; i<3; ++i)
            direction.vec[i] = height_point[i] - base_point[i];
        BSnorvec (&msg_loc, direction.vec);

        height.type = EMSdatainfo_numeric;
        MA2ptdis (&msg_loc, base_point, height_point, &height.val);
        
        /*
         * If the parameters being passed in are not objects, construct
         * objects out of the numeric values being passed in. These become
         * the parameters for the object. If the intelligence to recompute these
         * entities has also been passed in, this is incorporated within the
         * objects constructed.
         */
        stat_OM = EMgetparpt_object (&msg_loc, mattyp, mat, constros, basept,
                   &parobjs[BASE]);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      
        stat_OM = EMgetparval_object (&msg_loc, constros, NULL, &height,
                   &parobjs[HEIGHT]);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        stat_OM = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction,
                   &parobjs[DIRECTION]);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        stat_OM = EMgetparval_object (&msg_loc, constros, NULL, diameter,
                   &parobjs[DIAMETER]);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        /*
         * The parameter objects are now used to construct and initialize the 
         * cylinder object. After this call the object is associative. Within this
         * method, the geometric construction takes place via an invocation of
         * the EMconstruct_associative method (defined at EMSassoc).
         */

        classid = is_solid ? OPP_EMSsfsolid_class_id : OPP_EMAcylindr_class_id;
        stat_OM = om$construct(classid = classid,
                               osnum = constros, p_objid = cylobj);
        if (1 & stat_OM)
        {
            current_creator = *cylobj;
            stat_OM = om$send ( msg = message EMSassoc.EMinit_associative 
                                            ( &msg_loc,
                                              opts & ~EMSasconst_recompute,
                                              4,
                                              parobjs,
                                              (is_solid) ?
                                              EMS_ASsolid_cylinder :
                                              EMS_AScylinder,
                                              0,
                                              NULL,
                                              &vgcnstr ),
                                senderid = NULL_OBJID,
                                targetid = *cylobj,
                                targetos = constros);

            current_creator = NULL_OBJID;
        }

        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, stat_OM, "EMplace_cylinder");

    return (stat_OM);
}

end implementation EMAcylindr;
