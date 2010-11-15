/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlfetch.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Fetch results of a select statement.
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
#define utlfetch_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlfetch.prt"
#include "utlid.prt"
#include "utlerror.prt"
#include "utloutpt.prt"
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

extern void RISutl_fetch(
	int flag)
{
	unsigned char	execute_mode = SYNC_MODE;
	sqlda	*output;

	UTL_DBG(("RISutl_fetch(flag:%d)\n", flag));

	switch(flag)
	{
		case RETRIEVE_MODE:
			RISutl_printf("\nRetrieve Command\n");
			if (RISutl_get_stmt_id())
			{
				UTL_DBG(("RISutl_fetch:returning\n"));
				return;
			}
			break;

		case ASYNC_FETCH_MODE:
			execute_mode = ASYNC_START_MODE;
		case FETCH_MODE:
			RISutl_printf("\nFetch Command\n");
			if (RISutl_get_stmt_id())
			{
				UTL_DBG(("RISutl_fetch:returning\n"));
				return;
			}
			break;

		case ASYNC_NEXT_MODE:
			execute_mode = ASYNC_START_MODE;
		case NEXT_MODE:
			RISutl_printf("\nFetch Command\n");
			break;

	}

	/* Fetch all variables and print data */

	output = &RISutl_stmts[RISutl_stmt_id].output;

	CLEAR_INTERRUPT();
	do
	{
		if (execute_mode == ASYNC_START_MODE)
		{
			RISint_fetch(RISutl_stmt_id, &RISutl_async_id, output, 0,
				execute_mode);
		}
		else
		{
			RISint_fetch(RISutl_stmt_id, 0, output, 0, execute_mode);
		}
		UTL_WARNING_CHECK();
		UTL_ERROR_CHECK();
		if (SQLCODE == END_OF_DATA)
		{
			RISutl_printf("\nEnd of Data Found ... \n");
			break;
		}
	
		if (execute_mode == ASYNC_START_MODE)
		{
			RISutl_printf("\nThe async id for this statement is %d\n",RISutl_async_id);
		}
		else
		{
			RISutl_output_data(output);
		}
	
	} while (flag == RETRIEVE_MODE && !INTERRUPTED());

	UTL_DBG(("RISutl_fetch:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_output_parms(
	void)
{
	UTL_DBG(("RISutl_show_output_parms()\n"));

	if (RISutl_get_stmt_id())
	{
		UTL_DBG(("RISutl_show_output_parms:returning\n"));
		return;
	}

	RISutl_output_data(&RISutl_stmts[RISutl_stmt_id].output);

	UTL_DBG(("RISutl_show_output_parms:returning\n"));
}

/******************************************************************************/
