/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
**	NAME:							intslct.c
**	AUTHORS:						David Michal
**	CREATION DATE:					1/89
**	ABSTRACT:
**		The functions that handles single row select statements.
**	
**	REVISION HISTORY: Modified to avoid 'repreparing of static stmts' by
**                    Prasad Challa on 9/17/91.
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risasync.h"
#include "riscom.h"
#include "risflags.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define intslct_c
#include "appasync.prt"
#include "appclear.prt"
#include "appclose.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intexec.prt"
#include "intfetch.prt"
#include "intprep.prt"
#include "intrap.prt"
#include "intslct.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_select(
	short	*stmt_id,
	int		*async_id,
	char	*query,
	sqlda	*in_sqlda,
	sqlda	*out_sqlda,
	unsigned char		execute_mode)
{
	int clear_flag = 0; /* Shutup the compiler :-( */
        char *new_query;

	INT_DBG(("RISint_select(stmt_id:0x%x async_id:0x%x query:<%s> "
		"in_sqlda:0x%x out_sqlda:0x%x execute_mode:%s\n", 
		stmt_id, async_id, query, in_sqlda, out_sqlda, 
		RIScom_get_execute_mode_name(execute_mode)));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "SELECT INTO\n");
		fprintf(RIS_RAP, "stmt_id:%d\n", *stmt_id);
		 /* 1996.07.10:Alan Barksdale:TR439601444 */
		new_query = (char *)RIScom_sys_malloc(strlen(query) +1);
		DisguisePasswords(query, new_query);
		fprintf(RIS_RAP, "start query:\n%s\nstop query:\n", new_query);
		RIScom_sys_free(new_query);
		fprintf(RIS_RAP, "in_sqlda:0x%x\n", in_sqlda);
		RISXrap_print_input_sqlda(RIS_RAP, in_sqlda);
		fprintf(RIS_RAP, "out_sqlda:0x%x\n", out_sqlda);
		RISXrap_print_output_sqlda(RIS_RAP, out_sqlda);
		fprintf(RIS_RAP, "execute_mode:%d\n", execute_mode);
	RISrap_enter_END();

	if (IN_START_MODE(execute_mode))
	{
		if (RIS_parms.max_static_stmts == 0)
		{
			clear_flag = RIS_CLEAR_FLAG;
		}
		else
		{
			clear_flag = RIS_DONT_CLEAR_FLAG;
		}

		RISXint_prepare(stmt_id, query, clear_flag, RIS_STATIC_STMT);
		if (RIS_ERRCODE != RIS_SUCCESS)
		{
			RISrap_return_BEGIN();
				fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
			RISrap_return_END();
			RIS_RETURN();
		}

		if (IN_START_MODE_ONLY(execute_mode))
		{
			int sts;
			int len;

			*async_id = -1;
			if ((sts = SETJMP()) != 0)
			{
				RESETJMP();
				RISapp_clear_async(async_id, DONT_SET_SQLCODE);
				SET_RISCA(sts);
				RISrap_return_BEGIN();
					fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
				RISrap_return_END();
				RIS_RETURN();
			}

			/*
			** Allocate async struct here.
			*/

			*async_id = RISapp_new_async();

			RIS_stmt->async = RIS_async;
	
			RIS_async->stmt = RIS_stmt;
			RIS_async->stmt_id = RIS_current_stmt_id;

			RIS_async->state = SELECT_INTO_STATE;
			RIS_async->args.select_into.stmt_idp = stmt_id;
			RIS_async->args.select_into.in_sqlda = in_sqlda;
			RIS_async->args.select_into.out_sqlda = out_sqlda;

			len = strlen(query) + 1;
			RIS_async->rissqlstmt = ALLOCBA(RIS_async->async_id, len);
			memcpy(RIS_async->rissqlstmt, query, len);

			RESETJMP();
		}
	}

	if (IN_START_OR_FINISH_MODE(execute_mode))
	{
		RISXint_execute(stmt_id, async_id, in_sqlda, execute_mode, clear_flag,
			RIS_STATIC_STMT);
		if (IN_START_MODE_ONLY(execute_mode))
		{
			if (RIS_ERRCODE != RIS_SUCCESS)
			{
    			if (clear_flag == RIS_CLEAR_FLAG)
				{
					if (!RIS_client_died)
					{
						RISapp_clear(stmt_id, DONT_SET_SQLCODE, CLEAR_CLIENT,
							SYNC_MODE);
					}
				}

				RISapp_clear_async(async_id, DONT_SET_SQLCODE);

				RISrap_return_BEGIN();
					fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
				RISrap_return_END();
				RIS_RETURN();
			}

			/*
			**	Adjust RIS_async->stmt_id if RISint_execute changed the stmt_id
			*/
			if (RIS_async->stmt_id != *stmt_id)
			{
				RIS_async->stmt_id = *stmt_id;
			}
		}
	}

	if (IN_FINISH_MODE(execute_mode))
	{
		if (RIS_ERRCODE != STATEMENT_NOT_COMPLETE)
		{
			if (RIS_ERRCODE == RIS_SUCCESS)
			{
				RISXint_fetch(*stmt_id, 0, out_sqlda, 1, SYNC_MODE);
				if (!RIS_client_died)
				{
					RISapp_close(*stmt_id, DONT_SET_SQLCODE, SYNC_MODE);
				}
			}

			if (clear_flag == RIS_CLEAR_FLAG)
			{
				if (!RIS_client_died)
				{
					RISapp_clear(stmt_id, DONT_SET_SQLCODE, CLEAR_CLIENT,
						SYNC_MODE);
				}
			}
		}
	}

	INT_DBG(("RISint_select:complete\n"));

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
