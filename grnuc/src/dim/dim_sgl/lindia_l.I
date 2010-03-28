class implementation DMlindia;

#define AS_DEBUG 1

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
	struct ret_struct	retst;

	*mea_trak = me->mea_trak;
	*trak_dist = me->trak_dist;

	/*| - Get dimension plane orientation - */

	status =
	dm$get_plan_info(
		plan_objid = list[DIM_ROOT_PLAN].objid,
		osnum = list[DIM_ROOT_PLAN].osnum,
		md_env = md_env,
		plan_info = plan_info);
	dm$status(action = RET_STATUS);

	/*| - Get origin and measure pnt positions - */

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_LDIA_ORIG].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	math_v_equal(dim_orig, retst.var.point_st.pt);
	math_v_equal(cpx_orig, dim_orig);

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_LDIA_MEAS].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	math_v_equal(dim_meas, retst.var.point_st.pt);

	return(OM_S_SUCCESS);
}

end implementation DMlindia;
