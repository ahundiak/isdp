/* ###################   APOGEE COMPILED   ################## */
class implementation ECplslot;

/*
ABSTRACT:

This command creates slot. We can modify the depth of the slot (Thru all,
Thru next, Thru until & Finite).

HISTORY:

Tapadia  08/16/91	Creation date.  
Tapadia  10/09/91 	Fix for TR 91n2773
Tapadia  12/26/91 	Fix for TR 91n4227
Tapadia  01/06/92 	Support for closed profile.
Vadiraj  26/05/92       Modified for message subsystem compliance.
Sudha    07/05/93       Modified for BSprototypes ansification
Rustagi  11/30/93       Changing the LC_REF_OBJECTS to LC_NO_REF_OBJECTS as
                        we won't allow locating objects placed in the
                        reference files owing it to the design limitation
                        for feature placement. TR #119300805
scw      08/14/94       clarified sleep method
scw      09/14/96       removed math.h
                 

*/

#include "EC_I.h"
#include <stdio.h>
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
#include "exmacros.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "emsdef.h"	/* for MAXINT */
#include "EMSmsgdef.h"	/* for EMS_I_NoIntersection */
#include "EMSopt.h"
#include "EMSaction.h"  /* for EMSaction_handler */
#include "madef.h"	/* for MAIDMX */
#include "EMSasmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emserr.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "EMSdef.h"
#include "EC_P.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_E.h"
#include "EMSascmacros.h"

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#endif

#include "bsptlnplan.h"
#include "bscvnormal.h"

# define THR_ALL	0
# define THR_UNTIL	1
# define THR_NEXT	2
# define BLIND		3

/* for me->const_state use */
# define INIT	0
# define EXEC	1
# define DONE	2
# define UNDO	3
# define DNUD	4 /* don't undo */

# define FAIL	0

#if DEBUG
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn ECplslot: %s\n", error_message); \
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#endif

from GRvg import  GRgetsize, GRgetgeom, GRgetrang;
from GRgraphics import  GRdisplay, GRdelete;
from EMSsubbs import  EMgetowner;
from EMSdpr import  EMundo;

method init(int type; char *str_ptr)
{
	IGRlong  sts;

	/* initialize */
	ME.super_cmd->state = 0;
	ME.super_cmd->form_id = NULL_OBJID;
	me->solid_id.objid = me->construct_id.objid = NULL_OBJID;
	me->form_displayed = FALSE;
	me->const_state = INIT;
	me->depth_type = THR_ALL;
	me->dir_rev = FALSE;
	me->pro_nor_rev = FALSE;

	sts = om$send(mode = OM_e_wrt_message,
	    msg = message COconst.init(type, str_ptr), 
	    targetid = my_id);
	ERROR(sts, 1, "init.init error");

ret_end:
	return(sts);

} /* init */


method super_cmd.sleep(int pos)
{
	IGRlong  msg_loc, sts;
	enum GRdpmode  DisplayMode;

        ex$message(msgnumb=EMS_P_ClearPromptField);
        ex$message(msgnumb=EMS_S_ClearStatusField);
        ex$message(msgnumb=EM_M_ClearMessageField);
        ex$message(msgnumb=EMS_S_ClearStatusField, field=KEYIN_FIELD);
	DisplayMode = GRbdhe;
	msg_loc = EMS_S_Success;
	sts = OM_S_SUCCESS;

	if(me->associative)
		GRdisplay_associative_button(FALSE);

	if(me->form_displayed == TRUE)
		FIf_erase (ME.ECplslot->form1);

	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "sleep.erase_hilite");

ret_end:
	return(sts);

} /* sleep */


method wakeup(int pos)
{
	IGRlong msg, sts;
	IGRint 	ret;
	enum GRdpmode  DisplayMode;
	IGRboolean  state;

	gr$get_associative_flag(buffer = &state);
	if(state) {
		me->associative = TRUE;
		GRdisplay_associative_button(TRUE);
	}
	else
		me->associative = FALSE;

        ex$message(msgnumb=EM_M_PlaceSlot);
	msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	DisplayMode = GRbd;

	if(me->const_state == DONE || me->const_state == DNUD) {
		if(om$is_objid_valid(objid = me->construct_id.objid) == 
			OM_S_SUCCESS) {
		    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		     	targetid = me->construct_id.objid,
			targetos = me->construct_id.osnum);
		    ERROR(sts, msg, "wakeup.GRdisplay(1) error");
		}
		else if(om$is_objid_valid(objid = me->solid_id.objid) == 
			OM_S_SUCCESS) {
		    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		    	targetid = me->solid_id.objid,
			targetos = me->solid_id.osnum);
		    ERROR(sts, msg, "wakeup.GRdisplay(2) error");
		}
	} /* if DONE or DONT_UNDO */
	else {
		if(om$is_objid_valid(objid = me->solid_id.objid) 
			== OM_S_SUCCESS) {
		    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix, 
			    &DisplayMode, &me->surf_info[0].module_info.md_id),
		    	targetid = me->solid_id.objid,
			targetos = me->solid_id.osnum);
		    ERROR(sts, msg, "wakeup.GRdisplay(3) error");
		}
	} /* else */

	if(me->form_displayed == TRUE)
		ret = FIf_display (ME.ECplslot->form1);
ret_end:
	return(sts);

} /* wakeup */


method delete(int f_defer_flag)
{
	IGRlong	sts;

        ex$message(msgnumb=EMS_S_ClearStatusField, field=KEYIN_FIELD);
	sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
	    targetid = my_id);
	ERROR(sts, 1, "delete.me error");

	/* Delete the form object */

	if(ME.super_cmd->form_id != NULL_OBJID) {
		sts = om$send(msg = message Root.delete(1),
		    targetid = ME.super_cmd->form_id);
		ERROR(sts, 1, "delete.form error");
	}
ret_end:
	return(sts);
} /* delete */


method execute(int *response; char *response_data; int pos)
{
	IGRboolean stat_func, world = TRUE;
	IGRint     i, j, event_size, rcode, num_pts;
	IGRlong    buf_size, event_mask, sts, msg_loc;
	GRobjid    *display_ids;
	IGRpoint   st_pt, *cur_pts;
	IGRvector  vec, nor_vec;
	GRrange    range;
	IGRchar    locate_prompt[52], accept_prompt[52], relocate_prompt[52];
	struct GRevent  event, acc_event, loc_event;
	struct IGRbsp_curve  *boundary;
	extern IGRboolean EFdisplay_curve_normal_or_tangent();
extern void EFdraw_vector_on_screen() ;

	/* initialize */
	sts = OM_S_SUCCESS;
	display_ids = NULL;
	boundary = NULL;
	cur_pts = NULL;
	event_size = sizeof(struct GRevent);

	do
	{
	    switch(ME.super_cmd->state)
	    {
	/* Get the profile information */

	    case 0:
	    {
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass;
		extern OMuword OPP_GRcurve_class_id, OPP_GRbspline_class_id;

		/* Invoke status form to review options */
		ex$message(msgnumb = EMS_I_InvkStatusFrm);
                GRstatus_display_button(1);

		display_flag = ALL_WINDOWS | ELEM_HILIGHT |NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
              ex$message(msgnumb = EMS_P_IdentifyProfile, buff = locate_prompt);
              ex$message(msgnumb = EMS_P_00038, buff = accept_prompt); 
           ex$message(msgnumb = EMS_I_ProfileNotFound, buff = relocate_prompt);

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | 
					LC_PLANAR_ONLY | LC_RW;
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
			    LC_NO_REF_HEADER | LC_REF_OBJECTS;
		strcpy(attributes.classes, "GRbspline");

		rtree_classes.w_count = 1;
		elig_classes.w_count = 1;
		rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
		rclass = OPP_GRbspline_class_id;
		eliclass = OPP_GRcurve_class_id;
		rtree_classes.p_classes = &rclass;
		elig_classes.p_classes = &eliclass;

		stat_func = lc$locate(rc = &object_was_located, 
			    	event1 = &me->locate_event, 
			    	event2 = &acc_event, 
				event3 = &loc_event,
				mask1 = locate_mask, 
				mask2 = accept_mask, eventsize= &event_size, 
				display_flag = display_flag, 
				response = response, 
				response_data = response_data, 
			   	locate_prompt = locate_prompt, 
				acc_prompt = accept_prompt,
				relocate_prompt = relocate_prompt, 
				attributes = &attributes, 
				stack = &me->locate_stack, 
				rtree_classes = &rtree_classes, 
				eligible_classes = &elig_classes);

                ex$message(msgnumb=EMS_P_ClearPromptField);  
                GRstatus_display_button(0);

		if(stat_func == FALSE) {
                        ex$message(msgnumb=EMS_E_FailInputProcExit);
			*response = TERMINATE;
			goto  ret_end;
		}
		if(!object_was_located) { 
		    if(me->locate_event.response == EX_BACK_UP) {
			/* Undo the previous state */
			if(me->const_state == DONE) { 
			    IGRint  display_count, involk_count;
 			    IGRushort  option;
    		   	    enum GRdpmode DisplayMode=GRbd;

			    display_count = involk_count = 0;
			    option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

  			    sts = om$send(msg = message EMSdpr.EMundo(&msg_loc,
					&option, &me->surf_info[0].module_info,
					NULL, NULL, NULL, &display_ids,
					&display_count, &involk_count), 
				targetid = me->construct_id.objid,
				targetos = me->construct_id.osnum);
  			    ERROR(sts, msg_loc, "execute(0).EMundo error");

			    me->const_state = UNDO;
   	    	   	    sts = om$send(msg = message GRgraphics.GRdisplay(
			  		&msg_loc,
         		  		&me->surf_info[2].module_info.md_env.matrix_type,
                	  		me->surf_info[2].module_info.md_env.matrix, 
                	  		&DisplayMode, 
					&me->surf_info[2].module_info.md_id),
                	  	targetid = me->surf_info[2].located_obj.objid,
			  	targetos = me->surf_info[2].located_obj.osnum);
   	    	   	    ERROR(sts, msg_loc,"execute(0).GRdisplay(3) error");

			    if(me->depth_type == BLIND)
				ME.super_cmd->state = 6;
			    else if(me->depth_type == THR_UNTIL) 
				ME.super_cmd->state = 5;
			    else /* thru_all & thru_next */
				ME.super_cmd->state = 4;
			}
		    }
		    else return(OM_S_SUCCESS);
		}
		else {
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc,"execute(0).erase_hilite error");

		    switch(acc_event.response)
		    {
		    case EX_DATA:
			boundary = NULL;
			me->surf_info[2] = loc_event.located_object[0];

			sts = om$send(msg = message GRvg.GRgetsize(&msg_loc, 
			      &me->surf_info[2].module_info.md_env.matrix_type, 
			      me->surf_info[2].module_info.md_env.matrix,
			      &buf_size),
		            targetid = me->surf_info[2].located_obj.objid,
		            targetos = me->surf_info[2].located_obj.osnum);
			ERROR(sts, msg_loc, "execute(0).GRgetsize(1) error");

			boundary = (struct IGRbsp_curve *) om$malloc(size = 
					buf_size);
			if(!boundary) {
				sts = FAIL;
				goto ret_end;
			}

			/* Get the curve geometric data */
			sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
			      &me->surf_info[2].module_info.md_env.matrix_type, 
			      me->surf_info[2].module_info.md_env.matrix,
			      (IGRchar *) boundary),
			    targetid = me->surf_info[2].located_obj.objid,
			    targetos = me->surf_info[2].located_obj.osnum);
			ERROR(sts, msg_loc, "execute(0).GRgetgeom(1) error");

			st_pt[0] = boundary->poles[0];
			st_pt[1] = boundary->poles[1];
			st_pt[2] = boundary->poles[2];

			num_pts = (IGRint)boundary->num_poles;

			cur_pts = (IGRpoint *) om$malloc(size = 
					num_pts * sizeof(IGRpoint));
			if(!cur_pts) {
				sts = FAIL;
				goto ret_end;
			}

			for(i = 0; i < num_pts; i++) {
			    j = 3 * i;
			    if(boundary->rational) {
				cur_pts[i][0] = boundary->poles[j] / 
					boundary->weights[i];
				cur_pts[i][1] = boundary->poles[j+1] / 
					boundary->weights[i];
				cur_pts[i][2] = boundary->poles[j+2] / 
					boundary->weights[i];
			    }
			    else {
				cur_pts[i][0] = boundary->poles[j];  
				cur_pts[i][1] = boundary->poles[j+1];
				cur_pts[i][2] = boundary->poles[j+2];
			    }
			}

			BSptlnplan(num_pts, FALSE, cur_pts, NULL, &rcode, 
				nor_vec, &msg_loc);

			/* Check if the boundary is valid. Profile is planar 
			(rcode == 3) */
			if(rcode == 3) { 
				BScvnormal2(&msg_loc, boundary, vec);
				if(me->depth_type == THR_ALL ||
				    me->depth_type == BLIND)
					ME.super_cmd->state = 1;
				else
					ME.super_cmd->state = 2;
			} /* if boundary is not planar */
			else {
			    if(rcode == 1)
                                ex$message(msgnumb=EMS_I_PtElmentNotSupported)
			    else if(rcode == 2)
                                ex$message(msgnumb=EMS_I_LinearElmentNotSupported)
                                
			    sleep(1);
			}

			if(boundary)  om$dealloc(ptr = boundary);
                         /* fix for mlk */
                          if(cur_pts)  
                            {
                            om$dealloc(ptr = cur_pts);
                            cur_pts = NULL;
                            }
			boundary = NULL;	
			break;

   		    case EX_BACK_UP:
			ME.super_cmd->state = 0;
			break;

  		    default:  
	   		if(me->const_state == DONE) 
				me->const_state = DNUD;/* don't undo */
			goto ret_end;

		    } /* switch */
		} /* else */
	    } /* case 0 */
	    break;

	/* Identify solid only for THR ALL & BLIND slot */

	    case 1:
	    {
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		struct EMSaction_handler  locate;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass, accept_classid;
		extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id, 
			OPP_EMSsurface_class_id;
		extern IGRlong  EFlocate_action_handler();

		display_flag = ALL_WINDOWS |ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
                ex$message(msgnumb = EMS_P_00032, buff = locate_prompt);

           ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
           ex$message(msgnumb = EMS_I_00012, buff = relocate_prompt); 

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
                /*
                 * Changing the LC_REF_OBJECTS to LC_NO_REF_OBJECTS as
                 * we won't allow locating objects placed in the 
                 * reference files owing it to the design limitation
                 * for feature placement.
                 */
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
		    	LC_NO_REF_HEADER | LC_NO_REF_OBJECTS | LC_LOCALMOD;
		strcpy(attributes.classes, "EMSsubbs");

		rtree_classes.w_count = 1;
		elig_classes.w_count = 1;
		rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
		rclass = OPP_EMSsubbs_class_id;
		eliclass = OPP_EMSsurface_class_id;
		rtree_classes.p_classes = &rclass;
		elig_classes.p_classes = &eliclass;

		/* set up the owner must be a solid */
		accept_classid = OPP_EMSsurface_class_id;
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
			    	mask2 = accept_mask, eventsize= &event_size, 
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

                ex$message(msgnumb=EMS_S_ClearStatusField);  
                ex$message(msgnumb=EMS_P_ClearPromptField);

		if(stat_func == FALSE) {
                        ex$message(msgnumb=EMS_E_FailInputProcExit)
			*response = TERMINATE;
			goto ret_end;
		}

		if(!object_was_located) {
			if(me->locate_event.response == EX_BACK_UP)
				ME.super_cmd->state = 0;
			else 
				return(OM_S_SUCCESS);
		} /* if !object_was_located */
		else {
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc, "execute(1).erase_hilite error");

		    if(acc_event.response == EX_DATA) {
			me->surf_info[0] = loc_event.located_object[0];
			me->solid_id.objid = me->surf_info[0].located_obj.objid;
			me->solid_id.osnum = me->surf_info[0].located_obj.osnum;
			if(me->depth_type == BLIND)
				ME.super_cmd->state = 3;
			else
				ME.super_cmd->state = 4;
		    } /* if EX_DATA */
		    else if(acc_event.response == EX_BACK_UP)
			ME.super_cmd->state = 0;
		    else goto ret_end;
		} /* else object_was_located */
		break;
	    } /* case 1 */

	/* Identify surface for THR_UNTIL & THR_NEXT slot */

	    case 2:
	    {
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		struct EMSaction_handler  locate;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass, accept_classid;
		extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
		extern IGRlong  EFlocate_action_handler();

		display_flag = ALL_WINDOWS |ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
                ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);

               ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
               ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
		    	LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_LOCALMOD;
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
			    	mask2 = accept_mask, eventsize= &event_size, 
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

                ex$message(msgnumb=EMS_S_ClearStatusField); 
                ex$message(msgnumb=EMS_P_ClearPromptField);

		if(stat_func == FALSE) {
                        ex$message(msgnumb=EMS_E_FailInputProcExit) 
			*response = TERMINATE;
			goto ret_end;
		}

		if(!object_was_located) {
			if(me->locate_event.response == EX_BACK_UP)
				ME.super_cmd->state = 0;
			else 
				return(OM_S_SUCCESS);
		} /* if !object_was_located */
		else {
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc, "execute(2).erase_hilite error");

		    if(acc_event.response == EX_DATA) {
			me->surf_info[0] = loc_event.located_object[0];
			/* Get its active owner solid id */

			sts = om$send(msg = message EMSsubbs.EMgetowner(
					&msg_loc, &me->solid_id.objid, FALSE),
				targetid = me->surf_info[0].located_obj.objid,
				targetos = me->surf_info[0].located_obj.osnum);
			ERROR(sts, msg_loc, "execute(2).EMgetowner error");

			me->solid_id.osnum = me->surf_info[0].located_obj.osnum;
			if(me->depth_type == BLIND)
				ME.super_cmd->state = 3;
			else
				ME.super_cmd->state = 4;
		    } /* if EX_DATA */
		    else if(acc_event.response == EX_BACK_UP) 
			ME.super_cmd->state = 0;
		    else goto ret_end;
		} /* else object_was_located */
		break;
	    } /* case 2 */

	/* Show the profile normal orientation - only for BLIND slot  */

	    case 3:
		me->pro_nor_rev = FALSE;
		sts = om$send(msg = message GRvg.GRgetrang(&msg_loc,
			&me->surf_info[0].module_info.md_env.matrix_type,
			me->surf_info[0].module_info.md_env.matrix,
			&world, range),
		senderid = NULL_OBJID,
	   	targetid = me->solid_id.objid,
		targetos = me->solid_id.osnum);

		EFdraw_vector_on_screen(NULL_OBJID,
			&ME.COconst->ActiveDisplay, 
			&me->surf_info[0].module_info, GRbd,
			FALSE, st_pt, vec, range, &msg_loc);

                ex$message(msgnumb=EMS_P_AcptSlotDirnRejct);
		event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

		sts = ems$getevent(msg = &msg_loc, 
				event_mask = event_mask,	
				response = (long *)response,
				response_data = response_data,
				event = &event);

                ex$message(msgnumb=EMS_P_ClearPromptField);
                ex$message(msgnumb=EMS_S_ClearStatusField);
		if(!(1&sts) || msg_loc == MSFAIL) {
			sts = FAIL;
			goto ret_end;
		}

		EFdraw_vector_on_screen(NULL_OBJID,
			&ME.COconst->ActiveDisplay, 
			&me->surf_info[0].module_info, GRbe,
			FALSE, st_pt, vec, range, &msg_loc);

		switch(event.response)
		{
		case EX_DATA:
			ME.super_cmd->state = 4;
	     		break;

	  	case EX_RJT_MOVEON:
			me->pro_nor_rev = TRUE;
			ME.super_cmd->state = 4;
	     		break;

	  	case EX_BACK_UP:
			if(me->depth_type == THR_ALL || me->depth_type == BLIND)
				ME.super_cmd->state = 1;
			else
				ME.super_cmd->state = 2;
	     		break;

	  	default:
	   		/* In order to prevent the model from being unnecessary
			undo, I need to check if the slot already made */
	   		if(me->const_state == DONE) 
				me->const_state = DNUD;/* don't undo */
	   		goto ret_end;
		} /* switch */

	    break;

	/* Slot placement direction - to know which side to create the slot */

	    case 4:
		me->dir_rev = FALSE;
		stat_func = EFdisplay_curve_normal_or_tangent(&me->surf_info[2],
		 	NULL, TRUE, FALSE, my_id, GRbd, 
			&me->surf_info[0].module_info,
			&ME.COconst->ActiveDisplay, &msg_loc);

                ex$message(msgnumb=EMS_P_AcptMatRmovalDirnRejct);
		event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

		sts = ems$getevent(msg = &msg_loc, 
				event_mask = event_mask,	
				response = (long *)response,
				response_data = response_data,
				event = &event);

                ex$message(msgnumb=EMS_P_ClearPromptField);
                ex$message(msgnumb=EMS_S_ClearStatusField);
		if(!(1&sts) || msg_loc == MSFAIL) {
			sts = FAIL;
			goto ret_end;
		}

		stat_func =EFdisplay_curve_normal_or_tangent(&me->surf_info[2],
		 	NULL, TRUE, FALSE, my_id, GRbe, 
			&me->surf_info[0].module_info,
			&ME.COconst->ActiveDisplay, &msg_loc);

		if(event.response == EX_RJT_MOVEON)
			me->dir_rev = TRUE;

		switch(event.response)
		{
		case EX_DATA:
		case EX_RJT_MOVEON:
			if(me->depth_type == BLIND)
				ME.super_cmd->state = 6;
			else if(me->depth_type == THR_UNTIL)
				ME.super_cmd->state = 5;
			else
				ME.super_cmd->state = 7;
	     		break;

	  	case EX_BACK_UP:
			if(me->depth_type == THR_ALL) 
				ME.super_cmd->state = 1;
			else if(me->depth_type == BLIND) 
				ME.super_cmd->state = 3;
			else
				ME.super_cmd->state = 2;
	     		break;

	  	default:
	   		/* In order to prevent the model from being unnecessary
			undo, I need to check if the slot is already made */
	   		if(me->const_state == DONE) 
				me->const_state = DNUD;/* don't undo */
	   		goto ret_end;
		} /* switch */

	    break;

	/* Get another surface (exit) only if the slot's depth is THR_UNTIL */

	    case 5:
	    {
		IGRlong  locate_mask, accept_mask;
		IGRlong  object_was_located, display_flag;
		struct GRlc_locate  attributes;
		struct EMSaction_handler  locate;
		OM_S_CLASSLIST  rtree_classes, elig_classes;
		OMuword  rclass, eliclass, accept_classid;
		extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
		extern IGRlong  EFlocate_action_handler();

		display_flag = ALL_WINDOWS | ELEM_HILIGHT |NO_PROJ_ACCEPT_POINT;
		locate_mask = GRm_DATA | GRm_BACK_UP;
		accept_mask = GRm_DATA | GRm_BACK_UP;
                ex$message(msgnumb = EMS_P_IdntExtsrf, buff = locate_prompt);
                ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
                ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);

		attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
		attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
		    		LC_NO_REF_HEADER | LC_REF_OBJECTS;
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
				event2 = &acc_event, mask1 = locate_mask, 
				mask2 = accept_mask, eventsize= &event_size, 
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

                ex$message(msgnumb=EMS_S_ClearStatusField); 
                ex$message(msgnumb=EMS_P_ClearPromptField);
		if(stat_func == FALSE) {
                        ex$message(msgnumb=EMS_E_FailInputProcExit) 
			*response = TERMINATE;
			goto ret_end;
		}

		if(!object_was_located) {
		    if(me->locate_event.response == EX_BACK_UP)
			ME.super_cmd->state = 4;
		    else return(OM_S_SUCCESS);
		} /* if object was not located */
		else {
		    sts = dp$erase_hilite(msg = &msg_loc);
		    ERROR(sts, msg_loc, "execute(5).erase_hilite error");

		    switch(acc_event.response)
		    {
		    case EX_DATA:
			me->surf_info[1] = acc_event.located_object[0];
			me->slot.depth = 0.0; /* for profile slot */
			ME.super_cmd->state = 7;
			break;

		    case EX_BACK_UP:
			ME.super_cmd->state = 3;
			break;

		    default:  
			goto ret_end;
		    } /* switch */
		} /* else if object_was_located */
	    } /* case 5 */
	    break;

	/* Specify the slot depth only if it is a BLIND slot */

	    case 6:
                ex$message(msgnumb=EMS_P_KeyinSlotDepth);

		event_mask = GRm_VALUE | GRm_BACK_UP;
		sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		    	value_type = GRIO_DISTANCE, response = (long *)response, 
		    	response_data = response_data, event = &event);

                ex$message(msgnumb=EMS_P_ClearPromptField);  
                ex$message(msgnumb=EMS_S_ClearStatusField);

		if(!(1 & sts) || msg_loc == MSFAIL) {
			sts = FAIL;
			goto  ret_end;
		}
		if(msg_loc == GRw_no_value) {
                        ex$message(msgnumb=EMS_I_00006);
			break;
		}
		if(event.response == EX_VALUE) {
		    if(event.event.value <= 0) {
                        ex$message(msgnumb=EMS_S_InvInp)
			break;
		    }
		    else 
			OM_BLOCK_MOVE(&event, &me->depth_eve, event_size);
		    ME.super_cmd->state = 7;
		} /* if EX_DATA */
		else if(event.response == EX_BACK_UP)  ME.super_cmd->state = 4;
		else goto ret_end;
	    break;

	/* Does the construction of slot */

	    case 7:
	    {
		struct GRvg_construct construct_list;

		sts = dp$erase_hilite(msg = &msg_loc);
                ex$message(msgnumb=EMS_I_00003); 
        	ex$message(msgnumb=EMS_S_ClearStatusField, field=KEYIN_FIELD);
                construct_list.msg = &msg_loc;
		construct_list.env_info = &me->surf_info[0].module_info;
		construct_list.newflag = FALSE;
		construct_list.geometry = NULL;
		construct_list.class_attr = NULL;
		construct_list.name = NULL;
		construct_list.level = ME.COconst->ActiveLevel;
		construct_list.display = &ME.COconst->ActiveDisplay;
		construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE |
					 GRIS_NEW;

		me->construct_id.osnum = me->surf_info[0].located_obj.osnum;

		/* does the associative/non-associative slot placement */
/****************************************************************************
		sts = EFplace_slot(&msg_loc, NULL, me->dir_rev, 
			me->pro_nor_rev, &me->depth_type, &me->depth_eve, 
			&me->surf_info[0], &construct_list, &me->construct_id,
			me->associative ? NULL : EMSasconst_notassociative);
****************************************************************************/
                sts = ems$place_slot(msg = &msg_loc,
                                     is_dir_rev =  me->dir_rev,
                                     is_pro_nor_rev = me->pro_nor_rev,
                                     depth_type = &me->depth_type,
                                     depth = &me->depth_eve,
                                     surface = &me->surf_info[0],
                                     construction_list = &construct_list,
                                     resultant_obj = &me->construct_id,
              gen_opts = me->associative ? NULL : EMSasconst_notassociative);
		if( !(1 & sts & msg_loc)) {
                        ex$message(msgnumb=EMS_I_ErrorInConstruction)
			sts = FAIL; 
			goto ret_end;
		}
		else if(msg_loc == EMS_I_NoIntersection) {
                        ex$message(msgnumb=EMS_S_InvalidSlotConstrn)
			sts = FAIL; 
			goto ret_end;
		} /* if slot(s) doesn't intersect with solid  */
		else {
			me->const_state = DONE;
                        ex$message(msgnumb=EMS_I_ProcessCompBackUpToUndo);
			sleep(1);
			ME.super_cmd->state = 0;
			break;
		} /* slot success */
	    } /* case 7 */

	    default:	
		goto ret_end;

	    } /* switch ME.super_cmd->state */
	} while( TRUE );

ret_end:
    if(boundary)  
	om$dealloc(ptr = boundary);
    if(cur_pts)  
	om$dealloc(ptr = cur_pts);
	if(! (1 & sts)) {
		if(ME.super_cmd->state == 0) {
		    if(boundary)  
			om$dealloc(ptr = boundary);
		    if(cur_pts)  
			om$dealloc(ptr = cur_pts);
		}
		me->const_state = INIT;
		ME.super_cmd->state = 0;
		sts = OM_S_SUCCESS; /* reset to return case 0 */
	} /* if */
	return(sts);
} /* execute */

end implementation ECplslot;
