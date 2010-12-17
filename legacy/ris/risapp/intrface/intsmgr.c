/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intsmgr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument list for RISapp_initialize from RIS_DEFAULT_LANGUAGE
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
#define intsmgr_c
#include "appclear.prt"
#include "appcli.prt"
#include "appid.prt"
#include "appinit.prt"
#include "apptobuf.prt"
#include "appsndrc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
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

extern void RISAPI RISXint_schema_mgr(
	char	mode,
	char	*data,
	char	*str)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISint_schema_mgr(mode:%d data:<%s> str:0x%x)\n",mode,
		STRING(data), str));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "SCHEMA MGR\n");
		fprintf(RIS_RAP, "mode:%d\n", mode);
		fprintf(RIS_RAP, "data:0x%x\n", data);
		if (data)
		{
			fprintf(RIS_RAP, "*data:%s\n", data);
		}
		fprintf(RIS_RAP, "str:0x%x\n", str);
		if (str)
		{
			fprintf(RIS_RAP, "*str:%s\n", str);
		}
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

	RISapp_schema_mgr_to_buf(mode, data, str);
	RISapp_send_rec();

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISint_schema_mgr: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
