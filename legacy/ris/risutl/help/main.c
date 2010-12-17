/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							hlpmain.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					3/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "risstjmp.h"
#include "risutl.h"
#include "utl_inf.h"
#include "ris.h"

/*
**	DEFINES
*/
#define HLP_DBG(s)	if (RIShlp_debug) {RIScom_output_debug s;}
#define STRING(s)	((s)?(s):"NULL")

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define main_c
#include "main.prt"
#include "hlpdsply.prt"
#include "comjmp.prt"
#include "ucoerrbx.prt"
#include "ucodebug.prt"
#include "ucoumsg.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
int RIShlp_debug = 0;
debug_info_s debug_info[] =
{
	{ "hlp", 3, &RIShlp_debug }
};
int debug_count = sizeof(debug_info)/sizeof(debug_info_s);


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int main()
{
	int		status;

	if ((status = SETJMP()))
	{
		RESETJMP();
		RISuco_file_error_box(stdout,RISUTL_I_HELP_ERROR,0,status,NULL,0,1);
		return -1;
	}

	RISuco_initialize_debug(debug_info, debug_count);

	RISuco_initialize_ums(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE);

	RIShlp_display_help();

	RESETJMP();
	return 0;
}

/******************************************************************************/
