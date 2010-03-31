/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for associative cylinders.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMAcylindr;

#include "OMmacros.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "EMSdimdef.h"
#include "mascalvc.h"

#define BASE        0
#define HEIGHT      1
#define DIRECTION   2
#define DIAMETER    3

from EMSparamgm  import EMgetgeom;
from expression  import NDgive_value;

extern OMuword OPP_DMroot_class_id;

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong             om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid         assoc_id, source_id, dim_id;
    IGRpoint            dumpt;
    IGRint              trak_dir, axis;
    struct EMSgeomdata  direction;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    /*
     * Dimension the height if it hasn't already been done.
     */
    if (!(EFselect_first_component (&parents[HEIGHT], 
                                    OPP_DMroot_class_id, 
                                    &dim_id) & 1))
    {
        dim_id.objid = NULL_OBJID;
        trak_dir = 1;

        dm$place_sglpara ( orig_grid    = &source_id,
                           orig_pt      = dumpt,
                           plane_grid   = &source_id,
                           trak_dir     = trak_dir,
                           owner        = &parents[HEIGHT],
                           dim_grid     = &dim_id );

        EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
    }

    /*
     * Get the normalized direction vector.
     */
    om_msg = om$send (msg = message EMSparamgm.EMgetgeom  ( &msg_loc, 
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &direction ), 
                      targetid = parents[DIRECTION].objid,
                      targetos = parents[DIRECTION].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Dimension the diameter if it hasn't already been done.
     */
    if (!(EFselect_first_component (&parents[DIAMETER], 
                                    OPP_DMroot_class_id, 
                                    &dim_id) & 1) )
    {
        dim_id.objid = NULL_OBJID;
        trak_dir = EFis_negative (direction.vector);
        axis = 0;
        
        dm$place_lindia  ( orig_grid  = &source_id,
                           orig_pt    = dumpt,
                           meas_grid  = &source_id,
                           meas_pt    = dumpt,
                           plane_grid = &source_id,
                           trak_dir   = trak_dir,
                           axis       = axis,
                           owner      = &parents[DIAMETER],
                           dim_grid   = &dim_id );

        EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAcylindr.EMdim");

    return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort    options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
    IGRint              i;
    IGRlong             msg_loc, om_msg = OM_S_SUCCESS;
    IGRdouble           height, radius;
    IGRvector           x_axis, y_axis, z_axis;
    IGRvector           height_vector;
    struct EMSgeomdata  base, direction;
    IGRdouble         * base_point;
    IGRpoint            height_point;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    /*
     * Get the base point.
     */
    om_msg = om$send ( msg = message EMSparamgm.EMgetgeom ( &msg_loc, 
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &base ), 
                       targetid = parents[BASE].objid,
                       targetos = parents[BASE].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Get the height value.
     */
    om_msg = om$send ( msg = message expression.NDgive_value  ( &height),
                       targetid = parents[HEIGHT].objid,
                       targetos = parents[HEIGHT].osnum );

    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

    /*
     * Get the normalized direction vector.
     */
    om_msg = om$send (msg = message EMSparamgm.EMgetgeom  ( &msg_loc, 
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &direction ), 
                      targetid = parents[DIRECTION].objid,
                      targetos = parents[DIRECTION].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Determine the height point.
     */
    memcpy (x_axis, direction.vector, sizeof(IGRvector));
    base_point = base.point;
    MAscalvc ( &msg_loc, &height, x_axis, height_vector);
    for (i=0; i<3; ++i)
        height_point[i] = base_point[i] + height_vector[i];

    /*
     * Obtain the basic orientation triad for this cylinder.
     */
    EFget_normal_from_axis ( &msg_loc, 
                             &parents[HEIGHT], 
                             mod_env, 
                             x_axis,  /* In/Out */
                             y_axis, 
                             z_axis );
    /*
     * Depending on the parameter, format appropriate 
     * outputs.
     */
    if (dim_type)
    {
        *dim_type = (index == DIAMETER) ? LINEAR_DIAMETER : SINGLE_PARALLEL;
    }

    if (dim_plane)
    {

        memcpy (dim_plane->point, (index == HEIGHT) ? height_point : base_point, sizeof(IGRpoint));
        memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
    }

    if (dim_plane_xaxis)
    {
        memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));
    }

    if (dim_geom)
    {
        om_msg = om$send ( msg = message expression.NDgive_value (&radius),
                           targetid = parents[DIAMETER].objid,
                           targetos = parents[DIAMETER].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
        radius /= 2.0;

        dim_geom->geomtype = GEOMDATA_LINE;
        dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
        dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

        if (index == HEIGHT)
        {
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = base_point[i] - (radius * y_axis[i]);
                dim_geom->line.line_pt2[i] = height_point[i] - (radius * y_axis[i]);
            }
        }
        else if (index == DIAMETER)
        {
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = height_point[i] + (radius * y_axis[i]);
                dim_geom->line.line_pt2[i] = height_point[i] - (radius * y_axis[i]);
            }
        }
	else if (index == DIRECTION)
	{
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = base_point[i] - (height_vector[i] * DISPAXIS_FACTOR);
                dim_geom->line.line_pt2[i] = height_point[i] + (height_vector[i] * DISPAXIS_FACTOR);
            }
	}
	else /* index == BASE */
	{
	    *dim_geom = base;
	}
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAcylindr.EMdimparam");
 
    return (om_msg);
}

end implementation EMAcylindr;
