/* Do not alter this SPC information: $Revision: 1.2.9.1 $ */
/*
**	NAME:							clierbuf.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clierbuf_c
#include "ccoclstm.prt"
#include "ccoeot.prt"
#include "clierbuf.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RIScli_err_to_buf(
	int status)
{
	int							length;
	int							offset;
	int							eot_schname_count;
	char						*eot_schname_list;
	int							clear_stmt_count;
	short						*clear_stmt_list;
	struct ris_cliapp_buf_error	*error;

	CLI_DBG(("RIScli_err_to_buf(status:%d)\n", status));

	RIS_app_write->status = status;
	RIS_app_write->warning = RIS_warning_flag;
	risca->sqlcode = status;

	offset = 0;
	error = &RIS_app_write->buf.error;
	/*
	**	Fill in RIS_app_write and RIS_app_write_len
	**	Start by filling in RIS_app_write->buf.error.risca
	**
	**	NOTE: For the client process, risca->sqlerrm contains
	**		the dynamic error message, if any.
	*/
	memcpy(&error->risca, risca, sizeof(rissqlca));

	/*
	**	Fill in RIS_app_write->buf.error.dbca
	*/
	memcpy(&error->dbca, dbca, sizeof(rissqlca));

	/*
	**	Fill in RIS_app_write->buf.error.risstmt
	*/
	if (risca->sqlstmt && *risca->sqlstmt)
	{
		length = strlen(risca->sqlstmt) + 1;
		error->risstmt = offset;
		error->risstmt_len = length;
		offset += length;
	}
	else
	{
		error->risstmt = 0;
		error->risstmt_len = 0;
	}

	if (dbca->sqlstmt && *dbca->sqlstmt)
	{
		length = strlen(dbca->sqlstmt) + 1;
		error->dbstmt = offset;
		error->dbstmt_len = length;
		offset += length;
	}
	else
	{
		error->dbstmt = 0;
		error->dbstmt_len = 0;
	}

	/*
	**	eot schname list
	*/
	RIScco_get_eot_schname_list(&eot_schname_count, &eot_schname_list);
	if (eot_schname_count)
	{
		error->eot_schname_count = eot_schname_count;
		error->eot_schname_list = offset;
		offset += eot_schname_count * RIS_MAX_ID_SIZE;
	}
	else
	{
		error->eot_schname_count = 0;
		error->eot_schname_list = 0;
	}

	/*
	**	clear stmt list
	*/
	RIScco_get_clear_stmt_list(&clear_stmt_count, &clear_stmt_list);
	if (clear_stmt_count)
	{
		error->clear_stmt_count = clear_stmt_count;
		error->clear_stmt_list = offset;
		offset += clear_stmt_count * sizeof(short);
	}
	else
	{
		error->clear_stmt_count = 0;
		error->clear_stmt_list = 0;
	}
	/*
	**	Is the error a test completion error?
	*/
	error->test_completion = RIS_test_completion_flag;

	/*
	**	Test if the buffer is large enough
	*/
	RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.error.data) + offset;
	if (RIS_app_write_len > RIS_app_write_size)
	{
		CLI_DBG(("RIScli_err_to_buf: ERROR: RIS_app_write_len:%d > "
			"RIS_app_write_size:%d\n", RIS_app_write_len, RIS_app_write_size));

		error = &RIS_app_write->buf.error;

		RIS_app_write->status = RIS_E_INTERNAL_ERROR;
		memset(&error->risca, 0, sizeof(rissqlca));
		memset(&error->dbca, 0, sizeof(rissqlca));
		error->risstmt = 0;
		error->risstmt_len = 0;
		error->dbstmt = 0;
		error->dbstmt_len = 0;
		error->eot_schname_count = 0;
		error->eot_schname_list = 0;
		error->clear_stmt_count = 0;
		error->clear_stmt_list = 0;
		RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.error.data);
		CLI_DBG(("RIScli_err_to_buf: complete\n"));
		return;
	}

	/*
	**	Now fill in the variable length data
	*/

	/*
	**	Fill in RIS_app_write->buf.error.risstmt
	*/
	if (error->risstmt_len)
	{
		memcpy(error->data + error->risstmt,risca->sqlstmt,error->risstmt_len);
	}

	/*
	**	Fill in RIS_app_write->buf.error.dbstmt
	*/
	if (error->dbstmt_len)
	{
		memcpy(error->data + error->dbstmt, dbca->sqlstmt, error->dbstmt_len);
	}

	/*
	**	eot schname list
	*/
	if (error->eot_schname_count)
	{
		memcpy(error->data + error->eot_schname_list, eot_schname_list,
			eot_schname_count * RIS_MAX_ID_SIZE);
	}
	RIScco_clear_eot_schname_list();

	/*
	**	clear stmt list
	*/
	if (error->clear_stmt_count)
	{
		memcpy(error->data + error->clear_stmt_list, clear_stmt_list,
			clear_stmt_count * sizeof(short));
	}
	RIScco_clear_clear_stmt_list();

	if (RISbuf_debug)
	{
		int i;

		RIScom_output_debug("RIScli_err_to_buf:SENDING ERROR to application\n");

		RIScom_output_debug("\tRIS_app_write->status:%#x\n",
			RIS_app_write->status);
		RIScom_output_debug("\tRIS_app_write->warning:%#x\n",
			RIS_app_write->warning);

		RIScom_output_debug("\trisca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", error->risca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", error->risca.sqlerrm.sqlerrml);
		RIScom_output_debug("\t\tsqlerrmc:<%*s>\n",
			error->risca.sqlerrm.sqlerrml, error->risca.sqlerrm.sqlerrmc);

		RIScom_output_debug("\trisstmt(offset):%d\n", error->risstmt);
		RIScom_output_debug("\trisstmt_len:%d\n", error->risstmt_len);
		if (error->risstmt_len)
		{
			RIScom_output_debug("\trisstmt:<%s>\n",
				error->data + error->risstmt);
		}
		else
		{
			RIScom_output_debug("\trisstmt:NULL\n");
		}

		RIScom_output_debug("\tdbca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", error->dbca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", error->dbca.sqlerrm.sqlerrml);
		RIScom_output_debug("\t\tsqlerrmc:<%*s>\n",
			error->dbca.sqlerrm.sqlerrml, error->dbca.sqlerrm.sqlerrmc);

		RIScom_output_debug("\tdbstmt(offset):%d\n", error->dbstmt);
		RIScom_output_debug("\tdbstmt_len:%d\n", error->dbstmt_len);
		if (error->dbstmt_len)
		{
			RIScom_output_debug("\tdbstmt:<%s>\n", error->data + error->dbstmt);
		}
		else
		{
			RIScom_output_debug("\tdbstmt:NULL\n");
		}
 
		RIScom_output_debug("\teot_schname_list(offset):%d\n",
			error->eot_schname_list);
		RIScom_output_debug("\teot_schname_count:%d\n",
			error->eot_schname_count);
		if (error->eot_schname_count)
		{
			RIScom_output_debug("\teot_schname list:\n");
			for(i = 0; i < error->eot_schname_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n", (error->data +
				 error->eot_schname_list) + (i*RIS_MAX_ID_SIZE));
			}
		}
		RIScom_output_debug("\tclear_stmt_list(offset):%d\n",
			error->clear_stmt_list);
		RIScom_output_debug("\tclear_stmteot_schname_count:%d\n",
			error->clear_stmt_count);
		if (error->clear_stmt_count)
		{
			RIScom_output_debug("\tclear_stmt list:\n");
			for(i = 0; i < error->clear_stmt_count; i++)
			{
				RIScom_output_debug("\t\t<%s>\n",
					(error->data + error->clear_stmt_list) +
					(i*RIS_MAX_ID_SIZE));
			}
		}
		RIScom_output_debug("\ttest_completion:%d\n", error->test_completion);
	}

	RIS_app_write_len =
		((int)((ris_cliapp_buf *)0)->buf.error.data) + offset;

	CLI_DBG(("RIScli_err_to_buf: complete\n"));
}

/******************************************************************************/

