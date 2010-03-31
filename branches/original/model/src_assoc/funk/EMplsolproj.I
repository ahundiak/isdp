/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place solid of projection. These
 *  can be placed as associative or non-associative entities.
 *
 * HISTORY:
 *
 *  Sudhakar- 02Aug93  : Modified the fix for TR#119302045 such that, in the
 *                       associative mode, even if the reference planes are
 *                       parallel to the plane of the curve, only a 'gensolid'
 *                       is created. This is to avoid the recompute problems
 *                       which arise when initially, the planes are parallel
 *                       and a recompute is generated because one of the planes
 *                       is rotated, for example. There is need to change
 *                       class in such cases, but that implementation is to
 *                       be done in the future.
 *  Sudhakar- 30Jun93  : Fix for TR#119302045. Added an addl. arg to the two
 *                       functions 'EFget_axis_from_curve_one_pl()' and
 *                       'EFget_axis_from_curve_two_pls()'. Added code to
 *                       skip the call to 'EFplsolid_by_trimming_with_planes()'
 *                       if planes parallel. Added dummy calls to the
 *                       above two functions in the 'associative' part of
 *                       the code to determine whether to create a solid
 *                       of class 'EMSsfsolid' or 'EMSgensolid'.
 *  Sudha     06/01/93   modified to add BSprototypes
 *  Tapadia - 05/15/92 : Suppport for symmetrically projecting in both 
 *			 directions normal to the profile.
 *  Tapadia - 03/10/92 : Creation
 */
class implementation EMSswcompsf;

#define CURVE       0
#define HEIGHT      1
#define DIRECTION   2

#include "REsfsolid.h"
#include "REgensolid.h"
#include "OMmacros.h"
#include "ems_sun_def.h"
#include "ma2ptdis.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

#include "actparam.h"


extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMSproject_class_id, 
OPP_EMSprjcompsf_class_id, OPP_EMSgensolid_class_id;

static  IGRboolean aflag;
static  struct GRmd_env rf_env;
static IGRint rfsts;

from EMSproject import EMplace_surface_of_projection;
from EMSsfsolid import EMcap_thyself;

IGRlong EMplace_solid_of_projection(msg, opts, mdenv, level, disp, dispattr, 
	objname, curve, base_pt, height_pt, st_plane_info, end_plane_info,
	prjobj)
IGRlong               	*msg;
IGRushort       opts;
struct GRmd_env         *mdenv;
IGRshort                level;
struct IGRdisplay       *disp;
IGRchar                 *dispattr, *objname;
struct GRlc_info   	*curve;
struct EMSpoint_info    *base_pt, *height_pt;
struct GRlc_info    	*st_plane_info; 
struct GRlc_info    	*end_plane_info;
GRobjid                 *prjobj;
{
	IGRchar                 loc_name[PATH_MAX];
	IGRpoint                loc_base, loc_height, axis[2], cur_pt, 
				mid_point;
	IGRshort                mattyp;
	IGRlong                 msg_loc, stat_func, om_msg;
	IGRdouble             	*mat, move_dist;
	IGRint                  i, recomp_type = 0, num_parents = 0, index;
	GRobjid                 dummy_id, solidobj,tmpobj, capid;
	GRclassid               classid;
	struct GRmd_env         loc_mdenv;
	struct IGRdisplay       loc_disp;
	struct GRvg_construct   vgcnstr;
	struct EMSobject_info   *parobjs = NULL;
	GRspacenum              constros;
	void                    EMinitvgcnstr();
	IGRboolean              EMgetvgcnstr();
	IGRlong                 EMgetparptobj(), EMgetparvalobj();
	extern OM_S_OBJID       current_creator;
	extern IGRlong 		EFplsolid_by_trimming_with_planes(), 
				EFget_axis_from_curve_one_pl(), 
				EFget_axis_from_curve_two_pls(), 
				EFget_axis_from_curve_sym_dist(); 
	IGRboolean		st_pt_flag, st_rp_flag, end_rp_flag;
	IGRboolean		sym_dist_flag;
	IGRvector 		move_nor;
	IGRmatrix 		matrix;
	struct GRid 		new_id, tmp_id;
        IGRboolean              parallel_pls = FALSE;

	*msg = EMS_S_Success;
	om_msg = OM_S_SUCCESS;

	index = 0;
	st_pt_flag = st_rp_flag = end_rp_flag = TRUE;
	sym_dist_flag = FALSE;

	EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
	stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, 
		objname, &vgcnstr);
	EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

	constros = vgcnstr.env_info->md_id.osnum;

    aflag = pwIsActivationOn();
    if (aflag)
    {
       rfsts = pwGetActiveModuleEnv(&rf_env);

       vgcnstr.env_info = &rf_env;
       constros = vgcnstr.env_info->md_id.osnum;
    }

	mattyp = vgcnstr.env_info->md_env.matrix_type;
	mat = vgcnstr.env_info->md_env.matrix;

	if(base_pt->type == EMSdatainfo_numeric) {
		sym_dist_flag = TRUE;
		st_pt_flag = FALSE;
	}
	if(base_pt->type == EMSdatainfo_name)
		st_pt_flag = FALSE;
	if(st_plane_info->located_obj.objid == NULL_OBJID)
		st_rp_flag = FALSE;
	if(end_plane_info->located_obj.objid == NULL_OBJID)
		end_rp_flag = FALSE;

	if(st_pt_flag || sym_dist_flag)
		classid = OPP_EMSsfsolid_class_id;
	else 
		classid = OPP_EMSgensolid_class_id;

	if(opts & EMSasconst_notassociative) {
	    if(sym_dist_flag) {
		IGRdouble distance;
		distance = base_pt->ptevent->event.value;
		/* Get the axis points from the symmetric distance */
		om_msg = EFget_axis_from_curve_sym_dist(&msg_loc, curve, 
			distance, axis);

		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		OM_BLOCK_MOVE(axis[0], loc_base, sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis[1], loc_height, sizeof(IGRpoint));

		for(i = 14; i > 0; i--) matrix[i] = 0.0;
		matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

		move_nor[0] = axis[0][0] - axis[1][0];
		move_nor[1] = axis[0][1] - axis[1][1];
		move_nor[2] = axis[0][2] - axis[1][2];
		BSnorvec(&msg_loc, move_nor);
		move_dist = distance/2.0;
		matrix[3] = move_dist * move_nor[0];
		matrix[7] = move_dist * move_nor[1];
		matrix[11] = move_dist * move_nor[2];

		new_id.objid = NULL_OBJID;
		/* copy the original curve to the new position */
		om_msg = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
			    &curve->module_info, matrix,
			    &curve->module_info,
			    &new_id.objid),
		    senderid = NULL_OBJID,
		    targetid = curve->located_obj.objid,
		    targetos = curve->located_obj.osnum);

		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		tmp_id.objid = curve->located_obj.objid;
		curve->located_obj.objid = new_id.objid;
	    }
	    else if(st_pt_flag) {
		/* Get the start & end point */
		om_msg = EMgetparpt_numeric(&msg_loc, base_pt, loc_base);
		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);

		om_msg = EMgetparpt_numeric(&msg_loc, height_pt, loc_height);
		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
	    }
	    else if(st_rp_flag) {
		/* Get the intersection point of the curve with the planes */
		om_msg = EFget_axis_from_curve_two_pls(&msg_loc, curve, 
			st_plane_info, end_plane_info, cur_pt, axis, mid_point,
                        &parallel_pls);

		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		OM_BLOCK_MOVE(axis[0], loc_base, sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis[1], loc_height, sizeof(IGRpoint));

		for(i = 14; i > 0; i--) matrix[i] = 0.0;
		matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

		move_nor[0] = axis[0][0] - cur_pt[0];
		move_nor[1] = axis[0][1] - cur_pt[1];
		move_nor[2] = axis[0][2] - cur_pt[2];
		BSnorvec(&msg_loc, move_nor);
		move_dist = BSdistptpt(&msg_loc, axis[0], cur_pt);
		matrix[3] = move_dist * move_nor[0];
		matrix[7] = move_dist * move_nor[1];
		matrix[11] = move_dist * move_nor[2];

		new_id.objid = NULL_OBJID;
		/* copy the original curve to the new position */
		om_msg = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
			    &curve->module_info, matrix,
			    &curve->module_info,
			    &new_id.objid),
		    senderid = NULL_OBJID,
		    targetid = curve->located_obj.objid,
		    targetos = curve->located_obj.osnum);

		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		tmp_id.objid = curve->located_obj.objid;
		curve->located_obj.objid = new_id.objid;
	    }
	    else if(end_rp_flag) {
		/* Get the intersection point of the curve with the plane */
	    	om_msg = EFget_axis_from_curve_one_pl(&msg_loc, curve, 
			end_plane_info, axis, mid_point, &parallel_pls); 

		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);

		OM_BLOCK_MOVE(axis[0], loc_base, sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis[1], loc_height, sizeof(IGRpoint));
	    }

	    /* Create a surface of projection */
	    om_msg = om$construct( classid =  OPP_EMSproject_class_id,
		    msg = message EMSproject.EMplace_surface_of_projection(
		    		&vgcnstr, &curve->located_obj,
		    		&curve->module_info, NULL, NULL, loc_base, 
				loc_height, TRUE, prjobj),
		    	p_objid = &tmpobj,
		    	osnum = constros );

	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	    if(st_rp_flag || sym_dist_flag) {
		curve->located_obj.objid = tmp_id.objid;
		if(new_id.objid != NULL_OBJID) {
		    om_msg = om$send(msg = message GRgraphics.GRdelete(
				&msg_loc, vgcnstr.env_info),
			    senderid = NULL_OBJID,
			    targetid = new_id.objid,
			    targetos = constros);

	    	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, 
			ret_end);
		}
	    }
	    /* Construct the object & cap it to make it a solid */
	    om_msg = om$construct(classid = classid,
		    	p_objid = &dummy_id,
		    	osnum = constros);
	    if(1 & om_msg) {
		    current_creator = dummy_id;
		    om_msg = om$construct(classid = OPP_EMSsfsolid_class_id,
			    	msg = message EMSsfsolid.EMcap_thyself 
			    	(&msg_loc, &vgcnstr, prjobj), 
			    p_objid = &capid,
			    osnum = constros);

	    	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, 
			ret_end);

		    current_creator = NULL_OBJID;
	    }
	    om_msg = om$send(msg = message Root.delete(1),
			    senderid = NULL_OBJID,
			    targetid = dummy_id,
			    targetos = constros);

	    if(EMSerror(om_msg & msg_loc)) {
		    om$send(msg = message GRgraphics.GRdelete(&msg_loc,
			    	vgcnstr.env_info),
			  senderid = NULL_OBJID,
			  targetid = *prjobj,
			  targetos = constros);
	    	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, 
			ret_end);
	    }

	    /* Trim the solid with plane(s) */
	    if((st_rp_flag || end_rp_flag) && !parallel_pls) {
		om_msg = EFplsolid_by_trimming_with_planes(&msg_loc, 
			opts, st_rp_flag, &solidobj, capid, 
			end_plane_info, 
			(st_rp_flag) ? st_plane_info : NULL,
			mid_point, &vgcnstr);

	    	EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, 
			ret_end);
		*prjobj = solidobj;
	    }
	    else 
		*prjobj = capid;
	}
	else {	/* Associative placement */
	    struct EMSvector_info   direction;
	    struct EMSvalue_info    height;
	    struct EMSvalue_info    sym_val;

	    if(sym_dist_flag) {
		recomp_type = EMS_ASsolid_proj_by_sym_dist;
		num_parents = 2;	/* curve, symmetric distance */
	    }
	    else if(st_pt_flag) {
		recomp_type = EMS_ASsolid_surface_of_projection;
		num_parents = 3;	/* curve, st_pt, end_pt */
	    }
	    else if(st_rp_flag) {
		recomp_type = EMS_ASsolid_proj_by_trim_st_end_plane;
		num_parents = 3;	/* curve, start plane, end plane */
             
              /*   Dummy call to determine whether trim-planes parallel
                   with the plane of the curve. Might be useful later
                   for a complete fix of TR# 119302045 *
                om_msg = EFget_axis_from_curve_two_pls(&msg_loc, curve,
                        st_plane_info, end_plane_info, cur_pt, axis, mid_point,
                        &parallel_pls);
                EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail,
                        ret_end);

                * Reset the classid to 'EMSfsolid' if 'parallel_pls' *
                if(parallel_pls)
                       classid = OPP_EMSsfsolid_class_id;
              */

	    }
	    else if(end_rp_flag) {
		recomp_type = EMS_ASsolid_proj_by_trim_end_plane;
		num_parents = 2;	/* curve, end plane */

              /*   Dummy call to determine whether trim-plane parallel
                   with the plane of the curve. Might be useful later
                   for a complete fix of TR# 119302045 *
                om_msg = EFget_axis_from_curve_one_pl(&msg_loc, curve,
                                   end_plane_info, axis, mid_point,
                                   &parallel_pls);
                EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail,
                        ret_end);

                * Reset the classid to 'EMSfsolid' if 'parallel_pls' *
                if(parallel_pls)
                       classid = OPP_EMSsfsolid_class_id;
              */

	    }

	    parobjs = (struct EMSobject_info *) stackalloc(num_parents *
	    		sizeof(struct EMSobject_info));

	    EMerr_hndlr(!parobjs, *msg, EMS_E_NoStackMemory, ret_end);

	    parobjs[CURVE].grid = curve->located_obj;
	    parobjs[CURVE].env = curve->module_info;
	    index++;

	    if(sym_dist_flag) {
		sym_val.type = EMSdatainfo_event;
		sym_val.valevent = base_pt->ptevent;
		/* create a parameter value object */
	   	om_msg = EMgetparval_object(&msg_loc, constros, NULL, 
				&sym_val, &parobjs[index]);
	    	EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
	    }
	    else if(st_pt_flag) {
		om_msg = EMgetparpt_numeric (&msg_loc, base_pt, loc_base);
		EMerr_hndlr(EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);

		om_msg = EMgetparpt_numeric (&msg_loc, height_pt, loc_height);
		EMerr_hndlr(EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);

		direction.type = EMSdatainfo_numeric;
		for(i = 0; i < 3; ++i)
		    direction.vec[i] = loc_height[i] - loc_base[i];
		    BSnorvec (&msg_loc, direction.vec);

		    height.type = EMSdatainfo_numeric;
		    MA2ptdis (&msg_loc, loc_base, loc_height, &height.val);
		    om_msg = EMgetparval_object(&msg_loc, constros, NULL, 
				&height, &parobjs[index]);
		    EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		    index++;

		    om_msg = EMgetparvec_object(&msg_loc, mattyp, mat, constros,
			    &direction, &parobjs[index]);
		    EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
		}
		else if(st_rp_flag) {
		    parobjs[index].grid = st_plane_info->located_obj;
		    parobjs[index].env = st_plane_info->module_info;
		    index++;
		    parobjs[index].grid= end_plane_info->located_obj;
		    parobjs[index].env= end_plane_info->module_info;
		}
		else if(end_rp_flag) {
		    parobjs[index].grid= end_plane_info->located_obj;
		    parobjs[index].env= end_plane_info->module_info;
		}
		om_msg = om$construct(classid = classid, osnum = constros, 
		    		p_objid = prjobj);
		if(1 & om_msg) {
		    current_creator = *prjobj;

		    om_msg = om$send(msg = message EMSassoc.EMinit_associative 
			    	(&msg_loc,
			    	opts & ~EMSasconst_recompute,
			    	num_parents, 
			    	parobjs, 
			    	recomp_type, 
			    	0, 
			    	NULL, 
			    	&vgcnstr ),
			    senderid = NULL_OBJID,
			    targetid = *prjobj,
			    targetos = constros);
		    current_creator = NULL_OBJID;
		}
		EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);

	}

ret_end:
	if(parobjs) stackfree(parobjs);
	EMWRAPUP (*msg, om_msg, "EMplace_solid_of_projection");
	return (om_msg);
}

end implementation EMSswcompsf;
