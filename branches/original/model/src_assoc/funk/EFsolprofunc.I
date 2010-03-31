/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
 * History:
 *
 * WBC     - 09/09/93 : Using alloca to allocate memory for comp_ids instead
 *                      of declaring an array of 10 since elements with more
 *                      than 10 components were causing writes past the end
 *                      of the array (overwriting memory).  This fixes
 *                      TR 1193009595.
 * Sudhakar- 30Jun'93 : Fix for TR#119302045. Modified the two functions
 *                       'EFget_axis_from_curve_one_pl()' and
 *                       'EFget_axis_from_curve_two_pls()' as follows:
 *                         a) added an additional arg. each.
 *                         b) added code to check whether the plane of the
 *                            curve is parallel to the trim-plane(s).
 *                         c) added code to set the extension distance
 *                            for the length of the axis to '0.0'
 *                            if planes parallel.
 * Sudha     06/01/93 : Modified to handle BSprototypes
 * Rustagi - 06/03/92 : Declared variable 'bool_options' and initialised it
 *                      to EMSsfbool_opt_noredraw so as to avoid the interim
 *                      display during 'place solid of projection'. Modified
 *                      function name from EMintersect_with_plane to 
 *                      EMintersect_with_plane_mod as an argument bool_options
 *                      being added to the original function.
 * Tapadia - 05/15/92 : Suppport for symmetrically projecting in both 
 *			directions normal to the profile.
 * Tapadia - 03/15/92 - Creation
 */

class implementation EMSgensolid;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h" /* has bool option EMSsfbool_opt_noredraw */
#include "bsxlnpl.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include <alloca.h>

struct RLWplane {
	IGRpoint point;
	IGRvector normal;
};

from EMSdpr import EMmake_primitive1;

extern IGRboolean WANT_POST220_BEHAVIOR;

/* This function trims the solid with one/two planes(s) */

IGRlong  EFplsolid_by_trimming_with_planes(EMmsg, opts, both_planes,
	ori_gen_solid_id, solid_id, param_lc_info, endpl_lc_info, 
	mid_point, constr_list)

IGRlong 	*EMmsg;
IGRushort 	opts;
IGRboolean 	both_planes;
GRobjid 	*ori_gen_solid_id;
GRobjid 	solid_id;
struct GRlc_info *param_lc_info;
struct GRlc_info *endpl_lc_info;
IGRpoint 	mid_point;
struct GRvg_construct *constr_list;

{
	IGRlong   	om_msg, num_curves, num_buf_cut, int_opt;
	struct GRid 	my_GRid,dpr_id, fin_dpr_id, new_id;
	IGRint 		i, comp_count = 0;
	struct IGRplane curve_pl, plane_pl;
	OMuword 	dum_os;
         GRobjid         *comp_ids = NULL;
	GRspacenum	constros;
	IGRdouble 	cur_pt[3], cur_nor[3], plane_pt[3], plane_nor[3];
	struct GRlc_info int_obj1;
	struct GRid 	*int_curves;
	OM_S_OBJID	stupid_id;
	OM_S_CHANSELECT to_comps, to_owners;
	struct RLWplane *plane_buf;
        IGRushort 	bool_options;

	constros = constr_list->env_info->md_id.osnum;
	*EMmsg = EMS_S_Success;
	om_msg = OM_S_SUCCESS;
        bool_options=EMSsfbool_opt_noredraw;

	my_GRid.objid = *ori_gen_solid_id;
	my_GRid.osnum = constros;

	if(both_planes) num_buf_cut = 2;
	else num_buf_cut = 1;

	/* Obtain the plane buffer information from the plane id(s) */

	plane_buf = (struct RLWplane *) alloca(num_buf_cut *
	    sizeof(struct RLWplane));

	curve_pl.point = cur_pt;
	curve_pl.normal = cur_nor;
	om_msg = om$send(msg = message GRvg.GRdetplane(EMmsg,
	    		&param_lc_info->module_info.md_env.matrix_type,
	    		param_lc_info->module_info.md_env.matrix, &curve_pl),
	    	senderid = NULL_OBJID,
	    	targetid = param_lc_info->located_obj.objid,
	    	targetos = param_lc_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);

	for(i = 0; i < 3; i++ ) {
		plane_buf[0].point[i] = cur_pt[i];
		plane_buf[0].normal[i]= cur_nor[i];
	}

	if(both_planes) {
		plane_pl.point = plane_pt;
		plane_pl.normal = plane_nor;

		om_msg = om$send(msg = message GRvg.GRdetplane(EMmsg,
		    		&endpl_lc_info->module_info.md_env.matrix_type,
		    		endpl_lc_info->module_info.md_env.matrix,
		    		&plane_pl),
		    	senderid = NULL_OBJID,
		    	targetid = endpl_lc_info->located_obj.objid,
		    	targetos = endpl_lc_info->located_obj.osnum);

		EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);

		for(i = 0; i < 3; i++ ) {
			plane_buf[1].point[i] = plane_pt[i];
			plane_buf[1].normal[i] = plane_nor[i];
		}
	}

	int_obj1.located_obj.objid = solid_id;
	int_obj1.located_obj.osnum = constros;
	int_obj1.module_info = *constr_list->env_info;

	int_opt = 2;
	stupid_id = solid_id;

	/* Intersect the plane(s) with the solid - save side option */

	om_msg = EMintersect_with_plane_mod(int_opt, num_buf_cut, plane_buf, 
	    	NULL,  mid_point, FALSE, NULL, &int_obj1, constr_list, 
		TRUE, stupid_id, 2, &num_curves, &int_curves,
                bool_options, EMmsg);

	EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);

	om_msg = om$make_chanselect(channame = "GRconnector.to_owners",
	    		p_chanselect = &to_owners);
	om_msg = om$make_chanselect(channame = "GRcmpowner.to_components",
	    		p_chanselect = &to_comps);

	/* Obtain the boolean class id */
	om_msg = om$get_objid_at_index(objid = stupid_id,
	    		osnum = constros,
	    		p_chanselect = &to_owners,
	    		index = 0,
	    		objidaddr = &dpr_id.objid,
	    		osnumaddr = &dum_os);

	if(!(1 & om_msg)) goto ret_end;

	if(both_planes) {
		/* Obtain the boolean class id */
		om_msg = om$get_objid_at_index(objid = dpr_id.objid,
	    		osnum = constros,
	    		p_chanselect = &to_owners,
	    		index = 0,
	    		objidaddr = &fin_dpr_id.objid,
	    		osnumaddr = &dum_os);

		if(!(1 & om_msg)) goto ret_end;
	}

	if(!both_planes) 
		fin_dpr_id.objid = dpr_id.objid;

	/* Compress the tree to make an object of class EMSgensolid */
	om_msg = om$send(msg = message EMSdpr.EMmake_primitive1(EMmsg,
	    		&int_obj1.module_info, &new_id),
	    	senderid = NULL_OBJID,
	    	targetid = fin_dpr_id.objid,
	    	targetos = constros);

	EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);

	if(opts & EMSasconst_notassociative) 
		*ori_gen_solid_id = new_id.objid;

	else { /* Associative placement */
	    /* Get all the components & connect them to the original
		EMSgensolid */ 
	    om_msg = om$get_channel_count(osnum = new_id.osnum,
		    	objid = new_id.objid,
		    	p_chanselect = &to_comps,
		    	count = (OMuint *) &comp_count);

	    if(!(1 & om_msg)) goto ret_end;

            if (comp_count)
            {
                comp_ids = NULL;
                comp_ids = (GRobjid *) alloca(comp_count * sizeof(GRobjid));

                if (! comp_ids)
                {
                    *EMmsg = EMS_E_NoStackMemory;
                    goto ret_end;
                }
            }

	    for(i = 0; i < comp_count; i++) {
		om_msg = om$get_objid_at_index(objid = new_id.objid,
		 	p_chanselect = &to_comps,
			index = i,
		    	objidaddr = &comp_ids[i],
			osnumaddr = &dum_os);

	        if(!(1 & om_msg)) goto ret_end;
	    }

	    om_msg = om$send(msg = message GRconnector.GRdisconn(EMmsg,
		    	&new_id),
		    senderid = new_id.objid,
		    p_chanselect = &to_comps);

	    EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);

	    for(i = 0; i < comp_count; i++) {
		om_msg = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
			    &my_GRid, (IGRlong *) &i),
		   	senderid = NULL_OBJID,
			targetid = comp_ids[i],
			targetos = new_id.osnum);

	        EMerr_hndlr(!(1&om_msg&*EMmsg), *EMmsg, EMS_E_Fail, ret_end);
	    }

	    om_msg = om$send(msg = message Root.delete(1),
		    senderid = NULL_OBJID,
		    targetid = new_id.objid,
		    targetos = new_id.osnum);

	    if(!(1 & om_msg)) goto ret_end;
	}

ret_end:
	EMWRAPUP(*EMmsg, om_msg, "EFplsolid_by_trimming_with_planes"); 
	return(om_msg);
}

/* This function returns the axis points of the plane - curve intersection.
It also returns the mid point to be used by int plane - save side */

IGRlong EFget_axis_from_curve_one_pl(msg, curve_info, st_plane_info, 
	axis_line, mid_point, parallel_pls)

IGRlong 	*msg;
struct GRlc_info *curve_info;
struct GRlc_info *st_plane_info;
IGRpoint 	axis_line[2];
IGRpoint 	mid_point;
IGRboolean      *parallel_pls;
{
	IGRlong 	msg_loc, om_msg;
	IGRpoint 	sec_pt_ln, ln_pln_intpt;
	struct IGRplane curve_pl, plane_pl;
	IGRdouble 	range_dist, cur_pt[3], cur_nor[3], plane_pt[3], 
			plane_nor[3];
	GRrange 	range;
	IGRboolean 	world = TRUE;
	IGRvector 	proj_nor;

        IGRdouble       coltol;

	*msg = EMS_S_Success;
	om_msg = OM_S_SUCCESS;

	/* Get the curve point & normal */
	curve_pl.point = cur_pt;
	curve_pl.normal = cur_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&curve_info->module_info.md_env.matrix_type,
	    		curve_info->module_info.md_env.matrix,
	    		&curve_pl),
	    	senderid = NULL_OBJID,
	    	targetid = curve_info->located_obj.objid,
	    	targetos = curve_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	OM_BLOCK_MOVE(cur_pt, axis_line[0], sizeof(IGRpoint));

	/* Get the plane point & normal */
	plane_pl.point = plane_pt;
	plane_pl.normal = plane_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&st_plane_info->module_info.md_env.matrix_type,
	    		st_plane_info->module_info.md_env.matrix,
	    		&plane_pl),
	    	senderid = NULL_OBJID,
	    	targetid = st_plane_info->located_obj.objid,
	    	targetos = st_plane_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	sec_pt_ln[0] = cur_pt[0] + cur_nor[0];
	sec_pt_ln[1] = cur_pt[1] + cur_nor[1];
	sec_pt_ln[2] = cur_pt[2] + cur_nor[2];

	/* Intersection between infinite line & plane */
	BSxlnpl(&msg_loc, plane_nor, plane_pt, cur_pt, sec_pt_ln, ln_pln_intpt);
	if(msg_loc != BSSUCC) {
		*msg = EMS_E_BSerror;
		goto ret_end;
	}

	mid_point[0] = (cur_pt[0] + ln_pln_intpt[0])/2.0;
	mid_point[1] = (cur_pt[1] + ln_pln_intpt[1])/2.0;
	mid_point[2] = (cur_pt[2] + ln_pln_intpt[2])/2.0;

	proj_nor[0] = ln_pln_intpt[0] - cur_pt[0];
	proj_nor[1] = ln_pln_intpt[1] - cur_pt[1];
	proj_nor[2] = ln_pln_intpt[2] - cur_pt[2];

	/* This happens when the points are degenerate */
	BSnorvec(&msg_loc, proj_nor);
	if(msg_loc != BSSUCC) {
		*msg = EMS_E_BSerror;
		goto ret_end;
	}

        /* Determine if the normals of the 'curve-plane', the 'end-plane'
           are the same. If so set the 'parallel_pls' 
           flag to TRUE and do not extend the axis. */

        BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, coltol);

        BSnorvec(&msg_loc, cur_nor);
        BSnorvec(&msg_loc, plane_nor);

           if(WANT_POST220_BEHAVIOR &&
             (fabs(fabs(BSdotp(&msg_loc, cur_nor, plane_nor)) - 1.0)
                                                               <= coltol))
              *parallel_pls = TRUE;

#ifdef DEBUG
 printf(" coltol = %lf\n", coltol);
 printf("BSdotp cur_nor, plane_nor = %lf\n",
        fabs(fabs(BSdotp(&msg_loc, cur_nor, plane_nor))) - 1.0);
 printf("The parallel  planes flag = %d\n", *parallel_pls);
#endif

        if(!(*parallel_pls)) {

	  /* Get the plane range to determine the distance to extend by */
	  om_msg = om$send(msg = message GRvg.GRgetrang(msg, 
	    		&st_plane_info->module_info.md_env.matrix_type,
	    		st_plane_info->module_info.md_env.matrix,
	    		&world, range),
	    	senderid = NULL_OBJID,
	    	targetid = st_plane_info->located_obj.objid,
	    	targetos = st_plane_info->located_obj.osnum);

	  EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	  range_dist = BSdistptpt(&msg_loc, &range[0], &range[3]);
        }
        else  
          range_dist = 0.0;
        

	axis_line[1][0] = ln_pln_intpt[0] + proj_nor[0] * range_dist;
	axis_line[1][1] = ln_pln_intpt[1] + proj_nor[1] * range_dist;
	axis_line[1][2] = ln_pln_intpt[2] + proj_nor[2] * range_dist;

ret_end:
	EMWRAPUP(*msg, om_msg, "EFget_axis_from_curve_one_pl"); 
	return(om_msg);
}

/* This function returns the axis points of the planes - curve intersection.
It also returns the mid point to be used by int plane - save side */

IGRlong EFget_axis_from_curve_two_pls(msg, curve_info, st_plane_info, 
	end_plane_info, cur_pt, axis_line, mid_point, parallel_pls)

IGRlong 	*msg;
struct GRlc_info *curve_info;
struct GRlc_info *st_plane_info;
struct GRlc_info *end_plane_info;
IGRpoint 	cur_pt;
IGRpoint 	axis_line[2];
IGRpoint 	mid_point;
IGRboolean      *parallel_pls;
{
	IGRlong 	msg_loc, om_msg;
	IGRpoint 	sec_pt_ln, ln_stpl_int, ln_endpl_int;
	struct IGRplane curve_pl, st_plane, end_plane;
	IGRdouble 	st_range_dist, end_range_dist, cur_pl_pt[3], 
	    		cur_pl_nor[3], st_plane_pt[3], st_plane_nor[3], 
			end_plane_pt[3], end_plane_nor[3];
	GRrange 	st_range, end_range;
	IGRboolean 	world = TRUE;
	IGRvector 	proj_nor;

        IGRdouble       coltol;

	*msg = EMS_S_Success;
	om_msg = OM_S_SUCCESS;

	/* Get the curve point & normal */
	curve_pl.point = cur_pl_pt;
	curve_pl.normal = cur_pl_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&curve_info->module_info.md_env.matrix_type,
	    		curve_info->module_info.md_env.matrix, &curve_pl),
	    	senderid = NULL_OBJID,
	    	targetid = curve_info->located_obj.objid,
	    	targetos = curve_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	/* Get the start plane point & normal */
	st_plane.point = st_plane_pt;
	st_plane.normal = st_plane_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&st_plane_info->module_info.md_env.matrix_type,
	    		st_plane_info->module_info.md_env.matrix, &st_plane),
	    	senderid = NULL_OBJID,
	    	targetid = st_plane_info->located_obj.objid,
	    	targetos = st_plane_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	OM_BLOCK_MOVE(cur_pl_pt, cur_pt, sizeof(IGRpoint));

	sec_pt_ln[0] = cur_pl_pt[0] + cur_pl_nor[0];
	sec_pt_ln[1] = cur_pl_pt[1] + cur_pl_nor[1];
	sec_pt_ln[2] = cur_pl_pt[2] + cur_pl_nor[2];

	/* Find the intersection between line & start plane */
	BSxlnpl(&msg_loc, st_plane_nor, st_plane_pt, cur_pl_pt, sec_pt_ln,
	    	ln_stpl_int);
	if(msg_loc != BSSUCC) {
		*msg = EMS_E_BSerror;
		goto ret_end;
	}

	/* Get the end plane point & normal */
	end_plane.point = end_plane_pt;
	end_plane.normal = end_plane_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&end_plane_info->module_info.md_env.matrix_type,
	    		end_plane_info->module_info.md_env.matrix, &end_plane),
	    	senderid = NULL_OBJID,
	    	targetid = end_plane_info->located_obj.objid,
	    	targetos = end_plane_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	/* Find the intersection between line & end plane */
	BSxlnpl(&msg_loc, end_plane_nor, end_plane_pt, cur_pl_pt, sec_pt_ln, 
		ln_endpl_int);
	if(msg_loc != BSSUCC) {
		*msg = EMS_E_BSerror;
		goto ret_end;
	}

	proj_nor[0] = ln_stpl_int[0] - ln_endpl_int[0];
	proj_nor[1] = ln_stpl_int[1] - ln_endpl_int[1];
	proj_nor[2] = ln_stpl_int[2] - ln_endpl_int[2];

	BSnorvec(&msg_loc, proj_nor);
	/* This happens when the points are degenerate */
	if(msg_loc != BSSUCC) {
		*msg = EMS_E_BSerror;
		goto ret_end;
	}

        /* Determine if the normals of the 'curve-plane', the 'start-plane'
           and the end-plane are the same. If so set the 'parallel_pls'
           flag to TRUE and do not extend the axis. */

        BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, coltol);

        BSnorvec(&msg_loc, cur_pl_nor);
        BSnorvec(&msg_loc, st_plane_nor);
        BSnorvec(&msg_loc, end_plane_nor);

        if(WANT_POST220_BEHAVIOR &&
         (fabs(fabs(BSdotp(&msg_loc, cur_pl_nor, st_plane_nor)) - 1.0)
                                                               <= coltol) &&
           (fabs(fabs(BSdotp(&msg_loc, cur_pl_nor, end_plane_nor)) - 1.0) 
                                                               <= coltol))
              *parallel_pls = TRUE;

#ifdef DEBUG
 printf(" coltol = %lf\n", coltol);
 printf("BSdotp cur_pl_nor, st_pl_nor = %lf\n", 
        fabs(fabs(BSdotp(&msg_loc, cur_pl_nor, st_plane_nor))) - 1.0);
 printf("BSdotp cur_pl_nor, end_pl_nor = %lf\n", 
        fabs(fabs(BSdotp(&msg_loc, cur_pl_nor, end_plane_nor))) - 1.0);
 printf("The parallel  planes flag = %d\n", *parallel_pls);
#endif

        if(!(*parallel_pls)) {
        
          /* Get the start plane range to determine the distance to extend by */
	  om_msg = om$send(msg = message GRvg.GRgetrang(msg, 
	      		&st_plane_info->module_info.md_env.matrix_type,
	      		st_plane_info->module_info.md_env.matrix, &world, 
	  		st_range),
	          senderid = NULL_OBJID,
	    	  targetid = st_plane_info->located_obj.objid,
	    	  targetos = st_plane_info->located_obj.osnum);

	  EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	  st_range_dist = BSdistptpt(&msg_loc, &st_range[0], &st_range[3]);

	  /* Get the end plane range to determine the distance to extend by */
	  om_msg = om$send(msg = message GRvg.GRgetrang(msg, 
	    		&end_plane_info->module_info.md_env.matrix_type,
	    		end_plane_info->module_info.md_env.matrix, &world, 
			end_range),
	    	  senderid = NULL_OBJID,
	    	  targetid = end_plane_info->located_obj.objid,
	    	  targetos = end_plane_info->located_obj.osnum);

	  EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);

	  end_range_dist = BSdistptpt(&msg_loc, &end_range[0], &end_range[3]);
        }
        else {

          st_range_dist = 0.0;
          end_range_dist = 0.0;
        }

	axis_line[0][0] = ln_stpl_int[0] + (proj_nor[0] * st_range_dist);
	axis_line[0][1] = ln_stpl_int[1] + (proj_nor[1] * st_range_dist);
	axis_line[0][2] = ln_stpl_int[2] + (proj_nor[2] * st_range_dist);

	axis_line[1][0] = ln_endpl_int[0] - proj_nor[0] * end_range_dist;
	axis_line[1][1] = ln_endpl_int[1] - proj_nor[1] * end_range_dist;
	axis_line[1][2] = ln_endpl_int[2] - proj_nor[2] * end_range_dist;

	mid_point[0] = (ln_stpl_int[0] + ln_endpl_int[0])/2.0;
	mid_point[1] = (ln_stpl_int[1] + ln_endpl_int[1])/2.0;
	mid_point[2] = (ln_stpl_int[2] + ln_endpl_int[2])/2.0;

ret_end:
	EMWRAPUP(*msg, om_msg, "EFget_axis_from_curve_two_pls"); 
	return(om_msg);
}

/* Return the axis points given the profile & the symmetric projection 
   distance */

IGRlong EFget_axis_from_curve_sym_dist(msg, curve_info, sym_dist, axis_line)

IGRlong 	*msg;
struct GRlc_info *curve_info;
IGRdouble	sym_dist;
IGRpoint 	axis_line[2];
{
	IGRlong 	om_msg;
	struct IGRplane curve_pl;
	IGRdouble 	cur_pt[3], cur_nor[3];

	*msg = EMS_S_Success;
	om_msg = OM_S_SUCCESS;

	/* Get the curve point & normal */
	curve_pl.point = cur_pt;
	curve_pl.normal = cur_nor;

	om_msg = om$send(msg = message GRvg.GRdetplane(msg,
	    		&curve_info->module_info.md_env.matrix_type,
	    		curve_info->module_info.md_env.matrix, &curve_pl),
	    	senderid = NULL_OBJID,
	    	targetid = curve_info->located_obj.objid,
	    	targetos = curve_info->located_obj.osnum);

	EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);
	/* projecting on both sides of the profile */
	sym_dist /= 2.0;

	axis_line[0][0] = cur_pt[0] + (cur_nor[0] * sym_dist);
	axis_line[0][1] = cur_pt[1] + (cur_nor[1] * sym_dist);
	axis_line[0][2] = cur_pt[2] + (cur_nor[2] * sym_dist);
	axis_line[1][0] = cur_pt[0] - (cur_nor[0] * sym_dist);
	axis_line[1][1] = cur_pt[1] - (cur_nor[1] * sym_dist);
	axis_line[1][2] = cur_pt[2] - (cur_nor[2] * sym_dist);

ret_end:
	EMWRAPUP(*msg, om_msg, "EFget_axis_from_curve_sym_dist"); 
	return(om_msg);
}

end implementation EMSgensolid;
