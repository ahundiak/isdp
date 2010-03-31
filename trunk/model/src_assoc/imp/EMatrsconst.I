/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This is the method is used to construct and recompute a torus by
 *  axis, center and radius.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  4/10/91
 */
class implementation EMAtorus;

#include "OMmacros.h"
#include "EMSstruct.h"

#define AXIS_ORIGIN     0
#define AXIS_DIRECTION  1
#define CENTER          2
#define RADIUS          3

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
    case EMS_AStorus_by_axis_center_and_radius:
        param_type[AXIS_ORIGIN]     = EMSpoint;
        param_type[AXIS_DIRECTION]  = EMSvector;
        param_type[CENTER]          = EMSpoint;
        param_type[RADIUS]          = EMSdistance;
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
        case EMS_AStorus_by_axis_center_and_radius:
        {
            IGRpoint         loc_axis_origin, loc_point;
            IGRvector        loc_axis_direction;
            IGRpoint         loc_center;
            struct EMSradius loc_radius;

            memcpy(loc_axis_origin, param[AXIS_ORIGIN].point, sizeof(IGRpoint));
            memcpy(loc_axis_direction, param[AXIS_DIRECTION].vector, sizeof(IGRvector));
            memcpy(loc_center,  param[CENTER].point, sizeof(IGRpoint));

            loc_radius.select = 0;
            loc_radius.input.value = param[RADIUS].value;

            for (i=0; i<3; ++i)
                loc_point[i] = loc_axis_origin[i] + loc_axis_direction[i];

            om_msg = om$send ( msg = message EMStorus.EMtorus_by_axis_center_rad
                                                ( constr_list,
                                                  loc_axis_origin,
                                                  loc_point,
                                                  loc_center,
                                                  &loc_radius ),
                                targetid = my_id );

            EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
            break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAtorus.EMconstruct_associative");

    return (om_msg);
}

end implementation EMAtorus;

