class implementation DMcirdia;

#define AS_DEBUG 1

method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status, rc;
	struct ret_struct str;
	IGRint index;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					msg,
					md_env,
					plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMnode_give_structure(
		&rc,
		DIM_CDIA_CURVE,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&str);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] =
			str.var.circle_st.cent_p[index];
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint 		status, rc;
	struct dim_attr	*dim_attr;
	struct GRid	list[MAX_DIM_ROOTS];
	struct GRid	roots[2], context[2];

	dim_attr = (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	roots[0]	= assoc_lis->parents[DIM_CDIA_CURVE];
	roots[1]	= assoc_lis->parents[DIM_ROOT_PLAN];
	context[0]	= assoc_lis->context[DIM_CDIA_CURVE];
	context[1]	= assoc_lis->context[DIM_ROOT_PLAN];

	status =
	dm$create_root(
		type = DMradcen,
		count = 2,
		list = roots,
		context = context,
		attr = dim_attr->orig,
		md_env = md_env,
		p_root = &list[DIM_CDIA_CURVE]);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.DMplace(
					&rc,
					assoc_lis->num_parents,
					list,
					(char *) dim_attr,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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
	IGRint status, rc;
	IGRlong long_rc;
	IGRint index;
	IGRdouble *mea_axis;
	struct ret_struct str;

	*mea_trak = me->mea_trak;
	*trak_dist = me->trak_dist;

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					msg,
					md_env,
					plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMnode_give_structure(
		(IGRint *) &long_rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_CDIA_CURVE].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&str);
	dm$status(action = RET_STATUS);

	if (str.type != circle_type)
	{
		printf("DMcirdia.get_orig_meas: Error in parent type %d\n",
				str.type);
		return(OM_E_ABORT);
	}
	else
	{
		/*^
			printf("circle_type - OK\n");
			print_point("center", str.var.circle_st.cent_p);
			printf("radius=%lf\n", str.var.circle_st.rad);
		*/
	}

	mea_axis = (me->mea_trak & DM_MEA_AXIS)?
				plan_info->act_plan.vec_xpos:
				plan_info->act_plan.vec_ypos;

	for (index=0; index<3; index++)
	{
		cpx_orig[index] =
		dim_orig[index] = str.var.circle_st.cent_p[index] -
				  mea_axis[index] * str.var.circle_st.rad;
		dim_meas[index] = str.var.circle_st.cent_p[index] +
				  mea_axis[index] * str.var.circle_st.rad;
	}

	/*^
		print_point("dim_orig", dim_orig);
		print_point("dim_meas", dim_meas);
		print_point("cpx_orig", cpx_orig);
	*/

	*msg = DIM_S_SUCCESS;
     	return(OM_S_SUCCESS);
}

end implementation DMcirdia;
