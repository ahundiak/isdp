/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for associative cones.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 *  Aditya  06/14/95    Added code for auto-dimensioning elliptical cones.
 */
class implementation EMAelpcone;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "dimplcmacros.h"
#include "mascalvc.h"
#include "bserr.h"
#include "bscrossp.h"

#define BASE            0
#define HEIGHT          1
#define DIRECTION       2
#define BASE_DIAMETER   3      /* Base major axis for elliptical cone */
#define HEIGHT_DIAMETER 4      /* Base minor axis for elliptical cone */
#define BASE_MAJOR_DIR  5
#define HT_MAJOR_AXIS   6      /* For elliptical cone */

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
    IGRint              trak_dir, axis;
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

       switch(type)
       {
        case EMS_AScone_by_axis_and_diameters:

            /*
             * Dimension the height if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HEIGHT], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = -1;

                dm$place_sglpara ( orig_grid  = &source_id,
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
            if (!(EFselect_first_component (&parents[BASE_DIAMETER], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = !EFis_negative (direction.vector);
                axis = 0;
    
                dm$place_lindia  ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   meas_grid  = &source_id,
                                   meas_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   axis       = axis,
                                   owner      = &parents[BASE_DIAMETER],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            /*
             * Dimension the height diameter if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HEIGHT_DIAMETER], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
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
                                   owner      = &parents[HEIGHT_DIAMETER],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            break;

       case EMS_ASright_elliptical_cone:
            /*
             * Dimension the height if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HEIGHT], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = 1;

                dm$place_sglpara ( orig_grid  = &source_id,
                                        orig_pt    = dumpt,
                                        plane_grid = &source_id,
                                        trak_dir   = trak_dir,
                                        owner      = &parents[HEIGHT],
                                        dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            /*
             * Dimension the major axis if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[BASE_DIAMETER], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = !EFis_negative (direction.vector);
    
                dm$place_sglpara  ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &parents[BASE_DIAMETER],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            /*
             * Dimension the minor axis if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HEIGHT_DIAMETER], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = EFis_negative (direction.vector);
    
                dm$place_sglpara  ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &parents[HEIGHT_DIAMETER],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }

            /*
             * Dimension the height major axis if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[HT_MAJOR_AXIS], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {   
                dim_id.objid = NULL_OBJID;
                trak_dir = EFis_negative (direction.vector);
    
                dm$place_sglpara ( orig_grid  = &source_id,
                                   orig_pt    = dumpt,
                                   plane_grid = &source_id,
                                   trak_dir   = trak_dir,
                                   owner      = &parents[HT_MAJOR_AXIS],
                                   dim_grid   = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
            }
            break;
       }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAelpcone.EMdim");

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
    IGRdouble               height, base_radius, height_radius, radius;
    IGRvector               x_axis, y_axis, z_axis;
    IGRvector               height_vector;
    struct EMSgeomdata      base, direction,base_maj_dir;
    IGRpoint                height_point;
    IGRdouble             * point, * base_point;
    IGRdouble               ht_major_axis, * axis = NULL;

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

   if(type == EMS_AScone_by_axis_and_diameters)
   {
    /*
     * Obtain the basic orientation triad for this cone.
     */
    EFget_normal_from_axis ( &msg_loc,
                             &parents[HEIGHT],
                             mod_env,
                             x_axis,  /* In/Out */
                             y_axis,
                             z_axis );
   }
   else{
    /*
     * Get the normalized base major axis direction vector.
     */
    om_msg = om$send (msg = message EMSparamgm.EMgetgeom  ( &msg_loc, 
                                                            NULL,
                                                            &mod_env->md_env.matrix_type,
                                                            mod_env->md_env.matrix,
                                                            &base_maj_dir),
                      targetid = parents[BASE_MAJOR_DIR].objid,
                      targetos = parents[BASE_MAJOR_DIR].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    memcpy (y_axis, base_maj_dir.vector, sizeof(IGRvector));

    BScrossp(&msg_loc, x_axis, y_axis, z_axis);
    EMerr_hndlr ( msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
   }


    /*
     * Depending on the parameter, format appropriate 
     * outputs.
     */
    if (dim_type)
    {
        if(type == EMS_ASright_elliptical_cone) *dim_type = SINGLE_PARALLEL;
        else
          *dim_type = (index == HEIGHT) ? SINGLE_PARALLEL : LINEAR_DIAMETER;
    }

    if (dim_plane)
    {
        if (index == HEIGHT_DIAMETER) /*also minor_axis*/
        {
            memcpy (dim_plane->point, height_point, sizeof(IGRpoint));
            if(type == EMS_AScone_by_axis_and_diameters)
            {
                   memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
            }
            else memcpy (dim_plane->normal, y_axis, sizeof (IGRvector));
        }
        else if(index == HEIGHT || index == BASE_DIAMETER || index == HT_MAJOR_AXIS)
        {
                 memcpy (dim_plane->point, base_point, sizeof(IGRpoint));
                 memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
        }
    }

    if (dim_plane_xaxis)
    {
        memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));
    }

    if (dim_geom)
    {
        om_msg = om$send ( msg = message expression.NDgive_value (&base_radius),
                          targetid = parents[BASE_DIAMETER].objid,
                          targetos = parents[BASE_DIAMETER].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        switch (index)
        {
        case HEIGHT:
        case BASE_DIAMETER:
        case HEIGHT_DIAMETER:
        case HT_MAJOR_AXIS:

            om_msg = om$send ( msg = message expression.NDgive_value (&height_radius),
                               targetid = parents[HEIGHT_DIAMETER].objid,
                               targetos = parents[HEIGHT_DIAMETER].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            if( type == EMS_ASright_elliptical_cone)
            {
               om_msg = om$send ( msg = message expression.NDgive_value (&ht_major_axis),
                                  targetid = parents[HT_MAJOR_AXIS].objid,
                                  targetos = parents[HT_MAJOR_AXIS].osnum );

               EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
            }
            else
            {
                 height_radius /= 2.0;
                 base_radius /= 2.0;
            }

            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

            switch (index)
            {
            case HEIGHT:
                memcpy (dim_geom->line.line_pt1, base_point, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2, height_point, sizeof(IGRpoint));
                axis = (IGRdouble *) &y_axis[0];
                if(type == EMS_ASright_elliptical_cone )
                {
                    /* The way the height dimension is placed, the 
                     * base_minor_axis( = base_radius) and the ht_minor_axis 
                     * (from the proportional conversion below) are required.
                     */

                    height_radius = ht_major_axis;
                }

                for (i=0; i<3; i++)
                {
                    dim_geom->line.line_pt1[i] -= base_radius * axis[i];
                    dim_geom->line.line_pt2[i] -= height_radius * axis[i];
                }
                break;

            case BASE_DIAMETER:
            case HEIGHT_DIAMETER:
                if (index == BASE_DIAMETER)
                {
                    point = base_point;
                    radius = base_radius;
                    axis = (IGRdouble *) &y_axis[0];
                }
                else
                {
                    if(type == EMS_ASright_elliptical_cone )
                    {
                        point = base_point;
                        axis = (IGRdouble *) &z_axis[0];
                    }
                    else{
                        point = height_point;
                        axis = (IGRdouble *) &y_axis[0];
                    }
                    radius = height_radius;
                }

                memcpy (dim_geom->line.line_pt1, point, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2, point, sizeof(IGRpoint));

                for (i=0; i<3; ++i)
                {
                    dim_geom->line.line_pt1[i] -= radius * axis[i];
                    if( type == EMS_AScone_by_axis_and_diameters)
                            dim_geom->line.line_pt2[i] += radius * axis[i];
                }
                break;

            case HT_MAJOR_AXIS:  /* place semi_ht_major_axis dimension */
                memcpy (dim_geom->line.line_pt1,height_point, sizeof(IGRpoint));
                memcpy (dim_geom->line.line_pt2,height_point, sizeof(IGRpoint));

                for (i=0; i<3; ++i)
                    dim_geom->line.line_pt2[i] -= ht_major_axis * y_axis[i];

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
           if(type == EMS_ASright_elliptical_cone)
           {
             dim_geom->geomtype = GEOMDATA_LINE;
             dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
             dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
            for (i=0; i<3; ++i)
            {
                dim_geom->line.line_pt1[i] = base_point[i] - (base_maj_dir.vector[i] * DISPAXIS_FACTOR);
                dim_geom->line.line_pt2[i] = base_point[i] +  base_maj_dir.vector[i] * (DISPAXIS_FACTOR + base_radius);
            }
           }
            break;
        }
    }

ret_end:

  EMWRAPUP (*msg, om_msg, "EMAelpcone.EMdimparam");

  return (om_msg);
}

end implementation EMAelpcone;
