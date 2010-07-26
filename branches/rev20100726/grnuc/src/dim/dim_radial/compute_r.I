class implementation DMradjog;

#define AS_DEBUG 1
#include "diminst.h"
#include "dimdyn.h"
#include "bsvalues.h"
#include "mascalvc.h"
#include "bsxlnpl.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdistptpt.h"

extern IGRdouble fabs();
extern ASsuper_construct();

from IGEgragad import DPinrot;
from dim_param import give_internal;

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint 		status, rc;
	struct dim_attr	*dim_attr;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRid	roots[2], context[2];

	dim_attr = (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	roots[0]	= assoc_lis->parents[DIM_RAD_CURVE];
	roots[1]	= assoc_lis->parents[DIM_ROOT_PLAN];
	context[0]	= assoc_lis->context[DIM_RAD_CURVE];
	context[1]	= assoc_lis->context[DIM_ROOT_PLAN];

	status =
	dm$create_root(
		type = DMradcen,
		count = 2,
		list = roots,
		context = context,
		attr = dim_attr->orig,
		md_env = md_env,
		p_root = &list[DIM_RAD_CURVE]);
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

	me->jogged = FALSE;

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

	IGRint index, i, rc;
	IGRint num_jog_pts;
	IGRshort projection_required, const_radius;

	struct DMplan_info	plan_info;
	struct DMenv_param	par_env;
	struct DMloc_param	par_loc;
	struct DMdim_arc	arc_info;

	IGRlong status;
	IGRpoint center;     /* curve center point on win_plan */
	IGRpoint term_pt;     /* curve terminator point on win_plan */

	IGRdouble dimn_value, sca_value;
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	IGRdouble cent_term[3], dia_line[3]; /* radial line */
	IGRdouble jog_line[9];
	BSrc		bsrc;

	struct GRid parents[MAX_DIM_ROOTS];

	/**************************************************************/


	*msg = MSSUCC;

	/*| Fill the duplicate parents if necessary */

	for(i=0; i<count; i++)
	{
		parents[i].objid = list[i].objid;
		parents[i].osnum = list[i].osnum;
	}

	for(i=count; i < NO_RAD_DIM_ROOTS; i++)
	{
		parents[i].objid = list[0].objid;
		parents[i].osnum = list[0].osnum;
	}

	/*| - Gather Data - */

	status =
	om$send(msg = message DMradjog.gather_data(
					&rc,
					count,
					parents,
					md_env,
					&projection_required,
					&const_radius,
					center,
					term_pt,
					&dimn_value,
					&arc_info,
					&plan_info,
					&par_env,
					&par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| if dimension is radial diameter */

	if( me->dim_type == RADIAL_DIAMETER)
	{
		BSmkvec(&bsrc, dia_line, term_pt, center);
		BSnorvec(&bsrc, dia_line);

		sca_value = dimn_value * BSlenvec(&bsrc, plan_info.win_plan.vec_xpos);

		/*^ print_point(" dia_line : ", dia_line); */

		for(index=0; index<3; index++)
			center[index] = center[index] +
					dia_line[index] * sca_value;
		dimn_value = dimn_value * 2;
	}

	/*| - Compute Jog line - */

	status =
	om$send(msg = message DMradjog.compute_jog_line(
						&rc,
						&num_jog_pts,
						center,
						term_pt,
						cent_term,
						jog_line,
						&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);					
	
	/*| - Compute break point position - */

	status =
	om$send(msg = message DMradjog.compute_break_pt(
					&rc,
					center,
					term_pt,
					cent_term,
					dimn_value,
					jog_line,
					break_pt,
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_point("break_pt", break_pt); */

	/*| - Compute Leader Point Position - */

	status =
	om$send(msg = message DMradjog.compute_lead_pt(
					&rc,
					center,
					term_pt,
					break_pt,
					&par_loc,
					&plan_info,
					leader_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_point("leader_pt", leader_pt); */

	/*| - Projection arc - */

	status =
	om$send(msg = message DMradjog.make_proj_arc(
					&rc,
					&par_env,
					&par_loc,
					&plan_info,
					&arc_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Text - */

	status =
	om$send(msg = message DMdim.make_text_string(
						&rc,
						dimn_value,
						md_env,
						&par_env,
						&par_loc,
						NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMradjog.make_dim_text(
					&rc,
					num_jog_pts,
					center,
					term_pt,
					dimn_value,
					break_pt,
					leader_pt,
					jog_line,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Terminators - */

	status =
	om$send(msg = message DMradjog.make_dim_term(
					&rc,
					center,
					term_pt,
					cent_term,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Line - */

	status =
	om$send(msg = message DMradjog.make_dim_line(
					&rc,
					num_jog_pts,
					center,
					term_pt,
					cent_term,
					break_pt,
					leader_pt,
					jog_line,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/* - Set Symbology - */

	status =
	om$send(msg = message DMroot.chgdp(&rc, &par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->dim_state &= (~DIM_NEEDS_UPDATE);
 
	return(OM_S_SUCCESS);
}

method compute_break_pt(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble radline_vec[3];
	IGRdouble dimn_value;
	IGRdouble *jog_line;
	IGRdouble break_pt[3];
	struct DMplan_info *plan_info)
{
	IGRint rc;
	IGRdouble *from_pt, *cen_pt, *ter_pt;
	IGRdouble radius, displacement, cent_term[3];
	BSrc	bsrc;

	if (me->jogged)
	{
		if (me->brk_pos == BRK_ALT_CENTER)
		{
		   cen_pt = &jog_line[6];
		   ter_pt = &jog_line[3];
		}
		else
		{
		   cen_pt = jog_line;
		   ter_pt = term_pt;
		}
	}
	else
	{
		cen_pt = center;
		ter_pt = term_pt;
	}

	BSmkvec(&bsrc, cent_term, cen_pt, ter_pt);
	radius = BSlenvec(&bsrc, cent_term);
	BSnorvec(&bsrc, cent_term);

	switch (me->brk_pos)
	{
		case BRK_LEFT:

			/*| - Break Left */

			from_pt = cen_pt;
			displacement = - me->brk_dist;
			break;

		case BRK_CENTER:
		case BRK_ALT_CENTER:

			/*| - Break Center */

			from_pt = cen_pt;
			displacement = me->brk_dist * radius;
			break;

		case BRK_RIGHT:

			/*| - Break Right */

			from_pt = term_pt;
			displacement = me->brk_dist;
			break;

		default:
		printf("Invalid Break position = %d\n",me->brk_pos);
		return(OM_E_ABORT);
	};

	MATH_ptdelta(&rc, from_pt, cent_term, displacement, break_pt);

	/*^
		print_point("from_pt",from_pt);
		print_point("break_pt",break_pt);
		printf("brk_dist = %f\n",me->brk_dist);
	*/

	return(OM_S_SUCCESS);
}

method compute_lead_pt(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble break_pt[3];
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble leader_pt[3])
{
	int i, rc;
	IGRdouble *axis_for_text, angle, scale;
	IGRdouble mea_axis[3], perp_axis[3];
	BSrc	bsrc;

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

		BSmkvec(&bsrc, mea_axis, center, term_pt);
		BSnorvec(&bsrc, mea_axis);

		angle = M_PI/2;
		MATH_rotate_vector(
			&rc,
			mea_axis,
			angle,
			plan_info->act_plan.matrix,
			perp_axis);

		BSnorvec(&bsrc, perp_axis);
		scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
		MAscalvc(&bsrc, &scale, perp_axis, perp_axis);
		axis_for_text = perp_axis;
		break;

		default:
		printf("Invalid text Orientation = %d\n",par_loc->txt_orie);
		return(OM_E_ABORT);
	}

	for (i=0; i<3; i++)
		leader_pt[i] = break_pt[i] + me->lead_dist * axis_for_text[i];

	/*^
		print_point(" break_pt : ", break_pt);
		print_point(" leader_pt : ", leader_pt);
		printf(" lead_dist : %lf\n",me->lead_dist);
	*/
	return(OM_S_SUCCESS);
}

method leader_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *leader)
{
	IGRint status;
	struct DMloc_param p_loc;

	*msg = DIM_S_SUCCESS;

	status =
	dm$get_dim_param(
		type = DM_LOC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *)&p_loc);
	dm$status(action = RET_STATUS);

	if (p_loc.txt_orie == TXT_ORIE_PARALLEL
	||  me->brk_pos == BRK_ALT_CENTER
	||  me->brk_pos == BRK_CENTER)
		me->leader = *leader = FALSE;
	else	me->leader = *leader = TRUE;

	return(OM_S_SUCCESS);
}

method validate_roots(
	IGRint *msg;
	IGRint count;
	struct GRid list[])
{
	/*^
		printf(" num_parents : %d\n",count);
		printf(" parents[0] : %d, %d\n",list[0].objid, list[0].osnum);
		printf(" parents[1] : %d, %d\n",list[1].objid, list[1].osnum);
		printf(" parents[2] : %d, %d\n",list[2].objid, list[2].osnum);
		printf(" parents[3] : %d, %d\n",list[3].objid, list[3].osnum);
	*/

	if( count == NO_RAD_DIM_ROOTS)
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
	IGRint status;
	struct dim_ret_struct dmstr;
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
	DMsrc_give_structure(
		msg,
		DIM_RAD_CURVE,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		FALSE,
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&dmstr);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] =
			dmstr.var.dm_radcen.point[index];
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method jog_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *jogged)
{
	*msg = DIM_S_SUCCESS;

	if ((me->brk_pos == BRK_CENTER)
	||  (me->brk_pos == BRK_ALT_CENTER))
		me->jogged = *jogged;

	return(OM_S_SUCCESS);
}

method jogged_off()
{
	me->jogged = FALSE;
	me->jog_pt1[0] = me->jog_pt1[1] = 0.0;
	me->jog_pt2[0] = me->jog_pt2[1] = 0.0;

	return(OM_S_SUCCESS);
}

method clear_jog_pts(IGRint flag)
{
	if (flag & CLEAR_JOG_PT1)
	{
		/*|- clearing jog_pt1 */
		me->jog_pt1[0] = me->jog_pt1[1] = 0.0;
	}

	if (flag & CLEAR_JOG_PT2)
	{
		/*|- clearing jog_pt2 */
		me->jog_pt2[0] = me->jog_pt2[1] = 0.0;
	}

	return(OM_S_SUCCESS);
}

method compute_jog_line(
	IGRint *msg;
	IGRint *num_jog_pts;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble radline_vec[3];
	IGRdouble *jog_line;
	struct DMplan_info *plan_info)
{
	IGRint i, rc;
	IGRdouble displacement;
	IGRdouble radius, sca_fact;
	BSrc	bsrc;

	*msg = DIM_S_SUCCESS;

	BSmkvec(&bsrc, radline_vec, center, term_pt);
	radius = BSlenvec(&bsrc, radline_vec);
	sca_fact = 1/radius;
	MAscalvc(&bsrc, &sca_fact, radline_vec, radline_vec);

	if (!me->jogged)
	{
		*num_jog_pts = 0;
		return(OM_S_SUCCESS);
	}

	sca_fact = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
	displacement = me->lead_dist * radius * sca_fact;
	MATH_ptdelta(&rc, center, radline_vec, displacement, jog_line);

	/*"jog_pt2 = (%f, %f)\n",me->jog_pt1[0],me->jog_pt1[1]*/

	if ((fabs(me->jog_pt1[0]) > 0.0) || (fabs(me->jog_pt1[1]) > 0.0))
	{
		for (i=0; i<3; i++)
		{
			jog_line[i+3] = jog_line[i] + (me->jog_pt1[0] * plan_info->act_plan.matrix[i] +
			me->jog_pt1[1] * plan_info->act_plan.matrix[i+4]);
		}

		/*"me->jog_pt3 = (%f, %f)\n",me->jog_pt2[0],me->jog_pt2[1]*/
		if ((fabs(me->jog_pt2[0]) > 0.0) || (fabs(me->jog_pt2[1]) > 0.0))
		{
			for (i=0; i<3; i++)		
			{
				jog_line[i+6] = jog_line[i+3] + (me->jog_pt2[0] * plan_info->act_plan.matrix[i] +
				me->jog_pt2[1] * plan_info->act_plan.matrix[i+4]);
			}
			*num_jog_pts = 3;
		}
		else *num_jog_pts = 2;
	}
	else *num_jog_pts = 1;

	/*^
		printf(" num_jog_pts : %d\n", *num_jog_pts);
		for(i=0; i<*num_jog_pts; i++)
		printf("jog_pts[%d] = %f, %f, %f\n", i, jog_line[i*3],
			jog_line[i*3+1], jog_line[i*3+2]);
	*/

	return(OM_S_SUCCESS);
}

method return_vertex(
IGRint *msg;
IGRint *dim_type;
IGRboolean *first_in_cpx, *jogged;
IGRpoint point;
IGRint *vertex_no;
struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRint num_jog_pts, count;
	IGRboolean projection_required, const_radius;
	IGRpoint keypt, point2;
	IGRdouble *poles;
	struct DMplan_info plan_info;
	struct GRid parents[MAX_DIM_ROOTS];
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMdim_arc arc_info;
	IGRdouble center[3], term_pt[3];
	IGRdouble cent_term[3];
	IGRdouble dimn_value;
	IGRdouble jog_line[12];
	IGRdouble pt_on_plane[3], norm_on_plane[3];
	IGRdouble dist, dist1;
	BSrc	bsrc;

	*vertex_no = -1;
	*dim_type = me->dim_type;
	*first_in_cpx = FALSE;
	*jogged = me->jogged;

	if (!me->jogged)
	{
		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					parents),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Gather Data - */

	status =
	om$send(msg = message DMradjog.gather_data(
					&rc,
					count,
					parents,
					md_env,
					&projection_required,
					&const_radius,
					center,
					term_pt,
					&dimn_value,
					&arc_info,
					&plan_info,
					&par_env,
					&par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (i=0; i<3; i++)
	{
	    pt_on_plane[i] = plan_info.win_plan.matrix[(4*i)+3];
	    norm_on_plane[i] = plan_info.win_plan.matrix[i+8];
	    point2[i] = point[i] + plan_info.win_plan.matrix[i+8];
	}

	BSxlnpl(&bsrc,
		&plan_info.win_plan.matrix[8],
		pt_on_plane,
		point,
		point2,
		keypt);

	status =
	om$send(msg = message DMradjog.compute_jog_line(
						&rc,
						&num_jog_pts,
						center,
						term_pt,
						cent_term,
						&jog_line[3],
						&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);					

	math_v_equal(jog_line, term_pt);

	dist = dist1 = 0.0;
	dist = BSdistptpt(&bsrc, jog_line, keypt);
	*vertex_no = 0;
	/*^ print_point("term_pt", term_pt); */

	for (i=1; i<num_jog_pts+1; i++)
	{
		poles = &jog_line[3*i];

		/*^ print_point("poles", poles); */

		dist1 = BSdistptpt(&bsrc, poles, keypt);

		if (dist1 < dist)
		{
			*vertex_no = i;
			dist = dist1;
		}
	}

	/*^ printf("vertex=%d\n", *vertex_no); */

	if (*vertex_no < 0)
	{
		/*|Key point is not one of the poles*/
		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_dim_attr(char *attr)
{
	struct dim_attr *dim_attr;

	dim_attr = (struct dim_attr *)attr;

	dim_attr->dim_type	= me->dim_type;
	dim_attr->dim_state	= me->dim_state;
	dim_attr->brk_dist	= me->brk_dist;
	dim_attr->lead_dist	= me->lead_dist;
	dim_attr->trak_dist	= me->trak_dist;
	dim_attr->offs_pt[0]	= me->offs_pt[0];
	dim_attr->offs_pt[1]	= me->offs_pt[1];
	dim_attr->prj_offs[0]	= me->prj_offs[0];
	dim_attr->prj_offs[1]	= me->prj_offs[1];
	dim_attr->mea_trak	= me->mea_trak;
	dim_attr->brk_pos	= me->brk_pos;
	dim_attr->leader	= me->leader;
	dim_attr->ter_loca	= me->ter_loca;
	dim_attr->geom_type	= me->geom_type;
	dim_attr->display	= me->display;
	dim_attr->jogged 	= me->jogged;
	dim_attr->jog_offs[0]	= me->jog_pt1[0];
	dim_attr->jog_offs[1]	= me->jog_pt1[1];
	dim_attr->jog_offs[2]	= me->jog_pt2[0];
	dim_attr->jog_offs[3]	= me->jog_pt2[1];

	return(OM_S_SUCCESS);
}

method copy_dim_attr(
	IGRint *msg;
	IGRint control;
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status;
	struct dim_attr dim_attr;
	struct GRid grid;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message DMroot.get_dim_attr((char *)&dim_attr),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	/*" trak dist:%f\n",dim_attr.trak_dist*/

	if (control & INST_JOG_PTS)
	{
		/*|- Copy Jog Instance */

		me->jogged = dim_attr.jogged;
		me->jog_pt1[0] = dim_attr.jog_offs[0];
		me->jog_pt1[1] = dim_attr.jog_offs[1];
		me->jog_pt2[0] = dim_attr.jog_offs[2];
		me->jog_pt2[1] = dim_attr.jog_offs[3];
		me->lead_dist = dim_attr.lead_dist;
		me->brk_pos = dim_attr.brk_pos;
		me->brk_dist = dim_attr.brk_dist;
		me->trak_dist = dim_attr.trak_dist;
		me->mea_trak = dim_attr.mea_trak;
	}
	
	if (control & INST_BREAK_PT
	||  control & INST_TRAK_PT)
	{
		/*|- Copy Break & Trak Instance */

		me->brk_pos = dim_attr.brk_pos;
		me->brk_dist = dim_attr.brk_dist;
		me->trak_dist = dim_attr.trak_dist;
		me->mea_trak = dim_attr.mea_trak;
	}

	if (control & INST_PROJ_OFFS_PT)
	{
		/*|- Copy Projection Instance */

		me->prj_offs[0] = dim_attr.prj_offs[0];
		me->prj_offs[1] = dim_attr.prj_offs[1];
	}

	if (control & INST_LEADER_PT)
	{
		/*|- Copy Leader Instance */

		me->leader = dim_attr.leader;
		me->lead_dist = dim_attr.lead_dist;
	}

	if (control & INST_OFFS_PT)
	{
		/*|- Copy text offset Instance */

		me->offs_pt[0] = dim_attr.offs_pt[0];
		me->offs_pt[1] = dim_attr.offs_pt[1];
	}

	if (control & INST_TER_LOCA)
		me->ter_loca = dim_attr.ter_loca;

	grid.objid = my_id;
	grid.osnum = OM_Gw_current_OS;

        if ((!ASbroadcast_in_progress) && !(control & INST_NOT_IN_BATCH))
	{
		IGRint cn_type;

		cn_type = ND_COMP;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_jog_info(
	IGRint *msg;
	IGRboolean *jogged;
	IGRint *num_jog_pts;
	IGRdouble jog_line[12];
	struct GRmd_env *md_env)
{
	if (jogged)
	   *jogged = me->jogged;

	if (me->jogged)
	{
		if (jog_line)
		{
			IGRint status, rc, count;
			IGRboolean projection_required, const_radius;
			IGRdouble center[3], term_pt[3];
			IGRdouble cent_term[3], dimn_value;
			struct DMplan_info plan_info;
			struct GRid parents[MAX_DIM_ROOTS];
			struct DMenv_param par_env;
			struct DMloc_param par_loc;
			struct DMdim_arc arc_info;

			status =
			om$send(msg = message DMroot.DMreturn_roots(
						&count,
						parents),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*| - Gather Data - */

			status =
			om$send(msg = message DMradjog.gather_data(
						&rc,
						count,
						parents,
						md_env,
						&projection_required,
						&const_radius,
						center,
						term_pt,
						&dimn_value,
						&arc_info,
						&plan_info,
						&par_env,
						&par_loc),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMradjog.compute_jog_line(
						&rc,
						num_jog_pts,
						center,
						term_pt,
						cent_term,
						jog_line,
						&plan_info),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	*msg = DIM_S_SUCCESS;	
	return(OM_S_SUCCESS);
}

end implementation DMradjog;
