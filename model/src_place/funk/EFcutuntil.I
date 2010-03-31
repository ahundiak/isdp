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
#include "EMSconstruct.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"

#define ERR	-1

from EMSsubbs	import EMget_unit_norm;
from GRvg	import GRgetrang;
from EMSsolid	import EMcrvsrfint, EMpoint_locate;

IGRlong	EFcomp_cut_until(EMmsg, axis_normal, depth_type, hole_depth, axis_dir,
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
Description:

This method calculates the depth vector and point for thru until cutout

Variables:

IGRlong	 *EMmsg		Output	Completion code.
IGRboolean *axis_normal Input	normal indicator of hole axis.
IGRshort *depth_type  	Input	hole depth indicator.
IGRdouble  *hole_depth	Input	it can be NULL except thru_until and blind hole.
IGRvector  axis_dir	Input	axis direction of hole.
GRlc_info  *surfs_info	Input	surfaces information.
struct GRid *active_GRid Input	active state solid id.
struct hole_data *hole	I/O	relative information of hole.

History:

    Tapadia - 09/28/92 	Genesis

    Sudha     06/30/93  Modified for BSprototypes ansification
*/

{
	IGRboolean  	world, stat_func, not_done;
	IGRint  	point_size, n;
	IGRlong  	sts, msg_loc, num_slots, num_intersect;
	IGRulong  	*inter_props, location;
	IGRdouble  	*inter_pts, x, y, z, len, knots[4], poles[6], bas_tol;
	IGRpoint 	better_line[2];
	GRrange   	range;
	extern void EMsort_by_parameter();
	struct IGRbsp_curve	curve;
	struct GRparms  *sf_inter_parm, *cv_inter_parm;
	extern IGRdouble tan();
	extern IGRboolean  rlw_get_better_line(), EFisAncestryValid();

	*EMmsg = EMS_S_Success;
	point_size = sizeof(IGRpoint);
	inter_pts = NULL;	
	inter_props = NULL;
	sf_inter_parm = cv_inter_parm = NULL;
	not_done = world = TRUE;

	/* get the solid range */
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

	/* fill in data to create the ray */
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

	/* Intersect the ray with the solid */
	sts = om$send(msg = message EMSsolid.EMcrvsrfint(&msg_loc, 
	    		NULL, &surfs_info[0].module_info.md_env, 
	    		&curve, NULL, NULL, FALSE, &num_slots,
	    		&num_intersect, NULL, &sf_inter_parm,
	    		&cv_inter_parm, &inter_pts, &inter_props), 
	   	senderid = NULL_OBJID,
		targetid = active_GRid->objid,
		targetos = active_GRid->osnum);
	EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

	EMsort_by_parameter(sf_inter_parm, cv_inter_parm, inter_pts,
	    	inter_props, num_intersect);

	for(n = 1;not_done && n < num_intersect-1;++n) {
	    if(sf_inter_parm[n].leaf_id.objid == 
			surfs_info[1].located_obj.objid) {
		IGRint  a, b;
		IGRpoint test_pt;
		IGRpoint tmp_pt;

		a = 3 * n;
		b = a + 3;
		OM_BLOCK_MOVE(&inter_pts[a], tmp_pt, sizeof(IGRpoint));

 		sts = BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bas_tol);  

		test_pt[0] = tmp_pt[0] + axis_dir[0] * 10 * bas_tol;
		test_pt[1] = tmp_pt[1] + axis_dir[1] * 10 * bas_tol;
		test_pt[2] = tmp_pt[2] + axis_dir[2] * 10 * bas_tol;

		sts = om$send(msg = message EMSsolid.EMpoint_locate(&msg_loc,
				&surfs_info[1].module_info, NULL, test_pt, 
				NULL, &location),
		    	senderid = NULL_OBJID,
		    	targetid = active_GRid->objid,
		    	targetos = active_GRid->osnum);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		/* this situation results in cutout being placed inside the
		material */
		if(location == EMS_S_INSOLID) {
			*EMmsg = EMS_E_Fail;
			goto wrapup;
		}
		hole->axis_line[1][0] = (inter_pts[a] + inter_pts[b]) / 2.0;
		hole->axis_line[1][1]=(inter_pts[++a] + inter_pts[++b]) / 2.0;
		hole->axis_line[1][2]=(inter_pts[++a] + inter_pts[++b]) / 2.0;
		not_done = FALSE;
	   } /* if */
	} /* for */

	/* the ray doesn't intersect with the solid selected - thru all */
	if(not_done) {
	    IGRdouble  vec[3];
	    struct IGRline  line;

	    vec[0] = hole->center[0] + axis_dir[0];
	    vec[1] = hole->center[1] + axis_dir[1];
	    vec[2] = hole->center[2] + axis_dir[2];
	    line.point1 = hole->center;
	    line.point2 = vec;

	    stat_func = rlw_get_better_line(range, &line,better_line,&msg_loc);
	    EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

	    OM_BLOCK_MOVE(better_line[1], hole->axis_line[1], point_size);
	} /* if not_done */
	OM_BLOCK_MOVE(hole->center, hole->axis_line[0], point_size);

wrapup:
	if(sf_inter_parm)  om$dealloc(ptr = sf_inter_parm);
	if(cv_inter_parm)  om$dealloc(ptr = cv_inter_parm);
	if(inter_pts)  om$dealloc(ptr = inter_pts);
	if(inter_props)  om$dealloc(ptr = inter_props);

	if(msg_loc != ERR)	return(EMS_S_Success);
	else return(EMS_E_Success);

} /* EFcomp_cut_until */


end implementation ECplhole;
