/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: weld.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:26  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:25  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:55  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/11/01  10:11:59  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.3  1993/09/27  09:34:14  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.2  1993/08/03  11:26:11  laxmi
# COMMENT : taken care of the warnings during complation -Laxmi. 3 aug 1993
#
# Revision 240.1  1993/08/03  05:42:43  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.0  1992/12/06  23:42:06  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:21:47  root
# COMMENT : Corresponds to Rel201.8 in 2.0.1 RCS
#
Revision 201.8  1992/07/20  05:31:05  poo
COMMENT : ANSI compilance, CR 91N0643, and correcting modified fuction calls.

Revision 201.5  1992/02/03  13:01:04  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.2  92/01/22  07:35:37  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.


*/

class implementation DMweld;

#include "dimmod.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "bslininter.h"
#include "bslenvec.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscvcv_int.h"

#define AS_DEBUG	1

from DMsrc	import DMgive_tangent, DMmodify;
from GRlinear	import GRgetpolyline, GRputpolyline;

extern double fabs(), BSdotp();
extern IGRboolean BSproj0(), BSnorvec(), BSmkvec();


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
	struct GRid go_grid[22], null_grid;
	struct DMsenv_param par_senv;
	struct DMplan_info plan_info;
	IGRpoint start_pt, end_pt, pt;
	IGRdouble *vertex;
	struct GRmd_env mod_info;
	BSrc	bsrc;

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
	me->cross_section = FALSE;

	/*"dim_type:%d\n",an_attr->dim_type*/

	num_vertex = an_attr->num_brkpt + 3;

	/*"num_vertex = %d\n", num_vertex*/

	status =
	om$vla_set_dimension(varray = me->break_pt,
		size = 3 * num_vertex);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.get_components(
					TRUE,
					go_grid,
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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
		BSproj1(&bsrc,
			&me->break_pt[3*i],
			&plan_info.win_plan.matrix[8],
			start_pt,
			pt);
		memcpy(&me->break_pt[3*i], pt, sizeof(IGRpoint));
	}

	status =
	om$send(msg = message DMweld.make_weld_text(
					&rc,
					&plan_info,
					&par_senv,
					go_grid,
					&mod_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.make_weld_line(
				&rc,
				&me->break_pt[3*(num_vertex-1)],
				&me->break_pt[3*(num_vertex-2)],
				&par_senv,
				&plan_info,
				go_grid,
				&mod_info),
		targetid = my_id);
	dm$status(action = RET_STAUS);

	status =
	om$vla_set_dimension(varray = me->break_pt, size = 0);
	dm$status(action = RET_STATUS);

	status =
	om$vla_set_dimension(varray = me->vector, size = 0);
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
	IGRint status, rc, num_vertex, last_vtx, curr_vtx;
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRpoint start_pt, end_pt, flag_pt, src_dir;
	IGRdouble *vertex, dotp;
	struct GRid go_grid[22];
	BSrc		bs_rc;

	status =
	om$send( msg = message DMannot.gather_data(
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

	status =
	om$send(msg = message DMweld.get_components(
					FALSE,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.update_weld_line(
					&rc,
					start_pt,
					end_pt,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.place_weld_cs(
					&rc,
					&plan_info,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.make_weld_text(
					&rc,
					&plan_info,
					&par_senv,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.set_weld_text_attr(
					&rc,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
	curr_vtx = (num_vertex - 2)*3;
	last_vtx = (num_vertex - 1)*3;

	/*|- Compute the flag point */

	/*^
		printf("prev_pt = %f,%f,%f\n",me->break_pt[curr_vtx-3],
			me->break_pt[curr_vtx-2],me->break_pt[curr_vtx-1]);
		printf("curr_pt = %f,%f,%f\n",me->break_pt[curr_vtx],
			me->break_pt[curr_vtx+1],me->break_pt[curr_vtx+2]);
	*/

	if( num_vertex > 3)
	{
		/*|- Check if prev segment is parallel to current seg*/

		BSmkvec(&bs_rc,src_dir, &me->break_pt[curr_vtx - 3],&me->break_pt[curr_vtx]);
		BSnorvec(&bs_rc,src_dir);

		/*^ print_point("src_dir", src_dir); */

		dotp = BSdotp(&bs_rc, src_dir, plan_info.win_plan.vec_xpos);

		/*"dotp = %f\n",dotp*/

		if ((fabs(dotp) > DOTP_LOWER_BOUND)
		&&  (fabs(dotp) < DOTP_UPPER_BOUND))
		{
			/*|- Parallel copy prev pt to Flag pt*/

			vec_equal(&me->break_pt[curr_vtx-3], flag_pt);
		}
		else
		{
			/*|- Non_parallel copy curr pt to flag pt */

			vec_equal(&me->break_pt[curr_vtx], flag_pt);
		}
	}
	else
	{
		vec_equal(&me->break_pt[curr_vtx], flag_pt);
	}
	
	/*^ print_point("flag_pt", flag_pt); */

	/*|- Position text */ 

	status =
	om$send(msg = message DMweld.position_weld_text(
						&rc,
						&me->break_pt[curr_vtx],
						end_pt,
						flag_pt,
						go_grid,
						&plan_info,
						&par_senv,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	vertex = &me->break_pt[last_vtx];
	vec_equal(end_pt, vertex);
	
	status =
	om$send(msg = message DMweld.make_weld_line(
				&rc,
				end_pt,
				flag_pt,
				&par_senv,
				&plan_info,
				go_grid,
				md_env),
		targetid = my_id);
	dm$status(action = RET_STAUS);

	status =
	om$send(msg = message DMannot.make_an_term(
					&rc,
					&plan_info,
					&par_senv,
					go_grid[TERM],
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send(msg = message DMannot.chg_an_dp(&rc, &par_senv),
		targetid = my_id);
	dm$status( action = RET_STATUS);

	me->dim_state &=(~DIM_NEEDS_UPDATE);

	status =
	om$vla_set_dimension(varray = me->break_pt, size = 0);
	dm$status(action = RET_STATUS);

	*msg = MSSUCC;

	return(OM_S_SUCCESS);
}

method fill_info( IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRshort src_type;
	IGRlong long_rc;
	struct IGRbsp_curve *bsp_curve;
	struct DMdyn_weld *place_attr;
	IGRdouble end_pt[3];
	IGRint num_parents;
	struct GRid list[MAX_DIM_ROOTS];
	extern struct DMglobal DM_global;
	struct GRmd_env mod_info;

	/* - Gather data     */

	place_attr = (struct DMdyn_weld *)info;

	status =
	om$send(msg = message DMroot.DMreturn_roots(&num_parents, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	status=
	om$send(msg = message DMannot.gather_data(
					&rc,
					num_parents,
					list,
					place_attr->attach_pt,
					end_pt,
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

	if (src_type == POINT_TYPE)
	{
		/*| - Element is point type */

		for(i=0; i<3; i++)
		place_attr->src_dir[i] =
		place_attr->plan_info.act_plan.vec_xpos[i];
	}

	status =
	om$send(msg = message DMweld.get_components(
						TRUE,
						place_attr->go_grid,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
		targetid = place_attr->go_grid[LEAD_LINE].objid,
		targetos = place_attr->go_grid[LEAD_LINE].osnum);
	dm$status(action = RET_STATUS);

	status=
	om$vla_set_dimension(varray = me->break_pt,
			     size  = bsp_curve->num_poles *3);
	dm$status(action = RET_STATUS);

	memcpy( me->break_pt,
		bsp_curve->poles,
		3*sizeof(IGRdouble) * bsp_curve->num_poles);

	vec_equal(place_attr->attach_pt,me->break_pt);

	/*^ print_point("attach point",me->break_pt); */

	status =
	om$send(msg = message DMweld.make_weld_text(
						&rc,
						&place_attr->plan_info,
						&place_attr->par_senv,
						place_attr->go_grid,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMweld.set_weld_text_attr(
					&rc,
					place_attr->go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMannot.make_an_term(
					&rc,
					&place_attr->plan_info,
					&place_attr->par_senv,
					place_attr->go_grid[TERM],
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	place_attr->ter_just = 
	DM_global.term_info[place_attr->par_senv.ter_type].center_just?
				CENTER_CENTER:RIGHT_CENTER;
 
	return(OM_S_SUCCESS);
}

method get_components(
	IGRboolean create;
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, i, rc;

	for (i=0; i<15; i++)
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

	for (i=15; i<18; i++)
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

	return(OM_S_SUCCESS);
}

method make_weld_line(
	IGRint *msg;
	IGRdouble tail_pt[3];
	IGRdouble flag_pt[3];
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, num_vertex;
	IGRlong long_rc, nover, bsrc;
	IGRdouble line[9], src_dir[3], *weld_dir;
	IGRdouble *req_pt,*prev_pt;
	IGRdouble poles[6], knots[4], weights[2];
	IGRdouble poles1[6], knots1[4], weights1[2];
	IGRdouble *xintpt, *xendpt, mdist, dist, nvec[3];
	IGRdouble *xpar1, *xpar2, *xover1, *xover2;
	IGRdouble proj_line[6], sav_vector[7];
	IGRint nint, index, num_pts;
	struct IGRbsp_curve bsp_curve1, *bsp_curve2, line_curve;
	struct GRid arc_grid;

	num_vertex = om$dimension_of(varray = me->break_pt)/3;

	if (me->cross_section)
	{
		/*|- Check if CS ARC is present */

		index = (me->dual_mode)?CS_ARC2:CS_ARC1;

		if (me->cross_section == FILLET_CS) index = CS_ARC1;

		status =
		om$send(msg = message DMroot.return_dim_go(
					&rc,
					index,
					FALSE,
					DM_ARC,
					md_env,
					&arc_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else	arc_grid.objid = NULL_OBJID;

	/*|- If arc present check for intersection */

	if (arc_grid.objid != NULL_OBJID || me->cross_section == FILLET_CS)
	{
		/*^ print_grid("arc_grid", &arc_grid);*/

		prev_pt = &me->break_pt[3];

		BSmkvec(&bsrc, src_dir, me->break_pt, prev_pt);
		BSnorvec(&bsrc, src_dir);

		/*^
			print_point("me->break_pt",me->break_pt);
			print_point("prev_pt",prev_pt);
		*/

		for(index =0; index<3; index++)
		{
			proj_line[index] =
			prev_pt[index] - 10000 * src_dir[index];
			proj_line[index + 3] =
			me->break_pt[index] + 10000 * src_dir[index];
		}

		bsp_curve1.poles = poles;
		bsp_curve1.knots = knots;
		bsp_curve1.weights = weights;

		num_pts = 2;

		/*^ print_line("proj_line", proj_line); */

		status =
		BSlininter(&bsrc, &num_pts, proj_line, &bsp_curve1, nvec);
		if( !status || bsrc != BSSUCC)
		{
			/*"BSlininter fails: rc=%d, status=%d\n", rc, status*/
			return(OM_E_ABORT);
		}

		if (arc_grid.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message GRvg.GRgenabsg(&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						(char **)&bsp_curve2),
				targetid = arc_grid.objid,
				targetos = arc_grid.osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*|- Construct Fillet line segment for intersection*/

			if (BSdotp(&bsrc, me->vector, src_dir) > 0.)
			{
				/*|- Vec1 on same side */

				for (i=0; i<3; i++)
				proj_line[i] = me->break_pt[i] +
					(me->vector[i] * me->slant);
			}
			else
			{
				/*|- Vec1 on opp side */

				for (i=0; i<3; i++)
				proj_line[i] = me->break_pt[i] -
					(me->vector[i] * me->slant);
			}

			if (BSdotp(&bsrc, &me->vector[3], src_dir) > 0.)
			{
				/*|- Vec2 on same side */

				for (i=0; i<3; i++)
				proj_line[i+3] = me->break_pt[i] +
					(me->vector[i+3] * me->slant);
			}
			else
			{
				/*|- Vec2 on opp side */

				for (i=0; i<3; i++)
				proj_line[i+3] = me->break_pt[i] -
					(me->vector[i+3] * me->slant);
			}

			line_curve.poles = poles1;
			line_curve.knots = knots1;
			line_curve.weights = weights1;

			num_pts = 2;

			/*^ print_line("proj_line", proj_line); */

			status =
			BSlininter(&bsrc, &num_pts, proj_line, &line_curve, nvec);
			if( !status || bsrc != BSSUCC)
			{
				/*"BSlininter fails: rc=%d, status=%d\n", rc, status*/
				return(OM_E_ABORT);
			}

			bsp_curve2 = &line_curve;
		}
	
		status =	
		BScvcv_int(
			&bsrc,
			&bsp_curve1,
			bsp_curve2,
			&nint,
			&xintpt,
			&xpar1,
			&xpar2,
			&nover,
			&xendpt,
			&xover1,
			&xover2);
		if( !status || bsrc != BSSUCC)
		{
			/*"BScvcv_int fails: rc=%d, status=%d\n", rc, status*/
			return(OM_E_ABORT);
		}

		/*^ printf("nint = %d\n",nint); */

		if (nint)
		{
			if( nint == 1)
			    req_pt = &xintpt[0];
			else
			{
				index=0;
				mdist = BSdistptpts(&bsrc, prev_pt, xintpt);
				for(i=1; i< nint; i++)
				{
					dist = BSdistptpts(&bsrc,
						prev_pt,
						&xintpt[i*3]);
					if(dist < mdist)
					{
						mdist = dist;
						index = i;
					}
				}
				req_pt = &xintpt[index*3];
			}

			/*^ print_point("req_pt",req_pt); */

			num_pts = om$dimension_of(varray = me->vector);

			/*"vec pts = %d\n", num_pts*/

			memcpy(sav_vector, me->vector,
				(sizeof(IGRdouble)* num_pts));

			num_pts = (me->cross_section == FILLET_CS)?7:4;

			status =
			om$vla_set_dimension(varray = me->vector, size = num_pts);
			dm$status(action = RET_STATUS);

			sav_vector[num_pts-1] = BSdistptpt(&bsrc, me->break_pt, req_pt);

			memcpy(me->vector, sav_vector,
				(sizeof(IGRdouble) * num_pts));

			/*"vec offset = %f\n", me->vector[num_pts -1]*/

			vec_equal(req_pt, me->break_pt);
		}
	}	

	/*^ print_point("me->break_pt",me->break_pt); */

	status =
	om$send(msg = message DMroot.position_line_string(
					msg,
					DIM_NO_INDEX,
					&go_grid[LEAD_LINE],
					md_env,
					num_vertex,
					me->break_pt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->tail)
	{
		/*|- Construct tail line points */

		weld_dir = (me->bln_dir == RIGHT_SIDE)?
				plan_info->win_plan.vec_xpos:
				plan_info->win_plan.vec_xneg;

		for (i=0; i<3; i++)
		    src_dir[i] = tail_pt[i] + (par_senv->txt_widt * weld_dir[i]);
	
		for (i=0; i<3; i++)
		{
			line[i] = src_dir[i] + (par_senv->txt_heig *
				plan_info->win_plan.vec_ypos[i]);
			line[i+3] = tail_pt[i];
			line[i+6] = src_dir[i] + (par_senv->txt_heig *
				plan_info->win_plan.vec_yneg[i]);
		}

		/*^
			print_point("weld_dir", weld_dir);
			for (i=0; i<3; i++)
			printf("tail_pt[%d] = %f,%f,%f\n",
				i, line[i*3],line[i*3+1],line[i*3+2]);
		*/

		status =
		om$send(msg = message DMroot.position_line_string(
						msg,
						DIM_NO_INDEX,
						&go_grid[TAIL_LINE],
						md_env,
						3,
						line),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						TAIL_LINE,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		go_grid[TAIL_LINE].objid = NULL_OBJID;
	}

	if (me->leader)
	{
		/*|- Construct Dash line points */

		weld_dir = (me->leader == ABOVE)?
				plan_info->win_plan.vec_ypos:
				plan_info->win_plan.vec_yneg;

		for (i=0; i<3; i++)
		{
		   line[i] = flag_pt[i] + (0.3 * par_senv->txt_heig * weld_dir[i]);
		   line[i+3] = tail_pt[i] + (0.3 * par_senv->txt_heig * weld_dir[i]);
		}

		/*^
			print_point("weld_dir", weld_dir);
			print_line("dash_line",line);
		*/

		status =
		om$send(msg = message DMroot.position_line_string(
						msg,
						DIM_NO_INDEX,
						&go_grid[DASH_LINE],
						md_env,
						2,
						line),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						DASH_LINE,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		go_grid[DASH_LINE].objid = NULL_OBJID;
	}

	return(OM_S_SUCCESS);
}

method update_weld_line(
	IGRint *msg;
	IGRdouble start_pt[3];
	IGRdouble end_pt[3];
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, index, num_vertex, rc;
	IGRlong long_rc, bsrc;
	IGRdouble *vertex, diff_vec[3];
	struct IGRbsp_curve *bsp_curve;

	status =
	om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(char **)&bsp_curve),
		targetid = go_grid[LEAD_LINE].objid,
		targetos = go_grid[LEAD_LINE].osnum);
	dm$status(action = RET_STATUS);

	num_vertex = bsp_curve->num_poles ;

	status =
	om$vla_set_dimension(varray = me->break_pt,
		size = num_vertex * 3);
	dm$status(action = RET_STATUS);

	memcpy( me->break_pt,
		bsp_curve->poles,
		3*sizeof(IGRdouble) * num_vertex);

	if (me->cross_section)
	{
		/*|- Cross_section present update the start pt*/

		BSmkvec(&bsrc, diff_vec, &me->break_pt[3], me->break_pt);
		BSnorvec(&bsrc, diff_vec);

		index = om$dimension_of(varray = me->vector);

		/*^ print_point("old break_pt",me->break_pt);*/

		/*"vector index = %d\n", index*/

		if ((me->cross_section == FILLET_CS) && (index == 7))
		{
			/*"fillet offset = %f\n", me->vector[6]*/
			for (index=0; index<3; index++)
		    	me->break_pt[index]
			+= me->vector[6] * diff_vec[index];
		}
		else if (index == 4)
		{
			/*"butt offset = %f\n", me->vector[3]*/
			for (index=0; index<3; index++)
			me->break_pt[index]
			+= me->vector[3] * diff_vec[index];
		}
	}

	/*^ print_point("break_pt",me->break_pt);*/

	vec_sub(start_pt, me->break_pt, diff_vec);

	/*^ print_point("def vec",diff_vec);*/

	for (index=0; index<num_vertex; index++)
	{
		vertex = &me->break_pt[index*3];
		vec_add(vertex, diff_vec, vertex);

		/*^
			printf("break_pt[%d] ",index);
			print_point("",vertex);
		*/
	}

	return(OM_S_SUCCESS);
}

method set_weld_text_attr(
	IGRint *msg;
	struct GRid go_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	short font_num;
	struct GRdpb_text_symb text_symb;
	struct DMsenv_param par_senv;
	IGRdouble txt_heig, txt_widt;

	status =
	om$send(msg = message DMannot.get_active_senv(&par_senv),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	DMretrieve_font(&rc, OM_Gw_current_OS, "99", &font_num);
	if (rc != DIM_S_SUCCESS)
	{
		printf("Error retrieving font\n");
		return(FALSE);
	}

	txt_heig = par_senv.txt_heig;
	txt_widt = par_senv.txt_widt;

	text_symb.Active_font    = par_senv.text_font;
	text_symb.Active_just    = -1;
	text_symb.Active_fraction_font = par_senv.frac_font;
	text_symb.Active_charspac= par_senv.car_spac;
	text_symb.Active_linespac= par_senv.lin_spac;

	for (i=0; i<14; i++)
	{
		if (go_grid[i].objid != NULL_OBJID)
		{
			if ((i== SYMBOL1) ||  (i== SYMBOL2))
			{
				/*| Above and Below Symbols */

                                /* scale has been changed to 1.5 from 2.0  3-9-92*/
				text_symb.Active_height = txt_heig * 1.5;
				text_symb.Active_width = txt_widt * 1.5;
				text_symb.Active_font = font_num;
			}
			else if (i == FLAG)
			{
				/*|- Flag Symbol */

				text_symb.Active_height = txt_heig * 3.0;
				text_symb.Active_width = txt_widt * 3.0;
				text_symb.Active_font = font_num;
			}
			else if (i == CIRCLE)
			{
				/*|- Circle Symbol */
				text_symb.Active_font = font_num;
				text_symb.Active_height = txt_heig;
				text_symb.Active_width = txt_widt;
			}
			else if (i == ZSTEXT)
			{
				/*|- Z symbol */

				text_symb.Active_height = txt_heig * 4.0;
				text_symb.Active_width = txt_widt;
				text_symb.Active_font = par_senv.text_font;
			}
			else
			{
				/*|- Normal Text */

				text_symb.Active_height = txt_heig;
				text_symb.Active_width = txt_widt;
				text_symb.Active_font = par_senv.text_font;
			}

			status =
			om$send(msg = message DMroot.chgtextattr(
							&rc,
							DIM_NO_INDEX,
							&go_grid[i],
							md_env,
							&text_symb),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method chg_an_dp(IGRint *msg; struct DMsenv_param *par_senv)
{
	IGRint status, i;
	struct DMenv_param par_env;
	IGRlong long_rc;
	struct IGRdisplay line_display, text_display;
	struct GRid text_grid[20];
	struct GRmd_env md_env;
	IGRshort current_layer;
	IGRint rc;
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
	om$send(msg = message DMweld.get_components(
					FALSE,
					text_grid,
					&md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS)

	for (i=0; i<14; i++)
	{
		if (text_grid[i].objid != NULL_OBJID)
		{
			status =
			om$send(msg = message GRvg.GRchgdp(&long_rc, &text_display),
				targetid = text_grid[i].objid,
				targetos = text_grid[i].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	if (text_grid[DASH_LINE].objid != NULL_OBJID)
	{
		/*|- Set the line style properly */

		line_display.style = 2;

		status =
		om$send(msg = message GRvg.GRchgdp(&long_rc, &line_display),
			targetid = text_grid[DASH_LINE].objid,
			targetos = text_grid[DASH_LINE].osnum);
		dm$status(action = RET_STATUS);

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
	IGRchar ter_type;
	IGRdouble scale;
	struct GRdpb_text_symb	text_symb;
	extern struct DMglobal DM_global;
	BSrc	bs_rc;

	num_vertex = om$dimension_of(varray = me->break_pt)/ 3;

	if (num_vertex < 2)
	{
		status =
		om$send(msg = message DMroot.delete_dim_go(
						&rc,
						TERM,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	BSmkvec(&bs_rc, term_orie, &me->break_pt[3], me->break_pt);
	BSnorvec(&bs_rc, term_orie);
	scale = BSlenvec(&bs_rc, plan_info->win_plan.vec_xpos);
	math_v_scale(term_orie, scale);

	ter_just = DM_global.term_info[par_senv->ter_type].center_just?
				CENTER_CENTER:RIGHT_CENTER;

	ter_type = par_senv->ter_type;

	text_symb.Active_font =
	DMmap_font(OM_Gw_current_OS, DM_global.term_info[ter_type].font_num);
	text_symb.Active_just = -1;
	text_symb.Active_charspac= 1;
	text_symb.Active_linespac= 1;
	text_symb.Active_width  = par_senv->ter_widt_r * par_senv->txt_heig;
	text_symb.Active_height = par_senv->ter_heig_r * par_senv->txt_heig;

	if (ter_type == TER_TYPE_DOT)
	{
		text_symb.Active_width /= 3.0;
		text_symb.Active_height /= 3.0;
	}

	status =
	om$send(msg = message DMroot.chgtextattr(
					&rc,
					DIM_NO_INDEX,
					&term_grid,
					md_env,
					&text_symb),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_NO_INDEX,
				&term_grid,
				md_env,
				1,
		(IGRuchar *)&DM_global.term_info[ter_type].font_char),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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

method 	modify_geom(
	IGRint *msg;
	IGRint control;
	IGRint vertex_no;
	IGRpoint cursor;
	struct GRid *win_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint hilite, i ,count, flag;
	IGRlong long_rc;
	IGRint num_vertex, last_vtx, curr_vtx;
	IGRboolean src_modify, pos_term, src_type;
	struct GRid list[NO_LEADER_ROOTS],go_grid[24];
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;
	IGRdouble *start_pt,*prev_point;
	IGRpoint diff, point, point1, flag_pt;
	struct IGRline bore_line;
	IGRdouble src_dir[3] , *vertex, dotp;
	IGRdouble target_pt[3];
	struct GRmd_env mod_info;

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
	om$send(msg = message DMweld.get_components(
					FALSE,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS)

	src_modify = pos_term = FALSE;

	if ((control & MOVE_TERMINATOR) || (vertex_no == 0))
	{
		/*| - Modify attach element */
		src_modify = TRUE;
	}
	else if ((control & MOVE_POLE) || (control & MOVE_TEXT))
	{
		/*| - Modify one of poles */

		status =
		om$send(msg = message DMweld.update_weld_line(
						&rc,
						point,
						point1,
						go_grid,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		num_vertex = om$dimension_of(varray = me->break_pt)/3;
		last_vtx = 3*(num_vertex -1);
		curr_vtx = 3*(num_vertex -2);

		if (control & MOVE_TEXT)
		{
			/*| - MOVE TEXT - check text intersection */
			vertex_no = curr_vtx;
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

		if( num_vertex > 3)
		{
			/*|- Check if prev segment is parallel to current seg*/
			BSmkvec(&rc, src_dir, target_pt, prev_point);
			BSnorvec(&rc, src_dir);
			dotp = BSdotp(&rc, src_dir, plan_info.win_plan.vec_xpos);
			/*"dotp = %f\n",dotp*/
			if ((fabs(dotp) > DOTP_LOWER_BOUND)
			&&  (fabs(dotp) < DOTP_UPPER_BOUND))
			{
				/*|- Parallel copy prev pt to Flag pt*/
				vec_equal(prev_point, flag_pt);
			}
			else
			{
				/*|- Non_parallel copy curr pt to flag pt */
				vec_equal(target_pt, flag_pt);
			}
		}
		else
		{
			vec_equal(target_pt, flag_pt);
		}
	
		/*^ print_point("flag_pt", flag_pt); */

		if ((vertex_no*3) == curr_vtx)
		{		
			DMget_direction(
				prev_point,
				target_pt,
				plan_info.act_plan.matrix,
				&flag);

			if(flag == AN_BEFORE)
				me->bln_dir = LEFT_SIDE;
			else	me->bln_dir = RIGHT_SIDE;
		}

		status =
		om$send(msg = message DMweld.position_weld_text(
					&rc,
					&me->break_pt[curr_vtx],
					&me->break_pt[last_vtx],
					flag_pt,
					go_grid,
					&plan_info,
					&par_senv,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMweld.make_weld_line(
					&rc,
					&me->break_pt[last_vtx],
					flag_pt,
					&par_senv,
					&plan_info,
					go_grid,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		if(pos_term)
		{
			status =
			om$send(msg = message DMweld.make_an_term(
						&rc,
						&plan_info,
						&par_senv,
						go_grid[TERM],
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


	if(src_modify && (!me->cross_section))
	{
		bore_line.point1 = cursor;
		bore_line.point2 = point;
		
		point[0] = bore_line.point1[0] + plan_info.act_plan.matrix[8];
		point[1] = bore_line.point1[1] + plan_info.act_plan.matrix[9];
		point[2] = bore_line.point1[2] + plan_info.act_plan.matrix[10];

		status =
		om$send(msg = message DMsrc.DMmodify(
						&rc,
						md_env,
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

	*msg = OM_S_SUCCESS;
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
	dim_attr->leader= me->cross_section;
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
					LEAD_LINE,
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

	return(OM_S_SUCCESS);
}

end implementation DMweld;
