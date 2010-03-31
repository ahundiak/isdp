/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the next event processing, verify event,
 perform construction, perform dynamics, and display construction
 methods for the ruled surface command.

 History

 02/16/88 : rlw : The beginning
 05/05/89 : rlw : Modified to support status display form which allows the
                  user to pick the manner in which the ruled surface is
                  created.
 09/15/89 : pp  : Outputting a message into the prompt area to indicate
                  the presence of status display form.
 03/25/91 : mm  : Changed to c_based form.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 01/24/93 : Kumar N : Port to NT
 12-Feb-93 : Jack : Removed unused import of EMSgenbs.EMruled_surface.
 06/14/93 : scw : Removed references to the X11 directory for include files.
 09/14/93 : WBC : Changed the #define names and values for the status display
                  form's buttons to reflect the new button names and gadget
                  numbers.
 08/13/94 : scw : Added X11 for Intel Solaris port

 */

class implementation ECruledsur;

%safe
#include <math.h>
%endsafe

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif
#include "EMSdpb.h" /* For EMSDPB_ASSOC_PLACEMENT */
#include "EMSasopts.h" /*For EMSasconst_not..*/
#include "EMSifmacros.h"
#include "EMSascmacros.h"

#define FORM1 1


extern OMuword OPP_EMSgenbs_class_id;

#define BIG_CURVE           0
#define ACCEPT_BUTTON       1
#define SMOOTH_BUTTON      15
#define NATURAL_BUTTON     16
#define DEVELOPABLE_BUTTON 13

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)
{
 void		EFget_locate_information();
 IGRlong	key, *my_msg, integer_to_encode;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 integer_to_encode = 0;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 prompt
 */
   case 0:
   case 3:
    *locate_desired = TRUE;
    EFget_locate_information(BIG_CURVE, loc_info);
    key = EMS_P_00035;
    integer_to_encode = (me->number_of_events_input ? 2 : 1);
    loc_info->acc_key = EMS_P_00107;
    break;
/*
 * Event 2 prompt
 */
   case 1:
   case 4:
    key = EMS_P_00077;
    break;
/*
 * Event 3 prompt
 */
   case 2:
   case 5:
    key = EMS_P_00061;
    *event_mask |= GRm_RJT_MOVEON;
    break;
/*
 * Control point logic
 */
   default:
    {
     IGRlong	index;

     index = me->number_of_events_input - 4;
     integer_to_encode = index / 2;     
     if (index % 2)				/* Is odd? */
      key = EMS_P_00109;
     else
      {
       key = EMS_P_00108;
       *event_mask |= GRm_RJT_MOVEON;
      }
    }
    break;
  } /* switch (me->number_of_events_input) */
/*
 * Get the prompt string
 */
 if (integer_to_encode)
  {
   ex$message(
    msgnumb = key,
    type = "%d",
    var = `integer_to_encode`,
    buff = prompt_string);
  }
 else
  {
   ex$message(
    msgnumb = key,
    buff = prompt_string);
  }
/*
 * eof
 */

 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method verify_event(
 IGRboolean	use_default;
 IGRboolean	*was_valid_event;
 IGRboolean	*done)
{
 IGRlong	key, sts, *my_msg, my_type;
 struct		GRevent *event;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *done = FALSE;
 key = EMS_I_00022;
 *was_valid_event = TRUE;
 event = &me->events[me->number_of_events_input - 1];
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 verification
 */
   case 1:
   case 4:
    event->located_object[0].geom_parms.polygon_inx = FALSE;
    break;
/*
 * Event 2 verification
 */
   case 2:
   case 5:
    {
     IGRlong		index;
     struct		GRprops properties;

     index = me->number_of_events_input - 2;
     sts = EFgetprops(
       &me->events[index],
       my_id,
       &properties,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     if (properties.phy_closed)
      {
       sts = EFpoint_on_object(
         &me->events[index].located_object[0],
         event,
         my_id,
         my_msg);
      }
     else
      {
       event->located_object[0] = me->events[index].located_object[0];
       sts = EFdetermine_direction(
         event,
         my_id,
         my_msg);
        if (! (1 & sts)) goto wrapup;
       me->events[index].located_object[0] = event->located_object[0];
       sts = om$send(
         msg = message ECconstruct.display_constructions(
          TRUE,		/* Draw in background */
          TRUE),	/* Display one state */
         targetid = my_id);
        if (! (1 & sts)) goto wrapup;
       me->event.subtype = GRst_DEFAULT;
       me->event.response = EX_MAX_RESPONSE;
       sts = om$send(
         msg = message ECconstruct.add_event(FALSE),
         targetid = my_id);
        if (! (1 & sts)) goto wrapup;
      }
    }
    break;
/*
 * Event 3 verification
 */
   case 3:
   case 6:
    if (event->response != EX_DATA)		/* Toggle direction? */
     {
      IGRlong	index;

      index = me->number_of_events_input - 3;
      me->number_of_events_input--;
      sts = EFpatch_the_display_for_normals(
        &me->events[index],
        my_id);
       if (! (1 & sts)) goto wrapup;
      me->number_of_events_input++;
     }
    break;
/*
 * Default:
 */
   default:
    if (event->response == EX_RJT_MOVEON) 
     *done = TRUE;
    else
     {
      IGRlong	index;

      if (me->number_of_events_input % 2)
       index = 0;
      else
       index = 3;
      sts = EFpoint_on_object(
        &me->events[index].located_object[0],
        event,
        my_id,
        my_msg);
     }
    break;
  } /* switch (me->number_of_events_input) */
/*
 * Output the error message, if any
 */
 if (! *was_valid_event)
  ex$message(msgnumb = key)
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method perform_dynamics()
{
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 dynamics
 */
   case 1:		/* Have curve 1 */
   case 2:		/* Have starting point on curve 1 */
   case 3:		/* Have direction for curve 1 */
   case 5:		/* Have starting point on curve 2 */
   case 6:		/* Have direction for curve 2 */
/*  noop; */
    break;
/*
 * Event 4 dynamics
 */
   case 4:		/* Have curve 2 */
    EFrblineseg(
     &me->events[1].event.button.x,
     &me->display);
    break;
/*
 * Default
 */
   default:
    if (me->number_of_events_input % 2)		/* Odd? */
     EFrblineseg(
      &me->events[me->number_of_events_input - 1].event.button.x,
      &me->display);
    break;
  } /* switch (me->number_of_events_input) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)
{
 IGRlong	number_of_points, i, alpha, omega, *my_msg;
 IGRpoint	points[2];
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
/*
 * Compiler optimizations
 */
 my_display = &me->display;
 my_display_env = &me->display_env;
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * Set up the loop indices
 */
 omega = me->number_of_events_input;
 if (!omega) goto wrapup;		/* Degenerate case */
 if (draw_single)
  alpha = omega;
 else
  alpha = 1;
/*
 * Enter the loop
 */
 for (i = alpha; i <= omega; i++)
  {
   number_of_points = 0;
/*
 * Branch based on the command state
 */
   switch (i)
    {
/*
 * Event 1 construction lines
 */
     case 1:
     case 4:
/*    noop; */
      break;
/*
 * Event 2 construction lines
 */
     case 2:
     case 5:
      {
       IGRboolean	reverse_vector;
       IGRlong		sts;
       struct		GRlc_info *loc_info;

       loc_info = &me->events[i - 2].located_object[0];
       reverse_vector = loc_info->geom_parms.polygon_inx;
       sts = EFdisplay_curve_normal_or_tangent(
         loc_info,
         NULL,			/* Only used for normal vectors */
         FALSE,			/* Display the tangent vector? */
         reverse_vector,	/* Is the curve flowing the correct way? */
         my_id,
         draw_background ? GRbd : GRbe,
         my_display_env,
         my_display,
         my_msg);
        if (! (1 & sts)) goto wrapup;
       number_of_points = 1;
       OM_BLOCK_MOVE(
        &me->events[i - 1].event.button.x,
        points[0],
        sizeof(IGRpoint));
       if (i == 5)	/* Also draw the line connecting the starting points */
        {
         number_of_points = 2;
         OM_BLOCK_MOVE(
          &me->events[1].event.button.x,
          points[1],
          sizeof(IGRpoint));
        }
       }
      break;
/*
 * Event 3 construction lines
 */
     case 3:
     case 6:
/*    noop; */
      break;
/*
 * Event 7+ construction lines
 */
     default:
      {
       IGRlong	index;

       index = (i - 1) % 2;
       number_of_points = 1 + index;
       OM_BLOCK_MOVE(
        &me->events[i - 1].event.button.x,
        points[0],
        sizeof(IGRpoint));
       if (index)
        OM_BLOCK_MOVE(
         &me->events[i - 2].event.button.x,
         points[1],
         sizeof(IGRpoint));
       }
      break;
    } /* switch (i) */
/*
 * Draw it
 */
   if (number_of_points)
    {
     IGRlong	sts;
/*     IGRlong ECdisplayPointSetByBuffer();*/
/****************************************************************
     sts = ECdisplayPointSetByBuffer(
       my_msg,
       *my_display,
       *my_display_env,
       my_id,
       number_of_points,
       points,
       draw_background);
****************************************************************/
     sts = ems$displayPointSetByBuffer(
                      msg = my_msg,
                      num_points = number_of_points,
                      points = points,
                      senderid = my_id,
                      display_attr = *my_display,
                      mdenv = *my_display_env,
                      draw_background = draw_background);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
    } /* if (number_of_points) */
  } /* for (i = start; i <= end; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method perform_construction()
{
 OMuword	space_number;
 IGRboolean	curve_1_reversed, curve_2_reversed;
 IGRlong	i, j, *my_msg, sts;
 IGRlong	number_of_control_points;
 GRobjid	*my_constructed_object;
 IGRpoint	*c1_control_points, *c2_control_points;
 struct		GRvg_construct *my_construct_list;
 struct		GRlc_info *curve_1, *curve_2;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 space_number = me->construct_env.md_id.osnum;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 c1_control_points = NULL;
 c2_control_points = NULL;
/*
 * Unpack the required data
 */
 curve_1 = &me->events[0].located_object[0];
 curve_1_reversed = curve_1->geom_parms.polygon_inx;
 curve_2 = &me->events[3].located_object[0];
 curve_2_reversed = curve_2->geom_parms.polygon_inx;
/*
 * Get the control data, if any
 */
 number_of_control_points = (me->number_of_events_input - 7) / 2 + 1;
 c1_control_points = (IGRpoint *) malloc(number_of_control_points *
   sizeof(IGRpoint));
  if (! c1_control_points)
   {
    *my_msg = MANOMEMORY;
    goto wrapup;
   }
 c2_control_points = (IGRpoint *) malloc(number_of_control_points *
   sizeof(IGRpoint));
  if (! c2_control_points)
   {
    *my_msg = MANOMEMORY;
    goto wrapup;
   }
 OM_BLOCK_MOVE(
  &me->events[1].event.button.x,
  c1_control_points,
  sizeof(IGRpoint));
 OM_BLOCK_MOVE(
  &me->events[4].event.button.x,
  c2_control_points,
  sizeof(IGRpoint));
 j = 6;
 for (i = 1; i < number_of_control_points; i++)
  {
   OM_BLOCK_MOVE(
    &me->events[j].event.button.x,
    &c1_control_points[i][0],
    sizeof(IGRpoint));
   j++;
   OM_BLOCK_MOVE(
    &me->events[j].event.button.x,
    &c2_control_points[i][0],
    sizeof(IGRpoint));
   j++;
  } /* for (i = 1; i < number_of_control_points; i++) */
/*
 * Construct the ruled surface
 */
/****************************************************************************
 sts = EFplace_ruled_surface(my_msg,
                      (me->associative ? NULL : EMSasconst_notassociative),
                       curve_1,
                       curve_2,
                       me->creation_option,
                       number_of_control_points,
                       c1_control_points,
                       c2_control_points,
                       my_construct_list,
                       my_constructed_object);
****************************************************************************/
  sts = ems$place_ruled_surface(msg = my_msg,
             options = (me->associative ? NULL : EMSasconst_notassociative),
                                crv1_info = curve_1,
                                crv2_info = curve_2,
                  ruled_surface_type = me->creation_option,
                  num_cnt_pts = number_of_control_points,
                  curve1_cnt_pts = c1_control_points,
                  curve2_cnt_pts = c2_control_points,
                  construction_list = my_construct_list,
                  ruledsf_obj = my_constructed_object);
 
  if (! (1 & sts & *my_msg)) 
   *my_msg = MSFAIL;
/*
 * eof
 */
wrapup:
 if (c1_control_points) free(c1_control_points);
 if (c2_control_points) free(c2_control_points);
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

method init(int type; char *str_ptr)
{
 IGRlong	sts;
/*
 * Let my parent do it's stuff
 */
 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message ECconstruct.init(
   type,
   str_ptr),
  targetid = my_id);

/*
 * Initialize status display form variables
 */

 me->creation_option = 1;  /* Smooth is default */

/*
 * eof
 */
 me->form_requested = 0;
 return(OM_S_SUCCESS);
}

// Make sure the user knows a status form is available.

method wakeup(int pos)
{
    om$send(mode = OM_e_wrt_message,
            msg = message ECconstruct.wakeup(pos),
            targetid = my_id);
    ex$message(msgnumb = EMS_I_InvkStatusFrm); 
    GRstatus_display_button(1);
    return(OM_S_SUCCESS);
}


/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */
method update_status_form()
{
 int ret;
 
 ret = FIg_set_state_off(me->form1, NATURAL_BUTTON);
 ret = FIg_set_state_off(me->form1, SMOOTH_BUTTON); 
 ret = FIg_set_state_off(me->form1, DEVELOPABLE_BUTTON); 
 if (me->creation_option == 0){
   ret = FIg_set_state_on(me->form1, NATURAL_BUTTON);
 }
 else if (me->creation_option == 1){ 
  ret = FIg_set_state_on(me->form1, SMOOTH_BUTTON);
 }
 else if (me->creation_option == 2){
  ret = FIg_set_state_on(me->form1, DEVELOPABLE_BUTTON);
 }
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */

method status_disp()
{ 
  IGRlong status, EMmsg;
  int ret;
  IGRint ECruledsur_process_form();

  status = OM_S_SUCCESS;
  EMmsg = 1;
  ret = FIf_new (FORM1, "EMSRuledSf", ECruledsur_process_form, &me->form1);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
  ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
  status = om$send(msg = message ECconstruct.update_status_form(),
                targetid = my_id);
  if (!me->form_requested)
  {
    ret = FIf_set_location (me->form1, 0, 125);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
    ret = FIf_display(me->form1);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
 me->form_requested = TRUE;
  }

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}

IGRint ECruledsur_process_form (form_label, gadget_label, value, form_ptr)
int form_label, gadget_label;
double value;
Form  form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECruledsur.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
return (stat_OM);
}


method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRint	update_form, stat_func;
 IGRlong sts;
 int ret;

/*
 * Initialize
 */
 update_form = 1;
 sts = OM_S_SUCCESS;

/*
 * Branch based on the form label
 * which was affected.
 */
 if (form_label == FORM1) {
 switch (gadget_label)
  {
   case ACCEPT_BUTTON:
    update_form = 0;
    ret = FIg_set_state_off (me->form1, ACCEPT_BUTTON);
    ret = FIf_erase(me->form1);
    me->form_requested = 0;
    break;
   case NATURAL_BUTTON:
    me->creation_option = 0;
    break;
   case SMOOTH_BUTTON:
    me->creation_option = 1;
    break;
   case DEVELOPABLE_BUTTON:
    me->creation_option = 2;
    break;
   default:
    update_form = 0;
    break;
 } /* switch (gadget_label) */
/*
 * Update the form, if required
 */
}
 if (update_form == 1){
   stat_func = om$send(msg = message ECconstruct.update_status_form(),
                       targetid = my_id);
   if (!(1 & stat_func)) {
      return (OM_E_ABORT);
   }
 }
 
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method is_associative(IGRint type; IGRlong *associative)
{
 IGRlong    EMmsg;
 IGRboolean state;

 EMmsg = 1;

 *associative = FALSE;
 gr$get_associative_flag( buffer = &state );

 if (state)
    *associative = TRUE;

 return(OM_S_SUCCESS); 
}

end implementation ECruledsur;
