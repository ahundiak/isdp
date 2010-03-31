/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This method constructs/recomputes associative cylinders.
 *
 * HISTORY:
 *
 *  SS     ???????? Creation.
 *  jhw    06/12/91 Reparameterized cylinder class.
 *
 *  Sudha   06/01/93    modified to handle BSprototype headers

 */
class implementation EMAcylindr;

#include "OMmacros.h"
#include "mascalvc.h"

#define BASE        0
#define HEIGHT      1
#define DIRECTION   2
#define DIAMETER    3

#define USE_VALUE 0

method EMconstruct_associative ( IGRlong                * msg; 
                                 IGRushort        opts;
                                 GRobjid                  old_objid;
                                 IGRint                   num_parents; 
                                 IGRchar                * parent_info;
                                 IGRint                   type; 
                                 IGRchar                * recomp_info;
                                 struct GRvg_construct  * constr_list )
{
    IGRuint       * param_type;
    IGRlong                 msg_loc, stat_OM = OM_S_SUCCESS;
    IGRdouble             * base_point;
    IGRpoint                height_point;
    IGRvector               height_vector;
    IGRint                  i;
    struct EMSradius        radius;
    union EMSparent_info  * param;

    *msg = EMS_S_Success;

    /*
     * Obtain my parameter information in an understandable
     * format
     */
    param_type = (IGRuint *)alloca (num_parents * sizeof (IGRint));
    EMerr_hndlr (!param_type, *msg, EMS_E_NoStackMemory, ret_end);

    param = (union EMSparent_info *)alloca (num_parents * sizeof (union EMSparent_info));
    EMerr_hndlr (!param, *msg, EMS_E_NoStackMemory, ret_end);

    param_type[BASE]      = EMSpoint;
    param_type[HEIGHT]    = EMSdistance;
    param_type[DIRECTION] = EMSvector;
    param_type[DIAMETER]  = EMSdistance;

    stat_OM = om$send ( msg = message EMSassoc.EMget_parent_info 
                                              ( &msg_loc,
                                                NULL, 
                                                num_parents, 
                                                parent_info, 
                                                param_type, 
                                                param ),
                        targetid = my_id );

    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    radius.select = USE_VALUE;
    radius.input.value = param[DIAMETER].value/2;

    base_point = param[BASE].point;
    MAscalvc ( &msg_loc, &param[HEIGHT].value, param[DIRECTION].vector, height_vector);
    for (i=0; i<3; ++i)
        height_point[i] = base_point[i] + height_vector[i];

    /*
     * Post the geometry into myself or construct additional component
     * elements. Basically, initialize myself, geometrically.
     */
    stat_OM = om$send ( msg = message EMScylindr.EMcylinder_by_axis_n_radius 
                                                ( constr_list, 
                                                  base_point, 
                                                  height_point, 
                                                  &radius ),     
                        targetid = my_id );

    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

ret_end:

    EMWRAPUP (*msg, stat_OM, "EMAcylindr.EMconstr");

    return (stat_OM);
}

end implementation EMAcylindr;

