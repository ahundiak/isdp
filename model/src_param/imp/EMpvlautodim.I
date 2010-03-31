/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

The following message creates a dimensional handle for the constraint.
The dimension is returned and is always constructed in this object
space.

HISTORY

SS  :  04/09/91  :  Creation
jhw :  06/10/91  :  Added EFconnect_geom_to_dim and support for dim_type.
jhw :  06/30/91  :  Added  check for a predimensioned parameter.
jhw :  07/11/91  :  Modified to work with the new autodim setup.
jhw :  08/06/91  :  Added support for single arc angle and length dimensions.

*/
class implementation EMSparamvl;

#include "OMmacros.h"
#include "bserr.h"
#include "dimplcmacros.h"

extern OMuword OPP_DMroot_class_id;

method EMauto_dimension ( IGRlong           * msg;
                          IGRushort   opts;
                          IGRint              dim_type;
                          IGRshort          * mattyp;
                          IGRmatrix           mat;
                          GRobjid           * dimobj )
{
    IGRint            trak_dir, sector, axis;
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRpoint          dumpt;
    struct GRid       dim_id, assoc_id, source_id, param_id;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    trak_dir = !(opts & EMS_NEG_TRAK_DIR);
    axis     = !(opts & EMS_NEG_AXIS);
    sector   = !(opts & EMS_NEG_SECTOR);

    param_id.objid = my_id;
    param_id.osnum = OM_Gw_current_OS;

    if (EFselect_first_component (&param_id, OPP_DMroot_class_id, &dim_id))
    {
        *dimobj = dim_id.objid;
        goto ret_end;
    }

    /*
     * Construct the appropriate dimension object, connecting the dimension
     * as a child of the associative object sending the auto_dimension message.
     */
    dim_id.objid = NULL_OBJID;

    assoc_id.objid = sender_id;
    assoc_id.osnum = sender_os;

    om_msg = EFget_parent_source (&assoc_id, &source_id);

    switch (dim_type)
    {
        case SINGLE_PARALLEL:
            dm$place_sglpara ( orig_grid  = &source_id,
                               orig_pt    = dumpt,
                               plane_grid = &source_id,
                               trak_dir   = trak_dir,
                               owner      = &param_id,
                               dim_grid   = &dim_id );
            break;

        case LINEAR_DIAMETER:
            dm$place_lindia  ( orig_grid  = &source_id,
                               orig_pt    = dumpt,
                               meas_grid  = &source_id,
                               meas_pt    = dumpt,
                               plane_grid = &source_id,
                               trak_dir   = trak_dir,
                               axis       = axis,
                               owner      = &param_id,
                               dim_grid   = &dim_id );
            break;

        case CIRCULAR_DIAMETER:
            dm$place_cirdia  ( orig_grid  = &source_id,
                               orig_pt    = dumpt,
                               plane_grid = &source_id,
                               trak_dir   = trak_dir,
                               axis       = axis,
                               owner      = &param_id,
                               dim_grid   = &dim_id );
            break;

        case RADIAL:
            dm$place_radial  ( orig_grid  = &source_id,
                               orig_pt    = dumpt,
                               plane_grid = &source_id,
                               owner      = &param_id,
                               dim_grid   = &dim_id );
            break;

        case STACKED_LINEAR:
            dm$place_stack_linear ( orig_grid  = &source_id,
                                    orig_pt    = dumpt,
                                    meas_grid  = &source_id,
                                    meas_pt    = dumpt,
                                    plane_grid = &source_id,
                                    trak_dir   = trak_dir,
                                    axis       = axis,
                                    owner      = &param_id,
                                    dim_grid   = &dim_id );
            break;

        case SINGLE_ARC_ANGLE:
            dm$place_sglarc_angle( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &param_id,
                                   dim_grid   = &dim_id );
            break;

        case SINGLE_ARC_LENGTH:
            dm$place_sglarc_length ( orig_grid  = &source_id,
                                     orig_pt    = dumpt,
                                     plane_grid = &source_id,
                                     trak_dir   = trak_dir,
                                     owner      = &param_id,
                                     dim_grid   = &dim_id );
            break;

        case STRINGED_LINEAR:
        case SYMMETRICAL_DIAMETER:
        case STACKED_ANGULAR:
        case STRINGED_ANGULAR:
        case RADIAL_DIAMETER:
        case COORDINATE:
        case CENTER_LINE:
        case CHAMFER:
        case TEXT_WITH_BALLOON:
        case LEADER_LINE:
        case FEATURE_CONTROL_FRAME:
        case DATUM_FRAME:
            break;

        default:
            break;
    }

    EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);

    /*
     * Return the dimension object
     */
    *dimobj = dim_id.objid;

ret_end:

    EMWRAPUP (*msg, om_msg, "EMparamvl.EMauto_dimension");

    return (om_msg);
}

end implementation EMSparamvl;

