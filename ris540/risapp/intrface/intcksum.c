/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intcksum.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**	
**	01/95:	Changed the argument of RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risasync.h"
#include "risflags.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intcksum_c
#include "appclear.prt"
#include "appcli.prt"
#include "appid.prt"
#include "appinit.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "intcksum.prt"
#include "interror.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXrestore_schema_file_checksum(
	void)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISrestore_schema_file_checksum()\n"));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "CHECKSUM SCHEMA FILE\n");
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT,
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	
	RISapp_opcode_to_buf(RISCLI_CHECKSUM_SCHEMA_FILE_CODE, SYNC_MODE);
	RISapp_send_rec();

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISrestore_schema_file_checksum: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
