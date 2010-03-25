#include <malloc.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMClose						*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMClose (TCBD)						*/
/*									*/
/*	  int  TCBD;	--  TCB descriptor of terminal instance to	*/
/*			    close					*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function closes a terminal instance.  It removes the	*/
/*	  specified TCB from the TCB list, frees the storage used	*/
/*	  by the TCB, and closes the printer port (if open).		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If the terminal instance is successfully closed, a zero is    */
/*	  value is returned.						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMClose (TCBD)
     
int	TCBD;
{
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	/* Free the storage previously allocated for the TCB,		*/
	/* remove its entry in the TCB list, and close its printer	*/
	/* port if necessary.						*/

	if (TCB->term_settings.printerMode != NO_PRINTER)
	    close(TCB->printer_port);

	if (TCB->save_screen != NULL)
	    free (TCB->save_screen);
	free (TCB->screen);
	free (TCB);
	EM_TCB_list[TCBD] = NULL;

	/* Return to caller. */
	return (EM_NO_ERROR);
}
