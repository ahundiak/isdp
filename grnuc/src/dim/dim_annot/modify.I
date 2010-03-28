/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: modify.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:21  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:19  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:49  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/11/01  10:11:56  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.0  1992/12/06  23:41:52  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.1  1992/10/16  19:23:57  poo
# COMMENT : Checking in 2.1 Fixes to 2.2 RCS
#
Revision 201.17  1992/10/06  15:23:56  poo
COMMENT : Fix for Leader line modify - cursor locking.

Revision 201.16  1992/09/18  09:29:11  poo
COMMENT : Fix for modify on Leader line (AutoDimensions).

Revision 201.13  1992/04/02  12:19:09  dimdp20
COMMENT : Fix for modify dimension on multiple balloon dynamics display.

Revision 201.11  1992/02/24  19:48:15  dimdp20
COMMENT : VLA for  no leader cases  saves offset distance

Revision 201.8  1992/01/22  07:36:16  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.


*/

class implementation DMannot;

#define AS_DEBUG 1

#include "dimmod.h"
#include "bslenvec.h"

extern IGRdouble fabs();
extern BSlininter();
extern free();
extern double BSdistptpt();

from DMsrc import DMmodify, DMgive_tangent;
from DMframe import make_profile_sym;

method modify_geom(
	IGRint *msg;
	IGRint control;
	IGRint vertex_no;
	IGRpoint cursor;
	struct GRid *win_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint hilite=FALSE,i ,index=0, count, key, ptdist;
	IGRlong long_rc, bsrc;
	IGRint num_vertex,last_vtx;
	IGRboolean src_modify, pos_term, src_type;
	struct GRid list[NO_LEADER_ROOTS];
	struct GRid text_grid, term_grid, line_grid;
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRdouble *start_pt,*prev_point;
	IGRpoint diff,point,point1;
	struct IGRline bore_line;
	IGRdouble src_dir[3] , *vertex;
	IGRdouble target_pt[3];
	struct GRmd_env mod_info;
	struct ret_struct ret_str;

	if ((me->geom_type & DIM_IMPORTED)
	&&  ((control & MOVE_TERMINATOR) || (vertex_no == 0)))
	{
		/*|- Cannot modify source location for retrived dim*/
		return(OM_S_SUCCESS);
	}

	/* - KLudge for Leader line dimension, during macro
	     placement, if num_brkpt was zero the leader
	     was not set. The leader will be set TRUE
	     for leader line always
	*/

	if (me->dim_type == LEADER_LINE) me->leader = TRUE;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send( msg = message DMannot.gather_data(
					&rc,
					count,
					list,
					point,
					point1,
					&plan_info,
					&par_senv,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.ASreturn_go(
				&list[AN_ROOT_ELEM1],
				&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if(!DMancestry_valid(list[AN_ROOT_ELEM1],
			      OPP_dim_src_class_id))
		return(OM_S_SUCCESS);

	if (md_env->md_env.matrix_type != MAIDMX)
		mod_info = *md_env;

	status =
	om$send(msg = message DMsrc.DMgive_tangent(
					&rc,
					&src_type,
					src_dir,
					NULL,
					&mod_info),
		targetid= list[AN_ROOT_ELEM1].objid,
		targetos= list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if (src_type == POINT_TYPE)
	{
		/*| - Element is point type */

		for(i=0; i<3; i++)
		src_dir[i] = plan_info.act_plan.vec_xpos[i];
	}
	
	status =
	om$send(msg = message DMannot.get_graphics(
					FALSE,
					&text_grid,
					&line_grid,
					&term_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	src_modify = pos_term = FALSE;

	if(!me->leader)
	{
		/*| No leader so Modify DMsrc element*/
		src_modify = TRUE;
		index = AN_ROOT_ELEM1;
	}
	else if ((control & MOVE_TERMINATOR) || (vertex_no == 0))
	{
		/*| - Modify attach element */

		src_modify = TRUE;
		index = AN_ROOT_ELEM1;
		math_v_equal(target_pt, cursor);
	}
	else if ((control & MOVE_POLE) || (control & MOVE_TEXT))
	{

		/*| - Modify one of poles */

		status =
		om$send(msg = message DMannot.fill_leader_info(
						&rc,
						point,
						point1,
						line_grid,
						text_grid,
						&plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		num_vertex = om$dimension_of(varray = me->break_pt)/3;
		last_vtx = 3*(num_vertex -1);

		if ((vertex_no == num_vertex - 1) && (me->dim_type == LEADER_LINE))
		{
			/*| - Modify leader end  element */
			src_modify = TRUE;
			index = AN_ROOT_ELEM2;

			if (me->geom_type & DIM_IMPORTED)
			{
				status =
				om$send(msg = message NDnode.ASreturn_go(
						&list[index],
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
					targetid = list[index].objid,
					targetos = list[index].osnum);
				dm$status(action = RET_STATUS);
			}

			/*| - Get previous vector direction */

			for(i=0; i<3; i++)
			   src_dir[i] = me->break_pt[3*(vertex_no - 1) + i] -
					me->break_pt[3*(vertex_no - 2) + i];

			prev_point = &me->break_pt[(vertex_no-1)*3];

			/*| DMinquire_hilite*/

			DMinquire_hilite( 
				cursor,
				prev_point,
				target_pt,
				NULL,
				src_dir,
				NULL,
				&plan_info,
				win_grid,
			 	&hilite);
		}
		else
		{
			if (control & MOVE_TEXT)
			{
				/*| - MOVE TEXT - check text intersection */
				vertex_no = num_vertex - 1;
			}

			if (vertex_no == 1)
			{
				/*| - MOVE 1ST POLE - get source direction */
				pos_term = TRUE;
			}
			else
			{
				/*| - Get previous vector direction */
				for(i=0; i<3; i++)
					src_dir[i] = 
					    me->break_pt[3*(vertex_no - 1) + i] -
					    me->break_pt[3*(vertex_no - 2) + i];
			}

			if(vertex_no == num_vertex -1)
				start_pt = &me->break_pt[last_vtx];
			else
				start_pt= &me->break_pt[vertex_no*3];

			prev_point = &me->break_pt[(vertex_no-1)*3];

			/*| DMinquire_hilite*/

			DMinquire_hilite( 
				cursor,
				prev_point,
				target_pt,
				NULL,
				src_dir,
				NULL,
				&plan_info,
				win_grid,
			 	&hilite);

			for(i=0; i<3; i++)
			{
				diff[i] = target_pt[i] - start_pt[i];
 			}
			
			/*^ print_point("diff:",diff); */

			for (i=vertex_no; i<num_vertex; i++)
			{
				vertex = &me->break_pt[i*3];
				vec_add(vertex, diff, vertex);
			}
			
			if( me->dim_type != LEADER_LINE)
			{
				
				status =
				om$send(msg = message DMannot.make_an_text(
							&rc,
							&plan_info,
							&par_senv,
							text_grid,
							md_env),
				targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			else
			{
				for( i = 0 ;i< 3; i++)
					me->break_pt[3*(num_vertex -1) +i] = point1[i];
			}

			status =
			om$send(msg = message DMannot.make_lead_line(
							&rc,
							&par_senv,
							&plan_info,
			 				line_grid,
			 				md_env),
				targetid = my_id);
			dm$status(action = RET_STAUS);
		

			if (me->dim_type == FEATURE_CONTROL_FRAME)
			{
				status =
				om$send(msg = message DMframe.make_profile_sym(
							&rc,
							&par_senv,
							&plan_info,
							md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}

			if(pos_term)
			{
				status =
				om$send(msg = message DMannot.make_an_term(
								&rc,
								&plan_info,
								&par_senv,
				 				term_grid,
				 				md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		
			par_senv.dim_weig += (hilite)?2:0;

			status =
			om$send(msg = message DMannot.chg_an_dp(&rc, &par_senv),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	else
	{
		/*"control:%d\n",control*/
		return(OM_E_ABORT);
	}


	if(src_modify && me->leader)
	{
		bore_line.point1 = target_pt;
		bore_line.point2 = point;
		
		point[0] = bore_line.point1[0] + plan_info.act_plan.matrix[8];
		point[1] = bore_line.point1[1] + plan_info.act_plan.matrix[9];
		point[2] = bore_line.point1[2] + plan_info.act_plan.matrix[10];

		key = (me->dim_type == LEADER_LINE || !me->leader)? TRUE: FALSE;

		if(!me->leader && (me->dim_type == DATUM_FRAME ||
				   me->dim_type == FEATURE_CONTROL_FRAME))
			ptdist = FALSE;
		else	ptdist = TRUE;

		status =
		om$send(msg = message DMsrc.DMmodify(
						&rc,
						&mod_info,
						key,
						ptdist,
						&bore_line),
			targetid = list[index].objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							ND_COMP,
							md_env),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		if (hilite)
		{
			par_senv.dim_weig += 2;

			status =
			om$send(msg = message DMannot.chg_an_dp(&rc, &par_senv),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	else if(src_modify && !me->leader)
	{
		status =
		DMnode_give_structure(
			&rc,
			AN_ROOT_ELEM1,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&ret_str);
		dm$status(action = RET_STATUS);

		if (ret_str.type == line_generic)
		{
			math_v_equal(point, ret_str.var.line_st.p1);
		}
		else
		{
			math_v_equal(point, ret_str.var.point_st.pt);
		}

		status =
		om$vla_set_dimension(varray = me->break_pt,
			size = 3);
		dm$status(action = RET_STATUS);

		me->break_pt[0] = (cursor[0] - point[0])/
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		me->break_pt[1] = (cursor[1] - point[1])/
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		me->break_pt[2] = (cursor[2] - point[2])/
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		/*"break_pt=(%lf, %lf, %lf)\n", me->break_pt[0], me->break_pt[1], me->break_pt[2]*/

		status =
		om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							ND_COMP,
							md_env),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

end implementation DMannot;
