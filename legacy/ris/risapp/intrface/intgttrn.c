/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intgttrn.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
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
#define intgetss_c
#include "appclear.prt"
#include "appcli.prt"
#include "appid.prt"
#include "appinit.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
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

extern void RISAPI RISXget_schema_transactions(
	char	(*buffer)[RIS_MAX_ID_SIZE],
	int		*countp)
{
	int					i;
	int					sts;
	static  short		stmt_id;

	INT_DBG(("RISget_schema_transactions(buffer:0x%x countp:0x%x)\n",
		buffer, countp));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET SCHEMA TRANSACTIONS\n");
		fprintf(RIS_RAP, "buffer:0x%x\n", buffer);
		fprintf(RIS_RAP, "countp:0x%x\n", countp);
		if (countp)
		{
			fprintf(RIS_RAP, "*countp:%d\n", *countp);
		}
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

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

	if (RIS_client_died)
	{
		LONGJMP(RIS_E_CLIENT_DIED);
	}

	if (!countp)
	{
		LONGJMP(RIS_E_INV_ARG);
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

	RISapp_opcode_to_buf(RISCLI_GET_SCH_IN_TRANS_CODE, SYNC_MODE);
	RISapp_send_rec();

	if (*countp == 0)
	{
		*countp = RIS_read->buf.get_sch_in_trans.sch_count;
	}
	else if (*countp >= RIS_read->buf.get_sch_in_trans.sch_count)
	{
		for (i = 0; i < RIS_read->buf.get_sch_in_trans.sch_count; i++)
		{
			memcpy(buffer[i],
				RIS_read->buf.get_sch_in_trans.data + (i * RIS_MAX_ID_SIZE),
				RIS_MAX_ID_SIZE);
		}
		*countp = RIS_read->buf.get_sch_in_trans.sch_count;
	}
	else
	{
		LONGJMP(RIS_E_NOT_ENOUGH_SPACE);
	}

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_schema_transactions: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
