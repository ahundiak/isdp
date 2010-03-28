class implementation DMlinear;

#define AS_DEBUG 1

from GRtext import GRchgtextattr;
from dim_param import store_internal;

#include "dimmod.h"
#include "mascalvc.h"
#include "maaddvc.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

extern double sqrt();
extern IGRboolean	BSproj0();

method dynamics(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	IGRint status, rc;

	struct DMdyn_linear  *place_attr;
	struct DMenv_param   *par_env;
	struct DMloc_param   *par_loc;
	struct DMplan_info   *plan_info;

	IGRdouble trak_pt[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	IGRdouble orig_meas[3], orig_brak[3], meas_brak[3];
	IGRdouble dotp_ori, dotp_mea;
	IGRint index, i;
	BSrc	bsrc;

	IGRboolean cursor_above;
	IGRdouble tmp_vec[3];
	IGRdouble term_ori[3], term_mea[3];
	IGRdouble proj_ori[6], proj_mea[6];
	IGRdouble dim_line[6];
	IGRdouble lea_line[6];
	IGRdouble text_pt[3];
	IGRdouble *proj_vec, *projline, dist;
	IGRdouble *oldpt, *oldterm, *old_vec;
	IGRdouble newpt[3], new_vec[3], proj_offs, proj_extn;
	IGRdouble *ter_pt, temp_dist;
	IGRvector brak_lead;
	IGRpoint trak_perp_pt;
	IGRvector orig_trak, xaxis, yaxis;
	IGRpoint lead_end;
	IGRpoint cpx_origin;
	IGRdouble trak_dist;
	IGRshort txt_just;
	IGRdouble box[4][3];
	IGRdouble proj_line[6];
	struct DMmisc_param par_misc;

	if (me->dim_state & DIM_NEEDS_UPDATE)
	{
		/*| - Update Dimensions - */

		status =
		om$send(msg = message NDnode.NDs_compute_node(
						(IGRlong *)&rc,
						NULL,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		control |= FILL_INFO;
	}

	if (control & FILL_INFO)
	{
		/*| - Fill Dimension Info - */

		status =
		om$send(msg = message DMroot.fill_info(
						&rc,
						control,
						level,
						info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (*level == 0)
		{
			/*| - Get miscellaneous parameters - */

			place_attr = (struct DMdyn_linear *)info;

			if (me->dim_state & DIM_IN_PLACEMENT)
			{
				status =
				dm$get_dim_param(
					type = DM_MISC_PARAM,
					p_data = (char *) &par_misc);
				dm$status(action = RET_STATUS);

				place_attr->aut_cent = par_misc.aut_cent;
			}
			else	place_attr->aut_cent = FALSE;
		}
	}

	place_attr = (struct DMdyn_linear *)info + (*level);
	plan_info  = &place_attr->plan_info;
	par_env    = &place_attr->par_env;
	par_loc    = &place_attr->par_loc;

	/*^
		print_point("orig_P", place_attr->orig_P);
		print_point("meas_P", place_attr->meas_P);
		print_point("cursor", cursor);
	*/

	if (*level)
	{
		/*|Dependent Dimension*/

		/* -
			Control passes down to the dependents
			only when the dimension line is being moved,
			otherwise we should never get here.
		- */

		if (!(control & MOVE_TRAK_PT))
		{
			printf("dynamics: ERROR in dependent control\n");
			return(OM_W_ABORT);
		}

		trak_dist = 0.0;

		status =
		om$send(msg = message DMlinear.get_mea_trak_info(
						cpx_origin,
						(char *)&me->mea_trak,
						&trak_dist,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMlinear.compute_trak_pt(
						&rc,
						place_attr->cpx_orig_P,
						trak_dist,
						plan_info,
						place_attr->trak_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMlinear.compute_proj_term(
						&rc,
						place_attr->trak_pt,
						par_env->proj_angl,
						plan_info,
						place_attr->orig_P,
						place_attr->meas_P,
						term_ori,
						term_mea),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMlinear.compute_break_pt(
						&rc,
						term_ori,
						term_mea,
						&place_attr->dimn_value,
						orig_meas,
						break_pt,
						&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMlinear.make_proj_line(
						&rc,
						par_env,
						par_loc,
						place_attr->orig_P,
						place_attr->meas_P,
						term_ori,
						term_mea,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
    else
    {

	/*|Independent Dimension*/

	if ((control & MOVE_ORIG_PT) || (control & MOVE_MEAS_PT))
	{
		/* -
			Project cursor onto the projection line
			to obtain the new orig point and
			compute offset distance and direction 
		- */

		if(control & MOVE_ORIG_PT)
		{
			oldpt = place_attr->orig_P;
			oldterm = place_attr->term_ori;
			old_vec = place_attr->orig_vec;
			projline = place_attr->proj_ori;
			index = 0;
		}
		else
		{
			oldpt = place_attr->meas_P;
			oldterm = place_attr->term_mea;
			old_vec = place_attr->meas_vec;
			projline = place_attr->proj_mea;
			index = 1;
		}

		BSproj0(&bsrc, cursor, projline, newpt);
		BSmkvec(&bsrc, new_vec, oldpt, newpt);

		if(BSdotp(&bsrc, old_vec, new_vec) >= 0.0)
			me->prj_offs[index] = BSlenvec(&bsrc, new_vec);
		else	me->prj_offs[index] = -BSlenvec(&bsrc, new_vec);

		dist = BSdistptpt(&bsrc, oldpt, oldterm);

		if(me->prj_offs[index] <= dist)
		{
			proj_offs = me->prj_offs[index] + place_attr->proj_offs;
			proj_extn = place_attr->proj_extn;
		}
		else
		{
			proj_offs = me->prj_offs[index] - place_attr->proj_offs;
			proj_extn = -place_attr->proj_extn;
		}

		DMmake_proj_line(
			&rc,
			oldpt,
			oldterm,
			proj_offs,
			proj_extn,
			proj_line);

		status =
		om$send(msg = message DMroot.position_line(
						&rc,
						DIM_NO_INDEX,
						&place_attr->proj_grid[index],
						md_env,
						proj_line),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (control & MOVE_LEADER_PT)
	{
		/* -
			This is an exclusive movement and
			cannot be done in combination with any
			other modification. The dimension must
			have the leader "ON" by now.
		*/

		if (!me->leader)
		{
			printf("dynamics: ERROR leader is OFF\n");
			return(OM_W_ABORT);
		}

		/* -
			Project cursor onto the leader line
			to obtain the leader point and
			compute leader distance and direction 
		- */

		BSproj0(&bsrc, cursor, place_attr->lea_line, leader_pt);
		BSmkvec(&bsrc, brak_lead, place_attr->break_pt, leader_pt);
		if (BSdotp(&bsrc, brak_lead, place_attr->text_dir) >= 0)
		{
			txt_just = place_attr->just_pos;
			me->lead_dist = BSlenvec(&bsrc, brak_lead);
		}
		else
		{
			txt_just = place_attr->just_neg;
			me->lead_dist = - BSlenvec(&bsrc, brak_lead);
		}

		me->lead_dist = me->lead_dist/
			BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);

		/* - Position Text - */

		MAaddvc(&bsrc, leader_pt, place_attr->def_offs, text_pt);

		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_NO_INDEX,
						&place_attr->text_grid,
						md_env,
						txt_just,
						text_pt,
						NULL,
						NULL,
						par_loc,
						par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/* - Compute leader line end point - */	/*|Find text extents*/

		status =
		om$send(msg = message DMdim.get_text_extents(
						&rc,
						 (double *)box,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		DMcompute_endpt(
			&rc,
			place_attr->break_pt,
			leader_pt,
			box,
			par_loc->txt_posn,
			plan_info->win_plan.matrix,
			md_env,
			lead_end);

		DMlineptpt(place_attr->break_pt, lead_end, lea_line);

		/* - Position Leader Line - */

		status =
		om$send(msg = message DMroot.position_line(
						&rc,
						DIM_LEADER,
						NULL,
						md_env,
						lea_line),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (control & MOVE_TRAK_PT)
	{
		cursor_above = FALSE;

		if (!place_attr->first_in_cpx)
		{
			/* - Find if cursor is above or below the
			     minimum position - */

			BSmkvec(&bsrc, tmp_vec, place_attr->trak_pt, cursor);
			if (BSdotp(&bsrc, tmp_vec, place_attr->trak_vec) < 0)
			{
				/*| Cursor is below minimum position */

				/* - Use the pre-computed values for
				     trak point, terminator positions
				     and projection line end points - */

				me->trak_dist = (par_env->lin_offs_r *
						par_env->txt_heig)/
				BSlenvec(&bsrc, place_attr->mea_axis);

				math_v_equal(trak_pt, place_attr->trak_pt);
				math_v_equal(term_ori, place_attr->term_ori);
				math_v_equal(term_mea, place_attr->term_mea);
				math_ln_equal(proj_ori, place_attr->proj_ori);
				math_ln_equal(proj_mea, place_attr->proj_mea);

				if (control & MOVE_BREAK_PT)
				{
					/* - Project cursor onto the minimum
					     dimension line(precomputed) to
					     obtain break_pt positon - */

					BSproj0(&bsrc,
						cursor,
						place_attr->dim_line,
						break_pt);
				}
			}
			else
			{
				/*| Cursor above minimum position */
				cursor_above = TRUE;
			}
		}

		if (place_attr->first_in_cpx || cursor_above)
		{
			/*| First in complex or cursor above min posn */

			/* -
				Trak_pt and break_pt at cursor location
				Dimline passes throuh trak_pt and is
				parallel to mea_axis
			- */

			math_v_equal(trak_pt, cursor);
			if (control & MOVE_BREAK_PT)
				math_v_equal(break_pt, cursor);
			DMlineptvec(trak_pt, place_attr->mea_axis, dim_line);

			/* - Compute trak distance - */

			MATH_proj_along_vector(
				&rc,
				place_attr->cpx_orig_P,
				place_attr->perp_axis,
				dim_line,
				trak_perp_pt);

			BSmkvec(&bsrc,
				orig_trak,
				place_attr->cpx_orig_P,
				trak_perp_pt);

			/*|- Scale the Trak Dist */

			temp_dist = BSlenvec(&bsrc, orig_trak) /
				BSlenvec(&bsrc, place_attr->mea_axis);

			/*"temp_dist = %f\n", temp_dist*/
			/*"prev_dist = %f\n", place_attr->trak_dist_prev*/

			me->trak_dist = temp_dist -
					place_attr->trak_dist_prev;

			/*"trak_dist = %f\n", me->trak_dist*/

			if (place_attr->first_in_cpx)
			{
				/* - First in complex - set trak dir - */

				if (BSdotp(&bsrc, orig_trak, place_attr->perp_axis) < 0)
					me->mea_trak &= (~DM_TRAK_DIR);
				else	me->mea_trak |= DM_TRAK_DIR;

				/*"mea_trak = %d\n", me->mea_trak*/
			}

			/* - Project origin and measurement points onto
			     the dimension line along the projection vector
			     to obtain the terminator positions - */

			MATH_proj_along_vector(
				&rc,
				place_attr->orig_P,
				place_attr->proj_vec,
				dim_line,
				term_ori);

			MATH_proj_along_vector(
				&rc,
				place_attr->meas_P,
				place_attr->proj_vec,
				dim_line,
				term_mea);

			/* - Compute the projection line end points - */

			BSmkvec(&bsrc, tmp_vec, place_attr->orig_P, term_ori);
			if (BSdotp(&bsrc, tmp_vec, place_attr->proj_vec) < 0)
				proj_vec = place_attr->proj_neg;
			else	proj_vec = place_attr->proj_vec;
				
			dist = BSlenvec(&bsrc, tmp_vec);

			if(me->prj_offs[0] <= dist)
			{
				proj_offs = me->prj_offs[0] + place_attr->proj_offs;
				proj_extn = place_attr->proj_extn;
			}
			else
			{
				proj_offs = me->prj_offs[0] - place_attr->proj_offs;
				proj_extn = -place_attr->proj_extn;
			}

			MATH_ptdelta(
				&rc,
				place_attr->orig_P,
				proj_vec,
				proj_offs,
				&proj_ori[0]);

			MATH_ptdelta(
				&rc,
				term_ori,
				proj_vec,
				proj_extn,
				&proj_ori[3]);

			BSmkvec(&bsrc, tmp_vec, place_attr->meas_P, term_mea);
			if (BSdotp(&bsrc, tmp_vec, place_attr->proj_vec) < 0)
				proj_vec = place_attr->proj_neg;
			else	proj_vec = place_attr->proj_vec;
	
			dist = BSlenvec(&bsrc, tmp_vec);

			if(me->prj_offs[1] <= dist)
			{
				proj_offs = me->prj_offs[1] + place_attr->proj_offs;
				proj_extn = place_attr->proj_extn;
			}
			else
			{
				proj_offs = me->prj_offs[1] - place_attr->proj_offs;
				proj_extn = -place_attr->proj_extn;
			}

			MATH_ptdelta(
				&rc,
				place_attr->meas_P,
				proj_vec,
				proj_offs,
				&proj_mea[0]);

			MATH_ptdelta(
				&rc,
				term_mea,
				proj_vec,
				proj_extn,
				&proj_mea[3]);
		}
	}
	else
	{
		/* - Use the pre-computed values for
		     trak point, terminator positions
		     and projection line end points - */

		math_v_equal(trak_pt, place_attr->trak_pt);
		math_v_equal(term_ori, place_attr->term_ori);
		math_v_equal(term_mea, place_attr->term_mea);
		math_ln_equal(proj_ori, place_attr->proj_ori);
		math_ln_equal(proj_mea, place_attr->proj_mea);

		if (control & MOVE_BREAK_PT)
		{
			/* - Project cursor onto the dimension
			     line(precomputed) to obtain break_pt
			     positon - */

			BSproj0(&bsrc,
				cursor,
				place_attr->dim_line,
				break_pt);
		}
	}

	if (control & MOVE_BREAK_PT)
	{
		/* - Compute Break Point Position - */

		BSmkvec(&bsrc, orig_meas, term_ori, term_mea);
		BSmkvec(&bsrc, orig_brak, term_ori, break_pt);
		BSmkvec(&bsrc, meas_brak, term_mea, break_pt);

		dotp_ori = BSdotp(&bsrc, orig_meas, orig_brak);
		dotp_mea = BSdotp(&bsrc, orig_meas, meas_brak);

		/*^
			print_point("term_orig", term_ori);
			print_point("term_meas", term_mea);
			print_point("break_pt", break_pt);
		*/

		/*"dotp_ori=%lf, dotp_mea=%lf\n", dotp_ori, dotp_mea*/

		if (dotp_ori > 0.0 && dotp_mea > 0.0)
		{
			me->brk_pos = BRK_RIGHT;
			me->brk_dist = BSlenvec(&bsrc, meas_brak)/
			 BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);
		}
		else if ((dotp_ori > 0.0 && dotp_mea < 0.0) ||
			 (dotp_ori < 0.0 && dotp_mea > 0.0))
		{
			me->brk_pos = BRK_CENTER;
			if (place_attr->aut_cent)
			{
				/*| Auto Center ON */
				me->brk_dist = 0.5;
				for (i=0; i<3; i++)
				{
					break_pt[i] = ( term_ori[i] +
							term_mea[i] ) / 2.0;
				}
			}
			else
			{
				me->brk_dist =
					BSlenvec(&bsrc, orig_brak) /
					BSlenvec(&bsrc, orig_meas);
				/*"me->brk_dist = %f\n", me->brk_dist*/
			}
		}
		else
		{
			me->brk_pos = BRK_LEFT;
			me->brk_dist = BSlenvec(&bsrc, orig_brak) /
			 BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);
		}

		/*"brk_pos=%d\n", me->brk_pos*/
	}
	else
	{
		status =
		om$send(msg = message DMlinear.compute_break_pt(
						&rc,
						term_ori,
						term_mea,
						&place_attr->dimn_value,
						orig_meas,
						break_pt,
						&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (control & MOVE_TRAK_PT)
	{
		/*| - Set Projection Lines - */

		for (index=0; index<2; index++)
		{
			projline = (index==0)?proj_ori:proj_mea;
			if (place_attr->proj_grid[index].objid != NULL_OBJID)
			{
				status =
				om$send(msg = message DMroot.position_line(
							&rc,
							DIM_NO_INDEX,
							&place_attr->proj_grid[index],
							md_env,
							projline),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}
	}
    } /* independent dimension */

	if (me->leader)
	{
		status =
		om$send(msg = message DMlinear.compute_lead_pt(
							&rc,
							break_pt,
							par_loc,
							plan_info,
							leader_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	MAaddvc(
		&bsrc,
		(me->leader)?leader_pt:break_pt,
		place_attr->def_offs,
		text_pt);

	if (control & MOVE_TEXT_POS)
	{
		for (index=0; index<3; index++)
		{
			xaxis[index] = place_attr->plan_info.act_plan.matrix[index];
			yaxis[index] = place_attr->plan_info.act_plan.matrix[index+4];
		}

		BSnorvec(&bsrc, xaxis);
		BSnorvec(&bsrc, yaxis);

		me->offs_pt[0] =
		xaxis[0] * (cursor[0] - text_pt[0]) +
		xaxis[1] * (cursor[1] - text_pt[1]) +
		xaxis[2] * (cursor[2] - text_pt[2]);

		me->offs_pt[0] = me->offs_pt[0]/
		BSlenvec(&bsrc, place_attr->plan_info.act_plan.vec_xpos);

		me->offs_pt[1] =
		yaxis[0] * (cursor[0] - text_pt[0]) +
		yaxis[1] * (cursor[1] - text_pt[1]) +
		yaxis[2] * (cursor[2] - text_pt[2]);

		me->offs_pt[1] = me->offs_pt[1]/
		BSlenvec(&bsrc, place_attr->plan_info.act_plan.vec_xpos);

		/*"offs_pt=(%lf, %lf)\n", me->offs_pt[0], me->offs_pt[1]*/

		math_v_equal(text_pt, cursor);
	}

	/*^
		print_point("break_pt", break_pt);
		print_point("text_pt", text_pt);
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);
	*/

	/* - Move text - */

	status =
	om$send(msg = message DMroot.position_text(
					&rc,
					TRUE,
					DIM_NO_INDEX,
					&place_attr->text_grid,
					md_env,
					-1,
					text_pt,
					NULL,
					NULL,
					par_loc,
					par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* - Set Dimension Line(s) - */

	BSnorvec(&bsrc, orig_meas);

	status =
	om$send(msg = message DMlinear.make_dim_line(
					&rc,
					term_ori,
					term_mea,
					orig_meas,
					break_pt,
					leader_pt,
					par_env,
					par_loc,
					plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* - Move Terminators - */

	for (index=0; index<2; index++)
	{
		ter_pt = (index == 0)?term_ori:term_mea;
		if (place_attr->ter_grid[index].objid != NULL_OBJID)
		{
			status =
			om$send(msg = message DMroot.position_text(
							&rc,
							FALSE,
							DIM_NO_INDEX,
							&place_attr->ter_grid[index],
							md_env,
							-1,
							ter_pt,
							NULL,
							NULL,
							par_loc,
							par_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	if (!(control & MOVE_TRAK_PT)) return(OM_S_SUCCESS);

	/*| - Compute other children in stack */

	*level += 1;

	if (place_attr->next[0].objid != NULL_OBJID)
	{
		status =
		om$send(msg = OPPmargs,
			targetid = place_attr->next[0].objid,
			targetos = place_attr->next[0].osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method fill_info(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;

	IGRint count;
	struct GRid list[MAX_LINEAR_ROOTS];
	struct DMdyn_linear *place_attr;

	IGRint   go_index[5], i;
	struct GRid go_grid[5];
	IGRdouble orig_meas[3];
	IGRdouble proj_angl;
	IGRdouble trak_dist, offs_ratio;
	IGRdouble proj_offs, proj_extn, dist;
	BSrc	bsrc;

	place_attr = (struct DMdyn_linear *)info + (*level);

	/*"level=%d, place_attr=%x, info=%x\n", *level, place_attr, info*/

	/*| - Get List of Parents - */

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|Gather Data for this dimension*/

	status =
	om$send(msg = message DMlinear.gather_data(
					&rc,
					count,
					list,
					place_attr->orig_P,
					place_attr->meas_P,
					place_attr->cpx_orig_P,
					&trak_dist,
					&place_attr->plan_info,
					&place_attr->par_env,
					&place_attr->par_loc,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	place_attr->trak_dist_prev = trak_dist - me->trak_dist;

	if (control & MOVE_TRAK_PT)
	{
		/*|Compute minimum trak point position*/

		place_attr->trak_dist =
			place_attr->trak_dist_prev +
			(place_attr->par_env.lin_offs_r *
			place_attr->par_env.txt_heig)/
			BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);
	}
	else	place_attr->trak_dist = trak_dist;

	/*^
		printf("trak_dist=%lf\n", trak_dist);
		printf("prev_trak_dist=%lf\n", place_attr->trak_dist_prev);
	*/

	/*| - Get measurement and perpendicular axes - */

	DMget_axis_info(
		&place_attr->plan_info,
		place_attr->norm_to_plane,
		place_attr->pt_on_plane,
		place_attr->mea_axis,
		place_attr->perp_axis,
		me->mea_trak,
		place_attr->trak_vec);

	/*| - Get text orientation - */

	DMget_text_info(
		&place_attr->par_loc,
		&place_attr->plan_info,
		me->mea_trak,
		me->leader,
		place_attr->text_dir,
		place_attr->offs_dir,
		&place_attr->just_pos,
		&place_attr->just_neg);

	/*| - Compute text offset - */

	if (!me->leader)
	{
		if (place_attr->par_loc.txt_orie == TXT_ORIE_HORIZONTAL
		||  place_attr->par_loc.txt_orie == TXT_ORIE_VERTICAL)

			place_attr->par_loc.txt_posn = TXT_POSN_EMBEDDED;
	}

	if (place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
	{
		place_attr->txt_yoff =
			place_attr->par_env.txt_yoff_r *
			place_attr->par_env.txt_heig;

		MAscalvc(&bsrc,
			 &place_attr->txt_yoff,
			 place_attr->offs_dir,
			 place_attr->def_offs);
	}
	else
	{
		place_attr->def_offs[0] =
		place_attr->def_offs[1] =
		place_attr->def_offs[2] = 0.0;
	}

	/* - Compute Trak Point, Break Point etc. - */

	MATH_ptdelta(
		&rc,
		place_attr->cpx_orig_P,
		place_attr->trak_vec,
		place_attr->trak_dist,
		place_attr->trak_pt);

	/*^
		printf("trak_dist=%lf\n", place_attr->trak_dist);
		print_point("trak_pt", place_attr->trak_pt);
	*/

	/* - Compute

		- dimension line
		- terminator positions
		- projection lines
	*/

	/*| Dimension Line */

	DMlineptvec(
		place_attr->trak_pt,
		place_attr->mea_axis,
		place_attr->dim_line);

	/*| Projection vector and terminator positions */

	proj_angl = (90 - place_attr->par_env.proj_angl) * PI / 180.0;

	MATH_rotate_vector(
		&rc,
		place_attr->mea_axis,
		proj_angl,
		place_attr->plan_info.win_plan.matrix,
		place_attr->proj_vec);

	BSnorvec(&bsrc, place_attr->proj_vec);

	math_v_opposite(place_attr->proj_neg, place_attr->proj_vec);

	MATH_proj_along_vector(
		&rc,
		place_attr->orig_P,
		place_attr->proj_vec,
		place_attr->dim_line,
		place_attr->term_ori);

	MATH_proj_along_vector(
		&rc,
		place_attr->meas_P,
		place_attr->proj_vec,
		place_attr->dim_line,
		place_attr->term_mea);

	/*| Projection Lines */

	if (me->dim_type == CIRCULAR_DIAMETER)
	{
		dist =
		BSdistptpt(&bsrc,place_attr->orig_P,place_attr->meas_P);

		offs_ratio =
		sqrt((place_attr->par_env.proj_offs_r * dist * 0.5) /
			place_attr->par_env.txt_heig);

		place_attr->proj_offs =
		offs_ratio * place_attr->par_env.txt_heig;
	}
	else
	{
		place_attr->proj_offs = 
			place_attr->par_env.proj_offs_r *
			place_attr->par_env.txt_heig;
	}
	place_attr->proj_extn = place_attr->par_env.proj_extn_r *
				place_attr->par_env.txt_heig;

	dist = BSdistptpt(&bsrc, place_attr->orig_P, place_attr->term_ori);

	if(me->prj_offs[0] <= dist)
	{
		proj_offs = me->prj_offs[0] + place_attr->proj_offs;
		proj_extn = place_attr->proj_extn;
	}
	else
	{
		proj_offs = me->prj_offs[0] - place_attr->proj_offs;
		proj_extn = -place_attr->proj_extn;
	}

	BSmkvec(&bsrc, place_attr->orig_vec, place_attr->orig_P, place_attr->term_ori);
	BSnorvec(&bsrc, place_attr->orig_vec);

	BSmkvec(&bsrc, place_attr->meas_vec, place_attr->meas_P, place_attr->term_mea);
	BSnorvec(&bsrc, place_attr->meas_vec);

	DMmake_proj_line(
		&rc,
		place_attr->orig_P,
		place_attr->term_ori,
		proj_offs,
		proj_extn,
		place_attr->proj_ori);

	dist = BSdistptpt(&bsrc, place_attr->meas_P, place_attr->term_mea);

	if(me->prj_offs[1] <= dist)
	{
		proj_offs = me->prj_offs[1] + place_attr->proj_offs;
		proj_extn = place_attr->proj_extn;
	}
	else
	{
		proj_offs = me->prj_offs[1] - place_attr->proj_offs;
		proj_extn = -place_attr->proj_extn;
	}

	DMmake_proj_line(
		&rc,
		place_attr->meas_P,
		place_attr->term_mea,
		proj_offs,
		proj_extn,
		place_attr->proj_mea);

	if (control & MOVE_LEADER_PT)
	{
		/*| Leader On - Compute Break Point */

		status =
		om$send(msg = message DMlinear.compute_break_pt(
						&rc,
						place_attr->term_ori,
						place_attr->term_mea,
						&place_attr->dimn_value,
						orig_meas,
						place_attr->break_pt,
						&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*^ print_point("break_pt", place_attr->break_pt); */

		DMlineptvec(
			place_attr->break_pt,
			place_attr->text_dir,
			place_attr->lea_line);
	}

	go_index[0] = DIM_TEXT;
	go_index[1] = DIM_ORI_TERM;
	go_index[2] = DIM_MEA_TERM;
	go_index[3] = DIM_ORI_PROJ;
	go_index[4] = DIM_MEA_PROJ;

	for (i=0; i<5; i++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						go_index[i],
						FALSE,
						NULL,
						md_env,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	place_attr->text_grid = go_grid[0];
	place_attr->ter_grid[0] = go_grid[1];
	place_attr->ter_grid[1] = go_grid[2];
	place_attr->proj_grid[0] = go_grid[3];
	place_attr->proj_grid[1] = go_grid[4];

	place_attr->first_in_cpx = TRUE;
	place_attr->next[0].objid =
	place_attr->next[1].objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

end implementation DMlinear;
