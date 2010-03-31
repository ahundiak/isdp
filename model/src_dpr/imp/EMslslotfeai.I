/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslslotfea;

%safe
#include <math.h>
%endsafe
#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "EMSdef.h"	/* struct EMparms */
#include "EMSmsgdef.h"	/* for EMS_I_NoIntersection */
#include "EMSfeadef.h"	/* for feature's struct */
#include "EMSasfeatdef.h"	/* for feature's struct */
#include "EMSopt.h"
#include "EMSstruct.h"
#include "emssfintdef.h"  /* for EMSsfbool_opt_xxxx */
#include "emserr.h"
#include "emsdef.h"	/* for MAXINT, DPR_DISPLAY_BUFF_INCR */
#include "EC_I.h"  /* for EMS_I_Processing */
#include "bserr.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "msdef.h"
#include "msmacros.h"	/* for ex$message() */
#include "exmacros.h" 
#include "lcmacros.h"
#include "EMSsfintsort.h"
#include "emsbool.h"
#include "EMSdef.h"
#include "EMSbnddef.h"
#include "EMSconstruct.h"
#include "bsproj0.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#define THR_ALL  	0
#define THR_UNTIL  	1
#define THR_NEXT  	2
#define BLIND  		3

#define SM_ADDED_DEBUG_CODE_SHOULD_BE_ACTIVATED 0

from EMSsubbs	import	EMget_unit_norm, EMpartolbasis;
from EMSproject import  EMplace_surface_of_projection;
from EMSloopset import  EMpt_location;
from EMSsfsolid import  EMcap_thyself;

extern OMuword OPP_EMSproject_class_id, OPP_EMSsfsolid_class_id;
extern OMuword OPP_GRcompcurve_class_id;

method EMmake_slot(IGRlong *EMmsg; 
		IGRushort *depth_type; 
		IGRboolean dir_rev;
		struct GRid *new_prof_id;
		IGRboolean is_closed;
		struct GRlc_info  *surf_info;
		struct GRvg_construct *construct_list;
		struct EMSslot *slot;
		struct GRid *active_GRid)
/*

Procedures:

(1) Surface construction: Constructs the surface of projection.
    Cap the surface to make a solid. 
(2) Difference boolean operation (create selective surface/solid boolean)  for
    open profiles.  If selective boolean fails invoke ordinary boolean.
    For closed profiles ordinary boolean is invoked.

Variables:

IGRlong	 *EMmsg		O	return status.
IGRshort *depth_type	I	depth indicator.
IGRboolean dir_rev	I 	direction of surface of projection
struct GRid  *new_porf_id I 	Objid of the new profile created
IGRboolean is_closed    I 	TRUE if profile is closed else FALSE.
struct GRlc_info *surf_info  I 	surfaces information.
struct GRvg_construct *construct_list  I  construct information of slot;
struct slot *slot   I/O	slot part information.
struct GRid *active_GRid   I	active state id.

History:
NP      09/09/93   Changed parameter type of "sortpt" & "badpt" parameter for 
                   the selective boolean function. Used to be EMSsortpt_info and
                   now is EMparms.
Sudha   06/23/93 - Modified for BSprototype ansification
Tapadia 08/06/92 - Enhanced the code to select all the pole points to check
		   if the ray intersects the solid (EFget_slot_intpt)
		   Fixed TR 92n5448, 92N2169 & 92n4919
Tapadia 07/27/92 - Changed the name from EFperform_special_boolean() to
		   EFperform_special_boolean to reflect Navin's changes
SM      05/05/92 - Fixed all compiler warnings. This brought out a bug -
                   incorrect data type was being passed to the method
                   EMSsubbs.EMpartolbasis
SM      05/05/92 - As an investigation tool, added code to optionally output
                   the surfaces and the points input to the selective boolean
                   function. This code can be activated by defining the
                   compiler conditional statement 
                   'SM_ADDED_DEBUG_CODE_SHOULD_BE_ACTIVATED' and recompiling.

Tapadia 06/01/91 - Support for closed profiles.
Tapadia 12/30/91 - Support for ordinary boolean when selective boolean fails
Tapadia 11/13/91 - Create a solid of projection for all types of slots.
Tapadia 10/21/91 - Implemented creative selective surface/solid boolean for
		   finite slots.
Tapadia 10/10/91 - Fixed a few TR's
Tapadia 09/10/91 - Support for composite curves.
Tapadia 08/29/91 - Creation

*/
{
    	IGRlong  	sts, msg_loc, num_slots, num_intersect;
        IGRulong 	location, *inter_props;
    	GRspacenum  	*osnum;
    	OM_S_OBJID  	surfs[2], surf_id, solid_id, save_mdid;
	OMuword 	dum_os, classid;
	IGRint 		i, j1, j2, k, kkk, num_sort_pts, num_bad_pts = 0,
			next_st_ind, next_nxt_ind, until_ind, until_st_ind, 
			pt_size, count_surfs, total_objs, num_objs, 
			num_chil;
	OMuint		num_ls, num_of_comps;
	IGRpoint 	first_pt, sec_pt, mid_pt, surf_pt, check_pt, 
			st_from_pt, new_pt, proj_st_pt, proj_end_pt;
	IGRdouble 	sf_uv_pt1[2], sf_uv_pt2[2], knots[4],
			poles[6], *inter_pts, dotval, dottol = 0.000001,
			ord_dist, proj_dist;
	struct GRid 	slot_id;
	extern void 	EMsort_by_parameter();
	IGRvector 	prof_nor, start_surf_nor, ch_dir;
	IGRboolean 	same_surf_flag = FALSE, st_pt_flag, end_pt_flag,
			world = TRUE, st_dot_flag, end_dot_flag, is_comp;
	GRobjid 	GRids, comp_ids, proj_compsf_id, proj_id,
			temp_id, swap_id, *surf_ids;
	struct GRparms 	*sf_inter_parm, *cv_inter_parm, proj_parms;
	struct EMparms 	st_surf_parms;
	extern IGRlong 	EFret_crv_norpt();
	extern void 	EFperform_special_boolean();
	OM_S_CHANSELECT sf_ls_chan, to_comps;
	struct IGRbsp_curve curve;
	struct EMparms *sortpts_info, *bad_pts_info = NULL;
	enum EMSbooltype bool_type;
	struct EMSpartolbasis partolbasis;
	OM_S_OBJECT_LINKAGE ls_list;
	extern IGRlong EFget_slot_intpt();
	IGRpoint new_intpt;
	IGRboolean result;
	IGRdouble pr_line[2][3];
	struct GRid 	*surf_list;

	/* initialize */
    	sts = OM_S_SUCCESS;
    	*EMmsg = EMS_S_Success;
    	osnum = &surf_info[0].located_obj.osnum;
	slot_id.objid = my_id;
	slot_id.osnum = *osnum;
	sf_inter_parm = cv_inter_parm = NULL;
	inter_pts = NULL;
	inter_props = NULL;
	sortpts_info = NULL;
	surf_ids = NULL;
	surf_list = NULL;
	new_pt[0] = new_pt[1] = new_pt[2] = 0.0;
	st_pt_flag = end_pt_flag = FALSE;
	num_slots = num_intersect = 0;
	bool_type = EMSbool_difference;
	is_comp = st_dot_flag = end_dot_flag = FALSE;
	pt_size = sizeof(IGRpoint);
	temp_id = swap_id = NULL_OBJID;

	sts = EMmake_chanselect(EMSsubbs_to_loopset, &sf_ls_chan);
	if(!(1 & sts)) goto wrapup;
	sts = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
	if(!(1 & sts)) goto wrapup;

	if(is_closed) {
	    *EMmsg = om$get_classid(objid = surf_info[2].located_obj.objid,
			osnum = surf_info[2].located_obj.osnum,
			p_classid = &classid);
   	    EMerr_hndlr (!(1 & *EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

	    sts = om$is_ancestry_valid(subclassid = classid,
			superclassid = OPP_GRcompcurve_class_id);
	    if(sts == OM_S_SUCCESS)
		is_comp = TRUE;
	}
	else
	    is_comp = TRUE;


	/* Get the component count of the original profile */
	sts = om$get_channel_count(p_chanselect = &to_comps,
		objid = surf_info[2].located_obj.objid,
		osnum = surf_info[2].located_obj.osnum,
		count = (OMuint *)&num_chil);

	if(! (1 & sts)) 
		num_chil = 1;

	/* profile normal */
	prof_nor[0] = slot->axis_vec[0];
	prof_nor[1] = slot->axis_vec[1];
	prof_nor[2] = slot->axis_vec[2];

	/* This selects the best point of all the curve points for intersecting
	the ray */
	sts = EFget_slot_intpt(EMmsg, surf_info, active_GRid, depth_type, 
		slot, new_intpt, &result);

	partolbasis.in_world = TRUE;
	partolbasis.mattyp = &surf_info[0].module_info.md_env.matrix_type;
	partolbasis.mat = surf_info[0].module_info.md_env.matrix;

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

	/* Generating a ray. Project the best point along the slot axis */
	if(result) {
		IGRpoint min_pt, max_pt;
	    	for(i = 0; i < 3; i++) {
			pr_line[0][i] = new_intpt[i];
			pr_line[1][i] = new_intpt[i] + prof_nor[i];
	    	}
		BSproj0(&msg_loc, slot->axis_pts[0], pr_line, min_pt);
		BSproj0(&msg_loc, slot->axis_pts[1], pr_line, max_pt);

		for(i = 0; i < 3; i++) 
			curve.poles[i] = min_pt[i];
		for(i = 3; i < 6; i++) 
			curve.poles[i] = max_pt[i- 3];
	}
	else {
		for(i = 0; i < 3; i++) 
			curve.poles[i] = slot->axis_pts[0][i];
		for(i = 3; i < 6; i++) 
			curve.poles[i] = slot->axis_pts[1][i - 3];
	}

	/* Intersect the ray with the solid range limit */
	sts = om$send(msg = message EMSsolid.EMcrvsrfint(EMmsg, NULL,
			&surf_info[0].module_info.md_env,
			&curve, NULL, NULL, FALSE, &num_slots,
			&num_intersect, NULL, &sf_inter_parm,
			&cv_inter_parm, &inter_pts, &inter_props),
		senderid = NULL_OBJID,
		targetid = active_GRid->objid,
		targetos = active_GRid->osnum);

     	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	
	/* sort the intersections obtained */
	EMsort_by_parameter(sf_inter_parm,cv_inter_parm, inter_pts,
		inter_props, num_intersect);

  	/* num_intersect = 0 - in which case both the points are inside/outside
	num_intersect = 1 - in which one of the points is inside/outside */

	if(*depth_type == BLIND) {
	    if(num_intersect % 2 == 1 || num_intersect < 1) {
		OM_BLOCK_MOVE(slot->axis_pts[0], check_pt, pt_size);
		sts = om$send(msg = message EMSsolid.EMpoint_locate(
				EMmsg, construct_list->env_info, NULL,
				check_pt, NULL, &location),
			senderid = NULL_OBJID,
			targetid = active_GRid->objid,
			targetos = active_GRid->osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg,EMS_E_Fail, wrapup);

		if(location == EMS_S_INSOLID)
	 		st_pt_flag = TRUE;

		OM_BLOCK_MOVE(slot->axis_pts[1], check_pt, pt_size);
		sts = om$send(msg = message EMSsolid.EMpoint_locate(
				EMmsg, construct_list->env_info, NULL,
				check_pt, NULL, &location),
			senderid = NULL_OBJID,
			targetid = active_GRid->objid,
			targetos = active_GRid->osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg,EMS_E_Fail, wrapup);

		if(location == EMS_S_INSOLID)
			end_pt_flag = TRUE;
		if(st_pt_flag && end_pt_flag) 
			num_sort_pts = 1;
		else if(st_pt_flag || end_pt_flag) 
			num_sort_pts = (num_intersect+1)/2;

		/* No intersections found - invoke ordinary boolean (behaves 
		like a closed profile) */

		else 
			is_closed = TRUE;
	    }
	    else if(num_intersect == 2) 
		num_sort_pts = 1;
	    else if(num_intersect % 2 == 0) 
		num_sort_pts = num_intersect * 0.5;
	}
	/* for a thru. all, thru. next & thru. until slot */
	else {
	    	if(num_intersect != 0)
			num_sort_pts = num_intersect * 0.5;

		/* If there are no intersections - make it a thru all slot & 
		invoke ordinary boolean (behaves like a closed profile) */

		else if(num_intersect == 0)
			is_closed = TRUE;
	}

	/* For THR_NEXT slot */
	if(*depth_type == THR_NEXT) {
		num_sort_pts = 1;
		/* Get a point on the surface & it's normal such that it
		points inside the solid */
		sts = om$send(msg = message EMSsurface.EMget_point_on_surface(
				EMmsg, &surf_info[0].module_info, 0, 1, 					st_from_pt, &st_surf_parms),
			senderid = NULL_OBJID,
			targetid = surf_info[0].located_obj.objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
				EMmsg, FALSE, NULL,
				&surf_info[0].module_info.md_env,
				st_from_pt, start_surf_nor),
			senderid = NULL_OBJID,
			targetid = surf_info[0].located_obj.objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
				
		/* obtain the index of the start surface & intersected 
		surface */
		next_st_ind = -1;
		for(i = 0; i < num_intersect; i++) {
			if(surf_info[0].located_obj.objid == 
				sf_inter_parm[i].leaf_id.objid) 
				next_st_ind = i;
		}

		/* no surface found or num_intersect == 2, we change to 
		through all slot */
		if(next_st_ind == -1 || num_intersect == 2) 
			*depth_type = THR_ALL;
		else { 
			/* find the dot product between the profile normal & 
			surface normal to decide in which direction the next 
			surface lies */

			dotval = BSdotp(EMmsg, prof_nor, start_surf_nor);
			if(dotval >= 0.0) 
				next_nxt_ind = next_st_ind + 1;
			else
				next_nxt_ind = next_st_ind - 1;
		}
	} /* for THR_NEXT slot */

	if(*depth_type == THR_UNTIL) {
		/* get the indices of the start & end surface w.r.t to the
		intersected surface */
		next_st_ind = next_nxt_ind = -1;
		for(i = 0; i < num_intersect; i++) {
		    if(surf_info[0].located_obj.objid == 
			sf_inter_parm[i].leaf_id.objid) 
			    next_st_ind = i;
		    if(surf_info[1].located_obj.objid == 
			sf_inter_parm[i].leaf_id.objid) 
			    next_nxt_ind = i;
		}

		/* If the start & end surface identified are actual start &
		end surface along the normal we create a through slot */
		if((next_st_ind == 0 && next_nxt_ind == (num_intersect - 1)) ||
		  (next_st_ind == (num_intersect - 1) && next_nxt_ind == 0)) {
			*depth_type = THR_ALL;
			same_surf_flag = TRUE;
		}
		/* If both the indices are same we create through slot */
		else if(next_st_ind == next_nxt_ind) {
			*depth_type = THR_ALL;
			same_surf_flag = TRUE;
		}
		/* If it doesn't intersect either one of the surfaces we create
		a through slot */
		else if(next_st_ind == -1 || next_nxt_ind == -1) {
			*depth_type = THR_ALL;
			same_surf_flag = TRUE;
		}

		/* Don't modify this - Tapadia */
		if(!same_surf_flag) {
		    until_ind = abs(next_st_ind - next_nxt_ind);
		    if(until_ind % 2 != 0) 
			num_sort_pts = (until_ind + 1)/2;
		    else
			num_sort_pts = until_ind/2;
		    until_st_ind = (next_st_ind > next_nxt_ind) ? 
				next_nxt_ind : next_st_ind;

		    if(until_st_ind % 2 != 0) {
		        if(num_sort_pts >= 1 && until_ind % 2 == 0) 
			    until_st_ind += 1;
			else if(num_sort_pts > 1 && until_ind % 2 != 0) {
			    until_st_ind += 1;
			    num_sort_pts -= 1;
			    if(next_st_ind > next_nxt_ind) 
				next_st_ind--;
			    else 
				next_nxt_ind--;
			} /* else if */
			if(until_ind > 1) {
			    if(next_st_ind > next_nxt_ind) 
				next_nxt_ind++;
			    else 
				next_st_ind++;
			}
		    } /* if */
		    else { 
			if(until_ind % 2 == 0) {
			    if(next_st_ind > next_nxt_ind) 
				next_st_ind--;
			    else 
				next_nxt_ind--;
			}
		    }
		} /* if */
	} /* if */

	/* Compute the axis of the start & end surface. Check if the dot
	product of the surface normal & profile normal is either 1 or -1. */

	if((*depth_type == THR_NEXT || *depth_type == THR_UNTIL) && 
	    num_intersect > 2) {
		IGRpoint temp_pt1, temp_pt2;
		IGRvector st_su_nor, end_su_nor;
		struct EMparms parms;

		sts = om$send(msg = message EMSsurface.EMget_point_on_surface(
				EMmsg, construct_list->env_info, 0, 1, 
				temp_pt1, &parms),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[next_st_ind].leaf_id.objid,
			targetos = *osnum);
			
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
				EMmsg, FALSE, NULL,
				&surf_info[0].module_info.md_env,
				temp_pt1, st_su_nor),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[next_st_ind].leaf_id.objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		dotval = BSdotp(EMmsg, prof_nor, st_su_nor);
		if((fabs(dotval) + dottol) >= 1.0) 
			st_dot_flag = TRUE;

		sts = om$send(msg = message EMSsurface.EMget_point_on_surface(
				EMmsg, construct_list->env_info, 0, 1, 
				temp_pt2, &parms),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[next_nxt_ind].leaf_id.objid,
			targetos = *osnum);
			
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
				
		sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
				EMmsg, FALSE, NULL,
				&surf_info[0].module_info.md_env,
				temp_pt2, end_su_nor),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[next_nxt_ind].leaf_id.objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

		dotval = BSdotp(EMmsg, prof_nor, end_su_nor);
		if((fabs(dotval) + dottol) >= 1.0) 
			end_dot_flag = TRUE;
	}

	/* Compute the points to be used by surface of projection for thru.
	next & thru. until slot. This is used to compute the exact projection 
	distance to be used by ordinary boolean */

	if((*depth_type == THR_NEXT || *depth_type == THR_UNTIL) && 
	  num_intersect > 2) {
	    IGRpoint pt_sf1, pt_sf2;
	    IGRdouble proj_line[2][3];
	    IGRmatrix matrix;
	    IGRint a, b;

	    for(i = 14; i > 0; i--) matrix[i] = 0.0;
	    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
	    OM_BLOCK_MOVE(slot->axis_pts[0],proj_line[0], pt_size);
	    OM_BLOCK_MOVE(slot->axis_pts[1],proj_line[1], pt_size);

	    /* if dot st_dot_flag || end_dot_flag == TRUE, get the point
	    from the inter_pts else take the average */

	    if(next_st_ind == 0) {
	        OM_BLOCK_MOVE(slot->axis_pts[0], pt_sf1, pt_size);
		a = next_nxt_ind * 3;
	        if(end_dot_flag) 
		    	OM_BLOCK_MOVE(&inter_pts[a], pt_sf2, pt_size); 
		else {
			b = a + 3;
			pt_sf2[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf2[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf2[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
	    } /* if */
	    else if(next_st_ind == (num_intersect -1)) {
		OM_BLOCK_MOVE(slot->axis_pts[1], pt_sf1, pt_size);
		if(end_dot_flag) {
			a = next_nxt_ind * 3;
		    	OM_BLOCK_MOVE(&inter_pts[a], pt_sf2, pt_size);
		}
		else {
			a = (next_nxt_ind -1) * 3;
			b = a + 3;
			pt_sf2[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf2[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf2[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
	    } /* else if */
	    else if(next_nxt_ind == 0) {
		OM_BLOCK_MOVE(slot->axis_pts[0], pt_sf2, pt_size);
		a = next_st_ind * 3;
		if(st_dot_flag) 
			OM_BLOCK_MOVE(&inter_pts[a], pt_sf1, pt_size);
		else {
			b = a + 3;
			pt_sf1[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf1[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf1[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
	    } /* else if */
	    else if(next_nxt_ind == (num_intersect -1)) {
		OM_BLOCK_MOVE(slot->axis_pts[1], pt_sf2, pt_size);
		if(st_dot_flag) {
			a = next_st_ind * 3;
		    	OM_BLOCK_MOVE(&inter_pts[a], pt_sf1, pt_size);
		}
		else {
			a = (next_st_ind - 1) * 3;
			b = a + 3;
			pt_sf1[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf1[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf1[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
	        }
	    } /* else if */
	    else if(next_st_ind > next_nxt_ind) {
		a = next_st_ind * 3; 
		if(st_dot_flag) 
		    	OM_BLOCK_MOVE(&inter_pts[a], pt_sf1, pt_size);
		else {
			b = a + 3;
			pt_sf1[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf1[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf1[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
		if(end_dot_flag) {
			a = (next_nxt_ind) * 3;
		    	OM_BLOCK_MOVE(&inter_pts[a], pt_sf2, pt_size);
		}
		else {
			a = (next_nxt_ind - 1) * 3;
			b = a + 3;
			pt_sf2[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf2[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf2[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
	    } /* else if */
   	    else {
		a = (next_nxt_ind ) * 3; 
		if(end_dot_flag) 
			OM_BLOCK_MOVE(&inter_pts[a], pt_sf2, pt_size);
		else {
			b = a + 3;
			pt_sf2[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf2[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf2[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
		if(st_dot_flag) {
			a = (next_st_ind ) * 3;
	    		OM_BLOCK_MOVE(&inter_pts[a], pt_sf1, pt_size);
		}
		else {
			a = (next_st_ind - 1) * 3;
			b = a + 3;
			pt_sf1[0] = (inter_pts[a] + inter_pts[b])/2.0;
			pt_sf1[1] = (inter_pts[++a] + inter_pts[++b])/2.0;
			pt_sf1[2] = (inter_pts[++a] + inter_pts[++b])/2.0;
		}
	    } /* else */

	    /* Project pt_sf1, pt_sf2 onto the profile normal */
	    BSproj0(EMmsg, pt_sf1, proj_line, proj_st_pt);
	    BSproj0(EMmsg, pt_sf2, proj_line, proj_end_pt);

	    for(i = 0; i < 3; i++) 
	    	ch_dir[i] = proj_end_pt[i] - proj_st_pt[i];

	    BSnorvec(&msg_loc, ch_dir);
	    ord_dist = BSdistptpt(EMmsg, proj_st_pt, slot->axis_pts[0]);
	    matrix[3] = ord_dist * prof_nor[0];
	    matrix[7] = ord_dist * prof_nor[1];
	    matrix[11] = ord_dist * prof_nor[2];

            save_mdid = surf_info[0].module_info.md_id.objid;
            surf_info[0].module_info.md_id.objid = NULL_OBJID;

	    /* Copy the profile to create a new one */ 
	    sts = om$send(msg = message GRgraphics.GRcptform(EMmsg,
			&surf_info[0].module_info,
			matrix, &surf_info[0].module_info,
			&temp_id),
		senderid = NULL_OBJID,
		targetid = new_prof_id->objid,
		targetos = new_prof_id->osnum);
            surf_info[0].module_info.md_id.objid = save_mdid;

     	    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	    swap_id = new_prof_id->objid;
	    new_prof_id->objid = temp_id;
	} /* if */
	else {
		OM_BLOCK_MOVE(slot->axis_pts[0],proj_st_pt, pt_size);
		OM_BLOCK_MOVE(slot->axis_pts[1],proj_end_pt, pt_size);
	}

	/* Create a surface of projection */
    	sts = om$construct(classid = OPP_EMSproject_class_id,
			msg = message EMSproject.EMplace_surface_of_projection(
			construct_list, new_prof_id, &surf_info[0].module_info, 
			NULL, NULL, proj_st_pt, proj_end_pt, 
			dir_rev, &surf_id), 
		p_objid = &surfs[0],
		osnum = *osnum);
     	EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, EMS_E_Fail, 
		wrapup);

	proj_id = surf_id;

	/* Make a solid by capping it's ends with planes */
	sts = om$construct(classid = OPP_EMSsfsolid_class_id,
			msg = message EMSsfsolid.EMcap_thyself(EMmsg,
			construct_list, &surf_id),
		p_objid = &solid_id,
		osnum = *osnum);

	if(!(1 & sts & *EMmsg &*construct_list->msg)) {
		sts = om$send(msg = message GRgraphics.GRdelete(EMmsg,
				construct_list->env_info),
			targetid = surf_id,
			targetos = *osnum);

		*EMmsg = EMS_E_Success;
		goto wrapup;
	}
	proj_id = solid_id;

	/* This computes the new point of the curve normal to allow us to 
	decide if the point is inside the solid or not. If it's not inside 
	then we perform intersection instead of difference */

	sts = EFret_crv_norpt(&surf_info[2], dir_rev, new_pt, EMmsg);

     	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	proj_dist = BSdistptpt(EMmsg, proj_st_pt, proj_end_pt);
	proj_dist /= 2.0;

	/* Move the new pt. by the distance the original profile was moved + 
	half the solid of projection distance */

	if((*depth_type == THR_UNTIL || *depth_type == THR_NEXT) &&
	    num_intersect > 2) {
	    for(i = 0; i < 3; i++) 
		new_pt[i] += (prof_nor[i] * (ord_dist + (proj_dist*ch_dir[i]) - 
			slot->dist_move));
	} /* if */
	else {
		for(i = 0; i < 3; i++) 
			new_pt[i] += (prof_nor[i] * (proj_dist - 
				slot->dist_move));
	}

	sts = om$send(msg = message EMSsolid.EMpoint_locate(EMmsg,
			construct_list->env_info, NULL, new_pt, NULL,
			&location),
		senderid = NULL_OBJID,
		targetid = proj_id,
		targetos = *osnum);

	if(!(1 & sts & *EMmsg)) {
		sts = 0;
		goto wrapup;
	}
	if(location != EMS_S_INSOLID && location != EMS_S_ONSOLID) 
		bool_type = EMSbool_intersect;

	/* Only for open profiles invoke selective surface/solid boolean */
	if(!is_closed) {
	    sts = om$get_objid_at_index(objid = proj_id,
                       p_chanselect = &to_comps,
                       index = 0,
                       objidaddr = &GRids,
                       osnumaddr = &dum_os);

	    EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    proj_compsf_id = GRids;

	    sortpts_info = (struct EMparms *) malloc(num_sort_pts * 
		num_chil * sizeof(struct EMparms));  
	    if(!sortpts_info) {
		*EMmsg = EMS_E_NoDynamicMemory;
		goto wrapup;
	    }

	    /* get the data for creative selective solid/surface boolean */
	    if(*depth_type != BLIND) {
	      for(i = 0; i < num_sort_pts; i++) {
		if(*depth_type == THR_NEXT) {
			j1 = next_st_ind;
			j2 = next_nxt_ind;
		}
		else if(*depth_type == THR_UNTIL) {
			j1 = until_st_ind + (2 * i);
			j2 = until_st_ind + (2 * i) + 1;
		}
		else { /* for a through all slot */
			j1 = 2 * i;
			j2 = 2 * i + 1;
		}
	
		sf_uv_pt1[0] = sf_inter_parm[j1].u;
		sf_uv_pt1[1] = sf_inter_parm[j1].v;

		sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, first_pt),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[j1].leaf_id.objid,
			targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	
		sf_uv_pt2[0] = sf_inter_parm[j2].u;
		sf_uv_pt2[1] = sf_inter_parm[j2].v;

		sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt2, 2, sec_pt),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[j2].leaf_id.objid,
			targetos = sf_inter_parm[j2].leaf_id.osnum);
	
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	
		mid_pt[0] = (first_pt[0] + sec_pt[0])/2.0;
		mid_pt[1] = (first_pt[1] + sec_pt[1])/2.0;
		mid_pt[2] = (first_pt[2] + sec_pt[2])/2.0;

		for(k = 0; k < num_chil; k++) {
			kkk = (i * num_chil) + k;
			/* get the surface ids of the individual curve
			segments. Project the computed mid_pt on each of these 
			surfaces */
			
	    	    	sts = om$get_objid_at_index(objid = proj_compsf_id,
                       		p_chanselect = &to_comps,
                       		index = k,
                       		objidaddr = &comp_ids,
                       		osnumaddr = &dum_os);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		sts = om$get_channel_objects(objid = comp_ids,
				osnum = *osnum,
				p_chanselect = &sf_ls_chan,
				list = &ls_list, size = 1, count = &num_ls);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		/* Get the list of its components */
	    		sts = om$get_channel_count(objid = proj_id,
				osnum = *osnum, 
				p_chanselect = &to_comps,
				count = &num_of_comps);

	    		if(!(1 & sts)) goto wrapup;
		
	    		sts = om$get_channel_objects(objid = comp_ids,
				osnum = *osnum,
				p_chanselect = &sf_ls_chan,
				list = &ls_list, size = 1, count = &num_ls);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		sts = om$send(msg = message EMSsubbs.EMpartolbasis(
				EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				&world, NULL, &partolbasis.tol),
	     		    senderid = NULL_OBJID,
	    		    targetid = comp_ids, 
			    targetos = *osnum);

     	    	        EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, 
				wrapup);

			sts = om$send(msg = message EMSsubbs.GRptproject(EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				mid_pt, surf_pt, &proj_parms),
		    	    senderid = NULL_OBJID,
			    targetid = comp_ids,
			    targetos = *osnum);
	
     			EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
	
			sortpts_info[kkk].leaf_id  = proj_parms.leaf_id;
			sortpts_info[kkk].u        = proj_parms.u;
			sortpts_info[kkk].v        = proj_parms.v;

/*************** NOT NEEDED *********************
			sortpts_info[kkk].md_env = surf_info[0].module_info;
	
			sts = om$send(msg = message EMSloopset.EMpt_location(
				EMmsg, surf_uv_pt, 
				&sortpts_info[kkk].ptloc_info,
				&partolbasis),
			    senderid = NULL_OBJID,
			    targetid = ls_list.S_objid, 
			    targetos = *osnum);

     			EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, 
				wrapup);
	
			* If point location does not return location as either
			on edge or on vertex, replace the pt_location closest 
			point by sf_uv_pt 
                        *
                        
			if((sortpts_info[kkk].ptloc_info.location != 
				EMS_L_ONEDGE) && 
			   (sortpts_info[kkk].ptloc_info.location != 
				EMS_L_ONVRTX))
		    	   OM_BLOCK_MOVE(surf_uv_pt, 
			    sortpts_info[kkk].ptloc_info.edge[0].nst_pt.proj_pt,
			    	sizeof(IGRdouble)*2);
			sortpts_info[kkk].sf_id = comp_ids;
			sortpts_info[kkk].xyz_pt[0] = surf_pt[0];
	   		sortpts_info[kkk].xyz_pt[1] = surf_pt[1]; 
			sortpts_info[kkk].xyz_pt[2] = surf_pt[2];
			sortpts_info[kkk].ed_oprnd  = 1;
*************************/


		}
	      } /* for */
	    } /* if */
	    /* get the data of blind slot for creative selective solid/surface 
	    boolean */
	    else {
	      for(i = 0; i < num_sort_pts; i++) {
		if(num_intersect == 0) {
			OM_BLOCK_MOVE(slot->axis_pts[0], first_pt, pt_size);
			OM_BLOCK_MOVE(slot->axis_pts[1], sec_pt, pt_size);
		}
		/* for odd number of intersections */
		else if(num_intersect == 1)  {
		    	if(st_pt_flag)
			    OM_BLOCK_MOVE(slot->axis_pts[0], first_pt, pt_size);
		    	else 
			    OM_BLOCK_MOVE(slot->axis_pts[1], first_pt, pt_size);

			j1 = 2 * i;
			sf_uv_pt1[0] = sf_inter_parm[j1].u;
			sf_uv_pt1[1] = sf_inter_parm[j1].v;

			sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, sec_pt),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[j1].leaf_id.objid,
			    targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     			EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
		}
		else if((num_intersect % 2 == 1) && i == 0)  {
		    	if(st_pt_flag) {
			    OM_BLOCK_MOVE(slot->axis_pts[0], first_pt, pt_size);
			    j1 = 2 * i;
			}
		    	else { 
			    OM_BLOCK_MOVE(slot->axis_pts[1], first_pt, pt_size);
			    j1 = 2 * (num_sort_pts - 1);
			}
			sf_uv_pt1[0] = sf_inter_parm[j1].u;
			sf_uv_pt1[1] = sf_inter_parm[j1].v;

			sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, sec_pt),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[j1].leaf_id.objid,
			    targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     			EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
		}
		/* for even number of intersections */
		else if((num_intersect % 2 == 0) || (num_intersect %2 != 0 
			&& i > 0)) {
			if(st_pt_flag) {
				j1 = 2 * i - 1;
				j2 = 2 * i; 
			}
			else if(end_pt_flag) {
				j1 = 2 * (i - 1);
				j2 = 2 * (i - 1) + 1;
			}
			else {
				j1 = 2 * i;
				j2 = 2 * i + 1;
			}
			sf_uv_pt1[0] = sf_inter_parm[j1].u;
			sf_uv_pt1[1] = sf_inter_parm[j1].v;

			sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, first_pt),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[j1].leaf_id.objid,
			    targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     			EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
	
			sf_uv_pt2[0] = sf_inter_parm[j2].u;
			sf_uv_pt2[1] = sf_inter_parm[j2].v;

			sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt2, 2, sec_pt),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[j2].leaf_id.objid,
			    targetos = sf_inter_parm[j2].leaf_id.osnum);
	
     		        EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
		} /* else if */
		mid_pt[0] = (first_pt[0] + sec_pt[0])/2.0;
		mid_pt[1] = (first_pt[1] + sec_pt[1])/2.0;
		mid_pt[2] = (first_pt[2] + sec_pt[2])/2.0;

		for(k = 0; k < num_chil; k++) {
			kkk = (i * num_chil) + k;
			/* get the surface ids of the individual curve
			segments. Project the computed mid_pt on each of these 
			surfaces */

	    		sts = om$get_objid_at_index(objid = proj_compsf_id,
                       		p_chanselect = &to_comps,
                       		index = k,
                       		objidaddr = &comp_ids,
                       		osnumaddr = &dum_os);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		sts = om$get_channel_objects(objid = comp_ids,
				osnum = *osnum,
				p_chanselect = &sf_ls_chan,
				list = &ls_list, size = 1, count = &num_ls);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		/* Get the list of its components */
	    		sts = om$get_channel_count(objid = proj_id,
				osnum = *osnum, 
				p_chanselect = &to_comps,
				count = &num_of_comps);

	    		if(!(1 & sts)) goto wrapup;
		
	    		sts = om$get_channel_objects(objid = comp_ids,
				osnum = *osnum,
				p_chanselect = &sf_ls_chan,
				list = &ls_list, size = 1, count = &num_ls);

	    		EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	    		sts = om$send(msg = message EMSsubbs.EMpartolbasis(
				EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				&world, NULL, &partolbasis.tol),
	     		    senderid = NULL_OBJID,
	    		    targetid = comp_ids, 
			    targetos = *osnum);

     	    		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, 
				wrapup);

			sts = om$send(msg = message EMSsubbs.GRptproject(EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				mid_pt, surf_pt, &proj_parms),
			    senderid = NULL_OBJID,
			    targetid = comp_ids,
			    targetos = *osnum);
	
     			EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
	
			sortpts_info[kkk].leaf_id = proj_parms.leaf_id;
			sortpts_info[kkk].u       = proj_parms.u;
			sortpts_info[kkk].v       = proj_parms.v;

/**************** NOT NEEDED *************
			sortpts_info[kkk].md_env = surf_info[0].module_info;
	
			sts = om$send(msg = message EMSloopset.EMpt_location(
				EMmsg, surf_uv_pt, 
				&sortpts_info[kkk].ptloc_info,
				&partolbasis),
			    senderid = NULL_OBJID,
			    targetid = ls_list.S_objid, 
			    targetos = *osnum);

     			EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, 
				wrapup);
	
			* If point location does not return location as either
			on edge or on vertex, replace the pt_location closest 
			point by sf_uv_pt 
                        *
	
	   		if((sortpts_info[kkk].ptloc_info.location != 
				EMS_L_ONEDGE) && 
			(sortpts_info[kkk].ptloc_info.location != EMS_L_ONVRTX))
		    	   OM_BLOCK_MOVE(surf_uv_pt, 
			    sortpts_info[kkk].ptloc_info.edge[0].nst_pt.proj_pt,
			      sizeof(IGRdouble)*2);
	
			* profile created is always a composite curve *
			sortpts_info[kkk].sf_id = comp_ids;
			sortpts_info[kkk].xyz_pt[0] = surf_pt[0];
	   		sortpts_info[kkk].xyz_pt[1] = surf_pt[1]; 
			sortpts_info[kkk].xyz_pt[2] = surf_pt[2];
			sortpts_info[kkk].ed_oprnd  = 1;
  ****************************************************************/



	        }
	      } /* for */
	    } /* else */

	    num_sort_pts *= num_chil;

	    /* Creative selective surface/solid boolean operation is used to
	    create slot. If it fails ordinary boolean is invoked */
	
#if SM_ADDED_DEBUG_CODE_SHOULD_BE_ACTIVATED
	    {
	     IGRchar keyin;
	     struct GRid junk;
             IGRpoint xyzpt;
             IGRdouble uvpt[2];
             IGRint loci;
             enum GRdpmode dpmode = GRbd;
	
	     EFgetchar(stderr, "Output sel bool operand?[y]", &keyin);
             if (toupper (keyin) != 'N')	
              {
	       sts = om$send(msg = message GRgraphics.GRcopy(EMmsg, 
	             construct_list->env_info, construct_list->env_info, 
	             &junk.objid), targetid = proj_id);
	
	       sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
	             &construct_list->env_info->md_env.matrix_type, 
	             construct_list->env_info->md_env.matrix, &dpmode, 
	             &construct_list->env_info->md_id), 
	             targetid = junk.objid);
              } /* if (toupper (keyin) != 'N') */

	     EFgetchar(stderr, "Output sel bool sort points?[y]", &keyin);
             if (toupper (keyin) != 'N')
              {
	        for(loci = 0; loci < num_sort_pts; loci++)
	         {
                   uvpt[0] = sortpts_info[loci].u;
                   uvpt[1] = sortpts_info[loci].v;

                    sts = om$send (msg = message GRvg.EMptatpr (EMmsg, 
                             &construct_list->env_info->md_env.matrix_type, 
                             construct_list->env_info->md_env.matrix,
                             uvpt, 1, xyzpt),
                          targetid = junk.objid);
 
		  sts = EMoutput_point(EMmsg, my_id, construct_list, 1, 
		        xyzpt, &junk);
	          sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
	                &construct_list->env_info->md_env.matrix_type, 
	                construct_list->env_info->md_env.matrix, &dpmode, 
	                &construct_list->env_info->md_id), 
	                targetid = junk.objid);
	         }
	
              } /* if (toupper (keyin) != 'N') */
	    }
#endif

            if (OM_Gf_verbose_warning)
	      fprintf(stderr, "slotfea calling EFperform_special_boolean\n");

	    EFperform_special_boolean(EMmsg, &surf_info[0].module_info,
			active_GRid->objid, 1, &proj_id, 0, construct_list, 
			bool_type, num_sort_pts, &sortpts_info[0], 
			EMSsfbool_opt_doublecheck, &num_bad_pts, 
			&bad_pts_info, slot_id);
	}

	/* If selective boolean fails or slot profile is closed */
    	if(!(1 & sts & *EMmsg) || (*EMmsg == EMS_I_NoIntersection) ||
	    is_closed) {
		IGRchar	status_str[54];
		IGRushort optionsEMboolean;
		enum GRdpmode DisplayMode;

            	/*DLB 8/5/92 - added fprintf is OMVEBOSE_WARNING is set*/
		if (OM_Gf_verbose_warning && !is_closed)
		{
	     	  fprintf(stderr, "---EFperform_special_boolean failed---\n");
		  if (*EMmsg == EMS_I_NoIntersection)
  		    fprintf(stderr, "\t---no intersections found---\n");
  		  else
    		    EFprintcode(0, *EMmsg);
		}

		/* Get all the surfaces of slot for redraw after boolean */
		sts = om$send(msg = message GRowner.GRget_number_components(
				EMmsg, &count_surfs),
			targetid = proj_id,
			targetos = *osnum);

  		total_objs = num_objs = count_surfs;

  		/* get all the surfaces' ids in the part for boolean display 
		use */

  		if(total_objs < DPR_DISPLAY_BUFF_INCR)  
			num_objs = DPR_DISPLAY_BUFF_INCR;
  		else if(total_objs % DPR_DISPLAY_BUFF_INCR) {
     			i = (IGRint) total_objs / DPR_DISPLAY_BUFF_INCR;
     			num_objs = ++i * DPR_DISPLAY_BUFF_INCR;
  		}

  		surf_list = (struct GRid *) om$malloc(size = total_objs * 
			sizeof(struct GRid));
  		surf_ids = (GRobjid *) om$malloc(size = num_objs * 
			sizeof(GRobjid));
  		if(!surf_list || !surf_ids) {
     			*EMmsg = EMS_E_NoDynamicMemory;
     			goto wrapup;
  		}

		total_objs = 0;
     		sts = om$send(msg = message GRowner.GRget_components(
				EMmsg, &surf_info->module_info, 
				&surf_list[total_objs], count_surfs, 
				&num_objs, 0, MAXINT),
                    	targetid = proj_id,
			targetos = *osnum);
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

		total_objs += count_surfs;

  		for(i = 0 ; i < total_objs ; ++i)  
			surf_ids[i] = surf_list[i].objid;


		ex$message(msgnumb = EMS_I_Processing, buff = status_str);
		optionsEMboolean = EMSsfbool_opt_display | 
			EMSsfbool_opt_noredraw;

                if (OM_Gf_verbose_warning)
   	          fprintf(stderr, "slotfea sending EMboolean msg\n");

		sts = om$send(msg = message EMSsfboolean.EMboolean(EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				active_GRid->objid, 1,
				&proj_id, construct_list,
				bool_type, optionsEMboolean,
				status_str, NULL, NULL, &surf_ids, &total_objs),
			targetid = my_id);

     		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, wrapup);
    		if(*EMmsg == EMS_I_NoIntersection) 
			goto wrapup; 
		
		DisplayMode = GRbd;
  		for(i = total_objs - 1 ; i >= 0 ; --i) {
     			sts = om$send(msg = message GRgraphics.GRdisplay(
				&msg_loc, 
				&surf_info[0].module_info.md_env.matrix_type,
                		surf_info[0].module_info.md_env.matrix, 
                		&DisplayMode, &surf_info[0].module_info.md_id),
                	    targetid = surf_ids[i],
			    targetos = *osnum);
     			EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg,EMS_E_OMerror,
				wrapup);
		}
    	}  /* if */


wrapup:
    if(!(1 & sts & *EMmsg) || (*EMmsg == EMS_I_NoIntersection) ) {
	sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
			construct_list->env_info),
		targetid = proj_id,
		targetos = *osnum);
    } /* if */

    /* Delete the new profile created */
    if(temp_id != NULL_OBJID && is_comp) {
	OMuint comp_count;
	GRobjid *co_ids;
	OMuword dum_os;

	sts= EMmake_chanselect(GRcmpowner_to_components, &to_comps);

	sts = om$get_channel_count(p_chanselect = &to_comps,
			objid = temp_id,
			osnum = new_prof_id->osnum,
			count = &comp_count);

	co_ids = (GRobjid *) stackalloc(sizeof(GRobjid) * comp_count);
	EMerr_hndlr(!co_ids, *EMmsg, EMS_E_NoStackMemory,wrapup);

	/* get all the components */
	for(i = 0; i < comp_count; i++) {
		sts = om$get_objid_at_index(
			objid = temp_id,
			p_chanselect = &to_comps,
			index = i,
			objidaddr = &co_ids[i],
			osnumaddr = &dum_os);
	} /* for */

	/* delete all the components */
	for(i = 0; i < comp_count; i++) {
		sts = om$send(msg = message Root.delete(1),
			senderid = NULL_OBJID,
			targetid = co_ids[i],
			targetos = OM_Gw_current_OS);
	} /* for */
    } /* if */

    /* delete the owner */
    if(temp_id != NULL_OBJID) {
    	sts = om$send(msg = message Root.delete(1),
		senderid = NULL_OBJID,
		targetid = temp_id,
		targetos = new_prof_id->osnum);
    } /* if */

    if(swap_id != NULL_OBJID)
	new_prof_id->objid = swap_id;

    if(sortpts_info) om$dealloc(ptr = sortpts_info);
    if(bad_pts_info) om$dealloc(ptr = bad_pts_info);
    if(sf_inter_parm) om$dealloc(ptr = sf_inter_parm);
    if(cv_inter_parm) om$dealloc(ptr = cv_inter_parm);
    if(inter_pts) om$dealloc(ptr = inter_pts);
    if(inter_props) om$dealloc(ptr = inter_props);
    if(surf_list) om$dealloc(ptr = surf_list);
    if(surf_ids) om$dealloc(ptr = surf_ids);

    EMWRAPUP(*EMmsg, sts, "In EMSslslotfea.EMmake_slot")
    return(sts);

} /* EMmake_slot */

end implementation EMSslslotfea;
