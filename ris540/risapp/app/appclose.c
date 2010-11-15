/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appclose.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "risasync.h"
#include "riscom.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appclose_c
#include "appbufto.prt"
#include "appclose.prt"
#include "appcrsr.prt"
#include "appsndrc.prt"
#include "appsqlca.prt"
#include "apptobuf.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISapp_close(
	short	stmt_id,
	int		set_sqlcode,
	unsigned char	execute_mode)
{
	int		status;

	APP_DBG(("RISapp_close(stmt_id:%d set_sqlcode:%d execute_mode:%s)\n",
		stmt_id, set_sqlcode, RIScom_get_execute_mode_name(execute_mode)));

	if (stmt_id < 0 || stmt_id >= (short)RIS_max_stmts || !RIS_stmts[stmt_id])
	{
		if (set_sqlcode) LONGJMP(RIS_E_INV_STMTID);
		return;
	}

	RIS_current_stmt_id = stmt_id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	if (IN_START_MODE(execute_mode))
	{
		if (!RIS_stmt->fetch_buf)
		{
			if (set_sqlcode) LONGJMP(RIS_E_CURSOR_NOT_OPEN);
			return;
		}
	}

	if (!set_sqlcode)
	{
		RISapp_push_risca_dbca();
	}

	status = SETJMP();
	if (!status)
	{
		if (IN_START_MODE(execute_mode))
		{
			RISapp_close_cursor(RIS_current_stmt_id);
		}
		if (!RIS_client_died)
		{
			if (IN_START_OR_FINISH_MODE(execute_mode))
			{
				RISapp_opcode_to_buf(RISCLI_CLOSE_CODE, execute_mode);
				RISapp_send_rec();
			}
			if (IN_FINISH_MODE(execute_mode))
			{
				RISapp_buf_to_close();
			}
		}
	}
	RESETJMP();

	if (set_sqlcode)
	{
		if (status != RIS_SUCCESS) LONGJMP(status);
		return;
	}
	else
	{
		RISapp_pop_risca_dbca();
		return;
	}
}

/******************************************************************************/
