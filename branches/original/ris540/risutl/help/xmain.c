/*
**	NAME:							xmain.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					3/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include <helpif.h>
#include "risver.h"
#include "riscom.h"
#include "risstjmp.h"
#include "risprods.h"
#include "risutl.h"
#include "utl_inf.h"
#include "utl_err.h"
#include "ris_err.h"
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
#define xmain_c
#include "xmain.prt"
#include "hlpdsply.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "comdebug.prt"
#include "ucoerrbx.prt"
#include "ucodebug.prt"
#include "ucoumsg.prt"
#include "hlp.prt"
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

extern int main(
	int		argc,
	char	*argv[])
{
	int		sts;
	int		i;
	char	*display_ptr;
	static char env_buf[80];

	if ((sts = SETJMP()))
	{
		RESETJMP();
		RISuco_file_error_box(stdout,RISUTL_I_HELP_ERROR,0,sts,NULL,0,1);
		return -1;
	}

	RISuco_initialize_debug(debug_info, debug_count);

	RISuco_initialize_ums(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE);

	if (!(display_ptr = getenv("DISPLAY")))
	{
		HLP_DBG(("environment variable DISPLAY is not defined; "));
		display_ptr = "unix:0.0";
	}

	if (argc == 2)
	{
		if (strcmp(argv[1], "-V") == 0)
		{
			/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
			/* 1996.03.12:Alan Barksdale:TR439600483 */
			PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
			PRINTF(" ");
			PRINTF(COPYRIGHTYEAR);
			PRINTF(", ");
			PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
			PRINTF(MSG(RISUTL_I_XRISHELP_VERSION), RIS_version);
			return(0);
		}
		if (strcmp(argv[1], "-?") == 0)
		{
			PRINTF(MSG(RISUTL_I_XRISHELP_USAGE));
			PRINTF(MSG(RISUTL_I_XRISHELP_USAGE_1));
			PRINTF(MSG(RISUTL_I_XRISHELP_USAGE_2));
			PRINTF(MSG(RISUTL_I_XRISHELP_USAGE_3));
			return(0);
		}
		else
		{
			fprintf(stderr,MSG(RISUTL_I_INVALID_OPTION), argv[0], argv[1]);
			fprintf(stderr,MSG(RISUTL_I_XRISHELP_USAGE));
			return(1);
		}
	}

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i],"-display") == 0)
		{
			if (i+1 == argc)
			{
				/* node name is not provided */
				fprintf(stderr,MSG(RISUTL_I_INVALID_OPTION), argv[0], argv[i]);
				fprintf(stderr,MSG(RISUTL_I_XRISHELP_USAGE));
				return(1);
			}
			sprintf(env_buf,"DISPLAY=%s",argv[++i]);
			putenv(env_buf);
			display_ptr = getenv("DISPLAY");
			HLP_DBG(("command line option -display %s\n", display_ptr));
		}
		else
		{
			fprintf(stderr,MSG(RISUTL_I_INVALID_OPTION), argv[0], argv[i]);
			fprintf(stderr,MSG(RISUTL_I_XRISHELP_USAGE));
			return(1);
		}
	}

	if ((Help_set_Xdisplay(display_ptr)) != HP_SUCCESS)
	{
		char display_string[80];
		sprintf(display_string, "DISPLAY=\"%s\"", display_ptr);
		RISuco_file_error_box(stdout, RISUTL_I_FORMS_ERROR, 0,
				RISUTL_E_OPEN_X_DISPLAY, display_string, 0, 1);
		return -1;
	}

	RIShlp_display_help();

	RESETJMP();
	return 0;
}

/******************************************************************************/
