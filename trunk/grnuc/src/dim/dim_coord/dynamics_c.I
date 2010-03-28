class implementation DMcoordj;

#define AS_DEBUG 1

#include "dimmod.h"

extern IGRboolean 	BSproj0(), BSproj1(), BSnorvec(), BSmkvec();
extern double 		BSdotp(), BSlenvec(), fabs();

method dynamics(
	IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar *info;
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	IGRint status, rc, count, index, proj_index, val;
	IGRint hilite=FALSE;
	struct DMdyn_coord *place_attr;
	struct GRid list[NO_CPX_DIM_ROOTS], first, dim_grid;
	struct DMtrak_info trak_info;
	IGRdouble dimn_value, trak_dist, dist1, dist2;
	IGRdouble txt_P[3];
	IGRdouble term_pos[6];
	IGRpoint  p1, p2, p3, p4;
	IGRvector v1, v2, v3, v4;
	IGRdouble orig_meas[3];
	IGRdouble mea_line[6];
	IGRdouble *oldpt, txt_heig, *txt_dir=NULL;
	IGRchar mea_trak;
	IGRboolean dimline_valid;
	IGRdouble trak_orig[3], box[12];
	IGRdouble *pt, *pt1;
	extern IGRboolean dynamics_in_progress;
	extern IGRboolean Dim_coord_jog;

	place_attr = (struct DMdyn_coord *)info + (*level);

	if (me->dim_state & DIM_IN_PLACEMENT)
	{
		/*|- Set the global Jogged value in instance*/

		me->jogged = Dim_coord_jog;
	}

	if (me->dim_state & DIM_NEEDS_UPDATE)
	{
		/*| - update Dimensions */

		status =
		om$send(msg = message NDnode.NDs_compute_node(
						(IGRlong *)&rc,
						NULL,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if(control == NULL) return(OM_S_SUCCESS);

		control |= FILL_INFO;
	}

	if (control & FILL_INFO)
	{
		/*|- Fill info*/

		status =
		om$send(msg = message DMroot.DMreturn_roots(&count, list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMcoordj.gather_data(
					&rc,
					count,
					list,
					md_env,
					place_attr->orig_P,
					place_attr->meas_P,
					place_attr->cpx_orig_P,
					&place_attr->plan_info,
					&place_attr->par_env,
					&place_attr->par_loc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.get_first_in_cpx(
							&rc,
							&first),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		place_attr->first_in_cpx = (first.objid == my_id);

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

		if (rc != DIM_S_SUCCESS)
		{
			/*|- Dimension Trak Zone does not match*/

			if (me->dim_state & DIM_IN_PLACEMENT)
			{
				/*|- First Compute, trak_zone is yet to be initailised*/

				if (place_attr->first_in_cpx)
				   me->mea_trak |= DM_TRAK_ZONE1;
				math_v_equal(trak_orig, place_attr->meas_P);
				trak_dist = place_attr->par_env.txt_heig *
					place_attr->par_env.lin_offs_r;
			}
		}

		status =
		om$send(msg = message DMcoordj.compute_trak_pt(
						&rc,
						mea_trak,
						trak_orig,
						trak_dist,
						&place_attr->plan_info,
						place_attr->trak_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (place_attr->first_in_cpx)
		{
			place_attr->pri_trak_zone =
				(me->mea_trak & DM_TRAK_ZONE1)?
				DM_TRAK_ZONE1:DM_TRAK_ZONE2;
		}

		if (mea_trak & DM_MEA_AXIS)
		{
			/*| mea_axis : x  perp_axis : y */

			math_v_equal(place_attr->mea_axis,
				place_attr->plan_info.act_plan.vec_xpos);

			math_v_equal(place_attr->perp_axis,
				place_attr->plan_info.act_plan.vec_ypos);

			if (mea_trak & DM_TRAK_DIR)
			{
				math_v_equal(place_attr->trak_dir,
				place_attr->plan_info.act_plan.vec_ypos);
			}
			else
			{
				math_v_equal(place_attr->trak_dir,
				place_attr->plan_info.act_plan.vec_yneg);
			}
		}
		else
		{
			/*| mea_axis : y  perp_axis : x */


			math_v_equal(place_attr->mea_axis,
				place_attr->plan_info.act_plan.vec_ypos);

			math_v_equal(place_attr->perp_axis,
				place_attr->plan_info.act_plan.vec_xpos);

			if (mea_trak & DM_TRAK_DIR)
			{
				math_v_equal(place_attr->trak_dir,
				place_attr->plan_info.act_plan.vec_xpos);
			}
			else
			{
				math_v_equal(place_attr->trak_dir,
				place_attr->plan_info.act_plan.vec_xneg);
			}
		}

		status =
		om$send(msg = message DMcoordj.compute_jog_line(
						&place_attr->num_jog_pts,
						mea_trak,
						place_attr->meas_P,
						place_attr->trak_pt,
						place_attr->jog_line,
						&place_attr->plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (((control & MOVE_TRAK_PT)
		||  (control & MOVE_BREAK_PT)
		||  (control & MOVE_JOG_PT2))
		&& !place_attr->first_in_cpx)
		{
			/*|- Compute primary trak pt*/

			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			mea_trak = trak_info.mea_trak;

			place_attr->pri_trak_zone =
				(mea_trak & DM_TRAK_ZONE1)?
				DM_TRAK_ZONE1:DM_TRAK_ZONE2;

			status =
			om$send(msg = message DMcoordj.find_mea_trak_info(
							&rc,
							TRUE,
							TRUE,
 							place_attr->pri_trak_zone,
							&mea_trak,
							&trak_dist,
							trak_orig,
							&dim_grid,
							md_env),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);
	
			status =
			om$send(msg = message DMcoordj.compute_trak_pt(
							&rc,
							mea_trak,
							trak_orig,
							trak_dist,
							&place_attr->plan_info,
							place_attr->pri_trak_pt),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*^ print_point("pri_trak_pt", place_attr->pri_trak_pt); */

			mea_trak = 0;

			if (trak_info.mea_trak & DM_TRAK_ZONE1)
			   place_attr->sec_trak_zone = DM_TRAK_ZONE2;
			else
			   place_attr->sec_trak_zone = DM_TRAK_ZONE1;

			place_attr->sec_trak_pt[0] =
			place_attr->sec_trak_pt[1] =
			place_attr->sec_trak_pt[2] = 0.0;

			/*|- Compute secondary trak pt*/

			status =
			om$send(msg = message DMcoordj.find_mea_trak_info(
							&rc,
							TRUE,
							TRUE,
 							place_attr->sec_trak_zone,
							&mea_trak,
							&trak_dist,
							trak_orig,
							&dim_grid,
							md_env),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			if (rc)
				place_attr->sec_trak = TRUE;
			else	place_attr->sec_trak = FALSE;

			if ((dim_grid.objid == my_id)
			||  (me->mea_trak & DM_TRAK_CTRL_DIM))
				place_attr->sec_trak_dim = TRUE;
			else	place_attr->sec_trak_dim = FALSE;

			/*^
				printf("secondary_trak = %d\n", place_attr->sec_trak);
				printf("secondary_trak_dim = %d\n", place_attr->sec_trak_dim);
			*/

			if (place_attr->sec_trak)
			{
				status =
				om$send(msg = message DMcoordj.compute_trak_pt(
							&rc,
							mea_trak,
							trak_orig,
							trak_dist,
							&place_attr->plan_info,
							place_attr->sec_trak_pt),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				/*^ print_point("sec_trak_pt", place_attr->sec_trak_pt); */
			}
		}

		if ((control & MOVE_ORIG_PT)
		||  (control & MOVE_MEAS_PT)
		||  (control & MOVE_JOG_PT)
		||  (control & MOVE_JOG_PT1)
		||  (control & MOVE_JOG_PT2))
		{
			status =
			om$send(msg = message DMcoordj.compute_proj_term(
							&rc,
							&dimline_valid,
							place_attr->trak_pt,
							&place_attr->par_env,
							&place_attr->plan_info,
							md_env,
							place_attr->orig_P,
							place_attr->cpx_orig_P,
							place_attr->meas_P,
							&dimn_value,
							txt_P,
							orig_meas,
							place_attr->term_ori,
							place_attr->term_mea,
							place_attr->jog_line),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (control & MOVE_JOG_PT2)
			{
				DMlineptvec(
					&place_attr->jog_line[6],
					place_attr->trak_dir,
					place_attr->proj_line);
			}
			else
			{
				DMlineptvec(
					place_attr->jog_line,
					place_attr->trak_dir,
					place_attr->proj_line);
			}
		}

		place_attr->proj_extn = place_attr->par_env.proj_extn_r
					* place_attr->par_env.txt_heig;

		place_attr->proj_offs = place_attr->par_env.proj_offs_r
					* place_attr->par_env.txt_heig;

		control &= ~FILL_INFO;
	}

	/*^
		print_point("orig_P", place_attr->orig_P);
		print_point("meas_P", place_attr->meas_P);
		print_point("cursor", cursor);
	*/

	if (control & MOVE_JOG_TRAK_PT)
	{
		/*|- Move Jog/Trak point */

		if (me->jogged)
			control &= ~MOVE_TRAK_PT;
		else	control &= ~MOVE_JOG_PT;

		/*"me->jogged = %d\n", me->jogged*/
	}

	hilite = FALSE;

	if ((control & MOVE_ORIG_PT) ||	(control & MOVE_MEAS_PT))
	{
		/*| Move projection line */

		/* -
			Project cursor onto the projection line
			to obtain the new orig point and
			compute offset distance and direction 
		- */

		if(control & MOVE_ORIG_PT)
		{
			/*| Move origin projection line */

			oldpt = place_attr->orig_P;
			index = 0;
		}
		else
		{
			/*| Move measure projection line */

			oldpt = place_attr->meas_P;
			index = 1;
		}

		BSproj0(&rc, cursor, place_attr->proj_line, p1);
		BSmkvec(&rc, v1, oldpt, p1);

		if(BSdotp(&rc, place_attr->trak_dir, v1) >= 0.0)
			me->prj_offs[index] = BSlenvec(&rc, v1);
		else	me->prj_offs[index] = -BSlenvec(&rc, v1);

		/*^
			printf("me->prj_offs[%d] = %f\n",index,me->prj_offs[index]);
		*/

		status =
		om$send(msg = message DMcoordj.make_proj_line(
						&rc,
						&place_attr->par_env,
 						&place_attr->par_loc,
						&place_attr->plan_info,
						place_attr->orig_P,
						place_attr->meas_P,
						place_attr->term_ori,
						place_attr->term_mea,
						place_attr->jog_line,
						md_env),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (control & MOVE_JOG_PT
	||  control & MOVE_JOG_PT1)
	{
		if (place_attr->first_in_cpx)
		{
			proj_index = DIM_ORI_PROJ;
			oldpt = place_attr->orig_P;
		}
		else
		{
			proj_index = DIM_MEA_PROJ;
			oldpt = place_attr->meas_P;
		}

		if (control & MOVE_JOG_PT)
		{
			/*| Move Jog point*/
	
			BSproj0(&rc, cursor, place_attr->proj_line, p1);
			BSmkvec(&rc, v1, oldpt, p1);

			if(BSdotp(&rc, place_attr->perp_axis, v1) >= 0.0)
				me->brk_dist = BSlenvec(&rc, v1);
			else	me->brk_dist = -BSlenvec(&rc, v1);

			for (index=0; index <3; index++)
			    place_attr->jog_line[index + 3] = p1[index];

			if (me->dim_state & DIM_IN_PLACEMENT)
			   place_attr->num_jog_pts = 2;

			if (place_attr->num_jog_pts > 2)
			{
				/*|- Set the offsets correctly */

				pt = &place_attr->jog_line[3];
				pt1 = &place_attr->jog_line[6];

				math_v_offset(
					place_attr->plan_info.win_plan.vec_xpos,
					place_attr->plan_info.win_plan.vec_ypos,
					pt,
					pt1,
					me->jog_pt[0],
					me->jog_pt[1]);

				/*"jog_pt2 = (%lf, %lf)\n", me->jog_pt[0], me->jog_pt[1]*/
			}
		}	
		else
		{
			/*|- Move jog point 1 */

			pt = &place_attr->jog_line[3];

			math_v_offset(
				place_attr->plan_info.win_plan.vec_xpos,
				place_attr->plan_info.win_plan.vec_ypos,
				pt,
				cursor,
				me->jog_pt[0],
				me->jog_pt[1]);

			/*"jog_pt2 = (%lf, %lf)\n", me->jog_pt[0], me->jog_pt[1]*/

			for (index=0; index<3; index++)
			    place_attr->jog_line[index+6] = cursor[index];

			if (me->dim_state & DIM_IN_PLACEMENT)
				place_attr->num_jog_pts = 3;

			if (place_attr->num_jog_pts > 3)
			{
				/*|- Compute the 3rd Jog pt*/

				DMlineptvec(
					place_attr->trak_pt,
					place_attr->mea_axis,
					mea_line);

				BSproj0(&rc,
					&place_attr->jog_line[6],
					mea_line,
					p2);

				if (me->mea_trak & DM_TRAK_CTRL_DIM)
				{
				    for (index=0; index<3; index++)
					place_attr->jog_line[index+9] = p2[index];
				}
				else
				{
					MATH_ptdelta(
						&rc,
						p2,
						place_attr->trak_dir,
						me->trak_dist,
						&place_attr->jog_line[9]);
				}
			}
		}

		/*|- Position text */

		if (place_attr->num_jog_pts == 3)
		{
			/*| jog pts is 2 position text at center*/

			switch(place_attr->par_loc.txt_orie)
			{
				case TXT_ORIE_HORIZONTAL:
	
				txt_dir = place_attr->plan_info.win_plan.vec_xpos;
				break;

				case TXT_ORIE_VERTICAL:
	
				txt_dir = place_attr->plan_info.win_plan.vec_ypos;
				break;

				case TXT_ORIE_PARALLEL:
	
				txt_dir = place_attr->perp_axis;
				break;

				case TXT_ORIE_PERPENDICULAR:
	
				txt_dir = place_attr->mea_axis;
				break;

				default:
				/*"illegal txt_orientation"*/
				break;
			}

			status =
			om$send(msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_TEXT,
						NULL,
						md_env,
						CENTER_CENTER,
						cursor,
						txt_dir,
						&place_attr->plan_info.win_plan.matrix[8],
						&place_attr->par_loc,
						&place_attr->par_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else if (!((place_attr->num_jog_pts == 4)
		&& (control & MOVE_JOG_PT)))
		{
			val = (place_attr->num_jog_pts-1) * 3;

			MATH_ptdelta(
				&rc,
				&place_attr->jog_line[val],
				place_attr->trak_dir,
				place_attr->proj_extn,
				txt_P);

			status =
			om$send(msg = message DMcoordj.make_dim_text(
					&rc,
					place_attr->meas_P,
					txt_P,
					dimn_value,
					&place_attr->par_env,
					&place_attr->par_loc,
					&place_attr->plan_info,
					md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		MATH_ptdelta(
			&rc,
			oldpt,
			place_attr->trak_dir,
			(place_attr->proj_offs +
			(place_attr->first_in_cpx) ?
			me->prj_offs[0]:me->prj_offs[1]),
			place_attr->jog_line);

		status =
		om$send(msg = message DMdim.get_text_extents(
						&rc,
						box,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if ((place_attr->par_loc.ctxt_posn == TXT_POSN_ABOVE)
		&&  ((place_attr->par_loc.txt_orie == TXT_ORIE_PARALLEL)
		||   (place_attr->par_loc.txt_orie == TXT_ORIE_PERPENDICULAR))
		&&  !(control & MOVE_JOG_PT1))
		{
			/*| Find the length of text */

			val = place_attr->num_jog_pts;

			MATH_line_extend(
				&rc,
				&place_attr->jog_line[(val-2)*3],
				&place_attr->jog_line[(val-1)*3],
				(IGRdouble (*)[])box,
				p2);

			for (index=0; index<3; index++)
			    place_attr->jog_line[(val-1)*3+index] = p2[index];
		}
		else
		{
			index = place_attr->num_jog_pts;

			MATH_ptdelta(&rc,
				&place_attr->jog_line[(index-1)*3],
				place_attr->trak_dir,
				place_attr->proj_extn,
				p2);
	
			MATH_line_break(
				&rc,
				&place_attr->jog_line[(index-2)*3],
				p2,
				place_attr->plan_info.win_plan.matrix,
				(IGRdouble (*)[])box,
				&place_attr->jog_line[(index-1)*3]);
		}

		/*^
			for (index=0; index<place_attr->num_jog_pts; index++)
			{
				printf("jog_pt[%d] = %f,%f,%f\n", index,
				   place_attr->jog_line[index*3],
				   place_attr->jog_line[(index*3)+1],
				   place_attr->jog_line[(index*3)+2]);
			}
		*/

		status =
		om$send(msg = message DMroot.position_line_string(
						&rc,
						proj_index,
						(struct GRid *)NULL,
						md_env,
						place_attr->num_jog_pts,
						place_attr->jog_line),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*|- During Jog dynamics delete dimline & Terminator*/

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_LINE1,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						(place_attr->first_in_cpx)?
						DIM_ORI_TERM:DIM_MEA_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if ((control & MOVE_TRAK_PT)
	||  (control & MOVE_BREAK_PT)
	||  (control & MOVE_JOG_PT2))	
	{
		/*| Move Trak/Break/Jog point */
	
		if(place_attr->first_in_cpx)
		{
			/*| first dimension */

			DMlineptvec(cursor, place_attr->mea_axis, mea_line);

			BSproj0(&rc,
				place_attr->orig_P,
				mea_line,
				place_attr->trak_pt);

			/*^ print_point("place_attr->trak_pt", place_attr->trak_pt); */

			BSmkvec(&rc,
				place_attr->trak_dir,
				place_attr->orig_P,
				place_attr->trak_pt);

			if (BSdotp(
				&rc,
				place_attr->trak_dir,
				place_attr->perp_axis) < 0)
				me->mea_trak &= (~DM_TRAK_DIR);
			else	me->mea_trak |= DM_TRAK_DIR;

			me->mea_trak |= place_attr->pri_trak_zone;
			me->mea_trak |= DM_TRAK_CTRL_DIM;

			place_attr->trak_dist =
			me->trak_dist = BSlenvec(&rc, place_attr->trak_dir);

			if (me->jogged)
			{
				DMlineptvec(
					place_attr->trak_pt,
					place_attr->mea_axis,
					mea_line);

				BSproj0(&rc,
					&place_attr->jog_line[6],
					mea_line,
					&place_attr->jog_line[9]);
			}
			else
			{
				for (index=0; index<3; index++)
				    place_attr->jog_line[index+3] =
				    place_attr->trak_pt[index];
			}
		}
		else
		{
			trak_dist = dist1 = dist2 = 0.0;

			val = (me->jogged)?6:0;

			pt1 = &place_attr->jog_line[val];

			DMlineptvec(
				pt1,
				place_attr->perp_axis,
				mea_line);

			BSproj0(&rc,
				cursor,
				mea_line,
				p1);

			BSmkvec(&rc, v1, pt1, p1);

			if (BSdotp(&rc, v1, place_attr->perp_axis) < 0.)
				me->mea_trak &= (~DM_TRAK_DIR);
			else	me->mea_trak |= DM_TRAK_DIR;

			trak_dist = BSlenvec(&rc, v1);

			BSproj0(&rc,
				place_attr->pri_trak_pt,
				mea_line,
				p2);

			BSmkvec(&rc, v2, pt1, p2);
			
			dist1 = (trak_dist - BSlenvec(&rc, v2));

			if (place_attr->sec_trak)
			{
				BSproj0(&rc,
					place_attr->sec_trak_pt,
					mea_line,
					p3);

				BSmkvec(&rc, v3, pt1, p3);
			
				dist2 = (trak_dist - BSlenvec(&rc, v3));
			}

			txt_heig = place_attr->par_env.txt_heig;

			/*^
				print_point("meas_P", pt1);
				print_point("cursor_P", p1);
				print_point("pri_trak_pt",p2);
				print_point("sec_trak_pt",p3);
				printf("pri_trak_zone = %d\n",place_attr->pri_trak_zone);
				printf("sec_trak_zone = %d\n",place_attr->sec_trak_zone);
				printf("trak_dist = %f, dist1 = %f, dist2 = %f\n",
					trak_dist, dist1, dist2);
				printf("txt_heig = %f\n", txt_heig);
			*/
			if (!place_attr->sec_trak_dim)
			   me->mea_trak &= ~DM_TRAK_CTRL_DIM;

			/*|- Check whether cursor falls in trak_zone*/

			if ((BSdotp(&rc, v1, v2) > 0.0)
			&&  (fabs(dist1) <= txt_heig)
			&&  (!place_attr->sec_trak_dim))
			{
				/*|- Cursor falls in pri_trak_zone*/

				me->mea_trak &= ~place_attr->sec_trak_zone;
				me->mea_trak |= DM_TRAK_LOCK;
				me->mea_trak |= place_attr->pri_trak_zone;

				me->trak_dist = 0.0;
				hilite = TRUE;

				math_v_equal(place_attr->trak_pt, p2);

				math_v_equal(p4, p2);
			}
			else if (place_attr->sec_trak
			&& (BSdotp(&rc, v1, v3) > 0.0)
			&& (fabs(dist2) <= txt_heig)
			&& (!place_attr->sec_trak_dim))
			{
				/*|- Cursor falls in sec_trak_zone*/

				me->mea_trak &= ~place_attr->pri_trak_zone;
				me->mea_trak |= DM_TRAK_LOCK;
				me->mea_trak |= place_attr->sec_trak_zone;
	
				me->trak_dist = 0.0;
				hilite = TRUE;

				math_v_equal(place_attr->trak_pt, p3);

				math_v_equal(p4, p3);
			}
			else
			{
				/*|- Dimension not locked to a Trak zone*/

				me->mea_trak &= ~DM_TRAK_LOCK;

				if ((BSdotp(&rc, v1, v2) > 0.0)
				&&  !place_attr->sec_trak_dim)
				{
					/*|- Establish primary Trak Zone*/

					me->mea_trak &= ~place_attr->sec_trak_zone;
					me->mea_trak |= place_attr->pri_trak_zone;

					BSmkvec(&rc, v4, p2, p1);

					if (BSdotp(&rc, v1, v4) > 0.0)
						me->trak_dist = BSlenvec(&rc, v4);
					else	me->trak_dist = -BSlenvec(&rc, v4);

					math_v_equal(place_attr->trak_pt, p2);
				}
				else
				{
					/*|- Establish secondary Trak Zone*/

					me->mea_trak &= ~place_attr->pri_trak_zone;
					me->mea_trak |= place_attr->sec_trak_zone;

					if ((place_attr->sec_trak)
					&&  (!place_attr->sec_trak_dim))
					{
						BSmkvec(&rc, v4, p3, p1);

						if (BSdotp(&rc, v3, v4) > 0.0)
							me->trak_dist = BSlenvec(&rc, v4);
						else	me->trak_dist = -BSlenvec(&rc, v4);

						math_v_equal(place_attr->trak_pt, p3);
					}
					else
					{
						/*|- Dimension is first in sec_trak_zone*/

						me->mea_trak |= DM_TRAK_CTRL_DIM;

						DMlineptvec(
							place_attr->meas_P,
							place_attr->perp_axis,
							mea_line);

						BSproj0(&rc,
							cursor,
							mea_line,
							p1);

						BSmkvec(&rc, v1, place_attr->meas_P, p1);
						me->trak_dist = BSlenvec(&rc, v1);
						math_v_equal(place_attr->trak_pt, p1);
					}
				}

				math_v_equal(p4, p1);
			}

			if (me->jogged)
			{
				DMlineptvec(
					p4,
					place_attr->mea_axis,
					mea_line);

				BSproj0(&rc,
					&place_attr->jog_line[6],
					mea_line,
					&place_attr->jog_line[9]);
			}
			else
			{
				for (index=0; index<3; index++)
				    place_attr->jog_line[index+3] =
							p4[index];
			}
		}

		/*^
			printf("me->mea_trak = %d\n", me->mea_trak);
			printf("me->trak_dist=%lf\n", me->trak_dist);
			print_point("trak_pt", place_attr->trak_pt);
		*/

		me->trak_dist /= BSlenvec(&rc, place_attr->plan_info.win_plan.vec_xpos);
	}

	if (control & MOVE_TRAK_PT
	||  control & MOVE_BREAK_PT
	||  control & MOVE_TEXT_POS
	||  control & MOVE_JOG_PT2)
	{
		/*| Compute proj line and term pos */

		status =
		om$send(msg = message DMcoordj.compute_proj_term(
						&rc,
						&dimline_valid,
						place_attr->trak_pt,
						&place_attr->par_env,
						&place_attr->plan_info,
						md_env,
						place_attr->orig_P,
						place_attr->cpx_orig_P,
						place_attr->meas_P,
						&dimn_value,
						txt_P,
						orig_meas,
						&term_pos[0],
						&term_pos[3],
						place_attr->jog_line),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (control & MOVE_TEXT_POS)
		{
			IGRdouble xaxis[3], yaxis[3];

			for (index=0; index<3; index++)
			{
				xaxis[index] = place_attr->plan_info.act_plan.matrix[index];
				yaxis[index] = place_attr->plan_info.act_plan.matrix[index+4];
			}

			BSnorvec(&rc, xaxis);
			BSnorvec(&rc, yaxis);

			me->offs_pt[0] =
			xaxis[0] * (cursor[0] - txt_P[0]) +
			xaxis[1] * (cursor[1] - txt_P[1]) +
			xaxis[2] * (cursor[2] - txt_P[2]);

			me->offs_pt[0] = me->offs_pt[0]/
			BSlenvec(&rc, place_attr->plan_info.act_plan.vec_xpos);

			me->offs_pt[1] =
			yaxis[0] * (cursor[0] - txt_P[0]) +
			yaxis[1] * (cursor[1] - txt_P[1]) +
			yaxis[2] * (cursor[2] - txt_P[2]);

			me->offs_pt[1] = me->offs_pt[1]/
			BSlenvec(&rc, place_attr->plan_info.act_plan.vec_xpos);

			/*"offs_pt=(%lf, %lf)\n", me->offs_pt[0], me->offs_pt[1]*/
		}

		/*| - Dimension Text */

		status =
		om$send(msg = message DMcoordj.make_dim_text(
						&rc,
						place_attr->meas_P,
						txt_P,
						dimn_value,
						&place_attr->par_env,
						&place_attr->par_loc,
						&place_attr->plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - Projection lines - */

		status =
		om$send(msg = message DMcoordj.make_proj_line(
						&rc,
						&place_attr->par_env,
						&place_attr->par_loc,
						&place_attr->plan_info,
						place_attr->orig_P,
						place_attr->meas_P,
						&term_pos[0],
						&term_pos[3],
						place_attr->jog_line,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - Dimension Line - */

		status =
		om$send(msg = message DMcoordj.make_dim_line(
						&rc,
						dimline_valid,
						&term_pos[0],
						&term_pos[3],
						&place_attr->par_env,
						&place_attr->par_loc,
						&place_attr->plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| - Terminators - */

		status =
		om$send(msg = message DMcoordj.make_dim_term(
						&rc,
						dimline_valid,
						&term_pos[0],
						&term_pos[3],
						orig_meas,
						&place_attr->par_env,
						&place_attr->par_loc,
						&place_attr->plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (dynamics_in_progress)
	{
		place_attr->par_env.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMroot.chgdp(&rc, &place_attr->par_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble cpx_orig_P[3];
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc)
{
	IGRint status, rc, index, prev_count;
	IGRboolean first_in_cpx;
	IGRdouble norm[3];
	struct ret_struct ret_st;
	struct GRid prev_list[MAX_DIM_ROOTS], prev_grid;

	/*| - Get trak_dist and mea_trak - */

	status =
	om$send(msg = message DMcoordj.get_cpx_origin(
					cpx_orig_P,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Get dimension plane orientation - */

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					&rc,
					md_env,
					plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS); 

	for (index=0; index<3; index++)
	{
		norm[index] = plan_info->win_plan.matrix[index+8];
		plan_info->win_plan.matrix[4*index+3] = cpx_orig_P[index];
	}

	/* - Get origin and measure pnt positions and
	     project the orig and meas pnts onto dimension
             plane - */

	status =
	om$send(msg = message DMroot.give_previous(
					&rc,
					&first_in_cpx,
					&prev_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx)
	{
		status =
		om$send(msg = message DMroot.DMreturn_roots(
						&prev_count,
						prev_list),
			targetid = prev_grid.objid,
			targetos = prev_grid.osnum);
		dm$status(action = RET_STATUS);

		if (prev_count == NO_CPX_DIM_ROOTS)
		{
			status =
			DMnode_give_structure(
				&rc,
				DIM_NO_INDEX,
				MEAS_INFO,
				(me->geom_type & DIM_IMPORTED),
				prev_list[DIM_CPX_MEAS].objid,
				prev_grid.objid,
				prev_grid.osnum,
				md_env,
				&ret_st);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			DMnode_give_structure(
				&rc,
				DIM_NO_INDEX,
				ORIG_INFO,
				(me->geom_type & DIM_IMPORTED),
				prev_list[DIM_CPX_ORIG].objid,
				prev_grid.objid,
				prev_grid.osnum,
				md_env,
				&ret_st);
			dm$status(action = RET_STATUS);
		}

		status =
		BSproj1(&rc,
			ret_st.var.point_st.pt,
			norm,
			cpx_orig_P,
			orig_P);
		dm$status(action = RET_STATUS);

		status =
		DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			MEAS_INFO,
			(me->geom_type & DIM_IMPORTED),
			list[DIM_CPX_MEAS].objid,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&ret_st);
		dm$status(action = RET_STATUS);

		status =
		BSproj1(&rc,
			ret_st.var.point_st.pt,
			norm,
			cpx_orig_P,
			meas_P);
		dm$status(action = RET_STATUS);

	}
	else
	{
		math_v_equal(orig_P, cpx_orig_P);
		math_v_equal(meas_P, cpx_orig_P);
	}

	/*^
		print_point("orig_P", orig_P);
		print_point("meas_P", meas_P);
		print_point("cpx_orig_P", cpx_orig_P);
	*/

	/*| - Get dimension parameters - */

	status =
	om$send(msg = message DMdim.get_active_params(&rc, par_env, par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation DMcoordj;
