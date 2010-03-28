class implementation DMradjog;

#define AS_DEBUG 1
extern double fabs();

method make_proj_arc(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct DMdim_arc *arc_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble norm[3];

	*msg = MSSUCC;

	arc_info->flag = TRUE;

	if( arc_info->needed)
	{
		/*| projection arc needed */

		norm[0] = plan_info->act_plan.matrix[8];
		norm[1] = plan_info->act_plan.matrix[9];
		norm[2] = plan_info->act_plan.matrix[10];

		status =
		om$send(msg = message DMroot.position_arc(
						&rc,
						DIM_ORI_PROJ,
						(struct GRid *)NULL,
						md_env,
						norm,
						arc_info),
			    targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*| position arc NOT needed */

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_ORI_PROJ,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}
method make_dim_line(
	IGRint *msg;
	IGRint num_jog_pts;
	IGRdouble center[3], term_pt[3];
	IGRdouble dimline_vec[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	IGRdouble *jog_line;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRboolean intersect;
	IGRdouble pri_extn[3], sec_extn[3];
	IGRdouble intpt[2][3], extn;
	IGRdouble line_term[6], end_pt[3], cen_pt[3];
	IGRdouble box[12], points[9];
	struct DMdim_line dim_line[3];

	/*| Compute external point */

	extn = par_env->pnt_exte_r * par_env->txt_heig;

	for (i=0; i<3; i++)
	{
		pri_extn[i] = term_pt[i] + (dimline_vec[i] * extn);
		sec_extn[i] = center[i] + (-dimline_vec[i] * extn);
	}

	/*| Initialise dim_line */

	dim_line[0].line_index = DIM_LINE1;
	dim_line[1].line_index = DIM_LINE2;
	dim_line[2].line_index = DIM_LEADER;

	dim_line[0].needed =
	dim_line[1].needed = FALSE;

	intersect = 0;

	/*|Find text extents*/

	status =
	om$send(msg = message DMdim.get_text_extents(
					&rc,
					box,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if ( me->jogged )
	{
		math_v_equal(cen_pt, jog_line);
	}
	else
	{
		math_v_equal(cen_pt, center);
	}

	if (me->jogged)
	{
		/*| Find points of intersection with the text */

		if (num_jog_pts == 2)
		{
		       DMlineptpt(jog_line, &jog_line[3], line_term);
		}
		else
		{
		    if (me->brk_pos == BRK_CENTER)
		       DMlineptpt(cen_pt, term_pt, line_term);
		    else
		       DMlineptpt(&jog_line[6], &jog_line[3], line_term);
		}

		MATH_intersect_box_line(
			&rc,
			line_term,
			(IGRdouble (*)[])box,
			intpt,
			&intersect,
			plan_info->win_plan.matrix);

		dim_line[2].needed = FALSE;

		if (num_jog_pts == 2)
		{
			if (intersect)
			   const_dim_line(jog_line, intpt[0], &dim_line[2]);
			else
			   const_dim_line(jog_line, &jog_line[3], &dim_line[2]);

			me->brk_pos = BRK_CENTER;
			intersect = FALSE;

			status =
			om$send(msg = message DMroot.position_line(
					msg,
					DIM_LEADER,
					(struct GRid *)NULL,
					md_env,
					dim_line[2].line),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}		

		if (num_jog_pts > 2)
		{
			if (me->brk_pos == BRK_ALT_CENTER)
			{
			    for (i=0; i<3; i++)
			    {
				points[i] = term_pt[i];
				points[i+3] = jog_line[i];
				points[i+6] = jog_line[i+3];
			    }

			    if (me->ter_loca == TER_LOCA_EXTERNAL)
			    {
				math_v_equal(points, pri_extn);
			    }
			}
			else
			{
			    for (i=0; i<3*num_jog_pts; i++)
				points[i] = jog_line[i];
			}

			status =
			om$send(msg = message DMroot.position_line_string(
						msg,
						DIM_LEADER,
						(struct GRid *)NULL,
						md_env,
						num_jog_pts,
						points),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			dim_line[2].needed = TRUE;
		}
	}
	else if (me->leader)
	{
		if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
		{
			MATH_line_break(
				&rc,
				break_pt,
				leader_pt,
				plan_info->win_plan.matrix,
				(IGRdouble (*)[])box,
				(IGRdouble *) intpt);
		}
		else
		{
			MATH_line_extend(
				&rc,
				break_pt,
				leader_pt,
				(IGRdouble (*)[])box,
				(IGRdouble *)intpt);
		}

		const_dim_line(break_pt, intpt[0], &dim_line[2]);

		status =
		om$send(msg = message DMroot.position_line(
					msg,
					DIM_LEADER,
					(struct GRid *)NULL,
					md_env,
					dim_line[2].line),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		dim_line[2].needed = FALSE;

		if (me->brk_pos == BRK_LEFT)
		{
			math_v_equal(end_pt, cen_pt);
		}
		else if (me->brk_pos == BRK_RIGHT)
		{		
			math_v_equal(end_pt, term_pt);
		}

		if (me->brk_pos == BRK_LEFT || me->brk_pos == BRK_RIGHT)
		{
			if((par_loc->txt_posn == TXT_POSN_ABOVE) &&
			   ((par_loc->txt_orie == TXT_ORIE_PARALLEL) ||
			   (par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
			{
				MATH_line_extend(
					&rc,
					end_pt,
					break_pt,
				        (IGRdouble (*)[])box,
				        (IGRdouble *) intpt);
			}
			else
			{
				MATH_line_break(
					&rc,
					end_pt,
					break_pt,
					plan_info->win_plan.matrix,
					(IGRdouble (*)[])box,
					(IGRdouble *) intpt);
			}
		}
		else
		{
		    /*| Find points of intersection with the text */

		    DMlineptpt(cen_pt, term_pt, line_term);
		    MATH_intersect_box_line(
				&rc,
				line_term,
				(IGRdouble (*)[])box,
				intpt,
				&intersect,
				plan_info->win_plan.matrix);
		}
	}

	/*| compute dim line */

	switch(me->brk_pos)
	{
		case BRK_LEFT:

		/*| BRK_LEFT */
		if (me->ter_loca == TER_LOCA_INTERNAL)
			if(me->leader)
			     const_dim_line(term_pt, break_pt, &dim_line[0]);
			else const_dim_line(term_pt, intpt[0], &dim_line[0]);
		else if((me->dim_type == RADIAL_DIAMETER) &&
			(par_loc->lin_disp == LIN_DISP_OFF))
		{
			const_dim_line(pri_extn, term_pt, &dim_line[0]);
			if(me->leader)
			     const_dim_line(cen_pt, break_pt, &dim_line[1]);
			else const_dim_line(cen_pt, intpt[0], &dim_line[1]);
		}
		else
		{
			if(me->leader)
			     const_dim_line(pri_extn, break_pt, &dim_line[0]);
			else const_dim_line(pri_extn, intpt[0], &dim_line[0]);
		}
		break;

		case BRK_CENTER:

		/*| BRK_CENTER */
		if (me->ter_loca == TER_LOCA_INTERNAL)
		{
		    if ((par_loc->txt_posn == TXT_POSN_ABOVE) &&
			((par_loc->txt_orie == TXT_ORIE_PARALLEL ) ||
			(par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
		    {
			const_dim_line(cen_pt, term_pt, &dim_line[0]);
		    }
		    else
		    {
			if (intersect)
			{
			    const_dim_line(cen_pt,intpt[0], &dim_line[0]);
			    const_dim_line(term_pt,intpt[1], &dim_line[1]);
			}
			else const_dim_line(cen_pt,term_pt, &dim_line[0]);
		    }
		}
		else
		{
		    if(me->dim_type == RADIAL_DIAMETER)
		    {
    		    	if(par_loc->lin_disp == LIN_DISP_ON)
		    	{
		    	    if ((par_loc->txt_posn == TXT_POSN_ABOVE) &&
				((par_loc->txt_orie == TXT_ORIE_PARALLEL) ||
				(par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
			    {
		    	        const_dim_line(sec_extn, pri_extn, &dim_line[0]);
			    }
			    else
			    {
			    	if (intersect)
			    	{
			    		const_dim_line(sec_extn,
						intpt[0], &dim_line[0]);
			    		const_dim_line(pri_extn,
						intpt[1], &dim_line[1]);
			    	}
			    	else	const_dim_line(sec_extn,
						pri_extn, &dim_line[0]);
		    	    }
		    	}
			else
			{
				const_dim_line(sec_extn, cen_pt, &dim_line[0]);
				const_dim_line(term_pt, pri_extn, &dim_line[1]);
			}
		    }
		    else
		    {
			if ((par_loc->txt_posn == TXT_POSN_ABOVE) &&
			((par_loc->txt_orie == TXT_ORIE_PARALLEL) ||
			(par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
			{
			    const_dim_line(cen_pt, pri_extn, &dim_line[0]);
			}
			else
			{
			    if (intersect)
			    {
				const_dim_line(cen_pt, intpt[0], &dim_line[0]);
				const_dim_line(pri_extn, intpt[1], &dim_line[1]);
			    }
			    else
				const_dim_line(cen_pt, pri_extn, &dim_line[0]);
			}
		    }
		}

		break;

		case BRK_ALT_CENTER:

		/*| BRK_ALT_CENTER */

		if ((par_loc->txt_posn == TXT_POSN_ABOVE) &&
		((par_loc->txt_orie == TXT_ORIE_PARALLEL) ||
		(par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
		{
		    const_dim_line(&jog_line[6], &jog_line[3], &dim_line[0]);
		}
		else
		{
		    if (intersect)
		    {
			const_dim_line(&jog_line[6], intpt[0], &dim_line[0]);
			const_dim_line(&jog_line[3], intpt[1], &dim_line[1]);
		    }
		    else
		    const_dim_line(&jog_line[6], &jog_line[3], &dim_line[0]);
		}

		break;

		case BRK_RIGHT:

		/*| BRK_RIGHT */
		if (me->ter_loca == TER_LOCA_INTERNAL)
		{
		    if(par_loc->lin_disp == LIN_DISP_ON)
		    {
			if(me->dim_type == RADIAL_DIAMETER)
			{
			    if(!me->leader)
			   	const_dim_line(sec_extn, intpt[0], &dim_line[0]);
			    else const_dim_line(sec_extn, break_pt, &dim_line[0]);
			}
			else
			{
			    if(!me->leader)
			   	const_dim_line(cen_pt, intpt[0], &dim_line[0]);
			    else const_dim_line(cen_pt, break_pt, &dim_line[0]);
			}
		    }
		    else
		    {
			if(!me->leader)
			   const_dim_line(term_pt, intpt[0], &dim_line[0]);
			else const_dim_line(term_pt, break_pt, &dim_line[0]);
		    }
		}
		else
		{
			if(!me->leader)
			   const_dim_line(cen_pt, intpt[0], &dim_line[0]);
			else const_dim_line(cen_pt, break_pt, &dim_line[0]);
		}
		break;
	};

	/*^
		printf(" center : %f, %f, %f\n",center[0],center[1],center[2]);
		printf(" cen_pt : %f, %f, %f\n",cen_pt[0],cen_pt[1],cen_pt[2]);
		printf(" term_pt : %f, %f, %f\n",term_pt[0],term_pt[1],term_pt[2]);
		printf(" break_pt : %f, %f, %f\n",break_pt[0],break_pt[1],break_pt[2]);
	*/

	for (i=0; i<2; i++)
	{
		if (dim_line[i].needed)
		{
			/*^ print_line("dim_line", dim_line[i].line); */

			status =
			om$send(msg = message DMroot.position_line(
						msg,
						dim_line[i].line_index,
						(struct GRid *)NULL,
						md_env,
						dim_line[i].line),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*| Delete dim_line */

			status =
			om$send(msg = message DMroot.delete_dim_go(
						&rc,
						dim_line[i].line_index,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	if (!dim_line[2].needed)
	{
		/*| Delete DIM_LEADER component */

		status =
		om$send(msg = message DMroot.delete_dim_go(
					&rc,
					DIM_LEADER,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMradjog.make_center_marker(
					&rc,
					(num_jog_pts == 3),
					&jog_line[6],
					par_env,
					plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method make_center_marker(
	IGRint *msg;
	IGRboolean marker_needed;
	IGRdouble center[3];
	struct DMenv_param *par_env;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, i;
	IGRdouble point1[3], point2[3];
	struct DMdim_line dim_line[2];

	dim_line[0].line_index = DIM_LINE3;
	dim_line[1].line_index = DIM_LINE4;

	dim_line[0].needed =
	dim_line[1].needed = FALSE;

	if (marker_needed)
	{
		/*|- Place the center marker*/

		for(i=0; i<3; i++)
		{
			point1[i] = center[i] +
			(0.5 * par_env->txt_heig *
			plan_info->win_plan.vec_xpos[i]);

			point2[i] = center[i] +
			(0.5 * par_env->txt_heig *
			plan_info->win_plan.vec_xneg[i]);
		}

		const_dim_line(point1, point2, &dim_line[0]);

		for(i=0; i<3; i++)
		{
			point1[i] = center[i] +
			(0.5 * par_env->txt_heig *
			plan_info->win_plan.vec_ypos[i]);

			point2[i] = center[i] +
			(0.5 * par_env->txt_heig *
			plan_info->win_plan.vec_yneg[i]);
		}

		const_dim_line(point1, point2, &dim_line[1]);
	}

	for (i=0; i<2; i++)
	{
		if (dim_line[i].needed)
		{
			/*^ print_line("dim_line", dim_line[i].line); */

			status =
			om$send(msg = message DMroot.position_line(
						msg,
						dim_line[i].line_index,
						(struct GRid *)NULL,
						md_env,
						dim_line[i].line),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*| Delete dim_line */

			status =
			om$send(msg = message DMroot.delete_dim_go(
						msg,
						dim_line[i].line_index,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

end implementation DMradjog;

