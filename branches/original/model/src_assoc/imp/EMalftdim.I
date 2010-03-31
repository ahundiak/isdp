/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  This is the autodimension method for lift face.
 *
 * HISTORY:
 *
 *  DLB      11/23/92 - Dont set loops to active/inactive if Im unevaluated.
 *  Tapadia  11/11/91 - Modified as ordinary lift is no longer supported.
 *  Tapadia  09/06/91 - Modified to support for lift vector which is normal
 *                      to the surface
 *  Tapadia  Creation   08/12/91
 */
class implementation EMSlift;

#include "EMSdef.h"
#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "bsconic.h"
#include "EMSlift.h"
#include "EMSconstruct.h"
#include "dimplcmacros.h"

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;
from EMSboundary import EMtree_traverse;
from EMSloop     import EMset_props;

#define LIFT            0
#define DRAFT_LIFT      1

extern OMuword OPP_DMroot_class_id;

/* This method calls the appropriate auto dimensioning */

method EMdim(IGRlong        *msg;
        struct GRmd_env     *mod_env;
        IGRushort   options;
        IGRint              type;
        IGRchar             *info;
        IGRint              num_parents;
        struct GRid         *parents )
{
        IGRlong         om_msg = OM_S_SUCCESS, msg_loc;
        struct GRid     dim_id, source_id, assoc_id;
        IGRpoint        dumpt;
        IGRint          trak_dir;       
        IGRint          lft_dist_index;

        msg_loc = *msg = EMS_S_Success;

        dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
        assoc_id.objid = my_id;
        assoc_id.osnum = OM_Gw_current_OS;

        if(num_parents == 2)  /* distance & surface information */
                lft_dist_index = 0;
        else 
                lft_dist_index = 1; /* 0th index is vector */

        EFget_parent_source(&assoc_id, &source_id);

        /* Perform auto-dimensioning */
        if(!(EFselect_first_component(&parents[lft_dist_index],
                                        OPP_DMroot_class_id,
                                        &dim_id) & 1))
        {
                dim_id.objid = NULL_OBJID;
                trak_dir = 1;
                
                dm$place_sglpara(orig_grid  = &source_id,
                                orig_pt     = dumpt,
                                 plane_grid = &source_id,
                                 trak_dir   = trak_dir,
                                 owner      = &parents[lft_dist_index],
                                 dim_grid   = &dim_id);

                EMerr_hndlr(dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail,
                        ret_end);
        }

ret_end:
        EMWRAPUP (*msg, om_msg, "EMSlift.EMdim");
        return (om_msg);
}

/* This method returns the geometry, plane & axis to the dimensioning macro */

/*
History
    Tapadia 01/21/91    Fixed TR 92n0284
    DLB     01/08/91    Fix bug caused by conversion to drafted lift.
*/    

method EMdimparam(IGRlong  *msg; 
        struct GRmd_env    *mod_env;
        IGRushort  options;
        IGRint             type;
        IGRchar            *info;
        IGRint             num_parents;
        struct GRid        *parents;
        IGRint             index; 
        struct IGRplane    *dim_plane;
        IGRdouble          *dim_plane_xaxis;
        struct EMSgeomdata *dim_geom;
        IGRint             *dim_type )
{
        IGRlong             msg_loc, om_msg = OM_S_SUCCESS;
        IGRint              i, j, oper_type, cur_index, val_index;
        IGRdouble           height, cht; 
        IGRvector           x_axis, y_axis, z_axis, diagonal;
        IGRpoint            point1, point2;
        struct IGRline      boreline;
        struct GRparms      key_parms;
        IGRpoint            keypoint;
        struct EMSgeomdata  direction;
        GRclassid           classid;
        struct GRid         curve;
        IGRboolean          vec_flag, world = TRUE;
        GRrange             range;
        struct EMSdrafted_lift *lift_info;
        extern OMuword       OPP_EMSsfdlift_class_id;
        struct EMparms       parms;


        if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
        {
          *msg = EMS_E_Fail;
          return(OM_S_SUCCESS);
        }
          
        *msg = msg_loc = EMS_S_Success;

        vec_flag = FALSE;

        /* EMS 2.0 behavior - Lift/drafted lift, EMS 1.4 behavior - 
        Drafted lift */
        if (EFisAncestryValid(msg, my_id, OM_Gw_current_OS,
                              OPP_EMSsfdlift_class_id, FALSE))
        {
            oper_type = DRAFT_LIFT;
            cur_index = 1;  /* curve/surface info */
            /* value requested - draft angle or distance  */
            val_index = index;      

            /* EMS 2.0 behavior - ordinary lift, pocket/boss without draft,
            make & lift face */
            if(num_parents == 2) 
            {
                oper_type = LIFT; 
                cur_index = 1;  /* curve/surface info */        
                val_index = 0;  /* distance */
                lift_info = (struct EMSdrafted_lift *) info;
                cht = lift_info->cht;
            }
        }
        else  /* EMS 1.4 behavior - Ordinary lift (vector is also specified) */
        {
            oper_type = LIFT; 

            lift_info = (struct EMSdrafted_lift *) info;
            cht = lift_info->cht;

            if(num_parents == 2)  /*Normal lift*/
            {
                cur_index = 1;  /* curve/surface info */        
                val_index = 0;  /* distance */
            }
            else
            {
                cur_index = 2;
                val_index = 1;
                vec_flag = TRUE;
            }
        }
        /* Obtain the curve(lift)/surface(drafted lift) information */
        om_msg = om$send(msg = message NDnode.ASreturn_go 
                                (&curve, &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix ),
                       targetid = parents[cur_index].objid,
                       targetos = parents[cur_index].osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
                      
        /* EMS 1.4 behavior - Get vector information */
        if(vec_flag) {
                struct EMSgeomdata axis;
                om_msg = om$send(msg = message EMSparamgm.EMgetgeom(
                                msg, NULL, &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix, &axis),
                        senderid = NULL_OBJID,
                        targetid = parents[0].objid,
                        targetos = parents[0].osnum );
                        
                EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

                memcpy(parms.normal, axis.vector, sizeof(IGRvector));
        }
        /* get the vector from the surface - normal to the surface */
        else {
                IGRpoint          from_point;
                IGRushort opts;
                IGRlong           loc_msg=1;
                IGRboolean        pos_orient;
                struct GRlc_info  sf_info;
                OM_S_CHANSELECT   to_loopset;
                extern OMuword    OPP_EMSloop_class_id;

                sf_info.located_obj = curve;
                sf_info.module_info = *mod_env;
                opts = EMS_GET_POS_ORIENT;

                /*The surface trying to get the point from may be INACTIVE.
                 * 11/23/92 - NOTE IT WILL BE ACTIVE IF THE LIFT FAILED,
                 *            OR IS SUPPRESSED BY SOME OTHER MEANS!!!!
                 * Make the loops active, do the get_point_on_surf and then
                 * make inactive.
                 */
                EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
                if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
                {
                  om_msg = om$send(msg = message EMSboundary.EMtree_traverse(
                                         msg, message EMSloop.EMset_props(msg,
                                                      EMLP_ACTIVE, EMS_O_ON),
                                         MAXINT, 1, &OPP_EMSloop_class_id, 
                                         TRUE, NULL, NULL, NULL),
                                   senderid = sf_info.located_obj.objid,
                                   p_chanselect = &to_loopset); 
                  if (!(1 &om_msg & *msg)) goto ret_end;
                }

                om_msg=om$send(msg = message EMSsurface.EMget_point_on_surface(
                                        &loc_msg, mod_env, 0, 1, from_point,
                                        &parms), 
                                senderid = NULL_OBJID,
                                targetid = sf_info.located_obj.objid,
                                targetos = OM_Gw_current_OS);

                if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
                {
                  om_msg = om$send(msg = message EMSboundary.EMtree_traverse(
                                         msg, 
                                               message EMSloop.EMset_props(msg,
                                                       EMLP_ACTIVE, EMS_O_OFF),
                                         MAXINT, 1, &OPP_EMSloop_class_id, 
                                         TRUE, NULL, NULL, NULL),
                                   senderid = sf_info.located_obj.objid,
                                   p_chanselect = &to_loopset); 
                  if (!(1 & om_msg & *msg)) goto ret_end;
                }

                if (!(1 & loc_msg)) goto ret_end;
                
                om_msg= om$send(msg = message EMSsurface.EMalgnnrml(msg, opts,
                                        &pos_orient, NULL, NULL),
                                senderid = NULL_OBJID,
                                targetid = sf_info.located_obj.objid,
                                targetos = OM_Gw_current_OS);

                if(!(1 &om_msg & *msg)) goto ret_end;

                if(pos_orient && oper_type == DRAFT_LIFT) {
                        parms.normal[0] *= -1;
                        parms.normal[1] *= -1;
                        parms.normal[2] *= -1;
                }
                else if(oper_type == LIFT) {
                    if(!pos_orient) {
                        parms.normal[0] *= -1;
                        parms.normal[1] *= -1;
                        parms.normal[2] *= -1;
                    }
                    if(type & EMlft_WITH_POS_ORIENT) {
                        parms.normal[0] *= -1;
                        parms.normal[1] *= -1;
                        parms.normal[2] *= -1;
                    }
                }
        }
        memcpy(direction.vector, parms.normal, sizeof(IGRvector));

        /* Get the distance parameter */
        om_msg = om$send ( msg = message expression.NDgive_value  ( &height ),
                           targetid = parents[val_index].objid,
                           targetos = parents[val_index].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        /* For pocket/boss without draft */
        if(oper_type == LIFT) {
            if(type & EMlft_POS_WITH_VECT) {    
                if(height < 0.0)
                        height *= -1;
            }   
        }
        else { /* drafted lift */
            if(type & EMdlft_NEG_MAG_OUTSIDE) { /* Boss */
                if(height > 0.0)
                        height *= -1;
            }
            if(type & EMdlft_POS_MAG_INSIDE) { /* Pocket */ 
                if(height < 0.0)
                        height *= -1;
            }
        }

        om_msg = om$send(msg = message GRgraphics.GRgetrang 
                                (&msg_loc, &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix, &world, range ),
                       targetid = curve.objid,
                       targetos = curve.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        for (i=0,j=3; i<3; ++i, ++j)
                diagonal[i] = range[j] - range[i];

        memcpy(point1, EFis_negative(diagonal) ? range : &range[3], 
                sizeof(IGRpoint));

        for (i=0; i<3; ++i)
                point2[i] = point1[i] - direction.vector[i];

        boreline.point1 = point1;
        boreline.point2 = point2;

        om$get_classid ( objid = curve.objid,
                         osnum = curve.osnum,
                         p_classid = &classid );

        if(om$is_ancestry_valid(superclassid = OPP_GRowner_class_id,
                                   subclassid = classid ) == OM_S_SUCCESS)
                om_msg = om$send(msg = message GRowner.GRkeypoint 
                                (&msg_loc, &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix, &boreline,
                                keypoint, &key_parms ),
                        mode = OM_e_wrt_message,
                        targetid = curve.objid,
                        targetos = curve.osnum );
        else
                om_msg = om$send(msg = message GRvg.GRkeypoint 
                                (&msg_loc, &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix, &boreline,
                                keypoint, &key_parms ),
                        targetid = curve.objid,
                        targetos = curve.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        for(i=0; i<3; ++i) {
            point2[i] = (point1[i] = keypoint[i]) - (direction.vector[i] * 
                        height);
            x_axis[i] = point2[i] - point1[i];
        }
        EFget_normal_from_axis ( &msg_loc, 
                                 &parents[val_index],
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
    
ret_end:
        EMWRAPUP (*msg, om_msg, "EMSlift.EMdimparam");
        return (om_msg);
}

end implementation EMSlift;
