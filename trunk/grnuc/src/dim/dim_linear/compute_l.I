class implementation DMlinear;

#include "diminst.h"
#include "mascalvc.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"

#define AS_DEBUG 1

extern IGRdouble fabs();

from dim_param import give_internal;
from GRlinear import GRgetpolyline;

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint status, rc;
	struct dim_attr *dim_attr;
	struct GRid list[MAX_DIM_ROOTS];

	dim_attr	= (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	/*^
		print_grid_info("dim_orig", list[DIM_CPX_ORIG]);
		print_grid_info("dim_meas", list[DIM_CPX_MEAS]);
	*/

	if (!DMancestry_valid(list[DIM_CPX_ORIG], OPP_DMlinear_class_id))
	{
		status =
		dm$create_root(
			type = DMkeypt,
			count = 1,
			list = &assoc_lis->parents[DIM_CPX_ORIG],
			context = &assoc_lis->context[DIM_CPX_ORIG],
			attr = dim_attr->orig,
			md_env = md_env,
			p_root = &list[DIM_CPX_ORIG]);
		dm$status(action = RET_STATUS);
	}

	status =
	dm$create_root(
		type = DMkeypt,
		count = 1,
		list = &assoc_lis->parents[DIM_CPX_MEAS],
		context = &assoc_lis->context[DIM_CPX_MEAS],
		attr = dim_attr->meas,
		md_env = md_env,
		p_root = &list[DIM_CPX_MEAS]);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.DMplace(
					(IGRint *) &rc,
					assoc_lis->num_parents,
					list,
					(char *)dim_attr,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method DMcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	/******************* LOCAL PARAMETERS *************************/

	IGRlong status, i;
	IGRlong rc;

	struct DMplan_info	plan_info;
	struct DMenv_param	par_env;
	struct DMloc_param	par_loc;

	IGRpoint cpx_orig_P; /* cpx_orig projection onto win_plan */
	IGRpoint orig_P;     /* dim_orig projection onto win_plan */
	IGRpoint meas_P;     /* dim_meas projection onto win_plan */

	IGRpoint term_ori;   /* origin terminator position */
	IGRpoint term_mea;   /* measure terminator postion */
	IGRdouble orig_meas[3];
	IGRdouble dimn_value;


	IGRdouble trak_dist;
	IGRdouble trak_pt[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];

	struct GRid parents[MAX_DIM_ROOTS];

	/**************************************************************/


	*msg = MSSUCC;

	/*| Fill the duplicate parents if necessary */

	for(i=0; i<count; i++)
	{
		parents[i].objid = list[i].objid;
		parents[i].osnum = list[i].osnum;
	}

	for(i=count; i<NO_CPX_DIM_ROOTS; i++)
	{
		parents[i].objid = list[0].objid;
		parents[i].osnum = list[0].osnum;
	}

	/*| - Gather Data - */

	status =
	om$send(msg = message DMlinear.gather_data(
					(IGRint *) &rc,
					count,
					parents,
					orig_P,
					meas_P,
					cpx_orig_P,
					&trak_dist,
					&plan_info,
					&par_env,
					&par_loc,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Calculate trak_pt absolute position - */

	status =
	om$send(msg = message DMlinear.compute_trak_pt(
						(IGRint *) &rc,
						cpx_orig_P,
						trak_dist,
						&plan_info,
						trak_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_point("trak_pt", trak_pt); */

	/*| - Compute proj_line orientation and term positions - */

	status =
	om$send(msg = message DMlinear.compute_proj_term(
						(IGRint *) &rc,
						trak_pt,
						par_env.proj_angl,
						&plan_info,
						orig_P,
						meas_P,
						term_ori,
						term_mea),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);
	*/

	/*| - Compute break point position - */

	dimn_value = 0.0;

	status =
	om$send(msg = message DMlinear.compute_break_pt(
					(IGRint *) &rc,
					term_ori,
					term_mea,
					&dimn_value,
					orig_meas,
					break_pt,
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("break_pt", break_pt);
		printf("dimn_value = %lf\n", dimn_value);
	*/

	/*| - Compute Leader Point Position - */

	status =
	om$send(msg = message DMlinear.compute_lead_pt(
					(IGRint *) &rc,
					break_pt,
					&par_loc,
					&plan_info,
					leader_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("leader_pt", leader_pt);
	*/

	/*| - Projection lines - */

	status =
	om$send(msg = message DMlinear.make_proj_line(
					(IGRint *) &rc,
					&par_env,
					&par_loc,
					orig_P,
					meas_P,
					term_ori,
					term_mea,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Text - */

	status =
	om$send(msg = message DMdim.make_text_string(
						(IGRint *) &rc,
						dimn_value,
						md_env,
						&par_env,
						&par_loc,
						NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMlinear.make_dim_text(
					(IGRint *) &rc,
					term_ori,
					term_mea,
					break_pt,
					leader_pt,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Terminators - */

	status =
	om$send(msg = message DMlinear.make_dim_term(
					(IGRint *) &rc,
					term_ori,
					term_mea,
					orig_meas,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Line - */

	status =
	om$send(msg = message DMlinear.make_dim_line(
					(IGRint *) &rc,
					term_ori,
					term_mea,
					orig_meas,
					break_pt,
					leader_pt,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/* - Set Symbology - */

	status =
	om$send(msg = message DMroot.chgdp((IGRint *) &rc, &par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->dim_state &= (~DIM_NEEDS_UPDATE);

	return(OM_S_SUCCESS);
}

method compute_trak_pt(
	IGRint *msg;
	IGRdouble dim_orig[3];
	IGRdouble trak_dist;
	struct DMplan_info *plan_info;
	IGRdouble trak_pt[3])
{
	IGRint rc;
	IGRdouble *trak_vec;

	if (me->mea_trak & DM_MEA_AXIS)
	{
		trak_vec = (me->mea_trak & DM_TRAK_DIR)?
				plan_info->act_plan.vec_ypos:
				plan_info->act_plan.vec_yneg;
	}
	else
	{
		trak_vec = (me->mea_trak & DM_TRAK_DIR)?
				plan_info->act_plan.vec_xpos:
				plan_info->act_plan.vec_xneg;
	}

	MATH_ptdelta(&rc, dim_orig, trak_vec, trak_dist, trak_pt);

	/*^
		printf("me->mea_trak=%d\n", me->mea_trak);
		printf("trak_dist=%f\n", trak_dist);
	*/

	return(OM_S_SUCCESS);
}

method compute_proj_term(
	IGRint *msg;
	IGRdouble trak_pt[3];
	IGRdouble proj_angl;
	struct DMplan_info *plan_info;
	IGRdouble orig[3];
	IGRdouble meas[3];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3])
{
	IGRint rc;
	IGRdouble dim_line[6];
	IGRvector mea_axis, perp_axis, trak_dir;
	IGRvector vec_ori, vec_mea;
	IGRdouble proj_vec[3];
	BSrc	bsrc;

	DMget_mea_trak(
		me->mea_trak,
		plan_info,
		mea_axis,
		perp_axis,
		trak_dir);

	/*| - Construct line through trak_pt and parallel to dim axis - */

	DMlineptvec(trak_pt, mea_axis, dim_line);

	/*| - Projection Lines - */

	proj_angl = (90 - proj_angl) * PI / 180.0;

	MATH_rotate_vector(
		&rc,
		mea_axis,
		proj_angl,
		plan_info->win_plan.matrix,
		proj_vec);

	/*| - Project orig and meas onto dim_line - */

	MATH_proj_along_vector(&rc, orig, proj_vec, dim_line, term_ori);
	MATH_proj_along_vector(&rc, meas, proj_vec, dim_line, term_mea);

	/*| - Set Origin & Measure Proj line directions - */

	BSmkvec(&bsrc, vec_ori, orig, term_ori);
	BSmkvec(&bsrc, vec_mea, meas, term_mea);

	if (BSdotp(&bsrc, vec_ori, trak_dir) > 0)
		me->mea_trak |= DM_ORIG_DIR;
	else	me->mea_trak &= ~DM_ORIG_DIR;

	if (BSdotp(&bsrc, vec_mea, trak_dir) > 0)
		me->mea_trak |= DM_MEAS_DIR;
	else	me->mea_trak &= ~DM_MEAS_DIR;

	/*^
		print_point("orig", orig);
		print_point("meas", meas);
		print_point("proj_vec", proj_vec);
		print_line("dim_line", dim_line);
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);
	*/

	return(OM_S_SUCCESS);
}

method compute_break_pt(
	IGRint *msg;
	IGRdouble orig[3];
	IGRdouble meas[3];
	IGRdouble *dimn_value;
	IGRdouble dimline_vec[3];
	IGRdouble break_pt[3];
	struct DMplan_info *plan_info)
{
	IGRint rc;
	IGRdouble *from_pt;
	IGRdouble displacement;
	IGRdouble sca_fact;
	BSrc	bsrc;

	BSmkvec(&bsrc, dimline_vec, orig, meas);
	*dimn_value = BSlenvec(&bsrc, dimline_vec);
	BSnorvec(&bsrc, dimline_vec);
	sca_fact = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
	*dimn_value = *dimn_value / sca_fact;
	MAscalvc(&bsrc, &sca_fact, dimline_vec, dimline_vec);

	switch (me->brk_pos)
	{
		case BRK_LEFT:

			/*| - Break Left */

			from_pt = orig;
			displacement = - me->brk_dist;
			break;

		case BRK_CENTER:

			/*| - Break Center */

			from_pt = orig;
			displacement = me->brk_dist * (*dimn_value);
			break;

		case BRK_RIGHT:

			/*| - Break Right */

			from_pt = meas;
			displacement = me->brk_dist;
			break;

		default:
			from_pt = NULL;
			displacement = 0.0;
			printf("compute_break_pt: Invalid brk_pos = %d\n",me->brk_pos);
			return(OM_E_ABORT);
	};

	MATH_ptdelta(&rc, from_pt, dimline_vec, displacement, break_pt);

	/*^
		printf("dimension value = %lf\n", *dimn_value);
		printf("displacement = %f\n", displacement);
		printf("me->brk_dist = %f\n", me->brk_dist);
		print_point("dimline_vec", dimline_vec);
		print_point("orig", orig);
		print_point("meas", meas);
		print_point("break_pt", break_pt);
	*/

	return(OM_S_SUCCESS);
}

method get_mea_trak_info(
	IGRdouble cpx_origin[3];
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct ret_struct str;

	status =
	DMnode_give_structure(
			&rc,
			DIM_CPX_ORIG,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&str);
	dm$status(action = RET_STATUS);

	math_v_equal(cpx_origin, str.var.point_st.pt);
	*mea_trak = me->mea_trak;
	*trak_dist = me->trak_dist;
	return(OM_S_SUCCESS);
}

method compute_lead_pt(
	IGRint *msg;
	IGRdouble break_pt[3];
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble leader_pt[3])
{
	int i;
	IGRdouble *axis_for_text;

	*msg = DIM_S_SUCCESS;

	if (!me->leader)
	{
		for (i=0; i<3; i++)
			leader_pt[i] = break_pt[i];
		return(OM_S_SUCCESS);
	}

	switch (par_loc->txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:
		axis_for_text = plan_info->win_plan.vec_xpos;
		break;

		case TXT_ORIE_VERTICAL:
		axis_for_text = plan_info->win_plan.vec_ypos;
		break;

		case TXT_ORIE_PERPENDICULAR:
		axis_for_text =	(me->mea_trak & DM_MEA_AXIS)?
				plan_info->act_plan.vec_ypos:
				plan_info->act_plan.vec_xpos;
		break;

		default:
		printf("compute_lead_pt: Error in txt_orie %d\n",
			par_loc->txt_orie);
		return(OM_E_ABORT);
	}

	for (i=0; i<3; i++)
		leader_pt[i] = break_pt[i] + me->lead_dist * axis_for_text[i];

	/*^
		print_point("break_pt", break_pt);
		printf("lead_dist = %lf\n", me->lead_dist);
		print_point("leader_pt", leader_pt);
	*/

	return(OM_S_SUCCESS);
}

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble cpx_orig_P[3];
	IGRdouble *trak_dist;
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint index, min_dist_used;
	IGRdouble min_dist;
	IGRdouble cpx_orig[3];
	IGRdouble dim_orig[3];
	IGRdouble dim_meas[3];
	IGRdouble norm[3], ptplan[3];
	IGRdouble sca_fact,old_trak;
	BSrc	bsrc;

	/*| - Get dimension parameters - */

	status =
	om$send(msg = message DMdim.get_active_params((IGRint *) &rc, par_env, par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* - Adjust trak_dist - */

	min_dist_used = 0;
	if (DMancestry_valid(list[DIM_CPX_ORIG], OPP_DMlinear_class_id))
	{
		min_dist = par_env->txt_heig * par_env->lin_offs_r;
		if (me->trak_dist < min_dist)
		{
			old_trak = me->trak_dist;
			me->trak_dist = min_dist;
			min_dist_used = 1;
		}
	}

	/*| - Get origin and measure pnt positions - */

	status =
	om$send(msg = message DMlinear.get_orig_meas(
					(IGRint *) &rc,
					count,
					list,
					md_env,
					plan_info,
					(char *)&me->mea_trak,
					trak_dist,
					dim_orig,
					dim_meas,
					cpx_orig),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Set depth to complex origin position - */

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[3 + index*4] =
		plan_info->act_plan.matrix[3 + index*4] = cpx_orig[index];
	}

	if(min_dist_used)
	{
		double ret_vec;

		sca_fact = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
		/*"old trak:%lf min_dist:%lf sca:%lf\n",old_trak,min_dist,sca_fact*/
		/*"trak dist:%lf,my_dist:%lf\n",*trak_dist,me->mea_trak*/

		if( old_trak > min_dist/sca_fact)
			ret_vec = old_trak;
		else
		 	ret_vec = min_dist/sca_fact;
		me->trak_dist = ret_vec;

		*trak_dist = (*trak_dist - min_dist) + ret_vec;
	}

	/*| - Project the orig and meas pnts onto win_plan - */

	for (index=0; index<3; index++)
	{
		norm[index] = plan_info->win_plan.matrix[index+8];
		ptplan[index] = plan_info->win_plan.matrix[4*index+3];
	}

	status =
	BSproj1(&bsrc,
		dim_orig,
		norm,
		ptplan,
		orig_P);
	dm$status(action = RET_STATUS);

	status =
	BSproj1(&bsrc,
		cpx_orig,
		norm,
		ptplan,
		cpx_orig_P);
	dm$status(action = RET_STATUS);

	status =
	BSproj1( &bsrc,
		dim_meas,
		norm,
		ptplan,
		meas_P);
	dm$status(action = RET_STATUS);

	/*^
		print_point("orig_P", orig_P);
		print_point("meas_P", meas_P);
		print_point("cpx_orig_P", cpx_orig_P);
		printf("mea_trak=%d, trak_dist=%lf\n",
			me->mea_trak, *trak_dist);
	*/

	return(OM_S_SUCCESS);
}

method leader_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *leader)
{
	IGRint status, rc;
	IGRdouble *mea_axis, *axis_for_text;
	IGRdouble dotp;
	struct DMplan_info plan_info;
	struct DMloc_param par_loc;
	BSrc	bsrc;

	*msg = DIM_S_SUCCESS;

	status =
	om$send(msg = message DMroot.get_dim_params(
						(IGRint *) &rc,
						DM_LOC_PARAM,
						sizeof(par_loc),
						(char *)&par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						(IGRint *) &rc,
						md_env,
						&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->leader = *leader = FALSE;

	if (par_loc.txt_orie == TXT_ORIE_PARALLEL
	||  me->brk_pos == BRK_CENTER)
	{
		/*|TXT_ORIE_PARALLEL or BRK_CENTER - leader NOT needed*/

		me->leader = *leader = FALSE;
		return(OM_S_SUCCESS);
	}

	mea_axis = (me->mea_trak & DM_MEA_AXIS)?
			plan_info.act_plan.vec_xpos:
			plan_info.act_plan.vec_ypos;

	switch (par_loc.txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:
		axis_for_text = plan_info.win_plan.vec_xpos;
		break;

		case TXT_ORIE_VERTICAL:
		axis_for_text = plan_info.win_plan.vec_ypos;
		break;

		case TXT_ORIE_PERPENDICULAR:
		axis_for_text = (me->mea_trak & DM_MEA_AXIS)?
				plan_info.act_plan.vec_ypos:
				plan_info.act_plan.vec_xpos;
		break;
	}

	/* - Find if dimension line is parallel to the
	     required text orientation - */

	dotp = fabs(BSdotp(&bsrc, mea_axis, axis_for_text));
	me->leader = *leader = !(dotp > DOTP_LOWER_BOUND && dotp < DOTP_UPPER_BOUND);

	return(OM_S_SUCCESS);
}

method get_parent_info(
	IGRboolean   *orig_needed;
	IGRboolean   *meas_needed)
{
	*orig_needed =
	*meas_needed = TRUE;

	return(OM_S_SUCCESS);
}

method change_dimension_origin(
	IGRint *msg;
	struct GRid new_orig;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;
	IGRint cn_type;
	extern IGRboolean ASbroadcast_in_progress;

	/* - IMPORTANT - CHECK TO SEE IF NEW OBJECT TYPE IS VALID - */

	status =
	om$send(msg = message DMroot.change_parent(
					(IGRint *) &rc,
					DIM_CPX_ORIG,
					new_orig,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!ASbroadcast_in_progress)
	{
		cn_type = ND_COMP;
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &my_grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_dimension_measurement(
	IGRint *msg;
	struct GRid new_meas;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;
	IGRint cn_type;
	extern IGRboolean ASbroadcast_in_progress;

	/* - IMPORTANT - CHECK TO SEE IF NEW OBJECT TYPE IS VALID - */

	status =
	om$send(msg = message DMroot.change_parent(
					(IGRint *) &rc,
					DIM_CPX_MEAS,
					new_meas,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!ASbroadcast_in_progress)
	{
		cn_type = ND_COMP;
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &my_grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status;
	IGRpoint cpx_origin;
	IGRint index;
	IGRchar mea_trak;
	IGRdouble trak_dist = 0.0;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						(IGRint *) msg,
						md_env,
						plan_info),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMlinear.get_mea_trak_info(
						cpx_origin,
						&mea_trak,
						&trak_dist,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] = cpx_origin[index];
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method init_ter_loca(IGRdouble ter_limit)
{
	char ter_loca;

	ter_loca = (me->dim_value > ter_limit)?
				TER_LOCA_INTERNAL:
				TER_LOCA_EXTERNAL;
	if (ter_loca != me->ter_loca)
	{
		me->dim_state |= DIM_NEEDS_UPDATE;
		me->ter_loca = ter_loca;
	}

	return(OM_S_SUCCESS);
}

method set_proj_disp(IGRchar *proj_disp)
{
	return(OM_S_SUCCESS);
}

end implementation DMlinear;
