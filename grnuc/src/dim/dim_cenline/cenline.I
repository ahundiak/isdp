class implementation DMcenline;

#define AS_DEBUG 1

#include "diminst.h"
#include "dimext.h"
#include "dimmod.h"
#include "bsconic.h"
#include "bsprj_cv_pl.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscncprop.h"
#include "bsalloccv.h"
 
extern IGRboolean BSproj0();
extern ASsuper_construct();
extern free();

from IGEgragad import DPinrot;
from dim_param import give_internal, edit;
from DMsrc import DMgive_src_info;
from GRcontext import GRgetmodule_env;

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint status, rc;
	struct cenline_attr *cenline_attr;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRid	roots[2], context[2];

	cenline_attr = (struct cenline_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	roots[0]	= assoc_lis->parents[DIM_CEN_CURVE];
	roots[1]	= assoc_lis->parents[DIM_ROOT_PLAN];
	context[0]	= assoc_lis->context[DIM_CEN_CURVE];
	context[1]	= assoc_lis->context[DIM_ROOT_PLAN];

	status =
	dm$create_root(
		type = DMradcen,
		count = 2,
		list = roots,
		context = context,
		attr = cenline_attr->pnt_meas,
		md_env = md_env,
		p_root = &list[DIM_CEN_CURVE]);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.DMplace(
					&rc,
					assoc_lis->num_parents,
					list,
					assoc_lis->as_attr,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status;
	struct cenline_attr *cen_attr;

	cen_attr = (struct cenline_attr *)attr;

	me->gap_r = cen_attr->gap_r;
	me->minor_len_r = cen_attr->minor_len_r;
	me->major_len_r = cen_attr->major_len_r;
	me->posn = cen_attr->posn;
	me->dim_state = cen_attr->dim_state;
	me->dim_type = cen_attr->dim_type;

	status =
	om$send(msg = message DMroot.DMplace(msg, count, list, attr, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dim_attr(char *attr)
{
	struct cenline_attr *cenline_attr;

	cenline_attr = (struct cenline_attr *)attr;

	cenline_attr->gap_r	= me->gap_r;
	cenline_attr->minor_len_r = me->minor_len_r;
	cenline_attr->major_len_r = me->major_len_r;
	cenline_attr->dim_type	= me->dim_type;
	cenline_attr->dim_state = me->dim_state;
	cenline_attr->posn	= me->posn;

	return(OM_S_SUCCESS);
}

method copy_dim_attr(
	IGRint *msg;
	IGRint control;
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status;
	struct cenline_attr attr;
	IGRint cn_type;
	struct GRid my_grid;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message DMroot.get_dim_attr((char *)&attr),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	me->posn = attr.posn;

        if ((!ASbroadcast_in_progress) && !(control & INST_NOT_IN_BATCH))
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

method DMcompute_node(
	IGRlong *msg;
	IGRint  cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	/******************* LOCAL PARAMETERS *************************/

	struct DMplan_info	plan_info;
	struct DMenv_param	par_env;
	struct DMdim_line	cenline_info[6];

	IGRlong status, rc;
	IGRdouble pri_radius, sec_radius;
	IGRpoint center;     /* curve center point on win_plan */

	/**************************************************************/


	*msg = MSSUCC;

	/*| - Gather Data - */

	status =
	om$send(msg = message DMcenline.gather_data(
					(IGRint *)&rc,
					count,
					list,
					md_env,
					center,
					&pri_radius,
					&sec_radius,
					cenline_info,
					&plan_info,
					&par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Line - */

	status =
	om$send(msg = message DMcenline.make_cen_line(
					(IGRint *)&rc,
					cenline_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/* - Set Symbology - */

	status =
	om$send(msg = message DMroot.chgdp((IGRint *)&rc, &par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->dim_state &= (~DIM_NEEDS_UPDATE);
 
	return(OM_S_SUCCESS);
}

method make_cen_line(
	IGRint *msg;
	struct DMdim_line cenline_info[6];
	struct GRmd_env *md_env)
{
	IGRint i, status, rc;

	*msg = MSSUCC;

	cenline_info[0].line_index = DIM_ORI_PROJ;
	cenline_info[1].line_index = DIM_MEA_PROJ;
	cenline_info[2].line_index = DIM_LINE1;
	cenline_info[3].line_index = DIM_LINE2;
	cenline_info[4].line_index = DIM_LINE3;
	cenline_info[5].line_index = DIM_LINE4;

	cenline_info[0].needed =
	cenline_info[1].needed = TRUE;

	if(me->posn)
	{
		/*| cursor outside the curve */

		cenline_info[2].needed =
		cenline_info[3].needed =
		cenline_info[4].needed =
		cenline_info[5].needed = TRUE;
	}
	else
	{
		/*| cursor inside the curve */

		cenline_info[2].needed =
		cenline_info[3].needed =
		cenline_info[4].needed =
		cenline_info[5].needed = FALSE;
	}
	
	for(i=0; i<6; i++)
	{
		if( cenline_info[i].needed)
		{
			/*^ print_line(" cenline", cenline_info[i].line); */
			status =
			om$send(msg = message DMroot.position_line(
						&rc,
						cenline_info[i].line_index,
						(struct GRid *)NULL,
						md_env,
						cenline_info[i].line),
			    targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*| center line NOT needed */
	
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							cenline_info[i].line_index,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	return(OM_S_SUCCESS);
}

method validate_roots(
	IGRint *msg;
	IGRint count;
	struct GRid list[])
{
	if( count == NO_CEN_DIM_ROOTS)
	{
		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}
	else
	{
		*msg = FALSE;
		return(FALSE);
	}
}

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
		DIM_CEN_CURVE,
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

method dynamics(
	IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	struct DMdyn_cenlin *place_attr;
	IGRshort	status;
	IGRint		rc;
	IGRdouble	pri_pt[3], sec_pt[3];
	IGRdouble	pri_radius, sec_radius, x, y;
	BSrc		bsrc;

	*msg = DIM_S_SUCCESS;

	place_attr = (struct DMdyn_cenlin *)info;

	if ((me->dim_state & DIM_NEEDS_UPDATE)
	||  (control & FILL_INFO))
	{
		/*|Initialise place_attr*/

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					place_attr->list,
					NO_CEN_DIM_ROOTS,
					NULL,
					0,
					NO_CEN_DIM_ROOTS - 1,
					&place_attr->count),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (me->dim_state & DIM_NEEDS_UPDATE)
		{
			/*| - Update Dimensions - */

			status =
			om$send(msg = message NDnode.NDcompute_node(
						(IGRlong *)&rc,
						NULL,
						place_attr->count,
						place_attr->list,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		/*|Gather Data for this dimension*/

		status =
		om$send(msg = message DMcenline.gather_data(
					&rc,
					place_attr->count,
					place_attr->list,
					md_env,
					place_attr->center,
					&pri_radius,
					&sec_radius,
 					place_attr->cenline_info,
					&place_attr->plan_info,
					&place_attr->par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->pri_radius = pri_radius * pri_radius;
		place_attr->sec_radius = sec_radius * sec_radius;
	}

	/*"control = %d\n", control*/

	if ((control & MOVE_TRAK_PT) || (control & MOVE_BREAK_PT))
	{
		BSproj0(&bsrc,
			cursor,
			place_attr->cenline_info[2].line,
			pri_pt);

		BSproj0(&bsrc,
			cursor,
			place_attr->cenline_info[4].line,
			sec_pt);

		x = BSdistptpt(&bsrc, place_attr->center, pri_pt);
		y = BSdistptpt(&bsrc, place_attr->center, sec_pt);

		/*^
			printf(" pri : %lf\n",place_attr->pri_radius);
			printf(" sec : %lf\n",place_attr->sec_radius);
			printf(" x : %lf\n",x);
			printf(" y : %lf\n",y);
		*/

		if((((x * x)/ place_attr->pri_radius) +
			((y * y)/place_attr->sec_radius)) > 1.0)
				me->posn = TRUE;
		else me->posn = FALSE;
		
		/*| - Center Line - */

		status =
		om$send(msg = message DMcenline.make_cen_line(
						&rc,
						place_attr->cenline_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRdouble center[3];
	IGRdouble *pri_radius;
	IGRdouble *sec_radius;
	struct DMdim_line  cenline_info[6];
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env)
{
	IGRshort	status, flag;
	IGRlong		long_rc, bsrc;
	IGRint		index, rc, type;
	IGRdouble	cross_length, cenline_offs, cenline_extn;
	IGRdouble	pt_on_plane[3], norm_to_plane[3];
	IGRpoint	f1, f2, v1, v2, v3, v4;
	IGRdouble	p1[3], p2[3], p3[3], w1, w2, w3;
	IGRvector	vec1, vec2;
	struct IGRbsp_curve *bsp_curve = NULL;
	struct IGRbsp_curve *proj_curve = NULL;
	struct dim_src_info src_info;
	struct GRmd_env env, mod_info;
	extern GRclassid OPP_GRconic_class_id;
	struct GRid go_grid;

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMcenline.get_dimension_plane(
						&rc,
						md_env,
						plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Get dimension parameters - */

	status =
	dm$get_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) par_env);
	dm$status(action = RET_STATUS);

	/*| - Compute radius and center of the curve */


	status =
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
		targetid = list[DIM_CEN_CURVE].objid,
		targetos = list[DIM_CEN_CURVE].osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsrc.DMgive_src_info(&rc, &mod_info, &src_info),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	if ((src_info.degraded == FALSE)
	&&  DMancestry_valid(src_info.parents[0], OPP_GRconic_class_id))
	{
		/*| GRconics */

		for(index=0; index<3; index++)
		{
			pt_on_plane[index] = plan_info->act_plan.matrix[4*index + 3];
			norm_to_plane[index] = plan_info->act_plan.matrix[index + 8];
		}

		if (src_info.context[0].objid != NULL_OBJID)
		{
			status =
			om$send(msg = message GRcontext.GRgetmodule_env(
								&long_rc,
								&env),
				targetid = src_info.context[0].objid,
				targetos = src_info.context[0].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			if (md_env->md_env.matrix_type != MAIDMX)
				env = *md_env;
			else	env = mod_info;
		}

		status =
		om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						&env.md_env.matrix_type,
						env.md_env.matrix,
						(char **)&bsp_curve),
			targetid = src_info.parents[0].objid,
			targetos = src_info.parents[0].osnum);
		dm$status(action = RET_STATUS);

		/*| allocate space for projected curve */

		BSalloccv(
			bsp_curve->order,
			bsp_curve->num_poles,
			bsp_curve->rational,
			bsp_curve->num_boundaries,
			&proj_curve,
			&bsrc);
		if (bsrc != BSSUCC)
		{
			printf("DMcenline - gather_data : BSalloccv Fail\n");
			return(FALSE);
		}

		/*| project curve */

		status =
    		BSprj_cv_pl(
			&bsrc,
			bsp_curve,
			pt_on_plane,
			norm_to_plane,
			norm_to_plane,
			proj_curve);
		if (!status || bsrc != BSSUCC)
		{
			printf("BSprj_cv_pl: Error status=%d, rc=%d\n",
							status, rc);
			if (proj_curve){
                           BSfreecv(&bsrc, proj_curve);
                           proj_curve = NULL;
                        }
			return(FALSE);
		}

		if (proj_curve->rational)
		{
			w1 = proj_curve->weights[0];
			w2 = proj_curve->weights[1];
			w3 = proj_curve->weights[2];
		}
		else
		{
			w1 = w2 = w3 = 1.0;
		}

		for(index=0; index<3; index++)
		{
			p1[index] = proj_curve->poles[index]/w1;
			p2[index] = proj_curve->poles[index + 3]/w2;
			p3[index] = proj_curve->poles[index + 6]/w3;
		}

	        if (proj_curve) {
                   BSfreecv(&rc, proj_curve);
                   proj_curve = NULL;
                }
	
		/*| Find conic properties */

		status =
		BScncprop(&bsrc,
			norm_to_plane,
			p1,
			p2,
			p3,
			&w1,
			&w2,
			&w3,
			&type,
			center,
			pri_radius,
			sec_radius,
			f1,
			f2,
			v1,
			v2,
			v3,
			v4);
		if (!status || bsrc != BSSUCC)
		{
			printf("BScncprop : Error status=%d, bsrc=%d\n",
							status, bsrc);
			return(FALSE);
		}

		/*^
			printf(" type = %d\n",type);
			printf(" pri_radius = %lf\n",*pri_radius);
			printf(" sec_radius = %lf\n",*sec_radius);
			print_point(" center = ",center);
		*/

		if(type == BSCELLIPSE)
		{
			/*| if ellipse construct center line with element axis*/

			/*^
				print_point(" v1 = ",v1);
				print_point(" v2 = ",v2);
			*/

			BSmkvec(&bsrc, vec1, center, v1);
			BSnorvec(&bsrc, vec1);

			BSmkvec(&bsrc, vec2, center, v3);
			BSnorvec(&bsrc, vec2);

			for (index=0; index<3; index++)
			{
				plan_info->act_plan.matrix[index] =
				plan_info->act_plan.vec_xpos[index] = vec1[index];

				plan_info->act_plan.vec_xneg[index] =
					-plan_info->act_plan.vec_xpos[index];

				plan_info->act_plan.matrix[index+4] =
				plan_info->act_plan.vec_ypos[index] = vec2[index];

				plan_info->act_plan.vec_yneg[index] =
					-plan_info->act_plan.vec_ypos[index];
			}
		}
		else *sec_radius = *pri_radius;

		/*^
			print_point("xpos", plan_info->act_plan.vec_xpos);
			print_point("ypos", plan_info->act_plan.vec_ypos);
		*/
	}
	else
	{
		flag = FALSE;
		math_v_equal(center, src_info.var.dm_radcen.center);
		*pri_radius = *sec_radius = src_info.var.dm_radcen.radius;
	}
	
	/*| - compute cross and center lines offset and extension */

	if (*pri_radius > (1.5 * par_env->txt_heig))
	{
		me->gap_r = 0.5;
		me->minor_len_r = 1.0;
		cross_length = par_env->txt_heig * me->minor_len_r * 0.5;
		cenline_offs = cross_length + me->gap_r * par_env->txt_heig;
	}
	else
	{
		me->gap_r = 1.0 / 3.0;
		me->minor_len_r = 2.0 / 3.0;
		cross_length = (*pri_radius) * me->minor_len_r * 0.5;
		cenline_offs = cross_length + me->gap_r * (*pri_radius);
	}

	if (*pri_radius > (4.0 * par_env->txt_heig))
	{
		me->major_len_r = 2.0;
		cenline_extn = *pri_radius + (me->major_len_r * par_env->txt_heig);
	}
	else
	{
		me->major_len_r = 1.5;
		cenline_extn = *pri_radius * me->major_len_r;
	}

	/*^
		printf("cross_length: %lf\n",cross_length);
		printf("cenline_offs : %lf\n",cenline_offs);
		printf("cenline_extn : %lf\n",cenline_extn);
	*/

	/*| - Compute end points of the cross */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xpos,
		cross_length,
		&cenline_info[0].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xneg,
		cross_length,
		&cenline_info[0].line[3]);

	/*^ print_line(" cross_line1 : ", cenline_info[0].line); */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_ypos,
		cross_length,
		&cenline_info[1].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_yneg,
		cross_length,
		&cenline_info[1].line[3]);

	/*^ print_line(" cross_line2 : ", cenline_info[1].line); */

	/*| - Compute the end points of the center lines */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xpos,
		cenline_offs,
		&cenline_info[2].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xpos,
		cenline_extn,
		&cenline_info[2].line[3]);

	/*^ print_line(" cenline1 : ", cenline_info[2].line); */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xneg,
		cenline_offs,
		&cenline_info[3].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_xneg,
		cenline_extn,
		&cenline_info[3].line[3]);

	/*^ print_line(" cenline2 : ", cenline_info[3].line); */

	/*| ellipse : change cenline_extn for minor axis */

	cenline_extn = cenline_extn * ( *sec_radius / *pri_radius);
		
	/*^ printf(" cenline_extn : %lf\n",cenline_extn); */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_ypos,
		cenline_offs,
		&cenline_info[4].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_ypos,
		cenline_extn,
		&cenline_info[4].line[3]);

	/*^ print_line(" cenline3 : ", cenline_info[4].line); */

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_yneg,
		cenline_offs,
		&cenline_info[5].line[0]);

	MATH_ptdelta(&rc,
		center,
		plan_info->act_plan.vec_yneg,
		cenline_extn,
		&cenline_info[5].line[3]);

	/*^ print_line(" cenline4 : ", cenline_info[5].line); */

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char *param)
{
	IGRint status;
	struct DMsenv_param par_senv;

	status =
	om$send(msg = message dim_param.give_internal(
			DM_SENV_PARAM,
			sizeof(par_senv),
			(char *)&par_senv),
		p_chanselect = &ND_father,
		from = DIM_ROOT_SENV,
		to = DIM_ROOT_SENV);
	dm$status(action = RET_STATUS);

	switch (type)
	{
		case DM_ENV_PARAM:

		DMsplit_senv(&par_senv, param, NULL, NULL);
		break;

		case DM_LOC_PARAM:

		DMsplit_senv(&par_senv, NULL, param, NULL);
		break;

		case DM_MISC_PARAM:

		DMsplit_senv(&par_senv, NULL, NULL, param);
		break;

		case DM_SENV_PARAM:

		*(struct DMsenv_param *)param = par_senv;
		break;
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method set_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	struct GRmd_env *md_env;
	char *param)
{
	IGRint status;
	struct DMsenv_param par_senv;
	struct GRid grid;

	status =
	om$send(msg = message dim_param.give_internal(
					DM_SENV_PARAM,
					sizeof(par_senv),
					(char *)&par_senv),
		p_chanselect = &ND_father,
		from = DIM_ROOT_SENV,
		to = DIM_ROOT_SENV);
	dm$status(action = RET_STATUS);

	switch (type)
	{
		case DM_ENV_PARAM:
		DMmerge_senv(&par_senv, param, NULL, NULL);
		break;

		case DM_LOC_PARAM:
		DMmerge_senv(&par_senv, NULL, param, NULL);
		break;

		case DM_MISC_PARAM:
		DMmerge_senv(&par_senv, NULL, NULL, param);
		break;

		case DM_SENV_PARAM:
		par_senv = *(struct DMsenv_param *)param;
		break;
	}

	status =
	om$send(msg = message dim_param.edit(
					DM_SENV_PARAM,
					sizeof(par_senv),
					(char *)&par_senv,
					md_env,
					&grid),
		p_chanselect = &ND_father,
		from = DIM_ROOT_SENV,
		to = DIM_ROOT_SENV);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method update_parents()
{
	IGRint status;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRid senv_grid;
	struct GRid my_grid, null_grid;
	IGRint count;

	if (!(me->dim_state & DIM_IN_PLACEMENT))
		return(OM_S_SUCCESS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	null_grid.objid = NULL_OBJID;

	status =
	DMget_parents(my_grid, MAX_DIM_ROOTS, list, &count);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(type = DM_SENV_PARAM, p_grid = &senv_grid);
	dm$status(action = RET_STATUS);

	if (list[DIM_ROOT_SENV].objid != senv_grid.objid)
	{
		list[DIM_ROOT_SENV] = senv_grid;

		status =
		om$send(msg = message NDnode.NDconnect(
					count,
					list,
					null_grid,
					ND_FULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->dim_state |= DIM_NEEDS_UPDATE;
	}

	return(OM_S_SUCCESS);
}

end implementation DMcenline;
