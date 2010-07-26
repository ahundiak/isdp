class implementation DMlincpx;

#define AS_DEBUG 1

#include "dimcomplex.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"

extern	IGRboolean	BSproj0();

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint cpx_type, rel_pos;
	IGRboolean first_in_cpx;
	struct GRid first, meas, null_grid;
	struct GRid dim_before, dim_after;
	struct GRid list_c[MAX_DIM_ROOTS];
	struct dim_attr *dim_attr;

	null_grid.objid = NULL_OBJID;

	dim_attr = (struct dim_attr *)attr;
	DMcopy_roots(list_c, list, count);
	first_in_cpx = !DMancestry_valid(
				list_c[DIM_CPX_ORIG],
				OPP_DMlincpx_class_id);

	if (!first_in_cpx)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
			targetid = list_c[DIM_CPX_ORIG].objid,
			targetos = list_c[DIM_CPX_ORIG].osnum);
		dm$status(action = RET_STATUS);

		dim_before.objid = NULL_OBJID;
		dim_after.objid  = NULL_OBJID;
		cpx_type = (dim_attr->dim_type == STRINGED_LINEAR)?STRINGED_CPX:STACKED_CPX;

		status =
		om$send(msg = message DMroot.find_position_in_cpx(
						&rc,
						cpx_type,
						null_grid,
						list_c[DIM_CPX_MEAS],
						md_env,
						&rel_pos,
						&dim_before,
						&dim_after),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$get_objid_at_index(
			objid = first.objid,
			osnum = first.osnum,
			index = DIM_CPX_ORIG,
			p_chanselect = &ND_father,
			objidaddr = &list_c[DIM_CPX_ORIG].objid,
			osnumaddr = &list_c[DIM_CPX_ORIG].osnum);
		dm$status(action = RET_STATUS);

		if ((dim_attr->dim_type == STRINGED_LINEAR)
		&&  (rel_pos == CPX_OPPOSITE_FAR || rel_pos == CPX_OPPOSITE_NEAR))
		{
			meas = list_c[DIM_CPX_ORIG];
			list_c[DIM_CPX_ORIG] = list_c[DIM_CPX_MEAS];
			list_c[DIM_CPX_MEAS] = meas;
		}
	}

	status =
	om$send(msg = message DMlinear.DMplace(msg, count, list_c, attr, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx)
	{
		if (dim_before.objid != NULL_OBJID
		&&  dim_after.objid == NULL_OBJID
		&&  dim_attr->dim_type != STRINGED_LINEAR)
		{
			struct GRmd_env mod_info;

			DMget_module_info(&mod_info);

			status =
			om$send(msg = message DMroot.delete_dim_go(
								&rc,
								DIM_ORI_PROJ,
								&mod_info),
				targetid = dim_before.objid,
				targetos = dim_before.osnum);
			dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message DMroot.insert_into_cpx(
					&rc,
					ADJUST_TRAK_DIST,
					md_env,
					rel_pos,
					&dim_before,
					&dim_after),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

/* - Override DMlinear messages - */

method get_mea_trak_info(
	IGRdouble cpx_origin[3];
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid prev, first;
	IGRboolean first_in_cpx;

	if (me->dim_type == STRINGED_LINEAR)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMlinear.get_mea_trak_info(
					cpx_origin,
					mea_trak,
					trak_dist,
					md_env),
			mode = OM_e_wrt_message,
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		if (first.objid != my_id)
			*trak_dist += me->trak_dist;

		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx)
	{
		*trak_dist += me->trak_dist;

		status =
		om$send(msg = message DMlinear.get_mea_trak_info(
					cpx_origin,
					mea_trak,
					trak_dist,
					md_env),
			targetid = prev.objid,
			targetos = prev.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		IGRdouble cum_trak_dist;

		cum_trak_dist = *trak_dist;

		status =
		om$send(msg = message DMlinear.get_mea_trak_info(
					cpx_origin,
					mea_trak,
					trak_dist,
					md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);

		*trak_dist += cum_trak_dist;
	}

	return(OM_S_SUCCESS);
}

method get_orig_meas(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	IGRdouble dim_orig[3];
	IGRdouble dim_meas[3];
	IGRdouble cpx_orig[3])
{
	IGRint status, rc, index;
	struct ret_struct retst;
	GRclassid obj_class;

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					&rc,
					md_env,
					plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*trak_dist = 0;

	status =
	om$send(msg = message DMlinear.get_mea_trak_info(
						cpx_orig,
						mea_trak,
						trak_dist,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] = cpx_orig[index];
	}

	if (me->dim_type == STRINGED_LINEAR)
	{
		status =
		om$get_classid(
			osnum = list[DIM_CPX_ORIG].osnum,
			objid = list[DIM_CPX_ORIG].objid,
			p_classid = &obj_class);
		dm$status(action = RET_STATUS);

		if (om$is_ancestry_valid(
			subclassid = obj_class,
			superclassid = OPP_DMroot_class_id) == OM_S_SUCCESS)
		{
			/* - If not the first dimension in the complex
			     obtain the measurement point of the previous
			     dimension as your origin point - */

			status =
			DMnode_give_structure(
				&rc,
				DIM_CPX_MEAS,
				MEAS_INFO,
				(me->geom_type & DIM_IMPORTED),
				NULL_OBJID,
				list[DIM_CPX_ORIG].objid,
				list[DIM_CPX_ORIG].osnum,
				md_env,
				&retst);
			dm$status(action = RET_STATUS);

			math_v_equal(dim_orig, retst.var.point_st.pt);
		}
		else	math_v_equal(dim_orig, cpx_orig);
	}
	else	math_v_equal(dim_orig, cpx_orig);

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_CPX_MEAS].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	math_v_equal(dim_meas, retst.var.point_st.pt);

	return(OM_S_SUCCESS);
}

/* - Override DMroot messages - */

method give_rel_pos(
	IGRint *msg;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos)
{
	IGRint status, rc;
	struct DMplan_info plan_info;
	IGRdouble *mea_axis;
	IGRdouble dimline[6];
	IGRdouble dim_orig[3];
	IGRdouble dim_meas[3];
	IGRdouble cpx_orig[3];
	IGRdouble orig_meas[3];
	IGRdouble orig_new[3];
	IGRdouble dist1, dist2;
	IGRint count;
	struct GRid list[MAX_DIM_ROOTS];
	struct ret_struct retst;
	IGRdouble *newpt;
	IGRdouble dim_orig_D[3];
	IGRdouble dim_meas_D[3];
	IGRdouble newpt_D[3];
	IGRdouble trak_dist;
	BSrc	bsrc;

	*msg = DIM_S_SUCCESS;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMlincpx.get_orig_meas(
						&rc,
						count,
						list,
						md_env,
						&plan_info,
						(IGRchar *) &me->mea_trak,
						&trak_dist,
						dim_orig,
						dim_meas,
						cpx_orig),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(new_dim.objid == NULL_OBJID)?FALSE:TRUE,
		new_meas.objid,
		new_dim.objid,
		new_meas.osnum,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	newpt = retst.var.point_st.pt;

	mea_axis = (me->mea_trak & DM_MEA_AXIS)?
			plan_info.act_plan.vec_xpos:
			plan_info.act_plan.vec_ypos;

	DMlineptvec(cpx_orig, mea_axis, dimline);

	BSproj0(&bsrc, dim_orig, dimline, dim_orig_D);
	BSproj0(&bsrc, dim_meas, dimline, dim_meas_D);
	BSproj0(&bsrc, newpt, dimline, newpt_D);

	/*^
		print_point("dim_orig_D", dim_orig_D);
		print_point("dim_meas_D", dim_meas_D);
		print_point("newpt_D", newpt_D);
	*/

	BSmkvec(&bsrc, orig_meas, dim_orig_D, dim_meas_D);
	BSmkvec(&bsrc, orig_new,  dim_orig_D, newpt_D);

	dist1 = BSlenvec(&bsrc, orig_meas);
	dist2 = BSlenvec(&bsrc, orig_new);

	if (BSdotp(&bsrc, orig_meas, orig_new) < 0.0)
	{
		if (dist1 < dist2)
			*rel_pos = CPX_OPPOSITE_FAR;
		else	*rel_pos = CPX_OPPOSITE_NEAR;
	}
	else
	{
		if (dist1 < dist2)
			*rel_pos = CPX_FAR;
		else	*rel_pos = CPX_NEAR;
	}

	return(OM_S_SUCCESS);
}

method swap_if_needed(struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble *mea_axis;
	struct DMplan_info plan_info;
	struct ret_struct orig, meas;
	struct GRid list[MAX_DIM_ROOTS], tmp_grid;
	IGRvector orig_meas;
	IGRint count;
	BSrc	bsrc;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			list[DIM_CPX_ORIG].objid,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&orig);
	dm$status(action = RET_STATUS);

	status =
	DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			MEAS_INFO,
			(me->geom_type & DIM_IMPORTED),
			list[DIM_CPX_MEAS].objid,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&meas);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					&rc,
					md_env,
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	mea_axis = (me->mea_trak & DM_MEA_AXIS)?
			plan_info.act_plan.vec_xpos:
			plan_info.act_plan.vec_ypos;

	BSmkvec(&bsrc, orig_meas, orig.var.point_st.pt, meas.var.point_st.pt);

	if (BSdotp(&bsrc, orig_meas, mea_axis) > 0)
		return(OM_S_SUCCESS);

	tmp_grid = list[DIM_CPX_ORIG];
	list[DIM_CPX_ORIG] = list[DIM_CPX_MEAS];
	list[DIM_CPX_MEAS] = tmp_grid;
	tmp_grid.objid = NULL_OBJID;

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					list,
					tmp_grid,
					ND_FULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method fill_info(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct DMdyn_linear *place_attr;
	struct GRid prev;
	IGRboolean last_in_cpx;

	status =
	om$send(msg = message DMlinear.fill_info(
					msg,
					control,
					level,
					info,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	place_attr = (struct DMdyn_linear *)info + (*level);

	status =
	om$send(msg = message DMroot.give_previous(
					&rc,
					&place_attr->first_in_cpx,
					&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					place_attr->next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (place_attr->next[0].objid != NULL_OBJID
	&&  me->dim_type == STRINGED_LINEAR)
	{
		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_NEEDS_UPDATE),
			targetid = place_attr->next[0].objid,
			targetos = place_attr->next[0].osnum);
		dm$status(action = RET_STATUS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_dimension_origin(
	IGRint *msg;
	struct GRid new_orig;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;
	IGRboolean first_in_cpx;
	struct GRid prev;
	IGRint cpx_type;

	status =
	om$send(msg = message DMroot.give_previous(
						&rc,
						&first_in_cpx,
						&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_complex_type(&cpx_type),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx && (cpx_type == STRINGED_CPX))
	{
		/* - For a STRINGED complex dimension - changing the
		     origin point of measurement for any component
		     except the first one is basically changing the
		     measurement point for the previous dimension. - */

		status =
		om$send(msg = message DMroot.change_dimension_measurement(
							&rc,
							new_orig,
							md_env),
			targetid = prev.objid,
			targetos = prev.osnum);
		dm$status(action = RET_STATUS);

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMlinear.change_dimension_origin(
							&rc,
							new_orig,
							md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	DMupdate_complex(&rc, my_grid, md_env);
	dm$status(action = RET_STATUS);

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

	status =
	om$send(msg = message DMlinear.change_dimension_measurement(
							&rc,
							new_meas,
							md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	DMupdate_complex(&rc, my_grid, md_env);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method set_proj_disp(IGRchar *proj_disp)
{
	IGRint status, rc;
	IGRboolean last_in_cpx, first_in_cpx;
	struct GRid prev, next[2];

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if ((me->dim_type == STRINGED_LINEAR)
	&& !(me->dim_state & DIM_IN_PLACEMENT)
	&& !(me->dim_state & DIM_IN_MODIFY))
	{
		if (!first_in_cpx)
		{
			status =
			om$send(msg = message DMlincpx.compute_proj_disp(
						me->mea_trak,
						PROJ_DISP_ORI,
						me->trak_dist,
						first_in_cpx,
						proj_disp),
				targetid = prev.objid,
				targetos = prev.osnum);
			dm$status(action = RET_STATUS);
		}

		if (!last_in_cpx)
		{
			status =
			om$send(msg = message DMlincpx.compute_proj_disp(
					me->mea_trak,
					PROJ_DISP_MEA,
					me->trak_dist,
					first_in_cpx,
					proj_disp),
				targetid = next[0].objid,
				targetos = next[0].osnum);
			dm$status(action = RET_STATUS);
		}
	}
	else if (!last_in_cpx && me->dim_type != STRINGED_LINEAR)
		*proj_disp &= ~PROJ_DISP_ORI;

	return(OM_S_SUCCESS);
}

method compute_proj_disp(
	IGRchar mea_trak;
	IGRchar proj_side;
	IGRdouble trak_dist;
	IGRboolean first_in_cpx;
	IGRchar *proj_disp)
{
	IGRint status, rc;
	IGRboolean iam_first;
	IGRchar ori_dir, mea_dir;
	struct GRid prev;

	if (proj_side == PROJ_DISP_ORI)
	{
		/*|PROJ_DISP_ORI*/

		ori_dir = (mea_trak & DM_ORIG_DIR)?TRUE:FALSE;
		mea_dir = (me->mea_trak & DM_MEAS_DIR)?TRUE:FALSE;;

		if (ori_dir != mea_dir)
		{
			/*"different: %d, %d\n", ori_dir, mea_dir*/
			return(OM_S_SUCCESS);
		}

		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						&iam_first,
						&prev),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (iam_first)
			return(OM_S_SUCCESS);

		if (ori_dir)
		{
			/*|ori_dir ON*/

			if (me->trak_dist > trak_dist)
			{
				/*|Turn off ori_disp*/
				*proj_disp &= ~proj_side;
			}
		}
		else
		{
			/*|ori_dir OFF*/

			if (!(me->trak_dist > trak_dist))
			{
				/*|Turn off ori_disp*/
				*proj_disp &= ~proj_side;
			}
		}
	}
	else
	{
		/*|PROJ_DISP_MEA*/

		ori_dir = (me->mea_trak & DM_ORIG_DIR)?TRUE:FALSE;
		mea_dir = (mea_trak & DM_MEAS_DIR)?TRUE:FALSE;

		if (ori_dir != mea_dir)
		{
			/*"different: %d, %d\n", ori_dir, mea_dir*/
			return(OM_S_SUCCESS);
		}

		if (first_in_cpx)
		{
			/*|Turn off mea_disp*/
			*proj_disp &= ~proj_side;
			return(OM_S_SUCCESS);
		}

		if (ori_dir)
		{
			/*|ori_dir ON*/

			if (!(trak_dist > me->trak_dist))
			{
				/*|Turn off mea_disp*/
				*proj_disp &= ~proj_side;
			}
		}
		else
		{
			/*|ori_dir OFF*/

			if (trak_dist > me->trak_dist)
			{
				/*|Turn off mea_disp*/
				*proj_disp &= ~proj_side;
			}
		}
	}

	return(OM_S_SUCCESS);
}

end implementation DMlincpx;

