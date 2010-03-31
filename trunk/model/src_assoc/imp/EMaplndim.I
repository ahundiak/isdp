/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for associative planes.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMAplane;

#include "OMmacros.h"
#include "dimdef.h"
#include "REplane.h"
#include "EMSdimdef.h"
#include "dimplcmacros.h"
#include "mascalvc.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4

#define X_BOX       0
#define Y_BOX       1

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
    IGRlong       om_msg = OM_S_SUCCESS, msg_loc;
    IGRint        i, trak_dir;
    struct GRid   assoc_id, source_id, dim_id;
    IGRpoint      dumpt;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    switch (type)
    {
        case EMS_ASplane_by_3pts:
        case EMS_ASparallelogram_by_3pts:
            for (i=WIDTH; i<4; i+=2)
            {
                /*
                 * If this parameter is not already dimensioned ...
                 */
                if (!( EFselect_first_component ( &parents[i], 
                                                  OPP_DMroot_class_id, 
                                                  &dim_id ) & 1) )
                {
                    dim_id.objid = NULL_OBJID;
                    trak_dir = 1;

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

        case EMS_ASplane_tangent_to_surface:
        case EMS_ASplane_tangent_to_curve:
        case EMS_ASplane_normal_to_curve:
        case EMS_ASplane_encompassing_curves:
        default:
            break;
    }        

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAplane.EMdim");

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
    IGRdouble          * base, values[2];
    struct EMSgeomdata   base_point, vector[2];
    IGRpoint             points[2];
    IGRvector            vectors[2];

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

    base = base_point.point;

    for (i=0,j=WIDTH,k=WIDTH_VEC; i<2; ++i, j+=2, k+=2)
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

    EFget_dim_box (base, vectors[X_BOX], vectors[Y_BOX], NULL);

    for (i=0; i<2; ++i)
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
        for (i=0; i<2; ++i)
            BSnorvec (&msg_loc, vectors[i]);

        if (dim_plane)
        {
            memcpy ( dim_plane->point, points[index/2], sizeof(IGRpoint));

            BScrossp (&msg_loc, vectors[X_BOX], vectors[Y_BOX], dim_plane->normal);
            
            if (EFis_negative(dim_plane->normal))
                for (i=0; i<3; ++i) 
                    dim_plane->normal[i] *= -1;
        }

        if (dim_plane_xaxis)
        {
            switch (index)
            {
                case WIDTH:
                    for (i=0; i<3; ++i)
                        dim_plane_xaxis[i] = (vectors[X_BOX][i] * -1);
                    break;

                case HEIGHT:
                    memcpy (dim_plane_xaxis, vectors[Y_BOX], sizeof(IGRpoint));
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
            memcpy (dim_geom->line.line_pt1, base, sizeof(IGRpoint));
            memcpy (dim_geom->line.line_pt2, points[index/2], sizeof(IGRpoint));
            break;

        case BASE:
            *dim_geom = base_point;
            break;
    
        case WIDTH_VEC:
        case HEIGHT_VEC:
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = base[i] - (vectors[(index/2)-1][i] * DISPAXIS_FACTOR);
                dim_geom->line.line_pt2[i] = points[index/2][i] + (vectors[(index/2)-1][i] * DISPAXIS_FACTOR);
            }
            break;
        }
    }
    
ret_end:

    EMWRAPUP (*msg, om_msg, "EMAplane.EMdimparam");

    return (om_msg);
}

end implementation EMAplane;
