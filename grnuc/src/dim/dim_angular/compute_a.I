/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:29 $
$Locker:  $
$Log: compute_a.I,v $
Revision 1.1.1.1  2001/12/17 22:39:29  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:06:50  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:20:46  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:19  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/07/15  15:02:45  gvk
# COMMENT : Changes for feature patterning.
#
# Revision 220.0  1992/08/29  06:20:39  root
# COMMENT : Corresponds to Rel201.16 in 2.0.1 RCS
#
Revision 201.16  1992/07/20  07:44:12  poo
COMMENT : ANSI compilance, TR 92N1519, TR92N1741, and updating modified fucnction calls.

*/

class implementation DMangular;

#define AS_DEBUG 1

#include "diminst.h"

extern GRclassid OPP_dim_src_class_id;

from dim_param import give_internal;

method NDplace( struct GRas *assoc_lis;
		struct GRmd_env *md_env;
		char *go_cnst_lis)
{
	IGRint status, rc;
	struct dim_attr *dim_attr;
	struct GRid list[MAX_DIM_ROOTS];
	extern GRclassid OPP_DMsrc_class_id;

	dim_attr	= (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	if (!DMancestry_valid(assoc_lis->parents[DIM_CPX_ORIG],
					OPP_DMangular_class_id)
	&&  !DMancestry_valid(assoc_lis->parents[DIM_CPX_ORIG],
					OPP_DMsrc_class_id))
	{
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
	}

	if (!DMancestry_valid(assoc_lis->parents[DIM_CPX_MEAS],
					OPP_DMsrc_class_id))
	{
		status =
		dm$create_root(
			type = DMkeyseg,
			count = 1,
			list = &assoc_lis->parents[DIM_CPX_MEAS],
			context = &assoc_lis->context[DIM_CPX_MEAS],
			attr = dim_attr->meas,
			md_env = md_env,
			p_root = &list[DIM_CPX_MEAS]);
		dm$status(action = RET_STATUS);
	}

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

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char   *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint cpx_type, rel_pos;
	IGRboolean first_in_cpx;
	struct GRid first, null_grid;
	struct dim_attr *dim_attr;
	struct GRid dim_before, dim_after;
	struct GRid list_c[MAX_DIM_ROOTS];

	null_grid.objid = NULL_OBJID;

	DMcopy_roots(list_c, list, count);

	dim_attr = (struct dim_attr *)attr;

	first_in_cpx =
	!DMancestry_valid(list_c[DIM_CPX_ORIG],OPP_DMroot_class_id);

	if (!first_in_cpx)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
			targetid = list_c[DIM_CPX_ORIG].objid,
			targetos = list_c[DIM_CPX_ORIG].osnum);
		dm$status(action = RET_STATUS);

		dim_before.objid = NULL_OBJID;
		dim_after.objid  = NULL_OBJID;
		cpx_type = (dim_attr->dim_type == STRINGED_ANGULAR)?
					STRINGED_CPX:STACKED_CPX;

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
	}

	status =
	om$send(msg = message DMdim.DMplace(msg, count, list_c, attr, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx)
	{
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

method DMcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRlong rc;
	IGRint status, i;

	struct DMplan_info	plan_info;
	struct DMenv_param	p_env;
	struct DMloc_param	p_loc;

	IGRdouble trak_rad_prev;
	struct  dm_ang_src_st ang_parent_st;
	struct  angular_data_st ang_dim_info;
	struct GRid parents[MAX_DIM_ROOTS];

	*msg = OM_S_SUCCESS;

	/*| Fill the duplicate parents if necessary */

	for (i=0; i<count; i++)
	{
		parents[i].objid = list[i].objid;
		parents[i].osnum = list[i].osnum;
	}

	if (DMancestry_valid(list[0], OPP_dim_src_class_id))
	{
		for(i=count; i<5; i++)
		{
			parents[i].objid = list[0].objid;
			parents[i].osnum = list[0].osnum;
			(count)++;
		}
	}
	if( count < 5 )
	{
		for(i=count; i<5; i++)
		{
			parents[i].objid = list[3].objid;
			parents[i].osnum = list[3].osnum;
			(count)++;
		}
	}

	/*| Get dim parameters (plane , loc_param, env_param ,etc)  */

	status = om$send( msg = message DMangular.get_dim_info( &rc,
						count,
						parents,
						md_env,
						&ang_parent_st,
						&trak_rad_prev,
						&plan_info,
						&p_env,
						&p_loc),
			targetid = my_id);
	dm$status(action = RET_STATUS);


        ang_dim_info.norm_pl[0] = plan_info.win_plan.matrix[8];
        ang_dim_info.norm_pl[1] = plan_info.win_plan.matrix[9];
        ang_dim_info.norm_pl[2] = plan_info.win_plan.matrix[10];

	/*"trak rad prev:%lf\n",trak_rad_prev*/
	trak_rad_prev *= BSlenvec(&rc, plan_info.win_plan.vec_xpos);

	ang_dim_info.arc_rad = trak_rad_prev;

	/*| get the dim sect parameters    */
	status = om$send ( msg =  message DMangular.get_dim_sect( &rc,
						 &ang_parent_st,
						 &ang_dim_info,
						 &plan_info,
						 &p_env),
			targetid = my_id);
	dm$status( action = RET_STATUS);


	/*| compute the break point  */
	status = om$send( msg= message DMangular.compute_breakpt(&rc,
						   &ang_dim_info,
						   &ang_parent_st,
						   &plan_info),
			targetid = my_id);
	dm$status(action= RET_STATUS);

	/*^ print_point("breakpt",ang_dim_info.breakpt); */

	/*| compute the leader points   */
	status = om$send( msg = message DMangular.compute_leader_pt(&rc,
							&ang_dim_info,
							&p_loc,
							&p_env,
							&plan_info),
			targetid = my_id);
	dm$status( action = RET_STATUS);

	/*^print_point("leaderpt:",ang_dim_info.leaderpt);*/
	
	/*|- make projection lines  */
	status = 
	om$send( msg = message DMangular. make_proj_lines(&rc,
					  	 &p_env,
						 &p_loc,
						 &plan_info,
						 &ang_parent_st,
						 &ang_dim_info,
						 md_env),
			targetid = my_id);
	dm$status( action = RET_STATUS);

	/*| - make dimension text    */

	status=
	om$send(msg = message DMdim.make_text_string(
					(IGRint *) &rc,
					ang_dim_info.dimn_val * ang_parent_st.arc_radius,
					md_env,
					&p_env,
					&p_loc,
					NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMangular.make_dim_text(
						&rc,
						&ang_dim_info,
						&p_env,
						&p_loc,
						&plan_info,
						md_env),
		targetid = my_id);
	dm$status( action = RET_STATUS);

	/*| making of the dim line*/
	status = 
	om$send( msg = message DMangular.make_dim_line( &rc,
						&p_env,
						&p_loc,
						&ang_dim_info,
						&plan_info,
						md_env),
			targetid = my_id);
	dm$status( action = RET_STATUS);

	/*|making of the terminators */
	status = 
	om$send( msg = message DMangular.make_dim_term(&rc,
					   &ang_dim_info,
					   &p_env,
					   &p_loc,
					   &plan_info,
					   md_env),
			targetid= my_id);
	dm$status( action = RET_STATUS);

	/*|set symbology   */

	status = 
	om$send( msg = message DMroot.chgdp(( IGRint *)&rc, &p_env),
			  targetid = my_id);
	dm$status( action = RET_STATUS);

        me->dim_state &= (~DIM_NEEDS_UPDATE);
	return(OM_S_SUCCESS);					   	
}

method get_dim_info(
	IGRlong *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct dm_ang_src_st *angle_st;
	IGRdouble *trak_dist_prev;
	struct DMplan_info *plan_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc)
{
	IGRint status;
	IGRint rc;

	status =
	om$send( msg= message DMangular.give_orig_meas(
						msg,
						count,
						list,
						angle_st,
						plan_info,
						(IGRchar *)&me->mea_trak,
						trak_dist_prev,
						md_env),
		targetid = my_id);
	dm$status( action = RET_STATUS);
	
	/*^
		print_point("orig pt1:",angle_st->orig_line.point1);
		print_point("orig pt2:",angle_st->orig_line.point2);
		print_point("meas pt1:",angle_st->meas_line.point1);
		print_point("meas pt2:",angle_st->meas_line.point2);

	*/

	/*| - Get dimension parameters - */

	status =
	om$send(msg = message DMdim.get_active_params(&rc, p_env, p_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method compute_breakpt(
	IGRlong *msg;
	struct angular_data_st *a_info;
	struct dm_ang_src_st *angle_st;
	struct DMplan_info *plan_info)
{
	IGRint rc, flag;
	double rot_vec[3], *orie, off_angle;

	MATH_get_dir_vec(
		&rc,
		a_info->centerpt,
		a_info->orig_term_pt,
		a_info->meas_term_pt,
		a_info->norm_pl, &flag);

	/*"flag(2=anti,1=clock):%d\n",flag*/

	if (me->mea_trak & CLOCK_WISE)
	{
		a_info->left = 1;
		a_info->right =0;
	}
	else 
	{
		a_info->left  = 0;
		a_info->right = 1;
	}
		
	/*|computing the breakpoint */

	if (a_info->left)
	{
		a_info->left_ptr = a_info->orig_ln_orie;
		a_info->right_ptr= a_info->meas_ln_orie;
	}
	else
	{
		a_info->left_ptr = a_info->meas_ln_orie;
		a_info->right_ptr= a_info->orig_ln_orie;
	}
	
	/*^
		print_point("origpt",a_info->orig_ln_orie);
		print_point("measpt",a_info->meas_ln_orie);
		print_point("left_ptr",a_info->left_ptr);
		print_point("right_ptr",a_info->right_ptr);
	*/

	MATH_ang_bet_lines(
		a_info->right_ptr,
		a_info->left_ptr,
		&a_info->dimn_val,
		a_info->norm_pl);

	/*"dimension angle:%lf\n", a_info->dimn_val*/

	switch( me->brk_pos)
	{
		case BRK_LEFT:

		orie = a_info->left_ptr;
		off_angle = me->brk_dist;
		break;

		case BRK_RIGHT:

		orie = a_info->right_ptr;
		off_angle =  -me->brk_dist;
		break;

		case BRK_CENTER:

		orie = a_info->right_ptr;
		off_angle = me->brk_dist * a_info->dimn_val;
		break;
	}

	MATH_rotate_vector(
		&rc,
		orie,
		off_angle,
		plan_info->win_plan.matrix,
		rot_vec);

	v_projpt(a_info->centerpt, a_info->arc_rad, rot_vec, a_info->breakpt);

	/*^ print_point("breakpt",a_info->breakpt); */

	return(OM_S_SUCCESS);
}

method compute_leader_pt(
	IGRlong *msg;
	struct angular_data_st *a_info;
	struct DMloc_param  *p_loc;
	struct DMenv_param  *p_env;
	struct DMplan_info *plan_info)
{
	IGRdouble *leader_orie,leader_vec[3], sca_fact;
	IGRint i, rc;

	*msg = OM_S_SUCCESS;

	if(!me->leader)
	{
		vec_equal(a_info->breakpt, a_info->leaderpt);
		return(OM_S_SUCCESS);
	}

	switch( p_loc->txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:
			leader_orie = plan_info->win_plan.vec_xpos;
			break;
		case TXT_ORIE_VERTICAL:
			leader_orie = plan_info->win_plan.vec_ypos;
			break;
		case TXT_ORIE_PERPENDICULAR:
			for (i=0; i< 3; i++)
			   leader_vec[i] = a_info->breakpt[i] - a_info->centerpt[i];
			BSnorvec(&rc, leader_vec);
			sca_fact = BSlenvec(&rc, plan_info->win_plan.vec_xpos);
			MAscalvc(&rc, &sca_fact, leader_vec, leader_vec);
			leader_orie = leader_vec;
			break;
		default:
			leader_orie = NULL;
			printf("DMangular: Invalid txt orie = %d\n", p_loc->txt_orie);
			return(OM_E_ABORT);
	}

	for (i=0; i< 3; i++)
	    a_info->leaderpt[i] = a_info->breakpt[i] +
			      me->lead_dist * leader_orie[i];

	return(OM_S_SUCCESS);
}

method get_dim_sect(
	IGRlong *msg;
	struct dm_ang_src_st *angle_st;
	struct angular_data_st *a_info;
	struct DMplan_info *plan_info;
	struct DMenv_param *p_env)
{
	IGRint status,rc;
	IGRint i;
	IGRdouble pt_on_plane[3];
	struct ret_struct retst;

 	/* project all points to the dimension plane */

	for( i = 0; i< 3; i++)
	pt_on_plane[i] = plan_info->win_plan.matrix[4*i +3];

	if(me->dim_type == SINGLE_ARC_LENGTH ||
	   me->dim_type == SINGLE_ARC_ANGLE)
	{
		struct GRmd_env md_env;

		DMget_module_info(&md_env);

		status =
		DMnode_give_structure(
			&rc,
			DIM_CPX_ORIG,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			&md_env,
			&retst);
		dm$status(action = RET_STATUS);
	
		vec_equal(retst.var.circle_st.cent_p, a_info->centerpt);
	}
	else
	{
		DMproject_points(
			&rc,
			angle_st->orig_line.point1,
			angle_st->orig_line.point2,
			angle_st->meas_line.point1,
			angle_st->meas_line.point2,
			a_info->norm_pl,
			pt_on_plane);

		/* | Find the intersection of the point   */

		rc = BSSUCC;
		status = BSxln( &rc,angle_st->orig_line.point1,
				angle_st->orig_line.point2,
				angle_st->meas_line.point1,
				angle_st->meas_line.point2,
				a_info->centerpt);
		if (rc == BSCOINCIDENT)
		{
			IGRdouble dist1, dist2, mdist1, mdist2;

			/*- The lines are coincident find the
			    common point (or closest pt) and
			    return it as origin
			*/

			dist1 = BSdistptpt(&rc, angle_st->orig_line.point1,
				angle_st->meas_line.point1);

			dist2 = BSdistptpt(&rc, angle_st->orig_line.point1,
				angle_st->meas_line.point2);

			if (dist1 > dist2)
				mdist1 = dist2;
			else	mdist1 = dist1;

			dist1 = BSdistptpt(&rc, angle_st->orig_line.point2,
				angle_st->meas_line.point1);

			dist2 = BSdistptpt(&rc, angle_st->orig_line.point2,
				angle_st->meas_line.point2);

			if (dist1 > dist2)
				mdist2 = dist2;
			else	mdist2 = dist1;

			if (mdist1 > mdist2)
			{
			   vec_equal( angle_st->orig_line.point2,a_info->centerpt);
			}
			else
			{
			   vec_equal( angle_st->orig_line.point1,a_info->centerpt);
			}
		}
		else if( rc!= BSSUCC || !(status &1))
		{ 
			if( me->mea_trak & ORIG_START)
			{	
				vec_equal(angle_st->orig_line.point2,a_info->centerpt);
			}
			else
			{
				vec_equal(angle_st->orig_line.point1,a_info->centerpt);
			}
		}
	}

	vec_sub( angle_st->orig_line.point2,
		 angle_st->orig_line.point1,
		 a_info->orig_ln_orie);
	
	if( me->mea_trak & ORIG_START)
	{
		vec_neg(a_info->orig_ln_orie,a_info->orig_ln_orie);
	}

	vec_sub(angle_st->meas_line.point2, 
		angle_st->meas_line.point1,
		a_info->meas_ln_orie);

	if( !(me->dim_type == SINGLE_ARC_LENGTH  ||
	      me->dim_type == SINGLE_ARC_ANGLE ))
	{
		if( me->mea_trak & MEAS_START)
		{
			vec_neg(a_info->meas_ln_orie,a_info->meas_ln_orie);
		}
	}

	/*| Get the unit vectors along the orig and meas directions */

	BSnorvec(&rc, a_info->orig_ln_orie);
	BSnorvec(&rc, a_info->meas_ln_orie);

	/*^
		print_point("centerpt",a_info->centerpt);
		print_point("orig orie",a_info->orig_ln_orie);
		print_point("meas orie",a_info->meas_ln_orie);
	*/

	/*| - computing the term points   */

	 v_projpt( a_info->centerpt,a_info->arc_rad,a_info->orig_ln_orie,
		   a_info->orig_term_pt); 
	 v_projpt( a_info->centerpt,a_info->arc_rad,a_info->meas_ln_orie,
		   a_info->meas_term_pt); 

        a_info->left = (me->mea_trak & CLOCK_WISE);
        a_info->right= ( !a_info->left);

	return( OM_S_SUCCESS);	
}

method leader_needed(
        IGRint *msg;
	struct GRmd_env *md_env;
        IGRboolean *leader)
{
	IGRint status;
        struct DMloc_param p_loc;

	status =
	dm$get_dim_param(
		type = DM_LOC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) &p_loc);
	dm$status(action = RET_STATUS);

	if( me->brk_pos == BRK_CENTER ||
	    p_loc.txt_orie == TXT_ORIE_PARALLEL)
	{
		*leader = FALSE;
		me->leader = FALSE;
	}
	else
	{
		me->leader = TRUE;
		*leader = TRUE;
	}

	*msg = OM_S_SUCCESS;
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

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						msg,
						md_env,
						plan_info),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMangular.get_cpx_origin(
						msg,
						cpx_origin,
						plan_info,
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

method give_trak_dist(IGRdouble *trak_dist)
{
	IGRint status, rc;
	IGRdouble prev_dist;
	struct GRid grid;
	IGRboolean first_in_cpx;

	*trak_dist = me->trak_dist;

	if (me->dim_type == STRINGED_ANGULAR)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		first_in_cpx = (grid.objid == my_id);
	}
	else
	{
		status =
		om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (!first_in_cpx)
	{
		status =
		om$send(msg = message DMangular.give_trak_dist(&prev_dist),
			targetid = grid.objid,
			targetos = grid.osnum);
		dm$status(action = RET_STATUS);

		*trak_dist += prev_dist;
	}

	return(OM_S_SUCCESS);
}

method init_ter_loca(IGRdouble ter_limit)
{
	IGRint status;
	IGRdouble trak_dist, arc_length;
	char ter_loca;

	status =
	om$send(msg = message DMangular.give_trak_dist(&trak_dist),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	arc_length = (trak_dist * me->dim_value);
	ter_loca = (arc_length > ter_limit)?
				TER_LOCA_INTERNAL:
				TER_LOCA_EXTERNAL;
	if (ter_loca != me->ter_loca)
	{
		me->dim_state |= DIM_NEEDS_UPDATE;
		me->ter_loca = ter_loca;
	}

	return(OM_S_SUCCESS);
}

end implementation DMangular;
