/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							cliclose.c
**	AUTHORS:						David Michal
**	CREATION DATE:					7/88
**	ABSTRACT:
**		This function frees up the space used by a cursor.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cliclose_c
#include "cliclose.prt"
#include "comexmod.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "usrexec.prt"
#include "usrsndrc.prt"

/******************************************************************************/

extern void RIScli_close(
	short			id,
	unsigned char	execute_mode)
{
	CLI_DBG(("RIScli_close(id:%d execute_mode:%s)\n", id,
		RIScom_get_execute_mode_name(execute_mode)));

	if (id < 0 || id > RIS_parms.max_user_stmts || !RIS_stmts[id])
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	RIS_current_stmt_id = id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	if (RIS_stmt->sql->schema && RIS_stmt->sql->dbms)
	{
		RIS_sdp->schema = RIS_stmt->sql->schema;
		RISusr_send_rec(RIS_CLOSE_CODE, RIS_sdp, SYNC_MODE);
	}
	if (IN_FINISH_MODE(execute_mode))
	{
		RISusr_close_cursor(RIS_current_stmt_id);
	}

	CLI_DBG(("RIScli_close:complete\n"));
}

/******************************************************************************/
