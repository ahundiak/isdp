/* ###################   APOGEE COMPILED   ################## */
class implementation ECplslot;

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
#include "emserr.h"
#include "bserr.h"
#include "EMSdef.h"
#include "bsproj0.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#define THR_ALL		0
#define THR_UNTIL	1
#define THR_NEXT	2
#define BLIND		3

from GRcurve 	import GRptextend;
from GRgraphics import GRcptform, GRconstruct, GRdelete;
from EMSsubbs	import GRgetsize, GRgetgeom, GRptproject, EMget_unit_norm;
from GRvg	import GRgetrang;
from GR3dlinestr import GRputpolyline;
from GRcompcurve import EMmakecomp;
from EMSsolid import EMcrvsrfint;
from EMSsurface import EMget_point_on_surface;

extern OMuword OPP_GR3dlinestr_class_id, OPP_GRcompcurve_class_id;

/* Tapadia - 08/03/92 - Genesis. 
			This function is used to get the best point for a thru.
			until & thru next slot. Earlier only the first point 
			(end point of first segment) was used for passing the 
			ray. Now all the points which lie on the curve are 
			selected for testing. If none of them (for thr_until/
			thr_all/ blind) satisfy then the mid point of each 
			segment is used for testing. However the mid point is 
			selected for thr_next/thr_all/blind always so as to 
			get the best solution 

   Sudha    06/30/93    Modified for BSprototypes ansification
*/

IGRlong EFget_slot_intpt(EMmsg, surf_info, active_GRid, depth_type, 
		slot, new_intpt, result)

IGRlong			*EMmsg;
struct	GRlc_info	*surf_info;
struct	GRid		*active_GRid;
IGRushort 		*depth_type;
struct	EMSslot		*slot;
IGRpoint 		new_intpt;
IGRboolean		*result;

/*
Variables:

IGRlong	 *EMmsg		    O	Completion code.
struct GRlc_info *surf_info I	Surfaces information.
struct GRid *active_GRid    I	Active state solid id.
IGRushort *depth_type 	    I 	Slot depth for finite slot
struct slot_data *slot	    I/O	Relative information of slot.
IGRpoint new_intpt	    O   Output intsection point if any
IGRboolean *result	    O	TRUE if a point is found else FALSE
*/

{
	IGRlong	sts, msg_loc, num_slots, num_intersect, buf_size, 
		num_ints = 2;
	struct GRparms *sf_inter_parm, *cv_inter_parm, proj_parms;
	IGRdouble *inter_pts, poles[6], knots[4], test_dist, pr_line[2][3], 
		dotval;
	IGRulong *inter_props;
	IGRint i, j, k, kkk, pt_size;
	struct IGRbsp_curve curve, *cur_geom = NULL;
	IGRvector prof_nor, start_surf_nor;
	IGRpoint st_from_pt;
	struct EMparms st_surf_parms;
	extern void EMsort_by_parameter();
	IGRboolean done = TRUE, try_flag = FALSE;

	sts = OM_S_SUCCESS;
	*EMmsg = EMS_S_Success;
	prof_nor[0] = slot->axis_vec[0];
	*result = FALSE;
	pt_size = sizeof(IGRpoint);
	prof_nor[1] = slot->axis_vec[1];
	prof_nor[2] = slot->axis_vec[2];

	/* Get the curve pole points */
	sts = om$send(msg = message GRvg.GRgetsize(EMmsg,
			&surf_info[2].module_info.md_env.matrix_type,
			surf_info[2].module_info.md_env.matrix,
			&buf_size),
		senderid = NULL_OBJID,
		targetid = surf_info[2].located_obj.objid,
		targetos = surf_info[2].located_obj.osnum);

	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	cur_geom = (struct IGRbsp_curve *) om$malloc(size = buf_size);
	if(!cur_geom) {
		sts = EMS_E_Fail;
		goto wrapup;
	}

	sts= om$send(msg = message GRvg.GRgetgeom(EMmsg,
			&surf_info[2].module_info.md_env.matrix_type,
			surf_info[2].module_info.md_env.matrix,
			(IGRchar *)cur_geom),
		senderid = NULL_OBJID,
		targetid = surf_info[2].located_obj.objid,
		targetos = surf_info[2].located_obj.osnum);

	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

try_again:
	for(i = 0; done && i < cur_geom->num_poles; i++) {
		IGRpoint tmp_point, min_pt, max_pt, proj_pt;
		IGRpoint fir, sec;
		IGRint next_st_ind, next_nxt_ind;
		IGRdouble nxt_dist;
		
		next_st_ind = next_nxt_ind = -1;
		
		sf_inter_parm = cv_inter_parm = NULL;
		inter_pts = NULL;
		inter_props = NULL;
		num_slots = num_intersect = 0;
		k = 3 * i;
		if(try_flag)		
			kkk = 3 * (i+1);

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

		if(try_flag){		
			OM_BLOCK_MOVE(&cur_geom->poles[k], fir, pt_size);
			OM_BLOCK_MOVE(&cur_geom->poles[kkk], sec, pt_size);
			tmp_point[0] = (fir[0] + sec[0]) /2.0;
			tmp_point[1] = (fir[1] + sec[1]) /2.0;
			tmp_point[2] = (fir[2] + sec[2]) /2.0;
		}
		else 
			OM_BLOCK_MOVE(&cur_geom->poles[k], tmp_point, pt_size);

		/* Project the pole point onto the curve to get the exact point
		on the curve */
		if(cur_geom->order > 2) {
		    sts = om$send(msg = message GRgraphics.GRptproject(EMmsg, 
				&surf_info[2].module_info.md_env.matrix_type,
				surf_info[2].module_info.md_env.matrix,
				tmp_point, proj_pt, &proj_parms),
			senderid = NULL_OBJID,
			targetid = surf_info[2].located_obj.objid,
			targetos = surf_info[2].located_obj.osnum);

		    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
		    OM_BLOCK_MOVE(proj_pt, tmp_point, pt_size);
		}
		OM_BLOCK_MOVE(tmp_point, pr_line[0], pt_size);
		pr_line[1][0] = tmp_point[0] + prof_nor[0];	
		pr_line[1][1] = tmp_point[1] + prof_nor[1];	
		pr_line[1][2] = tmp_point[2] + prof_nor[2];	

		/* Project each point onto the slot axis, to get the ray 
		points */
		BSproj0(&msg_loc, slot->axis_pts[0], pr_line, min_pt);
		BSproj0(&msg_loc, slot->axis_pts[1], pr_line, max_pt);
		
		OM_BLOCK_MOVE(min_pt, &curve.poles[0], pt_size);
		OM_BLOCK_MOVE(max_pt, &curve.poles[3], pt_size);

		if(i == 0 && !try_flag) 
			test_dist = BSdistptpt(&msg_loc, min_pt, max_pt);

		/* Intersect the ray with the solid */
		sts = om$send(msg = message EMSsolid.EMcrvsrfint(EMmsg,
				NULL, &surf_info[0].module_info.md_env,
				&curve, NULL, NULL, FALSE, &num_slots, 
				&num_intersect, NULL, &sf_inter_parm, 
				&cv_inter_parm, &inter_pts, &inter_props),
			senderid = NULL_OBJID,
			targetid = active_GRid->objid,
			targetos = active_GRid->osnum);
		
		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		EMsort_by_parameter(sf_inter_parm, cv_inter_parm, 
			inter_pts, inter_props, num_intersect);

		/* Check if the until surface is part of the intersected 
		surfaces. If it's obtained then don't loop again */
		if(*depth_type == THR_UNTIL && num_intersect > 2) {
		    for(j = 0; j < num_intersect; j++) {
			if(surf_info[0].located_obj.objid == 
				sf_inter_parm[j].leaf_id.objid)
				next_st_ind = j;
			if(surf_info[1].located_obj.objid == 
				sf_inter_parm[j].leaf_id.objid)
				next_nxt_ind = j;

		    }
		    if(next_st_ind != -1 && next_nxt_ind != -1) {
			done = FALSE;
			OM_BLOCK_MOVE(tmp_point, new_intpt, pt_size);
			*result = TRUE;
		    }
		}
		/* for thr_next surface get the distance & obtain the surface
		for which the distance is minimum */
		else if(*depth_type == THR_NEXT && num_intersect > 2) {
		    sts = om$send(msg = message 
				EMSsurface.EMget_point_on_surface(EMmsg,
				&surf_info[0].module_info, 0, 1, st_from_pt, 
				&st_surf_parms),
			senderid = NULL_OBJID,
			targetid = surf_info[0].located_obj.objid,
			targetos = surf_info[0].located_obj.osnum);

		    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		    sts = om$send(msg = message EMSsubbs.EMget_unit_norm(EMmsg,
				FALSE, NULL, &surf_info[0].module_info.md_env, 
				st_from_pt, start_surf_nor),
			senderid = NULL_OBJID,
			targetid = surf_info[0].located_obj.objid,
			targetos = surf_info[0].located_obj.osnum);

		    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		    for(j = 0; j < num_intersect; j++) {
			if(surf_info[0].located_obj.objid == 
				sf_inter_parm[j].leaf_id.objid)
				next_st_ind = j;

			if(next_st_ind != -1) {
				dotval = BSdotp(EMmsg,prof_nor,start_surf_nor);
				if(dotval >= 0.0)
					next_nxt_ind = next_st_ind + 1;
				else 
					next_nxt_ind = next_st_ind - 1;
				nxt_dist = BSdistptpt(&msg_loc, 
					&inter_pts[ 3 * next_st_ind], 
					&inter_pts[3 * next_nxt_ind]);
				if(nxt_dist < test_dist) {
					test_dist = nxt_dist;
					*result = TRUE;
					OM_BLOCK_MOVE(tmp_point, new_intpt, 
						pt_size);
				}
			}
		    }
		}
		/* Get the point which has the maximum intersections */
		else if((*depth_type == THR_ALL || *depth_type == BLIND) && 
			num_intersect > 2) {
			if(num_intersect > num_ints) {
				num_ints = num_intersect;
				*result = TRUE;
				OM_BLOCK_MOVE(tmp_point, new_intpt, pt_size);
			}
		}
		if(try_flag && (i == cur_geom->num_poles - 2))
			i++;
		if(sf_inter_parm) om$dealloc(ptr = sf_inter_parm);
		if(cv_inter_parm) om$dealloc(ptr = cv_inter_parm);
		if(inter_pts) om$dealloc(ptr = inter_pts);
		if(inter_props) om$dealloc(ptr = inter_props);
	}
	/* retry with the mid points if no pole points are valid */
	if((*depth_type == THR_UNTIL && !*result && !try_flag) || 
	    ((*depth_type == THR_NEXT || *depth_type == THR_ALL ||
	    *depth_type == BLIND) && !try_flag)) {
		try_flag = TRUE;
		goto try_again;
	}

wrapup:
  /* fix for mlk */
   if(cur_geom) 
     {
     om$dealloc(ptr = cur_geom);
     cur_geom = NULL;
     }
	return(sts);
	
} /* EFget_slot_intpt() */

end implementation ECplslot;
