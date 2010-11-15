/*
**	NAME:							ccoerror.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "clicom.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccoerror_c
#include "sys.prt"
#include "ccoerror.prt"
#include "comstrcp.prt"
#include "comjmp.prt"
#include "comdebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_net_errhandle(
	struct net_s *net)
{
	int			len;

	CCO_DBG(("RIScco_net_errhandle(net:0x%x)\n", net));

	/*
	**	Fill in dbca
	*/
	dbca->sqlcode = net->error_code;
	dbca->sqlerrm.sqlerrml =
		(short)RIScom_strcpy(dbca->sqlerrm.sqlerrmc, net->error_string);

	dbca->sqlcaid[5] = 'N';
	dbca->sqlcaid[6] = 'E';
	dbca->sqlcaid[7] = 'T';

	/*
	**	This should never be true, but it doesn't hurt to check
	*/
	if (dbca->sqlstmt != RIS_dbstmt)
	{
		dbca->sqlstmt = RIS_dbstmt;
	}

	if ((len = strlen(net->net_error_string)) > 0)
	{
		if (len > sizeof(RIS_dbstmt) - 1)
		{
			len = sizeof(RIS_dbstmt) - 1;
		}
		memcpy(dbca->sqlstmt, net->net_error_string, len);
		dbca->sqlstmt[len] = '\0';
	}
	else
	{
		*dbca->sqlstmt = '\0';
	}

	CCO_DBG(("RIScco_net_errhandle: complete\n"));
}

/******************************************************************************/

extern void RIScco_arc_errhandle(
	struct arc_s	*arc)
{
	int		len;

	CCO_DBG(("RIScco_arc_errhandle()\n"));

	dbca->sqlcode = arc->error_code;
	dbca->sqlerrm.sqlerrml =
		(short)RIScom_strcpy(dbca->sqlerrm.sqlerrmc, arc->error_string);

	dbca->sqlcaid[5] = 'A';
	dbca->sqlcaid[6] = 'R';
	dbca->sqlcaid[7] = 'C';

	if (dbca->sqlstmt)
	{
		if ((len = strlen((const char *)arc->arc_error_string)) > 0)
		{
			if (len > RIS_MAX_STMT_LEN - 1)
			{
				len = RIS_MAX_STMT_LEN - 1;
			}
			memcpy(dbca->sqlstmt, arc->arc_error_string, len);
			dbca->sqlstmt[len] = '\0';
		}
		else
		{
			*dbca->sqlstmt = '\0';
		}
	}

	CCO_DBG(("RIScco_arc_errhandle:complete\n"));
	LONGJMP(RIS_E_ARCH_ERROR);
}

/******************************************************************************/
