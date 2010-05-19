/*
$Author: cvs $
$Revision: 1.1.1.1 $
$Date: 2001/01/04 21:07:40 $
$Locker:  $
$Log: annot.I,v $
Revision 1.1.1.1  2001/01/04 21:07:40  cvs
Initial import to CVS

# Revision 1.2  1998/11/08  05:35:04  pinnacle
# Replaced: vdannot/dim/annot.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/30  16:39:10  pinnacle
# Replaced: vdannot/dim/annot.I for:  by azuurhou for vds.240
#
# Revision 1.3  1996/05/30  15:49:26  pinnacle
# Replaced: vdannot/dim/annot.I for:  by azuurhou for vds.240
#
# Revision 1.2  1996/05/02  12:10:06  pinnacle
# Replaced: ./vdannot/dim/annot.I for:  by azuurhou for vds.240
#
# Revision 1.1  1996/01/10  14:54:20  pinnacle
# Created: vdannot/dim/annot.I by jwfrosch for vds.240
#
# Revision 320.3  1995/06/30  06:14:14  satya
# COMMENT : Modify Annotation/Geometry: Infinite extension of last leader segment in "Text with Leader" problem resolved
#
# Revision 320.2  1995/05/17  07:10:24  satya
# COMMENT : Copy Dimension: Fixed a crash problem
#
# Revision 240.4  1994/11/01  10:11:47  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.3  1993/12/17  13:46:42  samuel
# COMMENT : Fix for TR119313981-Computing immediately.
#
# Revision 240.2  1993/11/05  05:51:54  samuel
# COMMENT : Fix for TR 119311178 - Alt mode chars for balloon
#
# Revision 240.1  1993/05/19  07:08:01  laxmi
# COMMENT : Checking in Dimensioning TR fixes -Laxmi 19 may 1993.
#
# Revision 220.2  1992/10/16  19:36:22  poo
# COMMENT : Created a new macro to place balloon annotation.
#
# Revision 220.1  1992/09/09  14:15:08  scott
# COMMENT : ANSI/SGI fixes
#
# Revision 220.0  1992/08/29  06:21:13  root
# COMMENT : Corresponds to Rel201.24 in 2.0.1 RCS
#
Revision 201.24  1992/08/28  09:00:40  poo
COMMENT : Fix for Autodims(Multiple text with leader).

Revision 201.23  1992/07/31  18:46:00  poo
COMMENT :

Revision 201.19  1992/02/24  19:47:58  dimdp20
COMMENT : VLA for  no leader cases  saves offset distance

Revision 201.17  1992/02/03  13:00:43  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/07/98        Ming            TR179802270
*/

class implementation DMannot;

#include "dimgraph.h"
#include "dimweld.h"
#include "dimsurf.h"
#include "diminst.h"
#include "fontmacros.h"
#include "bsproj1.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

#define AS_DEBUG 1

extern IGRboolean BSproj0(), BSnorvec();
extern double fabs();
extern GRclassid OPP_dim_src_class_id;
extern GRclassid OPP_dim_plan_class_id;
extern GRclassid OPP_DMtxldr_class_id;

from GRlinear	import GRgetpolyline, GRputpolyline;
from GRtext	import GRreplace_text, GRchgtextattr;
from dim_param	import give_internal, edit;
from DMsrc	import DMgive_tangent;
from DMtxbln	import position_balloon, give_bln_center;
from DMframe 	import set_datum_term,update_text_box,get_tol_just;
from DMframe 	import make_profile_sym;
from GRtext import GRgettxattr;


method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, bytes_char;
	IGRlong bsrc, long_rc;
	struct annot_attr *an_attr;
	struct GRid text_grid, lead_grid, term_grid;
	IGRint num_vertex, num_parents;
	struct GRid *go_grid[3], null_grid;
	struct GRid parents[MAX_DIM_ROOTS];
	struct DMsenv_param par_senv;
	struct DMmisc_param par_misc;
	struct DMplan_info plan_info;
	IGRpoint start_pt, end_pt, pt;
	IGRdouble *vertex;
	struct GRmd_env mod_info;
	struct vfont_entry font_info;
	extern GRclassid OPP_dim_plan_class_id,OPP_dim_src_class_id;
	extern IGRshort GRfwd_esc_seq();
	IGRshort start_index,num_chars;
	IGRboolean multimode;
	IGRlong long_rc1;
	IGRshort t_length;

	struct GRid s_line;
	struct GRid s_text2;
	
	an_attr = (struct annot_attr *)attr;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	/* - VALIDATE ROOTS - */

	status =
	om$send(msg = message DMroot.validate_roots(&rc, count, list),
		targetid = my_id);
 	dm$status(action = RET_STATUS);

	/*|	- Connect Parents - */

	null_grid.objid = NULL_OBJID;
	null_grid.osnum = OM_Gw_current_OS;

	me->comp_mask	= 0;
	me->state	= ND_DEFAULT;

	num_parents = count;

	DMcopy_roots(parents, list, num_parents);

	if ((DMancestry_valid(list[0], OPP_dim_src_class_id))
	&& (DMancestry_valid(list[2], OPP_dim_plan_class_id))
	&& (list[2].objid == list[0].objid))
	{
		/*| - Duplicate parent id */

		for(i=2; i<count-1; i++)
		{
			list[i].objid = list[i+1].objid;
			list[i].osnum = list[i+1].osnum;
		}			
		count--;
	}

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

	/*"dim_type:%d\n",an_attr->dim_type*/

	if (an_attr->dim_type == FEATURE_CONTROL_FRAME)
	{
		me->tol_symbol = an_attr->tol_symbol;
		me->dual_mode  = an_attr->dual_mode;
		me->bln_dir    = an_attr->bln_dir;
	}
	else if (an_attr->dim_type == DATUM_FRAME)
		me->bln_dir = an_attr->bln_dir ;
	
	dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);	

	num_vertex = (an_attr->dim_type == LEADER_LINE  ||
				 (an_attr->dim_type == TEXT_WITH_BALLOON &&
				  par_senv.attach_pt == INSIDE_OBJECT)) ?
			an_attr->num_brkpt + 2:
			an_attr->num_brkpt + 1;

	//check if there is a leader 

	if (!an_attr->leader) 
 	{	
		num_vertex = 1;	
	}

	go_grid[0] = (an_attr->dim_type != LEADER_LINE)?&text_grid:NULL;
	go_grid[1] = (an_attr->leader)?&lead_grid:NULL;
	go_grid[2] = (num_vertex > 1)?&term_grid:NULL;

	status =
	om$send(msg = message DMannot.get_graphics(
					TRUE,
					go_grid[0],
					go_grid[1],
					go_grid[2],
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	s_text2.objid = NULL_OBJID ;
	if( me->dim_type == TEXT_WITH_BALLOON ){

		status =
		om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_TEXT2,
                            TRUE,
                            DM_TEXT,
                            &mod_info,
                            &s_text2),
		targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMannot.gather_data(
					&rc,
					num_parents,
					parents,
					start_pt,
					end_pt,
					&plan_info,
					&par_senv,
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (an_attr->text_length && an_attr->dim_type != LEADER_LINE)
	{
		if ((an_attr->dim_type == TEXT_WITH_LEADER)
		&&  (num_parents > NO_TEXT_LEADER_ROOTS))
		{
			/*| - Text leader with expression */

			status =
			om$vla_set_dimension(varray = me->txexp,
				size = an_attr->text_length);
			dm$status(action = RET_STATUS);

			memcpy(	me->txexp,
				an_attr->text_string,
				sizeof(IGRchar) * an_attr->text_length);
		}
		else
		{
			if (an_attr->dim_type == TEXT_WITH_BALLOON)
			{
				if (an_attr->text_string[0] & 0x80)
				{
					/*| Kanji input */

					status =
					dm$get_dim_param(
						type = DM_MISC_PARAM,
						p_data = (char *) &par_misc);
					dm$status(action = RET_STATUS);
		
					status =
					font$get_info(
						msg = &rc,
						font_num = &par_misc.sixteen_bit_font,
						font_info = &font_info);
					dm$status(action = RET_STATUS);

					if (!(font_info.flags & SIXTEEN_BIT))
					{
						/*|- Font must be 16 bit 
						return(OM_S_SUCCESS); */
			/* Fix for TR 119311178 */
						/*| Alt mode input */
						bytes_char = 1;
					}
					else
					{
						bytes_char = 2;
						an_attr->text_length /= 2;
					}
				}
				else
				{
					/*| normal input */
					bytes_char = 1;
				}

        /*  The text length beyond the escape sequence is determined.
	 *  This length is compared with allowable number of characters 
	 *  that can be displayed based on the balloon width.
	 *  If the length is greater than displayable length then,
         *  the extra characters of the text string are truncated
	 *  and the text length adjusted accordingly.	
	 */
			
				start_index = 0;
				multimode = TRUE;
				t_length = an_attr->text_length;	
					
				GRfwd_esc_seq(&long_rc1,
					      an_attr->text_string,
					      &t_length,
					      &multimode,
					      &start_index,
  				 	      &num_chars );			

			  	t_length = an_attr->text_length - num_chars;
	
				if ( t_length > ((int)(par_senv.bln_size + 0.0001)))
				{
				/*	|- Text too long - truncated */

					t_length = (int)(par_senv.bln_size + 0.0001);
					an_attr->text_length = num_chars + t_length;	
					an_attr->text_string[ an_attr->text_length * bytes_char] = '\0';
				}


			}
			else
			{
				status =
				DMconv_txldr_text(&an_attr->text_length, (IGRchar **) &an_attr->text_string);
				dm$status(action = RET_STATUS);
			}

			status =
			om$send(msg = message GRtext.GRreplace_text(
						&long_rc,
						&mod_info,
						an_attr->text_length,
						(IGRuchar *)an_attr->text_string),
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	if (num_vertex < 2)
		return(OM_S_SUCCESS);

	status =
	om$vla_set_dimension(varray = me->break_pt,
		size = 3 * num_vertex);
	dm$status(action = RET_STATUS);

	vec_equal(start_pt, me->break_pt);

	memcpy(	&me->break_pt[3],
		an_attr->brkpt,
		sizeof(IGRdouble) *(3*an_attr->num_brkpt));

	if (an_attr->dim_type == LEADER_LINE )
	{
		vertex = &me->break_pt[3*(num_vertex - 1)];
		vec_equal(end_pt, vertex);
	}

	for (i=1; i<num_vertex; i++)
	{
		BSproj1(&bsrc,
			&me->break_pt[3*i],
			&plan_info.win_plan.matrix[8],
			start_pt,
			pt);
		memcpy(&me->break_pt[3*i], pt, sizeof(IGRpoint));
	}

	if (an_attr->dim_type != LEADER_LINE)
	{
		status =
		om$send(msg = message DMannot.make_an_text(
						&rc,
						&plan_info,
						&par_senv,
						text_grid,
						&mod_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (s_text2.objid != NULL_OBJID)
		{
			status =
        		om$send(msg = message DMannot.make_an_text(
                        		&rc,
                        		&plan_info,
                        		&par_senv,
                        		s_text2,
                        		&mod_info),
            			targetid = my_id);
        		dm$status(action = RET_STATUS);
		}
	}

	status =
	om$send(msg = message DMannot.make_lead_line(
				&rc,
				&par_senv,
				&plan_info,
				lead_grid,
				&mod_info),
		targetid = my_id);
	dm$status(action = RET_STAUS);
	
	status =
	om$vla_set_dimension(varray = me->break_pt, size = 0);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method DMcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRpoint start_pt, end_pt, txt_offset;
	struct GRid text_grid, lead_grid, term_grid;
	struct GRid parents[MAX_DIM_ROOTS], tmp_grid, tmp_grid1;
	struct GRmd_env mod_info;
	BSrc	bsrc;

	struct GRid text2_grid;


	/*| - Duplicate the roots if necessary */

	for(i=0; i<count; i++)
	{
		parents[i].objid = list[i].objid;
		parents[i].osnum = list[i].osnum;
	}

	if (me->geom_type & DIM_IMPORTED)
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(
					&tmp_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = parents[0].objid,
			targetos = parents[0].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&tmp_grid1,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = parents[AN_ROOT_ELEM1].objid,
			targetos = parents[AN_ROOT_ELEM1].osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		tmp_grid  = parents[0];
		tmp_grid1 = parents[AN_ROOT_ELEM1];
	}

	if ((DMancestry_valid(tmp_grid, OPP_dim_src_class_id))
	&&  (!(DMancestry_valid(tmp_grid1, OPP_dim_src_class_id))))
	{
		for (i=count; i > 2; i--)
		{
			parents[i].objid = parents[i-1].objid;
			parents[i].osnum = parents[i-1].osnum;
		}

		parents[2].objid = parents[0].objid;
		parents[2].osnum = parents[0].osnum;

		count++;
	}


	status =
	om$send( msg = message DMannot.gather_data(
					&rc,
					count,
					parents,
					start_pt,
					end_pt,
					&plan_info,
					&par_senv,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMannot.get_graphics(
					FALSE,
					&text_grid,
					&lead_grid,
					&term_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if( me->dim_type == TEXT_WITH_BALLOON ){
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_TEXT2,
						FALSE,
						NULL,
						md_env,
						&text2_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMannot.fill_leader_info(
					&rc,
					start_pt,
					end_pt,
					lead_grid,
					text_grid,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->dim_type != LEADER_LINE)
	{
		status =
		om$send(msg = message DMannot.set_text_attr(
						&rc,
						text_grid,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if( me->dim_type == TEXT_WITH_BALLOON ){
			status =
			om$send(msg = message DMannot.set_text_attr(
						&rc,
						text2_grid,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	if(me->dim_type != LEADER_LINE)
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

		if( me->dim_type == TEXT_WITH_BALLOON ){

			status =
			om$send(msg = message DMannot.make_an_text(
						&rc,
						&plan_info,
						&par_senv,
						text2_grid,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	/* TR179802270 by Ming */
	status =
	om$send(msg = message DMannot.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					lead_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMannot.make_an_term(
					&rc,
					&plan_info,
					&par_senv,
					term_grid,
					md_env),
	targetid = my_id);
	dm$status(action = RET_STATUS);

 	/* Commented by Ming for TR179802270
	status =
	om$send(msg = message DMannot.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					lead_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	*/

	if( me->dim_type == FEATURE_CONTROL_FRAME)
	{
		status =
		om$send( msg = message DMframe.make_profile_sym (
							&rc,
							&par_senv,
							&plan_info,
							md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status = 
	om$send(msg = message DMannot.chg_an_dp(&rc, &par_senv),
		targetid = my_id);
	dm$status( action = RET_STATUS);

	me->dim_state &=(~DIM_NEEDS_UPDATE);

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
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		txt_offset[1] = (me->break_pt[1] - start_pt[1])/
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		txt_offset[2] = (me->break_pt[2] - start_pt[2])/
		BSlenvec(&bsrc, plan_info.act_plan.vec_xpos);

		vec_equal(txt_offset, me->break_pt);

		/*"break_pt=(%lf, %lf, %lf)\n", me->break_pt[0], me->break_pt[1], me->break_pt[2]*/
	}

	*msg = MSSUCC;

	return(OM_S_SUCCESS);
}

method make_an_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid text_grid;
	struct GRmd_env *md_env)
{
	IGRint status,rc;
	IGRshort first;
	IGRlong long_rc, bsrc;
	IGRint num_vertex ,index;
	IGRdouble txt_orig[3],*break_pt;
	IGRshort txt_just;
	IGRchar  just_attr;
	IGRdouble *src_perp_vec, ver_dotp, scale;
	IGRvector txt_orie,perp_vec;
	IGRvector norm,lea_dir,elem_dir,y_axis;
	IGRdouble offset,y_offset;
	struct GRid balloon_grid,uline_grid, prev;
	IGRboolean is_src_text,on_element;
	IGRdouble ext_line[6];
	IGRdouble geometry[4][3];
	struct IGRestx attr;
	IGRuchar *text_string;
	struct IGRlbsys *lbs_geom;
	IGRint dir_flag, count;
	struct GRid list[MAX_DIM_ROOTS], owner, go_grid, src_grid;
	struct GRmd_env mod_info;

	*msg = OM_S_SUCCESS ;

	num_vertex = om$dimension_of(varray = me->break_pt) / 3;
	
	break_pt =  &me->break_pt[3*(num_vertex - 1)];
	vec_equal(break_pt,txt_orig); 

	norm[0] = plan_info->win_plan.matrix[8];
	norm[1] = plan_info->win_plan.matrix[9];
	norm[2] = plan_info->win_plan.matrix[10];

	scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

	just_attr = (me->dim_type == TEXT_WITH_LEADER)?
			par_senv->an_posn:ANNOT_JUST_CENTER;


	/*"just attr:%d\n",just_attr*/
	
	switch(me->dim_type)
	{
		case TEXT_WITH_LEADER:
		case TEXT_WITH_BALLOON:
		if(num_vertex > 1)
		{
			for(index = 0; index<3; index++)
			{
				lea_dir[index] = me->break_pt[3*(num_vertex - 1) + index] -
						 me->break_pt[3*(num_vertex - 2) + index];
			}
		}
		else
		{
			first = TRUE;
			if(me->dim_type == TEXT_WITH_BALLOON)
			{
				status =
				om$send(msg = message DMroot.give_previous(
								&rc,
								&first,
								&prev),
						targetid = my_id);
				dm$status(action = RET_STATUS);
			}

			if(!first)
			{
				if(me->bln_dir == RIGHT_SIDE)
				{
					math_v_equal(lea_dir,
						plan_info->act_plan.vec_xpos);
				}
				else
				{
					math_v_equal(lea_dir,
						plan_info->act_plan.vec_xneg);
				}
			}
			else
			{
				math_v_equal(lea_dir,
						plan_info->act_plan.vec_xpos);
			}
		}

		/*^ print_point ( "lea_dir",lea_dir); 
		    printf("just attr:%d\n",just_attr);
		    printf(" txt orie:%d\n",par_senv->an_orie);
		    print_point ( "norm",norm); 
		*/
		status =
		DMget_annot_txt_info(
			plan_info,
			par_senv,
			txt_orie,
			norm,
			&txt_just,
			lea_dir);
		dm$status(action = RET_STATUS);
		
		if(me->dim_type == TEXT_WITH_LEADER)
		{
			if (num_vertex > 1)
			{
				DMget_direction(
					&me->break_pt[3 *(num_vertex -2)],
					&me->break_pt[3 *(num_vertex -1)],
					plan_info->win_plan.matrix,
					&dir_flag);
			
				if( txt_just == LEFT_CENTER && dir_flag == AN_BEFORE)
					txt_just = RIGHT_CENTER;
				if( txt_just == LEFT_CAP && dir_flag == AN_BEFORE)
					txt_just = RIGHT_CAP;
				if( txt_just == LEFT_BASE && dir_flag == AN_BEFORE)
					txt_just = RIGHT_BASE;
			}
			else
			{
				/*|- No Leader */

			    /* Check if parent is a text with
			       leader, if so get the justication
			       from parents. KLUDGE for multiple
			       text with leader autodims */

			    status =
			    om$send(msg = message DMroot.DMreturn_roots(
							&count,
							list),
					targetid = my_id);
			    dm$status(action = RET_STATUS);

			    status =
			    om$send(msg = message NDnode.ASreturn_go(
						&src_grid,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
					targetid = list[AN_ROOT_ELEM1].objid,
					targetos = list[AN_ROOT_ELEM1].osnum);
			    dm$status(action = RET_STATUS);

			    /*^ print_grid("src_grid", &src_grid); */

			    status =
			    DMget_parents(src_grid, 10, list, &count);
			    dm$status(action = RET_STATUS);

			    status =
			    om$send(msg = message NDnode.ASreturn_go(
						&go_grid,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
					targetid = list[0].objid,
					targetos = list[0].osnum);
			    dm$status(action = RET_STATUS);

			    /*^ print_grid("go_grid", &go_grid); */

			    status =
			    om$get_objid_at_index(
					objid = go_grid.objid,
					osnum = go_grid.osnum,
					index = 0,
					p_chanselect = &AS_to_owner,
					objidaddr = &owner.objid,
					osnumaddr = &owner.osnum);
			    if (status == OM_S_SUCCESS)
			    {
				if (DMancestry_valid(owner, OPP_DMtxldr_class_id))
				{
				   /*|- Parent is a text with leader*/

				   status =
				   om$send(msg = message GRtext.GRgettxattr(
								&long_rc,
								&attr,
								NULL,
								NULL),
					targetid = go_grid.objid,
					targetos = go_grid.osnum);
				   dm$status(action = RET_STATUS);

				   if (attr.just < CENTER_BOTTOM)
				   	txt_just = LEFT_CENTER;
				   else txt_just = RIGHT_CENTER;
				}
				else txt_just = LEFT_CENTER;
			    }
			    else  txt_just = LEFT_CENTER;
			}
		}
		else
		if (me->dim_type == TEXT_WITH_BALLOON)
    	{
			if (par_senv->bln_type < 8)
			{
				txt_just = CENTER_CENTER;
			}
			else
			{
        		struct GRid t_grid;
 
        		status =
        		om$send(msg = message DMroot.return_dim_go(
               				     &rc,
			                     DIM_TEXT,
            			         FALSE,
                    			 NULL,
			                     md_env,
            			         &t_grid),
                		targetid = my_id);
        		dm$status(action = RET_STATUS);
 
        		if (t_grid.objid == text_grid.objid)
        		{
            		txt_just = CENTER_BOTTOM;
        		}
        		else
        		{
            		txt_just = CENTER_TOP;
        		}
			}
		} 
		else
				txt_just = CENTER_CENTER;

		BScrossp(&bsrc, norm, txt_orie, y_axis);

		BSnorvec(&bsrc, y_axis);

		y_offset = 0.5* par_senv->txt_heig;

		/*^
			print_point("break_pt", break_pt);
			print_point("y_axis", y_axis);
			printf("y_offset = %f\n",y_offset);
		*/

		if(just_attr == ANNOT_JUST_ABOVE)
		{
			for(index=0; index<3; index++)
			{
			   txt_orig[index] = break_pt[index] + y_offset * y_axis[index];
			}
		}
		else if (just_attr == ANNOT_JUST_BOTTOM)
		{
			for(index=0; index<3; index++)
			{	
			   txt_orig[index] = break_pt[index] - y_offset * y_axis[index];
			}
		}
		else if (just_attr == ANNOT_JUST_UNDER)
		{
			for(index=0; index<3; index++)
			{	
			   txt_orig[index] = break_pt[index] + y_offset * y_axis[index];
			}
		}

		break;
		
		case FEATURE_CONTROL_FRAME:
		case DATUM_FRAME:
			
		status =
		om$send(msg = message DMroot.DMreturn_roots(
							&count,
							list),
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
		om$send(msg = message DMsrc.DMgive_tangent(&rc,
					&is_src_text,
					lea_dir,
					geometry,
					&mod_info),
			targetid = list[AN_ROOT_ELEM1].objid,
			targetos = list[AN_ROOT_ELEM1].osnum);
		dm$status(action = RET_STATUS);

		if (is_src_text == POINT_TYPE)
		{
			/*|- Element is point type */

			for(index=0; index<3; index++)
			lea_dir[index] = plan_info->act_plan.vec_xpos[index];
		}

		BSnorvec(&bsrc, lea_dir);

		status =
		DMget_annot_txt_info(
			plan_info,
			par_senv,
			txt_orie,
			norm,
			&txt_just,
			lea_dir);
		dm$status(action = RET_STATUS);

		BScrossp( &bsrc,norm,txt_orie,perp_vec);
		math_v_scale(perp_vec, scale);
		ver_dotp = fabs(BSdotp(&bsrc,txt_orie,lea_dir));
		if (ver_dotp > DOTP_LOWER_BOUND
		&&  ver_dotp < DOTP_UPPER_BOUND)
			src_perp_vec = perp_vec;
		else	src_perp_vec = txt_orie;

		if(num_vertex < 2)
		{
			if(me->bln_dir)
			{
				MATH_ptdelta(&rc,txt_orig,src_perp_vec,
					     par_senv->txt_heig,txt_orig);
			}
			else
			{
				MATH_ptdelta(&rc,txt_orig,src_perp_vec,
					     -par_senv->txt_heig,txt_orig);
			}
			
		}
		status =
		om$send(msg = message DMframe.get_tol_just(
						&rc,
						txt_orig,
						is_src_text,
						geometry,
						plan_info,
						&txt_just,
						&me->bln_dir,
						&on_element,
						ext_line,
						par_senv,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		default: printf("dim_type:%d\n",me->dim_type);
			 return(OM_E_ABORT);
	}
	
	/*^print_point("txt orig",txt_orig);
	   printf("txt just:%d\n",txt_just);*/

	status =
	om$send(msg = message DMroot.position_text(
					&rc,
					TRUE,
					DIM_NO_INDEX,
					&text_grid,
					md_env,
					txt_just,
					txt_orig,
					txt_orie,
					norm,
					NULL,
					NULL),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	if(me->dim_type == TEXT_WITH_BALLOON)
	{
		/*| position balloon*/
			status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_BALLOON,
						FALSE,
						NULL,
						md_env,
						&balloon_grid),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	
		status =
		om$send(msg = message DMtxbln.position_balloon(
							&rc,
							DIM_BALLOON,
							par_senv,
							txt_orig,
							&balloon_grid,
							md_env,
							plan_info),
 				  targetid = my_id);
		dm$status( action = RET_STATUS);
	}
	else if( me->dim_type == FEATURE_CONTROL_FRAME ||
		 me->dim_type == DATUM_FRAME)
	{
		status = 
		om$send( msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&lbs_geom),
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);


		status =
		om$send ( msg = message GRtext.GRgettxattr(
						&long_rc,
						&attr,
						NULL,
						&text_string),
			targetid= text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		/*^
			analyse_string(text_string, attr.text_length);
		*/

		status = 
		om$send( msg = message DMframe.update_text_box(
						&long_rc,
						text_string,
						&attr,
						lbs_geom,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		if(text_string)	 free(text_string);
	
		if(!me->leader && !on_element)
		{
			BSmkvec(&bsrc,elem_dir,&ext_line[3],ext_line);
			BSnorvec(&bsrc,elem_dir);
			
			offset = -0.5 * par_senv->txt_heig;
			MATH_ptdelta( &rc,ext_line,elem_dir,offset,ext_line);
			status =
			om$send(msg = message DMroot.return_dim_go(
							&rc,
							DIM_ULINE,
							FALSE,
							NULL,
							md_env,
							&uline_grid),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status=
			om$send(msg = message DMroot.position_line(
						&rc,
						DIM_ULINE,
						&uline_grid,
						md_env,
						ext_line),
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
	}

	return(OM_S_SUCCESS);
}

method get_dim_attr( char *attr)
{
    IGRint status;
    IGRlong long_rc;
    IGRint num_brkpt;
    struct annot_attr *dim_attr;
    struct GRid text_grid, lead_grid;
    struct GRmd_env md_env;
    struct IGRbsp_curve *bsp_curve;
 
    struct DMsenv_param par_senv;
 
    dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);
 
    dim_attr = (struct annot_attr *)attr;
 
    dim_attr->dim_type = me->dim_type;
    dim_attr->dim_state = me->dim_state;
    dim_attr->geom_type = me->geom_type;
    dim_attr->display = me->display;
    dim_attr->leader = me->leader;
    dim_attr->dual_mode = me->dual_mode;
    dim_attr->bln_dir = me->bln_dir;
    dim_attr->tol_symbol = me->tol_symbol;
    dim_attr->num_brkpt = 0;
    dim_attr->text_length = 0;
 
 
    status = DMget_module_info(&md_env);
    dm$status(action = RET_STATUS);
 
    status =
    om$send(msg = message DMannot.get_graphics(
                    FALSE,
                    &text_grid,
                    &lead_grid,
                    NULL,
                    &md_env),
        targetid = my_id);
    dm$status(action = RET_STATUS);
 
    if (lead_grid.objid != NULL_OBJID )
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
 
        if (me->dim_type == LEADER_LINE ||
           (me->dim_type == TEXT_WITH_BALLOON &&
            par_senv.attach_pt == INSIDE_OBJECT))
            num_brkpt = bsp_curve->num_poles - 2;
        else    num_brkpt = bsp_curve->num_poles - 1;
 
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
 
            if (me->dim_type == LEADER_LINE )
            {
                memcpy(dim_attr->end_pt,
                    &bsp_curve->poles
                        [3*(bsp_curve->num_poles - 1)],
                    sizeof(IGRdouble) * 3);
            }
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
    if (text_grid.objid != NULL_OBJID)
    {
        status =
        om$send(msg = message GRtext.GRgettxattr(
                    &long_rc,
                    NULL,
                    &dim_attr->text_length,
                    &dim_attr->text_string),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);
    }
 
    return(OM_S_SUCCESS);
}

method get_active_senv(struct DMsenv_param *par_senv)
{
    IGRint status;
 
    status =
    dm$get_dim_param(
        type = DM_SENV_PARAM,
        dim_objid = my_id,
        dim_osnum = OM_Gw_current_OS,
        p_data = (char *) par_senv);
    dm$status(action = RET_STATUS);
 
    if (me->dim_type == TEXT_WITH_BALLOON)
    {
        if(par_senv->bln_type == BLN_TYPE_TRIANGLE || 
           par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)
            par_senv->num_sides = 3;
        else if (par_senv->bln_type == BLN_TYPE_SQUARE || 
                 par_senv->bln_type == BLN_TYPE_SPLIT_SQUARE)
            par_senv->num_sides = 4;
        else if (par_senv->bln_type == BLN_TYPE_POLYGON || 
                 par_senv->bln_type == BLN_TYPE_SPLIT_POLYGON)
        {
            if(par_senv->num_sides < 4)
                par_senv->num_sides = 4;
        }
    }
 
    return(OM_S_SUCCESS);
}

end implementation DMannot;
