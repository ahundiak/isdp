/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for associative spheres.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMAsphere;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "bsconic.h"
#include "dimplcmacros.h"
#include "bscirc3pts.h"

#define CENTER 0
#define RADIUS 1

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;

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

    /*
     * If the radius is not already dimensioned ...
     */
    if (!( EFselect_first_component ( &parents[RADIUS], 
                                      OPP_DMroot_class_id, 
                                      &dim_id ) & 1) )
    {
        dim_id.objid = NULL_OBJID;

        dm$place_radial  ( orig_grid  = &source_id,
                           orig_pt    = dumpt,
                           plane_grid = &source_id,
                           owner      = &parents[RADIUS],
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
    IGRlong             msg_loc, om_msg = OM_S_SUCCESS;
    IGRdouble           r, p1[3], p2[3], p3[3], normal[3];
    struct EMSgeomdata  center;

    *msg = EMS_S_Success;

    /*
     * Get the center of the sphere.
     */
    om_msg = om$send ( msg = message EMSparamgm.EMgetgeom ( &msg_loc, 
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &center ), 
                       targetid = parents[CENTER].objid,
                       targetos = parents[CENTER].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Set the dimension type.
     */
    if (dim_type)
    {
        *dim_type = RADIAL;
    }

    /*
     * Determine the normal;
     */
    normal[0] = normal[1] = 0.0; normal[2] = 1.0;

    /*
     * Determine the dimension plane, the x-y plane at center point.
     */
    if (dim_plane)
    {
        memcpy (dim_plane->point, center.point, sizeof(IGRpoint));
        memcpy (dim_plane->normal, normal, sizeof(IGRvector));
    }

    /*
     * Set x_axis, this is the actual x-axis.
     */
    if (dim_plane_xaxis)
    {
        dim_plane_xaxis[0] = 1.0; dim_plane_xaxis[1] = dim_plane_xaxis[2] = 0.0;
    }

    /*
     * Return a circle for the RADIAL dimension.
     */
    if (dim_geom)
    {
        if (index == CENTER)
        {
            *dim_geom = center;
        }
        else /* index == RADIUS */
        {
            om_msg = om$send ( msg = message expression.NDgive_value (&r),
                               targetid = parents[RADIUS].objid,
                               targetos = parents[RADIUS].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            dim_geom->geomtype = GEOMDATA_CURVE;

            /*
             * Determine three points on the circle.
             */
            memcpy (p1, center.point, sizeof(IGRpoint));
            p1[0] += r;

            memcpy (p2, center.point, sizeof(IGRpoint));
            p2[0] -= r;

            memcpy (p3, center.point, sizeof(IGRpoint));
            p3[1] += r;

            /*
             * Get a buffer for the curve.
             */
            EFget_curve_buffer ( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &dim_geom->curve);

            /*
             * Fill in the curve structure.
             */
            BScirc3pts(&msg_loc, p1, p2, p3, dim_geom->curve);
        }
    }

ret_end:

  EMWRAPUP (*msg, om_msg, "EMAsphere.EMdimparam");

  return (om_msg);
}

end implementation EMAsphere;
