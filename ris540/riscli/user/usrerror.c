/*
**	NAME:							usrerror.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					10/91
**	ABSTRACT:
**		Miscellaneous functions for handling RIS user errors.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "user.h"
#include "net.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrerror_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrcp.prt"
#include "usrerror.prt"
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

extern void RISusr_net_errhandle(
	struct net_s *net)
{
	int			len;

	USR_DBG(("RISusr_net_errhandle(net:%d)\n", net));

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

	USR_DBG(("RISusr_net_errhandle: complete\n"));
	if (net->error_code == NET_E_TIMEOUT)
	{
		LONGJMP(STATEMENT_NOT_COMPLETE);
	}
	else
	{
		LONGJMP(RIS_E_SERVER_NETWORK_ERROR);
	}
}

/******************************************************************************/
