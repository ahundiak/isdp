class implementation DMsglpara;
%safe
#include "math.h"
%endsafe

#include "mascalmx.h"
#include "marotmx.h"
#include "mamulmx.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"

#define AS_DEBUG 1

from dim_plan import give_plane;

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint 		status, rc;
	struct dim_attr	*dim_attr;
	struct GRid	list[MAX_DIM_ROOTS];

	dim_attr	= (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	status =
	dm$create_root(
		type = DMkeyseg,
		count = 1,
		list = &assoc_lis->parents[DIM_CPX_ORIG],
		context = &assoc_lis->context[DIM_CPX_ORIG],
		attr = dim_attr->orig,
		md_env = md_env,
		p_root = &list[DIM_CPX_ORIG]);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.DMplace(
					&rc,
					assoc_lis->num_parents,
					list,
					(char *)dim_attr,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status, rc, i, j;
	IGRlong long_rc;
	struct GRid list[MAX_DIM_ROOTS], plan_go, dim_id;
	struct ret_struct dim_line;
	struct GRmd_env mod_info;
	IGRint count, index;
	IGRshort four;
	IGRdouble mea_axis[3], angle;
	IGRmatrix rot_matrix, matrix;
	IGRdouble *win_matrix, *act_matrix;
	IGRvector win_xpos,act_xpos;
	IGRdouble scale, sca_fact;
	struct ret_struct ret_str;
	extern GRclassid OPP_GRgencs_class_id;
	BSrc	bsrc;

	if (me->geom_type & DIM_IMPORTED)
	{
		/*|- imported dim, pass the msg to parent dim */

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					NULL,
					OM_K_MAXINT,
					&count),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&dim_id,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[count-1].objid,
			targetos = list[count-1].osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("dim_id",&dim_id);*/

		status =
		om$send(msg = message DMroot.get_dimension_plane(
							msg,
							&mod_info,
							plan_info),
			targetid = dim_id.objid,
			targetos = dim_id.osnum);
		dm$status(action = RET_STATUS);

	}
	else
	{
	
		status =
		om$send(msg = message DMroot.DMreturn_roots(&count, list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*^
			printf("count = %d\n", count);
			print_grid("dim_plan", &list[DIM_ROOT_PLAN]);
			print_grid("sgpar_line", &list[DIM_SGPAR_LINE]);
		*/

		/*- dimension could be connected directly to coordinate
		    system object(instead of dim_plan object), in this
		    case we need to do a NDgive_structure first and if
		    if fails send a give_plane message
		*/

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&plan_go,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[DIM_ROOT_PLAN].objid,
			targetos = list[DIM_ROOT_PLAN].osnum);
		dm$status(action = RET_STATUS);

		/*|- The object could be a coordinate system*/

		if (DMancestry_valid(plan_go, OPP_GRgencs_class_id))
		{
			ret_str.type = NULL;

			status =
			om$send(msg = message NDnode.NDgive_structure(
							&long_rc,
							&ret_str,
							md_env),
				targetid = list[DIM_ROOT_PLAN].objid,
				targetos = list[DIM_ROOT_PLAN].osnum);
			if ((1 & status & long_rc) && (ret_str.type == ref_generic))
			{
				/*|- Parent is a coordinate system*/
	
				/*- Need to transpose the matrix returned by
				    the NDgive_structure, since the format is
				    different from DMplan matrix */

				for (i=0; i<4; i++)
				{
				    for (j=0; j<4; j++)
				    {
					plan_info->win_plan.matrix[i*4+j] =
					ret_str.var.ref_st.t[j*4+i];
				    }
				}
			}
			else
			{
				/*|- Invalid Dimension plane object*/
				return(OM_E_ABORT);
			}
		}
		else
		{
			if (md_env->md_env.matrix_type != MAIDMX)
				mod_info = *md_env;

			status =
			om$send(msg = message dim_plan.give_plane(
							&rc,
							plan_info->win_plan.matrix,
							&mod_info),
				targetid = plan_go.objid,
				targetos = plan_go.osnum);
			dm$status(action = RET_STATUS);
		}
		
		/*^ print_matrix("md_env matrix",md_env->md_env.matrix); */
	
		status =
		DMcompute_mea_axis(
			&rc,
			&list[DIM_SGPAR_LINE],
			1,
			mea_axis,
			plan_info->win_plan.matrix,
			md_env);
		dm$status(action = RET_STATUS);
	
		/*^ print_point("mea_axis", mea_axis); */
	
		MATH_compute_plan_info(
			&rc,
			mea_axis,
			plan_info->win_plan.matrix,
			plan_info->act_plan.matrix);
	}

	if (me->display & DIM_PLANE_ROTATED)
	{
		four = 4;

		angle = 0.0;
		if(me->display & DIM_PLANE_ROTATED_BY_90)
			angle = -PI * 0.5;
		else if(me->display & DIM_PLANE_ROTATED_BY_180)
			angle = -PI;
		else if(me->display & DIM_PLANE_ROTATED_BY_270)
			angle = -PI * 1.5;

		for( i = 0; i < 3; i++)
		{
			win_xpos[i] = plan_info->win_plan.matrix[i];
			act_xpos[i] = plan_info->act_plan.matrix[i];
		}

		scale = BSlenvec(&bsrc, win_xpos);
		sca_fact = 1.0/scale;

		BSnorvec(&bsrc, win_xpos);
		BSnorvec(&bsrc, act_xpos);
	
		status = 	
		MArotmx(&long_rc, 
			act_xpos,
			&angle,
			matrix);
		dm$status(action = RET_STATUS);

		win_matrix = plan_info->win_plan.matrix;
		act_matrix = plan_info->act_plan.matrix;

		if (fabs(scale - 1.0) > 0.001)
		{
			status =
			MAscalmx(&long_rc,
				&four,
				&four,
				&sca_fact,
				act_matrix,
				act_matrix);
			dm$status(action = RET_STATUS);
		}

		MAmulmx(&bsrc, &four, &four, &four, act_matrix, matrix, rot_matrix);

		angle = -acos(BSdotp(&bsrc, win_xpos, act_xpos));

		/*^
			printf("mea_angle = %f\n",angle);
			print_point("act_axis",rot_matrix);
		*/

		MATH_rotate_vector(
			&rc,
			rot_matrix,
			angle,
			rot_matrix,
			mea_axis);

		/*^ print_point("win_xaxis",mea_axis); */

		MATH_compute_plan_info(
			&rc,
			mea_axis,
			rot_matrix,
			win_matrix);
			
		memcpy(act_matrix, rot_matrix, sizeof(IGRmatrix));

		if (fabs(scale - 1.0) > 0.001)
		{
			status =
			MAscalmx(&long_rc,
				&four,
				&four,
				&scale,
				act_matrix,
				act_matrix);
			dm$status(action = RET_STATUS);

			status =
			MAscalmx(&long_rc,
				&four,
				&four,
				&scale,
				win_matrix,
				win_matrix);
			dm$status(action = RET_STATUS);
		}
	}

	/*^
		print_matrix("act_matrix",plan_info->act_plan.matrix);
		print_matrix("win_matrix",plan_info->win_plan.matrix);
	*/
		
	DMfill_plan_info(plan_info);

	if (me->geom_type & DIM_IMPORTED)
		return(OM_S_SUCCESS);
	
	/*| - Get origin and measure pnt positions - */

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_SGPAR_LINE].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&dim_line);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] =
		dim_line.var.line_st.p0[index];
	}

	*msg = DIM_S_SUCCESS;
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
	struct ret_struct dim_line;
	IGRdouble v0[3], zero[3], xvec[3];
	BSrc	bsrc;

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						plan_info),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("xpos", plan_info->act_plan.vec_xpos);
		print_point("ypos", plan_info->act_plan.vec_ypos);
	*/

	/*| - Get origin and measure pnt positions - */

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		list[DIM_SGPAR_LINE].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&dim_line);
	dm$status(action = RET_STATUS);

	/*^
		print_point("p0", dim_line.var.line_st.p0);
		print_point("p1", dim_line.var.line_st.p1);
	*/

	math_v_equal(dim_orig, dim_line.var.line_st.p0);
	math_v_equal(cpx_orig, dim_line.var.line_st.p0);
	math_v_equal(dim_meas, dim_line.var.line_st.p1);

	zero[0] =
	zero[1] =
	zero[2] = 0.0;

	status =
	BSproj1(&bsrc,
		dim_line.var.line_st.v0,
		&plan_info->win_plan.matrix[8],
		zero,
		v0);
	dm$status(action = RET_STATUS);

	BSnorvec(&bsrc, v0);
	math_v_equal(xvec, plan_info->act_plan.vec_xpos);
	BSnorvec(&bsrc, xvec);

	if (fabs(BSdotp(&bsrc, v0, xvec)) > MINIMUM_DOTP_TOLERANCE)
		me->mea_trak |= DM_MEA_AXIS;
	else	me->mea_trak &= ~DM_MEA_AXIS;

	*mea_trak = me->mea_trak;
	*trak_dist = me->trak_dist;

	return(OM_S_SUCCESS);
}

end implementation DMsglpara;

