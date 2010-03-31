/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for solid blocks and wedges.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha  07/01/93	    Modified for BSprototypes ansification
 */

class implementation EMSpolyhdrn;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "REpolyhdrn.h"
#include "dimplcmacros.h"
#include "ma.h"
#include "mascalvc.h"
#include "bserr.h"
#include "bsnorvec.h"

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

#define X_BOX       0
#define Y_BOX       1
#define Z_BOX       2

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
    IGRint        i, trak_dir;
    struct GRid   assoc_id, source_id, dim_id;
    IGRpoint      dumpt;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2];

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    switch (type)
    {
        case EMS_ASsolid_box_by_4pts:
        case EMS_ASsolid_right_angle_wedge:
        case EMS_ASsolid_right_angle_wedge1:
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

                    if (type == EMS_ASsolid_box_by_4pts)
                    {
                        trak_dir = !(i==LENGTH);
                    }
                    else
                    {
                        struct EMSgeomdata  vector;
                        
                        om_msg = om$send ( msg = message EMSparamgm.EMgetgeom
                                                            ( &msg_loc,
                                                              NULL,
                                                              &mod_env->md_env.matrix_type,
                                                              mod_env->md_env.matrix,
                                                              &vector ),
                                           targetid = parents[i+1].objid,
                                           targetos = parents[i+1].osnum );

                        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

                        trak_dir = (EFis_negative (vector.vector));
                    }

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

        case EMS_ASsolid_box_by_2pts:
            for (i=TWO_WIDTH; i<=TWO_LENGTH; ++i)
            {
                /*
                 * If this parameter is not already dimensioned ...
                 */
                if (!( EFselect_first_component ( &parents[i], 
                                                  OPP_DMroot_class_id, 
                                                  &dim_id ) & 1) )
                {
                    dim_id.objid = NULL_OBJID;

                    trak_dir = !(i==TWO_LENGTH);

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

        default:
            break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMSpolyhdrn.EMdim");

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
    IGRdouble            values[3];
    IGRpoint             base;
    struct EMSgeomdata   base_point, vector[3];
    IGRpoint             points[3];
    IGRvector            vectors[3];

    *msg = EMS_S_Success;

    om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                ( &msg_loc, 
                                                  NULL,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &base_point ), 
                       targetid = parents[BASE].objid,
                       targetos = parents[BASE].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    memcpy (base, base_point.point, sizeof(IGRpoint));

    if (type == EMS_ASsolid_box_by_2pts)
    {
        struct EMSgeomdata diagonal;

        for (i=0,j=TWO_WIDTH; i<3; ++i, ++j)
        {
            om_msg = om$send ( msg = message expression.NDgive_value  ( &values[i]),
                               targetid = parents[j].objid,
                               targetos = parents[j].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
        }

        om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                ( &msg_loc, 
                                                  NULL,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &diagonal ), 
                           targetid = parents[TWO_DIRECTION].objid,
                           targetos = parents[TWO_DIRECTION].osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        for (i=0; i<3; ++i)
            for (j=0; j<3; ++j)
                if (i==j)
                    vectors[i][j] = (diagonal.vector[i] > 0.0) ?
                        values[i] : -values[i];
                else
                    vectors[i][j] = 0.0;

        /* Transform the 2pt index into a 4pt index. */
        if (index) index += (index - 1);
    }
    else /* Box by 4 points or Wedge */
    {
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
    }

    if (type != EMS_ASsolid_right_angle_wedge &&
        type != EMS_ASsolid_right_angle_wedge1)
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

                default:
                    memcpy (dim_plane_xaxis, vectors[Y_BOX], sizeof(IGRpoint));
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
        case WIDTH:
        case HEIGHT:
        case LENGTH:
            memcpy (dim_geom->line.line_pt1, base, sizeof(IGRpoint));
            memcpy (dim_geom->line.line_pt2, points[index/2], sizeof(IGRpoint));

            if ((type != EMS_ASsolid_right_angle_wedge &&
                 type != EMS_ASsolid_right_angle_wedge1) && (index == LENGTH))
            {
                /*
                 * Adjust the length (z axis) so it's dimensioned at the
                 * outer edge of the box rather that from the base point.
                 */
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
    
ret_end:

    EMWRAPUP (*msg, om_msg, "EMSpolyhdrn.EMdimparam");

    return (om_msg);
}

end implementation EMSpolyhdrn;
