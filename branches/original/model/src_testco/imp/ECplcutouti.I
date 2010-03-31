/* ###################   APOGEE COMPILED   ################## */
class implementation ECplcutout;

/*
ABSTRACT:

This command creates  profile holes. 

HISTORY:

07/28/92  Rustagi  Created this file for 'PLACE CUTOUT' command. Added
                   and deleted code from its parent file 'ECplholei.I' 
                   for its present form.
07/30/92  Tapadia  Message sub system compliance, fixed some bugs & did some 
		   cleanup.
08/18/92  Tapadia  Fix for TR 92n5721
01/14/93  WBC      Replaced the call to BSprptonsf with a call to BSprptarrsf.
02/03/93  Tapadia  Fix for TR 119300629
07/05/93  Sudha    Modified for BSprototypes ansification
11/18/93  Rustagi  Fix for TR #119312907.
08/14/94  scw      clarified sleep method
*/

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
#include "bserr.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "ECmsg.h"
#include "ECcmd.h"
#include "msdef.h"
#include "msmacros.h"
#include "bsgeom_cvsf.h"
#include "ma.h"
#include "matypemx.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bstst_plan.h"
#include "bspt_in_cv.h"
#include "bsprptarrsf.h"
#include "bsfreecv.h"

# define THR_ALL	0
# define THR_UNTIL	1
# define THR_NEXT	2

/* for me->const_state use */
# define INIT	0
# define EXEC	1
# define DONE	2
# define UNDO	3
# define DNUD	4 /* don't undo */

# define FAIL	0
# define OFF_SURFACE	2

#define WBC_USE_NEW_MATH 1

#if DEBUG
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn ECplcutout: %s\n", error_message); \
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

from GRvg import  GRgetsize, GRgetgeom;
from GRgraphics import  GRdisplay, GRdelete;
from EMSsubbs import  EMgetowner, GRlnproject, EMget_unit_norm, GRptproject;
from EMSdpr import  EMundo;
from EMSslboolfea import  EMpunch_hole;

extern GRclassid OPP_GR3dpoint_class_id;

method init(int type; char *str_ptr)
{
    IGRlong  sts;

    /* initialize */
    ME.super_cmd->state = 0;
    ME.super_cmd->form_id = NULL_OBJID;
    me->solid_id.objid = me->construct_id.objid = NULL_OBJID;
    me->form_displayed = FALSE;
    me->const_state = INIT;
    me->num_holes = 0;
    me->depth_type = THR_ALL;

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

    ex$message(msgnumb = EMS_P_ClearPromptField)
    ex$message(msgnumb = EMS_I_ClearStatusField)
    ex$message(msgnumb = EM_M_ClearMessageField)
    ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)

    DisplayMode = GRbdhe;
    msg_loc = EMS_S_Success; 
    sts = OM_S_SUCCESS;

    if(me->associative)
	GRdisplay_associative_button(FALSE);

    if(me->form_displayed == TRUE)
    {
       FIf_erase (ME.ECplcutout->form1);
    }

    sts = dp$erase_hilite(msg = &msg_loc);
    ERROR(sts, msg_loc, "sleep.erase_hilite");

 ret_end:
    return(sts);

} /* sleep */


method wakeup(int pos)
{
    IGRlong  msg, sts;
    IGRint  ret;
    enum GRdpmode  DisplayMode;
    extern IGRlong  EFshort_cvtn();
    IGRboolean     state;

    gr$get_associative_flag( buffer = &state );
    if(state)
    {
	me->associative = TRUE;
	GRdisplay_associative_button(TRUE);
    }
    else
	me->associative = FALSE;

    ex$message(msgnumb = EM_M_PlaceCutout)
    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    DisplayMode = GRbd;

    if(me->const_state == DONE || me->const_state == DNUD)
    {
        if(om$is_objid_valid(objid = me->construct_id.objid) == OM_S_SUCCESS)
	{
   	    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->surf_info[0].module_info.md_env.matrix_type,
                me->surf_info[0].module_info.md_env.matrix, 
                &DisplayMode, &me->surf_info[0].module_info.md_id),
                targetid = me->construct_id.objid,
		targetos = me->construct_id.osnum);
   	    ERROR(sts, msg, "wakeup.GRdisplay(1) error");
	}
	else if(om$is_objid_valid(objid = me->solid_id.objid) == OM_S_SUCCESS)
	{
   	    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->surf_info[0].module_info.md_env.matrix_type,
                me->surf_info[0].module_info.md_env.matrix, 
                &DisplayMode, &me->surf_info[0].module_info.md_id),
                targetid = me->solid_id.objid,
		targetos = me->solid_id.osnum);
   	    ERROR(sts, msg, "wakeup.GRdisplay(2) error");
	}

    } /* if DONE or DONT_UNDO */
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

    } /* else */

    if(me->form_displayed == TRUE)
    {
    ret = FIf_display (ME.ECplcutout->form1);
    }

 ret_end:
    return(sts);

} /* wakeup */


method delete(int f_defer_flag)
{
    IGRlong	sts;

    ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)
    sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
		targetid = my_id);
    ERROR(sts, 1, "delete.me error");

    /*
     * Delete the form object.
     */

    if(ME.super_cmd->form_id != NULL_OBJID)
    {
       sts = om$send(msg = message Root.delete(1),
                 targetid = ME.super_cmd->form_id);
       ERROR(sts, 1, "delete.form error");
    }

ret_end:
    return(sts);

} /* delete */


method execute(int *response; char *response_data; int pos)
{
 IGRboolean  stat_func;
 IGRint  point_size, event_size, qsize, i, n;
 IGRlong  event_mask, sts, msg_loc;
 IGRdouble  dist_tol;
 GRobjid  *display_ids;
 struct GRevent  event, acc_event, loc_event;
 struct IGRbsp_surface  *surf;
 struct IGRbsp_curve  *boundary;
 extern IGRlong  ECdisplayPointSetByBuffer0(), EFshort_cvtn();
 extern IGRlong EFplace_hole_mod(), EFcomp_hole_depth(), EFcomphole_until(),
		EFpoint_on_object(), EFcomp_cut_until();
 extern IGRboolean EMptsubtype_supported();
 IGRvector temp_vec;
 IGRdouble v_angle = 118.0;
 IGRboolean axis_normal = TRUE;
 IGRpoint input_pt, surf_pt;
 struct GRparms proj_parms;

 /* initialize */
 sts = OM_S_SUCCESS;
 display_ids = NULL;
 surf = NULL;
 boundary = NULL;
 event_size = sizeof(struct GRevent);
 point_size = sizeof(IGRpoint);
 qsize = event_size - 2 * sizeof(IGRint);

 sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
 ERROR(sts, 1, "BSEXTRACTPAR error");

 do
 {
  switch(ME.super_cmd->state)
  {
    case 0:
    {
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      struct GRlc_locate  attributes;
      struct EMSaction_handler  locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass, accept_classid;
      extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
      extern IGRlong  EFlocate_action_handler();

      if(me->const_state == DONE) /* for UNDO stuff */ 
         	ex$message(msgnumb = EMS_I_PrCoBkUpToUnStFo)
      else 
		ex$message(msgnumb = EMS_I_InvkStatusFrm);
      GRstatus_display_button(1);
      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;
      ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);
      ex$message(msgnumb = EMS_P_AccProfileReject, buff = accept_prompt);
      ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY
				 | LC_PLANAR_ONLY | LC_WRITE_ONLY;

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
                mask2 = accept_mask, eventsize= &event_size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                act_handler = EFlocate_action_handler, /* for solid only */
                act_args = &locate, /* for solid only */
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)
      GRstatus_display_button(0);

      if(stat_func == FALSE)
      {
	if(*response == DATA) {
		break;
	}
	else { 
	ex$message(msgnumb = EMS_E_FailInputProcExit)
	 *response = TERMINATE;
	 goto ret_end;
	}
      }

      if(!object_was_located)
      {
        if(me->locate_event.response == EX_BACK_UP)
          {
	     if(me->const_state == DONE) /* for UNDO stuff */ 
	     {
		IGRint  display_count, involk_count;
 		IGRushort  option;

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

		{
    		   enum GRdpmode DisplayMode=GRbd;

   	    	   sts = om$send(msg = message GRgraphics.GRdisplay(
			  &msg_loc,
         		  &me->surf_info[2].module_info.md_env.matrix_type,
                	  me->surf_info[2].module_info.md_env.matrix, 
                	  &DisplayMode, &me->surf_info[2].module_info.md_id),
                	  targetid = me->surf_info[2].located_obj.objid,
			  targetos = me->surf_info[2].located_obj.osnum);
   	    	   ERROR(sts, msg_loc, "execute(0).GRdisplay(3) error");
		}
                for(i = 0 ; i < me->num_holes ; ++i)
                {
                   sts= ECdisplayPointSetByBuffer0(&msg_loc,
                        ME.COconst->ActiveDisplay,
                        me->surf_info[0].module_info, my_id, 1,
                        (IGRpoint *) me->hole[i].center, GRbd, IGRPS);
                }

                if(me->num_holes)  ME.super_cmd->state = 3;
                else  ME.super_cmd->state = 1;

             }
          }
        else {
            	if(me->const_state == DONE) me->const_state = DNUD;
		return(OM_S_SUCCESS);
	}
      } /* if !object_was_located */
      else
      {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(0).erase_hilite error");

	if(acc_event.response == EX_DATA)
	{
	   me->surf_info[0] = loc_event.located_object[0];

	   /* Get its active owner solid id */

           sts = om$send(msg = message EMSsubbs.EMgetowner(&msg_loc,
			&me->solid_id.objid, FALSE),
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
	   ERROR(sts, msg_loc, "execute(0).EMgetowner error");
       
	   me->solid_id.osnum = me->surf_info[0].located_obj.osnum;

	   sts = ex$putque(msg = &msg_loc, response = response,
			byte = (IGRlong *)&qsize, 
			buffer = (char *)&acc_event.event);
	   ERROR(sts, msg_loc, "execute(0).putque error");

	   ME.super_cmd->state = 5;

	} /* if EX_DATA */
	else if(acc_event.response == EX_BACK_UP)
	   ME.super_cmd->state = 1;  
	else 
           {
            	if(me->const_state == DONE) me->const_state = DNUD;
                goto ret_end;
           }

     } /* else object_was_located */
      break;

    } /* case 0 */

    case 1:
      ex$message(msgnumb = EMS_P_AccRefPlCutout);

      /* Fix for TR#119312907
       * ex$message(msgnumb = EMS_I_RefCntrInProfile)
       */

      event_mask = GRm_DATA | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      ex$message(msgnumb = EMS_P_ClearPromptField)

      if(!(1 & sts) || msg_loc == MSFAIL)
      {
	 sts = FAIL;
	 goto  ret_end;
      }
      if(msg_loc == GRw_no_value)
      {
         ex$message(msgnumb = EMS_S_InvInp)
	 break;
      }

      if(event.response == EX_DATA) {
	/* If a constrainted object is to be created */
	if(EMptsubtype_supported(&event)) {
	    OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
	    sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info[0].module_info.md_env.matrix_type,
			me->surf_info[0].module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		    targetid = me->surf_info[0].located_obj.objid,
		    targetos = me->surf_info[0].located_obj.osnum);
	    OM_BLOCK_MOVE(surf_pt, me->hole[0].center, point_size);
	}
	else {
            sts = EFpoint_on_object(&me->surf_info[0], &event, my_id, &msg_loc);
            OM_BLOCK_MOVE(&event.event.button.x, me->hole[0].center,point_size);
	}

	if(!(1 & sts & msg_loc)) {
             	ex$message(msgnumb = EMS_S_InvInp)
		break;
	}
        OM_BLOCK_MOVE(&event, &me->center_eve[0], event_size);

        sts = ECdisplayPointSetByBuffer0(&msg_loc,
                ME.COconst->ActiveDisplay,
                me->surf_info[0].module_info, my_id, 1,
                (IGRpoint *) me->hole[0].center, GRbd, IGRPS);
        ERROR(sts,msg_loc,"execute(1).ECdisplayPointSetByBuffer0 error");

	me->num_holes = 1;

 	sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
		&msg_loc, FALSE, /* inside solid */
		NULL, &me->surf_info[0].module_info.md_env,
		me->hole[0].center, me->axis_dir), 
		targetid = me->surf_info[0].located_obj.objid,
		targetos = me->surf_info[0].located_obj.osnum);
	  /* prevent center is not being projected to the located surface */
	if(sts == OFF_SURFACE) {
  	     sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[0].center, GRbe, IGRPS);

	     me->num_holes = 0;
             ex$message(msgnumb = EMS_S_InvInp)
	     break;
	}
	
 	ERROR(sts, msg_loc, "execute(1).EMget_unit_norm error");
	OM_BLOCK_MOVE(me->axis_dir, temp_vec, point_size);
	OM_BLOCK_MOVE(me->hole[0].center, me->hole[0].axis_line[0], 
			point_size);

	switch(me->depth_type)
	{
	    case THR_ALL:
	    case THR_NEXT:
		sts = EFcomp_hole_depth(&msg_loc,&axis_normal,
			&me->depth_type, NULL, temp_vec, &me->surf_info[0], 
			&me->solid_id, &me->hole[0]);

 	      	ERROR(sts, msg_loc, "execute(1).EMget_hole_depth error");
		ME.super_cmd->state = 3;
		break;
	    case THR_UNTIL:
		ME.super_cmd->state = 2;
		break;
	    default:
		goto ret_end;
	 } /* switch */

	me->const_state = EXEC;
      } /* if EX_DATA */
      else if(event.response == EX_BACK_UP)
	   ME.super_cmd->state = 5;
      else goto ret_end;
      break;

    /*
     * Get another surface info only if the hole's depth is THR_UNTIL
     */

    case 2:
    {
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      struct GRlc_locate  attributes;
      struct EMSaction_handler  locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass, accept_classid;
      extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
      extern IGRlong  EFlocate_action_handler();

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;

      ex$message(msgnumb = EMS_P_IdeExitSurface, buff = locate_prompt); 
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
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                act_handler = EFlocate_action_handler, /* for solid only */
                act_args = &locate, /* for solid only */
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)
      if(stat_func == FALSE)
      {
	  ex$message(msgnumb = EMS_E_FailInputProcExit)
	  *response = TERMINATE;
	  goto ret_end;
      }

      if(!object_was_located)
      {
        if(me->locate_event.response == EX_BACK_UP) 
	{
	       me->num_holes = 0;
  	       sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[0].center, GRbe, IGRPS);
	       ERROR(sts, msg_loc, 
			"execute(2).ECdisplayPointSetByBuffer0 error");

	       ME.super_cmd->state = 1;
	} /* if */
        else  return(OM_S_SUCCESS);
      } /* if object was not located */
      else
      {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(2).erase_hilite error");

	switch(acc_event.response)
	{
	  case EX_DATA:
	     me->surf_info[1] = acc_event.located_object[0];
	 	me->hole[0].radius = 0.0; /* for profile hole */
		if(me->depth_type == THR_UNTIL)
			sts = EFcomp_cut_until(&msg_loc, &axis_normal,
				&me->depth_type, NULL, temp_vec, 
				&me->surf_info[0], &me->solid_id, &me->hole[0]);
		else 
			sts = EFcomp_hole_depth(&msg_loc, &axis_normal,
				&me->depth_type, NULL, temp_vec, 
				&me->surf_info[0], &me->solid_id, &me->hole[0]);

		if(msg_loc == EMS_E_Fail) {
			ex$message(msgnumb = EMS_I_InvalidSurface)
 		 	sts = OM_S_SUCCESS;
		 	goto ret_end;
		}
	     ME.super_cmd->state = 3;
	     break;

	  case EX_BACK_UP:
	       	 me->num_holes = 0;
  	       	 sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[0].center, GRbe, IGRPS);
	       	 ERROR(sts, msg_loc, 
			"execute(2).ECdisplayPointSetByBuffer0 error");
		 ME.super_cmd->state = 1;
	      break;

	  default:  goto ret_end;
	} /* switch */

      } /* else if object_was_located */

    } /* case 2 */
    break;

    case 3:
      ex$message(msgnumb = EMS_P_CutRefCntrMvOn)
      event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      if(event.response != EX_DATA)
       ex$message(msgnumb = EMS_P_ClearPromptField)
      if(!(1 & sts) || msg_loc == MSFAIL)
      {
	  sts = FAIL;
	  goto  ret_end;
      }
      if(msg_loc == GRw_no_value)
      {
          ex$message(msgnumb = EMS_S_InvInp)
	  break;
      } /* if */

      switch(event.response)
      {
	case EX_DATA:
	{
	  n = me->num_holes;
	  /* If a constrainted object is to be created */
	  if(EMptsubtype_supported(&event)) {
	      OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
	      sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info[0].module_info.md_env.matrix_type,
			me->surf_info[0].module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		    targetid = me->surf_info[0].located_obj.objid,
		    targetos = me->surf_info[0].located_obj.osnum);
            ERROR(sts, msg_loc, "execute(3).GRptproject error");
	  }
	  else {
              sts = EFpoint_on_object(&me->surf_info[0], &event, my_id, 
			&msg_loc);
              ERROR(sts, msg_loc, "execute(3).EFpoint_on_object error");
	  }

	  if(om$dimension_of(varray = me->center_eve) <= me->num_holes) {
	      sts = om$vla_set_dimension(varray = me->center_eve,
			size = me->num_holes + 4);
	      ERROR(sts, msg_loc, "execute(3).vla_set_dimension");
	  }

          OM_BLOCK_MOVE(&event, &me->center_eve[n], event_size);
	  if(EMptsubtype_supported(&event))
              OM_BLOCK_MOVE(surf_pt, me->hole[n].center, point_size);
	  else 
              OM_BLOCK_MOVE(&event.event.button.x, me->hole[n].center,
                        point_size);

          sts = ECdisplayPointSetByBuffer0(&msg_loc,
                ME.COconst->ActiveDisplay,
                me->surf_info[0].module_info, my_id, 1,
                (IGRpoint *) me->hole[n].center, GRbd, IGRPS);
          ERROR(sts,msg_loc,"execute(3).ECdisplayPointSetByBuffer0(1) error");

	  me->num_holes++;
	  /* Get the unit axis vector */
 	  sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
			&msg_loc, FALSE, /* inside solid */
			NULL, &me->surf_info[0].module_info.md_env,
			me->hole[n].center, me->axis_dir), 
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
	  /* prevent center is not being projected to the located surface */
	  if(sts == OFF_SURFACE)
	  {
  	   	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[n].center, GRbe, IGRPS);

	   	me->num_holes--;
                ex$message(msgnumb = EMS_S_InvInp)
		break;
	  }
 	  ERROR(sts, msg_loc, "execute(3).EMget_unit_norm error");

	  OM_BLOCK_MOVE(me->axis_dir, temp_vec, point_size);
	  OM_BLOCK_MOVE(me->hole[n].center, me->hole[n].axis_line[0], 
			point_size);
	  switch(me->depth_type)
	  {
	     case THR_ALL:
	     case THR_NEXT:
		sts = EFcomp_hole_depth(&msg_loc, &axis_normal,
			&me->depth_type, &me->hole_depth, temp_vec, 
			&me->surf_info[0], &me->solid_id, &me->hole[n]);
 	    	ERROR(sts, msg_loc, "execute(3).EMget_hole_depth(1) error");
		break;

	     case THR_UNTIL:
	     {
		    me->hole[n].radius = 0.0; 
		    sts = EFcomp_cut_until(&msg_loc, &axis_normal,
			&me->depth_type, NULL, temp_vec, &me->surf_info[0], 
			&me->solid_id, &me->hole[n]);
 	      	    ERROR(sts, msg_loc, "execute(3).EMget_hole_depth(2) error");
	     } /* end of THR_UNTIL */
	     break;

	     default:
		goto ret_end;

	  } /* switch me->depth_type */

	  me->const_state = EXEC;
	  break;
	} /* case EX_DATA */

	case EX_RJT_MOVEON:
	   ME.super_cmd->state = 4;
	   break;

	case EX_BACK_UP:
	   /* I only allow the first backup to change the active hole dia, 
	      others will delete the latest hole until place another hole or 
	      delete all exist holes. */
	   {
	     if(me->depth_type == THR_UNTIL && me->num_holes == 1) 
	     {
		if(me->depth_type == THR_UNTIL)  ME.super_cmd->state = 2;
              ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)
		break;
	     }
	     else
	     {
	      	n = --me->num_holes;
  	      	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[n].center, GRbe, IGRPS);
	      	ERROR(sts, msg_loc, 
			"execute(3).ECdisplayPointSetByBuffer0 error");

	      	me->const_state = EXEC;
	      	if(me->num_holes == 0)
	      	{
                    ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)
		    ME.super_cmd->state = 1;
		    break;
	      	}
		else 
			ME.super_cmd->state = 3;	
		
	     }  /* else */

	   } 
	   break;

	default:  goto ret_end;
      } /* switch */
      break;

    case 4:
    {
      IGRushort hole_type;
      struct GRvg_construct construct_list;
      extern OMuword  OPP_EMSslboolfea_class_id;

# define  PROFILE	2
      sts = dp$erase_hilite(msg = &msg_loc);
      ex$message(msgnumb = EMS_I_Processing);
      ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)

      hole_type = PROFILE;

      for(i = 0 ; i < me->num_holes ; ++i)
      {
          sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
                me->surf_info[0].module_info, my_id, 1,
                (IGRpoint *) me->hole[i].center, GRbe, IGRPS);
          ERROR(sts, msg_loc, "execute(4).ECdisplayPointSetByBuffer0 error");
      }
      construct_list.msg = &msg_loc;
      construct_list.env_info = &me->surf_info[0].module_info;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.name = NULL;
      construct_list.level = ME.COconst->ActiveLevel;
      construct_list.display = &ME.COconst->ActiveDisplay;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;

      me->construct_id.osnum = me->surf_info[0].located_obj.osnum;

	sts = EFplace_hole_mod(&msg_loc, NULL, FALSE, axis_normal, hole_type, 
		&me->depth_type, me->center_eve, &me->dia_eve, &me->depth_eve,
		&me->surf_info[0], &v_angle, &construct_list,
	 	me->num_holes, me->hole, &me->construct_id, 
		me->associative ? NULL : EMSasconst_notassociative);

      if( !(1 & sts & msg_loc))
      {
         ex$message(msgnumb = EMS_I_ErrorInConstruction)
	 sts = FAIL; goto ret_end;
      }
      else if(msg_loc == EMS_I_NoIntersection)
      {
	ex$message(msgnumb = EMS_I_InvalidHoleConst)
	 sts = FAIL; goto ret_end;
      } /* if hole(s) doesn't intersect with solid  */
      else
      {
      	 me->const_state = DONE;
      	 ME.super_cmd->state = 0;
	 break;
      } /* punch_hole success */

    } /* case 4 */
      
    case 5:
    {
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      struct GRlc_locate  attributes;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass;
      extern OMuword OPP_GRcurve_class_id, OPP_GRbspline_class_id;

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;

      ex$message(msgnumb = EMS_P_IdentifyProfile, buff = locate_prompt);
      ex$message(msgnumb = EMS_P_AccRefPlCutout, buff = accept_prompt);
      ex$message(msgnumb = EMS_I_ProfileNotFound, buff = relocate_prompt);

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY | LC_RW;
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
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)

      if(stat_func == FALSE)
      {
	 ex$message(msgnumb = EMS_E_FailInputProcExit)
	 *response = TERMINATE;
	 goto  ret_end;
      }

      if(!object_was_located)
      {
         if(me->locate_event.response == EX_BACK_UP) ME.super_cmd->state = 0;
         else  return(OM_S_SUCCESS);
      }
      else
      {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(5).erase_hilite error");

	switch(acc_event.response)
	{
	 IGRlong  buf_size;
	 extern IGRboolean EFisAncestryValid();

	 case EX_DATA:
	    boundary = NULL;
	    surf = NULL;
	    me->surf_info[2] = loc_event.located_object[0];

	    /* Fix for TR 119300629 - Tapadia. A profile point was selected
	    as a profile curve with 2 degenerate points. Don't locate points 
	    as valid profile curves */

	    if(EFisAncestryValid(&msg_loc, me->surf_info[2].located_obj.objid,
	    	me->surf_info[2].located_obj.osnum,
		OPP_GR3dpoint_class_id, FALSE)) {
	    	ex$message(msgnumb = EMS_S_InvalidProfile)
		break;
	    }

	    sts = om$send(msg = message GRvg.GRgetsize(&msg_loc, 
			&me->surf_info[2].module_info.md_env.matrix_type, 
			me->surf_info[2].module_info.md_env.matrix,
			&buf_size),
			targetid = me->surf_info[2].located_obj.objid,
			targetos = me->surf_info[2].located_obj.osnum);
            ERROR(sts, msg_loc, "execute(5).GRgetsize(1) error");

	    boundary = (struct IGRbsp_curve *) om$malloc(size = buf_size);
            if(!boundary)
            {
	       sts = FAIL;
	       goto ret_end;
	    }

            sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
			&me->surf_info[2].module_info.md_env.matrix_type, 
			me->surf_info[2].module_info.md_env.matrix,
			(IGRchar *) boundary),
			targetid = me->surf_info[2].located_obj.objid,
			targetos = me->surf_info[2].located_obj.osnum);
	    ERROR(sts, msg_loc, "execute(5).GRgetgeom(1) error");

	    /* Fix for TR 119300629 - Tapadia. A profile point was selected
	    as a profile curve with 2 degenerate points. It was returned as a 
	    closed curve. Later BSpt_in_cv resulted in the command aborting as 
	    the points were both degenerate */

	    if(boundary->phy_closed && (boundary->num_poles < 3)) {
	    	ex$message(msgnumb = EMS_S_InvalidProfile)
		break;
	    }

	    /* Check if the boundary is valid */

	    if(boundary->phy_closed)
	    {
	      IGRboolean  on_surf;
	      IGRdouble  uv[2];
	      IGRpoint  pt;
              IGRint    numpts;
              BSrc      rc;
              struct BSgeom_bsp_surf geom_surface;
extern void EFinit_geom_surface() ;

	      /* Get the base surface's geometry */

	      sts = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc, 
			&me->surf_info[0].module_info.md_env.matrix_type, 
			me->surf_info[0].module_info.md_env.matrix,
			&buf_size),
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
              ERROR(sts, msg_loc, "execute(5).GRgetsize(2) error");

	      surf = (struct IGRbsp_surface *) om$malloc(size = buf_size);
              if(!surf)
              {
	    	 sts = FAIL;
	    	 goto ret_end;
	      }

	      sts = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc, 
			&me->surf_info[0].module_info.md_env.matrix_type, 
			me->surf_info[0].module_info.md_env.matrix, 
			(IGRchar *) surf),
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
              ERROR(sts, msg_loc, "execute(5).GRgetgeom(2) error");

	      if(boundary->rational)
	      {
		 pt[0] = boundary->poles[0] / boundary->weights[0];
		 pt[1] = boundary->poles[1] / boundary->weights[0];
		 pt[2] = boundary->poles[2] / boundary->weights[0];
	      }
	      else  OM_BLOCK_MOVE(boundary->poles, pt, point_size);

#if WBC_USE_NEW_MATH
              geom_surface.sfgen_cv = NULL;

              EFinit_geom_surface(&sts, surf,
                                  me->surf_info[0].located_obj.objid,
                                  me->surf_info[0].located_obj.osnum,
                                  &geom_surface);
              ERROR(sts, 1, "execute(5).EFinit_geom_surface error");

              numpts = 1;

              BSprptarrsf(&geom_surface, dist_tol, 0, 0, &numpts,
                          pt, uv, NULL, &on_surf, NULL, &msg_loc);

              if (geom_surface.sfgen_cv)
                  BSfreecv(&rc, geom_surface.sfgen_cv);

	      if(msg_loc != BSSUCC)
	      {
		 sts = FAIL;
		 goto ret_end;
	      }
#else
	      BSprptonsf(&msg_loc, surf, pt, &uv[0], &uv[1], &on_surf);
	      if(msg_loc != 0)
	      {
		 sts = FAIL;
		 goto ret_end;
	      }
#endif
	      /* check if the boundary on the surface */

	      if(on_surf)
	      {
	        IGRboolean  pos_orient;
    		IGRshort  modmat_type, xmat_type;
	        IGRint  in_boundary;
		IGRlong  num_pts;
		IGRvector  normal;
    	      	IGRmatrix  module_mat, xmat;
extern void EMtoplnxform() ;
		extern IGRlong EFpoint_on_object();

		/*
     		 * Since, BSpt_in_cv() routine only handles xy_plane curves,
     		 * We need to transform the projected curve and the surface's
     		 * points to the xy_plane before invoking this function.
     		 */
		/* If a constrainted object is to be created */
		if(EMptsubtype_supported(&acc_event)) {
	    	    OM_BLOCK_MOVE(&acc_event.event.button.x, input_pt, 
			point_size);
	    	    sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			    &me->surf_info[0].module_info.md_env.matrix_type,
			    me->surf_info[0].module_info.md_env.matrix,
			    input_pt, pt, &proj_parms),
		        targetid = me->surf_info[0].located_obj.objid,
		        targetos = me->surf_info[0].located_obj.osnum);
	            ERROR(sts, msg_loc, "execute(5).GRptproject error");
	    	    OM_BLOCK_MOVE(pt, me->hole[0].center, point_size);
		}
		else {
		    sts = EFpoint_on_object(&me->surf_info[0], &acc_event,
			my_id, &msg_loc);
	            ERROR(sts, msg_loc, "execute(5).EFpoint_on_object error");
	            OM_BLOCK_MOVE(&acc_event.event.button.x, pt, point_size);
		}

    		BStst_plan(surf->u_num_poles * surf->v_num_poles, surf->poles, 
                	surf->weights, &surf->planar, normal, &msg_loc);
    		if(msg_loc != 0) goto ret_end;

    		sts = MAidmx(&msg_loc, module_mat);
    		modmat_type = MAIDMX;

    		EMtoplnxform(&msg_loc, pt, normal, &modmat_type, module_mat, 
                  	&xmat_type, xmat, NULL, NULL, NULL);
    		if (!(1 & msg_loc)) goto ret_end;
 
    		sts = MAtypemx(&msg_loc, xmat, &xmat_type);
    		if(!(1 & msg_loc)) goto ret_end;

    		num_pts = 1;
    		sts = MAoptsxform(&msg_loc, &num_pts, &xmat_type, xmat, pt, pt);
    		if(!sts || !(1 & msg_loc)) goto ret_end;

     		sts = MArptsxform(&msg_loc, &boundary->num_poles, 
			&boundary->rational,
              		boundary->rational ? boundary->weights : NULL, xmat, 
			boundary->poles, boundary->poles);
     		if(!sts || !(1 & msg_loc)) goto ret_end;

		/* Check if the reference point inside the boundary */

	        BSpt_in_cv(boundary, pt, FALSE, &pos_orient, &in_boundary, 
			&msg_loc);
	        if(msg_loc != 0)
	        {
    		   if(boundary)  om$dealloc(ptr = boundary);
		   boundary = NULL;
		   break;
	        }

		if(!in_boundary)
		{
		  ex$message(msgnumb = EMS_I_RefCntrInProfile)
		}
	    	else
		{
	    	   sts = ex$putque(msg = &msg_loc, response = response,
			byte = (IGRlong *)&qsize, 
			buffer = (char *)&acc_event.event);
	    	   ERROR(sts, msg_loc, "execute(5).putque error");
		} /* else the center inside/on the profile */


	    	ME.super_cmd->state = 1;

	      } /* if on SURFACE */
	      else  ex$message(msgnumb = EMS_I_ProfileNotOnSurf)

	    } /* if boundary is CLOSED */
	    else  ex$message(msgnumb = EMS_I_ProfileNotClosed)

	    if(boundary)  om$dealloc(ptr = boundary);
	    if(surf)  om$dealloc(ptr = surf);
	    boundary = NULL;	surf = NULL;
	    break;

	 case EX_BACK_UP:
	    ME.super_cmd->state = 0;
	    break;
	 default:  goto ret_end;

	} /* switch */
      } /* else */

    } /* case 5 */
    break;

    default:	goto ret_end;

  } /* switch ME.super_cmd->state */
 } while( TRUE );

ret_end:
  if(! (1 & sts))
  {
     if(ME.super_cmd->state == 6)
     {
    	if(boundary)  om$dealloc(ptr = boundary);
    	if(surf)  om$dealloc(ptr = surf);
     }

     me->num_holes = 0;
     me->const_state = INIT;
     ME.super_cmd->state = 0;
     sts = OM_S_SUCCESS; /* reset to return case 0 */
  } /* if */
	
  return(sts);

} /* execute */

end implementation ECplcutout;

