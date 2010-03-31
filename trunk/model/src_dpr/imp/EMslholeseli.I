/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolfea;

/*
	This file contains EMhole_sel_boolean
*/

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMerrordef_include
#include "OMerrordef.h"
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igetypedef_include
#include "igetypedef.h"
#endif

#ifndef gr_include
#include "gr.h"
#endif

#ifndef igr_include
#include "igr.h"
#endif

#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"	/* for EMS_I_NoIntersection */
#endif

#ifndef EMSfeadef_include
#include "EMSfeadef.h"	/* for feature's struct */
#endif

#ifndef EMSopt_include
#include "EMSopt.h"
#endif

#ifndef EMSstruct_include
#include "EMSstruct.h"
#endif

#ifndef emssfintdef_include
#include "emssfintdef.h"  /* for EMSsfbool_opt_xxxx */
#endif

#ifndef emserr_include
#include "emserr.h"
#endif

#ifndef emsdef_include
#include "emsdef.h"	/* for MAXINT, DPR_DISPLAY_BUFF_INCR */
#endif

#ifndef EC_I_include
#include "EC_I.h"  /* for EMS_I_Processing */
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#endif

#ifndef msmacros_include
#include "msdef.h"
#include "msmacros.h"	/* for ex$message() */
#endif

#ifndef exmacros_include
#include "exmacros.h" 
#endif

#ifndef lcmacros_include
#include "lcmacros.h"
#endif

#include "EMSasfeatdef.h"
#include "EMSdef.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "bsconic.h"
#include "bssortptsln.h"
#include "bsproj0.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsbasisvect.h"

#define VBOTTOM	1	/* for the blind hole with v_bottom */

#define THR_ALL 	0
#define THR_UNTIL 	1
#define THR_NEXT 	2
#define BLIND		3	/* for checking a blind hole */

#define HALF_RADIAN	0.0087266462599716483
#define MAXNUM	10

from EMScylindr import  EMcylinder_by_axis_n_radius;
from EMScone	import  EMcone;
from EMSsubbs	import	EMpartolbasis, EMget_edges;
from EMSgencompsf import  EMmake_comp;
from EMSsfsolid import  EMcap_thyself;
from EMSloopset import EMpt_location;
from EMSedge import EMget_bcxyz_geom; 

extern OMuword  OPP_EMScone_class_id, OPP_EMScylindr_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword  OPP_EMSsfsolid_class_id;
extern OMuword  OPP_EMSdatpln_class_id;

method EMhole_sel_boolean(IGRlong *EMmsg; 
		IGRushort hole_type, *depth_type; 
		struct GRlc_info  *surf_info;
		IGRdouble *v_angle;
		struct GRvg_construct *construct_list;
		IGRint num_holes;
		struct EMShole *holes;
		struct GRid *active_GRid)
/*

Procedures:

(1) Surface construction:
    a) The circular hole type:
       1. constructs cylinder(s) and/or cone(s).
       2. stitches the surfaces to be a composite surface if any.
(2) Solid construction:
    Apply EMcap_thyself to make the EMScylindr/EMSproject/EMScompsurf object(s) 
    become a EMSsfsolid object(s).

(3) Difference special boolean operation

Variables:

IGRlong	 *EMmsg		O	return status.
IGRshort hole_type	I	hole type indicator :
				0 : for the regular circular hole.
				1 : for the blind hole with v bottom.
				2 : for the profile hole.
IGRshort *depth_type	I	depth indicator.
struct GRlc_info *surf_info  I 	surfaces information.
IGRdouble *v_angle	I	v bottom angle, it can be NULL if it is not
				a v bottom blind hole.
struct GRvg_construct *construct_list  I  construct information of holes;
IGRint	num_holes	I   	number of holes are constructed.
struct hole_data *holes   I/O	hole parts information.
struct GRid *active_GRid   I	active state id.

History:

Tapadia  09/09/92	Genesis 
Rustagi  05/21/93       Changes are scattered all over the file to
                        incorporate the new sort point generation
                        functionality. It was done to make a fix for
                        TR # 119304943 where problem was occuring due
                        to wrong sort points. I have made changes only
                        for Thru_all case.
Sudha    06/23/93       Modified for BSprototype ansification                
NP       09/09/93       Changed paramter"sortpts_info" and "bad_pts_info" from
                        struct EMSsortpt_info to struct EMparms. Change was due
                        to change in selective boolean fn. parameter change. All
                        other related changes also made in this fn.
Aditya	4/28/95         Fix for TR#119423280. Return without abort if
                        hole axis doesn't intersect solid.
Aditya  7/17/95         Fix for TR#119423568 abort.
*/
{
  	IGRboolean  	sts_fun, world = TRUE, fin_flag, end_ref_plane;
  	IGRlong  	sts, msg_loc, num_slots, num_intersect;
  	IGRint  	m, kk, i, pt_size, sort_ind[8], num_sort_pts, 
			sub_sort_pts, k, j1, j2, num_bad_pts, tot_sort_pts, 
			next_st_ind, next_nxt_ind, until_ind;
  	IGRdouble  	vec[3], tanv, d_r, cone_rads[2], delx, dely, delz, 
			proj_line[2][3], *inter_pts, poles[6], knots[4], 
			test_dist, fin_dist;
  	IGRvector  	vec1, vec2, vec3;
  	OM_S_OBJID  	surfs[2], surf_id, finite_id;
  	GRobjid  	*holes_id, hole_objs[MAXNUM], *hl_id;
        struct GRid     *circid=NULL, cirobjs[MAXNUM];
        IGRint          num_so_rt[MAXNUM];
  	GRspacenum  	*osnum;
  	struct EMSradius  radius_stuff;
extern IGRboolean EFisAncestryValid() ;
	GRrange 	range;
	IGRpoint 	min_range, max_range, min_pt, max_pt, start_pt, mid_pt,
			axis_line[2], ran_sort_pts[8], pl_cre_pts[8], sec_pt, 
			surf_pt, sf_uv_pt2, sf_uv_pt1, first_pt;
	struct GRparms	*sf_inter_parm, *cv_inter_parm;
	IGRulong 	*inter_props;
	struct IGRbsp_curve curve;
	struct EMparms  *sortpts_info = NULL, *bad_pts_info = NULL;
	struct GRid 	hole_bool_id;
	extern void 	EFperform_special_boolean();
	struct EMSpartolbasis partolbasis;
	enum EMSbooltype bool_type;
	struct GRparms 	proj_parms;
	OM_S_CHANSELECT sf_ls_chan;
	OM_S_OBJECT_LINKAGE ls_list;
	OMuint 		num_ls;

/* RUSTAGI -  I defined the following variables  to incorporate the
 *  new sort point generation functionality.
 */
        BSrc rc;
        IGRdouble  my_vec[3];
        struct GRid feasfs;
        IGRint  index, *numsort=NULL, newsize=0;
        IGRlong feaopts, matopts;
        IGRdouble vec_mag, uvalu[2];
        struct EMparms *thesort=NULL, *sortpoints=NULL;
        extern IGRlong EMgen_rightsortpts();

	IGRdouble dist_tol, dot_val;
	IGRvector tmp_vec;
        OM_S_OBJID save_md_id;
	
  	/* initialize */
  	sts = OM_S_SUCCESS;
  	*EMmsg = EMS_S_Success;
  	osnum = &surf_info[0].located_obj.osnum;
	pt_size = sizeof(IGRpoint);
	bool_type = EMSbool_difference;
	hole_bool_id.objid = my_id;
	hole_bool_id.osnum = *osnum;
	end_ref_plane = FALSE;
	tot_sort_pts = sub_sort_pts = 0;

        uvalu[0] = 0.25;
        uvalu[1] = 0.75;

        if(*depth_type == THR_ALL) feaopts = EMSfeature_thru_all;
        else
        if(*depth_type == THR_NEXT) feaopts = EMSfeature_thru_next;
        else
        if(*depth_type == THR_UNTIL) feaopts = EMSfeature_thru_until;

        matopts = EMSremove_material;


	/* To check if the end surface is reference plane */
	if(*depth_type == THR_UNTIL) {
	    if(EFisAncestryValid(&msg_loc, surf_info[1].located_obj.objid,
		surf_info[1].located_obj.osnum, OPP_EMSdatpln_class_id,
		FALSE)) 
	    end_ref_plane= TRUE;
	}

	/* Get the solid range limits */
	sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
			&surf_info[0].module_info.md_env.matrix_type,
			surf_info[0].module_info.md_env.matrix,
			&world, range),
		senderid = NULL_OBJID,
		targetid = active_GRid->objid,
		targetos = active_GRid->osnum);

   	EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

	sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
	dist_tol *= 100;
		
	OM_BLOCK_MOVE(&range[0], min_range, pt_size);
	OM_BLOCK_MOVE(&range[3], max_range, pt_size);
        vec_mag = BSdistptpt(&rc, min_range, max_range);

  	if(num_holes > MAXNUM) {
     	 holes_id = (GRobjid *)om$malloc(size = num_holes * sizeof(GRobjid));
     	 hl_id = (GRobjid *)om$malloc(size = num_holes * sizeof(GRobjid));
         circid = (struct GRid *) om$malloc(size = num_holes * 
                                       sizeof(struct GRid));
         numsort = (IGRint *) om$malloc(size = num_holes * sizeof(IGRint));
     	 if(!holes_id || !hl_id || !circid || !numsort){
        	*EMmsg = EMS_E_NoDynamicMemory;
		goto wrapup;
     	    }
  	}
  	else  {
	    holes_id = hole_objs;
	    hl_id = hole_objs;
            circid = cirobjs;
            numsort = num_so_rt;
	}
	sortpts_info = (struct EMparms *) malloc(
			4 * num_holes * sizeof(struct EMparms));

	if(!sortpts_info) {
		*EMmsg = EMS_E_NoDynamicMemory;
		goto wrapup;
	}

	partolbasis.in_world = TRUE;
	partolbasis.mattyp = &surf_info[0].module_info.md_env.matrix_type;
	partolbasis.mat = surf_info[0].module_info.md_env.matrix;

  /* 
   * Construct the solid cylinder(s) (hole part)
   */

  if(*depth_type == BLIND && hole_type == VBOTTOM)
  {
     IGRdouble  angle;
     extern IGRdouble  tan();

     angle = *v_angle * HALF_RADIAN;
     tanv = tan(angle);
  }
  radius_stuff.select = 0;  /* by radius value */

  for(i = 0 ; i < num_holes ; ++i)
  {
	fin_flag = TRUE;
	sf_inter_parm = cv_inter_parm = NULL;
	inter_pts = NULL;
	inter_props = NULL;
	num_slots = num_intersect = 0;
	radius_stuff.input.value = holes[i].radius;

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

    	vec[0] = holes[i].axis_line[1][0] - holes[i].axis_line[0][0];
    	vec[1] = holes[i].axis_line[1][1] - holes[i].axis_line[0][1];
    	vec[2] = holes[i].axis_line[1][2] - holes[i].axis_line[0][2];
        for(index=0; index<3; index++)
         my_vec[index] = vec[index];
	BSnorvec(&msg_loc, vec);

	OM_BLOCK_MOVE(holes[i].axis_line[0], start_pt, pt_size);
	OM_BLOCK_MOVE(start_pt, proj_line[0], pt_size);

	proj_line[1][0] = holes[i].axis_line[0][0] + vec[0];
	proj_line[1][1] = holes[i].axis_line[0][1] + vec[1];
	proj_line[1][2] = holes[i].axis_line[0][2] + vec[2];

	BSproj0(&msg_loc, min_range, proj_line, min_pt);
	BSproj0(&msg_loc, max_range, proj_line, max_pt);

	/* find the difference in x, y & z to compute the solid 8 points */
	delx = range[3] - range[0];
	dely = range[4] - range[1];
	delz = range[5] - range[2];

	OM_BLOCK_MOVE(&range[0], pl_cre_pts[0], pt_size);
	OM_BLOCK_MOVE(&range[3], pl_cre_pts[7], pt_size);

	OM_BLOCK_MOVE(&range[0], pl_cre_pts[1], pt_size);
	pl_cre_pts[1][0] = range[0] + delx;
	OM_BLOCK_MOVE(&range[0], pl_cre_pts[2], pt_size);
	pl_cre_pts[2][1] = range[1] + dely;
	OM_BLOCK_MOVE(&range[0], pl_cre_pts[3], pt_size);
	pl_cre_pts[3][2] = range[2] + delz;
	
	OM_BLOCK_MOVE(&range[3], pl_cre_pts[4], pt_size);
	pl_cre_pts[4][0] = range[3] - delx;
	OM_BLOCK_MOVE(&range[3], pl_cre_pts[5], pt_size);
	pl_cre_pts[5][1] = range[4] - dely;
	OM_BLOCK_MOVE(&range[3], pl_cre_pts[6], pt_size);
	pl_cre_pts[6][2] = range[5] - delz;

	for(k = 0; k < 8; k++) 
		BSproj0(&msg_loc, pl_cre_pts[k], proj_line, ran_sort_pts[k]);

        for(k = 0; k < 8; k++) sort_ind[k]=0; /**Initialize**/
	/* sort all the 8 points - start point, min_pt & max_pt */
	BSsortptsln(8, FALSE, ran_sort_pts, NULL, sort_ind, &msg_loc);

        for(k = 0; k < 8; k++)
        {
             /* This will prevent reading of the ran_sort_pts array
              * beyond its bounds. Fix for TR119423568 Abort.
              */
             if( sort_ind[k] < 0 || sort_ind[k] > 7)
               EMerr_hndlr(TRUE, *EMmsg, EMS_E_Fail, wrapup);
        }

	if(*depth_type != BLIND && !end_ref_plane) {
		IGRint sign;

    		tmp_vec[0] = ran_sort_pts[sort_ind[7]][0] -  
			ran_sort_pts[sort_ind[0]][0];
    		tmp_vec[1] = ran_sort_pts[sort_ind[7]][1] -  
			ran_sort_pts[sort_ind[0]][1];
    		tmp_vec[2] = ran_sort_pts[sort_ind[7]][2] -  
			ran_sort_pts[sort_ind[0]][2];

		BSnorvec(&msg_loc, tmp_vec);

		dot_val = BSdotp(&msg_loc, tmp_vec, vec);

		if(dot_val > 0) sign = -1;
		else sign = 1;

		axis_line[0][0] = ran_sort_pts[sort_ind[7]][0] - 
			vec[0] * dist_tol * sign;
		axis_line[0][1] = ran_sort_pts[sort_ind[7]][1] - 
			vec[1] * dist_tol * sign;
		axis_line[0][2] = ran_sort_pts[sort_ind[7]][2] - 
			vec[2] * dist_tol * sign;
		axis_line[1][0] = ran_sort_pts[sort_ind[0]][0] + 
			vec[0] * dist_tol * sign;
		axis_line[1][1] = ran_sort_pts[sort_ind[0]][1] +
			vec[1] * dist_tol * sign;
		axis_line[1][2] = ran_sort_pts[sort_ind[0]][2] +
			vec[2] * dist_tol * sign;
	}
	else {
    		tmp_vec[0] = holes[i].axis_line[1][0] - 
				ran_sort_pts[sort_ind[7]][0];
    		tmp_vec[1] = holes[i].axis_line[1][1] -  
				ran_sort_pts[sort_ind[7]][1];
    		tmp_vec[2] = holes[i].axis_line[1][2] - 
				ran_sort_pts[sort_ind[7]][2]; 

		BSnorvec(&msg_loc, tmp_vec);

		dot_val = BSdotp(&msg_loc, tmp_vec, vec);

		if(dot_val < 0.0) {
			axis_line[0][0] = ran_sort_pts[sort_ind[0]][0];
			axis_line[0][1] = ran_sort_pts[sort_ind[0]][1];
			axis_line[0][2] = ran_sort_pts[sort_ind[0]][2];
		}
		else {
			axis_line[0][0] = ran_sort_pts[sort_ind[7]][0];
			axis_line[0][1] = ran_sort_pts[sort_ind[7]][1];
			axis_line[0][2] = ran_sort_pts[sort_ind[7]][2];
		}
		axis_line[0][0] = axis_line[0][0] - vec[0] * dist_tol;	
		axis_line[0][1] = axis_line[0][1] - vec[1] * dist_tol;	
		axis_line[0][2] = axis_line[0][2] - vec[2] * dist_tol;	
		OM_BLOCK_MOVE(holes[i].axis_line[1], axis_line[1], pt_size);
	}
	sts_fun = BSbasisvect(EMmsg, vec, vec1, vec2, vec3);
	if(!sts_fun || *EMmsg != 0) {
    	    	*EMmsg = EMS_E_Success;
	    	goto  wrapup;
	} /* if */

	d_r = radius_stuff.input.value/tanv;
	if(*depth_type == THR_ALL) {
		curve.poles[0] = ran_sort_pts[sort_ind[7]][0];
		curve.poles[1] = ran_sort_pts[sort_ind[7]][1];
		curve.poles[2] = ran_sort_pts[sort_ind[7]][2];
		curve.poles[3] = ran_sort_pts[sort_ind[0]][0];
		curve.poles[4] = ran_sort_pts[sort_ind[0]][1];
		curve.poles[5] = ran_sort_pts[sort_ind[0]][2];
	}
	else {
	    curve.poles[0] = holes[i].axis_line[0][0]; 
	    curve.poles[1] = holes[i].axis_line[0][1];
	    curve.poles[2] = holes[i].axis_line[0][2];
	    if(hole_type == VBOTTOM) {
	        curve.poles[3] = holes[i].axis_line[1][0] + vec1[0] * d_r;
	    	curve.poles[4] = holes[i].axis_line[1][1] + vec1[1] * d_r;
	    	curve.poles[5] = holes[i].axis_line[1][2] + vec1[2] * d_r;
	    }
	    else {
	        curve.poles[3] = holes[i].axis_line[1][0];
	    	curve.poles[4] = holes[i].axis_line[1][1];
	    	curve.poles[5] = holes[i].axis_line[1][2];
	    }
	}

	sts = om$construct(classid = OPP_EMScylindr_class_id,
			msg = message EMScylindr.EMcylinder_by_axis_n_radius(
			construct_list, axis_line[0], axis_line[1], 
			&radius_stuff),
		p_objid = &surf_id,
		osnum = *osnum);
     	EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

	if(hole_type == VBOTTOM) {
	    IGRint  sts_loc;

	    axis_line[1][0] = curve.poles[3];
	    axis_line[1][1] = curve.poles[4];
	    axis_line[1][2] = curve.poles[5];

	    /* construct the cylinder surface */

	    surfs[0] = surf_id;

	    sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
			EMmsg, &construct_list->env_info->md_env, NULL),
		targetid = surfs[0],
		targetos = *osnum);
     	    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	    /* construct the cone surface */

            cone_rads[0] = radius_stuff.input.value;
            cone_rads[1] = 0.0;
	    OM_BLOCK_MOVE(holes[i].axis_line[1], axis_line[0], pt_size);

	    test_dist = BSdistptpt(&msg_loc, axis_line[0], axis_line[1]);

            sts = om$construct(classid = OPP_EMScone_class_id,
			msg = message EMScone.EMcone(&sts_loc, 
			construct_list, axis_line, cone_rads),
		p_objid = &surfs[1],
		osnum = *osnum);
            EMerr_hndlr(!(1 & sts & *construct_list->msg & sts_loc), 
			*EMmsg, EMS_E_OMerror, wrapup);

	    sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
			EMmsg, &construct_list->env_info->md_env, NULL),
		targetid = surfs[1],
		targetos = *osnum);
     	    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	    /* connect the cylinder and cone to become a comp surface */

	    sts = om$construct(classid = OPP_EMSgencompsf_class_id,
			msg = message EMSgencompsf.EMmake_comp(EMmsg, 
			2, surfs, construct_list->env_info), 
		  p_objid = &surf_id,
		  osnum = *osnum);
     	    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
	    finite_id = surf_id;
        } /* v_bottom hole */

    	sts = om$construct(classid = OPP_EMSsfsolid_class_id,
			msg = message EMSsfsolid.EMcap_thyself(
			EMmsg, construct_list, &surf_id),
		p_objid = &holes_id[i],
		osnum = *osnum);
    	if(!(1 & sts & *EMmsg & *construct_list->msg)) {
       		sts = om$send(msg = message GRgraphics.GRdelete(EMmsg,
				construct_list->env_info),
		    	targetid = surf_id,
		    	targetos = *osnum);

       		*EMmsg = EMS_E_Success;
       		goto  wrapup;
    	}

	if(hole_type == VBOTTOM) 
		surf_id = surfs[0];

	sts = EMmake_chanselect(EMSsubbs_to_loopset, &sf_ls_chan);
	if(!(1 & sts)) goto wrapup;

	sts = om$get_channel_objects(objid = surf_id,
			osnum = *osnum,
			p_chanselect = &sf_ls_chan,
			list = &ls_list, size = 1, count = &num_ls);

	EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);
	
  	sts = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg,
			&surf_info[0].module_info.md_env.matrix_type,
			surf_info[0].module_info.md_env.matrix, 
			&world, NULL, &partolbasis.tol),
	     	senderid = NULL_OBJID,
	    	targetid = surf_id, 
		targetos = *osnum);
     	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	sts = om$send(msg = message EMSsolid.EMcrvsrfint(EMmsg, NULL,
			&surf_info[0].module_info.md_env,
			&curve, NULL, NULL, FALSE, &num_slots,
			&num_intersect, NULL, &sf_inter_parm,
			&cv_inter_parm, &inter_pts, &inter_props),
		senderid = NULL_OBJID,
		targetid = active_GRid->objid,
		targetos = active_GRid->osnum);

        /* Fix for TR#119423280 */
     	EMerr_hndlr(!(1 & sts & *EMmsg) || !num_intersect, *EMmsg, 
                    EMS_E_Fail, wrapup);
	
	/* sort the intersections obtained */

	EMsort_by_parameter(sf_inter_parm,cv_inter_parm, inter_pts,
		inter_props, num_intersect);

	if(*depth_type == THR_ALL) {
	    for(kk = 0; kk < num_intersect; kk++) {
		if(surf_info[0].located_obj.objid == 
		    sf_inter_parm[kk].leaf_id.objid) {
			next_st_ind = kk;
		}
	    }
	    if(next_st_ind % 2 != 0) {
		num_sort_pts = (next_st_ind + 1)/2;
		next_st_ind = 0;
	    }
	    else if(next_st_ind != 0) 
	    	num_sort_pts = ((IGRint)num_intersect - next_st_ind)/2;
	    else 
	    	num_sort_pts = (IGRint)num_intersect/2;
	}

	if(*depth_type == THR_NEXT) {
	    num_sort_pts = 1;
	    for(kk = 0; kk < num_intersect; kk++) {
		if(surf_info[0].located_obj.objid == 
		    sf_inter_parm[kk].leaf_id.objid) {
			next_st_ind = kk;
			next_nxt_ind = kk + 1;
		}
	    }
	}
	if(*depth_type == THR_UNTIL) {
	    if(!end_ref_plane) {
		next_nxt_ind = -1;
	    	for(kk = 0; kk < num_intersect; kk++) {
		    if(surf_info[0].located_obj.objid == 
		    	sf_inter_parm[kk].leaf_id.objid) 
				next_st_ind = kk;
		    if(surf_info[1].located_obj.objid == 
		    	sf_inter_parm[kk].leaf_id.objid) 
				next_nxt_ind = kk;
		}
		if(next_nxt_ind == -1) {
			*EMmsg = EMS_E_Fail;
			goto wrapup;
		}
	        until_ind = abs(next_st_ind - next_nxt_ind);
	        if(until_ind % 2 != 0)
		    num_sort_pts = (until_ind + 1)/2;
	    	else 
		    num_sort_pts = until_ind/2;
	    }
	    else { /* when we have an end reference plane */
		if(num_intersect % 2 != 0) 
			*depth_type = BLIND;  
		else {
			num_sort_pts = num_intersect/2;
			*depth_type = THR_ALL;  
		}
	    }
	}
	if(*depth_type == BLIND) {
	    if(num_intersect % 2 != 0)
		num_sort_pts = (num_intersect + 1)/2;
	    else 
		num_sort_pts = num_intersect/2;
	}
	sub_sort_pts += num_sort_pts;

	if(sub_sort_pts > (4 * num_holes)) 
        {
		sortpts_info = (struct EMparms *) om$realloc(
			ptr = (IGRchar *) sortpts_info, size = 
			(sub_sort_pts + 4) * sizeof(struct EMparms));

		if(!sortpts_info) 
                {
			*EMmsg = EMS_E_NoDynamicMemory;
			goto wrapup;
		}
	}
	hl_id[i] = holes_id[i];

	if(*depth_type != BLIND) 
        {
    	    for(m = 0; m < num_sort_pts; m++) 
            {
		if(*depth_type == THR_NEXT) 
                {
			j1 = next_st_ind;
			j2 = next_nxt_ind;
		}
		else if(*depth_type == THR_UNTIL || *depth_type == THR_ALL) 
                {
			j1 = next_st_ind + (2 * m);
			j2 = next_st_ind + (2 * m) + 1;
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

		sts = om$send(msg = message EMSsubbs.GRptproject(EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				mid_pt, surf_pt, &proj_parms),
		    	senderid = NULL_OBJID,
			targetid = surf_id,
			targetos = *osnum);
	
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	
		sortpts_info[m+tot_sort_pts].leaf_id.objid = surf_id;
		sortpts_info[m+tot_sort_pts].leaf_id.osnum = *osnum;
		sortpts_info[m+tot_sort_pts].u             = proj_parms.u;
		sortpts_info[m+tot_sort_pts].v             = proj_parms.v;
                

/****** THIS STUFF NOT NEEDED ********
		sortpts_info[m+tot_sort_pts].md_env = surf_info[0].module_info;
	
		sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg,
				surf_uv_pt, 
				&sortpts_info[m + tot_sort_pts].ptloc_info,
				&partolbasis),
			senderid = NULL_OBJID,
			targetid = ls_list.S_objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, wrapup);
	
		* If point location does not return location as either on 
		edge or on vertex, replace the pt_location closest point by 
		sf_uv_pt 
                *
	
	   	if((sortpts_info[m + tot_sort_pts].ptloc_info.location != 
			EMS_L_ONEDGE) && 
			(sortpts_info[m + tot_sort_pts].ptloc_info.location != 
			EMS_L_ONVRTX))
		    OM_BLOCK_MOVE(surf_uv_pt, 
	 	  	sortpts_info[m+tot_sort_pts].ptloc_info.edge[0].nst_pt.proj_pt,
		    	sizeof(IGRdouble)*2);
		sortpts_info[m + tot_sort_pts].sf_id = surf_id,
		sortpts_info[m + tot_sort_pts].xyz_pt[0] = surf_pt[0];
	   	sortpts_info[m + tot_sort_pts].xyz_pt[1] = surf_pt[1]; 
		sortpts_info[m + tot_sort_pts].xyz_pt[2] = surf_pt[2];
		sortpts_info[m + tot_sort_pts].ed_oprnd  = 1;

**********************************************/


   	    } /* for */
	}
	else 
        {
    	    for(m = 0; m < num_sort_pts; m++) 
            {
		if(num_intersect < 2) 
                {
			OM_BLOCK_MOVE(holes[i].axis_line[0], first_pt, pt_size);
			OM_BLOCK_MOVE(holes[i].axis_line[1], sec_pt, pt_size);
		}
		else if(num_intersect % 2 == 1) 
                {
		    j1 = 2 * m;
	
		    sf_uv_pt1[0] = sf_inter_parm[j1].u;
		    sf_uv_pt1[1] = sf_inter_parm[j1].v;

		    sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, first_pt),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[j1].leaf_id.objid,
			targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     		    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

		    if(m == (num_sort_pts - 1) && hole_type == VBOTTOM) 
                    {
	    	        fin_dist = BSdistptpt(&msg_loc, first_pt, axis_line[1]);
		    	if(fin_dist >= test_dist)
			    fin_flag = FALSE;
		    }

		    if(m == (num_sort_pts - 1)) 
                    { 
			if(hole_type == VBOTTOM) 
                        {
			  if(fin_flag) 
                          {
			    surf_id = surfs[1];
			    sts = om$get_channel_objects(objid = surf_id,
				osnum = *osnum,
				p_chanselect = &sf_ls_chan,
				list = &ls_list, size = 1, count = &num_ls);

			    EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, 
				wrapup);
			    OM_BLOCK_MOVE(axis_line[1], first_pt, pt_size);
			    OM_BLOCK_MOVE(axis_line[1], sec_pt, pt_size);
  			    sts = om$send(msg = message EMSsubbs.EMpartolbasis(
				EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				&world, NULL, &partolbasis.tol),
	     		      senderid = NULL_OBJID,
	    		      targetid = surf_id, 
			      targetos = *osnum);

     			    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg,EMS_E_Fail,
					wrapup);
			  }
			  else
				OM_BLOCK_MOVE(axis_line[0], sec_pt, pt_size);
			}
			else 
				OM_BLOCK_MOVE(axis_line[1], sec_pt, pt_size);
		    }
		    else 
                    {
			j2 = 2 * m + 1;
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
		    }
		}
		else if(num_intersect % 2 == 0) 
                {
		    j1 = 2 * m;
		    j2 = 2 * m + 1;
	
		    sf_uv_pt1[0] = sf_inter_parm[j1].u;
		    sf_uv_pt1[1] = sf_inter_parm[j1].v;

		    sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt1, 2, first_pt),
			senderid = NULL_OBJID,
			targetid = sf_inter_parm[j1].leaf_id.objid,
			targetos = sf_inter_parm[j1].leaf_id.osnum);
	
     		    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
		    sf_uv_pt2[0] = sf_inter_parm[j2].u;
		    sf_uv_pt2[1] = sf_inter_parm[j2].v;

		    sts = om$send(msg = message GRvg.EMptatpr(EMmsg, 
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix,
				sf_uv_pt2, 2, sec_pt),
			    senderid = NULL_OBJID,
			    targetid = sf_inter_parm[j2].leaf_id.objid,
			    targetos = sf_inter_parm[j2].leaf_id.osnum);
	
     		    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
		}
	
		mid_pt[0] = (first_pt[0] + sec_pt[0])/2.0;
		mid_pt[1] = (first_pt[1] + sec_pt[1])/2.0;
		mid_pt[2] = (first_pt[2] + sec_pt[2])/2.0;

		sts = om$send(msg = message EMSsubbs.GRptproject(EMmsg,
				&surf_info[0].module_info.md_env.matrix_type,
				surf_info[0].module_info.md_env.matrix, 
				mid_pt, surf_pt, &proj_parms),
		    	senderid = NULL_OBJID,
			targetid = surf_id,
			targetos = *osnum);
	
     		EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	
		if(hole_type == VBOTTOM)
			surf_id = surfs[0];

                sortpts_info[m+tot_sort_pts].leaf_id.objid = surf_id;
                sortpts_info[m+tot_sort_pts].leaf_id.osnum = *osnum;
                sortpts_info[m+tot_sort_pts].u             = proj_parms.u;
                sortpts_info[m+tot_sort_pts].v             = proj_parms.v;
	
/*********** THIS STUFF NOT NEEDED ***************
		sortpts_info[m+tot_sort_pts].md_env = surf_info[0].module_info;
	
		sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg,
				surf_uv_pt, 
				&sortpts_info[m + tot_sort_pts].ptloc_info,
				&partolbasis),
			senderid = NULL_OBJID,
			targetid = ls_list.S_objid,
			targetos = *osnum);

     		EMerr_hndlr(!(1 & sts & *EMmsg),*EMmsg, EMS_E_Fail, wrapup);
	
		* If point location does not return location as either on 
		edge or on vertex, replace the pt_location closest point by 
		sf_uv_pt 
                *
	
	   	if((sortpts_info[m + tot_sort_pts].ptloc_info.location != 
			EMS_L_ONEDGE) && 
			(sortpts_info[m + tot_sort_pts].ptloc_info.location != 
			EMS_L_ONVRTX))
		    OM_BLOCK_MOVE(surf_uv_pt, 
	 	  	sortpts_info[m+tot_sort_pts].ptloc_info.edge[0].nst_pt.proj_pt,
		    	sizeof(IGRdouble)*2);

		if(hole_type == VBOTTOM)
			surf_id = surfs[0];

		sortpts_info[m + tot_sort_pts].sf_id = surf_id,
		sortpts_info[m + tot_sort_pts].xyz_pt[0] = surf_pt[0];
	   	sortpts_info[m + tot_sort_pts].xyz_pt[1] = surf_pt[1]; 
		sortpts_info[m + tot_sort_pts].xyz_pt[2] = surf_pt[2];
		sortpts_info[m + tot_sort_pts].ed_oprnd  = 1;

 **********************************************/

	    }
   	}
/********************************************************************/
        {
        /* Rustagi - Here are the major changes TR # 119304943 */

        if(*depth_type == THR_ALL)
         {
         IGRint numcomp, array_size=0, numedges=0,tmp;
         IGRdouble value1, value2;
         struct GRparms projparms;
         IGRboolean flag;
         struct GRid *compids=NULL, *edge_GRids=NULL;
         struct IGRbsp_curve edge_geometry;
         IGRpoint projpt;

         feasfs.objid = hl_id[i];
         feasfs.osnum = active_GRid->osnum;
         circid[i].osnum = active_GRid->osnum;
         sts = EMget_component_info(&msg_loc, &feasfs, 
                 &surf_info[0].module_info, &numcomp, &compids, &flag);
         sts = om$send(msg = message EMSsubbs.EMget_edges(&msg_loc,
                        MAXINT, EMS_OPT_ALL, &surf_info[0].module_info,
                        &edge_GRids, &array_size, &numedges),
                      senderid = NULL_OBJID,
                      targetid = compids[2].objid,
                      targetos = compids[2].osnum);
         EMSmsgReport(sts, "EMhole_sel_boolean:EMSsubbs.EMget_edges",FALSE);
         edge_geometry.weights = NULL;
         edge_geometry.poles = NULL;
         edge_geometry.knots = NULL;
         edge_geometry.bdrys = NULL;
         sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                           &surf_info[0].module_info.md_env, &compids[2],
                           (struct IGRbsp_surface *)NULL, (IGRint) 0, MAXINT,
                           FALSE, NULL, &edge_geometry),
                        senderid = NULL_OBJID,
                        targetid = edge_GRids[0].objid,
                        targetos = edge_GRids[0].osnum);
         EMSmsgReport(sts, "EMhole_sel_boolean:EMSedge.EMgetbcgeom", FALSE);
         circid[i].osnum = edge_GRids[0].osnum;
         sts = om$construct(classid = OPP_GR3dcircle_class_id,
                         p_objid = &(circid[i].objid),
                         osnum =   circid[i].osnum);
         construct_list->geometry = (IGRchar *)(&edge_geometry);
         save_md_id = construct_list->env_info->md_id.objid;
         construct_list->env_info->md_id.objid = NULL_OBJID;
         sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
                         senderid = NULL_OBJID,
                         targetid = circid[i].objid,
                         targetos = circid[i].osnum); 
         construct_list->env_info->md_id.objid = save_md_id;
         EMSmsgReport(sts, "EMhole_sel_boolean:GRgraphics.GRconstruct", FALSE);
         sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                              &surf_info[0].module_info.md_env.matrix_type,
                              surf_info[0].module_info.md_env.matrix,
                              &holes[i].axis_line[0][0], projpt, &projparms),
                       senderid = NULL_OBJID,
                       targetid = compids[2].objid,
                       targetos = compids[2].osnum);
         EMSmsgReport(msg_loc, "EMhole_sel_boolean:GRowner.GRptproject", FALSE);
         value1 = BSdistptpt(&rc, &holes[i].axis_line[0][0], projpt);
         sts = om$send(msg = message GRowner.GRptproject(&msg_loc,
                              &surf_info[0].module_info.md_env.matrix_type,
                              surf_info[0].module_info.md_env.matrix,
                              &holes[i].axis_line[1][0], projpt, &projparms),
                       senderid = NULL_OBJID,
                       targetid = compids[2].objid,
                       targetos = compids[2].osnum);
         EMSmsgReport(msg_loc, "EMhole_sel_boolean:GRowner.GRptproject", FALSE);
         value2 = BSdistptpt(&rc, &holes[i].axis_line[1][0], projpt);
         if(value2 < value1 )
         {
         for(tmp=0; tmp<3; tmp ++)
          my_vec[tmp] = - my_vec[tmp]; 
         }
         sts = EMgen_rightsortpts(&msg_loc, &circid[i],
                         &surf_info[0].module_info, &holes[i].axis_line[0],
                         my_vec, vec_mag, NULL, active_GRid, &feasfs, NULL,
                        &surf_info[0].module_info, 2, uvalu, feaopts, matopts,
                        construct_list, &numsort[i], &thesort);                                                        
         newsize = newsize + numsort[i];
         if(i == 0)
         {
         sortpoints = (struct EMparms *)om$malloc(size = newsize *
                                 sizeof(struct EMparms));
         EMerr_hndlr (!sortpoints, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         OM_BLOCK_MOVE(thesort, &sortpoints[0],
                             newsize * sizeof(struct EMparms));
         }
         else
         {
        sortpoints = (struct EMparms *)om$realloc(
                                ptr = (IGRchar *)sortpoints,
                                size = newsize * sizeof(struct EMparms));
        EMerr_hndlr (!sortpoints, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        OM_BLOCK_MOVE(thesort, &sortpoints[(newsize - numsort[i])] ,
                            numsort[i] * sizeof(struct EMparms));
         }
        if(thesort) om$dealloc (ptr = thesort); thesort=NULL;
        if(compids) om$dealloc (ptr = compids); compids = NULL;
        if(edge_geometry.weights)om$dealloc(ptr = edge_geometry.weights);
        if(edge_geometry.poles)om$dealloc(ptr = edge_geometry.poles);
        if(edge_geometry.knots)om$dealloc(ptr = edge_geometry.knots);
        if(edge_geometry.bdrys)om$dealloc(ptr = edge_geometry.bdrys);
       } 
      }
        tot_sort_pts += num_sort_pts;
    	if(sf_inter_parm) om$dealloc(ptr = sf_inter_parm);
    	if(cv_inter_parm) om$dealloc(ptr = cv_inter_parm);
    	if(inter_pts) om$dealloc(ptr = inter_pts);
    	if(inter_props) om$dealloc(ptr = inter_props);
  } /* for (hole construction) */

  /* Call selective boolean for holes */
        if(*depth_type == THR_ALL)
        {
         EFperform_special_boolean(EMmsg, &surf_info[0].module_info,
                     active_GRid->objid, num_holes, hl_id, 0,
                     construct_list, bool_type, newsize, sortpoints, NULL,
                     &num_bad_pts, &bad_pts_info, hole_bool_id);
        }
        else
        {
        EFperform_special_boolean(EMmsg, &surf_info[0].module_info,
			active_GRid->objid, num_holes, hl_id, 0, 
			construct_list, bool_type, tot_sort_pts, 
			&sortpts_info[0], NULL, 
			&num_bad_pts, &bad_pts_info, hole_bool_id);
        }
wrapup:
   if(*depth_type == THR_ALL)
   { 
    if(num_holes > MAXNUM)
    {
    if(numsort) om$dealloc (ptr = numsort);
    if(circid) om$dealloc (ptr = circid);
    }
    if(sortpoints) om$dealloc (ptr = sortpoints);
    for(i=0; i<num_holes; i++)
     {
     sts = om$send (msg = message Root.delete(1),
                         targetid = circid[i].objid,
                         targetos = circid[i].osnum,
                         senderid = NULL_OBJID);
     }
    }

    if(!(1 & sts & *EMmsg)) {
	for(i = 0; i < num_holes; i++) {
	    IGRlong l_msg;

	    enum GRdpmode DisplayMode;

  	    DisplayMode = GRbe;
     	    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                	&surf_info[0].module_info.md_env.matrix_type,
                	surf_info[0].module_info.md_env.matrix, 
                	&DisplayMode, &surf_info[0].module_info.md_id),
                targetid = hl_id[i],
		targetos = *osnum);

	    sts = om$send(msg = message GRgraphics.GRdelete(&l_msg,
			construct_list->env_info),
		senderid = NULL_OBJID,
		targetid = hl_id[i],
		targetos = *osnum);
	}
    }
    if(bad_pts_info) om$dealloc(ptr = bad_pts_info);
    if(sortpts_info) om$dealloc(ptr = sortpts_info);
    if(num_holes > MAXNUM && holes_id)  om$dealloc(ptr = holes_id);
    if(num_holes > MAXNUM && hl_id)  om$dealloc(ptr = hl_id);
    EMWRAPUP(*EMmsg, sts, "In EMhole_sel_boolean")
    return(sts);
} /* EMhole_sel_boolean */

end implementation EMSslboolfea;
