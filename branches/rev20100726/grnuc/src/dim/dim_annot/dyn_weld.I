class implementation DMweld;

#define AS_DEBUG	1
#include "dimmod.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"

extern double fabs();

method txdynamics(IGRlong *msg;
	IGRint control;
	IGRint info_flag;
	IGRint *level;
	IGRchar *info;
	struct EX_button *cursor;
	IGRuchar *character;
	IGRint numbytes;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env)
{
	IGRint	status, rc;
	IGRint  hilite;
	IGRdouble  target_pt[3], *prev_point;
	IGRdouble refer_dir[3], tail_pt[3], flag_pt[3], dotp;
	struct DMplan_info *plan_info;
	struct DMdyn_weld *place_attr;
	extern IGRboolean dynamics_in_progress;
	IGRint last_vtx, curr_vtx, num_vertex, flag;
	BSrc	bs_rc;

	*msg = OM_S_SUCCESS;

	if(info_flag & TEXT_ENTERED)
		return(OM_S_SUCCESS);

	place_attr = ( struct DMdyn_weld *)info;
	plan_info = ( struct DMplan_info *)&place_attr->plan_info;


	if( (me->dim_state & DIM_NEEDS_UPDATE )
	   || (control & FILL_INFO))
	{
		/*| FILL_INFO*/
		status=
		om$send(msg = message DMannot.fill_info(&rc,
						control,
						level,
						info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->dim_state &=(~DIM_NEEDS_UPDATE);
		control &=(~FILL_INFO);
	}

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
	curr_vtx = 3*(num_vertex -2);
	last_vtx = 3*(num_vertex -1);

	/*^ print_point("cursor",cursor); */

	prev_point = &me->break_pt[ curr_vtx - 3];
	if( num_vertex > 3)
	{
		BSmkvec(&bs_rc,refer_dir,prev_point,&me->break_pt[curr_vtx - 6]);
		BSnorvec(&bs_rc,refer_dir);
	}
	else
	{
		vec_equal(place_attr->src_dir,refer_dir);
	}
	
	/*^
	    print_point("refer_dir",refer_dir);
	    print_point("prev_pt", prev_point);
	    print_grid("win_grid", &place_attr->win_grid);
	*/

	/*| DMinquire_hilite*/

	DMinquire_hilite(
		(IGRdouble *)cursor,
		prev_point,
		target_pt,
		NULL,
		refer_dir,
		NULL,
		plan_info,
		&place_attr->win_grid,
		&hilite);

	memcpy(&me->break_pt[curr_vtx],target_pt,3*sizeof(IGRdouble));

	/*^ print_point("target_pt", target_pt); */

	DMget_direction(
		prev_point,
		target_pt,
		place_attr->plan_info.act_plan.matrix,
		&flag);

	if(flag == AN_BEFORE)
		me->bln_dir = LEFT_SIDE;
	else	me->bln_dir = RIGHT_SIDE;

	if( num_vertex > 3)
	{
		/*|- Check if prev segment is parallel to current seg*/

		BSmkvec(&bs_rc, refer_dir, target_pt, prev_point);
		BSnorvec(&bs_rc, refer_dir);

		dotp = BSdotp(&bs_rc, refer_dir, plan_info->win_plan.vec_xpos);

		/*"dotp = %f\n",dotp*/

		if ((fabs(dotp) > DOTP_LOWER_BOUND)
		&&  (fabs(dotp) < DOTP_UPPER_BOUND))
		{
			/*|- Parallel copy prev pt to Flag pt*/
			vec_equal(prev_point, flag_pt);
		}
		else
		{
			/*|- Non_parallel copy curr pt to flag pt */
			vec_equal(target_pt, flag_pt);
		}
	}
	else
	{
		vec_equal(target_pt, flag_pt);
	}
	
	/*^ print_point("flag_pt", flag_pt); */

	status =
	om$send(msg = message DMweld.position_weld_text(
					&rc,
					target_pt,
					tail_pt,
					flag_pt,
					place_attr->go_grid,
					&place_attr->plan_info,
					&place_attr->par_senv,
					md_env),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	memcpy(&me->break_pt[last_vtx],tail_pt,3*sizeof(IGRdouble));

	status =
	om$send(msg = message DMweld.make_weld_line(
					&rc,
					tail_pt,
					flag_pt,
					&place_attr->par_senv,
					plan_info,
					place_attr->go_grid,
					md_env),
			targetid = my_id);
	dm$status(action = RET_STATUS);
		
	BSmkvec(&bs_rc, refer_dir, &me->break_pt[3], me->break_pt);
	BSnorvec(&bs_rc, refer_dir);

	status =
	om$send(msg = message DMroot.position_text(
					&rc,
					FALSE,
					DIM_NO_INDEX,
					&place_attr->go_grid[TERM],
					md_env,
					place_attr->ter_just,
					me->break_pt,
					refer_dir,
					&plan_info->win_plan.matrix[8],
					NULL,
					NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - change display properties*/

	if (dynamics_in_progress)
	{
		place_attr->par_senv.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMannot.chg_an_dp(&rc, &place_attr->par_senv),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation DMweld;
