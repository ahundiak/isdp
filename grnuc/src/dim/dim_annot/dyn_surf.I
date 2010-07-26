class implementation DMsurf;

#define AS_DEBUG	1
#include "dimmod.h"
#include "bspt_on_lne.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"

extern IGRboolean BSproj0();
extern double fabs();
from DMsrc import DMgive_tangent;

method dynamics(
	IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar *info;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	IGRint	status, rc;
	IGRlong long_rc, bsrc;
	IGRint  hilite;
	IGRdouble  target_pt[3], *prev_point;
	IGRdouble refer_dir[3],term_dir[3];
	struct DMplan_info *plan_info;
	struct DMdyn_surf *place_attr;
	extern IGRboolean dynamics_in_progress;
	IGRint last_vtx, curr_vtx, num_vertex=0, flag;
	IGRdouble sym_posn[MAX_SURF_COMP*3];
	IGRdouble *vertex, *ex_point, ext_length, ext_line[6];
	IGRboolean on_element;
	IGRdouble dist1, dist2, *req_pt, surf_dir[3];
	IGRdouble u_par;
	IGRint index;
	*msg = OM_S_SUCCESS;

	place_attr = ( struct DMdyn_surf *)info;
	plan_info = ( struct DMplan_info *)&place_attr->plan_info;

	if ((me->dim_state & DIM_NEEDS_UPDATE)
	||  (control & FILL_INFO))
	{
		/*| FILL_INFO*/

		status = 
		om$send(msg = message DMannot.fill_info(
						&rc,
						control,
						level,
						info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->dim_state &=(~DIM_NEEDS_UPDATE);
		control &=(~FILL_INFO);
	}

	if (me->leader)
	{
		num_vertex = om$dimension_of(varray =  me->break_pt)/3;
		curr_vtx = 3*(num_vertex -2);
		last_vtx = 3*(num_vertex -1);
	
		/*^ print_point("cursor",cursor); */
	
		prev_point = &me->break_pt[ curr_vtx - 3];

		if( num_vertex > 3)
		{
			BSmkvec(&bsrc,refer_dir,prev_point,&me->break_pt[curr_vtx - 6]);
			BSnorvec(&bsrc,refer_dir);
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
			me->bln_dir = SURF_LEFT;
		else	me->bln_dir = SURF_RIGHT;

		vertex = &me->break_pt[curr_vtx];
		ex_point = &me->break_pt[last_vtx];
		ext_length = (me->front_len + me->rear_len + 5.25)*
				place_attr->par_senv.txt_widt;

		if (me->bln_dir == SURF_RIGHT)
		{
			/*|- Surf dir is SURF_RIGHT*/

			math_v_equal(surf_dir, plan_info->win_plan.vec_xpos);
		}
		else
		{
			/*|- Surf dir is SURF_LEFT*/

			math_v_equal(surf_dir, plan_info->win_plan.vec_xneg);
		}

		MATH_ptdelta(&rc,
			     vertex,
			     surf_dir,
			     ext_length,
			     ex_point);
	}
	else
	{
		hilite = FALSE;
		me->bln_dir = SURF_RIGHT;

		/*^ print_point("cursor", cursor); */

		status = BSproj0(&bsrc,
				cursor,
				place_attr->line,
				target_pt);

		/*^ print_point("target_pt", target_pt); */

		on_element = FALSE;

		BSpt_on_lne(&long_rc,
			    place_attr->line,
			    &place_attr->line[3],
			    target_pt,
			    &u_par,
			    &on_element);

		if (!on_element)
		{
			/*|- Position line */

			dist1 = BSdistptpts(&bsrc,place_attr->line,target_pt);
			dist2 = BSdistptpts(&bsrc,&place_attr->line[3],target_pt);

			req_pt = (dist1 > dist2)?&place_attr->line[3]:
						place_attr->line;

			for( index = 0; index<3; index++)
			{
				ext_line[index] = req_pt[index];
				ext_line[index + 3] = target_pt[index];
			}

			BSmkvec(&bsrc, surf_dir, req_pt, target_pt);
			BSnorvec(&bsrc, surf_dir);

			ext_length = 0.5 * place_attr->par_senv.txt_heig;
			MATH_ptdelta(&rc, ext_line, surf_dir, ext_length, ext_line);

			if (BSdotp(&bsrc, place_attr->txt_orie, surf_dir) > 0.0)
			{
				/*|- Same as text dir*/

				if (me->sym_posn == SURF_ABOVE)
					ext_length = (me->rear_len + 3.75) * place_attr->par_senv.txt_widt;
				else	ext_length = (me->front_len + 1.5) * place_attr->par_senv.txt_widt;
			}
			else
			{
				/*|- opposite to text dir */

				if (me->sym_posn == SURF_ABOVE)
					ext_length = (me->front_len + 1.5) * place_attr->par_senv.txt_widt;
				else	ext_length = (me->rear_len + 3.75) * place_attr->par_senv.txt_widt;
			}

			MATH_ptdelta(&rc,
			     &ext_line[3],
			     surf_dir,
			     ext_length,
			     &ext_line[3]);

			/*^  print_line("extn_line", ext_line); */

			status =
			om$send(msg = message DMroot.position_line(
						&rc,
						SURF_EXTN_LINE,
						NULL,
						md_env,
						ext_line),
				targetid = my_id);
			dm$status(action = RET_STATUS);		     
		}
		else
		{
			/*|- Delete SURF_EXTN_LINE */

			status =
			om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_EXTN_LINE,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			place_attr->go_grid[SURF_EXTN_LINE].objid = NULL_OBJID;
		}
	}

	/*|- Compute symbol positions */

        status =
        om$send(msg = message DMsurf.compute_symbol_positions(
                                                &rc,
						target_pt,
                                                place_attr->txt_orie,
                                                &place_attr->par_senv,
                                                &place_attr->plan_info,
                                                sym_posn),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	/*|- Position Surf Text */

        status =
        om$send(msg = message DMsurf.position_surf_text(
                                        &rc,
                                        place_attr->go_grid,
                                        place_attr->txt_orie,
                                        &place_attr->par_senv,
                                        &place_attr->plan_info,
                                        sym_posn,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	/*|- Position Surf Symbol */

        status =
        om$send(msg = message DMsurf.position_surf_symbol(
                                        &rc,
                                        sym_posn,
                                        place_attr->txt_orie,
                                        place_attr->go_grid,
                                        &place_attr->par_senv,
                                        &place_attr->plan_info,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	if(me->leader)
	{
		/*|- Position Leader & Term */

        	status =
        	om$send(msg = message DMroot.position_line_string(
               	                        	&rc,
                                        	DIM_NO_INDEX,
                                        	&place_attr->go_grid[SURF_LEADER],
                                        	md_env,
                                        	num_vertex,
                                        	me->break_pt),
                	targetid = my_id);
        	dm$status(action = RET_STATUS);

		BSmkvec(&bsrc, term_dir, &me->break_pt[3], me->break_pt);
		BSnorvec(&bsrc, term_dir);

		/*^ print_point("term_pt", me->break_pt); */
		/*^ print_point("term_dir", term_dir); */
        
		status =
        	om$send(msg = message DMroot.position_text(
				        &rc,
				       	FALSE,
		                	DIM_NO_INDEX,
	                		&place_attr->go_grid[SURF_TERM],
		        	        md_env,
                			place_attr->ter_just,
			                place_attr->start_pt,
					term_dir,
			                place_attr->norm,
			                NULL,
			                NULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| - change display properties*/

	if (dynamics_in_progress)
	{
		place_attr->par_senv.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMannot.chg_an_dp(&rc, &place_attr->par_senv),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- clear the break pts*/

		status =
		om$vla_set_dimension(varray = me->break_pt, size = 0);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method fill_info( IGRint *msg;
        IGRint control;
        IGRint *level;
        IGRchar info[];
        struct GRmd_env *md_env)
{
	IGRint status, rc, index;
	IGRpoint end_pt;
	IGRint count;
	struct GRid list[MAX_DIM_ROOTS];
	struct DMdyn_surf *place_attr;
	extern struct DMglobal DM_global;
	BSrc	bsrc;

	place_attr = (struct DMdyn_surf *)info;

	status = 
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
        om$send(msg = message DMannot.gather_data(
                                        &rc,
                                        count,
                                        list,
                                        place_attr->start_pt,
                                        end_pt,
                                        &place_attr->plan_info,
                                        &place_attr->par_senv,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	    place_attr->norm[index] =
	    place_attr->plan_info.win_plan.matrix[8+index];

        status =
        om$send(msg = message DMsurf.get_components(
                                        TRUE,
                                        place_attr->go_grid,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMsurf.fill_leader_info(
					&rc,
                                        place_attr->start_pt,
                                        end_pt,
                                        place_attr->go_grid[SURF_LEADER],
                                        place_attr->go_grid[SURF_TEXTA],
					&place_attr->plan_info,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	status =
        om$send(msg = message DMsrc.DMgive_tangent(
        				&rc,
                			&place_attr->src_type,
               				place_attr->src_dir,
                                        (IGRdouble (*)[])place_attr->line,
                                        md_env),
                targetid = list[AN_ROOT_ELEM1].objid,
                targetos = list[AN_ROOT_ELEM1].osnum);
        dm$status(action = RET_STATUS);

        if (me->leader)
	{
		if (place_attr->src_type == POINT_TYPE)
		{
			/*| - Element is point type */

			math_v_equal(place_attr->src_dir,
			place_attr->plan_info.win_plan.vec_xpos);
		}
	
		math_v_equal(place_attr->txt_orie,
			place_attr->plan_info.win_plan.vec_xpos);
	}
	else
	{

		if (BSdotp(&bsrc, place_attr->plan_info.win_plan.vec_xpos,
			place_attr->src_dir) > 0.0)
		{
		    math_v_equal(place_attr->txt_orie,
			place_attr->src_dir);
		}
		else
		{
		    math_v_opposite(place_attr->txt_orie,
				place_attr->src_dir);
		}
	}

        status =
        om$send(msg = message DMsurf.make_surf_text(
                                        &rc,
                                        &place_attr->plan_info,
                                        &place_attr->par_senv,
                                        place_attr->go_grid,
                                        md_env),
                targetid= my_id);
        dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsurf.set_surf_text_attr(
					&rc,
					place_attr->go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->leader)
	{
		place_attr->ter_just =
		(DM_global.term_info[place_attr->par_senv.ter_type].center_just)?
				CENTER_CENTER:RIGHT_CENTER;

		status =
		om$send(msg = message DMannot.make_an_term(
						&rc,
						&place_attr->plan_info,
						&place_attr->par_senv,
						place_attr->go_grid[SURF_TERM],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*|- Delete SURF_EXTN_LINE */

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_EXTN_LINE,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->go_grid[SURF_EXTN_LINE].objid = NULL_OBJID;
	}
	else
	{
		/*|- No Leader - delete the terminator */

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_LEADER,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->go_grid[SURF_TERM].objid = NULL_OBJID;

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->go_grid[SURF_TERM].objid = NULL_OBJID;
	}

	return(TRUE);
}

end implementation DMsurf;




