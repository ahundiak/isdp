class implementation DMleader;

#define AS_DEBUG	1
#include "dimmod.h"

extern IGRboolean	BSmkvec(), BSnorvec();

from DMsrc import DMdisplay_source;

method txdynamics(IGRlong *msg;
	IGRint control;
	IGRint info_flag;
	IGRint *level;
	IGRchar *info;
	struct EX_button *cursor;
	unsigned char *character;
	IGRint numbytes;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env)
{
	IGRint	status, rc;
	IGRint  hilite;
	IGRdouble  target_pt[3], *prev_point;
	IGRdouble refer_dir[3];
	struct DMplan_info *plan_info;
	struct DMdyn_annot *place_attr;
	extern IGRboolean dynamics_in_progress;
	IGRint last_vtx,num_vertex;

	*msg = OM_S_SUCCESS;


	if(info_flag & TEXT_ENTERED)
		return(OM_S_SUCCESS);

	place_attr = ( struct DMdyn_annot *)info;
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
	}

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
	last_vtx = 3*(num_vertex -1);

	/*^ print_point("cursor",cursor); */

	prev_point = &me->break_pt[ last_vtx - 3];
	if( num_vertex > 2)
	{
		BSmkvec(&rc,refer_dir,prev_point,&me->break_pt[last_vtx - 6]);
		BSnorvec(&rc,refer_dir);
	}
	else
	{
		vec_equal(place_attr->src_dir,refer_dir);
	}
	
	/*^
	    print_point("refer_dir",refer_dir);
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

	memcpy(&me->break_pt[last_vtx],target_pt,3*sizeof(IGRdouble));

/*
	IGRdouble tolerance, point2[3];
	struct IGRline boreline;

	DMget_dit_tol(&place_attr->win_grid, &tolerance);

	boreline.point1 = target_pt;
	boreline.point2 = point2;

	point2[0] = target_pt[0] + plan_info->act_plan.matrix[8];
	point2[1] = target_pt[1] + plan_info->act_plan.matrix[9];
	point2[2] = target_pt[2] + plan_info->act_plan.matrix[10];

	status =
	om$send(msg = message DMsrc.DMdisplay_source(
						&rc,
						&tolerance,
						&boreline,
						md_env),
			senderid = my_id,
			p_chanselect = &ND_father,
			from = AN_ROOT_ELEM2,
			to = AN_ROOT_ELEM2);
	dm$status(action = RET_STATUS);
*/
	status=
	om$send(msg = message DMannot.make_lead_line(
				&rc,
				&place_attr->par_senv,
				plan_info,
				place_attr->go_grid[AN_POLY_LINE],
				md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);
		
	status =
	om$send(msg = message DMannot.make_an_term(
					&rc,
					plan_info,
					&place_attr->par_senv,
					place_attr->go_grid[AN_TER_TEXT],
					md_env),
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

end implementation DMleader;
