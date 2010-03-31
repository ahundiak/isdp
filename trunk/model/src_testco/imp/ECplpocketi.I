/* ###################   APOGEE COMPILED   ################## */
class implementation ECplpocket;

/*
ABSTRACT:

The purpose of this command is to speed up the common operation of placing 
pockets in parts or bosses on parts.  The pocket may be drafted and the 
bottom edges of the pocket may be rounded.  The boss may be drafted and its 
intersection with the part may be rounded.

Histroy:

BL  10/11/89	Creation date.
BL  11/06/89    Added a LC_PLANAR_ONLY option to attributes.properties and
		GRgeomprops to get the profile's properties such that I don't
		need to extract the geometry of profile.
BL  01/25/90	Modified variable value_type from GRIO_SCALAR to GRIO_DISTANCE 
		in co$getevent and also added EFshort_cvtn() to handle when the 
		unit of distance is changed.
BL  06/21/90	Made change to interface such that the multi pockets/bosses can 
		be placed by using event generator. The EMmake_pocket method
		is moved to the new class, EMSslmacfea, represented the 
		macro features using locat modification.
Tapadia 04/10/91  Modified to make pockets/bosses associative.
Tapadia 04/16/91  Changed to ems$getevent from co$getevent. 
Tapadia 04/19/21  The instance data of pocket/boss is modified. Modified 
		  value_type from GRIO_ANGLE to GRIO_SCALAR in ems$getevent. 
Tapadia 07/15/91  All pockets now have the same depth. Multiple pockets of
		  varying depths can't be placed now (auto-dimesnioning)  
Tapadia 07/25/91  Option to place multiple pockets removed. Hence the COB is
		  modified & lot of extra code removed.
scw  08/08/91   Converted to use gr$dpb associative flag
Tapadia 05/21/92  Modified for message sub system compliance
scw  08/14/94   clarified sleep method
*/

#if DEBUG
#include <stdio.h>
#endif

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"	/* for co$getevent */
#include "lcdef.h"
#include "lc.h"
#include "madef.h"
#include "exmacros.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "EC_I.h"
#include "EC_M.h"
#include "emsdef.h"	/* for MAXINT */
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSaction.h"  /* for EMSaction_handler */
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasmacros.h" /* for ems$getevent */

#ifndef EMScmacros_include
#include "EMScmacros.h"
#endif

#ifndef EMSlogic_include
#include "EMSlogic.h"
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#endif


# ifndef DEBUG
# define DEBUG 0
# endif

# define POCKET 0
# define FAIL	0

/* for me->const_state use */
# define INIT	0
# define EXEC	1
# define DONE	2
# define UNDO	3
# define DNUD	4 /* don't undo */

/* for me->update_dia index use */
# define ON	1
# define OFF	2


#if DEBUG
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn ECplpocket: %s\n", error_message); \
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#endif

from GRvg import  GRgeomprops;
from GRgraphics import  GRdisplay, GRdelete;
from EMSsubbs import  EMgetowner;
from EMSdpr import  EMundo;
from EMSslmacfea import  EMmake_pocket_fea;


method init(int type; char *str_ptr)
{
	IGRlong  sts;

	/* initialize */
	sts = OM_S_SUCCESS;
	me->drafted = me->round = FALSE;
	me->const_state = INIT;
	me->draft_angle.event.value = me->round_radius.event.value = 0.0;
	me->num_parts = 0;
	me->solid_id.objid = me->construct_id.objid = NULL_OBJID;

	sts = om$send(mode = OM_e_wrt_message, msg = message COconst.init(type, 
	    str_ptr), targetid = my_id);
	ERROR(sts, 1, "init.init error");

ret_end:  
	return(sts);
} /* init */


method wakeup(int pos)
{
	IGRlong  msg, sts;
	enum GRdpmode  DisplayMode;
	IGRboolean     state;

	gr$get_associative_flag( buffer = &state );
	if(state)
        {
           me->associative = TRUE;
           GRdisplay_associative_button(TRUE);
	}
	else
           me->associative = FALSE;

	if(ME.super_cmd->mytype == POCKET)
	    ex$message(msgnumb = EM_M_PlacePocket)
	else ex$message(msgnumb = EM_M_PlaceBoss)
	msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	DisplayMode = GRbd;

	if(me->const_state == DONE || me->const_state == DNUD)
	{
	    if(om$is_objid_valid(objid = me->construct_id.objid) 
			== OM_S_SUCCESS)
	    {
		sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		    targetid = me->construct_id.objid,
		    targetos = me->construct_id.osnum);
		ERROR(sts, msg, "wakeup.GRdisplay(1) error");
	    } /* if */
	    else if(om$is_objid_valid(objid = me->solid_id.objid) 
			== OM_S_SUCCESS)
	    {
		sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		    targetid = me->solid_id.objid,
		    targetos = me->solid_id.osnum);
		ERROR(sts, msg, "wakeup.GRdisplay(2) error");
	    } /* else if */
	} /* if const_state == DONE */
	else 
	{
	    if(om$is_objid_valid(objid = me->solid_id.objid) == OM_S_SUCCESS)
	    {
		sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		    targetid = me->solid_id.objid,
		    targetos = me->solid_id.osnum);
		ERROR(sts, msg, "wakeup.GRdisplay(3) error");
	    }
	} /* else if */

ret_end: 
	return(sts);

} /* wakeup */


method super_cmd.sleep(int pos)
{
	IGRlong  msg_loc, sts;
	enum GRdpmode  DisplayMode;


	ex$message(msgnumb = EMS_P_ClearPromptField);
	ex$message(msgnumb = EMS_S_ClearStatusField);
	ex$message(msgnumb = EM_M_ClearMessageField);
	DisplayMode = GRbdhe;
	msg_loc = EMS_S_Success;
	sts = OM_S_SUCCESS;

	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "sleep.erase_hilite");

	if(me->associative)
		GRdisplay_associative_button(FALSE);

ret_end: 
	return(sts);

} /* sleep */


method delete(int f_defer_flag)
{
	IGRlong  sts;

	sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
	    targetid = my_id);
	ERROR(sts, 1, "delete.me error");

ret_end:
	return(sts);

} /* delete */


method execute(int *response; char *response_data; int pos)
{
	IGRboolean  stat_func;
	IGRint  i, n, point_size, event_size, greve_size;
	IGRlong  event_mask, sts, msg_loc, qsize;
	IGRdouble  bas_tol;
	GRobjid  *display_ids;
	static struct GRevent  event, acc_event, loc_event;

	/* initialize */
	sts = OM_S_SUCCESS;
	*response = TERMINATE;
	display_ids = NULL;
	event_size = sizeof(event);
	point_size = sizeof(IGRpoint);
	qsize = event_size - 2 * sizeof(IGRint);
	greve_size = sizeof(struct GRevent);

	sts = BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bas_tol);  /* ADDED line - Ashok */

	ERROR(sts, 1, "BSEXTRACTPAR error");

	do
	{
	    switch(ME.super_cmd->state)
	    {
	    case 0:
		ex$message( msgnumb = EMS_P_KeyDrAng );

		if(me->const_state == DONE)
			ex$message( msgnumb = EMS_I_ProcessCompBackUpToUndo)

		event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
		sts = ems$getevent(msg = &msg_loc, 
			event_mask = event_mask,
		    	value_type = GRIO_SCALAR, response = (long *)response, 
		    	response_data = response_data, event = &event);
		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);
		if(!(1 & sts) || msg_loc == MSFAIL)
		{
			sts = FAIL;
			goto  ret_end;
		}
		if(msg_loc == GRw_no_value)  
			event.response = EX_RJT_MOVEON;

		switch(event.response)
		{
		case EX_VALUE:
			if(event.event.value < 0)
			{
				ex$message(msgnumb = EMS_E_InvalidAngle);
				break;
			}

			/* it only for inward draft (negative radian) */
			OM_BLOCK_MOVE(&event, &me->draft_angle, greve_size);
			me->drafted = TRUE;
			me->const_state = INIT;
			me->num_parts = 0;
			ME.super_cmd->state = 1;
			break;

		case EX_RJT_MOVEON:
			me->drafted = FALSE;
			me->const_state = INIT;
			me->num_parts = 0;
			ME.super_cmd->state = 1;
			break;

		case EX_BACK_UP:
		    if(me->const_state == DONE)
		    {
			IGRint  display_count, involk_count;
			IGRushort  option;
			enum GRdpmode  DisplayMode;

			display_ids = NULL;
			display_count = involk_count = 0;
			option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

			sts = om$send(msg = message EMSdpr.EMundo(
			    		&msg_loc,
			    		&option,
			    		&me->surf_info[0].module_info,
			    		NULL, /* Active ids after undo */
					NULL, /* Number of active ids - better be 1 */
					NULL, /* Space manager for memory on active ids */
					&display_ids,	
			    		&display_count,	
			    		&involk_count),
				targetid = me->construct_id.objid,
			    	targetos = me->construct_id.osnum);
			ERROR(sts, msg_loc, "execute(0).EMundo error");

			/* redraw the referent center(s) and profile */

			DisplayMode = GRbd;
			sts =om$send(msg = message GRgraphics.GRdisplay(
			    	&msg_loc,
			       &me->surf_info[1].module_info.md_env.matrix_type,
			    	me->surf_info[1].module_info.md_env.matrix, 
			    	&DisplayMode, 
				&me->surf_info[1].module_info.md_id),
			    targetid = me->surf_info[1].located_obj.objid,
			    targetos = me->surf_info[1].located_obj.osnum);
			ERROR(sts, msg_loc, "execute(0).GRdisplay(2) error");

			me->const_state = EXEC;
			ME.super_cmd->state = 4;
			if(display_ids)  free(display_ids);

		    } /* if me->const_state = DONE */
		    else  ex$message(msgnumb = EMS_I_00005)
		    break;

		default:
			/* In order to prevent the model from being unnecessary
			undo, I need to check if the pocket/boss already made */

			if(me->const_state == DONE) 
				me->const_state = DNUD;/* don't undo */
				goto ret_end;
			} /* switch */
			break;

	    case 1:
		ex$message(msgnumb = EMS_P_KeyRndRad);

		event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
		sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		    value_type = GRIO_DISTANCE, response = (long *)response, 
		    response_data = response_data, event = &event);
		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);
		if(!(1 & sts) || msg_loc == MSFAIL)
		    {
			sts = FAIL;
			goto  ret_end;
		    }
		if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

		switch(event.response)
		    {
		    case EX_VALUE:
			if(event.event.value <= 0) {
				ex$message(msgnumb = EMS_E_InvalidData);
				break;
			}
			OM_BLOCK_MOVE(&event, &me->round_radius, greve_size);
			me->round = TRUE;
			ME.super_cmd->state = 2;
			break;

		    case EX_RJT_MOVEON:
			me->round = FALSE;
			ME.super_cmd->state = 2;
			break;

		    case EX_BACK_UP:
			ME.super_cmd->state = 0;
			break;

		    default:
			goto ret_end;
		    } /* switch */

		break;

	     case 2:
	     {
		n = me->num_parts;
		i = n - 1;
		if(ME.super_cmd->mytype == POCKET)  
			ex$message(msgnumb = EMS_P_KeyPocDep)
		else ex$message(msgnumb = EMS_P_KeyBosHeig)

		event_mask = GRm_VALUE | GRm_DATA | GRm_DIST | 
			    GRm_RJT_MOVEON | GRm_BACK_UP;
		sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
			    value_type = GRIO_DISTANCE, response = (long *)response, 
			    response_data = response_data, event = &event);
		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);
		if(!(1 & sts) || msg_loc == MSFAIL)
		{
			sts = FAIL;
			goto  ret_end;
		}
		if(msg_loc == GRw_no_value)
		{
			if(n == 0)
			{
				ex$message(msgnumb = EMS_I_00006); 
				break;
			}
			else event.response = EX_RJT_MOVEON;
		} /* if GRw_no_value */

		switch(event.response)
		{
		    case EX_VALUE:
			if(event.response == EX_VALUE) 
			{
			    	OM_BLOCK_MOVE(&event,&me->depth_eve,greve_size);
		     		me->active_depth = event.event.value;
			}
			else
			{
				ex$message(msgnumb = EMS_S_InvInp);
				break;
			}
			if(me->active_depth <= bas_tol)
			{
				ex$message(msgnumb = EMS_S_InvInp);
				break;
			}

			ME.super_cmd->state = 3;
			break;

	    	    case EX_RJT_MOVEON:
			ex$message(msgnumb = EMS_I_00006); 
			break;

		    case EX_BACK_UP:
			if(n > 0)
			{
				n = --me->num_parts;
			}
			ME.super_cmd->state = 1;
			break;

		    default:  
			goto ret_end;

		} /* switch */
		break;

	    } /* end of case 2 */

	    /* Get the surface info and its owner solid objid */

	    case 3:
	    {
		IGRchar locate_prompt[52],accept_prompt[52],relocate_prompt[52];
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		struct EMSaction_handler  locate;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass, accept_classid;
		extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
		extern IGRlong  EFlocate_action_handler();

		display_flag= ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
		ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);
		ex$message(msgnumb = EMS_P_AccProfileReject, 
			buff = accept_prompt);
		ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | 
					LC_PLANAR_ONLY | LC_WRITE_ONLY;
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
				    LC_NO_REF_HEADER | LC_REF_OBJECTS |
				    LC_LOCALMOD;
		strcpy(attributes.classes, "EMSsubbs");

		rtree_classes.w_count = 1;
		elig_classes.w_count = 1;
		rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
		rclass = OPP_EMSsubbs_class_id;
		eliclass = OPP_EMSsubbs_class_id;
		rtree_classes.p_classes = &rclass;
		elig_classes.p_classes = &eliclass;

		/* set up the owner must be a solid */
		accept_classid = OPP_EMSsolid_class_id;
		locate.next = NULL;
		locate.option = 5;
		locate.type = 3;
		locate.num_objects = 1;
		locate.objects.classids = &accept_classid;

		stat_func = lc$locate(rc = &object_was_located, 
		    		event1 = &me->locate_event, 
			    	event2 = &acc_event,
				event3 = &loc_event,
				mask1 = locate_mask, 
				mask2 = accept_mask, 
				eventsize= &event_size, 
				display_flag = display_flag, 
				response = response, 
				response_data = response_data, 
				locate_prompt = locate_prompt, 
				/* for solid only */
				act_handler = EFlocate_action_handler, 
				act_args = &locate, /* for solid only */
				acc_prompt = accept_prompt,
				relocate_prompt = relocate_prompt, 
				attributes = &attributes, 
				stack = &me->locate_stack, 
				rtree_classes = &rtree_classes, 
				eligible_classes = &elig_classes);

		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);

		if(stat_func == FALSE)
		{
			ex$message(msgnumb = EMS_P_ClearPromptField);
			ex$message(msgnumb = EMS_E_FailInputProcExit);
			*response = TERMINATE;
			goto ret_end;
		}
		if(!object_was_located)
		{
			if(me->locate_event.response == EX_BACK_UP)  
				ME.super_cmd->state = 2;
			else return(OM_S_SUCCESS);
		} /* if object was not located */
		else
		{
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc, "execute(3).erase_hilite error");

		    switch(acc_event.response)
		    {
		        case EX_DATA:
			    me->surf_info[0] = loc_event.located_object[0];

			    /* Get the active owner solid id */

			    sts = om$send(msg=message EMSsubbs.EMgetowner(
					&msg_loc,
					&me->solid_id.objid, FALSE),
				targetid = me->surf_info[0].located_obj.objid,
				targetos = me->surf_info[0].located_obj.osnum);
			    ERROR(sts,msg_loc,"execute(3).EMgetowner error");

			    me->solid_id.osnum = me->surf_info[0].located_obj.osnum;

			    sts = ex$putque(msg = &msg_loc, 
					response = response,
					byte = &qsize, 
					buffer = (char *)&acc_event.event);
			    ERROR(sts, msg_loc, "execute(3).putque error");
			    ME.super_cmd->state = 4;
			    break;

			case EX_BACK_UP:
			    ME.super_cmd->state = 2;
			    break;
			default:  
			    goto ret_end;

		    } /* switch */

		} /* else */
		break;

	    } /* case 3 */

	    /* Locate the profile and get infomation */

	    case 4:
	    {
		IGRchar locate_prompt[52],accept_prompt[52],relocate_prompt[52];
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass;
		extern OMuword OPP_GRcurve_class_id, OPP_GRbspline_class_id;
 		extern OMuword OPP_GRlinear_class_id;
		extern IGRlong EFlocate_action_handler();
		struct EMSaction_handler dont_locate;
		OMuword reject_classid;

		reject_classid = OPP_GRlinear_class_id;
		dont_locate.next= NULL;
		dont_locate.option= 2;
		dont_locate.type= 3;
		dont_locate.num_objects= 1;
		dont_locate.objects.classids = &reject_classid;

		display_flag= ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
		ex$message(msgnumb = EMS_P_IdentifyProfile, 
			buff = locate_prompt);
		ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
		ex$message(msgnumb = EMS_I_ProfileNotFound,
			buff = relocate_prompt);

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | 
					LC_PLANAR_ONLY | LC_RW;
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
				    LC_NO_REF_HEADER | LC_REF_OBJECTS;
		strcpy(attributes.classes, "GRbspline");

		rtree_classes.w_count = 1;
		elig_classes.w_count = 1;
		rtree_classes.w_flags = OM_CLST_subclass;
		elig_classes.w_flags = OM_CLST_subclass;
		rclass = OPP_GRbspline_class_id;
		eliclass = OPP_GRcurve_class_id;
		rtree_classes.p_classes = &rclass;
		elig_classes.p_classes = &eliclass;

		stat_func = lc$locate(rc = &object_was_located, 
		    		event1 = &me->locate_event, 
				event2 = &acc_event, 
				event3 = &loc_event, 
				mask1 = locate_mask, 
				mask2 = accept_mask, 
				eventsize = &event_size, 
			        display_flag = display_flag, 
				response = response, 
			        response_data = response_data, 
				locate_prompt = locate_prompt, 
				acc_prompt = accept_prompt,
				relocate_prompt = relocate_prompt, 
				act_handler = EFlocate_action_handler,
				act_args = &dont_locate,
				attributes = &attributes, 
				stack = &me->locate_stack, 
				rtree_classes = &rtree_classes, 
				eligible_classes = &elig_classes);

		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);
		if(stat_func == FALSE)
		{
			ex$message(msgnumb = EMS_E_FailInputProcExit);
			*response = TERMINATE;
			goto ret_end;
		} /* if */

		if(!object_was_located)
		{
			if(me->locate_event.response == EX_BACK_UP)  
				ME.super_cmd->state = 3;
			else return(OM_S_SUCCESS);
		}
		else
		{
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc, "execute(4).erase_hilite error");

		    switch(acc_event.response)
		    {
			struct GRprops  profile;

			case EX_DATA:
			    me->surf_info[1] = loc_event.located_object[0];
			    sts = om$send(msg = message GRvg.GRgeomprops(
					&msg_loc,
			        	&me->surf_info[1].module_info.md_env.matrix_type, 
				    	me->surf_info[1].module_info.md_env.matrix,
					&profile),
			  	targetid = me->surf_info[1].located_obj.objid,
				targetos = me->surf_info[1].located_obj.osnum);
			    ERROR(sts, msg_loc, "execute(4).GRgeomprops error");

			    /* Check if the profile is closed */

			    if(profile.phy_closed)
			    {
				sts = ex$putque(msg = &msg_loc, 
					response = response,
				    	byte = &qsize, 
					buffer = (char *)&acc_event.event);
				ERROR(sts, msg_loc, "execute(4).putque error");

				ME.super_cmd->state = 5;
			    } /* if CLOSE */
			    else
			    {
				ex$message(msgnumb = EMS_I_ProfileNotClosed);
				break;
			    }
			break;

			case EX_BACK_UP:
			    ME.super_cmd->state = 3;
			    break;
			default:  
			    goto ret_end;

		    } /* switch */
		} /* else object_was_located */

	    } /* case 4 */
	    break;

	    case 5:
		ex$message(msgnumb = EMS_P_00038);

		event_mask = GRm_DATA | GRm_BACK_UP;
		sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
			    response = (long *)response, response_data = response_data, 
			    event = &event);
		ex$message(msgnumb = EMS_P_ClearPromptField);
		ex$message(msgnumb = EMS_S_ClearStatusField);
		if(!(1 & sts) || msg_loc == MSFAIL)
		{
			sts = FAIL;
			goto  ret_end;
		}
		if(msg_loc == GRw_no_value)
		{
			ex$message(msgnumb = EMS_S_InvInp);
			break;
		}

		switch(event.response)
		{
		    case EX_DATA:
			ME.super_cmd->state = 6;
			break;

		    case EX_BACK_UP:
			ME.super_cmd->state = 4;
			break;

		    default:  
			goto ret_end;
		} /* switch */
	    break;

	    case 6:
	    {
		struct GRvg_construct const_list;
		extern OMuword  OPP_EMSslmacfea_class_id;

		ex$message(msgnumb = EMS_I_00003);

		const_list.msg = &msg_loc;
		const_list.env_info = &me->surf_info[0].module_info;
		const_list.newflag = FALSE;
		const_list.geometry = NULL;
		const_list.class_attr = NULL;
		const_list.name = NULL;
		const_list.level = ME.COconst->ActiveLevel;
		const_list.display = &ME.COconst->ActiveDisplay;
		const_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | 
					GRIS_NEW;

		me->construct_id.osnum = me->surf_info[0].located_obj.osnum;

		sts = om$construct(classid = OPP_EMSslmacfea_class_id,
				    p_objid = &me->construct_id.objid,
				    osnum = me->construct_id.osnum);
		ERROR(sts, 1, "construct error");

		/* Does the actual placement of pocket/boss */
		sts = om$send(msg = message EMSslmacfea.EMmake_pocket_fea(
			    	&msg_loc, ME.super_cmd->mytype, 
			    	&me->depth_eve, me->drafted, 
			 	&me->draft_angle, 
				me->round, &me->round_radius, 
				&const_list, &me->solid_id, &me->surf_info[0],
				me->associative ? NULL : 
				EMSasconst_notassociative), 
	   		targetid = me->construct_id.objid,
		    	targetos = me->construct_id.osnum);

		if(! (1 & sts & msg_loc))
		{
		    enum GRdpmode  DisplayMode;
		    IGRlong  stat_OM;

		    if(! (1 & sts))  
			ex$message(msgnumb = EMS_F_ConsFailRecModel)
		    else 
		    {
			if(ME.super_cmd->mytype == POCKET)
				ex$message(msgnumb = EMS_E_PlPockError)
			else 	ex$message(msgnumb = EMS_E_PlBossError)
			sts = FAIL;
		    }

		    /* redraw the original profile */
		    DisplayMode = GRbd;
		    stat_OM = om$send(msg = message GRgraphics.GRdisplay(
				&msg_loc,
			       &me->surf_info[1].module_info.md_env.matrix_type,
			    	me->surf_info[1].module_info.md_env.matrix, 
			    	&DisplayMode, 
				&me->surf_info[1].module_info.md_id),
			targetid = me->surf_info[1].located_obj.objid,
		    	targetos = me->surf_info[1].located_obj.osnum);

		    goto ret_end;
		}
		me->const_state = DONE;
		ME.super_cmd->state = 0;
		ex$message( msgnumb = EMS_I_ProcessCompBackUpToUndo);

	    } /* end of case 6 */
	    break;

	    default:
		goto ret_end;

	    } /* switch ME.super_cmd->state */
	} while( TRUE );

ret_end:
	if(!(1 & sts))
	{
	    if(ME.super_cmd->state == 0)
	    {
		enum GRdpmode  DisplayMode;

		DisplayMode = GRbd;

		if(om$is_objid_valid(objid=me->construct_id.objid) == 
				OM_S_SUCCESS)
		{
		    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		        targetid = me->construct_id.objid,
			targetos = me->construct_id.osnum);
		    ERROR(sts, msg_loc, "ret_end.GRdisplay(1) error");
		}
		else if(om$is_objid_valid(objid=me->solid_id.objid) == 
			OM_S_SUCCESS)
		{
		    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
			targetid = me->solid_id.objid,
			targetos = me->solid_id.osnum);
		    ERROR(sts, msg_loc, "ret_end.GRdisplay(2) error");
		}

		if(display_ids)  om$dealloc(ptr = display_ids);

	    } /* if ME.super_cmd->state = 0 */

	    me->num_parts = 0;
	    ME.super_cmd->state = 0;
	    sts = OM_S_SUCCESS; /* reset to return case 0 */
     	} /* if */

	return(sts);

} /* execute */

end implementation ECplpocket;
