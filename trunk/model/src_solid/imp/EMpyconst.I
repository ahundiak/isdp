/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the construct method for solid blocks and wedges.
 *
 * HISTORY:
 *
 *  jhw    Creation         04/10/91
 *  Sudha  07/01/93	    Modified for BSprototypes ansification
 */

class implementation EMSpolyhdrn;

#include "OMmacros.h"
#include "REpolyhdrn.h"
#include "ma.h"
#include "mascalvc.h"

from EMSblock     import EMboxby2pt, EMboxbyhwd;
from EMSwedge     import EMrtwedge;

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

#define TWO_WIDTH     1
#define TWO_HEIGHT    2
#define TWO_LENGTH    3
#define TWO_DIRECTION 4

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRlong                   msg_loc, om_msg;
    IGRuint         * param_type;
    union EMSparent_info    * param;
    IGRpoint                  loc_point;
    IGRint                    i, j, k;
    IGRboolean convert_into_plane = TRUE;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca (num_parents * sizeof(IGRint));
    param = (union EMSparent_info *)alloca(num_parents * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_ASsolid_box_by_2pts:
        if (num_parents < 5) goto ret_end;
        param_type[BASE] = EMSpoint;
        param_type[TWO_WIDTH] = param_type[TWO_HEIGHT] = param_type[TWO_LENGTH] = EMSdistance;
        param_type[TWO_DIRECTION] = EMSvector;
        break;

    case EMS_ASsolid_box_by_4pts:
    case EMS_ASsolid_right_angle_wedge:
    case EMS_ASsolid_right_angle_wedge1:
        if (num_parents < 7) goto ret_end;
        param_type[BASE] = EMSpoint;
        param_type[WIDTH] = param_type[HEIGHT] = param_type[LENGTH] = EMSdistance;
        param_type[WIDTH_VEC] = param_type[HEIGHT_VEC] = param_type[LENGTH_VEC] = EMSvector;
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
     * Construct the appropriate plane.
     */
    switch (type)
    {
    case EMS_ASsolid_box_by_2pts:
        memcpy (loc_point, param[BASE].point, sizeof(IGRpoint));
        for (i=0, j=TWO_WIDTH; i<3; ++i, ++j)
            if (param[TWO_DIRECTION].vector[i] > 0.0)
                loc_point[i] += param[j].value;
            else
                loc_point[i] -= param[j].value;

        om_msg = om$send ( msg = message EMSblock.EMboxby2pt
                                            ( &msg_loc,
                                              constr_list,
                                              param[BASE].point,
                                              loc_point ),
                           targetid = my_id );
        break;

    case EMS_ASsolid_box_by_4pts:
    case EMS_ASsolid_right_angle_wedge:
    case EMS_ASsolid_right_angle_wedge1:
    {
        IGRvector   vectors[3];

        for (i=0,j=WIDTH,k=WIDTH_VEC; i<3; ++i, j+=2, k+=2)
            MAscalvc (&msg_loc, &param[j].value, param[k].vector, vectors[i]);


        if (type == EMS_ASsolid_box_by_4pts)
            om_msg = om$send ( msg = message EMSblock.EMboxbyhwd
                                            ( &msg_loc,
                                              constr_list,
                                              param[BASE].point,
                                              vectors[0],
                                              vectors[1],
                                              vectors[2] ),
                               targetid = my_id );
        else
            om_msg = om$send ( msg = message EMSwedge.EMrtwedge
                                            ( &msg_loc,
                                              constr_list,
                                              param[BASE].point,
                                              vectors[0],
                                              vectors[1],
                                              vectors[2] ),
                               targetid = my_id );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
        break;
    }    



     if( (type == EMS_ASsolid_right_angle_wedge1) && convert_into_plane)
      om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, constr_list->env_info, my_id, OM_Gw_current_OS);

ret_end:

    EMWRAPUP (*msg, om_msg, "EMSpolyhdrn.EMconstruct_associative");

    return (om_msg);
}

end implementation EMSpolyhdrn;
