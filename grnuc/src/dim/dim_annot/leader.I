class implementation DMleader;

#define AS_DEBUG	1

from DMsrc import DMgive_tangent;

method fill_info( IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{

	IGRint status, rc, i;
	IGRshort src_type;
	IGRlong long_rc;
	struct IGRbsp_curve *bsp_curve;
	struct DMdyn_annot *place_attr;
	IGRdouble end_pt[3];
	IGRint num_parents;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRmd_env mod_info;

	/* - Gather data     */

	place_attr = (struct DMdyn_annot *)info;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&num_parents, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	status=
	om$send(msg = message DMannot.gather_data(
					&rc,
					num_parents,
					list,
					place_attr->attach_pt,
					end_pt,
					&place_attr->plan_info,
					&place_attr->par_senv,
					md_env),
		targetid =my_id);
	dm$status(action=RET_STATUS);

	status =
	om$send(msg = message DMannot.get_graphics(
					FALSE,
					&place_attr->go_grid[AN_ANNOT_TEXT],
					&place_attr->go_grid[AN_POLY_LINE],
					&place_attr->go_grid[AN_TER_TEXT],
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	if( place_attr->go_grid[AN_ANNOT_TEXT].objid != NULL_OBJID)
	{
		/*| text object exits delete it */
		
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_TEXT,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message NDnode.ASreturn_go(
				&list[AN_ROOT_ELEM1],
				&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if (md_env->md_env.matrix_type != MAIDMX)
		mod_info = *md_env;

	status =
	om$send(msg = message DMsrc.DMgive_tangent(
					&rc,
					&src_type,
					place_attr->src_dir,
					NULL,
					&mod_info),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if (src_type == POINT_TYPE)
	{
		/*| - Element is point type */

		for(i=0; i<3; i++)
		place_attr->src_dir[i] =
		place_attr->plan_info.act_plan.vec_xpos[i];
	}

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
		targetid = place_attr->go_grid[AN_POLY_LINE].objid,
		targetos = place_attr->go_grid[AN_POLY_LINE].osnum);
	dm$status(action = RET_STATUS);

	status=
	om$vla_set_dimension(varray = me->break_pt,
			     size  = bsp_curve->num_poles *3);
	dm$status(action = RET_STATUS);

	memcpy( me->break_pt,
		bsp_curve->poles,
		3*sizeof(IGRdouble) * bsp_curve->num_poles);

	if( bsp_curve->num_poles ==2)
	{
		vec_equal(place_attr->attach_pt,me->break_pt);
	}
	/*^ print_point("attach point",me->break_pt); */

	place_attr->ele_header.dis_att = NULL;

	return(OM_S_SUCCESS);
}
end implementation DMleader;
