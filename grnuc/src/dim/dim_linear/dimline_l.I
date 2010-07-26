class implementation DMlinear;

#define AS_DEBUG 1

extern double sqrt();

#include "bsdistptpt.h"
#include "bsnorvec.h"

method make_proj_line(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	IGRdouble orig[3], meas[3];
	IGRdouble term_ori[3], term_mea[3];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble proj_offs, proj_extn, offs, extn;
	IGRdouble proj_orig[6], proj_meas[6], dist;
	IGRdouble offs_ratio;
	BSrc	bsrc;

	if (me->dim_type == CIRCULAR_DIAMETER)
	{
		dist = BSdistptpt(&bsrc, orig, meas);		
		offs_ratio = sqrt((par_env->proj_offs_r * dist * 0.5) /
				par_env->txt_heig);
		offs = offs_ratio * par_env->txt_heig;
	}
	else offs = par_env->proj_offs_r * par_env->txt_heig;
	extn = par_env->proj_extn_r * par_env->txt_heig;

	status =
	om$send(msg = message DMlinear.set_proj_disp(&par_loc->proj_disp),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (par_loc->proj_disp & PROJ_DISP_ORI)
	{
	    dist = BSdistptpt(&bsrc, orig, term_ori);
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

	    DMmake_proj_line(
		&rc,
		orig,
		term_ori,
		proj_offs,
		proj_extn,
		proj_orig);

	    /*^	print_line("proj_orig", proj_orig); */

	    status =
	    om$send(msg = message DMroot.position_line(
					&rc,
					DIM_ORI_PROJ,
					(struct GRid *)NULL,
					md_env,
					proj_orig),
		    targetid = my_id);
	    dm$status(action = RET_STATUS);
	}
	else
	{
	    status =
	    om$send(msg = message DMroot.delete_dim_go(
					&rc,
					DIM_ORI_PROJ,
					md_env),
		    targetid = my_id);
	    dm$status(action = RET_STATUS);
	}

	if (par_loc->proj_disp & PROJ_DISP_MEA)
	{
	    dist = BSdistptpt(&bsrc, meas, term_mea);
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

	    DMmake_proj_line(
		&rc,
		meas,
		term_mea,
		proj_offs,
		proj_extn,
		proj_meas);

	    /*^	print_line("proj_meas", proj_meas); */

	    status =
	    om$send(msg = message DMroot.position_line(
					&rc,
					DIM_MEA_PROJ,
					(struct GRid *)NULL,
					md_env,
					proj_meas),
		    targetid = my_id);
	    dm$status(action = RET_STATUS);
	}
	else
	{
	    status =
	    om$send(msg = message DMroot.delete_dim_go(
					&rc,
					DIM_MEA_PROJ,
					md_env),
		    targetid = my_id);
	    dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method make_dim_line(
	IGRint *msg;
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble dimline_vec[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble box[4][3];
	struct DMdim_line dim_line[3];
	IGRdouble orig_extn[3], meas_extn[3];
	IGRdouble *term_pt;
	IGRdouble line_term[6];
	IGRdouble intpt[2][3];
	IGRdouble pnt_exte;
	IGRboolean intersect;
	int i;
	BSrc	bsrc;

	if (me->ter_loca == TER_LOCA_EXTERNAL)
	{
	    /*| Compute external points */

	    pnt_exte = par_env->pnt_exte_r * par_env->txt_heig;

	    BSnorvec(&bsrc, dimline_vec);

	    MATH_ptdelta(
		&rc,
		term_ori,
		dimline_vec,
		-pnt_exte,
		orig_extn);

	    MATH_ptdelta(
		&rc,
		term_mea,
		dimline_vec,
		pnt_exte,
		meas_extn);
	}

	/*|Find text extents*/

	status =
	om$send(msg = message DMdim.get_text_extents(
					&rc,
					(double *)box,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| Initialise dim_line */

	dim_line[0].line_index = DIM_LINE1;
	dim_line[1].line_index = DIM_LINE2;
	dim_line[2].line_index = DIM_LEADER;

	dim_line[0].needed =
	dim_line[1].needed = FALSE;

	if (me->leader)
	{
		DMcompute_endpt(
			&rc,
			break_pt,
			leader_pt,
			box,
			par_loc->txt_posn,
			plan_info->win_plan.matrix,
			md_env,
			(IGRdouble *)intpt);

		const_dim_line(break_pt, intpt[0], &dim_line[2]);
		math_v_equal(intpt[0], break_pt);
	}
	else
	{
		dim_line[2].needed = FALSE;

		if (me->brk_pos == BRK_LEFT || me->brk_pos == BRK_RIGHT)
		{
			if (me->brk_pos == BRK_LEFT)
				term_pt = term_ori;
			else if (me->brk_pos == BRK_RIGHT)
				term_pt = term_mea;

			DMcompute_endpt(
				&rc,
				term_pt,
				break_pt,
				box,
				par_loc->txt_posn,
				plan_info->win_plan.matrix,
				md_env,
				(IGRdouble *) intpt);
		}
		else if (((me->ter_loca == TER_LOCA_INTERNAL) ||
			  (par_loc->lin_disp == LIN_DISP_ON )) &&
			 (par_loc->txt_posn == TXT_POSN_EMBEDDED))
		{
		    /*| Find points of intersection with the text */

		    DMlineptpt(term_ori, term_mea,  line_term);
		    MATH_intersect_box_line(
				&rc,
				line_term,
				box,
				intpt,
				&intersect,
				plan_info->win_plan.matrix);
		}
	}

	/*| compute dim line */

	switch(me->brk_pos)
	{
		case BRK_LEFT:

		if (me->ter_loca == TER_LOCA_INTERNAL)
			const_dim_line(term_mea, intpt[0], &dim_line[0]);
		else if (par_loc->lin_disp == LIN_DISP_ON)
			const_dim_line(meas_extn, intpt[0], &dim_line[0]);
		else
		{
			const_dim_line(term_ori, intpt[0], &dim_line[0]);
			const_dim_line(meas_extn, term_mea, &dim_line[1]);
		}
		break;

		case BRK_CENTER:

		if (me->ter_loca == TER_LOCA_INTERNAL)
		{
		    if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
		    {
			if (intersect)
			{
			    const_dim_line(term_ori,intpt[0], &dim_line[0]);
			    const_dim_line(term_mea,intpt[1], &dim_line[1]);
			}
			else const_dim_line(term_ori,term_mea, &dim_line[0]);
		    }
		    else const_dim_line(term_ori, term_mea, &dim_line[0]);
		}
		else
		{
		    if (par_loc->lin_disp == LIN_DISP_ON)
		    {
			if (me->dim_type == SYMMETRICAL_DIAMETER)
			{
				/* For symmetrical diameter the
				   origin extension cannot exist */

				math_v_equal(orig_extn, term_ori);
			}

			if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
			{
			    if (intersect)
			    {
				const_dim_line(orig_extn, intpt[0], &dim_line[0]);
				const_dim_line(meas_extn, intpt[1], &dim_line[1]);
			    }
			    else const_dim_line(orig_extn, meas_extn, &dim_line[0]);
			}
			else const_dim_line(orig_extn, meas_extn, &dim_line[0]);
		    }
		    else
		    {
			const_dim_line(term_ori, orig_extn, &dim_line[0]);
			const_dim_line(term_mea, meas_extn, &dim_line[1]);
		    }
		}

		break;

		case BRK_RIGHT:

		if (me->ter_loca == TER_LOCA_INTERNAL)
			const_dim_line(term_ori, intpt[0], &dim_line[0]);
		else if (par_loc->lin_disp == LIN_DISP_ON)
		{
			if (me->dim_type == SYMMETRICAL_DIAMETER)
			{
				/* For symmetrical diameter the
				   origin extension cannot exist */

				math_v_equal(orig_extn, term_ori);
			}

			const_dim_line(orig_extn, intpt[0], &dim_line[0]);
		}
		else
		{
			const_dim_line(term_ori, orig_extn, &dim_line[0]);
			const_dim_line(term_mea, intpt[0], &dim_line[1]);
		}

		break;
	};

	for (i=0; i<3; i++)
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

	return(OM_S_SUCCESS);
}

end implementation DMlinear;

