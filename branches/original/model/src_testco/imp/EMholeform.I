/* ###################   APOGEE COMPILED   ################## */
class implementation ECplhole;

/* 
Histroy:
    Tapadia 6/8/92 - Genesis

*/

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igrdef_include
#include "igrdef.h"
#endif

#ifndef igrdp_include
#include "igrdp.h"
#endif

#ifndef igewinmacros_include
#include "igewinmacros.h"
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

#ifndef exdef_include
#include "exdef.h"
#endif

#ifndef griomacros_include
#include "griomacros.h"
#endif

#include "comisc.h"
#include "EC_M.h"
#include "EC_E.h"

/* define the gadget label for form */
#define FORM1       1 

#define THROUGH_ALL	12
#define THROUGH_UNTIL	13
#define THROUGH_NEXT	14
#define BLIND		15
#define BOTTOM_FLAT	16
#define BOTTOM_V	17
#define V_ANGLE		18
#define NOR_TOGGLE	21

#define EXIT		1
#define CON_TO_WINDOW	5
#define SAVE		11

#define ON  		1
#define OFF 		0

#define THRU_ALL	0
#define THRU_UNTIL	1
#define THRU_NEXT	2
#define BLIND_HOLE	3

#ifndef DEBUG
#define DEBUG 0  /* Set to 1 if want error strings printed. */
#endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number)) \
   { \
      printf("\n%s\n", error_message); \
      goto ret_end; \
   } \
}
#else
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number))  goto ret_end; \
}
#endif

/* This method handles all the input that the gadget(s) of form received */

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
        IGRdouble value)
{
   	IGRlong  	msg_loc, sts, event_size;
   	IGRint  	response;
   	struct GRevent  event;
   	int 		ret, sel_flag, r_pos;
   	IGRdouble 	dvalue;

   	sts = OM_S_SUCCESS;
   	event_size = sizeof(struct GRevent);

 	if (form_label == 1) {
   	  switch(gadget_label) {
	    case THROUGH_ALL:
	  	me->depth_type = THRU_ALL; 
          	FIg_set_state_on(ME.ECplhole->form1, THROUGH_ALL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_UNTIL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_NEXT);
          	FIg_set_state_off(ME.ECplhole->form1, BLIND);
		FIg_erase(ME.ECplhole->form1, BOTTOM_FLAT);
		FIg_erase(ME.ECplhole->form1, BOTTOM_V);
		FIg_erase(ME.ECplhole->form1, V_ANGLE);
		break;

	    case THROUGH_UNTIL:
	  	me->depth_type = THRU_UNTIL; 
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_ALL);
          	FIg_set_state_on(ME.ECplhole->form1, THROUGH_UNTIL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_NEXT);
          	FIg_set_state_off(ME.ECplhole->form1, BLIND);
		FIg_erase(ME.ECplhole->form1, BOTTOM_FLAT);
		FIg_erase(ME.ECplhole->form1, BOTTOM_V);
		FIg_erase(ME.ECplhole->form1, V_ANGLE);
		break;

	    case THROUGH_NEXT:
	  	me->depth_type = THRU_NEXT; 
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_ALL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_UNTIL);
          	FIg_set_state_on(ME.ECplhole->form1, THROUGH_NEXT);
          	FIg_set_state_off(ME.ECplhole->form1, BLIND);
		FIg_erase(ME.ECplhole->form1, BOTTOM_FLAT);
		FIg_erase(ME.ECplhole->form1, BOTTOM_V);
		FIg_erase(ME.ECplhole->form1, V_ANGLE);
		break;

      	    case BLIND:
	  	me->depth_type = BLIND_HOLE; 
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_ALL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_UNTIL);
          	FIg_set_state_off(ME.ECplhole->form1, THROUGH_NEXT);
          	FIg_set_state_on(ME.ECplhole->form1, BLIND);
      		if(me->v_bottom) {  /* v bottom hole */
			FIg_erase(ME.ECplhole->form1, BOTTOM_FLAT);
			FIg_display(ME.ECplhole->form1, BOTTOM_V);
			FIg_display(ME.ECplhole->form1, V_ANGLE);
		}
      		else {	/* flat bottom hole */			
			FIg_erase(ME.ECplhole->form1, BOTTOM_V);
			FIg_erase(ME.ECplhole->form1, V_ANGLE);
			FIg_display(ME.ECplhole->form1, BOTTOM_FLAT);
		}
		break;
       
      	    case BOTTOM_FLAT: /* Toggle - displays the v bottom hole gadget */
	  	me->v_bottom = TRUE; 
		FIg_erase(ME.ECplhole->form1, BOTTOM_FLAT);
		FIg_display(ME.ECplhole->form1, BOTTOM_V);
		FIg_display(ME.ECplhole->form1, V_ANGLE);
	  	break;

      	    case BOTTOM_V: /* Toggle - displays the flat bottom hole gadget */
	  	me->v_bottom = FALSE;
		FIg_erase(ME.ECplhole->form1, BOTTOM_V);
		FIg_erase(ME.ECplhole->form1, V_ANGLE);
		FIg_display(ME.ECplhole->form1, BOTTOM_FLAT);
	  	break;

      	    case V_ANGLE: /* Can change the v bottom angle */
      		ret = FIfld_get_value(ME.ECplhole->form1, V_ANGLE, 0,0, &dvalue,
                             &sel_flag, &r_pos);
	  	if(dvalue <= 0 || dvalue > 180) {
			ex$message(msgnumb = EMS_E_InvalidAngle);
        		FIg_set_value(ME.ECplhole->form1, V_ANGLE, me->v_angle);
	  	}
	  	else  me->v_angle = dvalue;
      		FIg_set_value(ME.ECplhole->form1, V_ANGLE, dvalue);
	        break;

	    case NOR_TOGGLE: /* Toggle from normal to non-normal mode */
		me->axis_normal = !me->axis_normal;
		break;

      	    case EXIT:
          	FIf_erase(ME.ECplhole->form1);
	  	me->form_displayed = FALSE;
      	  	response = EX_DATA;
      	  	event.response = EX_DATA;
      	  	sts = ex$putque(msg = &msg_loc, response = &response,
                  	byte = &event_size, buffer = (char *)&event);
      	  	ERROR(sts, msg_loc, "In form_input: SAVE error");
	  	break;

	    default:
		break;
   	   } /* switch */
	}
ret_end:
   return(sts);

} /* do_form */

IGRint ECplhole_process_form(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
 	IGRint 		stat_func, stat_OM;
  	IGRlong 	msg_loc;
  	GRobjid 	cmdobj;
  	GRspacenum 	cmdos;

  	stat_OM = OM_S_SUCCESS;

  	stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  	if (stat_func)
    		return (OM_E_ABORT);
  
  	stat_OM = om$send (msg = message ECplhole.do_form (&msg_loc, form_label,
                     gadget_label, value),
             	senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  	if(! (stat_OM & 1))
   		return (OM_E_ABORT);
    	return(OM_S_SUCCESS);
}

/* This method sets up the instance data needed by the form_input method */

method status_disp()
{
	IGRlong  	msg_loc, sts;
	IGRint 		ret;
	IGRint 		ECplhole_process_form();

	sts = msg_loc = OM_S_SUCCESS;

	/* Invoke the form only when the diameter is being asked */
	if(ME.super_cmd->state == 0 && !me->form_displayed) {
    		if(!ME.ECplhole->form1) {
			ret = FIf_new(FORM1, "EMHole", ECplhole_process_form, 
	    			&ME.ECplhole->form1);
			if(ret) return (OM_E_ABORT);
			if(me->depth_type == THRU_ALL)
          		    FIg_set_state_on(ME.ECplhole->form1, THROUGH_ALL);
			else if(me->depth_type == THRU_NEXT)
          		    FIg_set_state_on(ME.ECplhole->form1, THROUGH_NEXT);
			else if(me->depth_type == THRU_UNTIL)
          		    FIg_set_state_on(ME.ECplhole->form1, THROUGH_UNTIL);
			else
          		    FIg_set_state_on(ME.ECplhole->form1, BLIND);
    		}
		else { /* this is invoked when the user changes the hole type
							by keying in */
			IGRint form_lab = 1, gad_lab;
			if(me->depth_type == THRU_ALL)
				gad_lab = THROUGH_ALL;
			else if(me->depth_type == THRU_NEXT)
				gad_lab = THROUGH_NEXT;
			else if(me->depth_type == THRU_UNTIL)
				gad_lab = THROUGH_UNTIL;
			else	gad_lab = BLIND;
			ret = ECplhole_process_form(form_lab, gad_lab, 1.0, 
				ME.ECplhole->form1);
		}
		ret = FIf_set_cmd_oid_os(ME.ECplhole->form1, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);

		ret = FIf_display (ME.ECplhole->form1);
		if(ret) return (OM_E_ABORT);
		me->form_displayed = TRUE;
	}
	return(sts);
} /* status_disp */

end implementation ECplhole;
