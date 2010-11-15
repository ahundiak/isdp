/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intclear.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risasync.h"
#include "riscom.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intclear_c
#include "appclear.prt"
#include "appasync.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "intclear.prt"
#include "interror.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_clear(
	short	*stmt_id,
	int		*async_id,
	unsigned char		execute_mode)
{
	int sts;
	int len;

	INT_DBG(("RISint_clear(stmt_id:0x%x async_id:0x%x execute_mode:%s)\n",
		stmt_id, async_id, RIScom_get_execute_mode_name(execute_mode)));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "CLEAR\n");
		fprintf(RIS_RAP, "stmt_id:%d\n", *stmt_id);
		fprintf(RIS_RAP, "execute_mode:%d\n", execute_mode);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		SET_RISCA(RIS_E_NOT_INITIALIZED);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (!RIS_net)
	{
		SET_RISCA(RIS_E_CLIENT_NOT_STARTED);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (*stmt_id < 0 || *stmt_id >= (short)RIS_max_stmts 
		|| !RIS_stmts[*stmt_id])
	{
		SET_RISCA(RIS_E_INV_STMTID);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	RIS_current_stmt_id = *stmt_id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	/*
	**	Check the state
	*/
	if (IN_START_MODE(execute_mode) && RIS_stmt->async &&
		IN_INCOMPLETE_STATE(RIS_stmt->async->state))
	{
		SET_RISCA(RIS_E_ALREADY_EXECUTING);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (IN_START_MODE_ONLY(execute_mode))
	{
		*async_id = -1;
	}
	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (IN_START_MODE_ONLY(execute_mode))
		{
			RISapp_clear_async(async_id, DONT_SET_SQLCODE);
		}

		SET_RISCA(sts);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (IN_START_MODE_ONLY(execute_mode))
	{
		/*
		** Allocate async struct here.
		*/
		*async_id = RISapp_new_async();

		RIS_stmt->async = RIS_async;

		RIS_async->stmt = RIS_stmt;
		RIS_async->stmt_id = RIS_current_stmt_id;
		RIS_async->state = CLEAR_STATE;
		RIS_async->args.clear.stmt_idp = stmt_id;

		len = strlen(RIS_stmt->query) + 1;
		RIS_async->rissqlstmt = ALLOCBA(RIS_async->async_id, len);
		memcpy(RIS_async->rissqlstmt, RIS_stmt->query, len);
	}

	if (IN_START_OR_FINISH_MODE(execute_mode))
	{
		RISapp_clear(stmt_id, SET_SQLCODE, CLEAR_CLIENT, execute_mode);
	}

	RESETJMP();

	INT_DBG(("RISint_clear:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return_BEGIN();
		fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		if (IN_START_MODE_ONLY(execute_mode))
		{
			fprintf(RIS_RAP, "async_id:%d\n", *async_id);
		}
	RISrap_return_END();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXint_clear_async(
	int	*async_id)
{
	int sts;

	INT_DBG(("RISint_clear_async(*async_id:%d)\n", *async_id));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "CLEAR_ASYNC\n");
		fprintf(RIS_RAP, "async_id:%d\n", *async_id);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		SET_RISCA(RIS_E_NOT_INITIALIZED);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_net)
	{
		SET_RISCA(RIS_E_CLIENT_NOT_STARTED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	RISapp_clear_async(async_id, SET_SQLCODE);

	RESETJMP();

	INT_DBG(("RISint_clear_async:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
