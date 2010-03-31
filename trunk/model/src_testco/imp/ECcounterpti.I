/* ###################   APOGEE COMPILED   ################## */
class implementation ECcounterpt;

/*

ABSTRACT:

This is a high level interface Command Object aimed at speeding up the
placement of counterbores/countersinks on a solid when given the hole diameter, 
counterbore dia, hole depth and counterbore depth; OR given the hole dia, hole 
depth, countersink dia and included angle of the countersink.

HISTORY:

BL  07/28/89	Creation date.
pp  08/23/89    Edited some UI strings.
BL  09/22/89	Modified the command name and enhanced this command to allow 
		the user to place a through hole and select the bottom angle 
		if the hole depth is finite.
BL  11/15/89	Modified the qsize for the enhanced ex$putque and also checked
		for the duplicate centers to prevent mishaps while using the 
		event generator to place a matrix of points etc.
BL  01/25/90	Modified variable value_type from GRIO_SCALAR to GRIO_DISTANCE 
		in co$getevent and also added EFshort_cvtn() to handle when the 
		unit of distance is changed.
BL  06/21/90	Made change to interface such that the multi-c'bore holes can 
		be placed by using event generator. The EMpunch_counterpart
		method is moved to the new class, EMSslboolfea, represented
		the boolean features. Also, the undo stuff will be taken care 
		by the new EMSslboolfea class so I removed some codes that 
		redraw the modified surfaces after undo.
Tapadia 04/10/91 Modified to make c-bore/c-sink associative.
Tapadia 04/18/91 Changed to ems$getevent from co$getevent. The instance data
		 is modified.
scw  08/08/91   Converted to use gr$dpb associative flag
Tapadia 01/13/92 Changed from EFpoint_on_object to GRptproject to compute the
		projected center point.
SM   04/07/92   Moved the function EFget_hole_depth into the new file
                ../funk/EFholedpth.I. Reason - I wanted to compile it in
                debug, was having problems with the compiler core dumping
                when compiling this file and there was not enough time to
                figure out the compiler problem.
SM   05/04/92   Message subsystem compliance.
Sudha 7/05/93   Modified for BSprototypes ansification
scw  08/14/94   clarified sleep method

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
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSaction.h"  /* for EMSaction_handler */
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "EMSsfparms.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasmacros.h" /* for ems$getevent */
#include "bserr.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "EMScmacros.h"
#include "EMSlogic.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "msdef.h"
#include "msmacros.h"
#include "EMSascmacros.h"
#include "bsdistptpt.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# define COUNTERSINK 	0
# define COUNTERBORE	1

# define MAXNUM		10
# define FAIL		0
# define OFF_SURFACE	2

/* for me->const_state use */
# define INIT	0
# define EXEC	1
# define DONE	2
# define UNDO	3
# define DNUD	4 /* don't undo */

#if DEBUG
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn ECcounterpt: %s\n", error_message); \
	sts = EMS_E_Success; \
	goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
	sts = EMS_E_Success; \
	goto ret_end;\
    }\
 }
#endif

extern OMuword OPP_EMScylindr_class_id;

from GRgraphics import  GRdisplay, GRdelete;
from GRvg import  GRgetrang;
from EMSsubbs import  EMgetowner, EMget_unit_norm, GRptproject;
from EMSdpr import  EMundo;
from EMSsolid import  EMcrvsrfint;
from EMSslboolfea import  EMpunch_counterpart;
from EMSsolid import  EMpoint_locate;
from EMSsurface import EMget_params;


method init(int type; char *str_ptr)
{
    IGRlong  sts;

    /* initialize */
    sts = OM_S_SUCCESS;
    me->show_center = FALSE;
    me->const_state = INIT;
    me->num_parts = 0;
		    
    sts = om$send(mode = OM_e_wrt_message,
		msg = message COconst.init(type, str_ptr), targetid = my_id);
    ERROR(sts, 1, "init.init error");

ret_end:
	return(sts);

} /* init */

method wakeup(int pos)
{
    IGRlong  msg, sts;
    IGRint  i; 
    IGRboolean    state;
    enum GRdpmode  DisplayMode;

    gr$get_associative_flag( buffer = &state );
    if(state) {
	me->associative = TRUE;
	GRdisplay_associative_button(TRUE);
    }
    else
	me->associative = FALSE;

    if(ME.super_cmd->mytype == COUNTERSINK)
     ex$message(msgnumb = EM_M_PlaceCntrSinkHole)
    else ex$message(msgnumb = EM_M_PlaceCntrBoreHole)

    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    DisplayMode = GRbd;

    if(me->const_state == DONE || me->const_state == DNUD)
    {
        if(om$is_objid_valid(objid = me->construct_id.objid) == OM_S_SUCCESS)
	{
   	    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->surf_info.module_info.md_env.matrix_type,
                me->surf_info.module_info.md_env.matrix, 
                &DisplayMode, &me->surf_info.module_info.md_id),
                targetid = me->construct_id.objid,
		targetos = me->construct_id.osnum);
   	    ERROR(sts, msg, "wakeup.GRdisplay(1) error");
	} /* if */
	else if(om$is_objid_valid(objid = me->solid_id.objid) == OM_S_SUCCESS)
	{
   	    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->surf_info.module_info.md_env.matrix_type,
                me->surf_info.module_info.md_env.matrix, 
                &DisplayMode, &me->surf_info.module_info.md_id),
                targetid = me->solid_id.objid,
		targetos = me->solid_id.osnum);
   	    ERROR(sts, msg, "wakeup.GRdisplay(2) error");
	} /* else */

    } /* if */
    else if(me->const_state == UNDO || me->const_state == EXEC)
    {
	if(!me->show_center)
	{
    	   extern IGRlong  ECdisplayPointSetByBuffer0();

	   for(i = 0 ; i < me->num_parts ; i++)
	   {
  	    sts= ECdisplayPointSetByBuffer0(&msg, ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[i].center, GRbd, IGRPS);
	    ERROR(sts, msg, "wakeup.ECdisplayPointSetByBuffer0 error");
	   }
	   me->show_center = TRUE;
	}

	if(om$is_objid_valid(objid = me->solid_id.objid) == OM_S_SUCCESS)
	{
	   sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->surf_info.module_info.md_env.matrix_type,
                me->surf_info.module_info.md_env.matrix, 
                &DisplayMode, &me->surf_info.module_info.md_id),
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
    IGRint  i;
    IGRlong  msg_loc, sts;
    enum GRdpmode  DisplayMode;

    ex$message(msgnumb = EMS_P_ClearPromptField)
    ex$message(msgnumb = EMS_I_ClearStatusField)
    ex$message(msgnumb = EM_M_ClearMessageField)

    DisplayMode = GRbdhe;
    msg_loc = EMS_S_Success; 
    sts = OM_S_SUCCESS;

    sts = dp$erase_hilite(msg = &msg_loc);
    ERROR(sts, msg_loc, "sleep.erase_hilite");

    if(me->associative)
	GRdisplay_associative_button(FALSE);

    if(me->show_center)
    {
       extern IGRlong  ECdisplayPointSetByBuffer0();

       for(i = 0 ; i < me->num_parts ; ++i)
       {
  	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "sleep.ECdisplayPointSetByBuffer0 error");
       }
       me->show_center = FALSE;
    }

 ret_end:
    return(sts);

} /* sleep */


method delete(int f_defer_flag)
{
    IGRlong	sts, msg_loc, i;

    sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
                        targetid = my_id);
    ERROR(sts, 1, "delete.me error");

    if(me->show_center)
    {
       extern IGRlong  ECdisplayPointSetByBuffer0();

       for(i = 0 ; i < me->num_parts ; ++i)
       {
  	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "delete.ECdisplayPointSetByBuffer0 error");
       }
    } /* if  */

ret_end:
    return(sts);

} /* delete */


method execute(int *response; char *response_data; int pos)
{
 IGRboolean  stat_func;
 IGRchar  *data_type;
 IGRint  point_size, event_size, qsize, i, n, greve_size;
 IGRlong  event_mask, sts, msg_loc;
 IGRdouble  bas_tol, *center, *axis_dir, temp_rad;
 GRobjid  *display_ids;
 struct GRevent  event, acc_event, loc_event;
 extern IGRlong  ECdisplayPointSetByBuffer0(), EFshort_cvtn();
 extern IGRlong EFpoint_on_object(), EFplace_counterpart();
 IGRlong EFget_the_hole_depth();
 extern IGRboolean EMptsubtype_supported();
 IGRpoint input_pt, surf_pt;
 struct GRparms proj_parms;

 /* initialize */
 sts = OM_S_SUCCESS;
 *response = TERMINATE;
 display_ids = NULL;
 event_size = sizeof(event);
 point_size = sizeof(IGRpoint);
 qsize = event_size - 2 * sizeof(IGRint);
 greve_size = sizeof(struct GRevent);

/* sts = BSEXTRACTPAR(&msg_loc, BSBASISVAL, bas_tol); ### COMMENTED OUT - Ashok */
 sts = BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bas_tol);
 ERROR(sts, 1, "BSEXTRACTPAR error");

 do
 {
  switch(ME.super_cmd->state)
  {
    case 0:
        ex$message(msgnumb = EMS_P_KeyinHoleDia)

	if(me->const_state == DONE)
	 ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo)

	event_mask = GRm_VALUE | GRm_BACK_UP;
  	sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);
	ex$message(msgnumb = EMS_P_ClearPromptField)
	ex$message(msgnumb = EMS_S_ClearStatusField)

	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	   sts = FAIL;
	   goto  ret_end;
	}
        if(msg_loc == GRw_no_value)
	{
	   ex$message(msgnumb = EMS_I_00006) /* No default is supplied */
	   break;
	}

	if(event.response == EX_VALUE)
	{
	   if(event.event.value <= 0)
	   {
	        ex$message(msgnumb = EMS_I_00009) /* Invalid value */
		break;
	   }

/*
      	   strcpy(me->dia_status, "hole diameter = ");
*/
           ex$message(msgnumb = EMS_I_HoleDiameter, buff = me->dia_status)
	   sts = EFshort_cvtn(me->dia_status, event.event.value, 0, 30);

	   OM_BLOCK_MOVE(&event, &me->hole_dia, greve_size);
	   ME.super_cmd->state = 1;

	   /* initialize */
	   me->axis_normal = TRUE;
	   me->const_state = INIT;
	   me->num_parts = 0;
	}
	else if(event.response == EX_BACK_UP)
	{
	  if(me->const_state == DONE) /* for UNDO stuff */ 
	  {
	     IGRint  display_count, involk_count;
 	     IGRushort  option;

	     display_count = involk_count = 0;
	     option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

  	     sts = om$send(msg = message EMSdpr.EMundo(&msg_loc,
			&option, &me->surf_info.module_info,
			NULL, NULL, NULL, &display_ids,
			&display_count, &involk_count), 
			targetid = me->construct_id.objid,
			targetos = me->construct_id.osnum);
  	     ERROR(sts, msg_loc, "execute(0).EMundo error");

	     for(i = 0 ; i < me->num_parts ; ++i)
	     {
  	    	sts= ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info.module_info, my_id, 1, 
			(IGRpoint *) me->part[i].center, GRbd, IGRPS);
	     }
	     me->const_state = UNDO;
	     me->show_center = TRUE;
	     ME.super_cmd->state = 8;

	  } /* if me->const_state == DONE */
	  else  ex$message(msgnumb = EMS_I_00005) /*Input discarded*/

	} /* else if event.response == EX_BACK_UP */
	else
	{
	  /* In order to prevent the model from being unnecessary undo, 
	     I need to check if the pocket(s)/boss(es) already made */
	  if(me->const_state == DONE) me->const_state = DNUD;/* don't undo */
	  goto ret_end;
	}
  	break;

    case 1:
    {
      ex$message(msgnumb = EMS_P_KeyinHoleDepth)

      event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);
	ex$message(msgnumb = EMS_P_ClearPromptField)
	ex$message(msgnumb = EMS_S_ClearStatusField)

      if(!(1 & sts) || msg_loc == MSFAIL)
      {
	  sts = FAIL;
	  goto  ret_end;
      }
      if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

      switch(event.response)
      {
	case EX_RJT_MOVEON:
	    me->go_through = TRUE;
	    me->bottom_angle.event.value = 180.0;
	    ME.super_cmd->state = 3;
	    break;

	case EX_VALUE:
	    if(event.event.value <= 0)  
	    {
	        ex$message(msgnumb = EMS_I_00009) /* Invalid value */
		break;
	    } /* if */

/*
      	    strcpy(me->depth_status, "hole depth = ");
*/
	    ex$message(msgnumb = EMS_I_HoleDepth, buff = me->depth_status)
	    sts = EFshort_cvtn(me->depth_status, event.event.value, 0, 30);

	    OM_BLOCK_MOVE(&event, &me->hole_depth, greve_size);
	    me->go_through = FALSE;
	    ME.super_cmd->state = 2;
	    break;

	case EX_BACK_UP:
	    ME.super_cmd->state = 0;
	    break;

	default:  goto ret_end;

      } /* switch */
      break;

    } /* end of case 1 */
      
    case 2:
      ex$message(msgnumb = EMS_P_KeyinHoleBottomAngle)
      event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_SCALAR, response = (long *)response, 
		response_data = response_data, event = &event);
		
	ex$message(msgnumb = EMS_P_ClearPromptField)
	ex$message(msgnumb = EMS_S_ClearStatusField)

      if(!(1 & sts) || msg_loc == MSFAIL)
      {
	 sts = FAIL;
	 goto  ret_end;
      }
      if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

      switch(event.response)
      {
	case EX_RJT_MOVEON:
	    OM_BLOCK_MOVE(&event, &me->bottom_angle, greve_size);
	    me->bottom_angle.event.value = 180.0;
	    ME.super_cmd->state = 3;
	    break;

	case EX_VALUE:
	    if(event.event.value <= 0 || event.event.value > 180)
	    {
	        ex$message(msgnumb = EMS_I_00009) /* Invalid value */
		break;
	    }
	    OM_BLOCK_MOVE(&event, &me->bottom_angle, greve_size);
	    ME.super_cmd->state = 3;
	    break;

	case EX_BACK_UP:
	    ME.super_cmd->state = 1;
	    break;

	default: goto ret_end;
      }
      break;

    case 3:
	if(ME.super_cmd->mytype == COUNTERSINK) 
	 ex$message(msgnumb = EMS_P_KeyinCntrSinkDia)
      	else  ex$message(msgnumb = EMS_P_KeyinCntrBoreDia)

        ex$message(msgnumb = EMS_I_HoleDiameter, buff = me->dia_status)
	sts = EFshort_cvtn(me->dia_status, me->hole_dia.event.value, 0, 30);
	ex$message(field = KEYIN_FIELD, in_buff = me->dia_status, 
	           justification = LEFT_JUS)
	
      	event_mask = GRm_VALUE | GRm_BACK_UP;
      	sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField)
        ex$message(msgnumb = EMS_I_ClearStatusField)
        ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField, 
                   justification = LEFT_JUS)

      	if(!(1 & sts) || msg_loc == MSFAIL)
      	{
	   sts = FAIL;
	   goto  ret_end;
      	}
      	if(msg_loc == GRw_no_value)
      	{
	   ex$message(msgnumb = EMS_I_00006) /* No default is supplied */
	   break;
      	} /* if */
      
      	switch(event.response)
      	{
	  case EX_VALUE:
	      OM_BLOCK_MOVE(&event, &me->drill_dia, greve_size);

	      if(me->drill_dia.event.value <= me->hole_dia.event.value)  
	      {
		   ex$message(msgnumb = EMS_I_DataMustMoreThanHoleDia)
		   break;
	      } /* if */

	      ME.super_cmd->state = 4;
	      break;

	  case EX_BACK_UP:
	      if(me->go_through)  ME.super_cmd->state = 1;
	      else  ME.super_cmd->state = 2;
	      break;

	  default:  goto ret_end;

      	} /* switch */
      	break;
      
    case 4:
      	if(ME.super_cmd->mytype == COUNTERSINK)
	{
	   data_type = GRIO_SCALAR;
	   ex$message(msgnumb = EMS_P_KeyinCntrSinkAng)
	}
      	else	/* COUNTERBORE */
	{
	   data_type = GRIO_DISTANCE;
	   ex$message(msgnumb = EMS_P_KeyinCntrBoreDepth)
	   if(!me->go_through)
	   {
		ex$message(msgnumb = EMS_I_HoleDepth, buff = me->depth_status)
	    	sts = EFshort_cvtn(me->depth_status,me->hole_depth.event.value,
			 0, 30);
		ex$message(field = KEYIN_FIELD, in_buff = me->depth_status, 
		           justification = LEFT_JUS)
	   }
	}

      	event_mask = GRm_VALUE | GRm_BACK_UP;
      	sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = data_type, response = (long *)response, 
		response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField)
        ex$message(msgnumb = EMS_I_ClearStatusField)
        ex$message(field = KEYIN_FIELD, msgnumb = EMS_I_ClearStatusField, 
                   justification = LEFT_JUS)

      	if(!(1 & sts) || msg_loc == MSFAIL)
      	{
	    sts = FAIL;
	    goto  ret_end;
      	}
      	if(msg_loc == GRw_no_value)
      	{
	   ex$message(msgnumb = EMS_I_00006) /* No default is supplied */
	    break;
      	} /* if */
      
      	switch(event.response)
      	{
	  case EX_VALUE:
	    OM_BLOCK_MOVE(&event, &me->angle_or_depth, greve_size);

	    if(ME.super_cmd->mytype == COUNTERSINK)
	    {
	      if(me->angle_or_depth.event.value > 0 && 
			me->angle_or_depth.event.value< 180)
	      {
	      	IGRdouble  radius, angle, tanv;
	      	extern IGRdouble  tan(), atan();

#define HALF_RADIAN	0.0087266462599716483
#define DEGREE_X_2	114.591559026164644

		radius = (me->drill_dia.event.value-me->hole_dia.event.value)/2;
		tanv = tan(me->angle_or_depth.event.value * HALF_RADIAN);
	    	/* me->drill_depth will be used to check the hole depth */
		me->drill_depth = radius / tanv;

		if(!me->go_through && me->drill_depth >= 
			me->hole_depth.event.value)
	      	{
		   angle = DEGREE_X_2 * atan(radius/me->hole_depth.event.value);
		   ex$message(msgnumb = EMS_I_RecommendedAngMore, 
		              var = angle, type = "%6.1f")
		   break;
	      	}
	      } /* if valid angle */
	      else
	      {
	        ex$message(msgnumb = EMS_I_00009) /* Invalid value */
		 break;
	      }

	    } /* if COUNTERSINK */
	    else
	    {
	      if(me->angle_or_depth.event.value<= 0)  
	      {
	        ex$message(msgnumb = EMS_I_00009) /* Invalid value */
		 break;
	      }
	      else if(!me->go_through && me->angle_or_depth.event.value >= 
			me->hole_depth.event.value)
	      {
		 ex$message(msgnumb = EMS_I_CntrBoreDeepHole)
		 break;
	      }
	      else  me->drill_depth = me->angle_or_depth.event.value;

	    } /* else COUNTERBORE */
	    ME.super_cmd->state = 5;
	    break;

	  case EX_BACK_UP:
	    ME.super_cmd->state = 3;
	    break;

	  default:  goto ret_end;

      	} /* switch */
      	break;

    /*
     * Get the surface info and its owner solid objid
     */

    case 5:
    {
      IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
      IGRlong  locate_mask, accept_mask;
      IGRlong  object_was_located, display_flag;
      struct GRlc_locate  attributes;
      struct EMSaction_handler  locate;
      OM_S_CLASSLIST  rtree_classes, elig_classes;
      OMuword  rclass, eliclass, accept_classid;
      extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
      extern IGRlong  EFlocate_action_handler();

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_BACK_UP;

      ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);  
      ex$message(msgnumb = EMS_P_AcceptWitBaCen, buff = accept_prompt);
      ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
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
                display_flag = display_flag, response = (long *)response, 
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
         if(me->locate_event.response == EX_BACK_UP)  ME.super_cmd->state = 4;
         else  return(OM_S_SUCCESS);
      }
      else
      {
	sts = dp$erase_hilite(msg = &msg_loc);
	ERROR(sts, msg_loc, "execute(5).erase_hilite error");

	switch(acc_event.response)
	{
	  case EX_DATA:
	      me->surf_info = loc_event.located_object[0];

	      /* Get the active owner solid id */

              sts = om$send(msg = message EMSsubbs.EMgetowner(&msg_loc,
			&me->solid_id.objid, FALSE),
			targetid = me->surf_info.located_obj.objid,
			targetos = me->surf_info.located_obj.osnum);
	      ERROR(sts, msg_loc, "execute(5).EMgetowner error");
       
	      me->solid_id.osnum = me->surf_info.located_obj.osnum;
	      sts = ex$putque(msg = &msg_loc, response = response,
			byte = (IGRlong *)&qsize, 
			buffer = (IGRchar *)&acc_event.event);
	      ERROR(sts, msg_loc, "execute(5).putque error");

	      me->pick_center = TRUE;
	      ME.super_cmd->state = 6;
	      break;
	  case EX_BACK_UP:
	      ME.super_cmd->state = 4;
	      break;
	  default:  goto ret_end;

	} /* switch */
      } /* else object_was_not_located */
      break;

    } /* end of case 5 */

    case 6:
      if(!me->pick_center)  ex$message(msgnumb = EMS_P_PlaceBaseCntr)
      else  me->pick_center = FALSE;

      event_mask = GRm_DATA | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)

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

      switch(event.response)
      {
	case EX_DATA:

	  /* If a constrainted object is to be created */
	  if(EMptsubtype_supported(&event)) {
	    OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
	    sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info.module_info.md_env.matrix_type,
			me->surf_info.module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		targetid = me->surf_info.located_obj.objid,
		targetos = me->surf_info.located_obj.osnum);

	    OM_BLOCK_MOVE(surf_pt, me->part[0].center, point_size);
	  }
	  else {
	    sts = EFpoint_on_object(&me->surf_info, &event, my_id, &msg_loc);
	    OM_BLOCK_MOVE(&event.event.button.x, me->part[0].center,point_size);
	  }
	  OM_BLOCK_MOVE(&event, &me->cen_pt_eve[0], greve_size);

	  if(!(1 & sts & msg_loc))
	  {
	     ex$message(msgnumb = EMS_I_InvalidBaseCenter)
	     if(!sts)  sts = OM_S_SUCCESS; 
	     goto ret_end;
	  }

	  sts = om$send(msg = message EMSsubbs.EMget_unit_norm(&msg_loc, 
		FALSE, /* outside solid? */ NULL,
		&me->surf_info.module_info.md_env,
		me->part[0].center, me->part[0].axis_dir), 
		targetid = me->surf_info.located_obj.objid,
		targetos = me->surf_info.located_obj.osnum);
	  /* prevent center is not being projected to the located surface */
	  if(sts == OFF_SURFACE)
	  {
             ex$message(msgnumb = EMS_S_InvInp)
	     event.num_id = 0; /* clear the event generator, if any */
	     sts = OM_S_SUCCESS;
	     goto ret_end;
	  }
 	  ERROR(sts, msg_loc, "execute(6).EMget_unit_norm error");

      	  /* 
	   * Get the FIRST hole depth, by default, the axis is NORMAL
	   */

      	  if(me->go_through)
      	  {
	     temp_rad = me->hole_dia.event.value * 0.5;
	     sts = EFget_the_hole_depth(&me->surf_info.module_info,
			me->axis_normal, &temp_rad, &me->part[0], 
			&me->solid_id, my_id);
	     ERROR(sts, 1, "execute(6).EFget_hole_depth error");

	     me->hole_depth.event.value = me->part[0].hole_depth;

	     if((me->hole_depth.event.value - me->drill_depth) <= bas_tol)
	     {
	    	if(ME.super_cmd->mytype == COUNTERSINK)
	          ex$message(msgnumb = EMS_I_CntrSinkDeepHole)
	        else ex$message(msgnumb = EMS_I_CntrBoreDeepHole)

  	    	sts = ECdisplayPointSetByBuffer0(&msg_loc, 
		 	ME.COconst->ActiveDisplay,
			me->surf_info.module_info, my_id, 1, 
			(IGRpoint *) me->part[0].center, GRbe, IGRPS);

	    	me->num_parts = 0;
	    	ME.super_cmd->state = 4;
	    	break;
	     }
      	  } /* if hole is go_through */
      	  else  
      	  {
	     center = me->part[0].center;
	     axis_dir = me->part[0].axis_dir;
	     me->part[0].hole_depth = me->hole_depth.event.value;
	     me->part[0].depth_pt[0] = center[0] + me->hole_depth.event.value *
			axis_dir[0];
	     me->part[0].depth_pt[1] = center[1] + me->hole_depth.event.value *
			axis_dir[1];
	     me->part[0].depth_pt[2] = center[2] + me->hole_depth.event.value *
			axis_dir[2];
      	  }
	  ME.super_cmd->state = 8;

  	  sts= ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay, 
			me->surf_info.module_info, my_id, 1, 
			(IGRpoint *) me->part[0].center, GRbd, IGRPS);
	  ERROR(sts,msg_loc,"execute(6).ECdisplayPointSetByBuffer0 error");

	  me->show_center = TRUE;
	  me->num_parts = 1;
	  me->const_state = EXEC;
	  break;
	case EX_BACK_UP:
	  ME.super_cmd->state = 5;
	  break;
	default:  goto ret_end;
  
      } /* switch */
      break;

    /*
     * Only for the COUNTERBORE hole use 
     */

    case 7:
      ex$message(msgnumb = EMS_P_InputPtForAxisDir)
      sts = EFrblineseg(me->part[0].center, &ME.COconst->ActiveDisplay);

      event_mask = GRm_VALUE | GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &event);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)

      if(!(1 & sts) || msg_loc == MSFAIL)
      {
	 sts = FAIL;
	 goto  ret_end;
      }
      if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

      if(event.response == EX_DATA)
      {
	 IGRdouble  vec[3], axis[3], len;
	 extern IGRdouble  sqrt();

	 OM_BLOCK_MOVE(&event.event.button.x, axis, point_size);
	 center = me->part[0].center;
	 vec[0] = axis[0] - center[0];
	 vec[1] = axis[1] - center[1];
	 vec[2] = axis[2] - center[2];

	 /* check if the axis direction is appropriate */
	 axis_dir = me->part[0].axis_dir;
	 len = vec[0]*axis_dir[0] + vec[1]*axis_dir[1] + vec[2]*axis_dir[2];

	 if(len < -bas_tol)
	 {
	    vec[0] = -vec[0];
	    vec[1] = -vec[1];
	    vec[2] = -vec[2];
	 } 
	 else if((len >= -bas_tol) && (len <= bas_tol))
	 {
	    ex$message(msgnumb = EMS_I_InvalidAxisDir)
	    goto ret_end;
	 }

	 len = sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
	 me->part[0].axis_dir[0] = vec[0] / len;
	 me->part[0].axis_dir[1] = vec[1] / len;
	 me->part[0].axis_dir[2] = vec[2] / len;
	 me->axis_normal = FALSE;

      } /* if EX_DATA */
      else if(event.response == EX_RJT_MOVEON)
      {
	 sts = om$send(msg = message EMSsubbs.EMget_unit_norm(&msg_loc, 
		FALSE, /* outside solid? */ NULL,
		&me->surf_info.module_info.md_env,
		me->part[0].center, me->part[0].axis_dir), 
		targetid = me->surf_info.located_obj.objid,
		targetos = me->surf_info.located_obj.osnum);
 	 ERROR(sts, msg_loc, "execute(7).EMget_unit_norm error");

	 me->axis_normal = TRUE;

      } /* if EX_RJT_MOVEON */
      else if(event.response == EX_BACK_UP)
      {
  	 sts = ECdisplayPointSetByBuffer0(&msg_loc, 
		ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[0].center, GRbe, IGRPS);
	 ERROR(sts,msg_loc,"execute(7‚).ECdisplayPointSetByBufer0 error");

	 me->num_parts = 0;
	 ME.super_cmd->state = 6;
	 break;

      } /* if EX_BACK_UP */
      else  goto ret_end;

      /* Get the FIRST hole depth */

      if(me->go_through)
      {
	 temp_rad = me->hole_dia.event.value * 0.5;
	 sts = EFget_the_hole_depth(&me->surf_info.module_info,
		me->axis_normal, &temp_rad, &me->part[0], 
		&me->solid_id, my_id);
	 ERROR(sts, 1, "execute(7).EFget_hole_depth error");

	 me->hole_depth.event.value = me->part[0].hole_depth;

	 if((me->hole_depth.event.value - me->drill_depth) <= bas_tol)
	 {
	    ex$message(msgnumb = EMS_I_CntrBoreDeepHole)

  	    sts = ECdisplayPointSetByBuffer0(&msg_loc, 
		 	ME.COconst->ActiveDisplay,
			me->surf_info.module_info, my_id, 1, 
			(IGRpoint *) me->part[0].center, GRbe, IGRPS);

	    me->num_parts = 0;
	    ME.super_cmd->state = 4;
	    break;
	 }
      } /* if hole is go_through */
      else  
      {
	 center = me->part[0].center;
	 axis_dir = me->part[0].axis_dir;
	 me->part[0].hole_depth = me->hole_depth.event.value;
	 me->part[0].depth_pt[0] = center[0] + me->hole_depth.event.value * 
			axis_dir[0];
	 me->part[0].depth_pt[1] = center[1] + me->hole_depth.event.value * 
			axis_dir[1];
	 me->part[0].depth_pt[2] = center[2] + me->hole_depth.event.value * 
			axis_dir[2];
      }
      ME.super_cmd->state = 8;
      break;

    case 8:
      ex$message(msgnumb = EMS_P_MoreBaseCntrMvOn)

      n = me->num_parts;

      if(n == 1)
       ex$message(msgnumb = EMS_I_BackupToAlterAxisDir)

      event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
		response = (long *)response, response_data = response_data, 
		event = &event);
      if(event.response != EX_DATA)  
       ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_I_ClearStatusField)

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

      switch(event.response)
      {
	case EX_DATA:
	{

	  /* If a constrainted object is to be created */
	  if(EMptsubtype_supported(&event)) {
	    OM_BLOCK_MOVE(&event.event.button.x, input_pt, point_size);
	    sts = om$send(msg = message EMSsubbs.GRptproject(&msg_loc,
			&me->surf_info.module_info.md_env.matrix_type,
			me->surf_info.module_info.md_env.matrix,
			input_pt, surf_pt, &proj_parms),
		targetid = me->surf_info.located_obj.objid,
		targetos = me->surf_info.located_obj.osnum);

	    ERROR(sts, msg_loc, "execute(8).GRptproject error");
	  }
	  else { 
	    sts = EFpoint_on_object(&me->surf_info, &event, my_id, &msg_loc);
	    ERROR(sts, msg_loc, "execute(8).EFpoint_on_object error");
	  }

	  if(om$dimension_of(varray = me->part) <= n) {
	     sts = om$vla_set_dimension(varray=me->part,size=n+4);
	     ERROR(sts, msg_loc, "execute(8).vla_set_dimension");
	  }
	  if(om$dimension_of(varray = me->cen_pt_eve) <= n) {
	     sts = om$vla_set_dimension(varray=me->cen_pt_eve,size=n+4);
	     ERROR(sts, msg_loc, "execute(8).vla_set_dimension");
	  }

	  /* Check if there are duplicate centers */
	  if(BSdistptpt(&msg_loc, &event.event.button.x, me->part[n-1].center)
		< bas_tol)  break;
	  else  {
              OM_BLOCK_MOVE(&event, &me->cen_pt_eve[n], greve_size);
	      if(EMptsubtype_supported(&event)) 
		OM_BLOCK_MOVE(surf_pt, me->part[n].center, point_size);
	      else 
		OM_BLOCK_MOVE(&event.event.button.x, me->part[n].center, 
			point_size);
	  }

	  if(me->axis_normal)
 	  {
 	    sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
		&msg_loc, FALSE, NULL,
		&me->surf_info.module_info.md_env,
		me->part[n].center, me->part[n].axis_dir),
		targetid = me->surf_info.located_obj.objid,
		targetos = me->surf_info.located_obj.osnum);
	    /* prevent center is not being projected to the located surface */
	    if(sts == OFF_SURFACE)
	    {
                ex$message(msgnumb = EMS_S_InvInp)
		event.num_id = 0; /* clear the event generator, if any */
	    	sts = OM_S_SUCCESS;
	    	goto ret_end;
	    }
 	    ERROR(sts, msg_loc, "execute(8).EMget_unit_norm error");

	  } /* if axis is normal */
	  else  OM_BLOCK_MOVE(me->part[n-1].axis_dir,
			me->part[n].axis_dir, point_size);

	  if(me->go_through)
	  {
	     temp_rad = me->hole_dia.event.value * 0.5;
	     sts = EFget_the_hole_depth(&me->surf_info.module_info,
			me->axis_normal, &temp_rad, &me->part[n],
			&me->solid_id, my_id);
	     ERROR(sts, 1, "execute(8).EFget_hole_depth error");

	     /* check if the hole depth is sufficient */

	     if((me->part[n].hole_depth-me->drill_depth) <= bas_tol)
	     {
	    	if(ME.super_cmd->mytype == COUNTERSINK)
	          ex$message(msgnumb = EMS_I_CntrSinkDeepHole)	
	    	else ex$message(msgnumb = EMS_I_CntrBoreDeepHole)	
		break;
	     }
	  } /* if through hole */
	  else
	  {
	     center = me->part[n].center;
	     axis_dir = me->part[n].axis_dir;
	     me->part[n].hole_depth = me->hole_depth.event.value;
	     me->part[n].depth_pt[0] = center[0] + me->hole_depth.event.value *
			axis_dir[0];
	     me->part[n].depth_pt[1] = center[1] + me->hole_depth.event.value *
			axis_dir[1];
	     me->part[n].depth_pt[2] = center[2] + me->hole_depth.event.value *
			axis_dir[2];

	  } /* if it is blind hole */

  	  sts= ECdisplayPointSetByBuffer0(&msg_loc, 
		ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[n].center, GRbd, IGRPS);
	  ERROR(sts,msg_loc,"execute(8).ECdisplayPointSetByBuffer0 error");

	  me->num_parts++;
	  me->const_state = EXEC;
	  break;
	} /* case EX_DATA */

	case EX_RJT_MOVEON:
	  ME.super_cmd->state = 9;
	  break;

	case EX_BACK_UP:
	  if(n > 1) 
	  {
	     n = --me->num_parts;

  	     sts = ECdisplayPointSetByBuffer0(&msg_loc, 
			ME.COconst->ActiveDisplay,
			me->surf_info.module_info, my_id, 1, 
			(IGRpoint *) me->part[n].center, 
			GRbe, IGRPS);
	     ERROR(sts,msg_loc,"execute(8).ECdisplayPointSetByBuffer0 error");
/*
	     if(me->num_parts < 1)
	     {
	    	me->show_center = FALSE;
	    	ME.super_cmd->state = 6;
	     }
*/
	  }
	  else if(n == 1)  ME.super_cmd->state = 7;

	  me->const_state = EXEC;
	  break;

	default:  goto ret_end;

      } /* switch */
      break;

    case 9:
    {
      struct GRvg_construct construct_list;
      extern OMuword  OPP_EMSslboolfea_class_id;

      ex$message(msgnumb = EMS_I_Processing)
      sts = dp$erase_hilite(msg = &msg_loc);

      /* erase the center(s) of counterpart(s) */
      for(i = 0 ; i < me->num_parts ; ++i)
      { 
	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "execute(9).ECdisplayPointSetByBuffer0 error");
      }
      me->show_center = FALSE;

      construct_list.msg = &msg_loc;
      construct_list.env_info = &me->surf_info.module_info;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.level = ME.COconst->ActiveLevel;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &ME.COconst->ActiveDisplay;
      construct_list.name = NULL;

      me->construct_id.osnum = me->surf_info.located_obj.osnum;

/*
      sts = om$construct(classid = OPP_EMSslboolfea_class_id,
      		p_objid = &me->construct_id.objid,
      		osnum = me->construct_id.osnum);
      ERROR(sts, 1, "construct error");
*/
/****************************************************************************
        sts = EFplace_counterpart(&msg_loc, NULL, &construct_list, 
		ME.super_cmd->mytype, me->axis_normal, me->go_through, 
		me->cen_pt_eve, &me->bottom_angle, &me->surf_info, 
		me->num_parts, me->part, &me->angle_or_depth,
		&me->drill_dia, &me->hole_dia, &me->hole_depth, 
		&me->construct_id, me->associative ? NULL:
		EMSasconst_notassociative); 
****************************************************************************/
        sts = ems$place_counterpart(msg = &msg_loc,
                                    construction_list = &construct_list,
                                type = ME.super_cmd->mytype,
                                axis_normal = me->axis_normal,
                                thru_hole = me->go_through,
                                center_pt_event = me->cen_pt_eve,
                                bottom_angle_event = &me->bottom_angle,
                                surface = &me->surf_info,
                                num_parts = me->num_parts,
                                part_info = me->part,
                                counter_depth_event = &me->angle_or_depth,
                                counter_dia_event = &me->drill_dia,
                                hole_dia_event = &me->hole_dia,
                                hole_depth_event = &me->hole_depth,
                                resultant_id = &me->construct_id,
                gen_opts = me->associative ? NULL:EMSasconst_notassociative);
/*
      sts = om$send(msg = message EMSslboolfea.EMpunch_counterpart(&msg_loc, 
		&construct_list, ME.super_cmd->mytype, 
		me->axis_normal, me->go_through, &me->bottom_angle, 
		&me->surf_info, me->num_parts, 
		me->part, &me->angle_or_depth, &me->drill_radius,
		&me->hole_radius, &me->solid_id), 
		targetid = me->construct_id.objid,
		targetos = me->construct_id.osnum);
*/

      if( !(1 & sts & msg_loc) || (msg_loc == EMS_I_NoIntersection))
      {
	ex$message(msgnumb = EMS_I_ErrorInConstruction)
	 sts = FAIL; goto ret_end;
      }
      else
      {
      	 me->const_state = DONE;
	 ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo)         
      	 ME.super_cmd->state = 0;
	 break;
      } /* punch_counterpart success */
	  
    } /* end of case 9 */
      
    default:	
	goto ret_end;

  } /* switch ME.super_cmd->state */
 } while( TRUE );

ret_end:
 if(!(1 & sts))
 {
    if(me->show_center)
    {
       for(i = 0 ; i < me->num_parts ; ++i)
       { 
	  sts= ECdisplayPointSetByBuffer0(&msg_loc, ME.COconst->ActiveDisplay,
		me->surf_info.module_info, my_id, 1, 
		(IGRpoint *) me->part[i].center, GRbe, IGRPS);
	  ERROR(sts, msg_loc, "ret_end.ECdisplayPointSetByBuffer0 error");
       }
       me->show_center = FALSE;
    }

    me->num_parts = 0;
    me->const_state = INIT;
    ME.super_cmd->state = 0;
    sts = OM_S_SUCCESS; /* reset to return case 0 */
 } /* if */

 return(sts);

} /* execute */



end implementation ECcounterpt;


