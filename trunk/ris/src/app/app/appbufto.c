/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appbufto.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**		The routine to extract data from RIS_write buffer and RIS_write_len;
**	
**	REVISION HISTORY:
*/
#include "risapp.h"
#include "rismem.h"
#include "risnet.h"
#include "riscom.h"

/******************************************************************************/

extern void RISapp_buf_to_err(void)
{
	struct ris_cliapp_buf_error	*error = &RIS_read->buf.error;

	ERROR_FROM_NET(RIS_arc, &RIS_read->buf.error);

	APP_DBG(("RISapp_buf_to_err()\n"));

	if (RISbuf_debug)
	{
		int i;

		RIScom_output_debug("RISapp_buf_to_err: RECEIVED ERROR from client\n");
		RIScom_output_debug("RISapp_buf_to_err: warning:%d\n", RIS_read->warning);

		RIScom_output_debug("\trisca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", error->risca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", error->risca.sqlerrm.sqlerrml);
		RIScom_output_debug("\t\tsqlerrmc:<%s>\n", error->risca.sqlerrm.sqlerrmc);

		RIScom_output_debug("\trisstmt(offset):%d\n", error->risstmt);
		RIScom_output_debug("\trisstmt_len:%d\n", error->risstmt_len);
		if (error->risstmt_len)
		{
			RIScom_output_debug("\trisstmt:<%*s>\n", error->risstmt_len,
				error->data + error->risstmt);
		}
		else
		{
			RIScom_output_debug("\trisstmt:NULL\n");
		}

		RIScom_output_debug("\tdbca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", error->dbca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", error->dbca.sqlerrm.sqlerrml);
		RIScom_output_debug("\t\tsqlerrmc:<%s>\n", error->dbca.sqlerrm.sqlerrmc);

		RIScom_output_debug("\tdbstmt(offset):%d\n", error->dbstmt);
		RIScom_output_debug("\tdbstmt_len:%d\n", error->dbstmt_len);
		if (error->dbstmt_len)
		{
			RIScom_output_debug("\tdbstmt:<%*s>\n", error->dbstmt_len,
				error->data + error->dbstmt);
		}
		else
		{
			RIScom_output_debug("\tdbstmt:NULL\n");
		}

		RIScom_output_debug("\teot_schname_list(offset):%d\n", error->eot_schname_list);
		RIScom_output_debug("\teot_schname_count:%d\n", error->eot_schname_count);
		if (error->eot_schname_count)
		{
			RIScom_output_debug("\teot_schname list:\n");
			for(i = 0; i < error->eot_schname_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n", (error->data + error->eot_schname_list) +
					(i*RIS_MAX_ID_SIZE));
			}
		}
		RIScom_output_debug("\tclear_stmt_list(offset):%d\n", error->clear_stmt_list);
		RIScom_output_debug("\tclear_stmt_count:%d\n", error->clear_stmt_count);
		if (error->clear_stmt_count)
		{
			RIScom_output_debug("\tclear_stmt list:\n");
			for(i = 0; i < error->clear_stmt_count; i++)
			{
				RIScom_output_debug("\t\t%d\n", *((error->data +
				 error->clear_stmt_list) + (i*sizeof(short))));
			}
		}
		RIScom_output_debug("\ttest_completion:%d\n", error->test_completion);
	}

	RIS_test_completion_flag = error->test_completion;

	/*
	**	Process eot_schname_list first; this way if it fails, the original
	**	error is still preserved in the buffer.
	*/
	if (error->eot_schname_count)
	{
		if (!SETJMP())
		{
			RISapp_process_eot_schname_list(error->eot_schname_count,
				(error->data + error->eot_schname_list));
		}
		RESETJMP();
	}

	if (error->clear_stmt_count)
	{
		if (!SETJMP())
		{
			RISapp_process_clear_stmt_list(error->clear_stmt_count,
				(error->data + error->clear_stmt_list));
		}
		RESETJMP();
	}

	/*
	**	Copy risca from the buffer
	*/
	memcpy(risca, &(error->risca), sizeof(rissqlca));
	risca->sqlstmt = RIS_risstmt;
	if (error->risstmt_len)
	{
		memcpy(risca->sqlstmt, (error->data + error->risstmt),
			error->risstmt_len);
	}
	else
	{
		*risca->sqlstmt = '\0';
	}

	/*
	**	Copy dbca from the buffer
	*/
	memcpy(dbca, &(error->dbca), sizeof(rissqlca));
	dbca->sqlstmt = RIS_dbstmt;
	if (error->dbstmt_len)
	{
		memcpy(dbca->sqlstmt, (error->data + error->dbstmt), error->dbstmt_len);
	}
	else
	{
		*dbca->sqlstmt = '\0';
	}

	/*
	**	Map warnings if any
	*/
	RISapp_map_warnings(RIS_read->warning);
	APP_DBG(("RISapp_buf_to_err:complete\n"));
}

/******************************************************************************/

extern void RISapp_buf_to_execute(void)
{
	int		i;
	struct ris_cliapp_buf_exec *exec = &RIS_read->buf.exec;

	EXECUTE_FROM_NET(RIS_arc, &RIS_read->buf.exec);
	APP_DBG(("RISapp_buf_to_execute()\n"));

	if (RISbuf_debug)
	{
		RIScom_output_debug("BUFFER: CLI_TO_APP: RISCLI_EXEC_CODE\n");
		RIScom_output_debug("\tRIS_def_schname:<%s>\n", exec->RIS_def_schname);
		RIScom_output_debug("\teot_schname_count:%d\n", exec->eot_schname_count);
		if (exec->eot_schname_count)
		{
			RIScom_output_debug("\teot_schname list:\n");
			for(i = 0; i < exec->eot_schname_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n",
					exec->data + exec->eot_schname_list + (i*RIS_MAX_ID_SIZE));
			}
		}
		RIScom_output_debug("\tclear_stmt_count:%d\n", exec->clear_stmt_count);
		if (exec->clear_stmt_count)
		{
			RIScom_output_debug("\tclear_stmt list:\n");
			for(i = 0; i < exec->clear_stmt_count; i++)
			{
				RIScom_output_debug("\t\t%d\n",
					*(exec->data + exec->clear_stmt_list + (i*sizeof(short))));
			}
		}
	}

	if (RIScom_can_change_dflt_schema(RIS_stmt->stmt_type))
	{
		strcpy(RIS_def_schname, exec->RIS_def_schname);
	}

	if (exec->eot_schname_count)
	{
		RISapp_process_eot_schname_list(exec->eot_schname_count,
			exec->data + exec->eot_schname_list);
	}

	if (exec->clear_stmt_count)
	{
		RISapp_process_clear_stmt_list(exec->clear_stmt_count,
			exec->data + exec->clear_stmt_list);
	}
	APP_DBG(("RISapp_buf_to_execute:complete\n"));
}

/******************************************************************************/


extern void RISapp_buf_to_fetch(void)
{
	int offset;
	unsigned int i;
	struct ris_cliapp_buf_fetch *fetch = &RIS_read->buf.fetch;

/*
** May be we need to pass in RIS_stmt[RIS_current_stmt_id] instead of RIS_stmt
*/
	FETCH_FROM_NET(RIS_arc, RIS_stmt, &RIS_read->buf.fetch);
	APP_DBG(("RISapp_buf_to_fetch()\n"));
	if (RISbuf_debug)
	{

		RIScom_output_debug("RISapp_buf_to_fetch: RISCLI_FETCH_CODE\n");
		RIScom_output_debug("\trow_count:%d\n", fetch->row_count);
		RIScom_output_debug("\tblob_to_follow:%s\n", 
					fetch->blob_to_follow ? "YES" : "NO");
		RIScom_output_debug("\tmore_to_follow:%s\n",
					fetch->more_to_follow ? "YES" : "NO");

		for (i = 0, offset = 0;
			i < fetch->row_count;
			i++, offset += RIS_stmt->output_len)
		{
			RIScom_output_debug("\trow %d:\n", i);
			RIScom_output_data(RIScom_output_debug, RIS_stmt->output->sqld,
				RIS_stmt->output->sqlvar,
				(char *)(fetch->data + offset), 2);
		}
	}
	RIS_stmt->row_count = fetch->row_count;
	RIS_stmt->end_of_data = !fetch->more_to_follow;
	RIS_stmt->row = (char *)fetch->data;

	APP_DBG(("RISapp_buf_to_fetch()\n"));
}

/******************************************************************************/

extern void RISapp_buf_to_close(void)
{
	int		i;
	struct ris_cliapp_buf_close *close = &RIS_read->buf.close;

	CLOSE_FROM_NET(RIS_arc, &RIS_read->buf.close);
	APP_DBG(("RISapp_buf_to_close()\n"));

	if (RISbuf_debug)
	{
		RIScom_output_debug("APPsend_rec: RISCLI_CLOSE_CODE\n");
		RIScom_output_debug("\teot_schname_count:%d\n", close->eot_schname_count);
		if (close->eot_schname_count)
		{
			RIScom_output_debug("\teot_schname list:\n");
			for(i = 0; i < close->eot_schname_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n",
					close->data + (i*RIS_MAX_ID_SIZE));
			}
		}
	}

	if (close->eot_schname_count)
	{
		RISapp_process_eot_schname_list(close->eot_schname_count,
			close->data);
	}

	APP_DBG(("RISapp_buf_to_close:complete\n"));
}

/******************************************************************************/

extern void RISapp_buf_to_clear(void)
{
	int	i;
	struct ris_cliapp_buf_clear *clear = &RIS_read->buf.clear;

	CLEAR_FROM_NET(RIS_arc, &RIS_read->buf.clear);
	APP_DBG(("RISapp_buf_to_clear()\n"));
	if (RISbuf_debug)
	{
		RIScom_output_debug("APPsend_rec: RISCLI_CLEAR_CODE\n");
		RIScom_output_debug("\teot_schname_count:%d\n", clear->eot_schname_count);
		if (clear->eot_schname_count)
		{
			RIScom_output_debug("\teot_schname list:\n");
			for(i = 0; i < clear->eot_schname_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n", clear->data + (i*RIS_MAX_ID_SIZE));
			}
		}
	}

	if (clear->eot_schname_count)
	{
		RISapp_process_eot_schname_list(clear->eot_schname_count, clear->data);
	}

	APP_DBG(("RISapp_buf_to_clear:complete\n"));
}

/******************************************************************************/

extern int RISapp_buf_to_report_ss_error(ris_schema_error_info *ss_error)
{
	char									*save_ris_sqlstmt;
	char									*save_db_sqlstmt;
	struct ris_cliapp_buf_report_ss_error	*report_ss_error = &RIS_read->buf.report_ss_error;

	APP_DBG(("RISapp_buf_to_report_ss_error(ss_error:0x%x)\n",
		ss_error));

	REPORT_SS_ERR_FROM_NET(RIS_arc, &RIS_read->buf.report_ss_error)

	if (RISbuf_debug)
	{
		RIScom_output_debug("RISapp_buf_to_report_ss_error: RISCLI_REPORT_SS_ERROR\n");

		RIScom_output_debug("\trisca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", report_ss_error->risca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", report_ss_error->risca.sqlerrm.sqlerrml);
		if (report_ss_error->risca.sqlerrm.sqlerrml > 0)
		{
			RIScom_output_debug("\t\tsqlerrmc:<%s>\n",
				report_ss_error->risca.sqlerrm.sqlerrmc);
		}

		RIScom_output_debug("\trisstmt(offset):%d\n", report_ss_error->risstmt);
		RIScom_output_debug("\trisstmt_len:%d\n", report_ss_error->risstmt_len);
		if (report_ss_error->risstmt_len)
		{
			RIScom_output_debug("\trisstmt:<%s>\n",
				report_ss_error->data + report_ss_error->risstmt);
		}
		else
		{
			RIScom_output_debug("\trisstmt:NULL\n");
		}

		RIScom_output_debug("\tdbca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", report_ss_error->dbca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", report_ss_error->dbca.sqlerrm.sqlerrml);
		if (report_ss_error->dbca.sqlerrm.sqlerrml > 0)
		{
			RIScom_output_debug("\t\tsqlerrmc:<%s>\n",
				report_ss_error->dbca.sqlerrm.sqlerrmc);
		}

		RIScom_output_debug("\tdbstmt(offset):%d\n", report_ss_error->dbstmt);
		RIScom_output_debug("\tdbstmt_len:%d\n", report_ss_error->dbstmt_len);
		if (report_ss_error->dbstmt_len)
		{
			RIScom_output_debug("\tdbstmt:<%s>\n",
				report_ss_error->data + report_ss_error->dbstmt);
		}
		else
		{
			RIScom_output_debug("\tdbstmt:NULL\n");
		}

		RIScom_output_debug("\tss_name:<%s>\n", report_ss_error->ss_name);
		RIScom_output_debug("\tmore_to_follow:%s\n",
			report_ss_error->more_to_follow?"YES":"NO");
	}

	/*
	**	Save the current sqlstmt pointers
	*/
	save_ris_sqlstmt = ss_error->schrisca.sqlstmt;
	save_db_sqlstmt = ss_error->schdbca.sqlstmt;


	/*
	**	Copy risca from the buffer
	*/
	APP_DBG(("memcpying risca to schrisca ...\n"));
	memcpy(&ss_error->schrisca, &report_ss_error->risca, sizeof(rissqlca));

	/*
	**	Copy dbca from the buffer
	*/
	APP_DBG(("memcpying dbca to schdbca ...\n"));
	memcpy(&ss_error->schdbca, &report_ss_error->dbca, sizeof(rissqlca));

	/*
	**	Copy schrisca->sqlstmt from the buffer
	*/
	APP_DBG(("save_ris_sqlstmt:0x%x\n", save_ris_sqlstmt));
	if (report_ss_error->risstmt_len)
	{
		if (save_ris_sqlstmt)
		{
			APP_DBG(("REALLOCing schris_sqlstmt ...\n"));
			ss_error->schrisca.sqlstmt = SYS_REALLOC(save_ris_sqlstmt,
				report_ss_error->risstmt_len);
		}
		else
		{
			APP_DBG(("MALLOCing schris_sqlstmt ...\n"));
			ss_error->schrisca.sqlstmt=SYS_MALLOC(report_ss_error->risstmt_len);
		}
		memcpy(ss_error->schrisca.sqlstmt,
			report_ss_error->data + report_ss_error->risstmt,
			report_ss_error->risstmt_len);
	}
	else
	{
		if (save_ris_sqlstmt)
		{
			APP_DBG(("FREEing ris_sqlstmt ...\n"));
			SYS_FREE(save_ris_sqlstmt);
		}
		ss_error->schrisca.sqlstmt = 0;
	}

	/*
	**	Copy schdbca->sqlstmt from the buffer
	*/
	APP_DBG(("save_db_sqlstmt: 0x%x\n", save_db_sqlstmt));
	if (report_ss_error->dbstmt_len)
	{
		if (save_db_sqlstmt)
		{
			APP_DBG(("REALLOCing db_sqlstmt ...\n"));
			ss_error->schdbca.sqlstmt = SYS_REALLOC(save_db_sqlstmt,
				report_ss_error->dbstmt_len);
		}
		else
		{
			APP_DBG(("MALLOCing db_sqlstmt ...\n"));
			ss_error->schdbca.sqlstmt = SYS_MALLOC(report_ss_error->dbstmt_len);
		}
		memcpy(ss_error->schdbca.sqlstmt,
			report_ss_error->data + report_ss_error->dbstmt,
			report_ss_error->dbstmt_len);
	}
	else
	{
		if (save_db_sqlstmt)
		{
			APP_DBG(("FREEing db_sqlstmt ...\n"));
			SYS_FREE(save_db_sqlstmt);
		}
		ss_error->schdbca.sqlstmt = 0;
	}

	APP_DBG(("strcpying ss_name ...\n"));
	strcpy(ss_error->schname, report_ss_error->ss_name);

	APP_DBG(("RISapp_buf_to_report_ss_error:returning more_to_follow:%d\n",
		report_ss_error->more_to_follow));
	return report_ss_error->more_to_follow;
}

/******************************************************************************/

extern void RISapp_map_warnings(char warning_flag)
{
	APP_DBG(("RISapp_map_warnings(warning_flag:%d)\n", warning_flag));
	if( IS_RIS_WARNING(warning_flag)  )
	{
    	risca->sqlwarn[0] = 'W';
		if( IS_RIS_WARNING1(warning_flag) ) risca->sqlwarn[1] = 'W';
		if( IS_RIS_WARNING2(warning_flag) ) risca->sqlwarn[2] = 'W';
		if( IS_RIS_ILICENSE_WARNING(warning_flag) ) risca->sqlwarn[3] = 'W';
		if( IS_RIS_WARNING4(warning_flag) ) risca->sqlwarn[4] = 'W';
		if( IS_RIS_WARNING5(warning_flag) ) risca->sqlwarn[5] = 'W';
		if( IS_RIS_PRIM_SCH_WARNING(warning_flag) ) 
		{
			risca->sqlwarn[6] = 'W';
			superschema_warning |= 0x2; 
		}
		if( IS_RIS_SEC_SCH_WARNING(warning_flag) ) 
		{
			risca->sqlwarn[7] = 'W';
			superschema_warning |= 0x1; 
		}
	}
	APP_DBG(("RISapp_map_warnings: superschema_warning:%d\n", 
		superschema_warning));
	APP_DBG(("RISapp_map_warnings: complete\n"));

	/*************************************************************************

		superschema_warning is set according to following bits:
		PRIM		SEC
		----		---
		 0			 0 	(superschema_warning = 0 : both alive)
		 0			 1	(superschema_warning = 1 : only secondary died)
		 1			 0	(superschema_warning = 2 : only primary died)
		 1			 1 	(superschema_warning = 3 : both died)

	 *************************************************************************/
}

/******************************************************************************/
