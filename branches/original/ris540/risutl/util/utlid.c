/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlid.c
**	AUTHORS:						David Michal
**	CREATION DATE:					9/88
**	ABSTRACT:
**		The function that gets a cursor number from the user.
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
#define utlid_c
#include "comdebug.prt"
#include "utlid.prt"
#include "utlmisc.prt"
#include "utlprint.prt"
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

extern int RISutl_get_stmt_id(
	void)
{
	char temp_buf[20];
	int temp;

	UTL_DBG(("RISutl_get_stmt_id()\n"));

	CLEAR_INTERRUPT();

	if (RISutl_stmt_id >= 0 &&
		RISutl_stmt_id < RISutl_parameters.max_user_stmts)
	{
		RISutl_printf("Enter the statement id [%d]:\n", RISutl_stmt_id);
	}
	else
	{
		RISutl_printf("Enter the statement id:\n");
	}

	RISutl_fgets(temp_buf,20,RISutl_file_tos->file);
	if (INTERRUPTED())
	{
		UTL_DBG(("RISutl_get_stmt_id:returning 1\n"));
		return 1;
	}
	if (*temp_buf)
	{
		if (sscanf(temp_buf, "%d", &temp) == 0)
		{
			RISutl_printf("Invalid statement id.\n");

			UTL_DBG(("RISutl_get_stmt_id:returning 1\n"));
			return 1;
		}
		
		if (temp < 0 ||
			temp >= RISutl_parameters.max_user_stmts ||
			temp != RISutl_stmts[temp].stmt_id)
		{
			RISutl_printf("Invalid statement id.\n");

			UTL_DBG(("RISutl_get_stmt_id:returning 1\n"));
			return 1;
		}

		RISutl_stmt_id = temp;
	}
	else if(RISutl_stmt_id < 0 ||
			RISutl_stmt_id >= RISutl_parameters.max_user_stmts ||
			RISutl_stmt_id != RISutl_stmts[RISutl_stmt_id].stmt_id)
	{
		RISutl_printf("Invalid statement id.\n");

		UTL_DBG(("RISutl_get_stmt_id:returning 1\n"));
		return 1;
	}

	UTL_DBG(("RISutl_get_stmt_id:returning 0\n"));
	return 0;
}

/******************************************************************************/

extern int RISutl_get_async_id(
	void)
{
	int		temp;
	char	temp_buf[20];

	UTL_DBG(("RISutl_get_async_id()\n"));

	CLEAR_INTERRUPT();

	if (RISutl_async_id >= 0 &&
		RISutl_async_id < RIS_MAX_TRANSACTIONS)
	{
		RISutl_printf("Enter the async id [%d]:\n", RISutl_async_id);
	}
	else
	{
		RISutl_printf("Enter the async id:\n");
	}

	RISutl_fgets(temp_buf,20,RISutl_file_tos->file);
	if (INTERRUPTED())
	{
		UTL_DBG(("RISutl_get_async_id:returning 1\n"));
		return 1;
	}
	if (*temp_buf)
	{
		if (sscanf(temp_buf, "%d", &temp) == 0)
		{
			RISutl_printf("Invalid async id.\n");

			UTL_DBG(("RISutl_get_async_id:returning 1\n"));
			return 1;
		}
		
		if (temp < 0 || temp >= RIS_MAX_TRANSACTIONS)
		{
			RISutl_printf("Invalid async id.\n");

			UTL_DBG(("RISutl_get_async_id:returning 1\n"));
			return 1;
		}

		RISutl_async_id = temp;
	}
	else if (RISutl_async_id < 0 ||
		RISutl_async_id >= RIS_MAX_TRANSACTIONS)
	{
		RISutl_printf("Invalid async id.\n");

		UTL_DBG(("RISutl_get_async_id:returning 1\n"));
		return 1;
	}

	UTL_DBG(("RISutl_get_async_id:returning 0\n"));
	return 0;
}

/******************************************************************************/
