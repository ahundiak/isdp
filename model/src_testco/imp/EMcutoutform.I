/* ###################   APOGEE COMPILED   ################## */
class implementation ECplcutout;

/* 
History:
    Tapadia 07/22/92 - Genesis. This form is used to display the profile hole
                       options.
    Kumar N 01/24/93 - Reaction to shamrock - WINDOWS NT
    scw     06/14/93 - Removed references to the X11 directory for include 
                       files.
    scw     08/13/94 - Added X11 for Intel Solaris port
*/

#if DEBUG
#include <stdio.h>
#endif

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

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

#define THROUGH_ALL	16
#define THROUGH_UNTIL	18
#define THROUGH_NEXT	17

#define EXIT		1
#define CON_TO_WINDOW	5
#define SAVE		11

#define ON  		1
#define OFF 		0

#define THRU_ALL	0
#define THRU_UNTIL	1
#define THRU_NEXT	2

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

   	sts = OM_S_SUCCESS;
   	event_size = sizeof(struct GRevent);

 	if (form_label == 1) {
   	  switch(gadget_label) {
	    case THROUGH_ALL:
	  	me->depth_type = THRU_ALL; 
          	FIg_set_state_on(ME.ECplcutout->form1, THROUGH_ALL);
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_UNTIL);
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_NEXT);
		break;

	    case THROUGH_UNTIL:
	  	me->depth_type = THRU_UNTIL; 
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_ALL);
          	FIg_set_state_on(ME.ECplcutout->form1, THROUGH_UNTIL);
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_NEXT);
		break;

	    case THROUGH_NEXT:
	  	me->depth_type = THRU_NEXT; 
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_ALL);
          	FIg_set_state_off(ME.ECplcutout->form1, THROUGH_UNTIL);
          	FIg_set_state_on(ME.ECplcutout->form1, THROUGH_NEXT);
		break;

      	    case EXIT:
          	FIf_erase(ME.ECplcutout->form1);
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

IGRint ECplcutout_process_form(form_label, gadget_label, value, form_ptr)
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
  
  	stat_OM = om$send (msg = message ECplcutout.do_form (&msg_loc, 
			form_label, gadget_label, value),
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
	IGRint 		ECplcutout();

	sts = msg_loc = OM_S_SUCCESS;

	/* Invoke the form only when the diameter is being asked */
	if(ME.super_cmd->state == 0 && !me->form_displayed) {
    		if(!ME.ECplcutout->form1) {
			ret = FIf_new(FORM1, "EMCutout", 
				ECplcutout_process_form, &ME.ECplcutout->form1);
			if(ret) return (OM_E_ABORT);
			if(me->depth_type == THRU_ALL)
          		    FIg_set_state_on(ME.ECplcutout->form1, THROUGH_ALL);
			else if(me->depth_type == THRU_NEXT)
          		    FIg_set_state_on(ME.ECplcutout->form1,
				THROUGH_NEXT);
			else 
          		    FIg_set_state_on(ME.ECplcutout->form1, 
				THROUGH_UNTIL);
    		}
		else { /* this is invoked when the user changes the hole type
							by keying in */
			IGRint form_lab = 1, gad_lab;
			if(me->depth_type == THRU_ALL)
				gad_lab = THROUGH_ALL;
			else if(me->depth_type == THRU_NEXT)
				gad_lab = THROUGH_NEXT;
			else 
				gad_lab = THROUGH_UNTIL;
			ret = ECplcutout_process_form(form_lab, gad_lab, 1.0, 
				ME.ECplcutout->form1);
		}
		ret = FIf_set_cmd_oid_os(ME.ECplcutout->form1, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);

		ret = FIf_display (ME.ECplcutout->form1);
		if(ret) return (OM_E_ABORT);
		me->form_displayed = TRUE;
	}
	return(sts);
} /* status_disp */

end implementation ECplcutout;
