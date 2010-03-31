/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
 * FUNCTIONS:
 *  
 *  EFget_active_param  - Returns the parameter which is being autodimensioned.
 *
 *  EFget_parent_source - Returns the source of parents for an associative
 *                        object.
 *
 *  EFis_negative       - Determines if the major component of a vector 
 *                        is negative.
 *                  
 *  EFget_out_vector    - Normalizes the input vector and reverses it's 
 *                        direction if the original vector is negative.
 *
 *  EFget_dim_box       - Takes a origin point and x, y, z vectors defining
 *                        a box and modifies this definition so that the
 *                        vectors are all negative but the definition of 
 *                        the box is unchanged.
 *
 *  EFget_major_axis    - Returns the major positive component of a vector.
 *
 *  EFget_last_point_normal  - Returns a vector which is the normal of the
 *                        window where the last data point was entered in.
 * 
 *  EFselect_first_component - Returns the first component on an owner's 
 *                        channel which is a subclass of the specified classid.
 *
 *  EFget_dimension_normal   - Returns the normal of a dimension.
 *
 *  EFget_normal_from_axis   - Returns the new x, y, z axis of a dimension
 *                        based on the last point.
 *
 *  EFget_curve_buffer       - Returns the a pointer to a bspcurve buffer. 
 *                        This buffer is used in the EMdimparam message when 
 *                        a geometry for radial dimensions is to be returned.
 *
 * DESCRIPTION:
 *
 *  These functions are used by the EMdimparam overrides on associative
 *  objects to help determine a reasonable dimension plane and x axis.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91

    Sudha       06/01/93        modified to handle BSprototypes

*/
class implementation EMSdim;

#include "exdef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "madotvc.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bscrossp.h"
#include "bsalloccv.h"

#define MAETA   1.0e-15

extern OMuword OPP_DMroot_class_id;

IGRint EFget_active_parameter (assoc_id, dim_id, param_id)
    struct GRid * assoc_id;     /* In  */
    struct GRid * dim_id;       /* In  */
    struct GRid * param_id;     /* Out */
{
    IGRlong         om_msg = OM_E_ABORT;
    OMuword         classid;
    IGRint          i, count;
    OMuword         depth;
    struct GRid     id;
    OM_S_CHANSELECT owner_chansel, child_chansel, father_chansel;

    EMmake_chanselect (GRconnector_to_owners, &owner_chansel);

    if (dim_id && (dim_id->objid != NULL_OBJID))
    {
        om$get_classid ( objid = dim_id->objid,
                         osnum = dim_id->osnum,
                         p_classid = &classid );

        if (om$is_ancestry_valid (superclassid = OPP_DMroot_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            om_msg = om$get_objid_at_index ( objid        = dim_id->objid,
                                             osnum        = dim_id->osnum,
                                             p_chanselect = &owner_chansel,
                                             index        = 0,
                                             objidaddr    = &param_id->objid,
                                             osnumaddr    = &param_id->osnum );
        }
    }

    /* 
     * This will only be needed if the dimension id is not specified or
     * the dimension id was not a true dimension. This will NEVER happen
     * for all known uses.
     */
    if (!(om_msg & 1))
    {
        EMmake_chanselect (NDchildren_children, &child_chansel);

        om_msg = om$get_channel_count (objid = assoc_id->objid,
                                       osnum = assoc_id->osnum,
                                       p_chanselect = &child_chansel,
                                       count = (OMuint *) &count);

        if (om_msg & 1)
        {
            for (i=0; i<count; ++i)
            {
                om_msg = om$get_objid_at_index (objid = assoc_id->objid,
                                                osnum = assoc_id->osnum,
                                                p_chanselect = &child_chansel, 
                                                index = i,
                                                objidaddr = &(id.objid),
                                                osnumaddr = &(id.osnum));

                if (om_msg & 1)
                {
                    om$get_classid ( objid = id.objid,
                                     osnum = id.osnum,
                                     p_classid = &classid );

                    if (om$is_ancestry_valid (superclassid = OPP_DMroot_class_id,
                                              subclassid = classid) == OM_S_SUCCESS)
                    {
                        om_msg = om$get_senddepth (objid = id.objid,
                                                   osnum = id.osnum,
                                                   p_depth = &depth);

                        if ((om_msg & 1) && (depth > 0)) 
                        {
                            om_msg = om$get_objid_at_index (objid = id.objid,
                                                            osnum = id.osnum,
                                                            p_chanselect = &owner_chansel, 
                                                            index = 0,
                                                            objidaddr = &(param_id->objid),
                                                            osnumaddr = &(param_id->osnum));
                            if (om_msg & 1) break;
                        }
                    }
                }
            }

            if (i==count)
            {
                EMmake_chanselect (NDfather_father, &father_chansel);

                om_msg = om$get_channel_count (objid = assoc_id->objid,
                                               osnum = assoc_id->osnum,
                                               p_chanselect = &father_chansel,
                                               count = (OMuint *) &count);

                if (om_msg & 1)
                {
                    for (i=0; i<count; ++i)
                    {
                        om_msg = om$get_objid_at_index (objid = assoc_id->objid,
                                                        osnum = assoc_id->osnum,
                                                        p_chanselect = &father_chansel, 
                                                        index = i,
                                                        objidaddr = &(param_id->objid),
                                                        osnumaddr = &(param_id->osnum));

                        if (om_msg & 1)
                        {
                            om_msg = om$get_senddepth (objid = param_id->objid,
                                                       osnum = param_id->osnum,
                                                       p_depth = &depth);

                            if ((om_msg & 1) && (depth > 0)) break;
                        }
                    }

                    if (i==count) om_msg = OM_E_ABORT;
                }
            }
        }
    }

    return (om_msg & 1);
}

extern OMuword OPP_EMSsfsolid_class_id;

IGRint EFget_parent_source (assoc_id, source_id)
    struct GRid * assoc_id;     /* In  */
    struct GRid * source_id;    /* Our */
{
    IGRlong         om_msg = OM_S_SUCCESS;
    OMuword         classid;
    IGRint          count;
    OM_S_CHANSELECT father_chansel, owner_chansel;
    
    EMmake_chanselect (NDfather_father, &father_chansel);

    om_msg = om$get_channel_count ( objid = assoc_id->objid,
                                    osnum = assoc_id->osnum,
                                    p_chanselect = &father_chansel,
                                    count = (OMuint *) &count );

    if ((om_msg == OM_S_SUCCESS) && count) *source_id = *assoc_id;
    else
    {
        EMmake_chanselect (GRconnector_to_owners, &owner_chansel);

        om_msg = om$get_objid_at_index ( objid = assoc_id->objid,
                                         osnum = assoc_id->osnum,
                                         index = 0,
                                         objidaddr = &source_id->objid,
                                         osnumaddr = &source_id->osnum,
                                         p_chanselect = &owner_chansel );

        if (om_msg == OM_S_SUCCESS)
        {
            om$get_classid ( objid = source_id->objid,
                             osnum = source_id->osnum,
                             p_classid = &classid );

            om_msg = om$is_ancestry_valid ( superclassid = OPP_EMSsfsolid_class_id,
                                            subclassid = classid);
        }
    }                                            

    return (om_msg == OM_S_SUCCESS);
}

IGRint EFis_negative (vec)
    IGRdouble * vec;
{
    IGRint      i, maxi = 0;
    IGRdouble   fabs(), max = 0.0, loc;

    for (i=0; i<3; ++i)
        if ((loc = fabs(vec[i])) > max) 
            { max = loc; maxi = i; }

    return (vec[maxi] < 0.0);
}

void EFget_out_vector (vec)
    IGRdouble * vec;
{
    IGRint i;
    IGRlong msg;

    BSnorvec (&msg, vec);

    if (EFis_negative(vec))
        for (i=0; i<3; ++i)
            vec[i] *= -1;
}

void EFget_dim_box (o, x, y, z)
    IGRdouble  * o, * x, * y, * z;
{
    IGRint       i;

    if (!EFis_negative(x))
        for (i=0; i<3; ++i)
            o[i] -= (x[i] *= -1);

    if (EFis_negative(y))
        for (i=0; i<3; ++i)
            o[i] -= (y[i] *= -1);

    if (z)
        if (EFis_negative(z))
            for (i=0; i<3; ++i)
                o[i] -= (z[i] *= -1);
}

IGRint EFget_major_axis (vec)
    IGRvector   vec;
{
    IGRint      i, maxi = 0;
    IGRdouble   fabs(), max = 0.0, loc;

    for (i=0; i<3; ++i)
        if ((loc = fabs(vec[i])) > max) 
            { max = loc; maxi = i; }

    return (maxi);
}

IGRint EFget_last_point_normal (normal)
    IGRvector normal;
{
    IGRlong             msg;
    IGRint              nret;
    struct EX_button    button;
    IGRmatrix           matrix;
    struct var_list     var_list[2];
    IGRlong             which_error;
  
    gr$get_last_point ( buffer = &button );

    var_list[0].var = VIEW_ROTATION;
    var_list[0].var_ptr = (IGRchar *) matrix;
    var_list[0].num_bytes = sizeof(IGRdouble) * 16;
    var_list[0].bytes_returned = (IGRlong * )&nret;
    var_list[1].var = END_PARAM;

    dp$inq_set_gragad ( msg = &msg,
                        osnum = button.osnum,
                        gragad_objid = button.objid,
                        which_error = &which_error,
                        var_list = var_list );

    normal[0] = matrix[8];
    normal[1] = matrix[9];
    normal[2] = matrix[10];

    return (msg & 1);
}

IGRint EFselect_first_component (owner_grid, component_classid, component_grid)
    struct GRid     * owner_grid;
    OMuword           component_classid;
    struct GRid     * component_grid;
{
    IGRint          i;
    OM_S_CHANSELECT to_comps;
    OMuword         classid;

    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    for ( i=0; 
          (om$get_objid_at_index(objid = owner_grid->objid,
                                 osnum = owner_grid->osnum,
                                 p_chanselect = &to_comps,
                                 index = i,
                                 objidaddr = &component_grid->objid,
                                 osnumaddr = &component_grid->osnum ) == OM_S_SUCCESS);
          ++i)
    {
        om$get_classid ( objid = component_grid->objid,
                         osnum = component_grid->osnum,
                         p_classid = &classid );

        if (om$is_ancestry_valid(superclassid = component_classid,
                                 subclassid = classid) == OM_S_SUCCESS)
        {
            return(1);
        }
    }

    return (0);
}

extern OMuword OPP_GRlbsys_class_id;

IGRint EMget_dimension_normal (dim_id, dim_mod, normal)
    struct GRid     * dim_id;
    struct GRmd_env * dim_mod;
    IGRvector         normal;
{
    IGRlong         om_msg = OM_S_SUCCESS, msg = EMS_S_Success;
    struct IGRplane plane;
    IGRpoint        point;
    struct GRid     text_id;
    
    plane.point  = point;
    plane.normal = normal;

    if (EFselect_first_component (dim_id, OPP_GRlbsys_class_id, &text_id))
    {
        om_msg = om$send ( msg = message GRvg.GRdetplane 
                                            ( &msg,
                                              &dim_mod->md_env.matrix_type,
                                              dim_mod->md_env.matrix,
                                              &plane ),
                           senderid = NULL_OBJID,
                           targetid = text_id.objid,
                           targetos = text_id.osnum );
    }
    else msg = EMS_E_Fail;

    return (om_msg & msg & 1);
}

IGRint EFget_normal_from_axis ( msg, 
                                param,
                                mod_env,
                                x_axis, 
                                y_axis, 
                                z_axis )
    IGRlong         * msg;
    struct GRid     * param;
    struct GRmd_env * mod_env;
    IGRvector         x_axis, y_axis, z_axis;
{
    IGRlong     om_msg = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRdouble   dotval;
    IGRboolean  update_normal = TRUE;
    IGRint      i;

    *msg = EMS_S_Success;

    EFget_out_vector (x_axis);

    if (param && mod_env)
    {
        struct GRid dim_id;
    
        if (EFselect_first_component (param, OPP_DMroot_class_id, &dim_id))
        {
            if (EMget_dimension_normal (&dim_id, mod_env, z_axis))
            {
                MAdotvc (&msg_loc, z_axis, x_axis, &dotval);
                if ((dotval > -MAETA) && (dotval < MAETA))
                {
                    if (EFget_major_axis(z_axis) == 1)
                        for (i=0; i<3; ++i)
                            z_axis[i] *= -1.0;
                        
                    update_normal = FALSE;
                }
            }
        }
    }

    if (update_normal)
    {
        EFget_last_point_normal (z_axis);
  
        MAdotvc (&msg_loc, z_axis, x_axis, &dotval);

        if ((dotval < -MAETA) || (dotval > MAETA))
        {
            EMorthovec (x_axis, z_axis);
            EFget_out_vector (z_axis);
        }
    }

    BScrossp (&msg_loc, z_axis, x_axis, y_axis);
    BSnorvec (&msg_loc, y_axis);

    return (om_msg);
}

%safe
static struct IGRbsp_curve   * EMautodim_curve   = NULL;
%endsafe

void EFget_curve_buffer (order, num_poles, rational, num_boundaries, buffer)
    IGRint                 order;
    IGRint                 num_poles;
    IGRboolean             rational;
    IGRint                 num_boundaries;
    struct IGRbsp_curve ** buffer;
{
    IGRlong     msg_loc;

    if (EMautodim_curve)
    {
        /*
         * If the curve isn't big enough trash it and realloc.
         */
        if ( (EMautodim_curve->order < order)                   ||
             (EMautodim_curve->num_poles < num_poles)           ||
             (EMautodim_curve->num_boundaries < num_boundaries) ||
             ((EMautodim_curve->rational == FALSE) && (rational == TRUE)) )
        {
            BSfreecv (&msg_loc, EMautodim_curve);
            EMautodim_curve = NULL;
        }
    }

    if (!EMautodim_curve)
    {
        /*
         * Allocate memory for the curve.
         */
        BSalloccv ( order, num_poles, rational, num_boundaries, &EMautodim_curve, &msg_loc);
    }

    *buffer = EMautodim_curve;
}

end implementation EMSdim;
