class implementation DMcoordj;

#define AS_DEBUG 1

#include "bsnorvec.h"
#include "bsmkvec.h"

method make_proj_line(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble orig[3], meas[3];
	IGRdouble term_ori[3], term_mea[3];
	IGRdouble jog_line[12];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRint num_jog_pts, val;
	IGRint dsp_flag, pos_indx, del_indx;
	IGRshort  first_in_cpx;
	IGRdouble proj_offs, proj_extn;
	IGRdouble *origin, *origin_term;
	IGRdouble proj_vec[3], endpt[3];
	IGRdouble box[12], int_pt[3];
	struct GRid prev_grid;
	BSrc	bsrc;

	/*^
		print_point("orig", orig);
		print_point("meas", meas);
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);

		num_jog_pts = (me->jogged)?4:2;

		for (i=0; i<num_jog_pts; i++)
		{
		    printf("jog_pt[%d] = %f,%f,%f\n",
			i,jog_line[i*3],jog_line[i*3+1],jog_line[i*3+2]);
		}
	*/

	proj_offs = par_env->proj_offs_r * par_env->txt_heig;
	proj_extn = par_env->proj_extn_r * par_env->txt_heig;

	status =
	om$send(msg = message DMroot.give_previous(&rc,
					&first_in_cpx,
					&prev_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if ( first_in_cpx)
	{
		/*| first in cpx */

		pos_indx = DIM_ORI_PROJ;
		del_indx = DIM_MEA_PROJ;
		origin = orig;
		origin_term = (me->jogged)?&jog_line[9]:&jog_line[3];
		dsp_flag = PROJ_DISP_ORI;
	}
	else 
	{
		/*| NOT first in cpx */

		pos_indx = DIM_MEA_PROJ;
		del_indx = DIM_ORI_PROJ;
		origin = meas;
		origin_term = (me->jogged)?&jog_line[9]:&jog_line[3];
		dsp_flag = PROJ_DISP_MEA;
	}

	val = (me->jogged)?6:0;
	BSmkvec(&bsrc, proj_vec, &jog_line[val], &jog_line[3+val]);
	BSnorvec(&bsrc, proj_vec);

	MATH_ptdelta(&rc,
		origin,
		proj_vec,
		proj_offs +
		((first_in_cpx)?me->prj_offs[0]:me->prj_offs[1]),
		jog_line);

	if (me->jogged) origin = &jog_line[6];

	/*^
		print_point("origin", origin);
		print_point("origin_term", origin_term);
	*/

	status =
	om$send(msg = message DMdim.get_text_extents(
					&rc,
					box,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if ((par_loc->ctxt_posn == TXT_POSN_ABOVE)
	&&  ((par_loc->txt_orie == TXT_ORIE_PARALLEL)
	||   (par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)))
	{
		/*| Find the length of text */

		MATH_line_extend(
			&rc,
			origin,
			origin_term,
			box,
			int_pt);
	}
	else
	{
		MATH_ptdelta(&rc,
			origin_term,
			proj_vec,
			proj_extn,
			endpt);

		/*^ print_point("end_pt", endpt);*/

		MATH_line_break(
			&rc,
			origin,
			endpt,
			plan_info->win_plan.matrix,
			box,
			int_pt);
	}

	/*^ print_point("int_pt", int_pt); */

	if (me->jogged)
	{
		for (i=0; i<3; i++)
		   jog_line[i+9] = int_pt[i];
		
		num_jog_pts = 4;
	}
	else
	{
		for (i=0; i<3; i++)
		   jog_line[i+3] = int_pt[i];

		num_jog_pts = 2;
	}

	if (par_loc->proj_disp & dsp_flag)
	{
		/*^
			for (i=0; i<num_jog_pts; i++)
			{
			    printf("jog_pt[%d] = %f,%f,%f\n",
				i,jog_line[i*3],jog_line[i*3+1],jog_line[i*3+2]);
			}
		*/

		status =
		om$send(msg = message DMroot.position_line_string(
							&rc,
							pos_indx,
							(struct GRid *)NULL,
							md_env,
							num_jog_pts,
							jog_line),
			    targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
							&rc,
							del_indx,
							md_env),
				    targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						pos_indx,
						md_env),
			    targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
							&rc,
							del_indx,
							md_env),
				    targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method make_dim_line(
	IGRint *msg;
	IGRboolean dimline_valid;
	IGRdouble *term_ori, *term_mea;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRdouble line[6];

	if ((par_loc->lin_disp == LIN_DISP_ON)
	&&  (dimline_valid))
	{
		DMlineptpt(term_ori, term_mea, line);

		/*^ print_line("dim_line", line); */

		status =
		om$send(msg = message DMroot.position_line(
					msg,
					DIM_LINE1,
					(struct GRid *)NULL,
					md_env,
					line),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*| Delete dim_line */

		status =
		om$send(msg = message DMroot.delete_dim_go(
				msg,
				DIM_LINE1,
				md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation DMcoordj;

