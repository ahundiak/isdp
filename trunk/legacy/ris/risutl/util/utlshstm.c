/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshstm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "util.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define utlshstm_c
#include "ris.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "utlshstm.prt"
#include "utlerror.prt"
#include "utlprint.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_util_stmts(
	void)
{
	int				i,j;
	ris_utl_stmt	*stmt;

	UTL_DBG(("RISutl_show_util_stmts()\n"));

	RISutl_printf("\n\nINTERACTIVE UTILITY STATEMENTS:\n");
	for (i = 0; i < RISutl_parameters.max_user_stmts; i++)
	{
		if (RISutl_stmts[i].stmt_id != -1)
		{
			stmt = &RISutl_stmts[i];

			RISutl_printf("Statement %d:\n", i);
			RISutl_printf("\tstmt_id:%d\n", stmt->stmt_id);
			RISutl_printf("\tinput:\n");
			RISutl_printf("\t\tsqln:%d sqld:%d\n",
			 stmt->input.sqln,stmt->input.sqld);
			RISutl_printf("\t\tsqlvar:0x%x\n", stmt->input.sqlvar);
			for (j = 0; j < stmt->input.sqln; j++)
			{
				RISutl_printf("\t\tsqlvar[%d]:\n", j);
				RIScom_output_sqlvar(RISutl_printf, &stmt->input.sqlvar[j], 3);
			}

			RISutl_printf("\toutput:\n");
			RISutl_printf("\t\tsqln:%d sqld:%d\n", stmt->output.sqln,
				stmt->output.sqld);
			RISutl_printf("\t\tsqlvar:0x%x\n", stmt->output.sqlvar);
			for (j = 0; j < stmt->output.sqln; j++)
			{
				RISutl_printf("\t\tsqlvar[%d]:\n", j);
				RIScom_output_sqlvar(RISutl_printf, &stmt->output.sqlvar[j], 3);
			}
		}
	}

	UTL_DBG(("RISutl_show_util_stmts:complete\n"));
}

/******************************************************************************/

extern void RISutl_show_app_stmts()
{
	UTL_DBG(("RISutl_show_app_stmts()\n"));

	RISint_show_app_stmts(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_app_stmts:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_async_stmts()
{
	UTL_DBG(("RISutl_show_async_stmts()\n"));

	RISint_show_async_stmts(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_async_stmts:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_cli_stmts()
{
	UTL_DBG(("RISutl_show_cli_stmts()\n"));

	RISint_show_cli_stmts(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_cli_stmts:returning\n"));
}

/******************************************************************************/
