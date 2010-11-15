/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							btcprep.c
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
#include "batch.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define btcprep_c
#include "btcgtcmd.prt"
#include "utlprint.prt"
#include "btcprep.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlmisc.prt"
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
	int				i;
	short			stmt_id = -1;
	char			c;
	char			buf[1000];

	BTC_DBG(("RISutl_prep()\n"));

	RISutl_printf("\nEnter a query to be prepared.\n");
#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
	{
		if (RISbtc_getcmd(buf, 1000, NULL) == -1)
		{
			LONGJMP(RISUTL_E_INPUT_TOO_LONG);
		}
	}
#else
	if (RISutl_file_tos->file == stdin)
	{
		if (RISbtc_getcmd(buf, 1000, stdin) == -1)
		{
			LONGJMP(RISUTL_E_INPUT_TOO_LONG);
		}
	}
#endif
	else
	{

		while((c = getc(RISutl_file_tos->file)) == ' ' | c == '\n' | c == '\t');

		for (buf[0]=c,i=1; (c = getc(RISutl_file_tos->file)) != ';'; i++)
		{
			buf[i]=c;
		}
		buf[i] = '\0';

		/* to remove the newline char */

		getc(RISutl_file_tos->file);
	}
	RISint_prepare(&stmt_id, buf, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	UTL_ERROR_CHECK();
	UTL_WARNING_CHECK();

	describe(stmt_id, &RISutl_stmts[stmt_id].input, RIS_INPUT_FLAG);
	describe(stmt_id, &RISutl_stmts[stmt_id].output, RIS_OUTPUT_FLAG);
	RISutl_stmts[stmt_id].stmt_id = stmt_id;
	RISutl_stmt_id = stmt_id;

	RISutl_printf("\nThe id for this statement is %d\n", RISutl_stmt_id);

	BTC_DBG(("RISutl_prep:returning\n"));
}

/******************************************************************************/

static void describe(
	short	id,
	sqlda	*ptr,
	int		mode)
{
	int i;

	BTC_DBG(("describe()\n"));

	RISint_describe(id, ptr, mode);
	UTL_ERROR_CHECK();
	UTL_WARNING_CHECK();

	if (ptr->sqld > 0)
	{
		ptr->sqln = ptr->sqld;
		if ((ptr->sqlvar = calloc(ptr->sqln, sizeof(sqlvar))) == NULL)
		{
			RISutl_clear_sqlda(ptr);
			LONGJMP(RISUTL_E_MALLOC);
		}

		RISint_describe(id, ptr, mode);
		UTL_ERROR_CHECK();
		UTL_WARNING_CHECK();

		for (i=0;i < ptr->sqln;i++)
		{
			if (ptr->sqlvar[i].sqltype == RIS_CHARACTER ||
				ptr->sqlvar[i].sqltype == RIS_DECIMAL)
			{
				ptr->sqlvar[i].sqldata = calloc(1, ptr->sqlvar[i].sqllen+1);
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

	BTC_DBG(("describe:returning\n"));
}

/******************************************************************************/
