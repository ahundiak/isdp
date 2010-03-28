/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: frame.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:17  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:15  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:45  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.5  1994/11/01  10:11:55  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.4  1993/09/27  09:34:12  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.3  1993/08/03  05:42:44  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.2  1993/05/19  07:07:56  laxmi
# COMMENT : Checking in Dimensioning TR fixes -Laxmi 19 may 1993.
#
# Revision 220.3  1992/12/27  18:40:32  gvk
# COMMENT : Same gap should be maintained during single or dual mode.
#
Revision 201.13  1992/09/02  13:07:01  gvk
COMMENT : Fix for Feature control frame & vertical line angle.

Revision 201.12  1992/08/26  13:50:30  gvk
COMMENT : Fix for dynamics line display for noleader dual mode

Revision 201.11  1992/08/07  15:40:50  grnuc20
COMMENT : ANSI C conversion fixes

Revision 201.10  1992/07/20  05:31:01  poo
COMMENT : ANSI compilance, CR 91N0643, and correcting modified fuction calls.

Revision 201.8  1992/02/03  13:00:49  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992


*/

class implementation DMframe;

#define AS_DEBUG	1

#include "dpdef.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "bsvalues.h"
#include "bspt_on_lne.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpts.h"

extern IGRboolean	BSproj0();
extern double fabs();
extern double sqrt();
from dim_param import give_internal, edit;
from DMsrc import DMgive_tangent, DMgive_src_info;
from GRtext import GRgettxattr,GRfield_inquire; 
#define WHITE_SPACE_COMPENSATION 0.331366

method fill_info( IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status,rc, i;
	IGRlong long_rc;
	struct DMdyn_annot *place_attr;
	struct IGRbsp_curve *bsp_curve;
	struct GRid list[MAX_DIM_ROOTS];
 	IGRint count;
 	extern GRclassid OPP_GR3dtext_class_id;
	IGRdouble active_angle,h_val;
	IGRdouble *prev_point;
	IGRint num_vertex,index;
	struct GRmd_env mod_info;

	/* - Gather data     */

	place_attr = (struct DMdyn_annot *)info;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status=
	om$send(msg = message DMannot.gather_data( &rc,
					count,
					list,
					place_attr->attach_pt,
					NULL,
					&place_attr->plan_info,
					&place_attr->par_senv,
 					md_env),
		targetid =my_id);
	dm$status(action=RET_STATUS);
	
	status =
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		p_data = &place_attr->par_misc);
	dm$status(action = RET_STATUS);
	status =
	om$send(msg = message DMannot.get_graphics(
					TRUE,
					&place_attr->go_grid[AN_ANNOT_TEXT],
					(me->leader ? &place_attr->go_grid[AN_POLY_LINE] : NULL),
					(me->leader ? &place_attr->go_grid[AN_TER_TEXT] : NULL),
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

	if (md_env->md_env.matrix_type != MAIDMX)
		mod_info = *md_env;

	status=
	om$send(msg = message DMsrc.DMgive_tangent(
					&rc,
					(IGRboolean *)&place_attr->src_type,
					place_attr->src_dir,
					place_attr->box,
					&mod_info),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if (place_attr->src_type == POINT_TYPE)
	{
		/*|- Element is point type */

		for(i=0; i<3; i++)
		place_attr->src_dir[i] =
		place_attr->plan_info.act_plan.vec_xpos[i];
	}

	place_attr->text_st.active_symb.Active_just = LEFT_CENTER;

	ANget_disp_par(
		&place_attr->par_senv,
		&place_attr->text_st,
		md_env->md_id.osnum);

	/*| set the text weight to text weight */

	place_attr->text_st.active_display.weight = place_attr->par_senv.txt_weig;
	if(me->leader)
	{
		status =
		om$send(msg = message GRvg.GRgenabsg(&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						(char **)&bsp_curve),
			targetid = place_attr->go_grid[AN_POLY_LINE].objid,
			targetos = place_attr->go_grid[AN_POLY_LINE].osnum);
		dm$status(action = RET_STATUS);

		num_vertex = bsp_curve->num_poles;

		status=
		om$vla_set_dimension(varray = me->break_pt,
				     size  = 3*num_vertex );
		dm$status(action = RET_STATUS);

		memcpy( me->break_pt,
			bsp_curve->poles,
			3*sizeof(IGRdouble) * num_vertex);
	}
	else
	{	
		num_vertex = 1;
		status =
		om$vla_set_dimension(varray = me->break_pt,
				     size  = 3);
		dm$status(action = RET_STATUS);
	}
	vec_equal(place_attr->attach_pt,me->break_pt);
	
	/*| move to DMplace */
	place_attr->gtattr.text_font = place_attr->par_senv.text_font;

	DMretrieve_font(&long_rc, OM_Gw_current_OS, 
			"100",&place_attr->gtattr.geom_font);

	DMretrieve_font(&long_rc, OM_Gw_current_OS,
			"102",&place_attr->gtattr.ter_font);

	if(!(place_attr->text_length))
	{
		DMadd_tolerance_symbol(place_attr->text_string,
			       &place_attr->text_length,
			       &place_attr->gtattr,
				me->dual_mode,
				&place_attr->text_st.estx,me->dim_type);
	}
	else if( me->dim_type == FEATURE_CONTROL_FRAME)
	{
		DMreplace_tol_sym(place_attr->text_string,
			          &place_attr->text_length,
				  place_attr->gtattr.tol_symbol,
				  me->dual_mode,
				  &place_attr->text_st.estx,
				  &place_attr->gtattr);
	}

	/*"dim type:%d\n",me->dim_type*/
	DMupdt_disp_chars(place_attr->text_string,
			  &place_attr->text_length,
			  &place_attr->gtattr,
			  (me->dual_mode),
			  me->dim_type);
	place_attr->gtattr.disp_char_index = place_attr->gtattr.num_disp_char;

	/*"length:%d\n",place_attr->text_length*/
	/*
	if(me->leader  && (num_vertex > 2))
	{
		for( i = 0;i<3;i++)
			lea_dir[i] = me->break_pt[3*(num_vertex -2)+i] -
			          me->break_pt[3*(num_vertex -3)+i];	
	}
	else
	{
		vec_equal(place_attr->plan_info.act_plan.vec_xpos,lea_dir);
	}
	*/

	DMget_annot_txt_info(
		&place_attr->plan_info,
		&place_attr->par_senv,
		place_attr->txt_orie,
		&place_attr->plan_info.win_plan.matrix[8],
		&place_attr->txt_just,
		place_attr->src_dir);

	if(me->dual_mode == DUAL_MODE_ON)
	{
	 	for ( index=0; index<place_attr->text_length; index++ )
		{
			if ( ( place_attr->text_string[index]   == ESC ) &&
			( place_attr->text_string[index+1] == 'M' ) )
			{
				memcpy(&h_val,&place_attr->text_string[index+4],8);	 
	 		       h_val += WHITE_SPACE_COMPENSATION;
	 		       memcpy(&place_attr->text_string[index+4],&h_val,8);
	 		       break;
			}
	 	}
		/*| Dual mode call field ref*/

		DMfld_fil(
			place_attr->text_string,
			place_attr->text_length,
			&place_attr->text_st.active_display,
			&place_attr->text_st.active_symb);
	}

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
	dm$status(action = RET_STATUS);

	place_attr->text_st.text_info.estx->text_length=place_attr->text_length;
	place_attr->text_st.text_info.text_string =(IGRchar *)place_attr->text_string;

        dp$build_dis_buffer(buffer = &place_attr->ele_header,
                       type = IGRLB,
                       display_att = &place_attr->text_st.active_display,
                       ele_spec_att = &place_attr->text_st.text_info,
                       geometry = &place_attr->lbsys_geom);
	active_angle = 0.0;

	num_vertex = om$dimension_of(varray = me->break_pt)/3;
	prev_point = &me->break_pt[3*(num_vertex -2)];

	status =
	GRcreate_lbs(&long_rc,
		     &active_angle,
		     md_env->md_env.matrix,
		     prev_point,
		     &place_attr->text_st.text_extents,
		     place_attr->ele_header.geometry.lbsys);
	dm$status(action=RET_STATUS);

	status =
	om$send(msg = message DMframe.make_profile_sym(
					&rc,
					&place_attr->par_senv,
					&place_attr->plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_disp_list(
	IGRint *msg;
	IGRint *count;
	struct GRid *list;
	struct GRmd_env *md_env)
{
	IGRint status, rc , index;
	IGRint go_index[10],go_type[10];
	IGRint num_obj;

	if(me->leader)
	{
		go_index[0] = DIM_LINE1;
		go_index[1] = DIM_LINE2;
		go_index[2] = DIM_LEADER;
		go_index[3] = DIM_ORI_TERM;
		go_index[4] = DIM_LINE3;
		go_index[5] = DIM_MEA_TERM;
		num_obj = 6;
	}
	else
	{
		go_index[0] = DIM_LINE1;
		go_index[1] = DIM_LINE2;
		go_index[2] = DIM_ULINE;
		go_index[3] = DIM_LINE3;
		num_obj = (me->dual_mode)?4:3;
	}

	go_type[0] = DM_LINE;
	go_type[1] = DM_LINE;
	go_type[2] = (me->leader)? DM_LINE_STR:DM_LINE;
	go_type[3] = (me->leader)? DM_TEXT:DM_LINE;
	go_type[4] = DM_LINE;
	go_type[5] = DM_TEXT;

	*count = 0;
	for( index = 0; index<num_obj;index++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						go_index[index],
						FALSE,
						go_type[index],
						md_env,
						&list[*count]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	if(list[*count].objid != NULL_OBJID)
			(*count)++;
	}
	return(OM_S_SUCCESS);
}
method put_dim_attr(struct annot_attr *attr)
{
	me->dim_type = attr->dim_type;
	me->dual_mode = attr->dual_mode;
	return(OM_S_SUCCESS);
}

method update_text_box(
	IGRlong *msg;
	IGRuchar *text_string;
	struct IGRestx *estx;
	struct IGRlbsys *lbs_geom;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, index;
	IGRlong long_rc, bsrc;
	IGRdouble box[4][3];
	struct vfont_entry font_info;
	IGRint go_type[3];
	double descent_r,box_orie[3];
	struct DMsenv_param par_senv;
	struct IGRdisplay display;

	IGRdouble dim_line1[6],dim_line2[6],dim_line3[6];
	struct just_pts just_pts;
	IGRdouble dist1,dist2;
	IGRuchar *contents, field_num;
	IGRint num_disp_line;

	IGRdouble *disp_line[3];

	go_type[0] = DIM_LINE1;
	go_type[1] = DIM_LINE2;
	go_type[2] = DIM_LINE3;

	status =
	dm$get_dim_param(
		type = DM_SENV_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = &par_senv);
	dm$status(action = RET_STATUS);

	if(me->dual_mode == DUAL_MODE_OFF)
	{
		/*| Get font info */

		status=
		font$get_info(
			msg = &long_rc,
			font_num = &par_senv.text_font,
			font_info = &font_info);
		dm$status(action = RET_STATUS);

		MATH_get_box_points(&rc,lbs_geom,box);

		descent_r = (font_info.descent * 2 * par_senv.txt_heig )/
		    		(font_info.bodysize - font_info.descent);

		vec_sub( box[3],box[0],box_orie);
		BSnorvec(&bsrc,box_orie);

		MATH_ptdelta(&rc,box[0],box_orie,descent_r,box[0]);
		MATH_ptdelta(&rc,box[1],box_orie,descent_r,box[1]);
		MATH_ptdelta(&rc,box[2],box_orie,-descent_r,box[2]);
		MATH_ptdelta(&rc,box[3],box_orie,-descent_r,box[3]);

		/*^
			print_point("top line point1",box[2]);
			print_point("top line point2",box[3]);
			print_point("bottom line point1",box[0]);
			print_point("bottom line point2",box[1]);
		*/

		for( index = 0;index < 2;index++)
		{
			disp_line[index] = box[2*index];
		}
		num_disp_line = 2;
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_LINE3,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		display.color = par_senv.dim_colr;
		display.style = 0;
		display.weight = par_senv.txt_weig;
		for( index = 1;index< 4;index++)
		{
			contents = NULL;
			field_num = index;

			status =
			GRfield_inquire(&long_rc,
					text_string,
					estx,
					&display,
					lbs_geom,
					&field_num,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					NULL,
					&contents,
					NULL,
					NULL,
					NULL,
					&just_pts);
			dm$status(action = RET_STATUS);

			if( index == 1)
			{
				DMlineptpt(just_pts.left_cap,just_pts.right_cap,dim_line2);
				DMlineptpt(just_pts.left_base,just_pts.right_base,dim_line1);
				for( i = 0; i<3; i++)
				{
					dim_line3[i] = (just_pts.right_cap[i] +just_pts.right_base[i])/2;
					dim_line3[i+3]  = dim_line3[i] + 
						       just_pts.right_cap[i] - just_pts.left_cap[i];
				}
			}
			else if( index == 2)
			{
				BSproj0(&bsrc,just_pts.right_base,dim_line3,&dim_line3[3]);
				BSproj0(&bsrc,just_pts.right_cap,dim_line2,&dim_line2[3]);
			}
			else if( index == 3)
			{
				dist1 = BSdistptpts(&long_rc,dim_line3,&dim_line3[3]);
				dist2 = BSdistptpts(&long_rc,just_pts.left_cap,just_pts.right_cap);

				/*"dist1:%lf\tdist2:%lf\n",dist1,dist2*/

				BSproj0(&bsrc,just_pts.right_base,dim_line1,&dim_line1[3]);
				if( dist2 > dist1)
				{
					BSproj0(&bsrc,just_pts.right_cap,dim_line3,&dim_line3[3]);
				}
			}
		}

		num_disp_line = 3;
		disp_line[0] = dim_line1;
		disp_line[1] = dim_line2;
		disp_line[2] = dim_line3;

		/*^
			print_point("dim_line1",dim_line1);
			print_point("dim_line1",dim_line2);
			print_point("dim_line1",dim_line3);
		*/
	}

	for(index = 0; index< num_disp_line;index++)
	{
		status=
		om$send(msg = message DMroot.position_line(&rc,
						go_type[index],
						(struct GRid *)NULL,
						md_env,
						disp_line[index]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}


method  set_datum_term(
	IGRlong *msg;
	struct GRid *term_grid;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc)
{
	IGRint status,rc;
	struct GRdpb_text_symb text_symb;
	extern struct DMglobal DM_global;
	IGRchar font_char;

	text_symb.Active_font =
	DMmap_font(
		OM_Gw_current_OS,
		DM_global.term_info[TER_TYPE_FILLED_ARROW].font_num);

	text_symb.Active_just = -1;
	text_symb.Active_charspac= 1;
	text_symb.Active_linespac= 1;
	text_symb.Active_width  = par_env->ter_widt_r * par_env->txt_heig;
	text_symb.Active_height = par_env->ter_heig_r * par_env->txt_heig;

	font_char = 'N';
	status =
	om$send(msg = message DMroot.chgtextattr(
					&rc,
					DIM_NO_INDEX,
					term_grid,
					md_env,
					&text_symb),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_NO_INDEX,
				term_grid,
				md_env,
				1,
		(IGRuchar *)&font_char),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_tol_just(
	IGRint *msg;
	IGRdouble *cursor;
	IGRboolean src_type;
	IGRdouble geometry[4][3];
	struct DMplan_info *plan_info;
	IGRshort *txt_just;
	IGRchar *annot_dir;
	IGRboolean *on_element;
	IGRdouble  ext_line[6];
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env)
{
	IGRint status,rc;
	IGRlong long_rc, bsrc;
	IGRint num_vertex;
	IGRdouble *prev_point,*req_pt;
	IGRpoint targetpt1,targetpt2;
	IGRdouble dist1,dist2,cur_dir[3],angle;
	IGRdouble u_par;
	IGRint txt_posn;
	IGRint index;
	extern GRclassid OPP_GRpoint_class_id;

	num_vertex = om$dimension_of(varray = me->break_pt)/3;
	prev_point = &me->break_pt[3*(num_vertex -2)];

	if(me->leader)
	{
		status = BSmkvec(&long_rc,cur_dir,prev_point,cursor);

		MATH_ang_bet_lines(
			plan_info->win_plan.vec_xpos,
			cur_dir,
			&angle,
			&plan_info->win_plan.matrix[8]);
	
		angle = (angle*180.0)/M_PI;

		if (par_senv->an_orie == TXT_ORIE_VERTICAL )
		{
			if( angle > 5.0 && angle < 175.0 )
				*txt_just = LEFT_CENTER;
			else if ( angle > 175.0 && angle < 185.0 )
				*txt_just = CENTER_BASE;
			else if ( angle > 185.0 && angle < 355.0 )
				*txt_just = RIGHT_CENTER;
			else    *txt_just = CENTER_CAP;
		}
		else if (par_senv->an_orie == TXT_ORIE_HORIZONTAL)
                {
                        if( (angle < 85.0) || angle > 275.0 )
                                *txt_just = LEFT_CENTER;
                        else if( angle > 85.0 && angle < 95.0)
                                *txt_just = CENTER_BASE;
                        else if( angle > 265.0 && angle < 275.0)
                                *txt_just = CENTER_CAP;
                        else    *txt_just = RIGHT_CENTER;
                }
	}
	else
	{
		*on_element = FALSE;
		*txt_just = 0;

		if(src_type == TEXT_TYPE)
		{
			status = BSproj0(&bsrc,
					cursor,
					geometry[0],
					targetpt1);
			status = BSproj0(&bsrc,
					cursor,
					geometry[2],
					targetpt2);

			dist1 = BSdistptpts(&bsrc,cursor,targetpt1);
			dist2 = BSdistptpts(&bsrc,cursor,targetpt2);
			
			txt_posn = (dist1 > dist2) ? TXT_POSN_ABOVE:
						TXT_POSN_EMBEDDED ;
			req_pt = (dist1 >dist2) ?targetpt2:targetpt1 ;

			DMget_active_just(txt_posn,
					DM_TEXT,
					geometry[0],
					geometry[1],
					plan_info->win_plan.matrix,
					txt_just,
					annot_dir);
			*on_element = TRUE;	/* not needed for the text */
			vec_equal(req_pt,cursor);	/*| send back the project point */
		}
		else
		{
			status = BSproj0(&bsrc,
					cursor,
					geometry[0],
					targetpt1);

			BSpt_on_lne(&long_rc,
				    geometry[0],
				    geometry[1],
				    targetpt1,
				    &u_par,
				    on_element);

			DMget_active_just(TXT_POSN_ABOVE,
					DM_LINE,
					targetpt1,
					cursor,
					plan_info->win_plan.matrix,
					txt_just,
					annot_dir);
			req_pt = targetpt1;

			if (src_type == POINT_TYPE)
			{
				/*| Point Generic */

				*txt_just= (*annot_dir?LEFT_CENTER:RIGHT_CENTER);
				*on_element = TRUE;
			}
			else
			{
				if( !(*on_element))
				{
					dist1 = BSdistptpts(&bsrc,geometry[0],targetpt1);
					dist2 = BSdistptpts(&bsrc,geometry[1],targetpt1);
					req_pt = (dist1 > dist2) ? geometry[1]:geometry[0];

					for( index = 0; index<3; index++)
					{
						ext_line[index] = req_pt[index];
						ext_line[index + 3] = targetpt1[index];
					}
				}

				/*| send back the project point */

				vec_equal(targetpt1,cursor);
			}


			/*^
				print_point("first point:",req_pt);
				print_point("first point:",targetpt1);
			*/
		}
	}

	return(OM_S_SUCCESS);
}
method chg_an_dp(IGRint *msg; struct DMsenv_param *par_senv)
{

	IGRint status, rc;
	IGRlong long_rc;
	IGRint i,go_type[4];
	struct IGRdisplay line_display, text_display;
	IGRint sizbuf, nret;
	struct GRid go_grid[4];
	struct GRmd_env mod_info;
	IGRshort current_layer;
        struct DMenv_param par_env;
	IGRboolean invalid_layer;

	*msg = DIM_S_SUCCESS;
	invalid_layer = FALSE;

	DMsplit_senv(par_senv, &par_env, NULL, NULL);

        status =
        om$send(msg = message DMroot.chgdp(&rc, &par_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	sizbuf = sizeof(struct IGRdisplay);
	gr$get_active_display(
		msg = &rc,
		sizbuf = &sizbuf,
		buffer = &line_display,
		nret = &nret);

	line_display.color =
	text_display.color = par_senv->dim_colr;

	line_display.weight = par_senv->dim_weig;
	text_display.weight = par_senv->txt_weig;

	line_display.style =
	text_display.style = 0;

	status =
	om$send(msg = message GRvg.GRchgdp(&long_rc, &line_display),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	current_layer = par_senv->dim_layr;
        if(DMvalid_dim_offset_active_layer(par_senv->dim_layr))
	{
                DMget_current_dim_layer(par_env.dim_layr,
                                        &current_layer, &invalid_layer);
		if (invalid_layer)
			ex$message(msgnumb=DM_E_LyrOutOfRngActLyr);
	}

        status =
        om$send(msg = message GRvg.GRchglevel(&long_rc, &current_layer),
                targetid = my_id);
        dm$status(action = RET_STATUS);


	go_type[0] = DIM_TEXT;
	go_type[1] = DIM_LINE1;
	go_type[2] = DIM_LINE2;
	go_type[3] = DIM_LINE3;

	for( i = 0;i<4;i++)
	{
		status =
		om$send(msg  = message DMroot.return_dim_go(
						&rc,
						go_type[i],
						FALSE,
						-1,
						&mod_info,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (rc == DIM_S_SUCCESS)
		{
			status =
			om$send(msg = message GRvg.GRchgdp(&long_rc, &text_display),
				targetid =go_grid[i].objid,
				targetos = go_grid[i].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method make_profile_sym(
	IGRint *msg;
	struct DMsenv_param *p_par_senv;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRlong long_rc;
	IGRdouble *prof_orie;
	IGRuchar font_char;
	struct GRdpb_text_symb text_symb;
	struct GRid brk_grid, lead_grid;
	struct IGRbsp_curve *bsp_curve;
	IGRdouble place_pt[3];
	extern struct DMglobal DM_global;

	if(   me->tol_symbol != PROFILE_SURFACE_TOT)
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DIM_MEA_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send( msg = message DMroot.return_dim_go(
						&rc,
						DIM_LEADER,
						FALSE,
						DM_LINE,
						md_env,
						&lead_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		if( lead_grid.objid == NULL_OBJID)
			return(OM_S_SUCCESS);
			
		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
			targetid = lead_grid.objid,
			targetos = lead_grid.osnum);
		dm$status(action = RET_STATUS);

		if( bsp_curve->num_poles <= 2)
			return(OM_S_SUCCESS);

		for( i = 0;i<3;i++)
		{
			place_pt[i] = bsp_curve->poles[(bsp_curve->num_poles-2)*3 + i];
		}

		/*^print_point(" place pt",place_pt);*/


		status =
		om$send( msg = message DMroot.return_dim_go(
						&rc,
						DIM_MEA_TERM,
						TRUE,
						DM_TEXT,
						md_env,
						&brk_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		prof_orie = plan_info->win_plan.vec_xpos;

		text_symb.Active_font =
		DMmap_font(
			OM_Gw_current_OS,
			DM_global.term_info[TER_TYPE_FILLED_ARROW].font_num);

		text_symb.Active_just = CENTER_CENTER;
		text_symb.Active_charspac = 1;
		text_symb.Active_linespac = 1;
		text_symb.Active_width  = p_par_senv->txt_widt;
		text_symb.Active_height = p_par_senv->txt_heig;

		status =
		om$send(msg = message DMroot.chgtextattr(
						&rc,
						DIM_NO_INDEX,
						&brk_grid,
						md_env,
						&text_symb),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		font_char = 'O';

		status =
		om$send(msg = message DMroot.replace_text(
					&rc,
					DIM_NO_INDEX,
					&brk_grid,
					md_env,
					1,
					&font_char),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.position_text(
						&rc,
						FALSE,
						DIM_NO_INDEX,
						&brk_grid,
						md_env,
						CENTER_CENTER,
						place_pt,
						plan_info->win_plan.vec_xpos,
						&plan_info->win_plan.matrix[8],
						NULL,
						NULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method set_profile_type(IGRchar profile_type)
{
	me->tol_symbol = profile_type;
	return(OM_S_SUCCESS);
}

method get_profile_type(IGRchar *profile_type)
{
	*profile_type = me->tol_symbol;
	return(OM_S_SUCCESS);
}

method check_profile_type(IGRint *msg;
		IGRint tol_sym;
		struct GRmd_env *md_env)
{
	IGRint status,rc;
	IGRlong long_rc;
	struct IGRbsp_curve *bsp_curve;
	struct GRid lead_grid;

	*msg = OM_S_SUCCESS;

	if( tol_sym != PROFILE_SURFACE_TOT)
	{
		return(OM_S_SUCCESS);
	}
	status =
	om$send( msg = message DMroot.return_dim_go(
					&rc,
					DIM_LEADER,
					FALSE,
					DM_LINE,
					md_env,
					&lead_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	if( lead_grid.objid == NULL_OBJID)
	{
		*msg = FALSE;
		return(OM_S_SUCCESS);
	}
			
	status =
	om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(char **)&bsp_curve),
		targetid = lead_grid.objid,
		targetos = lead_grid.osnum);
	dm$status(action = RET_STATUS);

	if( bsp_curve->num_poles <= 2)
	{
		*msg = FALSE;
		return(OM_S_SUCCESS);
	}
	return(OM_S_SUCCESS);
}

method set_tol_mode( IGRchar tol_mode)
{
	me->dual_mode = tol_mode;
	return(OM_S_SUCCESS);
}
end implementation DMframe;
