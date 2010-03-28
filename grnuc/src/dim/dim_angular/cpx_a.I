/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:29 $
$Locker:  $
$Log: cpx_a.I,v $
Revision 1.1.1.1  2001/12/17 22:39:29  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:06:52  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:20:48  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1994/12/28  08:24:24  sudha
# COMMENT : Purify fixes
#
# Revision 320.0  1994/12/12  17:50:20  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/11/01  10:11:40  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.0  1992/12/06  23:40:47  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:20:43  root
# COMMENT : Corresponds to Rel201.13 in 2.0.1 RCS
#
Revision 201.13  1992/07/20  07:44:14  poo
COMMENT : ANSI compilance, TR 92N1519, TR92N1741, and updating modified fucnction calls.

Revision 201.10  1992/02/12  14:08:43  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Feb 12 '92

*/

class implementation DMangular;

#define AS_DEBUG 1

#include "dimcomplex.h"
#include "bsxln.h"
#include "bsproj1.h"
#include "bsdistptpt.h"

extern GRclassid OPP_DMsrc_class_id;

method get_mea_trak_info(
	struct DMdim_root *cpx_origin_line;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRchar loc_mea_trak;
	struct GRid parent;
	IGRboolean first_in_cpx;
	struct ret_struct retst;

	first_in_cpx = FALSE;
	if( me->dim_type == STRINGED_ANGULAR)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(
						&rc,
						&parent),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (parent.objid == my_id)
		   first_in_cpx = TRUE;
	}
	else
	{
		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						&first_in_cpx,
						&parent),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (!first_in_cpx)
	{
		/*| Not a first dimension*/

		*trak_dist += me->trak_dist;
		/*^ print_grid("parent dimension", &parent); */
		/*"my trak dist:%lf\n",me->trak_dist*/
		/*"my mea_trak :%d\n",me->mea_trak*/

		loc_mea_trak = me->mea_trak;

		status =
		om$send(msg = message DMangular.get_mea_trak_info(
						cpx_origin_line,
						mea_trak,
						trak_dist,
						md_env),
			targetid = parent.objid,
			targetos = parent.osnum);
		dm$status(action = RET_STATUS);

		if (loc_mea_trak & MEAS_START)
			*mea_trak |= MEAS_START;
		else	*mea_trak &= ~MEAS_START;
	}
	else
	{
		/*|first dimension*/

        	status =
		DMnode_give_structure(
			&rc,
			DIM_CPX_ORIG,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&retst);
        	dm$status(action = RET_STATUS);

        	vec_equal(retst.var.line_st.p0,cpx_origin_line->point1);
        	vec_equal(retst.var.line_st.p1,cpx_origin_line->point2);

        	*mea_trak = me->mea_trak;
        	*trak_dist += me->trak_dist;
	}

	/*"mea trak:%d\n",*mea_trak*/
	/*"trak_dist:%lf\n",*trak_dist*/

	return(OM_S_SUCCESS);
}

method give_orig_meas(
	IGRlong *msg;
	IGRint 	count;
	struct GRid *list;
	struct dm_ang_src_st *angle_st;
	struct DMplan_info *plan_info;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env)
{

	IGRint status, rc, index;
	struct ret_struct retst;
	double *orig_end;
	IGRboolean first_in_cpx;
	struct DMtrak_info trak_info;
	IGRpoint cpx_origin;

	*trak_dist = 0;
	*msg = DIM_S_SUCCESS;

	angle_st->arc_radius = 1.0;

	status =
	om$send(msg = message DMangular.get_mea_trak_info(
						&angle_st->cpx_orig_line,
						mea_trak,
						trak_dist,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						plan_info),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMangular.get_cpx_origin(
						&rc,
						cpx_origin,
						plan_info,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[index*4 + 3] =
		plan_info->act_plan.matrix[index*4 + 3] = cpx_origin[index];
	}

	/*"orig dir(2=anti,1=clock):%d\n",*mea_trak*/
	/*"trak dist:%lf\n",*trak_dist*/

	first_in_cpx = 
	!DMancestry_valid(list[DIM_CPX_ORIG], OPP_DMroot_class_id);

	if (me->dim_type == STRINGED_ANGULAR)
	{
		if(!first_in_cpx)
		{
			/* - If not the first dimension in the complex
			     obtain the measurement elem of the previous
			     dimension as your origin  - */

			status =
			DMnode_give_structure(
				&rc,
				DIM_CPX_MEAS,
				MEAS_INFO,
				(me->geom_type & DIM_IMPORTED),
				NULL_OBJID,
				list[DIM_CPX_ORIG].objid,
				list[DIM_CPX_ORIG].osnum,
				md_env,
				&retst);
			dm$status(action = RET_STATUS);

			me->mea_trak &= (~ORIG_START);

			if(!(retst.type & point_generic))
			{
				vec_equal( retst.var.line_st.p0 , angle_st->orig_line.point1);
				vec_equal( retst.var.line_st.p1 , angle_st->orig_line.point2);
			/*^ 
				print_point("origpt1",angle_st->orig_line.point1);
				print_point("origpt1",angle_st->orig_line.point2);
			*/

				status=
				om$send(msg = message DMangular.get_trak_info(&trak_info),
					targetid= list[DIM_CPX_ORIG].objid,
					targetos= list[DIM_CPX_ORIG].osnum);

				if( trak_info.mea_trak & MEAS_START)
					me->mea_trak |= ORIG_START;
			}
			else
			{
				vec_equal(retst.var.point_st.pt,angle_st->orig_line.point2);
				vec_equal(cpx_origin, angle_st->orig_line.point1);
			}
		}
		else
		{
			vec_equal(angle_st->cpx_orig_line.point1,angle_st->orig_line.point1);
			vec_equal(angle_st->cpx_orig_line.point2,angle_st->orig_line.point2);
		}
	}
	else
	{
		vec_equal(angle_st->cpx_orig_line.point1,angle_st->orig_line.point1);
		vec_equal(angle_st->cpx_orig_line.point2,angle_st->orig_line.point2);
	}


	/*"measid:%d\tosnum%d\n",list[DIM_CPX_MEAS].objid,list[DIM_CPX_MEAS].osnum*/

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
		&retst);
	dm$status(action = RET_STATUS);

	if( retst.type & point_generic)
	{
		vec_equal(retst.var.point_st.pt,angle_st->meas_line.point2);
		
		/*"meas is point and first in cpx:%d\n",first_in_cpx*/
		if( first_in_cpx )
		{
			orig_end = ((me->mea_trak&ORIG_START)?
					angle_st->cpx_orig_line.point2:
					angle_st->cpx_orig_line.point1);
			vec_equal( orig_end,angle_st->meas_line.point1);
		}
		else
		{
			
			me->mea_trak &= (~MEAS_START);
			vec_equal(cpx_origin, angle_st->meas_line.point1);
		}
	}
	else
	{
		vec_equal( retst.var.line_st.p0 , angle_st->meas_line.point1);
		vec_equal( retst.var.line_st.p1 , angle_st->meas_line.point2);
	}
	
	return(OM_S_SUCCESS);
}

method give_rel_pos(
	IGRint *msg;
	struct GRid new_dim;
	struct GRid new_meas_id;
	struct GRmd_env *md_env;
	IGRint *rel_pos)
{
	IGRint status,rc;
	IGRlong long_rc, bsrc;
	IGRint count,i;
	struct GRid list[MAX_DIM_ROOTS];
	struct dm_ang_src_st angle_st;
	struct angular_data_st a_info;
	struct DMdim_root new_meas;
	struct DMplan_info plan_info;
	IGRdouble meas_pt[2][3];
	IGRdouble dim_val[2];
	IGRdouble new_meas_orie[3];
	IGRdouble pt_on_plane[3];
	struct ret_struct retst;
	IGRchar mea_trak;
	IGRdouble trak_dist;
	struct DMtrak_info trak_info;

	*msg = DIM_S_SUCCESS;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&count,
					list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status=
	om$send( msg = message DMangular.give_orig_meas(
					&long_rc,
					count,
					list,
					&angle_st,
					&plan_info,
					&mea_trak,
					&trak_dist,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	for ( i=0; i< 3; i++)
	{
		pt_on_plane[i] = plan_info.win_plan.matrix[4*i+3];
		a_info.norm_pl[i] = plan_info.win_plan.matrix[i+8];
	}

	status =
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(new_dim.objid == NULL_OBJID)?FALSE:TRUE,
		new_meas_id.objid,
		new_dim.objid,
		new_meas_id.osnum,
		md_env,
		&retst);
	dm$status(action = RET_STATUS);

	if( retst.type & point_generic)
	{
		vec_equal(retst.var.point_st.pt,new_meas.point2);

		new_meas.point1[0] = plan_info.act_plan.matrix[3];
		new_meas.point1[1] = plan_info.act_plan.matrix[7];
		new_meas.point1[2] = plan_info.act_plan.matrix[11];
	}
	else
	{
		trak_info.mea_trak &= ~MEAS_START;
		
		if (new_dim.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				targetid = new_dim.objid,
				targetos = new_dim.osnum);
			dm$status(action = RET_STATUS);
		}

		if (trak_info.mea_trak & MEAS_START)
		{
			vec_equal( retst.var.line_st.p1 , new_meas.point1);
			vec_equal( retst.var.line_st.p0 , new_meas.point2);
		}
		else
		{
			vec_equal( retst.var.line_st.p0 , new_meas.point1);
			vec_equal( retst.var.line_st.p1 , new_meas.point2);
		}
	}

	/*^
		print_point("meas point1:",new_meas.point1);
		print_point("meas point2:",new_meas.point2);
	*/

	a_info.arc_rad = 1.0;
	
	status =
	om$send( msg = message DMangular.get_dim_sect( &long_rc,
				&angle_st,&a_info,&plan_info,NULL),
			targetid = my_id);
	dm$status( action = RET_STATUS);

	status = BSproj1(&bsrc,new_meas.point1,a_info.norm_pl,
			  pt_on_plane,meas_pt[0]);
	dm$status(action = RET_STATUS);

	status = BSproj1(&bsrc,new_meas.point2,a_info.norm_pl,
			 pt_on_plane,meas_pt[1]);
	dm$status(action = RET_STATUS);

	vec_sub( meas_pt[1],meas_pt[0],new_meas_orie);

	/*^
		print_point("orig_orie:",a_info.orig_ln_orie);
		print_point("meas_pt:",a_info.meas_ln_orie);
		print_point("new measpt:",new_meas_orie);
		print_point("norm_pl:",a_info.norm_pl);
	*/
	
	if( me->mea_trak & CLOCK_WISE)
	{
		MATH_ang_bet_lines(a_info.meas_ln_orie, a_info.orig_ln_orie,
			    &dim_val[0],a_info.norm_pl);
		MATH_ang_bet_lines(new_meas_orie, a_info.orig_ln_orie,
			    &dim_val[1],a_info.norm_pl);
	}
	else
	{
		MATH_ang_bet_lines(a_info.orig_ln_orie, a_info.meas_ln_orie,
			    &dim_val[0],a_info.norm_pl);
		MATH_ang_bet_lines(a_info.orig_ln_orie,new_meas_orie,
			    &dim_val[1],a_info.norm_pl);
	}

	/*"dimval before:%lf \n",dim_val[0]*/
	/*"dimval current:%lf\n",dim_val[1]*/

	if( dim_val[0] > dim_val[1] )
		*rel_pos = CPX_NEAR;
	else    *rel_pos = CPX_FAR;

	return(OM_S_SUCCESS);
}

method fill_info(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct DMdyn_angular *place_attr;
	struct GRid prev;
	IGRboolean last_in_cpx;

	status =
	om$send(msg = message DMangular.fill_buff(
					msg,
					control,
					level,
					info,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	place_attr = (struct DMdyn_angular *)info + (*level);

	status =
	om$send(msg = message DMroot.give_previous(
					&rc,
					&place_attr->first_in_cpx,
					&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*"first in cpx:%d\n", place_attr->first_in_cpx*/

	status =
	om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					place_attr->next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*"last in cpx:%d\n", last_in_cpx*/

	if (place_attr->next[0].objid != NULL_OBJID
	&&  me->dim_type == STRINGED_ANGULAR)
	{
		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_NEEDS_UPDATE),
			targetid = place_attr->next[0].objid,
			targetos = place_attr->next[0].osnum);
		dm$status(action = RET_STATUS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_dimension_origin(
	IGRint *msg;
	struct GRid new_orig;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint cpx_type;
	IGRboolean first_in_cpx;
	struct GRid prev;
	struct GRid my_grid;

	status =
	om$send(msg = message DMroot.give_previous(
					&rc,
					&first_in_cpx,
					&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_complex_type(&cpx_type),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx && (cpx_type == STRINGED_CPX))
	{
		/* - For a STRINGED complex dimension - changing the
		     origin point of measurement for any component
		     except the first one is basically changing the
		     measurement point for the previous dimension. - */

		status =
		om$send(msg = message DMroot.change_dimension_measurement(
							&rc,
							new_orig,
							md_env),
			targetid = prev.objid,
			targetos = prev.osnum);
		dm$status(action = RET_STATUS);

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.change_parent(
					&rc,
					DIM_CPX_ORIG,
					new_orig,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status = DMupdate_complex(&rc,my_grid,md_env);
	dm$status( action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_dimension_measurement(
	IGRint *msg;
	struct GRid new_meas;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid my_grid;

	if (DMancestry_valid(new_meas, OPP_DMsrc_class_id))
	{
		/*"new meas :%d, %d\n",new_meas.objid,new_meas.osnum*/

		status =
		om$send(msg = message DMroot.change_parent(
						&rc,
						DIM_CPX_MEAS,
						new_meas,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		printf("Located object is not of DMsrc class\n");
		return(OM_E_ABORT);
	}

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status=
	DMupdate_complex(&rc,my_grid,md_env);
	dm$status(action= RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_cpx_origin(
	IGRint *msg;
	IGRdouble *origin;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	struct GRid first;
	IGRint status, rc;
	struct ret_struct ret_st;

	if (me->dim_type == SINGLE_ARC_LENGTH
	||  me->dim_type == SINGLE_ARC_ANGLE)
	{
		status =
		DMnode_give_structure(
			&rc,
			DIM_CPX_ORIG,
			ORIG_INFO,
			(me->geom_type & DIM_IMPORTED),
			NULL_OBJID,
			my_id,
			OM_Gw_current_OS,
			md_env,
			&ret_st);
		dm$status(action = RET_STATUS);

		vec_equal(ret_st.var.circle_st.cent_p, origin);

		return(OM_S_SUCCESS);	 
	}

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMangular.give_angle_center(
						&rc,
						origin,
						plan_info,
						md_env),
		targetid = first.objid,
		targetos = first.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method update_src(
	IGRint *msg;
	struct GRid *meas, first;
	struct GRmd_env *md_env)
{
	IGRint status, rc, count;
	struct GRid list[MAX_DIM_ROOTS];
	struct ret_struct ret_st;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	*meas = list[DIM_CPX_MEAS];

	status= 
	DMnode_give_structure(
		&rc,
		DIM_NO_INDEX,
		MEAS_INFO,
		(me->geom_type & DIM_IMPORTED),
		meas->objid,
		my_id,
		meas->osnum,
		md_env,
		&ret_st);
	dm$status(action =RET_STATUS);
		
	if (ret_st.type & point_generic)
	{
		struct GRid src_list[2], context[2], parents[2];
		struct GRvg_construct cnst_lis;
		struct IGRdisplay display;
		extern GRclassid OPP_GR3dpoint_class_id;
		struct IGRpolyline polyline;
		IGRint num_parents;
		IGRlong long_rc, chan_index;
		IGRdouble *pt;
		IGRshort matrix_type;
		IGRmatrix matrix;
		IGRdouble point[6];
		struct DMplan_info plan_info;

		/* If the measure is point type create a point go
		   with non_displayable & non locatable properties
		   make the DMsrc a DM2ptseg type, this needs to be
		   done because the first dimension in angular should
		   have a line seg type of DMsrc (DMaxis,DMkeyseg or
		   DM2ptseg).
		*/

		status =
		dm$get_plan_info(
			plan_objid = list[DIM_ROOT_PLAN].objid,
			osnum = list[DIM_ROOT_PLAN].osnum,
			plan_info = &plan_info,
			md_env = md_env);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMangular.give_angle_center(
						&rc,
						point,
						&plan_info,
						md_env),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		pt = &point[3];
		vec_equal(point, pt);

		cnst_lis.msg = &long_rc;
		cnst_lis.env_info = md_env;
		cnst_lis.newflag = FALSE;
		cnst_lis.properties = 0;
		cnst_lis.display = &display;
		cnst_lis.class_attr = NULL;
		cnst_lis.name = NULL;

		cnst_lis.level = 1;
		display.color = 0;
		display.style = 0;
		display.weight = 0;

		polyline.num_points = 1;
		polyline.points = point;

		cnst_lis.geometry = (char *)&polyline;

		src_list[0].osnum = md_env->md_id.osnum;

		status =
		om$construct(
			classid = OPP_GR3dpoint_class_id,
			msg = message GRgraphics.GRaltconstruct(
						&cnst_lis),
			p_objid = &src_list[0].objid,
			osnum = src_list[0].osnum);
		dm$status();

		context[0].objid = NULL_OBJID;

        	status =
		DMget_parents(*meas, 2, parents, &num_parents);
        	dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&src_list[1],
					&matrix_type,
					matrix),
			targetid = parents[0].objid,
			targetos = parents[0].osnum);
		dm$status(action = RET_STATUS);

		status =
		GRfindcontext(
			&rc,
			&matrix_type,
			matrix,
			&src_list[1].osnum,
			&context[1]);
		if (status != OM_S_SUCCESS || rc != MSSUCC)
			context[1].objid = NULL_OBJID;

		pt = &point[3];

		vec_equal( ret_st.var.point_st.pt,pt);

		/*|- Change The DMsrc type */

		/*^ print_line("point",point); */

		status =
		dm$create_root(
			construct = FALSE,
			type = DM2ptseg,
			count = 2,
			list = src_list,
			context = context,
			attr = point,
			md_env = md_env,
			p_root = meas);
		dm$status(action = RET_STATUS);

		/*| Connect Graphic Object */

		chan_index = 0;

		status =
		om$send(msg = message GRconnector.GRrigidconn(
						&long_rc,
						meas,
						&chan_index),
			targetid = src_list[0].objid,
			targetos = src_list[0].osnum);
		dm$status(action = RET_STATUS);

		me->mea_trak &= ~MEAS_START;

		/*"new_src = %d,%d\n",meas->objid, meas->osnum*/
	}

	*msg = OM_S_SUCCESS;
        return(OM_S_SUCCESS);
}

method give_angle_center(
	IGRint *msg;
	IGRpoint center;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct ret_struct ret_st[2];
	BSrc	bsrc;

	status= 
	DMnode_give_structure(
		&rc,
		DIM_CPX_ORIG,
		ORIG_INFO,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		ret_st);
	dm$status(action =RET_STATUS);
	
	status= 
	DMnode_give_structure(
		&rc,
		DIM_CPX_MEAS,
		MEAS_INFO,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&ret_st[1]);
	dm$status(action =RET_STATUS);
		
	if( ret_st[1].type & point_generic)
	{
		if(me->mea_trak & ORIG_START)
		{
			vec_equal( ret_st[0].var.line_st.p1,center);
		}
		else
		{
			vec_equal( ret_st[0].var.line_st.p0,center);
		}
	}
	else
	{
		DMproject_points(
			&rc,
			ret_st[0].var.line_st.p0,
			ret_st[0].var.line_st.p1,
			ret_st[1].var.line_st.p0,
			ret_st[1].var.line_st.p1,
			&plan_info->act_plan.matrix[8],
			ret_st[0].var.line_st.p0);

		bsrc = BSSUCC;
		status = BSxln( &bsrc,ret_st[0].var.line_st.p0,
				ret_st[0].var.line_st.p1,
				ret_st[1].var.line_st.p0,
				ret_st[1].var.line_st.p1,
				center);

		/*^
			print_point("orig_0", ret_st[0].var.line_st.p0);
			print_point("orig_1", ret_st[0].var.line_st.p1);
			print_point("meas_0", ret_st[1].var.line_st.p0);
			print_point("meas_1", ret_st[1].var.line_st.p1);
			print_point("cpx_orig", center);
		*/

		if (bsrc == BSCOINCIDENT)
		{
			IGRdouble dist1, dist2, mdist1, mdist2;

			/*- The lines are coincident find the
			    common point (or closest pt) and
			    return it as center
			*/

			dist1 = BSdistptpt(&bsrc, ret_st[0].var.line_st.p0,
				ret_st[1].var.line_st.p0);

			dist2 = BSdistptpt(&bsrc, ret_st[0].var.line_st.p0,
				ret_st[1].var.line_st.p1);

			if (dist1 > dist2)
				mdist1 = dist2;
			else	mdist1 = dist1;

			dist1 = BSdistptpt(&bsrc, ret_st[0].var.line_st.p1,
				ret_st[1].var.line_st.p0);

			dist2 = BSdistptpt(&bsrc, ret_st[0].var.line_st.p1,
				ret_st[1].var.line_st.p1);

			if (dist1 > dist2)
				mdist2 = dist2;
			else	mdist2 = dist1;

			if (mdist1 > mdist2)
			{
			   vec_equal( ret_st[0].var.line_st.p1,center);
			}
			else
			{
			   vec_equal( ret_st[0].var.line_st.p0,center);
			}
		}
		else if(bsrc != BSSUCC)
		{
			printf("Intersection error rc:%d\n",rc);
			return(OM_E_ABORT);
		}
	}

	/*"Interpt:%lf|%lf|%lf\n",center[0],center[1],center[2]*/

	return(OM_S_SUCCESS);
}
end implementation DMangular;
