class implementation DMsurf;

#include "dimsurf.h"
#include "bsvalues.h"
#include "dimmod.h"
#include "fielddef.h"
#include "msdef.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "bspt_on_lne.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"

#define AS_DEBUG	1

from DMsrc	import DMgive_tangent, DMmodify;
from GRlinear	import GRgetpolyline, GRputpolyline;
from GRtext import GRreplace_text, GRgettxattr;

extern double fabs();
extern IGRboolean	BSproj0();

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	struct annot_attr *an_attr;
	IGRint num_vertex;
	struct GRid go_grid[MAX_SURF_COMP], null_grid;
	struct DMsenv_param par_senv;
	struct DMplan_info plan_info;
	IGRpoint start_pt, end_pt, pt;
	IGRdouble *vertex;
	struct GRmd_env mod_info;
	BSrc	bs_rc;

	an_attr = (struct annot_attr *)attr;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	/* - VALIDATE ROOTS - */

	status =
	om$send(msg = message DMroot.validate_roots(&rc, count, list),
		targetid = my_id);
 	dm$status(action = RET_STATUS);

	/*|- Connect Parents - */

	null_grid.objid = NULL_OBJID;
	null_grid.osnum = OM_Gw_current_OS;

	me->comp_mask	= 0;
	me->state	= ND_DEFAULT;

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					list,
					null_grid,
					ND_NEW),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.set_degrade(md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| Set the Instance */

	me->dim_type	= an_attr->dim_type;
	me->dim_state	= an_attr->dim_state;
	me->leader 	= an_attr->leader;
	me->geom_type	= an_attr->geom_type;
	me->display	= an_attr->display;
	me->bln_dir	= 0;

	/*"dim_type:%d\n",an_attr->dim_type*/

	status =
	om$send(msg = message DMannot.gather_data(
					&rc,
					count,
					list,
					start_pt,
					end_pt,
					&plan_info,
					&par_senv,
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->leader)
	{
		num_vertex = an_attr->num_brkpt + 3;

		/*"num_vertex = %d\n", num_vertex*/

		status =
		om$vla_set_dimension(varray = me->break_pt,
			size = 3 * num_vertex);
		dm$status(action = RET_STATUS);

		vec_equal(start_pt, me->break_pt);

		memcpy(	&me->break_pt[3],
			an_attr->brkpt,
			sizeof(IGRdouble) *(3*an_attr->num_brkpt));

		if (num_vertex < 4)
		{
			vertex = &me->break_pt[3*(num_vertex - 2)];
			vec_equal(start_pt, vertex);
			vertex = &me->break_pt[3*(num_vertex - 1)];
			vec_equal(start_pt, vertex);
		}
	
		for (i=1; i<num_vertex; i++)
		{
			BSproj1(&bs_rc,
				&me->break_pt[3*i],
				&plan_info.win_plan.matrix[8],
				start_pt,
				pt);
			memcpy(&me->break_pt[3*i], pt, sizeof(IGRpoint));
		}
	}

	status =
	om$send(msg = message DMsurf.make_surf_text(
					&rc,
					&plan_info,
					&par_senv,
					go_grid,
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->leader)
	{
		status =
		om$send(msg = message DMsurf.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					go_grid[SURF_LEADER],
					&mod_info),
			targetid = my_id);
		dm$status(action = RET_STAUS);
	}

	status =
	om$vla_set_dimension(varray = me->break_pt, size = 0);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method DMcompute_node(
	IGRlong *msg;
	IGRint count;
	IGRint cn_type;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, flag;
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRpoint start_pt,end_pt;
	struct GRid go_grid[MAX_SURF_COMP];
	IGRdouble orie[3], txt_dir[3];
	IGRint num_vertex;
	IGRboolean src_type;
	IGRdouble sym_posn[MAX_SURF_COMP*3], line[6];
	IGRdouble *current_pt, txt_offset[3], base_pt[3];
	IGRdouble *prev_point;
	BSrc	bs_rc;

	/*|- Gather data */

	status = 
	om$send(msg = message DMannot.gather_data(
                                        &rc,
                                        count,
                                        list,
                                        start_pt,
                                        end_pt,
                                        &plan_info,
                                        &par_senv,
                                        md_env),
                targetid = my_id);
  	dm$status(action = RET_STATUS);

	/*|- get components */

	status =
        om$send(msg = message DMsurf.get_components(
                                        FALSE,
                                        go_grid,
                                        md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	/*|- Fill Leader Info */

	status = 
	om$send(msg = message DMsurf.fill_leader_info(
        				&rc,
        				start_pt,
        				end_pt,
        				go_grid[SURF_LEADER],
        				go_grid[SURF_TEXTA],
					&plan_info,
        				md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
		
	if (me->leader)
	{
		math_v_equal(orie,plan_info.win_plan.vec_xpos);
		math_v_equal(txt_dir, orie);

		prev_point = &me->break_pt[(num_vertex -3) *3];
		current_pt = &me->break_pt[(num_vertex -2) *3];

		DMget_direction(
			prev_point,
			current_pt,
			plan_info.act_plan.matrix,
			&flag);
	
		if(flag == AN_BEFORE)
			me->bln_dir = SURF_LEFT;
		else	me->bln_dir = SURF_RIGHT;
	}
	else
	{
		om$send(msg = message DMsrc.DMgive_tangent(
                                        &rc,
                                        &src_type,
                                        orie,
                                        (IGRdouble (*)[])line,
                                        md_env),
                targetid = list[AN_ROOT_ELEM1].objid,
                targetos = list[AN_ROOT_ELEM1].osnum);

		if (src_type == LINE_TYPE)
		{
			status = BSproj0(&bs_rc,
					me->break_pt,
					line,
					base_pt);

			/*^ print_point("src dir", orie); */

			if (BSdotp(&bs_rc, plan_info.win_plan.vec_xpos, orie) > 0.0)
			{
				math_v_equal(txt_dir, orie);
			}
			else
			{
				math_v_opposite(txt_dir, orie);
			}
		}
		else
		{
			/*- Normal surface texture symbol without a leader
			    should have a line type parent, if it had lost
			    its parent(Detached) a point type is returned,
			    in this case the window x dir and old point
			    used.
			*/

			math_v_equal(txt_dir, plan_info.win_plan.vec_xpos);
			math_v_equal(base_pt, start_pt);
		}

		current_pt = base_pt;
	}

	/*^ print_point("text dir", txt_dir); */

	status =
	om$send(msg = message DMsurf.make_surf_text(
					&rc,
					&plan_info,
					&par_senv,
					go_grid,
					md_env),
		targetid= my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send(msg = message DMsurf.compute_symbol_positions(
        					&rc,
        					current_pt,
						txt_dir,
        					&par_senv,
        					&plan_info,
        					sym_posn),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsurf.set_surf_text_attr(
					&rc,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send(msg = message DMsurf.position_surf_text(
					&rc,
        				go_grid,
					txt_dir,
        				&par_senv,
        				&plan_info,
        				sym_posn,
        				md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send(msg = message DMsurf.position_surf_symbol(
       					&rc, 
        				sym_posn,
        				txt_dir,
        				go_grid,
        				&par_senv,
					&plan_info,
        				md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsurf.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					go_grid[SURF_LEADER],
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->leader)
	{
		status = 
		om$send(msg = message DMannot.make_an_term(
						&rc,
						&plan_info,
						&par_senv,
						go_grid[SURF_TERM],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- No Leader option */

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		go_grid[SURF_TERM].objid = NULL_OBJID;
	}

	status = 
	om$send(msg = message DMsurf.chg_an_dp(
					&rc,
					&par_senv),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	if (me->leader)
	{
		status =
		om$vla_set_dimension(varray = me->break_pt, size = 0);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- clear the start pt*/

		txt_offset[0] = (me->break_pt[0] - start_pt[0])/
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

		txt_offset[1] = (me->break_pt[1] - start_pt[1])/
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

		txt_offset[2] = (me->break_pt[2] - start_pt[2])/
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

		vec_equal(txt_offset, me->break_pt);

		/*"break_pt=(%lf, %lf, %lf)\n", me->break_pt[0], me->break_pt[1], me->break_pt[2]*/
	}

	me->dim_state &=(~DIM_NEEDS_UPDATE);

	return(OM_S_SUCCESS);
}

method compute_symbol_positions(
	IGRint *msg;
        IGRdouble *point;
	IGRdouble *xaxis;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
        IGRdouble *sym_posn)
{
	IGRint i,rc;
	IGRdouble xoffset1, xoffset2,xoffset3;
	IGRdouble xoffset4, xoffset5;
	IGRdouble yoffset0,yoffset1, yoffset2;
	IGRdouble yoffset3, base_offset;
	IGRdouble yaxis[3], base_pt[3];
	IGRdouble descent_r, txt_size;
	struct vfont_entry font_info;
	BSrc	bs_rc;

	*msg = MSSUCC;

	/*^ print_point("xaxis", xaxis); */

	BSnorvec(&bs_rc, xaxis);

	MATH_rotate_vector(
		&rc,
		xaxis,
		(M_PI/2),
		plan_info->win_plan.matrix,
		yaxis);

	BSnorvec(&bs_rc, yaxis);

	/*|- Get font info */

        font$get_info(msg = &rc,
            font_num = &par_senv->text_font,
            font_info = &font_info);

	descent_r = font_info.descent/ font_info.bodysize;

	txt_size = par_senv->txt_heig + (par_senv->txt_heig * descent_r);

	/*|- Compute offsets */

	xoffset1 = 0.866025 * txt_size; /* 0.5 x sqrt(3) */
	xoffset2 = 2 * xoffset1 ;
	xoffset3 = xoffset2 + (1.25 * txt_size);
	xoffset4 = xoffset1 + (0.25 * txt_size);
	xoffset5 = xoffset1 - (0.5 * txt_size);
	yoffset0 = txt_size;
	yoffset1 = 1.5 * txt_size;
	yoffset2 = 2.9 * txt_size;
	yoffset3 = 3.0 * txt_size;

        if (me->sym_posn == SURF_BELOW)
	{
		/*|- Symbol Position Below */

		xoffset1 = -xoffset1;
		xoffset2 = -xoffset2;
		xoffset3 = -xoffset3;
		xoffset4 = -xoffset4;
		xoffset5 = -xoffset5;
		yoffset0 = -yoffset0;
		yoffset1 = -yoffset1;
		yoffset2 = -yoffset2;
		yoffset3 = -yoffset3;
	}

	/*^
		printf("text hieght = %f\n", par_senv->txt_heig);
		printf("xoffset1 = %f\n", xoffset1);
		printf("xoffset2 = %f\n", xoffset2);
		printf("xoffset3 = %f\n", xoffset3);
		printf("yoffset0 = %f\n", yoffset0);
		printf("yoffset1 = %f\n", yoffset1);
		printf("yoffset2 = %f\n", yoffset2);
		printf("yoffset3 = %f\n", yoffset3);
	*/

	if (me->leader)
	{
		if ((me->bln_dir == SURF_RIGHT)&& (me->sym_posn == SURF_ABOVE)
		||  (me->bln_dir == SURF_LEFT)&& (me->sym_posn == SURF_BELOW))
			base_offset = (me->front_len +1.5) * par_senv->txt_widt;
		else    base_offset = (me->rear_len + 3.75) * par_senv->txt_widt;

		if (me->bln_dir == SURF_LEFT)
		   base_offset = -base_offset;

		for (i=0; i<3; i++)
		    base_pt[i] = point[i] + (base_offset * xaxis[i]);
	}
	else
	{
		math_v_equal(base_pt, point);
	}

	/*^ print_point("base_pt", base_pt); */

	/*|- Compute text position wrto x-axis*/

	for (i=0; i<3; i++)
	{
		sym_posn[MID_PT+i] = base_pt[i] + (xaxis[i] * xoffset1);
		sym_posn[START_PT+i] = base_pt[i] - (xaxis[i] * xoffset1);
		sym_posn[BASE_PT+i] = base_pt[i];
		sym_posn[END_PT+i] = base_pt[i] + (xaxis[i] * xoffset2);
		sym_posn[CEN_PT+i] = base_pt[i];
		sym_posn[TEXT_A+i] = base_pt[i] - (xaxis[i] * xoffset4);
		sym_posn[TEXT_B+i] = 
		sym_posn[TEXT_C+i] = base_pt[i] + (xaxis[i] * xoffset5);
		sym_posn[TEXT_E+i] = 
		sym_posn[TEXT_F+i] = base_pt[i] + (xaxis[i] *xoffset3);
		sym_posn[DIR_SYM+i] = base_pt[i] + (xaxis[i] * xoffset4);
	}

	/*|- Compute text position wrto y-axis*/

	for (i=0; i<3; i++)
	{
		sym_posn[MID_PT+i] = sym_posn[MID_PT+i] + (yaxis[i] * yoffset1); 
		sym_posn[START_PT+i] = sym_posn[START_PT+i] + (yaxis[i] * yoffset1);
		sym_posn[END_PT+i] = sym_posn[END_PT+i] + (yaxis[i] * yoffset3);
		sym_posn[CEN_PT+i] = sym_posn[CEN_PT+i] + (yaxis[i] * yoffset0);
		sym_posn[TEXT_A+i] = sym_posn[TEXT_A+i] + (yaxis[i] * yoffset1);
		sym_posn[TEXT_B+i] = sym_posn[TEXT_B+i] + (yaxis[i] * yoffset1);
		sym_posn[TEXT_C+i] = sym_posn[TEXT_C+i] + (yaxis[i] * yoffset2); 
		sym_posn[TEXT_E+i] = sym_posn[TEXT_E+i] + (yaxis[i] * yoffset3); 
		sym_posn[TEXT_F+i] = sym_posn[TEXT_F+i] + (yaxis[i] * yoffset1);
		sym_posn[DIR_SYM+i] = sym_posn[DIR_SYM+i] + (yaxis[i] * yoffset1);
	}

	/*^
		for (i=0; i<9; i++)
		printf("sym_posn[%d] = %f,%f,%f\n",i,
		sym_posn[i*3], sym_posn[i*3+1], sym_posn[i*3+2]);
	*/

	return(OM_S_SUCCESS);
}

method position_surf_text(
	IGRint *msg;
	struct GRid text_grid[];
	IGRdouble txt_orie[3];
        struct DMsenv_param *par_senv;
        struct DMplan_info *plan_info;
        IGRdouble *sym_posn;
	struct GRmd_env *md_env)
{
	IGRint rc,status ;
	IGRshort txt_just[SURF_TERM];
	IGRdouble norm[3], *origin;
	IGRint index;

	if (me->sym_posn == SURF_ABOVE)
	{
		txt_just[SURF_TEXTA] = RIGHT_TOP;
		txt_just[SURF_TEXTB] = RIGHT_BOTTOM;
		txt_just[SURF_TEXTC] = RIGHT_BOTTOM;
		txt_just[SURF_TEXTD] = LEFT_BOTTOM;
		txt_just[SURF_TEXTE] = LEFT_TOP;
		txt_just[SURF_TEXTF] = LEFT_TOP;
		txt_just[SURF_DIR_SYM] = LEFT_TOP;
	}
	else
	{
		txt_just[SURF_TEXTA] = LEFT_BOTTOM;
		txt_just[SURF_TEXTB] = LEFT_TOP;
		txt_just[SURF_TEXTC] = LEFT_TOP;
		txt_just[SURF_TEXTD] = RIGHT_TOP;
		txt_just[SURF_TEXTE] = RIGHT_BOTTOM;
		txt_just[SURF_TEXTF] = RIGHT_BOTTOM;
		txt_just[SURF_DIR_SYM] = RIGHT_BOTTOM;
	}

/* dummy initialisation of origin in order to avoid compilation warning*/
	origin = &sym_posn[TEXT_A];
 	norm[0] = plan_info->win_plan.matrix[8];
 	norm[1] = plan_info->win_plan.matrix[9];
 	norm[2] = plan_info->win_plan.matrix[10];

	for ( index= 0; index < 7 ; index++)
	{
		/*^
			printf("text_grid[%d] ", index);
			print_grid("", &text_grid[index]);
		*/

		if (text_grid[index].objid != NULL_OBJID)
		{
			if (index == SURF_TEXTA )
 				origin = &sym_posn[TEXT_A];
			else if (index == SURF_TEXTB )
				origin = &sym_posn[TEXT_B];
			else if (index == SURF_TEXTC)
				origin = &sym_posn[TEXT_C];
			else if (index == SURF_TEXTD)
				origin = &sym_posn[TEXT_D];
			else if (index == SURF_TEXTE)
				origin = &sym_posn[TEXT_E];
			else if (index == SURF_TEXTF)
				origin = &sym_posn[TEXT_F];
			else if (index == SURF_DIR_SYM)
				origin = &sym_posn[DIR_SYM];

			/*^ print_point("origin", origin); */

			status =
			om$send(msg = message DMroot.position_text(
						&rc,
						FALSE,
						DIM_NO_INDEX,
						&text_grid[index],
						md_env,
						txt_just[index],
						origin,
						txt_orie,
						norm,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
        return(OM_S_SUCCESS);
}

method position_surf_symbol(
	IGRint *msg;
	IGRdouble *points;
	IGRdouble *txt_dir;
	struct GRid *go_grid;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status,rc, index, num_pts,i;
	IGRdouble radius, lin_offset, surf_dir[3];

	if (me->tol_symbol == SURF_TRIANGLE)
	{
		index = MID_PT;
		num_pts = 4;
	}
	else
	{
		index = START_PT;
		num_pts = 3;
	}

	if (me->dual_mode)
	{
		/*|- Symbol Line On */

		lin_offset = (me->rear_len + 0.5) * par_senv->txt_widt;

		if (me->sym_posn == SURF_BELOW)
		{
		   math_v_opposite(surf_dir, txt_dir);
		}
		else
		{
		   math_v_equal(surf_dir, txt_dir);
		}

		for (i=0; i<3; i++)
		{
			points[i+EXTN_PT] = points[i+TEXT_E] + (surf_dir[i] * lin_offset);
		}

		num_pts++;
	}

	/*|- Postion Symbol Line */

	/*^
		printf("start_index = %d\n", index);
		printf("symbol num_pts = %d\n", num_pts);
		for(i=0; i<num_pts; i++)
		printf("points[i] = %f,%f,%f\n",
			i, points[(i*3)+index],
			points[(i*3)+1+index], points[(i*3)+2+index]);
	*/

	status =
	om$send(msg = message DMroot.position_line_string(
					&rc,
					DIM_NO_INDEX,
					&go_grid[SURF_SYM_LINE],
					md_env,
					num_pts,
					&points[index]),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	if (me->tol_symbol == SURF_CIRCLE)
	{
		/*|- Position symbol circle*/

		radius = par_senv->txt_heig * 0.5;

		status =
		DMmake_circle(
			&rc,
			&radius,
			&points[CEN_PT],
			&plan_info->win_plan.matrix[8],
			&go_grid[SURF_SYM_CIRCLE],
			md_env);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- Delete the circle component*/

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_SYM_CIRCLE,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		go_grid[SURF_SYM_CIRCLE].objid = NULL_OBJID;
	}

	*msg = TRUE;	
	return(TRUE);
}

method get_components(
	IGRboolean create;
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, i, rc;

	for (i=0; i< SURF_LEADER; i++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						i,
						create,
						DM_TEXT,
						md_env,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	for (i=SURF_LEADER; i< SURF_SYM_CIRCLE; i++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						i,
						create,
						DM_LINE_STR,
						md_env,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					SURF_EXTN_LINE,
					create,
					DM_LINE,
					md_env,
					&go_grid[SURF_EXTN_LINE]),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					SURF_SYM_CIRCLE,
					create,
					DM_CIRCLE,
					md_env,
					&go_grid[SURF_SYM_CIRCLE]),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method chg_an_dp(IGRint *msg; struct DMsenv_param *par_senv)
{
	IGRint status, i;
	struct DMenv_param par_env;
	IGRlong long_rc;
	struct IGRdisplay line_display, text_display;
	struct GRid go_grid[11];
	struct GRmd_env md_env;
	IGRshort current_layer;
	IGRint  rc;
	IGRboolean invalid_layer;

	*msg = DIM_S_SUCCESS;
	invalid_layer = FALSE;

	DMget_module_info(&md_env);
	DMsplit_senv(par_senv, &par_env, NULL, NULL);

	status = 
	om$send(msg = message DMroot.chgdp(&rc, &par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	line_display.color =
	text_display.color = (me->dim_state & DIM_DETACHED)?
			par_env.det_colr:par_env.dim_colr;

	line_display.weight = par_env.dim_weig;
	text_display.weight = par_env.txt_weig;

	line_display.style =
	text_display.style = 0;

	status =
	om$send(msg = message GRvg.GRchgdp(&long_rc, &line_display),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	current_layer = par_env.dim_layr;
	if(DMvalid_dim_offset_active_layer(par_env.dim_layr))
	{
                DMget_current_dim_layer(par_env.dim_layr , &current_layer, 
					&invalid_layer);
		if (invalid_layer)
			ex$message(msgnumb=DM_E_LyrOutOfRngActLyr);
	}

	status =
	om$send(msg = message GRvg.GRchglevel(&long_rc, &current_layer),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	

	status =
	om$send(msg = message DMsurf.get_components(
					FALSE,
					go_grid,
					&md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS)

	for (i=SURF_TEXTA; i<SURF_TERM; i++)
	{
		if (go_grid[i].objid != NULL_OBJID)
		{
			status =
			om$send(msg = message GRvg.GRchgdp(&long_rc, &text_display),
				targetid = go_grid[i].objid,
				targetos = go_grid[i].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method fill_leader_info(
	IGRint *msg;
	IGRpoint start_pt;
	IGRpoint end_pt;
	struct GRid lead_grid;
	struct GRid text_grid;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint index,num_vertex;
	IGRlong long_rc, bsrc;
	struct IGRbsp_curve *bsp_curve;
	IGRvector diff_vec;
	IGRdouble *vertex, text_orig[3], scale;

	if (me->leader)
	{
		if (lead_grid.objid == NULL_OBJID)
		   return(OM_E_ABORT);

		/*|- leader line present */

		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
			targetid = lead_grid.objid,
			targetos = lead_grid.osnum);
		dm$status(action = RET_STATUS);

		num_vertex = bsp_curve->num_poles ;
	
		status =
		om$vla_set_dimension(varray = me->break_pt,
			size = num_vertex * 3);
		dm$status(action = RET_STATUS);

		memcpy( me->break_pt,
			bsp_curve->poles,
			3*sizeof(IGRdouble) * num_vertex);

		vec_sub(start_pt, me->break_pt, diff_vec);

		/*^ print_point("def vec",diff_vec);*/

		for (index=0; index<num_vertex; index++)
		{
			vertex = &me->break_pt[index*3];
			vec_add(vertex, diff_vec, vertex);
		}
	}
	else
	{
		num_vertex = om$dimension_of(varray = me->break_pt) / 3;

		/*"num_vertex = %d\n", num_vertex*/

		if (num_vertex)
		{
			/*|- Text offset present*/

			/*^ print_point("txt offset", me->break_pt); */

			scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

			for (index=0; index<3; index++)
			text_orig[index] = start_pt[index] +
				(scale * me->break_pt[index]);

			vec_equal(text_orig, me->break_pt);
		}
		else
		{
			num_vertex = 1;

			status =
			om$vla_set_dimension(varray = me->break_pt,
			     	size = 3);
			dm$status(action = RET_STATUS);

			vec_equal(start_pt, me->break_pt);
		}
	}

	return(OM_S_SUCCESS);
}

method set_surf_text_attr(
 	IGRint *msg;
	struct GRid *text_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc,index;
	struct GRdpb_text_symb text_symb;
	struct DMsenv_param par_senv;

	status =
	om$send(msg = message DMannot.get_active_senv(&par_senv),
			targetid = my_id);
	dm$status(action = RET_STATUS);


	text_symb.Active_font    = par_senv.text_font;
	text_symb.Active_just    = -1;
	text_symb.Active_fraction_font = par_senv.frac_font;
	text_symb.Active_width   = par_senv.txt_widt;
	text_symb.Active_height  = par_senv.txt_heig;
	text_symb.Active_charspac= par_senv.car_spac;
	text_symb.Active_linespac= par_senv.lin_spac;

	for (index=SURF_TEXTA;index < SURF_TERM; index++)
	{
		if (text_grid[index].objid == NULL_OBJID)
			continue;

		status =
		om$send(msg = message DMroot.chgtextattr(
						&rc,
						DIM_NO_INDEX,
						&text_grid[index],
						md_env,
						&text_symb),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method make_lead_line(
	IGRint *msg;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRid lead_grid;
	struct GRmd_env *md_env)
{
	IGRint status,rc,count;
	IGRint num_vertex,index;
	struct GRid list[10];
	IGRdouble ext_length,*vertex, src_dir[3],line[6],*ex_point;
	IGRboolean on_element;
	IGRboolean src_type;
	IGRdouble target_pt[3],u_par;
	IGRlong long_rc, bs_rc;
	IGRdouble dist1,dist2, *req_pt,ext_line[6], surf_dir[3];

	if(me->leader)
	{
		/*|Extend the last point */

		num_vertex = om$dimension_of(varray=me->break_pt)/3;
		if(num_vertex < 2) return(OM_S_SUCCESS);

		vertex = &me->break_pt[ 3*(num_vertex -2)];
		ex_point = &me->break_pt[ 3*(num_vertex -1)];
		ext_length = (me->front_len + me->rear_len + 5.25)*
				par_senv->txt_widt;

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

		/* Position Line string*/

		status =
		om$send(msg = message DMroot.position_line_string(
						msg,
						DIM_NO_INDEX,
						&lead_grid,
						md_env,
						num_vertex,
						me->break_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);		     

		/*|- Extn line not needed - delete*/

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_EXTN_LINE,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- No Leader option - delete leader go*/

		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_LEADER,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status=
		om$send(msg = message DMsrc.DMgive_tangent(
						&rc,
						&src_type,
						src_dir,
						(IGRdouble (*)[])line,
						md_env),
			targetid = list[AN_ROOT_ELEM1].objid,
			targetos = list[AN_ROOT_ELEM1].osnum);
		dm$status(action = RET_STATUS);

		if (src_type == LINE_TYPE)
		{
			if (!(BSdotp(&bs_rc, plan_info->win_plan.vec_xpos, src_dir) > 0.0))
			{
				math_v_opposite(src_dir, src_dir);
			}

			BSproj0(&bs_rc, me->break_pt, line, target_pt);

			/*^ print_point("target pt", target_pt); */

			on_element = FALSE;

			BSpt_on_lne(&long_rc,
				    line,
				    &line[3],
				    target_pt,
				    &u_par,
				    &on_element);
		}
		else	on_element = TRUE;

		if (!on_element)
		{
			/*|- Position Extension line */

			dist1 = BSdistptpts(&bs_rc,line,target_pt);
			dist2 = BSdistptpts(&bs_rc,&line[3],target_pt);
			req_pt = (dist1 > dist2) ? &line[3]:line;

			for( index = 0; index<3; index++)
			{
				ext_line[index] = req_pt[index];
				ext_line[index + 3] = target_pt[index];
			}

			BSmkvec(&bs_rc, surf_dir, req_pt, target_pt);
			BSnorvec(&bs_rc, surf_dir);

			ext_length = 0.5 * par_senv->txt_heig;
			MATH_ptdelta(&rc,ext_line,surf_dir, ext_length, ext_line);

			if (BSdotp(&bs_rc, src_dir, surf_dir) > 0.0)
			{
				/*|- Same as text dir*/

				if (me->sym_posn == SURF_ABOVE)
					ext_length = (me->rear_len + 3.75) * par_senv->txt_widt;
				else	ext_length = (me->front_len + 1.5) * par_senv->txt_widt;
			}
			else
			{
				/*|- opposite to text dir */

				if (me->sym_posn == SURF_ABOVE)
					ext_length = (me->front_len + 1.5) * par_senv->txt_widt;
				else	ext_length = (me->rear_len + 3.75) * par_senv->txt_widt;
			}

			MATH_ptdelta(&rc,
			     &ext_line[3],
			     surf_dir,
			     ext_length,
			     &ext_line[3]);

			/*^ print_line("extn_line", ext_line); */

			status =
			om$send(msg = message DMroot.position_line(
							msg,
							SURF_EXTN_LINE,
							NULL,
							md_env,
							ext_line),
				targetid = my_id);
			dm$status(action = RET_STATUS);		     
		}
		else
		{
			/*|- No Extn line - delete extn line go*/

			status =
			om$send(msg = message DMroot.delete_dim_go(
						&rc,
						SURF_EXTN_LINE,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method make_surf_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, rc,i;
	IGRlong long_rc;
	extern struct DMsurf_param frm_surf;
	IGRint txt_len;
	IGRuchar text_string[128];
	short font_num;
	unsigned char *text_ptr;

	if ((me->dim_state & DIM_IN_PLACEMENT)
	||  (me->dim_state & DIM_IN_EDIT))
	{
		/*|- Update all the instance and txt value from global struct */

		me->tol_symbol = frm_surf.basic_sym;
		me->dual_mode = frm_surf.line_on;
		me->dir_sym = frm_surf.dir_sym;
		me->sym_posn = frm_surf.sym_posn;
	
		me->front_len = me->rear_len = txt_len = 0;

		/*^
			printf("basic_sym = %d\n", frm_surf.basic_sym);
			printf("line_on = %d\n", frm_surf.line_on);
			printf("dir_sym = %d\n", frm_surf.dir_sym);
			printf("sym_posn = %d\n", frm_surf.sym_posn);
			printf("text_a = %s\n", frm_surf.text_a);
			printf("text_b = %s\n", frm_surf.text_b);
			printf("text_c = %s\n", frm_surf.text_c);
			printf("text_d = %s\n", frm_surf.text_d);
			printf("text_e = %s\n", frm_surf.text_e);
			printf("text_f = %s\n", frm_surf.text_f);
		*/

		status = 
		om$send(msg = message DMsurf.get_components(
						TRUE,
						go_grid,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		for (i=SURF_TEXTA; i< SURF_DIR_SYM ; i++)
		{
			switch(i)
			{
				case SURF_TEXTA:
					strcpy((char *)text_string,frm_surf.text_a);
					me->front_len =
					txt_len = strlen((char *)text_string);
					break;
				case SURF_TEXTB:
					strcpy((char *)text_string,frm_surf.text_b);
					txt_len = strlen((char *)text_string);
					break;
				case SURF_TEXTC:
					strcpy((char *)text_string,frm_surf.text_c);
					txt_len = strlen((char *)text_string);
					break;
				case SURF_TEXTD:
					strcpy((char *)text_string,frm_surf.text_d);
					txt_len = strlen((char *)text_string);
					if (txt_len > me->rear_len)
					   me->rear_len = txt_len;
					break;
				case SURF_TEXTE:
					strcpy((char *)text_string,frm_surf.text_e);
					txt_len = strlen((char *)text_string);
					if (txt_len > me->rear_len)
					   me->rear_len = txt_len;
					break;
				case SURF_TEXTF:
					strcpy((char *)text_string,frm_surf.text_f);
					txt_len = strlen((char *)text_string);
					if (txt_len > me->rear_len)
					   me->rear_len = txt_len;
					break;
				default:
				printf("wrong option\n");
				return(FALSE);
			}

			if(txt_len > 0)
			{
				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_len,
								text_string),
					targetid = go_grid[i].objid,
					targetos = go_grid[i].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status = 
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								i,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);
				
				go_grid[i].objid = NULL_OBJID;
			}
		}
		
		/*"me->front_len = %d\n", me->front_len*/
		/*"me->rear_len = %d\n", me->rear_len*/

		if (me->dir_sym != SURF_DIR_NONE)
		{
			/*"dir_sym = %d\n", frm_surf.dir_sym*/

			txt_len = 1;
			text_string[1] = '\0';

			switch (frm_surf.dir_sym)
			{
				case SURF_DIR_R:
				text_string[0] = 'R';
				break;

				case SURF_DIR_X:
				text_string[0] = 'X';
				break;

				case SURF_DIR_C:
				text_string[0] = 'C';
				break;

				case SURF_DIR_M:
				text_string[0] = 'M';
				break;
			
				case SURF_DIR_P:
				text_string[0] = 'P';
				break;

				case SURF_DIR_E:
				text_string[0] = '=';
				break;

				case SURF_DIR_T:
				text_string[0] = '\0';
				txt_len = 0;
				break;

				default:
				printf("Illegal Dir Symbol\n");
				return(OM_E_ABORT);
				
			}

			if (frm_surf.dir_sym == SURF_DIR_T)
			{
				/*|- Perpendicular Symbol - change font */

				DMretrieve_font(&rc, OM_Gw_current_OS, "100", &font_num);
				if (rc != DIM_S_SUCCESS)
				{
			                ex$message(msgnumb = DM_I_ErrRetFont,
                        			   type = "%s",
			                           var = "100");

					printf("Error retrieving font\n");
					return(FALSE);
				}

				text_ptr = text_string;
				change_font(text_ptr, font_num, txt_len);
				*text_ptr++ = 'l';
				txt_len++;
				change_font(text_ptr, font_num, txt_len);			
			}

			status = 
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							txt_len,
							text_string),
				targetid = go_grid[SURF_DIR_SYM].objid,
				targetos = go_grid[SURF_DIR_SYM].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status = 
			om$send( msg = message DMroot.delete_dim_go(
							&rc,
							SURF_DIR_SYM,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			go_grid[SURF_DIR_SYM].objid = NULL_OBJID;
		}
	}	
	return(OM_S_SUCCESS);
}

method modify_geom(
	IGRint *msg;
	IGRint control;
	IGRint vertex_no;
	IGRpoint cursor;
	struct GRid *win_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint hilite, i ,count, flag;
	IGRlong long_rc, bs_rc;
	IGRint num_vertex, last_vtx, curr_vtx;
	IGRboolean src_modify, pos_term, src_type;
	struct GRid list[NO_LEADER_ROOTS],go_grid[MAX_SURF_COMP];
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRdouble *start_pt,*prev_point;
	IGRpoint diff, point, point1;
	struct IGRline bore_line;
	IGRdouble src_dir[3] , *vertex, *extn_pt;
	IGRdouble target_pt[3], extn_length, surf_dir[3];
	IGRdouble sym_posn[MAX_SURF_COMP*3];
	struct GRmd_env mod_info;
	struct ret_struct ret_str;

	/*"vertex_no = %d\n", vertex_no*/

	if ((me->geom_type & DIM_IMPORTED)
	&&  ((control & MOVE_TERMINATOR) || (vertex_no == 0)))
	{
		/*|- Cannot modify source location for retrived dim*/
		return(OM_S_SUCCESS);
	}

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

	if(!DMancestry_valid(list[AN_ROOT_ELEM1],OPP_dim_src_class_id))
		return(OM_S_SUCCESS);

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
	om$send(msg = message DMsurf.get_components(
					FALSE,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS)

	src_modify = pos_term = FALSE;

	if (!me->leader)
	{
		/*| No leader so Modify DMsrc element*/
		src_modify = TRUE;
	}
	else if ((control & MOVE_TERMINATOR) || (vertex_no == 0))
	{
		/*| - Modify attach element */
		src_modify = TRUE;
	}
	else if ((control & MOVE_POLE) || (control & MOVE_TEXT))
	{
		/*| - Modify one of poles */

		status =
		om$send(msg = message DMannot.fill_leader_info(
						&rc,
						point,
						point1,
						go_grid[SURF_LEADER],
						go_grid[SURF_TEXTA],
						&plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		num_vertex = om$dimension_of(varray = me->break_pt)/3;
		last_vtx = 3*(num_vertex -1);
		curr_vtx = 3*(num_vertex -2);

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
			if ((vertex_no*3) == last_vtx)
			   vertex_no = curr_vtx/3;

			/*| - Get previous vector direction */
			for(i=0; i<3; i++)
				src_dir[i] = 
				    me->break_pt[3*(vertex_no - 1) + i] -
				    me->break_pt[3*(vertex_no - 2) + i];
		}

		if((vertex_no*3) == curr_vtx)
			start_pt = &me->break_pt[curr_vtx];
		else	start_pt= &me->break_pt[vertex_no*3];

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
			
		/*^
			print_point("diff:",diff);
			printf("num_vertex = %d\n", num_vertex);
			printf("curr_vtx = %d\n", curr_vtx);
			printf("last_vtx = %d\n", last_vtx);
			printf("vertex_no = %d\n", vertex_no);
		*/

		for (i=vertex_no; i<num_vertex; i++)
		{
			vertex = &me->break_pt[i*3];
			vec_add(vertex, diff, vertex);
		}

		if ((vertex_no*3) == curr_vtx)
		{		
			DMget_direction(
				prev_point,
				target_pt,
				plan_info.act_plan.matrix,
				&flag);

			if(flag == AN_BEFORE)
				me->bln_dir = SURF_LEFT;
			else	me->bln_dir = SURF_RIGHT;

			vertex = &me->break_pt[curr_vtx];
			extn_pt = &me->break_pt[last_vtx];
			extn_length = (me->front_len + me->rear_len + 5.25)*
				par_senv.txt_widt;

			if (me->bln_dir == SURF_RIGHT)
			{
				/*|- Surf dir is SURF_RIGHT*/

				math_v_equal(surf_dir, plan_info.win_plan.vec_xpos);
			}
			else
			{
				/*|- Surf dir is SURF_LEFT*/

				math_v_equal(surf_dir, plan_info.win_plan.vec_xneg);
			}

			MATH_ptdelta(&rc,
				     vertex,
				     surf_dir,
				     extn_length,
				     extn_pt);
		}

		/*|- Compute symbol positions */

	        status =
	        om$send(msg = message DMsurf.compute_symbol_positions(
                                       &rc,
				       &me->break_pt[curr_vtx],
                                       plan_info.win_plan.vec_xpos,
                                       &par_senv,
                                       &plan_info,
                                       sym_posn),
               		targetid = my_id);
	        dm$status(action = RET_STATUS);

		/*|- Position Surf Text */

	        status =
	        om$send(msg = message DMsurf.position_surf_text(
				       &rc,
                                       go_grid,
                                       plan_info.win_plan.vec_xpos,
                                       &par_senv,
                                       &plan_info,
                                       sym_posn,
                                       md_env),
               		targetid = my_id);
	        dm$status(action = RET_STATUS);

		/*|- Position Surf Symbol */

	        status =
	        om$send(msg = message DMsurf.position_surf_symbol(
                                       &rc,
                                       sym_posn,
                                       plan_info.win_plan.vec_xpos,
                                       go_grid,
	                               &par_senv,
                                       &plan_info,
                                       md_env),
               		targetid = my_id);
	        dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMsurf.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					go_grid[SURF_LEADER],
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		if(pos_term)
		{
			status =
			om$send(msg = message DMannot.make_an_term(
						&rc,
						&plan_info,
						&par_senv,
						go_grid[SURF_TERM],
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
	else
	{
		/*"control:%d\n",control*/
		return(OM_E_ABORT);
	}


	if(src_modify && me->leader)
	{
		bore_line.point1 = cursor;
		bore_line.point2 = point;
		
		point[0] = bore_line.point1[0] + plan_info.act_plan.matrix[8];
		point[1] = bore_line.point1[1] + plan_info.act_plan.matrix[9];
		point[2] = bore_line.point1[2] + plan_info.act_plan.matrix[10];

		status =
		om$send(msg = message DMsrc.DMmodify(
						&rc,
						&mod_info,
						FALSE,
						TRUE,
						&bore_line),
			targetid = list[AN_ROOT_ELEM1].objid,
			targetos = list[AN_ROOT_ELEM1].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							ND_COMP,
							md_env),
				targetid = my_id);
		dm$status(action = RET_STATUS);
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
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

		me->break_pt[1] = (cursor[1] - point[1])/
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

		me->break_pt[2] = (cursor[2] - point[2])/
		BSlenvec(&bs_rc, plan_info.act_plan.vec_xpos);

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

method get_surf_text(
	IGRint *msg;
	struct DMsurf_param *par_surf;
	struct GRmd_env *md_env)
{
	IGRint status, i;
	IGRshort length, len[4], num_str;
	IGRlong long_rc;
	IGRuchar *string = NULL, *str[4];
	IGRuchar str1[128], str2[128], str3[128], str4[128];
	struct GRid go_grid[MAX_SURF_COMP];

	length = len[0] = len[1] = len[2] = len[3] = 0;
	str[0] = str1;
	str[1] = str2;
	str[2] = str3;
	str[3] = str4;

	/*|- Update the instances & Text values */

	par_surf->basic_sym = me->tol_symbol;
	par_surf->line_on = me->dual_mode;
	par_surf->dir_sym = me->dir_sym;
	par_surf->sym_posn = me->sym_posn;

	/*|- Extract the text values from text components */

	par_surf->text_a[0] = '\0';
	par_surf->text_b[0] = '\0';
	par_surf->text_c[0] = '\0';
	par_surf->text_d[0] = '\0';
	par_surf->text_e[0] = '\0';
	par_surf->text_f[0] = '\0';

	status =
	om$send(msg = message DMsurf.get_components(
						FALSE,
						go_grid,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);
		
	for (i=SURF_TEXTA; i < SURF_DIR_SYM; i++)
	{
		if (go_grid[i].objid == NULL_OBJID)
		   continue;

		/*|- Text object present */

		string = NULL;

		status =
		om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					NULL,
					&length,
					&string),
			targetid = go_grid[i].objid,
			targetos = go_grid[i].osnum);
		dm$status(action = RET_STATUS);

		status =
		DMret_disp_char(
			string,
			length,
			&num_str,
			str,
			len);

		if (string) free(string);

		if (num_str > 1)
		{
			/*"Num of strings more than one, num_str = %d\n", num_str*/
			return(OM_E_ABORT);
		}

		/*^
			printf("text_sting = <%s>\n", str1);
			printf("length = %d\n", len[0]);
		*/

		switch(i)
		{
			case SURF_TEXTA:
			strcpy((char *)par_surf->text_a, (char *)str1);
			break;
			case SURF_TEXTB:
			strcpy((char *)par_surf->text_b, (char *)str1);
			break;
			case SURF_TEXTC:
			strcpy((char *)par_surf->text_c, (char *)str1);
			break;
			case SURF_TEXTD:
			strcpy((char *)par_surf->text_d, (char *)str1);
			break;
			case SURF_TEXTE:
			strcpy((char *)par_surf->text_e, (char *)str1);
			break;
			case SURF_TEXTF:
			strcpy((char *)par_surf->text_f, (char *)str1);
			break;
			default:
			printf("wrong option\n");
			return(FALSE);
		}

		str1[0] = '\0';
		len[0] = 0;
	}

	/*^
		printf("basic_sym = %d\n", par_surf->basic_sym);
		printf("line_on = %d\n", par_surf->line_on);
		printf("dir_sym = %d\n", par_surf->dir_sym);
		printf("sym_posn = %d\n", par_surf->sym_posn);
		printf("text_a = %s\n", par_surf->text_a);
		printf("text_b = %s\n", par_surf->text_b);
		printf("text_c = %s\n", par_surf->text_c);
		printf("text_d = %s\n", par_surf->text_d);
		printf("text_e = %s\n", par_surf->text_e);
		printf("text_f = %s\n", par_surf->text_f);
	*/

	return(OM_S_SUCCESS);
}

method get_dim_attr(char *attr)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRint num_brkpt;
	struct annot_attr *dim_attr;
	struct GRid lead_grid;
	struct GRmd_env md_env;
	struct IGRbsp_curve *bsp_curve;

	dim_attr = (struct annot_attr *)attr;

	dim_attr->dim_type = me->dim_type;
	dim_attr->geom_type = me->geom_type;
	dim_attr->display = me->display;
	dim_attr->dim_state= me->dim_state;
	dim_attr->leader= me->leader;
	dim_attr->dual_mode= me->dual_mode;
	dim_attr->bln_dir= me->bln_dir;
	dim_attr->tol_symbol = me->tol_symbol;
	dim_attr->num_brkpt = 0;
	dim_attr->text_length = 0;

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					SURF_LEADER,
					FALSE,
					DM_LINE_STR,
					&md_env,
					&lead_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (lead_grid.objid != NULL_OBJID)
	{
		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env.md_env.matrix_type,
					md_env.md_env.matrix,
					(char **)&bsp_curve),
			targetid = lead_grid.objid,
			targetos = lead_grid.osnum);
		dm$status(action = RET_STATUS);

		num_brkpt = bsp_curve->num_poles - 2;

		if (num_brkpt > 0)
		{
			dim_attr->num_brkpt = num_brkpt;
			dim_attr->brkpt = (IGRdouble *)
			om$malloc(size = sizeof(IGRdouble) * 3 * num_brkpt);
			if (dim_attr->brkpt == NULL)
			{
				dm$status(sts = OM_E_NODYNMEM,
					action = RET_STATUS);
			}

			memcpy(dim_attr->brkpt,
				&bsp_curve->poles[3],
				sizeof(IGRdouble) * 3 * num_brkpt);

			memcpy(dim_attr->start_pt,
				bsp_curve->poles,
				sizeof(IGRdouble) * 3);
		}
	}
	else
	{
		num_brkpt = om$dimension_of(varray = me->break_pt) / 3;

		if (num_brkpt > 0)
		{
			dim_attr->num_brkpt = num_brkpt;
			dim_attr->brkpt = (IGRdouble *)
			om$malloc(size = sizeof(IGRdouble) * 3 * num_brkpt);
			if (dim_attr->brkpt == NULL)
			{
				dm$status(sts = OM_E_NODYNMEM,
					action = RET_STATUS);
			}

			memcpy(dim_attr->brkpt,
				me->break_pt,
				sizeof(IGRdouble) * 3 * num_brkpt);
		}		
	}

	return(OM_S_SUCCESS);
}

end implementation DMsurf;

