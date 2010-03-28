class implementation DMradjog;

#define AS_DEBUG 1

#include "bsvalues.h"
#include "dimtxt.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"

extern double fabs();

from GRtext import GRgettxattr;

method make_dim_text(
	IGRint *msg;
	IGRint num_jog_pts;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble dimn_value;
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	IGRdouble *jog_line;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env)
{
	IGRint status, rc, indx;
	IGRdouble text_pt[3], brk_pt[3];
	IGRdouble dotp, brak_line[3];
	IGRdouble norm_to_plane[3];
	IGRdouble mea_axis[3];
	IGRdouble perp_axis[3];
	IGRdouble angle;
	IGRdouble text_dir[3];
	IGRdouble offs_dir[3];
	IGRshort  txt_just;
	BSrc	bsrc;

	*msg = MSSUCC;

	for( indx=0; indx < 3; indx ++)
		norm_to_plane[indx] = plan_info->act_plan.matrix[ indx + 8];

	if ((me->jogged) && (num_jog_pts == 2))
	{
		BSmkvec(&bsrc, mea_axis, jog_line, &jog_line[3]);
	}
	else if ((me->jogged)
	      && (num_jog_pts == 3)
	      && (me->brk_pos == BRK_ALT_CENTER))
	{
		BSmkvec(&bsrc, mea_axis, &jog_line[3], &jog_line[6]);
	}
	else 	BSmkvec(&bsrc, mea_axis, center, term_pt);

	BSnorvec(&bsrc, mea_axis);

	angle = M_PI/2;

	MATH_rotate_vector(
		&rc,
		mea_axis,
		angle,
		plan_info->act_plan.matrix,
		perp_axis);
	/*^
		print_point(" break_pt : ", break_pt);
		print_point(" center : ",center);
		print_point(" mea_axis : ",mea_axis);
		print_point(" perp_axis : ",perp_axis);
	*/

	if (me->jogged)
	{
		if ((par_loc->txt_posn == TXT_POSN_ABOVE)
		&&  (par_loc->txt_orie == TXT_ORIE_PARALLEL))
			txt_just = CENTER_BOTTOM;
		else	txt_just = CENTER_CENTER;

		if (num_jog_pts == 2)
		{
			for (indx=0; indx<3; indx++)
			    brk_pt[indx] = jog_line[indx+3];
		}
		else
		{
			math_v_equal(brk_pt, break_pt);
		}
	}
	else if (me->leader)
	{
		BSmkvec(&bsrc, brak_line, break_pt, leader_pt);
		BSnorvec(&bsrc, brak_line);
		if(BSdotp(&bsrc, brak_line,
			plan_info->win_plan.vec_xpos) >= 0)
		{
			if(par_loc->txt_posn == TXT_POSN_EMBEDDED)
				txt_just = LEFT_CENTER;
			else	txt_just = LEFT_BASE;
		}
		else
		{
			if(par_loc->txt_posn == TXT_POSN_EMBEDDED)
				txt_just = RIGHT_CENTER;
			else	txt_just = RIGHT_BASE;
		}

		math_v_equal(brk_pt, leader_pt);
	}
	else
	{
		math_v_equal(brk_pt, break_pt);

		if (par_loc->txt_posn == TXT_POSN_ABOVE)
		{
		 	if (par_loc->txt_orie == TXT_ORIE_PARALLEL)
				txt_just = CENTER_BOTTOM;
			else if (par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)
				txt_just = LEFT_CENTER;
			else	txt_just = CENTER_CENTER;
		}
		else	txt_just = CENTER_CENTER;
	}

	switch (par_loc->txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:

		math_v_equal(text_dir, plan_info->win_plan.vec_xpos);
		math_v_equal(offs_dir, plan_info->win_plan.vec_ypos);

		break;

		case TXT_ORIE_VERTICAL:

		math_v_equal(text_dir, plan_info->win_plan.vec_ypos);
		math_v_equal(offs_dir, plan_info->win_plan.vec_xneg);

		break;

		case TXT_ORIE_PARALLEL:

		dotp = BSdotp(&bsrc, plan_info->win_plan.vec_xpos, mea_axis);
		if(dotp > 0.0)
		{
			math_v_equal(text_dir, mea_axis);
			math_v_equal(offs_dir, perp_axis);
		}
		else
		{
			for(indx=0; indx<3; indx++)
			{
			   text_dir[indx] = -mea_axis[indx];
			   offs_dir[indx] = -perp_axis[indx];
			}
		}

		break;

		case TXT_ORIE_PERPENDICULAR:

		dotp = BSdotp(&bsrc, plan_info->win_plan.vec_ypos, mea_axis);
		if(dotp > 0.0)
		{
			for(indx=0; indx<3; indx++)
			{
			   text_dir[indx] = -perp_axis[indx];
			   offs_dir[indx] = mea_axis[indx];
			}
		}
		else
		{
			for(indx = 0; indx<3; indx++)
			{
			   text_dir[indx] = perp_axis[indx];
			   offs_dir[indx] = -mea_axis[indx];
			}
		}
		break;

		default:

		/*"ERROR: txt_orie=%d\n", par_loc->txt_orie*/
		return(FALSE);
	}

	if ((par_loc->txt_posn == TXT_POSN_ABOVE) &&
	    (( par_loc->txt_orie == TXT_ORIE_PARALLEL) ||
	    ( me->leader)))
	{
		/*| txt_posn above */
		for (indx=0; indx<3; indx++)
		    text_pt[indx] =
		    brk_pt[indx] +
		    (offs_dir[indx] * par_env->txt_yoff_r * par_env->txt_heig);
	}
	else
	{
		math_v_equal(text_pt, brk_pt);
	}

	/* - Add the offs_pt to text_pt - */

	for (indx=0; indx<3; indx++)
	{
		text_pt[indx] +=
			me->offs_pt[0] * plan_info->act_plan.matrix[indx] +
			me->offs_pt[1] * plan_info->act_plan.matrix[indx + 4];
	}

	/*^
		print_point(" text_dir : ", text_dir);
		print_point(" text_pt : ", text_pt);
	*/

	status =
	om$send(msg = message DMroot.position_text(
					msg,
					TRUE,
					DIM_TEXT,
					NULL,
					md_env,
					txt_just,
					text_pt,
					text_dir,
					norm_to_plane,
					par_loc,
					par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
method make_dim_term(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble radline[3];
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, i, dsp_flag, go_index;
	IGRdouble norm[3], pri_orie[3], sec_orie[3];
	IGRdouble *origin, *orientation;
	IGRshort pri_just, sec_just, justification, sec_term;
	struct GRid term_grid;
	extern struct DMglobal DM_global;

	norm[0] = plan_info->win_plan.matrix[8];
	norm[1] = plan_info->win_plan.matrix[9];
	norm[2] = plan_info->win_plan.matrix[10];

	sec_term = FALSE;
	if(me->dim_type == RADIAL_DIAMETER)
		sec_term = TRUE;

	/*| - Set Terminator direction */

	switch (me->brk_pos)
	{
		case BRK_LEFT:
		case BRK_CENTER:
		case BRK_ALT_CENTER:

		/*| brk CENTER/LEFT */

		if (me->ter_loca == TER_LOCA_INTERNAL)
		{
			/*| SAME_SIDE : terminator inside */
			for (i=0; i<3; i++)
			{
				pri_orie[i] = radline[i];
				sec_orie[i] = -radline[i];
			}
		}
		else
		{
			/*| SAME_SIDE : terminator outside */
			for (i=0; i<3; i++)
			{
				pri_orie[i] = -radline[i];
				sec_orie[i] = radline[i];
			}
		}
		break;

		case BRK_RIGHT:

		/*| brk RIGHT */

		if (me->ter_loca == TER_LOCA_INTERNAL)
		{
			/*| OPPOSITE_SIDE : terminator inside*/
			for (i=0; i<3; i++)
			{
				pri_orie[i] = -radline[i];
				sec_orie[i] = radline[i];
			}
		}
		else
		{
			/*| OPPOSITE_SIDE : terminator outside */
			for (i=0; i<3; i++)
			{
				pri_orie[i] = radline[i];
				sec_orie[i] = -radline[i];
			}
		}
		break;

		default:

		/*"ERROR: brk_pos=%d\n", me->brk_pos*/
		return(FALSE);
	}

	pri_just = DM_global.term_info[par_env->ter_type0].center_just?
				CENTER_CENTER:
				RIGHT_CENTER;

	sec_just = DM_global.term_info[par_env->ter_type].center_just?
				CENTER_CENTER:
				RIGHT_CENTER;

	for (i=0; i<2; i++)
	{
		if (i == 0)
		{
			/*| GO : DIM_ORI_TERM */
			orientation = pri_orie;
			justification = pri_just;
			origin = term_pt;
			dsp_flag = (par_loc->ter_disp & TER_DISP_ORI);
			go_index = DIM_ORI_TERM;
		}
		else
		{
			/*| GO : DIM_MEA_TERM */
			orientation = sec_orie;
			justification = sec_just;
			origin = center;
			dsp_flag = (par_loc->ter_disp & TER_DISP_MEA);
			go_index = DIM_MEA_TERM;
			if(sec_term)
			{
				if((par_loc->lin_disp == LIN_DISP_OFF) &&
					(me->brk_pos == BRK_RIGHT) &&
					(me->ter_loca == TER_LOCA_INTERNAL))
				{
					dsp_flag = FALSE;
					/*| sec term false -- lin disp off*/
				}
			}
			else
			{
				dsp_flag = FALSE;
				/*| sec term false -- radial dim */
			}
		}

		if (dsp_flag)
		{
			/*| set terminator go */

			status =
			om$send(msg = message DMroot.set_ter_type(
							msg,
							go_index,
							&term_grid,
							md_env,
							par_env,
							par_loc),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMroot.position_text(
							msg,
							FALSE,
							go_index,
							&term_grid,
							md_env,
							justification,
							origin,
							orientation,
							norm,
							par_loc,
							par_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*| Delete terminator go */
			status =
			om$send(msg = message DMroot.delete_dim_go(
							msg,
							go_index,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

end implementation DMradjog;
