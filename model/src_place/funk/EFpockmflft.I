class implementation EMSsubbs;

#include "EMS.h"
#include "EMSbnddef.h"		/* Required by EMSbnd.h */
#include "OMmacros.h"
#include "EMSbnd.h"		/* Required by one of the messages */
#include "EMSlm.h"		/* Has the ambiguous grouping structure */
#include "EMSlmdef.h"		/* Make face defines */
#include "EMSmsgdef.h"		/* EMS_I_NeedGrpInfo is defined here */
#include "bsparameters.h"
#include "bserr.h"
#include "emsmapdef.h"
#include "EMSlift.h"
#include "ems_m_inc.h"
#include "EMSas.h"
#include "EMSasdef.h"
#include "EMSdef.h"
#include "EMSconstruct.h"
#include "EMSasopts.h"
#include "EMSprop.h"
#include "matypemx.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bstst_plan.h"
#include "bspt_in_cv.h"
#include "bsfreecv.h"
#include "bsalloccv.h"

#define POCKET 0
#define BOSS 1
#define FAST_MAKE_LIFT 2

extern OMuword OPP_EMSsubbs_class_id;
from EMSdpr import EMsetprops;

/*
 Description

 Given a surface and a set of curves with distances this routine
 will use the set of curves to make faces on the surface and then
 lift the faces by the specified distances.  Curves with the same
 lift distance (i.e same event) will be placed on the same face.

 The vector, along which the surface is lifted, is determined
 by the normal vector of the surface.  As such, this function
 will only do something meaningful for planar surfaces.

 If the sign of the lift distance is positive then material is
 added.  If the sign of the lift distance is negative then
 material is removed.

 It is expected that the input curves are closed and planar.
 Ambiguous grouping conditions are not supported and if this
 condition arises it is considered to be an error.
 This function is very much a subset of the functionality provided
 for in the make face command.  It was intended to work for
 a very simple subset of the general problem.

 This function is used by fast make & lift, Pocket/Boss placement.

 History

 Tapadia 11/08/91 - Modified to call only one function EFdrafted_lift for
		    pocket/boss with & without draft & make & lift face.
 Tapadia 09/06/91 - Option to not store the lift vector for pocket/boss. We
		    give only the pos_orient info.
 Tapadia 07/25/91 - Extensive changes done. Renamed the function because the
		    argument list is changed.
 Tapadia 06/12/91 - Support for pocket/boss with draft
 Tapadia 06/10/91 - Modified the code to get the correct made_face id.
 Tapadia 05/17/91 - Modified for recomputing pockets/bosses of varying depths/
		    heights
 Tapadia 05/03/91 - Creation
 Sudha   06/30/93 - Modified for BSprototypes ansification
 */

struct	rlw_temp_sort
{
	IGRlong	number_of_curves;
	struct	GRlc_info *curves;
	IGRdouble	distance;
};

IGRlong EFgen_make_lift_face(
	/* Input arguments */
part_type,		/* Part type - Pocket/Boss */
md_env,			/* Module enviroment of the datum surface */
datum_surface,		/* Surface on which makes are to take place */
number_of_curves,	/* Number of curves to impose as boundaries */
curves,			/* The curves which are used to make faces */
lift_distances,		/* The distances the faces are to be lifted */
drafted, 		/* To indicate if drafted */
draft_angle,		/* Draft angle */
options,		/* Initial creation or recompute */
construct_list,		/* Standard list used to build new sf's */
top_state_before,	/* Top node in the state tree before */
my_stupid_id,		/* Caller's object id */
	/* Output arguments */
top_state_after,	/* Top node after makes and lifts */
last_lift,		/* The id of the last lifted surface */
num_grps,
msg)			/* Errror return code */

IGRint part_type;
struct	GRmd_env *md_env;
struct	GRid *datum_surface;
IGRlong	number_of_curves;
struct	GRlc_info curves[];
struct GRevent lift_distances[];
IGRboolean drafted;
struct GRevent *draft_angle;
IGRushort options;
struct	GRvg_construct *construct_list;
struct	GRid *top_state_before;
GRobjid	my_stupid_id;
struct	GRid *top_state_after;
struct	GRid *last_lift;
IGRint  *num_grps;
IGRlong	*msg;
{
	IGRlong		sts, number_of_groups, loc_msg, i, j, add_group;
	IGRlong 	EFret_makefaceid();
	IGRboolean 	*dep_index, action = TRUE;
	struct GRid 	made_face, make_face_id, lift_face_id;
	extern IGRlong 	EFmake_face(), EFdrafted_lift();
	struct rlw_temp_sort *sorted;
	struct GRlc_info surface_for_make_face;
	IGRushort gen_opts, mask;
	struct EMSdlft_info dlift_info;
	struct EMSvalue_info *lift_mag;

	/*  Initialize */
	sts = OM_S_SUCCESS;
	*msg = EMS_S_Success;
	lift_mag = NULL;
	sorted = NULL;
	mask = EMS_MACRO_STATE;

	/* Group the curves with the same event into one for placing on
	the same face. This is done by checking if the event value is 0.0 */

	dep_index = (IGRboolean *) malloc(number_of_curves * 
			sizeof(IGRboolean));
	if (!dep_index) {
		*msg = EMS_E_NoDynamicMemory;
		goto wrapup;
	}

	lift_mag = (struct EMSvalue_info *) malloc(number_of_curves * 
		sizeof(struct EMSvalue_info));

	if (!lift_mag) {
		*msg = EMS_E_NoDynamicMemory;
		goto wrapup;
	}

	/* Assign the lift distance to the lift mag structure */
	for(i = 0; i < number_of_curves; i++)  {
		if(lift_distances[i].event.value == 0.0) {
			lift_distances[i].event.value =
				lift_distances[i - 1].event.value;
			dep_index[i] = FALSE;
			lift_mag[i].type = EMSdatainfo_numeric;
			lift_mag[i].val = lift_distances[i].event.value;
		}
		else {
			dep_index[i] = TRUE;
			lift_mag[i].type = EMSdatainfo_event;
			lift_mag[i].valevent = &lift_distances[i];
		}
	}

	sorted = (struct rlw_temp_sort *) malloc(number_of_curves *
	    		sizeof(struct rlw_temp_sort));
	if (! sorted) {
		*msg = EMS_E_NoDynamicMemory;
		goto wrapup;
	}
	number_of_groups = 0;

	/* Group curves with the same event together */
	for (i = 0; i < number_of_curves; i++) {
		if(dep_index[i] == FALSE) {
			add_group = number_of_groups - 1;
			sorted[add_group].number_of_curves++;
		}
		else {
			add_group = number_of_groups;
			sorted[number_of_groups].number_of_curves = 1;
			sorted[number_of_groups].curves = &curves[i];
			number_of_groups++;
		}
	} 

	/* For each group of curves make the required face and then lift/
	dlift it */
	j = 0;
	for(i = 0; (i < number_of_curves) && (1 & *msg); i++) {
		surface_for_make_face.module_info = *md_env;
		surface_for_make_face.located_obj = *datum_surface;

		/* Construct a make face object */
		make_face_id.objid = NULL_OBJID;

		/* Does the associative make face construction */
		sts = EFmake_face(msg, NULL, 
				(IGRint)sorted[j].number_of_curves,
		    		sorted[j].curves, &surface_for_make_face,
		    		construct_list, &make_face_id, options);

		EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, cleanup);

		/* Set the dpr bit */
		sts = om$send(msg = message EMSdpr.EMsetprops(msg, &action,
					&mask),
				senderid = NULL_OBJID,
	    			targetid = make_face_id.objid,
	    			targetos = datum_surface->osnum);
		EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, cleanup);

		/* Find the objid of the make face - needed for lift face */
		sts = EFret_makefaceid(msg, &make_face_id, &made_face,
				&surface_for_make_face, number_of_curves, 
				curves);
		EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, cleanup);

		if(!drafted)
			*last_lift = made_face;

		/* Fill in only the dlift_info structure for pocket/boss/fast
		make & lift face.  Rest of the information is computed during
		placement */
		if(drafted) { 
			dlift_info.sf_GRid = made_face;
			dlift_info.assoc_magnatude.type = EMSdatainfo_event;
			dlift_info.assoc_magnatude.valevent= &lift_distances[i];
			dlift_info.uniform_surface = TRUE;
			dlift_info.assoc_draft_angle.type = EMSdatainfo_event;
			dlift_info.assoc_draft_angle.valevent = &draft_angle[i];
			dlift_info.no_fillets = TRUE;
			dlift_info.num_ed_infos = 0;
			dlift_info.num_lps = 0;
			dlift_info.lps_info = NULL;
		}
		else { /* without draft */
			dlift_info.sf_GRid = made_face;
			dlift_info.assoc_magnatude.type = EMSdatainfo_event;
			dlift_info.assoc_magnatude.valevent= &lift_distances[i];
			dlift_info.uniform_surface = TRUE;
			dlift_info.assoc_draft_angle.type = EMSdatainfo_numeric;
			dlift_info.no_fillets = TRUE;
			dlift_info.num_ed_infos = 0;
			dlift_info.num_lps = 0;
			dlift_info.lps_info = NULL;
		}

		/* Construct a lift/dlift face object */
		lift_face_id.objid = NULL_OBJID;

		if(!drafted) {
			if(part_type == POCKET || part_type == BOSS) 
				gen_opts = options | EFlft_POS_WITH_VECT;
			else /* make & lift face */
				gen_opts = options;
			if(part_type == POCKET)
				gen_opts |= EFlft_WITH_POS_ORIENT;
		}
		else { /* Drafted */
			gen_opts = options | EFdlft_NEG_ANGLE_OUTSIDE;
			if(part_type == POCKET) 
				gen_opts |= EFdlft_POS_MAG_INSIDE;
			else /* boss */
				gen_opts |= EFdlft_NEG_MAG_OUTSIDE;
		}

		/* Does the associative drafted lift construction for both
		with draft & without it */
		sts = EFdrafted_lift(msg, NULL, construct_list,
				&dlift_info, &lift_face_id, gen_opts); 

		EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, cleanup);
		*last_lift = dlift_info.sf_GRid;

		/* Set the dpr bit */
		sts = om$send(msg = message EMSdpr.EMsetprops(msg, &action,
					&mask),
				senderid = NULL_OBJID,
	    			targetid = lift_face_id.objid,
	    			targetos = datum_surface->osnum);
		EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, cleanup);

		*top_state_after = lift_face_id;

		/* Curves with the same event are placed together */
		i = i + (sorted[j].number_of_curves - 1);

		/* For fast make & lift */
		if(part_type == FAST_MAKE_LIFT) 
		    	*last_lift = *datum_surface;
		j++;
	}
	*num_grps = number_of_groups;

cleanup:
	/*  If one of the make or lifts failed then attempt to recover the 
	model to it's state prior to entering this routine.  */
	if (! (1 & *msg)) {
		IGRint	display_count, invoke_count;
		GRobjid	*display_ids;
		IGRushort deactivate_option;

		deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
		display_count = 0;
		display_ids = NULL;
		invoke_count = 0;
		sts = om$send( msg = message EMSsurface.EMmake_active_state(
		    		&loc_msg,
		    		&deactivate_option,
		    		md_env,
		    		NULL,		/* Active ids after undo */
				NULL,
				NULL,
				&display_ids,
				&display_count,
				&invoke_count),
			senderid = my_stupid_id,
		    	targetid = top_state_before->objid,
		    	targetos = top_state_before->osnum);

		if (!(1 & sts)) goto wrapup;
		*top_state_after = *top_state_before;
	} /* if (! (1 & *msg)) */
wrapup:
	if (sorted) free(sorted);
	if(dep_index) free(dep_index);
	if(lift_mag) free(lift_mag);
	EMWRAPUP(*msg, sts, "In EFgen_make_lift_face");
	if (! (1 & *msg))
		return(FALSE);
	else
		return(TRUE);
}

/* This function returns the id of the made face to be used by the
lift operation 

Tapadia - 6/10/91 - Creation  */

IGRlong EFret_makefaceid(msg, make_face_id, made_face,
			surface_for_make_face, num_of_curves, curve)
IGRlong *msg;
struct GRid *make_face_id;
struct GRid *made_face;
struct	GRlc_info *surface_for_make_face;
IGRlong	num_of_curves;
struct	GRlc_info curve[];
{

	IGRlong sts;
	OM_S_CHANSELECT own_to_comps;
	extern void EFgetobjids();
	IGRint number_of_ids = 0;
	struct GRid *return_GRids, *surface_id;
	struct GRmd_env *md_env;
	extern OMuword OPP_GRbcsubbc_class_id;
	struct IGRbsp_curve *boundary = NULL;
	struct IGRbsp_surface *sf_geom = NULL;

	md_env = &surface_for_make_face->module_info;

	*msg = EMS_S_Success;

	sts = EMmake_chanselect(GRcmpowner_to_components,&own_to_comps);
	if(!(1&sts)) {
		*msg = EMS_E_Fail;
		goto wrapup;
	}

	surface_id = &surface_for_make_face->located_obj;
	return_GRids = NULL;

	EFgetobjids(msg, make_face_id, &own_to_comps, &return_GRids, 
	    	&number_of_ids, OPP_EMSsubbs_class_id, surface_id, 1);

	if(! (1 & *msg)) goto wrapup;

	if(number_of_ids == 1) {
	    IGRboolean found, pos_orient, status;
	    OMuword input_cv_class = OPP_GRbcsubbc_class_id, pj_cv_class;
	    IGRshort modmat_type, xmat_type;
	    IGRint i,j,in_boundary;
	    IGRlong buf_size, msg_loc, max_buf_size, sf_size, num_pts;
	    IGRmatrix module_mat, xmat;
	    IGRdouble sf_points[9], point_on_plane[3];
	    IGRvector normal_vector;
	    struct IGRplane plane;
	    struct IGRbsp_curve *pj_cv;
	    extern IGRlong EFproject_curve_onto_plane();
	    extern void EMtoplnxform();

	    for(max_buf_size = 0, i = 0; i < num_of_curves; ++i) {

		sts = om$send(msg = message GRvg.GRgetsize(msg,
				&curve[i].module_info.md_env.matrix_type,
				curve[i].module_info.md_env.matrix, &buf_size),
			senderid = NULL_OBJID,
			targetid = curve[i].located_obj.objid,
			targetos = curve[i].located_obj.osnum);
		if(! (1 & sts & *msg)) goto wrapup;

		max_buf_size = buf_size > max_buf_size ? buf_size :max_buf_size;
	    }
	    boundary=(struct IGRbsp_curve *)om$malloc(size = max_buf_size);
	    if(!boundary) goto wrapup;

	    sts = om$send(msg = message EMSsubbs.EMget_point_on_surface(msg,
				&surface_for_make_face->module_info, 0, 3, 
				sf_points, NULL),
			senderid = NULL_OBJID,
			targetid = return_GRids->objid,
			targetos= return_GRids->osnum);

	    if(!(1 & sts & *msg)) goto wrapup;

    	    sts = om$send (msg = message GRvg.GRgetsize (msg, 
                    		&md_env->md_env.matrix_type, 
                    		md_env->md_env.matrix, &sf_size),
                  	senderid = NULL_OBJID,
                  	targetid = return_GRids->objid,
                  	targetos = return_GRids->osnum);
    	    if(! (1 & sts & *msg)) goto wrapup;

    	    sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
    	    if(!sf_geom) goto wrapup;

    	    sts = om$send(msg = message GRvg.GRgetgeom(msg, 
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix, 
                   		(IGRchar *) sf_geom),
                  	senderid = NULL_OBJID,
                  	targetid = return_GRids->objid,
                  	targetos = return_GRids->osnum);
    	    if(! (1 & sts & *msg)) goto wrapup;
        
    	    BStst_plan (sf_geom->u_num_poles * sf_geom->v_num_poles,
                	sf_geom->poles, sf_geom->weights, &sf_geom->planar,
                	normal_vector, &msg_loc);
    	    if (msg_loc != 0) goto wrapup;

    	    input_cv_class = OPP_GRbcsubbc_class_id;

    	    for (i = 0; i < 3; i++) {
     		point_on_plane[i] = sf_geom->poles[i];
     		if (sf_geom->rational)
      			point_on_plane[i] /= sf_geom->weights[0]; 
    	    }

    	    plane.point = point_on_plane;
    	    plane.normal = normal_vector;

    	    /*
     	    * Since, BSpt_in_cv() routine only handles xy_plane curves,
     	    * We need to transform the projected curve and the surface's
     	    * points to the xy_plane before invoking this function.
     	    */

    	    status = MAidmx (msg, module_mat);
    	    modmat_type = MAIDMX;

    	    EMtoplnxform (msg, plane.point, plane.normal, &modmat_type, 
                  	module_mat, &xmat_type, xmat, NULL, NULL, NULL);
    	    if (!(1 & *msg)) goto wrapup;
 
    	    status = MAtypemx (msg, xmat, &xmat_type);
    	    if (!(1 & *msg)) goto wrapup;

    	    num_pts = 3;
    	    status = MAoptsxform (msg, &num_pts, &xmat_type, xmat, sf_points,
                          sf_points);
    	    if (!status || !(1 & *msg)) goto wrapup;

    	    for(i = 0 , found = FALSE; !found && i < num_of_curves ; ++i) {
     		sts = om$send(msg = message GRvg.GRgetgeom(msg,
                    		&curve[i].module_info.md_env.matrix_type, 
                    		curve[i].module_info.md_env.matrix, 
                    		(IGRchar *) boundary),
                   	senderid = NULL_OBJID,
                   	targetid = curve[i].located_obj.objid,
                   	targetos = curve[i].located_obj.osnum);
     	    	if(! (1 & sts & *msg)) goto wrapup;
                   
     	    	BSalloccv (boundary->order, boundary->num_poles, 
			boundary->rational, 0, &pj_cv, &msg_loc);
     	    	if(msg_loc != 0) goto wrapup;

     	    	sts = EFproject_curve_onto_plane (NULL,boundary,input_cv_class,
            		&plane, normal_vector,NULL_OBJID, pj_cv, &pj_cv_class, 
			msg);
     	    	if (!(1&sts&*msg)) goto wrapup;

     	    	status = MArptsxform (msg, &pj_cv->num_poles, &pj_cv->rational,
              		pj_cv->rational ? pj_cv->weights : NULL, xmat, 
			pj_cv->poles, pj_cv->poles);
     	    	if(!status || !(1 & *msg)) goto wrapup;

     	    	for (j = 0; !found && j < 3; j++) {
      			BSpt_in_cv(pj_cv, &sf_points[3*j], FALSE, &pos_orient, 
                 		&in_boundary, &msg_loc);
      			if(msg_loc != 0) goto wrapup;

			/* inside the boundary */
      			if(in_boundary == 1)  found = TRUE;  

     	    	} /* for (j = 0; !found && j < 3; j++) */

     	    	status = BSfreecv (&msg_loc, pj_cv);

    	    } /* for(i = 0 , found = FALSE; !found && i < num_of_curves ; */

    	    if(found)  *made_face = *return_GRids;
    	    else  *made_face = *surface_id;
            /*fix for mlk */
            if(return_GRids) om$dealloc(ptr = return_GRids);
	}
	else {
		*msg = EMS_E_Fail;
		if(number_of_ids && return_GRids) 
			free(return_GRids);
	}

wrapup:
	if(boundary) free(boundary);
	if(sf_geom) om$dealloc(ptr = sf_geom);
	EMWRAPUP(*msg, sts, "In EFret_makefaceid");
	if (! (1 & *msg))
		return(FALSE);
	else
		return(TRUE);
}

end implementation EMSsubbs;
