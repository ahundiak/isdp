/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intgtflg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**					Feb. 94, Added func. for the blankstrip_mode. - Sanju
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE"). Paula Blohm
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
#define intgtflg_c
#include "apptobuf.prt"
#include "appsndrc.prt"
#include "appclear.prt"
#include "appcli.prt"
#include "appid.prt"
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intgtflg.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_get_flags(
	int		*ansi_mode,
	int		*enable_dbms,
	int		*verify_mode,
	int		*blankstrip_mode,
	int		*autocommit,
	int		*autorename)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISint_get_flags()\n"));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET FLAGS\n");
		fprintf(RIS_RAP, "ansi_mode:0x%x\n", ansi_mode);
		fprintf(RIS_RAP, "enable_dbms:0x%x\n", enable_dbms);
		fprintf(RIS_RAP, "verify_mode:0x%x\n", verify_mode);
		fprintf(RIS_RAP, "blankstrip_mode:0x%x\n", blankstrip_mode);
		fprintf(RIS_RAP, "autocommit:0x%x\n", autocommit);
		fprintf(RIS_RAP, "autorename:0x%x\n", autorename);
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

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}
	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	RISapp_opcode_to_buf(RISCLI_GET_FLAGS_CODE, SYNC_MODE);
	RISapp_send_rec();

	if (ansi_mode)
	{
		*ansi_mode = RIS_read->buf.get_flags.ansi_mode;
	}
	if (enable_dbms)
	{
		*enable_dbms = RIS_read->buf.get_flags.enable_dbms;
	}
	if (verify_mode)
	{
		*verify_mode = RIS_read->buf.get_flags.verify_mode;
	}
	if (blankstrip_mode)
	{
		*blankstrip_mode = RIS_read->buf.get_flags.blankstrip_mode;
	}
	if (autocommit)
	{
		*autocommit = RIS_read->buf.get_flags.autocommit;
	}
	if (autorename)
	{
		*autorename = RIS_read->buf.get_flags.autorename;
	}

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISint_get_flags: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXget_ansi_mode(
	int	*ansi_mode)
{
	RISXint_get_flags(ansi_mode, NULL, NULL, NULL, NULL, NULL);
}

/******************************************************************************/

extern void RISAPI RISXget_enabled_databases(
	int	*enable_dbms)
{
	RISXint_get_flags(NULL, enable_dbms, NULL, NULL, NULL, NULL);
}

/******************************************************************************/

extern void RISAPI RISXget_verify_mode(
	int	*verify_mode)
{
	RISXint_get_flags(NULL, NULL, verify_mode, NULL, NULL, NULL);
}

/******************************************************************************/

extern void RISAPI RISXget_blankstrip_mode(
	int	*blankstrip_mode)
{
	RISXint_get_flags(NULL, NULL, NULL, blankstrip_mode, NULL, NULL);
}

/******************************************************************************/
extern void RISAPI RISXget_autocommit_mode(
	int	*autocommit)
{
	RISXint_get_flags(NULL, NULL, NULL, NULL, autocommit, NULL);
}

/******************************************************************************/
extern void RISAPI RISXget_autorename_mode(
	int	*autorename)
{
	RISXint_get_flags(NULL, NULL, NULL, NULL, NULL, autorename);
}

/******************************************************************************/
