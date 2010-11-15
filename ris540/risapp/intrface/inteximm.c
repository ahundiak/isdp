/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
**	NAME:							inteximm.c
**	AUTHORS:						David Michal
**	CREATION DATE:					1/89
**	ABSTRACT:
**		The function that handles execute immediate statements.
**	
**	REVISION HISTORY: Modified to avoid 'repreparing of static stmts' by
**                    Prasad Challa on 9/17/91.
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
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
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define inteximm_c
#include "appclear.prt"
#include "appasync.prt"
#include "appinit.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intexec.prt"
#include "inteximm.prt"
#include "intprep.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

/*
** RIS_TO_BE_DONE_IN_FUTURE
** variable execute_mode should be unsigned char instead of int.
** In code, it has been typecasted whenever necessary -- Hitesh 5/93
*/
extern void RISAPI RISXint_execute_immediate(
	short	*stmt_id,
	int		*async_id,
	char	*query,
	sqlda	*in_sqlda,
	int		execute_mode,
	int		clear_flag,
	int		static_flag)
{
        char *new_query;

	INT_DBG(("RISint_execute_immediate(stmt_id:0x%x async_id:0x%x "
		"in_sqlda:0x%x execute_mode:<%s> clear_flag:%d static_flag:%d\n",
		stmt_id, async_id, in_sqlda, 
		RIScom_get_execute_mode_name((unsigned char)execute_mode), clear_flag, 
		static_flag));
	/*
	** NOTE
	** query was removed from the debug statement
	** because it reveils passwords
	** during "declare schema" type statements
	*/

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "EXECUTE IMMEDIATE\n");
		fprintf(RIS_RAP, "stmt_id:0x%x\n", stmt_id);
		if (stmt_id)
		{
			fprintf(RIS_RAP, "*stmt_id:%d\n", *stmt_id);
		}
		 /* 1996.07.10:Alan Barksdale:TR439601444 */
		new_query = (char *)RIScom_sys_malloc(strlen(query) +1);
		DisguisePasswords(query, new_query);
		fprintf(RIS_RAP, "start query:\n%s\nstop query:\n", new_query);
		RIScom_sys_free(new_query);
		fprintf(RIS_RAP, "in_sqlda:0x%x\n", in_sqlda);
		RISXrap_print_input_sqlda(RIS_RAP, in_sqlda);
		fprintf(RIS_RAP, "execute_mode:%d\n", execute_mode);
		fprintf(RIS_RAP, "clear_flag:%d\n", clear_flag);
		fprintf(RIS_RAP, "static_flag:%d\n", static_flag);
	RISrap_enter_END();

   	if (!RIS_mem)
	{
		int sts;

		if ((sts = SETJMP()) == 0 )
		{
       		RISapp_initialize(getenv("RIS_LANGUAGE"));
			RESETJMP();
		}
		else
		{
			RESETJMP();
			SET_RISCA(sts);
			RISrap_return_BEGIN();
				fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
			RISrap_return_END();
			RIS_RETURN();
		}
	}

	if (IN_START_MODE(execute_mode))
	{
		/*
		**	if MAX_STATIC_STMTS in parameters file equals to 0,
		**	reprepare static statements everytime.
		*/
		if (static_flag == RIS_STATIC_STMT &&
			clear_flag == RIS_DONT_CLEAR_FLAG &&
			RIS_parms.max_static_stmts == 0)
		{
    		clear_flag = RIS_CLEAR_FLAG;
		}

    	RISXint_prepare(stmt_id, query, clear_flag, static_flag);
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

			RIS_async->state = EXECUTE_IMM_STATE;
			RIS_async->args.execute_imm.stmt_idp = stmt_id;
			RIS_async->args.execute_imm.in_sqlda = in_sqlda;
			RIS_async->args.execute_imm.clear_flag = clear_flag;
			RIS_async->args.execute_imm.static_flag = static_flag;

			len = strlen(query) + 1;
			RIS_async->rissqlstmt = ALLOCBA(RIS_async->async_id, len);
			memcpy(RIS_async->rissqlstmt, query, len);

			RESETJMP();
		}
	}

	if (IN_START_OR_FINISH_MODE(execute_mode))
	{
    	RISXint_execute(stmt_id, async_id, in_sqlda, (unsigned char)execute_mode,
			clear_flag, static_flag);
		if (IN_START_MODE_ONLY(execute_mode))
		{
			if (RIS_ERRCODE != RIS_SUCCESS)
			{
    			if (clear_flag == RIS_CLEAR_FLAG)
				{
    				if (!RIS_client_died)
					{
						RISapp_clear(stmt_id,DONT_SET_SQLCODE,CLEAR_CLIENT,
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
    		if (clear_flag == RIS_CLEAR_FLAG)
			{
    			if (!RIS_client_died)
				{
					RISapp_clear(stmt_id,DONT_SET_SQLCODE,CLEAR_CLIENT,
						SYNC_MODE);
				}
			}
		}
	}

	INT_DBG(("RISint_execute_immediate:complete\n"));

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
