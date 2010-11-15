/*
**	NAME:							intparms.c
**	AUTHORS:						Sanju Kapoor
**	CREATION DATE:					3/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
**
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intparms_c
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "intparms.prt"
#if defined(WIN32) || defined(DOS) || defined(__hpux__) || defined(sco)
#include "interror.prt"
#endif
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXint_upgrade_parms_file()
{

	INT_DBG(("RISint_upgrade_parms_file:\n"));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "UPGRADE PARAMETERS FILE\n");
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	/*
	**	RIS_upgrage_parms_file flag is turned on to update the parms file.
	*/
	RIS_upgrade_parms_file = 1;

	INT_DBG(("RISint_upgrade_parms_file: RIS_upgrade_parms_file %d\n",
		RIS_upgrade_parms_file));

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	INT_DBG(("RISint_upgrade_parms_file: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RIS_RETURN();
}

/******************************************************************************/
