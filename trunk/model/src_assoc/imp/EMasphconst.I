/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This is the method is used to construct and recompute a sphere by
 *  center and radius.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMAsphere;

#include "OMmacros.h"

#define CENTER 0
#define RADIUS 1

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

    *msg = EMS_S_Success;

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca (num_parents * sizeof(IGRuint));
    param = (union EMSparent_info *)alloca(num_parents * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_ASsphere_by_center_and_radius:
        param_type[CENTER] = EMSpoint;
        param_type[RADIUS] = EMSdistance;
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
                                              (IGRchar *)parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Initialize the sphere.
     */
    switch (type)
    {
        case EMS_ASsphere_by_center_and_radius:
            om_msg = om$send ( msg = message EMSsphere.EMsphere_by_center_radius
                                                        ( constr_list,
                                                          param[CENTER].point,
                                                          param[RADIUS].value ),
                               targetid = my_id );

            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
            break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAsphere.EMconstruct_associative");
    return (om_msg);
}

end implementation EMAsphere;
