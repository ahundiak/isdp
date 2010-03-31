/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This method does the recompute and associative construction for 
 *  surface of revolution and projection.
 *
 * HISTORY:
 *
 *  jhw  :  03/20/91  :  Creation
 *  SS   :  01/03/92  :  Normal cnstr on the vector.
 *  Tapadia 03/16/92  : Support for solid of projection with planes 
 *   			(EMS_ASsurf_of_proj_trim_st_end_plane &
 *   			EMS_ASsurf_of_proj_trim_end_plane)
 *  Tapadia 05/15/92  : Suppport for symmetrically projecting in both 
 *			directions normal to the profile 
 *			(EMS_ASsurf_of_proj_by_sym_dist)
 *  SM   :  06/01/92  : For EMS_ASsurface_of_revolution1/proj1, try and convert
 *                      all planar surfaces into planes.
 *  Sudha   06/21/93    Modified to handle BSprototype ansification
 *  Sudhakar:30Jun93  : Fix for TR#119302045. Added an addl. arg to the two
 *                      functions 'EFget_axis_from_curve_one_pl()' and
 *                      'EFget_axis_from_curve_two_pls()'.
 *  PP : 21 Jan 94    : Tapadia was issuing a Root.delete as opposed
 *                      to a GRgraphics.GRdelete to the copied and
 *                      transformed curve. Thus causing all the components
 *                      to be left behind as dead weight.
 *
 */

class implementation EMSswcompsf;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "mascalvc.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include <stdio.h>

#define CURVE           0

#define REV_BASE        1
#define REV_DIRECTION   2
#define REV_START       3
#define REV_SWEEP       4

#define PRJ_HEIGHT      1
#define PRJ_DIRECTION   2

#define SYM_DIST        1

#define ST_END_PLANE    1
#define END_PLANE       2

extern GRclassid OPP_EMSpervcnstr_class_id;

from EMScnstr import EMinit;

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRuint     *param_type;
    IGRlong     msg_loc, om_msg = OM_S_SUCCESS;
    IGRdouble	dottol, dotp, move_dist;
    IGRpoint    axis[2], pln_point, mid_point, cur_pt;
    IGRvector	pln_norm, move_nor;
    GRobjid     obj, cnstrobj;
    IGRint      i;
    IGRmatrix 	matrix;
    struct GRid	*cvid, *grid_ptr, new_id, tmp_id;
    struct IGRplane plane;
    struct EMSsweep sweep;
    struct GRmd_env *env;
    extern IGRlong 	EFget_axis_from_curve_one_pl(); 
    extern IGRlong 	EFget_axis_from_curve_two_pls();
    extern IGRlong 	EFget_axis_from_curve_sym_dist();
    union EMSparent_info *param;
    IGRboolean convert_into_plane = TRUE;
    IGRboolean  parallel_pls = FALSE;

    *msg = EMS_S_Success;

    for(i = 14; i > 0; i--) matrix[i] = 0.0;
    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca(num_parents * sizeof(IGRint));
    param = (union EMSparent_info *)alloca(num_parents * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_ASsurface_of_revolution:
    case EMS_ASsurface_of_revolution1:
        param_type[CURVE]          = EMSlcinfo;
        param_type[REV_BASE]       = EMSpoint;
        param_type[REV_DIRECTION]  = EMSvector;
        param_type[REV_START]      = EMSangle;
        param_type[REV_SWEEP]      = EMSangle;
        break;

    case EMS_ASsurface_of_projection:
    case EMS_ASsurface_of_projection1:
        param_type[CURVE]         = EMSlcinfo;
        param_type[PRJ_HEIGHT]    = EMSdistance;
        param_type[PRJ_DIRECTION] = EMSvector;
        break;

    case EMS_ASsurf_of_proj_trim_st_end_plane:
        param_type[CURVE]         = EMSlcinfo;
        param_type[ST_END_PLANE]  = EMSlcinfo;
        param_type[END_PLANE]  = EMSlcinfo;
	break;

    case EMS_ASsurf_of_proj_trim_end_plane:
        param_type[CURVE]         = EMSlcinfo;
        param_type[ST_END_PLANE]  = EMSlcinfo;
	break;

    case EMS_ASsurf_of_proj_by_sym_dist:
        param_type[CURVE]         = EMSlcinfo;
        param_type[SYM_DIST]  = EMSdistance;
	break;

    default:
        goto ret_end;
    }        

    /*
     * Get the parameter information.
     */
    om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Fill in the appropriate sweep information.
     */
    switch (type)
    {    
    case EMS_ASsurface_of_projection:
    case EMS_ASsurface_of_projection1:
        axis[0][0] = axis[0][1] = axis[0][2] = 0.0;
        MAscalvc ( &msg_loc, 
                   &param[PRJ_HEIGHT].value, 
                   param[PRJ_DIRECTION].vector, 
                   axis[1]);
        sweep.type = EMProject;
        sweep.data.prj_data.point1 = (IGRpoint *)axis[0];
        sweep.data.prj_data.point2 = (IGRpoint *)axis[1];
        break;

    case EMS_ASsurface_of_revolution:
    case EMS_ASsurface_of_revolution1:
        memcpy( axis[0], param[REV_BASE].point, sizeof(IGRpoint));
        for (i=0; i<3; ++i)
            axis[1][i] = axis[0][i] + param[REV_DIRECTION].vector[i];

/********* check for profile axis intersection ********/

       if (opts & EMSasconst_recompute)
       {
         EFvalidate_surface_of_revolution(
          FALSE,
          &(param[CURVE].lc_info),
          axis,
          my_id,
          NULL,
          NULL,
          msg);

       if(*msg == EMS_I_Intersect ||*msg == EMS_I_Useless)
          EMerr_hndlr (EMSerror(!(msg_loc & om_msg)),*msg,EMS_E_Fail,ret_end);
       }

/************************************* Nirmal 05/12/92 */

        sweep.type = EMRevolve;
        sweep.data.rev_data.axis = (double *)axis;
        sweep.data.rev_data.start_angle = param[REV_START].value;
        sweep.data.rev_data.sweep_angle = param[REV_SWEEP].value;
        sweep.data.rev_data.full_rev = (param[REV_SWEEP].value == 360.0);
        break;

    case EMS_ASsurf_of_proj_trim_end_plane:
	/* get the axis by intersecting curve with the plane */
	om_msg = EFget_axis_from_curve_one_pl(&msg_loc, &(param[CURVE].lc_info),
		&(param[ST_END_PLANE].lc_info), axis, mid_point, &parallel_pls);

        EMerr_hndlr(EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        sweep.type = EMProject;
        sweep.data.prj_data.point1 = (IGRpoint *)axis[0];
        sweep.data.prj_data.point2 = (IGRpoint *)axis[1];
	break;

    case EMS_ASsurf_of_proj_trim_st_end_plane:
	/* get the axis by intersecting curve with both the planes */
	om_msg = EFget_axis_from_curve_two_pls(&msg_loc, 
		&(param[CURVE].lc_info), &(param[ST_END_PLANE].lc_info),  
		&(param[END_PLANE].lc_info), cur_pt, axis, mid_point, 
                &parallel_pls);

        EMerr_hndlr(EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	move_nor[0] = axis[0][0] - cur_pt[0];
	move_nor[1] = axis[0][1] - cur_pt[1];
	move_nor[2] = axis[0][2] - cur_pt[2];
	BSnorvec(&msg_loc, move_nor);
	
	move_dist = BSdistptpt(&msg_loc, axis[0], cur_pt);

	matrix[3] = move_dist * move_nor[0];
	matrix[7] = move_dist * move_nor[1];
	matrix[11] = move_dist * move_nor[2];

	new_id.objid = NULL_OBJID;
	om_msg = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
			&param[CURVE].lc_info.module_info, matrix,
			&param[CURVE].lc_info.module_info, 
			&new_id.objid),
		senderid = NULL_OBJID,
		targetid = param[CURVE].lc_info.located_obj.objid,
		targetos = param[CURVE].lc_info.located_obj.osnum);

        EMerr_hndlr(EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	tmp_id.objid = param[CURVE].lc_info.located_obj.objid;
	
	param[CURVE].lc_info.located_obj.objid = new_id.objid;

        sweep.type = EMProject;
        sweep.data.prj_data.point1 = (IGRpoint *)axis[0];
        sweep.data.prj_data.point2 = (IGRpoint *)axis[1];
	break;

    case EMS_ASsurf_of_proj_by_sym_dist:
	/* get the axis from curve & sym distance */
	om_msg = EFget_axis_from_curve_sym_dist(&msg_loc, 
		&(param[CURVE].lc_info), param[SYM_DIST].value, axis);

        EMerr_hndlr(EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	move_nor[0] = axis[0][0] - axis[1][0];
	move_nor[1] = axis[0][1] - axis[1][1];
	move_nor[2] = axis[0][2] - axis[1][2];
	BSnorvec(&msg_loc, move_nor);
	move_dist = param[SYM_DIST].value/2.0;
	matrix[3] = move_dist * move_nor[0];
	matrix[7] = move_dist * move_nor[1];
	matrix[11] = move_dist * move_nor[2];

	new_id.objid = NULL_OBJID;
	om_msg = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
			&param[CURVE].lc_info.module_info, matrix,
			&param[CURVE].lc_info.module_info, 
			&new_id.objid),
		senderid = NULL_OBJID,
		targetid = param[CURVE].lc_info.located_obj.objid,
		targetos = param[CURVE].lc_info.located_obj.osnum);

        EMerr_hndlr(EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	tmp_id.objid = param[CURVE].lc_info.located_obj.objid;
	param[CURVE].lc_info.located_obj.objid = new_id.objid;

        sweep.type = EMProject;
        sweep.data.prj_data.point1 = (IGRpoint *)axis[0];
        sweep.data.prj_data.point2 = (IGRpoint *)axis[1];
	break;
    }

    /*
     * Construct the appropriate surface(s) of projection/revolution.
     */
    obj = NULL_OBJID;
    om_msg = om$send ( msg = message EMSswcompsf.EMsweep_composite_curve
                                            ( constr_list,
                                              &(param[CURVE].lc_info),
                                              &sweep,
                                              &obj ),
                          targetid = my_id );

    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
	
    if(type == EMS_ASsurf_of_proj_trim_st_end_plane || 
	type == EMS_ASsurf_of_proj_by_sym_dist) {
	    param[CURVE].lc_info.located_obj.objid = tmp_id.objid;
	    if(new_id.objid != NULL_OBJID) {
               IGRlong l_msg;
	       om$send(msg = message GRgraphics.GRdelete(&l_msg,
                         &param[CURVE].lc_info.module_info),
			senderid = NULL_OBJID,
			targetid = new_id.objid,
			targetos = param[CURVE].lc_info.located_obj.osnum);
	    }
    }

    /*
     * If this is not a recompute but a true construction and
     * if the axis of projection is perpendicular to the plane defined
     * by the param[CURVE], then put in a perpendicularity constraint
     * between the vector and the curve.
     */
    
    if ( (type == EMS_ASsurface_of_projection ||
          type == EMS_ASsurface_of_projection1) &&
        ! (opts & EMSasconst_recompute))
      {
      env = constr_list->env_info;
      plane.point = pln_point;
      plane.normal = pln_norm;
      grid_ptr = (struct GRid *) parent_info;
      cvid = &param[CURVE].lc_info.located_obj;

      om_msg = om$send (msg = message GRvg.GRdetplane (&msg_loc,
                &env->md_env.matrix_type, env->md_env.matrix,
                &plane), targetid = cvid->objid, targetos = cvid->osnum);
      if (!EMSerror (om_msg & msg_loc) &&
          msg_loc == MSSUCC)
        {
        BSnorvec (&msg_loc, axis[1]);
        BSEXTRACTPAR (&msg_loc, BSTOLORTHOVEC, dottol);
        dotp = BSdotp (&msg_loc, plane.normal, axis[1]);
        if (fabs (1.0 - fabs (dotp)) < dottol)
          {
          om_msg = om$construct (classid = OPP_EMSpervcnstr_class_id,
                    msg = message EMScnstr.EMinit (&msg_loc, NULL,
                    env, 1, cvid, EMScnstr_self_constraint, NULL,
                    1, &grid_ptr[PRJ_DIRECTION]),
                    p_objid = &cnstrobj);
          EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
          }
        }
      }

     if( (type == EMS_ASsurface_of_revolution1 ||
          type == EMS_ASsurface_of_projection1) && convert_into_plane)
      om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, constr_list->env_info, my_id, OM_Gw_current_OS);

ret_end:
    EMWRAPUP (*msg, om_msg, "EMSswcompsf.EMconstruct_associative");
    return (om_msg);
}

end implementation EMSswcompsf;
