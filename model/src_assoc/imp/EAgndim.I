/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for general bspline surfaces.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *
 *  Sudha	06/01/93	modified to add BSprototype headers
 *
 */
class implementation EMAgenbs;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "bsconic.h"
#include "dimplcmacros.h"
#include "mascalvc.h"
#include "bsprepcirc.h"
#include "bsnorvec.h"

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

#define LINESTRING  0
#define RADIUS      1

#define X_BOX       0
#define Y_BOX       1
#define Z_BOX       2

from GRlinear import GRgetpolyline;

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
    IGRint        i, trak_dir;
    IGRpoint      dumpt;
    struct GRid   assoc_id, source_id, dim_id;
    void          EFget_out_vector(), EFget_dim_box();

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    switch (type)
    {
        case EMS_ASbox_by_4pts:
            for (i=WIDTH; i<=LENGTH; i+=2)
            {
                /*
                 * If this parameter is not already dimensioned ...
                 */
                if (!( EFselect_first_component ( &parents[i], 
                                                  OPP_DMroot_class_id, 
                                                  &dim_id ) & 1) )
                {
                    dim_id.objid = NULL_OBJID;

                    trak_dir = !(i==LENGTH);

                    dm$place_sglpara ( orig_grid  = &source_id,
                                       orig_pt    = dumpt,
                                       plane_grid = &source_id,
                                       trak_dir   = trak_dir,
                                       owner      = &parents[i],
                                       dim_grid   = &dim_id );

                    EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
                }
            }
            break;

        case EMS_AStube_by_linear_and_radii:
            /*
             * If the tube radius is not already dimensioned ...
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
            break;

        default:
            break;
     }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAgenbs.EMdim");

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
    IGRint               i, j, k;
    IGRdouble          * base, values[3];
    struct EMSgeomdata   base_point, vector[3];
    IGRpoint             points[3];
    IGRvector            vectors[3];
    void          EFget_out_vector(),  EFget_dim_box();
    *msg = EMS_S_Success;

    if (type == EMS_ASbox_by_4pts)
    {
        om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                    ( &msg_loc, 
                                                      NULL,
                                                      &mod_env->md_env.matrix_type,
                                                      mod_env->md_env.matrix,
                                                      &base_point ), 
                           targetid = parents[BASE].objid,
                           targetos = parents[BASE].osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        base = base_point.point;

        for (i=0,j=WIDTH,k=WIDTH_VEC; i<3; ++i, j+=2, k+=2)
        {
            om_msg = om$send ( msg = message expression.NDgive_value  ( &values[i]),
                               targetid = parents[j].objid,
                               targetos = parents[j].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                    ( &msg_loc, 
                                                      NULL,
                                                      &mod_env->md_env.matrix_type,
                                                      mod_env->md_env.matrix,
                                                      &vector[i] ), 
                               targetid = parents[k].objid,
                               targetos = parents[k].osnum );

            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            MAscalvc (&msg_loc, &values[i], vector[i].vector, vectors[i]);
        }        

        EFget_dim_box (base, vectors[X_BOX], vectors[Y_BOX], vectors[Z_BOX]);

        for (i=0; i<3; ++i)
            for (j=0; j<3; ++j)
                points[i][j] = base[j] + vectors[i][j];

        /*
         * Depending on the parameter, format appropriate 
         * outputs.
         */
        if (dim_type)
        {
            *dim_type = SINGLE_PARALLEL;
        }

        if (dim_plane || dim_plane_xaxis)
        {
            for (i=0; i<3; ++i)
                BSnorvec (&msg_loc, vectors[i]);

            if (dim_plane)
            {
                memcpy ( dim_plane->point, points[index/2], sizeof(IGRpoint));

                if (index != LENGTH)
                {
                    memcpy (dim_plane->normal, vectors[Z_BOX], sizeof(IGRvector));
                }
                else
                {
                    for (i=0; i<3; ++i) 
                        dim_plane->normal[i] = (vectors[Y_BOX][i] * -1);
                }
            }

            if (dim_plane_xaxis)
            {
                switch (index)
                {
                    case WIDTH:
                    case WIDTH_VEC:
                        for (i=0; i<3; ++i)
                            dim_plane_xaxis[i] = (vectors[X_BOX][i] * -1);
                        break;

                    case HEIGHT:
                    case HEIGHT_VEC:
                        memcpy (dim_plane_xaxis, vectors[Y_BOX], sizeof(IGRpoint));
                        break;
                
                    case LENGTH:
                    case LENGTH_VEC:
                        memcpy (dim_plane_xaxis, vectors[Z_BOX], sizeof(IGRpoint));
                        break;
                }
            }
        }

        if (dim_geom)
        {
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

            switch (index)
            {
            case LENGTH:
            case WIDTH:
            case HEIGHT:
                memcpy (dim_geom->line.line_pt1, base, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2, points[index/2], sizeof(IGRpoint));

                if (index == LENGTH)
                {
                    for (i=0; i<3; ++i)
                    {
                        dim_geom->line.line_pt1[i] += vectors[X_BOX][i];
                        dim_geom->line.line_pt2[i] += vectors[X_BOX][i];
                    }
                }
                break;

            case BASE:
                *dim_geom = base_point;            
                break;

            case WIDTH_VEC:
            case HEIGHT_VEC:
            case LENGTH_VEC:
                for (i=0; i<3; ++i)
                {
                    dim_geom->line.line_pt1[i] = base[i] - (vectors[(index/2)-1][i] * DISPAXIS_FACTOR);
                    dim_geom->line.line_pt2[i] = points[(index/2)-1][i] + (vectors[(index/2)-1][i] * DISPAXIS_FACTOR);
                }
                break;
            }
        }
    }
    else if (type == EMS_AStube_by_linear_and_radii) 
    {
        IGRvector           vector;
        IGRdouble         * point1, * point2;
        struct GRid         line_id;
        struct IGRpolyline  polyline;
        IGRint              action;
        
        /*
         * Get the line string.
         */
        om_msg = om$send ( msg = message NDnode.ASreturn_go 
                                                ( &line_id,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix ),
                       targetid = parents[LINESTRING].objid,
                       targetos = parents[LINESTRING].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        /*
         * Get the number of points in from the linestring.
         */
        action = 0;
        om_msg = om$send ( msg = message GRlinear.GRgetpolyline 
                                                ( msg,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &action,
                                                  &polyline ),
                           targetid = line_id.objid,
                           targetos = line_id.osnum );

        EMerr_hndlr (EMSerror (om_msg & *msg), *msg, EMS_E_Fail, ret_end);

        /*
         * Allocate stack space for the points.
         */
        polyline.points = (IGRdouble *)alloca(polyline.num_points * sizeof(IGRpoint));

        /*
         * Get the points.
         */
        action = 1;
        om_msg = om$send ( msg = message GRlinear.GRgetpolyline 
                                                ( msg,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &action,
                                                  &polyline ),
                           targetid = line_id.objid,
                           targetos = line_id.osnum );

        EMerr_hndlr (EMSerror (om_msg & *msg), *msg, EMS_E_Fail, ret_end);

        if (dim_type) *dim_type = RADIAL;

        /*
         * Get the vector that points out at the beginning of the line string.
         */
        point1 = &polyline.points[3];
        point2 = polyline.points; 
        for (i=0; i<3; ++i)
            vector[i] = point2[i] - point1[i];

        /*
         * If this vector doesn't point in a positive direction try the vector
         * at the other end of the linestring.
         */
        if (EFis_negative (vector))
        {
            point1 = &polyline.points[(polyline.num_points - 2) * 3];
            point2 = &polyline.points[(polyline.num_points - 1) * 3];
            for (i=0; i<3; ++i)
                vector[i] = point2[i] - point1[i];

            /*
             * The positive vector and the second point will define the 
             * dimensioning plane.
             */
            EFget_out_vector (vector);
        } 

        if (dim_plane)
        {
            memcpy (dim_plane->point, point2, sizeof(IGRpoint));
            memcpy (dim_plane->normal, vector, sizeof(IGRvector));
        }

        if (dim_geom || dim_plane_xaxis)
        {
            if (index == RADIUS)
            {
                IGRlong               ma_msg;
                IGRint                bstype;
                IGRdouble             radius;
                struct IGRbsp_curve * curve;
                                
                om_msg = om$send ( msg = message expression.NDgive_value (&radius),
                                   targetid = parents[RADIUS].objid,
                                   targetos = parents[RADIUS].osnum );

                EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

                /*
                 * Get a buffer for the curve.
                 */
                EFget_curve_buffer ( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &curve);

                /*
                 * Fill in the curve structure.
                 */
                BSprepcirc (&ma_msg, point2, &radius, vector, curve, vector, &bstype);

                if (dim_geom)
                {
                    dim_geom->geomtype = GEOMDATA_CURVE;
                    dim_geom->curve = curve;
                }
                else
                {
                    for (i=0; i<3; ++i)
                        dim_plane_xaxis[i] = curve->poles[i] - point2[i];

                    EFget_out_vector (dim_plane_xaxis);
                }
            }
        }
    }
    
ret_end:

    EMWRAPUP (*msg, om_msg, "EMAgenbs.EMdimparam");

    return (om_msg);
}
end implementation EMAgenbs;
