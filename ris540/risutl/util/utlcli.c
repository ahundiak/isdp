/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlcli.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "util.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define utlcli_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "utlclear.prt"
#include "utlcli.prt"
#include "utlerror.prt"
#include "utlprint.prt"
#include "ris.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_start_client(
	void)
{
	UTL_DBG(("RISutl_start_client()\n"));

	RISstart_client();
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_start_client:returning\n"));
}

/******************************************************************************/

extern void RISutl_stop_client(
	void)
{
	UTL_DBG(("RISutl_stop_client()\n"));
		
	RISstop_client();
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	RISutl_clear_all_util_stmts();

	UTL_DBG(("RISutl_stop_client:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_cli_hash_table(
	void)
{
	UTL_DBG(("RISutl_show_cli_hash_table()\n"));

	RISint_show_cli_hash_table(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_cli_hash_table:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_cli_servers(
	void)
{
	UTL_DBG(("RISutl_show_cli_servers()\n"));

	RISint_show_cli_servers(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_cli_servers:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_cli_struct_mgrs(
	void)
{
	UTL_DBG(("RISutl_show_cli_struct_mgrs()\n"));

	RISint_show_cli_struct_mgrs(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_cli_struct_mgrs:returning\n"));
}

/******************************************************************************/
