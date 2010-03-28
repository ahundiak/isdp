class implementation DMlinear;

#define AS_DEBUG 1

extern IGRdouble fabs();

#include "bsproj1.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

extern 	IGRboolean	BSproj0();

method compute_attr(
	IGRint *msg;
	IGRdouble axis_vec[3];
	IGRdouble trk_pt[3];
	IGRdouble brk_pt[3];
	IGRdouble lea_pt[3];
	IGRshort  txt_just;
	struct IGRlbsys *txt_geom;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid list[MAX_DIM_ROOTS];
	IGRint count;
	IGRpoint orig_P, meas_P, cpx_orig_P;
	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	IGRdouble trak_dist, dotp, dotp_ori, dotp_mea;
	IGRdouble dim_line[6];
	IGRpoint p1, p2, ptproj;
	IGRdouble *axis_dir, *perp_dir, trak_vec[3];
	IGRvector orig_meas, orig_brak, meas_brak, vec;
	IGRdouble txt_pt[3];
	IGRvector text_dir, offs_dir, norm;
	IGRshort  just_pos, just_neg, new_just;
	IGRboolean leader;
	BSrc	bsrc;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					0,
					MAX_DIM_ROOTS - 1,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| Compute Measurement Axis */

	if (me->dim_type == CIRCULAR_DIAMETER)
	{
		status =
		dm$get_plan_info(
			plan_objid = list[DIM_ROOT_PLAN].objid,
			osnum = list[DIM_ROOT_PLAN].osnum,
			md_env = md_env,
			plan_info = &plan_info);
		dm$status(action = RET_STATUS);

		dotp = fabs(BSdotp(&bsrc, axis_vec, plan_info.act_plan.vec_xpos));
		if (dotp > DOTP_LOWER_BOUND && dotp < DOTP_UPPER_BOUND)
			me->mea_trak = DM_MEA_AXIS;
		else	me->mea_trak = 0;
	}

	status =
	om$send(msg = message DMlinear.gather_data(
					(IGRint *) &rc,
					count,
					list,
					orig_P,
					meas_P,
					cpx_orig_P,
					&trak_dist,
					&plan_info,
					&par_env,
					&par_loc,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	trak_dist = trak_dist - me->trak_dist;

	/*"trak_dist_prev=%lf\n", trak_dist*/

	if (me->dim_type != CIRCULAR_DIAMETER)
	{
		dotp = fabs(BSdotp(&bsrc, axis_vec, plan_info.act_plan.vec_xpos));
		if (dotp > DOTP_LOWER_BOUND && dotp < DOTP_UPPER_BOUND)
			me->mea_trak = DM_MEA_AXIS;
		else	me->mea_trak = 0;
	}

	if (me->mea_trak & DM_MEA_AXIS)
	{
		axis_dir = plan_info.act_plan.vec_xpos;
		perp_dir = plan_info.act_plan.vec_ypos;
	}
	else
	{
		axis_dir = plan_info.act_plan.vec_ypos;
		perp_dir = plan_info.act_plan.vec_xpos;
	}

	/*"    dotp=%lf, mea_trak=%d\n", dotp, me->mea_trak*/

	/*| Compute Trak info */

	norm[0] = plan_info.win_plan.matrix[8];
	norm[1] = plan_info.win_plan.matrix[9];
	norm[2] = plan_info.win_plan.matrix[10];

	DMlineptvec(cpx_orig_P, axis_dir, dim_line);

	BSproj1(&bsrc,
		brk_pt,
		norm,
		cpx_orig_P,
		ptproj);
	math_v_equal(brk_pt, ptproj);

	BSproj1(&bsrc,
		lea_pt,
		norm,
		cpx_orig_P,
		ptproj);
	math_v_equal(lea_pt, ptproj);

	BSproj0(&bsrc, brk_pt, dim_line, ptproj);
	BSmkvec(&bsrc, trak_vec, ptproj, brk_pt);
	me->trak_dist = BSlenvec(&bsrc, trak_vec) - trak_dist;

	if (BSdotp(&bsrc, trak_vec, perp_dir) >= 0)
		me->mea_trak |= DM_TRAK_DIR;

	/*^
		print_point("cpx_orig_P", cpx_orig_P);
		print_point("brk_pt", brk_pt);
		print_point("lea_pt", lea_pt);
		print_point("axis_dir", axis_dir);
		print_point("ptproj", ptproj);
		print_point("trak_vec", trak_vec);
	*/

	/*"    trak_dist=%lf, mea_trak=%d\n", me->trak_dist, me->mea_trak*/

	/*| Compute Break info */

	DMlineptvec(brk_pt, axis_dir, dim_line);
	BSproj0(&bsrc, orig_P, dim_line, p1);
	BSproj0(&bsrc, meas_P, dim_line, p2);
	DMlineptpt(p1, p2, dim_line);
	BSmkvec(&bsrc, orig_meas, &dim_line[0], &dim_line[3]);
	BSmkvec(&bsrc, orig_brak, &dim_line[0], brk_pt);
	BSmkvec(&bsrc, meas_brak, &dim_line[3], brk_pt);

	dotp_ori = BSdotp(&bsrc, orig_meas, orig_brak);
	dotp_mea = BSdotp(&bsrc, orig_meas, meas_brak);

	if (dotp_ori > 0.0 && dotp_mea > 0.0)
	{
		me->brk_pos = BRK_RIGHT;
		me->brk_dist = BSlenvec(&bsrc, meas_brak);
	}
	else if ((dotp_ori > 0.0 && dotp_mea < 0.0) ||
		 (dotp_ori < 0.0 && dotp_mea > 0.0))
	{
		me->brk_pos = BRK_CENTER;
		me->brk_dist =	BSlenvec(&bsrc, orig_brak) /
				BSlenvec(&bsrc, orig_meas);
	}
	else
	{
		me->brk_pos = BRK_LEFT;
		me->brk_dist = BSlenvec(&bsrc, orig_brak);
	}

	/*"    brk_pos=%d, brk_dist=%lf\n", me->brk_pos, me->brk_dist*/

	/*| Compute Leader info */

	status =
	om$send(msg = message DMroot.leader_needed(
					(IGRint *) &rc,
					md_env,
					&leader),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	DMget_text_info(
		&par_loc,
		&plan_info,
		me->mea_trak,
		me->leader,
		text_dir,
		offs_dir,
		&just_pos,
		&just_neg);

	if (leader)
	{
		DMlineptvec(brk_pt, text_dir, dim_line);
		BSproj0(&bsrc, brk_pt, dim_line, p1);
		BSproj0(&bsrc, lea_pt, dim_line, p2);
		me->lead_dist = BSdistptpt(&bsrc, p1, p2);
		BSmkvec(&bsrc, vec, p1, p2);
		if (BSdotp(&bsrc, vec, text_dir) < 0)
		{
			me->lead_dist = -me->lead_dist;
			new_just = just_neg;
		}
		else	new_just = just_pos;
	}
	else	new_just = just_pos;

	/*"    leader=%d, lead_dist=%lf\n", me->leader, me->lead_dist*/


	DMget_just_pt(
		&rc,
		txt_just,
		txt_geom,
		new_just,
		txt_pt);

	status =
	om$send(msg = message DMdim.compute_offset(
					&rc,
					&par_env,
					&par_loc,
					&plan_info,
					offs_dir,
					(me->leader)?lea_pt:brk_pt,
					txt_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

end implementation DMlinear;
