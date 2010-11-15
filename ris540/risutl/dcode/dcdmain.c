/*
**	NAME:							dcdmain.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#include "riscom.h"
#include "risver.h"
#include "util.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/
#define UMS_MASK	(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE|INIT_NET_UMS_FILE)
/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define dcdmain_c
#include "dcdmain.prt"
#include "sys.prt"

#include "comumsg.prt"
#include "comjmp.prt"
#include "ucodcode.prt"
#include "ucoerrbx.prt"
#include "ucofgets.prt"
#include "ucoumsg.prt"
#include "ucodebug.prt"
#if defined(WIN32S)
#include "btcerrbx.prt"
#endif 
#if defined(WIN32)
#include "ris.prt"
#include "ucoio.prt"
#endif

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/
extern int main(
	int argc,
	char *argv[])
{
	int status;
	char *arg;
	char buffer[80];
#if defined(WIN32S)
	char about[128];
#endif
	if ((status = SETJMP()) != 0)
	{
		RESETJMP();
#if defined(WIN32S)
		RIS32s_file_error_box(RISUTL_I_DCODE_ERROR,0,status,NULL,0,1);
#else
		RISuco_file_error_box(stdout,RISUTL_I_DCODE_ERROR,0,status,NULL,0,1);
#endif
		PRINTF(CHECK_UNINIT_MSG(RISUTL_I_DCODE_COULD_NOT_INIT,
			"RIS Decode Utility could not initialize... Bye\n"));
		return 1;
	}

	RISuco_initialize_debug(NULL, 0);
	RISuco_initialize_ums(UMS_MASK);
#if defined(WIN32S)
	winio_setfont(winio_current(),ANSI_FIXED_FONT);
	sprintf(about,MSG(RISUTL_I_DECODE_UTILITY), RIS_version);
	winio_about(about);
#endif

	do
	{
		if (argc == 1)
		{
			/* Prompt for the code */
			PRINTF(MSG(RISUTL_I_ENTER_DECODE_VALUE));
#if defined(WIN32S)
			GETS(buffer);
#else
			RISuco_fgets(buffer, 80, stdin);
#endif
			if (!buffer[0])
			{
#if defined(WIN32S)
				DestroyWindow(winio_current());
#endif
				break;
			}
			arg = buffer;
		}
		else
		{
			/*
			** The if statements were added to fix TR # 439502826.
			** The version and usage option was added. GBF (9/27/95)
			*/
#if defined(WIN32)
			if (!strcmp(argv[1],"-V") || !strcmp(argv[1],"/V"))
#else
			if (!strcmp(argv[1],"-V"))
#endif
			{
				DoVersion();
				return(0);
			} 
#if defined(WIN32)
			else if (!strcmp(argv[1],"-?") || !strcmp(argv[1],"/?"))
#else
			else if (!strcmp(argv[1],"-?"))
#endif
			{
				DoUsage();
				return(0);
			} 
			else
			{
				arg = argv[1];
			}
		}

		if (*arg == '\0' || *arg == '\n')
		{
			PRINTF("\n");
			break;
		}

		if (!RISuco_valid_code(arg, &status))
		{
			PRINTF(MSG(RISUTL_E_INVALID_CODE));
			PRINTF("\n");
		}
		else if (!RISuco_decode(status, PRINTF))
		{
			PRINTF(MSG(RISUTL_E_INV_CODE));
			PRINTF("\n");
		}

	} while(argc == 1);

	RESETJMP();
#if defined(WIN32S)
	winio_end();
#endif
	return 0;
}

/******************************************************************************/

static void DoVersion()
{
	/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
	/*/ 1996.03.12:Alan Barksdale:TR439600483 */
	PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
	PRINTF(" ");
	PRINTF(COPYRIGHTYEAR);
	PRINTF(", ");
	PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
	PRINTF(MSG(RISUTL_I_DECODE_UTILITY), RIS_version);
}

/******************************************************************************/

static void DoUsage()
{
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_1));
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_2));
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_3));
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_4));
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_5));
	PRINTF(MSG(RISUTL_I_DCODE_USAGE_6));
}

/******************************************************************************/
