/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshmem.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					12/92
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
#define utlshmem_c
#include "ris.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "utlshmem.prt"
#include "utlerror.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_app_memory(
	void)
{
	UTL_DBG(("RISutl_show_app_memory()\n"));

	RISint_show_app_memory(printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_app_memory:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_cli_memory(
	void)
{
	UTL_DBG(("RISutl_show_cli_memory()\n"));

	RISint_show_cli_memory(printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_cli_memory:returning\n"));
}

/******************************************************************************/
