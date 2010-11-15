/*
**	NAME:							intshcli.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					02/86
**	ABSTRACT:
**		The generic function to print client info returned in the buffer.
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include <string.h>
#include "intrface.h"
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
#define intshcli_c
#include "appcli.prt"
#include "appinit.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intshcli.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void show_client(
	int	(* output_func)(const char *, ...),
	unsigned char	opcode)
{
	int				sts;

	INT_DBG(("show_client(opcode:%d %s)\n", opcode, RIS_cli_codes[opcode]));

	RIS_CLEAR_ERROR();

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
	RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
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

	do
	{
		RISapp_opcode_to_buf(opcode, SYNC_MODE);
		RISapp_send_rec();
		output_func("%s", RIS_read->buf.string.data);
	}
	while(RIS_read->buf.string.more_to_follow);
		
	RESETJMP();

	INT_DBG(("show_client: complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXint_show_cli_memory(
	int	(* output_func)(const char *, ...))
{
	show_client(output_func, RISCLI_SHOW_MEMORY_CODE);
}

/******************************************************************************/

extern void RISAPI RISXint_show_cli_stmts(
	int	(* output_func)(const char *, ...))
{
	show_client(output_func, RISCLI_SHOW_STMTS_CODE);
}

/******************************************************************************/

extern void RISAPI RISXint_show_cli_hash_table(
	int	(* output_func)(const char *, ...))
{
	show_client(output_func, RISCLI_SHOW_HASH_TABLE_CODE);
}

/******************************************************************************/

extern void RISAPI RISXint_show_cli_servers(
	int	(* output_func)(const char *, ...))
{
	show_client(output_func, RISCLI_SHOW_SERVERS_CODE);
}

/******************************************************************************/

extern void RISAPI RISXint_show_cli_struct_mgrs(
	int	(* output_func)(const char *, ...))
{
	show_client(output_func, RISCLI_SHOW_STRUCT_MGRS_CODE);
}

/******************************************************************************/
