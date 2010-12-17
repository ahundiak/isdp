/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intexec.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**		The function that handles execute statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "intrface.h"
#include "risasync.h"
#include "riscom.h"
#include "rissttyp.h"
#include "risflags.h"
#include "errno.h"
#if defined(DOS)
#include <io.h>
#endif



/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intexec_c
#include "appasync.prt"
#include "appbufto.prt"
#include "appblob.prt"
#include "appcrsr.prt"
#include "appclear.prt"
#include "apptobuf.prt"
#include "appsndrc.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comstmt.prt"
#include "comjmp.prt"
#include "intexec.prt"
#include "interror.prt"
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

extern void RISAPI RISXint_execute(
	short	*stmt_id,
	int		*async_id,
	sqlda	*in_sqlda,
	unsigned char		execute_mode,
	int		clear_flag,
	int		static_flag)
{
	int			sts;
	int			len;
	char 		*temp_query;

	/******** BLOB *********/	
	int blob_count = 0;
	/* We allow more than one blob/text col. An array is used to
		put all blob info */ 
    unsigned char *blob_infos=0;
	/*   blobinfo :

		0 1 2 3 4 5 6 7
		  | | | | |	| |	
		  | | |     | |  
		  | | |     |  ---  1 more_to_follow	
		  | | |		|	
		  | | |		------  1 more_blob_col  
		  | | ---  1 mem used 	
		  | |	
		  | | 
		  | --- 1 fileused	
		  |	
		  --- 0 input (insert, update)
			    1 output (fetch)
	*/

    ris_app_stmt *dbg_stmt;
	/******** BLOB *********/	

	INT_DBG(("RISint_execute(stmt_id:0x%x async_id:0x%x in_sqlda:0x%x "
		"execute_mode:%s clear_flag:%d static_flag:%d)\n", stmt_id, async_id,
		in_sqlda, RIScom_get_execute_mode_name(execute_mode), clear_flag,
		static_flag));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "EXECUTE\n");
		fprintf(RIS_RAP, "stmt_id:%d\n", *stmt_id);
		fprintf(RIS_RAP, "in_sqlda:0x%x\n", in_sqlda);
		RISXrap_print_input_sqlda(RIS_RAP, in_sqlda);
		fprintf(RIS_RAP, "execute_mode:%d\n", execute_mode);
		fprintf(RIS_RAP, "clear_flag:%d\n", clear_flag);
		fprintf(RIS_RAP, "static_flag:%d\n", static_flag);
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
	if (*stmt_id < 0 || *stmt_id >= (short)RIS_max_stmts || 
		!RIS_stmts[*stmt_id])
	{
		SET_RISCA(RIS_E_INV_STMTID);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	RIS_current_stmt_id = *stmt_id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];
    dbg_stmt=RIS_stmt;

	/*
	**	Check the state
	*/
	if (RIS_int_level == 1 && IN_START_MODE(execute_mode) &&
		RIS_stmt->async && IN_INCOMPLETE_STATE(RIS_stmt->async->state))
	{
		SET_RISCA(RIS_E_ALREADY_EXECUTING);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (RIS_int_level == 1 && IN_START_MODE_ONLY(execute_mode)
		&& IN_START_MODE(execute_mode))
	{
		*async_id = -1;
	}
	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (sts != STATEMENT_NOT_COMPLETE)
		{
			if (!SETJMP())
			{
				RISapp_close_cursor(RIS_current_stmt_id);
			}
			RESETJMP();

			if (RIS_int_level == 1 && IN_START_MODE_ONLY(execute_mode))
			{
				RISapp_clear_async(async_id, DONT_SET_SQLCODE);
			}
		}

		SET_RISCA(sts);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (IN_START_MODE(execute_mode))
	{
		if (RISstmt_debug)
		{
			RIScom_output_debug("\nSQL Query:\n");
			RIScom_output_debug("%s\n\n", RIS_stmt->query ? RIS_stmt->query : "NULL");
		}

		if (RIScom_default_schema_required(RIS_stmt->stmt_type))
		{
			INT_DBG(("RISint_exec: RIS_stmt->prep_def_schname:<%s> "
				"RIS_def_schname:<%s>\n", STRING(RIS_stmt->prep_def_schname),
					STRING(RIS_def_schname)));

			if (!RIS_def_schname[0])
			{
				LONGJMP(RIS_E_NO_DEFAULT);
			}

			if (static_flag == RIS_STATIC_STMT &&
				clear_flag == RIS_DONT_CLEAR_FLAG)
			{
				if (strcmp(RIS_stmt->prep_def_schname, RIS_def_schname))
				{
					len = strlen(RIS_stmt->query);
					temp_query = (char *) SYS_CALLOC(len, sizeof(char));
					strcpy(temp_query, RIS_stmt->query);
					RISapp_clear(stmt_id, DONT_SET_SQLCODE, CLEAR_CLIENT,
						SYNC_MODE);
					RISXint_prepare(stmt_id,temp_query,clear_flag,static_flag);
					SYS_FREE(temp_query);
					if (RIS_ERRCODE != RIS_SUCCESS)
					{
						RESETJMP();
						INT_DBG(("RISint_execute:prepare failed:returning\n"));
						RISrap_return_BEGIN();
							fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
						RISrap_return_END();
						RIS_RETURN();
					}
				}
			}
			else  /* Dynamic Stmt */
			{
				if (strcmp(RIS_stmt->prep_def_schname, RIS_def_schname))
				{
					LONGJMP(RIS_E_DIFF_DEFAULT_AT_PREP_N_EXEC);
				}
			}
		}

		if (RIS_int_level == 1 && IN_START_MODE_ONLY(execute_mode))
		{
			/*
			** Allocate async struct here.
			*/
			*async_id = RISapp_new_async();
	
			RIS_stmt->async = RIS_async;
	
			RIS_async->stmt = RIS_stmt;
			RIS_async->stmt_id = RIS_current_stmt_id;
			RIS_async->state = EXECUTE_STATE;
			RIS_async->args.execute.in_sqlda = in_sqlda;
			RIS_async->args.execute.clear_flag = clear_flag;
			RIS_async->args.execute.static_flag = static_flag;
	
			len = strlen(RIS_stmt->query) + 1;
			RIS_async->rissqlstmt = ALLOCBA(RIS_async->async_id, len);
			memcpy(RIS_async->rissqlstmt, RIS_stmt->query, len);
		}

		switch(RIS_stmt->stmt_type)
		{
			case RIS_DROP_INDEX_STMT:
				clear_static_stmts_referencing_schema(RIS_current_stmt_id);

				/*
				** These may have been cleared, so reset them.
				*/
				RIS_current_stmt_id = *stmt_id;
				RIS_stmt = RIS_stmts[RIS_current_stmt_id];
				break;

			case RIS_DROP_TABLE_STMT:
			case RIS_DROP_VIEW_STMT:
			case RIS_ALTER_TABLE_STMT:
			case RIS_CREATE_INDEX_STMT:
				clear_static_stmts_referencing_tab(RIS_current_stmt_id);

				/*
				** These may have been cleared, so reset them.
				*/
				RIS_current_stmt_id = *stmt_id;
				RIS_stmt = RIS_stmts[RIS_current_stmt_id];
				break;

			default:
				break;
		}

		if (RIS_stmt->input && !in_sqlda)
		{
			LONGJMP(RIS_E_NOT_ENOUGH_SQLVARS);
		}

		/*
		**	Allocate the cursor if needed
		*/
		if (RIS_stmt->fetch_buf_size > 0 && !RIS_stmt->fetch_buf)
		{
			RISapp_alloc_cursor(RIS_current_stmt_id);
		}


		blob_count=RISapp_locate_blob_column(
				in_sqlda, 		
				RIS_stmt->input,
				1,
				&blob_infos);
		/*
		 *	Load the buffer 	
		 */


		if (blob_count > 0)
		{
			/* There is a blob column involved */

			/* the info. packed in blobinfo
			** the bites (l. to r. ) 			
			**
			**	high 4 bites ----  1 if a file is used.
			**	low  4 bites ----  1 if more to follow.
			*/

			RISapp_execute_to_buf(in_sqlda, execute_mode);

			/* 	All non blob  sqlvar will be sent first. */ 

			RIS_write->opcode = RISCLI_EXEC_DEFERRED_CODE;		

			RISapp_send_rec();
			RISapp_load_all_blob_columns(	
				in_sqlda, 		
				RIS_stmt->input,
				blob_infos,
				blob_count,
				execute_mode);

		} /********************  BLOB *********************/
		else
		RISapp_execute_to_buf(in_sqlda, execute_mode);
	}
	else if (IN_FINISH_MODE_ONLY(execute_mode))
	{
		/*
		**	Load the buffer with just the opcode
		*/
        if (! blob_count)
        RISapp_opcode_to_buf(RISCLI_EXECUTE_CODE, execute_mode);
        else
        RISapp_opcode_to_buf(RISCLI_EXEC_DEFERRED_CODE, execute_mode);
	}

  
    if (!blob_count)
    {
     /* If no blob involved send the opcode for both start and finish */
           if (IN_START_OR_FINISH_MODE(execute_mode))
           {
             RISapp_send_rec();
           }
    }
    else
    {
         /* blob involved ,
            Start mode opcode already been sent.
            Finish mode opcode , is yet to be sent.
            It is really for ASYNC mode */
   		if (IN_FINISH_MODE_ONLY(execute_mode))
                RISapp_send_rec();
    }

 


	if (IN_FINISH_MODE(execute_mode))
	{
		/*
		**	Finish mode
		*/
		RISapp_buf_to_execute();
	}

	RESETJMP();

	INT_DBG(("RISint_execute: complete\n"));

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

static void clear_static_stmts_referencing_tab(
	short	stmt_id)
{
	int				i;
	short			id;
	short			temp_id;
	char			*schname;
	char			*tabname;
	ris_app_stmt	*stmt;

	INT_DBG(("clear_static_stms_referencing_tab(stmt_id:%d)\n", stmt_id));
	
	stmt = RIS_stmts[stmt_id];
	if (!stmt->schname[0])
	{
		INT_DBG(("RISint_exec: error: stmt->schname[0] == 0\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	schname = stmt->schname;
	if (stmt->tab_count != 1)
	{
		INT_DBG(("RISint_exec: error: stmt->tab_count(%d) != 1\n",
			stmt->tab_count));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	tabname = stmt->tab_list[0];
	INT_DBG(("clear_static_stms_referencing_tab:tabname:<%s>\n", tabname));

	for(id = 0; id < (short)RIS_parms.max_user_stmts; id++)
	{
		if (id != stmt_id && RIS_stmts[id] && RIS_stmts[id]->timestamp &&
			!strcmp(schname, RIS_stmts[id]->schname))
		{
			INT_DBG(("it's a static stmt:%d\n",id));

			for (i = 0; i < RIS_stmts[id]->tab_count; i++)
			{
				if (!strcmp(tabname, RIS_stmts[id]->tab_list[i]))
				{
					temp_id = id;
					INT_DBG(("clear_static_stmts_referencing_tab: "
						"clearing stmt:%d\n", temp_id));
					RISapp_clear(&temp_id, DONT_SET_SQLCODE, CLEAR_CLIENT,
						SYNC_MODE);
					break;
				}
			}
		}
	}

	INT_DBG(("clear_static_stms_referencing_tab:complete\n"));
}

/******************************************************************************/

static void clear_static_stmts_referencing_schema(
	short	stmt_id)
{
	short			id;
	short			temp_id;
	char			*schname;
	ris_app_stmt	*stmt;

	INT_DBG(("clear_static_stms_referencing_schema(stmt_id:%d)\n", stmt_id));
	
	stmt = RIS_stmts[stmt_id];
	if (!stmt->schname[0])
	{
		INT_DBG(("RISint_exec: error: stmt->schname[0] == 0\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	schname = stmt->schname;
	INT_DBG(("clear_static_stms_referencing_schema:schname:<%s>\n", schname));

	for(id = 0; id < (short)RIS_parms.max_user_stmts; id++)
	{
		if (id != stmt_id && RIS_stmts[id] && RIS_stmts[id]->timestamp &&
			!strcmp(schname, RIS_stmts[id]->schname))
		{
			INT_DBG(("it's a static stmt:%d\n",id));

			temp_id = id;
			INT_DBG(("clear_static_stmts_referencing_schema: "
				"clearing stmt:%d\n", temp_id));
			RISapp_clear(&temp_id, DONT_SET_SQLCODE, CLEAR_CLIENT,
				SYNC_MODE);
		}
	}

	INT_DBG(("clear_static_stms_referencing_schema:complete\n"));
}

/******************************************************************************/
