/*
**	NAME:							utlshflg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
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
#define utlshflg_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "utlshflg.prt"
#include "utlerror.prt"
#include "ris.prt"
#include "utlprint.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_flags(
	void)
{
	int ansi_mode = 0;
	int verify_mode = 0;
	int autocommit_mode = 0;
	int blankstrip_mode = 0;
	int autorename_mode = 0;
	int	enable_dbms = 0;

	UTL_DBG(("RISutl_show_flags()\n"));

	RISint_get_flags(&ansi_mode, &enable_dbms, &verify_mode,
		&blankstrip_mode, &autocommit_mode, &autorename_mode);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_1), ansi_mode?"ON":"OFF");
	RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_2), verify_mode?"ON":"OFF");
	RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_13), blankstrip_mode?"ON":"OFF");
	RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_3), autocommit_mode?"ON":"OFF");
	RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_14), autorename_mode?"ON":"OFF");

	if (IS_INFORMIX_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_4));
	if (IS_ORACLE_ENABLED(enable_dbms))		
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_5));
	if (IS_INGRES_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_6));
	if (IS_DB2_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_7));
	if (IS_RDB_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_8));
	if (IS_SYBASE_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_9));
	if (IS_SQLDS_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_10));
	if (IS_ADABAS_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_11));
	if (IS_OS400_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_12));
	if (IS_MSSQL_ENABLED(enable_dbms))
		RISutl_printf(MSG(RISUTL_I_SHOW_FLAGS_15));

	RISutl_printf("\n");

	UTL_DBG(("RISutl_show_flags:complete\n"));
}

/******************************************************************************/
