/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This is the method is used to construct and recompute the following:
 *
 *      Ellipsoid by foci and axis length
 *      Ellipsoid by center, axis and radius
 *
 * HISTORY:
 *
 *  jhw  : 05/1/91 : Creation.
 */
class implementation EMAelpsoid;

#include "OMmacros.h"

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
    struct EMesellpsd1        method1, * p_method1;
    struct EMesellpsd2        method2, * p_method2;

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
    case EMS_ASellipsoid_by_foci_axis_len:
    case EMS_ASellipsoid_by_center_axis_radius:
        param_type[0] = EMSpoint; 
        param_type[1] = EMSpoint; 
        param_type[2] = EMSdistance;
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
     * Fill in the ellipsoid method.
     */
    switch (type)
    {
    case EMS_ASellipsoid_by_center_axis_radius:
        memcpy (method1.center, param[0].point, sizeof(IGRpoint));
        for (i=0; i<3; ++i) 
            method1.semi_axis[i] = param[1].point[i] - param[0].point[i];
        method1.radius = param[2].value;
        p_method1 = &method1;
        p_method2 = NULL;
        break;

    case EMS_ASellipsoid_by_foci_axis_len:
        memcpy (method2.focus0, param[0].point, sizeof(IGRpoint));
        memcpy (method2.focus1, param[1].point, sizeof(IGRpoint));
        method2.major_axis_length = param[2].value;
        p_method1 = NULL;
        p_method2 = &method2;
        break;
    }

    om_msg = om$send ( msg = message EMSelpsoid.EMelpsd ( p_method1,
                                                          p_method2,
                                                          constr_list,
                                                          &msg_loc ),
                       targetid = my_id );

    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAelpsoid.EMconstruct_associative");

    return (om_msg);
}

end implementation EMAelpsoid;
