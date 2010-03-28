/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: annot.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.3  1997/11/06  10:35:52  jpulapar
# COMMENT : Fit problems in Place Text with leader/Add leader line have been fixed
#
# Revision 340.0  1997/05/27  23:07:08  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.4  1997/01/31  12:30:16  bsubbaia
# COMMENT : Fix for Ultralite Add-material problem.
#
# Revision 330.3  1996/12/28  12:44:30  bsubbaia
# COMMENT : patterning dimensions regressions caused by balloons
#
# Revision 330.2  1996/06/27  11:32:03  grnuc33
# COMMENT : Corrected Syntax errors.
#
# Revision 330.1  1996/05/31  10:09:19  skathiri
# COMMENT : Code changes for the enhanced balloon functionality
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

method  NDplace(
    struct GRas *assoc_lis;
    struct GRmd_env *md_env;
    char *go_cnst_lis)
{
    IGRint status, rc;
    IGRint count;
    struct annot_attr *an_attr;
    struct GRid list[MAX_DIM_ROOTS];
    struct GRid null_grid;

    an_attr = (struct annot_attr *)assoc_lis->as_attr;
    DMcopy_roots(list, assoc_lis->parents, count=assoc_lis->num_parents);
    null_grid.objid = NULL_OBJID;

    status =
    dm$create_root(
        type = DMptdist,
        count = 1,
        list = &list[AN_ROOT_ELEM1],
        context = &null_grid,
        attr = an_attr->start_pt,
        md_env = md_env,
        p_root = &list[AN_ROOT_ELEM1]);
    dm$status(action = RET_STATUS);

    if (an_attr->dim_type == LEADER_LINE)
    {
        status =
        dm$create_root(
            type = DMptdist,
            count = 1,
            list = &list[AN_ROOT_ELEM2],
            context = &null_grid,
            attr = an_attr->end_pt,
            md_env = md_env,
            p_root = &list[AN_ROOT_ELEM2]);
        dm$status(action = RET_STATUS);
    }

    status =
    om$send(msg = message DMroot.DMplace(
                    &rc,
                    count,
                    list,
                    assoc_lis->as_attr,
                    md_env),
        targetid = my_id);
    dm$status(action = RET_STATUS);

    return(OM_S_SUCCESS);
}

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

    if(me->dim_type == TEXT_WITH_BALLOON)
	{
	status = om$send(msg = message DMroot.return_dim_go(
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
                if(me->dim_type == TEXT_WITH_BALLOON)
                {
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

        if(me->dim_type == TEXT_WITH_BALLOON)
        { 
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
                
        if(me->dim_type == TEXT_WITH_BALLOON)
         {
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

	status =
	om$send(msg = message DMannot.make_an_term(
					&rc,
					&plan_info,
					&par_senv,
					term_grid,
					md_env),
	targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMannot.make_lead_line(
					&rc,
					&par_senv,
					&plan_info,
					lead_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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

method get_dimension_plane(
    IGRint *msg;
    struct GRmd_env *md_env;
    struct DMplan_info *plan_info)
{
    IGRint status, rc, index;
    IGRshort first;
    IGRdouble text_offset, start_pt[3];
    struct GRid prev;
    struct DMsenv_param par_senv;
    struct ret_struct ret_str;

    *msg = DIM_S_SUCCESS;

    status =
    om$send(msg = message DMroot.get_dimension_plane(
                    msg,
                    md_env,
                    plan_info),
        mode = OM_e_wrt_message,
        targetid = my_id);
    dm$status(action = RET_STATUS);

    first = TRUE;
    if(me->dim_type == TEXT_WITH_BALLOON)
    {
        status =
        om$send(msg = message DMroot.give_previous(&rc, &first, &prev),
                targetid = my_id);
        dm$status(action = RET_STATUS);
    }

    if(!first)
    {
        /*| - get bln center form the previous balloon */

        status =
        om$send(msg = message DMannot.get_active_senv(&par_senv),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        text_offset = par_senv.txt_heig * 0.5;
        status=
        om$send(msg = message DMtxbln.give_bln_center(
                            &rc,
                            &text_offset,
                            start_pt,
                            &prev,
                            plan_info,
                            md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);
    }
    else
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
            math_v_equal(start_pt, ret_str.var.line_st.p1);
        }
        else
        {
            math_v_equal(start_pt, ret_str.var.point_st.pt);
        }
    }

    for (index=0; index<3; index++)
    {
        plan_info->win_plan.matrix[4*index + 3] =
        plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
    }

    return(OM_S_SUCCESS);
}

method gather_data(
    IGRint *msg;
    IGRint count;
    struct GRid list[];
    IGRpoint start_pt;
    IGRpoint end_pt;
    struct DMplan_info *plan_info;
    struct DMsenv_param *par_senv;
    struct GRmd_env *md_env)
{
    IGRint status, rc, index;
    IGRshort first;
    IGRdouble text_offset;
    struct GRid prev;
    struct ret_struct ret_str;

    /*| - Get environment parameters */

    status =
    om$send(msg = message DMannot.get_active_senv(par_senv),
            targetid = my_id);
    dm$status(action = RET_STATUS);

    /*| - Get the dimension plane */

    status =
    om$send(msg = message DMroot.get_dimension_plane(
                    msg,
                    md_env,
                    plan_info),
        mode = OM_e_wrt_message,
        targetid = my_id);
    dm$status(action = RET_STATUS);

    first = TRUE;
    if(me->dim_type == TEXT_WITH_BALLOON)
    {
        status =
        om$send(msg = message DMroot.give_previous(&rc, &first, &prev),
                targetid = my_id);
        dm$status(action = RET_STATUS);
    }

    if(!first)
    {
        /*| - get bln center form the previous balloon */

        text_offset = par_senv->txt_heig * 0.5;
        status=
        om$send(msg = message DMtxbln.give_bln_center(
                            &rc,
                            &text_offset,
                            start_pt,
                            &prev,
                            plan_info,
                            md_env),
                targetid = my_id);
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
            list[AN_ROOT_ELEM1].objid,
            my_id,
            OM_Gw_current_OS,
            md_env,
            &ret_str);
        dm$status(action = RET_STATUS);

        if (ret_str.type == line_generic)
        {
            math_v_equal(start_pt, ret_str.var.line_st.p1);
        }
        else
        {
            math_v_equal(start_pt, ret_str.var.point_st.pt);
        }
    }

    for (index=0; index<3; index++)
    {
        plan_info->win_plan.matrix[4*index + 3] =
        plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
    }

    if (me->dim_type == LEADER_LINE)
    {
        status =
        DMnode_give_structure(
            &rc,
            DIM_NO_INDEX,
            MEAS_INFO,
            (me->geom_type & DIM_IMPORTED),
            list[AN_ROOT_ELEM2].objid,
            my_id,
            OM_Gw_current_OS,
            md_env,
            &ret_str);
        dm$status(action = RET_STATUS);

        if (ret_str.type == line_generic)
        {
            math_v_equal(end_pt, ret_str.var.line_st.p1);
        }
        else
        {
            math_v_equal(end_pt, ret_str.var.point_st.pt);
        }
    }

    return(OM_S_SUCCESS);
}

method get_graphics(
    IGRboolean create;
    struct GRid *text_grid;
    struct GRid *lead_grid;
    struct GRid *term_grid;
    struct GRmd_env *md_env)
{
    IGRint status, rc;
    IGRint go_index[3], go_type[3], index;
    struct GRid *go_grid[3];

    go_index[0] = DIM_TEXT;
    go_index[1] = DIM_LEADER;
    go_index[2] = DIM_ORI_TERM;

    go_grid[0] = text_grid;
    go_grid[1] = lead_grid;
    go_grid[2] = term_grid;

    go_type[0] = DM_TEXT;
    go_type[1] = DM_LINE_STR;
    go_type[2] = DM_TEXT;

    for (index=0; index<3; index++)
    {
        if (!go_grid[index]) continue;

        status =
        om$send(msg = message DMroot.return_dim_go(
                        &rc,
                        go_index[index],
                        create,
                        go_type[index],
                        md_env,
                        go_grid[index]),
            targetid = my_id);
        dm$status(action = RET_STAUS);
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
    IGRint status, num_vertex, index, rc;
    IGRlong long_rc, bsrc;
    struct IGRbsp_curve *bsp_curve;
    struct IGRlbsys *lbsys_geom;
    IGRdouble *vertex,scale;
    IGRpoint text_orig, text_pt;
    IGRvector diff_vec;

        struct DMsenv_param par_senv;
        IGRvector norm, yaxis;
        IGRchar just_attr;
        IGRpoint vert1, vert2, text_pt1,inter_pt;

    /*| Get the Connect data from the text element */

    scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

    if((me->dim_type != LEADER_LINE) && me->leader)
    {
        status =
        om$send(msg = message GRvg.GRgenabsg(
                    &long_rc,
                    &md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    (char **)&lbsys_geom),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);

        /*^ print_matrix("matrix",lbsys_geom->matrix); */

        text_pt[0] = lbsys_geom->matrix[3];
        text_pt[1] = lbsys_geom->matrix[7];
        text_pt[2] = lbsys_geom->matrix[11];

                yaxis[0] = lbsys_geom->matrix[4];
                yaxis[1] = lbsys_geom->matrix[5];
                yaxis[2] = lbsys_geom->matrix[6];

        vec_equal(text_pt,text_orig);
    }

    if (lead_grid.objid != NULL_OBJID)
    {
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

        if(me->dim_type == TEXT_WITH_LEADER)
        {
/* Commented out this Code and replaced it with new code to take care of
   TR# 119525285
                    status =
            BSproj0(&long_rc, text_pt,
                                &bsp_curve->poles[3*(num_vertex -2)],
                text_orig);
            if(!(status & 1))
            {
                vec_equal(text_pt,text_orig);

            }
*/
                       status =
                                dm$get_dim_param ( type = DM_SENV_PARAM,
                                                   dim_objid = my_id,
                                                   dim_osnum = OM_Gw_current_OS,
                                                   p_data =  &par_senv);
                        dm$status (action = RET_STATUS);
                        just_attr = par_senv.an_posn;

                        BSnorvec (&bsrc, yaxis);


                        for (index=0;index<3;index++)
                        {
                                vert1[index] = bsp_curve->poles[3*
                                         (num_vertex-1) +index];
                                vert2[index] = bsp_curve->poles[3*
                      (num_vertex-2) + index];
                                text_pt1[index] = text_pt[index];
                        }

                        status = BSxln(&bsrc, vert1, vert2,
                                              text_pt, text_pt1,
                                              inter_pt);

                        if (status == TRUE)
                        {
                                memcpy(text_orig,
                                       inter_pt,
                                       sizeof(IGRpoint));
                        }
                        else
                        {
                                status = BScollin(&bsrc,vert2,
                                                  vert1,text_pt);
                                if (status == FALSE)
                                     status = BSproj0(&bsrc,
                                                      text_pt,
                                                      &bsp_curve->poles[3*
                            (num_vertex-2)],
                                                      text_orig);
                                else
                                     for (index=0;index<3;index++)
                                        text_orig[index] = text_pt[index];
                        }
        }

        vec_sub(start_pt, me->break_pt, diff_vec);

        /*^ print_point("def vec",diff_vec);*/

        vec_add(text_orig, diff_vec, text_orig);

        for (index=0; index<num_vertex; index++)
        {
            vertex = &me->break_pt[index*3];
            vec_add(vertex, diff_vec, vertex);
        }

        vertex = &me->break_pt[3*(num_vertex - 1)];
        /*^
            print_point("last vertex",vertex);
            print_point("startpt",start_pt);
        */
        if( me->dim_type != LEADER_LINE)
        {
            /*| modify to the text origin*/
            vec_equal(text_orig, vertex);
        }
        else
        {
            /*| modify to the second element origin */
            vec_equal(end_pt,vertex);
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

    /*^
        {
            int i;
            for( i = 0 ;i < 3*num_vertex;i++)
                printf("point[%d]:%lf\n",i,me->break_pt[i]);
        }
    */
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

method make_an_term(
    IGRint *msg;
    struct DMplan_info *plan_info;
    struct DMsenv_param *par_senv;
    struct GRid term_grid;
    struct GRmd_env *md_env)
{
    IGRint status, rc;
    IGRint num_vertex;
    IGRvector term_orie;
    IGRshort ter_just;
    IGRdouble scale;
    struct DMenv_param par_env;
    struct DMloc_param par_loc;
    extern struct DMglobal DM_global;
    BSrc    bsrc;

    num_vertex = om$dimension_of(varray = me->break_pt)/ 3;
    if (num_vertex < 2)
    {
        status =
        om$send(msg = message DMroot.delete_dim_go(
                        &rc,
                        DIM_ORI_TERM,
                        md_env),
            targetid = my_id);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
    }

    BSmkvec(&bsrc, term_orie, &me->break_pt[3], me->break_pt);
    BSnorvec(&bsrc, term_orie);
    scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);
    math_v_scale(term_orie, scale);

    ter_just = DM_global.term_info[par_senv->ter_type].center_just?
                CENTER_CENTER:RIGHT_CENTER;


    DMsplit_senv(par_senv, &par_env, &par_loc, NULL);

    if(me->dim_type == DATUM_FRAME &&
       par_senv->datum_ter_type == DATUM_TER_TYPE_ANCHOR)
    {
        ter_just = RIGHT_CENTER;

        status =
        om$send(msg = message DMframe.set_datum_term(
                        (IGRlong *)&rc,
                        &term_grid,
                        md_env,
                        &par_env,
                        &par_loc),
            targetid = my_id);
        dm$status(action = RET_STATUS);
    }
    else
    {
        status =
        om$send(msg = message DMroot.set_ter_type(
                        &rc,
                        DIM_NO_INDEX,
                        &term_grid,
                        md_env,
                        &par_env,
                        &par_loc),
            targetid = my_id);
        dm$status(action = RET_STATUS);
    }

    status =
    om$send(msg = message DMroot.position_text(
                    &rc,
                    FALSE,
                    DIM_NO_INDEX,
                    &term_grid,
                    md_env,
                    ter_just,
                    me->break_pt,
                    term_orie,
                    &plan_info->win_plan.matrix[8],
                    NULL,
                    NULL),
        targetid = my_id);
    dm$status(action = RET_STATUS);

    return(OM_S_SUCCESS);
}

method make_lead_line(
    IGRint *msg;
    struct DMsenv_param *par_senv;
    struct DMplan_info *plan_info;
    struct GRid lead_grid;
    struct GRmd_env *md_env)
{
    IGRint status, rc, num_vertex;

    status =
    om$send(msg = message DMannot.update_leader(
                    &rc,
                    &num_vertex,
                    NULL,/* geometry of text*/
                    par_senv,
                    plan_info,
                    md_env),
        targetid = my_id);
    dm$status(action = RET_STATUS);

    if (num_vertex < 2) return(OM_S_SUCCESS);

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

    return(OM_S_SUCCESS);
}

method update_leader(
    IGRint *msg;
    IGRint *num_vertex;
    IGRdouble *geometry;
    struct DMsenv_param *par_senv;
    struct DMplan_info *plan_info;
    struct GRmd_env *md_env)
{
    IGRint status, rc;
    IGRlong long_rc, bsrc;
    struct IGRlbsys *lbsys;
    struct IGRestx attr;
    struct GRid text_grid;
    IGRboolean extend, intersect;
    IGRdouble intpt[6], lea_line[6], lea_vec[3];
    IGRdouble dotp, *req_dir, *p1, *p2, offset;
    IGRchar just_attr;
    IGRdouble box[12];

    *num_vertex = om$dimension_of(varray = me->break_pt) / 3;

    if (me->dim_type != TEXT_WITH_LEADER)
        return(OM_S_SUCCESS);

    if (*num_vertex < 2)
    {
        status =
        om$send(msg = message DMroot.delete_dim_go(
                        &rc,
                        DIM_LEADER,
                        md_env),
            targetid = my_id);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
    }

    /*"geometry:%d",geometry*/

    if(!geometry)
    {
        status =
        om$send(msg = message DMroot.return_dim_go(
                        &rc,
                        DIM_TEXT,
                        FALSE,
                        DM_TEXT,
                        md_env,
                        &text_grid),
            targetid = my_id);
        dm$status(action = RET_STATUS);

        if( text_grid.objid == NULL_OBJID)
            return(OM_S_SUCCESS);

        status =
        om$send(msg = message GRtext.GRgettxattr(
                        &long_rc,
                        &attr,
                        NULL,
                        NULL),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);

        if (!attr.num_char)
        {
            /*| displayable chars = 0 */
            return(OM_S_SUCCESS);
        }

        status =
        om$send(msg = message GRvg.GRgenabsg(
                    &long_rc,
                    &md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    (char **)&lbsys),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);
    }
    else
    {
        lbsys = (struct IGRlbsys *)geometry;
    }

    p1 = &me->break_pt[3 * (*num_vertex - 2)];
    p2 = &me->break_pt[3 * (*num_vertex - 1)];


    DMlineptpt(p1, p2, lea_line);
    BSmkvec(&bsrc, lea_vec, p1, p2);
    BSnorvec(&bsrc, lea_vec);

    just_attr = (me->dim_type == TEXT_WITH_LEADER)?
            par_senv->an_posn:ANNOT_JUST_CENTER;

    extend = FALSE;

    if (just_attr == ANNOT_JUST_UNDER)
    {
        /*| ANNOT_JUST_UNDER */

        if (par_senv->an_orie == TXT_ORIE_HORIZONTAL
        ||  par_senv->an_orie == TXT_ORIE_VERTICAL)
        {
            /*| HORIZONTAL OR VERTICAL */

            req_dir = (par_senv->an_orie == TXT_ORIE_HORIZONTAL)?
                    plan_info->win_plan.vec_xpos:
                    plan_info->win_plan.vec_ypos;
            dotp = fabs(BSdotp(&bsrc, req_dir, lea_vec));
            if (dotp > DOTP_LOWER_BOUND && dotp < DOTP_UPPER_BOUND)
                extend = TRUE;
        }
        else    extend = TRUE;
    }

    MATH_get_box_points(&rc, lbsys, box);

    if (extend)
    {
        /*| Extend line */

        MATH_line_extend(
            &rc,
            lea_line,
            lea_line + 3,
            box,
            p2);

        intersect = FALSE;
    }
    else
    {
        /*| Intersect Line */

        MATH_intersect_box_line(
            &rc,
            lea_line,
            box,
            intpt,
            &intersect,
            plan_info->win_plan.matrix);
    }

    /*"intersect :%d\n",intersect*/
    /*^print_point("lea vec:",lea_vec);*/
    if (intersect)
    {
        offset =  - par_senv->txt_heig;

        MATH_ptdelta(
            &rc,
            intpt,
            lea_vec,
            offset,
            p2);
    }
    /*^
        print_point(" prev point",p1);
        print_point(" last point",p2);
    */

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

method get_dim_params(
    IGRint *msg;
    IGRint type;
    IGRint size;
    char *param)
{
    IGRint status;
    struct DMsenv_param par_senv;

    status =
    om$send(msg = message dim_param.give_internal(
            DM_SENV_PARAM,
            sizeof(par_senv),
            (char *)&par_senv),
        p_chanselect = &ND_father,
        from = DIM_ROOT_SENV,
        to = DIM_ROOT_SENV);
    dm$status(action = RET_STATUS);

    switch (type)
    {
        case DM_ENV_PARAM:

        DMsplit_senv(&par_senv, (struct DMenv_param *) param, NULL, NULL);
        break;

        case DM_LOC_PARAM:

        DMsplit_senv(&par_senv, NULL, (struct DMloc_param  *) param, NULL);
        break;

        case DM_MISC_PARAM:

        DMsplit_senv(&par_senv, NULL, NULL, (struct DMmisc_param *) param);
        break;

        case DM_SENV_PARAM:

        *(struct DMsenv_param *)param = par_senv;
        break;
    }

    *msg = DIM_S_SUCCESS;
    return(OM_S_SUCCESS);
}

method set_dim_params(
    IGRint *msg;
    IGRint type;
    IGRint size;
    struct GRmd_env *md_env;
    char *param)
{
    IGRint status;
    struct DMsenv_param par_senv;
    struct GRid grid;

    status =
    om$send(msg = message dim_param.give_internal(
                    DM_SENV_PARAM,
                    sizeof(par_senv),
                    (char *)&par_senv),
        p_chanselect = &ND_father,
        from = DIM_ROOT_SENV,
        to = DIM_ROOT_SENV);
    dm$status(action = RET_STATUS);

    switch (type)
    {
        case DM_ENV_PARAM:

        DMmerge_senv(&par_senv, (struct DMenv_param *)param, NULL, NULL);
        break;

        case DM_LOC_PARAM:

        DMmerge_senv(&par_senv, NULL, (struct DMloc_param *) param, NULL);
        break;

        case DM_MISC_PARAM:

        DMmerge_senv(&par_senv, NULL, NULL, (struct DMmisc_param *) param);
        break;

        case DM_SENV_PARAM:

        par_senv = *(struct DMsenv_param *)param;
        break;
    }

    status =
    om$send(msg = message dim_param.edit(
                    DM_SENV_PARAM,
                    sizeof(par_senv),
                    (char *)&par_senv,
                    md_env,
                    &grid),
        p_chanselect = &ND_father,
        from = DIM_ROOT_SENV,
        to = DIM_ROOT_SENV);
    dm$status(action = RET_STATUS);

    *msg = DIM_S_SUCCESS;
    return(OM_S_SUCCESS);
}

method set_text_attr(
    IGRint *msg;
    struct GRid text_grid;
    struct GRmd_env *md_env)
{
    IGRint status, rc;
    struct GRdpb_text_symb text_symb;
    struct DMsenv_param par_senv;

    status =
    om$send(msg = message DMannot.get_active_senv(&par_senv),
            targetid = my_id);
    dm$status(action = RET_STATUS);

    if(me->dim_type == TEXT_WITH_BALLOON)
    {
        status = DMget_bln_txt_width(
                    TRUE,
                    NULL,
                    &par_senv,
                    text_grid,
                    md_env);
    }


    text_symb.Active_font    = par_senv.text_font;
    text_symb.Active_just    = -1;
    text_symb.Active_fraction_font = par_senv.frac_font;
    text_symb.Active_width   = par_senv.txt_widt;
    text_symb.Active_height  = par_senv.txt_heig;
    text_symb.Active_charspac= par_senv.car_spac;
    text_symb.Active_linespac= par_senv.lin_spac;

    status =
    om$send(msg = message DMroot.chgtextattr(
                    &rc,
                    DIM_NO_INDEX,
                    &text_grid,
                    md_env,
                    &text_symb),
        targetid = my_id);
    dm$status(action = RET_STATUS);

    return(OM_S_SUCCESS);
}

method copy_dim_attr(
    IGRint *msg;
    IGRint control;
    struct GRid *dim_grid;
    struct GRmd_env *md_env)
{
    IGRint status, index;
        OMuint count;
    IGRchar *geom;
    IGRlong long_rc;
    struct GRpost_info post_info;
    OM_S_OBJID dummy,md_id_save;
    extern IGRboolean ASbroadcast_in_progress;
    enum GRdpmode mode;
    struct annot_attr attr;

    md_id_save = md_env->md_id.objid;
    if(md_id_save != NULL_OBJID)
        md_env->md_id.objid = NULL_OBJID;

    mode = GRbe;

    status =
    om$send(msg = message GRgraphics.GRdisplay(
                        &long_rc,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                        &mode,
                        &md_env->md_id),
            targetid = my_id);
    dm$status(action = RET_STATUS);

    status =
    om$get_channel_count(
            osnum = dim_grid->osnum,
            objid = dim_grid->objid,
            p_chanselect = &AS_to_comp,
            count = &count);
    dm$status(action = RET_STATUS);

    post_info.construct_flag = FALSE;

    for(index = 0; index < count; index++)
    {
        om$send(msg = message GRvg.GRgenabsg(
                        &long_rc,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                        (char **)&geom),
            senderid = dim_grid->objid,
            from = index,
            to = index,
            p_chanselect = &AS_to_comp);
        dm$status(action = RET_STATUS);

        /*| GRpostabsg*/

        status =
        om$send(msg = message GRvg.GRpostabsg(
                        &long_rc,
                            md_env,
                            &post_info,
                            (char *)geom,
                            &dummy),
            senderid = my_id,
            from = index,
            to = index,
            p_chanselect = &AS_to_comp);
        dm$status(action = RET_STATUS);
    }

    if(md_id_save != NULL_OBJID)
        md_env->md_id.objid = md_id_save;

        if ((!ASbroadcast_in_progress) && !(control & INST_NOT_IN_BATCH))
    {
        struct GRid my_grid;
        IGRint cn_type;

        cn_type = ND_COMP;
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;

        nd$wait_batch(
            type = GR_GEOM_POSTED,
            l_object = &my_grid,
            l_obj_info = &cn_type,
            nb_obj   = 1);
    }

    if (!me->leader)
    {
        /*|- get the text offset instance from copy*/

        status =
        om$send(msg = message DMannot.get_dim_attr((char *)&attr),
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        if (attr.num_brkpt > 0)
        {
            /*|- Offset present */

            status =
            om$vla_set_dimension(varray = me->break_pt,
                    size = 3 * attr.num_brkpt);
            dm$status(action = RET_STATUS);

            memcpy(me->break_pt, attr.brkpt,
                sizeof(IGRdouble) * 3 * attr.num_brkpt);

        }
    }

    *msg = DIM_S_SUCCESS;
    return(OM_S_SUCCESS);
}

method get_just_attr(IGRchar *just_attr)
{
    *just_attr = ANNOT_JUST_CENTER;
    return(OM_S_SUCCESS);
}

method  ANadd_delete_vertex(
    IGRint *msg;
    IGRint flag;
    IGRdouble  *vertex;
    struct GRmd_env *md_env)
{
    IGRint status, rc, num_vertex, index, least_vtx_num;
    IGRlong long_rc;
    struct GRid lead_grid;
    IGRdouble *vtx, *last_vtx;
    IGRboolean new_flag;
    struct ret_struct ret_str;
    struct IGRpolyline poly_line;
    struct GRpost_info post_info;
    struct IGRbsp_curve *bsp_curve;

    /*| Return the graphic object */

    *msg = TRUE;

    if (me->dim_type == WELD)
    {
        index = LEAD_LINE;
        least_vtx_num = 3;
    }
    else if (me->dim_type == SURF)
    {
        index = SURF_LEADER;
        least_vtx_num = 3;
    }
    else
    {
        index = DIM_LEADER;
        least_vtx_num = 2;
    }

    status =
    om$send(msg = message DMroot.return_dim_go(
                    &rc,
                    index,
                    TRUE,
                    DM_LINE_STR,
                    md_env,
                    &lead_grid),
        targetid = my_id);
    dm$status(action = RET_STATUS);

    new_flag = (rc == DIM_I_OBJ_CREATED);

    /*"new flag%d\n",new_flag*/

    if (lead_grid.objid == NULL_OBJID)
        return(OM_S_SUCCESS);

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

    num_vertex = bsp_curve->num_poles;

    status =
    om$vla_set_dimension(varray = me->break_pt,
                 size   = num_vertex * 3);
    dm$status(action = RET_STATUS);

    memcpy( me->break_pt,
        bsp_curve->poles,
        3*sizeof(IGRdouble) * num_vertex);

    if (flag == DELETE_VERTEX)
    {
        /*|Delete Vertex*/
        num_vertex--;

        if (num_vertex < least_vtx_num)
        {
            *msg = FALSE;
            return(OM_S_SUCCESS);
        }

        status =
        om$vla_set_dimension(varray = me->break_pt,
            size = num_vertex * 3);
        dm$status(action = RET_STATUS);
    }
    else if (flag == ADD_VERTEX)
    {
        /*| Add vertex */

        if (new_flag)
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
               vec_equal(ret_str.var.line_st.p1, me->break_pt);
            }
            else
            {
               vec_equal(ret_str.var.point_st.pt, me->break_pt);
            }

            vtx = (vertex)? vertex:me->break_pt;
            last_vtx = &me->break_pt[3];
        }
        else
        {
            num_vertex++;

            status =
            om$vla_set_dimension(varray = me->break_pt,
                size = num_vertex * 3);
            dm$status(action = RET_STATUS);
            /*"num vertices:%d\n",om$dimension_of(varray = me->break_pt)/3*/

            vtx =   &me->break_pt[3 * (num_vertex - 2)];
            last_vtx = &me->break_pt[3 * (num_vertex - 1)];
        }

        vec_equal(vtx, last_vtx);
    }
    else if (flag == UPDATE_VERTEX)
    {
        /*| Update Vertex*/
        last_vtx = &me->break_pt[3 * (num_vertex - 1)];
        vec_equal(vertex, last_vtx);
    }

    poly_line.num_points = num_vertex;
    poly_line.points = me->break_pt;
    post_info.construct_flag = FALSE;

    /*^
        int i;

        for( i = 0 ;i < 3*num_vertex;i++)
            printf("point[%d]:%lf\n",i,me->break_pt[i]);
    */

    status=
    om$send(msg = message GRlinear.GRputpolyline(
                    &long_rc,
                    md_env,
                    &post_info,
                    &poly_line,
                    &lead_grid.objid),
        targetid = lead_grid.objid,
        targetos = lead_grid.osnum);
    dm$status(action = RET_STATUS);

    if(me->dim_type == TEXT_WITH_BALLOON)
    {
        status =
        om$send(msg = message DMroot.position_text(
                        &rc,
                        FALSE,
                        DIM_TEXT,
                        NULL,
                        md_env,
                        -1,
                        &me->break_pt[3*(num_vertex-1)],
                        NULL,
                        NULL,
                        NULL,
                        NULL),
            targetid = my_id);
        dm$status(action = RET_STATUS)
    }

    status =
    om$vla_set_dimension(varray = me->break_pt, size = 0);
    dm$status(action = RET_STATUS);

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

method get_disp_list(
    IGRint *msg;
    IGRint *count;
    struct GRid *list;
    struct GRmd_env *md_env)
{
    *count = 1;

    list[0].objid = my_id;
    list[0].osnum = OM_Gw_current_OS;

    return(OM_S_SUCCESS);
}

method put_dim_attr( struct annot_attr *attr)
{

    me->dual_mode = attr->dual_mode;
    return(OM_S_SUCCESS);
}

method chg_an_dp(IGRint *msg; struct DMsenv_param *par_senv)
{
    IGRint status,rc;
    struct DMenv_param par_env;

    DMsplit_senv(par_senv, &par_env, NULL, NULL);

    status =
    om$send(msg = message DMroot.chgdp(&rc, &par_env),
        targetid = my_id);
    dm$status( action = RET_STATUS);

    return(OM_S_SUCCESS);
}

method get_edit_attr(IGRint an_type;
         struct annot_attr *attr)
{
    attr->dim_type   = me->dim_type;
    attr->geom_type  = me->geom_type;
    attr->display    = me->display;
    attr->dim_state  = me->dim_state;
    attr->leader     = me->leader;
    attr->dual_mode  = me->dual_mode ;
    attr->tol_symbol = me->tol_symbol;
    attr->bln_dir    = me->bln_dir;
    attr->num_brkpt  = 0;
    attr->text_length = 0;

    return(OM_S_SUCCESS);
}

method DMreturn_roots(
    IGRint *count;
    struct GRid list[])
{
    IGRint status, i;
    OM_S_OBJECT_LINKAGE slist[MAX_DIM_ROOTS];
    struct GRmd_env mod_info;
    struct GRid tmp_grid, tmp_grid1;

    status =
    om$get_channel_objects(
        object = me,
        p_chanselect = &ND_father,
        list = slist,
        size = MAX_DIM_ROOTS,
        count = (OMuint *)count);
    dm$status(action = RET_STATUS);

    if (me->geom_type & DIM_IMPORTED)
        (*count)--;

    for (i=0; i < (*count); i++)
    {
        list[i].objid = slist[i].S_objid;
        list[i].osnum = slist[i].osnum;
    }

    if (me->geom_type & DIM_IMPORTED)
    {
        status =
        om$send(msg = message NDnode.ASreturn_go(
                    &tmp_grid,
                    &mod_info.md_env.matrix_type,
                    mod_info.md_env.matrix),
            targetid = list[0].objid,
            targetos = list[0].osnum);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message NDnode.ASreturn_go(
                    &tmp_grid1,
                    &mod_info.md_env.matrix_type,
                    mod_info.md_env.matrix),
            targetid = list[AN_ROOT_ELEM1].objid,
            targetos = list[AN_ROOT_ELEM1].osnum);
        dm$status(action = RET_STATUS);
    }
    else
    {
        tmp_grid  = list[0];
        tmp_grid1 = list[AN_ROOT_ELEM1];
    }

    if ((DMancestry_valid(tmp_grid, OPP_dim_src_class_id))
    &&  (!(DMancestry_valid(tmp_grid1, OPP_dim_src_class_id))))
    {
        for (i=(*count); i > 2; i--)
        {
            list[i].objid = list[i-1].objid;
            list[i].osnum = list[i-1].osnum;
        }

        list[2].objid = list[0].objid;
        list[2].osnum = list[0].osnum;

        (*count)++;
    }

    /*^
        for(i=0; i<*count; i++)
          printf("list[%d]=%d,%d\n",
                i, list[i].objid, list[i].osnum);
    */

    return(OM_S_SUCCESS);
}

method update_parents()
{
    return(OM_S_SUCCESS);
}

end implementation DMannot;
