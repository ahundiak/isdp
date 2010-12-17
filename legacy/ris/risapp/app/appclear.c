/*
**	NAME:							appclear.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					10/87
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appclear_c
#include "appbufto.prt"
#include "appclear.prt"
#include "appcrsr.prt"
#include "appsndrc.prt"
#include "appsqlca.prt"
#include "apptobuf.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comfree.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISapp_clear(
	short	*id,
	int		set_sqlcode,
	int		client_flag,
	unsigned char	execute_mode)
{
	int		status;
	short	*temp_stmt_id_addr;

	APP_DBG(("RISapp_clear(*id:%hd set_sqlcode:%d client_flag:%d "
		"execute_mode:%s)\n", *id, set_sqlcode, client_flag,
		RIScom_get_execute_mode_name(execute_mode)));

    if (*id < 0 || *id >= (short)RIS_max_stmts)
    {
		if (set_sqlcode) LONGJMP(RIS_E_INV_STMTID);
		return;
    }

	RIS_current_stmt_id = *id;
	RIS_stmt = RIS_stmts[*id];
	if (!set_sqlcode)
	{
		if (risca->sqlstmt && RIS_stmt && RIS_stmt->query)
		{
			strcpy(risca->sqlstmt, RIS_stmt->query);
		}
		RISapp_push_risca_dbca();
	}

	status = SETJMP();
	if (!status)
	{
		if (IN_START_MODE(execute_mode))
		{
			/*
			**	Close the cursor if needed
			*/
/* Fix for coredump (TR 439501479) to check if RIS_stmt exists before 
checking for RIS_stmt->fetch_buf -Radha 4/26/95
*/
			if ( (RIS_stmt) && (RIS_stmt->fetch_buf) )
			{
				RISapp_close_cursor(RIS_current_stmt_id);
			}
		}

		if (client_flag && !RIS_client_died)
		{
			if (IN_START_OR_FINISH_MODE(execute_mode))
			{
				/*
				**	Clear the client statement
				*/
				RISapp_clear_to_buf(set_sqlcode, execute_mode);
				RISapp_send_rec();
			}

			if (IN_FINISH_MODE(execute_mode))
			{
				RISapp_buf_to_clear();
			}
		}
	}
	RESETJMP();

	/*
	**	Clear the application no matter what happens on client side i.e. even
	**	if there was an error. BUT with one exception for errcode 
	**	STATEMENT_NOT_COMPLETE 	-- Hitesh R. Patel 9/93
	*/
	if (IN_FINISH_MODE(execute_mode) &&
	   (status != STATEMENT_NOT_COMPLETE))
	{
		if (!RIS_stmts[*id])
		{
			RIS_current_stmt_id = -1;
			*id = -1;
		}
		else
		{
			APP_DBG(("Clearing stmt_id:%d ...\n", *id));
			/*
			**	Save the address of the embedded stmt id.
			*/
			temp_stmt_id_addr = RIS_stmt->stmt_id_addr;

			/*
			**	Decrement the total static statement count if RIS_stmt
			**	is a static statement.
			*/
			if (RIS_stmt->timestamp)
			{
				if (RIS_static_stmt_cnt > 0) RIS_static_stmt_cnt--;
			}

			/*
			**	Free allocated memory associated with id
			*/
			FREE(*id);

			/*
			**	Make statement id valid again
			*/
			RIS_stmts[*id] = 0;
			RIS_stmt = 0;

			/*
			**	set id = -1
			*/
			RIS_current_stmt_id = -1;
			*id = -1;
			
			/*
			**	Reset the embedded variable if we know it.
			*/
			if (temp_stmt_id_addr)
			{
				*temp_stmt_id_addr = -1;
			}
		}
	}

	if (set_sqlcode)
	{
		if (status != RIS_SUCCESS) LONGJMP(status);
		return;
	}
	else
	{
		RISapp_pop_risca_dbca();
		return;
	}
}

/******************************************************************************/

extern void RISapp_clear_all(
	int		client_flag)
{
	int		status;
	short	id;
	short	*temp_stmt_id_addr;

	APP_DBG(("RISapp_clear(client_flag:%d)\n", client_flag));

	RISapp_push_risca_dbca();

    for (id = 0; id < (short)RIS_max_stmts; id++)
    {
		if (!RIS_stmts[id])
		{
			continue;
		}

		RIS_current_stmt_id = id;
		RIS_stmt = RIS_stmts[id];

		status = SETJMP();
		if (!status)
		{
			if (RIS_stmt->fetch_buf)
			{
				/*
				**	Close the cursor
				*/
				RISapp_close_cursor(RIS_current_stmt_id);
			}

			if (client_flag && !RIS_client_died)
			{
				/*
				**	Clear the client statement
				*/
				RISapp_clear_to_buf(DONT_SET_SQLCODE, SYNC_MODE);
				RISapp_send_rec();
				RISapp_buf_to_clear();
			}
		}
		RESETJMP();

		if (!RIS_stmts[id])
		{
			RIS_current_stmt_id = -1;
			id = -1;
		}
		else
		{
			/*
			**	Save the address of the embedded stmt id.
			*/
			temp_stmt_id_addr = RIS_stmt->stmt_id_addr;

			/*
			**	Free allocated memory associated with id
			*/
			FREE(id);

			/*
			**	Make statement id valid again
			*/
			RIS_stmts[id] = 0;
			RIS_stmt = 0;

			/*
			**	set id = -1
			*/
			RIS_current_stmt_id = -1;
			id = -1;
			
			/*
			**	Reset the embedded variable if we know it.
			*/
			if (temp_stmt_id_addr)
			{
				*temp_stmt_id_addr = -1;
			}
		}
	}

	RIS_static_stmt_cnt = 0;

	RISapp_pop_risca_dbca();
}

/******************************************************************************/

extern void RISapp_clear_async(
	int	*async_id,
	int	set_sqlcode)
{
	int sts;

	APP_DBG(("RISapp_clear_async(*async_id:%d set_sqlcode:%d)\n", *async_id,
		set_sqlcode));

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (set_sqlcode) LONGJMP(sts);
		return;
	}

	if (*async_id < 0 || *async_id >= RIS_MAX_TRANSACTIONS)
	{
		LONGJMP(RIS_E_INV_ASYNC_ID);
	}

	if (RIS_asyncs[*async_id])
	{
		if (IN_INCOMPLETE_STATE(RIS_asyncs[*async_id]->state))
		{
			LONGJMP(RIS_E_CANT_CLEAR_ASYNC);
		}
		FREEA(*async_id);
		RIS_asyncs[*async_id] = NULL;
		RIS_async = NULL;
		*async_id = -1;
	}

	RESETJMP();
	
	APP_DBG(("RISapp_clear:complete\n"));
}

/******************************************************************************/

extern void RISapp_clear_all_async(
	void)
{
	int async_id;
	int async_stmts = 0;

	APP_DBG(("RISapp_clear_all_async()\n"));

	for (async_id = 0; async_id < RIS_MAX_TRANSACTIONS; async_id++)
	{
		if (RIS_asyncs[async_id])
		{
			if (IN_INCOMPLETE_STATE(RIS_asyncs[async_id]->state))
			{
				LONGJMP(RIS_E_CANT_CLEAR_ASYNC);
			}

			async_stmts = 1;
		}
	}

	if (async_stmts)
	{
		for (async_id = 0; async_id < RIS_MAX_TRANSACTIONS; async_id++)
		{
			if (RIS_asyncs[async_id])
			{
				FREEA(async_id);
				RIS_asyncs[async_id] = NULL;
				RIS_async = NULL;
			}
		}
	}

	APP_DBG(("RISapp_clear:complete\n"));
}
/******************************************************************************/
