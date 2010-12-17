/*
**	NAME:							intshapp.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					02/86
**	ABSTRACT:
**		The functions that print application info.
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
#include "ris_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intshapp_c
#include "comdebug.prt"
#include "comoutpt.prt"
#include "comsttyp.prt"
#include "comumsg.prt"
#include "intshapp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_show_app_memory(
	int	(* output_func)(const char *, ...))
{
	int				i;
	ris_alloc_info	*mem;
	ris_block_info	*tempblock;

	INT_DBG(("RISint_show_app_memory()\n"));

	output_func("\n %s \n", RIScom_umsg(RIS_I_APPLICATION_MEM));
	if (!RIS_mem)
	{
		output_func("%s \n", RIScom_umsg(RIS_I_NOT_ALLOCATED));
		return;
	}

	output_func("RIS_mem:0x%x\n", RIS_mem);

	output_func("\n%s\n", RIScom_umsg(RIS_I_STMT_MEMORY));
	for (i = 0;i < (int)RIS_max_stmts; i++)
	{
		if (RIS_mem->statement[i].blk)
		{
			mem = &RIS_mem->statement[i];

			output_func("\n\t%s%d\n", RIScom_umsg(RIS_I_STMT_ID), i);
			RIScom_output_alloc_info(output_func, mem, 1);
			output_func("\t%s\n", RIScom_umsg(RIS_I_ALLOC_BLK_LIST));
			for (tempblock=mem->blk;tempblock;tempblock=tempblock->next)
			{
				output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_ALLOC_BLK), 
						tempblock);
				RIScom_output_block_info(output_func, tempblock, 3);
			}
		}
	}

	output_func("\n%s\n", RIScom_umsg(RIS_I_ASYNC_STMT_MEM));
	for (i = 0;i < RIS_MAX_TRANSACTIONS; i++)
	{
		if (RIS_mem->async[i].blk)
		{
			mem = &RIS_mem->async[i];

			output_func("\n\t%s%d\n",RIScom_umsg(RIS_I_ASYNC_STMT_ID), i);
			RIScom_output_alloc_info(output_func, mem, 1);
			output_func("\t%s\n", RIScom_umsg(RIS_I_ALLOC_BLK_LIST));
			for (tempblock=mem->blk;tempblock;tempblock=tempblock->next)
			{
				output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_ALLOC_BLK),
						tempblock);
				RIScom_output_block_info(output_func, tempblock, 3);
			}
		}
	}

	output_func("\n%s\n", RIScom_umsg(RIS_I_SCHEMA_MEMORY));
	for (i = 0;i < RIS_MAX_OPEN_SCHEMAS; i++)
	{
		if (RIS_mem->schema[i].blk)
		{
			mem = &RIS_mem->schema[i];

			output_func("\n\t%s%d\n",RIScom_umsg(RIS_I_SCHEMA_ID), i);
			RIScom_output_alloc_info(output_func, mem, 1);
			output_func("\t%s\n", RIScom_umsg(RIS_I_ALLOC_BLK_LIST));
			for (tempblock=mem->blk;tempblock;tempblock=tempblock->next)
			{
				output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_ALLOC_BLK),
						tempblock);
				RIScom_output_block_info(output_func, tempblock, 3);
			}
		}
	}

	output_func("\n%s\n", RIScom_umsg(RIS_I_SUPERSCH_MEMORY));
	for (i = 0;i < RIS_MAX_OPEN_SUPERSCHEMAS; i++)
	{
		if (RIS_mem->sschema[i].blk)
		{
			mem = &RIS_mem->sschema[i];

			output_func("\n\tsschema id:%d\n",i);
			output_func("\n\t%s%d\n", RIScom_umsg(RIS_I_SUPERSCH_ID), i);
			RIScom_output_alloc_info(output_func, mem, 1);
			output_func("\t%s\n", RIScom_umsg(RIS_I_ALLOC_BLK_LIST));
			for (tempblock=mem->blk;tempblock;tempblock=tempblock->next)
			{
				output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_ALLOC_BLK),
							tempblock);
				RIScom_output_block_info(output_func, tempblock, 3);
			}
		}
	}

	output_func("\n%s\n", RIScom_umsg(RIS_I_PERM_MEMORY));
	if (RIS_mem->permanent.blk)
	{
		mem = &RIS_mem->permanent;

		RIScom_output_alloc_info(output_func, mem, 1);
		output_func("\t%s\n", RIScom_umsg(RIS_I_ALLOC_BLK_LIST));
		for (tempblock=mem->blk;tempblock;tempblock=tempblock->next)
		{
			output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_ALLOC_BLK),tempblock);
			RIScom_output_block_info(output_func, tempblock, 3);
		}
	}

	output_func("\n%s\n", RIScom_umsg(RIS_I_FREE_BLK_LIST));
	for (tempblock = RIS_mem->free; tempblock; tempblock = tempblock->next)
	{
		output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_FREE_BLK));
		RIScom_output_block_info(output_func, tempblock, 2);
	}

	INT_DBG(("RISint_show_app_memory:complete\n"));
}

/******************************************************************************/

extern void RISAPI RISXint_show_app_stmts(
	int (* output_func)(const char *, ...))
{
	int				i, j;
	ris_app_stmt	*stmt;

	INT_DBG(("RISint_show_app_stmts()\n"));

	output_func("\n\n%s\n", RIScom_umsg(RIS_I_APPLICATION_STMT));
	if (!RIS_mem)
	{
		output_func("%s\n", RIScom_umsg(RIS_I_NOT_ALLOCATED));
		return;
	}
	output_func("\n%s%d\n", RIScom_umsg(RIS_I_CUR_STMT_ID),RIS_current_stmt_id);

	for (i = 0; i < (int)RIS_max_stmts; i++)
	{
		if (RIS_stmts[i])
		{
			stmt = RIS_stmts[i];
			output_func("%s\n", RIScom_umsg(RIS_I_STATEMENT));
			output_func("\t%s %d%s\n", RIScom_umsg(RIS_I_STMT_ID), i,
				(i == RIS_current_stmt_id) ? " (Current statement)" : "");
			output_func("\t%s%s\n", RIScom_umsg(RIS_I_QUERY), 
					stmt->query ? stmt->query : "");
			output_func("\t%s%d\n",RIScom_umsg(RIS_I_INPUT_LEN), 
					stmt->input_len);
			output_func("\t%s%d\n",RIScom_umsg(RIS_I_OUTPUT_LEN), 
					stmt->output_len);
			output_func("\t%s%d\n",RIScom_umsg(RIS_I_FETCH_BUF_SIZE), 
					stmt->fetch_buf_size);
			output_func("\t%s%d\n",RIScom_umsg(RIS_I_WRITE_BUF_SIZE), 
					stmt->write_buf_size);

			output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_INPUT_SQLDA), 
					stmt->input);
			if (stmt->input)
			{
				output_func("\t\t%s%d ", RIScom_umsg(RIS_I_SQLN), 
						stmt->input->sqln);
				output_func("%s%d\n", RIScom_umsg(RIS_I_SQLD),
						stmt->input->sqld);
				for (j = 0; j < stmt->input->sqln; j++)
				{
					output_func("\t\t%s[%d]:0x%x\n", RIScom_umsg(RIS_I_SQLVAR),
						j, &stmt->input->sqlvar[j]);
					RIScom_output_sqlvar(output_func, &stmt->input->sqlvar[j], 
						3);
				}
				
			}

			output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_OUTPUT_SQLDA),
					stmt->output);
			if (stmt->output)
			{
				output_func("\t\t%s%d \n", RIScom_umsg(RIS_I_SQLN),
						stmt->output->sqln);
				output_func("%s%d\n", RIScom_umsg(RIS_I_SQLD),
						stmt->output->sqld);
				for (j = 0; j < stmt->output->sqln; j++)
				{
					output_func("\t\t%s[%d]:0x%x\n", RIScom_umsg(RIS_I_SQLVAR),
						j, &stmt->output->sqlvar[j]);
					RIScom_output_sqlvar(output_func, &stmt->output->sqlvar[j],
						3);
				}
				
			}

			output_func("\t%s %d\n", RIScom_umsg(RIS_I_TAB_COUNT), 
					stmt->tab_count);
			for(j = 0; j < stmt->tab_count; j++)
			{
				output_func("\t%s[%d]:<%s>\n", RIScom_umsg(RIS_I_TAB_LIST), 
					j, stmt->tab_list[j]);
			}

			output_func("\t%s%d \n", RIScom_umsg(RIS_I_ROW_COUNT), 
					stmt->row_count); 
			output_func("%s%d\n",  RIScom_umsg(RIS_I_END_OF_DAT), 
					stmt->end_of_data);
			output_func("\t%s0x%x ", RIScom_umsg(RIS_I_FETCH_BUF),
					stmt->fetch_buf);
			output_func("%s0x%x\n", RIScom_umsg(RIS_I_ROW), stmt->row);
			output_func("\t%s<%s>\n", RIScom_umsg(RIS_I_PREP_DEF_SCH),
					stmt->prep_def_schname);
			output_func("\t%s<%s>\n", RIScom_umsg(RIS_I_SCHNAME),stmt->schname);
			output_func("\t%s<%s>\n", RIScom_umsg(RIS_I_STMT_TYPE),
					RIScom_get_stmt_type_name(stmt->stmt_type));

			output_func("\t%s%d\n", RIScom_umsg(RIS_I_TIMESTAMP),
					stmt->timestamp);
			output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_STMT_ID_ADDR),
					stmt->stmt_id_addr);
			output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_ASYNC),stmt->async);
		}
	}
	INT_DBG(("RISint_show_app_stmts:complete\n"));
}

/******************************************************************************/

extern void RISAPI RISXint_show_async_stmts(
	int (* output_func)(const char *, ...))
{
	int			i;
	risasync	*async;

	INT_DBG(("RISint_show_async_stmts()\n"));

	output_func("\n\n%s\n", RIScom_umsg(RIS_I_ASYNC_STMTS));
	if (!RIS_mem)
	{
		output_func("%s\n", RIScom_umsg(RIS_I_NOT_ALLOCATED));
		return;
	}

	for (i = 0; i < (int)RIS_max_stmts; i++)
	{
		if (RIS_asyncs[i])
		{
			async = RIS_asyncs[i];
			output_func("\n%s\n", RIScom_umsg(RIS_I_ASYNC_STMT));
			output_func("\t%s%d\n", RIScom_umsg(RIS_I_ASYNC_ID), 
					async->async_id);
			output_func("\t%s%d\n", RIScom_umsg(RIS_I_STMT_ID), async->stmt_id);
			output_func("\t%s0x%x\n", RIScom_umsg(RIS_I_STMT), async->stmt);

			switch(async->state)
			{
				case 0:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_STMT_COMP));
					break;

				case EXECUTE_IMM_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_EX_IMM_ST));
					break;

				case EXECUTE_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_EX_ST));
					output_func("\t%s\n", RIScom_umsg(RIS_I_ARGS));
					output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_IN_SQLDA), 
						async->args.execute.in_sqlda);
					output_func("\t\t%s%d\n", RIScom_umsg(RIS_I_CLEAR_FLAG),
						async->args.execute.clear_flag);
					output_func("\t\t%s%d\n", RIScom_umsg(RIS_I_STATIC_FLAG),
						async->args.execute.static_flag);
					break;

				case FETCH_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_FETCH_ST));
					output_func("\t%s\n", RIScom_umsg(RIS_I_ARGS));
					output_func("\t\t%s%d\n", RIScom_umsg(RIS_I_ONE_ROW_ONLY),
						async->args.fetch.one_row_only);
					output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_OUTPUT),
						async->args.fetch.output);
					break;

				case CLOSE_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_CLOSE_ST));	
					break;

				case CLEAR_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_CLEAR_ST));	
					output_func("\t%s\n", RIScom_umsg(RIS_I_ARGS));
					output_func("\t\t%s0x%x\n", RIScom_umsg(RIS_I_STMTIDP), 
							async->args.clear.stmt_idp);
					if (async->args.clear.stmt_idp)
					{
						output_func("\t\t*%s%d\n", RIScom_umsg(RIS_I_STMTIDP),
							*async->args.clear.stmt_idp);
					}
					break;

				case COMPLETE_ERROR_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_COMP_ERR_ST));
					break;

				case COMPLETE_EOD_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_COMP_EOD_ST));
					break;

				case COMPLETE_SUCCESS_STATE:
					output_func("\t%s\n", RIScom_umsg(RIS_I_ST_COMP_SUC_ST));
					break;

				default:
					output_func("\t%s(%d)\n", RIScom_umsg(RIS_I_ST_UNKNOWN), 
						async->state);		
					break;
			}
			output_func("\t%s\n", RIScom_umsg(RIS_I_RISCA));
			RIScom_output_rissqlca(output_func, &async->risca, 2);
			output_func("\t%s\n", RIScom_umsg(RIS_I_DBCA));
			RIScom_output_rissqlca(output_func, &async->dbca, 2);
			output_func("\t%s<%s>\n", RIScom_umsg(RIS_I_RISSQLSTMT),  
				STRING(async->rissqlstmt));
			output_func("\t%s<%s>\n", RIScom_umsg(RIS_I_DBSQLSTMT),
				STRING(async->dbsqlstmt));
		}
	}

	INT_DBG(("RISint_show_async_stmts:complete\n"));
}

/******************************************************************************/
