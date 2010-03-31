/* ###################   APOGEE COMPILED   ################## */

/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for surfaces of revolution and
 *  projection.
 *
 * HISTORY:
 *
 *  Sudha     06/21/93   Modified to handle BSprototype ansification
 *  Tapadia - 05/15/92 : Suppport for symmetrically projecting in both 
 *			 directions normal to the profile
 *			 (EMS_ASsurf_of_proj_by_sym_dist)
 *			
 *  AMD    Fix for TR#91N3253     1/15/92
 *  jhw    Creation               06/12/91
 */

class implementation EMSswcompsf;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "bsconic.h"
#include "dimplcmacros.h"
#include "maptsxfor.h"
#include "maptlnpro.h"
#include "magrotmx.h"
#include "madegrad.h"
#include "mabcueval.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsarc_rot.h"

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define CURVE           0

#define REV_BASE        1
#define REV_DIRECTION   2
#define REV_START       3
#define REV_SWEEP       4

#define PRJ_HEIGHT      1
#define PRJ_DIRECTION   2

extern OMuword  OPP_DMroot_class_id;

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
    IGRint        trak_dir;
    IGRdouble     value;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2];

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    /*
     * Perform the appropriate auto-dimensioning.
     */
    switch (type)
    {
        case EMS_ASsurface_of_projection:
        case EMS_ASsurface_of_projection1:
	case EMS_ASsurf_of_proj_by_sym_dist:
            /*
             * Dimension the height if it hasn't already been done.
             */
            if (!(EFselect_first_component (&parents[PRJ_HEIGHT], 
                                            OPP_DMroot_class_id, 
                                            &dim_id) & 1))
            {
                dim_id.objid = NULL_OBJID;
                trak_dir = 1;

                dm$place_sglpara ( orig_grid    = &source_id,
                                   orig_pt      = dumpt,
                                   plane_grid   = &source_id,
                                   trak_dir     = trak_dir,
                                   owner        = &parents[PRJ_HEIGHT],
                                   dim_grid     = &dim_id );

                EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, 
			ret_end);
            }
            break;

        case EMS_ASsurface_of_revolution:
        case EMS_ASsurface_of_revolution1:
            om_msg = om$send ( msg = message expression.NDgive_value  ( &value ),
                               targetid = parents[REV_START].objid,
                               targetos = parents[REV_START].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            if (value != 0.0)
            {
                /*
                 * Dimension the start angle if it hasn't already been done.
                 */
                if (!(EFselect_first_component (&parents[REV_START], 
                                                OPP_DMroot_class_id, 
                                                &dim_id) & 1))
                {
                    dim_id.objid = NULL_OBJID;
                    trak_dir = 0;

                    dm$place_sglarc_angle( orig_grid  = &source_id,
                                           orig_pt    = dumpt,
                                           plane_grid = &source_id,
                                           trak_dir   = trak_dir,
                                           owner      = &parents[REV_START],
                                           dim_grid   = &dim_id );

                    EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
                }
            }

            om_msg = om$send ( msg = message expression.NDgive_value  ( &value ),
                               targetid = parents[REV_SWEEP].objid,
                               targetos = parents[REV_SWEEP].osnum );

            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            if (value != 360.0)
            {
                /*
                 * Dimension the sweep angle if it hasn't already been done.
                 */
                if (!(EFselect_first_component (&parents[REV_SWEEP], 
                                                OPP_DMroot_class_id, 
                                                &dim_id) & 1))
                {
                    dim_id.objid = NULL_OBJID;
                    trak_dir = 0;

                    dm$place_sglarc_angle( orig_grid  = &source_id,
                                           orig_pt    = dumpt,
                                           plane_grid = &source_id,
                                           trak_dir   = trak_dir,
                                           owner      = &parents[REV_SWEEP],
                                           dim_grid   = &dim_id );

                    EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
                }
            }
            break;

        default:
            break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMSswcompsf.EMdim");

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
    IGRint              i, j, DIRECTION;
    IGRdouble           height, start, sweep, angle;
    IGRvector           x_axis, y_axis, z_axis, diagonal;
    IGRpoint            point1, point2, keypoint;
    struct EMSgeomdata  direction, base;
    GRclassid           classid;
    struct GRid         curve;
    IGRboolean          world = TRUE;
    GRrange             range;
    IGRlong             num_points = 1;
    IGRmatrix           matrix;

    *msg = msg_loc = EMS_S_Success;

    DIRECTION = ( (type == EMS_ASsurface_of_projection) ||
                  (type == EMS_ASsurface_of_projection1)) ? PRJ_DIRECTION 
                                                          : REV_DIRECTION;

    om_msg = om$send ( msg = message NDnode.ASreturn_go 
                                                ( &curve,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix ),
                       targetid = parents[CURVE].objid,
                       targetos = parents[CURVE].osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
                      
    if(type == EMS_ASsurface_of_projection ||
        type == EMS_ASsurface_of_projection1 ||
    	type == EMS_ASsurface_of_revolution ||
        type == EMS_ASsurface_of_revolution1) {
    	om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                ( &msg_loc, 
                                                  NULL,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &direction ), 
                       targetid = parents[DIRECTION].objid,
                       targetos = parents[DIRECTION].osnum );

    	EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    if(type == EMS_ASsurface_of_projection ||
       type == EMS_ASsurface_of_projection1 ||
	type == EMS_ASsurf_of_proj_by_sym_dist) {
        om_msg = om$send ( msg = message expression.NDgive_value  ( &height ),
                           targetid = parents[PRJ_HEIGHT].objid,
                           targetos = parents[PRJ_HEIGHT].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
    }
    else  /* Surface of revolution */
    {
        om_msg = om$send ( msg = message EMSparamgm.EMgetgeom 
                                                ( &msg_loc, 
                                                  NULL,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &base ), 
                           targetid = parents[REV_BASE].objid,
                           targetos = parents[REV_BASE].osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        om_msg = om$send ( msg = message expression.NDgive_value  ( &start ),
                           targetid = parents[REV_START].objid,
                           targetos = parents[REV_START].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        om_msg = om$send ( msg = message expression.NDgive_value  ( &sweep ),
                           targetid = parents[REV_SWEEP].objid,
                           targetos = parents[REV_SWEEP].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
    }

    om_msg = om$send ( msg = message GRgraphics.GRgetrang 
                                                ( &msg_loc,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &world,
                                                  range ),
                       targetid = curve.objid,
                       targetos = curve.osnum );

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    for (i=0,j=3; i<3; ++i, ++j)
        diagonal[i] = range[j] - range[i];

    if ( (type == EMS_ASsurface_of_revolution) ||
         (type == EMS_ASsurface_of_revolution1))
    {
        struct IGRline  loc_line;
        IGRdouble       t;
        IGRpoint        loc_center, loc_origin, loc_point, loc_axis[2];

        /*   AMD : 1/15/92:   Fix for TR#91N3253 
        EFget_out_vector(direction.vector);
        */

        for (i=0; i<3; ++i)
        {
            loc_origin[i] = range[i] + (diagonal[i] * 0.5);
            loc_axis[1][i] = (loc_axis[0][i] = base.point[i]) + direction.vector[i];
        }

        loc_line.point1 = loc_axis[0];
        loc_line.point2 = loc_axis[1];

        MAptlnproj (&msg_loc, loc_origin, &loc_line, loc_center, &t);

        /*
         * Move the origin point out beyond the range of the curve.
         * NOT DONE YET!!!!!
         */

        if (dim_type)
            *dim_type = SINGLE_ARC_ANGLE;

        if (dim_plane)
        {
            memcpy (dim_plane->point, loc_center, sizeof(IGRpoint));
            memcpy (dim_plane->normal, direction.vector, sizeof (IGRvector));
        }

        if (dim_plane_xaxis)
        {
            for (i=0; i<3; ++i)
                dim_plane_xaxis[i] = loc_origin[i] - loc_center[i];

            BSnorvec(&msg_loc, dim_plane_xaxis);
        }

        if (dim_geom)
        {
          if (index == REV_START || index == REV_SWEEP)
            {
            dim_geom->geomtype = GEOMDATA_CURVE;
            memcpy (loc_point, loc_origin, sizeof(IGRpoint));

            if (index == REV_START)
              angle = start;
            else
              {
              if (start != 0.0)
                {
                MAdegrad   (&msg_loc, &start, &angle);
                MAgrotmx   (&msg_loc, direction.vector, loc_center, &angle, 
                 matrix);
                MAptsxform (&msg_loc, &num_points, matrix, loc_origin,
                 loc_point);
                }
              angle =  sweep;
              }
            EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 
             0, &dim_geom->curve);
            BSarc_rot (&msg_loc, loc_axis[0], loc_axis[1], loc_point, &angle, 
             dim_geom->curve);
            }
          else if (index == REV_DIRECTION || index == REV_BASE)
            {
            IGRdouble *dptr, *basept;
            IGRpoint vecpt, boundpts[2];
            struct IGRline vecline;

            basept = base.point;
            if (index == REV_BASE)
              {
              dim_geom->geomtype = GEOMDATA_POINT;
              memcpy (dim_geom->point, basept, sizeof(IGRpoint));
              }
            else
              {
              dim_geom->geomtype = GEOMDATA_LINE;

              vecline.point1 = basept;
              for (i=X; i<=Z; i++)
                vecpt[i] = basept[i] + direction.vector[i];
              vecline.point2 = vecpt;
              EMget_bounded_line (range, &vecline, boundpts, &msg_loc);

              dptr = dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
              memcpy (dptr, boundpts[FIRST], sizeof (IGRpoint));
              dptr = dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
              memcpy (dptr, boundpts[SECOND], sizeof (IGRpoint));
              }
            }
        }
    }
    else /* surface of projection & symmetric surface of projection */
    {
        IGRlong               ma_msg;
        struct IGRbsp_curve   *bspcurve;
        IGRdouble             parm = 0.0, h;
        IGRshort              option = 1;

	if(type == EMS_ASsurf_of_proj_by_sym_dist)  {
		struct GRlc_info curve_loc;
		IGRpoint axis_ln[2];
	  	extern IGRlong EFget_axis_from_curve_sym_dist();

		curve_loc.located_obj.objid = curve.objid;
		curve_loc.located_obj.osnum = curve.osnum;
		curve_loc.module_info = *mod_env;
		/* Obtain the axis points from the curve & symmetric distance */
		om_msg = EFget_axis_from_curve_sym_dist(&msg_loc, &curve_loc, 
			height, axis_ln);
		
        	EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, 
			ret_end);

        	for (i=0; i<3; ++i)
			direction.vector[i] = axis_ln[0][i] - axis_ln[1][i];
            	BSnorvec(&msg_loc, direction.vector);
	}
        else if(type == EMS_ASsurface_of_projection ||
                type == EMS_ASsurface_of_projection1) {
        	memcpy(point1, EFis_negative(diagonal) ? range : &range[3], 
                 	sizeof(IGRpoint));
        	for (i=0; i<3; ++i)
            		point2[i] = point1[i] + direction.vector[i];
	}

        om$get_classid ( objid = curve.objid,
                         osnum = curve.osnum,
                         p_classid = &classid );

        /*
         * If this is an owner get the first true graphic component.
         */
        if (om$is_ancestry_valid ( superclassid = OPP_GRowner_class_id,
                                   subclassid = classid ) == OM_S_SUCCESS)
        {
            EFselect_first_component (&curve, OPP_GRvg_class_id, &curve);
        }

        /*
         * Determine the curve's geometry.
         */
        om_msg = om$send ( msg = message GRvg.GRgenabsg
                                                ( &msg_loc,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  (IGRchar **)&bspcurve ),
                           targetid = curve.objid,
                           targetos = curve.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        MAbcueval(&ma_msg, bspcurve, &option, &parm, keypoint, &h);

        if(type == EMS_ASsurface_of_projection ||
           type == EMS_ASsurface_of_projection1) {
            for(i=0; i<3; ++i) {
            	point2[i] = (point1[i] = keypoint[i]) + (direction.vector[i] * 
			height);
            	x_axis[i] = point2[i] - point1[i];
            }
	}
	/* Project on both sides of the profile */
	else if(type == EMS_ASsurf_of_proj_by_sym_dist)  {
            for (i=0; i<3; ++i) {
	    	point1[i] = keypoint[i] + (direction.vector[i] * (height/2.0));
	    	point2[i] = keypoint[i] - (direction.vector[i] * (height/2.0));
            	x_axis[i] = point2[i] - point1[i];
            }
	}
        EFget_normal_from_axis(&msg_loc, 
                                 &parents[PRJ_HEIGHT],
                                 mod_env, 
                                 x_axis,  /* In/Out */
                                 y_axis, 
                                 z_axis );

        if (dim_type)
            *dim_type = SINGLE_PARALLEL;

        if (dim_plane) {
            memcpy (dim_plane->point, point1, sizeof(IGRpoint));
            memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
        }

        if (dim_plane_xaxis) 
            memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));

        if (dim_geom) {
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
            memcpy (dim_geom->line.line_pt1, point1, sizeof(IGRpoint));
            memcpy (dim_geom->line.line_pt2, point2, sizeof(IGRpoint));
        }
    }
    
ret_end:

  EMWRAPUP (*msg, om_msg, "EMSswcompsf.EMdimparam");

  return (om_msg);
}

end implementation EMSswcompsf;
