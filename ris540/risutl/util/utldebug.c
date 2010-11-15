/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							utldebug.c
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
#define utldebug_c
#include "comdebug.prt"
#include "ucodebug.prt"
#include "utldebug.prt"
#include "utlprint.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void RISutl_process_debug(
	char *str)
{
	RISuco_process_debug_string(str, RISutl_debug_info, RISutl_debug_count);
	UTL_WARNING_CHECK();

	RISuco_output_debug_flags(RISutl_printf, RISutl_debug_info,
		RISutl_debug_count);

	UTL_DBG(("RISutl_process_debug:returning\n"));
}

/******************************************************************************/
