/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: txldr.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:25  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:23  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:53  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/11/03  15:23:08  gvk
# COMMENT : Modified for the support of value type in text_with_leader macro.
#
# Revision 240.2  1993/09/30  10:41:26  samuel
# COMMENT : Fix for TR 119304427
#
# Revision 240.0  1992/12/06  23:41:59  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.1  1992/09/09  14:15:14  scott
# COMMENT : ANSI/SGI fixes
#
# Revision 220.0  1992/08/29  06:21:42  root
# COMMENT : Corresponds to Rel201.16 in 2.0.1 RCS
#
Revision 201.16  1992/08/07  15:40:46  grnuc20
COMMENT : ANSI C conversion fixes

Revision 201.15  1992/07/20  05:31:03  poo
COMMENT : ANSI compilance, CR 91N0643, and correcting modified fuction calls.

Revision 201.9  1992/01/15  17:48:37  allen
COMMENT : Fix syntax error.

Revision 201.8  92/01/13  06:00:42  dimdp20
COMMENT : Dimensioning fixes release  - 13th Jan 92

*/

class implementation DMtxldr;

#define AS_DEBUG 1

#include "dpdef.h"
#include "cotxmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dimerror.h"

extern double fabs();

from DMsrc import DMgive_structure, DMgive_tangent;
from expression import give_formula;
from GRtext import GRreplace_text, GRgettxattr;

method fill_info(
	IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	struct GRid list[MAX_DIM_ROOTS];
	IGRshort src_type;
	IGRint status, rc, num_parents, i;
	IGRlong long_rc;
	IGRpoint origin;
	struct DMdyn_annot *place_attr;
	struct IGRbsp_curve *bsp_curve;
	IGRdouble active_angle = 0.0;
	struct GRid  *line_grid,*term_grid;
	struct GRmd_env mod_info;

	/*| - Gather data     */

	place_attr = (struct DMdyn_annot *)info;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&num_parents, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ printf("num_parents:%d\n",num_parents); */

	status=
	om$send(msg = message DMannot.gather_data(
					&rc,
					num_parents,
					list,
					place_attr->attach_pt,
					NULL,
					&place_attr->plan_info,
					&place_attr->par_senv,
					md_env),
		targetid =my_id);
	dm$status(action=RET_STATUS);

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

	status =
	om$send(msg = message DMsrc.DMgive_tangent(
					&rc,
					&src_type,
					place_attr->src_dir,
					NULL,
					&mod_info),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if ( src_type == POINT_TYPE)
	{
		/*|- Element is point type */

		for(i=0; i<3; i++)
		{
			place_attr->src_dir[i] =
			place_attr->plan_info.act_plan.vec_xpos[i];
		}
	}

 	ANget_disp_par(
		&place_attr->par_senv,
		&place_attr->text_st,
		md_env->md_id.osnum);

	place_attr->text_st.active_display.weight = place_attr->par_senv.txt_weig;

	if( me->leader)
	{
		line_grid = &place_attr->go_grid[AN_POLY_LINE];
		term_grid = &place_attr->go_grid[AN_TER_TEXT];
	}
	else
	{
		line_grid = term_grid = NULL;
	}
	status =
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		p_data = &place_attr->par_misc);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMannot.get_graphics(
					TRUE,
					&place_attr->go_grid[AN_ANNOT_TEXT],
					line_grid,
					term_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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

		/*"num poles:%d\n",bsp_curve->num_poles*/
		status=
		om$vla_set_dimension(varray = me->break_pt,
				     size  = bsp_curve->num_poles *3);
		dm$status(action = RET_STATUS);

		memcpy( me->break_pt,
			bsp_curve->poles,
			3*sizeof(IGRdouble) * bsp_curve->num_poles);
		if( bsp_curve->num_poles ==2)
		{
			vec_equal(place_attr->attach_pt,me->break_pt);
		}
	}
	else
	{	status =
		om$vla_set_dimension(varray = me->break_pt,
				     size  = 3);
		dm$status(action = RET_STATUS);
		vec_equal(place_attr->attach_pt,me->break_pt);
	}

	/*^
		int i;

		for( i = 0 ;i < 3*bsp_curve->num_poles;i++)
			printf("point[%d]:%lf\n",i,me->break_pt[i]);
	*/

	if(!place_attr->text_length)
	{
		DMadd_tolerance_symbol(place_attr->text_string,
			       &place_attr->text_length,
			       &place_attr->gtattr,
				me->dual_mode,
				&place_attr->text_st.estx,me->dim_type);

	}

	DMupdt_disp_chars(place_attr->text_string,
			  &place_attr->text_length,
			  &place_attr->gtattr,
			  me->dual_mode,
			  me->dim_type);
	place_attr->gtattr.disp_char_index = place_attr->gtattr.num_disp_char;
		
	DMget_annot_txt_info(
		&place_attr->plan_info,
		&place_attr->par_senv,
		place_attr->txt_orie,
		&place_attr->plan_info.win_plan.matrix[8],
		&place_attr->txt_just,
		place_attr->src_dir);

	/*|set text justification */
	
	place_attr->text_st.active_symb.Active_just = 
					place_attr->txt_just;

	/*- As in annotations no movements are allowed text length is
	    strlen of text_string*/
	
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

	place_attr->text_st.text_info.estx->text_length=place_attr->text_length;
	place_attr->text_st.text_info.text_string = (char *)place_attr->text_string;

 	/*^
		printf("text string:%ld\n",place_attr->text_string);
		printf("text length:%d\n",place_attr->text_length);
	*/

        dp$build_dis_buffer(
		buffer = &place_attr->ele_header,
                type = IGRLB,
                display_att = &place_attr->text_st.active_display,
                ele_spec_att = &place_attr->text_st.text_info,
                geometry = &place_attr->lbsys_geom);


	/*| create lbsys*/

	origin[0] = origin[1] = origin[2] = 0.0;

	status =
	GRcreate_lbs(&long_rc,
		     &active_angle,
		     md_env->md_env.matrix,
		     origin,
		     &place_attr->text_st.text_extents,
		     place_attr->ele_header.geometry.lbsys);
	dm$status(action=RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_disp_list(
	IGRint *msg;
	IGRint *count;
	struct GRid *list;
	struct GRmd_env *md_env)
{
	IGRint status;

	if(me->leader)
	{
		status =
		om$send(msg = message DMannot.get_graphics(
						FALSE,
						NULL,
						&list[0],/*  poly line  */
						&list[1],/*  terminator */
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if( list[0].objid != NULL_OBJID && list[1].objid != NULL_OBJID)
			*count = 2;
	}
	else
		*count = 0;
	return(OM_S_SUCCESS);
}

method make_an_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid text_grid;
	struct GRmd_env *md_env)
{
	IGRint status, count, vla_size, i;
	IGRshort text_length, disp_name, name_len;
	IGRlong long_rc;
	IGRuchar name[DI_PATH_MAX];
	struct GRid list[MAX_DIM_ROOTS], grid;
	IGRuchar *text_string, *sname;
	struct GRmd_env mod_info;
	IGRdouble conv_factor;

	text_string = sname = NULL;
	disp_name = FALSE;
	name_len = vla_size = text_length = 0;

	if (me->geom_type & DIM_BY_NAME)
	{
		/*|- Display Annotation by Name*/

		status =
		om$get_objid_at_index(
			object = me,
			p_chanselect = &AS_to_owner,
			index = 0,
			objidaddr = &grid.objid,
			osnumaddr = &grid.osnum);
		if (!((status & 1) &&
		DMancestry_valid(grid, OPP_expression_class_id)))
		{
			grid.objid = my_id;
			grid.osnum = OM_Gw_current_OS;
		}

		status =
		di$untranslate(
			objname = (DIchar *)name,
			objid = grid.objid,
			osnum = grid.osnum);
		if (status == DIR_S_SUCCESS)
		{
			sname = &name[strlen((char *)name)-1];
			while ((sname != name) && (*sname != ':'))
				sname--;
			sname++;
			disp_name = TRUE;
			name_len = strlen((char *)sname);
		}
	}

	vla_size = om$dimension_of(varray = me->txexp);

	if (disp_name)
	{
		/*|- Name Found */

		if (vla_size == 0)
		{
			status =
			om$send(msg = message GRtext.GRgettxattr(
						&long_rc,
						NULL,
						&text_length,
						&text_string),
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);

			if (text_length > 0)
			{
				/*|- Save the text in case of driven*/

				status =
				om$vla_set_dimension(varray = me->txexp,
					size = text_length);
				dm$status(action = RET_STATUS);

				memcpy(	me->txexp,
					text_string,
					sizeof(IGRchar) * text_length);
			}
		}

		/*|- Replace Text */

		status =
		om$send(msg = message GRtext.GRreplace_text(
						&long_rc,
						md_env,
						name_len,
						sname),
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/* imported dim, do not get from expression */
/*
		if(me->geom_type & DIM_IMPORTED) vla_size = 0;
Fix for TR 119304427, 11924926 (duplicate */

		status =
		om$send(msg = message DMroot.DMreturn_roots(&count, list),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		if (vla_size && (count > NO_TEXT_LEADER_ROOTS))
		{
			text_string = (IGRuchar *) om$malloc(size = 1024);
			if (text_string == NULL)
			{
				dm$status(sts = OM_E_NODYNMEM, action = RET_STATUS);
			}

			text_length = 1024;

			for (i=NO_TEXT_LEADER_ROOTS; i < count; i++)
			{
				status =
				om$send(msg = message NDnode.ASreturn_go(
						&list[i],
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
					targetid = list[i].objid,
					targetos = list[i].osnum);
				dm$status(action = RET_STATUS);
			}

			/*- Old dimension unit may not be initialised
			    check the unit and if not initilaise to 0
			*/

			if ((par_senv->ter_disp < 0) || (par_senv->ter_disp > 3))
			    par_senv->ter_disp = 0;

			/*|- Get the conversion factor for the dim unit*/

			status =
			DMtxt_conv_fact(0, &conv_factor, par_senv->ter_disp);
			dm$status(action = RET_STATUS);

			if( par_senv->value_type == DIM_ANGLE)
				conv_factor = 1.0;
			/*^
				printf("unit = %d\n", par_senv->ter_disp);
				printf("conv_factor = %f\n", conv_factor);
			*/

			status =
			DMparse_txexpr(
				me->txexp,
				vla_size,
				&list[NO_TEXT_LEADER_ROOTS],
				(count - NO_TEXT_LEADER_ROOTS),
				text_string,
				&text_length,
				conv_factor);
			dm$status(action = RET_STATUS);

			status =
			DMconv_txldr_text(&text_length, &text_string);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message GRtext.GRreplace_text(
						&long_rc,
						md_env,
						text_length,
						text_string),
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);
		}
		else if (vla_size)
		{
			/*|- Put back the save vla*/

			status =
			om$send(msg = message GRtext.GRreplace_text(
						&long_rc,
						md_env,
						vla_size,
						(IGRuchar *)me->txexp),
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);

			om$vla_set_dimension(varray = me->txexp,size = 0);
		}
	}

	status =
	om$send(msg = message DMannot.make_an_text(
					msg,
					plan_info,
					par_senv,
					text_grid,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (text_string) free(text_string);

	return(OM_S_SUCCESS);
}

end implementation DMtxldr;

