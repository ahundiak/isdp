/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for an associative torus.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMAtorus;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "bsconic.h"
#include "dimplcmacros.h"
#include "mascalvc.h"
#include "bsproj0.h"
#include "bsprepcirc.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define AXIS_ORIGIN     0
#define AXIS_DIRECTION  1
#define CENTER          2
#define RADIUS          3

from EMSparamgm import  EMgetgeom;
from expression import  NDgive_value;

extern OMuword OPP_DMroot_class_id;

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong       om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid   assoc_id, source_id, dim_id;
    IGRpoint      dumpt;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    switch (type)
    {
        case EMS_AStorus_by_axis_center_and_radius:
            /*
             * If the torus radius is not already dimensioned ...
             */
            if (!( EFselect_first_component ( &parents[RADIUS], 
                                              OPP_DMroot_class_id, 
                                              &dim_id ) & 1) )
            {
                dim_id.objid = NULL_OBJID;

                dm$place_radial  ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   brk_pos    = BRK_RIGHT,
                                   owner      = &parents[RADIUS],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }
            break;

        default:
            goto ret_end;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAtorus.EMdim");

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
    IGRlong              msg_loc, om_msg = OM_S_SUCCESS;
    struct EMSgeomdata   geom[4];
    IGRdouble          * center, * origin, * direction, radius;
    IGRpoint             point, points[2];
    IGRvector            vector, normal;
    IGRint               i;

    *msg = msg_loc = EMS_S_Success;

    origin    = geom[AXIS_ORIGIN].point;
    direction = geom[AXIS_DIRECTION].vector;
    center    = geom[CENTER].point;

    /*
     * Get the origin, direction, and center of the torus.
     */
    for (i=AXIS_ORIGIN; i<RADIUS; ++i)
    {
        om_msg = om$send ( msg = message EMSparamgm.EMgetgeom ( &msg_loc, 
                                                                NULL,
                                                                &mod_env->md_env.matrix_type,
                                                                mod_env->md_env.matrix,
                                                                &geom[i] ), 
                           targetid = parents[i].objid,
                           targetos = parents[i].osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    /*
     * Get the radius.
     */
    om_msg = om$send ( msg = message expression.NDgive_value (&radius),
                       targetid = parents[RADIUS].objid,
                       targetos = parents[RADIUS].osnum );

    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

    /*
     * Project the torus body's center onto the axis.
     */
    memcpy (points, origin, sizeof(IGRpoint));
    for (i=0; i<3; ++i)
        points[1][i] = origin[i] + direction[i];
        
    BSproj0 (&msg_loc, center, points, point);
    
    /*
     * Determine the vector from the axis center to the body center and
     * scale it to be the length of the radius.
     */
    for (i=0; i<3; ++i)
        vector[i] = center[i] - point[i];
    BSnorvec (&msg_loc, vector);
    MAscalvc (&msg_loc, &radius, vector, vector);

    /*
     * Cross this vector with the axis vector to determine the plane normal.
     */
    BScrossp (&msg_loc, direction, vector, normal);
    EFget_out_vector(normal);

    /*
     * Set the dimension type.
     */
    if (dim_type)
        *dim_type = RADIAL;

    /*
     * Return the dimension plane.
     */
    if (dim_plane)
    {
        for (i=0; i<3; ++i)
            dim_plane->point[i] = center[i] + vector[i];
        memcpy (dim_plane->normal, normal, sizeof(IGRvector));
    }

    /*
     * Return the dimension x axis.
     */
    if (dim_plane_xaxis)
        memcpy (dim_plane_xaxis, vector, sizeof(IGRvector));

    /*
     * Return the dimension geometry.
     */
    if (dim_geom)
    {
        switch (index)
        {
        case AXIS_ORIGIN:
        case CENTER:
            *dim_geom = geom[index];
            break;

        case AXIS_DIRECTION:
            MAscalvc (&msg_loc, &radius, direction, vector);
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = point[i] + (vector[i] * 1.5);
                dim_geom->line.line_pt2[i] = point[i] - (vector[i] * 1.5);
            }
            break;

        case RADIUS:
        {
            struct IGRbsp_curve * curve;
            IGRint                bstype;

            /*
             * Allocate memory for the curve.
             */
            EFget_curve_buffer ( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &curve);

            /*
             * Fill in the curve structure.
             */
            BSprepcirc (&msg_loc, center, &radius, normal, curve, vector, &bstype);

            dim_geom->geomtype = GEOMDATA_CURVE;
            dim_geom->curve = curve;
        }
            break;

        default:
            break;
        }
    }
    
ret_end:

  EMWRAPUP (*msg, om_msg, "EMAtorus.EMdimparam");

  return (om_msg);
}

end implementation EMAtorus;
