/* ###################   APOGEE COMPILED   ################## */
class implementation ECplhole;

/*
ABSTRACT:

This command creates circular holes. With a circular hole, we can modify 
three parameters: axis direction, depth, and type of bottom(flat or V)
should the depth be finite.

History:

BL  07/28/89	Creation date.  
pp  08/23/89    Edited some of the UI strings.
BL  09/01/89	Enhanced this command such that it can handle different hole 
		diameters and respond the active hole dia to the user as well. 
BL  10/23/89	Changed the arguments for both methods, EMget_hole_depth and 
		EMget_unit_norm, and modified the properties in lc$locate
		from LC_WRITE_ONLY to LC_RW such that you can locate profile 
		in reference file. I also added code to check if the hole axis 
		direction is valid.
BL  01/26/90	Modified variable value_type from GRIO_SCALAR to GRIO_DISTANCE 
		in co$getevent and also added EFshort_cvtn() to handle when the 
		unit of distance is changed.
BL  06/21/90	Made change to interface such that the multi-blind holes can 
		be placed by using event generator. The EMpunch_hole method
		is moved to the new class, EMSslboolfea, represented the solid
		boolean features. Also, the undo stuff will be taken care by
		the new EMSslboolfea class so I removed some codes that redraw
		the modified surfaces after undo.
mm  03/25/91    Changed to c_based form.

Tapadia 03/30/91  Modified to make the feature hole associative. Changed to 
		  ems$getevent instead of co$getevent. 
Tapadia 04/18/91  The instance data of hole is modified.
Tapadia 04/29/91  Moved some of the existing code for a through until circular 
		  hole into a function as it's also used during recompute 
		  information (EFcomphole_until). Changed EMget_hole_depth from
		  a method to a function (EFcomp_hole_depth).
Tapadia 07/12/91  Option to change the diameter when placing multiple holes is
		  no longer supported.
Tapadia 07/23/91  Added an additional option (axis_normal) in EFplace_hole.
scw  08/08/91   Converted to use gr$dpb associative flag
Tapadia 01/13/92 Changed from EFpoint_on_object to GRptproject to compute the
		projected center point.
SM      05/05/92  Message subsystem compliance.
Tapadia 07/27/92 Rewrote the command object as the command flow for 2.1 changed
		extensively. Support for action handler done. In addition the 
		profile hole option which was earlier in this file is moved to 
		ECplcutouti.I & has a new command name Place Cutout. 
		Changed the function EFplace_hole to EFplace_hole_mod.
sampath 05/26/93 Added more arguments to function Hole_EFdyvector.
Sudha   07/05/93 Modified for BSprototypes ansification
sampath 07/29/93 Fix for TR 119302147.
Rustagi 11/30/93 Changing the LC_REF_OBJECTS to LC_NO_REF_OBJECTS as
                  we won't allow locating objects placed in the
                  reference files owing it to the design limitation
                  for feature placement. TR #119300805
scw     08/14/94 clarified sleep method

*/

#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
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
#include "dpstruct.h"
#include "dpdef.h"
#include "dp.h"
#include "emsdef.h"	/* for MAXINT */
#include "EMSmsgdef.h"	/* for EMS_I_NoIntersection */
#include "EMSopt.h"
#include "EMSaction.h"  /* for EMSaction_handler */
#include "madef.h"	/* for MAIDMX */
#include "EMSasmacros.h"
#include "EMSfeadef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emserr.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "ECmsg.h"
#include "ECcmd.h"
#include "msdef.h"
#include "msmacros.h"
#include "bsprepcirc.h"
#include "bsdistptpt.h"

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
# define OFF_SURFACE	2

%safe
static IGRdouble def_dia = -1.0;
static IGRdouble def_dep = -1.0;
%endsafe

#if DEBUG
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn ECplhole: %s\n", error_message); \
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


from GRvg import  GRgetsize, GRgetgeom, GRdetplane, GRgenabsg;
from GRgraphics import  GRdisplay, GRdelete;
from EMSsubbs import  EMgetowner, GRlnproject, EMget_unit_norm, GRptproject;
from EMSdpr import  EMundo;
from EMSsurface import  EMgetactiveid;
extern OMuword OPP_EMSdatpln_class_id, OPP_EMSsolid_class_id, 
		OPP_EMSsubbs_class_id, OPP_EMSsurface_class_id;

method init(int type; char *str_ptr)
{
    IGRlong  	sts;
    short 	num_defaults = 1, flag = 0;
    IGRlong 	msg = MSSUCC;
    IGRchar 	units[52];	

    /* initialize */
    ME.super_cmd->state = 0;
    ME.super_cmd->form_id = NULL_OBJID;
    me->solid_id.objid = me->construct_id.objid = NULL_OBJID;
    me->form_displayed = FALSE;
    me->show_center = me->pick_center = me->show_status = FALSE;
    me->const_state = INIT;
    me->num_holes = 0;
    me->axis_normal = TRUE;
    me->depth_type = THR_ALL;
    me->v_bottom = FALSE;
    me->ref_plane = FALSE;
    me->end_ref_plane = FALSE;
    /* the default angle of v_bottom */
    me->v_angle = 118.0;  

    sts = om$send(mode = OM_e_wrt_message,
		msg = message COconst.init(type, str_ptr), 
		targetid = my_id);
    ERROR(sts, 1, "init.init error");

    /* Get the default units */
    sts = co$get_default_units(msg = &msg,
			table_name = GRIO_DISTANCE,
			osnum = 2,
			flag = &flag,
			num_defaults = &num_defaults,
			default_units = units);

    /* Based on the units assign a default value for diameter & depth */
    if(strncmp(units,"mm", 2) == 0) {
	if(def_dia < 0.0) 
		def_dia = 5.0;
	if(def_dep < 0.0)
		def_dep = 25.0;
    }
    else if(strncmp(units,"in", 2) == 0) {
	if(def_dia < 0.0) 
		def_dia = 0.25;
	if(def_dep < 0.0)
		def_dep = 1.0;
    }
ret_end:
    return(sts);
} /* init */

method super_cmd.sleep(int pos)
{
    IGRint  i;
    IGRlong  msg_loc, sts;
    enum GRdpmode  DisplayMode;

    ex$message(msgnumb = EMS_P_ClearPromptField)
    ex$message(msgnumb = EMS_I_ClearStatusField)
    ex$message(msgnumb = EM_M_ClearMessageField)
    ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)

    DisplayMode = GRbdhe;
    msg_loc = EMS_S_Success; 
    sts = OM_S_SUCCESS;
    me->show_status = FALSE;

    if(me->associative)
	GRdisplay_associative_button(FALSE);

    if(me->form_displayed == TRUE)
       FIf_erase (ME.ECplhole->form1);

    sts = dp$erase_hilite(msg = &msg_loc);
    ERROR(sts, msg_loc, "sleep.erase_hilite");

    if(me->show_center) {
       extern IGRlong  ECdisplayPointSetByBuffer0();
       for(i = 0 ; i < me->num_holes ; ++i) {
  	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");
       }
       me->show_center = FALSE;
    }
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
    struct DPele_header circle;
    struct IGResbc ele_attr;
    IGRdouble radius;
    IGRvector vector, normal;
    IGRpoint center;
    struct IGRbsp_curve *curve;
    IGRint  bstype;

    gr$get_associative_flag( buffer = &state );
    if(state) {
	me->associative = TRUE;
	GRdisplay_associative_button(TRUE);
    }
    else
	me->associative = FALSE;
    ex$message(msgnumb = EM_M_PlaceHole)
    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    DisplayMode = GRbd;

    if(ME.super_cmd->state > 1) 
	   me->show_status = TRUE;

    if(me->const_state == DONE || me->const_state == DNUD) {
        if(om$is_objid_valid(objid = me->construct_id.objid) == OM_S_SUCCESS) {
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
    else {
	if(!me->show_center) {
	   IGRint  i;
    	   extern IGRlong  ECdisplayPointSetByBuffer0();

	   for(i = 0 ; i < me->num_holes ; i++) {
  	      sts= ECdisplayPointSetByBuffer0(&msg, ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[i].center, GRbd, IGRPS);
	      ERROR(sts, msg, "wakeup.ECdisplayPointSetByBuffer0 error");

   	      EFget_curve_buffer(BSCIRCLE_ORDER, 
			BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &curve);
	      radius = me->hole[0].radius;
              OM_BLOCK_MOVE(me->axis_dir, vector, sizeof(IGRpoint));
	      OM_BLOCK_MOVE(me->hole[i].center, center, sizeof(IGRpoint));
       	      BSprepcirc(&msg, center, &radius, vector, 
				curve, normal, &bstype);
	      ele_attr.is_polydis = FALSE;
	      ele_attr.is_curvedis = TRUE;

	      dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	      dp$display(msg = &msg, mode = GRhd, 
				buffer = &circle);
	   }
	   me->show_center = TRUE;
	} /* if */
	if(om$is_objid_valid(objid = me->solid_id.objid) == OM_S_SUCCESS) {   	
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
    	ret = FIf_display (ME.ECplhole->form1);

ret_end:
    return(sts);
} /* wakeup */


method delete(int f_defer_flag)
{
    IGRlong	sts, msg_loc, i;

    ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)
    sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
		targetid = my_id);
    ERROR(sts, 1, "delete.me error");

    /* Delete the form object */
    if(ME.super_cmd->form_id != NULL_OBJID) {
       sts = om$send(msg = message Root.delete(1),
                 targetid = ME.super_cmd->form_id);
       ERROR(sts, 1, "delete.form error");
    }

    if(me->show_center) {
      extern IGRlong  ECdisplayPointSetByBuffer0();
      for(i = 0 ; i < me->num_holes ; ++i) {
  	 sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[i].center, GRbe, IGRPS);
	 ERROR(sts, msg_loc, "delete.ECdisplayPointSetByBuffer0 error");
      }
    } /* if */

ret_end:
    return(sts);
} /* delete */


method execute(int *response; char *response_data; int pos)
{
 IGRboolean  stat_func;
 IGRint  point_size, event_size, i, n, bstype;
 IGRlong  event_mask, sts, msg_loc, qsize;
 IGRdouble bas_tol, radius;
 GRobjid  *display_ids;
 struct GRevent  event, acc_event, loc_event;
 struct IGRbsp_surface  *surf;
 struct IGRbsp_curve  *boundary;
 extern IGRlong  ECdisplayPointSetByBuffer0(), EFshort_cvtn();
 extern IGRlong EFplace_hole_mod(), EFcomp_hole_depth(), EFcomphole_until(),
		EFpoint_on_object(), EFcomp_hole_depth_ref(),
		EFcomphole_until_ref(), EFpton_refplane();
 extern IGRboolean EMptsubtype_supported();
 extern void EFdraw_vector_on_screen();
 IGRvector temp_vec, vector, normal;
 IGRpoint input_pt, surf_pt, center;
 struct GRparms proj_parms;
 IGRchar inp_buff[52];
 struct IGRbsp_curve *curve;
 struct IGResbc ele_attr;
 struct GRlc_info *ref_info;
 struct DPele_header circle;
 
 /* initialize */
 sts = OM_S_SUCCESS;
 display_ids = NULL;
 surf = NULL;
 boundary = NULL;
 event_size = sizeof(struct GRevent);
 point_size = sizeof(IGRpoint);
 qsize = event_size - 2 * sizeof(IGRint);

 sts = BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bas_tol);  
 ERROR(sts, 1, "BSEXTRACTPAR error");

 do
 {
  switch(ME.super_cmd->state)
  {
    case 0:
	/* undo status displayed */
        if(me->const_state == DONE)
         	ex$message(msgnumb = EMS_I_PrCoBkUpToUnStFo)
	/* Invoke status form to review options */
	else 
		ex$message(msgnumb = EMS_I_InvkStatusFrm);
        GRstatus_display_button(1);

	me->active_dia = def_dia;
	ex$message(msgnumb = EMS_P_KeyinHoleDiaDef, type = "%g",
		var = `me->active_dia`, buff = inp_buff);
	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
		in_buff = inp_buff);
	event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;

  	sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);
		
        ex$message(msgnumb = EMS_P_ClearPromptField)
        ex$message(msgnumb = EMS_I_ClearStatusField)
        GRstatus_display_button(0);

	if(!(1 & sts) || msg_loc == MSFAIL) {
	    sts = FAIL;
	    goto  ret_end;
	}
        if(msg_loc == GRw_no_value)
	    event.response = EX_RJT_MOVEON;

	switch(event.response) {	
	    case EX_VALUE:
	    	if(event.event.value <= 0) {
	    		ex$message(msgnumb = EMS_S_InvInp)
	     		break;
	    	}
	    	else {
			OM_BLOCK_MOVE(&event, &me->dia_eve, event_size);
			me->active_dia = event.event.value;
			def_dia = me->active_dia;
	    	}
	    	if(me->depth_type != BLIND)  ME.super_cmd->state = 2;
	    	else  ME.super_cmd->state = 1;
		break;

	    case EX_RJT_MOVEON:
	    	me->dia_eve.event.value = me->active_dia;
	    	if(me->depth_type != BLIND)  ME.super_cmd->state = 2;
	    	else  ME.super_cmd->state = 1;
		break;

	    case EX_STRING:
		if(toupper(event.event.keyin[0]) == 'T') 
			me->depth_type = THR_ALL;	
		else if(toupper(event.event.keyin[0]) == 'U') 
			me->depth_type = THR_UNTIL;	
		else if(toupper(event.event.keyin[0]) == 'N') 
			me->depth_type = THR_NEXT;	
		else if(toupper(event.event.keyin[0]) == 'B') 
			me->depth_type = BLIND;	
		break;

	    case EX_BACK_UP:
		/* for undo purpose */
        	if(me->const_state == DONE) {
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

			me->show_center = TRUE;
			for(i = 0 ; i < me->num_holes ; ++i) {
  	    	   	    sts= ECdisplayPointSetByBuffer0(&msg_loc, 
				ME.COconst->ActiveDisplay,
				me->surf_info[0].module_info, my_id, 1, 
				(IGRpoint *) me->hole[i].center, GRbd, IGRPS);

	  		    EFget_curve_buffer(BSCIRCLE_ORDER, 
				BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &curve);
			    radius = me->hole[0].radius;
          		    OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  		    OM_BLOCK_MOVE(me->hole[i].center, center, 
				point_size);
       	  		    BSprepcirc(&msg_loc, center, &radius, vector, 
				curve, normal, &bstype);
	  		    ele_attr.is_polydis = FALSE;
	  		    ele_attr.is_curvedis = TRUE;

	  		    dp$build_dis_buffer(buffer = &circle,
				ele_spec_att = &ele_attr,
				display_att = &ME.COconst->ActiveDisplay, 
				geometry = curve);

			    dp$display(msg = &msg_loc, mode = GRhd, 
				buffer = &circle);
			} 
			if(me->num_holes)  ME.super_cmd->state = 6;
			else  ME.super_cmd->state = 4;
	     	} /* if UNDO */
	        else  ex$message(msgnumb = EMS_I_00005)
	        break;

	    default:
		if(me->const_state == DONE) me->const_state = DNUD;
		goto ret_end;
			
	} /* switch */
	break;

    /* Specify the depth of hole only if it is a blind hole */

    case 1:
        me->active_depth = def_dep;
	ex$message(msgnumb = EMS_P_KeyinHoleDepDef, type = "%g",
		var = `me->active_depth`, buff = inp_buff);
	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
		in_buff = inp_buff);
        event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP; 
        sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField)
        if(!(1 & sts) || msg_loc == MSFAIL) {
		sts = FAIL;
		goto  ret_end;
        }
        if(msg_loc == GRw_no_value) 
	    event.response = EX_RJT_MOVEON;

        if(event.response == EX_VALUE) {
	    if(event.event.value <= 0) {
          	ex$message(msgnumb = EMS_S_InvInp)
	  	break;
	    }
	    else  {
		OM_BLOCK_MOVE(&event, &me->depth_eve, event_size);
		me->hole_depth = event.event.value;
		def_dep = me->hole_depth;
	    }
	    ME.super_cmd->state = 2;
        } /* if EX_DATA */
	else if(event.response == EX_RJT_MOVEON) {
	    me->depth_eve.event.value = me->active_depth; 
	    me->hole_depth = me->active_depth;
	    ME.super_cmd->state = 2;
	}
        else if(event.response == EX_BACK_UP)  ME.super_cmd->state = 0;
        else goto ret_end;
        break;

    /* Identify starting surface or reference plane */
      
    case 2: {
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      struct GRlc_locate  attributes;
      struct hole_loc_acthndlr_args  hole_locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass[2], accept_classid[2];
      IGRlong  EFhole_fea_action_handler();
      struct GRlc_dynamics hole_dyn;
      struct GRid my_tmp_id;
      IGRint EFhole_dynamics();

      IGRboolean  aflag=0;

      aflag = pwIsActivationOn();
      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;
      ex$message(msgnumb = EMS_P_IdeStaSurfRefPl, buff = locate_prompt);  

      ex$message(msgnumb = EMS_P_AccWitBaseCenter, buff = accept_prompt);
      ex$message(msgnumb = EMS_P_ValSuRefPlNoFound, buff = relocate_prompt);

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY ;

      if(aflag)
      {
       attributes.properties |= LC_RW; 
       me->ref_plane = 0;
      }

      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | 
                       LC_NO_REF_HEADER | LC_REF_OBJECTS |
                       LC_HANDLES | LC_LOCALMOD; 
      strcpy(attributes.classes, "EMSsubbs");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 2;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass[0] = OPP_EMSsubbs_class_id;
      eliclass[1] = OPP_EMSdatpln_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = eliclass;

      accept_classid[0] = OPP_EMSdatpln_class_id;
      accept_classid[1] = OPP_EMSsubbs_class_id;
      hole_locate.option = 1;
      hole_locate.acc_prompt = accept_prompt;
      hole_locate.num_objects = 2;
      hole_locate.classids = accept_classid;
      hole_locate.my_inst.objid = my_id;
      hole_locate.my_inst.osnum = OM_Gw_current_OS;
      hole_locate.next = NULL;
      my_tmp_id.objid = my_id;
      my_tmp_id.osnum = OM_Gw_current_OS;
      hole_dyn.GRlc_dyn = EFhole_dynamics;
      hole_dyn.add_info = (IGRchar *)&my_tmp_id;

      stat_func = lc$locate(rc = &object_was_located, 
		event1 = &me->locate_event, 
                event2 = &acc_event, 
		event3 = &loc_event,
		mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &event_size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
		dyn = &hole_dyn,
                act_handler = EFhole_fea_action_handler,
                act_args = &hole_locate,
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)

      if(stat_func == FALSE) {
	ex$message(msgnumb = EMS_E_FailInputProcExit)
	*response = TERMINATE;
	goto ret_end;
      }

      if(!object_was_located) {
        if(me->locate_event.response == EX_BACK_UP) {
	     if(me->depth_type == BLIND) ME.super_cmd->state = 1;
	     else  ME.super_cmd->state = 0;
	}
        else  
		return(OM_S_SUCCESS);
      } /* if !object_was_located */
      else
      {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(2).erase_hilite error");

	if(acc_event.response == EX_DATA) {
	   me->surf_info[0] = loc_event.located_object[0];

	   /* Get its active owner solid id */
	   if(!me->ref_plane) {
               sts = om$send(msg = message EMSsubbs.EMgetowner(&msg_loc,
				&me->solid_id.objid, FALSE),
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
	       ERROR(sts, msg_loc, "execute(2).EMgetowner error");
       
	       me->solid_id.osnum = me->surf_info[0].located_obj.osnum;
           }
	   if(!me->ref_plane) {
	   sts = ex$putque(msg = &msg_loc, response = response,
			byte = &qsize, buffer = (char *)&acc_event.event);
	   ERROR(sts, msg_loc, "execute(2).putque error");
	   }

	   if(!me->ref_plane) {
	   	me->pick_center = TRUE;
	   	ME.super_cmd->state = 4;
	   }
	   else 
	   	ME.super_cmd->state = 3;

	} /* if EX_DATA */
	else if(acc_event.response == EX_BACK_UP) {
	      if(me->depth_type == BLIND) ME.super_cmd->state = 1;
	      else  ME.super_cmd->state = 0;
	} /* else EX_BACK_UP */
	else goto ret_end;
      } /* else object_was_located */
    } /* case 2 */
    break;

    /* Identify solid for reference plane selection */

    case 3:
    {
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      struct GRlc_locate  attributes;
      struct EMSaction_handler  locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass, accept_classid;
      extern IGRlong  EFlocate_action_handler();

      display_flag = ALL_WINDOWS |ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;
      ex$message(msgnumb = EMS_P_SelSolToPlaHole, buff = locate_prompt);
      ex$message(msgnumb = EMS_P_AccWitBaseCenter, buff = accept_prompt);
      ex$message(msgnumb = EMS_I_00012, buff = relocate_prompt);

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
     /*
      * Changing the LC_REF_OBJECTS to LC_NO_REF_OBJECTS as we won't allow
      * locating objects placed in the reference files owing it to the design
      * limitation for feature placement.
      */
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
			LC_HANDLES | LC_NO_REF_HEADER | LC_REF_OBJECTS;
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

      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_S_ClearStatusField);

      if(stat_func == FALSE) {
	ex$message(msgnumb = EMS_E_FailInputProcExit);
      	*response = TERMINATE;
      	goto ret_end;
      }

      if(!object_was_located) {
		if(me->locate_event.response == EX_BACK_UP)
			ME.super_cmd->state = 2;
		else 
			return(OM_S_SUCCESS);
      } /* if !object_was_located */
      else {
	    sts = dp$erase_hilite(msg = &msg_loc);
	    ERROR(sts, msg_loc, "execute(1).erase_hilite error");

	    if(acc_event.response == EX_DATA) {
		me->surf_info[2] = loc_event.located_object[0];
		me->solid_id.objid = loc_event.located_object[0].located_obj.objid;
		me->solid_id.osnum = loc_event.located_object[0].located_obj.osnum;
	   	sts = ex$putque(msg = &msg_loc, response = response,
			byte = &qsize, buffer = (char *)&acc_event.event);
	   	ERROR(sts, msg_loc, "execute(2).putque error");

		ME.super_cmd->state = 4;
	    } /* if EX_DATA */
	    else if(acc_event.response == EX_BACK_UP)
		ME.super_cmd->state = 2;
	    else goto ret_end;
      } /* else object_was_located */
    } /* case 3 */
     break;

    /* Accept with a base center */

    case 4:
      if(me->pick_center)  me->pick_center = FALSE;
      else
		ex$message(msgnumb = EMS_P_PlaceBaseCntr)

      event_mask = GRm_DATA | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      ex$message(msgnumb = EMS_P_ClearPromptField)

      if(!(1 & sts) || msg_loc == MSFAIL) {
	 sts = FAIL;
	 goto  ret_end;
      }
      if(msg_loc == GRw_no_value) {
         ex$message(msgnumb = EMS_S_InvInp)
	 break;
      }

      if(event.response == EX_DATA) {
	/* If a constrainted object is to be created */
	if(EMptsubtype_supported(&event)) {
	    OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
	    if(!me->ref_plane) {
	    	sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info[0].module_info.md_env.matrix_type,
			me->surf_info[0].module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		    targetid = me->surf_info[0].located_obj.objid,
		    targetos = me->surf_info[0].located_obj.osnum);
	    }
	    else {
		ref_info = &me->surf_info[0];
		sts = EFpton_refplane(&msg_loc, ref_info, input_pt, 
			surf_pt);
	    }
	    OM_BLOCK_MOVE(surf_pt, me->hole[0].center, point_size);
	}
	/* projecting the point onto the surface */
	else if(!me->ref_plane) {
	        sts = EFpoint_on_object(&me->surf_info[0], &event, my_id, 
			&msg_loc);
	        OM_BLOCK_MOVE(&event.event.button.x, me->hole[0].center,
			point_size);
	}
	else { 	/* Reference plane */
	    	OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
		ref_info = &me->surf_info[0];
		sts = EFpton_refplane(&msg_loc, ref_info, input_pt, 
			surf_pt);

	        OM_BLOCK_MOVE(surf_pt, me->hole[0].center, point_size);
	}
	OM_BLOCK_MOVE(&event, &me->center_eve[0], event_size);
		
	if(!(1 & sts & msg_loc)) {
		ex$message(msgnumb = EMS_I_InvalidBaseCenter)
	   	break;
	}

  	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
		ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[0].center, GRbd, IGRPS);
	ERROR(sts,msg_loc,"execute(3).ECdisplayPointSetByBuffer0 error");

	me->show_center = TRUE;
	me->hole[0].radius = 0.5 * me->active_dia;
	me->num_holes = 1;

	if(!me->ref_plane) {
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

	     me->show_center = FALSE;
	     me->num_holes = 0;
             ex$message(msgnumb = EMS_S_InvInp)
	     break;
	  }
 	  ERROR(sts, msg_loc, "execute(3).EMget_unit_norm error");
        }
	
	/* display the circle which is eqvivalent to the hole diameter */
	EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0,
		&curve);
	radius = me->hole[0].radius;
        OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	OM_BLOCK_MOVE(me->hole[0].center, center, point_size);

	BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, &bstype);
	ele_attr.is_polydis = FALSE;
	ele_attr.is_curvedis = TRUE;
	dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	dp$display(msg = &msg_loc, mode = GRhd, buffer = &circle);

	OM_BLOCK_MOVE(me->axis_dir, temp_vec, point_size);
	OM_BLOCK_MOVE(me->hole[0].center, me->hole[0].axis_line[0], point_size);

	switch(me->depth_type) {
	    case THR_ALL:
	    case THR_NEXT:
		if(!me->ref_plane) {
		    sts = EFcomp_hole_depth(&msg_loc,&me->axis_normal,
			 &me->depth_type, NULL, temp_vec, &me->surf_info[0], 
			 &me->solid_id, &me->hole[0]);
		}	
		else {
		    sts = EFcomp_hole_depth_ref(&msg_loc,&me->axis_normal,
			 &me->depth_type, NULL, temp_vec, &me->surf_info[0], 
			 &me->solid_id, &me->hole[0]);
		}

 	      	ERROR(sts, msg_loc, "execute(3).EMget_hole_depth error");
		ME.super_cmd->state = 6;
		break;

	    case BLIND:
	     	me->hole[0].axis_line[1][0] = me->hole[0].center[0] + 
			me->hole_depth * me->axis_dir[0];
	     	me->hole[0].axis_line[1][1] = me->hole[0].center[1] + 
			me->hole_depth * me->axis_dir[1];
	     	me->hole[0].axis_line[1][2] = me->hole[0].center[2] + 
			me->hole_depth * me->axis_dir[2];
		ME.super_cmd->state = 6;
		break;

	    case THR_UNTIL:
		ME.super_cmd->state = 5;
		break;

	    default:
		goto ret_end;
  	} /* switch */
	me->const_state = EXEC;
      } /* if EX_DATA */
      else if(event.response == EX_BACK_UP) {
	if(me->ref_plane) ME.super_cmd->state = 3;
	else ME.super_cmd->state = 2;
      }
      else goto ret_end;
      break;

    /* Get another surface info only if the hole's depth is THR_UNTIL */

    case 5:
    {
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      struct GRlc_locate  attributes;
      struct hole_loc_acthndlr_args  hole_locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass[2], accept_classid[2];
      IGRlong  EFhole_fea_action_handler();

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;
      ex$message(msgnumb = EMS_P_IdeExitSuOrRefPl, buff = locate_prompt);
      ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
      ex$message(msgnumb = EMS_P_ValSuRefPlNoFound, buff = relocate_prompt);
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
			LC_HANDLES | LC_NO_REF_HEADER | LC_REF_OBJECTS; 
      strcpy(attributes.classes, "EMSsubbs");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 2;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass[0] = OPP_EMSsubbs_class_id;
      eliclass[1] = OPP_EMSdatpln_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = eliclass;

      accept_classid[0] = OPP_EMSdatpln_class_id;
      accept_classid[1] = OPP_EMSsubbs_class_id;
      hole_locate.option = 0;
      hole_locate.acc_prompt = accept_prompt;
      hole_locate.num_objects = 2;
      hole_locate.classids = accept_classid;
      hole_locate.my_inst.objid = my_id;
      hole_locate.my_inst.osnum = OM_Gw_current_OS;
      hole_locate.next = NULL;

      stat_func = lc$locate(rc = &object_was_located, 
		event1 = &me->locate_event, 
                event2 = &acc_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &event_size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                act_handler = EFhole_fea_action_handler,
                act_args = &hole_locate,
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)
      if(stat_func == FALSE) {
	  ex$message(msgnumb = EMS_E_FailInputProcExit)
	  *response = TERMINATE;
	  goto ret_end;
      }

      if(!object_was_located) {
        if(me->locate_event.response == EX_BACK_UP) {
	       	me->num_holes = 0;
  	       	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[0].center, GRbe, IGRPS);
	       	ERROR(sts, msg_loc, 
			"execute(5).ECdisplayPointSetByBuffer0 error");

	  	EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 
			TRUE, 0, &curve);
		radius = me->hole[0].radius;
          	OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  	OM_BLOCK_MOVE(me->hole[0].center, center, point_size);

       	  	BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, 
			&bstype);
	  	ele_attr.is_polydis = FALSE;
	  	ele_attr.is_curvedis = TRUE;

	  	dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	        dp$display(msg = &msg_loc, mode = GRhe, buffer = &circle);
	       	me->show_center = FALSE;
	   	ME.super_cmd->state = 4;
	} /* if */
        else  return(OM_S_SUCCESS);
      } /* if object was not located */
      else {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(5).erase_hilite error");

	switch(acc_event.response)
	{
	  case EX_DATA:
	    	me->surf_info[1] = acc_event.located_object[0];
		if(!me->ref_plane && !me->end_ref_plane) 
		    sts = EFcomphole_until(&msg_loc, &me->axis_normal,
				me->axis_dir, &me->surf_info[0], &me->hole[0]);
		else 
		    sts = EFcomphole_until_ref(&msg_loc, &me->axis_normal,
				me->axis_dir, &me->surf_info[0], &me->hole[0]);

		if(msg_loc == EMS_E_Fail) {
			ex$message(msgnumb = EMS_I_InvalidSurface)
 		 	sts = OM_S_SUCCESS;
		 	goto ret_end;
		}
	     	ME.super_cmd->state = 6;
	     	break;

	  case EX_BACK_UP:
	       	me->num_holes = 0;
  	        sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[0].center, GRbe, IGRPS);
	       	ERROR(sts, msg_loc, 
			"execute(5).ECdisplayPointSetByBuffer0 error");

	  	EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 
			TRUE, 0, &curve);
		radius = me->hole[0].radius;
          	OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  	OM_BLOCK_MOVE(me->hole[0].center, center, point_size);

       	  	BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, 
			&bstype);
	  	ele_attr.is_polydis = FALSE;
	  	ele_attr.is_curvedis = TRUE;

	  	dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	        dp$display(msg = &msg_loc, mode = GRhe, buffer = &circle);
		me->show_center = FALSE;
	      	ME.super_cmd->state = 4;
	      	break;

	  default:  goto ret_end;
	} /* switch */
      } /* else if object_was_located */
    } /* case 5 */
    break;

    case 6:
	ex$message(msgnumb = EMS_P_MoreBaseCntrMvOn)
	me->show_status = FALSE;
	if(!me->show_status) {
              ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)
     	      me->show_status = TRUE;
	 }

      	event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
      	sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      	if(event.response != EX_DATA)
       	ex$message(msgnumb = EMS_P_ClearPromptField)
      	if(!(1 & sts) || msg_loc == MSFAIL) {
	  	sts = FAIL;
	  	goto  ret_end;
      	}
      	if(msg_loc == GRw_no_value) {
          	ex$message(msgnumb = EMS_S_InvInp)
	  	me->show_status = FALSE;
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
	      if(!me->ref_plane) {
	      	 sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info[0].module_info.md_env.matrix_type,
			me->surf_info[0].module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		    targetid = me->surf_info[0].located_obj.objid,
		    targetos = me->surf_info[0].located_obj.osnum);

	         ERROR(sts, msg_loc, "execute(7).GRptproject error");
	     }
	     else {
                /*DLB 10/6/92 ref_info !set cmd sleeps*/
		ref_info = &me->surf_info[0]; 
		sts = EFpton_refplane(&msg_loc, ref_info, input_pt, 
			surf_pt);
	     }
	  }
	  else if(!me->ref_plane) {
	    	sts = EFpoint_on_object(&me->surf_info[0], &event, my_id, 
			&msg_loc);
	    	ERROR(sts, msg_loc, "execute(7).EFpoint_on_object error");
	  }
	  else { 	/* Reference plane */
	    	OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
                /*DLB 10/6/92 ref_info !set cmd sleeps*/
		ref_info = &me->surf_info[0];
		sts = EFpton_refplane(&msg_loc, ref_info, input_pt, 
			surf_pt);
	  }

	  if(om$dimension_of(varray = me->hole) <= me->num_holes) {
	      sts = om$vla_set_dimension(varray = me->hole,
			size = me->num_holes + 4);
	      ERROR(sts, msg_loc, "execute(7).vla_set_dimension");
	  }
	  if(om$dimension_of(varray = me->center_eve) <= me->num_holes){ 
	      sts = om$vla_set_dimension(varray = me->center_eve,
			size = me->num_holes + 4);
	      ERROR(sts, msg_loc, "execute(7).vla_set_dimension");
	  }

	  /* validation of holes */
	  if(BSdistptpt(&msg_loc, &event.event.button.x, me->hole[n-1].center)
		< bas_tol)  break;
	  else  {
      	      OM_BLOCK_MOVE(&event, &me->center_eve[n], event_size);
	      if(EMptsubtype_supported(&event)) 
		OM_BLOCK_MOVE(surf_pt, me->hole[n].center, point_size);
	      else if(!me->ref_plane) 
		OM_BLOCK_MOVE(&event.event.button.x, me->hole[n].center, 
			point_size);
	      else /* Reference plane */
		OM_BLOCK_MOVE(surf_pt, me->hole[n].center, point_size);
	  }
  	  sts = ECdisplayPointSetByBuffer0(&msg_loc, 
		ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[n].center, GRbd, IGRPS);
	  ERROR(sts,msg_loc,"execute(7).ECdisplayPointSetByBuffer0(1) error");

	  me->hole[n].radius = 0.5 * me->active_dia;
	  me->num_holes++;

	  if(!me->ref_plane) {  
	     /* Get the unit axis vector */
		/*
		   Fix for TR 119302147 : Caluculate normal only 
		   for first hole, display rest of the holes parllel
		   to the first hole.
		*/
                if(me->num_holes < 2)
                {
 	     	sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
				&msg_loc, FALSE, /* inside solid */
				NULL, &me->surf_info[0].module_info.md_env,
				me->hole[n].center, me->axis_dir), 
			targetid = me->surf_info[0].located_obj.objid,
			targetos = me->surf_info[0].located_obj.osnum);
		}
	     	/* prevent center if it is not being projected to the located 
		surface */
	        if(sts == OFF_SURFACE) {
  	   		sts = ECdisplayPointSetByBuffer0(&msg_loc, 
				ME.COconst->ActiveDisplay,
				me->surf_info[0].module_info, my_id, 1, 
				(IGRpoint *) me->hole[n].center, GRbe, IGRPS);

	   		me->num_holes--;
                	ex$message(msgnumb = EMS_S_InvInp)
			break;
	     	}
 	     	ERROR(sts, msg_loc, "execute(7).EMget_unit_norm error");
	  }

	  EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0,
			&curve);
	  radius = me->hole[0].radius;
          OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  OM_BLOCK_MOVE(me->hole[n].center, center, point_size);

       	  BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, &bstype);
	  ele_attr.is_polydis = FALSE;
	  ele_attr.is_curvedis = TRUE;

	  dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	  dp$display(msg = &msg_loc, mode = GRhd, buffer = &circle);
	  OM_BLOCK_MOVE(me->axis_dir, temp_vec, point_size);
	  OM_BLOCK_MOVE(me->hole[n].center, me->hole[n].axis_line[0], 
		point_size);

	  switch(me->depth_type)
	  {
	     case THR_ALL:
	     case THR_NEXT:
		if(!me->ref_plane && !me->end_ref_plane) 
		    sts = EFcomp_hole_depth(&msg_loc, &me->axis_normal,
			&me->depth_type, &me->hole_depth, temp_vec, 
			&me->surf_info[0], &me->solid_id, &me->hole[n]);
		else 
		    sts = EFcomp_hole_depth_ref(&msg_loc,&me->axis_normal,
			 &me->depth_type, NULL, temp_vec, &me->surf_info[0], 
			 &me->solid_id, &me->hole[n]);
 	    	ERROR(sts, msg_loc, "execute(7).EMget_hole_depth(1) error");
		break;

	     case THR_UNTIL:
		if(!me->ref_plane && !me->end_ref_plane) 
		   	sts = EFcomphole_until(&msg_loc, &me->axis_normal,
				me->axis_dir, &me->surf_info[0], &me->hole[n]);
		else 
		     	sts = EFcomphole_until_ref(&msg_loc, &me->axis_normal,
				me->axis_dir, &me->surf_info[0], &me->hole[n]);
		if(msg_loc == EMS_E_Fail) { 
			n = --me->num_holes;
  	    	        sts = ECdisplayPointSetByBuffer0(&msg_loc, 
				ME.COconst->ActiveDisplay,
				me->surf_info[0].module_info, my_id, 1, 
				(IGRpoint *) me->hole[n].center, GRbe, 
				IGRPS);
	    	        ERROR(sts, msg_loc,
			"execute(7).ECdisplayPointSetByBuffer0(2) error");

	  		EFget_curve_buffer(BSCIRCLE_ORDER, 
				BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &curve);
			radius = me->hole[0].radius;
          		OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  		OM_BLOCK_MOVE(me->hole[n].center, center, point_size);

       	  		BSprepcirc(&msg_loc, center, &radius, vector, curve, 
				normal, &bstype);
	  		ele_attr.is_polydis = FALSE;
	  		ele_attr.is_curvedis = TRUE;

	  		dp$build_dis_buffer(buffer = &circle,
				ele_spec_att = &ele_attr,
				display_att = &ME.COconst->ActiveDisplay, 
				geometry = curve);

	        	dp$display(msg = &msg_loc, mode = GRhe, buffer = &circle);

			ex$message(msgnumb = EMS_I_InvalidCntrLoc)
		    	me->show_status = TRUE;

 		    	sts = OM_S_SUCCESS;
		    	goto ret_end;
		}
	     break;

	     case BLIND:
	    	if(me->axis_normal) {
		   me->hole[n].axis_line[1][0] = me->hole[n].center[0] + 
			me->hole_depth * me->axis_dir[0];
		   me->hole[n].axis_line[1][1] = me->hole[n].center[1] + 
			me->hole_depth * me->axis_dir[1];
		   me->hole[n].axis_line[1][2] = me->hole[n].center[2] + 
			me->hole_depth * me->axis_dir[2];
	    	}
	    	else {
		    if(!me->ref_plane && !me->end_ref_plane) 
		   	sts = EFcomp_hole_depth(&msg_loc, &me->axis_normal,
				&me->depth_type, &me->hole_depth, temp_vec, 
				&me->surf_info[0], &me->solid_id, &me->hole[n]);
		    else 
		   	sts = EFcomp_hole_depth_ref(&msg_loc, &me->axis_normal,
				&me->depth_type, &me->hole_depth, temp_vec, 
				&me->surf_info[0], &me->solid_id, &me->hole[n]);
 	    	    ERROR(sts, msg_loc,"execute(7).EMget_hole_depth(3) error");
	    	} /* else axis is not normal */
		break;

	     default:
		goto ret_end;

	  } /* switch me->depth_type */

	  me->const_state = EXEC;
	  break;
	} /* case EX_DATA */

	case EX_RJT_MOVEON:
	   ME.super_cmd->state = 7;
	   break;

	case EX_BACK_UP:
	   /* I only allow the first backup to change the active hole dia, 
	      others will delete the latest hole until place another hole or 
	      delete all exist holes. */
	     if(me->depth_type == THR_UNTIL && me->num_holes == 1) {
		ME.super_cmd->state = 5;
                ex$message(field = KEYIN_FIELD, 
			msgnumb = EMS_I_ClearStatusField)
		break;
	     }
	     else {
	      	n = --me->num_holes;
  	      	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info[0].module_info, my_id, 1, 
			(IGRpoint *) me->hole[n].center, GRbe, IGRPS);
	      	ERROR(sts, msg_loc, 
			"execute(7).ECdisplayPointSetByBuffer0 error");

	  	EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 
			TRUE, 0, &curve);
		radius = me->hole[0].radius;
          	OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	  	OM_BLOCK_MOVE(me->hole[n].center, center, point_size);

       	  	BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, 
			&bstype);
	  	ele_attr.is_polydis = FALSE;
	  	ele_attr.is_curvedis = TRUE;

	  	dp$build_dis_buffer(buffer = &circle,
			ele_spec_att = &ele_attr,
			display_att = &ME.COconst->ActiveDisplay, 
			geometry = curve);

	        dp$display(msg = &msg_loc, mode = GRhe, buffer = &circle);

	     	me->show_status = FALSE;
	      	me->const_state = EXEC;
	      	if(me->num_holes == 0) {
		    me->show_center = FALSE;
              	    ex$message(field = KEYIN_FIELD, 
			msgnumb = EMS_I_ClearStatusField)
		    ME.super_cmd->state = 4;
		    break;
	      	}
		else 
		    ME.super_cmd->state = 6;
	     } 
	   break;

	default:  goto ret_end;
      } /* switch */
      break;

    case 7:
    {
      IGRushort hole_type;
      struct GRvg_construct construct_list;
      extern OMuword  OPP_EMSslboolfea_class_id;

# define  CIRCULAR	0	/* for the regular circular hole */
# define  V_BOTTOM 	1	/* for the blind hole with v_bottom */

      sts = dp$erase_hilite(msg = &msg_loc);
      ex$message(msgnumb = EMS_I_Processing);
      ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField)

      if(me->v_bottom && me->v_angle < 180)  hole_type = V_BOTTOM;
      else  hole_type = CIRCULAR;

      /* erase the center(s) of hole(s) */
      for(i = 0 ; i < me->num_holes ; ++i) { 
	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "execute(8).ECdisplayPointSetByBuffer0 error");
      }
      me->show_center = FALSE;
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

      sts = EFplace_hole_mod(&msg_loc, NULL, me->ref_plane, me->axis_normal, 
		hole_type, &me->depth_type, me->center_eve, &me->dia_eve, 
		&me->depth_eve, &me->surf_info[0], &me->v_angle, 
		&construct_list, me->num_holes, me->hole, &me->construct_id, 
		me->associative ? NULL : EMSasconst_notassociative);

      if( !(1 & sts & msg_loc)) {
         ex$message(msgnumb = EMS_I_ErrorInConstruction)
	 sts = FAIL; goto ret_end;
      }
      else if(msg_loc == EMS_I_NoIntersection) {
	ex$message(msgnumb = EMS_I_InvalidHoleConst)
	 sts = FAIL; goto ret_end;
      } /* if hole(s) doesn't intersect with solid  */
      else {
      	 me->const_state = DONE;
      	 ME.super_cmd->state = 0;
	 break;
      } /* punch_hole success */
    } /* case 7 */
      
    default:	goto ret_end;

  } /* switch ME.super_cmd->state */
 } while( TRUE );

ret_end:
  if(! (1 & sts)) {
     if(me->show_center) {
      	for(i = 0 ; i < me->num_holes ; ++i) { 
	   sts= ECdisplayPointSetByBuffer0(&msg_loc, 
		ME.COconst->ActiveDisplay,
		me->surf_info[0].module_info, my_id, 1, 
		(IGRpoint *) me->hole[i].center, GRbe, IGRPS);
	   ERROR(sts, msg_loc, "ret_end.ECdisplayPointSetByBuffer0 error");
	   EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 
		TRUE, 0, &curve);
	   radius = me->hole[0].radius;
           OM_BLOCK_MOVE(me->axis_dir, vector, point_size);
	   OM_BLOCK_MOVE(me->hole[i].center, center, point_size);

       	   BSprepcirc(&msg_loc, center, &radius, vector, curve, normal, 
			&bstype);
	   ele_attr.is_polydis = FALSE;
	   ele_attr.is_curvedis = TRUE;

	   dp$build_dis_buffer(buffer = &circle,
		ele_spec_att = &ele_attr,
		display_att = &ME.COconst->ActiveDisplay, 
		geometry = curve);

	   dp$display(msg = &msg_loc, mode = GRhe, buffer = &circle);

      	}
      	me->show_center = FALSE;
     }

     if(ME.super_cmd->state == 9) {
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

/* Hole action handler used to select between surface & referance plane. Also
used to display the axis of the plane & give the user the flexibility to 
change the axis by changing the cursor position */

IGRlong EFhole_fea_action_handler(hole_locate, new_entry, locate_args, action)
struct	hole_loc_acthndlr_args *hole_locate;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;
{
 	IGRlong sts = OM_S_SUCCESS;

 	sts = om$send(msg = message ECplhole.hole_action_handler(
			hole_locate, new_entry, locate_args, action),
		senderid = NULL_OBJID,
		targetid = hole_locate->my_inst.objid,
		targetos = hole_locate->my_inst.osnum);

	if(!(1 & sts)) 
		goto ret_end;

ret_end:
 	return(sts);
}

method hole_action_handler(struct hole_loc_acthndlr_args *hole_locate;
	struct	GRlc_info *new_entry; struct LC_action_args *locate_args;
	enum	GRlocate_action *action)
{
 IGRboolean	call_action_handler;
 IGRlong msg_loc, sts, loc_msg; 
 struct GRid active_id;
 IGRint point_size;
 extern IGRlong LCptlocact();
 struct	GRid *search_id;
 extern IGRint Hole_EFdyvector();
 IGRlong option;
 IGRboolean aflag = 0;
 aflag = pwIsActivationOn();

/* Initialize */

 call_action_handler = FALSE;
 point_size = sizeof(IGRpoint);
 msg_loc = EMS_S_Success; 
 loc_msg = EMS_S_Success; 
 sts = OM_S_SUCCESS;
 me->end_ref_plane = FALSE;

 option = hole_locate->option;

 if(aflag)
 {
  GRspacenum osn;
  osn = pwGetActiveOs();
  if(new_entry->located_obj.osnum != osn)
    return(sts); 
 }


 if (!aflag)
 {
 if(option == 1) 
 	me->ref_plane = FALSE;
 }

 switch (*action)
  {
   case add_all:
   case add_inside:
   case add_outside:
   case add_overlap:
   case add_nopost:
   {
     IGRlong	i;
     search_id = &new_entry->located_obj;

     me->win_id.objid = locate_args->stack->window.objid;
     me->win_id.osnum = locate_args->stack->window.osnum;
     for (i = 0; i < 1; i++) {
  	search_id = &new_entry->located_obj;

     	if(EFisAncestryValid(&msg_loc, search_id->objid, search_id->osnum,
		OPP_EMSdatpln_class_id, FALSE)) {
 		if(option == 1)
                { 
			me->ref_plane = TRUE;
                }
		else 
			me->end_ref_plane = TRUE;
		call_action_handler = TRUE;
     	}

     	/* Get its active owner solid id */
     	if((!me->ref_plane && option == 1) || 
	    (!me->end_ref_plane)) {
		sts = om$send(msg = message EMSsurface.EMgetactiveid(&loc_msg, 
				&active_id, NULL),
			senderid = NULL_OBJID,
			targetid = search_id->objid,
			targetos = search_id->osnum);

		if(!(1 & sts &loc_msg)) {
			call_action_handler = FALSE;
			sts = OM_S_SUCCESS;
		}
		else {
     		    if(EFisAncestryValid(&msg_loc, active_id.objid, 
			active_id.osnum, OPP_EMSsolid_class_id, FALSE)) { 
			call_action_handler = TRUE;
 			if(option == 1) {
				me->solid_id.objid = active_id.objid;
				me->solid_id.osnum = search_id->osnum;
			}
			else {
				if(!IF_EQ_OBJID(me->solid_id.objid,
					active_id.objid))
					call_action_handler = FALSE;
			}
		    }
		    else 
			call_action_handler = FALSE;
		}
     	}
    }

    if(call_action_handler && hole_locate->next) {
       sts = EFhole_fea_action_handler(hole_locate->next, new_entry,
        	locate_args, action);
       return(sts);
     }
   }
   break;

   default:
      break;
  } /* switch (*action) */

 if(option == 1 && me->ref_plane) 
   	sts = LCptlocact(NULL, new_entry, locate_args, action);

/* Call the action handler */

if(call_action_handler && (option == 0 || !me->ref_plane)) 
   	sts = LCptlocact(NULL, new_entry, locate_args, action);
else
  	sts = OM_S_SUCCESS;

 return(sts);
}


/* This function performs the dynamics for drawing the arrow */

IGRint EFhole_dynamics(grid, event, cmd)
struct GRid *grid;
struct GRevent *event;
struct GRid *cmd;
{
 	IGRlong sts, msg_loc; 
	sts = OM_S_SUCCESS;
 	msg_loc = EMS_S_Success; 

     	if(EFisAncestryValid(&msg_loc, grid->objid, grid->osnum,
	    OPP_EMSdatpln_class_id, FALSE)) {
 		sts = om$send(msg = message ECplhole.hole_dynamics(grid, event,
				cmd),
			senderid = NULL_OBJID,
			targetid = cmd->objid,
			targetos = cmd->osnum);
	    	if(!(1 & sts)) 
			goto ret_end;
	}

ret_end:
 	return(sts);
}

/* This method performs the dynamics for displaying the reference plane 
direction */

method hole_dynamics(struct GRid *grid; struct GRevent *event; 
	struct GRid *cmd)
{
 IGRlong msg_loc, sts;
 struct var_list list_var[2];
 struct GRid win_id;
 IGRdouble vwvolume[6], dia_dist, refpl_pt[3], refpl_nor[3];
 IGRpoint dyn_point, to_pt;
 IGRint ret_stat, point_size;
 GRrange range;
 IGRvector axis_vec;
 struct IGRplane ref_pl;
 extern void EFdraw_vector_on_screen();
 extern IGRlong LCptlocact();
 extern IGRint Hole_EFdyvector();
 extern IGRlong  ECdisplayPointSetByBuffer0();

	/* Initialize */

 	point_size = sizeof(IGRpoint);
	win_id.objid = me->win_id.objid;
	win_id.osnum = me->win_id.osnum;

	ex$message(msgnumb = EMS_P_AccDirSideRej); 

      	list_var[0].var = VW_VOLUME;
      	list_var[0].var_ptr = (char *)vwvolume;
      	list_var[0].num_bytes = sizeof(IGRdouble) * 6;
      	list_var[0].bytes_returned = (IGRlong *)&ret_stat;
      	list_var[1].var = END_PARAM;
      	list_var[1].var_ptr = NULL;
      	list_var[1].num_bytes = 0;
      	list_var[1].bytes_returned = NULL;
	
      	sts = dp$inq_set_gragad(msg = &msg_loc, osnum = win_id.osnum,
		gragad_objid = win_id.objid, which_error = &ret_stat,
		var_list = list_var);

	
      	OM_BLOCK_MOVE(event->located_object[0].proj_pnt, dyn_point, point_size);
      	OM_BLOCK_MOVE(&vwvolume[0], &range[0], point_size);
      	OM_BLOCK_MOVE(&vwvolume[3], &range[3], point_size);

	dia_dist = BSdistptpt(&msg_loc, &range[0], &range[3]);
 	dia_dist /= 10.0;

      	ref_pl.point = refpl_pt;
      	ref_pl.normal = refpl_nor;
      
      	sts = om$send(msg = message GRvg.GRdetplane(&msg_loc, 
			&event->located_object[0].module_info.md_env.matrix_type,
			event->located_object[0].module_info.md_env.matrix,
			&ref_pl),
		senderid = NULL_OBJID,
		targetid = grid->objid,
		targetos = grid->osnum);
		
      	OM_BLOCK_MOVE(refpl_nor, axis_vec, point_size);

	OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

	to_pt[0] = dyn_point[0] + me->axis_dir[0] * dia_dist;
	to_pt[1] = dyn_point[1] + me->axis_dir[1] * dia_dist;
	to_pt[2] = dyn_point[2] + me->axis_dir[2] * dia_dist;

  	sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		event->located_object[0].module_info, cmd->objid, 1, 
      		event->located_object[0].proj_pnt, GRbd, IGRPS);
	ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");

        Hole_EFdyvector(axis_vec, dyn_point, to_pt, &ME.COconst->ActiveDisplay,
			0, NULL);

  	sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		event->located_object[0].module_info, cmd->objid, 1, 
      		event->located_object[0].proj_pnt, GRbe, IGRPS);
	ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");

	OM_BLOCK_MOVE(axis_vec, me->axis_dir, sizeof(IGRvector));

ret_end:
	return(sts);
}

end implementation ECplhole;

