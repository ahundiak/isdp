class implementation DMsglarc;

#define AS_DEBUG 1

#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"

method NDplace( struct GRas *assoc_lis;
		struct GRmd_env *md_env;
		char *go_cnst_lis)
{
	IGRint status, rc;
	struct dim_attr	*dim_attr;
	struct GRid par[2], cxt[2];
	struct GRid list[MAX_DIM_ROOTS];

	dim_attr = (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	par[0] = assoc_lis->parents[DIM_CPX_ORIG];
	par[1] = assoc_lis->parents[DIM_ROOT_PLAN];
	cxt[0].objid = cxt[1].objid = NULL_OBJID;

	status =
	dm$create_root(
		type = DMarc,
		count = 2,
		list = par,
		context = cxt,
		attr = dim_attr->orig,
		md_env = md_env,
		p_root = &list[DIM_CPX_ORIG]);
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

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char   *attr;
	struct GRmd_env *md_env)
{
	IGRint status;

	status =
	om$send(msg = message DMdim.DMplace(msg, count, list, attr, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

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

method give_orig_meas(
	IGRlong *msg;
	IGRint 	count;
	struct GRid *list;
	struct dm_ang_src_st *angle_st;
	struct DMplan_info *plan_info;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	struct dim_ret_struct dmstr;
	IGRdouble horizantal[3], *center, *matrix;
	IGRdouble radius1, radius2;
	IGRdouble orig_vec[3], meas_vec[3], normal[3];
	BSrc	bsrc;

	/*| - get the arc structure */

	status =
	om$send(msg = message DMroot.get_dimension_plane(&rc, md_env, plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMsrc_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		FALSE,
		list[DIM_CPX_ORIG].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&dmstr);
	dm$status(action = RET_STATUS);

	matrix = plan_info->win_plan.matrix;
	center = dmstr.var.dm_arc.center;

	for (i=0; i<3; i++)
	{
		plan_info->win_plan.matrix[i*4 + 3] =
		plan_info->act_plan.matrix[i*4 + 3] = center[i];
	}

	*trak_dist = me->trak_dist;

	/*^
		print_point("center",center);
	*/

	horizantal[0] = matrix[0];
	horizantal[1] = matrix[1];
	horizantal[2] = matrix[2];

	normal[0] = matrix[8];
	normal[1] = matrix[9];
	normal[2] = matrix[10];

	me->mea_trak = 0;

	/*^ print_matrix("matrix", matrix); */

	BSmkvec(&bsrc, orig_vec, center, dmstr.var.dm_arc.start_pt);
	radius1 = BSlenvec(&bsrc, orig_vec);
	if (me->dim_type == SINGLE_ARC_LENGTH)
		angle_st->arc_radius = radius1;
	else	angle_st->arc_radius = 1.0;
	BSnorvec(&bsrc, orig_vec);

	BSmkvec(&bsrc, meas_vec, center, dmstr.var.dm_arc.end_pt);
	radius2 = BSlenvec(&bsrc, meas_vec);
	BSnorvec(&bsrc, meas_vec);

	for(i = 0; i < 3; i++)
	{
		angle_st->orig_line.point1[i] = 
			center[i] + ((radius1 - 0.001) * orig_vec[i]);
		angle_st->orig_line.point2[i] =
			center[i] + radius1 * orig_vec[i];
		angle_st->meas_line.point1[i] =
			center[i] + ((radius2 - 0.001) * meas_vec[i]);
		angle_st->meas_line.point2[i] =
			center[i] + radius2 * meas_vec[i];
	}

	DMproject_points(
		&rc,
		angle_st->orig_line.point1,
		angle_st->orig_line.point2,
		angle_st->meas_line.point1,
		angle_st->meas_line.point2,
		&plan_info->act_plan.matrix[8],
		center);

	for (i=0; i<3; i++)
	{
		angle_st->cpx_orig_line.point1[i] = 
		angle_st->orig_line.point1[i];
		angle_st->cpx_orig_line.point2[i] = 
		angle_st->orig_line.point2[i];
	}		

	/*^
		print_point("orig_vec",orig_vec);
		print_point("meas_vec",meas_vec);
		print_point("origpt1",angle_st->orig_line.point1);
		print_point("origpt1",angle_st->orig_line.point2);
		print_point("measpt1",angle_st->meas_line.point2);
		print_point("measpt1",angle_st->meas_line.point1);
	*/

	return(OM_S_SUCCESS);
}

method get_cpx_origin(
	IGRint *msg;
	IGRdouble *origin;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct ret_struct retst;

	status= 
	DMnode_give_structure(
		&rc,
		DIM_CPX_ORIG,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	math_v_equal(origin, retst.var.circle_st.cent_p);

	/*^ print_point("origin", origin); */

	return(OM_S_SUCCESS);
}

method set_meas_type(IGRint type)
{
	me->dim_type = type;
	me->dim_state |= DIM_NEEDS_UPDATE;
	return(OM_S_SUCCESS);
}

end implementation DMsglarc;
