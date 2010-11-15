/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clishstm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					02/86
**	ABSTRACT:
**		The functions that print client stmts.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
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
#define clishstm_c
#include "clibuff.prt"
#include "clishstm.prt"
#include "ccooutpt.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_show_stmts(
	void)
{
	int			i,j;
	int			sts;
	static int	continue_flag;
	risstmt		*stmt;

	CLI_DBG(("RIScli_show_stmts()\n"));

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		if (sts == RIS_E_BUFFER_FULL)
		{
			continue_flag = 1;
			return;
		}

		continue_flag = 0;
		LONGJMP(sts);
	}

	RIScli_init_string_to_buf(continue_flag);

	RIScli_string_to_buf("\nRISCLIENT STATEMENTS:\n");
	RIScli_string_to_buf("\ncurrent stmt_id:%d\n", RIS_current_stmt_id);
	RIScli_ckpt_string_to_buf((char *)RIS_current_stmt_id);

	for (i = 0; (unsigned int)i < RIS_max_stmts; i++)
	{
		if (RIS_stmts[i])
		{
			stmt = RIS_stmts[i];
			RIScli_string_to_buf("\nstatement:\n");
			RIScli_string_to_buf("\tstmt:0x%x\n", stmt);
			RIScli_string_to_buf("\tstmt_id: %d%s\n", i,
				(i == RIS_current_stmt_id) ? " (Current statement)" : "");
			RIScli_string_to_buf("\tschema:<%s>\n", stmt->sql->schema ? 
			 stmt->sql->schema->schname : "NONE");
			RIScli_string_to_buf("\tsuperschema_flag:%d\n", stmt->sql->schema ? 
			 stmt->sql->schema->superschema_flag : -1);
			RIScli_string_to_buf("\tprimary_id:%d\n", stmt->primary_id);
			RIScli_string_to_buf("\tquery:<%s>\n", stmt->query);
			RIScli_string_to_buf("\tinput_len:%d\n", stmt->sql->input_len);
			RIScli_string_to_buf("\toutput_len:%d\n", stmt->row_len);
			RIScli_string_to_buf("\twrite_buf_size:%d\n", stmt->write_buf_size);
			RIScli_string_to_buf("\tread_buf_size:%d\n", stmt->read_buf_size);
			RIScli_string_to_buf("\tfetch_buf_size:%d\n", stmt->fetch_buf_size);

			RIScli_string_to_buf("\tinput sqlda:0x%x\n", stmt->sql->input);
			if (stmt->sql->input)
			{
				RIScli_string_to_buf("\t\tsqln:%d sqld:%d\n",
					stmt->sql->input->sqln, stmt->sql->input->sqld);
				for (j = 0; j < stmt->sql->input->sqln; j++)
				{
					RIScli_string_to_buf("\t\tinternal_sqlvar[%d]:0x%x\n", j,
						&stmt->sql->input->sqlvar[j]);
					RIScco_output_internal_sqlvar(RIScli_string_to_buf,
						&stmt->sql->input->sqlvar[j], 3);
				}
				
			}

			RIScli_string_to_buf("\toutput sqlda:0x%x\n", stmt->sql->output);
			if (stmt->sql->output)
			{
				RIScli_string_to_buf("\t\tsqln:%d sqld:%d\n",
					stmt->sql->output->sqln, stmt->sql->output->sqld);
				for (j = 0; j < stmt->sql->output->sqln; j++)
				{
					RIScli_string_to_buf("\t\tinternal_sqlvar[%d]:0x%x\n", j,
						&stmt->sql->output->sqlvar[j]);
					RIScco_output_internal_sqlvar(RIScli_string_to_buf,
						&stmt->sql->output->sqlvar[j], 3);
				}
				
			}
			RIScli_string_to_buf("\tfetch_buf:0x%x\n", stmt->fetch_buf);
			RIScli_string_to_buf("\tnext:0x%x\n", stmt->next);
			RIScli_string_to_buf("\tdbms:0x%x\n", stmt->sql->dbms);
		}
	}
	RIScli_ckpt_string_to_buf((char *)RIS_stmts);

	RESETJMP();

	continue_flag = 0;

	CLI_DBG(("RIScli_show_stmts:complete\n"));
}

/******************************************************************************/
