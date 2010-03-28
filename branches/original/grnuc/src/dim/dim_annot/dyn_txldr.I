class implementation DMtxldr;

#define AS_DEBUG	1
#include "dimmod.h"
#include "dpdef.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bscrossp.h"
extern double fabs();
from GRlinear import GRputpolyline;

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
	/* - local variables */

	IGRint status, rc, last_vtx, i;
	IGRlong	long_rc, bsrc;
	IGRshort txt_just;
	struct DMdyn_annot *place_attr; /* buffer for annot structure */
	struct DMplan_info *plan_info;	   
	struct DPele_header *loc_ele_header;
	struct IGRlbsys *lbs_geom;

	IGRuchar *loc_text_string;
	IGRint dir_flag, hilite, num_poles;
	IGRdouble curr_dir[3],target_pt[3], text_pt[3];
	IGRvector perp_vec, refer_dir;
	IGRdouble *prev_point, y_offset,*proj_pt;
	IGRdouble active_angle = 0.0;
	IGRint bytes_affected, current_index, action,dummy;
	extern IGRboolean dynamics_in_progress;

	/*|- initailizing pointers */

	place_attr = (struct DMdyn_annot *)info;
	plan_info = &place_attr->plan_info;
	loc_ele_header = &place_attr->ele_header;

	proj_pt = (IGRdouble *)cursor;

        if(( control & FILL_INFO) ||
           ( me->dim_state & DIM_NEEDS_UPDATE))
	{
		/*|- Fill the Default Info */

		status=
		om$send(msg = message DMannot.fill_info(&rc,
						control,
						0,
						info,
						md_env),
			targetid =my_id );
		dm$status(action = RET_STATUS);

	}

	loc_text_string =(loc_ele_header->ele_spec_att.text) ? 
			 (unsigned char *)
                         loc_ele_header->ele_spec_att.text->text_string : NULL;

	num_poles = om$dimension_of(varray =  me->break_pt)/3;
	last_vtx = 3*(num_poles -1);

	/*"num poles:%d\n",num_poles*/

	if(me->leader && num_poles > 1)
	{
		prev_point = &me->break_pt[ last_vtx - 3];
		if( num_poles > 2)
		{
			BSmkvec(&bsrc,refer_dir,prev_point,&me->break_pt[last_vtx - 6]);
			BSnorvec(&bsrc,refer_dir);
		}
		else
		{
			vec_equal(place_attr->src_dir,refer_dir);
		}
		/*^
		    print_point("src_dir",refer_dir);
		    print_point("prev point",prev_point);
		*/

		DMinquire_hilite( 
			proj_pt,
			prev_point, 
			target_pt,
			NULL,
			refer_dir, 
			NULL,
			plan_info, 
			&place_attr->win_grid,
			&hilite);

		vec_sub(target_pt,prev_point,curr_dir);
		memcpy(&me->break_pt[last_vtx],target_pt, 3*sizeof(IGRdouble));
	}
	else
	{

		for(i = 0; i < 3; i++)
		{
			curr_dir[i] = place_attr->src_dir[i];
			target_pt[i] = proj_pt[i];
		}
		hilite = FALSE;
	}

	if (dynamics_in_progress)
	{
		BSnorvec(&bsrc, curr_dir);

		DMget_annot_txt_info(plan_info,
				&place_attr->par_senv,
				place_attr->txt_orie,
				&plan_info->win_plan.matrix[8],
				&txt_just,
				curr_dir);
		if (num_poles > 1)
		{
           		DMget_direction(prev_point,
					&me->break_pt[last_vtx],
                          		plan_info->win_plan.matrix,
                           		&dir_flag);

		 	if( dir_flag == AN_BEFORE)
		 	{
           			if (txt_just == LEFT_CENTER)
					txt_just = RIGHT_CENTER;
               			else if (txt_just == LEFT_CAP)
					txt_just = RIGHT_CAP;
               			else if (txt_just == LEFT_BASE) 
					txt_just = RIGHT_BASE;
		 	}
			place_attr->txt_just = txt_just;
		}
		else	place_attr->txt_just = LEFT_CENTER;


		BScrossp(&bsrc,
			 &plan_info->win_plan.matrix[8], 
			 place_attr->txt_orie, 
			 perp_vec);

		y_offset =  0.5 * place_attr->par_senv.txt_heig;

		/*^
			print_point("target_pt", target_pt);
			print_point("y_axis", perp_vec);
			printf("y_offset = %f\n",y_offset);
		*/

		if (place_attr->par_senv.an_posn == ANNOT_JUST_BOTTOM)
			y_offset = -y_offset;

		if ((place_attr->par_senv.an_posn == ANNOT_JUST_ABOVE)
		||  (place_attr->par_senv.an_posn == ANNOT_JUST_BOTTOM)
		||  (place_attr->par_senv.an_posn == ANNOT_JUST_UNDER))
		{
			for(i=0; i<3; i++)
			   text_pt[i] = target_pt[i] + y_offset * perp_vec[i];
		}
		else
		{
			vec_equal(target_pt,text_pt);
		}

		/*^  print_point("text_pt",text_pt); */
	}
	else 
	{
		/*| Dynamics off, Replace text */

		status= 
		om$send( msg = message DMroot.replace_text(
					&rc,
					DIM_NO_INDEX,
					&place_attr->go_grid[AN_ANNOT_TEXT],
					md_env,
					place_attr->text_length,
					place_attr->text_string),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMannot.make_an_text(
						&rc,
						plan_info,
						&place_attr->par_senv,
						place_attr->go_grid[AN_ANNOT_TEXT],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if( info_flag & TEXT_ENTERED)
	{
		/*^ 
			printf("length:%ld\n",place_attr->text_length);
			analyse_string(loc_text_string,place_attr->text_length);
		*/
		/*|Text entered */
		status=
		DMmake_annot_text(loc_text_string,
				&place_attr->text_length,
				&place_attr->text_buff_size,
				&place_attr->text_st.estx,
				AN_NORMAL,
				character,
				numbytes,
				&place_attr->gtattr,
				me->dual_mode,
				me->dim_type,
				place_attr->par_misc.sixteen_bit_font,
				&current_index,
				&action,
				dummy);
		dm$status(action=RET_STATUS);

		/*^ 
			printf("length:%ld\n",place_attr->text_length);
			analyse_string(loc_text_string,place_attr->text_length);
		*/
	}

	place_attr->text_st.active_symb.Active_just = place_attr->txt_just;
	status=
	GRjust_string(&long_rc,
		      &place_attr->text_string,
		      &place_attr->text_length,
		      &place_attr->text_buff_size,
		      &place_attr->text_st.font_info,
		      &place_attr->text_st.active_display,
		      &place_attr->text_st.active_symb,
		      0,
		      NULL,
		      &place_attr->text_st.text_extents);
	dm$status(action=RET_STATUS);
	place_attr->text_st.estx.text_length = place_attr->text_length;

	status=
	GRcreate_lbs(&long_rc,
		     &active_angle,
		     md_env->md_env.matrix,
		     text_pt,
		     &place_attr->text_st.text_extents,
		     loc_ele_header->geometry.lbsys);
	dm$status(action=RET_STATUS);

	if( dynamics_in_progress)
	{
		lbs_geom = &place_attr->lbsys_geom;
		for( i = 0; i<3; i++)
		{
		   lbs_geom->matrix[3+4*i] = text_pt[i];
		   lbs_geom->matrix[i*4] = place_attr->txt_orie[i];
		   lbs_geom->matrix[i*4 +1] = perp_vec[i];
		   lbs_geom->matrix[i*4 +2] = plan_info->win_plan.matrix[8 +i];
		}
		status =
		om$send(msg = message DMannot.update_leader(
						&rc,
						&num_poles,
					(IGRdouble *)&place_attr->lbsys_geom,
						&place_attr->par_senv,
						plan_info,
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
	}

	if(me->leader)
	{
		status=
		om$send(msg = message DMroot.position_line_string(
						&rc,
						DIM_NO_INDEX,
						&place_attr->go_grid[AN_POLY_LINE],
						md_env,
						num_poles,
						me->break_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (dynamics_in_progress)
	{
		place_attr->par_senv.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMannot.chg_an_dp(&rc, &place_attr->par_senv),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (!dynamics_in_progress)
	{
		/*|- clear the break pts*/

		status =
		om$vla_set_dimension(varray = me->break_pt, size = 0);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}
end implementation DMtxldr;
