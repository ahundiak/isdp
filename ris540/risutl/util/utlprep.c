/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlprep.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					5/87
**	ABSTRACT:
**		Prepare a query.	
**	
**	REVISION HISTORY: Modified 'RISint_prepare' call to avoid 'repreparing of
**                    static stmts' by Prasad Challa on  9/16/91
**					  Modified for the superschema execution by Prasad. 11/91
*/
 
/*
**	INCLUDES
*/
#include "risflags.h"
#include "risasync.h"
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlprep_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "edtgtcmd.prt"
#include "ris.prt"
#include "utlmisc.prt"
#include "utlprep.prt"
#include "utlerror.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_prep()
{
	int				sts;
	short			stmt_id = -1;
	char			buf[1000];

	UTL_DBG(("RISutl_prep()\n"));

	printf("\nEnter a query to be prepared.\n");
	if (RISutl_file_tos->file == stdin)
	{
		if (EDT_getcmd(buf, 1000, 0) == -1)
		{
			LONGJMP(RISUTL_E_INPUT_TOO_LONG);
		}
	}
	else
	{
		if (EDT_getcmd(buf, 1000, RISutl_file_tos->file) == -1)
		{
			LONGJMP(RISUTL_E_INPUT_TOO_LONG);
		}
	}

	RISint_prepare(&stmt_id, buf, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		RISint_clear(&stmt_id, 0, SYNC_MODE);
		LONGJMP(sts);
	}
	else
	{
		describe(stmt_id, &RISutl_stmts[stmt_id].input, RIS_INPUT_FLAG);
		describe(stmt_id, &RISutl_stmts[stmt_id].output, RIS_OUTPUT_FLAG);
		RESETJMP();
	}

	RISutl_stmts[stmt_id].stmt_id = stmt_id;
	RISutl_stmt_id = stmt_id;
	printf("\nThe id for this statement is %d\n", RISutl_stmt_id);

	UTL_DBG(("RISutl_prep:returning\n"));
}

/******************************************************************************/

static void describe(
	short	id,
	sqlda	*ptr,
	int		mode)
{
	int i;

	UTL_DBG(("describe()\n"));

	RISint_describe(id, ptr, mode);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (ptr->sqld > 0)
	{
		ptr->sqln = ptr->sqld;
		if ((ptr->sqlvar = calloc(ptr->sqln, sizeof(sqlvar))) == NULL)
		{
			RISutl_clear_sqlda(ptr);
			LONGJMP(RISUTL_E_MALLOC);
		}

		RISint_describe(id, ptr, mode);
		UTL_WARNING_CHECK();
		UTL_ERROR_CHECK();

		for (i=0;i < ptr->sqln;i++)
		{
			if (ptr->sqlvar[i].sqltype == RIS_CHARACTER ||
				ptr->sqlvar[i].sqltype == RIS_DECIMAL)
			{
				ptr->sqlvar[i].sqldata = calloc(1, ptr->sqlvar[i].sqllen+1);
			}
			else if (ptr->sqlvar[i].sqltype == RIS_BLOB ||
				ptr->sqlvar[i].sqltype == RIS_TEXT)
			{
				LONGJMP(RISUTL_E_BLOB_QUERY);
			}
			else
			{
				ptr->sqlvar[i].sqldata = calloc(1, ptr->sqlvar[i].sqllen);
			}
			if (ptr->sqlvar[i].sqldata == NULL)
			{
				RISutl_clear_sqlda(ptr);
				LONGJMP(RISUTL_E_MALLOC);
			}

			ptr->sqlvar[i].sqlind = calloc(1, sizeof(long));
			if (ptr->sqlvar[i].sqlind == NULL)
			{
				RISutl_clear_sqlda(ptr);
				LONGJMP(RISUTL_E_MALLOC);
			}

			*ptr->sqlvar[i].sqlind = -1;
			ptr->sqlvar[i].sqlnull = 1;
		}
	}

	UTL_DBG(("describe:returning\n"));
}

/******************************************************************************/
