class implementation DPdsp_tol;

#include <stdio.h>
#include "FI.h"
#include "exmacros.h"
#include "dpmacros.h"

#define DSP_TOLERANCE_SLD 12	/* gadget number of the slider */

/*----------------------------------------------------------------------
NAME
        DPstdsptl_form_notif

DESCRIPTION
        Notificatin routine of the Set Display Tolerance ("DPStDspTl") form.

	Set the display tolerance and delete the form. Put FORM_FINISHED
	event into the event queue.

SYNOPSIS
PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
        07/20/93    T. Wang
        09/20/93    H.S.Gandhi -- made changes to save the pixel tolerance 
                                  in the design file
*/

#argsused
static void DPstdsptl_form_notif(int form_label, 
				 int gadget_label, 
				 double value, 
				 Form form_ptr)
{
    IGRint resp;
    IGRlong msg;
    IGRdouble tmp_double;
    
    switch( gadget_label )
    {
      case FI_ACCEPT:

	/* Set new tolerance */
	FIg_get_value( form_ptr, DSP_TOLERANCE_SLD, &tmp_double );
	dp$set_display_tolerance( pixel_toler = (IGRint)tmp_double );

        /* set the tolerance in the DPcodpb object --HSG */
        DPcodpb_set_pixel_tolerance( (IGRchar) tmp_double ); 
	/* no break */

      case FI_CANCEL:
	FIf_delete( form_ptr) ;
	resp = FORM_FINISHED;
	ex$putque( msg = &msg, response = &resp );

	break;
    }    
}


/*
NAME
        method execute

DESCRIPTION
        Create "Set Display Tolerance" form. Wait for form finish. Delete
	form. Note, for this simple command, I choose to always create and
	delete the form inside execute() method. This can avoid overriding
	wakeup,sleep methods, etc.
	
SYNOPSIS
PARAMETERS
GLOBALS USED

RETURN VALUES
       Allways OM_S_SUCESS       

NOTES
HISTORY
        07/20/93    T. Wang
        09/20/93    H.S.Gandhi -- made changes to read the pixel tolerance 
                                  from the design file through the DPcodpb
                                  object
*/

method execute(int *response;
	       char *response_data;
	       int pos )
{
    IGRlong msg;
    IGRint  sts;
    struct GRevent event1;
    IGRchar pixel_toler;

    /* Clear messages */
    ex$message(field=MESSAGE_FIELD, in_buff=ME.super_cmd->cmd_name);
    ex$message(field=PROMPT_FIELD, in_buff="");
    ex$message(field=ERROR_FIELD, in_buff="");
    ex$message(field=KEYIN_FIELD, in_buff="");

    /* Create the form and initialize it to be the current tolerance */
    sts = FIf_new( 101, "GRSetDisTol", DPstdsptl_form_notif, &(ME.DPdsp_tol->form) );

    if( sts != FI_SUCCESS ) 
    {
	*response = TERMINATE;
	goto wrapup;
    }
	
    /* Set current tolerance to the form */
/***
    dp$inq_display_tolerance( pixel_toler = &pixel_toler );
**/
    /* Got the tolerance from the design file --HSG */
    DPcodpb_get_pixel_tolerance( (IGRchar *) &pixel_toler );

    FIg_set_value( ME.DPdsp_tol->form, DSP_TOLERANCE_SLD, (IGRdouble)pixel_toler );
    FIf_display( ME.DPdsp_tol->form );

    /* Wait for form to finish */
    sts = co$getevent( msg = &msg ,
 		       event_mask = GRm_FORM_FINISHED,
		       response = response,
		       response_data = response_data,
		       event = &event1 );

    if ( event1.response == FORM_FINISHED )
    {
	/* Form is finished. Note that in this case the form is already
	   deleted and tolerance has been set by the notif routine */
	ME.DPdsp_tol->form = NULL;
	*response = TERMINATE;
    }
    else
    {
	/* Delete form when sleep */
	FIf_delete( ME.DPdsp_tol->form );
	ME.DPdsp_tol->form = NULL;
    }

  wrapup:
    return OM_S_SUCCESS;
}



end implementation DPdsp_tol;
