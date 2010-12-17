/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							inttest.c
**	AUTHORS:						Sarah Byram
**	CREATION DATE:					11/91
**	ABSTRACT:
**		This function 
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risasync.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define inttest_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "intclear.prt"
#include "intclose.prt"
#include "interror.prt"
#include "intexec.prt"
#include "inteximm.prt"
#include "intfetch.prt"
#include "intrap.prt"
#include "intslct.prt"
#include "inttest.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISAPI RISXint_test_completion(
	sqlda	*desc,
	int		wait_flag)
{
	int			i,j;
	int			all_flag;
	int			any_flag;
	int			status;
	int			async_count;
	int			complete_count;
	int			incomplete_count;
	int			statement_failed;
	int			statement_eod;
	int			id;
	int			async_ids[RIS_MAX_TRANSACTIONS];
	int			complete_ids[RIS_MAX_TRANSACTIONS];
	int			incomplete_ids[RIS_MAX_TRANSACTIONS];
	risasync	*async;
	
	INT_DBG(("RISint_test_completion(desc:0x%x wait_flag:%d)\n",
		desc, wait_flag));
	
	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "TEST COMPLETION\n");
		fprintf(RIS_RAP, "desc:0x%x\n", desc);
		RISXrap_print_test_sqlda(RIS_RAP, desc);
		fprintf(RIS_RAP, "wait_flag:%d\n", wait_flag);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	status = SETJMP();
	if (status)
	{
		RESETJMP();
             SET_RISCA(status); 
		RISrap_return();
		RIS_RETURN();
	}

	async_count = 0;
	complete_count = 0;
	incomplete_count = 0;
	all_flag = 0;
	any_flag = 0;

	switch(desc->sqln)
	{
		case 0:
			LONGJMP(RIS_E_INV_ARG);

		case 1:
			if (desc->sqlvar[0].sqltype == RIS_CHARACTER)
			{
				if (!RIScom_strcmp_ic(desc->sqlvar[0].sqldata, "all"))
				{
					all_flag = 1;
				}
				else if (!RIScom_strcmp_ic(desc->sqlvar[0].sqldata, "any"))
				{
					any_flag = 1;
				}
				else
				{
					LONGJMP(RIS_E_INV_ARG);
				}

				for (id = 0; id < RIS_MAX_TRANSACTIONS; id++)
				{
					if (RIS_asyncs[id] && IN_ASYNC_STATE(RIS_asyncs[id]->state))
					{
						async_ids[async_count++] = id;
						if (IN_COMPLETE_STATE(RIS_asyncs[id]->state))
						{
							complete_ids[complete_count++] = id;
						}
						if (IN_INCOMPLETE_STATE(RIS_asyncs[id]->state))
						{
							incomplete_ids[incomplete_count++] = id;
						}
					}
				}
				break;
			}

			/* no break; */

		default:
			for (i = 0; i < desc->sqln; i++)
			{
				INT_DBG(("RISint_test_completion: checking sqlvar[%d]\n", i));
		
				if (desc->sqlvar[i].sqltype != RIS_INTEGER)
				{
					LONGJMP(RIS_E_INV_ARG);
				}

				id = *(int *)desc->sqlvar[i].sqldata;

				INT_DBG(("RISint_test_completion: id:%d\n", id));

				if (id < 0 || id >= RIS_MAX_TRANSACTIONS ||
					!RIS_asyncs[id])
				{
					LONGJMP(RIS_E_INV_ASYNC_ID);
				}

				if (IN_ASYNC_STATE(RIS_asyncs[id]->state))
				{
					/*
					**	Check if id is already in async_ids
					*/
					for (j = 0; j < async_count; j++)
					{
						if (async_ids[j] == id) break;
					}
					if (j == async_count)
					{
						/*
						**	id wasn't is async_ids so put it in
						*/
						async_ids[async_count++] = id;
						if (IN_COMPLETE_STATE(RIS_asyncs[id]->state))
						{
							complete_ids[complete_count++] = id;
						}
						if (IN_INCOMPLETE_STATE(RIS_asyncs[id]->state))
						{
							incomplete_ids[incomplete_count++] = id;
						}
					}
				}
			}
		
			/*
			** This can be treated just as an all flag
			*/
			all_flag = 1;

			break;
	}

	INT_DBG(("RISint_test_completion:async_count:%d complete_count:%d "
		"incomplete_count:%d\n", async_count, complete_count,incomplete_count));

	if (async_count == 0)
	{
		LONGJMP(RIS_E_ASYNC_STMT_NOT_SPEC);
	}
	if (complete_count + incomplete_count != async_count)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (any_flag)
	{
		if (complete_count)
		{
			async = RIS_asyncs[complete_ids[0]];
			switch(async->state)
			{
				case COMPLETE_ERROR_STATE:
					async->state = 0;
					LONGJMP(STATEMENT_FAILED);

				case COMPLETE_EOD_STATE:
					async->state = 0;
					LONGJMP(END_OF_DATA);

				case COMPLETE_SUCCESS_STATE:
					async->state = 0;
					RESETJMP();

					INT_DBG(("RISint_test_completion:returning\n"));

					SET_RISCA(RIS_SUCCESS);
					RISrap_return();
					RIS_RETURN();
			}

			INT_DBG(("RISint_test_completion: invalid async state:%d, "
				"expected a complete state\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		else
		{
			do
			{
				for (i = 0; i < incomplete_count; i++)
				{
					async = RIS_asyncs[incomplete_ids[i]];
					test_completion(async, 0);
					if (IN_COMPLETE_STATE(async->state))
					{
						switch(async->state)
						{
							case COMPLETE_ERROR_STATE:
								async->state = 0;
								RIS_CLEAR_ERROR();
								LONGJMP(STATEMENT_FAILED);
	
							case COMPLETE_EOD_STATE:
								async->state = 0;
								RIS_CLEAR_ERROR();
								LONGJMP(END_OF_DATA);

							case COMPLETE_SUCCESS_STATE:
								async->state = 0;
								RESETJMP();

								INT_DBG(("RISint_test_completion:returning\n"));

								SET_RISCA(RIS_SUCCESS);
								RISrap_return();
								RIS_RETURN();
						}

						INT_DBG(("RISint_test_completion: invalid async "
							"state:%d, expected a complete state\n"));
							LONGJMP(RIS_E_INTERNAL_ERROR);
					}
				}
			} while(wait_flag);

			RIS_CLEAR_ERROR();
			LONGJMP(STATEMENT_NOT_COMPLETE);
		}
	}
	else
	{
		/*
		**	 All flag
		*/
		do
		{
			for (i = 0; i < incomplete_count; )
			{
				async = RIS_asyncs[incomplete_ids[i]];
				test_completion(async, 0);
				if (IN_COMPLETE_STATE(async->state))
				{
					/*
					**	The statement completed, so remove it from the ids array
					**	and decrement the incomplete count.
					*/
					for (j = i; j < incomplete_count - 1; j++)
					{
						incomplete_ids[j] = incomplete_ids[j+1];
					}
					incomplete_count--;
				}
				else
				{
					i++;
				}
			}
		} while(wait_flag && incomplete_count);

		if (incomplete_count)
		{
			INT_DBG(("RISint_test_completion: statement not complete\n"));
		
			RIS_CLEAR_ERROR();
			LONGJMP(STATEMENT_NOT_COMPLETE);
		}

		statement_failed = 0;
		statement_eod = 0;
		for (i = 0; i < async_count; i++)
		{
			async = RIS_asyncs[async_ids[i]];
			switch(async->state)
			{
				case COMPLETE_ERROR_STATE:
					statement_failed = 1;
					break;

				case COMPLETE_EOD_STATE:
					statement_eod = 1;
					break;

				case COMPLETE_SUCCESS_STATE:
					break;
				
				default:
					INT_DBG(("RISint_test_completion: invalid async state:%d,"
						"expected a complete state\n"));
					LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			async->state = 0;
		}

		if (statement_failed)
		{
			INT_DBG(("RISint_test_completion: statement failed\n"));
			RIS_CLEAR_ERROR();
			LONGJMP(STATEMENT_FAILED);
		}
		if (statement_eod)
		{
			INT_DBG(("RISint_test_completion: statement returned eod\n"));
			RIS_CLEAR_ERROR();
			LONGJMP(END_OF_DATA);
		}
	}

	RESETJMP();

	INT_DBG(("RISint_test_completion: returning\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

static void test_completion(
	risasync *async,
	int wait_flag)
{
	int len;
	int	sts;
	unsigned char	execute_mode;

	INT_DBG(("test_completion(async:0x%x wait_flag:%d)\n", async, wait_flag));

	RIS_test_completion_flag = 1;

	execute_mode = 
		(wait_flag) ? (unsigned char)ASYNC_WAIT_MODE : 
					  (unsigned char)ASYNC_TEST_MODE;

	switch(async->state)
	{
		case SELECT_INTO_STATE:
		{
			RISXint_select(&async->stmt_id, &async->async_id,
				async->rissqlstmt, 
				async->args.select_into.in_sqlda, 
				async->args.select_into.out_sqlda, 
				execute_mode);
		}
		break;

		case EXECUTE_IMM_STATE:
		{
			RISXint_execute_immediate(&async->stmt_id, &async->async_id,
				async->rissqlstmt, 
				async->args.execute_imm.in_sqlda, execute_mode,
				async->args.execute.clear_flag,
				async->args.execute.static_flag);
		}
		break;

		case EXECUTE_STATE:
		{
			RISXint_execute(&async->stmt_id, &async->async_id,
				async->args.execute.in_sqlda, execute_mode,
				async->args.execute.clear_flag,
				async->args.execute.static_flag);
		}
		break;
		
		case FETCH_STATE:
		{
			RISXint_fetch(async->stmt_id, &async->async_id,
				async->args.fetch.output, async->args.fetch.one_row_only,
				execute_mode);
		}
		break;

		case CLOSE_STATE:
		{
			RISXint_close(async->stmt_id, &async->async_id, execute_mode);
		}
		break;

		case CLEAR_STATE:
		{
			RISXint_clear(async->args.clear.stmt_idp, &async->async_id,
				execute_mode);
		}
		break;

		default:
		{
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}

	switch(RIS_ERRCODE)
	{
		case RIS_SUCCESS:
			async->state = COMPLETE_SUCCESS_STATE;

			memset(&async->risca, 0, sizeof(rissqlca));
			memset(&async->dbca, 0, sizeof(rissqlca));
			async->risca.sqlcode = RIS_SUCCESS;
			async->risca.sqlstmt = async->rissqlstmt;
			break;

		case END_OF_DATA:
			async->state = COMPLETE_EOD_STATE;

			memset(&async->risca, 0, sizeof(rissqlca));
			memset(&async->dbca, 0, sizeof(rissqlca));
			async->risca.sqlcode = END_OF_DATA;
			async->risca.sqlstmt = async->rissqlstmt;
			break;

		case STATEMENT_NOT_COMPLETE:

			memset(&async->risca, 0, sizeof(rissqlca));
			memset(&async->dbca, 0, sizeof(rissqlca));
			async->risca.sqlcode = STATEMENT_NOT_COMPLETE;
			async->risca.sqlstmt = async->rissqlstmt;
			break;

		default:
			if (RIS_test_completion_flag)
			{
				/*
				**	If test completion error longjmp
				*/
				sts = RIS_ERRCODE;
				RIS_CLEAR_ERROR();
				LONGJMP(sts);
			}
			else
			{
				async->state = COMPLETE_ERROR_STATE;

				/*
				**	If not test completion error, change error to stmt failed.
				*/
				if ((len = strlen(dbca->sqlstmt)) > 0)
				{
					len++;
					async->dbsqlstmt = ALLOCBA(async->async_id, len);
					memcpy(async->dbsqlstmt, dbca->sqlstmt, len);
				}

				memcpy(&async->risca, risca, sizeof(struct rissqlca));
				memcpy(&async->dbca, dbca, sizeof(struct rissqlca));
				async->risca.sqlstmt = async->rissqlstmt;
				async->dbca.sqlstmt = async->dbsqlstmt;

				RIS_CLEAR_ERROR();
				SQLCODE = STATEMENT_FAILED;
				RIS_ERRCODE = STATEMENT_FAILED;
			}
			break;
	}
	INT_DBG(("test_completion: complete.\n"));
}

/******************************************************************************/
