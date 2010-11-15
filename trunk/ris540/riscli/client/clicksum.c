/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							CLIcksumfile.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**		This file contains the functions to recalculate the check sum in
**		the schema file.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "client.h"
#include "risasync.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clicksum_c
#include "clicksum.prt"
#include "cliclear.prt"
#include "cliid.prt"
#include "ccosqlca.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "filtrans.prt"
#include "sys.prt"

/*
**	VARIABLES
*/


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_checksum_schfile(
	short	id)
{
	int				sts;
	static short	stmt_id;

	CLI_DBG(("RIScli_checksum_schfile(id:%d)\n", id));

	stmt_id = -1;

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();

		RIScco_push_risca_dbca();

		RISfil_rollback_schema_transact();
		if (stmt_id != -1)
		{
			RIScli_clear(stmt_id,0,SYNC_MODE,0);
		}

		RIScco_pop_risca_dbca();

		LONGJMP(sts);
	}

	stmt_id = RIScli_new_stmt(id);

	RISfil_recalculate_schema_file_checksum();
	RISfil_commit_schema_transact();

	RESETJMP();

	RIScli_clear(stmt_id,0,SYNC_MODE,0);

	CLI_DBG(("RIScli_checksum_schfile: complete\n"));
}

/******************************************************************************/
