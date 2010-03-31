/* ###################   APOGEE COMPILED   ################## */
class implementation ECplhole;

%safe
#include <math.h>
%endsafe
#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "EMSmsgdef.h"
#include "EMSfeadef.h"
#include "EMSsfparms.h"
#include "emserr.h"
#include "bserr.h"
#include "emsdef.h"
#include "bsparameters.h"
#include "maacos.h"
#include "bssfarrevnd.h"
#include "bsdistptpt.h"
#include "EMSbnddef.h"

# define THR_ALL	0
# define THR_NEXT	2
# define BLIND		3

# define OUT_SOLID	0
# define ERR	-1
# define ERR_TOL	0.00001

extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSsubbs	import GRgetsize, GRgetgeom, EMget_unit_norm, GRlnproject;
from GRvg	import GRgetrang;
from EMSsolid	import EMcrvsrfint;
from EMSsurface import EMget_params;

IGRlong	EFcomp_hole_depth(EMmsg, axis_normal, depth_type, hole_depth, axis_dir,
	surfs_info, active_GRid, hole)

IGRlong		*EMmsg;
IGRboolean	*axis_normal;
IGRushort 	*depth_type;
IGRdouble	*hole_depth;
IGRvector 	axis_dir;
struct	GRlc_info	*surfs_info;
struct	GRid		*active_GRid;
struct	EMShole		*hole;

/*
DESCRIPTION:

This method calculates the depth vector and point for the hole.

VARIABLES:

IGRlong	 *EMmsg		Output	Completion code.
IGRboolean *axis_normal Input	normal indicator of hole axis.
IGRshort *depth_type  	Input	hole depth indicator.
IGRdouble  *hole_depth	Input	it can be NULL except thru_until and blind hole.
IGRvector  axis_dir	Input	axis direction of hole.
GRlc_info  *surfs_info	Input	surfaces information.
struct GRid *active_GRid Input	active state solid id.
struct hole_data *hole	I/O	relative information of hole.

History:
    Aditya -  4/29/95	Fixed TR #119423280. This fix evaluates the intersection
                        of the hole axis with the solid to eliminate spurious
                        intersections. Also the abs value of hole axis_line 
                        extension dist is used for non_parallel surface case.

    GMK    -  7/09/93 TR 119307286
                      When using the "thru next" option for cutout, the system
                      is considering the intersecting of reference center with
                      more than two surfaces, not with  two surfaces. This fix
                      is considering two surfaces also.

    Tapadia - 1/16/91 Fixed TR 92n0181 (Support for cylinders when the thru 
		     next surface is a cylinder)
    Tapadia - 4/9/91 Changed from a method to a function & added some code
		     for finite holes 

    BL - 07/28/89    Creation date
    Sudha    6/30/93 Modified for BSprototypes ansification
*/

{
	IGRboolean  world, stat_func, cyl_flag;
	IGRint  point_size, i;
	IGRlong  sts, msg_loc;
	IGRulong  *inter_props;
	IGRdouble  check_dir, *inter_pts, unit_norm[3], cosv, dist[3], d,
           dist_tol;
	IGRpoint better_line[2];
	GRrange   range;
	struct IGRbsp_surface  *surf_geom;
	struct GRparms  *sf_inter_parm, *cv_inter_parm;
	extern IGRdouble tan();
	extern IGRboolean  rlw_get_better_line(), EFisAncestryValid();
	IGRushort type;
	struct EMsurface_params parms;

	*EMmsg = EMS_S_Success;
	point_size = sizeof(IGRpoint);
	surf_geom = NULL;	
	inter_pts = NULL;	
	inter_props = NULL;
	sf_inter_parm = cv_inter_parm = NULL;
	world = TRUE;
	cyl_flag = FALSE;
	BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);

        /*
         * We had a problem when the hole center came in with a
         * value way beyond the design limits. So if any value is
         * that huge get it within the design limit value.
         * -Aditya 07/17/95. Partial fix for TR119423568.
         */
         for( i=0; i<3; i++)
         {
           if(hole->center[i] > GRDGNLIMITS_MAX_D)
                   hole->center[i] = GRDGNLIMITS_MAX_D;
         }

	/* First, calculate the extra extent vector if the axis isn't normal
        to the surface (only for the circular hole) */

	if(!(*axis_normal)) {
		sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
		    	&msg_loc, FALSE, NULL, 
		    	&surfs_info[0].module_info.md_env,
		    	hole->center, unit_norm), 
		    senderid = NULL_OBJID,
		    targetid = surfs_info[0].located_obj.objid,
		    targetos = surfs_info[0].located_obj.osnum);

		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		/* Apply Inner product; both vectors are unit vector */

		cosv = unit_norm[0] * axis_dir[0] + unit_norm[1] * axis_dir[1]
		    + unit_norm[2] * axis_dir[2];
		d = hole->radius * tan(MAacos(&msg_loc, &cosv));

		dist[0] = d * axis_dir[0];
		dist[1] = d * axis_dir[1];
		dist[2] = d * axis_dir[2];

		hole->axis_line[0][0] = hole->center[0] - dist[0];
		hole->axis_line[0][1] = hole->center[1] - dist[1];
		hole->axis_line[0][2] = hole->center[2] - dist[2];

	} /* if axis is not NORMAL to surface */

	if(*depth_type == THR_ALL) {
		IGRdouble  vec[3];
		struct IGRline  line;

		sts = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
		    &surfs_info[0].module_info.md_env.matrix_type, 
		    surfs_info[0].module_info.md_env.matrix, 
		    &world, range),
		    senderid = NULL_OBJID,
		    targetid = active_GRid->objid,
		    targetos = active_GRid->osnum);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		vec[0] = hole->center[0] + axis_dir[0];
		vec[1] = hole->center[1] + axis_dir[1];
		vec[2] = hole->center[2] + axis_dir[2];
		line.point1 = hole->center;
		line.point2 = vec;

		stat_func = rlw_get_better_line(range, &line,better_line,
			&msg_loc);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		vec[0] = better_line[1][0] - better_line[0][0];
		vec[1] = better_line[1][1] - better_line[0][1];
		vec[2] = better_line[1][2] - better_line[0][2];

		/* check the direction of axis vector */
		check_dir = vec[0] * axis_dir[0] + vec[1] * axis_dir[1] +
			vec[2] * axis_dir[2];

		if(check_dir < 0)  {
			OM_BLOCK_MOVE(better_line[0], hole->axis_line[1], 
				point_size);
			OM_BLOCK_MOVE(better_line[1], hole->axis_line[0], 
				point_size);
		}
		else {
	 		OM_BLOCK_MOVE(better_line[1], hole->axis_line[1], 
				point_size);
	 		OM_BLOCK_MOVE(better_line[0], hole->axis_line[0], 
				point_size);
		}

		/* if the axis isn't normal to surface, the bottom centers 
		then need to extend a little bit */
		if(!(*axis_normal)) {
			hole->axis_line[1][0] += dist[0];
			hole->axis_line[1][1] += dist[1];
			hole->axis_line[1][2] += dist[2];
		}
	} /* if THR_ALL*/
	else if(*depth_type == THR_NEXT) {
		IGRlong  num_slots, num_intersect, buf_size, cnt, num_move; 
		IGRdouble  x, y, z, len, knots[4], pts[6], check_cos, poles[6];
		IGRboolean is_succ;
		struct IGRbsp_curve	curve;
		extern void EMsort_by_parameter();

		sts = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
		    	&surfs_info[0].module_info.md_env.matrix_type, 
		    	surfs_info[0].module_info.md_env.matrix, 
		    	&world, range),
		    senderid = NULL_OBJID,
		    targetid = active_GRid->objid,
		    targetos = active_GRid->osnum);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		x = range[3] - range[0];
		y = range[4] - range[1];
		z = range[5] - range[2];
		if(x < y) {
			if(y < z)  len = z;
			else len = y;
		} /* if */
		else {
			if(x < z)  len = z;
			else len = x;
		} /* else */

		/* prevent the curve doesn't intersect with the NEXT surface */

		if(!(*axis_normal)) len *= 1.8; /* because (1+1+1)**(1/2) = 
						1.73...*/

		curve.poles = curve.knots = curve.weights = curve.bdrys = NULL;
		curve.poles = poles;
		curve.knots = knots;
		curve.order = curve.num_poles = 2;
		curve.num_knots = 4;
		curve.knots[0] = curve.knots[1] = 0.0;
		curve.knots[2] = curve.knots[3] = 1.0;
		curve.periodic = curve.rational = curve.phy_closed = FALSE;
		curve.non_uniform = curve.planar = TRUE;
		curve.num_boundaries = 0;
		OM_BLOCK_MOVE(hole->center, curve.poles, point_size);
		curve.poles[3] = hole->center[0] + axis_dir[0] * len;
		curve.poles[4] = hole->center[1] + axis_dir[1] * len;
		curve.poles[5] = hole->center[2] + axis_dir[2] * len;

		num_slots = num_intersect = 0;

		sts = om$send(msg = message EMSsolid.EMcrvsrfint(&msg_loc, 
		    	NULL, &surfs_info[0].module_info.md_env, 
		    	&curve, NULL, NULL, TRUE, &num_slots,
		    	&num_intersect, NULL, &sf_inter_parm,
		    	&cv_inter_parm, &inter_pts, &inter_props), 
		    senderid = NULL_OBJID,
		    targetid = active_GRid->objid,
		    targetos = active_GRid->osnum);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		EMsort_by_parameter(sf_inter_parm, cv_inter_parm, inter_pts,
		    inter_props, num_intersect);

        /* Flag for returning all intersections has been set to TRUE in
         * above crvsfint. If intersection is EMS_L_INHOLE it is discarded.
         * For TR#119423280 - Aditya.
         */

                for (cnt=0; cnt<num_intersect; cnt++)
                {
                  if (inter_props[cnt] == EMS_L_INHOLE)
                  {
                    num_move = num_intersect - cnt - 1;
                    memmove (&sf_inter_parm[cnt], &sf_inter_parm[cnt+1],
                             num_move * sizeof (struct GRparms));
                    memmove (&cv_inter_parm[cnt], &cv_inter_parm[cnt+1],
                             num_move * sizeof (struct GRparms));
                    memmove (&inter_pts[3*cnt], &inter_pts[3*(cnt+1)],
                             num_move * 3 *sizeof (IGRdouble));
                    memmove (&inter_props[cnt], &inter_props[cnt+1], 
                             num_move * sizeof (IGRulong));
                    num_intersect --;
                    cnt --;
                  }
                }

		if(hole->radius) {
		/* Make sure the 'next' surface is NOT at zero distance from
		   the hole center - Fix for TR 119305627 - 4/28/93 - Ashok.
		*/
			for(cnt=1, is_succ=FALSE; cnt<num_intersect; cnt++) {
		          if(BSdistptpt(&msg_loc, hole->center, &inter_pts[3]) <
				        dist_tol) {
			     cv_inter_parm[1].u = MAXINT;
			     EMsort_by_parameter(sf_inter_parm, cv_inter_parm, 
				    inter_pts, inter_props, num_intersect);
			  }
			  else {
			     is_succ = TRUE;
			     break;
			  }
		        } /* for(cnt=1, .... */
			EMerr_hndlr(!(is_succ), *EMmsg, EMS_E_Fail, wrapup);

			/*  Get the next intersect surface's geometry */
			sts = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc, 
			    	&surfs_info[0].module_info.md_env.matrix_type, 
			    	surfs_info[0].module_info.md_env.matrix,
			    	&buf_size),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[1].leaf_id.objid,
			    targetos = sf_inter_parm[1].leaf_id.osnum);
			EMerr_hndlr(!(1&sts&msg_loc),*EMmsg, EMS_E_Fail,wrapup);

			surf_geom = (struct IGRbsp_surface *) om$malloc(size = 
					buf_size);

			sts = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc,
			    	&surfs_info[0].module_info.md_env.matrix_type, 
			    	surfs_info[0].module_info.md_env.matrix, 
			    	(IGRchar *) surf_geom),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[1].leaf_id.objid,
			    targetos = sf_inter_parm[1].leaf_id.osnum);
			EMerr_hndlr(!(1&sts&msg_loc),*EMmsg,EMS_E_Fail,wrapup);

			/* Check if the object is of class EMScylindr */
			if(EFisAncestryValid(EMmsg, 
			    sf_inter_parm[1].leaf_id.objid,
			    sf_inter_parm[1].leaf_id.osnum,
			    OPP_EMScylindr_class_id, FALSE))
				cyl_flag = TRUE;

			EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

			/* get bottom surface's unit normal vector */

			BSsfarrevnd(surf_geom, 1, &sf_inter_parm[1].u, 1, 
			    &sf_inter_parm[1].v, 1.0, NULL, pts, &msg_loc);
			EMerr_hndlr(BSERROR(msg_loc),*EMmsg,EMS_E_BSerror, 
				wrapup);


			/* Use Inner Product to test if top & bottom surfaces' 
			are parallel, for convenient I adjust the vectors to 
			have same direction */

			check_cos = (pts[3]-pts[0]) * axis_dir[0] + (pts[4] -
				pts[1]) * axis_dir[1] + (pts[5] - pts[2]) * 
				axis_dir[2];

			if(surf_geom->pos_orient != OUT_SOLID)  
				check_cos = -check_cos;

			/* if not parallel or axis is not normal to surface */
			if((1-check_cos) > ERR_TOL || !(*axis_normal)) {
			    /* I double the extent for safety */

                /* 
                 * Abs value is used for extension dist 'd'. 
                 * TR#119423280 - Aditya
                 */
			    	d = fabs( 2 * hole->radius * tan(MAacos(&msg_loc, 
					&check_cos)));
			    	hole->axis_line[1][0] = inter_pts[3] + 
					axis_dir[0] * d;
			    	hole->axis_line[1][1] = inter_pts[4] + 
					axis_dir[1] * d;
			    	hole->axis_line[1][2] = inter_pts[5] + 
					axis_dir[2] * d;
			    	hole->axis_line[0][0] -= axis_dir[0] * d;
			    	hole->axis_line[0][1] -= axis_dir[1] * d;
			    	hole->axis_line[0][2] -= axis_dir[2] * d;
			}
			else 
			 	OM_BLOCK_MOVE(&inter_pts[3], hole->axis_line[1],
					 point_size);

			if(cyl_flag) {
			        /* Get the cylinder radius */
			    	sts = om$send(msg = message 
				    EMSsurface.EMget_params(EMmsg,
					NULL, &surfs_info[0].module_info,
					&type, &parms),
				    senderid = NULL_OBJID,
				    targetid = sf_inter_parm[1].leaf_id.objid,
				    targetos = sf_inter_parm[1].leaf_id.osnum);

			        EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail,
					wrapup);

			        hole->axis_line[1][0] += axis_dir[0] * 
					fabs(parms.params.cyl.radius);
			        hole->axis_line[1][1] += axis_dir[1] * 
					fabs(parms.params.cyl.radius);
			        hole->axis_line[1][2] += axis_dir[2] * 
					fabs(parms.params.cyl.radius);
			}
		} /* if circular holes */
		else	/* profile holes */ {
                        /* GMK : TR No. 119307286
                         * If the solid has only two intersect points on its
                         * surfaces ( ex: simple solid with profile on one of
                         * its surfaces ), the following code has to be
                         * included.
                         */
                        if(num_intersect == 2) {

                           /* get the range of second surface */
                           sts = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                 &surfs_info[0].module_info.md_env.matrix_type,
                                 surfs_info[0].module_info.md_env.matrix,
                                 &world, range),
                             senderid = NULL_OBJID,
                             targetid = sf_inter_parm[1].leaf_id.objid,
                             targetos = sf_inter_parm[1].leaf_id.osnum);
                           EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
                           x = range[3] - range[0];
                           y = range[4] - range[1];
                           z = range[5] - range[2];
                           hole->axis_line[1][0] = inter_pts[3] + axis_dir[0]*x;
                           hole->axis_line[1][1] = inter_pts[4] + axis_dir[1]*y;
                           hole->axis_line[1][2] = inter_pts[5] + axis_dir[2]*z;
                        }else
			if(num_intersect > 2) {
				hole->axis_line[1][0] = (inter_pts[3] + 
					inter_pts[6]) / 2.0;
				hole->axis_line[1][1] = (inter_pts[4] + 
					inter_pts[7]) / 2.0;
				hole->axis_line[1][2] = (inter_pts[5] + 
					inter_pts[8]) / 2.0;
			}
		} /* else if profile holes */
	} /* if depth type is THR_NEXT */
	else if(*depth_type == BLIND) {
		hole->axis_line[1][0] = hole->center[0] + *hole_depth * 
			axis_dir[0];
		hole->axis_line[1][1] = hole->center[1] + *hole_depth * 
			axis_dir[1];
		hole->axis_line[1][2] = hole->center[2] + *hole_depth * 
			axis_dir[2];
	}
	if(*axis_normal && *depth_type != THR_ALL)
		OM_BLOCK_MOVE(hole->center, hole->axis_line[0], point_size);


wrapup:
	if(surf_geom)  om$dealloc(ptr = surf_geom);
	if(sf_inter_parm)  om$dealloc(ptr = sf_inter_parm);
	if(cv_inter_parm)  om$dealloc(ptr = cv_inter_parm);
	if(inter_pts)  om$dealloc(ptr = inter_pts);
	if(inter_props)  om$dealloc(ptr = inter_props);

	if(msg_loc != ERR)	return(EMS_S_Success);
	else return(EMS_E_Success);

} /* EFcompute_hole */

/* 

This function is used to compute the hole axis points for a through 
until circular hole 

Tapadia 1/16/91  - Fixed TR 92n0181 (Support for cylinders when the thru. until 
		   surface is a cylinder)
Tapadia 04/29/91 - Creation

*/

IGRlong	EFcomphole_until(EMmsg, axis_normal, axis_dir, surf_info, 
		hole)

IGRlong		*EMmsg;
IGRboolean	*axis_normal;
IGRvector 	axis_dir;
struct	GRlc_info	*surf_info;
struct	EMShole		*hole;
{
	IGRlong  	status, msg_loc;
	extern IGRdouble tan();
	struct GRparms  proj_parms;
	struct IGRline 	line;
	IGRdouble 	pt[3],line_pt[3], dummy,check_len, len, vec_len, 
			surf_pt[3],check_cos, cosv, temp_len;
	IGRboolean cyl_flag = FALSE;
	extern IGRboolean EFisAncestryValid();
	IGRushort type;
	struct EMsurface_params parms;
	IGRboolean is_plane = FALSE;

	*EMmsg = EMS_S_Success;
	pt[0] = hole->center[0] + axis_dir[0];
	pt[1] = hole->center[1] + axis_dir[1];
	pt[2] = hole->center[2] + axis_dir[2];
	line.point1 = hole->center;
	line.point2 = pt;

	if(EFisAncestryValid(&msg_loc, surf_info[0].located_obj.objid,
			surf_info[0].located_obj.osnum, OPP_EMSplane_class_id,
			FALSE)) 
		is_plane = TRUE;

	OM_BLOCK_MOVE(hole->center, line.point1, sizeof(IGRpoint));
	OM_BLOCK_MOVE(pt, line.point2, sizeof(IGRpoint));
	OM_BLOCK_MOVE(hole->center, line_pt, sizeof(IGRpoint));

	status = om$send(msg = message EMSsubbs.GRlnproject(&msg_loc,
			&surf_info[1].module_info.md_env.matrix_type,
			surf_info[1].module_info.md_env.matrix,
			&line, line_pt, surf_pt, &len, &proj_parms),
		senderid = NULL_OBJID,
		targetid = surf_info[1].located_obj.objid,
		targetos = surf_info[1].located_obj.osnum);

	EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

	vec_len = BSdistptpt(&msg_loc, surf_pt, hole->center);


	/* compare the length (vec_len), between project point & base center,
	& the actual length (len) to check if the axis of hole intersect 
	with the exit surface */

	check_len = vec_len - len;
	if(check_len < 0) check_len = -check_len;

	status = om$send(msg = message EMSsubbs.EMget_unit_norm(&msg_loc,
			FALSE, NULL, &surf_info[1].module_info.md_env,
			surf_pt, pt),
		senderid = NULL_OBJID,
		targetid = surf_info[1].located_obj.objid,
		targetos = surf_info[1].located_obj.osnum);

	EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

	/* Use inner product to check the validity */
	check_cos = pt[0] * axis_dir[0] + pt[1] * axis_dir[1] + 
		pt[2] * axis_dir[2];

	/* check if the located surface is valid */
	if(check_len > ERR_TOL || check_cos >= 0 || len < 0) {
		*EMmsg = EMS_E_Fail;
		goto wrapup;
	}
	else  OM_BLOCK_MOVE(surf_pt, hole->axis_line[1], sizeof(IGRpoint));

	if(((check_cos + 1) > ERR_TOL) || !(*axis_normal)){
	    dummy = 0.0 - check_cos;
	    len = hole->radius * tan(MAacos(&msg_loc, &dummy));
	    temp_len = len;
	    hole->axis_line[1][0] += len * axis_dir[0];
	    hole->axis_line[1][1] += len * axis_dir[1];
	    hole->axis_line[1][2] += len * axis_dir[2];

	    if(!(*axis_normal)) {
		status = om$send(msg=message EMSsubbs.EMget_unit_norm(&msg_loc,
				FALSE, NULL, &surf_info[1].module_info.md_env,
				hole->center, pt),
			senderid = NULL_OBJID,
			targetid = surf_info[0].located_obj.objid,
			targetos = surf_info[0].located_obj.osnum);

		EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		cosv = pt[0] * axis_dir[0] + pt[1] * axis_dir[1] + pt[2] *
			axis_dir[2];

		len = 2.0 * hole->radius * tan(MAacos(&msg_loc, &cosv));
		if(len < temp_len && !is_plane)
			len = temp_len;
	
		hole->axis_line[0][0] = hole->center[0] - len * axis_dir[0];
		hole->axis_line[0][1] = hole->center[1] - len * axis_dir[1];
		hole->axis_line[0][2] = hole->center[2] - len * axis_dir[2];
	    }
	}
	/* Check if the object is of class EMScylindr */
	if(EFisAncestryValid(EMmsg, surf_info[1].located_obj.objid,
	    surf_info[1].located_obj.osnum,
	    OPP_EMScylindr_class_id, FALSE))
		cyl_flag = TRUE;

	EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

	if(cyl_flag) {
	    /* Get the cylinder radius */
	    status = om$send(msg = message EMSsurface.EMget_params(EMmsg,
			NULL, &surf_info[0].module_info,
			&type, &parms),
		senderid = NULL_OBJID,
		targetid = surf_info[1].located_obj.objid,
		targetos = surf_info[1].located_obj.osnum);

	    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	    hole->axis_line[1][0] += axis_dir[0] *
	    			fabs(parms.params.cyl.radius);
	    hole->axis_line[1][1] += axis_dir[1] *
	    			fabs(parms.params.cyl.radius);
	    hole->axis_line[1][2] += axis_dir[2] *
	    			fabs(parms.params.cyl.radius);
	}	

	if(*axis_normal) 
		OM_BLOCK_MOVE(hole->center,hole->axis_line[0],sizeof(IGRpoint));

wrapup:
	if(msg_loc != ERR)	return(EMS_S_Success);
	else return(EMS_E_Success);
}

end implementation ECplhole;
