/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlterm.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					6/87
**	ABSTRACT:
**		Contains termination and signal handling initialization routine
**		USED ONLY BY THE RIS PROGRAM.  The general signal handling routine
**		for RIS is elsewhere.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlterm_c
#include "utlterm.prt"
#include "utlprint.prt"
#include "utlintrp.prt"
#include "edtgets.prt"
#include "ris.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_terminate()
{
	/*
	**	Reset the signals
	*/
	RISutl_reset_interrupt();

	/*
	** cleanup the editor stuff
	*/
	EDT_terminate();

	RISutl_printf("\n");

	RISterminate();
	exit(0);
}

/******************************************************************************/
