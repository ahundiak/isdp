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
#include "EMSdef.h"
#include "EMSsfparms.h"
#include "emserr.h"
#include "bserr.h"
#include "maacos.h"
#include "bsxlnpl.h"
#include "bssfarrevnd.h"
#include "bsdistptpt.h"

# define THR_ALL	0
# define THR_UNTIL	1
# define THR_NEXT	2
# define BLIND		3

# define OUT_SOLID	0
# define ERR	-1
# define ERR_TOL	0.00001

extern OMuword OPP_EMScylindr_class_id, OPP_EMSdatpln_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSsubbs	import GRgetsize, GRgetgeom, GRlnproject, EMget_unit_norm;
from GRvg	import GRgetrang, GRdetplane;
from EMSsolid	import EMcrvsrfint;
from EMSsurface import EMget_params, EMget_point_on_surface;

IGRlong	EFcomp_hole_depth_ref(EMmsg, axis_normal, depth_type, hole_depth, 
	axis_dir, surfs_info, active_GRid, hole)

IGRlong		*EMmsg;
IGRboolean	*axis_normal;
IGRushort *depth_type;
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

    Tapadia - 07/24/92  Genesis. Computes the hole depth for a hole having
			reference plane as the starting surface. 	 
    Sudha     06/30/93  Modified for BSprototypes ansification

*/

{
	IGRboolean  world, stat_func, cyl_flag;
	IGRint  point_size, int_in;
	IGRlong  sts, msg_loc;
	IGRulong  *inter_props;
	IGRdouble  check_dir, *inter_pts, dist[3], d;
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

	/* First, calculate the extra extent vector if the axis isn't normal
        to the surface (only for the circular hole) */
	/* Apply Inner product; both vectors are unit vector. Need to
	modify this later */

	dist[0] = 0.0;
	dist[1] = 0.0;
	dist[2] = 0.0;

	hole->axis_line[0][0] = hole->center[0] - dist[0];
	hole->axis_line[0][1] = hole->center[1] - dist[1];
	hole->axis_line[0][2] = hole->center[2] - dist[2];

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

		if(check_dir < 0)  
			OM_BLOCK_MOVE(better_line[1], hole->axis_line[0], 
				point_size);
		else 
	 		OM_BLOCK_MOVE(better_line[1], hole->axis_line[1], 
				point_size);

		/* if the axis isn't normal to surface, the bottom centers 
		then need to extend a little bit */
		if(!(*axis_normal)) {
			hole->axis_line[1][0] += dist[0];
			hole->axis_line[1][1] += dist[1];
			hole->axis_line[1][2] += dist[2];
		}
	} /* if THR_ALL*/
	else if(*depth_type == THR_NEXT) {
		IGRlong  num_slots, num_intersect, buf_size;
		IGRdouble  x, y, z, len, knots[4], pts[6], check_cos, poles[6];
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
		    		&curve, NULL, NULL, FALSE, &num_slots,
		    		&num_intersect, NULL, &sf_inter_parm,
		    		&cv_inter_parm, &inter_pts, &inter_props), 
		    	senderid = NULL_OBJID,
		    	targetid = active_GRid->objid,
		    	targetos = active_GRid->osnum);

		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		/* No intersections are present so error out */
		if(num_intersect == 0) {
			*EMmsg = EMS_E_Fail;
			goto wrapup;
		}

		EMsort_by_parameter(sf_inter_parm, cv_inter_parm, inter_pts,
		    inter_props, num_intersect);

		/* may be in case of reference plane - one intersection */
		if(num_intersect == 1)
			int_in = 0;
		else int_in = 1;

		/*  Get the next intersect surface's geometry */
		sts = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc, 
		    		&surfs_info[0].module_info.md_env.matrix_type, 
		    		surfs_info[0].module_info.md_env.matrix,
		    		&buf_size),
		    	senderid = NULL_OBJID,
			targetid = sf_inter_parm[int_in].leaf_id.objid,
			targetos = sf_inter_parm[int_in].leaf_id.osnum);
		EMerr_hndlr(!(1&sts&msg_loc),*EMmsg, EMS_E_Fail,wrapup);

		surf_geom = (struct IGRbsp_surface *) om$malloc(size = 
			buf_size);

		sts = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc, 
			    	&surfs_info[0].module_info.md_env.matrix_type, 
			    	surfs_info[0].module_info.md_env.matrix, 
			    	(IGRchar *) surf_geom),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[int_in].leaf_id.objid,
			targetos = sf_inter_parm[int_in].leaf_id.osnum);
		EMerr_hndlr(!(1&sts&msg_loc),*EMmsg,EMS_E_Fail,wrapup);

		/* Check if the object is of class EMScylindr */
		if(EFisAncestryValid(EMmsg, sf_inter_parm[int_in].leaf_id.objid,
			sf_inter_parm[int_in].leaf_id.osnum, 
			OPP_EMScylindr_class_id, FALSE))
		    cyl_flag = TRUE;

		EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

		/* get bottom surface's unit normal vector */

		BSsfarrevnd(surf_geom, 1, &sf_inter_parm[int_in].u, 1, 
		    	&sf_inter_parm[int_in].v, 1.0, NULL, pts, &msg_loc);
		EMerr_hndlr(BSERROR(msg_loc),*EMmsg,EMS_E_BSerror, wrapup);

		/* Use Inner Product to test if top & bottom surfaces' 
		are parallel, for convenient I adjust the vectors to 
		have same direction */

		check_cos = (pts[3]-pts[0]) * axis_dir[0] + (pts[4] -
			pts[1]) * axis_dir[1] + (pts[5] - pts[2]) * axis_dir[2];

		if(surf_geom->pos_orient != OUT_SOLID)  
			check_cos = -check_cos;

		/* if not parallel or axis is not normal to surface */
		if((1-check_cos) > ERR_TOL || !(*axis_normal)) {
		    /* I double the extent for safety */
		    	d = 2 * hole->radius * tan(MAacos(&msg_loc,&check_cos));
			hole->axis_line[1][0] = inter_pts[3 * int_in] + 
				axis_dir[0] * d;
			hole->axis_line[1][1] = inter_pts[3 * int_in + 1] + 
				axis_dir[1] * d;
			hole->axis_line[1][2] = inter_pts[3 * int_in + 2] + 
				axis_dir[2] * d;
			hole->axis_line[0][0] -= axis_dir[0] * d;
			hole->axis_line[0][1] -= axis_dir[1] * d;
			hole->axis_line[0][2] -= axis_dir[2] * d;
		}
		else 
		 	OM_BLOCK_MOVE(&inter_pts[3*int_in], hole->axis_line[1],
				 point_size);

		if(cyl_flag) {
		        /* Get the cylinder radius */
		    	sts = om$send(msg = message EMSsurface.EMget_params(
					EMmsg,
					NULL, &surfs_info[0].module_info,
					&type, &parms),
			 	senderid = NULL_OBJID,
			   	targetid = sf_inter_parm[int_in].leaf_id.objid,
			    	targetos = sf_inter_parm[int_in].leaf_id.osnum);

		      	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail,
				wrapup);

		        hole->axis_line[1][0] += axis_dir[0] * 
				fabs(parms.params.cyl.radius);

		        hole->axis_line[1][1] += axis_dir[1] * 
					fabs(parms.params.cyl.radius);
		        hole->axis_line[1][2] += axis_dir[2] * 
					fabs(parms.params.cyl.radius);
		}
	} /* if depth type is THR_NEXT or THR_UNTIL */
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
This function is used to compute the hole axis points for a through until 
circular hole having referance plane as the starting surface. The end surface 
could also be a reference plane

Tapadia 07/27/92 - Genesis
*/

IGRlong	EFcomphole_until_ref(EMmsg, axis_normal, axis_dir, surf_info, 
		hole)

IGRlong		*EMmsg;
IGRboolean	*axis_normal;
IGRvector 	axis_dir;
struct	GRlc_info	*surf_info;
struct	EMShole		*hole;
{
	IGRlong  	status, msg_loc;
	struct GRparms  proj_parms;
	IGRpoint 	new_pt, st_from_pt, temp_pt, int_pt;
	struct IGRline 	line;
	IGRdouble 	pt[3],line_pt[3], len, vec_len, surf_pt[3], new_len, 
			check_cos, dummy, end_plane_pt[3], end_plane_nor[3];
	IGRushort 	type;
	IGRboolean 	start_ref, end_ref, cyl_flag = FALSE;
	struct IGRplane end_plane;
	struct EMparms 	st_surf_parms;
	IGRboolean 	is_plane, extend;
	extern IGRdouble tan();
	struct EMsurface_params parms;
	extern IGRboolean EFisAncestryValid();

	*EMmsg = EMS_S_Success;
	start_ref = end_ref = is_plane = FALSE;
	extend = TRUE;

	/* TO check if the start & end surface are reference planes */
	if(EFisAncestryValid(&msg_loc, surf_info[0].located_obj.objid,
		surf_info[0].located_obj.osnum, OPP_EMSdatpln_class_id,
		FALSE))
	    start_ref = TRUE;

	if(EFisAncestryValid(&msg_loc, surf_info[1].located_obj.objid,
		surf_info[1].located_obj.osnum, OPP_EMSdatpln_class_id,
		FALSE)) {
	    end_ref = TRUE;
	}

	/* check if the end surface is of class plane */
	if(EFisAncestryValid(&msg_loc, surf_info[1].located_obj.objid,
			surf_info[1].located_obj.osnum, OPP_EMSplane_class_id,
			FALSE)) 
		is_plane = TRUE;

	pt[0] = hole->center[0] + axis_dir[0];
	pt[1] = hole->center[1] + axis_dir[1];
	pt[2] = hole->center[2] + axis_dir[2];
	line.point1 = hole->center;
	line.point2 = pt;

	OM_BLOCK_MOVE(hole->center, line.point1, sizeof(IGRpoint));
	OM_BLOCK_MOVE(pt, line.point2, sizeof(IGRpoint));
	OM_BLOCK_MOVE(hole->center, line_pt, sizeof(IGRpoint));

	/* Get the point & normal of the reference plane */
	if(end_ref) {
		end_plane.point = end_plane_pt;
		end_plane.normal = end_plane_nor;

		status = om$send(msg = message GRvg.GRdetplane(&msg_loc,
				&surf_info[1].module_info.md_env.matrix_type,
				surf_info[1].module_info.md_env.matrix,
				&end_plane),
	    		senderid = NULL_OBJID,
			targetid = surf_info[1].located_obj.objid,
			targetos = surf_info[1].located_obj.osnum);

	    	EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		BSxlnpl(&msg_loc, end_plane.normal, end_plane.point,
			pt, line_pt, int_pt);

		if(msg_loc != BSSUCC) {
			*EMmsg = MSFAIL;
			goto wrapup;
		}

		OM_BLOCK_MOVE(int_pt, surf_pt, sizeof(IGRpoint));
	}
	else { /* surface */
	    /* first try to project the start point onto the exit surface */
	    status = om$send(msg = message EMSsubbs.GRlnproject(&msg_loc,
				&surf_info[1].module_info.md_env.matrix_type,
				surf_info[1].module_info.md_env.matrix,
				&line, line_pt, surf_pt, &len, &proj_parms),
			senderid = NULL_OBJID,
			targetid = surf_info[1].located_obj.objid,
			targetos = surf_info[1].located_obj.osnum);

	    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
	    /* if the exit surface is planar compute the intersection point 
	    between the infinite plane & infinite line. Check if the earlier 
	    projected point and this point are same. If they are not same
	    use the intersection point as the projected point */
	    if(is_plane) {
		status = om$send(msg = message 
			    	EMSsurface.EMget_point_on_surface(
				EMmsg, &surf_info[1].module_info, 0, 1,
				st_from_pt, &st_surf_parms),
			senderid = NULL_OBJID,
			targetid = surf_info[1].located_obj.objid,
			targetos = surf_info[1].located_obj.osnum);

     		EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		BSxlnpl(&msg_loc, st_surf_parms.normal, st_from_pt,
			pt, line_pt, int_pt);
		
		if(msg_loc != BSSUCC) {
			*EMmsg = MSFAIL;
			goto wrapup;
		}

		vec_len = BSdistptpt(&msg_loc, surf_pt, int_pt);
		if(vec_len > ERR_TOL) {
		    OM_BLOCK_MOVE(int_pt, surf_pt, sizeof(IGRpoint));
		    extend = FALSE;
		}
	    }
	}
	OM_BLOCK_MOVE(hole->center, hole->axis_line[0], sizeof(IGRpoint));
	vec_len = BSdistptpt(&msg_loc, surf_pt, hole->center);
	if(vec_len < ERR_TOL) {
		*EMmsg = EMS_E_Fail;
		goto wrapup;
	}
	/* this check is made to check that the surface is not in the
	other direction of the hole axis */
	new_pt[0] = hole->center[0] + vec_len * axis_dir[0];
	new_pt[1] = hole->center[1] + vec_len * axis_dir[1];
	new_pt[2] = hole->center[2] + vec_len * axis_dir[2];
	new_len = BSdistptpt(&msg_loc, surf_pt, new_pt);

	if(new_len > ERR_TOL) {
		*EMmsg = EMS_E_Fail;
		goto wrapup;
	}

	/* for a surface */
	if(!end_ref) {
	    if(!extend) {
		OM_BLOCK_MOVE(surf_pt, temp_pt, sizeof(IGRpoint));
		OM_BLOCK_MOVE(st_from_pt, surf_pt, sizeof(IGRpoint));
	    }
	    status = om$send(msg = message EMSsubbs.EMget_unit_norm(&msg_loc,
			FALSE, NULL, &surf_info[1].module_info.md_env,
			surf_pt, pt),
		senderid = NULL_OBJID,
		targetid = surf_info[1].located_obj.objid,
		targetos = surf_info[1].located_obj.osnum);

	    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
	    if(!extend) 
		OM_BLOCK_MOVE(temp_pt, surf_pt, sizeof(IGRpoint));
        }

	/* this calculation is done to extend the surface if needed */
  	if(!end_ref && extend) {
	    /* Use inner product to check the validity */
	    check_cos = pt[0] * axis_dir[0] + pt[1] * axis_dir[1] + pt[2] * 
			axis_dir[2];

	    /* check if the located surface is valid */
	    if(check_cos >= 0) {
		*EMmsg = EMS_E_Fail;
		goto wrapup;
	    }
	    else  OM_BLOCK_MOVE(surf_pt, hole->axis_line[1], sizeof(IGRpoint));

	    if(((check_cos + 1) > ERR_TOL) || !(*axis_normal)){
	    	dummy = 0.0 - check_cos;
	    	len =  hole->radius * tan(MAacos(&msg_loc, &dummy));
	    	hole->axis_line[1][0] += len * axis_dir[0];
	    	hole->axis_line[1][1] += len * axis_dir[1];
	    	hole->axis_line[1][2] += len * axis_dir[2];

	        if(!(*axis_normal)) {
		    len = hole->radius * tan(MAacos(&msg_loc, &check_cos));
		    hole->axis_line[0][0] = hole->center[0] - len * axis_dir[0];
		    hole->axis_line[0][1] = hole->center[1] - len * axis_dir[1];
		    hole->axis_line[0][2] = hole->center[2] - len * axis_dir[2];
	        }
	    }
	}
	else  OM_BLOCK_MOVE(surf_pt, hole->axis_line[1], sizeof(IGRpoint));

	/* Check if the object is of class EMScylindr only if the exit surface
	is not a reference plane */
	if(!end_ref) {
	    if(EFisAncestryValid(EMmsg, surf_info[1].located_obj.objid,
	    	surf_info[1].located_obj.osnum, OPP_EMScylindr_class_id, FALSE))
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
	}
wrapup:
	if(msg_loc != ERR)	return(EMS_S_Success);
	else return(EMS_E_Success);
}

end implementation ECplhole;
