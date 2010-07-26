class implementation DMangular;

#define AS_DEBUG   1
#include "dimtxt.h"
#include "mascalvc.h"
#include "maaddvc.h"
#include "bsnorvec.h"
#include "bslenvec.h"
extern double sqrt();

from GRtext import GRgettxattr;

method make_dim_text( IGRlong *msg;
	struct angular_data_st *ang_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env)

{
	IGRlong status,rc;
	IGRint i;
	IGRshort txt_just;
	IGRdouble perp_vec[3];
	struct GRid text_grid;
	IGRdouble *place_pt, txt_orie_vec[3];
	IGRdouble def_offs[3],text_pt[3], *matrix;
	IGRdouble txt_yoff;

	*msg = MSSUCC;

	if (!me->leader)
	{
		if (p_loc->txt_orie == TXT_ORIE_HORIZONTAL
		||  p_loc->txt_orie == TXT_ORIE_VERTICAL)
			p_loc->txt_posn = TXT_POSN_EMBEDDED;
	}

	place_pt =( me->leader)? ang_info->leaderpt:ang_info->breakpt;

	/*^
		printf("txt_orie = %d\n",p_loc->txt_orie);
		print_point("xpos",plan_info->win_plan.vec_xpos);	
		print_point("ypos",plan_info->win_plan.vec_ypos);
	*/

	DMget_ang_txt_info(plan_info,p_loc,txt_orie_vec,
			   ang_info->norm_pl,
			   &txt_just,ang_info->breakpt,
			   ang_info->centerpt,me->leader,
			   me->lead_dist);

	/*"textjust:%d\n",txt_just*/
	/*^print_point(" txt_orie_vec",txt_orie_vec);*/

	if (p_loc->txt_posn == TXT_POSN_ABOVE)
	{
		vec_cross(ang_info->norm_pl,txt_orie_vec,perp_vec);
		BSnorvec(&rc,perp_vec);
		txt_yoff = p_env->txt_yoff_r * p_env->txt_heig;
		txt_yoff *= BSlenvec(&rc, txt_orie_vec);
		MAscalvc(&rc, &txt_yoff, perp_vec, def_offs);
	}
	else
	{
		def_offs[0] = def_offs[1] = def_offs[2] = 0.0;
	}

	MAaddvc(&rc, place_pt, def_offs, place_pt);

	/*| - Add offset to text - */

	matrix = plan_info->win_plan.matrix;
	for (i=0; i<3; i++)
	{
		text_pt[i] = place_pt[i]+
			me->offs_pt[0] * matrix[i] +
			me->offs_pt[1] * matrix[i + 4];
	}

	status =
	om$send(msg = message DMroot.position_text(
					( IGRint *)msg,
					TRUE,
					DIM_TEXT,
					NULL,
					md_env,
					txt_just,
					text_pt,
					txt_orie_vec,
					ang_info->norm_pl,
					p_loc,
					p_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.return_dim_go((IGRint *) &rc,
				DIM_TEXT,
				FALSE,
				-1,
				md_env,
				&text_grid),
		targetid = my_id);
	dm$status( action = RET_STATUS);
	DMget_txt_length(text_grid,&ang_info->min_length,
			 &ang_info->max_length,md_env,
			 plan_info);
	/* - reduce the text length by half text widt*/

	if(p_env->ang_unit != ANG_UNIT_RAD)
	{
		ang_info->max_length -= p_env->txt_widt;
	}

	return(OM_S_SUCCESS);
}

method make_dim_term(
	IGRlong *msg;
	struct angular_data_st *ang_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status,i;
	IGRint dsp_flag,go_index;
	IGRdouble *origin, *orientation;
	IGRdouble orig_term_start[3],meas_term_start[3];
	IGRshort orig_just,meas_just, justification;
	struct GRid term_grid;
	IGRint ter_dir0,ter_dir1;
	IGRlong		rc;
	
	extern struct DMglobal DM_global;
	extern struct DMglobal_param frm_glob;

	orig_just = DM_global.term_info[p_env->ter_type0].center_just?
					CENTER_CENTER:RIGHT_CENTER;

	meas_just = DM_global.term_info[p_env->ter_type].center_just?
					CENTER_CENTER:RIGHT_CENTER;

	if(me->mea_trak & CLOCK_WISE)
	{	
		ang_info->left_term_pt = ang_info->orig_term_pt;
		ang_info->right_term_pt= ang_info->meas_term_pt;
	}
	else
	{
		ang_info->left_term_pt = ang_info->meas_term_pt;
		ang_info->right_term_pt= ang_info->orig_term_pt;
	}

	ter_dir0 = CLOCK_DIR;
	ter_dir1 = ANTI_CLOCK_DIR;
	if(me->ter_loca == TER_LOCA_EXTERNAL)
	{
		ter_dir0 = ANTI_CLOCK_DIR;
		ter_dir1 = CLOCK_DIR;
	}

	/*^
		print_point("centerpt", ang_info->centerpt);
		print_point("left_term_pt", ang_info->left_term_pt);
		print_point("right_term_pt", ang_info->right_term_pt);
		printf("rad = %f, txt_widt = %f\n", ang_info->arc_rad, p_env->txt_widt);
	*/

        DMget_pt_at_angle( ang_info->centerpt,
                           ang_info->left_term_pt,
                           ang_info->arc_rad,
                           plan_info->win_plan.matrix,
                           orig_term_start,
                           p_env->txt_widt,
                           ter_dir0);

        DMget_pt_at_angle( ang_info->centerpt,
                           ang_info->right_term_pt,
                           ang_info->arc_rad,
                           plan_info->win_plan.matrix,
                           meas_term_start,
                           p_env->txt_widt,
                           ter_dir1);

	/*"orig_term_start:%lf|%lf|%lf\n",orig_term_start[0],orig_term_start[1], orig_term_start[2]*/
	/*"meas_term_start:%lf|%lf|%lf\n",meas_term_start[0],meas_term_start[1], meas_term_start[2]*/

	if(ang_info->left)
	{
		vec_sub(ang_info->left_term_pt,orig_term_start,
			ang_info->orig_term_orie);
		vec_sub(ang_info->right_term_pt,meas_term_start,
			ang_info->meas_term_orie);
	}
	else
	{
		vec_sub(ang_info->left_term_pt,orig_term_start,
			ang_info->meas_term_orie);
		vec_sub(ang_info->right_term_pt,meas_term_start,
			ang_info->orig_term_orie);
	}

	BSnorvec(&rc,ang_info->orig_term_orie);
	BSnorvec(&rc,ang_info->meas_term_orie);

	/*^
		print_point("orig_term_orie", ang_info->orig_term_orie);
		print_point("meas_term_orie", ang_info->meas_term_orie);
	*/

	/*| compute and post terminator information  */

	for (i=0; i<2; i++)
	{
		if (i == 0)
		{
			orientation = ang_info->orig_term_orie;
			justification = orig_just;
			origin = ang_info->orig_term_pt;
			dsp_flag = (p_loc->ter_disp & TER_DISP_ORI);
			go_index = DIM_ORI_TERM;

			if ((me->geom_type & DIM_DIRECTED)
			&& (frm_glob.dim_mode == MODELING_MODE))
				dsp_flag = FALSE;
		}
		else
		{
			orientation = ang_info->meas_term_orie;;
			justification = meas_just;
			origin = ang_info->meas_term_pt;
			dsp_flag = (p_loc->ter_disp & TER_DISP_MEA);
			go_index = DIM_MEA_TERM;
		}

		if (dsp_flag)
		{
			status =
			om$send(msg = message DMroot.set_ter_type(
							(IGRint *)msg,
							go_index,
							&term_grid,
							md_env,
							p_env,
							p_loc),
				targetid = my_id);

			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMroot.position_text(
							( IGRint *)msg,
							FALSE,
							go_index,
							&term_grid,
							md_env,
							justification,
							origin,
							orientation,
							ang_info->norm_pl,
							p_loc,
							p_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							(IGRint *)msg,
							go_index,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

end implementation DMangular;
