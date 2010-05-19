/* $Id: txbln.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdannot/dim/txbln.I
 *
 * Description:
 *		Correction file for new annotation
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: txbln.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/05/30  14:59:02  pinnacle
# Replaced: vdannot/dim/txbln.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/30/96	adz		second version
 ***************************************************************************/

class implementation DMtxbln;

#define AS_DEBUG 1

from DMsrc import DMgive_tangent;
from GRlinear import GRputpolyline;

#include "dpdef.h"
#include "dimgraph.h"
#include "bsprepcirc.h"
#include "bsnorvec.h"
#include "bslininter.h"
#include "bslenvec.h"
#include "bsdistptpts.h"
#include "bscvcv_int.h"
#include "bsxlnln.h"

%safe
#include "math.h"
static IGRint prev_bln = -1;
%endsafe

#define SPLIT_BLN_INDEX 8  /* Split type blns start after this index */

method fill_info( IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar info[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRshort src_type;
	IGRlong long_rc;
	IGRint count;
	struct DMdyn_annot *place_attr;
	struct IGRbsp_curve *bsp_curve;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRid *line_grid,*term_grid, active_grid;
	struct GRmd_env mod_info;
    struct GRid text_grid;

	/* - Gather data     */

	place_attr = (struct DMdyn_annot *)info;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status=
	om$send(msg = message DMtxbln.gather_data(
						&rc,
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
	if(place_attr->go_grid[AN_ANNOT_TEXT].objid != NULL_OBJID);
	{
		status =
		om$send(msg = message DMannot.set_text_attr(
						&rc,
						place_attr->go_grid[AN_ANNOT_TEXT],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.return_dim_go(
                        &rc,
                        DIM_TEXT2,
                        FALSE,
                        DM_TEXT,
                        md_env,
                        &text_grid),
                targetid = my_id);
        dm$status(action = RET_STATUS);
        if (text_grid.objid != NULL_OBJID)
        {
           status =
                  om$send(msg = message DMannot.set_text_attr(
                                  &rc,
                                  text_grid, 
                                  md_env),
                          targetid = my_id);
           dm$status(action = RET_STATUS);
        }
	}

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

		status=
		om$vla_set_dimension(varray = me->break_pt,
				     size  = bsp_curve->num_poles *3);
		dm$status(action = RET_STATUS);

		memcpy( me->break_pt,
			bsp_curve->poles,
			3*sizeof(IGRdouble) * bsp_curve->num_poles);
		vec_equal(place_attr->attach_pt,me->break_pt);
	}
	else
	{	status =
		om$vla_set_dimension(varray = me->break_pt,
				     size  = 3);
		dm$status(action = RET_STATUS);
		vec_equal(place_attr->attach_pt,me->break_pt);
	}

	place_attr->ele_header.dis_att = NULL;

	status =
	om$send(msg = message DMtxbln.get_active_balloon(
						&rc,
						&active_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^ print_grid("active_grid", &active_grid); */

	status =
	om$send(msg = message DMtxbln.initialise_text(
						&rc,
						md_env,
						place_attr),
			targetid = active_grid.objid,
			targetos = active_grid.osnum);
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
	IGRint status, rc, flag;
	IGRlong long_rc, bsrc, nover;
	struct IGRlbsys *lbs_geom;
	struct IGRbsp_curve bsp_curve1, *bsp_curve2;
	IGRpoint text_orig;
	IGRvector last_elem_dir;
	IGRdouble *req_pt,*prev_pt,*last_pt;
	IGRdouble poles[6], knots[4], weights[2];
	IGRdouble *xintpt, *xendpt, mdist, dist, nvec[3];
	IGRdouble *xpar1, *xpar2, *xover1, *xover2;
	IGRdouble proj_line[6], scale;
	IGRint nint;
	IGRint index,i;
	IGRint num_pts;
	struct GRid text_grid, balloon_grid;


	*num_vertex = om$dimension_of(varray = me->break_pt)/3;

	if(*num_vertex < 2)
		return(OM_S_SUCCESS);

	/*| Get the Text origin */
	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					DIM_TEXT,
					FALSE,
					-1,
					md_env,
					&text_grid),
			targetid = my_id);
	dm$status(action = RET_STATUS);
 
	status=
	om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(char **)&lbs_geom),
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);


	for( index = 0; index<3;index++)
		text_orig[index] = lbs_geom->matrix[3+4*index];

	prev_pt = &me->break_pt[3*(*num_vertex -2)];
	last_pt = &me->break_pt[3*(*num_vertex -1)];

	/*^
		print_point(" text orig",text_orig); 
		printf(" num vertex:%d\n",*num_vertex);
		print_point(" prev pt",prev_pt);
		print_point(" last pt",last_pt);
	*/

	dist = BSdistptpts( &bsrc,prev_pt,last_pt);

	if(fabs(dist) < 1e-8)
		last_pt[0] += 1.0;


	DMget_direction(
		prev_pt,
		last_pt,
		plan_info->act_plan.matrix,
		&flag);

	if(flag == AN_BEFORE)
		me->bln_dir = LEFT_SIDE;
	else	me->bln_dir = RIGHT_SIDE;

	for( index = 0; index<3;index++)
		last_elem_dir[index] = prev_pt[index] - last_pt[index];
	BSnorvec(&bsrc,last_elem_dir);

	/*^
		print_point(" last pt",last_pt);
		print_point(" last elem dir",last_elem_dir);
		printf(" flag = %d, me->bln_dir = %d\n",flag, me->bln_dir);
	*/
/*
	if(par_senv->bln_type == BLN_TYPE_CIRCLE)
	{
		for( index = 0; index<3;index++)
		   last_pt[index] = text_orig[index] + 
				    last_elem_dir[index] * 
				    par_senv->bln_size * 
				    par_senv->txt_heig * 0.5;
	}
	else
*/
	{
		for(index =0; index<3; index++)
		{
			proj_line[index] = 
			prev_pt[index] - 10000000 * last_elem_dir[index];
			proj_line[index + 3] = 
			last_pt[index] + 10000000 * last_elem_dir[index];
		}

		bsp_curve1.poles = poles;
		bsp_curve1.knots = knots;
		bsp_curve1.weights = weights;

		num_pts = 2;

		status =
		BSlininter(&bsrc, &num_pts, proj_line, &bsp_curve1, nvec);
		if( !status || bsrc != BSSUCC)
		{
			/*"BSlininter fails: bsrc=%d, status=%d\n", bsrc, status*/
			return(OM_E_ABORT);
		}

		status = 
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_BALLOON,
						FALSE,
						-1,
						md_env,
						&balloon_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	
		status =
		om$send(msg = message GRvg.GRgenabsg(&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						(char **)&bsp_curve2),
			targetid = balloon_grid.objid,
			targetos = balloon_grid.osnum);
		dm$status(action = RET_STATUS);

 	
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


		if( !status || bsrc != BSSUCC || !nint)
		{
			/*"BScvcv_int fails: bsrc=%d, status=%d\n", bsrc, status*/
			req_pt = &text_orig[0];	
		}
		else
		if( nint == 1)
		{
		    req_pt = &xintpt[0];
		}
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

		for( index= 0; index<3; index++)
		   me->break_pt[3*(*num_vertex-1) + index] = req_pt[index];
	}
	return(OM_S_SUCCESS);
}

method position_balloon(
	IGRint *msg;
	IGRint bln_index;
	struct DMsenv_param *par_senv;
	IGRdouble *centerpt;
	struct GRid *bln_grid;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status, type, rc, numbytes, i, j;
	IGRlong long_rc, bsrc;
	IGRshort create;
	IGRdouble poles[21],weights[7],knots[10];
	IGRdouble *vector, *matrix, rotvec[3], rotvec1[3];
	IGRdouble angle, angle_ex, ang, radius, scale;
	struct IGRbsp_curve *bsp_curve;
	struct IGRpolyline polyline;
	struct GRpost_info post_info;
	GRclassid subclassid;
	extern GRclassid OPP_GR3dcircle_class_id;
	extern GRclassid OPP_GR3dellipse_class_id;
	extern GRclassid OPP_GRconic_class_id;
	IGRdouble bln_size;
	IGRdouble bln_ratio;
	IGRvector unit_normal;
	
	IGRpoint tmppt1,tmppt2;

	/** in the case of a split balloon **/
            struct GRid split_grid;
            IGRpoint pt1,pt2;
            IGRint tmp;

	/** in the case of text only **/
	IGRboolean      action;             /* set or clear */
    IGRshort        properties_mask;    /* toggle locate & display */



	*msg = DIM_S_SUCCESS;

/*	
		print_grid("bln_grid",bln_grid);
		print_point("bln_center",centerpt);

		printf("bln_grid = %d\n",bln_grid->objid);
		printf("bln_index = %d\n",bln_index);
		printf("centerpt = %f %f %f\n",centerpt[0],centerpt[1],centerpt[2]);
		printf("par_senv->bln_size = %lf\n",par_senv->bln_size);
		printf("bln_type = %d\n", par_senv->bln_type);
*/


	bln_ratio = par_senv->bln_size;
	bln_size = bln_ratio * par_senv->txt_heig;
	scale = BSlenvec(&bsrc, plan_info->win_plan.vec_xpos);

    if(par_senv->bln_type < SPLIT_BLN_INDEX)
	{
		/*
		* If this balloon type is not split, delete the split line if it
		* exists.
		*/
		status = om$send(msg = message DMroot.return_dim_go(
							&rc,
							DIM_LINE1,
							FALSE,
							DM_LINE_STR,
							md_env,
							&split_grid),
						targetid = my_id);
		dm$status(action = RET_STATUS);

		if(split_grid.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_LINE1,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	if(bln_grid->objid != NULL_OBJID)
	{
		status =
		om$get_classid(
			osnum = bln_grid->osnum,
			objid = bln_grid->objid,
			p_classid = &subclassid);
		dm$status(action = RET_STATUS);

        create = FALSE;

        switch(par_senv->bln_type)
        {
         case BLN_TYPE_CIRCLE:
         case BLN_TYPE_SPLIT_CIRCLE:
         
		      status = om$is_ancestry_valid( subclassid = subclassid,
			                   superclassid = OPP_GR3dcircle_class_id);
              if(status != OM_S_SUCCESS)
              {
			     status =
			     om$send(msg = message DMroot.delete_dim_go(
							     &rc,
							     DIM_BALLOON, 
                                 md_env),
                         targetid = my_id);
                 dm$status(action = RET_STATUS);

                 create = TRUE;
              }
         break;

         case BLN_TYPE_ELLIPSE:
         case BLN_TYPE_SPLIT_ELLIPSE:

		      status = om$is_ancestry_valid( subclassid = subclassid,
			                   superclassid = OPP_GR3dellipse_class_id);
              if(status != OM_S_SUCCESS)
              {
			     status =
			     om$send(msg = message DMroot.delete_dim_go(
							     &rc,
							     DIM_BALLOON, 
							     md_env),
				         targetid = my_id);
			     dm$status(action = RET_STATUS);

                 create = TRUE;
              }
         break;

         default:
		      status = om$is_ancestry_valid( subclassid = subclassid,
			                   superclassid = OPP_GRconic_class_id);
              if(status == OM_S_SUCCESS)
              {
			     status =
			     om$send(msg = message DMroot.delete_dim_go(
							     &rc,
							     DIM_BALLOON, 
							     md_env),
				         targetid = my_id);
			     dm$status(action = RET_STATUS);

                 create = TRUE;
              }
        }
	}
	else create = TRUE;

    if ((par_senv->bln_type != BLN_TYPE_TWO_LINES_TEXT && 
         par_senv->bln_type != BLN_TYPE_ONE_LINE_TEXT) &&
       (prev_bln == BLN_TYPE_TWO_LINES_TEXT || 
        prev_bln == BLN_TYPE_ONE_LINE_TEXT)) 
    {
        status =
            om$send(msg = message DMroot.delete_dim_go(
                               &rc,
                               DIM_BALLOON,
                               md_env),
                    targetid = my_id);
        dm$status(action = RET_STATUS);

        create = TRUE;
        status = om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_LINE1,
                            FALSE,
                            DM_LINE_STR,
                            md_env,
                            &split_grid),
                        targetid = my_id);
        dm$status(action = RET_STATUS);

        if(split_grid.objid != NULL_OBJID)
        {
            status =
            om$send(msg = message DMroot.delete_dim_go(
                            &rc,
                            DIM_LINE1,
                            md_env),
                targetid = my_id);
            dm$status(action = RET_STATUS);
        }
    }

	/*"create flag:%d\n",create */
	if(create)
	{
		if (par_senv->bln_type == BLN_TYPE_CIRCLE || 
			par_senv->bln_type == BLN_TYPE_ELLIPSE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_CIRCLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_ELLIPSE ||
            par_senv->bln_type == BLN_TYPE_ONE_LINE_TEXT ||
            par_senv->bln_type == BLN_TYPE_TWO_LINES_TEXT)
		{
			type = DM_CIRCLE;
		}
		else
		{
		    type = DM_POLYGON;
		}

		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						bln_index,
						TRUE,
						type,
						md_env,
						bln_grid),
				targetid = my_id);
		dm$status(action = RET_STATUS);

	}
	
	if (par_senv->bln_type == BLN_TYPE_CIRCLE || 
		par_senv->bln_type == BLN_TYPE_SPLIT_CIRCLE || 
		par_senv->bln_type == BLN_TYPE_ONE_LINE_TEXT || 
		par_senv->bln_type == BLN_TYPE_TWO_LINES_TEXT)
	{
		/*| - Balloon type : CIRCLE  or SPLIT_CIRCLE*/

	        status =
        	om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        (char **)&bsp_curve),
	                targetid = bln_grid->objid,
        	        targetos = bln_grid->osnum);
		dm$status( action = RET_STATUS);

		/*  we need to allocate memory for 7 poles, 7 knots
		    and 7 weights to take care of all cases */

		bsp_curve->poles = poles;
		bsp_curve->weights = weights;
		bsp_curve->knots = knots;

		radius = bln_size * 0.5;

		/*^
			print_point("centerpt", centerpt);
			printf("bln_size = %f\n", bln_size);
			printf("radius = %f\n", radius);
		*/

		status =
	       	BSprepcirc(
			&bsrc,
			centerpt,
			&radius,
			&plan_info->win_plan.matrix[8],
			bsp_curve,
			unit_normal,
			&type);
		if(status != OM_S_SUCCESS || bsrc != BSSUCC)
		{
			printf("Position Balloon : BScirrdcr() Fails\n");
			return(OM_E_ABORT);
		}

		/*^
			printf("num poles:%ld\n",bsp_curve->num_poles);
			for( i = 0;i<bsp_curve->num_poles;i++)
				printf("pole[%d]:%lf\n",i,bsp_curve->poles[i]);
		*/

		post_info.construct_flag = FALSE;

		status =
	        om$send(msg = message GRvg.GRpostabsg(&long_rc,
        	                                      md_env,
                	                              &post_info,
                        	                      (char *)bsp_curve,
                                	              &bln_grid->objid),
	                targetid = bln_grid->objid,
        	        targetos = bln_grid->osnum);
		dm$status( action = RET_STATUS);


		if ( par_senv->bln_type == BLN_TYPE_ONE_LINE_TEXT || 
			par_senv->bln_type == BLN_TYPE_TWO_LINES_TEXT)
		{
			action = FALSE;
			properties_mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

			status = om$send (msg = message GRvg.GRchgprops
                            	(&long_rc, &action, &properties_mask),
					   		  targetid = bln_grid->objid,
                       		  targetos = bln_grid->osnum);	
			dm$status( action = RET_STATUS);
		}

		if (par_senv->bln_type == BLN_TYPE_SPLIT_CIRCLE || 
			par_senv->bln_type == BLN_TYPE_TWO_LINES_TEXT)
		{
        	status = om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_LINE1,
                            TRUE,
                            DM_LINE_STR,
                            md_env,
                            &split_grid),
                        targetid = my_id);
        	dm$status(action = RET_STATUS);

			if (split_grid.objid != NULL_OBJID)
            {
                for (i=0;i<3;i++)
                {
                    pt1[i]=centerpt[i] + radius*plan_info->win_plan.matrix[i];
                    pt2[i]=centerpt[i] - radius*plan_info->win_plan.matrix[i];
                }
                status = BSlngen(&bsrc,
                                 pt1,
                                 pt2,
                                 bsp_curve,
                                 &tmp);
 
                if(status != OM_S_SUCCESS || bsrc != BSSUCC)
                {
                    printf("Position Balloon : BSlngen() Fails\n");
                    return(OM_E_ABORT);
                }
                post_info.construct_flag = FALSE;
 
                status =
                    om$send(msg = message GRvg.GRpostabsg(&long_rc,
													md_env,
                                                  &post_info,
                                                  (char *)bsp_curve,
                                                  &split_grid.objid),
                            targetid = split_grid.objid,
                            targetos = split_grid.osnum);
                dm$status( action = RET_STATUS);


				if ( par_senv->bln_type == BLN_TYPE_TWO_LINES_TEXT )
        		{
            		action = FALSE;
            		properties_mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 
            		status = om$send (msg = message GRvg.GRchgprops
                                		(&long_rc, &action, &properties_mask),
                              		  targetid = split_grid.objid,
                              		  targetos = split_grid.osnum); 
            		dm$status( action = RET_STATUS);
        		}
            }
		} 
	}
	else
	  if(par_senv->bln_type == BLN_TYPE_ELLIPSE || 
		par_senv->bln_type == BLN_TYPE_SPLIT_ELLIPSE) 
	  {
		IGRdouble majsemaxis, minsemaxis;
		IGRpoint majpt, minpt;

		/** ("| - Balloon type : ELLIPSE\n"); **/

	        status =
        	om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        (char **)&bsp_curve),
	                targetid = bln_grid->objid,
        	        targetos = bln_grid->osnum);
		dm$status( action = RET_STATUS);

		/*  we need to allocate memory for 7 poles, 10 knots
		    and 7 weights to take care of all cases */

		bsp_curve->poles = poles;
		bsp_curve->weights = weights;
		bsp_curve->knots = knots;

		majsemaxis = bln_ratio * par_senv->txt_heig;
		minsemaxis = 1.5 * par_senv->txt_heig;
			
		tmppt1[0] = plan_info->win_plan.matrix[3];
		tmppt1[1] = plan_info->win_plan.matrix[7];
		tmppt1[2] = plan_info->win_plan.matrix[11];

		BSproj1(&bsrc,centerpt,&plan_info->win_plan.matrix[8],tmppt1,tmppt2);

		for (i=0;i<3;i++)
		{
			majpt[i]=tmppt2[i] + majsemaxis*plan_info->act_plan.matrix[i];
			minpt[i]=tmppt2[i] + minsemaxis*plan_info->act_plan.matrix[i+4];
		}

		status =
	       	BSprepelli(
			&bsrc,
			tmppt2,
			majpt,
			minpt,
			bsp_curve,
			unit_normal, 
			&type);

	
		if(status != OM_S_SUCCESS || bsrc != BSSUCC)
		{
			printf("Position Balloon : BSperpelli() Fails\n");
			printf("BSperpelli() Fails = %d\n",bsrc);
			return(OM_E_ABORT);
		}

		post_info.construct_flag = FALSE;

		status =
	        om$send(msg = message GRvg.GRpostabsg(&long_rc,
        	                                      md_env,
                	                              &post_info,
                        	                      (char *)bsp_curve,
                                	              &bln_grid->objid),
	                targetid = bln_grid->objid,
        	        targetos = bln_grid->osnum);
		dm$status( action = RET_STATUS);

		if (par_senv->bln_type == BLN_TYPE_SPLIT_ELLIPSE)
		{
            status = om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_LINE1,
                            TRUE,
                            DM_LINE_STR,
                            md_env,
                            &split_grid),
                        targetid = my_id);
            dm$status(action = RET_STATUS);
 
            if (split_grid.objid != NULL_OBJID)
            {
                for (i=0;i<3;i++)
                {
					pt1[i]=tmppt2[i] + majsemaxis*plan_info->act_plan.matrix[i];
                    pt2[i]=tmppt2[i] - majsemaxis*plan_info->act_plan.matrix[i];
                }
                status = BSlngen(&bsrc,
                                 pt1,
                                 pt2,
                                 bsp_curve,
								 &tmp);
 
                if(status != OM_S_SUCCESS || bsrc != BSSUCC)
                {
                    printf("Position Balloon : BSlngen() Fails\n");
                    return(OM_E_ABORT);
                }
                post_info.construct_flag = FALSE;
 
                status =
                    om$send(msg = message GRvg.GRpostabsg(&long_rc,
                                                    md_env,
                                                  &post_info,
                                                  (char *)bsp_curve,
                                                  &split_grid.objid),
                            targetid = split_grid.objid,
                            targetos = split_grid.osnum);
                dm$status( action = RET_STATUS);
            }
        }
	}
	else
	{
		/** 
		bln types - triangle,square,polygon,rectangle (split and non-split)
		**/
		IGRint n_sides;

		if (par_senv->bln_type == BLN_TYPE_SQUARE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_SQUARE || 
			par_senv->bln_type == BLN_TYPE_RECTANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE)
		{
			par_senv->num_sides = 4;
		}

		if (par_senv->bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)	
		{
			polyline.num_points = 3 + 1;
		}
		else
		{
			polyline.num_points = par_senv->num_sides + 1;
		}

		numbytes = polyline.num_points * 3 * sizeof(double);
		if((polyline.points = (IGRdouble *) om$malloc(size = numbytes)) == NULL)
		{
			printf("Position Balloon : malloc failed\n");
			return(OM_E_ABORT);
		} 

		if (par_senv->bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)
		{
			angle = (2.0 * PI ) / 3;
		}
		else
		{
			angle = (2.0 * PI ) / par_senv->num_sides;
		}
		angle_ex = -(PI - (( PI - angle)/2.0));

		if (par_senv->bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)
		{
			radius = bln_size * 0.866025;
		}
		else 
		{
			radius = (bln_size / (2.0 * cos(angle / 2.0)));
		}
		/*^
			printf("radius: %lf, bln_size: %lf\n",radius,bln_size);
	 		printf("angle : %lf\n", angle);
			printf("angle_extended : %lf\n",angle_ex);
		*/
	
		vector = plan_info->act_plan.vec_xpos;
		matrix = plan_info->act_plan.matrix;
 
		if (par_senv->bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE)
		{
			MATH_rotate_vector(&rc, vector, angle_ex+PI, matrix, rotvec);
		}
		else
		{
			if ((par_senv->bln_type == BLN_TYPE_POLYGON || 
				par_senv->bln_type == BLN_TYPE_SPLIT_POLYGON) && 
				par_senv->num_sides ==4)  
			{
				MATH_rotate_vector(&rc, vector, angle_ex+(PI/4), matrix, rotvec);
			}
			else
			{
				MATH_rotate_vector(&rc, vector, angle_ex, matrix, rotvec);
			}
		}
				

		/*^
			print_point("vector",vector);
			print_point("center",centerpt);
			print_point("rotvec",rotvec);
		*/

		ang = 0.0;

		if (par_senv->bln_type == BLN_TYPE_RECTANGLE || 
			par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE)   
		{
		  IGRpoint p1,p2,p3,p4,p5;
		  IGRdouble len, wid;

		  len = ((bln_ratio+2)*par_senv->txt_heig);
		  wid = 2*par_senv->txt_heig;
 
		  tmppt1[0] = plan_info->win_plan.matrix[3];
		  tmppt1[1] = plan_info->win_plan.matrix[7];
		  tmppt1[2] = plan_info->win_plan.matrix[11];

		  BSproj1(&bsrc,centerpt,&plan_info->win_plan.matrix[8],tmppt1,tmppt2);
			
		  for (i=0;i<3;i++)
			p1[i] = tmppt2[i] + (len/2)*plan_info->act_plan.matrix[i];

		  if (par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE)
          {
		  	for (i=0;i<3;i++)
				p2[i] = p1[i] + (wid)*plan_info->act_plan.matrix[i+4];
          }
          else
          {
		  	for (i=0;i<3;i++)
				p2[i] = p1[i] + (wid/2)*plan_info->act_plan.matrix[i+4];
		  }

		  for (i=0;i<3;i++)
			p3[i] = p2[i] - (len)*(plan_info->act_plan.matrix[i]);
	
		  if (par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE)
		  {
		  	for (i=0;i<3;i++)
				p4[i] = p3[i] - (2*wid)*(plan_info->act_plan.matrix[i+4]);
		  }
		  else
		  {
		  	for (i=0;i<3;i++)
				p4[i] = p3[i] - (wid)*(plan_info->act_plan.matrix[i+4]);
		  }	
	
		  for (i=0;i<3;i++)
			p5[i] = p4[i] + (len)*(plan_info->act_plan.matrix[i]);

		  polyline.points[0] = p2[0];
		  polyline.points[1] = p2[1];
		  polyline.points[2] = p2[2];

		  polyline.points[3] = p3[0];
		  polyline.points[4] = p3[1];
		  polyline.points[5] = p3[2];

		  polyline.points[6] = p4[0];
		  polyline.points[7] = p4[1];
		  polyline.points[8] = p4[2];

		  polyline.points[9] = p5[0];
		  polyline.points[10] = p5[1];
		  polyline.points[11] = p5[2];

		  polyline.points[12] = p2[0];
		  polyline.points[13] = p2[1];
		  polyline.points[14] = p2[2];
		}
		else
		{
			if (par_senv->bln_type == BLN_TYPE_INV_TRIANGLE || 
				par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE || 
				par_senv->bln_type == BLN_TYPE_TRIANGLE || 
				par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)
			{
				n_sides = 3;
			}
			else
			{	
				n_sides = par_senv->num_sides;
			}

			for(i = 0; i < n_sides + 1; i++)
			{
				MATH_rotate_vector(&rc, rotvec, ang, matrix, rotvec1);
				for(j = 0; j < 3; j++)
				{
					polyline.points[i*3+j] =
					centerpt[j] + (radius * rotvec1[j]);
					rotvec[j] = rotvec1[j];
				}
				ang = angle;
			}
		}

			
		/*^
			for(i = 0; i < par_senv->num_sides+1; i++)
			   printf("polyline[%d] : %lf, %lf, %lf\n",i,
						polyline.points[i*3],
						polyline.points[i*3+1],
						polyline.points[i*3+2]);
		*/


		post_info.construct_flag = FALSE;

		/*| put polyline */

		status =
		om$send(msg = message GRlinear.GRputpolyline(
							&long_rc,
							md_env,
							&post_info,
							&polyline,
							&bln_grid->objid),
			targetid = bln_grid->objid,
			targetos = bln_grid->osnum);
		om$dealloc(ptr = polyline.points);
		dm$status(action = RET_STATUS);

		if (par_senv->bln_type > (SPLIT_BLN_INDEX - 1))
		{
		 	status = om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_LINE1,
                            TRUE,
                            DM_LINE_STR,
                            md_env,
                            &split_grid),
                        targetid = my_id);
           	dm$status(action = RET_STATUS);

			if (split_grid.objid != NULL_OBJID)
           	{
				status =
            		om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        (char **)&bsp_curve),
                    		targetid = bln_grid->objid,
                    		targetos = bln_grid->osnum);
        		dm$status( action = RET_STATUS);
 
        /*  we need to allocate memory for 7 poles, 10 knots
            and 7 weights to take care of all cases */
 
        		bsp_curve->poles = poles;
        		bsp_curve->weights = weights;
        		bsp_curve->knots = knots;

				if (par_senv->bln_type == BLN_TYPE_SPLIT_SQUARE || 
					par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE)
				{
               		for (i=0;i<3;i++)
               		{
                    	pt1[i]=(polyline.points[3+i]+polyline.points[6+i])/2;
                    	pt2[i]=(polyline.points[9+i]+polyline.points[i])/2;

                	}
				}
				if (par_senv->bln_type == BLN_TYPE_SPLIT_POLYGON )
				{
					IGRpoint lpoint[2];
					IGRpoint xpoint[2];
					IGRpoint split_line[2];
					IGRpoint xpt[2];
					IGRint n_xpt;
					IGRdouble par1[2],par2[2];
					IGRint xct = 0,j;

					tmppt1[0] = plan_info->win_plan.matrix[3];
		          	tmppt1[1] = plan_info->win_plan.matrix[7];
          			tmppt1[2] = plan_info->win_plan.matrix[11];

					BSproj1(&bsrc,centerpt,&plan_info->win_plan.matrix[8],tmppt1,tmppt2);
					angle = (2.0 * PI ) / par_senv->num_sides;
					radius = (bln_size / (2.0 * cos(angle / 2.0)));

					for(i=0;i<3;i++)
					{
						pt1[i]=tmppt2[i]+radius*plan_info->act_plan.matrix[i];
						pt2[i]=tmppt2[i]-radius*plan_info->act_plan.matrix[i];
					}
					if (par_senv->num_sides % 2 != 0 || 
   					   (par_senv->num_sides % 4 == 0 && 
					    par_senv->num_sides != 4))
					{
						for (j=0;j<3;j++)
                        {
                            split_line[0][j] = pt1[j];
                            split_line[1][j] = pt2[j];
                        }
						for(i = 0; i < par_senv->num_sides; i++)
						{
							for (j=0;j<3;j++)
                        	{
                            	lpoint[0][j] = polyline.points[i*3+j];
                            	lpoint[1][j] = polyline.points[(i+1)*3+j];
                        	}
							BSxlnln(lpoint,
								    split_line, 
								    &n_xpt,
								    xpt,
								    par1, par2,
								    &bsrc);
							if (n_xpt && bsrc == BSSUCC)
							{
								for (j=0;j<3;j++)
								{
									xpoint[xct][j]  = xpt[0][j];
								}
								xct++;
							}
						}
						for (j=0;j<3;j++)
						{
							pt1[j] = xpoint[0][j];
							pt2[j] = xpoint[1][j];
						}
					}
				}	
				
				if (par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE || 
					par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE)
				{
					IGRdouble side,height,split_len,offset;

					tmppt1[0] = plan_info->win_plan.matrix[3];
                    tmppt1[1] = plan_info->win_plan.matrix[7];
                    tmppt1[2] = plan_info->win_plan.matrix[11];
 
                    BSproj1(&bsrc,centerpt,&plan_info->win_plan.matrix[8],tmppt1,tmppt2);
					radius = bln_size * 0.866025;	
					side = ((3*bln_ratio)/2)*par_senv->txt_heig;
					height = (1.7320508 * side)/2;
					split_len = 2*side /3;
					offset = (side/1.7320508) - radius;
				
					if (par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE)
					{
						for(i=0;i<3;i++)
							tmppt1[i] = tmppt2[i] + offset*plan_info->win_plan.matrix[4+i];
					}
					else
					{
						for(i=0;i<3;i++)
                            tmppt1[i] = tmppt2[i] - offset*plan_info->win_plan.matrix[4+i];
					}

					for(i=0;i<3;i++)
					{
						pt1[i] = tmppt1[i] + (split_len/2)*plan_info->win_plan.matrix[i];
						pt2[i] = tmppt1[i] - (split_len/2)*plan_info->win_plan.matrix[i];
					}	
				}
						
               	status = BSlngen(&bsrc,
                                 pt1,
                                 pt2,
                                 bsp_curve,
                                 &tmp);
 
                if(status != OM_S_SUCCESS || bsrc != BSSUCC)
                {
                    printf("Position Balloon : BSlngen() Fails\n");
                    return(OM_E_ABORT);
                }
                post_info.construct_flag = FALSE;
 
                status =
                    om$send(msg = message GRvg.GRpostabsg(&long_rc,
														md_env,
                                                  &post_info,
                                                  (char *)bsp_curve,
                                                  &split_grid.objid),
                            targetid = split_grid.objid,
                            targetos = split_grid.osnum);
                dm$status( action = RET_STATUS);
            }
		} 
	}

    prev_bln = par_senv->bln_type;
	return(OM_S_SUCCESS);
}

method stack_balloon(
	IGRint *msg;
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRint count;
	struct GRid list[MAX_DIM_ROOTS];
	struct annot_attr attr;


	*msg = OM_S_SUCCESS;

	/*| - Intilaise the ANattr with the instance data */

	attr.dim_type = me->dim_type;
	attr.geom_type = me->geom_type;
	attr.display = me->display;
	attr.dim_state = me->dim_state;
	attr.leader = FALSE;
	attr.num_brkpt = 0;
	attr.brkpt  = NULL;
	attr.text_string = NULL;
	attr.text_length = 0;

	/*| - get the list of roots from previous dimension (my_id) */

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	list[AN_ROOT_ELEM1].objid = my_id;
	list[AN_ROOT_ELEM1].osnum = OM_Gw_current_OS;

	/*^
		printf("count = %d\n",count);
		printf("my_id = %d, %d\n",list[AN_ROOT_ELEM1].objid,
					list[AN_ROOT_ELEM1].osnum);
		printf("plan = %d, %d\n",list[DIM_ROOT_PLAN].objid,
					list[DIM_ROOT_PLAN].osnum);
		printf("senv = %d, %d\n",list[DIM_ROOT_SENV].objid,
					list[DIM_ROOT_SENV].osnum);
	*/
	
	dim_grid->osnum = md_env->md_id.osnum;

	status =
	om$construct(
		classid = OPP_DMtxbln_class_id,
		p_objid = &dim_grid->objid,
		osnum = dim_grid->osnum,
		msg = message DMroot.DMplace(
					&rc,
					count,
					list,
					(char *)&attr,
					md_env));
	dm$status(action = RET_STATUS);

	/*^ printf("dim_grid = %d, %d\n",dim_grid->objid, dim_grid->osnum); */

	status =
	om$send(msg = message NDnode.NDs_compute_node(
						&long_rc,
						0,
						md_env),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_active_balloon(
	IGRint *msg;
	struct GRid *active_grid)
{
	IGRint status, rc;
	IGRboolean last_in_cpx;
	struct GRid next[2];


	/*"me->dim_state=%d\n", me->dim_state*/


	if(me->dim_state & DIM_IN_EDIT)
	{
		/*| - return my id */
		active_grid->objid = my_id;
		active_grid->osnum = OM_Gw_current_OS;
		return(OM_S_SUCCESS);		
	}
	status =
	om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (last_in_cpx)
	{
		/*| - return my id if no active balloon is found - temp */
		active_grid->objid = my_id;
		active_grid->osnum = OM_Gw_current_OS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = OPPmargs,
		targetid = next[0].objid,
		targetos = next[0].osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method give_center_offset(
	IGRint *msg;
	IGRshort flag;
	IGRchar *bln_dir;
	IGRdouble *offset;
	IGRdouble *center;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRdouble angle, angle_ex, ang, dist;
	struct GRid text_grid;
	struct DMsenv_param par_senv;
	struct IGRlbsys *lbsys;


	/*| - Get environment parameters */

	status =
	om$send(msg = message DMannot.get_active_senv(&par_senv),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	if(flag)
	{
		/*| - return_dim_go */

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

		/*^ printf("text_grid = %d, %d\n",text_grid.objid, text_grid.osnum); */

		if(text_grid.objid != NULL_OBJID)
		{
			/*| - get the center from balloon text */

			status =
       			om$send(msg = message GRvg.GRgenabsg(
               		                        &long_rc,
                       		                &md_env->md_env.matrix_type,
                               		        md_env->md_env.matrix,
                                       		(char **)&lbsys),
	        	        targetid = text_grid.objid,
       		        	targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);

			center[0] = lbsys->matrix[3];
			center[1] = lbsys->matrix[7];
			center[2] = lbsys->matrix[11];

			/*^
				printf("long_rc = %d\n",long_rc);
				print_point("center", center);
			*/
		}

		*bln_dir = me->bln_dir;
	}

	if (par_senv.stk_spacing > (par_senv.bln_size + 1))
	{
		if (par_senv.bln_type == BLN_TYPE_ELLIPSE ||
        	par_senv.bln_type == BLN_TYPE_SPLIT_ELLIPSE)
		{
			*offset = par_senv.stk_spacing * par_senv.txt_heig ;
		}
		else
		{
			*offset = par_senv.stk_spacing * par_senv.txt_heig * 0.5;
		}
	}
	else
	{
	if (par_senv.bln_type == BLN_TYPE_CIRCLE ||
		par_senv.bln_type == BLN_TYPE_SPLIT_CIRCLE || 
		par_senv.bln_type == BLN_TYPE_ELLIPSE || 
		par_senv.bln_type == BLN_TYPE_SPLIT_ELLIPSE || 
		par_senv.bln_type == BLN_TYPE_ONE_LINE_TEXT || 
		par_senv.bln_type == BLN_TYPE_TWO_LINES_TEXT)
	{
		/*| - ballon type CIRCLE or ELLIPSE */
		if (par_senv.bln_type == BLN_TYPE_CIRCLE ||
			par_senv.bln_type == BLN_TYPE_SPLIT_CIRCLE || 
			par_senv.bln_type == BLN_TYPE_ONE_LINE_TEXT || 
			par_senv.bln_type == BLN_TYPE_TWO_LINES_TEXT)
		{
			*offset = par_senv.bln_size * par_senv.txt_heig * 0.5;
		}
		else
		{
			if (par_senv.stk_orie == VERT_STK)
                *offset = par_senv.bln_size * par_senv.txt_heig * 0.5 ; 
            else
                *offset = par_senv.bln_size * par_senv.txt_heig ;
		}
		
	}
	else
	{
		/*| - balloon type NOT CIRCLE */

		if (par_senv.bln_type == BLN_TYPE_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_SPLIT_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE)
		{
			angle = (2.0 * PI )/3;
		}
		else
		{
			angle = (2.0 * PI )/ par_senv.num_sides;
		}
		angle_ex = fabs(PI - (( PI - angle)/2.0));

		if (par_senv.bln_type == BLN_TYPE_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_INV_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_SPLIT_TRIANGLE || 
			par_senv.bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE)
		{
			dist = par_senv.bln_size * par_senv.txt_heig * 0.866025;
		}
		else
		{
		 	dist = par_senv.bln_size * par_senv.txt_heig / (2.0 * cos(angle / 2.0));
		}

		if	(par_senv.bln_type == BLN_TYPE_POLYGON || 
			par_senv.bln_type == BLN_TYPE_SPLIT_POLYGON)
		{
			*offset = dist;
		}
		else
		{
			ang = fabs( angle_ex - angle);
			*offset = fabs(dist * cos(ang));
		}

		if	(par_senv.bln_type == BLN_TYPE_RECTANGLE || 				
			par_senv.bln_type == BLN_TYPE_SPLIT_RECTANGLE)
		{
			if (par_senv.stk_orie == VERT_STK)
				*offset = par_senv.txt_heig * 2;
			else 
				*offset = par_senv.txt_heig * 4 ;
		}


		/*^
	 		printf("angle : %lf\n", angle);
			printf("angle_extended : %lf\n",angle_ex);
			printf("dist = %lf\n",dist);
			printf("bln_side = %d\n",par_senv.num_sides);
			printf("offset = %f\n",*offset);
		*/
	}
	}

	return(OM_S_SUCCESS);
}

method get_disp_list(
	IGRint *msg;
	IGRint *count;
	struct GRid *list;
	struct GRmd_env *md_env)
{
	IGRint status, i;

	struct GRid my_grid;


	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	*count = 0;

	status =
	DMget_graph(
		my_grid,
		ROOT | CHILDREN,
		10,
		list,
		count);
	dm$status(action = RET_STATUS);

/*^	
		printf("display_count = %d\n", *count);
		for(i=0; i<*count; i++)
		printf("display_list[%d] = %d, %d\n", i, list[i].objid, list[i].osnum);
*/


	return(OM_S_SUCCESS);
}

method give_bln_center(
	IGRint *msg;
	IGRdouble *text_offset;
	IGRdouble *center;
	struct GRid *prev;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, index;
	IGRdouble offset, prev_offset, my_offset;
	IGRdouble *axis, p_center[3];

	struct DMsenv_param par_senv;

	status =
    om$send(msg = message DMannot.get_active_senv(&par_senv),
            targetid = my_id);
    dm$status(action = RET_STATUS);

 	status =
	om$send(msg = message DMtxbln.give_center_offset(
						&rc,
						TRUE,
						&me->bln_dir,
						&prev_offset,
						p_center,
						md_env),
			targetid = prev->objid,
			targetos = prev->osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMtxbln.give_center_offset(
						&rc,
						FALSE,
						NULL,
						&my_offset,
						NULL,
						md_env),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	offset = prev_offset + my_offset + *text_offset;


	if (par_senv.stk_orie == HORIZ_STK)
	{
		if(me->bln_dir == RIGHT_SIDE && par_senv.stk_dir == DEFAULT_DIR)
        	axis = plan_info->act_plan.vec_xpos;
    	else   
			if(me->bln_dir == RIGHT_SIDE && par_senv.stk_dir == REVERSE_DIR)
			 	axis = plan_info->act_plan.vec_xneg;
			else
				if(par_senv.stk_dir == DEFAULT_DIR)
			 		axis = plan_info->act_plan.vec_xneg;
				else
        			axis = plan_info->act_plan.vec_xpos;
					
	}
	else
	{
		if(me->bln_dir == RIGHT_SIDE && par_senv.stk_dir == DEFAULT_DIR)
        	axis = plan_info->act_plan.vec_ypos;
    	else   
			if(me->bln_dir == RIGHT_SIDE && par_senv.stk_dir == REVERSE_DIR)
			 	axis = plan_info->act_plan.vec_yneg;
			else
				if(par_senv.stk_dir == DEFAULT_DIR)
			 		axis = plan_info->act_plan.vec_yneg;
				else
        			axis = plan_info->act_plan.vec_ypos;
	}


		
	for(index = 0; index < 3; index ++)
		center[index] = p_center[index] + offset * axis[index];

	/*^
		print_point("center", center);
		printf("offset = %f\n", offset);
		print_point("axis", axis);
	*/

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

end implementation DMtxbln; 
