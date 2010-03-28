/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: compute_c.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:06  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:22:06  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:35  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.5  1994/11/01  10:12:07  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.4  1993/12/17  13:46:46  samuel
# COMMENT : Fix for TR119313981-Computing immediately.
#
# Revision 240.3  1993/04/26  08:57:07  rishad
# COMMENT : Removed include file ms.h - Rishad
#
# Revision 240.2  1993/04/07  10:12:10  rishad
# COMMENT : Incorporated enhancements to placement interface.
#
# Revision 220.1  1992/10/16  19:25:27  poo
# COMMENT : Checking in 2.1 Fixes to 2.2 RCS
#
Revision 201.17  1992/09/08  11:03:58  poo
COMMENT : Fix for delete & Trak problems

Revision 201.15  1992/07/29  18:55:27  poo
COMMENT : Initial Release of Surface Finish & Jogged bug fixes

Revision 201.13  1992/07/19  16:13:39  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

*/

class implementation DMcoordj;

#define AS_DEBUG 1

#include "diminst.h"
#include "dimdyn.h"
#include "msdef.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"

extern IGRboolean 	BSproj0();

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint status, rc;
	struct dim_attr *dim_attr;
	struct GRid list[MAX_DIM_ROOTS];
	IGRint par_index;

	dim_attr = (struct dim_attr *)assoc_lis->as_attr;
	DMcopy_roots(list, assoc_lis->parents, assoc_lis->num_parents);

	if (assoc_lis->num_parents == NO_CPX_DIM_ROOTS - 1)
	{
		/*| First in cpx */

		par_index = DIM_CPX_ORIG;
	}
	else
	{
		/*| Insert into cpx */

		par_index = DIM_CPX_MEAS;
	}

	status =
	dm$create_root(
		type = DMkeypt,
		count = 1,
		list = &assoc_lis->parents[par_index],
		context = &assoc_lis->context[par_index],
		attr = (par_index == DIM_CPX_ORIG)?dim_attr->orig:dim_attr->meas,
		md_env = md_env,
		p_root = &list[par_index]);
	dm$status(action = RET_STATUS);

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
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint rel_pos;
	IGRboolean first_in_cpx;
	struct GRid first, dim_before, dim_after;
	struct GRid list_c[MAX_DIM_ROOTS], null_grid;

	null_grid.objid = NULL_OBJID;

	DMcopy_roots(list_c, list, count);

	first_in_cpx = (count == NO_CPX_DIM_ROOTS-1);

	if (!first_in_cpx)
	{
		/*|Find position in complex*/

		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
			targetid = list_c[DIM_CPX_ORIG].objid,
			targetos = list_c[DIM_CPX_ORIG].osnum);
		dm$status(action = RET_STATUS);

		dim_before.objid = NULL_OBJID;
		dim_after.objid  = NULL_OBJID;

		status =
		om$send(msg = message DMroot.find_position_in_cpx(
						&rc,
						COORDINATE_CPX,
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

	me->jogged = FALSE;

	if (first_in_cpx)
	{
	   me->mea_trak |= DM_TRAK_ZONE1 | DM_TRAK_CTRL_DIM;
	   me->mea_trak &= ~DM_TRAK_LOCK;
	   
	}
	else
	{
		/*|Insert into complex*/

		if (me->mea_trak & DM_TRAK_LOCK) me->trak_dist = 0.0;

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
	IGRint  cn_type;
	int     count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	/******************* LOCAL PARAMETERS *************************/

	IGRint status, rc, i, num_jog_pts;
	IGRchar mea_trak;
	IGRboolean dimline_valid;

	struct DMplan_info	plan_info;
	struct DMenv_param	par_env;
	struct DMloc_param	par_loc;

	IGRpoint cpx_orig_P; /* cpx_orig projection onto win_plan */
	IGRpoint orig_P;     /* dim_orig projection onto win_plan */
	IGRpoint meas_P;     /* dim_meas projection onto win_plan */
	IGRpoint term_ori;   /* origin terminator position */
	IGRpoint term_mea;   /* measure terminator postion */
	IGRpoint txt_pt;     /* text postion */

	IGRdouble orig_meas[3];
	IGRdouble dimn_value;
	IGRdouble trak_pt[3], trak_orig[3];
	IGRdouble trak_dist;
	IGRdouble jog_line[12];
	struct GRid parents[MAX_DIM_ROOTS];

	/**************************************************************/

	*msg = MSSUCC;

	/*| Fill the duplicate parents if necessary */

	for(i=0; i < count; i++)
	{
		parents[i].objid = list[i].objid;
		parents[i].osnum = list[i].osnum;
	}

	for(i=count; i<NO_CPX_DIM_ROOTS; i++)
	{
		parents[i].objid = list[0].objid;
		parents[i].osnum = list[0].osnum;
	}

	/*| - Gather Data - */

	status =
	om$send(msg = message DMcoordj.gather_data(
					&rc,
					count,
 					parents,
					md_env,
					orig_P,
					meas_P,
					cpx_orig_P,
					&plan_info,
					&par_env,
					&par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Gather trak info. - */

	mea_trak = me->mea_trak;

	status =
	om$send(msg = message DMcoordj.get_mea_trak_info(
					&rc,
					trak_orig,
					&mea_trak,
					&trak_dist,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!(me->mea_trak & DM_TRAK_CTRL_DIM))
	{
		/*- Copy the ctrl_dim mea_trak to myself.
		    Make sure trak lock bit & trak ctrl dim
		    bit are set correctly.
		*/

		mea_trak &= ~DM_TRAK_CTRL_DIM;

		if (me->mea_trak & DM_TRAK_LOCK)
			mea_trak |= DM_TRAK_LOCK;
		else	mea_trak &= ~DM_TRAK_LOCK;

		me->mea_trak = mea_trak;
	}

	if (rc != DIM_S_SUCCESS)
	{
		/*|- Dimension Trak Zone does not match*/

		if (me->dim_state & DIM_IN_PLACEMENT)
		{
			/*|- First Compute, trak_zone is yet to be initailised*/

			math_v_equal(trak_orig, meas_P);
			trak_dist = par_env.txt_heig * par_env.lin_offs_r;
		}
	}

	/*| - Calculate trak_pt absolute positions - */

	status =
	om$send(msg = message DMcoordj.compute_trak_pt(
					&rc,
					mea_trak,
					trak_orig,
					trak_dist,
					&plan_info,
					trak_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_point("trak_pt", trak_pt); */

	/*| - Compute Jog line */

	status =
	om$send(msg = message DMcoordj.compute_jog_line(
						&num_jog_pts,
						mea_trak,
						meas_P,
						trak_pt,
						jog_line,
						&plan_info,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Compute proj_line orientation and term positions - */

	status =
	om$send(msg = message DMcoordj.compute_proj_term(
						&rc,
						&dimline_valid,
						trak_pt,
						&par_env,
						&plan_info,
						md_env,
						orig_P,
						cpx_orig_P,
						meas_P,
						&dimn_value,
						txt_pt,
						orig_meas,
						term_ori,
						term_mea,
						jog_line),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);
	*/

	/*| - Dimension Text - */

	/*"count=%d\n", count*/

	status =
	om$send(msg = message DMdim.make_text_string(
					&rc,
					dimn_value,
					md_env,
					&par_env,
					&par_loc,
					NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMcoordj.make_dim_text(
					&rc,
					meas_P,
					txt_pt,
					dimn_value,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*| - Projection lines - */

	status =
	om$send(msg = message DMcoordj.make_proj_line(
					&rc,
					&par_env,
					&par_loc,
					&plan_info,
					orig_P,
					meas_P,
					term_ori,
					term_mea,
					jog_line,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Dimension Line - */

	status =
	om$send(msg = message DMcoordj.make_dim_line(
					&rc,
					dimline_valid,
					term_ori,
					term_mea,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*| - Terminators - */

	status =
	om$send(msg = message DMcoordj.make_dim_term(
					&rc,
					dimline_valid,
					term_ori,
					term_mea,
					orig_meas,
					&par_env,
					&par_loc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* - Set Symbology - */

	status =
	om$send(msg = message DMroot.chgdp(&rc, &par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->dim_state &= (~DIM_NEEDS_UPDATE);

	return(OM_S_SUCCESS);
}

method compute_trak_pt(
	IGRint *msg;
	IGRchar mea_trak;
	IGRdouble dim_orig[3];
	IGRdouble trak_dist;
	struct DMplan_info *plan_info;
	IGRdouble trak_pt[3])
{
	IGRint 	rc;
	IGRdouble *trak_vec;

	/*| - Compute Trak Dist - */

	if (mea_trak & DM_MEA_AXIS)
	{
		/*| trak_vec along y axis */

		trak_vec = (mea_trak & DM_TRAK_DIR)?
				plan_info->act_plan.vec_ypos:
				plan_info->act_plan.vec_yneg;
	}
	else
	{
		/*| trak_vec along x axis */

		trak_vec = (mea_trak & DM_TRAK_DIR)?
				plan_info->act_plan.vec_xpos:
				plan_info->act_plan.vec_xneg;
	}

	MATH_ptdelta(&rc, dim_orig, trak_vec, trak_dist, trak_pt);

	/*^
		printf("trak_dist %f\n", trak_dist);
		print_point("dim_orig", dim_orig);
		print_point("trak_vec", trak_vec);
		print_point("trak_pt", trak_pt);
	*/

	return(OM_S_SUCCESS);
}

method compute_proj_term(
	IGRint *msg;
	IGRboolean *dimline_valid;
	IGRdouble trak_pt[3];
	struct DMenv_param *par_env;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env;
	IGRdouble orig[3];
	IGRdouble cpx_orig[3];
	IGRdouble meas[3];
	IGRdouble *dimn_value, txt_pt[3];
	IGRdouble dimline_vec[3];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble jog_line[12])
{
	IGRint rc, status, prev_num_pts;
	IGRshort  first_in_cpx;
	IGRdouble dim_line[6], term_cpx[3];
	IGRdouble *mea_axis, *orig_P, *meas_P;
	IGRdouble proj_vec[3], text_vec[3], term_act[3];
	IGRdouble proj_angl, proj_extn, txt_offset;
	IGRdouble sca_fact, prev_jog_line[12];
	IGRvector v1, v2;
	IGRdouble newpt[3], p1[3], p2[3], p3[3], mea_line[6];
	struct GRid prev_grid, first;
	struct DMtrak_info trak_info;
	BSrc	bsrc;

	*dimline_valid = FALSE;

	status =
	om$send(msg = message DMroot.give_previous(
					&rc,
					&first_in_cpx,
					&prev_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	proj_extn = par_env->proj_extn_r * par_env->txt_heig;
	proj_angl = (90 - par_env->proj_angl) * PI / 180.0;

	mea_axis = ( me->mea_trak & DM_MEA_AXIS)?
			plan_info->act_plan.vec_xpos:
			plan_info->act_plan.vec_ypos;

	/*| - Construct line through trak_pt and parallel to dim axis - */

	DMlineptvec(trak_pt, mea_axis, dim_line);

	/*| - Projection Lines - */

	MATH_rotate_vector(
		&rc,
		mea_axis,
		proj_angl,
		plan_info->win_plan.matrix,
		proj_vec);

	/*| - Project orig and meas onto dim_line - */

	MATH_proj_along_vector(&rc, cpx_orig, proj_vec, dim_line, term_cpx);

	if (first_in_cpx)
	{
		*dimn_value = 0.0;

		orig_P = (me->jogged)?&jog_line[6]:orig;
		MATH_proj_along_vector(&rc, orig_P, proj_vec, dim_line, term_ori);
		BSmkvec(&bsrc, text_vec, orig_P, term_ori);
		BSnorvec(&bsrc, text_vec);
		MATH_ptdelta(&rc, term_ori, text_vec, proj_extn, txt_pt);
		math_v_equal(term_mea, term_ori);
		math_v_equal(dimline_vec, mea_axis);

		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMcoordj.compute_jog_line(
					&prev_num_pts,
					NULL,
					orig,
					NULL,
					prev_jog_line,
					plan_info,
					md_env),
		targetid = prev_grid.objid,
		targetos = prev_grid.osnum);
	dm$status(action = RET_STATUS);

	orig_P = (prev_num_pts > 2)?&prev_jog_line[6]:orig;
	meas_P = (me->jogged)?&jog_line[6]:meas;

	MATH_proj_along_vector(&rc, orig_P, proj_vec, dim_line, term_ori);
	MATH_proj_along_vector(&rc, meas_P, proj_vec, dim_line, term_mea);
	MATH_proj_along_vector(&rc, meas, proj_vec, dim_line, term_act);

	BSmkvec(&bsrc, dimline_vec, term_cpx, term_act);
	*dimn_value = BSlenvec(&bsrc, dimline_vec);
	BSnorvec(&bsrc, dimline_vec);
	sca_fact = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
	*dimn_value = *dimn_value / sca_fact;

	if (me->mea_trak & DM_TRAK_CTRL_DIM)
		txt_offset = proj_extn;
	else	txt_offset = proj_extn + me->trak_dist;

	BSmkvec(&bsrc, text_vec, meas_P, term_mea);
	BSnorvec(&bsrc, text_vec);
	MATH_ptdelta(&rc, term_mea, text_vec, txt_offset, txt_pt);

	/*|- Validate whether dimension line can be drawn*/

	status =
	om$send(msg = message DMroot.get_trak_info(&trak_info),
		targetid = prev_grid.objid,
		targetos = prev_grid.osnum);
	dm$status(action = RET_STATUS);

	if ((me->mea_trak & DM_TRAK_DIR) !=
	    (trak_info.mea_trak & DM_TRAK_DIR))
		return(OM_S_SUCCESS);

	status =
	om$send(msg = message DMroot.get_first_in_cpx(
					&rc,
					&first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_trak_info(&trak_info),
		targetid = first.objid,
		targetos = first.osnum);
	dm$status(action = RET_STATUS);

	if ((me->mea_trak & DM_TRAK_ZONE1) ==
	    (trak_info.mea_trak & DM_TRAK_ZONE1))
	{
		/*|- Dimension belongs to first trak zone*/

		if (me->trak_dist < 0.0)
			*dimline_valid = FALSE;
		else	*dimline_valid = TRUE;
	}
	else
	{
		/*|- Project the first trak pt*/

		status =
		om$send(msg = message DMcoordj.compute_trak_pt(
					&rc,
					trak_info.mea_trak,
					cpx_orig,
					trak_info.trak_dist,
					plan_info,
					newpt),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		DMlineptvec(meas, proj_vec, mea_line);

		MATH_ptdelta(
			&rc,
			txt_pt,
			text_vec,
			-proj_extn,
			p2);

		BSproj0(&bsrc, newpt, mea_line, p1);
		BSproj0(&bsrc, p2, mea_line, p3);

		/*^ print_point("pri_trak_pt", p1); */
		/*^ print_point("term_pt", p3); */

		BSmkvec(&bsrc, v1, meas, p1);
		BSmkvec(&bsrc, v2, meas, p3);

		if (BSdotp(&bsrc, v1, v2) > 0.0)
		{
			if ((BSlenvec(&bsrc, v2)) >
				(BSlenvec(&bsrc, v1)))
			{
				*dimline_valid = TRUE;
				DMlineptvec(newpt, mea_axis, dim_line);

				MATH_proj_along_vector(
						&rc,
						orig_P,
						proj_vec,
						dim_line,
						term_ori);

				MATH_proj_along_vector(
						&rc,
						meas_P,
						proj_vec,
						dim_line,
						term_mea);
			}
		}
	}

	/*^
		print_point("orig", orig);
		print_point("meas", meas);
		print_point("trak_pt", trak_pt);
		print_point("text_vec", text_vec);
		print_line("dim_line", dim_line);
		print_point("term_ori", term_ori);
		print_point("term_mea", term_mea);
		print_point("txt_pt", txt_pt);
		printf("dimension value = %lf\n", *dimn_value);
		printf("trak_dist = %lf\n", me->trak_dist);
		printf("dimline_valid = %d\n", *dimline_valid);
	*/

	return(OM_S_SUCCESS);
}

method get_parent_info(
	IGRboolean   *orig_needed;
	IGRboolean   *meas_needed)
{
	IGRint status, rc;
	struct GRid prev;
	IGRboolean first_in_cpx;

	status =
	om$send(msg = message DMroot.give_previous(&rc,
					&first_in_cpx,
					&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*orig_needed = TRUE;
	*meas_needed = (first_in_cpx)?FALSE:TRUE;

	return(OM_S_SUCCESS);
}

method change_dimension_origin(
	IGRint *msg;
	struct GRid new_orig;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;
	IGRint cn_type;
	extern IGRboolean ASbroadcast_in_progress;

	/* - IMPORTANT - CHECK TO SEE IF NEW OBJECT TYPE IS VALID - */

	status =
	om$send(msg = message DMroot.change_parent(
					&rc,
					DIM_CPX_ORIG,
					new_orig,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!ASbroadcast_in_progress)
	{
		cn_type = ND_COMP;
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &my_grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_dimension_measurement(
	IGRint *msg;
	struct GRid new_meas;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;
	IGRint cn_type;
	extern IGRboolean ASbroadcast_in_progress;

	/* - IMPORTANT - CHECK TO SEE IF NEW OBJECT TYPE IS VALID - */

	status =
	om$send(msg = message DMroot.change_parent(
					&rc,
					DIM_CPX_MEAS,
					new_meas,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!ASbroadcast_in_progress)
	{
		cn_type = ND_COMP;
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &my_grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method give_rel_pos(
	IGRint *msg;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos)
{
	IGRint status, rc;
	IGRlong long_rc, bsrc;
	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	IGRdouble *mea_axis;
	IGRdouble dimline[6];
	IGRdouble dim_orig[3];
	IGRdouble dim_meas[3];
	IGRdouble cpx_orig[3];
	IGRdouble orig_meas[3];
	IGRdouble orig_new[3];
	IGRdouble dist1, dist2;
	IGRint count;
	struct GRid list[NO_CPX_DIM_ROOTS];
	struct ret_struct retst;
	IGRdouble *newpt;
	IGRdouble dim_orig_D[3];
	IGRdouble dim_meas_D[3];
	IGRdouble newpt_D[3];

	*msg = DIM_S_SUCCESS;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMcoordj.gather_data(
					&rc,
					count,
					list,
					md_env,
					dim_orig,
					dim_meas,
					cpx_orig,
					&plan_info,
					&par_env,
					&par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	status =
	DMnode_give_structure(
		&long_rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(new_dim.objid == NULL_OBJID)?FALSE:TRUE,
		new_meas.objid,
		new_dim.objid,
		new_meas.osnum,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	newpt = retst.var.point_st.pt;

	/*^
		print_point("orig", dim_orig);
		print_point("meas", dim_meas);
		print_point("cpx_orig", cpx_orig);
		print_point("newpt", newpt);
	*/

	mea_axis = (me->mea_trak & DM_MEA_AXIS)?
			plan_info.act_plan.vec_xpos:
			plan_info.act_plan.vec_ypos;

	DMlineptvec(cpx_orig, mea_axis, dimline);

	/*^
		print_point("mea_axis", mea_axis);
		print_line("dimline", dimline);
	*/

	BSproj0(&bsrc, dim_orig, dimline, dim_orig_D);
	BSproj0(&bsrc, dim_meas, dimline, dim_meas_D);
	BSproj0(&bsrc, newpt, dimline, newpt_D);

	/*^
		print_point("dim_orig_D", dim_orig_D);
		print_point("dim_meas_D", dim_meas_D);
		print_point("newpt_D", newpt_D);
	*/

	BSmkvec(&bsrc, orig_meas, dim_orig_D, dim_meas_D);
	BSmkvec(&bsrc, orig_new,  dim_orig_D, newpt_D);

	dist1 = BSlenvec(&bsrc, orig_meas);
	dist2 = BSlenvec(&bsrc, orig_new);

	if (count < NO_CPX_DIM_ROOTS)
	{
		/*| First in complex */

		/*
			if (BSdotp(&bsrc, orig_new, mea_axis) < 0.0)
				*rel_pos = CPX_OPPOSITE_FAR;
			else
		*/

		*rel_pos = CPX_FAR;
		return(OM_S_SUCCESS);
	}

	if (BSdotp(&bsrc, orig_meas, orig_new) < 0.0)
	{
		if (dist1 < dist2)
			*rel_pos = CPX_OPPOSITE_FAR;
		else	*rel_pos = CPX_OPPOSITE_NEAR;
	}
	else
	{
		if (dist1 < dist2)
			*rel_pos = CPX_FAR;
		else	*rel_pos = CPX_NEAR;
	}

	/*^ printf(" rel_pos : %d\n", *rel_pos); */

	return(OM_S_SUCCESS);
}

method find_mea_trak_info(
	IGRint *msg;
	IGRboolean first_in_cpx;
	IGRboolean ctrl_dim;
	IGRchar mask;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	IGRdouble trak_orig[3];
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRboolean last_in_cpx, zone_matched;
	struct GRid next[2];
	struct ret_struct ret_st;

	*msg = FALSE;
	*trak_dist = 0.0;
	dim_grid->objid = NULL_OBJID;

	if (me->mea_trak & mask)
	{
		if (ctrl_dim)
		{
			if (me->mea_trak & DM_TRAK_CTRL_DIM)
				zone_matched = TRUE;
			else	zone_matched = FALSE;
		}
		else	zone_matched = TRUE;
	}
	else	zone_matched = FALSE;

	if (zone_matched)
	{
		/*|- Trak Zone matched */

		*mea_trak = me->mea_trak;
		*trak_dist = me->trak_dist;

		status =
		DMnode_give_structure(
			&rc,
			(first_in_cpx)?DIM_CPX_ORIG:DIM_CPX_MEAS,
			(first_in_cpx)?ORIG_INFO:MEAS_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&ret_st);
		dm$status(action = RET_STATUS);

		math_v_equal(trak_orig, ret_st.var.point_st.pt);

		dim_grid->objid = my_id;
		dim_grid->osnum = OM_Gw_current_OS;

		*msg = DIM_S_SUCCESS;
	}
	else
	{
		/*|- Send to next dimension*/

		status =
		om$send(msg = message DMroot.give_next(
						&rc,
						&last_in_cpx,
						next),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (!last_in_cpx)
		{
			for(i=0; i<2; i++)
			{
				if (next[i].objid == NULL_OBJID)
					continue;

				status =
				om$send(msg = message DMcoordj.find_mea_trak_info(
								msg,
								FALSE,
								ctrl_dim,
								mask,
								mea_trak,
								trak_dist,
								trak_orig,
								dim_grid,
								md_env),
					targetid = next[i].objid,
					targetos = next[i].osnum);
				dm$status(action = RET_STATUS);

				if (*msg == DIM_S_SUCCESS)
				   return(OM_S_SUCCESS);
			}
		}
	}

	return(OM_S_SUCCESS);
}

method get_cpx_origin(
	IGRdouble cpx_origin[3];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid first;
	struct ret_struct ret_st;

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (first.objid == my_id)
	{
		status =
		DMnode_give_structure(
			&rc,
			DIM_CPX_ORIG,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			first.objid,
			first.osnum,
			md_env,
			&ret_st);
		dm$status(action = RET_STATUS);

		math_v_equal(cpx_origin, ret_st.var.point_st.pt);
	}
	else
	{
		status =
		om$send(msg = OPPmargs,
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method get_mea_trak_info(
	IGRint *msg;
	IGRdouble trak_orig[3];
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRchar trak_zone;
	struct GRid first, dim_grid;

	trak_zone = (*mea_trak & DM_TRAK_ZONE1)?DM_TRAK_ZONE1:DM_TRAK_ZONE2;

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMcoordj.find_mea_trak_info(
						msg,
						TRUE,
						TRUE,
						trak_zone,
						mea_trak,
						trak_dist,
						trak_orig,
						&dim_grid,
						md_env),
		targetid = first.objid,
		targetos = first.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status, index;
	IGRpoint cpx_origin;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						msg,
						md_env,
						plan_info),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMcoordj.get_cpx_origin(
						cpx_origin,
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

method compute_jog_line(
	IGRint *num_jog_pts;
	IGRchar mea_trak;
	IGRdouble orig_pt[3];
	IGRdouble trak_pt[3];
	IGRdouble jog_line[12];
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRchar loc_trak;
	IGRdouble trak_dir[3], *mea_axis, *perp_axis, dimline[6];
	IGRdouble newpt[3], trk_pt[3], trak_orig[3];
	IGRdouble trak_dist;
	BSrc	bsrc;

	math_v_equal(jog_line, orig_pt);

	if (!trak_pt)
	{
		loc_trak = me->mea_trak;

		/*|- Find Trak info from control Dim*/
	
		status =
		om$send(msg = message DMcoordj.get_mea_trak_info(
						&rc,
						trak_orig,
						&loc_trak,
						&trak_dist,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		/*| - Calculate trak_pt absolute positions - */

		status =
		om$send(msg = message DMcoordj.compute_trak_pt(
						&rc,
						mea_trak,
						trak_orig,
						trak_dist,
						plan_info,
						trk_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		loc_trak = mea_trak;
		math_v_equal(trk_pt, trak_pt);
	}

	/*^ print_point("trak_pt", trk_pt); */

	if (loc_trak & DM_MEA_AXIS)
	{
		mea_axis = plan_info->act_plan.vec_xpos;
		perp_axis = plan_info->act_plan.vec_ypos;
	}
	else
	{
		mea_axis = plan_info->act_plan.vec_ypos;
		perp_axis = plan_info->act_plan.vec_xpos;
	}

	DMlineptvec(trk_pt, mea_axis, dimline);

	if (me->jogged)
	{
		/*|- Dimension is jogged*/

		MATH_ptdelta(&rc, orig_pt, perp_axis, me->brk_dist, &jog_line[3]);

		for (i=0; i<3; i++)
		    jog_line[i+6] = jog_line[i+3] +
		    (me->jog_pt[0] * plan_info->act_plan.matrix[i] +
		    me->jog_pt[1] * plan_info->act_plan.matrix[i+4]);

		BSproj0(&bsrc, &jog_line[6], dimline, newpt);
		BSmkvec(&bsrc, trak_dir, &jog_line[6], newpt);
		BSnorvec(&bsrc, trak_dir);
		
		if (me->mea_trak & DM_TRAK_CTRL_DIM)
		{
			for (i=0; i<3; i++)
			    jog_line[i+9] = newpt[i];
		}
		else
		{
			MATH_ptdelta(
				&rc,
				newpt,
				trak_dir,
				me->trak_dist,
				&jog_line[9]);
		}

		*num_jog_pts = 4;
	}
	else
	{
		/*|- Dimension is standard*/

		BSproj0(&bsrc, orig_pt, dimline, newpt);
		BSmkvec(&bsrc, trak_dir, orig_pt, newpt);
		BSnorvec(&bsrc, trak_dir);
		
		if (me->mea_trak & DM_TRAK_CTRL_DIM)
		{
			for (i=0; i<3; i++)
			    jog_line[i+3] = newpt[i];
		}
		else
		{
			MATH_ptdelta(
				&rc,
				newpt,
				trak_dir,
				me->trak_dist,
				&jog_line[3]);
		}

		*num_jog_pts = 2;
	}

	/*^
		for (i=0; i<*num_jog_pts; i++)
		{
		    printf("jog_pt[%d] = %f,%f,%f\n",
			i,jog_line[i*3],jog_line[i*3+1],jog_line[i*3+2]);
		}
	*/

	return(OM_S_SUCCESS);
}

method jog_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *jogged)
{
	*msg = DIM_S_SUCCESS;

	me->jogged = *jogged;
	return(OM_S_SUCCESS);
}

method jogged_off()
{
	me->jogged = FALSE;
	me->jog_pt[0] = me->jog_pt[1] = 0.0;
	me->brk_dist = 0.0;

	return(OM_S_SUCCESS);
}

method clear_jog_pts(IGRint flag)
{
	if (flag & CLEAR_JOG_PTS)
	{
		/*|- clearing jog_pt */
		me->jog_pt[0] = me->jog_pt[1] = 0.0;
	}

	return(OM_S_SUCCESS);
}

method get_jog_info(
	IGRint *msg;
	IGRboolean *jogged;
	IGRint *num_jog_pts;
	IGRdouble jog_line[12];
	struct GRmd_env *md_env)
{
	IGRint status;

	if (jogged)
	   *jogged = me->jogged;

	if (me->jogged)
	{
		if (jog_line)
		{
			IGRint count;
			IGRpoint orig, meas, cpx_orig;
			struct DMplan_info plan_info;
			struct DMenv_param par_env;
			struct DMloc_param par_loc;
			struct GRid list[MAX_DIM_ROOTS];

			status =
			om$send(msg = message DMroot.DMreturn_roots(
							&count,
							list),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMcoordj.gather_data(
							msg,
							count,
 							list,
							md_env,
							orig,
							meas,
							cpx_orig,
							&plan_info,
							&par_env,
							&par_loc),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMcoordj.compute_jog_line(
							num_jog_pts,
							NULL,
							meas,
							NULL,
							jog_line,
							&plan_info,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	
	return(OM_S_SUCCESS);
}

method get_dim_attr(char *attr)
{
	struct dim_attr *dim_attr;

	dim_attr = (struct dim_attr *)attr;

	dim_attr->dim_type	= me->dim_type;
	dim_attr->dim_state	= me->dim_state;
	dim_attr->brk_dist	= me->brk_dist;
	dim_attr->lead_dist	= me->lead_dist;
	dim_attr->trak_dist	= me->trak_dist;
	dim_attr->offs_pt[0]	= me->offs_pt[0];
	dim_attr->offs_pt[1]	= me->offs_pt[1];
	dim_attr->prj_offs[0]	= me->prj_offs[0];
	dim_attr->prj_offs[1]	= me->prj_offs[1];
	dim_attr->mea_trak	= me->mea_trak;
	dim_attr->brk_pos	= me->brk_pos;
	dim_attr->leader	= me->leader;
	dim_attr->ter_loca	= me->ter_loca;
	dim_attr->geom_type	= me->geom_type;
	dim_attr->display	= me->display;
	dim_attr->jogged 	= me->jogged;
	dim_attr->jog_offs[0]	= me->jog_pt[0];
	dim_attr->jog_offs[1]	= me->jog_pt[1];

	return(OM_S_SUCCESS);
}

method copy_dim_attr(
	IGRint *msg;
	IGRint control;
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct dim_attr dim_attr;
	struct GRid grid;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message DMroot.get_dim_attr((char *)&dim_attr),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	/*" trak dist:%f\n",dim_attr.trak_dist*/

	if (control & INST_JOG_PTS)
	{
		/*|- Copy Jog Instance */

		me->jogged = dim_attr.jogged;
		me->jog_pt[0] = dim_attr.jog_offs[0];
		me->jog_pt[1] = dim_attr.jog_offs[1];
		me->brk_dist = dim_attr.brk_dist;
		me->trak_dist = dim_attr.trak_dist;
		me->mea_trak = dim_attr.mea_trak;
	}
	
	if (control & INST_BREAK_PT
	||  control & INST_TRAK_PT)
	{
		/*|- Copy Break & Trak Instance */

		me->brk_pos = dim_attr.brk_pos;
		me->brk_dist = dim_attr.brk_dist;
		me->trak_dist = dim_attr.trak_dist;
		me->mea_trak = dim_attr.mea_trak;
	}

	if (control & INST_PROJ_OFFS_PT)
	{
		/*|- Copy Projection Instance */

		me->prj_offs[0] = dim_attr.prj_offs[0];
		me->prj_offs[1] = dim_attr.prj_offs[1];
	}

	if (control & INST_LEADER_PT)
	{
		/*|- Copy Leader Instance */

		me->leader = dim_attr.leader;
		me->lead_dist = dim_attr.lead_dist;
	}

	if (control & INST_OFFS_PT)
	{
		/*|- Copy text offset Instance */

		me->offs_pt[0] = dim_attr.offs_pt[0];
		me->offs_pt[1] = dim_attr.offs_pt[1];
	}

	if (control & INST_TER_LOCA)
		me->ter_loca = dim_attr.ter_loca;

	if ((control & INST_TRAK_PT)
	||  (control & INST_JOG_PTS))
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		grid.objid = my_id;
		grid.osnum = OM_Gw_current_OS;
	}

        if ((!ASbroadcast_in_progress) && !(control & INST_NOT_IN_BATCH))
	{
		IGRint cn_type;

		cn_type = ND_COMP;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method remove_from_cpx(
	IGRint *msg;
	IGRint action;
	struct GRmd_env *md_env)
{
	IGRint status, rc, indx, cn_type, i;
	IGRchar trak_zone;
	struct GRid prev, next[2], next_f[2];
	struct GRid first, my_grid, ctrl_dim;
	IGRboolean first_in_cpx, last_in_cpx;
	struct DMtrak_info trak_info;
	IGRpoint trak_orig, trak_pt;
	extern IGRboolean ASbroadcast_in_progress;
	IGRboolean delete_first, last;

	*msg = DIM_S_SUCCESS;

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_grid("prev_grid", &prev);
		print_grid("first", &first);
		printf("first_in_cpx = %d, last_in_cpx = %d\n",
				first_in_cpx, last_in_cpx);
	*/

	if ((!first_in_cpx && last_in_cpx)
	&& action == DELETE_ACTION
	&& !(me->dim_state & DIM_IN_PLACEMENT))
	{
		/*|- check if dimension is the second one in complex*/

		if (first.objid == prev.objid)
		{
			/*- Second dimension in the complex deletes
			    along with it, the first dimension also.
			*/
		
			status =
			om$send(msg = message DMroot.give_next(
						&rc,
						&last,
						next_f),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			/*- Check if first dimension as another
			    branch, if so first dimension cannot
			    be deleted.
			*/

			delete_first = TRUE;

			for (indx=0; indx<2; indx++)
			{
				if (next_f[indx].objid == NULL_OBJID)
				   continue;

				if (next_f[indx].objid != my_id)
				{
				   delete_first = FALSE;
				   break;
				}
			}

			if (delete_first)
			{
				status =
				om$send(msg = message NDnode.NDdisplay(
							0,
							GRbe,
							md_env),
					targetid = first.objid,
					targetos = first.osnum);
				dm$status(action = RET_STATUS);
				
				status =
				om$send(msg = message NDnode.NDdelete( md_env),
					targetid = first.objid,
					targetos = first.osnum);
				dm$status(action = RET_STATUS);

				return(OM_S_SUCCESS);
			}
		}
	}

	/*"dim state = %d\n", me->dim_state*/

	for (indx=0; indx<2; indx++)
	{
		if (next[indx].objid == NULL_OBJID)
			continue;

		/*^
			printf("change_connect: old=%d,%d,prev=%d,%d\n",
					my_id,
					OM_Gw_current_OS,
					prev.objid,
					prev.osnum);
		*/

		if (first_in_cpx)
		{
			status =
			om$send(msg = message Root.disconnect(
							ND_children,
							next[indx].objid,
							next[indx].osnum,
							ND_father),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message ASnode.NDchange_connect(
							1,
							&my_grid,
							&prev),
				mode = OM_e_wrt_message,
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}

		if ((me->mea_trak & DM_TRAK_CTRL_DIM)
		&&  !first_in_cpx
		&&  (action == DELETE_ACTION))
		{
			/*|- Secondary Control Dimension */

			trak_zone = (me->mea_trak & DM_TRAK_ZONE1)?
				     DM_TRAK_ZONE1:DM_TRAK_ZONE2;

			status =
			om$send(msg = message DMroot.give_next(
						&rc,
						&last,
						next_f),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			/*|- Search for next suitable ctrl dimension */

			for (i=0; i<2; i++)
			{
				if (next_f[i].objid == NULL_OBJID)
					continue;

				status =
				om$send(msg = message DMcoordj.find_mea_trak_info(
							&rc,
							FALSE,
							FALSE,
							trak_zone,
							&trak_info.mea_trak,
							&trak_info.trak_dist,
							trak_orig,
							&ctrl_dim,
							md_env),
					targetid = next_f[i].objid,
					targetos = next_f[i].osnum);
				dm$status(action = RET_STATUS);

				/*^ print_grid("ctrl_dim", &ctrl_dim); */

				if (rc && (ctrl_dim.objid != my_id))
				   break;
			}

			if ((ctrl_dim.objid == NULL_OBJID)
			||  (ctrl_dim.objid == my_id))
			{
				status =
				om$send(msg = message DMcoordj.find_mea_trak_info(
							&rc,
							FALSE,
							FALSE,
							trak_zone,
							&trak_info.mea_trak,
							&trak_info.trak_dist,
							trak_orig,
							&ctrl_dim,
							md_env),
					targetid = next[indx].objid,
					targetos = next[indx].osnum);
				dm$status(action = RET_STATUS);
			}

			if (ctrl_dim.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message DMdim.get_orig_trak_pt(
								trak_pt,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMdim.get_orig_trak_info(
								trak_pt,
								&trak_info,
								md_env),
					targetid = ctrl_dim.objid,
					targetos = ctrl_dim.osnum);
				dm$status(action = RET_STATUS);

				trak_info.mea_trak |= DM_TRAK_CTRL_DIM;

				status =
				om$send(msg = message DMroot.set_trak_info(
								REP_TRAK_DIST,
								&trak_info),
					targetid = ctrl_dim.objid,
					targetos = ctrl_dim.osnum);
				dm$status(action = RET_STATUS);
			}
		}

		if (!(action == NO_ACTION)
		&& !(me->dim_state & DIM_IN_PLACEMENT))
		{
			status =
			om$send(msg = message DMroot.set_degrade(md_env),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}

		if (!ASbroadcast_in_progress)
		{
			cn_type = ND_COMP;
			nd$wait_batch(
				type = GR_GEOM_POSTED,
				l_object = &next[indx],
				l_obj_info = &cn_type,
				nb_obj   = 1);
		}
	}

	if (!first_in_cpx)
	{
		/*|- Final Checking */

		/* - If I am not the first dimension in the complex
		     my <prev_dim>, which is the previous dimension
		     in the complex, should be replaced by the actual
		     complex origin point - which is with the first
		     dimension in the complex - */

		if (last_in_cpx)
		{
			if ((me->mea_trak & DM_TRAK_CTRL_DIM)
			&&  (action == DELETE_ACTION))
			{
				/*|- Secondary Control Dimension */

				trak_zone = (me->mea_trak & DM_TRAK_ZONE1)?
				     DM_TRAK_ZONE1:DM_TRAK_ZONE2;

				status =
				om$send(msg = message DMroot.give_next(
							&rc,
							&last,
							next_f),
					targetid = first.objid,
					targetos = first.osnum);
				dm$status(action = RET_STATUS);

				/*|- Search for next suitable ctrl dimension */

				for (i=0; i<2; i++)
				{
					if (next_f[i].objid == NULL_OBJID)
						continue;

					status =
					om$send(msg = message DMcoordj.find_mea_trak_info(
							&rc,
							FALSE,
							FALSE,
							trak_zone,
							&trak_info.mea_trak,
							&trak_info.trak_dist,
							trak_orig,
							&ctrl_dim,
							md_env),
						targetid = next_f[i].objid,
						targetos = next_f[i].osnum);
					dm$status(action = RET_STATUS);

					/*^ print_grid("ctrl_dim", &ctrl_dim); */

					if (rc && (ctrl_dim.objid != my_id))
					   break;
				}
	
				if (ctrl_dim.objid != NULL_OBJID)
				{
					status =
					om$send(msg = message DMdim.get_orig_trak_pt(
								trak_pt,
								md_env),
					targetid = my_id);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message DMdim.get_orig_trak_info(
								trak_pt,
								&trak_info,
								md_env),
						targetid = ctrl_dim.objid,
						targetos = ctrl_dim.osnum);
					dm$status(action = RET_STATUS);

					trak_info.mea_trak |= DM_TRAK_CTRL_DIM;

					status =
					om$send(msg = message DMroot.set_trak_info(
								REP_TRAK_DIST,
								&trak_info),
						targetid = ctrl_dim.objid,
						targetos = ctrl_dim.osnum);
					dm$status(action = RET_STATUS);
				}
			}

			if (!ASbroadcast_in_progress)
			{
				cn_type = ND_COMP;
				nd$wait_batch(
					type = GR_GEOM_POSTED,
					l_object = &prev,
					l_obj_info = &cn_type,
					nb_obj   = 1);
			}
		}

		status =
		om$send(msg = message DMroot.give_previous(
							&rc,
							&first_in_cpx,
							&first),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("first", &first); */

		status =
		om$send(msg = message ASnode.NDchange_connect(
							1,
							&prev,
							&first),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method GRdelete(
	IGRlong *msg;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRboolean first_in_cpx, last_in_cpx;
	struct GRid prev, next[2];

	*msg = MSSUCC;

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (first_in_cpx && !last_in_cpx)
	{
		/*|- Cannot delete first dimension, group not empty*/

		ex$message(msgnumb = DM_I_CannotDelZeroDim);

		status =
		om$send(msg = message NDnode.NDdisplay(
						0,
						GRbd,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.GRdelete(msg, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method adjust_trak_dist(
	IGRchar mask;
	IGRdouble *trak_dist)
{
	IGRint status, rc, i;
	IGRboolean last_in_cpx;
	struct GRid next[2];

	/*"me->trak_dist = %f, trak_diff = %f\n", me->trak_dist, *trak_dist*/

	if (me->mea_trak & mask)
	{
		me->trak_dist -= *trak_dist;

		if ((fabs(me->trak_dist) > 0.0)
		&&  (me->mea_trak & DM_TRAK_LOCK))
			me->mea_trak &= ~DM_TRAK_LOCK;
	}

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(!last_in_cpx)
	{
		for (i=0; i<2; i++)
		{
			if (next[i].objid == NULL_OBJID)
			   break;

			status =
			om$send(msg = OPPmargs,
				targetid = next[i].objid,
				targetos = next[i].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

end implementation DMcoordj;

