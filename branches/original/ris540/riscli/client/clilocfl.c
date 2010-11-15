/*
**	NAME:							clilocfl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "client.h"

#if defined(unix) 
#include <dirent.h>
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clilocfl_c
#include "cliclear.prt"
#include "cliid.prt"
#include "clilocfl.prt"
#include "ccosqlca.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "filglob.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RIScli_locate_schfile(
	short id)
{
	int				sts;
	volatile short	stmt_id;

	CLI_DBG(("RIScli_locate_schfile(id:%d)\n", id));

	stmt_id = -1;

	RISfil_begin_globals_transaction();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		RIScco_push_risca_dbca();

		RISfil_globals_rollback();
		if (stmt_id != -1)
		{
			RIScli_clear(stmt_id,0,SYNC_MODE,0);
		}

		RIScco_pop_risca_dbca();
		LONGJMP(sts);
	}

	stmt_id = RIScli_new_stmt(id);

	RISfil_locate_schfile(&RIS_app_read->buf.locate_schfile.parms);

	RISfil_globals_commit();

	RESETJMP();

	RIScli_clear(stmt_id,0,SYNC_MODE,0);

	CLI_DBG(("RIScli_locate_schfile:complete\n"));
}

/******************************************************************************/
