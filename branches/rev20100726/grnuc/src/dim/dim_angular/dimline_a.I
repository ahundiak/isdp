class implementation DMangular;

#define AS_DEBUG	1
%safe
#include <bsvalues.h>
%endsafe 

#include "bsdistptpt.h"

method make_proj_lines(IGRlong *msg;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct dm_ang_src_st *angle_st;
	struct angular_data_st *ang_info;
	struct GRmd_env *md_env)
{
	int status, rc;
	IGRdouble proj_offs,proj_extn, offs, extn;
	double proj_line[6];
	IGRdouble dist1, dist2, dist;
        BSrc	bs_rc;

	offs = p_env->proj_offs_r * p_env->txt_heig;
	extn = p_env->proj_extn_r * p_env->txt_heig;

	if( p_loc->proj_disp & PROJ_DISP_ORI)
	{
		dist1 =	BSdistptpt(
			&bs_rc,
			angle_st->orig_line.point1,
			ang_info->orig_term_pt);

		dist2 =	BSdistptpt(
			&bs_rc,
			angle_st->orig_line.point2,
			ang_info->orig_term_pt);

		if(dist1 < dist2)
			dist = dist1;
		else	dist = dist2;

		if(me->prj_offs[0] <= dist)
		{
			proj_offs = me->prj_offs[0] + offs;
			proj_extn = extn;
		}
		else
		{
			proj_offs = me->prj_offs[0] - offs;
			proj_extn = -extn;
		}

		DMang_compute_proj_line(&angle_st->orig_line,
					ang_info->orig_term_pt,
					proj_line,
					proj_extn,
					proj_offs);
		/*^
			int i;

			for( i = 0; i<6;i++)
				printf("proj_line[%ld]:%lf\n",i,proj_line[i]);
		*/

		status =
		om$send(msg = message DMroot.position_line( &rc,
						DIM_ORI_PROJ,
						(struct GRid *)NULL,
						md_env,
						proj_line ),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else 
	{
		status =om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_ORI_PROJ,
							md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if( p_loc->proj_disp & PROJ_DISP_MEA)
	{
		dist1 =	BSdistptpt(
			&bs_rc,
			angle_st->meas_line.point1,
			ang_info->meas_term_pt);

		dist2 =	BSdistptpt(
			&bs_rc,
			angle_st->meas_line.point2,
			ang_info->meas_term_pt);

		if(dist1 < dist2)
			dist = dist1;
		else	dist = dist2;

		if(me->prj_offs[1] <= dist)
		{
			proj_offs = me->prj_offs[1] + offs;
			proj_extn = extn;
		}
		else
		{
			proj_offs = me->prj_offs[1] - offs;
			proj_extn = -extn;
		}

		DMang_compute_proj_line(&angle_st->meas_line,
					ang_info->meas_term_pt,
					proj_line,
					proj_extn,
					proj_offs);
		/*^
			int i;

			for( i = 0; i<6;i++)
				printf("proj_line[%ld]:%lf\n",i,proj_line[i]);
		*/
		status =
		om$send(msg = message DMroot.position_line(&rc,
						DIM_MEA_PROJ,
						(struct GRid *)NULL,
						md_env,
						proj_line ),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else 
	{
		status = om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_MEA_PROJ,
							md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method make_dim_line( IGRlong *msg;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct angular_data_st *ang_info;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct DMdim_line dim_leader;
	IGRdouble box[12];
	IGRdouble intpt[2][3];
	IGRdouble extn_arc=0.0,*loc_breakpt;
	struct DMdim_arc dmarc[2];
	IGRint num_inter, text_inter=0;
	int i, flag,single_arc;
	IGRdouble *extn_endpt, extnpt[3], endpt[3];
	IGRdouble txt_extn ;
	IGRdouble left_arc_endpt[3], right_arc_endpt[3];
	IGRchar txt_posn;

	if(me->mea_trak & CLOCK_WISE)
	{
		ang_info->left_term_pt = ang_info->orig_term_pt;
		ang_info->right_term_pt = ang_info->meas_term_pt;
	}
	else
	{
		ang_info->left_term_pt = ang_info->meas_term_pt;
		ang_info->right_term_pt = ang_info->orig_term_pt;
	}

	/*|As long as this routine is conserned if text orientation
	   is horizontal  text pos is EMBEDDED */

	txt_posn = p_loc->txt_posn;

	if ((p_loc->txt_orie == TXT_ORIE_HORIZONTAL)
	||  (p_loc->txt_orie == TXT_ORIE_VERTICAL))
		txt_posn = TXT_POSN_EMBEDDED;

	if (p_loc->txt_orie == TXT_ORIE_PERPENDICULAR)
		txt_extn = ang_info->min_length / 2.0;
	else	txt_extn = ang_info->max_length / 2.0;

	for (i=0; i<3; i++)
	{
		intpt[0][i] = intpt[1][i] =  0.0;
	}

	/*^
		print_point("breakpt:",ang_info->breakpt);
		printf("arc_rad:%lf\n",ang_info->arc_rad);
		printf("brkpos:%d\n",me->brk_pos);
	*/

	status =
	om$send(msg = message DMdim.get_text_extents(
					&rc,
					box,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (txt_posn == TXT_POSN_EMBEDDED && !(me->leader))
	{
		/*|get the text object and the intersection points*/

		MATH_intersect_circle_line(&rc,
					   ang_info->centerpt,
		    			   ang_info->arc_rad,
					   &num_inter,
		    			   intpt,
		    			   (IGRdouble (*)[])box,
		    			   plan_info->win_plan.matrix);

		/*^
			print_point("intpt0", intpt[0]);
			print_point("intpt1", intpt[1]);
		*/

		text_inter = (num_inter>0)?1:0;
	}

	dmarc[0].line_index = DIM_LINE1;
	dmarc[1].line_index = DIM_LINE2;

	dmarc[0].needed = 
	dmarc[1].needed = 0; 

	/*| init centerpt */

	vec_equal(ang_info->centerpt, dmarc[0].centerpt);
	vec_equal(ang_info->centerpt, dmarc[1].centerpt);

	/*| set term */

	if (me->ter_loca == TER_LOCA_EXTERNAL)
	   extn_arc = p_env->pnt_exte_r * p_env->txt_heig;

	if (me->leader)
	{
		/*|leader exits*/

		DMcompute_endpt(
			&rc,
			ang_info->breakpt,
			ang_info->leaderpt,
			(IGRdouble (*)[])box,
			p_loc->txt_posn,
			plan_info->win_plan.matrix,
			md_env,
			endpt);

		DMlineptpt(ang_info->breakpt, endpt, dim_leader.line);

		dim_leader.needed = TRUE;
	}
	else   dim_leader.needed = FALSE;

	switch (me->brk_pos)
	{
		case BRK_LEFT:

		/*|BREAK LEFT*/
		dmarc[0].needed = TRUE;

		if (me->leader
		|| txt_posn != TXT_POSN_EMBEDDED
		|| !text_inter)
			loc_breakpt = ang_info->breakpt;
		else
		{
			MATH_get_dir_vec(&rc,ang_info->centerpt,
			    		 intpt[0],intpt[1],
			    		 ang_info->norm_pl,&flag);
			if( flag == ANTI_CLOCK_DIR)
			{
				/*|take right inter point*/
				loc_breakpt = intpt[0];
			}
			else
			{
				/*|take left inter point*/
				loc_breakpt = intpt[1];
			}
		}

		if( me->ter_loca == TER_LOCA_EXTERNAL)
		{
			/*|Terminator location external */
			DMget_pt_at_angle( ang_info->centerpt,
					   ang_info->right_term_pt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
					   dmarc[0].startpt,
					   extn_arc,
					   CLOCK_DIR);
		}
		else
		{
			vec_equal(ang_info->right_term_pt,dmarc[0].startpt);
		}

		if (p_loc->lin_disp == LIN_DISP_ON
		|| me->ter_loca == TER_LOCA_INTERNAL)
		{
			vec_equal(loc_breakpt,dmarc[0].endpt);
			single_arc = TRUE;
		}
		else 
		{
			dmarc[1].needed = TRUE;
			vec_equal(ang_info->right_term_pt,dmarc[0].endpt);
			vec_equal(ang_info->left_term_pt,dmarc[1].startpt);
			vec_equal(loc_breakpt,dmarc[1].endpt);
			single_arc = FALSE;
		}

		if (((p_loc->txt_orie == TXT_ORIE_PERPENDICULAR)
		||   (p_loc->txt_orie == TXT_ORIE_PARALLEL))
		&&   (txt_posn == TXT_POSN_ABOVE) && !me->leader)
		{
			extn_endpt= (single_arc ?dmarc[0].endpt:dmarc[1].endpt);

			DMget_pt_at_angle( ang_info->centerpt,
					   extn_endpt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
					   extnpt,
					   txt_extn,
					   ANTI_CLOCK_DIR);
			vec_equal(extnpt,extn_endpt);
		}

		dmarc[1].flag = 1;   /* we need the smaller arc */

		MATH_get_dir_vec(&rc,ang_info->centerpt,
		    		 dmarc[0].startpt,
		    		 dmarc[0].endpt,
		    		 ang_info->norm_pl,&flag);

		if( flag == CLOCK_DIR)
			dmarc[0].flag = 2;
		else	dmarc[0].flag = 1; 

		break;

		case BRK_CENTER:

		/*|break center*/
		dmarc[0].needed = TRUE;
		if (me->ter_loca == TER_LOCA_EXTERNAL)
		{
			DMget_pt_at_angle( ang_info->centerpt,
			    		   ang_info->left_term_pt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
			   		   left_arc_endpt,
					   extn_arc,
					   ANTI_CLOCK_DIR);

			DMget_pt_at_angle( ang_info->centerpt,
					   ang_info->right_term_pt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
					   right_arc_endpt,
					   extn_arc,
					   CLOCK_DIR);
		}
		else 
		{
			v_equal(ang_info->left_term_pt,left_arc_endpt);
			v_equal(ang_info->right_term_pt,right_arc_endpt);
		}

		if (p_loc->lin_disp == LIN_DISP_OFF
		&&  me->ter_loca == TER_LOCA_EXTERNAL)
		{
			dmarc[1].needed = TRUE;
			vec_equal(left_arc_endpt,dmarc[0].startpt ) ;
			vec_equal(ang_info->left_term_pt,dmarc[0].endpt );
			vec_equal(ang_info->right_term_pt,dmarc[1].startpt );
			vec_equal(right_arc_endpt,dmarc[1].endpt);

			dmarc[0].flag = 1;
			dmarc[1].flag = 1;
		}
		else if (txt_posn == TXT_POSN_EMBEDDED && text_inter)
		{
			dmarc[1].needed = TRUE;
			MATH_get_dir_vec(&rc,ang_info->centerpt,
			    intpt[0],intpt[1],ang_info->norm_pl,
			    &flag);
			if(flag == ANTI_CLOCK_DIR)
			{
				/*|left inter pt is first inter*/
				loc_breakpt = intpt[1];
				vec_equal(intpt[0],dmarc[1].startpt);
			}
			else
			{
				/*|right inter pt is first inter*/
				loc_breakpt = intpt[0];
				vec_equal(intpt[1],dmarc[1].startpt);
			}

			vec_equal(left_arc_endpt,dmarc[0].startpt );
			vec_equal(loc_breakpt,dmarc[0].endpt);
			vec_equal(right_arc_endpt,dmarc[1].endpt);
			if( ang_info->dimn_val < M_PI)
			{
				dmarc[0].flag = 
				dmarc[1].flag = 1;
			}
			else
			{
			MATH_get_dir_vec(&rc,ang_info->centerpt,
					 dmarc[0].startpt,
					 dmarc[0].endpt,
					 ang_info->norm_pl,
					 &flag);
			dmarc[0].flag = (flag == ANTI_CLOCK_DIR)? 2:1;

			MATH_get_dir_vec(&rc,ang_info->centerpt,
					 dmarc[1].startpt,
					 dmarc[1].endpt,
					 ang_info->norm_pl,
					 &flag);
			dmarc[1].flag = (flag == ANTI_CLOCK_DIR)? 2:1;
			}
		}
		else 
		{
			/*|terminator position is external*/
			vec_equal(left_arc_endpt,dmarc[0].startpt );
			vec_equal(right_arc_endpt,dmarc[0].endpt );
			dmarc[0].flag = (ang_info->dimn_val < M_PI)?1:2;
		}

		break;

		case BRK_RIGHT:

		/*|break right*/

		dmarc[0].needed = TRUE;
		if (txt_posn != TXT_POSN_EMBEDDED
		|| me->leader || !text_inter)
			loc_breakpt = ang_info->breakpt;
		else 
		{
			MATH_get_dir_vec(&rc,ang_info->centerpt,
					 intpt[0],intpt[1],ang_info->norm_pl,
					 &flag);
			/*"flag:(clock=1,anti = 2)%d\n",flag*/

			if(flag == ANTI_CLOCK_DIR)
				loc_breakpt = intpt[1];
			else
				loc_breakpt = intpt[0];
		}

		if (me->ter_loca == TER_LOCA_EXTERNAL)
		{
			DMget_pt_at_angle( ang_info->centerpt,
					   ang_info->left_term_pt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
					   dmarc[0].startpt,
					   extn_arc,
					   ANTI_CLOCK_DIR);
		}
		else 
		{
			vec_equal(ang_info->left_term_pt,dmarc[0].startpt);
		}

		if (p_loc->lin_disp == LIN_DISP_ON
		||  me->ter_loca == TER_LOCA_INTERNAL)
		{
			/*|ter loca int or linedisp on */
			vec_equal(loc_breakpt,dmarc[0].endpt);
			single_arc = TRUE;
		}
		else 
		{
			dmarc[1].needed = TRUE;
			vec_equal(ang_info->left_term_pt,dmarc[0].endpt );
			vec_equal(ang_info->right_term_pt,dmarc[1].startpt );
			vec_equal(loc_breakpt,dmarc[1].endpt );
			single_arc = FALSE;
		}

		if (((p_loc->txt_orie == TXT_ORIE_PERPENDICULAR)
		||   (p_loc->txt_orie == TXT_ORIE_PARALLEL))
		&&   (txt_posn == TXT_POSN_ABOVE) && !me->leader)
		{
			extn_endpt=(single_arc ?dmarc[0].endpt:dmarc[1].endpt);

			DMget_pt_at_angle( ang_info->centerpt,
					   extn_endpt,
					   ang_info->arc_rad,
					   plan_info->win_plan.matrix,
					   extnpt,
					   txt_extn,
					   CLOCK_DIR);
			vec_equal(extnpt,extn_endpt);
		}

		dmarc[1].flag = 1;
		MATH_get_dir_vec(&rc,ang_info->centerpt,
				 dmarc[0].startpt,
				 dmarc[0].endpt,
				 ang_info->norm_pl, &flag);

		if(flag == ANTI_CLOCK_DIR)
			dmarc[0].flag = 2;
		else	dmarc[0].flag = 1;

		break;
	}

	for (i=0; i<2; i++)
	{
		if(dmarc[i].needed)
		{
			/*"position_arc flag = %d\n", dmarc[i].flag*/

			status = 
			om$send( msg = message DMroot.position_arc(&rc,
						dmarc[i].line_index,
						NULL,
						md_env,
						ang_info->norm_pl,
						&dmarc[i]),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*| Delete dim_line */

			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							dmarc[i].line_index,
							md_env),
			    targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	if( dim_leader.needed)
	{
		/*|leader needed*/
		status = 
		om$send( msg = message DMroot.position_line(&rc,
						DIM_LEADER,
						(struct GRid *)NULL,
						md_env,
						dim_leader.line),
			targetid = my_id);
		dm$status(action = RET_STATUS);

	}
	else
	{
		/*| Delete leader */
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_LEADER,
						md_env),
		    targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	return(OM_S_SUCCESS);

}

end implementation DMangular;
