class implementation DMradjog;

#define AS_DEBUG 1

#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "dimext.h"
#include "dimmod.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "bsvalues.h"
#include "mascalvc.h"
#include "maaddvc.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

extern BSxlnpl();
extern IGRboolean	BSproj0();
extern double fabs();
extern double acos();
extern IGRboolean Dim_rad_jog;

from DMsrc import DMmodify;

method dynamics(
	IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	struct DMdyn_radial *place_attr;
	struct DMdim_arc arc_info;

	IGRshort status, on_curve;
	IGRint rc, index,i, flag, hilite, src_count;
	IGRint brk_pos, brk_pos1;
	IGRdouble dotproduct, lead_end[3];
	IGRdouble leader_pt[3], dia_line[3], center[3];
	IGRdouble pt_on_curve[3], cent_cursor[3];
	IGRdouble cross_vec[3];
	IGRdouble cent_term[3], cent_cvpt[3], cvpt_term[3];
	IGRdouble cent_delpt[3], txt_yoff, p2[3];
	IGRdouble delta_theta, dimn_value, angle;
	IGRdouble text_pt[3], brak_lead[3], lea_line[6];
	IGRdouble target_pt[3], src_dir[3], *src_dir1;
	IGRvector xaxis, yaxis;
	IGRdouble box[12], sca_value, *pt, *pt1;
	IGRdouble brk_dist, brk_pt[3], brk_dist1, brk_pt1[3];
	IGRdouble scale, dist, dist1;
	struct dim_ret_struct dim_str;
	IGRboolean const_radius;
	extern IGRboolean dynamics_in_progress;
	struct IGRline boreline;
  	struct GRid go_grid, src_list[2];
	struct GRmd_env mod_info,md_env2;
	struct GRid go_grid2;
	BSrc	bsrc;

    IGRboolean aflag = 0;
    struct GRmd_env rfenv;

	place_attr = (struct DMdyn_radial *)info;

	hilite = 0;
	dimn_value = dotproduct = 0.0;

	if (control & MOVE_JOG_LEADER_PT)
	{
		if (me->jogged)
			control &= ~MOVE_LEADER_PT;
		else	control &= ~MOVE_JOG_PT1;
	}

	if ((me->dim_state & DIM_NEEDS_UPDATE)
	||  (control & FILL_INFO))
	{
		/*|Initialise place_attr*/

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					place_attr->list,
					NO_RAD_DIM_ROOTS,
					NULL,
					0,
					NO_RAD_DIM_ROOTS - 1,
					&place_attr->count),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (me->dim_state & DIM_NEEDS_UPDATE)
		{
			/*| - Update Dimension - */

			status =
			om$send(msg = message NDnode.NDcompute_node(
						(IGRlong *)&rc,
						NULL,
						place_attr->count,
						place_attr->list,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		/*|- Intialise the DMsrc cache memory */
		/* START FIX NEED INTEGERATION */

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = place_attr->list[DIM_RAD_CURVE].objid,
			targetos = place_attr->list[DIM_RAD_CURVE].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					src_list,
					2,
					NULL,
					0,
					1,
					&src_count),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);
		/*END FIX*/

		DMsrc_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			FALSE,
			place_attr->list[DIM_RAD_CURVE].objid,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&dim_str);
		dm$status(action = RET_STATUS);

		status = DMload_cache(
				src_list,
				TRUE,
				TRUE,
				&dim_str.var.dm_radcen.u_par,
				&mod_info);
		dm$status(action = RET_STATUS);

		/*|Gather Data for this dimension*/

		status =
		om$send(msg = message DMradjog.gather_data(
					&rc,
					place_attr->count,
					place_attr->list,
					md_env,
					&place_attr->projection_required,
					&place_attr->const_radius,
					place_attr->center,
					place_attr->term_pt,
					&place_attr->dimn_value,
					&arc_info,
					&place_attr->plan_info,
					&place_attr->par_env,
					&place_attr->par_loc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		for (index=0; index<3; index++)
		{
			place_attr->norm_to_plane[index] =
			place_attr->plan_info.win_plan.matrix[index + 8];

			place_attr->pt_on_plane[index] =
			place_attr->plan_info.win_plan.matrix[4*index + 3];
		}

		place_attr->proj_offs = place_attr->par_env.proj_offs_r *
				place_attr->par_env.txt_heig;
		place_attr->proj_extn = place_attr->par_env.proj_extn_r *
				place_attr->par_env.txt_heig;

		if(me->dim_state & DIM_IN_PLACEMENT)
		{
			status =
			dm$get_dim_param(
				type = DM_MISC_PARAM,
				p_data = (char *) &place_attr->misc_param);
			dm$status(action = RET_STATUS);
		}

		if( me->dim_type == RADIAL_DIAMETER)
		{
			/*| dimension is radial diameter */
	
			me->jogged = FALSE;

			BSmkvec(&bsrc, dia_line, place_attr->term_pt, place_attr->center);
			BSnorvec(&bsrc, dia_line);

			sca_value = place_attr->dimn_value *
			BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);

			for(index=0; index<3; index++)
			    center[index] = place_attr->center[index] +
				    dia_line[index] * sca_value;

			dimn_value = place_attr->dimn_value * 2;
		}
		else
		{
			math_v_equal(center, place_attr->center);
			dimn_value = place_attr->dimn_value;
		}

		status =
		om$send(msg = message DMradjog.compute_jog_line(
							&rc,
							&place_attr->num_jog_pts,
							center,
							place_attr->term_pt,
							cent_term,
							place_attr->jog_line,
							&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*^
			printf("num_jog_pts = %d\n",place_attr->num_jog_pts);
			for (index=0; index<place_attr->num_jog_pts; index++)
			printf("jog_pt[%d] = %f,%f,%f\n",index,
				place_attr->jog_line[3*index],
				place_attr->jog_line[3*index+1],
				place_attr->jog_line[3*index+2]);
		*/

		status =
		om$send(msg = message DMradjog.compute_break_pt(
							&rc,
							center,
							place_attr->term_pt,
							cent_term,
							dimn_value,
							place_attr->jog_line,
							place_attr->break_pt,
							&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->buffer[0].dis_att = NULL;
		place_attr->buffer[1].dis_att = NULL;

		if (control & MOVE_BREAK_PT)
		{
			if ((me->jogged) && (place_attr->num_jog_pts == 2))
			   control = MOVE_JOG_PT1;
		}

		if((control & MOVE_LEADER_PT)
		|| (control & MOVE_TEXT_POS)
		|| (control & MOVE_JOG_PT1)
		|| (control & MOVE_JOG_PT2))
		{
			om$send(msg = message DMroot.return_dim_go(
							&rc,
							DIM_TEXT,
							FALSE,
							NULL,
							md_env,
							&place_attr->text_grid),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*^ printf(" text_grid : %d, %d\n",
					place_attr->text_grid.objid,
					place_attr->text_grid.osnum);
			*/
		
			BSmkvec(&bsrc,
				place_attr->mea_axis,
				place_attr->center,
				place_attr->term_pt);
			BSnorvec(&bsrc, place_attr->mea_axis);

			angle = M_PI/2;

			MATH_rotate_vector(
				&rc,
				place_attr->mea_axis,
				angle,
				place_attr->plan_info.act_plan.matrix,
				place_attr->perp_axis);

			BSnorvec(&bsrc, place_attr->perp_axis);
			/*^
			   print_point(" mea_axis : ", place_attr->mea_axis);
			   print_point(" perp_axis : ", place_attr->perp_axis);
			*/

			switch (place_attr->par_loc.txt_orie)
			{
				case TXT_ORIE_HORIZONTAL:

				math_v_equal(place_attr->text_dir,
				   place_attr->plan_info.win_plan.vec_xpos);
				math_v_equal(place_attr->offs_dir,
				   place_attr->plan_info.win_plan.vec_ypos);
				break;

				case TXT_ORIE_VERTICAL:

				math_v_equal(place_attr->text_dir,
				   place_attr->plan_info.win_plan.vec_ypos);
				math_v_equal(place_attr->offs_dir,
				   place_attr->plan_info.win_plan.vec_xneg);
				break;

				case TXT_ORIE_PARALLEL:

				if(BSdotp(&bsrc,
					place_attr->plan_info.win_plan.vec_xpos,
					place_attr->mea_axis) > 0.0)
				{
					math_v_equal(place_attr->text_dir,
						place_attr->mea_axis);
					math_v_equal(place_attr->offs_dir,
						place_attr->perp_axis);
				}
				else 
				{
					math_v_opposite(place_attr->text_dir,
						place_attr->mea_axis);

					math_v_opposite(place_attr->offs_dir,
						place_attr->perp_axis);
				}
				break;

				case TXT_ORIE_PERPENDICULAR:

				if(BSdotp(&bsrc,
					place_attr->plan_info.win_plan.vec_ypos,
					place_attr->perp_axis) > 0.0)
				{
					math_v_opposite(place_attr->text_dir,
						place_attr->perp_axis);

					math_v_equal(place_attr->offs_dir,
						place_attr->mea_axis);
				}
				else 
				{
					math_v_equal(place_attr->text_dir,
						place_attr->perp_axis);

					math_v_opposite(place_attr->offs_dir,
						place_attr->mea_axis);
				}
				break;

				default:

				printf("ERROR: txt_orie=%d\n",
					place_attr->par_loc.txt_orie);
				return(FALSE);

			}
			/*^
			   print_point(" text_dir : ", place_attr->text_dir);
			   print_point(" offs_dir : ", place_attr->offs_dir);
			*/

			if (place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
			{
				txt_yoff = place_attr->par_env.txt_yoff_r *
						place_attr->par_env.txt_heig;
				MAscalvc(&bsrc,
					&txt_yoff,
					place_attr->offs_dir,
					place_attr->def_offs);
			}
			else
			{
				place_attr->def_offs[0] =
				place_attr->def_offs[1] =
				place_attr->def_offs[2] = 0.0;
			}

			/*^ print_point(" def_offs : ", place_attr->def_offs); */

			if( control & MOVE_LEADER_PT)
			{
				DMlineptvec(
					place_attr->break_pt,
					place_attr->text_dir,
					place_attr->lea_line);

				/*^ print_line("lea_line", place_attr->lea_line); */
			}
		}

		if (control & MOVE_JOG_PT2)
		{
			IGRdouble *xpos, *xneg, *ypos, *yneg;

			/*|- Fill the cross line buffer */

			xpos = place_attr->plan_info.win_plan.vec_xpos;
			xneg = place_attr->plan_info.win_plan.vec_xneg;
			ypos = place_attr->plan_info.win_plan.vec_ypos;
			yneg = place_attr->plan_info.win_plan.vec_yneg;

			for (index=0; index<3; index++)
			{
			    place_attr->pt_buffer[index] =
			    center[index] + (100000.0 * xneg[index]);

			    place_attr->pt_buffer[index+3] =
			    center[index] + (100000.0 * xpos[index]);

			    place_attr->pt_buffer[index+6] =
			    center[index] + (100000.0 * yneg[index]);

			    place_attr->pt_buffer[index+9] =
			    center[index] + (100000.0 * ypos[index]);
			}
		}
	}

	scale = BSlenvec(&bsrc, place_attr->plan_info.win_plan.vec_xpos);

	if (control & MOVE_BREAK_PT)
	{
		if ((me->jogged) && (place_attr->num_jog_pts == 2))
		   control = MOVE_JOG_PT1;
	}

	if (control & MOVE_LEADER_PT)
	{
		/*^ print_point("cursor", cursor); */

		/*| - Project cursor onto the leader line to obtain
		     the leader point - */

		BSproj0(&bsrc, cursor, place_attr->lea_line, leader_pt);

		/*^ print_point(" leader_pt : ", leader_pt); */

		BSmkvec(&bsrc, brak_lead, place_attr->break_pt, leader_pt);

		switch (place_attr->par_loc.txt_orie)
		{
			case TXT_ORIE_HORIZONTAL:

			if(BSdotp(&bsrc, brak_lead,
				place_attr->plan_info.win_plan.vec_xpos) >= 0)
			{
			    if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
				place_attr->txt_just = LEFT_BASE;
			    else place_attr->txt_just = LEFT_CENTER;
			    me->lead_dist = BSlenvec(&bsrc, brak_lead);
			}
			else
			{
			    if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
				place_attr->txt_just = RIGHT_BASE;
			    else place_attr->txt_just = RIGHT_CENTER;
			    me->lead_dist = -BSlenvec(&bsrc, brak_lead);
			}
			break;

			case TXT_ORIE_VERTICAL:

			if(BSdotp(&bsrc, brak_lead,
				place_attr->plan_info.win_plan.vec_ypos) >= 0)
			{
				if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
					place_attr->txt_just = LEFT_BASE;
				else place_attr->txt_just = LEFT_CENTER;

				me->lead_dist = BSlenvec(&bsrc, brak_lead);
			}
			else
			{
				if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
					place_attr->txt_just = RIGHT_BASE;
				else place_attr->txt_just = RIGHT_CENTER;

				me->lead_dist = -BSlenvec(&bsrc, brak_lead);
			}
			break;

			case TXT_ORIE_PERPENDICULAR:

			if (BSdotp(&bsrc, brak_lead,
					place_attr->text_dir) >= 0)
			     me->lead_dist = -BSlenvec(&bsrc, brak_lead);
			else me->lead_dist = BSlenvec(&bsrc, brak_lead);

			if (BSdotp(&bsrc, brak_lead,
				place_attr->plan_info.win_plan.vec_xpos) >= 0)
			{
				if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
					place_attr->txt_just = LEFT_BASE;
				else place_attr->txt_just = LEFT_CENTER;
			}
			else
			{
				if(place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
					place_attr->txt_just = RIGHT_BASE;
				else place_attr->txt_just = RIGHT_CENTER;
			}
			break;

			default:
			printf("ERROR: txt_orie=%d\n",
				place_attr->par_loc.txt_orie);
			return(FALSE);

		}

		me->lead_dist /= scale;

		/*^ printf(" lead_dist : %lf\n", me->lead_dist); */

		/* - Position Text - */

		MAaddvc(&bsrc, leader_pt, place_attr->def_offs, text_pt);

		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_NO_INDEX,
						&place_attr->text_grid,
						md_env,
						place_attr->txt_just,
						text_pt,
						NULL,
						NULL,
						&place_attr->par_loc,
						&place_attr->par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/* - Compute leader line end point - */

		status =
		om$send(msg = message DMdim.get_text_extents(
					&rc,
					box,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		DMcompute_endpt(
			&rc,
			place_attr->break_pt,
			leader_pt,
			(IGRdouble (*)[])box,
			place_attr->par_loc.txt_posn,
			place_attr->plan_info.win_plan.matrix,
			md_env,
			lead_end);

		DMlineptpt(place_attr->break_pt, lead_end, lea_line);

		/* - Position Leader Line - */

		status =
		om$send(msg = message DMroot.position_line(
						&rc,
						DIM_LEADER,
						NULL,
						md_env,
						lea_line),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if ((control & MOVE_JOG_PT1)
	||  (control & MOVE_JOG_PT2))
	{
		/*| - check whether to hilite */

		/*^ print_grid("win_grid",&place_attr->win_grid); */

		if ( control & MOVE_JOG_PT1)
		{
			math_v_equal(src_dir, place_attr->mea_axis);
			src_dir1 = NULL;
			index = 0;
		}
		else
		{
			BSmkvec(&bsrc,
				src_dir,
				&place_attr->jog_line[3],
				place_attr->jog_line);
			BSnorvec(&bsrc, src_dir);

			src_dir1 = place_attr->mea_axis;
			index = 3;
		}

		status =
		DMinquire_hilite(
			cursor,
			&place_attr->jog_line[index],
			target_pt,
			place_attr->center,
			src_dir,
			src_dir1,
			&place_attr->plan_info,
			&place_attr->win_grid,
			&hilite);
		dm$status(action = RET_STATUS);

		for (index=0; index<3; index++)
		{
			xaxis[index] = place_attr->plan_info.act_plan.matrix[index];
			yaxis[index] = place_attr->plan_info.act_plan.matrix[index+4];
		}

		BSnorvec(&bsrc, xaxis);
		BSnorvec(&bsrc, yaxis);

		if (control & MOVE_JOG_PT1)
		{
			/*| - set jog_pt2 offset */

			math_v_offset(
				xaxis,
				yaxis,
				place_attr->jog_line,
				target_pt,
				me->jog_pt1[0],
				me->jog_pt1[1]);

			me->jog_pt1[0] /= scale;
			me->jog_pt1[1] /= scale;

			/*"jog_pt2 = (%lf, %lf)\n", me->jog_pt1[0], me->jog_pt1[1]*/

 			for (index=0; index<3; index++)
			    place_attr->jog_line[index+3] = target_pt[index];

			if (place_attr->num_jog_pts < 2)
			   place_attr->num_jog_pts = 2;

			if (place_attr->num_jog_pts == 2)
			{
				/*|- Initilaise Text info */

				for (index=0; index<3; index++)
			   	    text_pt[index] = place_attr->jog_line[index+3];

				me->brk_pos = BRK_CENTER;

				/*"Brk_pos = %d\n", me->brk_pos*/
			}
			else
			{
				if (me->brk_pos == BRK_ALT_CENTER)
				{
				   BSmkvec(
					&bsrc,
					cent_term,
					&place_attr->jog_line[6],
					&place_attr->jog_line[3]);

				   dist = BSlenvec(&bsrc, cent_term);
				   dist *= me->brk_dist;

				   BSnorvec(&bsrc, cent_term);

				   MATH_ptdelta(
					&rc,
					&place_attr->jog_line[6],
					cent_term,
					dist,
					place_attr->break_pt);
				}

				math_v_equal(text_pt, place_attr->break_pt);

				if (place_attr->num_jog_pts == 3)
				{
				   pt = &place_attr->jog_line[3];
				   pt1 = &place_attr->jog_line[6];

				   math_v_offset(
					xaxis,
					yaxis,
					pt,
					pt1,
					me->jog_pt2[0],
					me->jog_pt2[1]);

					me->jog_pt1[0] /= scale;
					me->jog_pt1[1] /= scale;
 
 			   	   /*"jog_pt3 = (%lf, %lf)\n", me->jog_pt2[0], me->jog_pt2[1]*/
				}
			}
		}
		else
		{
			/*| - set jog_pt3 offset */

			/*^ print_point("jog_pt3", target_pt); */

			pt = &place_attr->jog_line[3];

			math_v_offset(
				xaxis,
				yaxis,
				pt,
				target_pt,
				me->jog_pt2[0],
				me->jog_pt2[1]);

			me->jog_pt2[0] /= scale;
			me->jog_pt2[1] /= scale;

			/*"jog_pt3 = (%lf, %lf)\n", me->jog_pt2[0], me->jog_pt2[1]*/

			for (index=0; index<3; index++)
			   place_attr->jog_line[index+6] = target_pt[index];

			if (place_attr->num_jog_pts < 3)
			   place_attr->num_jog_pts = 3;

			if (me->brk_pos == BRK_ALT_CENTER)
			{
				BSmkvec(
				&bsrc,
				cent_term,
				&place_attr->jog_line[6],
				&place_attr->jog_line[3]);

				dist = BSlenvec(&bsrc, cent_term);
				dist *= me->brk_dist;

				BSnorvec(&bsrc, cent_term);

				MATH_ptdelta(
					&rc,
					&place_attr->jog_line[6],
					cent_term,
					dist,
					place_attr->break_pt);
			}

			math_v_equal(text_pt, place_attr->break_pt);
		}

		/*|- Compute text info */
	
		if ((place_attr->num_jog_pts == 2)
		||  ((place_attr->num_jog_pts == 3)
		&&   (me->brk_pos == BRK_ALT_CENTER)))
		{
			/*|- Compute the new text & offs dir*/

			if (place_attr->num_jog_pts == 2)
			{
				pt = place_attr->jog_line;
				pt1 = &place_attr->jog_line[3];
			}
			else
			{
				pt = &place_attr->jog_line[3];
				pt1 = &place_attr->jog_line[6];
			}

			BSmkvec(&bsrc, xaxis, pt, pt1);
			BSnorvec(&bsrc, xaxis);

			angle = M_PI/2;

			MATH_rotate_vector(
				&rc,
				xaxis,
				angle,
				place_attr->plan_info.act_plan.matrix,
				yaxis);

			if(BSdotp(&bsrc,
				place_attr->plan_info.win_plan.vec_xpos,
				src_dir) > 0.0)
			{
				math_v_equal(place_attr->text_dir,
					xaxis);
				math_v_equal(place_attr->offs_dir,
					yaxis);
			}
			else 
			{
				for(index = 0; index<3; index++)
				{
				   place_attr->text_dir[index] =
					-xaxis[index];
				   place_attr->offs_dir[index] =
					-yaxis[index];
				}
			}
		}

		if (place_attr->par_loc.txt_orie == TXT_ORIE_PARALLEL)
		{
			for (index=0; index<3; index++)
			text_pt[index] += place_attr->def_offs[index];

			if (place_attr->par_loc.txt_posn == TXT_POSN_ABOVE)
				place_attr->txt_just = CENTER_BOTTOM;
			else	place_attr->txt_just = CENTER_CENTER;
		}
		else	place_attr->txt_just = CENTER_CENTER;

		/* - Position Text - */

		/*^ print_point("text_pt", text_pt); */

		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_NO_INDEX,
						&place_attr->text_grid,
						md_env,
						place_attr->txt_just,
						text_pt,
						place_attr->text_dir,
						place_attr->norm_to_plane,
						&place_attr->par_loc,
						&place_attr->par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*|- Make dim line */

		/*^
			printf("num_jog_pts = %d\n",place_attr->num_jog_pts);
			for (index=0; index<place_attr->num_jog_pts; index++)
			printf("jog_pt[%d] = %f,%f,%f\n",index,
				place_attr->jog_line[3*index],
				place_attr->jog_line[3*index+1],
				place_attr->jog_line[3*index+2]);
		*/

		status =
		om$send(msg = message DMradjog.make_dim_line(
					&rc,
					place_attr->num_jog_pts,
					place_attr->center,
					place_attr->term_pt,
					place_attr->mea_axis,
					place_attr->break_pt,
					place_attr->break_pt,
					place_attr->jog_line,
					&place_attr->par_env,
					&place_attr->par_loc,
					&place_attr->plan_info,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - change display properties*/

		if (dynamics_in_progress)
		{
			/*| - Set the display */

			if (control & MOVE_JOG_PT2)
			{
				place_attr->display.color     = 0;
				place_attr->display.weight    = (hilite & LOCKED_TO_CENTER)?2:0;
				place_attr->display.style     = 4;

				place_attr->linex.num_points  = 2;
				place_attr->linex.points      = place_attr->pt_buffer;
	
				place_attr->liney.num_points  = 2;
				place_attr->liney.points      = &place_attr->pt_buffer[6];

				/*| - Builds the display buffer of the two lines */

				dp$build_dis_buffer(
					buffer 	    = place_attr->buffer,
					type        = IGRPY,
					display_att = &place_attr->display,
					geometry    = &place_attr->linex);

				dp$build_dis_buffer(
					buffer      = &place_attr->buffer[1],
					type        = IGRPY,
					display_att = &place_attr->display,
					geometry    = &place_attr->liney);
			}

			place_attr->par_env.dim_weig = (hilite & LOCKED_TO_AXIS_SRC_DIR)?2:0;

			status =
			om$send(msg = message DMroot.chgdp(&rc, &place_attr->par_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		return(OM_S_SUCCESS);
	}

	if (control & MOVE_TRAK_PT)
	{
		/*| - compute radius and center point */

		flag = TRUE;

        if(aflag = pwIsActivationOn())
        { 
         IGRlong ret_msg;
         IGRshort four = 4;
         IGRmatrix tmp_matrix;
         pwGetActiveModuleEnv(&rfenv); 
         MAmulmx(&ret_msg,&four,&four,&four,matrix,rfenv.md_env.matrix,tmp_matrix); 
		 p2[0] = cursor[0] + tmp_matrix[8];
		 p2[1] = cursor[1] + tmp_matrix[9];
		 p2[2] = cursor[2] + tmp_matrix[10];
        }
        else
        {
		 p2[0] = cursor[0] + matrix[8];
		 p2[1] = cursor[1] + matrix[9];
		 p2[2] = cursor[2] + matrix[10];
        }

		boreline.point1 = cursor;
		boreline.point2 = p2;

		md_env2.md_env.matrix_type = 
				md_env->md_env.matrix_type;
		for ( i = 0; i < 16; i++)
			md_env2.md_env.matrix[i] = 			
				md_env->md_env.matrix[i];
		status =
                om$send(msg = message NDnode.ASreturn_go(
                                        &go_grid2,
                                        &md_env2.md_env.matrix_type,
                                        md_env2.md_env.matrix),
                        targetid = place_attr->list[DIM_RAD_CURVE].objid,
                        targetos = place_attr->list[DIM_RAD_CURVE].osnum);
                dm$status(action = RET_STATUS);

      		status =
                om$send(msg = message DMsrc.DMmodify(
                                                &rc,
                                                &md_env2,
                                                FALSE,
                                                FALSE,
                                                &boreline),
                        targetid = go_grid2.objid,
                        targetos = go_grid2.osnum);
                dm$status(action = RET_STATUS);

		status =
		DMsrc_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			FALSE,
			place_attr->list[DIM_RAD_CURVE].objid,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&dim_str);
		dm$status(action = RET_STATUS);

		math_v_equal(place_attr->center, dim_str.var.dm_radcen.center);
		math_v_equal(pt_on_curve, dim_str.var.dm_radcen.point);
		const_radius = fabs(place_attr->dimn_value -
				 dim_str.var.dm_radcen.radius) > 1e-08;

		place_attr->dimn_value = dim_str.var.dm_radcen.radius;
		on_curve = dim_str.var.dm_radcen.on_curve;

		/*| - update dimension plane orientation matrix - */

		for(index = 0; index < 3; index ++)
		{
		   place_attr->plan_info.win_plan.matrix[4*index + 3] =
		   place_attr->plan_info.act_plan.matrix[4*index + 3] =
		   place_attr->pt_on_plane[index] = pt_on_curve[index];
		}

		/*^ print_point("cursor", cursor); */

		/*START FIX*/
		if( ( me->geom_type & DIM_IMPORTED) || !on_curve)
		/*END FIX*/
		{
			/*| if projection point not curve */

			me->mea_trak = TRUE;

			/*| - compute vector for point projection direction */

			BSmkvec(&bsrc, cent_cursor, place_attr->center, cursor);
			BSnorvec(&bsrc, cent_cursor);
	
			BSmkvec(&bsrc, cent_cvpt, place_attr->center, pt_on_curve);
			BSnorvec(&bsrc, cent_cvpt);

			/*^ print_point(" cent_cvpt :",cent_cvpt); */

			if(acos(BSdotp(&bsrc, cent_cursor, cent_cvpt)) > PI/2.0)
			  math_v_opposite(cent_cursor, cent_cursor);

			/*| - Find projection point on the imaginary circle */

			MATH_ptdelta(&rc,
				place_attr->center,
				cent_cursor,
				place_attr->dimn_value,
				place_attr->term_pt);

			/*^ print_point(" term_pt :", place_attr->term_pt); */

			BSmkvec(&bsrc, cvpt_term, pt_on_curve, place_attr->term_pt);
			BSnorvec(&bsrc, cvpt_term);

			/*^ print_point(" cvpt_term :",cvpt_term); */

			status = BScrossp(&bsrc, cent_cvpt, cvpt_term, cross_vec);

			if ( BSdotp( &bsrc, cross_vec,
				place_attr->norm_to_plane) >= 0)
			{
				me->trak_dist = acos( BSdotp(&bsrc,
							cent_cursor,
							cent_cvpt));
			}
			else
			{	
				me->trak_dist = -acos( BSdotp(&bsrc,
							cent_cursor,
							cent_cvpt));
			}

			delta_theta =   place_attr->proj_offs /
					place_attr->dimn_value;

			if (me->trak_dist < 0.0)
				delta_theta = - delta_theta;

			/*^
				printf(" dotproduct : %f\n",dotproduct);
				printf(" me->trak_dist : %f\n",me->trak_dist);
				printf(" delta_theta cvpt : %f\n",delta_theta);
			*/

			MATH_rotate_vector(
				&rc,
				cent_cvpt,
				delta_theta,
				place_attr->plan_info.act_plan.matrix,
				cent_delpt);

			/*^ print_point(" cent_delpt :",cent_delpt); */

			MATH_ptdelta(&rc,
				place_attr->center,
				cent_delpt,
				place_attr->dimn_value,
				arc_info.startpt);

			delta_theta =   place_attr->proj_extn /
					place_attr->dimn_value;

			if (me->trak_dist < 0.0)
				delta_theta = - delta_theta;

			/*^
				printf(" delta_theta term : %f\n",delta_theta);
			*/

			MATH_rotate_vector(
				&rc,
				cent_cursor,
				delta_theta,
				place_attr->plan_info.act_plan.matrix,
				cent_delpt);

			/*^ print_point(" cent_delpt :",cent_delpt); */

			MATH_ptdelta(&rc,
				place_attr->center,
				cent_delpt,
				place_attr->dimn_value,
				arc_info.endpt);

			for(index = 0; index < 3; index++)
				arc_info.centerpt[index] = 
				place_attr->center[index];

			arc_info.needed = TRUE;

			/*^
				print_point(" start_pt :",arc_info.startpt);
				print_point(" end_pt :",arc_info.endpt);
			*/

		}
		else
		{
			me->mea_trak = FALSE;
			arc_info.needed = FALSE;
			math_v_equal(place_attr->term_pt, pt_on_curve);

			/*^ print_point(" term_pt : ",place_attr->term_pt); */
		}

		/*| - Projection Arc- */

		status =
		om$send(msg = message DMradjog.make_proj_arc(
						&rc,
						&place_attr->par_env,
						&place_attr->par_loc,
						&place_attr->plan_info,
						&arc_info,
						md_env),
				targetid = my_id);
		dm$status(action = RET_STATUS);

	}
	else	const_radius = TRUE;

	if( me->dim_type == RADIAL_DIAMETER)
	{
		/*| dimension is radial diameter */
	
		BSmkvec(&bsrc, dia_line, place_attr->term_pt, place_attr->center);
		BSnorvec(&bsrc, dia_line);

		sca_value = place_attr->dimn_value * scale;

		for(index=0; index<3; index++)
		    center[index] = place_attr->center[index] +
				    dia_line[index] * sca_value;
		dimn_value = place_attr->dimn_value * 2;
	}
	else
	{
		math_v_equal(center, place_attr->center);
		dimn_value = place_attr->dimn_value;
	}

	if (control & MOVE_JOG_BREAK_PT)
	{
		/* - Compute Jog/Break Point Position - */

		BSmkvec(&bsrc, cent_term, center, place_attr->term_pt);
		BSnorvec(&bsrc, cent_term);

		status =
		DMcompute_break_pt(
			FALSE,
			&brk_pos,
			&brk_dist,
			cursor,
			brk_pt,
			center,
			place_attr->term_pt);
		dm$status(action = RET_STATUS);

		if (me->dim_state & DIM_IN_PLACEMENT)
		{
		   /*|- Dimension in placement, check if jog is valid*/

		   if ((Dim_rad_jog)
		   &&  (brk_pos == BRK_CENTER)
		   &&  (me->dim_type == RADIAL))
		   {
			/*|- Jog dimension */

			me->jogged = TRUE;
			me->lead_dist = brk_dist / scale;
                	math_v_equal(place_attr->jog_line, brk_pt);

			if (place_attr->num_jog_pts < 0)
			   place_attr->num_jog_pts = 1;

			for (index=0; index<3; index++)
			    place_attr->break_pt[index] =
			    (place_attr->jog_line[index] + place_attr->term_pt[index]) * 0.5;

			me->brk_dist = 0.5;
			me->brk_pos = BRK_CENTER;
		   }
		   else
		   {
			me->jogged = FALSE;
			
			me->brk_pos = brk_pos;

			if ((me->brk_pos == BRK_CENTER)
			&&  (place_attr->misc_param.aut_cent))
			{
			   me->brk_dist = 0.5;

			   for (index=0; index<3; index++)
			   place_attr->break_pt[index] = (center[index]
			   	+ place_attr->term_pt[index]) * 0.5;
			}
			else
			{
			   me->brk_dist = brk_dist / scale;
			   math_v_equal(place_attr->break_pt, brk_pt);
			}
		   }
		}
		else
		{
		   if (!(control & MOVE_BREAK_PT))
		   {
			/*|- Move Jog_pt1 */

		   	if (brk_pos == BRK_CENTER)
		   	{
			   /*|- Jog dimension */

			   me->lead_dist = brk_dist / scale;
                	   math_v_equal(place_attr->jog_line, brk_pt);

			}
			else
			{
			   if (brk_pos == BRK_RIGHT)
			   	me->lead_dist = 1.0;
			   else me->lead_dist = 0.0;

                	   math_v_equal(place_attr->jog_line, brk_pt);
			}

			if (place_attr->num_jog_pts > 1)
			{
			   pt = &place_attr->jog_line[3];

			   math_v_offset(
				place_attr->plan_info.win_plan.vec_xpos,
				place_attr->plan_info.win_plan.vec_ypos,
				place_attr->jog_line,
				pt,
				me->jog_pt1[0],
				me->jog_pt1[1]);

			   me->jog_pt1[0] /= scale;
			   me->jog_pt1[1] /= scale;

			   /*"jog_pt2 = (%lf, %lf)\n", me->jog_pt1[0], me->jog_pt1[1]*/
			}

			if (place_attr->num_jog_pts == 3)
			{
			   pt = &place_attr->jog_line[3];
			   pt1 = &place_attr->jog_line[6];

			   math_v_offset(
				place_attr->plan_info.win_plan.vec_xpos,
				place_attr->plan_info.win_plan.vec_ypos,
				pt,
				pt1,
				me->jog_pt2[0],
				me->jog_pt2[1]);

			   me->jog_pt1[0] /= scale;
			   me->jog_pt1[1] /= scale;
 
 			   /*"jog_pt3 = (%lf, %lf)\n", me->jog_pt2[0], me->jog_pt2[1]*/
			}

			if (me->brk_pos == BRK_CENTER)
			{
			   for (index=0; index<3; index++)
			   place_attr->break_pt[index] =
			   place_attr->jog_line[index] +
			   (cent_term[index] * me->brk_dist);
			}
		   }
		   else
		   {
			/*|- Move Break Point */
			if (me->jogged)
		   	{
			   status =
			   DMcompute_break_pt(
				TRUE,
				&brk_pos,
				&brk_dist,
				cursor,
				brk_pt,
				place_attr->jog_line,
				place_attr->term_pt);
			   dm$status(action = RET_STATUS);

		   	   if (place_attr->num_jog_pts == 1)
		    	   {
			   	/*|- Single segment */

				   if (brk_pos == BRK_CENTER)
				      me->brk_dist = brk_dist / scale;

				   math_v_equal(place_attr->break_pt, brk_pt);
			   }
			   else
			   {
			   	/*|- Three segement */

				status =
				DMcompute_break_pt(
					TRUE,
					&brk_pos1,
					&brk_dist1,
					cursor,
					brk_pt1,
					&place_attr->jog_line[6],
					&place_attr->jog_line[3]);
				dm$status(action = RET_STATUS);

				if ((brk_pos == BRK_CENTER)
				&&  (brk_pos1 == BRK_CENTER))
				{
				    /*|- Take the closest point as brk_point*/
	
				    dist = BSdistptpt(&bsrc, cursor, brk_pt);
				    dist1 = BSdistptpt(&bsrc, cursor, brk_pt1);
	
				    if (dist > dist1)
				    {
				        me->brk_pos = BRK_ALT_CENTER;
					me->brk_dist = brk_dist1 / scale;
					math_v_equal(place_attr->break_pt, brk_pt1);
				    }
				    else
				    {
					me->brk_pos = BRK_CENTER;
					me->brk_dist = brk_dist / scale;
					math_v_equal(place_attr->break_pt, brk_pt);
				    }
				}
				else if (brk_pos == BRK_CENTER)
				{
				    /*|- Text on first segment*/
	
				    me->brk_pos = BRK_CENTER;
				    me->brk_dist = brk_dist / scale;
				    math_v_equal(place_attr->break_pt, brk_pt);
				}
				else if (brk_pos1 == BRK_CENTER)
				{
				    /*|- Text on third segment*/

				    me->brk_pos = BRK_ALT_CENTER;
				    me->brk_dist = brk_dist1 / scale;
				    math_v_equal(place_attr->break_pt, brk_pt1);
				}
				else
				{
				    /*|- Text point outside the segments*/
				    dist = BSdistptpt(&bsrc, cursor, brk_pt);
				    dist1 = BSdistptpt(&bsrc, cursor, brk_pt1);

				    if (dist > dist1)
				    {
					me->brk_dist = brk_dist1;
					math_v_equal(place_attr->break_pt, brk_pt1);
				    }
				    else
				    {
					me->brk_dist = brk_dist;
					math_v_equal(place_attr->break_pt, brk_pt);
				    }
				}
			   }
		   	}
			else
			{
			   me->brk_pos = brk_pos;
			   me->brk_dist = brk_dist / scale;
			   math_v_equal(place_attr->break_pt, brk_pt);
			}
		   }			
		}

		/*^
			printf("brk_pos = %d\n", me->brk_pos);
			printf("brk_dist = %f\n", me->brk_dist);
			print_point("break_pt", place_attr->break_pt);
		*/
	}
	else
	{
		status =
		om$send(msg = message DMradjog.compute_jog_line(
						&rc,
						&place_attr->num_jog_pts,
						center,
						place_attr->term_pt,
						cent_term,
						place_attr->jog_line,
						&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - Compute break point */
		
		status =
		om$send(msg = message DMradjog.compute_break_pt(
						&rc,
						center,
						place_attr->term_pt,
						cent_term,
						dimn_value,
						place_attr->jog_line,
						place_attr->break_pt,
						&place_attr->plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - Compute Leader Point Position - */

		status =
		om$send(msg = message DMradjog.compute_lead_pt(
						&rc,
						center,
						place_attr->term_pt,
						place_attr->break_pt,
						&place_attr->par_loc,
						&place_attr->plan_info,
						leader_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*^ print_point("leader_pt", leader_pt); */

	}

	/*| - Dimension Text */

	if (control & MOVE_TEXT_POS)
	{
		if (me->leader)
		{
			for (index=0; index<3; index++)
			text_pt[index] = leader_pt[index] + 
					place_attr->def_offs[index];
		}
		else if (place_attr->par_loc.txt_orie == TXT_ORIE_PARALLEL)
		{
			for (index=0; index<3; index++)
			text_pt[index] = place_attr->break_pt[index] +
					place_attr->def_offs[index];
		}
		else
		{
			math_v_equal(text_pt, place_attr->break_pt);
		}

		for (index=0; index<3; index++)
		{
			xaxis[index] = place_attr->plan_info.act_plan.matrix[index];
			yaxis[index] = place_attr->plan_info.act_plan.matrix[index+4];
		}

		BSnorvec(&bsrc, xaxis);
		BSnorvec(&bsrc, yaxis);

		me->offs_pt[0] =
		xaxis[0] * (cursor[0] - text_pt[0]) +
		xaxis[1] * (cursor[1] - text_pt[1]) +
		xaxis[2] * (cursor[2] - text_pt[2]);

		me->offs_pt[0] = me->offs_pt[0]/ scale;

		me->offs_pt[1] =
		yaxis[0] * (cursor[0] - text_pt[0]) +
		yaxis[1] * (cursor[1] - text_pt[1]) +
		yaxis[2] * (cursor[2] - text_pt[2]);

		me->offs_pt[1] = me->offs_pt[1]/ scale;

		/*"offs_pt=(%lf, %lf)\n", me->offs_pt[0], me->offs_pt[1]*/

		math_v_equal(text_pt, cursor);

		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_NO_INDEX,
						&place_attr->text_grid,
						md_env,
						-1,
						text_pt,
						NULL,
						NULL,
						&place_attr->par_loc,
						&place_attr->par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		if (const_radius)
		{
			status =
			om$send(msg = message DMdim.make_text_string(
							&rc,
							dimn_value,
							md_env,
							&place_attr->par_env,
							&place_attr->par_loc,
							NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message DMradjog.make_dim_text(
					&rc,
					place_attr->num_jog_pts,
					center,
					place_attr->term_pt,
					dimn_value,
					place_attr->break_pt,
					leader_pt,
					place_attr->jog_line,
					&place_attr->par_env,
					&place_attr->par_loc,
					&place_attr->plan_info,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| - Terminators - */

	/*^ print_point(" cent_term : ", cent_term); */

	status =
	om$send(msg = message DMradjog.make_dim_term(
					&rc,
					center,
					place_attr->term_pt,
					cent_term,
					&place_attr->par_env,
					&place_attr->par_loc,
					&place_attr->plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_point(" cent_term : ", cent_term); */

	/*| - Dimension Line - */

	status =
	om$send(msg = message DMradjog.make_dim_line(
					&rc,
					place_attr->num_jog_pts,
					center,
					place_attr->term_pt,
					cent_term,
					place_attr->break_pt,
					leader_pt,
					place_attr->jog_line,
					&place_attr->par_env,
					&place_attr->par_loc,
					&place_attr->plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRshort *projection_required;
	IGRshort *const_radius;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble *dimn_value;
	struct DMdim_arc *arc_info;
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc)
{
	IGRshort	status;
	IGRint		index, rc;
	IGRdouble	proj_offs, proj_extn;
	IGRdouble	pt_on_curve[3];
	IGRdouble	delta_theta;
	IGRdouble	cent_term[3], cent_cvpt[3], cent_delpt[3];
	struct dim_ret_struct dim_rst;
	BSrc		bsrc;

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMradjog.get_dimension_plane(
						&rc,
						md_env,
						plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Get dimension parameters - */

	status =
	om$send(msg = message DMdim.get_active_params(&rc, par_env, par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	proj_offs = par_env->proj_offs_r * par_env->txt_heig;
	proj_extn = par_env->proj_extn_r * par_env->txt_heig;

	status =
	DMsrc_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		FALSE,
		list[DIM_RAD_CURVE].objid,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&dim_rst);
	dm$status(action = RET_STATUS);

	*projection_required = TRUE;
	*const_radius = FALSE;

	math_v_equal(center, dim_rst.var.dm_radcen.center);
	math_v_equal(pt_on_curve, dim_rst.var.dm_radcen.point);
	*dimn_value = dim_rst.var.dm_radcen.radius;

	if(me->mea_trak)
	{
		/*| projection arc present */

		BSmkvec(&bsrc, cent_cvpt, center, pt_on_curve);
		BSnorvec(&bsrc, cent_cvpt);

		/*^ printf(" arc_angle : %f\n", me->trak_dist); */

		MATH_rotate_vector(
			&rc,
			cent_cvpt,
			me->trak_dist,
			plan_info->act_plan.matrix,
			cent_term);

		/*^ print_point(" cent_term : ", cent_term); */

		MATH_ptdelta(&rc,
			center,
			cent_term,
			*dimn_value,
			term_pt);

		/*^ print_point(" term_pt : ", term_pt); */

		delta_theta = proj_offs / *dimn_value;

		if(me->trak_dist < 0.0) delta_theta = - delta_theta;

		/*^ printf(" delta_theta cent : %f\n", delta_theta); */

		MATH_rotate_vector(
		&rc,
		cent_cvpt,
		delta_theta,
		plan_info->act_plan.matrix,
		cent_delpt);

		MATH_ptdelta(&rc,
			center,
			cent_delpt,
			*dimn_value,
			arc_info->startpt);

		delta_theta = proj_extn / *dimn_value;

		if(me->trak_dist < 0.0) delta_theta = - delta_theta;

		/*^ printf(" delta_theta term : %f\n", delta_theta); */

		MATH_rotate_vector(
			&rc,
			cent_term,
			delta_theta,
			plan_info->act_plan.matrix,
			cent_delpt);

		MATH_ptdelta(&rc,
			center,
			cent_delpt,
			*dimn_value,
			arc_info->endpt);

		arc_info->needed = TRUE;
		for(index = 0; index < 3; index ++)
			arc_info->centerpt[index] = center[index];

		/*^
			print_point(" start_pt :",arc_info->startpt);
			print_point(" end_pt :",arc_info->endpt);
		*/

	}
	else
	{
		/*| projection arc absent */

		math_v_equal(term_pt, pt_on_curve);
		arc_info->needed = FALSE;
	}

	return(OM_S_SUCCESS);
}

end implementation DMradjog;
