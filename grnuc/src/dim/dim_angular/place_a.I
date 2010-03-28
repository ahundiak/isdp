class implementation DMangular;

#define AS_DEBUG  1
%safe
#include <math.h>
%endsafe 

#include "dimmod.h"
#include "bsvalues.h"
#include "mascalvc.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

extern IGRboolean	BSproj0();

from GRtext import GRchgtextattr;
from dim_param import store_internal;

method dynamics(IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar *info;
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	IGRint status,rc;
	IGRlong long_rc, bsrc;
	IGRdouble proj_pt[3];
	IGRdouble leaderpt[3],lead_dir[3], lea_line[6];
	IGRdouble lead_end[3];
	IGRdouble trak_pt[3];
	IGRdouble sca_fact, txt_widt, xaxis[3], yaxis[3];
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;

	struct DMdyn_angular *place_attr;
	struct angular_data_st *ang_info;
	struct dm_ang_src_st *angle_st;

	IGRint i,index;

	struct GRid go_grid[5];

	/* projection line parameters  */

	IGRdouble proj_offs,proj_extn;
	double proj_line[6];

	/* text parameters */

	IGRdouble box[4][3];
	IGRdouble *orie_vec;
	IGRvector perp_vec;
	IGRpoint text_pt;
	IGRdouble *ter_pt;
	IGRdouble angle;
	IGRshort txt_just;
	IGRint dspflag;
	OM_S_OBJID objid;
	IGRshort osnum;

	/* dim line parameters */

	IGRdouble trak_dir[3];
	IGRdouble trak_vec_len,distance;
	IGRboolean cursor_above;
	
	/*  term orientation vectors   */
	double *term_orie;
	IGRint ter_dir0, ter_dir1;
	IGRvector orig_term_start,meas_term_start;

	IGRdouble *oldpt, *old_vec, *oldterm;
	IGRdouble newpt[3], new_vec[3], dist;
	struct DMdim_root *projline;

	/* assign place attributes  */


	if( me->dim_state & DIM_NEEDS_UPDATE)
	{
		/*| send a ND_s_compute_node  */

		/*"me:trakdist%lf\n",me->trak_dist*/

		status =
		om$send(msg = message NDnode.NDs_compute_node(
						(IGRlong *)&rc,
						NULL,
						md_env),
		    targetid = my_id);
		dm$status(action = RET_STATUS);

		control |= FILL_INFO;
	}

	if (control & FILL_INFO)
	{
		/*"me:trakdist%lf\n",me->trak_dist*/

		/*| - Fill Dimension Info - */

		status =
		om$send(msg = message DMroot.fill_info(
						&rc,
						control,
		    				level,
		    				info,
		    				md_env),
		    targetid = my_id);
		dm$status(action = RET_STATUS);

		/*"me:trakdist%lf\n",me->trak_dist*/

		place_attr = (struct DMdyn_angular *) info + (*level);
		if((*level == 0) && (me->dim_state & DIM_IN_PLACEMENT))
		{
			/*|- Get misc params  */

			status =
			    dm$get_dim_param(
			    type = DM_MISC_PARAM,
			    p_data = (char *) &place_attr->p_misc);
			dm$status(action = RET_STATUS);

		}
		else place_attr->p_misc.aut_cent = FALSE;
	}

	place_attr = (struct DMdyn_angular *) info + (*level);

	/*| set all the pointers for local use */

	plan_info = &place_attr->plan_info;
	p_env     = &place_attr->p_env;
	p_loc     = &place_attr->p_loc;
	ang_info  = &place_attr->ang_info;
	angle_st  = &place_attr->ang_parent_st;

	/*"me:trakdist%lf\n",me->trak_dist*/

	vec_equal(cursor,proj_pt);

	if(*level)
	{

		/* dimension is dependent move only trakpoint */
		if (!(control & MOVE_TRAK_PT))
		{
			printf("dynamics: ERROR in dependent control\n");
			return(OM_W_ABORT);
		}
		place_attr->trak_dist = 0.0;

		status =
		om$send(msg = message DMangular.get_mea_trak_info(
						&angle_st->cpx_orig_line,
						(IGRchar *) &me->mea_trak,
						&place_attr->trak_dist,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

	
		/*"me:trakdist%lf\n",me->trak_dist*/
		/*"trakdist%lf\n",place_attr->trak_dist*/

		place_attr->trak_dist *= BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);


		ang_info->arc_rad = place_attr->trak_dist;

		status =
		om$send(msg = message DMangular.compute_breakpt(&long_rc,
						ang_info,
						angle_st,
						plan_info),

			targetid = my_id);
		dm$status(action = RET_STATUS);

	 	v_projpt( ang_info->centerpt,ang_info->arc_rad,ang_info->orig_ln_orie,
		   	ang_info->orig_term_pt); 
		v_projpt( ang_info->centerpt,ang_info->arc_rad,ang_info->meas_ln_orie,
		   	ang_info->meas_term_pt); 

		/* because the breakpoint is not moving that has to 
		   act as the text point also */
		v_equal(ang_info->breakpt,text_pt);
		txt_just = place_attr->txt_just;
		orie_vec = place_attr->txt_orie_vec;
		vec_cross(ang_info->norm_pl,orie_vec,perp_vec);

		if(me->leader)
		{
			/*|compute leaderpt*/
			for( i = 0; i<3; i++)
				ang_info->leaderpt[i] = ang_info->breakpt[i] +
			    	me->lead_dist * place_attr->txt_orie_vec[i];
			v_equal(ang_info->leaderpt,text_pt);
		}
		/*^ print_point("leaderpt",ang_info->leaderpt); */

		status = 
		om$send( msg = message DMangular.make_proj_lines(&long_rc,
					  	 	p_env,
						 	p_loc,
						 	plan_info,
						 	angle_st,
						 	ang_info,
						 	md_env),
			targetid = my_id);
		dm$status( action = RET_STATUS);

	}
	else
	{
		if ((control & MOVE_ORIG_PT) || (control & MOVE_MEAS_PT))
		{
			/* -
				Project cursor onto the projection line
				to obtain the new orig point and
				compute offset distance and direction 
			- */

			if(control & MOVE_ORIG_PT)
			{
				oldpt = place_attr->orig_P;
				oldterm = ang_info->orig_term_pt;
				old_vec = place_attr->orig_vec;
				projline = &angle_st->orig_line;
				index = 0;
			}
			else
			{
				oldpt = place_attr->meas_P;
				oldterm = ang_info->meas_term_pt;
				old_vec = place_attr->meas_vec;
				projline = &angle_st->meas_line;
				index = 1;
			}

			BSproj0(&bsrc, cursor, projline, newpt);
			BSmkvec(&bsrc, new_vec, oldpt, newpt);

			if(BSdotp(&bsrc, old_vec, new_vec) >= 0.0)
				me->prj_offs[index] = BSlenvec(&bsrc, new_vec);
			else	me->prj_offs[index] = -BSlenvec(&bsrc, new_vec);

			dist = BSdistptpt(&bsrc, oldpt, oldterm);

			if(me->prj_offs[index] <= dist)
			{
				proj_offs = me->prj_offs[index] + place_attr->proj_offs;
				proj_extn = place_attr->proj_extn;
			}
			else
			{
				proj_offs = me->prj_offs[index] - place_attr->proj_offs;
				proj_extn = -place_attr->proj_extn;
			}

			DMang_compute_proj_line(
					projline,
	    				oldterm,
		    			proj_line,
			  		proj_extn,
			    		proj_offs);

			status =
			om$send(msg = message DMroot.position_line(
							&rc,
		    					DIM_NO_INDEX,
		    					&place_attr->proj_grid[index],
		    					md_env,
		    					proj_line),
			    targetid = my_id);
			dm$status(action = RET_STATUS);

			return(OM_S_SUCCESS);
		}

		if( control & MOVE_LEADER_PT)
		{
			if(!me->leader)
			{
				printf("dynamics: ERROR leader is OFF\n");
				return(OM_W_ABORT);
			}
			/*|leader exists*/
			/*"lead orie:%lf:%lf:%lf\n",place_attr->lead_orie[0], place_attr->lead_orie[1],place_attr->lead_orie[2]*/

			for( i = 0; i<3; i++)
			{
				lea_line[i] = ang_info->breakpt[i];
				lea_line[3+i] = ang_info->breakpt[i] + 
				    		place_attr->lead_orie[i];
			}

			BSproj0(&bsrc,proj_pt,lea_line,leaderpt);
			vec_sub(leaderpt,ang_info->breakpt,lead_dir);
			if( BSdotp( &bsrc, lead_dir, place_attr->lead_orie) >= 0)
			{
				me->lead_dist = BSlenvec(&bsrc, lead_dir);
				txt_just = (p_loc->txt_posn == TXT_POSN_ABOVE)?
						LEFT_BASE:LEFT_CENTER;
			}
			else
			{
				me->lead_dist = -BSlenvec(&bsrc,lead_dir);
				txt_just = (p_loc->txt_posn == TXT_POSN_ABOVE)?
						RIGHT_BASE:RIGHT_CENTER;
			}

			me->lead_dist /= BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

			/*^ print_point("leaderpt:",leaderpt);
			    print_point("breakpt:",ang_info->breakpt);
			*/

			vec_add(leaderpt,place_attr->def_offs,text_pt);

			status=
			om$send(msg = message DMroot.position_text(&rc,
							TRUE,
			    				DIM_NO_INDEX,
			    				&place_attr->text_grid,
			    				md_env,
							txt_just,
			    				text_pt,
							NULL,
							NULL,
							p_loc,
							p_env),
			    	targetid= my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMdim.get_text_extents(
								&rc,
								(double *)box,
								md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			DMcompute_endpt(
				&rc,
				ang_info->breakpt,
				leaderpt,
				box,
				p_loc->txt_posn,
				plan_info->win_plan.matrix,
				md_env,
				lead_end);

			DMlineptpt(ang_info->breakpt, lead_end, lea_line);

			status =
			om$send(msg = message DMroot.position_line(&rc,
			    				DIM_LEADER,
			    				NULL,
			    				md_env,
			    				lea_line),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			return(OM_S_SUCCESS);
		}

		vec_equal( proj_pt,trak_pt);
		v_sub(trak_pt,ang_info->centerpt,trak_dir);
		trak_vec_len = vec_len(trak_dir);
		BSnorvec(&bsrc, trak_dir);
		/*^print_point("trak_dir:",trak_dir);*/

		if( control & MOVE_TRAK_PT)
		{
			/*|move trakpt*/

			ang_info->arc_rad = trak_vec_len;

			cursor_above = FALSE;
			if(!place_attr->first_in_cpx)
			{
				/*|not first in cpx*/
				distance = v_dist(ang_info->centerpt,trak_pt);

				if( distance < (place_attr->trak_dist ) )
				{
					/*|cursor below min pos*/
					
					me->trak_dist = p_env->lin_offs_r *
					    		p_env ->txt_heig;
					ang_info->arc_rad = place_attr->trak_dist;

					/*"arc rad:%d\n",ang_info->arc_rad */

					if(control & MOVE_BREAK_PT)
					{
						v_projpt(ang_info->centerpt,
						    	 ang_info->arc_rad,
						    	 trak_dir,trak_pt);
						vec_equal(trak_pt,text_pt);
						/*^print_point("trak_pt:",trak_pt);*/
					}
				}
				else cursor_above = TRUE;
			}

			if(place_attr->first_in_cpx || cursor_above)
			{
				/*|cursor is above minpos*/
				if( control & MOVE_BREAK_PT)
					vec_equal( proj_pt,text_pt);

				if( place_attr->first_in_cpx)
					me->trak_dist = ang_info->arc_rad;
				else	me->trak_dist = ang_info->arc_rad - 
						place_attr->trak_dist_prev;
			}
			me->trak_dist /=
				BSlenvec(&bsrc,plan_info->win_plan.vec_xpos);
		}

		/*"trak dist:%lf\n",me->trak_dist */
		/*"arc rad:%lf\n",ang_info->arc_rad */

		/*|compute the termpoints*/

		v_projpt( ang_info->centerpt,ang_info->arc_rad,
		    ang_info->orig_ln_orie,ang_info->orig_term_pt);

		v_projpt( ang_info->centerpt,ang_info->arc_rad,
		    ang_info->meas_ln_orie,ang_info->meas_term_pt);

		/*|compute the break position*/
		ter_dir0 = CLOCK_DIR;
		ter_dir1 = ANTI_CLOCK_DIR;
		if(me->ter_loca == TER_LOCA_EXTERNAL)
		{
			ter_dir0 = ANTI_CLOCK_DIR;
			ter_dir1 = CLOCK_DIR;
		}
		
		txt_widt = p_env->txt_widt * BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

        	DMget_pt_at_angle( ang_info->centerpt,
                           ang_info->left_term_pt,
                           ang_info->arc_rad,
                           plan_info->win_plan.matrix,
                           orig_term_start,
                           txt_widt,
                           ter_dir0);

        	DMget_pt_at_angle( ang_info->centerpt,
                           ang_info->right_term_pt,
                           ang_info->arc_rad,
                           plan_info->win_plan.matrix,
                           meas_term_start,
                           txt_widt,
                           ter_dir1);

	if(me->mea_trak & CLOCK_WISE)
	{
		vec_sub(ang_info->left_term_pt,orig_term_start,
			ang_info->orig_term_orie);
		vec_sub(ang_info->right_term_pt,meas_term_start,
			ang_info->meas_term_orie);
	}
	else
	{
		vec_sub(ang_info->left_term_pt,orig_term_start,
			ang_info->meas_term_orie);
		vec_sub(ang_info->right_term_pt,meas_term_start,
			ang_info->orig_term_orie);
	}

		BSnorvec(&bsrc,ang_info->orig_term_orie);
		BSnorvec(&bsrc,ang_info->meas_term_orie);

		if( control & MOVE_BREAK_PT)
		{
			v_projpt(ang_info->centerpt,ang_info->arc_rad,
						    trak_dir,
						    ang_info->breakpt);

			if( me->mea_trak & CLOCK_WISE)
				ang_info->right_ptr = ang_info->meas_ln_orie;
			else 
				ang_info->right_ptr  = ang_info->orig_ln_orie;

				MATH_ang_bet_lines( ang_info->right_ptr,trak_dir,
						    &angle,ang_info->norm_pl);

			/*"orig&trak ang:%lf:dim_ang:%lf\n",angle,ang_info->dimn_val*/

			if(angle < ang_info->dimn_val)
			{
				me->brk_pos = BRK_CENTER;
				me->brk_dist = angle/ang_info->dimn_val;
				
				if(place_attr->p_misc.aut_cent){
					MATH_rotate_vector(&rc,
						    	ang_info->right_ptr,
						    	ang_info->dimn_val/2,
						    	plan_info->win_plan.matrix,
						    	text_pt);
					v_projpt(ang_info->centerpt,
						 ang_info->arc_rad,
						 text_pt,
						 ang_info->breakpt);
					me->brk_dist = 0.5;
				}
			}
			else if( angle > ang_info->dimn_val && 
				 angle < ( ang_info->dimn_val/2.0 + M_PI))
			{
				me->brk_pos = BRK_LEFT;
				me->brk_dist = angle - ang_info->dimn_val;
			}
			else
			{
				me->brk_pos = BRK_RIGHT;
				me->brk_dist = 2.0 * M_PI - angle;
			}

			/*"brkpos:%d\n", me->brk_pos*/
			v_equal(ang_info->breakpt,text_pt);
		}
		else
		{
			/*| compute the break point  */
			status = 
			om$send( msg= message DMangular.compute_breakpt(&long_rc,
								ang_info,
								angle_st,
								plan_info),
				targetid = my_id);
			dm$status(action= RET_STATUS);
			v_equal(ang_info->breakpt,text_pt);
			/*^print_point("text pt",text_pt); */
		}
		if(me->leader)
		{
			/*|compute leaderpt*/
			for( i = 0; i<3; i++)
				ang_info->leaderpt[i] = ang_info->breakpt[i] +
			    	me->lead_dist * place_attr->txt_orie_vec[i];
			v_equal(ang_info->leaderpt,text_pt);
		}
		/*^ print_point("leaderpt",ang_info->leaderpt); */

		/*| valid for all cases */
		/*|text orietation vector  */

		txt_just = place_attr->txt_just;
		orie_vec = place_attr->txt_orie_vec;
		vec_cross(ang_info->norm_pl,orie_vec,perp_vec);

		if( (p_loc->txt_orie == TXT_ORIE_PARALLEL) ||
		    (p_loc->txt_orie == TXT_ORIE_PERPENDICULAR))
		{
			DMget_ang_txt_info(plan_info,
					   p_loc,
					   orie_vec,
					   ang_info->norm_pl,
					   &place_attr->txt_just,
					   text_pt,
					   ang_info->centerpt,
					   FALSE,
					   FALSE);
			vec_cross(ang_info->norm_pl,orie_vec,perp_vec);
			BSnorvec(&bsrc, perp_vec);
			sca_fact = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
			MAscalvc(&bsrc, &sca_fact, perp_vec, perp_vec);

			if( p_loc->txt_posn == TXT_POSN_ABOVE)
			{
				if( p_loc->txt_posn == TXT_ORIE_PERPENDICULAR)
					MAscalvc(&bsrc,
						 &place_attr->txt_yoff,orie_vec,
						 place_attr->def_offs);
				else
					MAscalvc(&bsrc,
						 &place_attr->txt_yoff,perp_vec,
						 place_attr->def_offs);
			}
		}
	}
	if (control & MOVE_TEXT_POS)
	{
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

		me->offs_pt[0] = me->offs_pt[0]/
		BSlenvec(&bsrc, place_attr->plan_info.act_plan.vec_xpos);

		me->offs_pt[1] =
		yaxis[0] * (cursor[0] - text_pt[0]) +
		yaxis[1] * (cursor[1] - text_pt[1]) +
		yaxis[2] * (cursor[2] - text_pt[2]);

		me->offs_pt[1] = me->offs_pt[1]/
		BSlenvec(&bsrc, place_attr->plan_info.act_plan.vec_xpos);

		/*"offs_pt=(%lf, %lf)\n", me->offs_pt[0], me->offs_pt[1]*/

		math_v_equal(text_pt, cursor);
		v_equal(place_attr->txt_orie_vec,orie_vec);
	}

	vec_add(text_pt,place_attr->def_offs,text_pt);
	status= 
	om$send( msg = message DMroot.position_text(
						&rc,
						TRUE,
						DIM_TEXT,
						&place_attr->text_grid,
						md_env,
						-1,
						text_pt,
						orie_vec,
						ang_info->norm_pl,
						p_loc,
						p_env),
		targetid = my_id);
	dm$status(action= RET_STATUS);

	dist = BSdistptpt(
			&bsrc,
			place_attr->orig_P,
			place_attr->ang_info.orig_term_pt);

	if(me->prj_offs[0] <= dist)
	{
		proj_offs = me->prj_offs[0] + place_attr->proj_offs;
		proj_extn = place_attr->proj_extn;
	}
	else
	{
		proj_offs = me->prj_offs[0] - place_attr->proj_offs;
		proj_extn = -place_attr->proj_extn;
	}

	if( p_loc->proj_disp & PROJ_DISP_ORI)
	{
		DMang_compute_proj_line(&angle_st->orig_line,
		    			ang_info->orig_term_pt,
			    		proj_line,
			  		proj_extn,
			    		proj_offs);
		/*^
			for( i = 0; i<6;i++)
				printf("proj_line[%d]:%lf\n",i,proj_line[i]);
		*/

		status =
		om$send(msg = message DMroot.position_line( &rc,
		    				DIM_ORI_PROJ,
		    				&go_grid[DIM_ORI_PROJ],
		    				md_env,
		    				proj_line),
		    targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	
	dist = BSdistptpt(
			&bsrc,
			place_attr->meas_P,
			place_attr->ang_info.meas_term_pt);

	if(me->prj_offs[1] <= dist)
	{
		proj_offs = me->prj_offs[1] + place_attr->proj_offs;
		proj_extn = place_attr->proj_extn;
	}
	else
	{
		proj_offs = me->prj_offs[1] - place_attr->proj_offs;
		proj_extn = -place_attr->proj_extn;
	}

	if( p_loc->proj_disp & PROJ_DISP_MEA)
	{
		DMang_compute_proj_line( &angle_st->meas_line,
		    			ang_info->meas_term_pt,
		    			proj_line,
		    			proj_extn,
		    			proj_offs);
		/*^
			for( i = 0; i<6;i++)
				printf("proj_line[%d]:%lf\n",i,proj_line[i]);
		*/

		status =
		om$send(msg = message DMroot.position_line(&rc,
		    				DIM_MEA_PROJ,
		    				&go_grid[DIM_MEA_PROJ],
		    				md_env,
		    				proj_line ),
		    targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send( msg = message DMangular.make_dim_line(
						&long_rc,
	    					p_env,
	    					p_loc,
	    					ang_info,
	    					plan_info,
	    					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^
		print_point("orig:",ang_info->orig_term_orie);
		print_point("meas:",ang_info->meas_term_orie);
	*/

	/* compute_the perp vectors  */

	if( control & MOVE_TRAK_PT)
	{

		for (index=0; index<2; index++)
		{
			objid  = place_attr->ter_grid[index].objid;
			osnum  = place_attr->ter_grid[index].osnum;

			ter_pt = (index == 0)?ang_info->orig_term_pt:
			    ang_info->meas_term_pt;

			term_orie = (index == 0)?ang_info->orig_term_orie:
			    ang_info->meas_term_orie;

			dspflag = (index == 0)?TER_DISP_ORI:TER_DISP_MEA;
			if (p_loc->ter_disp & dspflag)
			{
				status= 
				om$send( msg = message DMroot.position_text(
							&rc,
							FALSE,
							DIM_NO_INDEX,
							&place_attr->ter_grid[index],
							md_env,
							-1,
							ter_pt,
							term_orie,
							ang_info->norm_pl,
							NULL,
							NULL),
					targetid = my_id);
				dm$status(action= RET_STATUS);

			}
		}
	}

	if(!(control & MOVE_TRAK_PT)) return(OM_S_SUCCESS);

	/*| - Compute other children in stack */
	*level += 1;

	for (index=0; index<2; index++)
	{
		if (place_attr->next[index].objid == NULL_OBJID)
			continue;

		status =
		om$send(msg = OPPmargs,
			targetid = place_attr->next[index].objid,
			targetos = place_attr->next[index].osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method fill_buff(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRlong long_rc, bsrc;
	IGRint count, i;
	struct GRid list[MAX_DIM_ROOTS];
	struct DMdyn_angular *place_attr;
	IGRint go_index[5];
	struct GRid go_grid[5];
	struct angular_data_st *ang_info;
	struct dm_ang_src_st *angle_st;
	struct DMplan_info *plan_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	IGRdouble dist1, dist2;

	place_attr = (struct DMdyn_angular *)info +(*level);
	
	/*^
		printf("level:%d,place_attr=%ld,info=%ld,size=%ld\n",
			*level,place_attr,info,sizeof(struct DMdyn_angular));
	*/

	plan_info = &place_attr->plan_info;
	p_env     = &place_attr->p_env;
	p_loc     = &place_attr->p_loc;
	ang_info  = &place_attr->ang_info;
	angle_st  = &place_attr->ang_parent_st;

	/*| - Get list of Parents - */

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					      &count,
					       list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|Gather Data for this dimension*/

	status = 
	om$send( msg = message DMangular.get_dim_info((long *)&rc,
		    				count,
		    				list,
		    				md_env,
		    				angle_st,
		    				&place_attr->trak_dist,
		    				plan_info,
		    				p_env,
		    				p_loc),
		    	targetid = my_id);
	dm$status( action = RET_STATUS);

	place_attr->trak_dist_prev = place_attr->trak_dist - me->trak_dist;
	place_attr->trak_dist *= BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
	place_attr->trak_dist_prev *= BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
	
	/*"previous trak dist:%lf\n",place_attr->trak_dist*/
	
	/* - Compute Trak Point , Break Point etc.,- */

	if (control & MOVE_TRAK_PT)
	{
		IGRdouble min_dist;
		IGRboolean first_in_cpx;

		/* Compute minimum trak point */

		min_dist = place_attr->trak_dist_prev +
			   p_env->lin_offs_r * p_env->txt_heig;

		first_in_cpx = !DMancestry_valid(
					list[DIM_CPX_ORIG],
					OPP_DMangular_class_id);

		ang_info->arc_rad =
		place_attr->trak_dist = (first_in_cpx)?place_attr->trak_dist:min_dist;
	}
	else	ang_info->arc_rad = place_attr->trak_dist;


	/*"arc rad:%lf\n",ang_info->arc_rad*/

	ang_info->norm_pl[0] = plan_info->win_plan.matrix[8];
	ang_info->norm_pl[1] = plan_info->win_plan.matrix[9];
	ang_info->norm_pl[2] = plan_info->win_plan.matrix[10];


	status =
	om$send( msg = message DMangular.get_dim_sect((long *)&rc,
	    					angle_st,
	    					ang_info,
	    					plan_info,
	    					p_env),
	    	targetid = my_id);
	dm$status(action= RET_STATUS);

	/*^ print_point("orig ln orie:",ang_info->orig_ln_orie);*/
	/*^ print_point("meas ln orie:",ang_info->meas_ln_orie);*/

	/*|compute dimn val */

	if( me->mea_trak & CLOCK_DIR)
	 	MATH_ang_bet_lines(ang_info->meas_ln_orie,
				   ang_info->orig_ln_orie,
				   &ang_info->dimn_val,
				   ang_info->norm_pl);
	else
		MATH_ang_bet_lines(ang_info->orig_ln_orie,
			   	   ang_info->meas_ln_orie,
			   	   &ang_info->dimn_val,
				   ang_info->norm_pl);

	/*"dimn val:%lf\n",ang_info->dimn_val*/
	
	status =
	om$send(msg = message DMangular.compute_breakpt(&long_rc,
					ang_info,
					angle_st,
					plan_info),
	    targetid = my_id);
	
	/*|fill the text direction and justification*/

	DMget_ang_txt_info(&place_attr->plan_info,
			   &place_attr->p_loc,
			   place_attr->txt_orie_vec,
			   ang_info->norm_pl,
			   &place_attr->txt_just,
			   ang_info->breakpt,
			   ang_info->centerpt,
			   me->leader,
			   me->lead_dist);

	vec_equal(place_attr->txt_orie_vec,place_attr->lead_orie);

	if (!me->leader)
	{
		if ((place_attr->p_loc.txt_orie == TXT_ORIE_HORIZONTAL)
		||  (place_attr->p_loc.txt_orie == TXT_ORIE_VERTICAL))

			place_attr->p_loc.txt_posn = TXT_POSN_EMBEDDED;
	}

	if (place_attr->p_loc.txt_posn == TXT_POSN_ABOVE)
	{
		/* compute the off direction*/
		vec_cross(ang_info->norm_pl,place_attr->txt_orie_vec,
			  place_attr->offs_dir);

		place_attr->txt_yoff =
			place_attr->p_env.txt_yoff_r *
			place_attr->p_env.txt_heig;

		MAscalvc(&bsrc,
			 &place_attr->txt_yoff,
			 place_attr->offs_dir,
			 place_attr->def_offs);
	}
	else
	{
		place_attr->def_offs[0] =
		place_attr->def_offs[1] =
		place_attr->def_offs[2] = 0.0;
	}

	/* projection lines nothing to do */
	if(control & MOVE_LEADER_PT || me->leader)
	{
		status = 
		om$send( msg= message DMangular.compute_breakpt((long *)&rc,
		    					ang_info,
		    					angle_st,
		    					plan_info),
		    		targetid = my_id);
		dm$status(action = RET_STATUS);
		DMget_ang_txt_info(&place_attr->plan_info,
			   	&place_attr->p_loc,
			   	place_attr->lead_orie,
			   	ang_info->norm_pl,
			   	&place_attr->txt_just,
			   	ang_info->breakpt,
			   	ang_info->centerpt,
			   	me->leader,
			   	me->lead_dist);

		/*^ print_point("breakpt",ang_info->breakpt); */
		/*|compute leaderpt*/
		for( i = 0; i<3; i++)
			ang_info->leaderpt[i] = ang_info->breakpt[i] +
				    me->lead_dist * place_attr->txt_orie_vec[i];
		/*^ print_point("leaderpt",ang_info->leaderpt); */
	}

        status =
        om$send( msg = message DMangular.make_dim_term((long *)&rc,
                                             ang_info,
                                             p_env,
                                             p_loc,
                                             plan_info,
                                             md_env),
                        targetid = my_id);
                dm$status( action = RET_STATUS);

	for( i = 0; i<3; i++)
		place_attr->pt_on_plane[i] = plan_info->win_plan.matrix[4*i +3];


	place_attr->proj_offs = p_env->proj_offs_r * p_env->txt_heig;
	place_attr->proj_extn = p_env->proj_extn_r * p_env->txt_heig;

	dist1 = BSdistptpt(&bsrc,
			ang_info->orig_term_pt,
			angle_st->orig_line.point1);

	dist2 = BSdistptpt(&bsrc,
			ang_info->orig_term_pt,
			angle_st->orig_line.point2);

	if(dist1 < dist2)
	{
		for(i=0; i<3; i++)
		{
			place_attr->orig_P[i] =
				angle_st->orig_line.point1[i];
			place_attr->orig_vec[i] =
				ang_info->orig_term_pt[i] -
				place_attr->orig_P[i];
		}
		BSnorvec(&bsrc, place_attr->orig_vec);
	}
	else
	{
		for(i=0; i<3; i++)
		{
			place_attr->orig_P[i] =
				angle_st->orig_line.point2[i];
			place_attr->orig_vec[i] =
				ang_info->orig_term_pt[i] -
				place_attr->orig_P[i];
		}
		BSnorvec(&bsrc, place_attr->orig_vec);
	}

	dist1 = BSdistptpt(&bsrc,
			ang_info->meas_term_pt,
			angle_st->meas_line.point1);

	dist2 = BSdistptpt(&bsrc,
			ang_info->meas_term_pt,
			angle_st->meas_line.point2);

	if(dist1 < dist2)
	{
		for(i=0; i<3; i++)
		{
			place_attr->meas_P[i] =
				angle_st->meas_line.point1[i];
			place_attr->meas_vec[i] =
				ang_info->meas_term_pt[i] -
				place_attr->meas_P[i];
		}
		BSnorvec(&bsrc, place_attr->meas_vec);
	}
	else
	{
		for(i=0; i<3; i++)
		{
			place_attr->meas_P[i] =
				angle_st->meas_line.point2[i];
			place_attr->meas_vec[i] =
				ang_info->meas_term_pt[i] -
				place_attr->meas_P[i];
		}
		BSnorvec(&bsrc, place_attr->meas_vec);
	}

	go_index[0] = DIM_TEXT;
	go_index[1] = DIM_ORI_TERM;
	go_index[2] = DIM_MEA_TERM;
	go_index[3] = DIM_ORI_PROJ;
	go_index[4] = DIM_MEA_PROJ;

	for (i=0; i<5; i++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						go_index[i],
						FALSE,
						NULL,
						md_env,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	place_attr->text_grid = go_grid[0];
	place_attr->ter_grid[0] = go_grid[1];
	place_attr->ter_grid[1] = go_grid[2];
	place_attr->proj_grid[0] = go_grid[3];
	place_attr->proj_grid[1] = go_grid[4];

	DMget_txt_length(place_attr->text_grid,&ang_info->min_length,
			 &ang_info->max_length,md_env,plan_info);
	/* - reduce the text length by half text widt*/

	if(place_attr->p_env.ang_unit != ANG_UNIT_RAD)
	{
		ang_info->max_length -= place_attr->p_env.txt_widt;
	}

	place_attr->first_in_cpx = TRUE;
	place_attr->next[0].objid =
	place_attr->next[1].objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

end implementation DMangular;
