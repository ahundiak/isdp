/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlexec.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Execute a query.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "risflags.h"
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlexec_c
#include "utlexec.prt"
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

extern void RISutl_exec(
	unsigned char	execute_mode)
{
	sqlda	*input;

	UTL_DBG(("RISutl_exec(execute_mode:0x%x)\n",execute_mode));

	if (RISutl_get_stmt_id())
	{
		return;
	}

	input = &RISutl_stmts[RISutl_stmt_id].input;

	if (execute_mode == ASYNC_START_MODE)
	{
		RISint_execute(&RISutl_stmt_id, &RISutl_async_id, input, execute_mode,
			RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	}
	else
	{
		RISint_execute(&RISutl_stmt_id, 0, input, execute_mode,
			RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	}
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();
	if (SQLCODE == END_OF_DATA)
	{
		RISutl_printf("No rows updated.\n");
	}

	if (execute_mode == ASYNC_START_MODE)
	{
		RISutl_printf("\nThe async id for this statement is %d\n", RISutl_async_id);
	}

	UTL_DBG(("RISutl_exec:returning\n"));
}

/******************************************************************************/
