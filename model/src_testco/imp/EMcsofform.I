/* ###################   APOGEE COMPILED   ################## */
class implementation ECcsoffset;

/* 
History:

	02/15/93 : sampath : Creation .
	09/14/93 : sampath : Modified to invoke EMOffsetSurf and invoke status
			     display form in all states of the command.
        12/23/93 : sudhakar: Modified to ensure changes in the form get
                             reflected in the options message [TR 119313356].
                             Also deleted code related to options such as
                             symmetric which no longer exist in the "offset
                             surface" form.

*/

#ifdef DEBUG
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

#define DIRECTION     11
#define SYMMETRIC     12
#define COMMON_TK     13
#define MULTIPLE_TK   14
#define DEFAULT_TK    19

#define EXIT		1
#define X_MARK		4
#define CON_TO_WINDOW	5
#define SAVE		11

#define ON  		1
#define OFF 		0


#ifndef DEBUG
#define DEBUG 0  /* Set to 1 if want error strings printed. */
#endif

#ifdef DEBUG
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

	    case COMMON_TK:
		if(me->common_tk_flag)
		{
	  	me->multi_tk = FALSE; 
          	FIg_set_state_on(ME.ECcsoffset->form1, COMMON_TK);
          	FIg_set_state_off(ME.ECcsoffset->form1, MULTIPLE_TK);
		}
		else
		{
          	FIg_set_state_on(ME.ECcsoffset->form1, MULTIPLE_TK);
          	FIg_set_state_off(ME.ECcsoffset->form1, COMMON_TK);
		}
		break;

	    case MULTIPLE_TK:
		if(me->multiple_tk_flag)
		{
	  	me->multi_tk = TRUE; 
          	FIg_set_state_on(ME.ECcsoffset->form1, MULTIPLE_TK);
          	FIg_set_state_off(ME.ECcsoffset->form1, COMMON_TK);
		}
		else
		{
          	FIg_set_state_on(ME.ECcsoffset->form1, COMMON_TK);
          	FIg_set_state_off(ME.ECcsoffset->form1, MULTIPLE_TK);
		}
		break;

      	    case EXIT:
		if(gadget_label==EXIT)
          	    FIg_set_state_off(ME.ECcsoffset->form1, EXIT);
          	FIf_erase(ME.ECcsoffset->form1);
	  	me->form_displayed = FALSE;

               /* Send a data point to ensure that the changes made in
                  the form get reflected in the options message */
      	  	response = EX_DATA;
      	  	event.response = EX_DATA;
      	  	sts = ex$putque(msg = &msg_loc, response = &response,
                  	byte = &event_size, buffer = (char *) &event.event);
      	  	ERROR(sts, msg_loc, "In form_input: SAVE error");

	  	break;

	    default:
		break;
   	   } /* switch */
	}

ret_end:
   return(sts);

} /* do_form */

IGRint ECcsoffset_process_form(form_label, gadget_label, value, form_ptr)
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
  
  	stat_OM = om$send(msg = message ECcsoffset.do_form (&msg_loc, form_label,
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
/*
	IGRint 		ECcsoffset_process_form(IGRint ,IGRint ,IGRdouble ,Form );
*/

	sts = msg_loc = OM_S_SUCCESS;

	/* Invoke the form  */

	if(!me->form_displayed) {
    		if(!ME.ECcsoffset->form1) {
			ret = FIf_new(FORM1, "EMOffsetSurf", 
	    			ECcsoffset_process_form, &ME.ECcsoffset->form1);
			if(ret) return (OM_E_ABORT);
			if(!me->multi_tk)
          		    FIg_set_state_on(ME.ECcsoffset->form1, COMMON_TK);
			else
          		    FIg_set_state_on(ME.ECcsoffset->form1, MULTIPLE_TK);
    		}
		else { /* this is invoked when the user changes the options  
							by keying in */
			IGRint form_lab = 1, gad_lab;
			if(!me->multi_tk)
				gad_lab = COMMON_TK;
			else
                        	gad_lab = MULTIPLE_TK;
			ret = ECcsoffset_process_form(form_lab, gad_lab, 1.0, 
				ME.ECcsoffset->form1);
		}
		ret = FIf_set_cmd_oid_os(ME.ECcsoffset->form1, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);

               /* Now display the form */
		ret = FIf_display (ME.ECcsoffset->form1);
		if(ret) return (OM_E_ABORT);
		me->form_displayed = TRUE;
	}
	return(sts);
} /* status_disp */

end implementation ECcsoffset;
