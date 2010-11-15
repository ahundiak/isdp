/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clischmg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clischmg_c
#include "cliclear.prt"
#include "cliid.prt"
#include "clischmg.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "dicopsch.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void RIScli_schema_mgr(
	short	id,
	char	mode,
	char	*data,
	char	*str)
{
	int status;
	static short	stmt_id;

	CLI_DBG(("RIScli_schema_mgr(id:%d mode:%d data:<%s> str:0x%x)\n",
		id, mode, STRING(data), STRING(str)));

	stmt_id = -1;

	status = SETJMP();
	if (status)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RIScli_clear(stmt_id,0,SYNC_MODE,0);
		}
		LONGJMP(status);
	}

	/*
	**	Get a new statement id
	*/
	stmt_id = RIScli_new_stmt(id);

	if (mode) /* set */
	{
		if (*str)
		{
			if (!RIScom_pd_same(str, "%&Y$::<0x8awGwmWvAHWWM7a3,BK0ziSwC)2n"))
			{
				LONGJMP(RIS_E_INSUFFICIENT_PRIV);
			}
		}
		else
		{
			RIS_dict_select_flag = 1;
		}
		status = SETJMP();
		if (!status)
		{
			RIS_default = RISdic_open_schema(data, SYNC_MODE);
			RESETJMP();
		}
		else
		{
			RESETJMP();
			RIS_dict_select_flag = 0;
			LONGJMP(status);
		}
	}
	else /* clear */
	{
		RIS_default = NULL;
		RIS_dict_select_flag = 0;
	}

	RESETJMP();

	RIScli_clear(stmt_id,0,SYNC_MODE,0);

	CLI_DBG(("RIScli_schema_mgr:complete\n"));
}
