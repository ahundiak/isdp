/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshprm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
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
#define utlshprm_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "utlshprm.prt"
#include "utlerror.prt"
#include "ucoshprm.prt"
#include "utlprint.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_parameters()
{
	UTL_DBG(("RISutl_show_parameters()\n"));

	RISuco_show_parameters(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_parameters:complete\n"));
}

/******************************************************************************/
