/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for associative elliptical
 *  cylinders.
 *
 * HISTORY:
 *
 *  Aditya    Creation        05/25/95
 *
 */
class implementation EMAelpcyl;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "dimplcmacros.h"
#include "mascalvc.h"
#include "bserr.h"
#include "bscrossp.h"

#define BASE              0
#define HEIGHT            1
#define DIRECTION         2
#define MAJOR_AXIS        3
#define MINOR_AXIS        4
#define BASE_MAJOR_DIR    5

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
    IGRlong             msg_loc, om_msg = OM_S_SUCCESS;
    struct GRid         assoc_id, source_id, dim_id;
    IGRint              trak_dir;
    IGRpoint            dumpt;
    struct EMSgeomdata  direction;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;


    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);
            /*
             * Get the normalized direction vector.
             */
            om_msg = om$send (msg = message EMSparamgm.EMgetgeom  
                                                    ( &msg_loc, 
                                                      NULL,
                                                      &mod_env->md_env.matrix_type,
                                                      mod_env->md_env.matrix,
                                                      &direction ), 
                      targetid = parents[DIRECTION].objid,
                      targetos = parents[DIRECTION].osnum );

            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            /*
             * Dimension the height if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HEIGHT], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = -1;

                 dm$place_sglpara ( orig_grid = &source_id,
                                        orig_pt    = dumpt,
                                        plane_grid = &source_id,
                                        trak_dir   = trak_dir,
                                        owner      = &parents[HEIGHT],
                                        dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            /*
             * Dimension the base diameter if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[MAJOR_AXIS], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {
                dim_id.objid = NULL_OBJID;
                trak_dir = !EFis_negative (direction.vector);
    
                dm$place_sglpara  ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &parents[MAJOR_AXIS],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }
            /*
             * Dimension the height diameter if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[MINOR_AXIS], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = !EFis_negative (direction.vector);
    
                dm$place_sglpara ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &parents[MINOR_AXIS],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAelpcyl.EMdim");

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
    IGRint                  i;
    IGRlong                 msg_loc, om_msg;
    IGRdouble               height, major_axis, minor_axis, radius;
    IGRvector               x_axis, y_axis, z_axis;
    IGRvector               height_vector;
    struct EMSgeomdata      base, direction, base_maj_dir;
    IGRpoint                height_point, major_axis_pt;
    IGRdouble             * point = NULL, * base_point = NULL, * axis = NULL;

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
     * Get the normalized major axis direction vector.
     */
    om_msg = om$send (msg = message EMSparamgm.EMgetgeom  ( &msg_loc,
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &base_maj_dir),
                      targetid = parents[BASE_MAJOR_DIR].objid,
                      targetos = parents[BASE_MAJOR_DIR].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    memcpy (z_axis, base_maj_dir.vector, sizeof(IGRvector));

    BScrossp(&msg_loc, z_axis, x_axis, y_axis);
    EMerr_hndlr ( msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    /* Get the values of the major_axis and minor_axis */
    om_msg = om$send ( msg = message expression.NDgive_value (&major_axis),
                               targetid = parents[MAJOR_AXIS].objid,
                               targetos = parents[MAJOR_AXIS].osnum );

    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

    om_msg = om$send ( msg = message expression.NDgive_value (&minor_axis),
                               targetid = parents[MINOR_AXIS].objid,
                               targetos = parents[MINOR_AXIS].osnum );

    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

    for(i=0;i<3;i++)
          major_axis_pt[i] = base_point[i] + (base_maj_dir.vector[i] * major_axis);

    /*
     * Depending on the parameter, format appropriate 
     * outputs. For elliptical cylinder all dimensions are 
     * single parallel.
     */
    if (dim_type) *dim_type = SINGLE_PARALLEL;

    if (dim_plane)
    {
        if ((index == HEIGHT) || (index == MINOR_AXIS))
        {
            memcpy (dim_plane->point, base_point, sizeof(IGRpoint));
            memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
        }
        else
        {
            memcpy (dim_plane->point, base_point, sizeof(IGRpoint));
            memcpy (dim_plane->normal, y_axis, sizeof (IGRvector));
        }

    }

    if (dim_plane_xaxis) memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));

    if (dim_geom)
    {
        switch (index)
        {
        case HEIGHT:
        case MAJOR_AXIS:
        case MINOR_AXIS: 

            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

            switch (index)
            {
              case HEIGHT:
                memcpy (dim_geom->line.line_pt1, base_point, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2, height_point, sizeof(IGRpoint));
                for (i=0; i<3; i++)
                {
                    dim_geom->line.line_pt1[i] += minor_axis * y_axis[i];
                    dim_geom->line.line_pt2[i] += minor_axis * y_axis[i];
                }
                break;

              case MAJOR_AXIS:
              case MINOR_AXIS: 

                  if(index == MAJOR_AXIS)
                  {
                    point = base_point;
                    radius = major_axis;
                    axis = (IGRdouble *)&z_axis[0];
                  }
                  else
                  {
                    point = base_point;
                    radius = minor_axis;
                    axis =(IGRdouble *)&y_axis[0];
                  }

                memcpy (dim_geom->line.line_pt1, point, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2, point, sizeof(IGRpoint));

                for (i=0; i<3; ++i) /* dimension semi_major/minor axis */
                {
                    dim_geom->line.line_pt1[i] -= radius * axis[i];
                }

                break;
            }
            break;

        case BASE:
            *dim_geom = base;
            break;

        case DIRECTION:
            for (i=0; i<3; ++i)
            {
                dim_geom->geomtype = GEOMDATA_LINE;
                dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
                dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
                dim_geom->line.line_pt1[i] = base_point[i] - (height_vector[i] * DISPAXIS_FACTOR);
                dim_geom->line.line_pt2[i] = height_point[i] + (height_vector[i] * DISPAXIS_FACTOR);
         
            }
            break;

        case BASE_MAJOR_DIR:
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = base_point[i] - (base_maj_dir.vector[i] * DISPAXIS_FACTOR);
                dim_geom->line.line_pt2[i] = major_axis_pt[i] + (base_maj_dir.vector[i] * DISPAXIS_FACTOR);
            }
            break;
        }
    }

ret_end:

  EMWRAPUP (*msg, om_msg, "EMAelpcyl.EMdimparam");

  return (om_msg);
}

end implementation EMAelpcyl;
