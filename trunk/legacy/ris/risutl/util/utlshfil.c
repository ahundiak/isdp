/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshfil.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
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
#define utlshfil_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlshfil.prt"
#include "utlerror.prt"
#include "utlprint.prt"
#include "ucoshfil.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_schfile(
	void)
{
	UTL_DBG(("RISutl_show_schfile()\n"));

	RISuco_show_schfile(RISutl_printf);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_show_schfile: complete\n"));
}

/******************************************************************************/

extern void RISutl_schema_file_checksum()
{
	UTL_DBG(("RISutl_schema_file_checksum()\n"));

	RISrestore_schema_file_checksum();
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	UTL_DBG(("RISutl_schema_file_checksum:returning\n"));
}

/******************************************************************************/
