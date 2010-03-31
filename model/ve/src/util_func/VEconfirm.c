
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

#include <FI.h>
#include "igrtypedef.h"

/*---VEconfirm--------------------------------------------------------------------*/

IGRboolean VEconfirm( msg )

	IGRchar *msg;

/*
NAME
	VEconfirm

DESCRIPTION
	Display a confirmation box with a "WARNING" title

PARAMETERS
	msg (IN) - the message to display in the confirmation box

RETURN VALUES
	TRUE - if user hit check box on form
	FALSE - if user hit x box on form

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
#ifdef X11
	/* FI_confirm_box is not implemented in XFORMS */
	return( HFI_confirm_box( FI_CURRENT_SCREEN, -1, -1,
	                        "WARNING", FI_RED, "swiss742", 36.0,
	                        msg, FI_BLACK, "swiss742", 18.0,
	                        FI_LEFT_JUSTIFIED, FI_ACCEPT | FI_CANCEL, 40 ) );
#else
	return( FI_confirm_box( FI_CURRENT_SCREEN, -1, -1,
	                        "WARNING", FI_RED, "swiss742", 36.0,
	                        msg, FI_BLACK, "swiss742", 18.0,
	                        FI_LEFT_JUSTIFIED, FI_ACCEPT | FI_CANCEL, 40 ) );
#endif

	}  /* VEconfirm */
	
