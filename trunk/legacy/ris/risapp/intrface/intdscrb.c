/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intdscrb.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "riscom.h"
#include "risflags.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define intdscrb_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "intdscrb.prt"
#include "interror.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_describe(
	short	stmt_id,
	sqlda	*data,
	int		in_out)
{
	int		i;
	int		sts;
	sqlda	*sql = 0;

	INT_DBG(("RISint_describe(stmt_id:%d data:0x%x in_out:%s)\n", stmt_id, data,
		(in_out == RIS_INPUT_FLAG) ? "RIS_INPUT_FLAG" :
		((in_out == RIS_OUTPUT_FLAG) ? "RIS_OUTPUT_FLAG" : "unknown")));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "DESCRIBE\n");
		fprintf(RIS_RAP, "stmt_id:%d\n", stmt_id);
		fprintf(RIS_RAP, "data:0x%x\n", data);
		RISXrap_print_describe_sqlda(RIS_RAP, data);
		fprintf(RIS_RAP, "in_out:%d\n", in_out);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		LONGJMP(RIS_E_NOT_INITIALIZED);
	}
	if (!RIS_net)
	{
		LONGJMP(RIS_E_CLIENT_NOT_STARTED);
	}
	if (stmt_id < 0 || stmt_id >= (short)RIS_max_stmts || !RIS_stmts[stmt_id])
	{
		LONGJMP(RIS_E_INV_STMTID);
	}
	RIS_current_stmt_id = stmt_id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	if (!data)
	{
		LONGJMP(RIS_E_INV_ARG);
	}

	if (in_out == RIS_INPUT_FLAG)
	{
		sql = RIS_stmt->input;
	}
	else if (in_out == RIS_OUTPUT_FLAG)
	{
		sql = RIS_stmt->output;
	}
	else
	{
		LONGJMP(RIS_E_INV_ARG);
	}

	if (sql)
	{
		data->sqld = sql->sqld;
		if (sql->sqld && sql->sqld <= data->sqln)
		{
			for(i=0;i < sql->sqld;i++)
			{
				if (!&data->sqlvar[i])
				{
					LONGJMP(RIS_E_INV_ARG);
				}
				else
				{
					data->sqlvar[i].sqltype = sql->sqlvar[i].sqltype;
					data->sqlvar[i].sqlnull = sql->sqlvar[i].sqlnull;
					data->sqlvar[i].sqllen = sql->sqlvar[i].sqllen;
					data->sqlvar[i].sqlscale = sql->sqlvar[i].sqlscale;
					data->sqlvar[i].sqlname.sqlnamel = 
						sql->sqlvar[i].sqlname.sqlnamel;
					memcpy(data->sqlvar[i].sqlname.sqlnamec,
						sql->sqlvar[i].sqlname.sqlnamec,
						RIS_MAX_ID_SIZE-1);
				}
			}
		}
	}
	else /* sql == NULL */
	{
		data->sqld = 0;
	}


	RESETJMP();

	INT_DBG(("RISint_describe:complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
