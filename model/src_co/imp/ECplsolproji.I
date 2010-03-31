/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the next event processing, verify event,
 perform construction, init, perform dynamics, and display construction
 methods for the place solid of projection command.

 History

 05/15/92 Tapadia - Suppport for symmetrically projecting in both directions 
		    normal to the profile.
 03/11/92 Tapadia - Creation
 06/03/93 Sudha     Modified for adding BSprototype headers
 */

class implementation ECplsolproj;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "emsdef.h"
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "FI.h"
#include "EMSdpb.h" /* For EMSDPB_ASSOC_PLACEMENT */
#include "EMSasopts.h" /*For EMSasconst_not..*/
#include "EMSmsgdef.h"
#include "bsxlnpl.h"
#include "bsdistnct2.h"

#define BIG_CURVE 0
#define LITTLE_SURFACE 2
#define MAX_POINTS 20

from GRvg import GRdetplane;
from GRgraphics import GRdisplay;

extern OMuword OPP_GRbspline_class_id, OPP_EMSplane_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_GRcurve_class_id, OPP_EMSsubbs_class_id;

extern IGRboolean ASbroadcast_in_progress;

method next_event_processing(IGRchar *prompt_string; IGRlong *prompt_index;
	IGRlong	*event_mask; IGRlong *type_of_value_needed;
	IGRboolean *locate_desired; struct RLW_locate_info *loc_info)

{
	extern void 	EFget_locate_information();
	IGRlong		key, integer_to_encode, *my_msg, my_type, 
			save_num_events = 0;
	IGRboolean     	prompt_string_set = FALSE;

	/* Compiler optimizations */
	my_msg = &me->msg;
	my_type = me->mytype;
	save_num_events = me->number_of_events_input;

	/* Initialize */
	*my_msg = MSSUCC;
	integer_to_encode = 0;

	/* Branch based on the command state */

	switch (me->number_of_events_input)
	{
	/* Event 1 prompt */
	case 0:
		*locate_desired = TRUE;
		EFget_locate_information(BIG_CURVE, loc_info);
		key = EMS_P_00106;
		loc_info->rtree_classes.w_count = 2;
		/* I am lying for 111 */
		loc_info->operation_type = info_read_only; 
		loc_info->relocate_key = EMS_I_00013;
		loc_info->r_classes[0] = OPP_GRbspline_class_id;
		loc_info->e_classes[0] = OPP_GRcurve_class_id;
		loc_info->planar_flag = LC_PLANAR_ONLY;
	     /* since code for solid of projection from surfaces is not yet made
             * associative, we disable the user from picking up surfaces to 
             * project, since the "EMsweep_surface_with_lift_face" code was 
             * wrongly notifying the batch list and causing the solid of 
             * projection to vanish. When the assoc. code is in, then the 
             * "if-else" statement below should be replaced by the "else" part
             * of the statement.
             */
		if (me->associative)
		{
			loc_info->eligible_classes.w_count = 1;
			loc_info->rtree_classes.w_count    = 1;
			loc_info->acc_key = EMS_P_00038;
			loc_info->accept_event_type = dummy;
			key = EMS_P_00166; /*pick ONLY closed curves prompt*/
		}
		else
		{
			loc_info->eligible_classes.w_count = 2;
			loc_info->r_classes[1] = OPP_EMSsubbs_class_id;
			loc_info->e_classes[1] = OPP_EMSsubbs_class_id;
			loc_info->accept_event_type = dummy;
			loc_info->acc_key = EMS_P_00038;
		}
		break;

	/* Event 2 prompt */
	case 1:
		*type_of_value_needed = DISTANCE;
		*event_mask |= GRm_RJT_MOVEON;
		key = EMS_P_00167;
		break;

	/* Event 3 prompt */
	case 2:
		*type_of_value_needed = DISTANCE;
		*event_mask |= GRm_RJT_MOVEON;
		key = EMS_P_00168;
		break;

	/* Event 4 prompt */
	case 3:
		key = EMS_P_00169;
		break;

	/* Event 5 prompt */
	case 4:
		*locate_desired = TRUE;
		EFget_locate_information(LITTLE_SURFACE, loc_info);
		key = EMS_P_00170;
		*event_mask |= GRm_RJT_MOVEON;
		loc_info->eligible_classes.w_count = 3;
		loc_info->r_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[2] = OPP_EMSdatpln_class_id;
		loc_info->accept_event_type = chained;
		loc_info->acc_key = EMS_P_00171;
		break;

	/* Event 6 prompt */
	case 5:
		*locate_desired = TRUE;
		EFget_locate_information(LITTLE_SURFACE, loc_info);
		key = EMS_P_00171;
		loc_info->eligible_classes.w_count = 3;
		loc_info->r_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[2] = OPP_EMSdatpln_class_id;
		loc_info->accept_event_type = dummy;
		loc_info->acc_key = EMS_P_00038;
		break;

	/* Event 7 prompt */
	case 6:
		*locate_desired = TRUE;
		EFget_locate_information(LITTLE_SURFACE, loc_info);
		key = EMS_P_00172;
		loc_info->eligible_classes.w_count = 3;
		loc_info->r_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[1] = OPP_EMSplane_class_id;
		loc_info->e_classes[2] = OPP_EMSdatpln_class_id;
		loc_info->accept_event_type = dummy;
		loc_info->acc_key = EMS_P_00038;
		break;

	/* Error */
	default:
		*my_msg = MSFAIL;
		goto wrapup;
	} /* switch (me->number_of_events_input) */
	/* Fix the event mask */
	if (*type_of_value_needed)
		*event_mask |= GRm_VALUE;
	/* Get the prompt string if not already done.  */
	if (prompt_string_set != TRUE) {
		ex$message(msgnumb = key, buff = prompt_string);
	}

wrapup:
	if (1 & *my_msg)
		return(TRUE);
	else
		return(FALSE);
}

method verify_event(IGRboolean use_default; IGRboolean *was_valid_event; 		IGRboolean *done)
{
	extern		void EFextract_points();
	IGRlong	save_num_events = 0;
	IGRboolean	*have_plane;
	IGRlong	key, sts, *my_msg, my_type;
	IGRpoint	points[20];
	IGRvector	*height_vector, *width_vector;
	struct		GRevent *event;
	struct		IGRplane plane;

	/* Compiler optimizations */
	my_msg = &me->msg;
	my_type = me->mytype;
	save_num_events = me->number_of_events_input;

	/* Initialize */
	*my_msg = MSSUCC;
	*done = FALSE;
	key = EMS_I_00001;
	*was_valid_event = TRUE;

	EFextract_points(me->number_of_events_input, me->events, points);

	event = &me->events[me->number_of_events_input - 1];

	/* I am cheating here and storing information computed by 
 	* this function in the events array.  This should be okay
 	* so long as I only use this stuff in events/places/states
 	* which are occur after the storage index.  For example the
 	* width and height vectors are used only after I have events[2]
 	* and the depth vector is only used after I have events[3].  */

	{
		struct	GRlc_info *info;

		info          = &me->events[0].located_object[0];
		have_plane    = &info->geom_parms.polygon_inx;
		width_vector  = (IGRvector *)&info->proj_pnt[0];
		height_vector = 
                     (IGRvector *)&me->events[0].located_object[1].proj_pnt[0];
		plane.point   = (IGRdouble *)width_vector;
		plane.normal  = (IGRdouble *)height_vector;
	}

	/* Branch based on the command state */
	switch (me->number_of_events_input)
	{
	/* Event 1 verification */
	case 1:
	{
	    IGRboolean	is_surface;
	    struct		GRlc_info *lc_info;
	    struct		GRid *id;
	    struct		GRmd_env *md_env;
	    struct		GRmdenv_info *mdenv_info;

	    lc_info = &event->located_object[0];
	    id = &lc_info->located_obj;
	    md_env = &lc_info->module_info;
	    mdenv_info = &md_env->md_env;
	    {
		OMuword	classid;

		sts = om$get_classid(objid = id->objid,
			    osnum = id->osnum,
			    p_classid = &classid);
		if (! (1 & sts)) {
			*my_msg = MSFAIL;
			goto wrapup;
		}
		sts = om$is_ancestry_valid(subclassid = classid,
		    superclassid = OPP_EMSsubbs_class_id);
		if (! (1 & sts)) {
			*my_msg = MSFAIL;
			goto wrapup;
		}
		is_surface = (sts == OM_S_SUCCESS);
	    }
	    event->located_object[1].geom_parms.polygon_inx = is_surface;
	    if(!is_surface) {
		extern	IGRlong EFgetprops();
		struct	GRprops properties;

		sts = EFgetprops(event, my_id, &properties, my_msg);
		if(! (1 & sts)) goto wrapup;
		if(!properties.phy_closed) {
			*was_valid_event = FALSE;
			key = EMS_I_00014;
		}
	    }
	    if(*was_valid_event) {
		struct GRid 	owner_id;
		OM_S_CHANSELECT to_owners;

		sts = om$send( msg = message GRvg.GRdetplane(my_msg, 
				&mdenv_info->matrix_type,
			    	mdenv_info->matrix, &plane),
			    targetid = id->objid,
			    targetos = id->osnum);
		if (! (1 & sts)) goto wrapup;
		if (*my_msg == MSSUCC)
			*have_plane = 1;
		else {
			*my_msg = MSSUCC;
			*have_plane = 0;
		}

          	EMmake_chanselect(GRconnector_to_owners, &to_owners);

		sts = om$get_objid_at_index (objid = id->objid,
				osnum = id->osnum,
				index = 0,
				p_chanselect = &to_owners,
				objidaddr = &owner_id.objid,
				osnumaddr = &owner_id.osnum);

		if(sts == OM_S_SUCCESS) {
	    	    IGRlong 	msg_loc;
		    enum GRdpmode DisplayMode;
		    if(EFisAncestryValid(&msg_loc, owner_id.objid,
			owner_id.osnum, OPP_EMSdatpln_class_id, FALSE)) {
			*was_valid_event = FALSE;
			key = EMS_S_InvInp;

			DisplayMode = GRhe;

			sts = om$send(msg = message GRgraphics.GRdisplay(my_msg,
				&mdenv_info->matrix_type,
				mdenv_info->matrix,
				&DisplayMode,
				&me->display_env.md_id),
				targetid = id->objid,
				targetos = id->osnum);
				
			if (! (1 & sts & *my_msg)) goto wrapup;
	            }
	        }
	    } /* if (*was_valid_event) */
	}
	break;

	/* Event 2 verification */
	case 2:
	{
	    me->start_PT_flag = TRUE;
	    me->sym_DIST_flag = FALSE;
	    if(me->event.response == EX_RJT_MOVEON) {
		    me->start_PT_flag = FALSE;
		    me->event.response = EX_MAX_RESPONSE;
		    sts = om$send(msg = message ECconstruct.add_event(FALSE),
			    targetid = my_id);
		    sts = om$send(msg = message ECconstruct.add_event(FALSE),
				    targetid = my_id);
	    }
	    else { /* distance */
		if(use_default) {
			*was_valid_event = FALSE;
			key = EMS_I_00006;
		}
		else if(event->response == EX_VALUE) {
		    IGRdouble	distance;
		    me->start_PT_flag = FALSE;
	    	    me->sym_DIST_flag = TRUE;
		    distance = event->event.value;
		    points[1][0] = plane.point[0] + distance * plane.normal[0];
		    points[1][1] = plane.point[1] + distance * plane.normal[1];
		    points[1][2] = plane.point[2] + distance * plane.normal[2];
		    points[2][0] = plane.point[0] - distance * plane.normal[0];
		    points[2][1] = plane.point[1] - distance * plane.normal[1];
		    points[2][2] = plane.point[2] - distance * plane.normal[2];
		} /* if (event->response == EX_DATA) */
		if(*was_valid_event && event->response == EX_VALUE) {
				*done = TRUE;
		} /* if (*was_valid_event) */
	    }
	}
	break;

	/* Event 3 verification */
	case 3:
	{
	    IGRboolean		status;
	    IGRlong		loc_msg;

	    me->nor_PROJ_flag = TRUE;
	    if(me->event.response == EX_RJT_MOVEON)
		me->nor_PROJ_flag = FALSE;
	    else { /* data point or distance */
		if (event->response == EX_DATA) {
			IGRdouble	t;
			IGRvector	vector;
			vector[0] = points[2][0] - points[1][0];
			vector[1] = points[2][1] - points[1][1];
			vector[2] = points[2][2] - points[1][2];
			t = vector[0] * plane.normal[0] +
			    vector[1] * plane.normal[1] + 
			    vector[2] * plane.normal[2];
			points[2][0] = points[1][0] + t * plane.normal[0];
			points[2][1] = points[1][1] + t * plane.normal[1];
			points[2][2] = points[1][2] + t * plane.normal[2];
		} /* if (event->response == EX_DATA) */
		else if (use_default) {
			*was_valid_event = FALSE;
			key = EMS_I_00006;
		}
		else {
			IGRdouble	distance, dot;
			IGRvector	vector;

			vector[0] = points[1][0] - plane.point[0];
			vector[1] = points[1][1] - plane.point[1];
			vector[2] = points[1][2] - plane.point[2];
			dot = vector[0] * plane.normal[0] +
			    vector[1] * plane.normal[1] + 
			    vector[2] * plane.normal[2];
			if (dot < 0.0)
				distance = -event->event.value;
			else
				distance = event->event.value;
			points[2][0] = points[1][0] + distance * plane.normal[0];
			points[2][1] = points[1][1] + distance * plane.normal[1];
			points[2][2] = points[1][2] + distance * plane.normal[2];
		} /* response is a value */
		if (*was_valid_event) {
			struct	EX_button *button;

			button = &event->event.button;
			button->x = points[2][0];
			button->y = points[2][1];
			button->z = points[2][2];
			status = BSdistnct2(&loc_msg, points[1], points[2]);
			if (!status)
				*was_valid_event = FALSE;
			else
				*done = TRUE;
		} /* if (*was_valid_event) */
	    }
	}
	break;

	/* Event 4 verification */
	case 4:
	{
		IGRboolean		status;
		IGRlong			loc_msg;

		if (*was_valid_event) {
			struct	EX_button *button;

			button = &event->event.button;
			button->x = points[3][0];
			button->y = points[3][1];
			button->z = points[3][2];
			status = BSdistnct2(&loc_msg, points[1], points[3]);
			if (!status)
				*was_valid_event = FALSE;
			else
				*done = TRUE;
		} /* if (*was_valid_event) */
	}
	break;

	/* Event 5 verification */
	case 5:
	  {
	    struct	GRmd_env *md_env;
	    struct	GRmdenv_info *mdenv_info;
	    struct	GRid *id;
	    struct	GRlc_info *lc_info;
	    struct	IGRplane st_plane;
	    IGRdouble 	plane_pt[3], plane_nor[3], cur_pt[3], sec_pt[3];
	    IGRpoint 	ln_pln_intpt;
	    IGRlong 	msg_loc;

	    lc_info = &event->located_object[0];
	    id = &lc_info->located_obj;
	    md_env = &lc_info->module_info;
	    mdenv_info = &md_env->md_env;
	    me->start_RP_flag = FALSE;
	    me->end_RP_flag = FALSE;
	    if(me->event.response == EX_RJT_MOVEON) {
		me->event.response = EX_MAX_RESPONSE;
		sts = om$send(msg = message ECconstruct.add_event(FALSE),
			    targetid = my_id);
	    }
	    else {
		me->start_RP_flag = TRUE;
		me->end_RP_flag = TRUE;

	        st_plane.point = plane_pt;
	        st_plane.normal = plane_nor;
	    
	        sts = om$send( msg = message GRvg.GRdetplane(my_msg, 
				&mdenv_info->matrix_type,
			    	mdenv_info->matrix, &st_plane),
			    targetid = id->objid,
			    targetos = id->osnum);
	        if(!(1 & sts))
			*was_valid_event = FALSE;

	        if(*was_valid_event) {
	            cur_pt[0] = plane.point[0];
	            cur_pt[1] = plane.point[1];
	            cur_pt[2] = plane.point[2];
	            sec_pt[0] = cur_pt[0] + plane.normal[0];
	            sec_pt[1] = cur_pt[1] + plane.normal[1];
	            sec_pt[2] = cur_pt[2] + plane.normal[2];

		    BSxlnpl(&msg_loc, plane_nor, plane_pt, cur_pt, sec_pt, 
			ln_pln_intpt);

		    if(msg_loc != BSSUCC) {
		        enum GRdpmode DisplayMode;
			*was_valid_event = FALSE;
			key = EMS_S_InvInp;

			DisplayMode = GRhe;

			sts = om$send(msg = message GRgraphics.GRdisplay(my_msg,
				&mdenv_info->matrix_type,
				mdenv_info->matrix,
				&DisplayMode,
				&me->display_env.md_id),
				targetid = id->objid,
				targetos = id->osnum);
				
			if (! (1 & sts & *my_msg)) goto wrapup;
		    }
	        } 
	    }
          }
          break;

	/* Event 6 verification */
	case 6:
	  {
	    struct	GRmd_env *md_env;
	    struct	GRmdenv_info *mdenv_info;
	    struct	GRid *id;
	    struct	GRlc_info *lc_info;
	    struct	IGRplane st_plane;
	    IGRdouble 	plane_pt[3], plane_nor[3], cur_pt[3], sec_pt[3];
	    IGRpoint 	ln_pln_intpt;
	    IGRlong 	msg_loc;

	    lc_info = &event->located_object[0];
	    id = &lc_info->located_obj;
	    md_env = &lc_info->module_info;
	    mdenv_info = &md_env->md_env;

	    st_plane.point = plane_pt;
	    st_plane.normal = plane_nor;
	    
	    sts = om$send( msg = message GRvg.GRdetplane(my_msg, 
				&mdenv_info->matrix_type,
			    	mdenv_info->matrix, &st_plane),
			    targetid = id->objid,
			    targetos = id->osnum);
	    if(!(1 & sts))
		*was_valid_event = FALSE;

	    if(*was_valid_event) {
	            cur_pt[0] = plane.point[0];
	            cur_pt[1] = plane.point[1];
	            cur_pt[2] = plane.point[2];
	            sec_pt[0] = cur_pt[0] + plane.normal[0];
	            sec_pt[1] = cur_pt[1] + plane.normal[1];
	            sec_pt[2] = cur_pt[2] + plane.normal[2];

		    BSxlnpl(&msg_loc, plane_nor, plane_pt, cur_pt, sec_pt, 
			ln_pln_intpt);

		    if(msg_loc != BSSUCC) {
		        enum GRdpmode DisplayMode;
			*was_valid_event = FALSE;
			key = EMS_S_InvInp;

			DisplayMode = GRhe;

			sts = om$send(msg = message GRgraphics.GRdisplay(my_msg,
				&mdenv_info->matrix_type,
				mdenv_info->matrix,
				&DisplayMode,
				&me->display_env.md_id),
				targetid = id->objid,
				targetos = id->osnum);
				
			if (! (1 & sts & *my_msg)) goto wrapup;
		    }
		    else *done = TRUE;
	    } 
          }
	  break;

	/* Event 7 verification */
	case 7:
	  {
	    struct	GRmd_env *md_env;
	    struct	GRmdenv_info *mdenv_info;
	    struct	GRid *id;
	    struct	GRlc_info *lc_info;
	    struct	IGRplane st_plane;
	    IGRdouble 	plane_pt[3], plane_nor[3], cur_pt[3], sec_pt[3];
	    IGRpoint 	ln_pln_intpt;
	    IGRlong 	msg_loc;

	    lc_info = &event->located_object[0];
	    id = &lc_info->located_obj;
	    md_env = &lc_info->module_info;
	    mdenv_info = &md_env->md_env;

	    st_plane.point = plane_pt;
	    st_plane.normal = plane_nor;
	    
	    sts = om$send( msg = message GRvg.GRdetplane(my_msg, 
				&mdenv_info->matrix_type,
			    	mdenv_info->matrix, &st_plane),
			    targetid = id->objid,
			    targetos = id->osnum);
	    if(!(1 & sts))
		*was_valid_event = FALSE;

	    if(*was_valid_event) {
	            cur_pt[0] = plane.point[0];
	            cur_pt[1] = plane.point[1];
	            cur_pt[2] = plane.point[2];
	            sec_pt[0] = cur_pt[0] + plane.normal[0];
	            sec_pt[1] = cur_pt[1] + plane.normal[1];
	            sec_pt[2] = cur_pt[2] + plane.normal[2];

		    BSxlnpl(&msg_loc, plane_nor, plane_pt, cur_pt, sec_pt, 
			ln_pln_intpt);

		    if(msg_loc != BSSUCC) {
		        enum GRdpmode DisplayMode;
			*was_valid_event = FALSE;
			key = EMS_S_InvInp;

			DisplayMode = GRhe;

			sts = om$send(msg = message GRgraphics.GRdisplay(my_msg,
				&mdenv_info->matrix_type,
				mdenv_info->matrix,
				&DisplayMode,
				&me->display_env.md_id),
				targetid = id->objid,
				targetos = id->osnum);
				
			if (! (1 & sts & *my_msg)) goto wrapup;
		    }
		    else {
			me->end_RP_flag = TRUE;
			*done = TRUE;
		    }
	    } 
          }
	  break;

	/* Error */
	default:
		*my_msg = MSFAIL;
		goto wrapup;
	} /* switch (me->number_of_events_input) */

	/* Output the error message, if any */
	if (! *was_valid_event)
		ex$message(msgnumb = key)

wrapup:
	if (1 & *my_msg)
		return(OM_S_SUCCESS);
	else
		return(OM_E_ABORT);
}


method perform_construction()
{
	IGRboolean	assoc_placement;
	extern		void EFextract_points();
	IGRlong        	sts, *my_msg;
	IGRpoint       	points[20];
	GRobjid        	*my_constructed_object;
	struct         	GRvg_construct *cnstrlist;
	struct         	GRlc_info *me_event_0_located_object_0;
	IGRboolean 	st_pt_flag, st_rp_flag, end_rp_flag, nor_flag;
	IGRboolean      is_surface, sym_flag;
	struct          GRlc_info *lc_info;
	struct          GRid *id;
	struct          GRmd_env *md_env;
	IGRboolean 	save_old_ASbroadcast;

	/* Compiler code reductions */

	my_msg = &me->msg;
	cnstrlist = &me->construct_list;
	my_constructed_object = &me->constructed_object;
	me_event_0_located_object_0 = &me->events[0].located_object[0];

	st_pt_flag = me->start_PT_flag;
	st_rp_flag = me->start_RP_flag;
	end_rp_flag = me->end_RP_flag;
	nor_flag = me->nor_PROJ_flag;
	sym_flag = me->sym_DIST_flag;

	/* Initialize */

	*my_msg = MSSUCC;
	*my_constructed_object = NULL_OBJID;
	EFextract_points(me->number_of_events_input, me->events, points);

	gr$get_associative_flag( buffer = &assoc_placement );

	lc_info = me_event_0_located_object_0;
	id = &lc_info->located_obj;
	md_env = &lc_info->module_info;
	is_surface = me->events[0].located_object[1].geom_parms.polygon_inx;

	/* The lift face operation is somehow putting itself into the 
        * batch list (which it should not) resulting in an update being
        * generated for the solid. The code for ASSOCIATIVELY creating a
        * solid of projection from a surface is not yet implemented, therefore, 
        * during the update, after the solid of projection is removed from the
        * range tree, the newly created associative solid (without any surfaces)
        * is added to the range tree and hence the solid seems to vanish on
        * screen. Solution to this is to:
        * 1. Prevent the user from picking a surface to project in the 
        *    associative mode and
        * 2. Making sure that the functions below are prevented from notifying
        *    the batch list (set ASbroadcast_in_progress = TRUE).
        * 
        * Both have been done. Eventually, somebody has to investigate why
        * the notify is being called within the 
	* "EMsweep_surface_via_lift_face_mod" code. 
	* Actually, setting ASbroadcast_in_progress need be done only if
        * "is_surface" is true, since surfaces are picked only for placing 
        * solids of proj. and not for placing surfaces of proj.
        */

	save_old_ASbroadcast = ASbroadcast_in_progress;
	ASbroadcast_in_progress = TRUE;

	if(is_surface) {
	    extern	IGRlong EMsweep_surface_via_lift_face_mod();
	    IGRpoint end_pt;

	    /* symmetric distance */
	    if(sym_flag) {
		extern IGRlong EFget_axis_from_curve_sym_dist();
		IGRpoint axis_line[2];
		IGRdouble distance;
		distance = me->events[1].event.value;
		
	    	sts = EFget_axis_from_curve_sym_dist(my_msg, lc_info, distance, 
		 	axis_line);
		if(!(1 & sts & *my_msg)) goto wrapup;

		OM_BLOCK_MOVE(axis_line[0], points[1], sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis_line[1], end_pt, sizeof(IGRpoint));
	    	sts = EMsweep_surface_via_lift_face_mod(lc_info, points[1], end_pt,
		 	cnstrlist, my_id, my_constructed_object, sym_flag,
			my_msg);
		if(!(1 & sts & *my_msg)) goto wrapup;
	    }
	    /* by two points */
	    else if(st_pt_flag) {
		if(nor_flag)
			OM_BLOCK_MOVE(points[2], end_pt, sizeof(IGRpoint));
		else 
			OM_BLOCK_MOVE(points[3], end_pt, sizeof(IGRpoint));

	    	sts = EMsweep_surface_via_lift_face_mod(lc_info, points[1], end_pt,
		 	cnstrlist, my_id, my_constructed_object, sym_flag,
			 my_msg);
		if(!(1 & sts & *my_msg)) goto wrapup;
	    }
	    else {
	    	struct GRlc_info curve, st_plane, end_plane;

	        curve = me->events[0].located_object[0];
	        /* by two planes */
	        if(st_rp_flag) {
			st_plane = me->events[4].located_object[0];
			end_plane = me->events[5].located_object[0];
	        }
	        /* only one plane */
	        else if(end_rp_flag) {
			st_plane.located_obj.objid = NULL_OBJID;
			end_plane = me->events[6].located_object[0];
	        }
	    	else {
			st_plane.located_obj.objid = NULL_OBJID;
			end_plane.located_obj.objid = NULL_OBJID;
	        }
	    	sts = EMsweep_surf_lift_face_trim(cnstrlist, 
			assoc_placement ? NULL : EMSasconst_notassociative,
			my_id, &curve, &st_plane, &end_plane, 
			my_constructed_object, my_msg);
		if(!(1 & sts & *my_msg)) goto wrapup;
	    }

	/* This may need to be removed eventually, when we let the user select
        * surfaces to project as solids. Right now the user cannot pick surfaces
        * in associative mode, but if he decides to pick in non-associative mode
        * and THEN turns off associativity before projection, this message will
        * be displayed. */

	    if (me->associative) {
		UI_status ("Warning: Solid of projection is non-associative");
		sleep (2);
	    }
	}
	else {
	    struct GRlc_info curve, st_plane, end_plane;
	    struct EMSpoint_info base, height;

	    curve = me->events[0].located_object[0];
	    base.type = EMSdatainfo_event;
	    height.type = EMSdatainfo_event;

	    /* by symmetric distance */
	    if(sym_flag) {
	    	base.type = EMSdatainfo_numeric;
	    	height.type = EMSdatainfo_numeric;
		base.ptevent = &me->events[1];
	    }
	    /* by two points */
	    else if(st_pt_flag) {
		base.ptevent = &me->events[1];
		if(nor_flag)
			height.ptevent = &me->events[2];
		else 
			height.ptevent = &me->events[3];
	    }
	    else {
		base.type = EMSdatainfo_name;
		height.type = EMSdatainfo_name;
	    }
	    /* by two planes */
	    if(st_rp_flag) {
		st_plane = me->events[4].located_object[0];
		end_plane = me->events[5].located_object[0];
	    }
	    /* only one plane */
	    else if(end_rp_flag) {
		st_plane.located_obj.objid = NULL_OBJID;
		end_plane = me->events[6].located_object[0];
	    }
	    else {
		st_plane.located_obj.objid = NULL_OBJID;
		end_plane.located_obj.objid = NULL_OBJID;
	    }

	    sts = EMplace_solid_of_projection (my_msg, 
			    assoc_placement ? NULL : EMSasconst_notassociative,
			    cnstrlist->env_info, cnstrlist->level,
			    cnstrlist->display, cnstrlist->class_attr,
			    cnstrlist->name, &curve, &base, &height,
			    &st_plane, &end_plane, my_constructed_object);
	    if(!(1 & sts & *my_msg)) goto wrapup;
	}

	ASbroadcast_in_progress = save_old_ASbroadcast;

wrapup:
	if (1 & *my_msg)
		return(OM_S_SUCCESS);
	else {
		*my_constructed_object = NULL_OBJID;
		return(OM_E_ABORT);
	}
}

method init(int type; char *str_ptr)
{
	IGRlong		sts;

	me->start_PT_flag = TRUE;
	me->nor_PROJ_flag = TRUE;
	me->start_RP_flag = FALSE;
	me->end_RP_flag = FALSE;
	me->sym_DIST_flag = FALSE;

	/* Let my parent do it's stuff */
	sts = om$send(mode = OM_e_wrt_message, 
		msg = message ECconstruct.init(type, str_ptr),
	    targetid = my_id);

	return(sts);
}

method perform_dynamics()

{
	extern		void EFextract_points();
	extern IGRlong 	EFrblineseg(), EFdyvector();
	IGRlong		my_type;
	IGRpoint	points[MAX_POINTS];
	struct		IGRdisplay *my_display;

	/* Compiler optimizations */
	my_type = me->mytype;
	my_display = &me->display;

	/* Initialize - note that I have made the assumption that
 	* the maximum case # will not exceed MAX_POINTS. */
	me->msg = MSSUCC;
	if(my_type == 203) goto wrapup;

	if (me->number_of_events_input < MAX_POINTS) 
		EFextract_points( me->number_of_events_input, me->events,
		    points);

	/* Branch based on the command state */
	switch (me->number_of_events_input)
	{
	/* Event 1 dynamics */
	case 1:
		break;

	/* Event 2 dynamics */
	case 2:
	{
		IGRvector	*normal;
		normal = (IGRvector *)
                        &me->events[0].located_object[1].proj_pnt[0];
		EFdyvector(normal, points[1], points[2], my_display);
	}
	break;

	/* Event 3 dynamics */
	case 3:
	{
		IGRvector	*normal;
		normal = (IGRvector *)&me->events[0].located_object[1].proj_pnt[0];
		EFrblineseg(points[1], my_display);
	}
	break;

	default:
		break;
	}

wrapup:
	if (1 & me->msg)
		return(OM_S_SUCCESS);
	else
		return(OM_E_ABORT);
}


method display_constructions(IGRboolean draw_background; 
	IGRboolean draw_single)

{
	extern		void EFextract_points();
	extern		IGRlong ECdisplayPointSetByBuffer();
	IGRboolean	use_default;
	IGRlong		number_of_points, i, alpha, omega, *my_msg, my_type;
	IGRpoint	points[MAX_POINTS];
	struct		IGRdisplay *my_display;
	struct		GRmd_env *my_display_env;

	/* Compiler optimizations */
	my_display = &me->display;
	my_display_env = &me->display_env;
	my_msg = &me->msg;
	my_type = me->mytype;

	/* Initialize */
	*my_msg = MSSUCC;

	/* Set up the loop indices */
	omega = me->number_of_events_input;
	if (!omega) goto wrapup;		/* Degenerate case */

	if (draw_single)
		alpha = omega;
	else
		alpha = 1;

	/* Enter the loop - Note that it is necessary to 
	* reextract the points each time since they are
 	* messed up in order to perform the display. */

	for(i = alpha; i <= omega; i++) {
	    use_default = FALSE;
	    number_of_points = 0;
	    if (i < MAX_POINTS) {
		EFextract_points(i,	/* me->number_of_events_input */
			me->events, points);
	    }

	/* Branch based on the command state */
	    switch (i)
	    {
		/* Event 1 construction lines */
		case 1:
			break;

		/* Event 2 construction lines */
		case 2:
			number_of_points = 1;
			points[0][0] = points[1][0];
			points[0][1] = points[1][1];
			points[0][2] = points[1][2];
			break;

		default:
			break;
	    }

	    /* Display my constructions */
	    if(use_default) {
		number_of_points = 2;
		OM_BLOCK_MOVE(&me->events[i - 1].event.button.x, points[0],
			    sizeof(IGRpoint));
		OM_BLOCK_MOVE(&me->events[i - 2].event.button.x, points[1],
			    sizeof(IGRpoint));
	     } /* if (use_default) */
	     if(number_of_points) {
		IGRlong	sts, ECdisplayPointSetByBuffer();

		if(me->start_PT_flag) {
			sts = ECdisplayPointSetByBuffer(my_msg,
			    *my_display, *my_display_env,
			    my_id, number_of_points,
			    points, draw_background);
			if(! (1 & sts)) {
				*my_msg = MSFAIL;
				goto wrapup;
			}
		}
	    } /* if (number_of_points) */
	} /* for (i = start; i <= end; i++) */

wrapup:
	if (1 & *my_msg)
		return(TRUE);
	else
		return(FALSE);
}

end implementation ECplsolproj;
