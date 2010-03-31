/* ###################   APOGEE COMPILED   ################## */
class implementation ECplslot;

/* 
History:

This method displays the slot form when the status button is invoked

Tapadia  08/16/91	Creation date.
mrm      10/25/91       Position the form on the right edge of the screen.
Tapadia  01/30/91 	Fix for TR 92n0547. If the expand button is hit twice
			the user is locked & hence can't input any data point. 
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

/* define the gadget label for form */

# define DEPTH_ALL	16
# define DEPTH_NEXT	17
# define DEPTH_UNTIL	18
# define DEPTH_FINITE	19

# define SAVE		1

#define FORM1       	1 

# define THROUGH_ALL	0
# define THROUGH_UNTIL	1
# define THROUGH_NEXT	2
# define BLIND		3

# define ON  1
# define OFF 0

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

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

/* 
This method handles all the input that the gadget(s) of form received.
*/

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
	IGRdouble value)
{
	IGRlong  sts, event_size;
	sts = OM_S_SUCCESS;
	event_size = sizeof(struct GRevent);

	if (form_label == 1) {
		switch(gadget_label)
		{
		case DEPTH_ALL:
			me->depth_type = THROUGH_ALL;
			FIg_set_state_on (ME.ECplslot->form1, DEPTH_ALL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_UNTIL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_NEXT);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_FINITE);
			break;

		case DEPTH_UNTIL:
			me->depth_type = THROUGH_UNTIL;
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_ALL);
			FIg_set_state_on (ME.ECplslot->form1, DEPTH_UNTIL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_NEXT);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_FINITE);
			break;

		case DEPTH_NEXT:
			me->depth_type = THROUGH_NEXT;
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_ALL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_UNTIL);
			FIg_set_state_on (ME.ECplslot->form1, DEPTH_NEXT);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_FINITE);
			break;

		case DEPTH_FINITE:
			me->depth_type = BLIND;
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_ALL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_UNTIL);
			FIg_set_state_off (ME.ECplslot->form1, DEPTH_NEXT);
			FIg_set_state_on ( ME.ECplslot->form1, DEPTH_FINITE);
			break;

		case SAVE:
			FIg_set_state_off (ME.ECplslot->form1,SAVE);
			FIf_erase (ME.ECplslot->form1);
			me->form_displayed = FALSE;
			break;
		} /* switch */
	}
	return(sts);
} /* do_form */

/*
 * This method sets up the instance data needed by the form_input method
 */

method status_disp()
{
	IGRlong  msg_loc, sts;
	IGRint ret;
	IGRint ECplslot_process_form();

	sts = msg_loc = OM_S_SUCCESS;

	/* Invoke the form only when the profile information is being asked */
	if(ME.super_cmd->state == 0 && !me->form_displayed) {
    	   	if( ! ME.ECplslot->form1 ) {
			ret = FIf_new(FORM1, "EMSslot", ECplslot_process_form, 
	    			&ME.ECplslot->form1);
			if (ret) 
				return (OM_E_ABORT);
           	}
		ret = FIf_set_cmd_oid_os(ME.ECplslot->form1, my_id, 
			OM_Gw_current_OS);
		if (ret) 
			return (OM_E_ABORT);

		/* Initialize the gadgets data */
		if(me->depth_type == THROUGH_ALL)
			FIg_set_state_on(ME.ECplslot->form1, DEPTH_ALL);
		else if(me->depth_type == THROUGH_UNTIL)
			FIg_set_state_on(ME.ECplslot->form1, DEPTH_UNTIL);
		else if(me->depth_type == THROUGH_NEXT)
			FIg_set_state_on(ME.ECplslot->form1, DEPTH_NEXT);
		else 
			FIg_set_state_on(ME.ECplslot->form1, DEPTH_FINITE);

		ret = FIf_display (ME.ECplslot->form1);
		if(ret) return (OM_E_ABORT);
		me->form_displayed = TRUE;
	}
	return(sts);
} /* status_disp */

IGRint ECplslot_process_form(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
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

	stat_OM = om$send (msg = message ECplslot.do_form (&msg_loc, form_label,
	    		gadget_label, value),
	    	senderid = NULL_OBJID, 
		targetid = cmdobj, 
		targetos = cmdos);
	if(! (stat_OM & 1)) return (OM_E_ABORT);
        return(OM_S_SUCCESS);
} /* ECplslot_process_form() */

end implementation ECplslot;
