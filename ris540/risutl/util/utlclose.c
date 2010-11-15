/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlclose.c
**	AUTHORS:						David Michal
**	CREATION DATE:					7/88
**	ABSTRACT:
**		The code to process the schema manager form.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlclose_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlid.prt"
#include "utlerror.prt"
#include "utlprint.prt"


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

extern void RISutl_close(
	unsigned char execute_mode)
{
	UTL_DBG(("RISutl_close()\n"));

	if (RISutl_get_stmt_id())
	{
		UTL_DBG(("RISutl_close:returning\n"));
		return;
	}

	if (execute_mode == ASYNC_START_MODE)
	{
		RISint_close(RISutl_stmts[RISutl_stmt_id].stmt_id, &RISutl_async_id,
			execute_mode);
	}
	else
	{
		RISint_close(RISutl_stmts[RISutl_stmt_id].stmt_id, 0, execute_mode);
	}
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (execute_mode == ASYNC_START_MODE)
	{
		RISutl_printf("\nThe async id for this statement is %d\n",RISutl_async_id);
	}

	UTL_DBG(("RISutl_close:returning\n"));
}

/******************************************************************************/
