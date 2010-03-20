#include <stdio.h>
#include "FI.h"

#include "XFIproto_pub.h"

		/* 	notify.c	*/
		/* NOTIFICATION ROUTINE */


/*** This routine is called by the forms system whenever  ***/
/*** the user pokes a gadget on the form. 		  ***/

/* ARGSUSED */
int DEMO_notification_routine ( form_label, gadget_label, value, form )
  int	  form_label;
  int	  gadget_label;
  double  value;
  Form	  form;
{
 /***  The ( form_label ) passed to this routine is what was    ***/
 /***  passed to the FIf_new() function when creating the form. ***/

 /***  The ( gadget_label ) is the label of the gadget on form  ***/
 /***  ( form_label ) that has been processed.			***/

 /***  The ( value ) is the state is the gadget is a state gadget.  ***/
 /***  The ( value ) is a value if the gadget is a slider or dial.  ***/
 /***  If the gadget was a field then ( value ) contains the row in ***/
 /***  the field that was modified.	 	                    ***/

 /*** The ( form ) is the actual form pointer to the form	   ***/


  switch ( gadget_label )
    {
	/* These are the #defines for the CANCEL and ACCEPT button */
	/* In our demo we will just erase the form if one of the   */
	/* control button are hit.				   */

      case FI_ACCEPT:
      case FI_CANCEL:

	FIf_erase ( form );
	FIg_set_state_off ( form, gadget_label );

	break;

      default:
	break;

    }
return(FI_SUCCESS);
}
