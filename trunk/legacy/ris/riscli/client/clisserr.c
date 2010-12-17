/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clisserr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					5/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**				Removed the dependency of risca and dbca from risschema and 
**				moved to rissuperschema (risstmtstat) -- Hitesh (7/92)
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
#define clisserr_c
#include "clisserr.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "dicundss.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_report_ss_error(
	char *ss_name)
{
	int										offset;
	int										length;
	static short							stmtstat_indx = -1;
	struct ris_cliapp_buf_report_ss_error	*report_ss_error;
	struct risstmtstat						*stmtstat;
	static rissuperschema					*sschema = 0;

	CLI_DBG(("RIScli_report_ss_error(ss_name:<%s>)\n", STRING(ss_name)));


	/*
	**	superschema name (ss_name) is passed only for primary schema by the 
	**	application. For secondary schemas, NULL is passed.
	*/
	if (ss_name && *ss_name)
	{
		/*
		**	Report error for primary schema
		*/
		if ((sschema = RISdic_find_supersch(ss_name)) == NULL)
		{
			LONGJMP(RIS_E_SUPERSCHEMA_NOT_DECLARED);
		}
		stmtstat_indx = 0;
	}
	else
	{
		/*
		**	Report error for secondary schema
		*/
		if ((stmtstat_indx <= 0) || (stmtstat_indx > (sschema->stmt_count-1))
		|| (!sschema))
		{
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}

	/*
	**	Current stmtstat structure
	*/
	stmtstat = sschema->stmtstat[stmtstat_indx];
	if (!stmtstat)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Fill in RIS_app_write and RIS_app_write_len
	**	Start with the fixed length fields
	*/

	offset = 0;
	report_ss_error = &RIS_app_write->buf.report_ss_error;

	/*
	**	Fill in RIS_app_write->buf.report_ss_error.risca
	*/
	memcpy(&report_ss_error->risca, stmtstat->risca, sizeof(rissqlca));

	/*
	**	Fill in RIS_app_write->buf.report_ss_error.dbca
	*/
	memcpy(&report_ss_error->dbca, stmtstat->dbca, sizeof(rissqlca));

	/*
	**	Fill in RIS_app_write->buf.report_ss_error.risstmt
	*/
	if (stmtstat->risca->sqlstmt && *stmtstat->risca->sqlstmt)
	{
		length = strlen(stmtstat->risca->sqlstmt) + 1;
		report_ss_error->risstmt = offset;
		report_ss_error->risstmt_len = length;
		offset += length;
	}
	else
	{
		report_ss_error->risstmt = 0;
		report_ss_error->risstmt_len = 0;
	}

	if (stmtstat->dbca->sqlstmt && *stmtstat->dbca->sqlstmt)
	{
		length = strlen(stmtstat->dbca->sqlstmt) + 1;
		report_ss_error->dbstmt = offset;
		report_ss_error->dbstmt_len = length;
		offset += length;
	}
	else
	{
		report_ss_error->dbstmt = 0;
		report_ss_error->dbstmt_len = 0;
	}

	/*
	**	Here, ss_name means current schema being reported
	*/
	strcpy(report_ss_error->ss_name, stmtstat->schname);

	/*
	**	Indicating to  the application that there are more secondary schemas
	**	to be reported
	**	For the last secondary schema, more_to_follow will be set to 0
	*/
	report_ss_error->more_to_follow = 
		(stmtstat_indx < (sschema->stmt_count-1)) ? 1 : 0;

	/*
	**	Test if the buffer is large enough
	*/
	RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.report_ss_error.data)
		+ offset;
	if (RIS_app_write_len > RIS_app_write_size)
	{
		CLI_DBG(("RIScli_report_ss_error: ERROR: RIS_app_write_len:%d > "
			"RIS_app_write_size:%d\n", RIS_app_write_len, RIS_app_write_size));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Now fill in the variable length data
	*/

	/*
	**	Fill in RIS_app_write->buf.report_ss_error.risstmt
	*/
	if (report_ss_error->risstmt_len)
	{
		memcpy(report_ss_error->data + report_ss_error->risstmt,
			stmtstat->risca->sqlstmt, report_ss_error->risstmt_len);
	}

	/*
	**	Fill in RIS_app_write->buf.report_ss_error.dbstmt
	*/
	if (report_ss_error->dbstmt_len)
	{
		memcpy(report_ss_error->data + report_ss_error->dbstmt,
			stmtstat->dbca->sqlstmt, report_ss_error->dbstmt_len);
	}

	RIS_app_write_len =
		((int)((ris_cliapp_buf *)0)->buf.report_ss_error.data) + offset;


	if (stmtstat_indx < (sschema->stmt_count-1))
	{
		stmtstat_indx++;
	}
	else
	{
		stmtstat_indx = -1;
	}

	if (RISbuf_debug)
	{
		RIScom_output_debug("RIScli_report_ss_error: RISCLI_REPORT_SS_ERROR\n");
		RIScom_output_debug("\tRIS_app_write->status:%d\n", RIS_app_write->status);
		RIScom_output_debug("\trisca:\n");
		RIScom_output_debug("\t\tsqlcode:%d\n", report_ss_error->risca.sqlcode);
		RIScom_output_debug("\t\tsqlerrml:%d\n", 
			report_ss_error->risca.sqlerrm.sqlerrml);
		if (report_ss_error->risca.sqlerrm.sqlerrml)
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
		RIScom_output_debug("\t\tsqlerrml:%d\n", 
			report_ss_error->dbca.sqlerrm.sqlerrml);
		if (report_ss_error->dbca.sqlerrm.sqlerrml)
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
			report_ss_error->more_to_follow ? "YES" : "NO");
		RIScom_output_debug("\tstmtstat_indx:%d\n", stmtstat_indx);

	}
	CLI_DBG(("RIScli_report_ss_error:complete\n"));
}

/******************************************************************************/
