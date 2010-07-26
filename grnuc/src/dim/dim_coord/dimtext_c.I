class implementation DMcoordj;

#define AS_DEBUG 1

#include "dimtxt.h"
#include "mascalvc.h"
#include "bsmkvec.h"

method make_dim_text(
	IGRint *msg;
	IGRdouble meas_pt[3];
	IGRdouble txt_pt[3];
	IGRdouble dimn_value;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env)
{
	IGRshort txt_just;
	IGRint status, rc, indx;
	IGRdouble def_offs[3], text_pt[3];
	IGRdouble text_dir[3], offs_dir[3];
	IGRdouble txt_yoff;
	IGRdouble norm[3];
	IGRdouble proj_vec[3];
	BSrc	bsrc;

	*msg = MSSUCC;

	txt_yoff = par_env->txt_yoff_r * par_env->txt_heig;

	BSmkvec(&bsrc, proj_vec, meas_pt, txt_pt);

	DMget_coord_text_info(
		par_loc,
		plan_info,
		me->mea_trak,
		proj_vec,
		text_dir,
		offs_dir,
		&txt_just);

	/*^ print_point(" text_dir : ", text_dir); */

	if ((par_loc->ctxt_posn == TXT_POSN_ABOVE)
	&&  ((par_loc->txt_orie == TXT_ORIE_PARALLEL)
	||   (par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
		MAscalvc(&bsrc, &txt_yoff, offs_dir, def_offs);
	else	def_offs[0] = def_offs[1] = def_offs[2] = 0.0;

	for (indx=0; indx<3; indx++)
		text_pt[indx] = txt_pt[indx] + def_offs[indx];
	/*^
		print_point("txt_pt ",txt_pt);
		print_point("text_pt ",text_pt);
		print_point("def_offs ",def_offs);
	*/

	norm[0] = plan_info->win_plan.matrix[8];
	norm[1] = plan_info->win_plan.matrix[9];
	norm[2] = plan_info->win_plan.matrix[10];

	/*| Add offset to text */

	{
		IGRint index;
		IGRdouble *matrix;

		matrix = plan_info->act_plan.matrix;
		for (index=0; index<3; index++)
		{
			text_pt[index] +=
			me->offs_pt[0] * matrix[index] +
			me->offs_pt[1] * matrix[index + 4];
		}
	}

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
					norm,
					par_loc,
					par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method make_dim_term(
	IGRint *msg;
	IGRboolean dimline_valid;
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble dimline[3];
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, dsp_flag, go_index, del_index;
	IGRdouble norm[3], orig_orie[3], meas_orie[3];
	IGRdouble *orientation, *origin;
	IGRshort justification, first_in_cpx;
	struct GRid term_grid, prev_grid;
	extern struct DMglobal DM_global;

	if(par_loc->lin_disp == LIN_DISP_ON)
	{
		/*| dimension line on */

		norm[0] = plan_info->win_plan.matrix[8];
		norm[1] = plan_info->win_plan.matrix[9];
		norm[2] = plan_info->win_plan.matrix[10];

		status =
		om$send(msg = message DMroot.give_previous(&rc,
						&first_in_cpx,
						&prev_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);


		for (i=0; i<3; i++)
		{
			orig_orie[i] = -dimline[i];
			meas_orie[i] = dimline[i];
		}

		if(first_in_cpx)
		{
			/*| set orgin terminator type */

			par_env->ter_type0 = par_env->comm_origin;
			justification =
			DM_global.term_info[par_env->comm_origin].center_just?
							CENTER_CENTER:
							RIGHT_CENTER;
			orientation = orig_orie;
			origin = term_ori;
			dsp_flag = TER_DISP_ORI;
			go_index = DIM_ORI_TERM;
			del_index = DIM_MEA_TERM;
			dimline_valid = TRUE;
		}
		else
		{
			/*| set measure terminator type */

			justification  =
			DM_global.term_info[par_env->ter_type].center_just?
							CENTER_CENTER:
							RIGHT_CENTER;
			orientation = meas_orie;
			origin = term_mea;
			dsp_flag = TER_DISP_MEA;
			go_index = DIM_MEA_TERM;
			del_index = DIM_ORI_TERM;
		}

		if ((par_loc->ter_disp & dsp_flag)
		&& dimline_valid)
		{
			/*^ print_point(" origin ",origin); */

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
			/*| delete terminator */

			status =
			om$send(msg = message DMroot.delete_dim_go(
							msg,
							go_index,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message DMroot.delete_dim_go(
							msg,
							del_index,
							md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}
	else
 	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						msg,
						DIM_ORI_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
						msg,
						DIM_MEA_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}
}

end implementation DMcoordj;
