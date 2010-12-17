/* Do not alter this SPC information: $Revision: 1.3.52.1 $ */
/*
**	NAME:							intfetch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/87
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
	
	BLOB support:

		1)	We 1st locate the blob columns in START MODE , if no blob 
			involved we shall stick to the old way of doing fetch.				

		2)  The blob file names are sent to client for fetching. Sever
			will use the file names to locate the files if app, client
			and server are all on one node and files are used. We only
			fetch one row at a time if blob is involved.

		3)  In FINISH MODE, after the non blob data is put into the user 
			variables, we will fetch blob data in chunks. This should be 
			done in SYNC_MODE. In the case a local file is used, the blob 
			data should have been in place in the files therefore no  
			further action is necessary. 	



													James Chang
													6/1993

*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "intrface.h"
#include "risasync.h"
#include "riscom.h"
/****** RIS_BLOB *******/
#include "errno.h"
#include <fcntl.h>
/****** RIS_BLOB *******/
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
#define intfetch_c
#include "appasync.prt"
#include "appblob.prt"
#include "appbufto.prt"
#include "appclear.prt"
#include "appparms.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intfetch.prt"
#include "intrap.prt"
#include "sys.prt"
/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_fetch(
	short	stmt_id,
	int		*async_id,
	sqlda	*output,
	int		one_row_only,
	unsigned char		execute_mode)
{
	int				len;
	int				status;
	unsigned int	fetch_count;
    /*********   RIS_BLOB *********/
    unsigned char *blob_infos=0x0;
    unsigned char blob_involved=0x0;
    ris_app_stmt *dbg_stmt;
    /*********   RIS_BLOB *********/


	INT_DBG(("RISint_fetch(stmt_id:%d async_id:0x%x output:%x one_row_only:%d "
		"execute_mode:%s)\n", stmt_id, async_id, output, one_row_only, 
		RIScom_get_execute_mode_name(execute_mode)));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "FETCH\n");
		if (RISXrap_compare_fetch(stmt_id, output, one_row_only))
		{
			fprintf(RIS_RAP, "stmt_id:%d\n", stmt_id);
			fprintf(RIS_RAP, "output:0x%x\n", output);
			RISXrap_print_output_sqlda(RIS_RAP, output);
			fprintf(RIS_RAP, "one_row_only:%d\n", one_row_only);

		}
		else
		{
			fprintf(RIS_RAP, "DITTO\n");
		}
		fprintf(RIS_RAP, "execute_mode:%d\n", execute_mode);
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
	if (stmt_id < 0 || stmt_id >= RIS_MAX_STMTS || !RIS_stmts[stmt_id])
	{
		SET_RISCA(RIS_E_INV_STMTID);
		RISrap_return();
		RIS_RETURN();
	}

	RIS_current_stmt_id = stmt_id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];
    dbg_stmt=RIS_stmt;

	/*
	**	return an error if the cursor is not open
	*/
	if (!RIS_stmt->fetch_buf)
	{
		SET_RISCA(RIS_E_CURSOR_NOT_OPEN);
		RISrap_return();
		RIS_RETURN();
	}

#if defined(WIN32)
	if (ODBCDLL)
	{
		if(!output)
		{
			if (IN_FINISH_MODE(execute_mode))
			{
				if (RIS_stmt->row_count == 0 && RIS_stmt->end_of_data == 0)
				{
					/* For very first fetch do not anything */
				}
				else
				{
					/* Increment internal row count */
					RISapp_move_to_next_row();
				}
			}
		}
	}
	else
#endif
	{
		/*
		**	return an error if there is no place to put the results
		*/
		if (!output)
		{
			SET_RISCA(RIS_E_NOT_ENOUGH_SQLVARS);
			RISrap_return();
			RIS_RETURN();
		}
	}

	/*
	**	Check the state
	*/
	if (RIS_int_level == 1 && IN_START_MODE(execute_mode) && RIS_stmt->async &&
		IN_INCOMPLETE_STATE(RIS_stmt->async->state))
	{
		SET_RISCA(RIS_E_ALREADY_EXECUTING);
		RISrap_return();
		RIS_RETURN();
	}

	if (IN_START_MODE_ONLY(execute_mode))
	{
		*async_id = -1;
	}
	if ((status = SETJMP()) != 0)
	{
		RESETJMP();
		if (IN_START_MODE_ONLY(execute_mode))
		{
			RISapp_clear_async(async_id, DONT_SET_SQLCODE);
		}
		SET_RISCA(status);
		RISrap_return();
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
		RIS_async->state = FETCH_STATE;
		RIS_async->args.fetch.output = output;
		RIS_async->args.fetch.one_row_only = one_row_only;

		len = strlen(RIS_stmt->query) + 1;
		RIS_async->rissqlstmt = ALLOCBA(RIS_async->async_id, len);
		memcpy(RIS_async->rissqlstmt, RIS_stmt->query, len);
	}

	INT_DBG(("RISint_fetch: row_count:%d end_of_data:%s\n",
		RIS_stmt->row_count, RIS_stmt->end_of_data ? "YES" : "NO"));

	if (RIS_stmt->row_count == 0)
	{
		if (RIS_stmt->end_of_data)
		{
			/*
			**	Nothing to do in start mode
			*/

			if (IN_FINISH_MODE(execute_mode))
			{
#ifdef ROW_COUNT_SUPPORTED
				risca->sqlerrd[2] = RIS_stmt->num_rows;
#endif
				INT_DBG(("RISint_fetch: complete(END OF DATA)\n"));
				LONGJMP(END_OF_DATA);
			}
		}
		else
		{
			
            if (IN_START_MODE(execute_mode))
            {
                fetch_count = (RIS_stmt->fetch_buf_size -
                    (int)&(((ris_cliapp_buf *)0)->buf.fetch.data)) /
                    RIS_stmt->output_len;
                INT_DBG(("RISint_fetch: fetching buffer: fetch_count:%d\n",
                    fetch_count));

				status = SETJMP();

				if (status)
				{
					RESETJMP();
					LONGJMP(status);
				}					
				else
				{

    				blob_involved=RISapp_locate_blob_column(
								output,
								RIS_stmt->output,	
								0,
								&blob_infos);
					 RESETJMP();
				}

    			if (blob_involved)
    			{
					/*
					** The app_cli network buffer now looks like this
					**
					+----------------+-----------+--------------+--------------+--
					|                |           |         |    |         |    |
					|structure header|blob fields|file name|null|file name|null| ...
					|                |           |         |    |         |    |
					+----------------+-----------+--------------+--------------+--
					**
					** So, the RIS_write_len has to be recalculated.
					** Surjit (Dec.28, 1994)
					**
					** But, once it is calculated, it gets overwritten in
					** RISapp_fetch_to_buf(), which follows. So we need to
					** save this value. Also we cannot call RISapp_fetch_to_buf()
					** first, because architecture conversion takes place in there
					** and out_data and file_names lose their original values.
					**
					** Surjit (Jan 9, 1995)
		   			*/

					int hold_RIS_write_len =
						(int)&(((ris_appcli_buf *)0)->buf.fetch.data) +
						RIS_write->buf.fetch.file_names + 
						RIS_write->buf.fetch.out_data ;

					INT_DBG(("RISint_fetch: RIS_write_len (HOLD) = <%d>\n",
							  hold_RIS_write_len));

					/* only one row at a time for blob */
        			RISapp_fetch_to_buf(1, execute_mode);

					RIS_write_len = hold_RIS_write_len;
					INT_DBG(("RISint_fetch: RIS_write_len (RESET) = <%d>\n",
							  hold_RIS_write_len));

				} /* if blob_involved */
				else
				{
					RISapp_fetch_to_buf(fetch_count, execute_mode);
				}
		 	} /* start mode */

			if (IN_FINISH_MODE_ONLY(execute_mode))
			{
				RISapp_fetch_to_buf(0, execute_mode);
			}

			if (IN_START_OR_FINISH_MODE(execute_mode))
			{
				RISapp_send_rec();
			}

			if (IN_FINISH_MODE(execute_mode))
			{
				RISapp_buf_to_fetch();

#ifdef ROW_COUNT_SUPPORTED
				stmt->num_rows = risca->sqlerrd[2];
#endif
				INT_DBG(("RISint_fetch:after fetching: row_count:%u "
					"end_of_data:%s\n", RIS_stmt->row_count,
					RIS_stmt->end_of_data ? "YES" : "NO"));

				if (RIS_stmt->row_count == 0) /* assume end_of_data == 1 */
				{
					INT_DBG(("RISint_fetch: complete(END OF DATA)\n"));
					LONGJMP(END_OF_DATA);
				}

				if (one_row_only && RIS_stmt->row_count > 1)
				{
					LONGJMP(RIS_E_TOO_MANY_ROWS);
				}
			} 
		} /* row count 0 */
	} /* Finish mode */
	else
	{
		/*
		**	nothing to do in start mode
		*/

		if (IN_FINISH_MODE(execute_mode))
		{
#ifdef ROW_COUNT_SUPPORTED
			risca->sqlerrd[2] = RIS_stmt->num_rows;
#endif
		}
	}

	if (IN_FINISH_MODE(execute_mode))
	{
		INT_DBG(("RISint_fetch: copying data to user variables\n")); 
		/******      BLOB  *****/ 
		INT_DBG(("blob_to_follow :%s\n",(RIS_read->buf.fetch.blob_to_follow)
				? "YES": "NO"));
		/******      BLOB  *****/
		RISapp_adjust_parms(RIS_stmt->output, RIS_stmt->row);

#if defined(WIN32)
		if (ODBCDLL && !output)
		{
			/* Skip  */
		}
		else	
#endif
		{	
			/* output sqlvar were provided */

			/* This will copy all non-blob columns data to user variables */
			RISapp_process_parms(RIS_stmt->output, output, OUTPUT);

			/****
	
				BLOB 
			 	Extra work required 
	
			 	It should all be done in SYNC_MODE
	
					If all 3 processes (app, cli, and server)
					are on same node, and files are used for all
					blob columns , the blob_to_follow would have 
					been set to 0.
	
			****/	
	
			/* This will copy all blob columns data to user variables */
			if (blob_involved && RIS_read->buf.fetch.blob_to_follow)	
			{
				status = SETJMP();
	
				if (!status)
				{
					RISapp_fetch_all_blob_columns(
						output,
						RIS_stmt->output,
						blob_infos);			
				}
	
				RESETJMP();
	
				if (status)
				{
					LONGJMP(status);
				}
			}	

			/* Increment internal row count */
			RISapp_move_to_next_row();
		} 

	} /* FINISH MODE */

	RESETJMP();

	INT_DBG(("RISint_fetch: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return_BEGIN();
		if (IN_START_MODE_ONLY(execute_mode))
		{
			fprintf(RIS_RAP, "async_id:%d\n", *async_id);
		}
	RISrap_return_END();
	RIS_RETURN();
}

/******************************************************************************/

