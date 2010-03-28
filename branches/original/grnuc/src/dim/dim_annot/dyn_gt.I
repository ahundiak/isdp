/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: dyn_gt.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:09  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:07  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:38  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1994/11/01  10:11:49  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.2  1993/05/19  07:08:07  laxmi
# COMMENT : Checking in Dimensioning TR fixes -Laxmi 19 may 1993.
#
# Revision 220.2  1992/12/27  18:40:34  gvk
# COMMENT : Same gap should be maintained during single or dual mode.
#
Revision 201.9  1992/08/07  15:40:53  grnuc20
COMMENT : ANSI C conversion fixes

Revision 201.8  1992/07/20  05:30:54  poo
COMMENT : ANSI compilance, CR 91N0643, and correcting modified fuction calls.


*/
class implementation DMframe;

#define WHITE_SPACE_COMPENSATION 0.331366
#define AS_DEBUG	1

#include "dpdef.h"
#include "dimmod.h"

extern IGRboolean 	BSnorvec(), BSmkvec(), BScrossp();

from DMsrc import DMmodify;

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
	IGRint status, rc, i;
	IGRlong long_rc;
	IGRshort *loc_text_length, tmp_length;
	IGRint num_vertex, last_vtx;
	IGRboolean on_element;
	IGRuchar *loc_text_string;
	struct DPele_header	*loc_ele_header;
	struct DMdyn_annot *place_attr;
	struct DMplan_info  *plan_info;
	struct IGRlbsys  *lbs_geom;

	IGRint hilite = FALSE;
	IGRdouble refer_dir[3], proj_pt[3], target_pt[3], *prev_point;
	IGRvector perp_vec ,curr_dir,elem_dir;
	IGRdouble ext_line[2][3];
	IGRdouble active_angle = 0.0, offset,h_val;
	IGRint index,chars_to_erase, curnt_indx, action,dummy;

	extern IGRboolean dynamics_in_progress;

	place_attr = (struct DMdyn_annot *)info;
	plan_info = &place_attr->plan_info;

	memcpy(proj_pt,cursor,3*sizeof(double));
	
	if(( control & FILL_INFO) ||
	   ( me->dim_state & DIM_NEEDS_UPDATE))
	{
		status=
		om$send(msg = message DMannot.fill_info(&rc,
						control,
						0,
						info,
						md_env),
			targetid =my_id );
		dm$status(action = RET_STATUS);

		me->dim_state &= (~DIM_NEEDS_UPDATE);
	}

	/*|set the local pointers*/

	loc_ele_header = &place_attr->ele_header;
	loc_text_length = &place_attr->text_length;
	loc_text_string = (IGRuchar *)loc_ele_header->ele_spec_att.text->text_string;

	/*^
		printf("text_length:%d\n",*loc_text_length);
		printf("text_string:%d\n",loc_text_string);
		printf("text entered:%d\n",(info_flag &TEXT_ENTERED));
		analyse_string(loc_text_string,*loc_text_length);
	*/

	if( (info_flag & TEXT_ENTERED ))
	{
		status=
		DMmake_annot_text(loc_text_string,
				loc_text_length,
				&place_attr->text_buff_size,
				&place_attr->text_st.estx,
				AN_NORMAL,
				character,
				numbytes,
				&place_attr->gtattr,
				me->dual_mode,
				me->dim_type,
				place_attr->par_misc.sixteen_bit_font,
                                &curnt_indx,
				&action,
				dummy);
		dm$status(action=RET_STATUS);

		if( action & SET_SINGLE_MODE)
		{
			me->dual_mode = DUAL_MODE_OFF;
		}
		else if( action & SET_DUAL_MODE)
		{
			me->dual_mode = DUAL_MODE_ON;
		}


		if(me->dual_mode == DUAL_MODE_ON)
		{
			/*| Dual mode call field ref*/
  
 		for ( index=0; index<(*loc_text_length); index++ )
 		{
 			if ( ( loc_text_string[index]   == ESC ) &&
 			     ( loc_text_string[index+1] == 'M' ) )
                         {
 			       memcpy(&h_val,&loc_text_string[index+4],8);	 
 			       h_val += WHITE_SPACE_COMPENSATION;
 			       memcpy(&loc_text_string[index+4],&h_val,8);
                                break;
 			}
 
 		}
 
			DMfld_fil(
				loc_text_string,
				*loc_text_length,
				&place_attr->text_st.active_display,
				&place_attr->text_st.active_symb);
		}
	}
	/*^ analyse_string(loc_text_string,*loc_text_length); */

	vec_equal(proj_pt,target_pt);
	
	status =
	om$send(msg = message DMframe.get_tol_just(
						&rc,
						target_pt,
						place_attr->src_type,
						place_attr->box,
						plan_info,
						&place_attr->text_st.active_symb.Active_just,
						&me->bln_dir,
						&on_element,
						(double *)ext_line,
						&place_attr->par_senv,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	tmp_length = *loc_text_length ;
	status=
	GRjust_string(&long_rc,
		      &loc_text_string,
		      loc_text_length,
		      &place_attr->text_buff_size,
		      &place_attr->text_st.font_info,
		      &place_attr->text_st.active_display,
		      &place_attr->text_st.active_symb,
		      0,
		      NULL,
		      &place_attr->text_st.text_extents);
	dm$status(action=RET_STATUS);
	place_attr->text_st.estx.text_length = *loc_text_length;


	status=
	GRcreate_lbs(&long_rc,
		&active_angle,
		md_env->md_env.matrix,
		(IGRdouble *)cursor,
		&place_attr->text_st.text_extents,
		loc_ele_header->geometry.lbsys);
	dm$status(action=RET_STATUS);

	/*^
		print_point("diag 1",loc_ele_header->geometry.lbsys->diag_pt1);
		print_point("diag 2",loc_ele_header->geometry.lbsys->diag_pt2);
	*/

	/*| -  End of text update   */

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
	last_vtx = 3*(num_vertex -1);

	if(me->leader)
	{
		prev_point = &me->break_pt[ last_vtx - 3];
		if( num_vertex > 2)
		{
			BSmkvec(&rc,refer_dir,prev_point ,&me->break_pt[last_vtx - 6]);
			BSnorvec(&rc,refer_dir);
		}
		else
		{
			vec_equal(place_attr->src_dir,refer_dir);
		}
	/*^
	    print_point("src_dir",refer_dir);
	    print_point("prev point",prev_point);
	*/
	}

	if(me->leader)
	{
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
		status=
		om$send(msg = message DMannot.make_lead_line(
					&rc,
					&place_attr->par_senv,
					plan_info,
					place_attr->go_grid[AN_POLY_LINE],
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);	
	}
	else
	{
		vec_equal(place_attr->src_dir,curr_dir);
		memcpy(me->break_pt,target_pt, 3*sizeof(IGRdouble));
		hilite = FALSE;
	}

	if(dynamics_in_progress)
	{
		/*| - Update the text to the current position */

		lbs_geom = place_attr->ele_header.geometry.lbsys;

		BScrossp(&rc,&plan_info->win_plan.matrix[8],place_attr->txt_orie,perp_vec);
	
		for( i = 0; i<3; i++)
		{
		   lbs_geom->matrix[i*4 +3] = target_pt[i];
		   lbs_geom->matrix[i*4]= place_attr->txt_orie[i];
		   lbs_geom->matrix[i*4 +1]= perp_vec[i];
		   lbs_geom->matrix[i*4 +2]= plan_info->win_plan.matrix[8+i];
		}

		if(me->dual_mode && 
		  ((place_attr->text_length + 2) < place_attr->text_buff_size))
		{
			int length;
			length = place_attr->text_length;
			place_attr->text_string[length++] = 27;
			place_attr->text_string[length++] = 'E';
			place_attr->text_st.text_info.estx->text_length  = length;
		}

		status =
		om$send( msg = message DMframe.update_text_box(
						&long_rc,
						loc_text_string,
						&place_attr->text_st.estx,
						lbs_geom,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		place_attr->text_st.text_info.estx->text_length = place_attr->text_length;

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

		place_attr->par_senv.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMannot.chg_an_dp(&rc, &place_attr->par_senv),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
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
	if(!me->leader && !on_element )
	{
		BSmkvec(&rc,elem_dir,ext_line[1],ext_line);
		BSnorvec(&rc,elem_dir);
		
		offset = - 0.5 * place_attr->par_senv.txt_heig;
		MATH_ptdelta( &rc,ext_line,elem_dir,offset,ext_line);

		/*^print_point("ext_line",ext_line);*/

		status=
		om$send(msg = message DMroot.position_line(
						&rc,
						DIM_ULINE,
						(struct GRid *)NULL,
						md_env,
						(double *)ext_line),
			targetid = my_id);
		dm$status(action= RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_ULINE,
						md_env),
			targetid = my_id);
		dm$status(action= RET_STATUS);
	}

	if(!dynamics_in_progress)
	{
		struct IGRline bore_line;
		double point2[3];
		/*| - update DMsrc object to the current position */

		if(!me->leader)
		{
			bore_line.point1 = proj_pt;
			for(i = 0; i<3;i++)
				point2[i] = proj_pt[i] + plan_info->win_plan.matrix[8 +i];
			bore_line.point2 = point2;

			status =
			om$send(msg = message DMsrc.DMmodify(
							&rc,
							md_env,
							TRUE,
							FALSE,
							&bore_line),
				p_chanselect = &ND_father,
				from = AN_ROOT_ELEM1,
				to = AN_ROOT_ELEM1);
			dm$status(action = RET_STATUS);
		}
	}

	/*| - position profile symbol  */

	if( me->tol_symbol == PROFILE_SURFACE_TOT)
	{
		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						FALSE,
						DIM_MEA_TERM,
						NULL,
						md_env,
						-1,
						prev_point,
						plan_info->win_plan.vec_xpos,
						&plan_info->win_plan.matrix[8],
						NULL,
						NULL),
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

end implementation DMframe;
