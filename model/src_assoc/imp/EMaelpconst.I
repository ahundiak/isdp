/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This is the method is used to construct and recompute the following:
 *
 *      Cone by Axis and Diameters
 *      Right Elliptical Cylinder
 *      Right Elliptical Cone
 *
 * HISTORY:
 *
 *  jhw  : 03/20/91 : Creation.
 *  jhw  : 04/30/91 : Added elliptical cone and cylinder. 
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMAelpcone;

#include "OMmacros.h"
#include "mascalvc.h"
#include "bsnorvec.h"
#include "bscrossp.h"

from EMScone      import EMcone;

#define BASE            0
#define HEIGHT          1
#define DIRECTION       2
#define BASE_DIAMETER   3 
#define HEIGHT_DIAMETER 4

#define BASE_MAJOR      3
#define BASE_MINOR      4
#define BASE_MAJOR_DIR  5
#define HEIGHT_MAJOR    6

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRuint         * param_type;
    union EMSparent_info    * param;
    IGRlong                   msg_loc, om_msg = OM_S_SUCCESS;
    IGRint                    i;
    
    *msg = EMS_S_Success;

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca(num_parents * sizeof(IGRint));
    param = (union EMSparent_info *)alloca(num_parents * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_AScone_by_axis_and_diameters:
        param_type[BASE]          = EMSpoint;  
        param_type[HEIGHT]        = EMSdistance;
        param_type[DIRECTION]     = EMSvector;
        param_type[BASE_DIAMETER]   = EMSdistance;
        param_type[HEIGHT_DIAMETER] = EMSdistance;
        break;

    case EMS_ASright_elliptical_cone:
        param_type[HEIGHT_MAJOR] = EMSdistance; 

    case EMS_ASright_elliptical_cylinder:
        param_type[BASE]           = EMSpoint;
        param_type[HEIGHT]         = EMSdistance;
        param_type[DIRECTION]      = EMSvector;
        param_type[BASE_MAJOR]     = EMSdistance;
        param_type[BASE_MINOR]     = EMSdistance;
        param_type[BASE_MAJOR_DIR] = EMSvector;
        break;

    default:
        goto ret_end;
    }        

    /*
     * Get the parameter information.
     */
    om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Initialize the cone.
     */
    switch (type)
    {
        case EMS_AScone_by_axis_and_diameters: 
        {
            IGRpoint  loc_axis[2];
            IGRdouble loc_radii[2];
            IGRvector loc_vector;

            memcpy(loc_axis[0], param[BASE].point, sizeof(IGRpoint));
            memcpy(loc_axis[1], param[BASE].point, sizeof(IGRpoint));

            MAscalvc ( &msg_loc, &param[HEIGHT].value, param[DIRECTION].vector, loc_vector);
            for (i=0; i<3; ++i)
                loc_axis[1][i] += loc_vector[i];

            loc_radii[0] = param[BASE_DIAMETER].value / 2.0;
            loc_radii[1] = param[HEIGHT_DIAMETER].value / 2.0;

            om_msg = om$send ( msg = message EMScone.EMcone
                                                    ( (IGRint *)&msg_loc,
                                                      constr_list,
                                                      loc_axis,
                                                      loc_radii ),
                               targetid = my_id );

            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        }
            break;

        case EMS_ASright_elliptical_cylinder:
        case EMS_ASright_elliptical_cone:
        {
            IGRdouble        scale;
            IGRvector        major_vc, minor_vc, height_vc, vector;

            MAscalvc (&msg_loc, &param[HEIGHT].value, param[DIRECTION].vector, height_vc);
            MAscalvc (&msg_loc, &param[BASE_MAJOR].value, param[BASE_MAJOR_DIR].vector, major_vc);
            BScrossp (&msg_loc, height_vc, major_vc, vector);
            BSnorvec (&msg_loc, vector);
            MAscalvc (&msg_loc, &param[BASE_MINOR].value, vector, minor_vc);

            if (type == EMS_ASright_elliptical_cone)
            {
                scale = (param[BASE_MAJOR].value == 0.0) ? 
                        1.0 : 
                        param[HEIGHT_MAJOR].value/param[BASE_MAJOR].value;
            }
            else scale = 1.0;

            om_msg = om$send ( msg = message EMSelpcone.EMconstruct_elliptical_cone 
                                                ( &msg_loc,
                                                  constr_list,
                                                  param[0].point,
                                                  major_vc,
                                                  minor_vc,
                                                  height_vc,
                                                  scale ),
                               targetid = my_id );

            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        }
            break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAelpcone.EMconstruct_associative");

    return (om_msg);
}

end implementation EMAelpcone;

